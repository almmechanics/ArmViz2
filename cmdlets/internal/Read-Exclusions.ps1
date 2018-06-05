Set-StrictMode -Version Latest
function Read-Exclusions
{
    [CmdletBinding()]
    param
    (
        [string]
        $FileName
    )

    if (([string]::IsNullOrEmpty($FileName)))
    {
        Write-Verbose 'Loading exclusions' 
        $FileName = Join-path $configPath 'exclusion-defaults.json'    
    }
    return Get-Content $FileName -Raw | ConvertFrom-Json
}
