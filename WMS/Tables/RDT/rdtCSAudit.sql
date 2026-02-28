IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[rdtCSAudit]') AND type in (N'U'))
BEGIN
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

ALTER TABLE [RDT].[rdtCSAudit] WITH NOCHECK ADD CONSTRAINT [CK_RDTCSAudit_01] CHECK (([Status]='0' OR [Status]='5' OR [Status]='9'))

ALTER TABLE [RDT].[rdtCSAudit] ADD CONSTRAINT [PKRDTCSAudit] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [Idx_RDTCSAudit_BatchID] ON [RDT].[rdtCSAudit] ([BatchID]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [Idx_RDTCSAudit_GroupID] ON [RDT].[rdtCSAudit] ([GroupID]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [Idx_RDTCSAudit_PalletID_CaseID_SKU] ON [RDT].[rdtCSAudit] ([PalletID], [CaseID], [SKU]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [Idx_RDTCSAudit_StorerKey_Workstation_ConsigneeKey_Status] ON [RDT].[rdtCSAudit] ([StorerKey], [Workstation], [ConsigneeKey], [Status]) WITH (FILLFACTOR=90) ON [PRIMARY]

GRANT DELETE ON  [RDT].[rdtCSAudit] TO [NSQL]

GRANT INSERT ON  [RDT].[rdtCSAudit] TO [NSQL]

GRANT SELECT ON  [RDT].[rdtCSAudit] TO [NSQL]

GRANT UPDATE ON  [RDT].[rdtCSAudit] TO [NSQL]

END

ELSE 
BEGIN

--ALTER COLUMN

		IF EXISTS( SELECT 1 
				FROM SYS.columns WHERE NAME ='CASEID' AND object_id = OBJECT_ID('[RDT].[rdtCSAudit]') and max_length <>40)
		ALTER TABLE [RDT].[rdtCSAudit]
		ALTER COLUMN [CaseID] [nvarchar] (20)  NULL;

END
