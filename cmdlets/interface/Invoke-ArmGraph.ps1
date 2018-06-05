Set-StrictMode -Version Latest
function Invoke-ArmGraph
{
    [CmdletBinding()]
    param
    (
        [string]
        $configFile,
        [string]
        $exclusionsFile,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_})]
        [string]
        $inputFile = 'C:\dev\vsts\armviz-data\mainTemplate20180604.json'
    )

    $VerbosePreference="Continue"

    # read config 
    $configData = Read-Config -FileName $configFile
    
    # read exclusions
    $exclusions = Read-exclusions -filename $exclusionsFile 

    # read params
    $paramNamelookup = Read-Params

    # read params
    $images = Read-ImageLookup

    $data = (Get-Content $inputFile -Raw) | ConvertFrom-Json 

    $items = @{}
    $dependencies = @{}
    
    $data.properties.additionalProperties.validatedResources | ForEach-Object {
        
        $template = [string]::Empty
        $templateVersion = [string]::Empty
        if  ($_.properties | Get-Member -Name 'templateLink')
        {        
            $template = ($_.properties.templateLink.uri)
            $templateVersion = $_.properties.templateLink.contentVersion
            Write-Warning 'adding implied dependency'
        
            $propertyname = $paramNamelookup[($template | Split-Path -Leaf)]
        
            $value = $_.properties.parameters.($propertyname).value
            if ($dependencies.ContainsKey($_.name))
            {
                $dependencies[$_.name] +=@($value)
            }
            else
            {
                $dependencies[$_.name] = @($value)
            }
        
            Write-verbose ('Processing: {0}' -f $value)
            if (!($items.ContainsKey($value)))
            {
                #Write-Error $value
                $guessType = [string]::Empty
                if ($value.EndsWith('-NSG')){$guessType = "Microsoft.Network/networkSecurityGroups"}
                if ($value.EndsWith('-NIC')){$guessType = "Microsoft.Network/networkInterfaces"}
                if ($value.EndsWith('-PublicIP')){$guessType = "Microsoft.Network/publicIPAddresses"}
                if ($value.EndsWith('-VM')){$guessType = "Microsoft.Compute/virtualMachine"}
                if ($value.EndsWith('AppServicePlan')){$guessType = "Microsoft.Web/serverfarms"}
    
                $Object = New-Object PSObject -Property @{   
                    Name       = $value
                    Type       = $guessType
                    ResourceGroup = $_.ResourceGroup
                    Properties   = $_.Properties
                } 
                $items[$value] = $Object
            }   
        } 
    
        $Object = New-Object PSObject -Property @{   
            Name       = $_.name
            Type       = $_.type
            ResourceGroup = $_.ResourceGroup
            Properties   = $_.Properties
            template = $template
            templateVersion = $templateVersion
            resourcetype= (($_.id -split('/'))[6])
    
        }       
    
        $items[$_.name] = $Object
    
        if ($_ | get-member -Name dependson)
        {
            foreach ($dependency in $_.dependson)
            {
                $leaf = ($dependency | Split-Path -Leaf)
                if ($dependencies.ContainsKey($_.name))
                {
                    $dependencies[$_.name] +=@($leaf)
                }
                else
                {
                    $dependencies[$_.name] = @($leaf)
                }
            }
        }
    }
    
    $resourcegroups = @($items.Keys | ForEach-Object {$items[$_].resourcegroup} | Sort-Object -Unique)
    
    $gvdata = New-GvHeader
        
    foreach ($resourcegroup in $resourcegroups)
    {
        $gvdata += Add-GVSubcluster -Name $resourcegroup

        @($items.Keys | where-Object {$items[$_].resourcegroup -eq $resourcegroup }) | ForEach-Object {
    
            $item = $items[$_]
            $replacement = $images[$item.Type]

            $propertyrows = @()

            if ($item | get-member Properties)
            {
                Write-Warning $item.Name
                $dataset = @(($item.Properties | Get-Member -MemberType NoteProperty).Name | Where-Object {($_ -ne 'mode') -and ($_ -ne 'templateLink') -and ($_ -ne 'template') } ) 

                foreach ($dataitem in $dataset)
                {
                    $content = @($item.Properties.$dataitem)

                    $content | ForEach-Object {

                        if ($_.GetType().Name -eq 'String')
                        {
                            $propertyrows += @('<tr><td>{0}</td><td>{1}</td></tr>' -f $dataitem, $_)
                        }
                        else
                        {
                            $columns = (@(($_ | gm -MemberType NoteProperty).Name) | Where-Object {$_ -ne 'properties'})

                            foreach ($column in $columns)
                            {
                                if ($exclusions.Contains($column))
                                {
                                    Write-Warning ('{0} is in the exclusions list' -f $column)
                                    $propertyrows += @('<tr><td ALIGN="Right">{0}</td><td ALIGN="Left"><i>{1}</i></td></tr>' -f $column, 'automatically excluded')
                                }
                                else
                                {
                                    Write-Verbose('Using  {0}:{1}' -f $dataitem, $column)                                
                                    if (($_.($column)) | get-member value)
                                    {
        
                                        $propertyrows += @('<tr><td ALIGN="Right">{0}</td><td ALIGN="Left">{1}</td></tr>' -f $column, ((($_.($column)).value).tostring().replace('{','\{').replace('}','\}')))
                                    }
                                    else
                                    {
                                        $propertyrows += @('<tr><td ALIGN="Right">{0}</td><td ALIGN="Left">{1}</td></tr>' -f $column, (($_.($column)).replace('{','\{').replace('}','\}')))
                                    }
                                }
                            }
                        } 
                    }
                    
                }                   
            }
                

            $gvdata += @('"{1}" [label=< <table border="0" CELLBORDER="1" ><tr><td BORDER="0" align = "Center" colspan="2" fixedsize="true" width="50" height="50"><img src="{0}" /></td></tr><tr><td colspan="2"><b>{1}</b></td></tr>{2}</table> >];' -f $replacement,$_, [string]::Join('',$propertyrows))
            $gvdata += (Add-GvQuotedItem -Item $_)
        }
    
        $gvdata += Add-GVEndSection
    }
    
    $items.Keys | ForEach-Object {
        $subs = @($dependencies[$_])
        foreach ($sub in $subs)
        {
            if (!([string]::IsNullOrEmpty($sub)))
            {
                if  (($items[($_)].properties | Get-Member -Name 'templateLink') -and ($items[($sub)].properties | Get-Member -Name 'templateLink'))
                {
                    $Options =  @{'color'='blue'}
                }
                else
                {
                    $Options =  @{'color'='blue';'style'='bold'}
                }   
                $gvdata += Add-GVConnection -From $_ -To $sub -Options $Options
            }
        }
    }
    $gvdata += Add-GVEndSection
    
    Publish-ArmGraph -DotPath ($configData.dotfolder) -GvData $gvdata
}