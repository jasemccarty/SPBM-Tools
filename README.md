.DESCRIPTION
This script will either export SPBM policies to a folder or import SPBM policies from a folder

Syntax is:
To Export SPBM Policies to a Folder
XFER-SPBM-Policies.ps1 -Server <vCenter Server> -Action export -FilePath <path to folder where files will be exported to ending in \>
To Import SPBM Policies to a Folder
XFER-SPBM-Policies.ps1 -Server <vCenter Server> -Action import -FilePath <path to folder where files will be exported to ending in \>
