CREATE TABLE [dbo].[AllocateStrategyDetail]
(
[AllocateStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_AllocateStrategyKey] DEFAULT (' '),
[AllocateStrategyLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_AllocateStrategyLineNumber] DEFAULT (' '),
[DESCR] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_DESCR] DEFAULT (' '),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_UOM] DEFAULT (' '),
[PickCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_PickCode] DEFAULT (' '),
[LocationTypeOverride] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_LocationTypeOverride] DEFAULT (' '),
[LocationTypeOverRideStripe] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_LocationTypeOverRideStripe] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Trigger: ntrAllocateStrategyDetailupdate                             */
/* Creation Date:  09-Sept-2008                                         */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose: AllocateStrategyDetail Update                               */
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

CREATE TRIGGER [dbo].[ntrAllocateStrategyDetailupdate]
ON [dbo].[AllocateStrategyDetail]
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
		UPDATE AllocateStrategyDetail with (ROWLOCK)
		SET EditDate = GETDATE(),
		    EditWho  = SUSER_SNAME(),
		    TrafficCop = NULL	
		FROM AllocateStrategyDetail , INSERTED (NOLOCK)
		WHERE AllocateStrategyDetail.AllocateStrategyKey = INSERTED.AllocateStrategyKey
		AND AllocateStrategyDetail.AllocateStrategyLineNumber = INSERTED.AllocateStrategyLineNumber
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62303   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on AllocateStrategyDetail table. (ntrAllocateStrategyDetailupdate)" 
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
		execute nsp_logerror @n_err, @c_errmsg, "ntrAllocateStrategyDetailupdate"
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
ALTER TABLE [dbo].[AllocateStrategyDetail] ADD CONSTRAINT [PKAllocateStrategyDetail] PRIMARY KEY CLUSTERED ([AllocateStrategyKey], [AllocateStrategyLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AllocateStrategyDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AllocateStrategyDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AllocateStrategyDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AllocateStrategyDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code of Allocate Strategy.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'AllocateStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates the order in which step should be processed during allocation process. System assigned; display only', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'AllocateStrategyLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter a description of the step', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'DESCR'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'If this field is filled in, then the system will only pull product from locations of this type that has been setup in the commodity screen.   The value are usually CASE - Case Pick Locations and PICK - Piece Pick Locations', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'LocationTypeOverride'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When AllowOverAllocation flag is switched on and multiple pick locations are assigned to a SKU, the Location Override Stripe (set to 1) allows user to distribute Overallocations across multiple pick locations', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'LocationTypeOverRideStripe'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick code to use when picking goods allocated by this step', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'PickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure of the commodity to be allocated by this step', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'UOM'
GO
