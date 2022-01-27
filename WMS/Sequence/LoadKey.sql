--  Select * from ncounter  (NOLOCK) where keyname = 'loadkey'

---    ALTER SEQUENCE LoadKey RESTART WITH 2747455 ;  

--   SELECT NEXT VALUE FOR dbo.[LoadKey]   



CREATE SEQUENCE dbo.[LoadKey] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 9999999999
 CYCLE
 CACHE 100
GO

grant update on dbo.[LoadKey]  to NSQL


