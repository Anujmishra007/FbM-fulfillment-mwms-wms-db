IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.tables where table_schema = 'dbo' AND table_name = 'RFPUTAWAY_DELLOG' )
BEGIN
exec sp_rename 'dbo.DF_RFPutaway_DELLOG_DelDate' , 'DF_RFPutaway_DEL_DelDate'
exec sp_rename 'dbo.DF_RFPutaway_DELLOG_DelWho' , 'DF_RFPutaway_DEL_DelWho'
exec sp_rename 'dbo.DF_RFPutaway_DELLOG_ReceiptKey' , 'DF_RFPutaway_DEL_ReceiptKey'
exec sp_rename 'dbo.DF_RFPutaway_DELLOG_ReceiptLineNumber' , 'DF_RFPutaway_DEL_ReceiptLineNumber'
exec sp_rename 'dbo.DF_RFPutaway_DELLOG_UDF01' , 'DF_RFPutaway_DEL_UDF01'
exec sp_rename 'dbo.DF_RFPutaway_DELLOG_UDF02' , 'DF_RFPutaway_DEL_UDF02'
exec sp_rename 'dbo.DF_RFPutaway_DELLOG_UDF03' , 'DF_RFPutaway_DEL_UDF03'
exec sp_rename 'dbo.RFPUTAWAY_DELLOG' , 'RFPUTAWAY_DEL'
END
GO
