IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.tables where table_schema = 'rdt' AND table_name = 'rdtPTLPieceLog_Log' )
BEGIN
exec sp_rename 'rdt.DF_rdtPTLPieceLog_Log_DelDate' , 'DF_rdtPTLPieceLog_DEL_DelDate'
exec sp_rename 'rdt.DF_rdtPTLPieceLog_Log_DelWho' , 'DF_rdtPTLPieceLog_DEL_DelWho'
exec sp_rename 'rdt.PK_rdtPTLPieceLog_Log' , 'PK_rdtPTLPieceLog_DEL'
exec sp_rename 'rdt.rdtPTLPieceLog_Log' , 'rdtPTLPieceLog_DEL'
END
GO


