USE [msdb]
GO

/****** Object:  Job [BEJ - isp_PreAllocOrderSortation_VIVO (DE003 - VIVO)]    Script Date: 17/10/2025 2:06:09 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/2/2025 2:06:09 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BEJ - isp_PreAllocOrderSortation_VIVO (DE003 - VIVO)', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Pre Allocation Order Sortation DE003 - VIVO', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'ddladminuser9', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [1]    Script Date: 10/2/2025 2:06:09 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE	@return_value int,
		@b_Success int,
		@n_Err int,
		@c_ErrMsg nvarchar(250)

EXEC	@return_value = [dbo].[isp_PreAllocOrderSortation_VIVO]
		@b_Success = @b_Success OUTPUT,
		@n_Err = @n_Err OUTPUT,
		@c_ErrMsg = @c_ErrMsg OUTPUT

SELECT	@b_Success as N''@b_Success'',
		@n_Err as N''@n_Err'',
		@c_ErrMsg as N''@c_ErrMsg''

SELECT	''Return Value'' = @return_value
', 
		@database_name=N'DEUWMS', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'5 Min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20050629, 
		@active_end_date=99991231, 
		@active_start_time=300, 
		@active_end_time=235959, 
		@schedule_uid=N'13f42f34-5bf7-4ea1-998a-7457a4a79a4c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


