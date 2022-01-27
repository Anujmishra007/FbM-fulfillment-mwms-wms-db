 

 
---    ALTER SEQUENCE ANFLabelNo RESTART WITH 1759347 ;  

--   SELECT NEXT VALUE FOR dbo.[ANFLabelNo]  

--   SELECT * from ncounter (NOLOCK) WHERE keyname = 'ANFLabelNo'

CREATE SEQUENCE dbo.[ANFLabelNo] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 0
 MAXVALUE 9999989999
 CYCLE
 CACHE 50
GO

grant Update on dbo.[ANFLabelNo]  to NSQL

/*
SELECT current_value, * FROM sys.sequences WHERE name = 'ANFLabelNo' ;


SELECT TOP 100 * FROM [ANFLabelNo] Order by adddate
 


*/
