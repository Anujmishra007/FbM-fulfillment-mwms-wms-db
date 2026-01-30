/*****************************************************************************/
/* Store Procedure: rdt_729DecodeSP01                                        */
/*                                                                           */
/* Purpose: Decode QR Code/Barcode for FN729 (UCC Inquiry)                   */
/* Customer: PageInd                                                         */
/*                                                                           */
/* Called from: rdtfnc_UCCInquire                                            */
/* Modifications log:                                                        */
/*                                                                           */
/* Date        Rev  Author   Purposes                                        */
/* 29-01-2026  1.0  SSR259   FCR-9907 DecodeQR Logic for UCC                 */
/*****************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_729DecodeSP01] (
    @nMobile     INT,
    @nFunc       INT,
    @cLangCode   NVARCHAR(3),
    @nStep       INT,
    @nInputKey   INT,
    @cFacility   NVARCHAR(5),
    @cStorerKey  NVARCHAR(15),
    @cBarcode    NVARCHAR(200),
    @cUCC        NVARCHAR(20)   OUTPUT,
    @nErrNo      INT            OUTPUT,
    @cErrMsg     NVARCHAR(1024) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET @cUCC  = N''
    SET @nErrNo = 0
    SET @cErrMsg = N''

    -- Basic validation
    IF ISNULL(@cBarcode, N'') = N''
    BEGIN
        SET @nErrNo = 257751 -- 'Barcode/UCC required'
        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
        GOTO Quit
    END

    -- Page QR format: &-delimited UCC = seg4 + seg5 + seg7
    DECLARE
        @s1 NVARCHAR(200) = N'', @s2 NVARCHAR(200) = N'', @s3 NVARCHAR(200) = N'',
        @s4 NVARCHAR(200) = N'', @s5 NVARCHAR(200) = N'', @s6 NVARCHAR(200) = N'',
        @s7 NVARCHAR(200) = N'', @s8 NVARCHAR(200) = N'', @s9 NVARCHAR(200) = N'',
        @work NVARCHAR(400) = @cBarcode + N'&', @pos INT = 1, @next INT, @seg NVARCHAR(200), @i INT = 1

    BEGIN TRY
        WHILE 1 = 1
        BEGIN
            SET @next = CHARINDEX(N'&', @work, @pos)
            IF @next = 0 BREAK
            SET @seg = SUBSTRING(@work, @pos, @next - @pos)

            IF     @i = 1 SET @s1 = @seg
            ELSE IF @i = 2 SET @s2 = @seg
            ELSE IF @i = 3 SET @s3 = @seg
            ELSE IF @i = 4 SET @s4 = @seg
            ELSE IF @i = 5 SET @s5 = @seg
            ELSE IF @i = 6 SET @s6 = @seg
            ELSE IF @i = 7 SET @s7 = @seg
            ELSE IF @i = 8 SET @s8 = @seg
            ELSE IF @i = 9 SET @s9 = @seg

            SET @pos = @next + 1
            SET @i += 1
            IF @i > 9 BREAK 
        END
    END TRY
    BEGIN CATCH
        SET @nErrNo = 257754 -- 'DECODE FAILURE'
        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
        GOTO Quit
    END CATCH

    -- Build UCC = seg4 + seg5 + seg7 (e.g., 4525003831 + NB + 021712)
    SET @cUCC = RTRIM(@s4) + RTRIM(@s5) + RTRIM(@s7)

    -- Fallbacks: if we couldn't parse into 4/5/7, allow direct use of barcode
    IF (ISNULL(@s4, '') = '' OR ISNULL(@s5, '') = '' OR ISNULL(@s7, '') = '')
    BEGIN
        -- If scanned is already a raw UCC, use it
        SET @cUCC = CASE WHEN LEN(ISNULL(@cUCC, '')) = 0 THEN @cBarcode ELSE @cUCC END
        
        -- Validate format when segments are missing
        IF LEN(ISNULL(@cUCC, '')) = 0
        BEGIN
            SET @nErrNo = 257752 -- 'INVALID FORMAT'
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            GOTO Quit
        END
    END

    -- Final validation: must exist in UCC table for this storer
    IF NOT EXISTS (SELECT 1
                    FROM dbo.UCC WITH (NOLOCK)
                    WHERE StorerKey = @cStorerKey
                    AND UCCNo = @cUCC)
    BEGIN
        SET @nErrNo = 257753 -- 'UCC NOT FOUND'
        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
        SET @cUCC = N''
        GOTO Quit
    END

    -- Retrieve actual SKU for this UCC from Database
    DECLARE @cUCCSKU NVARCHAR(20)
    SELECT TOP(1) @cUCCSKU = SKU
    FROM dbo.UCC WITH (NOLOCK)
    WHERE StorerKey = @cStorerKey
        AND UCCNo = @cUCC

    -- success
    SET @nErrNo = 0
    SET @cErrMsg = N''

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [RDT].[rdt_729DecodeSP01] TO [NSQL]
GO