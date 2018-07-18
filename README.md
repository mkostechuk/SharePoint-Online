# SharePoint-Online
Various SharePoint Online related stuff

#### SPOAllSitesAndSubsitesPlusOwners
###### FILENAME:
SPOAllSitesAndSubsitesPlusOwners.ps1

###### INFO:
This PowerShell script is for SharePoint Online Service and it can be used to export a list of
all of the sites and subsites and associated owners

###### NOTE:
If you have some naming standard for owner groups across all of your SPO sites - please adjust
the filter on line 52, or at least set it to "Sharing*" to filter out SharingLinks, or you will
have to iterate through all of the groups and sharing links an this will take forever!

###### DEPENDENCY:
This script employs additional module called SharePointPnPPowerShellOnline, you can install that
from PS online library using following command:
PS> Install-Module SharePointPnPPowerShellOnline

More info here:
https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-pnp/sharepoint-pnp-cmdlets
