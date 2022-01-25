 

  /*  reset seq to current value
 
 SELECT NEXT VALUE FOR dbo.[LogEvent] 

ALTER SEQUENCE LogEvent INCREMENT BY 2546071;
 
 SELECT NEXT VALUE FOR dbo.[LogEvent] 
 
ALTER SEQUENCE LogEvent INCREMENT BY 1;


*/ 

--   SELECT * from ncounter (NOLOCK) WHERE keyname = 'LogEvent'


CREATE SEQUENCE dbo.[LogEvent] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 0
 MAXVALUE 9999989999
 CYCLE
 CACHE 50
GO

grant Update on dbo.[LogEvent]  to NSQL

/*
SELECT current_value, * FROM sys.sequences WHERE name = 'LogEvent' ;

 
 


*/
