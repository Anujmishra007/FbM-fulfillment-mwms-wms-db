CREATE TABLE [dbo].[TRANSMITLOG2]
(
[transmitlogkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG2_tablename] DEFAULT (' '),
[key1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG2_key1] DEFAULT (' '),
[key2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG2_key2] DEFAULT (' '),
[key3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG2_key3] DEFAULT (' '),
[transmitflag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG2_transmitflag] DEFAULT ('0'),
[transmitbatch] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSMITLOG2_transmitbatch] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TRANSMITLOG2_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG2_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TRANSMITLOG2_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG2_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrTransmitlog2Add                                          */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/* Version: 5.5                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 04-Jul-2017  KHChan        Cater SKU table trigger (KH01)            */
/* 23-Mar-2021  KHChan        Remark Exec (KH02)                        */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrTransmitlog2Add]
ON  [dbo].[TRANSMITLOG2]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success               INT            -- Populated by calls to stored procedures - was the proc successful?
         , @n_Err                   INT            -- Error number returned by stored procedure or this trigger
         , @c_ErrMsg                NVARCHAR(250)  -- Error message returned by stored procedure or this trigger
         , @n_Continue              INT
         , @n_StarttCnt             INT            -- Holds the current transaction count
			, @b_debug						INT

--(KH02) - S
   --DECLARE @c_TransmitlogKey        NVARCHAR(10)         
   --      , @c_TableName             NVARCHAR(30)         
   --      , @c_Key1                  NVARCHAR(10)         
   --      , @c_Key2                  NVARCHAR(5)          
   --      , @c_Key3                  NVARCHAR(20)         
   --      , @c_TransmitBatch         NVARCHAR(30)                  
   --      , @c_QCommd_SPName         NVARCHAR(1024)       
   --      , @c_Exist                 CHAR(1)              
   --      , @c_ExecStatements        NVARCHAR(4000)       
   --      , @c_ExecArguments         NVARCHAR(4000)
   --      , @c_TempKey1              NVARCHAR(20) --(KH01)
   --      , @c_TempKey3              NVARCHAR(20) --(KH01)
--(KH02) - E

   SELECT @n_Continue=1, @n_StarttCnt=@@TRANCOUNT
	SELECT @b_debug = 0

   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   BEGIN
      SELECT @n_Continue = 4
   END

   /* #INCLUDE <TRLU1.SQL> */     
--(KH02) - S
   --IF @n_Continue = 1 or @n_Continue = 2
   --BEGIN

   --   DECLARE Cur_Transmitlog_Rec CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
   --   SELECT TransmitlogKey
   --        , TableName
   --        , Key1
   --        , Key2
   --        , Key3
   --        , TransmitBatch
   --   FROM   INSERTED 
   --   ORDER BY TransmitlogKey

   --   OPEN Cur_Transmitlog_Rec
   --   FETCH NEXT FROM Cur_Transmitlog_Rec INTO @c_TransmitlogKey, @c_TableName, @c_Key1, @c_Key2, @c_Key3, @c_TransmitBatch

   --   WHILE @@FETCH_STATUS <> -1
   --   BEGIN
   --      --(KH01) - Start
   --      IF @c_TableName <> 'WSSKUADDLOG'
   --      BEGIN
   --         SET @c_TempKey1 = @c_Key1
   --         SET @c_TempKey3 = @c_Key3
   --      END
   --      ELSE
   --      BEGIN
   --         SET @c_TempKey1 = @c_Key3
   --         SET @c_TempKey3 = @c_Key1
   --      END
   --      --(KH01) - End


   --      SET @c_Exist = '0'

   --      SELECT @c_QCommd_SPName    = QCommanderSP    
   --           , @c_Exist            = '1'      
   --      FROM   ITFTriggerConfig WITH (NOLOCK)
   --      WHERE  TargetTable         = 'TRANSMITLOG2' 
   --      AND    Tablename           = @c_TableName 
   --      --AND    StorerKey           = @c_Key3 --(KH01)
   --      AND    StorerKey           = @c_TempKey3 --(KH01)
			--AND   (QCommanderSP IS NOT NULL AND QCommanderSP <> '')

		 --  IF @c_Exist = '1' AND ISNULL(@c_QCommd_SPName, '') <> ''
		 --  BEGIN

   --         SET @c_ExecStatements = ''
   --         SET @c_ExecArguments = ''

   --         SET @c_ExecStatements = N'EXEC @c_QCommd_SPName '
   --                               + ' @c_Table				= ''TRANSMITLOG2'''
   --                               + ',@c_TransmitLogKey	= @c_TransmitLogKey'
   --                               + ',@c_TableName			= @c_TableName'
   --                               --+ ',@c_Key1				= @c_Key1' --(KH01)
   --                               + ',@c_Key1				= @c_TempKey1' --(KH01)
   --                               + ',@c_Key2				= @c_Key2'
   --                               --+ ',@c_Key3				= @c_Key3' --(KH01)
   --                               + ',@c_Key3				= @c_TempKey3' --(KH01)
   --                               + ',@c_TransmitBatch	= @c_TransmitBatch'  
			--								 + ',@b_Debug				= @b_debug'
   --                               + ',@b_Success			= @b_Success   OUTPUT'
   --                               + ',@n_Err					= @n_Err       OUTPUT'
   --                               + ',@c_ErrMsg				= @c_ErrMsg    OUTPUT'                            

   --         SET @c_ExecArguments = N'@c_QCommd_SPName    NVARCHAR(125)'
   --                              + ',@c_TransmitLogKey   NVARCHAR(10)'
   --                              + ',@c_TableName        NVARCHAR(30)'
   --                              --+ ',@c_Key1             NVARCHAR(10)'--(KH01)
   --                              + ',@c_TempKey1             NVARCHAR(20)'--(KH01)
   --                              + ',@c_Key2             NVARCHAR(5)'
   --                              --+ ',@c_Key3             NVARCHAR(20)'--(KH01)
   --                              + ',@c_TempKey3             NVARCHAR(20)'--(KH01)
   --                              + ',@c_TransmitBatch    NVARCHAR(30)' 
			--								+ ',@b_debug				INT'   
   --                              + ',@b_Success          INT             OUTPUT'                      
   --                              + ',@n_Err              INT             OUTPUT' 
   --                              + ',@c_ErrMsg           NVARCHAR(250)   OUTPUT' 
                        
   --         EXEC sp_ExecuteSql @c_ExecStatements 
   --                          , @c_ExecArguments 
   --                          , @c_QCommd_SPName
   --                          , @c_TransmitLogKey
   --                          , @c_TableName
   --                          --, @c_Key1 --(KH01)
   --                          , @c_TempKey1 --(KH01)
   --                          , @c_Key2
   --                          --, @c_Key3 --(KH01)
   --                          , @c_TempKey3 --(KH01)
   --                          , @c_TransmitBatch   
			--						  , @b_debug                           
   --                          , @b_Success         OUTPUT                       
   --                          , @n_Err             OUTPUT  
   --                          , @c_ErrMsg          OUTPUT
             
   --         IF @@ERROR <> 0 
   --         BEGIN
   --            SELECT @n_continue = 3
   --            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63811
   --            SELECT @c_errmsg= "NSQL" + CONVERT(char(5),@n_err) + ": Error Executing SP " + @c_QCommd_SPName + " Fail. (ispGenTRANSMITLOG2) ( SQLSvr MESSAGE=" + @c_errmsg + " ) "             	
   --         END
   --      END
         
   --      FETCH NEXT FROM Cur_Transmitlog_Rec INTO @c_TransmitlogKey, @c_TableName, @c_Key1, @c_Key2, @c_Key3, @c_TransmitBatch
   --   END -- WHILE @@FETCH_STATUS <> -1
   --   CLOSE Cur_Transmitlog_Rec
   --   DEALLOCATE Cur_Transmitlog_Rec
   --END
--(KH02) - E

   /* #INCLUDE <TRLU2.SQL> */

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_StarttCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StarttCnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'ntrTransmitlog2Add'
      RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_StarttCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Trigger: ntrTransmitlog2Update                                             */
/* Creation Date:                                                             */
/* Copyright: IDS                                                             */
/* Written by:                                                                */
/*                                                                            */
/* Purpose:   Transmitlog2 Update Trigger                                     */
/*                                                                            */
/* Usage:                                                                     */
/*                                                                            */
/* Called By: When records added into OrderHeader                             */
/*                                                                            */
/* PVCS Version: 1.4                                                          */
/*                                                                            */
/* Version: 5.4                                                               */
/*                                                                            */
/* Data Modifications:                                                        */
/* Date				Author   Ver	Purposes                                     */
/* 17-Mar-2009		TLTING	1.0   Change user_name() to SUSER_SNAME()				*/
/* 28-Oct-2013		TLTING	1.1   Review Editdate column update						*/
/* 30-Jun-2016		KTLow		1.2	Retrigger Queue Commander Process (KT01)		*/
/*											Add TrafficCop = NULL (KT01)						*/
/* 02-Oct-2018    TLTING   1.3   log and block bulk update                    */
/* 22-Sep-2020    TLTING   1.4   new service account                          */
/******************************************************************************/
CREATE TRIGGER [dbo].[ntrTransmitlog2Update]
ON  [dbo].[TRANSMITLOG2]
FOR UPDATE
AS
BEGIN 
 	IF @@ROWCOUNT = 0
	BEGIN
		RETURN
	END

  SET NOCOUNT ON
  SET ANSI_NULLS OFF
  SET QUOTED_IDENTIFIER OFF
  SET CONCAT_NULL_YIELDS_NULL OFF

  DECLARE @b_debug int
  SELECT @b_debug = 0
  DECLARE @b_Success						int       
			, @n_err							int       
			, @n_err2						int       
			, @c_errmsg						NVARCHAR(250) 
			, @n_continue					int
			, @n_starttcnt					int
			, @c_preprocess				NVARCHAR(250) 
			, @c_pstprocess				NVARCHAR(250) 
			, @n_cnt							int
			--(KT01) - Start
			, @c_TransmitlogKey			NVARCHAR(10)
         , @c_TableName					NVARCHAR(30)
         , @c_Key1						NVARCHAR(10)
         , @c_Key2						NVARCHAR(5) 
         , @c_Key3						NVARCHAR(20)
         , @c_TransmitBatch			NVARCHAR(30)
         , @c_DeletedTransmitFlag	NVARCHAR(5)        
         , @c_QCommd_SPName         NVARCHAR(1024)              
         , @c_Exist                 CHAR(1)      
         , @c_ExecStatements        NVARCHAR(4000)      
         , @c_ExecArguments         NVARCHAR(4000)                   
         --(KT01) - End

	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
	IF UPDATE(ArchiveCop)
	BEGIN
		SELECT @n_continue = 4 
	END

	--(KT01) - Start
	IF UPDATE(TrafficCop)
	BEGIN
		SELECT @n_continue = 4 
	END
	--(KT01) - End
	
	IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
	BEGIN 	
		UPDATE TRANSMITLOG2 
		SET EditDate = GETDATE()
			,EditWho = SUSER_SNAME()
			,Trafficcop = NULL
		FROM TRANSMITLOG2, INSERTED
		WHERE TRANSMITLOG2.TRANSMITLOGKey = INSERTED.TRANSMITLOGKey

		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
	 	IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72804   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table TRANSMITLOG2. (ntrTRANSMITLOG2Update)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
		END
	END
   
   IF ( (Select count(1) FROM  TRANSMITLOG2 (NOLOCK), INSERTED
       WHERE TRANSMITLOG2.TRANSMITLOGKey = INSERTED.TRANSMITLOGKey ) > 50 ) 
       AND Suser_sname() not in ('iml','dts','itadmin', 'QCmdUser', 'alpha\wmsadmingt','mctang', 'kwhchan', 'JovineNg', 'ALPHA\SRVwmsadminlfl', 'ALPHA\SRVwmsadmincn'    )
   BEGIN
         --Declare @c_Progname nvarchar(20)
         --Declare @c_Username nvarchar(20)

         --select @c_Progname= program_name , @c_Username = loginame from master.sys.sysprocesses where spid = @@SPID


         --INSERT INTO TRACEINFO ( TraceName , TimeIn, Col1 ,Col2 , Col3 , Col4 , Col5 )   
         --Select  'ntrTransmitlog2Update', GETDATE(), Suser_sname(), INSERTED.tablename,cast(count(5) as nvarchar),@c_Progname,''
         --FROM   TRANSMITLOG2, INSERTED
         --WHERE TRANSMITLOG2.TRANSMITLOGKey = INSERTED.TRANSMITLOGKey  
         --group by   INSERTED.tablename
      
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72814   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table TRANSMITLOG2. Batch Update not allow! (ntrTransmitlog2Update)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
          
   END

   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
    IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
    BEGIN
       ROLLBACK TRAN
    END
    ELSE
    BEGIN
       WHILE @@TRANCOUNT > @n_starttcnt
       BEGIN
       COMMIT TRAN
       END
    END
    EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrTransmitlog2Update'
    RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
    RETURN
   END
   ELSE
   BEGIN
    WHILE @@TRANCOUNT > @n_starttcnt
    BEGIN
       COMMIT TRAN
    END
    RETURN
   END
END
GO
ALTER TABLE [dbo].[TRANSMITLOG2] ADD CONSTRAINT [PKTRANSMITLOG2] PRIMARY KEY CLUSTERED ([transmitlogkey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TRANSMITLOG2_KEY1] ON [dbo].[TRANSMITLOG2] ([key1]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TRANSMITLOG2_KEY3] ON [dbo].[TRANSMITLOG2] ([key3], [transmitflag], [tablename], [key1]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TRANSMITLOG2_CIdx] ON [dbo].[TRANSMITLOG2] ([tablename], [key1], [key2], [key3]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[TRANSMITLOG2] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[TRANSMITLOG2] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TRANSMITLOG2] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TRANSMITLOG2] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TRANSMITLOG2] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG2', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG2', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG2', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG2', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG2', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Transmit Log.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG2', 'COLUMN', N'transmitlogkey'
GO
