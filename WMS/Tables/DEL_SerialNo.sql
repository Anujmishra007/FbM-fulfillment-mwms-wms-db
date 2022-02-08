CREATE TABLE [dbo].[DEL_SerialNo]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[SerialNoKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NULL CONSTRAINT [DF_DEL_SerialNo_Qty] DEFAULT ((0)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_SerialNo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_DEL_SerialNo_AddDate] DEFAULT (getdate()),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_SerialNo_Status] DEFAULT ('0'),
[LotNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DEL_SerialNo] ADD CONSTRAINT [PK__DEL_SerialNo__7DE6B1EE] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DEL_SerialNo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DEL_SerialNo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DEL_SerialNo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DEL_SerialNo] TO [NSQL]
GO
