Set-StrictMode -Version Latest
function New-GVHeader
{
    [CmdletBinding()]
    param(
    )
    
    $data = @( 'graph g{')
    $data += @( 'rankdir=LR;')
    $data += @( 'node [shape = Mrecord];')

    return $data
}