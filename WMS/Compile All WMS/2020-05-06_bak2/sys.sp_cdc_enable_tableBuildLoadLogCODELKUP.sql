/*
IF EXISTS (SELECT 1 FROM sys.tables WHERE is_tracked_by_cdc=0 AND name= N'BuildLoadLog' AND SCHEMA_NAME(schema_id)='dbo')
BEGIN
   EXEC sys.sp_cdc_enable_table @source_schema = N'dbo', @source_name = N'BuildLoadLog', @role_name = NULL;
END

IF EXISTS (SELECT 1 FROM sys.tables WHERE is_tracked_by_cdc=0 AND name= N'CODELKUP' AND SCHEMA_NAME(schema_id)='dbo')
BEGIN
   EXEC sys.sp_cdc_enable_table @source_schema = N'dbo', @source_name = N'CODELKUP', @role_name = NULL;
END
*/