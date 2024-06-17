# Repository Manager

**Repository Manager** is a repository used to create repositories conforming to naming, configuration and operational standards of Digital IS. 

In the future, Repository Manager will be expanded to provide initial code generation capabilities of new projects as well. 

## Quckstart
1. Clone a local copy of this repository
1. Create a new development branch
1. Create a new json file defining the properties of the new repository inside the directory [repository](./repository/). 
    1. Be sure to use a unique name, prefferabley using the name of the new projects. (i.e. Jh.NewService.json)
    1. For your convenience you may copy [./docs/sample-project.json](./docs/sample-project.json)
1. Commit the new file and push the branch.
1. Create a pull request following reveiw and approval process as with any code change. 
1. When the PR has the necessary approvals complete the merge. When the merge is completed and the CI script is run successfully your new repo will be created. 
1. After your new repository is created you may then clone the repository and add your project code to source directory using established pull request process and procedures. 

## Problems
If you have created the repository in error several things can be done to correct the error. Engage the build team to determine the best approach to correcting the proplem

Repositories created in error can be deleted by requesting their deletion using [jhNow](https://jhnow.service-now.com/esc?id=sc_cat_item&sys_id=8b23353c470965d0365e3e48436d4386). 

### Json Schema

```json
{
  "name": "project-name",          /* name of project. i.e. Jh.Sample */
  "solution": "solution-name",     /* name of the .sln file. if not provided, [project-name].sln will be used */
  "jira_ticket": "ticket_number",  /* the issue item associated with the creation of the repository */
  "teams": [
    "banno/team name",                          
    "banno/other team name"        /* repeat for each team */
  ],
  "codeowners": [                  /* combination of emails/GH id and/or GH teams */
    "owner1@email",                /* Use owner's email or GH id DO NOT ADD dwhitbeck@jackhenry.com */ 
    "@banno/team name"             /* When using team names do not add digital-is-build */
  ],
  "repo-modifier": "poc"           /* *OPTIONAL* a modify which which will be appended to the name of the repository created */
}
```

| Property | Description |
|:----------|:-------------|
| **name** | name of the project (i.e. Jh.NewService) |
| **solution** | name of the solution file (i.e. Jh.NewService.sln) |
| **jira_ticket** | JIRA id of the ticket tracking this new repository (i.e. ABC-123)|
| **teams** | array of team names to grant access (i.e. banno/bsl). _**Note:** do not include digital-is-buid, digital-is-superuser_ |
| **codeowners** | array of users to be added as codeowners using their @jhacorp.com or github user name (i.e. @banno/bsl) _**Note:** Do not include dwhitbeck@jhacorp.com, banno/digital-is-build, banno/digital-is-superuser_ |
| **repo-modifier** | [_**optional**_]  use "poc" when the new repo is to be used for practice/debugging. This will make the repo easily identifiable _**Note:** Only affects the naming of the new repository_ |
