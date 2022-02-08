CREATE TABLE [dbo].[PutawayStrategy]
(
[PutawayStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategy_Descr] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PutawayStrategy_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategy_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PutawayStrategy_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategy_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrPutawayStrategyUpdate                                    */
/* Creation Date:  18-March-2020                                        */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose: PutawayStrategy Update                                      */
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

CREATE TRIGGER [dbo].[ntrPutawayStrategyUpdate]
ON [dbo].[PutawayStrategy] FOR UPDATE
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
	
	DECLARE	 @n_err              INT           -- Error number returned by stored procedure or this trigger
	,         @c_errmsg           NVARCHAR(250) -- Error message returned by stored procedure or this trigger
	,         @n_continue         INT                 
	,         @n_starttcnt        INT           -- Holds the current transaction count
	,         @n_cnt              INT                  
	
	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
   	SELECT @n_continue = 4 
   END
   
   -- TLTING01
	IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
	BEGIN
		UPDATE PutawayStrategy WITH (ROWLOCK)
		SET EditDate = GETDATE(),
		    EditWho  = SUSER_SNAME(),
		    TrafficCop = NULL	
		FROM PutawayStrategy , INSERTED WITH (NOLOCK)
		WHERE PutawayStrategy.PutawayStrategyKey = INSERTED.PutawayStrategyKey

		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62303   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on PutawayStrategy table. (ntrPutawayStrategyUpdate)" + " ( " + " SQLSvr MESSAGE=" + LTrim(RTrim(@c_errmsg)) + " ) "
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
		EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrPutawayStrategyUpdate"
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
ALTER TABLE [dbo].[PutawayStrategy] ADD CONSTRAINT [PKPutawayStrategy] PRIMARY KEY CLUSTERED ([PutawayStrategyKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PutawayStrategy] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PutawayStrategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PutawayStrategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PutawayStrategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PutawayStrategy] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A putaway sub strategy controls how the system determines generating putaway tasks. This header table contains the key to the putaway sub strategy and a description of what it does or how it applies to the facilityÆs operations.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a description of the putaway sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a unique code identifying the putaway sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'PutawayStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'TrafficCop'
GO
