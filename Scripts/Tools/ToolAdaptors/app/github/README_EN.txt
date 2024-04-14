* README_EN.txt
* 2024.04.12
* contools--github

1. DESCRIPTION
2. CATALOG CONTENT DESCRIPTION
3. USAGE
3.1. Generate config files
3.2. Edit generated config files
3.3. Run restapi responce backup scripts
3.4. Run repositories backup
3.5. Run workflows enabler
4. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Github local scripts to:
* Backup rest API responces.
* Backup bare or/and checkouted repositories.
* Workflow enable.

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
    |     | # Output directory for the backup scripts configuration files.
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
       | #
       | # Output directory for github repository backup files.
       |
       +- /`bare`
       |    #
       |    # Output directory for backup bare repositories.
       |
       +- /`checkout`
       |    #
       |    # Output directory for backup checkouted with recursion
       |    # repositories.
       |
       +- /`restapi`
            #
            # Output directory for backup restapi responces.

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
3.3. Run restapi responce backup scripts
-------------------------------------------------------------------------------

To backup only restapi responces for user accounts:

  >
  backup_restapi_all_user_repos_list.bat

To backup only restapi responces for user organization accounts:

  >
  backup_restapi_all_org_repos_list.bat

To backup all restapi responces except repository list for user and
organization accounts:

  >
  backup_restapi_all_exclude_repos_list.bat

To backup all restapi responces (all above):

  >
  backup_restapi_all.bat

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

-------------------------------------------------------------------------------
3.5. Run workflows enabler
-------------------------------------------------------------------------------

To enable a user repository workflow:

  >
  enable_restapi_user_repo_workflow.bat ...

To enable workflows:

  >
  enable_restapi_workflows.bat ...

-------------------------------------------------------------------------------
4. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
