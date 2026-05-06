SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO



/*******************************************************************************/
/* Store procedure: rdt_839ExtUpd10                                            */
/* Copyright      : Maersk                                                     */ 
/* Purpose: PAGEIND                                                            */
/*                                                                             */
/* Modifications log:                                                          */
/*                                                                             */
/* Date         Author    Ver.   Purposes                                      */
/* 2026-01-14   NickT     1.0    FCR-9040 Created                              */
/*******************************************************************************/

CREATE OR ALTER     PROCEDURE [RDT].[rdt_839ExtUpd10]
    @nMobile         INT                   
   ,@nFunc           INT                    
   ,@cLangCode       NVARCHAR( 3)           
   ,@nStep           INT                    
   ,@nInputKey       INT                    
   ,@cFacility       NVARCHAR( 5)           
   ,@cStorerKey      NVARCHAR( 15)          
   ,@cPickSlipNo     NVARCHAR( 10)          
   ,@cPickZone       NVARCHAR( 10)          
   ,@cDropID         NVARCHAR( 20)          
   ,@cLOC            NVARCHAR( 10)          
   ,@cSKU            NVARCHAR( 20)          
   ,@nQTY            INT                    
   ,@cOption         NVARCHAR( 1)           
   ,@cLottableCode   NVARCHAR( 30)          
   ,@cLottable01     NVARCHAR( 18)          
   ,@cLottable02     NVARCHAR( 18)          
   ,@cLottable03     NVARCHAR( 18)          
   ,@dLottable04     DATETIME               
   ,@dLottable05     DATETIME               
   ,@cLottable06     NVARCHAR( 30)          
   ,@cLottable07     NVARCHAR( 30)          
   ,@cLottable08     NVARCHAR( 30)          
   ,@cLottable09     NVARCHAR( 30)          
   ,@cLottable10     NVARCHAR( 30)          
   ,@cLottable11     NVARCHAR( 30)          
   ,@cLottable12     NVARCHAR( 30)          
   ,@dLottable13     DATETIME               
   ,@dLottable14     DATETIME               
   ,@dLottable15     DATETIME
   ,@cPackData1      NVARCHAR( 30)
   ,@cPackData2      NVARCHAR( 30)
   ,@cPackData3      NVARCHAR( 30)  
   ,@nErrNo          INT           OUTPUT   
   ,@cErrMsg         NVARCHAR(250) OUTPUT   
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   SET @nErrNo          = 0
   SET @cErrMSG         = ''

   IF @nFunc = 839
   BEGIN
      IF @nStep = 8
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF ISNULL(@cOption, '') = '1'
            BEGIN
               -- Delete all Picked UCC/SerialNo
               BEGIN TRY
                  DELETE FROM rdt.rdtPickLog 
                  WHERE Mobile = @nMobile
                     AND PickSlipNo = @cPickSlipNo
                     AND AddWho = SUSER_NAME()
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 255801
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Delete PickSerialNo failed
                  GOTO Quit
               END CATCH
            END
         END
      END
   END
Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_839ExtUpd10] TO [NSQL]
GO

