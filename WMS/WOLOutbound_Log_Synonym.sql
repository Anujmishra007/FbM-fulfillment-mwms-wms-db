DECLARE @DTSDB nvarchar (25) , @WMSDB nvarchar (25)
,@SQL nvarchar (4000)

DECLARE CUR CURSOR READ_ONLY FAST_FORWARD FOR
SELECT name,  replace (name, 'WMS', 'DTSITF')
FROM sys.databases a
where name like '%WMS%'

    OPEN CUR
FETCH NEXT FROM CUR INTO @WMSDB,@DTSDB
    WHILE @@FETCH_STATUS = 0
BEGIN

IF EXISTS (SELECT * FROM sys.databases where name = @DTSDB)
BEGIN
SET @SQL = N'USE [' + @WMSDB + ']' + char(13) +
'IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name like ''%WOLOutbound_Log%'')
  BEGIN
  CREATE SYNONYM [DTS].[WOLOutbound_Log] FOR ['+ @DTSDB + '].[dbo].[WOLOutbound_Log]
  END
 '
EXEC (@SQL)
END

FETCH NEXT FROM CUR INTO @WMSDB,@DTSDB
END
CLOSE CUR
    DEALLOCATE CUR