Set-StrictMode -Version Latest
$cmdletsPath = Join-Path $PSScriptRoot 'cmdlets'

$interfacePath = Join-Path $cmdletsPath 'interface'
. (Join-Path $interfacePath 'Invoke-ArmGraph.ps1')

$internalPath = Join-Path $cmdletsPath 'internal'
. (Join-Path $internalPath 'Read-Config.ps1')
. (Join-Path $internalPath 'Read-Params.ps1')
. (Join-Path $internalPath 'Read-ImageLookup.ps1')
. (Join-Path $internalPath 'Read-Exclusions.ps1')
. (Join-Path $internalPath 'Publish-ArmGraph.ps1')
. (Join-Path $internalPath 'New-GVHeader.ps1')
. (Join-Path $internalPath 'Add-GVEndSection.ps1')
. (Join-Path $internalPath 'Add-GVSubCluster.ps1')
. (Join-Path $internalPath 'Add-GVQuotedItem.ps1')
. (Join-Path $internalPath 'Add-GVConnection.ps1')
. (Join-Path $internalPath 'Read-DataAsJson.ps1')

$configPath = Join-Path $PSScriptRoot 'config'

$imagesPath = Join-Path $PSScriptRoot 'images'