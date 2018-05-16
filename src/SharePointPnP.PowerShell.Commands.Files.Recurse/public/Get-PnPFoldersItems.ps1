<#
 # Created by Ryen Kia Zhi Tang
 #>

function Get-PnPFoldersItems
{
    [CmdletBinding()]

    param
    (
        [Parameter( 
            Mandatory=$False, 
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True,
            ParameterSetName='Connect')] 
        [Alias('uri')]
        [Uri] $Url,

        [Parameter( 
            Mandatory=$False, 
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True)] 
        [Alias('path')]
        [String] $FolderSiteRelativeUrl,

        [Parameter( 
            Mandatory=$False, 
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True)] 
        [Alias('dest')]
        [String] $Destination,

        [Parameter( 
            Mandatory=$False, 
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True)] 
        [String[]] $ExcludeFileExtension,

        [Parameter( 
            Mandatory=$False, 
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True)] 
        [String[]] $ExcludeFolderSiteRelativeUrl,

        [Parameter( 
            Mandatory=$False, 
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True,
            ParameterSetName='Connect')]
        [SharePointPnP.PowerShell.Commands.Base.PipeBinds.CredentialPipeBind] $Credential
    )

    begin
    {
        $ProgressCounter = 0

        if(!(Get-Module `
            -Name 'SharePointPnPPowerShellOnline' `
            -ListAvailable))
        {
            Write-Warning `
                -Message `
                    ([String]::Format('"{0}" {1} "{2}" {3}',
                        'Get-PnPFolderItemContent',
                        'cmdlet requires',
                        'SharePointPnPPowerShellOnline',
                        'SharePoint Online PowerShell Module to be installed.')) ;

            Write-Warning `
                -Message `
                    ([String]::Format('{0} "{1}" {2}: {3}',
                        'Please kindly install the',
                        'SharePointPnPPowerShellOnline',
                        'SharePoint Online PowerShell Module using the following command',
                        'Install-Module -Name SharePointPnPPowerShellOnline')) ;

            Break ;
        }
        else
        {
            if(!(Get-Module `
                -Name 'SharePointPnPPowerShellOnline'))
            {
                Import-Module `
                    -Name 'SharePointPnPPowerShellOnline' ;
            }
        }

        if($Credential -ne (Out-Null))
        {
            
            try
            {
                Connect-PnPOnline `
                    -Url $Url.AbsoluteUri `
                    -Credentials $Credential ;
                
                $Connection = Get-PnPConnection ;
            }
            catch [System.Exception]
            {
                throw($_) ;
            }
        }
        else
        {
            try
            {
                $Connection = Get-PnPConnection ;
            }
            catch [System.Exception]
            {
                throw($_) ;
            }
        }

    }

    process
    {
        $Items = @(Get-PnPFolderItem `
            -FolderSiteRelativeUrl $FolderSiteRelativeUrl)

        foreach ($Item in $Items)
        {

            # Strip the Site URL off the item path, because Get-PnpFolderItem wants it
            # to be relative to the site, not an absolute path.
            $ItemPath = $Item.ServerRelativeUrl `
                -replace "^$(([Uri]$Item.Context.Url).AbsolutePath)/",'' ;
        
            $DestinationFolderPath = [String]::Format('{0}\{1}',
                $Destination,
                ((Split-Path $ItemPath).Replace('/','\'))) ;
                
            if($ExcludeFolderSiteRelativeUrl `
                -notcontains `
                (Split-Path $ItemPath -Parent).Replace('\','/'))
            {

                # If this is a directory, recurse into this function.
                # Otherwise, write the item out to the pipeline.
                if ($Item -is [Microsoft.SharePoint.Client.Folder])
                {
                    if($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Destination"))
                    {
                        Get-PnPFolderItemContent `
                            -FolderSiteRelativeUrl $ItemPath `
                            -Destination $Destination `
                            -ExcludeFileExtension $ExcludeFileExtension `
                            -ExcludeFolderSiteRelativeUrl $ExcludeFolderSiteRelativeUrl ;
                    }
                    else
                    {
                        Get-PnPFolderItemContent `
                            -FolderSiteRelativeUrl $ItemPath `
                            -ExcludeFileExtension $ExcludeFileExtension `
                            -ExcludeFolderSiteRelativeUrl $ExcludeFolderSiteRelativeUrl ;
                    }
                }
                else 
                {
                    if($ExcludeFileExtension `
                        -notcontains `
                        [IO.Path]::GetExtension($(Split-Path -Path $ItemPath -Leaf)))
                    {
                        if($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Destination"))
                        {
                            if(!(Test-Path $DestinationFolderPath))
                            {
                                Write-Warning `
                                    -Message `
                                        ([String]::Format('{0} [{1}] {2}',
                                            'Folder path',
                                            $DestinationFolderPath,
                                            'does not exist')) ;

                                try
                                {
                                    New-Item `
                                        -Path $DestinationFolderPath `
                                        -ItemType Directory `
                                        -Force | `
                                            Out-Null ;
                    
                                    Write-Host `
                                        -Object `
                                            ([String]::Format('{0} [{1}] {2}',
                                                'Created',
                                                $DestinationFolderPath,
                                                'folder path')) `
                                        -ForegroundColor Green ; ;
                                }
                                catch [System.IO.IOException]
                                { 
                                    throw($_) ; 
                                }
                            }
                        
                            try
                            {
                                Write-Verbose `
                                    -Message `
                                        ([String]::Format('{0} [{1}] {2} [{3}]',
                                            'Downloading',
                                            $Item.ServerRelativeUrl, `
                                            'from', `
                                            $FolderSiteRelativeUrl)) ;

                                Write-Progress `
                                    -Activity `
                                        ([String]::Format('{0} [{1}] {2} [{3}]',
                                            'Downloading',
                                            $Item.ServerRelativeUrl, `
                                            'from', `
                                            $FolderSiteRelativeUrl)) `
                                    -Status `
                                        ([String]::Format('{0}: {1} {2} {3}',
                                            'Downloading',
                                            $ProgressCounter,
                                            'of',
                                            $($Items.Count))) `
                                    -PercentComplete (($ProgressCounter / $Items.Count)  * 100) ;
                            
                                Get-PnPFile `
                                    -Url $Item.ServerRelativeUrl `
                                    -Path $DestinationFolderPath `
                                    -AsFile `
                                    -Force ;

                                Write-Verbose `
                                    -Message `
                                        ([String]::Format('{0} [{1}] {2} [{3}]',
                                            'Saving',
                                            $Item.ServerRelativeUrl, `
                                            'to', `
                                            $DestinationFolderPath)) ;

                                $ProgressCounter++ ;
                            }
                            catch [Microsoft.SharePoint.Client.ClientRequestException]
                            { 
                                throw($_) ;
                            }
                        }
                        else
                        {
                            [Microsoft.SharePoint.Client.File] $File = $Item ;

                            Write-Output `
                                -InputObject `
                                    (New-Object `
                                        -TypeName PSObject `
                                        -Property ([Ordered] `
                                            @{
                                                Name = $File.Name
                                                Type = 'File'
                                                Path = (Split-Path $File.ServerRelativeUrl)
                                                Length = $File.Length
                                                Created = $File.TimeCreated
                                                Modified = $File.TimeLastModified
                                            }
                                        )
                                    );
                        }
                    }
                }
            }
        }
    }
    
    end
    {
    }
}