
# details: https://answers.microsoft.com/en-us/windows/forum/all/trying-to-install-program-using-powershell-and/4c3ac2b2-ebd4-4b2a-a673-e283827da143
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Install-Module -Name CredentialManager
