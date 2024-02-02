IF NOT EXISTS (SELECT 1 FROM CODELIST (NOLOCK) WHERE ListName = 'ASNStatChk')      --UWP-14379 
BEGIN 
   INSERT INTO CODELIST (LISTNAME, Description, Type)
   VALUES ( 'ASNStatChk', 'Disallow Change ASNStatus from and To', 'Validation')
END

IF NOT EXISTS (SELECT 1 FROM Codelkup  (NOLOCK) WHERE ListName = 'ASNStatChk'      --UWP-14379 
               AND Code ='00001')
BEGIN 
   INSERT INTO CODELKUP (LISTNAME, Code, Description, UDF01, UDF02, UDF03, Storerkey)
   VALUES ( 'ASNStatChk', '00001', 'Disallow change ASNStatus from ''1'' to ''0'''
          , '', '1', '0', '')
END
