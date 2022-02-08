CREATE TABLE [dbo].[NSQLCONFIG]
(
[ConfigKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NSQLValue] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLCONFIG_NSQLValue] DEFAULT (' '),
[NSQLDefault] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLCONFIG_NSQLDEFAULT] DEFAULT (' '),
[NSQLDescrip] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_NSQLCONFIG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLCONFIG_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_NSQLCONFIG_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLCONFIG_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrNSQLConfigUpdate                                         */
/* Creation Date: 17-Aug-2005                                           */
/* Copyright: IDS                                                       */
/* Written by: YokeBeen                                                 */
/*                                                                      */
/* Purpose: Update EditWho & EditDate in NSQLConfig table.              */
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

CREATE TRIGGER [dbo].[ntrNSQLConfigUpdate]
ON  [dbo].[NSQLCONFIG]
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

   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
	BEGIN 	
	 	UPDATE NSQLConfig with (ROWLOCK)
    	   SET EditDate = GETDATE(),
     	       EditWho = SUSER_SNAME(),
     	       Trafficcop = NULL
        FROM NSQLConfig, INSERTED
       WHERE NSQLConfig.ConfigKey = INSERTED.ConfigKey

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	 	IF @n_err <> 0
	    	BEGIN
      	   SELECT @n_continue = 3
      	   SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72804   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       	   SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table NSQLConfig. (ntrNSQLConfigUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
	    	END
	END
END
GO
ALTER TABLE [dbo].[NSQLCONFIG] ADD CONSTRAINT [PKNSQLConfig] PRIMARY KEY CLUSTERED ([ConfigKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[NSQLCONFIG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[NSQLCONFIG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[NSQLCONFIG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[NSQLCONFIG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'NSQLCONFIG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'NSQLCONFIG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Configuration.', 'SCHEMA', N'dbo', 'TABLE', N'NSQLCONFIG', 'COLUMN', N'ConfigKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'NSQLCONFIG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'NSQLCONFIG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'NSQLCONFIG', 'COLUMN', N'TrafficCop'
GO
