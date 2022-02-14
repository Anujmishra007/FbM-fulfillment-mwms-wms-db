CREATE TABLE [dbo].[ID]
(
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ID_Id] DEFAULT (' '),
[Qty] [int] NOT NULL CONSTRAINT [DF_ID_Qty] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ID_Status] DEFAULT ('OK'),
[Packkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ID_Packkey] DEFAULT ('STD'),
[PutAwayTI] [int] NOT NULL CONSTRAINT [DF_ID_PutAwayTi] DEFAULT ((0)),
[PutAwayHI] [int] NOT NULL CONSTRAINT [DF_ID_PutAwayHi] DEFAULT ((0)),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ID_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ID_EditDate] DEFAULT (getdate()),
[PalletFlag] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_PalletFlag] DEFAULT (''),
[TaskStatus] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_TaskStatus] DEFAULT (''),
[VirtualLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_VirtualLoc] DEFAULT (''),
[PalletFlag2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_PalletFlag2] DEFAULT (''),
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_Channel] DEFAULT (''),
[Channel_ID] [bigint] NULL CONSTRAINT [DF_ID_Channel_ID] DEFAULT ((0)),
[InitialWeight] [float] NULL CONSTRAINT [DF_ID_InitialWeight] DEFAULT ((0))
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ID] ADD CONSTRAINT [PKID] PRIMARY KEY CLUSTERED ([Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[ID] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[ID] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ID] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ID] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ID] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Initial Weight', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'InitialWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the Pack code.', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'Packkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Also known as quantity on hand, in stock, store quantity. Quantity on hand describes the actual physical inventory in the possession of the business. When inventory is received or produced, it is added to quantity on hand, when inventory is sold or consumed, it is removed from quantity on hand.', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'TrafficCop'
GO
