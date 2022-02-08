CREATE TABLE [dbo].[PTLLockLoc]
(
[PTLLockLocKey] [int] NOT NULL IDENTITY(1, 1),
[IPAddress] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DeviceID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DevicePosition] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PTLLockLoc_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PTLLockLoc_AddDate] DEFAULT (getdate()),
[LockType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLLockLoc_LockType] DEFAULT (''),
[NextLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLLockLoc_NextLoc] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PTLLockLoc] ADD CONSTRAINT [PK_PTLLockLoc] PRIMARY KEY CLUSTERED ([PTLLockLocKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PTLLockLoc_01] ON [dbo].[PTLLockLoc] ([DeviceID], [AddWho]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PTLLockLoc] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PTLLockLoc] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PTLLockLoc] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PTLLockLoc] TO [NSQL]
GO
