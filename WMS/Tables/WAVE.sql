IF NOT EXISTS (SELECT *
               FROM sys.tables
               WHERE name = 'Wave' AND type = 'U')
BEGIN
CREATE TABLE [dbo].[WAVE]
(
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WaveType] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_WaveType] DEFAULT ('0'),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_Descr] DEFAULT (' '),
[DispatchPQetPickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_DispatchPalletPickMethod] DEFAULT ('1'),
[DispatchCasePickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_DispatchCasePickMethod] DEFAULT ('1'),
[DispatchPiecePickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_DispatchPiecePickMethod] DEFAULT ('1'),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WAVE_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WAVE_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Wave_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Wave_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Wave_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Wave_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Wave_UserDefine05] DEFAULT (''),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Wave_UserDefine08] DEFAULT (''),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Wave_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Wave_UserDefine10] DEFAULT (''),
[LoadplanGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBOLGroupMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchNo] [bigint] NOT NULL CONSTRAINT [DF_WAVE_BatchNo] DEFAULT ((0)),
[TMSStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_TMSStatus] DEFAULT ('0'),
[DoorBookStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_DoorBookStatus] DEFAULT ('0'),
[ReplenishStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_ReplenishStatus] DEFAULT ('0'),
[TMReleaseFlag] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_TMReleaseFlag] DEFAULT ('N'),
[GenDynamicPickSlipCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_GenDynamicPickSlipCode] DEFAULT (''),
[Strategykey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVE_Strategykey] DEFAULT (''),
[ExternStatus] [nvarchar] (10) NOT NULL CONSTRAINT [DF_WAVE_ExternStatus] DEFAULT (''),
[EventDateTime] [datetime] NOT NULL CONSTRAINT [DF_WAVE_EventDateTime] DEFAULT (getdate()),
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WAVE] WITH NOCHECK ADD CONSTRAINT [CK_WAVE_WaveKey_Numeric] CHECK ((isnumeric([WaveKey])=(1)))
GO
ALTER TABLE [dbo].[WAVE] ADD CONSTRAINT [PKWave] PRIMARY KEY CLUSTERED ([WaveKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[WAVE] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[WAVE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WAVE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WAVE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WAVE] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A wave is simply a group of orders. Orders with the same criteria can be batched into a wave to simplify the picking process.', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Wave BatchNo', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'BatchNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Wave.', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Door Book Status', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'DoorBookStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Dynamic Pick PickSlip Code', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'GenDynamicPickSlipCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'MBOL Grouping Method', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'MBOLGroupMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenish Status', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'ReplenishStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Strategy Key', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'Strategykey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'TMS Status', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'TMSStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'WaveKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'External wave status' , 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN',N'ExternStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Captures the exact timestamp of the event' , 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN',N'EventDateTime'

END
ELSE
BEGIN
IF NOT EXISTS (SELECT 1
 		               FROM sys.columns
 		               WHERE Name = 'ExternStatus' AND Object_ID = Object_ID('WAVE'))
BEGIN
ALTER TABLE WAVE ADD ExternStatus NVARCHAR(10) NOT NULL CONSTRAINT [DF_WAVE_ExternStatus]  DEFAULT (' ');
EXEC sp_addextendedproperty N'MS_Description', N'ExternStatus', 'SCHEMA', N'dbo', 'TABLE', N'WAVE', 'COLUMN', N'ExternStatus'
END
IF NOT EXISTS (SELECT *
                       FROM sys.columns
                       WHERE Name = 'EventDateTime'
                         AND Object_ID = Object_ID('WAVE'))
BEGIN
ALTER TABLE WAVE
    ADD EventDateTime [datetime] NOT NULL CONSTRAINT [DF_WAVE_EventDateTime] DEFAULT (getdate());
EXEC sp_addextendedproperty N'MS_Description', N'EventDateTime', 'SCHEMA', N'dbo', 'TABLE',
                     N'WAVE', 'COLUMN', N'EventDateTime'
END
