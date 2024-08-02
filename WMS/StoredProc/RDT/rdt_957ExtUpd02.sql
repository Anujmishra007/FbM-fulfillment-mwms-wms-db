SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO



/******************************************************************************/
/* Store procedure: rdt_957ExtUpd02                                           */
/* Copyright      : Maersk                                                    */ 
/* Purpose:Extended Puma                                                      */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2024-07-16   JHU151    1.0   FCR-428 Created                               */
/******************************************************************************/

CREATE OR ALTER     PROCEDURE [RDT].[rdt_957ExtUpd02]
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
   ,@cSuggLOC        NVARCHAR( 10)
   ,@cSuggID         NVARCHAR( 18)
   ,@cSuggSKU        NVARCHAR( 20)
   ,@nSuggQTY        INT          
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
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR(250) OUTPUT 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bSuccess INT   
   DECLARE @nExists  INT
   DECLARE @cShort   NVARCHAR(20)

         
   SET @nErrNo          = 0
   SET @cErrMSG         = ''
   
   
   IF @nFunc = 957
   BEGIN
      IF @nStep = 5
      BEGIN
         -- Short pick
         IF @nInputKey = 1
         BEGIN
            DECLARE
               @cStoredProcedure  NVARCHAR(50),
               @cCCTaskType       NVARCHAR(60),
               @cHoldType         NVARCHAR(60),
               @cSQL              NVARCHAR(MAX),
               @cSQLParam         NVARCHAR(MAX),
               @cLot              NVARCHAR(10),
               @cReasonCode       NVARCHAR(20),
               @b_Success         INT,
               @n_err             INT,
               @c_errmsg          NVARCHAR(250)

            

            -- Short
            IF @cOption = '1'
            BEGIN
               SELECT 
                  @cReasonCode = Code2,
                  @cCCTaskType = UDF01,-- CC task type
                  @cHoldType = UDF02 -- Hold type
               FROM codelkup 
               WHERE listname = 'RDTREASON'
               AND code = @nFunc
               AND storerkey = @cStorerKey

               SET @cStoredProcedure = rdt.rdtGetConfig( @nFunc, 'ActRDTreason', @cStorerKey)
               IF @cStoredProcedure = '0'
                  SET @cStoredProcedure = ''
                     
               IF @cStoredProcedure <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cStoredProcedure AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cStoredProcedure) +
                           ' @nMobile, @nFunc, @cStorerKey, ' +
                           ' @cSKU, @cLOC, @cLot, @cID, @cReasonCode,@cPickSlipNo, ' +                      
                           ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
                     SET @cSQLParam =
                           ' @nMobile         INT                      ' +
                           ',@nFunc           INT                      ' +
                           ',@cStorerKey      NVARCHAR( 15)            ' +
                           ',@cSKU            NVARCHAR( 20)            ' +
                           ',@cLOC            NVARCHAR( 10)            ' +
                           ',@cLot            NVARCHAR( 10)            ' +
                           ',@cID             NVARCHAR( 20)            ' +
                           ',@cReasonCode     NVARCHAR( 20)            ' + 
                           ',@cPickSlipNo     NVARCHAR( 10)            ' +                          
                           ',@nErrNo          INT           OUTPUT     ' +
                           ',@cErrMsg         NVARCHAR(250) OUTPUT  '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                           @nMobile, @nFunc, @cStorerKey,
                           @cSuggSKU, @cSuggLOC, @cLot, @cSuggID, @cReasonCode,@cPickSlipNo,
                           @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                           GOTO Quit
                  END
               END
            END
         END
      END
   END
Quit:


END
GO
GRANT EXECUTE ON  [RDT].[rdt_957ExtUpd02] TO [NSQL]
GO

