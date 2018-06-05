Set-StrictMode -Version Latest
function Read-ImageLookup
{
    [CmdletBinding()]
    param
    (
    )

    $images = @{}
    $lookupFile = Join-path $configPath 'images-lookup.json' -Resolve        
    $lookupRaw = (Get-Content $lookupFile -Raw | ConvertFrom-Json) 
    (@($lookupRaw | Get-Member -MemberType NoteProperty).name) | ForEach-Object {
        $images[$_] = Join-Path $imagesPath $lookupRaw.$_
    }    

    return $images
}