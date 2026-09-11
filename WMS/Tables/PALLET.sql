SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PALLET]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PALLET]
(
[PalletKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLET_StorerKey] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLET_Status] DEFAULT ('0'),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_PALLET_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PALLET_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLET_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PALLET_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLET_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Length] [float] NOT NULL CONSTRAINT [DF_PALLET_Length] DEFAULT ((0)),
[Width] [float] NOT NULL CONSTRAINT [DF_PALLET_Width] DEFAULT ((0)),
[Height] [float] NOT NULL CONSTRAINT [DF_PALLET_Height] DEFAULT ((0)),
[GrossWgt] [float] NOT NULL CONSTRAINT [DF_PALLET_GrossWgt] DEFAULT ((0)),
[PalletType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLET_PalletType] DEFAULT (''),
[Hierarchy] NVARCHAR (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLET_Hierarchy]  DEFAULT (' '),
[Cube] [float] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[PALLET] WITH NOCHECK ADD CONSTRAINT [CK_PALLET_Status] CHECK (([Status]='9' OR [Status]='0' OR [Status]='5' OR [Status]='3'))

ALTER TABLE [dbo].[PALLET] ADD CONSTRAINT [PKPALLET] PRIMARY KEY CLUSTERED ([PalletKey]) WITH (FILLFACTOR=90) ON [PRIMARY]

GRANT SELECT ON  [dbo].[PALLET] TO [JReportRole]

GRANT DELETE ON  [dbo].[PALLET] TO [NSQL]

GRANT INSERT ON  [dbo].[PALLET] TO [NSQL]

GRANT SELECT ON  [dbo].[PALLET] TO [NSQL]

GRANT UPDATE ON  [dbo].[PALLET] TO [NSQL]

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'AddDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'AddWho'

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'EditDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'EditWho'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pallet.', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'PalletKey'

EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'StorerKey'

EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'TrafficCop'

END
GO

--FCR-15713
IF NOT EXISTS ( SELECT * FROM sys.columns WHERE Name = 'Hierarchy' AND Object_ID = Object_ID('PALLET'))
BEGIN
     ALTER TABLE PALLET
	 ADD Hierarchy NVARCHAR (10) NULL CONSTRAINT [DF_PALLET_Hierarchy]  DEFAULT (' ');
     EXEC sp_addextendedproperty N'MS_Description', 'Hierarchy' , 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN',N'Hierarchy'
END

IF NOT EXISTS ( SELECT * FROM sys.columns WHERE Name = 'Cube' AND Object_ID = Object_ID('PALLET'))
BEGIN
     ALTER TABLE PALLET
	 ADD Cube [float] NULL; 
     EXEC sp_addextendedproperty N'MS_Description', 'Cube' , 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN',N'Cube'
END
