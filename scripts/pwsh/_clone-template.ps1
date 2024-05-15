[CmdletBinding()]
param(
  $Project,
  [string]$template='wcenterprises/digital-is-jh-service-template'
)
if (-not "$($env:GH_TOKEN)") {
  write-host "::error::GH_TOKEN environement variable not found."
  throw "GH_TOKEN environement variable not found."
}

$README_TEMPLATE=@"
| | Status |
|:---|:---|
| Build | [![ CI ](https://github.com/wcenterprises/$($project.repository)/actions/workflows/ci.yml/badge.svg)](https://github.com/wcenterprises/$($project.repository)/actions/workflows/ci.yml) |
| Unit Tests | [![ Unit Tests ](https://github.com/wcenterprises/$($project.repository)/actions/workflows/unit-tests.yml/badge.svg)](https://github.com/wcenterprises/$($project.repository)/actions/workflows/unit-tests.yml)|
| CodeQL | [![ CodeQL ](https://github.com/wcenterprises/$($project.repository)/actions/workflows/codeql.yml/badge.svg)](https://github.com/wcenterprises/$($project.repository)/actions/workflows/codeql.yml)|

---

---

_Generated: $(Get-Date) by @$($env:GITHUB_ACTOR)_"
"@


function Get-Repository {
  [CmdletBinding()]
  param(
    [string]$owner,
    [string]$name
  )

  # GitHub CLI api
  # https://cli.github.com/manual/gh_api

  gh api `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    /repos/$owner/$name | ConvertFrom-Json
}


function Update-BranchProtection {
  gh api `
    --method PUT `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    /repos/wcenterprises/$($project.repository)/branches/main/protection `
      -F "required_status_checks[strict]=true" `
      -F "required_status_checks[checks][][context]=pull-request-validation" `
      -F "required_status_checks[checks][][app_id]=15368" `
      -F "enforce_admins=false" `
      -F "required_pull_request_reviews[dismiss_stale_reviews]=true" `
      -F "required_pull_request_reviews[require_code_owner_reviews]=true" `
      -F "required_pull_request_reviews[required_approving_review_count]=2" `
      -F "required_pull_request_reviews[require_last_push_approval]=true" `
      -f "bypass_pull_request_allowances[teams[]]=digital-is-super-users" `
      -F "restrictions=null" `
      -F "required_linear_history=true" `
      -F "allow_force_pushes=true" `
      -F "allow_merge_commits=false" `
      -F "allow_deletions=true" `
      -F "block_creations=true" `
      -F "required_conversation_resolution=true" 
}

function Set-RepositoryTeam {
  [CmdletBinding()]
  param(
    [string]$teamName,
    [string]$permission
  )  
  gh api `
    --method PUT `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    /orgs/wcenterprises/teams/$teamName/repos/wcenterprises/$($project.repository) `
      -f permission="$permission"
}

function Update-RepositoryProperties {
  gh api `
    --method PATCH `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    /repos/wcenterprises/$($project.repository) `
      -F "has_issues=false" `
      -F "has_projects=true" `
      -F "delete_branch_on_merge=true" `
      -F "allow_merge_commit=false" `
      -F "allow_squash_merge=true" `
      -F "allow_rebase_merge=true" `
      -F "allow_auto_merge=true" `
      -F "squash_merge_commit_title=PR_TITLE" `
      -F "squash_merge_commit_message=PR_BODY" `
      -F "has_wiki=true" `
      -F "security_and_analysis[advanced_security][status]=enabled" `
      -F "security_and_analysis[secret_scanning][status]=enabled"
}

function Convert-ContentTokens {
  param(
    $content
  )  
    $content -replace '\[DATE\]', (get-date).ToString() `
      -replace '\[PROJECT\-NAME\]', $($project.name) `
      -replace '\[SOLUTION\-NAME\]', $($project.solution) `
      -replace '\[REPO\-NAME\]', $($project.repository) `
      -replace  '\[CODE\-OWNERS\]', "$($project.codeowners -join " ")"
}

function Update-ActionVariable {
  param(
    [string]$variableName,
    [string]$variableValue
  )
  write-host "------ setting variable $variableName (value: $variableValue)"
  gh variable set $variableName --body $variableValue --repo wcenterprises/$($project.repository)  
}

$DESCRIPTION="Created by repo-manager, $((get-date -AsUTC).tostring("yyy-MM-dd HH:mm")) submitted by @$($env:GITHUB_ACTOR), Jira-Ticket: $($project.jira_ticket)"

$saveLocation = get-location

$item=$null

try {

  if (-not $((Get-Repository -owner "wcenterprises" -name $project.repository).message)) {
    write-host "::error::Duplicate repository name detected $($project.repository)"
    exit 1
  }

  write-host "--- creating repository wcenterprises/$($project.repository)"
  gh repo create wcenterprises/$($project.repository) --private --template $template --clone --description $DESCRIPTION
  $item=get-item $($project.repository)
  set-location $item

  write-host "--- adding topics"
  gh repo edit "wcenterprises/$($project.repository)" --add-topic "tvm-219898-219901"
  gh repo edit "wcenterprises/$($project.repository)" --add-topic "dotnet"

  write-host "--- adding teams standard teams"
  Set-RepositoryTeam -teamName "digital-is-build" -permission "admin"
  Set-RepositoryTeam -teamName "digital-is-superuser" -permission "push"
  
  write-host "--- adding team $($_)"
  $project.teams | foreach-object {
    Set-RepositoryTeam -teamName "$($_)" -permission "push"
  }

  $files=get-childitem -Recurse -include 'Dockerfile','CODEOWNERS','*.yml','README.md'
  $files | foreach-object {
    write-host "--- updating file $(resolve-path $_.fullname -Relative)" -ForegroundColor Blue
    $resultcontent=get-content $_.fullname
    $alteredcontent=Convert-ContentTokens -content:$resultcontent
    $alteredcontent | out-file $_.fullname -force
  }

  write-host "--- adding variable JH_PROJECT_NAME" 
  Update-ActionVariable -variableName "JH_PROJECT_NAME" -variableValue "$($project.name)"

  write-host "--- adding variable JH_SOLUTION_NAME"
  Update-ActionVariable -variableName "JH_SOLUTION_NAME" -variableValue "$($project.solution)"

  write-host "--- adding variable PACKAGE_UPDATE_JIRA_TICKET"
  Update-ActionVariable -variableName "PACKAGE_UPDATE_JIRA_TICKET" -variableValue "BSL-2921"

  
  $README_TEMPLATE | out-file ./README.md

  git config --global user.email "<>"
  git config --global user.name "GitHub Actions"

  write-host "--- committing updates"
  git add -A
  git commit -a -m "Initial commit $($project.jira_ticket)"
  git push origin main

}
catch {
  write-host "::error::An error occured cloning the template!"
  write-host "::error::$($_.message)"
  throw
}
finally {
  set-location $saveLocation
}

write-output "working-directory=$($item.fullname)" >> $env:GITHUB_OUTPUT
write-output "working-directory=$($item.fullname)" >> $env:GITHUB_ENV
