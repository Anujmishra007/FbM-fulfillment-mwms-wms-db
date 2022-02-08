CREATE TABLE [dbo].[StorerSODefault]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillTo] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Door] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Stop] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destination] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Terms] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryPlace] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_StorerSODefault_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StorerSODefault_AddWho] DEFAULT (suser_sname()),
[xDockLane] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSoDefault_XDockLane] DEFAULT (' '),
[XDockRoute] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XDockSTOP] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CutOffHour] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CutOffMin] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryTerm] [int] NULL CONSTRAINT [DF_StorerSODefault_DeliveryTerm] DEFAULT ((0)),
[Mon] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Mon] DEFAULT ((0)),
[Tue] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Tue] DEFAULT ((0)),
[Wed] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Wed] DEFAULT ((0)),
[Thu] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Thu] DEFAULT ((0)),
[Fri] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Fri] DEFAULT ((0)),
[Sat] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Sat] DEFAULT ((0)),
[Sun] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Sun] DEFAULT ((0)),
[HolidayKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScheduleKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_ScheduleKey] DEFAULT (' '),
[AddrOvrFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_AddrOvrFlag] DEFAULT (' '),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_StorerSODefault_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StorerSODefault_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Trigger: ntrStorerSODefaultUpdate                                    */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:  KHLIM                                                   */
/*                                                                      */
/* Purpose:  StorerSODefault Update                                     */
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

CREATE TRIGGER [dbo].[ntrStorerSODefaultUpdate]
ON  [dbo].[StorerSODefault] FOR UPDATE
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

	DECLARE @b_Success    int       -- Populated by calls to stored procedures - was the proc successful?
			, @n_err        int       -- Error number returned by stored procedure or this trigger
			, @n_err2       int       -- For Additional Error Detection
			, @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger
			, @n_continue   int                 
			, @n_starttcnt  int       -- Holds the current transaction count
			, @c_preprocess NVARCHAR(250) -- preprocess
			, @c_pstprocess NVARCHAR(250) -- post process
			, @n_cnt        int                  

	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

	   /* #INCLUDE <TRTHU1.SQL> */     


	IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
	BEGIN
		UPDATE StorerSODefault
		SET EditDate = GETDATE(),
		    EditWho = SUSER_SNAME()
		FROM StorerSODefault (NOLOCK), INSERTED (NOLOCK)
		WHERE StorerSODefault.StorerKey = INSERTED.StorerKey

		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table StorerSODefault. (ntrStorerSODefaultUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
		END
	END


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
		execute nsp_logerror @n_err, @c_errmsg, 'ntrStorerSODefaultUpdate'
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
ALTER TABLE [dbo].[StorerSODefault] ADD CONSTRAINT [PK_StorerSODefault] PRIMARY KEY CLUSTERED ([StorerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[StorerSODefault] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[StorerSODefault] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[StorerSODefault] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[StorerSODefault] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[StorerSODefault] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer Sales Order Default is built to accommodate the orders data default during the orders import', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'billto', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'BillTo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'door', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'Door'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying holiday.', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'HolidayKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order Type', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'OrderType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Shedule.', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'ScheduleKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer Key', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'xdockstop', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'XDockSTOP'
GO
