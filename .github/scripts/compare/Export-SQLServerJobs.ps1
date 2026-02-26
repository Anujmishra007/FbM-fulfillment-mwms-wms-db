#Requires -Version 5.1

<#
.SYNOPSIS
    Exports SQL Server Agent Job definitions to individual .sql files

.DESCRIPTION
    This script connects to a SQL Server instance, retrieves all SQL Server Agent Jobs,
    and exports each job definition as a separate .sql file with CREATE scripts.

.PARAMETER ServerInstance
    The SQL Server instance name (e.g., "localhost", "SERVER\INSTANCE", "SERVER,PORT")

.PARAMETER Database
    The database name (default is "msdb" where jobs are stored)

.PARAMETER OutputDirectory
    The directory path where .sql files will be saved

.PARAMETER Credential
    Optional PSCredential object for SQL Server authentication (uses Windows Auth if not provided)

.EXAMPLE
    .\Export-SQLServerJobs.ps1 -ServerInstance "localhost" -OutputDirectory "C:\JobBackups"

.EXAMPLE
    $cred = Get-Credential
    .\Export-SQLServerJobs.ps1 -ServerInstance "MYSERVER\SQLEXPRESS" -OutputDirectory "C:\JobBackups" -Credential $cred
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ServerInstance,
    
    [Parameter(Mandatory=$false)]
    [string]$Database = "msdb",
    
    [Parameter(Mandatory=$true)]
    [string]$OutputDirectory,
    
    [Parameter(Mandatory=$false)]
    [System.Management.Automation.PSCredential]$Credential
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

# Export jobs
try {
    $jobServer = $server.JobServer
    $jobs = $jobServer.Jobs
    
    if ($jobs.Count -eq 0) {
        Write-Warning "No SQL Server Agent Jobs found on $ServerInstance"
        exit 0
    }
    
    Write-Host "`nFound $($jobs.Count) job(s). Starting export..." -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Gray
    
    $successCount = 0
    $failCount = 0
    $exportedFiles = @()
    
    foreach ($job in $jobs) {
        try {
            $jobName = $job.Name
            $safeFileName = Get-SafeFileName -Name $jobName
            $filePath = Join-Path -Path $OutputDirectory -ChildPath "$safeFileName.sql"
            
            Write-Host "Exporting: $jobName" -ForegroundColor Yellow
            
            # Create scripting options
            $scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter($server)
            $scripter.Options.ScriptDrops = $false
            $scripter.Options.IncludeIfNotExists = $true
            $scripter.Options.ScriptBatchTerminator = $true
            $scripter.Options.ToFileOnly = $true
            $scripter.Options.FileName = $filePath
            $scripter.Options.AppendToFile = $false
            $scripter.Options.Encoding = [System.Text.Encoding]::UTF8
            
            # Script the job
            $scripter.Script($job)
            
            Write-Host "  -> Saved to: $filePath" -ForegroundColor Green
            $successCount++
            
            # Collect file info for CSV report
            $fileInfo = Get-Item -Path $filePath
            $lastModifiedDate = if ($job.DateLastModified) { $job.DateLastModified } else { $job.DateCreated }
            $exportedFiles += [PSCustomObject]@{
                FileName = $fileInfo.Name
                LastModified = $lastModifiedDate
            }
        }
        catch {
            Write-Warning "  -> Failed to export job: $jobName"
            Write-Warning "     Error: $($_.Exception.Message)"
            $failCount++
        }
    }
    
    Write-Host "`n" ("=" * 80) -ForegroundColor Gray
    Write-Host "Export completed!" -ForegroundColor Cyan
    Write-Host "  Success: $successCount" -ForegroundColor Green
    Write-Host "  Failed:  $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
    Write-Host "  Output:  $OutputDirectory" -ForegroundColor Cyan
    
    # Export CSV report
    if ($successCount -gt 0) {
        $csvPath = Join-Path -Path $OutputDirectory -ChildPath "_ExportReport.csv"
        $exportedFiles | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
        Write-Host "\nCSV Report saved to: $csvPath" -ForegroundColor Cyan
    }
}
catch {
    Write-Error "An error occurred during job export"
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
