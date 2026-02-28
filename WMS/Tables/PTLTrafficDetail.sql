IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PTLTrafficDetail]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PTLTrafficDetail]
(
[UserID] [nvarchar] (128) NOT NULL,
[PTLKey] [bigint] NOT NULL,
[MonitorID] [nvarchar] (20) NOT NULL,
[USERNO] [int] NOT NULL CONSTRAINT [DF_PTLTrafficDetail_USERNO] DEFAULT ('0'),
[TrafficData] [nvarchar] (max) NULL CONSTRAINT [DF_PTLTrafficDetail_TrafficData] DEFAULT (''),
[Status] [nvarchar] (1) NOT NULL CONSTRAINT [DF_PTLTrafficDetail_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_PTLTrafficDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PTLTrafficDetail_AddDate] DEFAULT (getdate()),
[Remarks] [nvarchar] (60) NULL CONSTRAINT [DF_PTLTrafficDetail_Remarks] DEFAULT ('')
) ON [PRIMARY]

ALTER TABLE [dbo].[PTLTrafficDetail] ADD CONSTRAINT [PK_PTLTrafficDetail] PRIMARY KEY CLUSTERED ([PTLKey], [MonitorID]) ON [PRIMARY]

GRANT DELETE ON  [dbo].[PTLTrafficDetail] TO [NSQL]

GRANT INSERT ON  [dbo].[PTLTrafficDetail] TO [NSQL]

GRANT SELECT ON  [dbo].[PTLTrafficDetail] TO [NSQL]

GRANT UPDATE ON  [dbo].[PTLTrafficDetail] TO [NSQL]

EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'AddDate'

EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'AddWho'

EXEC sp_addextendedproperty N'MS_Description', N'Monitor ID', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'MonitorID'

EXEC sp_addextendedproperty N'MS_Description', N'PTL Key', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'PTLKey'

EXEC sp_addextendedproperty N'MS_Description', N'Status', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'Status'

EXEC sp_addextendedproperty N'MS_Description', N'Traffic Data', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'TrafficData'

EXEC sp_addextendedproperty N'MS_Description', N'User ID', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'UserID'

END

ELSE 
BEGIN


IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'Remarks' AND Object_ID = Object_ID('dbo.PTLTrafficDetail'))
BEGIN
	ALTER TABLE dbo.PTLTrafficDetail ADD [Remarks] [nvarchar] (60) NULL CONSTRAINT [DF_PTLTrafficDetail_Remarks] DEFAULT ('') ;
	EXEC sp_addextendedproperty N'MS_Description', 'Remarks', 'SCHEMA', N'DBO', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'Remarks'
				
END

END

