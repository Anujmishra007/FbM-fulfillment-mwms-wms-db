SET NOCOUNT ON
GO
IF NOT EXISTS ( SELECT 1 
                FROM dbo.CODELIST AS c WITH (NOLOCK) 
                WHERE Listname = 'SHORTREPL' )
BEGIN
   INSERT INTO CODELIST ([LISTNAME], [DESCRIPTION])
   VALUES
   ( N'SHORTREPL', N'Additional Configuration for Short Replenishment' )
END