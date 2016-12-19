<#==========================================================================
Script Name: XFER-SPBM-Policies.ps1
Created on: 12/16/2016 
Created by: Jase McCarty
Github: http://www.github.com/jasemccarty
Twitter: @jasemccarty
Website: http://www.jasemccarty.com
===========================================================================

.DESCRIPTION
This script will either export SPBM policies to a folder or import SPBM policies from a folder

Syntax is:
To Export SPBM Policies to a Folder
XFER-SPBM-Policies.ps1 -Server <vCenter Server> -Action export -FilePath <path to folder where files will be exported to ending in \>
To Import SPBM Policies to a Folder
XFER-SPBM-Policies.ps1 -Server <vCenter Server> -Action import -FilePath <path to folder where files will be exported to ending in \>

.Notes

#>

# Set our Parameters
[CmdletBinding()]Param(
  [Parameter(Mandatory=$True)]
  [string]$Server,

  [Parameter(Mandatory = $true)]
  [ValidateSet('export','import')]
  [String]$Action,
  
  [Parameter(Mandatory = $true)]
  [String]$FilePath
  
)

# Policy Names that the we do not want to export 
$ExcludedPolicies = @("Default-VM-Home","Default-VirtualDisk","VSANStorageCapabilityProfile")

# Must be connected to vCenter Server 1st
# Connect-VIServer

# Check to ensure we have either enable or disable, and set our values/text
Switch ($Action) {
	"export" { 
		$ACTIONTEXT  = "Exporting SPBM Policy: "
		}
	"import" {
		$ACTIONTEXT  = "Importing SPBM Policy: " 
		}
	default {
		write-host "Please include the parameter -Action import or -Action export"
		exit
		}
	}
	
# Check to see if the path exists
If (Test-Path -Path $FilePath) {
		Write-Host "Using $FilePath" -foregroundcolor black -backgroundcolor green
	} else {
		Write-Host $FilePath "does not exist. Please enter a valid path" -foregroundcolor white -backgroundcolor red
		exit 
	}	


	If($Action -eq "export") {
	
	# Exporting Policies
	
		# Get a list of all the storage policies on the specified vCenter Server
		$StoragePolicies = Get-SpbmStoragePolicy -Server $Server
		
		# Enumerate the list of storage policies
		Foreach($StoragePolicy in $StoragePolicies) {
		
			# Get the name of the policy that is being exported.
			$PolicyName = $StoragePolicy.Name

			# If the policy is not in the excluded list, then export it to FilePath
			If ($ExcludedPolicies -notcontains $PolicyName) {
			
				Write-Host "$ACTIONTEXT $PolicyName from $Server to $FilePath" -foregroundcolor black -backgroundcolor green
				Export-SpbmStoragePolicy -FilePath $FilePath -StoragePolicy $StoragePolicy.Name -Server $Server -Force -ErrorAction SilentlyContinue
				Write-Host " "
				
				}
		}
	} else {
	
	# Importing Policies
	
		# Get all the xml files in the FilePath (***not doing xml validation***)
		$PolicyFiles = Get-ChildItem $FilePath -Filter *.xml

		# Go through each xml
		Foreach ($PolicyFile in $PolicyFiles) {
		
			# Get the PolicyFile Path 
			$PolicyFilePath = $PolicyFile.FullName

			# Get the contents of the file
			$xml = [xml](Get-Content $PolicyFilePath)

			# Grab the name of the policy so it may be set properly in vCenter
			$PolicyName = $xml.PbmCapabilityProfile.Name.'#text'
			
			# Grab the description of the policy so it may be set properly in vCenter
			$PolicyDescription = $xml.PbmCapabilityProfile.Description.'#text'
			
			Write-Host "$ACTIONTEXT $PolicyName from $FilePath to $Server" -foregroundcolor black -backgroundcolor green
			Import-SpbmStoragePolicy  -Name $PolicyName -Description $PolicyDescription -FilePath $PolicyFile -ErrorAction SilentlyContinue
			Write-Host 		
		}
	}
