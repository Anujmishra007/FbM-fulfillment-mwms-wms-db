SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO



/*******************************************************************************/
/* Store procedure: rdt_839ExtUpd07                                            */
/* Copyright      : Maersk                                                     */ 
/* Purpose:Extended Puma                                                       */
/*                                                                             */
/* Modifications log:                                                          */
/*                                                                             */
/* Date         Author    Ver.   Purposes                                      */
/* 2024-07-16   JHU151    1.0    FCR-428 Created                               */
/* 2025-04-11   JCH507    1.1.0  FCR-2705 Support new screen                   */
/* 2025-05-20   JACKC     1.2.0  UWP-24683 Should not send IML once short but  */ 
/*                                 the current dropid is finished              */
/*******************************************************************************/

CREATE OR ALTER     PROCEDURE [RDT].[rdt_839ExtUpd07]
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
   DECLARE @nScn        INT
   DECLARE @nDebugFlag  INT = 0
   
   DECLARE
      @cStoredProcedure  NVARCHAR(50),
      @cCCTaskType       NVARCHAR(60),
      @cHoldType         NVARCHAR(60),
      @cSQL              NVARCHAR( MAX),
      @cSQLParam         NVARCHAR( MAX),
      @cLot              NVARCHAR(10),
      @cID               NVARCHAR(20),
      @cReasonCode       NVARCHAR(20),
      @b_Success         INT,
      @n_err             INT,
      @cPickDetailKey    NVARCHAR(50) = '',
      @cOrderKey         NVARCHAR(10) = '',
      @cLoadKey          NVARCHAR(10) = '',
      @cZone             NVARCHAR(18) = '',
      @nOpenPKDCount     INT = 0, --V1.2.0
      @cPickConfirmStatus  NVARCHAR( 1), --V1.2.0
      @c_errmsg          NVARCHAR(250)
      
   SET @nErrNo          = 0
   SET @cErrMSG         = ''

   IF @nFunc = 839
   BEGIN

      SELECT @nScn = scn FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile

      IF @nStep = 1
      BEGIN
         BEGIN
            DECLARE @curOrder  CURSOR
            
            /*
               The auto scan-in at parent module, sometimes does not trigger update Orders.Status = 3
               
               Exceed base, scan-in backgroup (ntrPickingInfoAdd or isp_ScanInPickslip):
                  insert PickingInfo, with pickslip, date and picker, whether trigger update Orders.Status = 3
                     if cross dock pickslip, not trigger 
                     if discrete pickslip, trigger
                     if conso pickslip , trigger
                     if customize pickslip, not trigger 
                     
                     Note: Cross dock and customize pickslip, works on Order line level, not at order level

                  Update PickingInfo, with date and picker, does not trigger Orders.Status = 3
            */
            
            -- Get PickHeader info
            SELECT TOP 1
               @cOrderKey = OrderKey,
               @cLoadKey = ExternOrderKey,
               @cZone = Zone
            FROM dbo.PickHeader WITH (NOLOCK)
            WHERE PickHeaderKey = @cPickSlipNo
      
            -- Cross dock PickSlip
            IF @cZone IN ('XD', 'LB', 'LP')
               SET @curOrder = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR 
                  SELECT DISTINCT O.OrderKey
                  FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                     JOIN dbo.Orders O WITH (NOLOCK) ON (O.OrderKey = RKL.Orderkey)
                  WHERE RKL.PickSlipNo = @cPickSlipNo
                     AND O.Status < '3'

            -- Discrete PickSlip
            ELSE IF @cOrderKey <> ''
               SET @curOrder = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR 
                  SELECT OrderKey
                  FROM dbo.Orders WITH (NOLOCK)
                  WHERE OrderKey = @cOrderKey
                     AND Status < '3'
               
            -- Conso PickSlip
            ELSE IF @cLoadKey <> ''
               SET @curOrder = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR 
                  SELECT DISTINCT O.OrderKey
                  FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                     JOIN dbo.Orders O (NOLOCK) ON (LPD.OrderKey = O.OrderKey)
                  WHERE LPD.LoadKey = @cLoadKey
                     AND O.Status < '3'
            
            -- Custom PickSlip
            ELSE
               SET @curOrder = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR 
                  SELECT DISTINCT O.OrderKey
                  FROM dbo.Orders O WITH (NOLOCK)
                     JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.OrderKey = O.OrderKey)
                  WHERE PD.PickSlipNo = @cPickSlipNo
                     AND O.Status < '3'
           
            -- Loop orders
            OPEN @curOrder
            FETCH NEXT FROM @curOrder INTO @cOrderKey
            WHILE @@FETCH_STATUS = 0
            BEGIN
               -- Update order 
               UPDATE dbo.Orders SET
                  Status = '3', -- In-progress
                  EditDate = GETDATE(), 
                  EditWho = SUSER_SNAME()
               WHERE OrderKey = @cOrderKey
               SET @nErrNo = @@ERROR 
               IF @nErrNo <> 0
               BEGIN
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 
                  GOTO Quit
               END
               FETCH NEXT FROM @curOrder INTO @cOrderKey
            END
         END
      END

      --V1.2.0 start
      IF @nStep = 4
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Running rdt_839ExtUpd07 Step4'

         -- Get PickHeader info
         SELECT TOP 1
            @cOrderKey = OrderKey,
            @cLoadKey = ExternOrderKey,
            @cZone = Zone
         FROM dbo.PickHeader WITH (NOLOCK)
         WHERE PickHeaderKey = @cPickSlipNo

         SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
         IF @cPickConfirmStatus = '0'
            SET @cPickConfirmStatus = '5'

         -- Check is there any open pickdetail under current psno.
         -- if no, means no more task went to the scanout logic, the dropid is closed. Otherwise can continue the picking
         IF @cZone IN ('XD', 'LB', 'LP')
         BEGIN
            IF @cPickZone = ''
               SELECT @nOpenPKDCount = COUNT(1)
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
            ELSE
               SELECT @nOpenPKDCount = COUNT(1)
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
         END

         -- Discrete PickSlip
         ELSE IF @cOrderKey <> ''
         BEGIN
            IF @cPickZone = ''
               SELECT @nOpenPKDCount = COUNT(1)
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
            ELSE
               SELECT @nOpenPKDCount = COUNT(1)
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
         END

         -- Conso PickSlip
         ELSE IF @cLoadKey <> ''
         BEGIN
            IF @cPickZone = ''
               SELECT @nOpenPKDCount = COUNT(1)
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               WHERE LPD.LoadKey = @cLoadKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
            ELSE
               SELECT @nOpenPKDCount = COUNT(1)
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               WHERE LPD.LoadKey = @cLoadKey
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
         END

         -- Custom PickSlip
         ELSE
         BEGIN
            IF @cPickZone = ''
               SELECT @nOpenPKDCount = COUNT(1)
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
            ELSE
               SELECT @nOpenPKDCount = COUNT(1)
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
         END

         IF @nDebugFlag = 1
            SELECT @nOpenPKDCount AS OpenPickDetailCount, @cDropID AS DropID

         IF @nOpenPKDCount = 0 -- there is no open pickdetail, then rdt go to PSNO screen, trigger IML at this time
         BEGIN
            -- Using drop ID, send tote to WCS
            IF @cDropID <> ''
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Send IML'

               --Trigger MSG to WCS 
               EXEC rdt.rdt_839SendMsgToWCS @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
                  ,@cPickSlipNo
                  ,@cDropID
                  ,@nErrNo       OUTPUT
                  ,@cErrMsg      OUTPUT
               IF @nErrNo <> 0
                  GOTO Quit
            END -- dropid <> ''
         END
      END --step_4
      --V1.2.0 end
    
      IF @nStep = 5 OR (@nStep = 99 AND @nScn = 6524) -- Close DropID or Short pick
      BEGIN
         --IF @nInputKey = 1 AND @cOption IN ('1', '3') -- ENTER and close drop ID --NLT013 option = 1 is short pick, need trigger msg to WCS
         IF @nInputKey = 1 AND @cOption IN ('3') -- only send IML when user close the current dropid on short pick screen --V1.2.0
         BEGIN
            -- Using drop ID, send tote to WCS
            IF @cDropID <> ''
            BEGIN
               --Trigger MSG to WCS 
               EXEC rdt.rdt_839SendMsgToWCS @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
                  ,@cPickSlipNo
                  ,@cDropID
                  ,@nErrNo       OUTPUT
                  ,@cErrMsg      OUTPUT
               IF @nErrNo <> 0
                  GOTO Quit
            END
         END

         IF @nInputKey = 1 AND @cOption IN ('1', '9') --V1.1
         BEGIN
            SELECT 
                  @cReasonCode = code2,
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
         END
      END

      IF @nStep = 7 -- Confirm pick loc
      BEGIN
         IF @nInputKey = 0 --Esc
         BEGIN
            -- Using drop ID, send tote to WCS
            IF @cDropID <> ''
            BEGIN
               --Trigger MSG to WCS 
               EXEC rdt.rdt_839SendMsgToWCS @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
                  ,@cPickSlipNo
                  ,@cDropID
                  ,@nErrNo       OUTPUT
                  ,@cErrMsg      OUTPUT
               IF @nErrNo <> 0
                  GOTO Quit
            END 
         END
      END

      IF @nStep = 8 -- Abort Picking
      BEGIN
         IF @nInputKey = 1 AND @cOption ='1' -- ENTER and close drop ID
         BEGIN
            -- Using drop ID, send tote to WCS
            IF @cDropID <> ''
            BEGIN
               --Trigger MSG to WCS 
               EXEC rdt.rdt_839SendMsgToWCS @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
                  ,@cPickSlipNo
                  ,@cDropID
                  ,@nErrNo       OUTPUT
                  ,@cErrMsg      OUTPUT
               IF @nErrNo <> 0
                  GOTO Quit
            END 
         END
      END      
   END
Quit:


END
GO
GRANT EXECUTE ON  [RDT].[rdt_839ExtUpd07] TO [NSQL]
GO

