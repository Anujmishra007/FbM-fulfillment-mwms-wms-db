CREATE TABLE [dbo].[AllocateStrategy]
(
[AllocateStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategy_AllocateStrategyKey] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategy_Descr] DEFAULT (' '),
[RetryIfQtyRemain] [int] NOT NULL CONSTRAINT [DF_AllocateStrategy_RetryIfQtyRemain] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_AllocateStrategy_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategy_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_AllocateStrategy_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategy_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



/************************************************************************/
/* Trigger: ntrAllocateStrategyupdate                                   */
/* Creation Date:  09-Sept-2008                                         */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose: AllocateStrategy Update                                     */
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

CREATE TRIGGER [dbo].[ntrAllocateStrategyupdate]
ON [dbo].[AllocateStrategy]
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
		UPDATE AllocateStrategy with (ROWLOCK)
		SET EditDate = GETDATE(),
		    EditWho  = SUSER_SNAME(),
		    TrafficCop = NULL	
		FROM AllocateStrategy , INSERTED (NOLOCK)
		WHERE AllocateStrategy.AllocateStrategyKey = INSERTED.AllocateStrategyKey
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62303   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on AllocateStrategy table. (ntrAllocateStrategyupdate)" + " ( " + " SQLSvr MESSAGE=" + LTrim(RTrim(@c_errmsg)) + " ) "
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
		execute nsp_logerror @n_err, @c_errmsg, "ntrAllocateStrategyupdate"
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
ALTER TABLE [dbo].[AllocateStrategy] ADD CONSTRAINT [PKAllocateStrategy] PRIMARY KEY CLUSTERED ([AllocateStrategyKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AllocateStrategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AllocateStrategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AllocateStrategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AllocateStrategy] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'After product has been pre-allocated, the candidate lots are taken by order allocation and reserved by location, lot and (if necessary) ID.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a unique code identifying the allocation sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'AllocateStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a description of the allocation sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type 0 (for no) or 1 (for yes) to indicate if you want the system to break up larger units that have not been filled', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'RetryIfQtyRemain'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'TrafficCop'
GO
