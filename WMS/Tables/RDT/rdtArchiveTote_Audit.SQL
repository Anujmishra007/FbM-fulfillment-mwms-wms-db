-- UWP-53936
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[rdtArchiveTote_Audit]') AND type in (N'U'))
BEGIN
CREATE TABLE [RDT].[rdtArchiveTote_Audit](
   [ID] [int] IDENTITY(1,1) NOT NULL,
   [StorerKey] [nvarchar](15) NOT NULL,
   [DropID] [nvarchar](20) NOT NULL,
   [PackDetail_Keys] [nvarchar](2000) NOT NULL,
   [PackDetail_Cnt] [smallint] NOT NULL,
   [PickDetail_Keys] [nvarchar](2000) NOT NULL,
   [PickDetail_Cnt] [smallint] NOT NULL,
   [AddDate] [datetime] NOT NULL,
   [AddWho] [nvarchar](128) NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID(N'[RDT].[rdtArchiveTote_Audit]') AND name = N'DF_RDT.rdtArchiveTote_Audit_AddDate')
BEGIN
   ALTER TABLE [RDT].[rdtArchiveTote_Audit] ADD CONSTRAINT [DF_RDT.rdtArchiveTote_Audit_AddDate] DEFAULT (getdate()) FOR [AddDate]
END
GO

IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID(N'[RDT].[rdtArchiveTote_Audit]') AND name = N'DF_RDT.rdtArchiveTote_Audit_AddWho')
BEGIN
   ALTER TABLE [RDT].[rdtArchiveTote_Audit] ADD CONSTRAINT [DF_RDT.rdtArchiveTote_Audit_AddWho] DEFAULT (suser_sname()) FOR [AddWho]
END
GO

GRANT DELETE ON  [RDT].[rdtArchiveTote_Audit] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtArchiveTote_Audit] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtArchiveTote_Audit] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtArchiveTote_Audit] TO [NSQL]
GO

