USE [msdb]
GO

DECLARE @c_JobName SYSNAME = N'BEJ - Auto Hold Expired Item(ZAF)'
      , @c_DBName  SYSNAME = N'ZAFWMS'


IF NOT EXISTS(SELECT TOP 1 1 FROM sys.databases WHERE name=@c_DBName)
   GOTO QuitWithRollback

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
   EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
SELECT @jobId = job_id FROM msdb.dbo.sysjobs where name=@c_JobName

IF @jobId IS NULL
BEGIN
   EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@c_JobName,
         @enabled=1,
         @notify_level_eventlog=0,
         @notify_level_email=0,
         @notify_level_netsend=0,
         @notify_level_page=0,
         @delete_level=0,
         @description=N'No description available.',
         @category_name=N'[Uncategorized (Local)]',
         @job_id = @jobId OUTPUT
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

IF EXISTS(SELECT TOP 1 1
   FROM msdb.dbo.sysjobs a
   LEFT JOIN msdb.dbo.sysjobsteps b ON a.job_id = b.job_id
   WHERE a.name = @c_JobName AND b.job_id IS NULL)
BEGIN
   EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'TriggerAutoHoldExpiredItem',
         @step_id=1,
         @cmdexec_success_code=0,
         @on_success_action=1,
         @on_success_step_id=0,
         @on_fail_action=2,
         @on_fail_step_id=0,
         @retry_attempts=0,
         @retry_interval=0,
         @os_run_priority=0, @subsystem=N'TSQL',
         @command=N'SET ANSI_DEFAULTS OFF
EXEC [dbo].[ispFetchStorersAndTriggerAutoHoldExpiredItem]',
         @database_name=@c_DBName,
         @flags=0
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
   EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

IF EXISTS(SELECT TOP 1 1
   FROM msdb.dbo.sysjobs a
   LEFT JOIN msdb.dbo.sysjobschedules b ON a.job_id=b.job_id
   WHERE a.name = @c_JobName AND b.job_id IS NULL)
BEGIN
   EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Auto Hold Expired Item',
         @enabled=1,
         @freq_type=4,
         @freq_interval=1,
         @freq_subday_type=1,
         @freq_subday_interval=0,
         @freq_relative_interval=0,
         @freq_recurrence_factor=0,
         @active_start_date=20250909,
         @active_end_date=99991231,
         @active_start_time=100,
         @active_end_time=235959
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

IF EXISTS(SELECT TOP 1 1
   FROM msdb.dbo.sysjobs a
   LEFT JOIN msdb.dbo.sysjobservers b ON a.job_id=b.job_id
   WHERE a.name = @c_JobName AND b.job_id IS NULL)
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
