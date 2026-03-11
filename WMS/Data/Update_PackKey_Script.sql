BEGIN TRANSACTION;

DECLARE @BatchSize INT = 100;
DECLARE @RowsAffected INT = 1;
DECLARE @Counter INT = 0;

WHILE (@RowsAffected > 0 AND @Counter < 1000)
BEGIN

    ;WITH cte AS
              (
                  SELECT TOP (@BatchSize) P.PackKey
                  FROM PACK AS P WITH (ROWLOCK, READPAST)
     WHERE P.PackKey LIKE 'ON%'
       AND P.WidthUOM2 = 0
       AND (round(lengthUOM1*widthuom1*heightuom1,4)<>cubeUOM1 or round(lengthUOM3*widthuom3*heightuom3,4)<>cubeUOM3)
     ORDER BY P.PackKey
         )

UPDATE P
SET P.WidthUOM2 = 1
    FROM PACK P
    JOIN cte ON P.PackKey = cte.PackKey;

SET @RowsAffected = @@ROWCOUNT;
	SET @Counter = @Counter + 1;

    PRINT 'Rows Updated in this batch: ' + CAST(@RowsAffected AS VARCHAR);

END

-- Check results before committing
COMMIT TRANSACTION;

-- If testing
--ROLLBACK TRANSACTION;