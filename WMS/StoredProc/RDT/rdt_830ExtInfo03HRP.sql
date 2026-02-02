SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_830ExtInfo03HRP                                 */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 08-05-2025  1.0  WSE016      Copy FROM_Loc to NOTES                  */
/************************************************************************/

CREATE OR ALTER     PROCEDURE [RDT].[rdt_830ExtInfo03HRP]
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nAfterStep    INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cPickSlipNo   NVARCHAR( 10),
   @cPickZone     NVARCHAR( 10),
   @cSuggLOC      NVARCHAR( 10),
   @cLOC          NVARCHAR( 10),
   @cDropID       NVARCHAR( 20),
   @cSKU          NVARCHAR( 20),
   @cLottable01   NVARCHAR( 18),
   @cLottable02   NVARCHAR( 18),
   @cLottable03   NVARCHAR( 18),
   @dLottable04   DATETIME,
   @dLottable05   DATETIME,
   @cLottable06   NVARCHAR( 30),
   @cLottable07   NVARCHAR( 30),
   @cLottable08   NVARCHAR( 30),
   @cLottable09   NVARCHAR( 30),
   @cLottable10   NVARCHAR( 30),
   @cLottable11   NVARCHAR( 30),
   @cLottable12   NVARCHAR( 30),
   @dLottable13   DATETIME,
   @dLottable14   DATETIME,
   @dLottable15   DATETIME,
   @nTaskQTY      INT,
   @nQTY          INT,
   @cToLOC        NVARCHAR( 10),
   @cOption       NVARCHAR( 1),
   @cExtendedInfo NVARCHAR( 20) OUTPUT,
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    IF @nFunc = 830 -- PickSK

BEGIN
        IF @nAfterStep = 3 -- LOC

IF EXISTS (SELECT 1
        FROM PICKDETAIL WITH (NOLOCK)
        WHERE storerkey = @cStorerKey AND loc = @cLOC AND OrderKey IN (
        SELECT OrderKey
            FROM PICKHEADER WITH (NOLOCK)
            WHERE storerkey = @cStorerKey AND PickHeaderKey = @cPickSlipNo)
         )

        BEGIN
            UPDATE PICKDETAIL SET NOTES = @cLOC WHERE storerkey = @cStorerKey AND loc = @cLOC AND OrderKey IN (
            SELECT OrderKey
                FROM PICKHEADER WITH (NOLOCK)
                WHERE storerkey =@cStorerKey AND PickHeaderKey = @cPickSlipNo)
        END
    END

    Quit:

END
GO
