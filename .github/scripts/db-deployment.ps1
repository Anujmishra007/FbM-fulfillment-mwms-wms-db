############################# Dynamic Varibles #############################
$WMSDB_NAME = "#{DATBASE_NAME}#"
$WMSDB_DB_SERVER_NAME = "#{DB_SERVER_NAME}#"
$SQL_SCRIPT_FILES = ('#{SQL_SCRIPT_FILES_STRING}#').Split(",")

# Check if Dynamic variables are specified
if (($SQL_SCRIPT_FILES.Count -eq 0) -or ($WMSDB_NAME -eq "") -or ($WMSDB_DB_SERVER_NAME -eq "")) {
    Write-Host "One or more required variables are not set. Please ensure that WMSDB_NAME, WMSDB_DB_SERVER_NAME, and SQL_SCRIPT_FILES are defined."
    exit
}

# Separate WMS\Tables\ scripts and others
$wmsTablesScripts = $SQL_SCRIPT_FILES | Where-Object { $_ -like "*WMS\Tables\*" }
$otherScripts = $SQL_SCRIPT_FILES | Where-Object { $_ -notlike "*WMS\Tables\*" }

# Combine with WMS\Tables\ scripts first
$SQL_SCRIPT_FILES = $wmsTablesScripts + $otherScripts

############################# Static Varibles #############################
$username = "admin_user"
# Prompt for the password securely
$password = "#{DB_ADMIN_USER_PASSWORD}#"

# Generate a unique timestamp for the log files
$timestamp = Get-Date -Format 'dd_MMM_yy_HH-mm-ss'
New-Item -ItemType Directory  -Name "logs" | Out-Null
$logFilePath = ".\logs\$($WMSDB_NAME).txt"
$errorFilePath = ".\logs\logs_error_$($timestamp).txt"

$ERROR_FOUND = $false
foreach ($scriptFile in $SQL_SCRIPT_FILES) {
    # Check if the file exists
    if (-Not (Test-Path $scriptFile)) {
        Write-Host "The specified SQL file does not exist: $scriptFile"
        continue  # Skip to the next file
    }

    # Read the SQL script content
    $sqlQuery = Get-Content -Path $scriptFile -Raw

    # Output the script name for logging purposes
    $logMessage = "====================$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Running script: $($scriptFile) on server: $($WMSDB_DB_SERVER_NAME), database: $($WMSDB_NAME)===================="
    Write-Host $logMessage
    Add-Content -Path $logFilePath -Value $logMessage -Encoding UTF8
    try {
        # Run the SQL script using Invoke-Sqlcmd
        unix2dos "$scriptFile"
        $connectionString = "Server=$($WMSDB_DB_SERVER_NAME);Database=$($WMSDB_NAME);User Id=$($username);Password=$($password);TrustServerCertificate=True;"
        Invoke-Sqlcmd -ConnectionString $connectionString -Query $sqlQuery -ErrorAction Stop | Tee-Object -FilePath $logFilePath -Encoding utf8 -Append
  

        $successMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Successfully executed: $($scriptFile) on server: $($WMSDB_DB_SERVER_NAME), database: $($WMSDB_NAME)"
        Write-Output $successMessage
        Add-Content -Path $logFilePath -Value $successMessage -Encoding UTF8
        Add-Content -Path $logFilePath -Value ' ' -Encoding UTF8
    }
    catch {
        $errorMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - [SqlQueryExecutionFailure] Failed to execute: $($scriptFile) on server: $($WMSDB_DB_SERVER_NAME), database: $($WMSDB_NAME) - Error: $($_.Exception.Message)"
        Write-Output $errorMessage
        Add-Content -Path $logFilePath -Value $errorMessage -Encoding UTF8
        Add-Content -Path $errorFilePath -Value $errorMessage -Encoding UTF8
        $ERROR_FOUND = $true
    }
}
if($ERROR_FOUND)
{
    throw "One or more SQL scripts failed to execute. Please check the logs and error files for details."
}
