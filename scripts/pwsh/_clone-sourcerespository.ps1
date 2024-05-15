[CmdletBinding()]
param(
  [string]$repository
)
if (-not "$($env:GH_TOKEN)") {
  write-host "::error::GH_TOKEN environement variable not found."
  throw "GH_TOKEN environement variable not found."
}
$saveLocation = get-location

$item=$null

try {
  $repositoryName = $repository -replace 'wcenterprises/',''
  gh repo clone $repository
  $item = get-item $repositoryName
}
catch {
  write-host "::error::An error occured cloning the source repository $($repository)"
  write-host "::error::$($_.message)"
  throw
}
finally {
  set-location $saveLocation
}
write-output "source-directory=$($item.fullname)" >> $env:GITHUB_OUTPUT
write-output "source-directory=$($item.fullname)" >> $env:GITHUB_ENV
$item

