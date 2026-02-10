-- WorkOrderSeqKey
 
Declare @n_current_keycount INT = 0

DECLARE @c_SQL nvarchar(1000) = ''

IF NOT EXISTS ( SELECT 1 FROM sys.sequences WHERE name = 'WorkOrderSeqKey' )  
BEGIN
CREATE SEQUENCE dbo.[WorkOrderSeqKey] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 9999999999 
 CYCLE
 CACHE 50
 
 GRANT UPDATE ON dbo.[WorkOrderSeqKey] TO NSQL 

   SELECT  @n_current_keycount = keycount FROM nCounter (NOLOCK) where keyname  = 'WorkOrder' 

   IF @n_current_keycount is NULL
     SET @n_current_keycount = 0


  SELECT NEXT VALUE FOR dbo.[WorkOrderSeqKey] 
  
  IF @n_current_keycount > 1
  BEGIN

      SET @c_SQL = N'ALTER SEQUENCE WorkOrderSeqKey INCREMENT BY ' +  cast( @n_current_keycount as Nvarchar ) + ';'

      EXEC sp_executesql @c_SQL, N'@n_current_keycount INT', @n_current_keycount = @n_current_keycount;
   END

 
   SELECT NEXT VALUE FOR dbo.[WorkOrderSeqKey] 
 
   ALTER SEQUENCE WorkOrderSeqKey  INCREMENT BY 1;

END 
  
  --   SELECT name, current_value FROM sys.sequences WHERE name = 'WorkOrderSeqKey'
  --   drop sequence WorkOrderSeqKey