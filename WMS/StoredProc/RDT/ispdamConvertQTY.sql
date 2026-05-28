SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store procedure: ispdamConvertQTY                                    */
/*                                                                      */
/* Purpose: Convert system QTY to and from display QTY                  */
/*                                                                      */
/* Date        Rev   Author     Purposes                                */
/* 2026-05-18  1.0   Dennis     FCR-11167                               */
/************************************************************************/
CREATE OR ALTER PROCEDURE [RDT].[ispdamConvertQTY] (
    @cStorerKey NVARCHAR(15),
    @cSKU       NVARCHAR(20),
    @nQTY       INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables
    DECLARE @cBUSR2 NVARCHAR(30),
            @nBUSR2 INT;

    -- Get SKU info
    SELECT @cBUSR2 = BUSR2
    FROM dbo.SKU WITH (NOLOCK)
    WHERE StorerKey = @cStorerKey
      AND SKU = @cSKU;

    -- Validation
    IF ISNULL(@cBUSR2, '') = '' OR @cBUSR2 = '0'
        RETURN;

    -- Convert to INT
    SET @nBUSR2 = TRY_CAST(@cBUSR2 AS INT);

    IF @nBUSR2 IS NULL OR @nBUSR2 = 0
    BEGIN
        SET @nQTY = -1;
        RETURN;
    END

    -- Conversion Logic (UNCHANGED)
    IF ((@nQTY * @nBUSR2) % @nBUSR2) <> 0
        SET @nQTY = -1;
    ELSE
        SET @nQTY = @nQTY * @nBUSR2;

END;
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[ispdamConvertQTY] TO NSQL
GO