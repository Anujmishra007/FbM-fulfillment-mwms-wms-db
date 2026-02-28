SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TemperatureLog]') AND type in (N'U'))
BEGIN

CREATE TABLE [dbo].[TemperatureLog](
	[TemperatureLogID] [nvarchar](10) NOT NULL,
	[StorerKey] [nvarchar](15) NOT NULL,
	[Facility] [nvarchar](5) NOT NULL,
	[ReceiptKey] [nvarchar](10) NULL,
	[MbolKey] [nvarchar](10) NULL,
	[PalletId] [nvarchar](30) NOT NULL,
	[UCCNo] [nvarchar](30) NULL,
	[Temperature] [decimal](5, 2) NULL,
	[TempCheckPoint] [nvarchar](1) NOT NULL,
	[CheckDate] [datetime] NULL,
	[CheckUser] [nvarchar](128) NULL,
	[UserDefine01] [nvarchar](20) NULL,
	[Userdefine02] [nvarchar](20) NULL,
	[Userdefine03] [nvarchar](20) NULL,
	[Userdefine04] [nvarchar](20) NULL,
	[Userdefine05] [nvarchar](20) NULL,
	[EditDate] [datetime] NULL,
	[EditWho] [nvarchar](128) NULL,
 CONSTRAINT [PK_TemperatureLog] PRIMARY KEY CLUSTERED 
(
	[TemperatureLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Facility] ASC,
	[PalletId] ASC,
	[UCCNo] ASC,
	[CheckDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_TemperatureLogID]  DEFAULT (' ') FOR [TemperatureLogID]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_StorerKey]  DEFAULT (' ') FOR [StorerKey]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_Facility]  DEFAULT (' ') FOR [Facility]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_ReceiptKey]  DEFAULT (' ') FOR [ReceiptKey]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_MbolKey]  DEFAULT (' ') FOR [MbolKey]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_PalletId]  DEFAULT (' ') FOR [PalletId]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_UCCNo]  DEFAULT (' ') FOR [UCCNo]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_TempCheckPoint]  DEFAULT ('R') FOR [TempCheckPoint]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_CheckDate]  DEFAULT (getdate()) FOR [CheckDate]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_CheckUser]  DEFAULT (suser_sname()) FOR [CheckUser]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_UserDefine01]  DEFAULT (' ') FOR [UserDefine01]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_Userdefine02]  DEFAULT (' ') FOR [Userdefine02]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_Userdefine03]  DEFAULT (' ') FOR [Userdefine03]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_Userdefine04]  DEFAULT (' ') FOR [Userdefine04]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_Userdefine05]  DEFAULT (' ') FOR [Userdefine05]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_EditDate]  DEFAULT (getdate()) FOR [EditDate]

ALTER TABLE [dbo].[TemperatureLog] ADD  CONSTRAINT [DF_TemperatureLog_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]

--ALTER TABLE [dbo].[TemperatureLog]  WITH CHECK ADD  CONSTRAINT [FK_MBOL_MbolKey] FOREIGN KEY([MbolKey])
--REFERENCES [dbo].[MBOL] ([MbolKey])


--ALTER TABLE [dbo].[TemperatureLog] CHECK CONSTRAINT [FK_MBOL_MbolKey]


--ALTER TABLE [dbo].[TemperatureLog]  WITH CHECK ADD  CONSTRAINT [FK_Receipt_ReceiptKey] FOREIGN KEY([ReceiptKey])
--REFERENCES [dbo].[RECEIPT] ([ReceiptKey])


--ALTER TABLE [dbo].[TemperatureLog] CHECK CONSTRAINT [FK_Receipt_ReceiptKey]


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique key to the Storer record. Owner of the commodity' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'StorerKey'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique key that identifies the warehouse or distribution center' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'Facility'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ASN#' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'ReceiptKey'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ship Reference#, Load ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'MbolKey'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pallet ID/Drop ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'PalletId'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Carton ID/UCC Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'UCCNo'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Temperature' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'Temperature'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'R - Receiving, S - Stock/In House checking, L - Loading' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'TempCheckPoint'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Check Date and Time' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'CheckDate'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User ID of the person who captured the value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'CheckUser'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Extra field for site specific usage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'UserDefine01'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Extra field for site specific usage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'Userdefine02'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Extra field for site specific usage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'Userdefine03'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Extra field for site specific usage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'Userdefine04'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Extra field for site specific usage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'Userdefine05'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Edit Date and Time' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'EditDate'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When the data was changed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TemperatureLog', @level2type=N'COLUMN',@level2name=N'EditWho'


END 
GO

