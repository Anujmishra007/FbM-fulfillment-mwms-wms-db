-- On STAGE use [GLOWMS]
-- On PROD use [DNKWMS]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Stored Procedure: isp_GetMCSHospitalLocation                              */
/* Creation Date: 30-04-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: VMA237                                                        */
/*                                                                           */
/* Purpose : Return Hospital routing location for MCS integration fallback.  */
/*                                                                           */
/* Called By: MCS Integration (Inbound Pallet Dimensions Processing)         */
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purpose                                        */
/* 30-04-2026   VMA237   1.0  Initial version created                        */
/*****************************************************************************/
CREATE OR ALTER   PROC [dbo].[isp_GetMCSHospitalLocation]
(
    @cScanLocation    NVARCHAR(50),
    @ToLoc            NVARCHAR(50) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET ANSI_NULLS OFF
    SET QUOTED_IDENTIFIER OFF
    SET CONCAT_NULL_YIELDS_NULL OFF
    SET ANSI_WARNINGS ON

    -- Default output value
    SET @ToLoc = 'Hospital';

    BEGIN TRY

        -- Get Hospital location based on scan location configuration
        SELECT TOP 1
            @ToLoc = ISNULL(NULLIF(cdl.UDF01, ''), 'Hospital')
        FROM CODELKUP cdl (NOLOCK)
        WHERE cdl.LISTNAME = 'MCSRoutLoc'
          AND cdl.Code = @cScanLocation
          AND ISNULL(cdl.StorerKey, '') = CASE 
                WHEN EXISTS (
                    SELECT 1
                    FROM V_CODELKUP (NOLOCK)
                    WHERE LISTNAME = 'MCSRoutLoc'
                      AND Code = @cScanLocation
                      AND StorerKey = 'ARLA'
                )
                THEN 'ARLA'
                ELSE ''
          END;

        -- If configuration is missing or empty, keep default Hospital value
        SET @ToLoc = ISNULL(NULLIF(@ToLoc, ''), 'Hospital');

        RETURN;

    END TRY
    BEGIN CATCH
        -- In case of any SQL error, return default Hospital location
        SET @ToLoc = 'Hospital';
        RETURN;
    END CATCH
END
GO