IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE table_name = 'QRCODE' and table_schema= 'dbo' )
BEGIN
CREATE TABLE QRCODE
( RowRef [int] IDENTITY(1,1) NOT NULL,
  QRCode nvarchar(60) not null constraint DF_QRCODE_QRCode default (''),
  StorerKey nvarchar(15) not null constraint DF_QRCODE_StorerKey default ('') ,
  [Description] nvarchar(250) null constraint DF_QRCODE_Description default (''),
  UDF01 nvarchar(60) null constraint DF_QRCODE_UDF01 default (''),
  UDF02 nvarchar(60) null constraint DF_QRCODE_UDF02 default (''),
  UDF03 nvarchar(60) null constraint DF_QRCODE_UDF03 default (''),
  UDF04 nvarchar(60) null constraint DF_QRCODE_UDF04 default (''),
  UDF05 nvarchar(60) null constraint DF_QRCODE_UDF05 default (''),
  AddDate datetime not null constraint DF_QRCODE_AddDate default (getdate()),
  AddWho  nvarchar(128) not null constraint DF_QRCODE_AddWho default (suser_name()),
  EditDate datetime not null constraint DF_QRCODE_EditDate default (getdate()),
  EditWho nvarchar(128) not null constraint DF_QRCODE_EditWho default (suser_name()),
  TrafficCop nvarchar(1) null ,
  ArchiveCop nvarchar(1) null,
   CONSTRAINT [PK_QRCODE] PRIMARY KEY CLUSTERED 
(
	QRCode ASC, StorerKey ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
END

GRANT SELECT, INSERT, UPDATE, DELETE ON QRCODE to nsql
GO


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Row Reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'RowRef'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'QR Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'QRCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Storer/seller of the products being shipped (Owner of the goods)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'Storerkey'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User defined field 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'UDF01'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User defined field 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'UDF02'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User defined field 3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'UDF03'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User defined field 4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'UDF04'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User defined field 5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'UDF05'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'AddDate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'AddDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'AddWho' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'AddWho'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'EditDate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'EditDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'EditWho' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'EditWho'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'TrafficCop' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'TrafficCop'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ArchiveCop' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QRCODE', @level2type=N'COLUMN',@level2name=N'ArchiveCop'
GO