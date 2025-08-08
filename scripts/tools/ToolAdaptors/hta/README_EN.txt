* README_EN.txt
* 2025.08.08
* contools--ToolAdaptors--hta

1. DESCRIPTION
2. KNOWS ISSUES
2.1. The `cmd_admin_system.bat` has no effect of `psexec.exe` start.
2.1.1 The `psexec.exe` reports the
   `Error creating key file on HOSTNAME: The system cannot find the path specified.`
   error.

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
The `mshta.exe` based scripts.

-------------------------------------------------------------------------------
2. KNOWS ISSUES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
2.1. The `cmd_admin_system.bat` has no effect of `psexec.exe` start.
-------------------------------------------------------------------------------

Use `test_psexec.bat` from `contools--admin` project to test run `cmd.exe` in
the SYSTEM account or lookup the `psexec` error output.

-------------------------------------------------------------------------------
2.1.1 The `psexec.exe` reports the
   `Error creating key file on HOSTNAME: The system cannot find the path specified.`
   error.
-------------------------------------------------------------------------------

The reason:

  1. Make sure the `LanmanServer` (Server) or `LanmanWorkstation` (Workstation)
    services are in the `started` state before run the `psexec.exe`.

    Use `enable_psexec_svc.bat` script from `contools--admin` project to
    enable and run these explicitly.
