SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
 
/************************************************************************/  
/* Store procedure: rdt_1864ExtVLT_HRP                                  */  
/*                                                                      */  
/* Purpose:       HRPUMA Projcet                                        */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 25-04-2025  1.0  WSE016    Added check  if DropID not being used     */
/*                                                                      */  
/************************************************************************/  
CREATE or ALTER     PROCEDURE [RDT].[rdt_1864ExtVLT_HRP]
@nMobile       INT,           
@nFunc         INT,           
@cLangCode     NVARCHAR( 3),  
@nStep         INT,           
@nInputKey     INT,           
@cFacility     NVARCHAR( 5),  
@cStorerKey    NVARCHAR( 15), 
@cPickSlipNo   NVARCHAR( 10), 
@cPickZone     NVARCHAR( 10), 
@cLOC          NVARCHAR( 10), 
@cID           NVARCHAR( 18), 
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
@cToLOC        NVARCHAR( 10), 
@cOption       NVARCHAR( 1),  
@nErrNo        INT           OUTPUT, 
@cErrMsg       NVARCHAR( 20) OUTPUT  

 
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

 
   IF @nFunc = 1864
   BEGIN
        IF @nStep = 1 -- PickSlip
        BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN

                IF @cOrdType ='ZLF'
                BEGIN
                    SET @nErrNo = 218352
                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --PickSlip for xDock Ord
                    GOTO Quit
                END
            END
        END

END

Quit:	
END
GO
