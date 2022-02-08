CREATE TABLE [RDT].[RDTMenu]
(
[MenuNo] [int] NOT NULL,
[Heading] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OP1] [int] NULL CONSTRAINT [DF_RDTMenu_OP1] DEFAULT ((0)),
[OP2] [int] NULL CONSTRAINT [DF_RDTMenu_OP2] DEFAULT ((0)),
[OP3] [int] NULL CONSTRAINT [DF_RDTMenu_OP3] DEFAULT ((0)),
[OP4] [int] NULL CONSTRAINT [DF_RDTMenu_OP4] DEFAULT ((0)),
[OP5] [int] NULL CONSTRAINT [DF_RDTMenu_OP5] DEFAULT ((0)),
[OP6] [int] NULL CONSTRAINT [DF_RDTMenu_OP6] DEFAULT ((0)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMenu_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RDTMenu_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMenu_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_RDTMenu_EditDate] DEFAULT (getdate()),
[OP7] [int] NULL CONSTRAINT [DF_RDTMenu_OP7] DEFAULT ((0)),
[OP8] [int] NULL CONSTRAINT [DF_RDTMenu_OP8] DEFAULT ((0)),
[OP9] [int] NULL CONSTRAINT [DF_RDTMenu_OP9] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE TRIGGER [RDT].[ntrRDTMenuUpdate]
ON  [RDT].[RDTMenu]
FOR UPDATE
AS
IF @@ROWCOUNT = 0
BEGIN
RETURN
END
   SET NOCOUNT ON
   SET ANSI_NULLS OFF   
   SET QUOTED_IDENTIFIER OFF
	SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?
            @n_err         int,       -- Error number returned by stored procedure or this trigger
            @c_errmsg      NVARCHAR(250), -- Error message returned by stored procedure or this trigger
            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
            @n_starttcnt   int,       -- Holds the current transaction count
            @n_cnt         int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.

   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT
	 

   IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE RDT.RDTMenu SET
         EditWho  = SUSER_SNAME(), 
         EditDate = GETDATE()
      FROM RDT.RDTMenu
         INNER JOIN INSERTED ON RDT.RDTMenu.MenuNo = INSERTED.MenuNo
	   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	   IF @n_err <> 0
	   BEGIN
		   SELECT @n_continue = 3
		   SELECT @n_err     = 62850   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		   SELECT @c_errmsg  = 'NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table RDT.RDTMenu. (ntrRDTMenuUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
	   END
   END
GO
ALTER TABLE [RDT].[RDTMenu] ADD CONSTRAINT [PK_RDTMenu] PRIMARY KEY CLUSTERED ([MenuNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTMenu] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTMenu] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTMenu] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTMenu] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'RDT Menu No. 7', 'SCHEMA', N'RDT', 'TABLE', N'RDTMenu', 'COLUMN', N'OP7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RDT Menu No. 8', 'SCHEMA', N'RDT', 'TABLE', N'RDTMenu', 'COLUMN', N'OP8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RDT Menu No. 9', 'SCHEMA', N'RDT', 'TABLE', N'RDTMenu', 'COLUMN', N'OP9'
GO
