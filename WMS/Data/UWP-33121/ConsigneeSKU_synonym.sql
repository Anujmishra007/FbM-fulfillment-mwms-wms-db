DECLARE @DTSDB nvarchar (25) , @WMSDB nvarchar (25)
,@SQL nvarchar (4000)

DECLARE CUR CURSOR READ_ONLY FAST_FORWARD FOR
SELECT name,  replace (name, 'DTSITF', 'WMS')
FROM sys.databases a
where name like '%DTSITF%'

OPEN CUR
FETCH NEXT FROM CUR INTO @DTSDB ,@WMSDB
WHILE @@FETCH_STATUS = 0
BEGIN

IF EXISTS (SELECT * FROM sys.databases where name = @WMSDB)
BEGIN
SET @SQL = N'USE [' + @DTSDB + ']' + char(13) +
'IF EXISTS (SELECT * FROM sys.synonyms WHERE name = ''ConsigneeSKU'') 
 BEGIN 
   Print ''Synonyms ConsigneeSKU is exist in ''''' + @DTSDB + ''''' ''' + char(13) +
 'END
  ELSE
  BEGIN
  Print  ''Not exist and Create the Synonyms ConsigneeSKU''
  CREATE SYNONYM [WMS].[ConsigneeSku] FOR ['+ @WMSDB + '].[dbo].[ConsigneeSku]
  END
 '
EXEC (@SQL)
END

FETCH NEXT FROM CUR INTO @DTSDB ,@WMSDB
END
CLOSE CUR
DEALLOCATE CUR

