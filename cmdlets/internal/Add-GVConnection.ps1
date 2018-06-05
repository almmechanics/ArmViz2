Set-StrictMode -Version Latest
function Add-GVConnection
{
    [CmdletBinding()]
    param(
        [string]
        $From,
        [string]
        $To,
        [hashtable]
        $Options
        
    )
    

    $gvoptions = @()
    $options.Keys | ForEach-Object {
        $gvoptions += @('"{0}"="{1}"' -f $_, $Options[$_])
    }

    return ('"{0}"--"{1}" [{2}];' -f $From , $To, ($gvoptions -join ',') )
}