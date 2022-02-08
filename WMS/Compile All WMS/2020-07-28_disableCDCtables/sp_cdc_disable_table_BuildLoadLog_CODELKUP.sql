IF EXISTS (SELECT * FROM sys.tables WHERE name='BuildLoadLog' AND is_tracked_by_cdc = 1)
BEGIN
   EXEC sp_cdc_disable_table 'dbo', 'BuildLoadLog', 'dbo_BuildLoadLog';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name='CODELKUP' AND is_tracked_by_cdc = 1)
BEGIN
   EXEC sp_cdc_disable_table 'dbo', 'CODELKUP'    , 'dbo_CODELKUP';
END
