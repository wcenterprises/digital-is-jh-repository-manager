# Repository Manager

## Quckstart
1. Clone a local copy of this repository
1. Create a new development branch
1. Create a new json file defining the properties of the new repository inside the directory [repository](./repository/). 
    a. Be sure to use a unique name, prefferabley using the name of the new projects. (i.e. Jh.NewService.json)
    a. For your convenience you may copy [./docs/sample-project.json](./docs/sample-project.json)


### Json Schema

```json
{
  "name": "project-name",                 /* name of project. i.e. Jh.Sample */
  "solution": "solution-name",            /* name of the .sln file. if not provided, [project-name].sln will be used */
  "jira_ticket": "ticket_number",         /* the issue item associated with the creation of the repository */
  "teams": [
    "banno/team name",                          
    "banno/other team name"                     /* repeat for each team */
  ],
  "codeowners": [                         /* combination of emails/GH id and/or GH teams */
    "owner1@email",                       /* Use owner's email or GH id DO NOT ADD dwhitbeck@jackhenry.com */ 
    "@banno/team name"                    /* When using team names do not add digital-is-build */
  ],
  "repo-modifier": "poc"                  /* *OPTIONAL* a modify which which will be appended to the name of the repository created */
}
```

| Property | Description |
|:----------|:-------------|
| *name* | name of the project (i.e. Jh.NewService) |
| *solution* | name of the solution file (i.e. Jh.NewService.sln) |
| *jira_ticket* | JIRA id of the ticket tracking this new repository (i.e. ABC-123)|
| *teams* | array of team names to grant access (i.e. banno/bsl). _*Note:* do not include digital-is-buid, digital-is-superuser_ |
| *codeowners* | array of users to be added as codeowners using their @jhacorp.com or github user name (i.e. @banno/bsl) _*Note:* Do not include dwhitbeck@jhacorp.com, banno/digital-is-build, banno/digital-is-superusers_ |
| *repo-modifier* | [optional]  use "poc" when the new repo is to be used for practice/debugging. This will make the repo easily identifiable _*Note:* Only affects the naming of the new repository_ |
