CREATE TABLE [dbo].[XDOCKStrategy]
(
[XDockStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKStrategy_XDockStrategyKey] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKSTRATEGY_Descr] DEFAULT (' '),
[TYPE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKSTRATEGY_Type] DEFAULT (' '),
[OVERALLOC] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKSTRATEGY_OverAlloc] DEFAULT ('N'),
[USERDEFINE01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKSTRATEGY_UserDefine01] DEFAULT (' '),
[SORT01] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKSTRATEGY_Sort01] DEFAULT (' '),
[USERDEFINE02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKSTRATEGY_UserDefine02] DEFAULT (' '),
[SORT02] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKSTRATEGY_Sort02] DEFAULT (' '),
[USERDEFINE03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKSTRATEGY_UserDefine03] DEFAULT (' '),
[SORT03] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKSTRATEGY_Sort03] DEFAULT (' '),
[USERDEFINE04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKSTRATEGY_UserDefine04] DEFAULT (' '),
[SORT04] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKSTRATEGY_Sort04] DEFAULT (' '),
[USERDEFINE05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKSTRATEGY_UserDefine05] DEFAULT (' '),
[SORT05] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKSTRATEGY_Sort05] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_XDOCKSTRATEGY_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKSTRATEGY_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_XDOCKSTRATEGY_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKSTRATEGY_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOM1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKStrategy_UOM1] DEFAULT ('N'),
[UOM2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKStrategy_UOM2] DEFAULT ('N'),
[UOM3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKStrategy_UOM3] DEFAULT ('N'),
[UOM4] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKStrategy_UOM4] DEFAULT ('Y'),
[msrepl_tran_version] [uniqueidentifier] NOT NULL CONSTRAINT [DF_XDOCKStrategy_msrepl_tran_version] DEFAULT (newid())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[XDOCKStrategy] ADD CONSTRAINT [PKXDOCKStrategy] PRIMARY KEY NONCLUSTERED ([XDockStrategyKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[XDOCKStrategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[XDOCKStrategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[XDOCKStrategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[XDOCKStrategy] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Setup the crossdock strategy which will be used during the allocation of stock at receipt', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKStrategy', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKStrategy', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKStrategy', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a description of the xdock sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKStrategy', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKStrategy', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKStrategy', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKStrategy', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'uom1', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKStrategy', 'COLUMN', N'UOM1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a unique code identifying the xdock sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKStrategy', 'COLUMN', N'XDockStrategyKey'
GO
