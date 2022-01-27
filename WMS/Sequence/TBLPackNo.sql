-- TBLPackNo

--  SELECT  top 10 * FROM Ncounter where keyname  = 'TBLPackNo'
 

IF NOT EXISTS ( SELECT 1 FROM sys.sequences WHERE name = 'TBLPackNo' ) 
AND NOT EXISTS ( SELECT 1 FROM Ncounter where keyname  = 'TBLPackNo' ) 
BEGIN
CREATE SEQUENCE dbo.[TBLPackNo] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 9999989999
 CYCLE
 CACHE 50
 
grant Update on dbo.[TBLPackNo]  to NSQL

END
GO
 


/*

 SELECT NEXT VALUE FOR dbo.[TBLPackNo] 

ALTER SEQUENCE TBLPackNo INCREMENT BY 53;
 
 SELECT NEXT VALUE FOR dbo.[TBLPackNo] 
 
ALTER SEQUENCE TBLPackNo  INCREMENT BY 1;

*/
/*
SELECT current_value, * FROM sys.sequences WHERE name = 'TBLPackNo' ;
 
*/
