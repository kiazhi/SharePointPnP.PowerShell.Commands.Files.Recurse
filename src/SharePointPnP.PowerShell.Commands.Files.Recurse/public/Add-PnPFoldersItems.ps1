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
            -ListAvailable) `
            -and `
            !(Get-Module `
                -Name 'SharePointPnPPowerShell2013' `
                -ListAvailable) `
            -and `
            !(Get-Module `
                -Name 'SharePointPnPPowerShell2016' `
                -ListAvailable))
        {
            Write-Warning `
                -Message `
                    ([String]::Format('"{0}" {1} "{2}" {3}',
                        'Get-PnPFoldersItems',
                        'cmdlet requires',
                        'SharePointPnPPowerShellOnline or SharePointPnPPowerShell2013 or SharePointPnPPowerShell2016',
                        'SharePoint Online PowerShell Module to be installed.')) ;

            Write-Warning `
                -Message `
                    ([String]::Format('{0} "{1}" {2}: {3}',
                        'Please kindly install the',
                        'SharePointPnPPowerShellOnline or SharePointPnPPowerShell2013 or SharePointPnPPowerShell2016',
                        'SharePoint PowerShell Module using the following command',
                        'Install-Module -Name SharePointPnPPowerShellVERSION')) ;

            Break ;
        }
        #rely on auto load module instead of importing explicitly

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

# SIG # Begin signature block
# MIIQ/wYJKoZIhvcNAQcCoIIQ8DCCEOwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNOzul4aLkYo+UZCeS7ks5dyZ
# K86gggyRMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggP0MIIC3KADAgECAhB/a5fIdzrerUEQmV6aj/9NMA0GCSqGSIb3
# DQEBCwUAMBwxGjAYBgNVBAMMEVJ5ZW4uS2lhLlpoaS5UYW5nMB4XDTE3MTIyNjA5
# NTE1NVoXDTE4MTIyNjEwMTE1NVowHDEaMBgGA1UEAwwRUnllbi5LaWEuWmhpLlRh
# bmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDsBt37XrwrkReIAsf4
# Z6Ij9Du29Q/YLq1djViZvCfbWBwWSU+mYQs65IX58qg6D/kzX+QAdN7BrYkutk49
# Heqat7+9c1bDn8C1MtJs4D7xbPX2TrhvZJ4aFpSE05BXd9xI1NqYYGON32lVDilI
# +6yiD9/GfZhej0ysUPNHBsr0hq1TxHfILjmf8K2draYack0tr3gfOgPRrrgF+khZ
# Um1pS1S9e07OkWCH3L+O9y4x/1rapp9+d1kx5iF6zD3NHvitnIuNSV70livhr0B8
# V9GZsZ5Ln8QfhpZ68oEAK5ud/kTnK6sWkea2kV5eQNT/KNSm7+zfJ0bmIUvIDDtm
# 4q+tAgMBAAGjggEwMIIBLDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwgeUGA1UdEQSB3TCB2oY1aHR0cHM6Ly9tdnAubWljcm9zb2Z0LmNvbS9l
# bi11cy9QdWJsaWNQcm9maWxlLzUwMDE3MTCGRWh0dHBzOi8vc29jaWFsLnRlY2hu
# ZXQubWljcm9zb2Z0LmNvbS9wcm9maWxlL3J5ZW4lMjBraWElMjB6aGklMjB0YW5n
# L4YjaHR0cHM6Ly9uei5saW5rZWRpbi5jb20vaW4vcnllbnRhbmeGGmh0dHBzOi8v
# dHdpdHRlci5jb20va2lhemhphhlodHRwczovL2dpdGh1Yi5jb20va2lhemhpMB0G
# A1UdDgQWBBSGIqBWna8/GZNMsH+T5JM8jmkeNjANBgkqhkiG9w0BAQsFAAOCAQEA
# b/lIFMuGkQYH1mMdAXYBfgHZKq85vayddmoXJcXIzlwFygBTus9oytgln1nG1y20
# S7Wvb5a2Mmo6hyzIX1W8xB0mznW9EKI35dSfCzY4AJnpZFyguRn+JwumQJWN++Ej
# 4qp3tRQeJ2v0/Nsm8Q1Amp03S4oWZ1Ro5NRbpOILbk/IMRuZN4kecxltpyb7XKPG
# +GESKe4sGqJny3NRjGNdVE2CH/cJhsCzJdwgQwED8FVS/h/k4gkURdOJTQR8fOxI
# fMVtR69W3PZ3FEnFaN0frfevpImNRD5ucJd3Bp+NiJfK9DxKvgudiIth92okpP5w
# 7TYgNQKPDV59EFC5WUs6hjCCBKMwggOLoAMCAQICEA7P9DjI/r81bgTYapgbGlAw
# DQYJKoZIhvcNAQEFBQAwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVj
# IENvcnBvcmF0aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNl
# cnZpY2VzIENBIC0gRzIwHhcNMTIxMDE4MDAwMDAwWhcNMjAxMjI5MjM1OTU5WjBi
# MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xNDAy
# BgNVBAMTK1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgU2lnbmVyIC0g
# RzQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCiYws5RLi7I6dESbsO
# /6HwYQpTk7CY260sD0rFbv+GPFNVDxXOBD8r/amWltm+YXkLW8lMhnbl4ENLIpXu
# witDwZ/YaLSOQE/uhTi5EcUj8mRY8BUyb05Xoa6IpALXKh7NS+HdY9UXiTJbsF6Z
# WqidKFAOF+6W22E7RVEdzxJWC5JH/Kuu9mY9R6xwcueS51/NELnEg2SUGb0lgOHo
# 0iKl0LoCeqF3k1tlw+4XdLxBhircCEyMkoyRLZ53RB9o1qh0d9sOWzKLVoszvdlj
# yEmdOsXF6jML0vGjG/SLvtmzV4s73gSneiKyJK4ux3DFvk6DJgj7C72pT5kI4RAo
# cqrNAgMBAAGjggFXMIIBUzAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsG
# AQUFBwMIMA4GA1UdDwEB/wQEAwIHgDBzBggrBgEFBQcBAQRnMGUwKgYIKwYBBQUH
# MAGGHmh0dHA6Ly90cy1vY3NwLndzLnN5bWFudGVjLmNvbTA3BggrBgEFBQcwAoYr
# aHR0cDovL3RzLWFpYS53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNlcjA8BgNV
# HR8ENTAzMDGgL6AthitodHRwOi8vdHMtY3JsLndzLnN5bWFudGVjLmNvbS90c3Mt
# Y2EtZzIuY3JsMCgGA1UdEQQhMB+kHTAbMRkwFwYDVQQDExBUaW1lU3RhbXAtMjA0
# OC0yMB0GA1UdDgQWBBRGxmmjDkoUHtVM2lJjFz9eNrwN5jAfBgNVHSMEGDAWgBRf
# mvVuXMzMdJrU3X3vP9vsTIAu3TANBgkqhkiG9w0BAQUFAAOCAQEAeDu0kSoATPCP
# YjA3eKOEJwdvGLLeJdyg1JQDqoZOJZ+aQAMc3c7jecshaAbatjK0bb/0LCZjM+RJ
# ZG0N5sNnDvcFpDVsfIkWxumy37Lp3SDGcQ/NlXTctlzevTcfQ3jmeLXNKAQgo6rx
# S8SIKZEOgNER/N1cdm5PXg5FRkFuDbDqOJqxOtoJcRD8HHm0gHusafT9nLYMFivx
# f1sJPZtb4hbKE4FtAC44DagpjyzhsvRaqQGvFZwsL0kb2yK7w/54lFHDhrGCiF3w
# PbRRoXkzKy57udwgCRNx62oZW8/opTBXLIlJP7nPf8m/PiJoY1OavWl0rMUdPH+S
# 4MO8HNgEdTGCA9gwggPUAgEBMDAwHDEaMBgGA1UEAwwRUnllbi5LaWEuWmhpLlRh
# bmcCEH9rl8h3Ot6tQRCZXpqP/00wCQYFKw4DAhoFAKBwMBAGCisGAQQBgjcCAQwx
# AjAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSPcvjV8q3J+vNKH0QqOn4Xnfzd
# hDANBgkqhkiG9w0BAQEFAASCAQCeEClD2sI7jOnuTP26fiupYdkBTiChHR8+9KQ4
# GfvJFDZdN/H8XuA7FvmkuaUSqF5JG4TcEK05ZEJpkdvdAYrQp7HDBTR4MojdJLiI
# bwkstQ2SKi/KxEx1YOPMgZFhgxbXREdrmjtgIgu2GT29oXiyBN+SZLja7D6Tfqbn
# q60cxZaJDxZAYBVJ+k+/QwMF1fyxoM6phWGMPVAQwyBFSdANT2uMCbdXHumvUvLb
# iYv7tsg90nF+PPFAP/RPONCTsS0xpZBGM2SyN6VUvA4C7cUQ/oBB2pk+7E9nb+0h
# bwxii6uIVMayNVPQe4++HJDOQVbz9vWILQIxNF/fpjj/s4tDoYICCzCCAgcGCSqG
# SIb3DQEJBjGCAfgwggH0AgEBMHIwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5
# bWFudGVjIENvcnBvcmF0aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1w
# aW5nIFNlcnZpY2VzIENBIC0gRzICEA7P9DjI/r81bgTYapgbGlAwCQYFKw4DAhoF
# AKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE4
# MDcxMTAwMjAzMFowIwYJKoZIhvcNAQkEMRYEFCWAulMV5pjb8u4Q9rtVeETih6cW
# MA0GCSqGSIb3DQEBAQUABIIBAJ2aBaP6Nx9IYwH3n7bm83wFqII1CPBwpimvrO10
# 7Ok2JkJdsRt6FDJGa8yiXAijIc+pDuSQJhSHdCJf98/FNaNSm2hLjT1CAL9HhlH3
# X7U4O7th6kWdzn4LZIzm3tBL1ZPyQDV0jvaTS5A7YvSNTrcQz+6whHrsjDbR0zn6
# kJ80kQV293HJw2jGT754Rinhr8Rf70jpdZXhbpYYdRMLu/KCgCwP1mRHK1RQXUzU
# oVcX960st2Qpo5CSQ5fAH4W0pWeoSjBvkVABqfQxIc5WE0ce/vGkqp9oSV1YhKki
# IoYGhDzKSQIc/Zjnnx8dbND5L+o6OJdDQ9iqDx4m9Yjs0SM=
# SIG # End signature block
