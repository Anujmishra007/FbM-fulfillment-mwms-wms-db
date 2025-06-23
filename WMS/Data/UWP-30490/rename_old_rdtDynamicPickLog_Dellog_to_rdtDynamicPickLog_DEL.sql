IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.tables where table_schema = 'rdt' AND table_name = 'RDTDynamicPickLog_DELLOG' )
BEGIN
exec sp_rename 'rdt.DF_RDTDynamicPickLog_DELLOG_DelDate' , 'DF_RDTDynamicPickLog_DEL_DelDate'
exec sp_rename 'rdt.DF_RDTDynamicPickLog_DELLOG_DelWho' , 'DF_RDTDynamicPickLog_DEL_DelWho'
exec sp_rename 'rdt.RDTDynamicPickLog_DELLOG' , 'RDTDynamicPickLog_DEL'

alter table rdt.RDTDynamicPickLog_DEL add constraint PK_RDTDynamicPickLog_DEL primary key(RowRef)
END
GO

