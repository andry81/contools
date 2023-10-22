* README_EN.txt
* 2023.10.22
* contools--gitextensions

1. DESCRIPTION
2. USAGE
3. KNOWN ISSUES
3.1. `plink: unknown option "-o"`
3.2. `fatal: protocol error: bad line length character: logi`
3.3. `fatal: protocol error: bad line length character: | Pa`
3.4. GitExtensions hangs on Pull/Push and Ok button is not enabled.
4. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------

GitExtensions PuTTY PLink script to use Putty ssh agent with the Pageant.

-------------------------------------------------------------------------------
2. USAGE
-------------------------------------------------------------------------------

If your Putty has the issue and still requests the login or/and password while
the Pageant is running and using an ssh private key file, then you can bypass
it by substitution the plink executable in the GitExtensions config.

Just add `plink-agent.bat` into putty installation directory.

And use `plink-agent.bat` in the config (Git Extensions -> SSH):

> [x] PuTTY
>
> Configure PuTTY
>
> **Path to plink**: `<path-to-putty>\plink-agent.bat`

Then add the user name into the url: `ssh://username@domain/path`

This will avoid interaction with the user. Otherwise it will request the
`login as` input.

If it still requests the input, then you can temporary replace the
`plink-agent.bat` into something like:

```bat
@echo off

setlocal

echo.ssh agent command line: %*>&2

type con | "%~dp0plink.exe" -agent %*
```

Then input into the console, revert back to first variant and run again.

Another variant is to use a vbs script with the command line in a standalone
file:

> **Path to plink**: `<path-to-putty>\plink-agent.vbs`

Put `plink-agent.vbs` and `plink-agent.vbs.cmdline` to the same directory with
the `plink.exe`.

-------------------------------------------------------------------------------
3. KNOWN ISSUES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
3.1. `plink: unknown option "-o"`
-------------------------------------------------------------------------------

GitExtensions switched (manually or automatically) to use `Other ssh client`
setting instead of `PuTTY`.

Currently the GitExtensions checks the extension of the plink executable on
settings dialog apply and in case of a batch file does switch to
`Other ssh client`. In that case it will use different command line. You must
switch it back to the `PuTTY` option to use Putty command line.

To do that you must at first switch back to `PuTTY` option by editing the
`Path to plink` to `<path-to-putty>\plink.exe`, apply settings dialog and close
all instances of GitExtensions.

Only after that you can open the settings file directly in the editor:

> c:\Users\User\AppData\Roaming\GitExtensions\GitExtensions\GitExtensions.settings

Find to edit these lines:

```
    <key>
      <string>plink</string>
    </key>
    <value>
      <string>path-to-putty\plink.exe</string>
    </value>
```

And replace to:

```
    <key>
      <string>plink</string>
    </key>
    <value>
      <string>path-to-putty\plink-agent.bat</string>
    </value>
```

Now it must use the script with the Putty command line.

Beware of Settings dialog. If you open and apply it again (press OK or Apply
button), then it may reset the option back to `Other ssh client` and you will
have to repeat the steps above again.

Additionally, you can use another way which is a bit shorter:

Open settings dialog and edit the `Other ssh client` option to
`path-to-putty\plink.exe` and apply the setting. If then reopen the dialog (to
lookup the option and do not apply the dialog), then it will use `PuTTY` option
with the previous value in the `Path to plink` field.

-------------------------------------------------------------------------------
3.2. `fatal: protocol error: bad line length character: logi`
-------------------------------------------------------------------------------

```
fatal: protocol error: bad line length character: logi
FATAL ERROR: Error reading from console: Error 109: ����� ��� ������.
```

`plink` trying to request a user name:

```
login as:
```

**You must add the user name into the url: `ssh://username@domain/path`**

-------------------------------------------------------------------------------
3.3. `fatal: protocol error: bad line length character: | Pa`
-------------------------------------------------------------------------------

`plink` trying to request a password:

```
-| Password:
```

**You must run the Putty authentication agent (Pageant) and add the ssh key.**

As an additional measure add these git configuration variables:

>
git config --global --replace-all core.sshcommand "path-to-putty\plink-agent.bat"

>
git config --global --replace-all ssh.variant plink

This will force the git to use plink ssh method and the script with the plink
variant of the command line.

-------------------------------------------------------------------------------
3.4. GitExtensions hangs on Pull/Push and Ok button is not enabled.
-------------------------------------------------------------------------------

**You must use first variant of `plink-agent.bat` and remove `type con | ...`
prefix from the `plink` command.**

-------------------------------------------------------------------------------
3. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
