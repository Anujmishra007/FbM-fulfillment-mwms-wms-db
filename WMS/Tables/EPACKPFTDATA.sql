IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPACKPFTDATA]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[EPACKPFTDATA]
(
[RowRef] [bigint] NOT NULL IDENTITY(1, 1),
[TaskBatchNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderMode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cartonno] [int] NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [float] NULL,
[PackConfirm] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EPACKPFTDATA_PackConfirm] DEFAULT ('N'),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EPACKPFTDATA_Status] DEFAULT ('0'),
[LoginID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EPACKPFTDATA_LoginID] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_EPACKPFTDATA_AddDate] DEFAULT (getdate()),
[EditDate] [datetime] NULL CONSTRAINT [DF_EPACKPFTDATA_EditDate] DEFAULT (getdate()),
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EPACKPFTDATA_SerialNo] DEFAULT (''),
[QRCode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EPACKPFTDATA_QRCode] DEFAULT (''),
[AppType] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EPACKPFTDATA_AppType] DEFAULT (''),
[ComputerName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EPACKPFTDATA_ComputerName] DEFAULT ('')
) ON [PRIMARY]

ALTER TABLE [dbo].[EPACKPFTDATA] ADD CONSTRAINT [PK_EPACKPFTDATA] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]

GRANT DELETE ON  [dbo].[EPACKPFTDATA] TO [NSQL]

GRANT INSERT ON  [dbo].[EPACKPFTDATA] TO [NSQL]

GRANT SELECT ON  [dbo].[EPACKPFTDATA] TO [NSQL]

GRANT UPDATE ON  [dbo].[EPACKPFTDATA] TO [NSQL]

EXEC sp_addextendedproperty N'MS_Description', N'Ecom Packing Simulation Test Data', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', NULL, NULL

EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'AddDate'

EXEC sp_addextendedproperty N'MS_Description', N'Pack Carton #', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'Cartonno'

EXEC sp_addextendedproperty N'MS_Description', N'Carton Type', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'CartonType'

EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'EditDate'

EXEC sp_addextendedproperty N'MS_Description', N'User who login and execute the ECOM Packing simulation test', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'LoginID'

EXEC sp_addextendedproperty N'MS_Description', N'Shipment Order #', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'Orderkey'

EXEC sp_addextendedproperty N'MS_Description', N'Pack Task Order mode; Single/Multi', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'OrderMode'

EXEC sp_addextendedproperty N'MS_Description', N'Pack confirm instruction to simulator', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'PackConfirm'

EXEC sp_addextendedproperty N'MS_Description', N'Carton Tracking #', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'RefNo'

EXEC sp_addextendedproperty N'MS_Description', N'Record Reference No', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'RowRef'

EXEC sp_addextendedproperty N'MS_Description', N'Serial #', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'SerialNo'

EXEC sp_addextendedproperty N'MS_Description', N'Sku', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'Sku'

EXEC sp_addextendedproperty N'MS_Description', N'Simulation Test Status', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'Status'

EXEC sp_addextendedproperty N'MS_Description', N'Pack task Batch #', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'TaskBatchNo'

EXEC sp_addextendedproperty N'MS_Description', N'Carton Weight', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'Weight'

END

ELSE 
BEGIN 

--ADD COLUMN
        IF NOT EXISTS (SELECT *
                FROM sys.columns
                WHERE Name = 'AppType'
                    AND Object_ID = Object_ID('[dbo].[EPACKPFTDATA]'))
        BEGIN
            ALTER TABLE [dbo].[EPACKPFTDATA]
             ADD [AppType] [nvarchar](30) NULL CONSTRAINT [DF_EPACKPFTDATA_AppType] DEFAULT ('');
			 EXEC sp_addextendedproperty N'MS_Description', 'AppType', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'AppType'

        END

--ADD COLUMN
        IF NOT EXISTS (SELECT *
                FROM sys.columns
                WHERE Name = 'ComputerName'
                    AND Object_ID = Object_ID('[dbo].[EPACKPFTDATA]'))
        BEGIN
            ALTER TABLE [dbo].[EPACKPFTDATA]
             ADD [ComputerName] [nvarchar](50) NULL CONSTRAINT [DF_EPACKPFTDATA_ComputerName] DEFAULT ('');
			 EXEC sp_addextendedproperty N'MS_Description', 'ComputerName', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'ComputerName'

        END



END
