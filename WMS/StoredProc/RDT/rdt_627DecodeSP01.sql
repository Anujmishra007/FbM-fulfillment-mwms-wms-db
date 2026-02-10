SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*****************************************************************************/
/* Store Procedure: rdt_627DecodeSP01                                        */
/*                                                                           */
/* Purpose: Decode QR Code for FN627 (SerialNo Inquiry)                      */
/* Customer: PageInd                                                         */
/*                                                                           */
/* Called from: rdtfnc_SerialNo_Inquiry                                      */
/* Modifications log:                                                        */
/*                                                                           */
/* Date        Rev  Author   Purposes                                        */
/* 05-02-2026  1.0  NYE018   FCR-9890 created to decode the serialno         */
/*****************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_627DecodeSP01] (
    @nMobile     INT,
    @nFunc       INT,
    @cLangCode   NVARCHAR(3),
    @nStep       INT,
    @nInputKey   INT,
    @cFacility   NVARCHAR(5),
    @cStorerKey  NVARCHAR(15),
    @cBarcode    NVARCHAR(200),
    @cSerialNo   NVARCHAR(20)   OUTPUT,
    @nErrNo      INT            OUTPUT,
    @cErrMsg     NVARCHAR(1024) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    SET @cSerialNo  = N''
    SET @nErrNo = 0
    SET @cErrMsg = N''

    IF @nFunc = 627 AND @nStep = 1 AND @nInputKey = 1
    BEGIN

        IF ISNULL(@cBarcode, N'') = N''
        BEGIN
            SET @nErrNo = 258451 
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  -- 'Barcode required'
            GOTO Quit
        END

        -- Check for delimiter presence
        IF CharIndex('&', @cBarcode) = 0 
        BEGIN
            -- If no delimiter, assume raw SerialNo
            SET @cSerialNo = @cBarcode
        END
        ELSE
        BEGIN
            -- Validate Delimiter Count (expecting 7 segments for the QR code)
            DECLARE @nDelimiterCount INT
            SET @nDelimiterCount = LEN(@cBarcode) - LEN(REPLACE(@cBarcode, '&', ''))

            IF @nDelimiterCount <> 7 
            BEGIN
                 SET @nErrNo = 258452 
                 SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'INVALID FORMAT'
                 GOTO Quit
            END

            -- SerialNo = seg4 + seg5 + seg7
            DECLARE
                @s1 NVARCHAR(200) = N'', @s2 NVARCHAR(200) = N'', @s3 NVARCHAR(200) = N'',
                @s4 NVARCHAR(200) = N'', @s5 NVARCHAR(200) = N'', @s6 NVARCHAR(200) = N'',
                @s7 NVARCHAR(200) = N'', @s8 NVARCHAR(200) = N'', @s9 NVARCHAR(200) = N'',
                @work NVARCHAR(400) = @cBarcode + N'&', @pos INT = 1, @next INT = 1, @seg NVARCHAR(200), @i INT = 1

            BEGIN TRY
                WHILE @next > 0
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
                SET @nErrNo = 258454 
                SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  -- 'DECODE FAILURE'
                GOTO Quit
            END CATCH

            -- Build SerialNo = seg4 + seg5 + seg7 
            SET @cSerialNo = CONCAT(RTRIM(@s4), RTRIM(@s5), RTRIM(@s7))
        END

        
        IF ISNULL(@cSerialNo, '') = '' 
        BEGIN
             SET @cSerialNo = @cBarcode
        END

        -- Final validation: must exist in SERIALNO table for this storer
        IF NOT EXISTS (SELECT 1
                        FROM dbo.SERIALNO WITH (NOLOCK)
                        WHERE SerialNo = @cSerialNo)
        BEGIN
            SET @nErrNo = 258453 
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  -- 'SERIALNO NOT FOUND' 
            SET @cSerialNo = N''
            GOTO Quit
        END
    END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_627DecodeSP01] TO [NSQL]
GO