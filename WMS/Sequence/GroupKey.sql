-- GroupKey

--  SELECT  top 10 * FROM nCounter where keyname  = 'GroupKey'
 
 
IF NOT EXISTS ( SELECT 1 FROM sys.sequences WHERE name = 'GroupKey' ) 
AND NOT EXISTS ( SELECT 1 FROM nCounter WHERE keyname  = 'GroupKey' ) 
BEGIN
CREATE SEQUENCE dbo.[GroupKey] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 9999999999 
 CYCLE
 CACHE 50
 GRANT UPDATE ON dbo.[GroupKey] TO NSQL 

END
GO
 


/*

 SELECT NEXT VALUE FOR dbo.[GroupKey] 

ALTER SEQUENCE GroupKey INCREMENT BY 53;
 
 SELECT NEXT VALUE FOR dbo.[GroupKey] 
 
ALTER SEQUENCE GroupKey  INCREMENT BY 1;

*/
/*
SELECT current_value, * FROM sys.sequences WHERE name = 'GroupKey' ;
 
*/
