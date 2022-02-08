CREATE TABLE [RDT].[rdtCSAudit]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[GroupID] [int] NOT NULL CONSTRAINT [DF_rdtCSAudit_GroupID] DEFAULT ((0)),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Workstation] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PalletID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountQTY_A] [int] NOT NULL CONSTRAINT [DF_rdtCSAudit_CountQTY_A] DEFAULT ((0)),
[CountQTY_B] [int] NOT NULL CONSTRAINT [DF_rdtCSAudit_CountQTY_B] DEFAULT ((0)),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCSAudit_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCSAudit_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtCSAudit_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCSAudit_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtCSAudit_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo4] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo5] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalQTY] [int] NOT NULL CONSTRAINT [DF_rdtCSAudit_OriginalQTY] DEFAULT ((0)),
[AdjustedQTY] [int] NOT NULL CONSTRAINT [DF_rdtCSAudit_AdjustedQTY] DEFAULT ((0)),
[AdjustReason] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdjustWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdjustDate] [datetime] NULL,
[BatchID] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 28-Oct-2013  TLTING     Review Editdate column update                */

CREATE TRIGGER [RDT].[ntrRDTCSAuditUpdate]
ON  [RDT].[rdtCSAudit]
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
	 
   IF UPDATE( TrafficCop) OR 
      UPDATE( ArchiveCop) 
      RETURN

   IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE RDT.RDTCSAudit SET
         EditWho  = SUSER_SNAME(), 
         EditDate = GETDATE()
      FROM RDT.RDTCSAudit
         INNER JOIN INSERTED ON RDT.RDTCSAudit.RowRef = INSERTED.RowRef
	   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	   IF @n_err <> 0
	   BEGIN
		   SELECT @n_continue = 3
		   SELECT @n_err     = 62850   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		   SELECT @c_errmsg  = 'NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table RDT.RDTCSAudit. (ntrRDTCSAuditUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
	   END
   END
GO
ALTER TABLE [RDT].[rdtCSAudit] WITH NOCHECK ADD CONSTRAINT [CK_RDTCSAudit_01] CHECK (([Status]='0' OR [Status]='5' OR [Status]='9'))
GO
ALTER TABLE [RDT].[rdtCSAudit] ADD CONSTRAINT [PKRDTCSAudit] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_RDTCSAudit_BatchID] ON [RDT].[rdtCSAudit] ([BatchID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_RDTCSAudit_GroupID] ON [RDT].[rdtCSAudit] ([GroupID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_RDTCSAudit_PalletID_CaseID_SKU] ON [RDT].[rdtCSAudit] ([PalletID], [CaseID], [SKU]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_RDTCSAudit_StorerKey_Workstation_ConsigneeKey_Status] ON [RDT].[rdtCSAudit] ([StorerKey], [Workstation], [ConsigneeKey], [Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtCSAudit] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtCSAudit] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtCSAudit] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtCSAudit] TO [NSQL]
GO
