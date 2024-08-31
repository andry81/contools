* README_EN.txt
* 2024.08.31
* contools/admin/wincred

1. DESCRIPTION
2. INSTRUCTIONS
2.1. Installation of PowerShell 5.1 for Windows 7/8.x/Server2012
2.2. Add credentials
3. KNOWN ISSUES
3.1. Error message: `remote: Invalid username or password.`
     `fatal: Authentication failed for 'https://github.com/USER/REPO/'`

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Windows credentials maintain scripts.

-------------------------------------------------------------------------------
2. INSTRUCTIONS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
2.1. Installation of PowerShell 5.1 for Windows 7/8.x/Server2012
-------------------------------------------------------------------------------
https://www.microsoft.com/en-us/download/details.aspx?id=54616

Files:

* W2K12-KB3191565-x64.msu
* Win8.1AndW2K12R2-KB3191564-x64.msu
* Win8.1-KB3191564-x86.msu
* Win7AndW2K8R2-KB3191566-x64.zip
* Win7-KB3191566-x86.zip

-------------------------------------------------------------------------------
2.2. Add credentials
-------------------------------------------------------------------------------

1. Run cmd.exe console with Administrator privileges.

2. >
   newcred.bat git:https://github.com USER PASS Enterprise
   newcred.bat git:https://USER@github.com USER PASS LocalMachine

-------------------------------------------------------------------------------
3. KNOWN ISSUES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
3.1. Error message: `remote: Invalid username or password.`
     `fatal: Authentication failed for 'https://github.com/USER/REPO/'`
-------------------------------------------------------------------------------
Details:
https://github.com/orgs/community/discussions/133133#discussioncomment-10443908

The GitHub now requires 2 credentials instead of one as was before for
`https://github.com/USER/REPO` remotes:

1. Address: `git:https://github.com`
  User: `USER`
  Pass: `PASS`
  Persistence: `Enterprise`

*AND*

2. Address: `git:https://USER@github.com`
  User: `USER`
  Pass: `PASS`
  Persistence: `Local computer`

The second one must be with persistence `Local computer`, otherwise won't
work (!).

This one can not be added through the Control Panel Credential Manager nor
`cmdkey.exe` utility.
The details how to add through the PowerShell:
https://serverfault.com/questions/920048/change-persistence-type-of-windows-credentials-from-enterprise-to-local-compu

The Git Credential Manager adds the second automatically in the installation:
https://github.com/git-ecosystem/git-credential-manager
