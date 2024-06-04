#Repository Manager

##Quckstart
1. Create a json file

###Json Schema

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
| name | name of the project |
| solution | name of the solution file |
| jira_ticket | JIRA id of the ticket tracking this new repository |
| teams | array of team names to grant access |
| codeowners | array of users to be added as codeowners using their @jhacorp.com or github user name |
| repo-modifier | [optional]  use "poc" when the new repo is to be used for practice/debugging. This will make the repo easily identifiable |
