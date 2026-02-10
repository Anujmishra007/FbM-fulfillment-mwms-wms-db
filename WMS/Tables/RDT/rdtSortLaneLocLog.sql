SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[rdtSortLaneLocLog]') AND type in (N'U'))
BEGIN

CREATE TABLE [RDT].[rdtSortLaneLocLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Lane] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_Lane] DEFAULT (''),
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_LOC] DEFAULT (''),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_ID] DEFAULT (''),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_OrderKey] DEFAULT (''),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_ConsigneeKey] DEFAULT (''),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_EditDate] DEFAULT (getdate()),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSortLaneLocLog_LoadKey] DEFAULT ('')
) ON [PRIMARY]

ALTER TABLE [RDT].[rdtSortLaneLocLog] ADD CONSTRAINT [PK_rdtSortLaneLocLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [IX_rdtSortLaneLocLog_Lane_LOC] ON [RDT].[rdtSortLaneLocLog] ([Lane], [LOC]) WITH (FILLFACTOR=90) ON [PRIMARY]

GRANT DELETE ON  [RDT].[rdtSortLaneLocLog] TO [NSQL]

GRANT INSERT ON  [RDT].[rdtSortLaneLocLog] TO [NSQL]

GRANT SELECT ON  [RDT].[rdtSortLaneLocLog] TO [NSQL]

GRANT UPDATE ON  [RDT].[rdtSortLaneLocLog] TO [NSQL]

END

ELSE 
BEGIN
--WMS-24612
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'WaveKey' AND Object_ID = Object_ID(N'rdt.RDTSORTLANELOCLOG'))
BEGIN
   ALTER TABLE [rdt].[RDTSORTLANELOCLOG]
   ADD [WaveKey] [nvarchar](10) NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_WaveKey]  DEFAULT ('')

EXEC sp_addextendedproperty 
@name = N'MS_Description', @value = N'Store WaveKey', 
@level0type = N'Schema', @level0name = rdt, 
@level1type = N'Table',  @level1name = RDTSORTLANELOCLOG, 
@level2type = N'Column', @level2name = [WaveKey];

END

END


