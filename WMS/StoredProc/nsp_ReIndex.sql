if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nsp_ReIndex]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nsp_ReIndex]
GO

CREATE PROC nsp_ReIndex
AS
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
DECLARE @vcTableName nvarchar(50), @max tinyint

DECLARE cur CURSOR FAST_FORWARD READ_ONLY FOR
SELECT vcTableName FROM indexes ORDER BY nmPriority ASC
OPEN cur
FETCH NEXT FROM cur INTO @vcTableName
WHILE @@FETCH_STATUS = 0
BEGIN
	
	EXEC ('DBCC DBREINDEX (N''' + @vcTableName + ''') WITH NO_INFOMSGS')
	SELECT @max=MAX(nmPriority) FROM indexes
	UPDATE indexes SET nmPriority = @max, dtLastUpdated = getDate() WHERE vcTableName = @vcTableName
	UPDATE indexes SET nmPriority = nmPriority - 1 WHERE vcTableName NOT IN (@vcTableName)
	
	FETCH NEXT FROM cur INTO @vcTableName

END
CLOSE cur
DEALLOCATE cur
SET NOCOUNT OFF
/*
Final result

A 1 	4 3 2 1
B 2 	1 4 3 2
C 3 	2 1 4 3
D 4 	3 2 1 4
*/
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

