USE [msdb]
GO

/****** Object:  Job [LIT - Flag Invalid Address Orders]    Script Date: 2/26/2025 3:08:29 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 2/26/2025 3:08:29 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'LIT - Flag Invalid Address Orders', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job to flag orders with invalid address based on Codelkup post code matrix.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'databoss', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ADIDAS - Flag invalid address orders]    Script Date: 2/26/2025 3:08:29 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ADIDAS - Flag invalid address orders', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON 
SET ANSI_NULLS OFF  
SET ANSI_DEFAULTS OFF 
DECLARE @cOrderKey NVARCHAR(10)
DECLARE CUR CURSOR FAST_FORWARD READ_ONLY FOR
SELECT DISTINCT OrderKey FROM Orders O (NOLOCK)
LEFT JOIN Codelkup CNTRY (NOLOCK) ON CNTRY.ListName = ''WSCNTRYMAP'' AND CNTRY.LONG = O.C_Country AND CNTRY.StorerKey = O.StorerKey
OUTER APPLY (
    SELECT ISNULL(CL.Code, '''') AS Code FROM Codelkup CL (NOLOCK) 
    WHERE ListName = ''PostMatrix''
    AND CL.Short = CASE WHEN ISNULL(CNTRY.Short, '''') <> '''' THEN CNTRY.Short ELSE O.C_Country END
    AND CL.Code = O.C_Zip 
    AND CL.Long = O.C_City 
    AND CL.UDF01 = O.C_State
    AND ISNULL(O.C_Zip,'''') <> ''''           --JSM-103156 Flag if C_Zip is blank
    AND ISNULL(O.C_State,'''') <> ''''        --JSM-103156 Flag if C_State is blank
    AND ISNULL(O.C_Address1,'''') <> ''''  --JSM-103156 Flag if C_Address is blank
) CL
WHERE O.StorerKey IN (''ADIDAS'', ''OODIE'', ''HMCOS'', ''SWISHED'', ''MOSAIC'')
AND ISNULL(UserDefine09, '''') = CASE WHEN O.StorerKey = ''MOSAIC'' AND O.Type = ''DTS'' THEN ISNULL(UserDefine09, '''') ELSE '''' END
AND Status < ''5''
AND ISNULL(SOStatus, '''') NOT IN (''ADDR_ERR'', ''CANC'',''AD_CANC'')
AND CL.Code IS NULL 
AND C_COUNTRY <> CASE WHEN ISNULL(O.C_Address1,'''') <> '''' AND ISNULL(O.C_Zip,'''') <> '''' AND ISNULL(O.C_State,'''') <> '''' --JSM-103156
THEN ''NZ'' ELSE ''FLAG'' END -- exclude New Zealand Orders --INC-No ticket # - Dushynth.-- exclude New Zealand Orders --INC-No ticket # - Dushynth.
AND 1 = CASE WHEN O.Storerkey in (''HMCOS'') AND O.Type LIKE ''Z%'' THEN 2 ELSE 1 END --(ZhengGang 20240220)
AND 1 = CASE WHEN O.Storerkey in (''OODIE'') AND O.C_Country = ''GB'' THEN 2 ELSE 1 END --(JSM-210952)
AND 1 = CASE WHEN O.StorerKey = ''MOSAIC'' AND O.Type <> ''DTS'' THEN 2 ELSE 1 END
OPEN CUR
FETCH NEXT FROM CUR INTO @cOrderKey
WHILE @@FETCH_STATUS <> -1
BEGIN
    UPDATE Orders WITH (ROWLOCK) SET SOStatus = ''ADDR_ERR'', TrafficCop = NULL, ArchiveCop = NULL 
    WHERE OrderKey = @cOrderKey
    --AND ADDDATE > getdate()-0.05 --AAY 2022-12-16
FETCH NEXT FROM CUR INTO @cOrderKey
END
CLOSE CUR
DEALLOCATE CUR', 
		@database_name=N'AUSWMS', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [LEVI - NZ STAMP CORRECT STATE]    Script Date: 2/26/2025 3:08:29 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LEVI - NZ STAMP CORRECT STATE', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @CORDERKEY AS NVARCHAR(10), @C_ZIP AS NVARCHAR(10) , @C_STATE AS NVARCHAR(10) 
DECLARE CUR1 CURSOR FAST_FORWARD READ_ONLY FOR
SELECT ORDERKEY,C_ZIP,C_STATE FROM AUSWMS..ORDERS (NOLOCK) WHERE StorerKey = ''LVS'' AND C_Country = ''NZ'' 
AND ISNULL(C_ZIP,'''') <> ''''
AND C_State = CASE WHEN ISNULL(C_ZIP,'''') <> '''' AND LEFT(C_ZIP,1) IN (''7'', ''8'', ''9'' ) THEN ''NI'' ELSE ''SI'' END 
AND TYPE = ''B2C'' AND SOSTATUS <> ''CANC''
OPEN CUR1
FETCH NEXT FROM CUR1 INTO  @CORDERKEY,  @C_ZIP, @C_STATE
WHILE @@FETCH_STATUS <> -1
BEGIN
   IF ISNULL(@C_ZIP,'''') <> ''''
   BEGIN
     UPDATE AUSWMS..ORDERS WITH (ROWLOCK) SET C_STATE = CASE WHEN ISNULL(@C_ZIP,'''') <> '''' AND LEFT(@C_ZIP,1) IN (''7'', ''8'', ''9'' ) THEN ''SI'' ELSE ''NI'' END  
	 ,TRAFFICCOP = NULL,ARCHIVECOP = NULL WHERE ORDERKEY = @CORDERKEY
  END
FETCH NEXT FROM CUR1 INTO  @CORDERKEY, @C_ZIP, @C_STATE
END
CLOSE CUR1
DEALLOCATE CUR1
', 
		@database_name=N'AUSWMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [LEVI - STAMP CORRECT C_COUNTRY]    Script Date: 2/26/2025 3:08:29 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LEVI - STAMP CORRECT C_COUNTRY', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @CORDERKEY AS NVARCHAR(10), @C_ZIP AS NVARCHAR(10) , @C_STATE AS NVARCHAR(10) 
DECLARE CUR1 CURSOR FAST_FORWARD READ_ONLY FOR
SELECT ORDERKEY,C_ZIP,C_STATE FROM AUSWMS..ORDERS (NOLOCK) WHERE 
StorerKey = ''LVS'' AND C_Country = ''AU'' 
AND ISNULL(C_ZIP,'''') <> ''''
AND C_State IN (''SI'', ''NI'')
AND TYPE = ''B2C'' AND SOSTATUS <> ''CANC''
OPEN CUR1
FETCH NEXT FROM CUR1 INTO  @CORDERKEY,  @C_ZIP, @C_STATE
WHILE @@FETCH_STATUS <> -1
BEGIN
   IF ISNULL(@C_ZIP,'''') <> ''''
   BEGIN
     UPDATE AUSWMS..ORDERS WITH (ROWLOCK) SET C_STATE = CASE WHEN ISNULL(@C_ZIP,'''') <> '''' AND LEFT(@C_ZIP,1) IN (''7'', ''8'', ''9'' ) THEN ''SI'' ELSE ''NI'' END  
	 ,C_COUNTRY = ''NZ'', C_ISOCNTRYCODE = ''NZ''
	 ,TRAFFICCOP = NULL,ARCHIVECOP = NULL WHERE ORDERKEY = @CORDERKEY
  END
FETCH NEXT FROM CUR1 INTO  @CORDERKEY, @C_ZIP, @C_STATE
END
CLOSE CUR1
DEALLOCATE CUR1
', 
		@database_name=N'AUSWMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [LEVIS - Stamp Country for No Order File]    Script Date: 2/26/2025 3:08:29 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LEVIS - Stamp Country for No Order File', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @CORDERKEY AS NVARCHAR(10), @C_ZIP AS NVARCHAR(10) , @C_STATE AS NVARCHAR(10) 
DECLARE CUR1 CURSOR FAST_FORWARD READ_ONLY FOR
SELECT ORDERKEY,C_ZIP,C_STATE FROM AUSWMS..ORDERS (NOLOCK) WHERE 
StorerKey = ''LVS'' AND C_Country = ''''
AND ISNULL(C_ZIP,'''') <> ''''
AND SOSTATUS <> ''CANC''
OPEN CUR1
FETCH NEXT FROM CUR1 INTO  @CORDERKEY,  @C_ZIP, @C_STATE
WHILE @@FETCH_STATUS <> -1
BEGIN
   IF ISNULL(@C_STATE,'''') <> ''''
   BEGIN
     UPDATE AUSWMS..ORDERS WITH (ROWLOCK) SET 
      C_COUNTRY = CASE WHEN ISNULL(@C_STATE,'''') IN (''SI'', ''NI'') THEN ''NZ'' ELSE ''AU'' END
       ,TRAFFICCOP = NULL,ARCHIVECOP = NULL WHERE ORDERKEY = @CORDERKEY
  END
FETCH NEXT FROM CUR1 INTO  @CORDERKEY, @C_ZIP, @C_STATE
END
CLOSE CUR1
DEALLOCATE CUR1
', 
		@database_name=N'AUSWMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [LEVIS - B2C TEMP STAMP CORRECT AU STATE]    Script Date: 2/26/2025 3:08:30 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LEVIS - B2C TEMP STAMP CORRECT AU STATE', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @CORDERKEY AS NVARCHAR(10), @cCorrectState AS NVARCHAR(10) , @C_STATE AS NVARCHAR(10) 
DECLARE CUR1 CURSOR FAST_FORWARD READ_ONLY FOR
SELECT ORDERKEY, CASE C_STATE 
WHEN ''NEW'' THEN ''NSW''
WHEN ''QUE'' THEN ''QLD''
WHEN ''WES'' THEN ''WA''
WHEN ''TAS'' THEN ''TAS''
WHEN ''VIC'' THEN ''VIC''
WHEN ''SOU'' THEN ''SA''
WHEN ''NOR'' THEN ''NT''
WHEN ''AUS'' THEN ''ACT'' ELSE C_STATE END, C_STATE 
FROM ORDERS (NOLOCK) WHERE STORERKEY = ''LVS'' AND C_STATE COLLATE SQL_Latin1_General_CP1_CS_AS NOT IN (''VIC'',''NSW'',''QLD'',''SA'',''TAS'',''NT'',''WA'',''ACT'')
AND C_COUNTRY = ''AU'' AND TYPE = ''B2C''
OPEN CUR1
FETCH NEXT FROM CUR1 INTO  @CORDERKEY,  @cCorrectState, @C_STATE
WHILE @@FETCH_STATUS <> -1
BEGIN
   UPDATE AUSWMS..ORDERS WITH (ROWLOCK) SET 
    C_STATE = @cCorrectState
     ,TRAFFICCOP = NULL,ARCHIVECOP = NULL WHERE ORDERKEY = @CORDERKEY
FETCH NEXT FROM CUR1 INTO @CORDERKEY,  @cCorrectState, @C_STATE
END
CLOSE CUR1
DEALLOCATE CUR1
', 
		@database_name=N'AUSWMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [LEVIS - B2C Flag invalid address orders]    Script Date: 2/26/2025 3:08:30 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LEVIS - B2C Flag invalid address orders', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON 
SET ANSI_NULLS OFF  
SET ANSI_DEFAULTS OFF 
DECLARE @cOrderKey NVARCHAR(10)
DECLARE CUR CURSOR FAST_FORWARD READ_ONLY FOR
SELECT DISTINCT OrderKey FROM Orders O (NOLOCK)
LEFT JOIN Codelkup CNTRY (NOLOCK) ON CNTRY.ListName = ''WSCNTRYMAP'' AND CNTRY.LONG = O.C_Country AND CNTRY.StorerKey = O.StorerKey
OUTER APPLY (
    SELECT ISNULL(CL.Code, '''') AS Code FROM Codelkup CL (NOLOCK) 
    WHERE ListName = ''PostMatrix''
    AND CL.Short = CASE WHEN ISNULL(CNTRY.Short, '''') <> '''' THEN CNTRY.Short ELSE O.C_Country END
    AND CL.Code = O.C_Zip 
    AND CL.Long = CASE WHEN O.C_COUNTRY = ''AU'' OR O.C_CITY = ''Auckland'' THEN O.C_City ELSE CL.Long END
    AND CL.UDF01 = O.C_State
    AND (O.C_CITY = CASE WHEN O.C_COUNTRY = ''NZ'' THEN CL.LONG ELSE O.C_CITY END
              OR O.C_CITY =  CASE WHEN O.C_COUNTRY = ''NZ'' THEN CL.UDF03 ELSE O.C_CITY END)
    AND ISNULL(O.C_Zip,'''') <> ''''           --JSM-103156 Flag if C_Zip is blank
    AND ISNULL(O.C_State,'''') <> ''''        --JSM-103156 Flag if C_State is blank
    AND ISNULL(O.C_Address1,'''') <> ''''  --JSM-103156 Flag if C_Address is blank
) CL
WHERE O.StorerKey IN (''LVS'')
AND ISNULL(UserDefine09, '''') = ''''
AND Status < ''5''
AND ISNULL(SOStatus, '''') NOT IN (''ADDR_ERR'', ''CANC'')
AND CL.Code IS NULL 
AND O.[TYPE] = ''B2C''
OPEN CUR
FETCH NEXT FROM CUR INTO @cOrderKey
WHILE @@FETCH_STATUS <> -1
BEGIN
    UPDATE Orders WITH (ROWLOCK) SET SOStatus = ''ADDR_ERR'', TrafficCop = NULL, ArchiveCop = NULL 
    WHERE OrderKey = @cOrderKey
    --AND ADDDATE > getdate()-0.05 --AAY 2022-12-16
FETCH NEXT FROM CUR INTO @cOrderKey
END
CLOSE CUR
DEALLOCATE CUR', 
		@database_name=N'AUSWMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Adidas - Flag NZ B2C Address Error]    Script Date: 2/26/2025 3:08:30 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Adidas - Flag NZ B2C Address Error', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON 
SET ANSI_NULLS OFF  
SET ANSI_DEFAULTS OFF 
DECLARE @cOrderKey NVARCHAR(10)
DECLARE CUR CURSOR FAST_FORWARD READ_ONLY FOR
SELECT DISTINCT O.ORDERKEY FROM Orders O (NOLOCK)
OUTER APPLY (
    SELECT ISNULL(CL.Code, '''') AS Code FROM Codelkup CL (NOLOCK) 
    WHERE ListName = ''PostMatrix''
    AND CL.Short = O.C_Country 
    AND CL.Code = O.C_Zip 
    AND CL.Long = O.C_CITY
    --AND (CL.Long = O.C_City OR (CL.LONG = O.C_ADDRESS2 AND CL.UDF01 = O.C_CITY) OR O.C_City = CL.Long + '' '' + CL.UDF01)
    AND CL.UDF01 = O.C_State
    AND ISNULL(O.C_Zip,'''') <> ''''           --JSM-103156 Flag if C_Zip is blank
    AND ISNULL(O.C_State,'''') <> ''''        --JSM-103156 Flag if C_State is blank
    AND ISNULL(O.C_Address1,'''') <> ''''  --JSM-103156 Flag if C_Address is blank
) CL
WHERE O.StorerKey IN (''ADIDAS'' )
AND O.Type = ''ZECO''
AND C_Country = ''NZ''
AND ISNULL(UserDefine09, '''') = ''''
AND Status < ''5''
AND ISNULL(SOStatus, '''') NOT IN (''ADDR_ERR'', ''CANC'',''AD_CANC'')
AND CL.Code IS NULL 
AND C_Country = ''NZ'' 
AND C_CITY = CASE WHEN O.ADDDATE > ''2024-07-17 15:00'' THEN C_CITY ELSE CASE WHEN C_City Like ''%,%'' THEN C_City Else ''Auckland'' END END
OPEN CUR
FETCH NEXT FROM CUR INTO @cOrderKey
WHILE @@FETCH_STATUS <> -1
BEGIN
   UPDATE Orders WITH (ROWLOCK) SET SOStatus = ''ADDR_ERR'', TrafficCop = NULL, ArchiveCop = NULL 
    WHERE OrderKey = @cOrderKey
    --AND ADDDATE > getdate()-0.05 --AAY 2022-12-16
FETCH NEXT FROM CUR INTO @cOrderKey
END
CLOSE CUR
DEALLOCATE CUR', 
		@database_name=N'AUSWMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Mosaic - Flag invalid address orders]    Script Date: 2/26/2025 3:08:30 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Mosaic - Flag invalid address orders', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*
SET NOCOUNT ON 
SET ANSI_NULLS OFF  
SET ANSI_DEFAULTS OFF 
DECLARE @cOrderKey NVARCHAR(10)
DECLARE CUR CURSOR FAST_FORWARD READ_ONLY FOR
SELECT ORDERKEY FROM Orders O (NOLOCK)
OUTER APPLY (
    SELECT ISNULL(CL.Code, '''') AS Code FROM Codelkup CL (NOLOCK) 
    WHERE ListName = ''PostMatrix''
    AND CL.Short = CASE WHEN O.C_Country = ''Australia'' THEN ''AU'' ELSE O.C_Country END
    AND CL.Code = O.C_Zip 
    AND CL.Long = O.C_City 
    AND CL.UDF01 = O.C_State
) CL
WHERE O.StorerKey = ''MOSAIC''
AND ISNULL(UserDefine09, '''') = ''''
AND Status < ''5''
AND ISNULL(SOStatus, '''') <> ''ADDR_ERR''
AND O.C_COUNTRY IN (''Australia'', ''AU'')
AND CL.Code IS NULL 
OPEN CUR
FETCH NEXT FROM CUR INTO @cOrderKey
WHILE @@FETCH_STATUS <> -1
BEGIN
    UPDATE Orders WITH (ROWLOCK) SET SOStatus = ''ADDR_ERR'', TrafficCop = NULL, ArchiveCop = NULL 
    WHERE OrderKey = @cOrderKey
FETCH NEXT FROM CUR INTO @cOrderKey
END
CLOSE CUR
DEALLOCATE CUR
*/', 
		@database_name=N'AUSWMS', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ADIDAS - Flag for Fixed Address]    Script Date: 2/26/2025 3:08:30 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ADIDAS - Flag for Fixed Address', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--JSM-113335 Flag for fixed address
SET NOCOUNT ON 
SET ANSI_NULLS OFF  
SET ANSI_DEFAULTS OFF 
DECLARE @cOrderKey NVARCHAR(10), @cORDZIP NVARCHAR(10), @cShipperKey NVARCHAR(10)
DECLARE CUR CURSOR FAST_FORWARD READ_ONLY FOR
SELECT DISTINCT OrderKey FROM Orders O (NOLOCK)
LEFT JOIN Codelkup CNTRY (NOLOCK) ON CNTRY.ListName = ''WSCNTRYMAP'' AND CNTRY.LONG = O.C_Country AND CNTRY.StorerKey = O.StorerKey
CROSS APPLY (
    SELECT ISNULL(CL.Code, '''') AS Code FROM Codelkup CL (NOLOCK) 
    WHERE ListName = ''PostMatrix''
    AND CL.Short = CASE WHEN ISNULL(CNTRY.Short, '''') <> '''' THEN CNTRY.Short ELSE O.C_Country END
    AND CL.Code = O.C_Zip 
    AND CL.Long = CASE WHEN O.C_COUNTRY = ''AU'' OR O.C_CITY = ''Auckland'' OR O.STORERKEY <> ''LVS''
                               OR (O.Storerkey = ''Adidas'' and O.C_Country = ''NZ'') THEN O.C_City ELSE CL.Long END
   AND ( CL.UDF01 = O.C_State)
    AND (O.C_CITY = CASE WHEN O.C_COUNTRY = ''NZ'' AND O.STORERKEY = ''LVS'' THEN CL.LONG ELSE O.C_CITY END
              OR O.C_CITY =  CASE WHEN O.C_COUNTRY = ''NZ'' AND O.STORERKEY = ''LVS''  THEN CL.UDF03 ELSE O.C_CITY END)
    AND ISNULL(O.C_Zip,'''') <> ''''           --JSM-103156 Flag if C_Zip is blank
    AND ISNULL(O.C_State,'''') <> ''''        --JSM-103156 Flag if C_State is blank
    AND ISNULL(O.C_Address1,'''') <> ''''  --JSM-103156 Flag if C_Address is blank
) CL
WHERE O.StorerKey IN (''ADIDAS'', ''OODIE'', ''HMCOS'',''LVS'', ''SWISHED'')
AND ISNULL(UserDefine09, '''') = ''''
AND Status < ''5''
AND ISNULL(SOStatus, '''') = ''ADDR_ERR''
--AND CL.Code IS NULL 
--AND C_COUNTRY <> CASE WHEN ISNULL(O.C_Address1,'''') <> '''' AND ISNULL(O.C_Zip,'''') <> '''' AND ISNULL(O.C_State,'''') <> '''' --JSM-103156
--THEN ''NZ'' ELSE ''FLAG'' END -- exclude New Zealand Orders --INC-No ticket # - Dushynth.-- exclude New Zealand Orders --INC-No ticket # - Dushynth.
OPEN CUR
FETCH NEXT FROM CUR INTO @cOrderKey
WHILE @@FETCH_STATUS <> -1
BEGIN
--stamp shipperkey
  IF EXISTS (Select top 1 1 from Orders (nolock) where storerkey = ''Adidas'' and
                     orderkey = @cOrderKey)
  BEGIN
     SET @cShipperKey = ''''
     SET @cORDZIP = ''''
     SELECT @cORDZIP = C_ZIP from Orders (nolock) where
      Storerkey = ''Adidas'' and OrderKey = @cOrderKey
     SELECT @cShipperKey = SHORT from Codelkup (nolock) where
     Listname = ''CARRIERAL'' and Storerkey = ''Adidas'' and code2 = ''AU'' and CODE = @cORDZIP 
  END
--SKIP Fix for Adidas if no mandatory english characters
   IF NOT EXISTS (SELECT TOP 1 1 FROM Orders (nolock) where Storerkey = ''ADIDAS'' and 
                               PATINDEX(''%[A-Za-z]%'', c_company) = 0 AND Orderkey = @cOrderKey )
   BEGIN
       UPDATE Orders WITH (ROWLOCK) SET 
       SOStatus = CASE WHEN ISNULL(@cShipperKey,'''') = '''' AND STORERKEY = ''ADIDAS'' and C_Country = ''AU'' THEN SOStatus ELSE ''0'' END, 
       Shipperkey = CASE WHEN Storerkey = ''Adidas''  and C_Country = ''AU'' and Type = ''ZECO'' and ISNULL(@cShipperKey,'''') <> ShipperKey then ISNULL(@cShipperKey,'''') else Shipperkey END,
       USERDEFINE07 = CASE WHEN STORERKEY = ''ADIDAS'' THEN GETDATE() ELSE USERDEFINE07 END,
       TrafficCop = NULL, ArchiveCop = NULL 
       WHERE OrderKey = @cOrderKey
   END
FETCH NEXT FROM CUR INTO @cOrderKey
END
CLOSE CUR
DEALLOCATE CUR
', 
		@database_name=N'AUSWMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ADIDAS - Flag Missing English Characters and Name >40]    Script Date: 2/26/2025 3:08:30 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ADIDAS - Flag Missing English Characters and Name >40', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON 
SET ANSI_NULLS OFF  
SET ANSI_DEFAULTS OFF 
DECLARE @cOrderKey NVARCHAR(10)
DECLARE CUR CURSOR FAST_FORWARD READ_ONLY FOR
SELECT ORDERKEY
FROM ORDERS (NOLOCK) WHERE 
STORERKEY = ''ADIDAS''
AND (PATINDEX(''%[A-Za-z]%'', c_company) = 0
OR (C_COUNTRY = ''NZ'' 
       AND PATINDEX(''%[^A-Za-z0-9\s,.;!?''''"-\ūā-]%'', 
        replace(LTRIM(RTRIM(C_CITY)),'' '', '''')   ) > 0)
OR LEN(C_COMPANY) > 40 --name more than 40
        )
AND status < ''5''
AND ISNULL(USERDEFINE09,'''') = ''''
AND TYPE = ''ZECO''
AND SOSTATUS NOT IN (''AD_CANC'',''CANC'')
OPEN CUR
FETCH NEXT FROM CUR INTO @cOrderKey
WHILE @@FETCH_STATUS <> -1
BEGIN
    UPDATE Orders WITH (ROWLOCK) SET SOStatus = ''ADDR_ERR'', TrafficCop = NULL, ArchiveCop = NULL 
    WHERE OrderKey = @cOrderKey
    --AND ADDDATE > getdate()-0.05 --AAY 2022-12-16
FETCH NEXT FROM CUR INTO @cOrderKey
END
CLOSE CUR
DEALLOCATE CUR', 
		@database_name=N'AUSWMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Mosaic DTS - Flag for fixed address]    Script Date: 2/26/2025 3:08:30 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Mosaic DTS - Flag for fixed address', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON 
SET ANSI_NULLS OFF  
SET ANSI_DEFAULTS OFF 
DECLARE @cOrderKey NVARCHAR(10), @c_ConZip NVARCHAR(10), @cShipperKey NVARCHAR(10), @c_ConState NVARCHAR(30), @c_ConCity NVARCHAR(30)
DECLARE CUR CURSOR FAST_FORWARD READ_ONLY FOR
SELECT DISTINCT OrderKey FROM Orders O (NOLOCK)
JOIN Storer S (NOLOCK) ON S.StorerKey = O.ConsigneeKey AND S.Type = ''2''
LEFT JOIN Codelkup CNTRY (NOLOCK) ON CNTRY.ListName = ''WSCNTRYMAP'' AND CNTRY.LONG = O.C_Country AND CNTRY.StorerKey = O.StorerKey
CROSS APPLY (
    SELECT ISNULL(CL.Code, '''') AS Code FROM Codelkup CL (NOLOCK) 
    WHERE ListName = ''PostMatrix''
    AND CL.Short = CASE WHEN ISNULL(CNTRY.Short, '''') <> '''' THEN CNTRY.Short ELSE O.C_Country END
    AND CL.Code = S.Zip 
    AND CL.Long = CASE WHEN O.C_COUNTRY = ''AU'' OR O.C_CITY = ''Auckland'' OR O.STORERKEY <> ''LVS''
                               OR (O.Storerkey = ''Adidas'' and O.C_Country = ''NZ'') THEN S.City ELSE CL.Long END
   AND ( CL.UDF01 = S.State)
    AND (S.CITY = CASE WHEN O.C_COUNTRY = ''NZ'' AND O.STORERKEY = ''LVS'' THEN CL.LONG ELSE O.C_CITY END
              OR O.C_CITY =  CASE WHEN O.C_COUNTRY = ''NZ'' AND O.STORERKEY = ''LVS''  THEN CL.UDF03 ELSE S.CITY END)
    AND ISNULL(O.C_Zip,'''') <> ''''           --JSM-103156 Flag if C_Zip is blank
    AND ISNULL(O.C_State,'''') <> ''''        --JSM-103156 Flag if C_State is blank
    AND ISNULL(O.C_Address1,'''') <> ''''  --JSM-103156 Flag if C_Address is blank
) CL
WHERE O.StorerKey IN (''MOSAIC'')
AND ISNULL(UserDefine09, '''') <> ''''
AND O.Status < ''5''
AND ISNULL(SOStatus, '''') = ''ADDR_ERR''
AND O.Type = ''DTS''
OPEN CUR
FETCH NEXT FROM CUR INTO @cOrderKey
WHILE @@FETCH_STATUS <> -1
BEGIN
    SELECT @c_ConZip = Zip, @c_ConState = State, @c_ConCity = City FROM Orders O (NOLOCK) 
    JOIN Storer S (NOLOCK) ON S.StorerKey = O.ConsigneeKey
    WHERE O.Storerkey = ''MOSAIC'' 
    AND OrderKey = @cOrderKey
--SKIP Fix for Adidas if no mandatory english characters
   IF NOT EXISTS (SELECT TOP 1 1 FROM Orders (nolock) where Storerkey = ''ADIDAS'' and 
                               PATINDEX(''%[A-Za-z]%'', c_company) = 0 AND Orderkey = @cOrderKey )
   BEGIN
       UPDATE Orders WITH (ROWLOCK) SET 
       SOStatus = CASE WHEN ISNULL(@cShipperKey,'''') = '''' AND STORERKEY = ''ADIDAS'' and C_Country = ''AU'' THEN SOStatus ELSE ''0'' END, 
       Shipperkey = CASE WHEN Storerkey = ''Adidas''  and C_Country = ''AU'' and Type = ''ZECO'' and ISNULL(@cShipperKey,'''') <> ShipperKey then ISNULL(@cShipperKey,'''') else Shipperkey END,
       USERDEFINE07 = CASE WHEN STORERKEY = ''ADIDAS'' THEN GETDATE() ELSE USERDEFINE07 END,
       C_State = @c_ConState,
       C_City = @c_ConCity,
       C_Zip = @c_ConZip,
       TrafficCop = NULL, ArchiveCop = NULL 
       WHERE OrderKey = @cOrderKey
   END
FETCH NEXT FROM CUR INTO @cOrderKey
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


