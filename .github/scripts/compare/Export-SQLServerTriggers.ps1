#Requires -Version 5.1

<#
.SYNOPSIS
    Exports SQL Server Trigger definitions to individual .sql files

.DESCRIPTION
    This script connects to a SQL Server instance, retrieves all Triggers (both database-level and table-level) 
    from a specified database, and exports each trigger definition as a separate .sql file.

.PARAMETER ServerInstance
    The SQL Server instance name (e.g., "localhost", "SERVER\INSTANCE", "SERVER,PORT")

.PARAMETER Database
    The database name containing the triggers to export

.PARAMETER OutputDirectory
    The directory path where .sql files will be saved

.PARAMETER Credential
    Optional PSCredential object for SQL Server authentication (uses Windows Auth if not provided)

.PARAMETER IncludeSystemTriggers
    Include system triggers. Default is $false.

.PARAMETER SchemaFilter
    Optional schema name filter (e.g., "dbo", "API"). If not specified, exports all schemas.

.EXAMPLE
    .\Export-SQLServerTriggers.ps1 -ServerInstance "localhost" -Database "MyDB" -OutputDirectory "C:\Triggers"

.EXAMPLE
    $cred = Get-Credential
    .\Export-SQLServerTriggers.ps1 -ServerInstance "MYSERVER\SQLEXPRESS" -Database "WMS" -OutputDirectory "C:\Triggers" -Credential $cred
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
    [switch]$IncludeSystemTriggers = $false,
    
    [Parameter(Mandatory=$false)]
    [string]$SchemaFilter
)

# Function to sanitize filename
function Get-SafeFileName {
    param([string]$Name)
    $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
    $pattern = "[{0}]" -f [regex]::Escape($invalidChars)
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
    
    if (Get-Module -ListAvailable -Name SqlServer) {
        Import-Module SqlServer -ErrorAction Stop
    }
    elseif (Get-Module -ListAvailable -Name SQLPS) {
        Import-Module SQLPS -DisableNameChecking -ErrorAction Stop
    }
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
    
    $server.ConnectionContext.Connect()
    Write-Host "Connected to: $($server.Name) (Version: $($server.VersionString))" -ForegroundColor Green
}
catch {
    Write-Error "Failed to connect to SQL Server: $ServerInstance"
    Write-Error $_.Exception.Message
    exit 1
}

# Export triggers
try {
    $db = $server.Databases[$Database]
    
    if ($null -eq $db) {
        Write-Error "Database '$Database' not found on server $ServerInstance"
        exit 1
    }
    
    Write-Host "Using database: $Database" -ForegroundColor Green
    
    # Collect all triggers (database-level and table-level)
    $allTriggers = @()
    
    # Database-level triggers
    foreach ($trigger in $db.Triggers) {
        if (-not $IncludeSystemTriggers -and $trigger.IsSystemObject) {
            continue
        }
        $allTriggers += @{
            Object = $trigger
            Name = $trigger.Name
            Type = "Database"
            Parent = ""
        }
    }
    
    # Table-level triggers
    foreach ($table in $db.Tables) {
        if ($SchemaFilter -and $table.Schema -ne $SchemaFilter) {
            continue
        }
        
        foreach ($trigger in $table.Triggers) {
            if (-not $IncludeSystemTriggers -and $trigger.IsSystemObject) {
                continue
            }
            $allTriggers += @{
                Object = $trigger
                Name = $trigger.Name
                Type = "Table"
                Parent = "$($table.Schema).$($table.Name)"
            }
        }
    }
    
    if ($allTriggers.Count -eq 0) {
        Write-Warning "No triggers found in database $Database"
        exit 0
    }
    
    Write-Host "`nFound $($allTriggers.Count) trigger(s). Starting export..." -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Gray
    
    $successCount = 0
    $failCount = 0
    $exportedFiles = @()
    
    foreach ($triggerInfo in $allTriggers) {
        try {
            $trigger = $triggerInfo.Object
            $triggerName = if ($triggerInfo.Parent) {
                "$($triggerInfo.Parent).$($trigger.Name)"
            } else {
                $trigger.Name
            }
            
            $safeFileName = Get-SafeFileName -Name $triggerName
            $filePath = Join-Path -Path $OutputDirectory -ChildPath "$safeFileName.sql"
            
            Write-Host "Exporting: $triggerName [$($triggerInfo.Type) Trigger]" -ForegroundColor Yellow
            
            $scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter($server)
            $scripter.Options.ScriptDrops = $false
            $scripter.Options.IncludeIfNotExists = $false
            $scripter.Options.ScriptBatchTerminator = $true
            $scripter.Options.ToFileOnly = $true
            $scripter.Options.FileName = $filePath
            $scripter.Options.AppendToFile = $false
            $scripter.Options.Encoding = [System.Text.Encoding]::UTF8
            $scripter.Options.ScriptSchema = $true
            $scripter.Options.IncludeDatabaseContext = $false
            $scripter.Options.AnsiFile = $true
            $scripter.Options.DriAll = $false
            $scripter.Options.NoCommandTerminator = $false
            
            $scripter.Script($trigger)
            
            Write-Host "  -> Saved to: $filePath" -ForegroundColor Green
            $successCount++
            
            # Collect file info for CSV report
            $fileInfo = Get-Item -Path $filePath
            $lastModifiedDate = if ($trigger.DateLastModified) { $trigger.DateLastModified } else { $trigger.CreateDate }
            $exportedFiles += [PSCustomObject]@{
                FileName = $fileInfo.Name
                LastModified = $lastModifiedDate
            }
        }
        catch {
            Write-Warning "  -> Failed to export: $triggerName"
            Write-Warning "     Error: $($_.Exception.Message)"
            $failCount++
        }
    }
    
    Write-Host "`n" ("=" * 80) -ForegroundColor Gray
    Write-Host "Export completed!" -ForegroundColor Cyan
    Write-Host "  Success: $successCount" -ForegroundColor Green
    Write-Host "  Failed:  $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
    Write-Host "  Output:  $OutputDirectory" -ForegroundColor Cyan
    
    if ($successCount -gt 0) {
        Write-Host "`nType breakdown:" -ForegroundColor Cyan
        $dbTriggers = ($allTriggers | Where-Object { $_.Type -eq "Database" }).Count
        $tableTriggers = ($allTriggers | Where-Object { $_.Type -eq "Table" }).Count
        Write-Host "  Database Triggers: $dbTriggers" -ForegroundColor Gray
        Write-Host "  Table Triggers: $tableTriggers" -ForegroundColor Gray        
        # Export CSV report
        $csvPath = Join-Path -Path $OutputDirectory -ChildPath "_ExportReport.csv"
        $exportedFiles | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
        Write-Host "\nCSV Report saved to: $csvPath" -ForegroundColor Cyan    }
}
catch {
    Write-Error "An error occurred during trigger export"
    Write-Error $_.Exception.Message
    exit 1
}
finally {
    if ($server.ConnectionContext.IsOpen) {
        $server.ConnectionContext.Disconnect()
        Write-Host "`nDisconnected from SQL Server" -ForegroundColor Gray
    }
}
