Set-StrictMode -Version Latest

function Publish-ArmGraph
{
    [CmdletBinding()]
    param(
        [string]
        $DotPath,
        [array]
        $GvData
    )

    #invoke graphviz engine
    $tempfile = ('{0}.gv' -f  (New-TemporaryFile).FullName )
    $GvData | out-file  $tempfile -Encoding ascii -Force
    
    
    $dotExe = Join-path $DotPath 'dot.exe'
    & $dotExe -v -O $tempfile -Tpdf

    Write-Host ($tempfile+'.pdf')
}