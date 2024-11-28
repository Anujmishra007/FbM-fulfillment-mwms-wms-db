USE [msdb]
GO

/****** Object:  Job [BEJ - mWMS Swap Lot(SAU)]    Script Date: 11/28/2024 12:58:04 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
      , @astart_date NVARCHAR(8) = REPLACE(CONVERT(NVARCHAR(10), GETDATE(),121),'-','')
      
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/28/2024 12:58:04 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
SELECT @jobId = j.job_id FROM msdb..sysjobs j where j.name =N'BEJ - mWMS Swap Lot(SAU)'
 
IF @jobId IS NULL
BEGIN
   EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BEJ - mWMS Swap Lot(SAU)', 
   		@enabled=1, 
   		@notify_level_eventlog=2, 
   		@notify_level_email=0, 
   		@notify_level_netsend=0, 
   		@notify_level_page=0, 
   		@delete_level=0, 
   		@description=N'No description available.', 
   		@category_name=N'[Uncategorized (Local)]', 
   		@owner_login_name=N'databoss', @job_id = @jobId OUTPUT
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END
/****** Object:  Step [Storer Swap Lot By Codelkup Setup]    Script Date: 11/28/2024 12:58:04 PM ******/
IF NOT EXISTS (SELECT 1 FROM msdb..sysjobsteps js
               JOIN msdb..sysjobs j ON j.job_id = js.job_id
               WHERE js.command like '%msp_BEJ%''BEJ-SwapLot''%' 
               and Database_Name = 'SAUWMS'
               AND j.job_id = @jobId
              )
BEGIN   
   EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Storer Swap Lot By Codelkup Setup', 
   		@step_id=1, 
   		@cmdexec_success_code=0, 
   		@on_success_action=1, 
   		@on_success_step_id=0, 
   		@on_fail_action=2, 
   		@on_fail_step_id=0, 
   		@retry_attempts=0, 
   		@retry_interval=1, 
   		@os_run_priority=0, @subsystem=N'TSQL', 
   		@command=N'SET ANSI_DEFAULTS OFF
      EXEC msp_BEJ ''BEJ-SwapLot''', 
   		@database_name=N'SAUWMS', 
   		@flags=0
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

   EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
   EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 5 Mins', 
   		@enabled=1, 
   		@freq_type=4, 
   		@freq_interval=1, 
   		@freq_subday_type=4, 
   		@freq_subday_interval=5, 
   		@freq_relative_interval=0, 
   		@freq_recurrence_factor=0, 
   		@active_start_date=@astart_date, 
   		@active_end_date=99991231, 
   		@active_start_time=205, 
   		@active_end_time=235959, 
   		@schedule_uid=N'7c0ba23e-d6b4-4f9b-8ae5-68915dab5f6b'
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

IF NOT EXISTS (SELECT *
               FROM msdb.dbo.sysjobservers  
               WHERE job_id = @jobId
               AND server_id = 0
               )
BEGIN
   EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


