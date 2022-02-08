CREATE TABLE [dbo].[VASDetail]
(
[VASKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VASLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RefDescr] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Step] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VASDetail_Step] DEFAULT (' '),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_VASDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VASDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_VASDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VASDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Trigger: ntrVASDetailUpdate                                          */
/* Creation Date: 10-Oct-2011                                           */
/* Copyright: IDS                                                       */
/* Written by: YTWan                                                    */
/*                                                                      */
/* Purpose:  VAS Detail Update Transaction                              */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When update records                                       */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Purposes                                      */
/* 28-Oct-2013  TLTING     Review Editdate column update                */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrVASDetailUpdate]
ON  [dbo].[VASDetail] FOR UPDATE
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

	DECLARE @n_continue   int                 
			, @n_starttcnt  int       -- Holds the current transaction count@b_Success
			, @n_err        int       -- Error number returned by stored procedure or this trigger
			, @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger


	SET @n_continue = 1
   SET @n_starttcnt= @@TRANCOUNT

	IF UPDATE(ArchiveCop)
	BEGIN
		SET @n_continue = 4 
	END

	/* #INCLUDE <TRTHU1.SQL> */     

	IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
	BEGIN
		UPDATE VASDetail
		SET EditDate = GETDATE() 
		   ,EditWho = SUSER_SNAME()
		FROM VASDetail WITH (NOLOCK)
      JOIN INSERTED WITH (NOLOCK) ON (INSERTED.VasKey = VASDetail.VasKey)
                                  AND(INSERTED.VASLineNumber = VASDetail.VASLineNumber)
      JOIN DELETED WITH (NOLOCK)  ON (DELETED.VasKey = VASDetail.VasKey)
                                  AND(DELETED.VASLineNumber = VASDetail.VASLineNumber)

		SET @n_err = @@ERROR 

		IF @n_err <> 0
		BEGIN
			SET @n_continue = 3
			SET @c_errmsg = CONVERT(CHAR(250),@n_err)
         SET @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SET @c_errmsg ='NSQL'+CONVERT(char(5),@n_err)
                       +': Update Failed On Table VASDetail. (ntrVASDetailUpdate)' 
                       + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
		END
	END
	IF UPDATE(TrafficCop)
	BEGIN
		SET @n_continue = 4 
	END
	-- Begin

      /* #INCLUDE <TRTHU2.SQL> */
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
		execute nsp_logerror @n_err, @c_errmsg, 'ntrVASDetailUpdate'
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
ALTER TABLE [dbo].[VASDetail] ADD CONSTRAINT [PK_VASDetail] PRIMARY KEY CLUSTERED ([VASKey], [VASLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[VASDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[VASDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[VASDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[VASDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'VASDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'VASDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'VASDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'VASDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'VASDetail', 'COLUMN', N'TrafficCop'
GO
