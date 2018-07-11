Set-StrictMode -Version Latest
function Read-DataAsJson
{
    [CmdletBinding()]
    param
    (
        [string]
        $FileName
    )

    # Ensure that the specified file exists
    if (!(Test-Path -Path $Filename))
    {
        $message = "Data file cannot be found: {0}" -f $FileName
        throw $message

    } else {

        # Resolve the path so it is an absolute path
        # This is required to ensure that the URI scheme works properly
        $Filename = Resolve-Path -Path $Filename
    }

    # Get the content of the file
    # Select the best operation based on the type of file
    $scheme = ([uri]$Filename).Scheme
    switch -wildcard ($scheme)
    {
        "file"
        {
            $data = (Get-Content $FileName -Raw) | ConvertFrom-Json
        }
        "http[s]"
        {
            $data = ((Invoke-WebRequest $FileName).content) | ConvertFrom-Json
        }
        default {
            $message = "The source of the specified data file is not supported: {0}" -f $scheme
            throw $message
        }
    }

    return $data
}