CREATE TABLE [dbo].[UPSTracking_In]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[CartonID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UPSTracking_In_CartonID] DEFAULT (''),
[WMS_RefKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UPSTracking_In_WMS_RefKey] DEFAULT (''),
[WMS_RefType] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_In_WMS_RefType] DEFAULT (''),
[ServiceIndicator] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_In_ServiceIndicator] DEFAULT (''),
[UPSTrackingNo] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_In_UPSTrackingNo] DEFAULT (''),
[FreightCharge] [nvarchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_In_FreightCharge] DEFAULT ((0)),
[InsuranceCharge] [nvarchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_In_InsuranceCharge] DEFAULT ((0)),
[Weight] [nvarchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_In_Weight] DEFAULT ((0)),
[VoidIndicator] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_In_Status] DEFAULT ('0'),
[AddDate] [datetime] NULL CONSTRAINT [DF_UPSTracking_In_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UPSTracking_In] ADD CONSTRAINT [PK_UPSTracking_In] PRIMARY KEY CLUSTERED ([RowID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UPSTracking_In] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UPSTracking_In] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UPSTracking_In] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UPSTracking_In] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UPSTracking_In', 'COLUMN', N'AddDate'
GO
