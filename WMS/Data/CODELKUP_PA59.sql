 IF NOT EXISTS(SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK) WHERE LISTNAME='PALSTREST' AND Code='17')
 BEGIN
    INSERT INTO dbo.CODELKUP
   (
       LISTNAME,
       Code,
       Description,
       Short,
       Long,
       Notes
   )
   VALUES
   (   N'PALSTREST ',     -- LISTNAME - nvarchar(10)
       N'17',     -- Code - nvarchar(30)
       'Macthing Lottable02 with HostWHCode',    -- Description - nvarchar(250)
       '',    -- Short - nvarchar(10)
       '',    -- Long - nvarchar(250)
       ''    -- Notes - nvarchar(4000)
       )     
 END

