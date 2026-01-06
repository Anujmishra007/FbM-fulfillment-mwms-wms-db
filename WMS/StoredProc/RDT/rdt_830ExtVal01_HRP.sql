SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_830ExtVal01_HRP                                 */
/* Copyright      : LFLogistics                                         */
/*                                                                      */
/* Purpose: DropID compulsory                                           */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 25-04-2025  1.0  WSE016      based on rdt_830ExtVal01, added check   */
/*                              if DropID not being used                */
/************************************************************************/

CREATE or ALTER   PROCEDURE [RDT].[rdt_830ExtVal01_HRP]
    @nMobile INT,
    @nFunc INT,
    @cLangCode NVARCHAR(3),
    @nStep INT,
    @nInputKey INT,
    @cFacility NVARCHAR(5),
    @cStorerKey NVARCHAR(15),
    @cPickSlipNo NVARCHAR(10),
    @cPickZone NVARCHAR(10), 
    @cSuggLOC NVARCHAR(10),
    @cLOC NVARCHAR(10),
    @cDropID NVARCHAR(20),
    @cSKU NVARCHAR(20),
    @cLottable01 NVARCHAR(18),
    @cLottable02 NVARCHAR(18),
    @cLottable03 NVARCHAR(18),
    @dLottable04 DATETIME,
    @dLottable05 DATETIME,
    @cLottable06 NVARCHAR(30),
    @cLottable07 NVARCHAR(30),
    @cLottable08 NVARCHAR(30),
    @cLottable09 NVARCHAR(30),
    @cLottable10 NVARCHAR(30),
    @cLottable11 NVARCHAR(30),
    @cLottable12 NVARCHAR(30),
    @dLottable13 DATETIME,
    @dLottable14 DATETIME,
    @dLottable15 DATETIME,
    @nTaskQTY INT,
    @nQTY INT,
    @cToLOC NVARCHAR(10),
    @cOption NVARCHAR(1),
    @nErrNo INT OUTPUT,
    @cErrMsg NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF


DECLARE 
@cOrdType  NVARCHAR(10)

SELECT TOP 1
    @cOrdType = ORM.Type
FROM ORDERS ORM WITH (NOLOCK)
INNER JOIN PICKHEADER PKH WITH (NOLOCK)
    ON ORM.StorerKey = PKH.StorerKey 
    AND ORM.OrderKey = PKH.OrderKey
WHERE PKH.StorerKey = @cStorerKey
AND PKH.PickHeaderKey = @cPickSlipNo
ORDER BY ORM.OrderKey


    IF @nFunc = 830 -- PickSKU
    BEGIN

        IF @nStep = 1 -- PickSlip
        BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN

                IF @cOrdType ='ZPTO'
                BEGIN
                    SET @nErrNo = 218353
                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --PickSlip for Non-xDock Ord
                    GOTO Quit
                END
            END
        END


        IF @nStep = 2 -- LOC
        BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN


                IF @cDropID = ''
                BEGIN
                    SET @nErrNo = 108401
                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Need DropID
                    GOTO Quit
                END
                ELSE IF (
                            EXISTS
                     (
                         SELECT Id
                         FROM LOTxLOCxID (NOLOCK)
                         WHERE Id = @cDropID
						 AND STORERKEY = @cStorerKey
                         AND ID not in (
                         SELECT dropid
                         FROM PICKDETAIL (NOLOCK)
                         WHERE STORERKEY = @cStorerKey
                               AND STATUS <> '9'
                               AND DropID = @cDropID
                         )
                      )
                     )
                BEGIN
                    SET @nErrNo = 217933
                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --DropIDIsUsed
                END

            END
        END
    END

    Quit:

END
GO
