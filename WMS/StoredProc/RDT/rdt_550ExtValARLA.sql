USE [GLOWMS]
GO
/****** Object:  StoredProcedure [RDT].[rdt_550ExtValARLA]    Script Date: 6/21/2026 4:13:20 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*****************************************************************************/
/* Stored Procedure: rdt_500ExtValARLA                     */
/* Creation Date: 01-04-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: KMS043                                                        */
/*                                                                           */
/* Purpose : Validation of SSCC Number during Receiving  UWP-59503                          */
/*                                                                           */
/* Called By:  rdt_500ExtValARLA                 */
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purpose                                        */
/* 01-04-2026   KMS043   1.0  Initial version created                        */
/*****************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_550ExtValARLA]
(
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR(3),
   @nStep        INT,
   @nInputKey    INT,
   @cStorerKey   NVARCHAR(15),
   @cReceiptKey  NVARCHAR(10),
   @cPOKey       NVARCHAR(10),
   @cLOC         NVARCHAR(10),
   @cID          NVARCHAR(18),
   @cSKU         NVARCHAR(20),
   @nQTY         INT,
   @cLottable01  NVARCHAR(18),
   @cLottable02  NVARCHAR(18),
   @cLottable03  NVARCHAR(18),
   @dLottable04  DATETIME,
   @nErrNo       INT OUTPUT,
   @cErrMsg      NVARCHAR(20) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------
    -- MAIN LOGIC
    ------------------------------------------------------------
    IF @nFunc = 550  -- Normal receiving
    BEGIN
        IF @nStep = 5  -- UOM, QTY
        BEGIN
            IF @nInputKey = 1  -- ENTER
            BEGIN
                ------------------------------------------------------------
                -- VALIDATE ID
                ------------------------------------------------------------
                IF ISNULL(LTRIM(RTRIM(@cID)), '') <> ''
                BEGIN
                    -- Validate if ID exists for valid receipt type
                    IF NOT EXISTS
                    (
                        SELECT 1
                        FROM RECEIPTDETAIL RD WITH (NOLOCK)
                        INNER JOIN RECEIPT R 
                            ON R.RECEIPTKEY = RD.RECEIPTKEY
                           AND R.STORERKEY = RD.STORERKEY
                        LEFT JOIN LOTXLOCXID LLI  WITH (NOLOCK)
                            ON LLI.STORERKEY = @cStorerKey
                           AND LLI.ID = @cID  
                        WHERE RD.RECEIPTKEY = @cReceiptKey
                          AND RD.TOID = @cID
                          AND R.RECTYPE IN 
                          (
                              SELECT CODE
                              FROM CODELKUP WITH (NOLOCK)
							  WHERE STORERKEY = @cStorerKey
                                AND LISTNAME = 'RECTYPE'
                                AND UDF01 = 'Y'
                          )
                    )
                    BEGIN
                        SET @nErrNo = 88888;
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP'); -- Invalid SSCC
                        GOTO Fail;
                    END
                END
            END
        END
    END

------------------------------------------------------------
-- EXIT POINTS
------------------------------------------------------------
Quit:
    RETURN;

Fail:
    RETURN;
END
