# Define a hashtable of server instances and their corresponding databases
$serverInstances = @{

    #CDT
    #"wmsdb1" = @("GLOWMS","NLDWMS","GBRWMS")
    "wmsdb-a-utc-4"  = @("USA4DNJWMS")
}

$username = "admin_user"

# Prompt for the password securely
$password = "{{DB_ADMIN_USER_PASSWORD}}"

# Define an array of SQL script paths
$sqlScriptFiles = @(
"c:\temp\FbM-fulfillment-mwms-wms-db\WMS\StoredProc\isp_ODMRPL01.sql"
)

# Check if any SQL files are specified
if ($sqlScriptFiles.Count -eq 0) {
    Write-Host "No SQL files specified."
    exit
}

# Generate a unique timestamp for the log files
$timestamp = Get-Date -Format 'dd_MMM_yy_HH-mm-ss'
$logFilePath = "D:\log_$timestamp.txt"
$errorFilePath = "D:\error_$timestamp.txt"

foreach ($serverInstance in $serverInstances.Keys) {
    $databases = $serverInstances[$serverInstance]

    foreach ($database in $databases) {
        foreach ($scriptFile in $sqlScriptFiles) {
            # Check if the file exists
            if (-Not (Test-Path $scriptFile)) {
                Write-Host "The specified SQL file does not exist: $scriptFile"
                continue  # Skip to the next file
            }

            # Read the SQL script content
            $sqlQuery = Get-Content -Path $scriptFile -Raw

            # Output the script name for logging purposes
            $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Running script: $($scriptFile) on server: $serverInstance, database: $database"
            Write-Host $logMessage
            Add-Content -Path $logFilePath -Value $logMessage

            try {
                # Run the SQL script using Invoke-Sqlcmd
                $connectionString = "Server=$serverInstance;Database=$database;User Id=$username;Password=$password;TrustServerCertificate=True;"
                Invoke-Sqlcmd -ConnectionString $connectionString -Query $sqlQuery -ErrorAction Stop
                $successMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Successfully executed: $($scriptFile) on server: $serverInstance, database: $database"
                Write-Host $successMessage
                Add-Content -Path $logFilePath -Value $successMessage
            }
            catch {
                $errorMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Failed to execute: $($scriptFile) on server: $serverInstance, database: $database - Error: $($_.Exception.Message)"
                Write-Host $errorMessage
                Add-Content -Path $logFilePath -Value $errorMessage
                Add-Content -Path $errorFilePath -Value $errorMessage
            }
        }
    }
}
