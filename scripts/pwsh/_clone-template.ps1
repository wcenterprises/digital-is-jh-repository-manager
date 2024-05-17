[CmdletBinding()]
param(
  $Project,
  [string]$template="${env:PROJECT-OWNER}/digital-is-jh-service-template"
)
if (-not "$($env:GH_TOKEN)") {
  write-output "::error::GH_TOKEN environement variable not found."
  throw "GH_TOKEN environement variable not found."
}

$README_TEMPLATE=@"
#$($project.repository)

| | Status |
|:---|:---|
| Build | [![ CI ](https://github.com/${env:PROJECT-OWNER}/$($project.repository)/actions/workflows/ci.yml/badge.svg)](https://github.com/${env:PROJECT-OWNER}/$($project.repository)/actions/workflows/ci.yml) |
| Unit Tests | [![ Unit Tests ](https://github.com/${env:PROJECT-OWNER}/$($project.repository)/actions/workflows/unit-tests.yml/badge.svg)](https://github.com/${env:PROJECT-OWNER}/$($project.repository)/actions/workflows/unit-tests.yml)|
| CodeQL | [![ CodeQL ](https://github.com/${env:PROJECT-OWNER}/$($project.repository)/actions/workflows/codeql.yml/badge.svg)](https://github.com/${env:PROJECT-OWNER}/$($project.repository)/actions/workflows/codeql.yml)|

---

_Generated: $(Get-Date) by @$($env:GITHUB_ACTOR)_
"@

function Update-BranchProtection {
  
  write-host "------ Update branch protection"

  gh api `
    --method PUT `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    /repos/${env:PROJECT-OWNER}/$($project.repository)/branches/main/protection `
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

  write-host "------ adding team: $($teamName):$permission"

  gh api `
    --method PUT `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    /orgs/${env:PROJECT-OWNER}/teams/$teamName/repos/${env:PROJECT-OWNER}/$($project.repository) `
      -f permission=$permission
}

function Update-RepositoryProperties {

  write-host "------ Updating repository properties"
  try {
    gh api `
      --method PATCH `
      -H "Accept: application/vnd.github+json" `
      -H "X-GitHub-Api-Version: 2022-11-28" `
      /repos/${env:PROJECT-OWNER}/$($project.repository) `
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
  catch {
    throw
  }
  finally {
    $LASTEXITCODE=0
  }
  
}

function Convert-ContentTokens {
  param(
    $content
  )  
    $content -replace '\[DATE\]', (get-date).ToString() `
      -replace '\[PROJECT\-NAME\]', $($project.name) `
      -replace '\[SOLUTION\-NAME\]', $($project.solution) `
      -replace '\[REPO\-NAME\]', $($project.repository) `
      -replace '\[CODE\-OWNERS\]', "$($project.codeowners -join " ")" `
      -replace '\[PROJECT\-OWNER\]', "${env:PROJECT-OWNER}"
}

function Update-ActionVariable {
  param(
    [string]$variableName,
    [string]$variableValue
  )
  write-host "------ setting variable: $($variableName):$($variableValue)"
  gh variable set $variableName --body $variableValue --repo ${env:PROJECT-OWNER}/$($project.repository)  
}

$DESCRIPTION="Created by repo-manager, $((get-date -AsUTC).tostring("yyy-MM-dd HH:mm")) submitted by @$($env:GITHUB_ACTOR), Jira-Ticket: $($project.jira_ticket)"

$saveLocation=get-location

$item=$null

try {
  set-location "../"

  write-host "--- creating repository ${env:PROJECT-OWNER}/$($project.repository)"
  gh repo create ${env:PROJECT-OWNER}/$($project.repository) --public --template $template --clone --description $DESCRIPTION
  $item=get-item $($project.repository)
  set-location $item

  write-host "--- adding topics"
  gh repo edit "${env:PROJECT-OWNER}/$($project.repository)" --add-topic "tvm-219898-219901"
  gh repo edit "${env:PROJECT-OWNER}/$($project.repository)" --add-topic "dotnet"

  write-host "--- adding teams standard teams"
  Set-RepositoryTeam -teamName "digital-is-build" -permission "admin"
  Set-RepositoryTeam -teamName "digital-is-superuser" -permission "push"
  
  write-host "--- adding team $($_)"
  $project.teams | foreach-object {
    Set-RepositoryTeam -teamName "$($_)" -permission "push"
  }

  $files=get-childitem -Recurse -include 'Dockerfile','CODEOWNERS','*.yml','README.md','Jenkinsfile'
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

  git remote set-url origin https://$($env:GH_TOKEN)@github.com/${env:PROJECT-OWNER}/$($project.repository).git

  git config user.email "$($env:GITHUB_ACTOR)@users.noreply.github.com"
  git config user.name "$($env:GITHUB_ACTOR)"

  write-host "--- adding updates"
  git add -A

  write-host "--- commiting updates"
  git commit -a -m "Initial commit $($project.jira_ticket)"

  write-host "--- pushing updates"
  git push origin main

  write-host "--- creating branch protections"
  $branchProps=Update-BranchProtection  

  write-host "--- updating repository properties"
  $repoProps=Update-RepositoryProperties

  set-location "../"
}
catch {
  write-output "::error::An error occured cloning the template!"
  write-output "::error::$($_.message)"
  throw
}
finally {
}

exit 0