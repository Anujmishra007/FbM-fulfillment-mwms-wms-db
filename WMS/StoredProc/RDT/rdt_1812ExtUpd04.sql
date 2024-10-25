
/************************************************************************/
/* Store procedure: rdt_1812ExtUpd04                                    */
/* Purpose: Extended Update                                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2024-10-24   YYS027    1.0   FCR-989 Min Max Replenishment           */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1812ExtUpd04
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

   DECLARE @bSuccess    INT   
   DECLARE @nExists     INT
   DECLARE @cShort      NVARCHAR(20)

   DECLARE @cWCS        NVARCHAR(1)
   DECLARE @cCaseID     NVARCHAR(20)
   DECLARE @cListKey    NVARCHAR(10)
   DECLARE @cUserName   NVARCHAR(18)
   DECLARE @cStorerKey  NVARCHAR(15)
   DECLARE @cFacility   NVARCHAR(5)
   

   DECLARE @cLoadKey    NVARCHAR( 10) = ''
   DECLARE @cOrderKey   NVARCHAR( 10) = ''
   DECLARE @cZone       NVARCHAR( 18) = ''
   DECLARE @curOrder    CURSOR
   DECLARE @cActUCCNo   NVARCHAR( 40) = ''
   DECLARE @cActDropID  NVARCHAR( 40) = ''
   DECLARE @cActCaseID  NVARCHAR( 40) = ''
   
   DECLARE
      @cStoredProcedure  NVARCHAR(50),
      @cCCTaskType       NVARCHAR(60),
      @cHoldType         NVARCHAR(60),
      @cSQL              NVARCHAR(MAX),
      @cSQLParam         NVARCHAR(MAX),
      @cLOC              NVARCHAR(10), 
      @cLot              NVARCHAR(10),
      @cID               NVARCHAR(20),
      @cSKU              NVARCHAR(20),
      @cReasonCode       NVARCHAR(20),
      @b_Success         INT,
      @n_err             INT,
      @cPickDetailKey    NVARCHAR(50) = '',
      @c_errmsg          NVARCHAR(250)
         
   SET @nErrNo          = 0
   SET @cErrMSG         = ''
      
   
   SELECT 
      @cUserName = userName,
      @cStorerKey = StorerKey,
      @cFacility = Facility 
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE mobile = @nMobile
   
   -- TM Case Pick
   IF @nFunc = 1812
   BEGIN
      IF @nStep = 10 -- Is the location completely empty?
      BEGIN
         IF @nInputKey = 1 AND @cOption='1'           --ENTER and 1=YES(LOC is empty)
         BEGIN
         	-----replenishment should be triggered. But instead of the current way, the replenishment SP should be submitted to QCommander. 
         END
         IF @nInputKey = 1 AND @cOption='9'           --ENTER and 1=NO(LOC is not empty)
         BEGIN
            --If the user responds with 9 = NO, please refer to the RDT storer configuration NOREPLENREASON. 
            --If the Svalue maintained can be found in RDTREASON code list (Code2), then appropriate action has to be taken as mentioned in Code UDF01, Code UDF02, and Code UDF03. 
            --Please refer to FCR-428 for more information on implementing reason code.
            SELECT 
               @cReasonCode = Code2,
               @cCCTaskType = UDF01,-- CC task type
               @cHoldType = UDF02 -- Hold type
            FROM codelkup 
            WHERE listname = 'RDTREASON'
            AND code = @nFunc
            AND storerkey = @cStorerKey

            SET @cLoc = @cSuggLOC
            SET @cID = @cSuggID
            SET @cSKU = @cSuggSKU

            SET @cStoredProcedure = rdt.rdtGetConfig( @nFunc, 'ActRDTreason', @cStorerKey)
            IF @cStoredProcedure = '0'
               SET @cStoredProcedure = ''
                  
            IF @cStoredProcedure <> ''
            BEGIN
               IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cStoredProcedure AND type = 'P')
               BEGIN
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cStoredProcedure) +
                        ' @nMobile, @nFunc, @cStorerKey, ' +
                        ' @cSKU, @cLOC, @cLot, @cID, @cReasonCode, ' +                      
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
                        ',@nErrNo          INT           OUTPUT     ' +
                        ',@cErrMsg         NVARCHAR(250) OUTPUT  '

                  SELECT TOP 1
                        @cOrderKey = OrderKey,
                        @cLoadKey = ExternOrderKey,
                        @cZone = Zone
                  FROM dbo.PickHeader WITH (NOLOCK)
                  WHERE PickHeaderKey = @cPickSlipNo

                  WHILE (1=1)
                  BEGIN
                     -- Cross dock PickSlip
                     IF @cZone IN ('XD', 'LB', 'LP')
                     BEGIN
                        SELECT TOP 1
                           @cPickDetailKey = PD.PickDetailKey,
                           @cLot = Lot,
                           @cID = ID
                        FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                           JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                        WHERE RKL.PickSlipNo = @cPickSlipNo
                           AND PD.LOC = @cLOC
                           AND PD.SKU = @cSKU
                           AND (ISNULL(@cID,'') = '' OR ID = @cID)
                           AND PD.QTY > 0
                           AND (
                                 (@nFunc = 839  AND PD.status = '4')
                                 OR 
                                 (@nFunc = 957 AND PD.Status <> '4' AND PD.Status < '5')
                                 )
                           AND PD.PickDetailKey > @cPickDetailKey
                        ORDER BY PD.PickDetailKey
                     END
                     ELSE IF @cOrderKey <> ''
                     BEGIN
                        SELECT TOP 1
                           @cPickDetailKey = PD.PickDetailKey,
                           @cLot = Lot,
                           @cID = ID
                        FROM dbo.PickDetail PD WITH (NOLOCK)
                           JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                        WHERE PD.OrderKey = @cOrderKey
                           AND PD.LOC = @cLOC
                           AND PD.SKU = @cSKU
                           AND (ISNULL(@cID,'') = '' OR ID = @cID)
                           AND PD.QTY > 0
                           AND (
                                 (@nFunc = 839  AND PD.status = '4')
                                 OR 
                                 (@nFunc = 957 AND PD.Status <> '4' AND PD.Status < '5')
                                 )
                           AND PD.PickDetailKey > @cPickDetailKey
                        ORDER BY PD.PickDetailKey
                     END
                     ELSE IF @cLoadKey <> ''
                     BEGIN
                        
                        SELECT TOP 1
                              @cPickDetailKey = PD.PickDetailKey,
                              @cLot = Lot,
                              @cID = ID
                        FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                           JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                           JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                        WHERE LPD.LoadKey = @cLoadKey
                           AND PD.LOC = @cLOC
                           AND PD.SKU = @cSKU
                           AND (ISNULL(@cID,'') = '' OR ID = @cID)
                           AND PD.QTY > 0
                           AND (
                              (@nFunc = 839  AND PD.status = '4')
                              OR 
                              (@nFunc = 957 AND PD.Status <> '4' AND PD.Status < '5')
                              )
                           AND PD.PickDetailKey > @cPickDetailKey
                        ORDER BY PD.PickDetailKey
                     END
                     ELSE
                     BEGIN
                        SELECT TOP 1
                              @cPickDetailKey = PD.PickDetailKey,
                              @cLot = Lot,
                              @cID = ID
                        FROM dbo.PickDetail PD WITH (NOLOCK)
                        JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                        WHERE PD.PickSlipNo = @cPickSlipNo
                        AND PD.LOC = @cLOC
                        AND PD.SKU = @cSKU
                        AND (ISNULL(@cID,'') = '' OR ID = @cID)
                           AND PD.QTY > 0
                           AND (
                              (@nFunc = 839  AND PD.status = '4')
                              OR 
                              (@nFunc = 957 AND PD.Status <> '4' AND PD.Status < '5')
                              )
                           AND PD.PickDetailKey > @cPickDetailKey
                        ORDER BY PD.PickDetailKey
                     END


                     IF @@ROWCOUNT = 0
                     BEGIN
                        BREAK
                     END
                     
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                           @nMobile, @nFunc, @cStorerKey,
                           @cSKU, @cLOC, @cLot, @cID, @cReasonCode,
                           @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                           GOTO Quit

                  END
               END
            END
            ----------------------------------------------------
         END
      END
   END

Quit:


END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1812ExtUpd04 TO NSQL
GO
