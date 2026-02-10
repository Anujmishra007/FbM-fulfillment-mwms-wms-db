-- MPOC

DECLARE @n_current_keycount INT = 0

DECLARE @c_SQL NVARCHAR(1000) = N''

IF NOT EXISTS (  SELECT 1
                 FROM sys.sequences
                 WHERE name = 'MPOC')
BEGIN
   CREATE SEQUENCE dbo.[MPOC]
   AS [BIGINT]
   START WITH 1
   INCREMENT BY 1
   MINVALUE 1
   MAXVALUE 999999999
   CYCLE
   CACHE 50

   GRANT UPDATE ON dbo.[MPOC] TO NSQL

   SELECT @n_current_keycount = keycount
   FROM NCOUNTER (NOLOCK)
   WHERE keyname = 'MPOC'

   IF @n_current_keycount IS NULL
      SET @n_current_keycount = 0


   SELECT NEXT VALUE FOR dbo.[MPOC]

   IF @n_current_keycount > 1
   BEGIN

      SET @c_SQL = N'ALTER SEQUENCE MPOC INCREMENT BY ' + CAST(@n_current_keycount AS NVARCHAR) + N';'

      EXEC sp_executesql @c_SQL
                       , N'@n_current_keycount INT'
                       , @n_current_keycount = @n_current_keycount;
   END


   SELECT NEXT VALUE FOR dbo.[MPOC]

   ALTER SEQUENCE MPOC INCREMENT BY 1;

END

--   SELECT name, current_value FROM sys.sequences WHERE name = 'MPOC'
--   drop sequence MPOC