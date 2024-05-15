[CmdletBinding()]
param(
  [string]$Path,
  [string]$DestinationPath
)

$saveLocation = get-location
try {  
  copy-item -Path "$(.\$Path)\*.*" -Destination "$($DestinationPath)" -Recurse -Force -include *.*
  set-location $DestinationPath
  git checkout -b init/repo
  git add -A
  git commit -a -m "inital code commit"
  git push origin init/repo
}
catch {
  write-output "::error::An error occured copying files."
  write-output "::error::$($_.message)"
  throw
}
finally {
  set-location $saveLocation
}