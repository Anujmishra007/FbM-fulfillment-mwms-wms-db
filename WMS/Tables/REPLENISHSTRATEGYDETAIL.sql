CREATE TABLE [dbo].[REPLENISHSTRATEGYDETAIL]
(
[ReplenishStrategykey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_ReplenishStrategykey] DEFAULT (''),
[ReplenishStrategyLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_ReplenishStrategyLineNumber] DEFAULT (''),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_Descr] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_UOM] DEFAULT (''),
[ReplenCode] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_ReplenCode] DEFAULT (''),
[StrategyType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_StrategyType] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Trigger: ntrReplenishStrategyDetailUpdate                            */
/* Creation Date:  09-Sept-2008                                         */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose: ReplenishStrategyDetail Update                              */
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
/* Called By: When records updated                                      */
/*                                                                      */
/* PVCS Version: 1.5                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrReplenishStrategyDetailUpdate]
ON [dbo].[REPLENISHSTRATEGYDETAIL]
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
	
	DECLARE	@n_err                int       -- Error number returned by stored procedure or this trigger
	,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
	,         @n_continue int                 
	,         @n_starttcnt int                -- Holds the current transaction count
	,         @n_cnt int                  
	
	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
   	SELECT @n_continue = 4 
   END
   
   -- TLTING01
	IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
	BEGIN
		UPDATE ReplenishStrategyDetail WITH (ROWLOCK)
		SET EditDate = GETDATE(),
		    EditWho  = SUSER_SNAME(),
		    TrafficCop = NULL	
		FROM ReplenishStrategyDetail , INSERTED WITH (NOLOCK)
		WHERE ReplenishStrategyDetail.ReplenishStrategyKey = INSERTED.ReplenishStrategyKey
		AND ReplenishStrategyDetail.ReplenishStrategyLineNumber = INSERTED.ReplenishStrategyLineNumber
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62303   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on ReplenishStrategyDetail table. (ntrReplenishStrategyDetailupdate)" 
			         + " ( " + " SQLSvr MESSAGE=" + LTrim(RTrim(@c_errmsg)) + " ) "
		END
	END

   IF UPDATE(TrafficCop)
   BEGIN
   	SELECT @n_continue = 4 
   END   
    
	
	IF @n_continue=3  -- Error Occured - Process And Return
	BEGIN
		IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
		BEGIN
			ROLLBACK TRAN
		END
		execute nsp_logerror @n_err, @c_errmsg, "ntrReplenishStrategyDetailUpdate"
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
ALTER TABLE [dbo].[REPLENISHSTRATEGYDETAIL] ADD CONSTRAINT [PK_REPLENISHSTRATEGYDETAIL] PRIMARY KEY CLUSTERED ([ReplenishStrategykey], [ReplenishStrategyLineNumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[REPLENISHSTRATEGYDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[REPLENISHSTRATEGYDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[REPLENISHSTRATEGYDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[REPLENISHSTRATEGYDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenishment Strategy Detail table', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archiving purpose. When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When Type = ''StoredProc'', Replenish Strategy custom SP is used', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'ReplenCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenish Strategy Key', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'ReplenishStrategykey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenish Strategy Line #', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'ReplenishStrategyLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When Type = ''Rule'', Replenish Strategy Type is used', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'StrategyType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenish UOM', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'UOM'
GO
