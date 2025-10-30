DECLARE @DBName NVARCHAR(10) = 'GLOWMS'

IF NOT EXISTS (SELECT 1 FROM master.sys.databases WHERE name = @DBName)
BEGIN
	GOTO EndSave
END

DECLARE
        @OrderKey        NVARCHAR(50),
        @StorerKey       NVARCHAR(15),
        @EditWho         NVARCHAR(128),
        @TransmitLogKey  NVARCHAR(50),
        @b_Success       INT,
        @n_Err           INT,
        @c_ErrMsg        NVARCHAR(200);

    -- Cursor over ALL qualifying orders (no TOP 1)
    DECLARE curOrders CURSOR LOCAL FAST_FORWARD FOR
    SELECT Distinct
        o.orderkey,
        o.storerkey,
        ph.editwho
    FROM dbo.orders o WITH (NOLOCK)
    JOIN dbo.packheader ph WITH (NOLOCK)
      ON o.orderkey  = ph.orderkey
     AND o.storerkey = ph.storerkey
    WHERE
        o.storerkey = 'SWISSE'
        AND o.type    IN ('B2C')
        AND ph.status = '9'
        AND o.status  IN ('5','9')
        AND ISNULL(o.trackingno,'') = ''
		and  isnull(rtntrackingno,'') = ''
		and c_country <> 'Australia' and O.type not in ('OTO','VRT')
		and o.shipperkey = 'FDX'
        AND o.orderkey NOT IN (
            SELECT orderkey
            FROM dbo.orders WITH (NOLOCK)
            WHERE
                storerkey  = 'SWISSE'
                AND c_contact1 LIKE 'STAFF%'
                AND type = 'B2C'
                AND c_city IN ('Collingwood','Ravenhall')
        )
        AND o.orderkey NOT IN (
            SELECT key1
            FROM dbo.transmitlog2 WITH (NOLOCK)
            WHERE
                key3      = 'SWISSE'
                AND tablename = 'WSCRSOREQMW'
        );

    OPEN curOrders;
    FETCH NEXT FROM curOrders INTO @OrderKey, @StorerKey, @EditWho;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- generate a new unique transmitlogkey for this order
        EXEC dbo.nspg_getkey
            'TransmitlogKey2',  -- key name
            10,                  -- key length
            @TransmitLogKey OUTPUT,
            @b_Success     OUTPUT,
            @n_Err         OUTPUT,
            @c_ErrMsg      OUTPUT;

        -- insert one record per order, with its own unique key
        INSERT INTO dbo.transmitlog2
            (transmitlogkey, tablename, key1, key2, key3, transmitflag, addwho, adddate, editwho, editdate)
        VALUES
            (
              @TransmitLogKey,
              'WSCRSOREQMW',
              @OrderKey,
              '',
              @StorerKey,
              '0',
              @EditWho,
              GETDATE(),
              @EditWho,
              GETDATE()
            );

        FETCH NEXT FROM curOrders INTO @OrderKey, @StorerKey, @EditWho;
    END

    CLOSE curOrders;
    DEALLOCATE curOrders;


/****** Object:  Step [BEJ - SWISSE B2C TL2 INTL]    Script Date: 10/30/2025 ******/
IF NOT EXISTS (SELECT 1 from msdb..sysjobsteps js
               JOIN msdb..sysjobs j on j.job_id = js.job_id
			   WHERE js.command LIKE '%EXEC BEJ_SWISSE_B2C_TL2_INTL_AUS%'
               AND database_name = 'GLOWMS'
               AND j.job_id = @jobId
              )
BEGIN  
   EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'BEJ - SWISSE B2C TL2 INTL', 
		   @step_id=1, 
		   @cmdexec_success_code=0, 
		   @on_success_action=1, 
		   @on_success_step_id=0, 
		   @on_fail_action=2, 
		   @on_fail_step_id=0, 
		   @retry_attempts=0, 
		   @retry_interval=1, 
		   @os_run_priority=0, @subsystem=N'TSQL', 
           @command = ' SET ANSI_DEFAULTS OFF
           EXEC BEJ_SWISSE_B2C_TL2_INTL_AUS '
		   @database_name=N'GLOWMS', 
		   @flags=0
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
   EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
   EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 1 Mins', 
		   @enabled=1, 
		   @freq_type=4, 
		   @freq_interval=1, 
		   @freq_subday_type=4, 
		   @freq_subday_interval=1, 
		   @freq_relative_interval=0, 
		   @freq_recurrence_factor=0, 
		   @active_start_date=@astart_date, 
		   @active_end_date=99991231, 
		   @active_start_time=205, 
		   @active_end_time=235959
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

