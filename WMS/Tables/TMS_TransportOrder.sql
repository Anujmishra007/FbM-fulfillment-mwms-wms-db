CREATE TABLE [dbo].[TMS_TransportOrder]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[ProvShipmentID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderReleaseID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderSourceID] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClientReferenceID] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBOLkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentSourceID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SplitFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Principal] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Country] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FacilityID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StopSeq] [int] NULL,
[IOIndicator] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StopServiceTime] [int] NULL,
[OrderVolume] [numeric] (24, 6) NULL,
[OrderWeight] [numeric] (24, 6) NULL,
[OrderCartonCount] [int] NULL,
[OrderPalletCount] [int] NULL,
[PickPriority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TMS_TransportOrder_Addwho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_TMS_TransportOrder_AddDate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TMS_TransportOrder_Editwho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_TMS_TransportOrder_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMS_TransportOrder] ADD CONSTRAINT [PKTMS_TransportOrder] PRIMARY KEY CLUSTERED ([Rowref]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMS_TransportOrder] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TMS_TransportOrder] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TMS_TransportOrder] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TMS_TransportOrder] TO [NSQL]
GO
