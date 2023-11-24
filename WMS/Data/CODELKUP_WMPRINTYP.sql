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

      