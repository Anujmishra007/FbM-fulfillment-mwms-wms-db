IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TMS_TransportOrder]') AND type in (N'U'))
BEGIN

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
[EditDate] [datetime] NULL CONSTRAINT [DF_TMS_TransportOrder_EditDate] DEFAULT (getdate()),
[ArchiveCop] [nvarchar](1) NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[TMS_TransportOrder] ADD CONSTRAINT [PKTMS_TransportOrder] PRIMARY KEY CLUSTERED ([Rowref]) ON [PRIMARY]


GRANT DELETE ON  [dbo].[TMS_TransportOrder] TO [NSQL]
GRANT INSERT ON  [dbo].[TMS_TransportOrder] TO [NSQL]
GRANT SELECT ON  [dbo].[TMS_TransportOrder] TO [NSQL]
GRANT UPDATE ON  [dbo].[TMS_TransportOrder] TO [NSQL]

END

ELSE
BEGIN

    IF NOT EXISTS (SELECT 1
    FROM sys.columns
    WHERE Name = 'ArchiveCop' AND Object_ID = Object_ID('TMS_TransportOrder'))
	BEGIN
        ALTER TABLE dbo.TMS_TransportOrder ADD ArchiveCop [nvarchar](1) NULL;
		EXEC sp_addextendedproperty N'MS_Description', 'ArchiveCop', 'SCHEMA', N'dbo', 'TABLE', N'TMS_TransportOrder', 'COLUMN', N'ArchiveCop'


    END
END