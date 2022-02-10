CREATE TABLE [dbo].[AccessorialDetail]
(
[Accessorialkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AccessorialDetailkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_AccessorialDetailkey] DEFAULT (' '),
[Descrip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_Descrip] DEFAULT (' '),
[Rate] [decimal] (22, 6) NOT NULL,
[Base] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_Base] DEFAULT ('Q'),
[MasterUnits] [decimal] (12, 6) NOT NULL CONSTRAINT [DF_AccessorialDetail_MasterUnits] DEFAULT ((1.0)),
[UomShow] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AccessorialDetail_UomShow] DEFAULT (' '),
[TaxGroupKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_TaxGroupKey] DEFAULT ('XXXXXXXXXX'),
[GLDistributionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_GLDistributionKey] DEFAULT ('XXXXXXXXXX'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_AccessorialDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_AccessorialDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[CostRate] [decimal] (22, 6) NULL CONSTRAINT [DF_AccessorialDetail_CostRate] DEFAULT ((0.0)),
[CostBase] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AccessorialDetail_CostBase] DEFAULT ('Q'),
[CostMasterUnits] [decimal] (12, 6) NULL CONSTRAINT [DF_AccessorialDetail_CostMasterUnits] DEFAULT ((1.0)),
[CostUOMShow] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AccessorialDetail_CostUOMShow] DEFAULT (' ')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccessorialDetail] WITH NOCHECK ADD CONSTRAINT [CK_AccDet_Base] CHECK (([Base]='R' OR [Base]='F' OR [Base]='C' OR [Base]='G' OR [Base]='Q'))
GO
ALTER TABLE [dbo].[AccessorialDetail] WITH NOCHECK ADD CONSTRAINT [CK_AccDet_CostBase] CHECK (([CostBase]='R' OR [CostBase]='F' OR [CostBase]='C' OR [CostBase]='G' OR [CostBase]='Q'))
GO
ALTER TABLE [dbo].[AccessorialDetail] WITH NOCHECK ADD CONSTRAINT [CK_AccDet_MU] CHECK (([MasterUnits]>(0.0)))
GO
ALTER TABLE [dbo].[AccessorialDetail] ADD CONSTRAINT [PKAccessorialDetail] PRIMARY KEY CLUSTERED ([AccessorialDetailkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccessorialDetail] WITH NOCHECK ADD CONSTRAINT [FK_AccDet_GLDist_01] FOREIGN KEY ([GLDistributionKey]) REFERENCES [dbo].[GLDistribution] ([GLDistributionKey])
GO
ALTER TABLE [dbo].[AccessorialDetail] WITH NOCHECK ADD CONSTRAINT [FKAccessorialDetail] FOREIGN KEY ([Accessorialkey]) REFERENCES [dbo].[Accessorial] ([Accessorialkey])
GO
GRANT DELETE ON  [dbo].[AccessorialDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AccessorialDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AccessorialDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AccessorialDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Accessorial Detail.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'AccessorialDetailkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Accessorial.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'Accessorialkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the Accessorial Detail.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'Descrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying GL Distribution.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'GLDistributionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The cost per unit of a commodity or service.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'Rate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tax Group.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'TaxGroupKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'TrafficCop'
GO
