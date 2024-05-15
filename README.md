```json
{
  "name": "project-name",                 /* name of project. i.e. Jh.Sample */
  "solution": "solution-name",            /* name of the .sln file. if not provided, [project-name].sln will be used */
  "jira_ticket": "ticket_number",         /* the issue item associated with the creation of the repository */
  "teams": [
    "wcenterprises/team name",                          
    "wcenterprises/other team name"                     /* repeat for each team */
  ],
  "codeowners": [                         /* combination of emails/GH id and/or GH teams */
    "owner1@email",                       /* Use owner's email or GH id DO NOT ADD dwhitbeck@jackhenry.com */ 
    "@wcenterprises/team name"                    /* When using team names do not add digital-is-build */
  ],
  "repo-modifier": "poc"                  /* *OPTIONAL* a modify which which will be appended to the name of the repository created */
}
```