---
external help file: SharePointPnP.PowerShell.Commands.Files.Recurse-Help.xml
Module Name: SharePointPnP.PowerShell.Commands.Files.Recurse
online version:
schema: 2.0.0
---

# Add-PnPFoldersItems

## SYNOPSIS
Uploads file in their folder structure

## SYNTAX

```
Add-PnPFoldersItems [-Url <Uri>] [-FolderSiteRelativeUrl <String>] -Source <String>
 [-ExcludeFileExtension <String[]>] [-Credential <CredentialPipeBind>] [<CommonParameters>]
```

## DESCRIPTION
Uploads file in their folder structure to SharePoint Online.

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-PnPFolderItemContent `
    -Url 'https://amce.sharepoint.com/sites/powershellcommunity' `
    -FolderSiteRelativeUrl 'Shared Documents' `
    -Source 'C:\Temp' `
    -ExcludeFileExtension '.txt', '.xlsx' `
    -Credential (New-Object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList (Read-Host -Prompt 'Input your Username'), `
        (ConvertTo-SecureString `
            -String (Read-Host -Prompt 'Input your Password') `
            -AsPlainText `
            -Force)) ;
```

This command connects to "https://amce.sharepoint.com", filter to FolderSiteRelativeUrl "Shared Documents" path location, exclude files with the following file extensions \['.txt', '.xlsx'\] in the source path location and uploads the rest of the files in that source path location to SharePoint Online location with the credential provided.

## PARAMETERS

### -Credential
Specifies the SharePoint credential.

```yaml
Type: CredentialPipeBind
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ExcludeFileExtension
Specifies the file extension that will be excluded. (Eg. '.aspx', '.html')

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -FolderSiteRelativeUrl
Specifies the folder site relative url that will be included. (Eg. '_catalogs\masterpage\Display Templates')

```yaml
Type: String
Parameter Sets: (All)
Aliases: path

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Source
Specific the source path of the files that will be uploaded.

```yaml
Type: String
Parameter Sets: (All)
Aliases: src

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Url
Specifies the SharePoint Online site url.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases: uri

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Uri

### System.String

### System.String[]

### SharePointPnP.PowerShell.Commands.Base.PipeBinds.CredentialPipeBind


## OUTPUTS

### System.Object

## NOTES
The `Add-PnPFoldersItems` cmdlet from `SharePointPnP.PowerShell.Commands.Files.Recurse` SharePointPnP Add-on module that utilises the `Add-PnPFile` cmdlet from `SharePointPnPPowerShellOnline` module.

## RELATED LINKS
[SharePoint PnP PowerShell Cmdlets](https://github.com/SharePoint/PnP-PowerShell)
[SharePoint Developer Community (SharePoint PnP)](https://docs.microsoft.com/en-us/sharepoint/dev/community/community)
