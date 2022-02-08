CREATE TABLE [dbo].[Strategy]
(
[StrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_StrategyKey] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STRATEGY_Descr] DEFAULT (' '),
[PreAllocateStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_PreAllocateStrategyKey] DEFAULT (' '),
[AllocateStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_AllocateStrategyKey] DEFAULT (' '),
[ReplenishmentStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_ReplenishmentStrategyKey] DEFAULT (' '),
[PutawayStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_PutawayStrategyKey] DEFAULT (' '),
[PickStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_PickStrategyKey] DEFAULT (' '),
[TTMStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_TTMStrategyKey] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_STRATEGY_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STRATEGY_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_STRATEGY_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STRATEGY_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VASStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_VASStrategyKey] DEFAULT (' '),
[ABCPAStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransferStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_TransferStrategyKey] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Trigger: ntrStrategyUpdate                                           */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  Strategy Update Transaction                                */
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
/* 25 May 2012  TLTING01  DM integrity - add update editdate B4         */
/*                        TrafficCop                                    */ 
/* 28-Oct-2013  TLTING     Review Editdate column update                */ 
/************************************************************************/

CREATE TRIGGER [dbo].[ntrStrategyUpdate]
ON  [dbo].[Strategy] FOR UPDATE
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

	IF UPDATE(ArchiveCop)
	BEGIN
		SELECT @n_continue = 4 
	END
	
   --tlting01
	IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
	BEGIN
		UPDATE Strategy
		SET EditDate = GETDATE(),
		    EditWho  = SUSER_SNAME(),
		    TrafficCop = NULL
		FROM Strategy (NOLOCK), INSERTED (NOLOCK)
      WHERE Strategy.StrategyKey = INSERTED.StrategyKey
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table Strategy. (ntrStrategyUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
		END
	END
	
	IF UPDATE(TrafficCop)
	BEGIN
		SELECT @n_continue = 4 
	END
	
	   /* #INCLUDE <TRTHU1.SQL> */     


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
		execute nsp_logerror @n_err, @c_errmsg, 'ntrStrategyUpdate'
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
ALTER TABLE [dbo].[Strategy] ADD CONSTRAINT [PKStrategy] PRIMARY KEY CLUSTERED ([StrategyKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[Strategy] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[Strategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Strategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Strategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Strategy] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'WMS Exceed requires the configuration of a set of strategies for the system to work. These strategies include pre-allocation, allocation, putaway and crossdock', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique code identifying the allocation sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'AllocateStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the master strategy in detail', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick Strategy.', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'PickStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique code identifying the pre-allocation sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'PreAllocateStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique code identifying the putaway sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'PutawayStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Replenishment Strategy.', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'ReplenishmentStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Master strategy key that you will call upon and attach to the SKU master', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'StrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transfer Strategy', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'TransferStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique code identifying the task manager sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'TTMStrategyKey'
GO
