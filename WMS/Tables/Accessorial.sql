CREATE TABLE [dbo].[Accessorial]
(
[Accessorialkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descrip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_Descrip] DEFAULT (' '),
[SupportFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_SupportFlag] DEFAULT ('A'),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_StorerKey] DEFAULT (' '),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_SKU] DEFAULT (' '),
[ServiceKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_ServiceKey] DEFAULT ('XXXXXXXXXX'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_Accessorial_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_Accessorial_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Accessorial] WITH NOCHECK ADD CONSTRAINT [CK_ACCS_SupportFlag] CHECK (([SupportFLag]='D' OR [SupportFLag]='I' OR [SupportFLag]='A'))
GO
ALTER TABLE [dbo].[Accessorial] ADD CONSTRAINT [PKAccessorial] PRIMARY KEY CLUSTERED ([Accessorialkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Accessorial] WITH NOCHECK ADD CONSTRAINT [FKAccessorial] FOREIGN KEY ([ServiceKey]) REFERENCES [dbo].[Services] ([Servicekey])
GO
GRANT DELETE ON  [dbo].[Accessorial] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Accessorial] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Accessorial] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Accessorial] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Accessorial.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'Accessorialkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the Accessorial.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'Descrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Service.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'ServiceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Stock Keeping Unit. Refers to the identification number assigned to each SKU.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record. Owner of the commodity.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'TrafficCop'
GO
