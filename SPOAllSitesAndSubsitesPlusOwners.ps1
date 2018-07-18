# FILENAME:
# SPOAllSitesAndSubsitesPlusOwners.ps1
#
# INFO:
# This PowerShell script is for SharePoint Online Service and it can be used to export a list of
# all of the sites and subsites and associated owners
#
# NOTE:
# If you have some naming standard for owner groups across all of your SPO sites - please adjust
# the filter on line 52, or at least set it to "Sharing*" to filter out SharingLinks, or you will
# have to iterate through all of the groups and sharing links an this will take forever!
#
# DEPENDENCY:
# This script employs additional module called SharePointPnPPowerShellOnline, you can install that
# from PS online library using following command:
#  > Install-Module SharePointPnPPowerShellOnline
#
# More info here:
# https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-pnp/sharepoint-pnp-cmdlets
#
# Author Mikhail Kostechuk
# Distributed under GPLv3 license

clear

$credentials = Get-Credential

# $siteParent should be an address to the site collection, it is used to grab groups
$siteParent = <PUT YOUR PARENT SPO SITE COLLECTION HERE>

# $site is a starting point (root site) for the script, change this if you don't want to iterate
# through the whole collection
$site = $siteParent

# Make sure the path set below exists
$outputPath = "C:\temp\AllSubsitegrouppermission.csv"

function Write-Log ($string) {
    Write-Host (get-date).ToString('T'), $string
}

function Get-SPOAllSitesAndSubsitesPlusOwners ($credentials, $siteParent, $site, $groups) {
    Connect-PNPonline -Url $site -Credentials $credentials
    $result = @()
                 
    if ($groups.Count -eq 0) {
        Write-Log "=============== Get-PNPGroup started"
        $groups = Get-PNPGroup
        Write-Log "=============== Get-PNPGroup done! Total groups in the list:", $groups.Count
        Write-Log "=============== Filtering out..."
        # Group filter below
        $groups = $groups | Where-Object { $_.LoginName –Like "*wner*" }
        Write-Log "=============== Filtering done! Total groups in the list:", $groups.Count
    }

    Write-Host ""
    Write-Host "--------------------------------------------"
    Write-Log "=============== NEXT:", $site
    Write-Host ""

    $k = 0

    foreach($group in $groups) {
        $queryObj = "" | Select "SiteUrl","GroupName","Permission", "Users"
        if ($k -eq 100) {
            Write-Host ""
            $k = 0
        }

        $perm = Get-PNPGroupPermissions -Identity $group.loginname -ErrorAction SilentlyContinue
        if ($perm -ne $null) {
            Write-Host -NoNewline "!"
            
            $queryObj.SiteUrl = $site
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
    }

    if ($result.Count -eq 0) {
        $queryObj.SiteUrl = $site
        $queryObj.GroupName = "N/A"
        $queryObj.Permission = "N/A"
        $result += $queryObj       
    }

    Write-Host ""
    Write-Host "--------------------------------------------"

    foreach ($rec in $result) {
        Write-Log "Following data fetched for SiteUrl:", $rec.SiteUrl
        Write-Host "Group Name:", $rec.GroupName
        Write-Host "Permission:", $rec.Permission
        Write-Host "Users in the grp:", $rec.Users
        Write-Host "--------------------------------------------"
    }   

    $result | Export-Csv -Append -NoTypeInformation -Path $outputPath

    $subwebs = Get-PNPSubWebs
    if ($subwebs.Count -ne 0) {
        foreach ($nextSite in $subwebs) {
            Get-SPOAllSitesAndSubsitesPlusOwners $credentials $siteParent $nextSite.Url $groups    
        }
    }
}

Get-SPOAllSitesAndSubsitesPlusOwners $credentials $siteParent $site @()
