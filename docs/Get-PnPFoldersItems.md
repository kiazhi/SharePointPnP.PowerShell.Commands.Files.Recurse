---
external help file: SharePointPnP.PowerShell.Commands.Files.Recurse-Help.xml
Module Name: SharePointPnP.PowerShell.Commands.Files.Recurse
online version:
schema: 2.0.0
---

# Get-PnPFoldersItems

## SYNOPSIS
Get the folder structure and files

## SYNTAX

```
Get-PnPFoldersItems [-Url <Uri>] [-FolderSiteRelativeUrl <String>] [-Destination <String>]
 [-ExcludeFileExtension <String[]>] [-ExcludeFolderSiteRelativeUrl <String[]>]
 [-Credential <CredentialPipeBind>] [<CommonParameters>]
```

## DESCRIPTION
Get the folder structure and files from SharePoint Online.
Create the folder structure and download those files when destination parameter is specified with a local file system path.

## EXAMPLES

### Example 1
```
PS C:\> Connect-PnPOnline `
    -Url https://amce.sharepoint.com/ `
    -Credentials (New-Object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList (Read-Host -Prompt 'Input your Username'), `
        (ConvertTo-SecureString `
            -String (Read-Host -Prompt 'Input your Password') `
            -AsPlainText `
            -Force)) ;

PS C:\> Get-PnPFoldersItems `
    -FolderSiteRelativeUrl '_catalogs/masterpage' `
    -ExcludeFileExtension '.aspx', '.txt' `
    -ExcludeFolderSiteRelativeUrl '_catalogs/masterpage/Display Templates/Filters', '_catalogs/masterpage/Display Templates/System' ;
```

This command uses the existing "https://amce.sharepoint.com" connection, filter to get a list of items in FolderSiteRelativeUrl "_catalogs\masterpage", exclude files with the following file extensions \['.aspx', '.txt'\], exclude any other folders and files in following relative url \['_catalogs/masterpage/Display Templates/Filters', '_catalogs/masterpage/Display Templates/System'\] and list those files in their respective folder path.

### Example 2
```
PS C:\> Get-PnPFoldersItems `
    -Url https://amce.sharepoint.com/ `
    -FolderSiteRelativeUrl '_catalogs/masterpage' `
    -ExcludeFileExtension '.aspx', '.txt' `
    -ExcludeFolderSiteRelativeUrl '_catalogs/masterpage/Display Templates/Filters', '_catalogs/masterpage/Display Templates/System' `
    -Destination 'C:\Temp' `
    -Credential (New-Object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList (Read-Host -Prompt 'Input your Username'), `
        (ConvertTo-SecureString `
            -String (Read-Host -Prompt 'Input your Password') `
            -AsPlainText `
            -Force)) ;
```

This command connects to "https://amce.sharepoint.com", filter to get a list of items in FolderSiteRelativeUrl "_catalogs\masterpage", exclude files with the following file extensions \['.aspx', '.txt'\], exclude any other folders and files in following relative url \['_catalogs/masterpage/Display Templates/Filters', '_catalogs/masterpage/Display Templates/System'\] and download those files in their respective folder structure with the credential provided.

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

### -Destination
Specific the destination path for the downloaded files.

```yaml
Type: String
Parameter Sets: (All)
Aliases: dest

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

### -ExcludeFolderSiteRelativeUrl
Specifies the folder site relative url that will be excluded. (Eg. 'Forms', 'Forms\Html')

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
The `Get-PnPFoldersItems` cmdlet from `SharePointPnP.PowerShell.Commands.Files.Recurse` SharePointPnP Add-on module that utilises the `Get-PnPFile` cmdlet from `SharePointPnPPowerShellOnline` module.

## RELATED LINKS
[SharePoint PnP PowerShell Cmdlets](https://github.com/SharePoint/PnP-PowerShell)
[SharePoint Developer Community (SharePoint PnP)](https://docs.microsoft.com/en-us/sharepoint/dev/community/community)
[SharePointPnP.PowerShell.Commands.Files.Recurse](https://github.com/kiazhi/SharePointPnP.PowerShell.Commands.Files.Recurse)
