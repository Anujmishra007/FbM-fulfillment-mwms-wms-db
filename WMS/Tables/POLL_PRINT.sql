CREATE TABLE [dbo].[POLL_PRINT]
(
[printtype] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_POLL_PRINT_orderkey] DEFAULT (' '),
[caseid] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_POLL_PRINT_caseid] DEFAULT (' '),
[dropid] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_POLL_PRINT_dropid] DEFAULT (' '),
[status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_POLL_PRINT_status] DEFAULT ('0'),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_POLL_PRINT_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_POLL_PRINT_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_POLL_PRINT_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_POLL_PRINT_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_POLL_PRINT_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[POLL_PRINT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[POLL_PRINT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[POLL_PRINT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[POLL_PRINT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'POLL_PRINT', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_PRINT', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Case.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_PRINT', 'COLUMN', N'caseid'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This field is populated by the system once a sorter scans the ID that is used to identify the customerÆs outbound packing container. This allows the sorter to apply the Drop ID label to the outbound container and simply scan the barcode for the location to verify proper sortation. The system then records the sort into the Drop ID assigned to the scanned sortation location.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_PRINT', 'COLUMN', N'dropid'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'POLL_PRINT', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_PRINT', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_PRINT', 'COLUMN', N'orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_PRINT', 'COLUMN', N'TrafficCop'
GO
