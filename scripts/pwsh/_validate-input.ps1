[CmdletBinding()]
param(
  [Parameter(mandatory=$true)]
  [string]$sha,
  [string]$EventName,
  [string]$EventBefore,
  [string]$EventAfter
  
)

function Get-Repository {
  [CmdletBinding()]
  param(
    [string]$owner,
    [string]$name
  )
  gh api `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    /repos/$owner/$name | ConvertFrom-Json
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
    $item=get-item $_
    $project=(get-content $item | convertfrom-json)
    $project
    $project | add-member -notepropertyname repository -notepropertyvalue "$("digital-is-$($project.name.tolower() -replace '\.','-' -replace ' ', '-')")"
    $projects += $project

    write-host "--- check for previous"
    if (-not $((Get-Repository -owner "wcenterprises" -name $project.repository).message)) {
      write-host "::error::Duplicate repository name found $($project.repository)"
      exit 1
    }

  }
  if (-not $files) {
    throw "No json files detected incoming!"
  }
  if ($projects.count -eq 0) {
    throw "No projects collected!"
  }
}
catch {
  write-output "::error::Error processing incoming files!"
  throw
}
finally {
}

write-output "projects=$($projects|convertto-json -compress -depth 5)" >> $env:GITHUB_OUTPUT

