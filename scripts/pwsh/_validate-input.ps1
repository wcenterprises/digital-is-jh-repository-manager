[CmdletBinding()]
param(
  [Parameter(mandatory=$true)]
  [string]$sha,
  [string]$EventName,
  [string]$EventBefore,
  [string]$EventAfter  
)

function Test-Repository {
  [CmdletBinding()]
  param(
    [string]$owner=${env:GITHUB_REPOSITORY_OWNER},
    [string]$name
  ) 
  $result=gh api `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    /repos/$owner/$name | convertfrom-json

  return ("$($result.full_name)" -ne "")
}

$projects=@() # Start up an array

try {
  $items=$(
    if ($EventName -eq 'pull_request') {
      $(git diff --name-only -r HEAD^1 HEAD)
    } else {
      $(git diff --name-only $EventBefore $EventAfter)
    }) -split "`r?`n"
    
  # We only want the .json files
  $files=($items | where-object { $_ -match '\.json$' })
  $files | foreach-object {
    write-output "::debug::Item: $($_)"
    if (test-path $_) {
      $item=get-item $_
      $project=(get-content $item | convertfrom-json)
      $project
      $project | add-member -notepropertyname repository -notepropertyvalue "$("digital-is-$($project.name.tolower() -replace '\.','-' -replace ' ', '-')")"
      if ($project.modifier) {
        $project.repository+="-$($project.modifier.tolower())"
      }
      if (test-repository -name $project.repository) {
        write-output "::warning::Repository `"$($project.repository)`" already exists. Skipping!"
      }
      else {
        $projects += $project
      }
      
    }
  }
  if (-not $files -or ($projects.count -eq 0)) {
    write-output "::notice::No input files found. Nothing to do."
  }
}
catch {
  write-output "::error::Error processing incoming files!"
  throw
}
finally {
}

write-output "projects=$($projects|convertto-json -compress -depth 5)" >> $env:GITHUB_OUTPUT

