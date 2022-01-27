
--  Select * from ncounter  (NOLOCK) where keyname = 'BatchNo'

---    ALTER SEQUENCE batchno RESTART WITH 110408 ;  

--   SELECT NEXT VALUE FOR dbo.[BatchNo]   



CREATE SEQUENCE dbo.[BatchNo] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 CYCLE
 CACHE 100
GO

grant update on dbo.[BatchNo]  to NSQL


