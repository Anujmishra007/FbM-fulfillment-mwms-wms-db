 

 
  /*  reset seq to current value
 
 SELECT NEXT VALUE FOR dbo.[CCDetailKey] 

ALTER SEQUENCE CCDetailKey INCREMENT BY 63595260;
 
 SELECT NEXT VALUE FOR dbo.[CCDetailKey] 
 
ALTER SEQUENCE CCDetailKey INCREMENT BY 1;


*/ 

--   SELECT * from ncounter (NOLOCK) WHERE keyname = 'CCDetailKey'


CREATE SEQUENCE dbo.[CCDetailKey] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 0
 MAXVALUE 9999989999
 CYCLE
 CACHE 50
GO

grant Update on dbo.[CCDetailKey]  to NSQL

/*
SELECT current_value, * FROM sys.sequences WHERE name = 'CCDetailKey' ;

 


*/
