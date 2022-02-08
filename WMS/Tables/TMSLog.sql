CREATE TABLE [dbo].[TMSLog]
(
[TMSLogKey] [int] NOT NULL IDENTITY(1, 1),
[TableName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_Tablename] DEFAULT (' '),
[key1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_Key1] DEFAULT (' '),
[key2] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_Key2] DEFAULT (' '),
[key3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_Key3] DEFAULT (' '),
[TransmitFlag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_TransmitFlag] DEFAULT ('0'),
[TransmitBatch] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_TransmitBatch] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TMSLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TMSLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrTMSLogUpdate                                             */
/* Creation Date: 01-Nov-2006                                           */
/* Copyright: IDS                                                       */
/* Written by: YokeBeen                                                 */
/*                                                                      */
/* Purpose: Update EditWho & EditDate in TMSLog table.                  */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By:  Exceed                                                   */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications: Made a copy from ntrTransmitLogUpdate.           */
/*                                                                      */
/* Date         Author     Purposes                                     */
/* 28-Oct-2013  TLTING     Review Editdate column update                */
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrTMSLogUpdate]
ON  [dbo].[TMSLog]
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
   DECLARE   
     @b_Success            int       
   , @n_err                int       
   , @n_err2               int       
   , @c_errmsg             NVARCHAR(250) 
   , @n_continue           int
   , @n_starttcnt          int
   , @c_preprocess         NVARCHAR(250) 
   , @c_pstprocess         NVARCHAR(250) 
   , @n_cnt                int      

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
   	SELECT @n_continue = 4 
   END
 	
   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
	BEGIN 	
	 	UPDATE TMSLog 
    	   SET EditDate = GETDATE(),
     	       EditWho = SUSER_SNAME(),
     	       Trafficcop = NULL
        FROM TMSLog, INSERTED
       WHERE TMSLog.TMSLogKey = INSERTED.TMSLogKey

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	 	IF @n_err <> 0
	    	BEGIN
      	   SELECT @n_continue = 3
      	   SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=68000   
       	   SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table TMSLog. (ntrTMSLogUpdate)" + 
                             " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
	    	END
	END
END

GO
ALTER TABLE [dbo].[TMSLog] ADD CONSTRAINT [PKTMSLog] PRIMARY KEY NONCLUSTERED ([TMSLogKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TMSLOG_CIdx] ON [dbo].[TMSLog] ([TableName], [key1], [key2], [key3]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TMSLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TMSLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TMSLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TMSLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TMSLog', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TMSLog', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TMSLog', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying TMS Log.', 'SCHEMA', N'dbo', 'TABLE', N'TMSLog', 'COLUMN', N'TMSLogKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TMSLog', 'COLUMN', N'TrafficCop'
GO
