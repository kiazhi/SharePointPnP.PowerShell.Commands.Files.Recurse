---
name: Report an issue
about: Create a report to help us improve

---

Bug description
---------------
<!--
Please kindly provide a clear and concise description of the bug.
-->



Steps to reproduce
------------------
<!--
Please kindly provide the steps to reproduce the issue if possible.

Example:
1. Installed the SharePointPnP.PowerShell.Commands.Files.Recurse module:
`Install-Module -Name 'SharePointPnP.PowerShell.Commands.Files.Recurse'`
2. Execute `Add-PnPFoldersItems` cmdlet:
```powershell
Add-PnPFoldersItems `
    -Url 'https://amce.sharepoint.com/sites/powershellcommunity' `
    -FolderSiteRelativeUrl 'Shared Documents' `
    -Source 'C:\Temp' `
    -ExcludeFileExtension '.txt', '.xlsx' `
    -Credential (New-Object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList (Read-Host -Prompt 'Input your Username'), `
        (ConvertTo-SecureString `
            -String (Read-Host -Prompt 'Input your Password') `
            -AsPlainText `
            -Force)) ;
```
3. And got an error output below:
```text
Error: blah blah blah
```
-->



Expected behaviour
-----------------
<!--
Please kindly provide a clear and concise description of what you expected to
happen.
-->



Actual behaviour
----------------
<!--
Please kindly provide a clear and concise description of what actually happen.

We welcome screenshot or log of the bug. If applicable, add screenshots or logfile to help
explain your problem.
-->



Additional context
------------------
<!--
If you have a link to your screenshots, include the link so that we can
view your screenshots and may be able to assist on fixing it.
-->


