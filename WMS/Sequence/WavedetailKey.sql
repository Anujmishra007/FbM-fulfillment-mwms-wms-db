 

  /*  reset seq to current value
 
 SELECT NEXT VALUE FOR dbo.[WavedetailKey] 

ALTER SEQUENCE WavedetailKey INCREMENT BY 573086;
 
 SELECT NEXT VALUE FOR dbo.[WavedetailKey] 
 
ALTER SEQUENCE WavedetailKey INCREMENT BY 1;


*/ 
 

--   SELECT * from ncounter (NOLOCK) WHERE keyname = 'WavedetailKey'


CREATE SEQUENCE dbo.[WavedetailKey] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 0
 MAXVALUE 9999989999
 CYCLE
 CACHE 50
GO

grant Update on dbo.[WavedetailKey]  to NSQL

/*
SELECT current_value, * FROM sys.sequences WHERE name = 'WavedetailKey' ;


SELECT TOP 100 * FROM [WavedetailKey] Order by adddate
 


*/
