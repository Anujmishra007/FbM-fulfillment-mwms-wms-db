CREATE TABLE [dbo].[NSCLOG]
(
[nsclogkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_Tablename] DEFAULT (' '),
[key1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_Key1] DEFAULT (' '),
[key2] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_Key2] DEFAULT (' '),
[key3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_Key3] DEFAULT (' '),
[transmitflag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_transmitflag] DEFAULT ('0'),
[transmitbatch] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NSCLOG_transmitbatch] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_NSCLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_NSCLOG_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrNSCLogUpdate                                             */
/* Creation Date: 17-Aug-2005                                           */
/* Copyright: IDS                                                       */
/* Written by: YokeBeen                                                 */
/*                                                                      */
/* Purpose: Update EditWho & EditDate in NSCLog table.                  */
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

CREATE TRIGGER [dbo].[ntrNSCLogUpdate]
ON  [dbo].[NSCLOG]
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
	 	UPDATE NSCLog with (ROWLOCK)
    	   SET EditDate = GETDATE(),
     	       EditWho = SUSER_SNAME(),
     	       Trafficcop = NULL
        FROM NSCLog, INSERTED
       WHERE NSCLog.NSCLogKey = INSERTED.NSCLogKey

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	 	IF @n_err <> 0
	    	BEGIN
      	   SELECT @n_continue = 3
      	   SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72804   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       	   SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table NSCLog. (ntrNSCLogUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
	    	END
	END
END
GO
ALTER TABLE [dbo].[NSCLOG] ADD CONSTRAINT [PKNSCLOG] PRIMARY KEY CLUSTERED ([nsclogkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NSCLOG_CIdx] ON [dbo].[NSCLOG] ([tablename], [key1], [key2], [key3]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[NSCLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[NSCLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[NSCLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[NSCLOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'NSCLOG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'NSCLOG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'NSCLOG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'NSCLOG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying NSC Log.', 'SCHEMA', N'dbo', 'TABLE', N'NSCLOG', 'COLUMN', N'nsclogkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'NSCLOG', 'COLUMN', N'TrafficCop'
GO
