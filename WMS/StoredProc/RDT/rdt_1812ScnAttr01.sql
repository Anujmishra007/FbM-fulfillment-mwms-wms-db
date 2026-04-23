SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store procedure: rdt_1812ScnAttr01                                   */
/* Purpose: Add color display                                           */
/* Customer: ONBR                                                       */
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2026-04-16 1.0  Sreeja     FCR-12393. Location-based color coding    */
/************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_1812ScnAttr01] (
   @nMobile          INT,
   @nFunc            INT,
   @nScn             INT,
   @cY               NVARCHAR(  2),
   @cStorerKey       NVARCHAR( 15),
   @cSValueSP        NVARCHAR( MAX) OUTPUT
)  
AS  

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

/* Screen 4021 (From LOC):
   ,@cLine07 = 'FROM LOC:'
   ,@cLine08 = '%10d03'    -- y=8, display SuggFromLoc
   ,@cLine09 = '%20i04'    -- input field
 */

IF @nFunc = 1812
BEGIN

    DECLARE @suggestLoc NVARCHAR(10)

    -- Get SuggFromLoc from V_LOC
    SELECT @suggestLoc = V_LOC
    FROM rdt.rdtMobrec WITH (NOLOCK)
    WHERE Mobile = @nMobile

    -- Screen 4021 = From LOC screen
    IF @nScn = 4021
    BEGIN
        -- Line 8 = FROM LOC display field (%10d03)
        IF @cY = 8
        BEGIN
            SELECT TOP 1 @cSValueSP = ISNULL(ColorCode,'')
            FROM LOC (NOLOCK) WHERE LOC = @suggestLoc
            GOTO QUIT
        END
    END
    -- For all other screens/lines (including DROPID), return empty to prevent color attribute
    SET @cSValueSP = ''
END
  
QUIT:  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1812ScnAttr01 TO NSQL
GO
  

