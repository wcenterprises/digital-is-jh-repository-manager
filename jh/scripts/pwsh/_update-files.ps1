[CmdletBinding()]
param(
  [string]$Project,
  [string]$RootDirectory
)
if (-not "$($env:GH_TOKEN)") {
  write-output "::error::GH_TOKEN environement variable not found."
  throw "GH_TOKEN environement variable not found."
}

$filesScannedCount=0
$filesUpdatedCount=0
try {
  get-childitem $RootDirectory -file -recurse | foreach-object {
    $filesScannedCount++
    $fileContent = get-content $_
    $newContent = $fileContent `
      -replace '(Jh\.Template\.(.*))', "$($project.name).$2" `
      -replace '\[REPO(SITORY|\-NAME)\]',"$($projet.repository)" `
      -replace '\[SOLUTION\-NAME)\]',"$($projet.solution)" `
      -replace '\[PROJECT\-NAME)\]', "$($project.name)" `
      -replace '\[CODE(OWNERS|\-OWNERS)\]', "$($project.codeowners | foreach-object { "$($_.path) $($_.owners)" }) -join ""`n"")"
    if ($newContent -ne $newContent) {
      $filesUpdatedCount++
      $newContent | out-file $_.fullname
    }
  }  
}
catch {
  write-output "::error::Error updating files!"
  write-output "::error::$($_.message)"
  throw
}
finally {
  <#Do this after the try block regardless of whether an exception occurred or not#>
}

write-output "files-scanned=$filesScannedCount" >> $env:GITHUB_OUTPUT
write-output "files-scanned=$filesScannedCount" >> $env:GITHUB_ENV

write-output "files-updated=$filesScannedUpdated" >> $env:GITHUB_OUTPUT
write-output "files-updated=$filesScannedUpdated" >> $env:GITHUB_ENV



