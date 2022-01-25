-- Packkey_BWS

--  SELECT  top 10 * FROM Ncounter where keyname  = 'Packkey_BWS'
 

IF NOT EXISTS ( SELECT 1 FROM sys.sequences WHERE name = 'Packkey_BWS' ) 
AND NOT EXISTS ( SELECT 1 FROM Ncounter where keyname  = 'Packkey_BWS') 
BEGIN
CREATE SEQUENCE dbo.[Packkey_BWS] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 9999989999
 CYCLE
 CACHE 50
 
grant Update on dbo.[Packkey_BWS]  to NSQL

END
GO
 


/*

 SELECT NEXT VALUE FOR dbo.[Packkey_BWS] 

ALTER SEQUENCE Packkey_BWS INCREMENT BY 30173935;
 
 SELECT NEXT VALUE FOR dbo.[Packkey_BWS] 
 
ALTER SEQUENCE Packkey_BWS  INCREMENT BY 1;

*/
/*
SELECT current_value, * FROM sys.sequences WHERE name = 'Packkey_BWS' ;
 
*/
