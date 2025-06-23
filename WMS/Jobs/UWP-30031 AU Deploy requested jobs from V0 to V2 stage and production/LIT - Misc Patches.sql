USE [msdb]
GO

/****** Object:  Job [LIT - Misc Patches]    Script Date: 2/26/2025 3:06:26 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 2/26/2025 3:06:26 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'LIT - Misc Patches', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'databoss', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Crocs - Retain pallets for open lanes]    Script Date: 2/26/2025 3:06:26 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Crocs - Retain pallets for open lanes', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @cPalletKey NVARCHAR(40)

DECLARE CUR CURSOR FAST_FORWARD READ_ONLY FOR
 
SELECT DISTINCT PalletKey 
FROM AUSARCHIVE..PalletDetail PLD (NOLOCK)

WHERE StorerKey IN (''CROCS'', ''HPAU'') 
AND DATEDIFF(DAY, EditDate, GETDATE()) <= 14

AND EXISTS (
 SELECT 1 FROM MBOLDetail MD (NOLOCK) 
	
                             JOIN MBOL M (NOLOCK) ON M.MBOLKey = MD.MBOLKey
	
                             WHERE M.ExternMBOLKey = PLD.UserDefine03
	
                             AND OrderKey = PLD.UserDefine01
)


OPEN CUR

FETCH NEXT FROM CUR INTO @cPalletKey

WHILE @@FETCH_STATUS <> -1

BEGIN
	
EXEC isp_MoveData ''AUSARCHIVE'', ''AUSWMS'', ''dbo'', ''Pallet'', ''PalletKey'', @cPalletKey
	
EXEC isp_MoveData ''AUSARCHIVE'', ''AUSWMS'', ''dbo'', ''PalletDetail'', ''PalletKey'', @cPalletKey


FETCH NEXT FROM CUR INTO @cPalletKey

END

CLOSE CUR

DEALLOCATE CUR', 
		@database_name=N'AUSWMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 5 min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20050629, 
		@active_end_date=99991231, 
		@active_start_time=315, 
		@active_end_time=235959
		
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


