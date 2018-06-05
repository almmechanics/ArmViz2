Set-StrictMode -Version Latest
function Add-GVSubcluster
{
    [CmdletBinding()]
    param(
        [string]
        $Name
    )

    $data = @( "subgraph cluster_{0} {{" -f $Name.Replace('-','_'))
    $data += @( 'label = "{0}";' -f $Name )

    return $data
}