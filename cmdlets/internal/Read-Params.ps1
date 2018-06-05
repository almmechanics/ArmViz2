Set-StrictMode -Version Latest

function Read-Params
{
    [CmdletBinding()]
    param
    (
    )

    $paramsFile = Join-path $configPath 'parameter-lookup.json' -Resolve        
    $paramDataRaw = (get-content $paramsFile) | ConvertFrom-Json

    $paramNamelookup = @{}
       (@($paramDataRaw | Get-Member -MemberType NoteProperty).name) | ForEach-Object {
        $paramNamelookup[$_] = $paramDataRaw.$_
    }    
    return $paramNamelookup
}