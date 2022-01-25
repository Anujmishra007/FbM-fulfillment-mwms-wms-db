 

 
---    ALTER SEQUENCE OPRUN RESTART WITH 27435652 ;  

--   SELECT NEXT VALUE FOR dbo.[OPRUN]  

--   SELECT * from ncounter (NOLOCK) WHERE keyname = 'OPRUN'

CREATE SEQUENCE dbo.[OPRUN] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 0
 MAXVALUE 9999989999
 CYCLE
 CACHE 50
GO

grant Update on dbo.[OPRUN]  to NSQL

/*
SELECT current_value, * FROM sys.sequences WHERE name = 'OPRUN' ;


SELECT TOP 100 * FROM [OPRUN] Order by adddate
 


*/
