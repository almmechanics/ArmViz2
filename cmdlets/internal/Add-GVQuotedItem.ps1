Set-StrictMode -Version Latest
function Add-GVQuotedItem
{
    [CmdletBinding()]
    param(
        [string]
        $Item
    )
    
    return   @( '"{0}";' -f $Item)
}