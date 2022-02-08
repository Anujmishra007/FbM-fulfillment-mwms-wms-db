CREATE TABLE [dbo].[TTMStrategyDetail]
(
[TTMStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_TTMStrategyKey] DEFAULT (' '),
[TTMStrategyLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_TTMStrategyLineNumber] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_Descr] DEFAULT (' '),
[TaskType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_TaskType] DEFAULT (' '),
[TTMPickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_TTMPickCode] DEFAULT (' '),
[TTMOverride] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_TTMOverride] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TTMStrategyDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TTMStrategyDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Trigger: ntrTTMStrategyDetailUpdate                                  */
/* Creation Date:  09-Sept-2008                                         */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose: TTMStrategyDetail Update                                    */
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

CREATE TRIGGER [dbo].[ntrTTMStrategyDetailUpdate]
ON [dbo].[TTMStrategyDetail]
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
		UPDATE TTMStrategyDetail WITH (ROWLOCK)
		SET EditDate = GETDATE(),
		    EditWho  = SUSER_SNAME(),
		    TrafficCop = NULL	
		FROM TTMStrategyDetail , INSERTED WITH (NOLOCK)
		WHERE TTMStrategyDetail.TTMStrategyKey = INSERTED.TTMStrategyKey
		AND TTMStrategyDetail.TTMStrategyLineNumber = INSERTED.TTMStrategyLineNumber
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62303   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on TTMStrategyDetail table. (ntrTTMStrategyDetailupdate)" 
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
		execute nsp_logerror @n_err, @c_errmsg, "ntrTTMStrategyDetailUpdate"
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
ALTER TABLE [dbo].[TTMStrategyDetail] ADD CONSTRAINT [PKTTMStrategyDetail] PRIMARY KEY NONCLUSTERED ([TTMStrategyKey], [TTMStrategyLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TTMStrategyDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TTMStrategyDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TTMStrategyDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TTMStrategyDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter a description of the step', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of task to be dispatched in this step. The same task type can be used on more than one row; for example, you may dispatch Pick, then PutAway, then Pick, then PutAway, etc. Options include: CC = Cycle Counts, etc', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'TaskType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the stored procedure that creates the set of candidate tasks based on this task type', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'TTMPickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Task Detail Strategy.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'TTMStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates order in which step should be processed during task dispatch process. System-assigned, overwrite this number by typing over it.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'TTMStrategyLineNumber'
GO
