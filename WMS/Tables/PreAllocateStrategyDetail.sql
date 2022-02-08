CREATE TABLE [dbo].[PreAllocateStrategyDetail]
(
[PreAllocateStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_PreAllocateStrategyKey] DEFAULT (' '),
[PreAllocateStrategyLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_PreAllocateStrategyLineNumber] DEFAULT (' '),
[DESCR] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_DESCR] DEFAULT (' '),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_UOM] DEFAULT (' '),
[PreAllocatePickCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_PreAllocatePickCode] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrPreAllocateStrategyDetailUpdate                          */
/* Creation Date:  09-Sept-2008                                         */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose: PreAllocateStrategyDetail Update                            */
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
CREATE TRIGGER [dbo].[ntrPreAllocateStrategyDetailUpdate]
ON [dbo].[PreAllocateStrategyDetail]
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
		UPDATE PreAllocateStrategyDetail WITH (ROWLOCK)
		SET EditDate = GETDATE(),
		    EditWho  = SUSER_SNAME(),
		    TrafficCop = NULL	
		FROM PreAllocateStrategyDetail , INSERTED WITH (NOLOCK)
		WHERE PreAllocateStrategyDetail.PreAllocateStrategyKey = INSERTED.PreAllocateStrategyKey
		AND PreAllocateStrategyDetail.PreAllocateStrategyLineNumber = INSERTED.PreAllocateStrategyLineNumber
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62303   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on PreAllocateStrategyDetail table. (ntrPreAllocateStrategyDetailupdate)" 
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
		execute nsp_logerror @n_err, @c_errmsg, "ntrPreAllocateStrategyDetailUpdate"
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
ALTER TABLE [dbo].[PreAllocateStrategyDetail] ADD CONSTRAINT [PKPreAllocateStrategyDetail] PRIMARY KEY CLUSTERED ([PreAllocateStrategyKey], [PreAllocateStrategyLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PreAllocateStrategyDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PreAllocateStrategyDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PreAllocateStrategyDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PreAllocateStrategyDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter a description of the step', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'DESCR'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter a pick code to use when picking this UOM', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'PreAllocatePickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pre-allocate strategy.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'PreAllocateStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates order in which step should be processed during allocation process. System assigned, overwrite this number by typing over it', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'PreAllocateStrategyLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Select the first unit of measure that the system checks for pre-allocation', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'UOM'
GO
