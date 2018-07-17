# Title: SPOAllSitesAndSubsitesPlusOwners.ps1
#
# This PowerShell script is for SharePoint Online Service and it can be used to export a list of
# all of the sites and subsites and associated owners
#
# This script employs additional module called SharePointPnPPowerShellOnline, you can install that
# from PS library using following command:
#  > Install-Module SharePointPnPPowerShellOnline
#
# Author Mikhail Kostechuk
# Distributed under GPLv3 license

$credentials = Get-Credential
$siteParent = <INPUT YOUR ROOT SPO SITE HERE>
$outputPath = "C:\temp\AllSubsitegrouppermission.csv"

function Get-SPOAllSitesAndSubsitesPlusOwners ($credentials,$siteParent) {

    Connect-PNPonline -Url $siteParent -Credentials $credentials
    $subwebs = Get-PNPSubWebs
    $result = @()

    foreach ($site in $subwebs) {
        Connect-PNPonline -Url $site.Url -Credentials $credentials
        Write-Host ""
        Write-Host "--------------------------------------------"
        Write-Host $site.Url
        Write-Host ""

        $groups = Get-PNPGroup
        $k = 0

        foreach($group in $groups) {
            $queryObj = "" | Select "SiteUrl","GroupName","Permission", "Users"
            if ($k -eq 100) {
                Write-Host ""
                $k = 0
            }
            if ($group.LoginName -Like "*wner*") {
                $perm = Get-PNPGroupPermissions -Identity $group.loginname -ErrorAction SilentlyContinue
                if ($perm -ne $null) {
                    Write-Host -NoNewline "!"
            
                    $queryObj.SiteUrl = $site.Url
                    $queryObj.GroupName = $group.loginname
                    $queryObj.Permission = $perm.name
            
                    $grpUsers = Get-SPOSiteGroup -Group $group.loginname -Site $siteParent | Select Users
                    $usersString = ""
                    foreach ($user in $grpUsers.Users) {
                        $usersString += "$($user),"
                    }
                    $queryObj.Users = $usersString
            
                    $result += $queryObj

                    $k += 1
                } else {
                    Write-Host -NoNewline "."
                    $k += 1            
                }
            } else {
                Write-Host -NoNewline "x"
                $k += 1
            }
        }

        Write-Host ""
        Write-Host "--------------------------------------------"

#        foreach ($rec in $result) {
#            Write-Host "SiteUrl: ", $rec.SiteUrl
#            Write-Host "Group Name: ", $rec.GroupName
#            Write-Host "Permission: ", $rec.Permission
#            Write-Host "Users in the grp: ", $rec.Users
#            Write-Host "--------------------------------------------"
#        }
    }
}

Get-SPOAllSitesAndSubsitesPlusOwners $credentials $siteParent
$result | Export-Csv -NoTypeInformation -Path $outputPath
