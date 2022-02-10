CREATE TABLE [dbo].[TRANSMITLOG3]
(
[transmitlogkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG3_tablename] DEFAULT (' '),
[key1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG3_key1] DEFAULT (' '),
[key2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG3_key2] DEFAULT (' '),
[key3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG3_key3] DEFAULT (' '),
[transmitflag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG3_transmitflag] DEFAULT ('0'),
[transmitbatch] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSMITLOG3_transmitbatch] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TRANSMITLOG3_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG3_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TRANSMITLOG3_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSMITLOG3_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TRANSMITLOG3] ADD CONSTRAINT [PKTRANSMITLOG3] PRIMARY KEY CLUSTERED ([transmitlogkey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TRANSMITLOG3_CIdx] ON [dbo].[TRANSMITLOG3] ([tablename], [key1], [key3], [key2]) INCLUDE ([transmitflag]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TRANSMITLOG3_01] ON [dbo].[TRANSMITLOG3] ([transmitflag], [tablename], [key3]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[TRANSMITLOG3] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[TRANSMITLOG3] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TRANSMITLOG3] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TRANSMITLOG3] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TRANSMITLOG3] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG3', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG3', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG3', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG3', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG3', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Transmit Log.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSMITLOG3', 'COLUMN', N'transmitlogkey'
GO
