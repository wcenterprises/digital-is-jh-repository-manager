
param(
  [string]$Project,
  [string]$RootDirectory
)
if (-not "$($env:GH_TOKEN)") {
  write-host "::error::GH_TOKEN environement variable not found."
  throw "GH_TOKEN environement variable not found."
}

try {
  $rootItem=get-item $RootDirectory

  get-childitem $rootItem -file -recurse | where-object { $_.name -match '^Jh\.Template\.(.*)?' } | foreach-object {
    rename-item $_ -newname $($_.name -replace 'Jh\.Template\.(.*)', "$(project.name).`$1")
  }
}
catch {
  write-output "::error::Error renaming directories!"
  write-output "::error::$($_.message)"
  throw
}
finally {
  <#Do this after the try block regardless of whether an exception occurred or not#>
}