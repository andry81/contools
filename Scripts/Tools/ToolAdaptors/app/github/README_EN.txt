* README_EN.txt
* 2024.04.25
* contools--github

1. DESCRIPTION
2. CATALOG CONTENT DESCRIPTION
3. USAGE
3.1. Generate config files
3.2. Edit generated config files
3.3. Run restapi response backup scripts
3.4. Run repositories backup
3.5. Delete repositories
3.6. Run workflows enabler
4. AUTHENTICATION
5. KNOWN ISSUES
5.1. The `backup_restapi_user_repos_list.bat` script does return incomplete
     RestAPI response. Not all the public repositories is returned.
6. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Github local scripts to:
* Backup RestAPI responses.
* Backup bare or/and checkouted repositories.
* Workflow enable.
* Delete repositories.

-------------------------------------------------------------------------------
2. CATALOG CONTENT DESCRIPTION
-------------------------------------------------------------------------------

<subdir>
 |
 +- /`_config`
 |    #
 |    # Directory with input configuration files.
 |
 +- `*.bat`
     #
     # Backup scripts.

<root>
 |
 +- /`.log`
 |    #
 |    # Log files directory, where does store all log files from all scripts
 |    # including all nested projects.
 |
 +- /`_out`
    | #
    | # Output directory for all files.
    |
    +- /`config`
    |  | #
    |  | # Output directory for all configuration files.
    |  |
    |  +- /`contools/tool_adaptors/github`
    |     | #
    |     | # Output directory for the scripts configuration files.
    |     |
    |     +- `accounts-org.lst`
    |     |   #
    |     |   # User organization accounts.
    |     |
    |     +- `accounts-user.lst`
    |     |   #
    |     |   # User accounts.
    |     |
    |     +- `repos.lst`
    |     |   #
    |     |   # User repositories list.
    |     |
    |     +- `repos-auth.lst`
    |     |   #
    |     |   # Authenticated only user repositories list.
    |     |
    |     +- `repos-forks.lst`
    |     |   #
    |     |   # User forked repositories list.
    |     |
    |     +- `workflows.lst`
    |     |   #
    |     |   # User workflows.
    |     |
    |     +- `config.0.vars`
    |     |   #
    |     |   # Scripts public environment variables.
    |     |
    |     +- `config.1.vars`
    |         #
    |         # Scripts private environment variables.
    |
    +- /`github/backup`
    |  | #
    |  | # Output directory for github repository backup files.
    |  |
    |  +- /`bare`
    |  |    #
    |  |    # Output directory for backup bare plus checkout
    |  |    # repositories.
    |  |
    |  +- /`checkout`
    |  |    #
    |  |    # Output directory for backup only checkouted repositories.
    |  |
    |  +- /`restapi`
    |       #
    |       # Output directory for backup restapi responses.
    |
    +- /`github/workflow`
         #
         # Output directory for github repository workflow files.

-------------------------------------------------------------------------------
3. USAGE
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
3.1. Generate config files
-------------------------------------------------------------------------------

Run:

  >
  __init__/__init__.bat

-------------------------------------------------------------------------------
3.2. Edit generated config files
-------------------------------------------------------------------------------

accounts-org.lst
accounts-user.lst
repos.lst
repos-auth.lst
repos-forks.lst
workflows.lst
config.0.vars
config.1.vars

-------------------------------------------------------------------------------
3.3. Run restapi response backup scripts
-------------------------------------------------------------------------------

To backup all restapi responses for authenticated user plus accounts from
`accounts-user.lst`:

  >
  backup_restapi_all_user_repos_list.bat

To backup only restapi responses for user organization accounts from
`accounts-org.lst`:

  >
  backup_restapi_all_org_repos_list.bat

To backup using previous 2 plus `user repo info`, `stargazers`, `subscribers`,
`forks`, `releases` using `repos.lst` and/or `repos-forks.lst`.

  >
  backup_restapi_all.bat

To backup all restapi responses except repository list for user and
organization accounts. Or the same as `backup_restapi_all.bat` script but
excluding first 2 scripts:

  >
  backup_restapi_all_exclude_repos_list.bat

-------------------------------------------------------------------------------
3.4. Run repositories backup
-------------------------------------------------------------------------------

To backup only bare repositories:

  >
  backup_bare_*.bat ...

To backup only recursively checkouted repositories:

  >
  backup_checkouted_*.bat ...

To backup all repositories as bare plus with recursed checkout:

  >
  backup_bared_checkout_all_repos.bat ...

To backup only authenticated user repositories from `repos-auth.lst`.

  >
  backup_*_all_auth_repos.bat ...

To backup user repositories from `repos.lst` and/or `repos-forks.lst`.

  >
  backup_*_all_repos.bat ...

-------------------------------------------------------------------------------
3.5. Delete repositories
-------------------------------------------------------------------------------

To delete a user repository:

  >
  delete_restapi_user_repo.bat ...

To delete user repositories from `repos-to-delete.lst`:

  >
  delete_restapi_user_repos.bat ...

-------------------------------------------------------------------------------
3.6. Run workflows enabler
-------------------------------------------------------------------------------

To enable a user repository workflow:

  >
  enable_restapi_user_repo_workflow.bat ...

To enable workflows:

  >
  enable_restapi_workflows.bat ...

-------------------------------------------------------------------------------
4. AUTHENTICATION
-------------------------------------------------------------------------------
Authentication is based on `GH_AUTH_USER`. `GH_AUTH_PASS` and `GH_AUTH_PASS_*`
variables. You must set them to use authentication, otherwise the RestAPI
response may be truncated, incomplete or invalid.

-------------------------------------------------------------------------------
5. KNOWN ISSUES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
5.1. The `backup_restapi_user_repos_list.bat` script does return incomplete
     RestAPI response. Not all the public repositories is returned.
-------------------------------------------------------------------------------
For some not know reason the `https://api.github.com/users/USER/repos` url
does return an incomplete RestAPI response even for the authenticated user.

Solution:

Use the authenticated user request through the
`backup_restapi_auth_user_repos_list.bat` script. It does use authentication
and `https://api.github.com/user/repos` url as the RestAPI request.

-------------------------------------------------------------------------------
6. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
