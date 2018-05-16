<#
 # Created by Ryen Kia Zhi Tang
 #>

 function Add-PnPFoldersItems
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
            Mandatory=$True, 
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True)] 
        [Alias('src')]
        [String] $Source,
        
        [Parameter( 
            Mandatory=$False, 
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True)] 
        [String[]] $ExcludeFileExtension,

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
        if($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("ExcludeFileExtension"))
        {
            $FileExtensions = $ExcludeFileExtension | `
                ForEach-Object { `
                    $_.Replace('.','*.') 
                } ;

            $Items = @(Get-ChildItem `
                -Path $Source `
                -File `
                -Recurse `
                -Exclude $FileExtensions) ;
        }
        else
        {
            $Items = @(Get-ChildItem `
                -Path $Source `
                -File `
                -Recurse) ;
        }

        foreach ($Item in $Items)
        {

            $ChildFolder = ($Item.DirectoryName).Replace($Source,'').Replace('\','/') ;

            if($ChildFolder -eq [String]::Empty)
            {
                try
                {

                    Write-Verbose `
                        -Message `
                            ([String]::Format('{0} [{1}] {2} [{3}]',
                                'Uploading',
                                $Item.Name, `
                                'from', `
                                $Item.DirectoryName)) ;

                    Write-Progress `
                        -Activity `
                            ([String]::Format('{0} [{1}] {2} [{3}]',
                                'Uploading',
                                $Item.Name, `
                                'from', `
                                $Item.DirectoryName)) `
                        -Status `
                            ([String]::Format('{0}: {1} {2} {3}',
                                'Uploading',
                                $ProgressCounter,
                                'of',
                                $($Items.Count))) `
                        -PercentComplete (($ProgressCounter / $Items.Count)  * 100) ;

                    Add-PnPFile `
                        -Path $Item.FullName `
                        -Folder $FolderSiteRelativeUrl | `
                            Out-Null ;

                    Write-Verbose `
                        -Message `
                            ([String]::Format('{0} [{1}] {2} [{3}/{4}]',
                                'Uploaded',
                                $Item.Name, `
                                'to', `
                                $Connection.Url, `
                                $FolderSiteRelativeUrl)) ;

                    $ProgressCounter++ ;
                }
                catch [Microsoft.SharePoint.Client.ClientRequestException]
                { 
                    throw($_) ;
                }
            }
            else
            {
                try
                {

                    Write-Verbose `
                        -Message `
                            ([String]::Format('{0} [{1}] {2} [{3}]',
                                'Uploading',
                                $Item.Name, `
                                'from', `
                                $Item.DirectoryName)) ;

                    Write-Progress `
                        -Activity `
                            ([String]::Format('{0} [{1}] {2} [{3}]',
                                'Uploading',
                                $Item.Name, `
                                'from', `
                                $Item.DirectoryName)) `
                        -Status `
                            ([String]::Format('{0}: {1} {2} {3}',
                                'Uploading',
                                $ProgressCounter,
                                'of',
                                $($Items.Count))) `
                        -PercentComplete (($ProgressCounter / $Items.Count)  * 100) ;

                    Add-PnPFile `
                        -Path $Item.FullName `
                        -Folder $($FolderSiteRelativeUrl + $ChildFolder) | `
                            Out-Null ;

                    Write-Verbose `
                        -Message `
                            ([String]::Format('{0} [{1}] {2} [{3}/{4}]',
                                'Uploaded',
                                $Item.Name, `
                                'to', `
                                $Connection.Url,
                                $($FolderSiteRelativeUrl + $ChildFolder))) ;

                    $ProgressCounter++ ;
                }
                catch [Microsoft.SharePoint.Client.ClientRequestException]
                { 
                    throw($_) ;
                }
            }
        }
    }
    
    end
    {
    }
}