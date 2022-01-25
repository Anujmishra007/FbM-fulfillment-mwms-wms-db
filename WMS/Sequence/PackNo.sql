 

 
---    ALTER SEQUENCE PackNo RESTART WITH 18078051 ;  

--   SELECT NEXT VALUE FOR dbo.[PackNo]  

--   SELECT * from ncounter (NOLOCK) WHERE keyname = 'PackNo'


CREATE SEQUENCE dbo.[PackNo] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 0
 MAXVALUE 9999989999
 CYCLE
 CACHE 50
GO

grant Update on dbo.[PackNo]  to NSQL

/*
SELECT current_value, * FROM sys.sequences WHERE name = 'PackNo' ;


SELECT TOP 100 * FROM [PackNo] Order by adddate
 


*/
