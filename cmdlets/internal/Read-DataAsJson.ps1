Set-StrictMode -Version Latest
function Read-DataAsJson
{
    [CmdletBinding()]
    param
    (
        [string]
        $FileName
    )

    # Determine if the FileName is absolute
    # URLs will return True so this is safe for all tests
    $is_rooted = Split-Path -Path $FileName -IsAbsolute

    # If the path is not rooted resolve the path
    # The path has to be absolute for the URI scheme to work
    if (!$is_rooted)
    {
        # Attempt to resolve the path
        $resolved = Resolve-Path -Path $Filename -ErrorAction SilentlyContinue

        # If the filename is empty the file does not exist
        if ([String]::IsNullOrEmpty($resolved))
        {
            $message = "Data file cannot be found: {0}" -f $FileName
            throw $message
        } else {
            $Filename = $resolved
        }
    }

    # Get the scheme of the file
    $scheme = ([uri]$Filename).Scheme

    # Get the content of the file
    # Select the best operation based on the type of file
    switch -wildcard ($scheme)
    {
        "file"
        {
            # Ensure that the specified file exists
            if (!(Test-Path -Path $Filename))
            {
                $message = "Data file cannot be found: {0}" -f $FileName
                throw $message
            }

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