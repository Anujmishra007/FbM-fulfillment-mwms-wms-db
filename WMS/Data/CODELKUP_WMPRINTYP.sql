IF EXISTS (SELECT 1 FROM dbo.CODELKUP AS c WITH (NOLOCK) WHERE listname = 'WMPrintTyp'
               AND Code = 'ITFDOC')
BEGIN
   UPDATE CODELKUP WITH (ROWLOCK)
   SET UDF01 = 'PrintByCPC' 
   WHERE listname = 'WMPrintTyp'
   AND Code = 'ITFDOC'
END 
   
IF EXISTS (SELECT 1 FROM dbo.CODELKUP AS c WITH (NOLOCK) WHERE listname = 'WMPrintTyp'
               AND Code = 'ZPL')
BEGIN
   UPDATE CODELKUP WITH (ROWLOCK)
   SET UDF01 = 'PrintByCPC' 
   WHERE listname = 'WMPrintTyp'
   AND Code = 'ZPL'
END 


IF EXISTS (SELECT 1 FROM dbo.CODELKUP AS c WITH (NOLOCK) WHERE listname = 'WMPrintTyp'
               AND Code = 'Logireport')
BEGIN
   UPDATE CODELKUP WITH (ROWLOCK)
   SET UDF01 = 'PrintByCPC' 
   WHERE listname = 'WMPrintTyp'
   AND Code = 'Logireport'
END 

IF NOT EXISTS ( SELECT 1 
                FROM dbo.CODELIST AS c WITH (NOLOCK) 
                WHERE Listname = 'WMPrintTyp' )
BEGIN
   INSERT INTO CODELIST ([LISTNAME], [DESCRIPTION])
   VALUES
   ( N'WMPrintTyp', N'WM Print Type' )
END

IF NOT EXISTS ( SELECT 1 
                FROM dbo.CODELKUP AS c WITH (NOLOCK) 
                WHERE Listname = 'WMPrintTyp'
                AND Code = 'Logireport'
                AND Code2 = 'LOGIReportBE' )
BEGIN
   INSERT INTO CODELKUP ([LISTNAME], [Code], [Description], [Short], [Long], [UDF01], [Code2])
   VALUES
   ( N'WMPrintTyp', N'LOGIReport', N'Web Report Backend', N'JreportBE', N'LOGIReportBE', N'PrintByCPC', N'LOGIReportBE' )
END