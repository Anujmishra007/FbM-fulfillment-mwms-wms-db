-- UWP-53936
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[rdtArchiveTote_Audit]') AND type in (N'U'))
BEGIN
   CREATE TABLE [RDT].[rdtArchiveTote_Audit](
      [ID] [int] IDENTITY(1,1) NOT NULL,
      [StorerKey] [nvarchar](15) NOT NULL,
      [DropID] [nvarchar](20) NOT NULL,
      [PickDetail_Exists] [nvarchar](1) NOT NULL,
      [PickDetail_Cnt] [smallint] NOT NULL,
      [PackDetail_Exists] [nvarchar](1) NOT NULL,
      [PackDetail_Cnt] [smallint] NOT NULL,
      [AddDate] [datetime] NOT NULL,
      [AddWho] [nvarchar](128) NOT NULL
   ) ON [PRIMARY]
END
GO

ALTER TABLE [RDT].[rdtArchiveTote_Audit] ADD CONSTRAINT [PKrdtArchiveTote_Audit] PRIMARY KEY CLUSTERED ([ID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO

ALTER TABLE [RDT].[rdtArchiveTote_Audit] ADD  CONSTRAINT [DF_RDT.rdtArchiveTote_Audit_AddDate]  DEFAULT (getdate()) FOR [AddDate]
GO

ALTER TABLE [RDT].[rdtArchiveTote_Audit] ADD  CONSTRAINT [DF_RDT.rdtArchiveTote_Audit_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
GO

GRANT DELETE ON  [RDT].[rdtArchiveTote_Audit] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtArchiveTote_Audit] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtArchiveTote_Audit] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtArchiveTote_Audit] TO [NSQL]
GO

