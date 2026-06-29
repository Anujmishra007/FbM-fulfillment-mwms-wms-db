SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_600GetRcvInfo15                                       */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Customer: MICHELIN (VN)                                                    */
/* Purpose: Default Qty when receiving PC&TB                                  */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2026-06-29  Sreeja    1.0   FCR-14112 Created                              */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_600GetRcvInfo15 (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cStorerKey   NVARCHAR( 15),
   @cReceiptKey  NVARCHAR( 10),
   @cPOKey       NVARCHAR( 10),
   @cLOC         NVARCHAR( 10),
   @cID          NVARCHAR( 18)  OUTPUT,
   @cSKU         NVARCHAR( 20)  OUTPUT,
   @nQTY         INT            OUTPUT,
   @cLottable01  NVARCHAR( 18)  OUTPUT,
   @cLottable02  NVARCHAR( 18)  OUTPUT,
   @cLottable03  NVARCHAR( 18)  OUTPUT,
   @dLottable04  DATETIME       OUTPUT,
   @dLottable05  DATETIME       OUTPUT,
   @cLottable06  NVARCHAR( 30)  OUTPUT,
   @cLottable07  NVARCHAR( 30)  OUTPUT,
   @cLottable08  NVARCHAR( 30)  OUTPUT,
   @cLottable09  NVARCHAR( 30)  OUTPUT,
   @cLottable10  NVARCHAR( 30)  OUTPUT,
   @cLottable11  NVARCHAR( 30)  OUTPUT,
   @cLottable12  NVARCHAR( 30)  OUTPUT,
   @dLottable13  DATETIME       OUTPUT,
   @dLottable14  DATETIME       OUTPUT,
   @dLottable15  DATETIME       OUTPUT,
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET ANSI_NULLS OFF
    SET QUOTED_IDENTIFIER OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE
      @cSKUClass      NVARCHAR(10),
      @cDefaultQty    NVARCHAR(10),
      @nDefaultQty    INT,
      @cMasterUOM     NVARCHAR(10),
      @cPUOM          NVARCHAR(1),
      @nPUOM_Div      INT

    SET @nErrNo = 0
    SET @cErrMsg = ''

    -- Only process: Func 600, ENTER key
    IF @nFunc = 600
    BEGIN
        -- Ensure SKU is loaded if not passed
        IF ISNULL(@cSKU, '') = ''
        BEGIN
            SELECT @cSKU = V_SKU FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile
        END

        -- Step 4: SKU screen - Populate lottables from ReceiptDetail
        IF @nStep = 4
        BEGIN
            IF @nInputKey = 1
            BEGIN
                -- Get lottable values from ReceiptDetail (first matching line)
                -- NOTE: Do NOT populate Lottable02 (MIN DOT) or Lottable07 (PCS DOT) - user must enter them
                SELECT TOP 1
                    @cLottable01 = Lottable01,
                    -- @cLottable02 = Lottable02,  -- MIN DOT - do not auto-populate
                    @cLottable03 = Lottable03,
                    @dLottable04 = Lottable04,
                    @dLottable05 = Lottable05,
                    @cLottable06 = Lottable06,
                    -- @cLottable07 = Lottable07,  -- PCS DOT - do not auto-populate
                    @cLottable08 = Lottable08,
                    @cLottable09 = Lottable09,
                    @cLottable10 = Lottable10,
                    @cLottable11 = Lottable11,
                    @cLottable12 = Lottable12,
                    @dLottable13 = Lottable13,
                    @dLottable14 = Lottable14,
                    @dLottable15 = Lottable15
                FROM dbo.ReceiptDetail WITH (NOLOCK)
                WHERE ReceiptKey = @cReceiptKey
                AND StorerKey = @cStorerKey
                AND SKU = @cSKU
                ORDER BY ReceiptLineNumber
            END
        END

        -- Step 5: Lottable screen - Set default QTY
        IF @nStep = 5
        BEGIN
            IF @nInputKey = 1
            BEGIN
                 -- Get SKU CLASS only
                SELECT @cSKUClass = Class
                FROM dbo.SKU WITH (NOLOCK)
                WHERE StorerKey = @cStorerKey
                    AND SKU = @cSKU

                -- Lookup default QTY if CLASS found
                IF ISNULL(@cSKUClass, '') <> ''
                BEGIN
                    SELECT @cMasterUOM = P.PackUOM3
                    FROM dbo.SKU S WITH (NOLOCK)
                    INNER JOIN dbo.Pack P WITH (NOLOCK) ON S.PackKey = P.PackKey
                    WHERE S.StorerKey = @cStorerKey AND S.SKU = @cSKU

                    SELECT TOP 1 @cDefaultQty = Short
                    FROM dbo.CODELKUP WITH (NOLOCK)
                    WHERE ListName = 'MICPCSIBDF'
                      AND StorerKey = @cStorerKey
                      AND Code = @cSKUClass
                      AND Long = @cMasterUOM  -- Validate master UoM matches

                    -- Set QTY if valid number found
                    IF ISNULL(@cDefaultQty, '') <> '' AND ISNUMERIC(@cDefaultQty) = 1
                    BEGIN
                        SET @nDefaultQty = TRY_CAST(@cDefaultQty AS INT)
                        IF ISNULL(@nDefaultQty, 0) > 0
                        BEGIN
                            SET @nQTY = @nDefaultQty
                        END
                    END
                END
            END
        END

        -- Step 6: QTY screen - Set default QTY when user presses ENTER
        IF @nStep = 6
        BEGIN
            IF @nInputKey = 1
            BEGIN
                -- Get SKU CLASS
                SELECT @cSKUClass = Class
                FROM dbo.SKU WITH (NOLOCK)
                WHERE StorerKey = @cStorerKey
                  AND SKU = @cSKU

                -- Lookup default QTY if CLASS found
                IF ISNULL(@cSKUClass, '') <> ''
                BEGIN
                    SELECT @cMasterUOM = P.PackUOM3
                    FROM dbo.SKU S WITH (NOLOCK)
                    INNER JOIN dbo.Pack P WITH (NOLOCK) ON S.PackKey = P.PackKey
                    WHERE S.StorerKey = @cStorerKey AND S.SKU = @cSKU

                    SELECT TOP 1 @cDefaultQty = Short
                    FROM dbo.CODELKUP WITH (NOLOCK)
                    WHERE ListName = 'MICPCSIBDF'
                      AND StorerKey = @cStorerKey
                      AND Code = @cSKUClass
                      AND Long = @cMasterUOM  -- Validate master UoM matches

                    -- Set QTY if valid number found and @nQTY is 0
                    IF ISNULL(@cDefaultQty, '') <> '' AND ISNUMERIC(@cDefaultQty) = 1
                    BEGIN
                        SET @nDefaultQty = TRY_CAST(@cDefaultQty AS INT)

                        IF ISNULL(@nDefaultQty, 0) > 0 AND ISNULL(@nQTY, 0) = 0
                        BEGIN
                            SET @nQTY = @nDefaultQty
                        END
                    END
                END
            END
        END
    END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_600GetRcvInfo15 TO NSQL
GO
