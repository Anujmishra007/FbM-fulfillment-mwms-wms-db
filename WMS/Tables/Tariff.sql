CREATE TABLE [dbo].[Tariff]
(
[TariffKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descrip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Tariff_Descrip] DEFAULT (' '),
[SupportFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Tariff_SupportFlag] DEFAULT ('A'),
[InitialStoragePeriod] [int] NULL,
[RecurringStoragePeriod] [int] NULL,
[SplitMonthDay] [int] NOT NULL CONSTRAINT [DF_Tariff_SplitMonthDay] DEFAULT ((15)),
[SplitMonthPercent] [decimal] (12, 6) NOT NULL CONSTRAINT [DF_Tariff_SplitMonthPercent] DEFAULT ((0.50)),
[PeriodType] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_Tariff_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Tariff_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_Tariff_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Tariff_EditWho] DEFAULT (suser_sname()),
[CalendarGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RSPeriodType] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SplitMonthPercentBefore] [decimal] (12, 6) NULL CONSTRAINT [DF_Tariff_SplitMonthPercentBefore] DEFAULT ((1.0)),
[CaptureEndOfMonth] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Tariff_CaptureEndOfMonth] DEFAULT ('1')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Tariff] WITH NOCHECK ADD CONSTRAINT [CK_Tariff_I_S_P] CHECK (([InitialStoragePeriod]>=(1) AND [InitialStoragePeriod]<=(999)))
GO
ALTER TABLE [dbo].[Tariff] WITH NOCHECK ADD CONSTRAINT [CK_Tariff_RSPerType] CHECK (([RSPeriodType]='S' OR [RSPeriodType]='A' OR [RSPeriodType]='C' OR [RSPeriodType]='F'))
GO
ALTER TABLE [dbo].[Tariff] WITH NOCHECK ADD CONSTRAINT [CK_Tariff_R_S_P] CHECK (([RecurringStoragePeriod]>=(1) AND [RecurringStoragePeriod]<=(999)))
GO
ALTER TABLE [dbo].[Tariff] WITH NOCHECK ADD CONSTRAINT [CK_Tariff_R_S_Type] CHECK (([PeriodType]='C' OR [PeriodType]='S' OR [PeriodType]='A' OR [PeriodType]='F'))
GO
ALTER TABLE [dbo].[Tariff] WITH NOCHECK ADD CONSTRAINT [CK_Tariff_SpMonth_Before] CHECK (([SplitMonthPercentBefore]>=(0.0) AND [SplitMonthPercentBefore]<=(1.0)))
GO
ALTER TABLE [dbo].[Tariff] WITH NOCHECK ADD CONSTRAINT [CK_Tariff_Sp_Month_Per] CHECK (([SplitMonthPercent]>=(0.0)))
GO
ALTER TABLE [dbo].[Tariff] WITH NOCHECK ADD CONSTRAINT [CK_Tariff_SplitMonthDay] CHECK (([SplitMonthDay]>=(1) AND [SplitMonthDay]<=(31)))
GO
ALTER TABLE [dbo].[Tariff] WITH NOCHECK ADD CONSTRAINT [CK_Tariff_SupportFlag] CHECK (([SupportFLag]='D' OR [SupportFLag]='I' OR [SupportFLag]='A'))
GO
ALTER TABLE [dbo].[Tariff] ADD CONSTRAINT [PKTariff] PRIMARY KEY CLUSTERED ([TariffKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Tariff] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Tariff] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Tariff] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Tariff] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Tariff', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'Tariff', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the Tariff. ', 'SCHEMA', N'dbo', 'TABLE', N'Tariff', 'COLUMN', N'Descrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Tariff', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'Tariff', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of tariff assigned to the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'Tariff', 'COLUMN', N'TariffKey'
GO
