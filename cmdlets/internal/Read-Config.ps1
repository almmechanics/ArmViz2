Set-StrictMode -Version Latest
function Read-Config
{
    [CmdletBinding()]
    param
    (
        [string]
        $FileName
    )

    if (([string]::IsNullOrEmpty($FileName)))
    {
        Write-Verbose 'Loading default config' 
        $FileName = Join-path $configPath 'graphviz.json' -Resolve    
    }
    $configDataRaw = Get-Content $FileName -Raw | ConvertFrom-Json


    $config = @{}
    (@($configDataRaw | Get-Member -MemberType NoteProperty).name) | ForEach-Object {
        $config[$_] = $configDataRaw.$_
    }    
    return $config
}