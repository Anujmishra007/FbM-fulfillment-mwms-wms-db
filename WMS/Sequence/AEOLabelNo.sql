 

  /*  reset seq to current value
 
 SELECT NEXT VALUE FOR dbo.[AEOLabelNo] 

ALTER SEQUENCE AEOLabelNo INCREMENT BY 10000;
 
 SELECT NEXT VALUE FOR dbo.[AEOLabelNo] 
 
ALTER SEQUENCE AEOLabelNo INCREMENT BY 1;


*/ 

--   SELECT * from ncounter (NOLOCK) WHERE keyname = 'AEOLabelNo'


CREATE SEQUENCE dbo.[AEOLabelNo] 
 AS [BIGINT]
 START WITH 2000000001
 INCREMENT BY 1
 MINVALUE 2000000001
 MAXVALUE 9999989999
 CYCLE
 CACHE 50
GO

grant Update on dbo.[AEOLabelNo]  to NSQL

/*
SELECT current_value, * FROM sys.sequences WHERE name = 'AEOLabelNo' ;


SELECT TOP 100 * FROM [AEOLabelNo] Order by adddate
 


*/
