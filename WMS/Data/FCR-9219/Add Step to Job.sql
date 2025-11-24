DECLARE @ReturnCode INT
DECLARE @jobId BINARY(16)
DECLARE @c_CountryCode NVARCHAR(20) = LEFT(DB_NAME(), LEN(DB_NAME()) - LEN('WMS'))
DECLARE @c_CountryITFDB NVARCHAR(20) = @c_CountryCode + 'DTSITF'
DECLARE @command NVARCHAR(MAX)

-- Get the job_id of the existing job
SELECT @jobId = job_id
FROM msdb.dbo.sysjobs
WHERE name = N'IML - SP - ' + @c_CountryCode + N' - TMS_Outbound(' + @c_CountryCode + N')'

IF @jobId IS NULL
BEGIN
    PRINT 'Job not found!'
    GOTO QUIT
END

-- Step 11 command
SET @command = N'SET ANSI_DEFAULTS OFF
EXEC isp0000P_WMS_OTM_PACK_Export 
    @c_DataStream = ''A2A0040'', 
    @c_ClientID = '''', 
    @c_ClientCountry = ''' + @c_CountryCode + N''', 
    @b_debug=0, 
    @b_Success=0, 
    @n_err=0, 
    @c_errmsg='''''

-- Add Step 11
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
    @job_id = @jobId,
    @step_name = N'PACK OUT - A2A0040',
    @step_id = 11,
    @cmdexec_success_code = 0,
    @on_success_action = 2,  -- 1=Go to next step, 2=Quit with success
    @on_success_step_id = 0,
    @on_fail_action = 2,     -- Quit with failure
    @on_fail_step_id = 0,
    @retry_attempts = 0,
    @retry_interval = 0,
    @os_run_priority = 0,
    @subsystem = N'TSQL',
    @command = @command,
    @database_name = @c_CountryITFDB,
    @flags = 0

IF (@@ERROR <> 0 OR @ReturnCode <> 0)
    PRINT 'Error adding Step 11!'
ELSE
    PRINT 'Step 11 added successfully!'

EXEC @ReturnCode = msdb.dbo.sp_update_jobstep
    @job_id = @jobId,
    @step_id = 10,
    @on_success_action = 1     -- 1 = Go to next step

IF (@@ERROR <> 0 OR @ReturnCode <> 0)
    PRINT 'Error updating Step 10!'
ELSE
    PRINT 'Step 10 updated to go to Step 11 on success.'

QUIT: