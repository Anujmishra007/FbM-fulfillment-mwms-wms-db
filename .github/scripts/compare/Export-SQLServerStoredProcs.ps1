#Requires -Version 5.1

<#
.SYNOPSIS
    Exports SQL Server Stored Procedure definitions to individual .sql files

.DESCRIPTION
    This script connects to a SQL Server instance, retrieves all Stored Procedures from a specified database,
    and exports each procedure definition as a separate .sql file with CREATE/ALTER scripts.

.PARAMETER ServerInstance
    The SQL Server instance name (e.g., "localhost", "SERVER\INSTANCE", "SERVER,PORT")

.PARAMETER Database
    The database name containing the stored procedures to export

.PARAMETER OutputDirectory
    The directory path where .sql files will be saved

.PARAMETER Credential
    Optional PSCredential object for SQL Server authentication (uses Windows Auth if not provided)

.PARAMETER IncludeSystemProcs
    Include system stored procedures (sp_* and others). Default is $false.

.PARAMETER SchemaFilter
    Optional schema name filter (e.g., "dbo", "API"). If not specified, exports all schemas.

.EXAMPLE
    .\Export-SQLServerStoredProcs.ps1 -ServerInstance "localhost" -Database "MyDB" -OutputDirectory "C:\StoredProcs"

.EXAMPLE
    $cred = Get-Credential
    .\Export-SQLServerStoredProcs.ps1 -ServerInstance "MYSERVER\SQLEXPRESS" -Database "WMS" -OutputDirectory "C:\StoredProcs" -Credential $cred

.EXAMPLE
    .\Export-SQLServerStoredProcs.ps1 -ServerInstance "localhost" -Database "WMS" -OutputDirectory "C:\StoredProcs" -SchemaFilter "API"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ServerInstance,
    
    [Parameter(Mandatory=$true)]
    [string]$Database,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputDirectory,
    
    [Parameter(Mandatory=$false)]
    [System.Management.Automation.PSCredential]$Credential,
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeSystemProcs = $false,
    
    [Parameter(Mandatory=$false)]
    [string]$SchemaFilter
)

# Function to sanitize filename (handles both OS-specific and GitHub Actions artifact restrictions)
function Get-SafeFileName {
    param([string]$Name)
    # GitHub Actions artifacts don't allow: " : < > | * ? \r \n
    # Also include OS-specific invalid chars
    $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
    $additionalInvalid = '":;<>|*?'  # Explicitly add chars that may not be caught on Linux
    $allInvalid = $invalidChars + $additionalInvalid
    $pattern = "[{0}]" -f [regex]::Escape($allInvalid)
    return $Name -replace $pattern, '_'
}

# Create output directory if it doesn't exist
if (-not (Test-Path -Path $OutputDirectory)) {
    Write-Host "Creating output directory: $OutputDirectory" -ForegroundColor Green
    New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
}

# Load SQL Server SMO Assembly
try {
    Write-Host "Loading SQL Server SMO assemblies..." -ForegroundColor Cyan
    
    # Try to load from SqlServer module first (preferred)
    if (Get-Module -ListAvailable -Name SqlServer) {
        Import-Module SqlServer -ErrorAction Stop
    }
    # Fallback to SQLPS module
    elseif (Get-Module -ListAvailable -Name SQLPS) {
        Import-Module SQLPS -DisableNameChecking -ErrorAction Stop
    }
    # Manual assembly loading as last resort
    else {
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | Out-Null
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.Smo") | Out-Null
    }
    
    Write-Host "SMO assemblies loaded successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to load SQL Server SMO assemblies. Please install SQL Server Management Studio or SqlServer PowerShell module."
    Write-Error $_.Exception.Message
    exit 1
}

# Connect to SQL Server
try {
    Write-Host "Connecting to SQL Server instance: $ServerInstance" -ForegroundColor Cyan
    
    $server = New-Object Microsoft.SqlServer.Management.Smo.Server($ServerInstance)
    
    # Set authentication mode
    if ($Credential) {
        $server.ConnectionContext.LoginSecure = $false
        $server.ConnectionContext.Login = $Credential.UserName
        $server.ConnectionContext.SecurePassword = $Credential.Password
    }
    else {
        $server.ConnectionContext.LoginSecure = $true
    }
    
    # Trust server certificate for remote connections
    $server.ConnectionContext.TrustServerCertificate = $true
    
    # Test connection
    $server.ConnectionContext.Connect()
    Write-Host "Connected to: $($server.Name) (Version: $($server.VersionString))" -ForegroundColor Green
}
catch {
    Write-Error "Failed to connect to SQL Server: $ServerInstance"
    Write-Error $_.Exception.Message
    exit 1
}

# Export stored procedures
try {
    # Get database
    $db = $server.Databases[$Database]
    
    if ($null -eq $db) {
        Write-Error "Database '$Database' not found on server $ServerInstance"
        exit 1
    }
    
    Write-Host "Using database: $Database" -ForegroundColor Green
    
    # Get stored procedures
    $storedProcs = $db.StoredProcedures
    
    if ($storedProcs.Count -eq 0) {
        Write-Warning "No stored procedures found in database $Database"
        exit 0
    }
    
    # Filter stored procedures
    $filteredProcs = @()
    foreach ($proc in $storedProcs) {
        # Skip system procedures unless explicitly included
        if (-not $IncludeSystemProcs -and $proc.IsSystemObject) {
            continue
        }
        
        # Apply schema filter if specified
        if ($SchemaFilter -and $proc.Schema -ne $SchemaFilter) {
            continue
        }
        
        $filteredProcs += $proc
    }
    
    if ($filteredProcs.Count -eq 0) {
        Write-Warning "No stored procedures match the filter criteria"
        exit 0
    }
    
    Write-Host "`nFound $($filteredProcs.Count) stored procedure(s). Starting export..." -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Gray
    
    $successCount = 0
    $failCount = 0
    $exportedFiles = @()
    
    foreach ($proc in $filteredProcs) {
        try {
            $procName = "$($proc.Schema).$($proc.Name)"
            $safeFileName = Get-SafeFileName -Name $procName
            $filePath = Join-Path -Path $OutputDirectory -ChildPath "$safeFileName.sql"
            
            Write-Host "Exporting: $procName" -ForegroundColor Yellow
            
            # Create scripting options
            $scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter($server)
            $scripter.Options.ScriptDrops = $false
            $scripter.Options.IncludeIfNotExists = $false
            $scripter.Options.ScriptBatchTerminator = $true
            $scripter.Options.ToFileOnly = $true
            $scripter.Options.FileName = $filePath
            $scripter.Options.AppendToFile = $false
            $scripter.Options.Encoding = [System.Text.Encoding]::UTF8
            
            # Include CREATE and ALTER style scripting
            $scripter.Options.ScriptSchema = $true
            $scripter.Options.IncludeDatabaseContext = $false
            $scripter.Options.AnsiFile = $true
            $scripter.Options.DriAll = $false
            $scripter.Options.NoCommandTerminator = $false
            
            # Script the stored procedure
            $scripter.Script($proc)
            
            Write-Host "  -> Saved to: $filePath" -ForegroundColor Green
            $successCount++
            
            # Collect file info for CSV report
            $fileInfo = Get-Item -Path $filePath
            $lastModifiedDate = if ($proc.DateLastModified) { $proc.DateLastModified } else { $proc.CreateDate }
            $exportedFiles += [PSCustomObject]@{
                FileName = $fileInfo.Name
                LastModified = $lastModifiedDate
            }
        }
        catch {
            Write-Warning "  -> Failed to export: $procName"
            Write-Warning "     Error: $($_.Exception.Message)"
            $failCount++
        }
    }
    
    Write-Host "`n" ("=" * 80) -ForegroundColor Gray
    Write-Host "Export completed!" -ForegroundColor Cyan
    Write-Host "  Success: $successCount" -ForegroundColor Green
    Write-Host "  Failed:  $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
    Write-Host "  Output:  $OutputDirectory" -ForegroundColor Cyan
    
    # Show schema breakdown
    if ($successCount -gt 0) {
        Write-Host "`nSchema breakdown:" -ForegroundColor Cyan
        $schemaGroups = $filteredProcs | Group-Object -Property Schema | Sort-Object Name
        foreach ($group in $schemaGroups) {
            Write-Host "  $($group.Name): $($group.Count) procedure(s)" -ForegroundColor Gray
        }        
        # Export CSV report
        $csvPath = Join-Path -Path $OutputDirectory -ChildPath "_ExportReport.csv"
        $exportedFiles | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
        Write-Host "\nCSV Report saved to: $csvPath" -ForegroundColor Cyan    }
}
catch {
    Write-Error "An error occurred during stored procedure export"
    Write-Error $_.Exception.Message
    exit 1
}
finally {
    # Disconnect
    if ($server.ConnectionContext.IsOpen) {
        $server.ConnectionContext.Disconnect()
        Write-Host "`nDisconnected from SQL Server" -ForegroundColor Gray
    }
}
