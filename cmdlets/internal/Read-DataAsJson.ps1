Set-StrictMode -Version Latest
function Read-DataAsJson
{
    [CmdletBinding()]
    param
    (
        [string]
        $FileName
    )

    if(([uri]$FileName).Scheme -eq 'file')
    {
        $data = (Get-Content $FileName -Raw) | ConvertFrom-Json 
    }
    else
    {
        $data = ((Invoke-WebRequest $FileName).content) | ConvertFrom-Json 
    }
    return $data
}