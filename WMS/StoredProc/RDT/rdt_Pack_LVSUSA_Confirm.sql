
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_Pack_LVSUSA_Confirm                             */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Confirm logic for LVSUSA Packing                            */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 2024-10-23 1.0  JCH507      FCR-946 Created                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_Pack_LVSUSA_Confirm] (
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@nInputKey       INT
   ,@cFacility       NVARCHAR( 5)
   ,@cStorerKey      NVARCHAR( 15)
   ,@cType           NVARCHAR( 10) -- fcr-946 NEW, MERGE
   ,@cMasterLabelNo  NVARCHAR( 20) --fcr-946
   ,@cSKU            NVARCHAR( 20) 
   ,@nQTY            INT
   ,@cUCCNo          NVARCHAR( 20) 
   ,@cSerialNo       NVARCHAR( 30) 
   ,@nSerialQTY      INT
   ,@cPackDtlRefNo   NVARCHAR( 20)
   ,@cPackDtlRefNo2  NVARCHAR( 20)
   ,@cPackDtlUPC     NVARCHAR( 30)
   ,@cPackDtlDropID  NVARCHAR( 20)
   ,@nCartonNo       INT           OUTPUT
   ,@cLabelNo        NVARCHAR( 20) OUTPUT
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR(250) OUTPUT
   ,@nBulkSNO        INT
   ,@nBulkSNOQTY     INT
   ,@cPackData1      NVARCHAR( 30)
   ,@cPackData2      NVARCHAR( 30)
   ,@cPackData3      NVARCHAR( 30)
   ,@nUseStandard    INT = 0
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @cSQL           NVARCHAR(MAX)
   DECLARE @cSQLParam      NVARCHAR(MAX)
   DECLARE @cConfirmSP     NVARCHAR(20) = ''

   -- Get storer configure
   IF @nUseStandard = 0
   BEGIN
      SET @cConfirmSP = rdt.RDTGetConfig( @nFunc, 'ConfirmSP', @cStorerKey)
      IF @cConfirmSP = '0'
         SET @cConfirmSP = ''
   END
   
   /***********************************************************************************************
                                              Custom confirm
   ***********************************************************************************************/
   -- Custom logic
   IF @cConfirmSP <> '' 
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cConfirmSP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cConfirmSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, @cMasterLabelNo, ' +
            ' @cSKU, @nQTY, @cUCCNo, @cSerialNo, @nSerialQTY, @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, ' + 
            ' @nCartonNo OUTPUT, @cLabelNo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, ' + 
            ' @nBulkSNO, @nBulkSNOQTY, @cPackData1, @cPackData2, @cPackData3 '

         SET @cSQLParam =
            ' @nMobile        INT,           ' + 
            ' @nFunc          INT,           ' + 
            ' @cLangCode      NVARCHAR( 3),  ' + 
            ' @nStep          INT,           ' + 
            ' @nInputKey      INT,           ' + 
            ' @cFacility      NVARCHAR( 5),  ' + 
            ' @cStorerKey     NVARCHAR( 15), ' +   
            ' @cType          NVARCHAR( 10), ' +   
            ' @cMasterLabelNo NVARCHAR( 20), ' +   
            ' @cSKU           NVARCHAR( 20), ' +   
            ' @nQTY           INT,           ' + 
            ' @cUCCNo         NVARCHAR( 20), ' + 
            ' @cSerialNo      NVARCHAR( 30), ' +   
            ' @nSerialQTY     INT,           ' + 
            ' @cPackDtlRefNo  NVARCHAR( 20), ' + 
            ' @cPackDtlRefNo2 NVARCHAR( 20), ' + 
            ' @cPackDtlUPC    NVARCHAR( 30), ' + 
            ' @cPackDtlDropID NVARCHAR( 20), ' + 
            ' @nCartonNo      INT           OUTPUT, ' + 
            ' @cLabelNo       NVARCHAR( 20) OUTPUT, ' + 
            ' @nErrNo         INT           OUTPUT, ' + 
            ' @cErrMsg        NVARCHAR(250) OUTPUT, ' + 
            ' @nBulkSNO       INT           , ' + 
            ' @nBulkSNOQTY    INT           , ' + 
            ' @cPackData1     NVARCHAR( 30) , ' + 
            ' @cPackData2     NVARCHAR( 30) , ' + 
            ' @cPackData3     NVARCHAR( 30)   '
            
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, @cMasterLabelNo, 
            @cSKU, @nQTY, @cUCCNo, @cSerialNo, @nSerialQTY, @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, 
            @nCartonNo OUTPUT, @cLabelNo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, 
            @nBulkSNO, @nBulkSNOQTY, @cPackData1, @cPackData2, @cPackData3

         GOTO Quit
      END
   END

   /***********************************************************************************************
                                             Standard confirm
   ***********************************************************************************************/
   DECLARE @bSuccess    INT
   DECLARE @cLabelLine  NVARCHAR( 5)
   DECLARE @cNewLine    NVARCHAR( 1)
   DECLARE @cNewCarton  NVARCHAR( 1)
   DECLARE @cDropID     NVARCHAR( 20) = ''
   DECLARE @cRefNo      NVARCHAR( 20) = ''
   DECLARE @cRefNo2     NVARCHAR( 30) = ''
   DECLARE @cUPC        NVARCHAR( 30) = ''  


   
   DECLARE @cGenLabelNo_SP       NVARCHAR( 20)
   DECLARE @cPackDetailCartonID  NVARCHAR( 20)
   DECLARE @cPackByFromDropID    NVARCHAR( 1)

   DECLARE @cPSNO          NVARCHAR( 20)
   DECLARE @nFromCartonNo  INT
   DECLARE @cFromLabeLLine NVARCHAR( 5)
   DECLARE @nFromQty       INT

   DECLARE @nBalQty              INT
   DECLARE @nAdjustQty           INT

   DECLARE @nTranCount INT
   DECLARE @bDebugFlag BINARY = 1

   DECLARE @tMoveLog TABLE
   (
      PickSlipNo  NVARCHAR( 10) NOT NULL,
      LabelNo     NVARCHAR( 10) NOT NULL,
      SKU         NVARCHAR( 20) NOT NULL,
      MoveQty     INT
   )

   -- Generic Validation
   IF @cType NOT IN ('NEW','MERGE')
   BEGIN
      SET @nErrNo = 227601
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Inv type
      GOTO Quit
   END

   IF NOT EXISTS (SELECT 1 FROM PackDetail WITH (NOLOCK)
                  WHERE LabelNo = @cMasterLabelNo
                     AND SKU = @cSKU)
   BEGIN
      SET @nErrNo = 227602
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Inv type
      GOTO Quit
   END


   IF @cType = 'NEW'
   BEGIN
      --Generate LabelNo if it is new carton
      IF @cLabelNo = ''
      BEGIN
         IF @bDebugFlag = 1
            SELECT 'Generate CartonNo'

         SET @cGenLabelNo_SP = rdt.RDTGetConfig( @nFunc, 'GenLabelNo_SP', @cStorerkey)
         IF @cGenLabelNo_SP = '0'
            SET @cGenLabelNo_SP = ''

         IF @cGenLabelNo_SP <> ''
         BEGIN
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cGenLabelNo_SP AND type = 'P')  
            BEGIN
               SET @cSQL = 'EXEC dbo.' + RTRIM( @cGenLabelNo_SP) +
                  ' @cPSNO, ' +  --fcr-946
                  ' @nCartonNo,   ' +  
                  ' @cLabelNo     OUTPUT '  
               SET @cSQLParam =
                  ' @cPSNO  NVARCHAR(10),       ' +  --fcr-946
                  ' @nCartonNo    INT,                ' +  
                  ' @cLabelNo     NVARCHAR(20) OUTPUT '  
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @cPSNO, --fcr-946
                  @nCartonNo, 
                  @cLabelNo OUTPUT
            END
         END
         ELSE
         BEGIN   
            EXEC isp_GenUCCLabelNo
               @cStorerKey,
               @cLabelNo      OUTPUT, 
               @bSuccess      OUTPUT,
               @nErrNo        OUTPUT,
               @cErrMsg       OUTPUT
            IF @nErrNo <> 0
            BEGIN
               SET @nErrNo = 100402
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
               GOTO RollBackTran
            END
         END

         IF @cLabelNo = ''
         BEGIN
            SET @nErrNo = 227603
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
            GOTO RollBackTran
         END

         IF @bDebugFlag = 1
            SELECT 'Label No Generated', @cLabelNo AS NewLabelNo

         SET @cLabelLine = ''   
         SET @cNewLine = 'Y'
         SET @cNewCarton = 'Y'
         --SET @nCartonNo = 0
      END -- Generate new lableno

      SET @nBalQty = @nQty

      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdt_Pack_LVSUSA_Confirm -- For rollback or commit only our own transaction

      WHILE @nBalQTY > 0
      BEGIN
         SELECT TOP 1
            @cPSNO            = PickSlipNo,
            @nFromCartonNo    = CartonNo,
            @cFromLabelLine   = LabelLine,
            @nFromQTY         = Qty
         FROM PackDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND @cLabelNo = @cMasterLabelNo
            AND @cSKU = SKU
         ORDER BY Qty DESC

         IF @bDebugFlag = 1
         BEGIN
            SELECT 'Handling PackDetail'
            SELECT @cPSNO AS PSNO, @cMasterLabelNo AS MasterLableNo, @nFromCartonNo AS MasterCartonNo, @cFromLabelLine AS FromLabelLine,
                     @nFromQty AS FromQty, @cLabelNo AS ToLabelNo
         END
         
         -- Handle master carton start
         IF @nBalQty < @nFromQTY
         BEGIN
            UPDATE PackDetail WITH (ROWLOCK)
            SET Qty = @nFromQty - @nBalQty
            WHERE PickSlipNo = @cPSNO
               AND CartonNo = @nFromCartonNo
               AND LabelNo = @cMasterLabelNo
               AND LableLine = @cFromLabelLine

            IF @@Error <> 0
            BEGIN
               SET @nErrNo = 227604
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd PackDetail Fail
               GOTO RollBackTran
            END

            SET @nAdjustQty = @nBalQTY

            IF @bDebugFLag = 1
               SELECT '@BalQty < @FromQty', @nAdjustQty AS AdjustQty

            BREAK
         END -- BalQty < FromQty
         ELSE
         BEGIN
            SET @nAdjustQty = @nFromQty

            DELETE PackDetail WITH (ROWLOCK)
            WHERE PickSlipNo = @cPSNO
               AND CartonNo = @nFromCartonNo
               AND LabelNo = @cMasterLabelNo
               AND LableLine = @cFromLabelLine
            IF @@Error <> 0
            BEGIN
               SET @nErrNo = 227604
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Del PackDetail Fail
               GOTO RollBackTran
            END

            IF @bDebugFlag = 1
               SELECT '@BalQty >= @FromQty', @nAdjustQty AS AdjustQty, @nBalQty AS LeftBalQty
         END--BalQty >= FromQty

         -- Handle Master Carton END

         --Handle To Carton Start
         IF @cNewCarton = 'Y'
         BEGIN
            IF @bDebugFlag = 1
               SELECT 'Insert new carton'

            --PackdetailAdd trigger will handle cartonNo and LabelLine
            INSERT INTO PackDetail (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, Qty)
            VALUES (cPSNO, 0, @cLabelNo, '', @cStorerKey, @cSKU, @nAdjustQty) 
            
            IF @@Error <> 0
            BEGIN
               SET @nErrNo = 227606
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins PackDetail Fail
               GOTO RollBackTran
            END


            --PackdetailAdd trigger will handle packinfo generation
            /*
            INSERT INTO PackInfo (PickSlipNO, CartonNo, Qty)
            SELECT @cPSNO,
                   COALESCE(MAX(CartonNo),0) + 1,
                   @nQty
            FROM PackDetail WITH (NOLOCK)
            WHERE PickSlipNo = @cPSNO

            IF @@Error <> 0
            BEGIN
               SET @nErrNo = 227607
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins PackInfo Fail
               GOTO RollBackTran
            END*/
         END -- New Carton
         ELSE
         BEGIN-- Existing carton existing label line
            IF EXISTS (SELECT 1 FROM PackDetail WITH (NOLOCK)
                        WHERE PickSlipNO = @cPSNO
                           AND LabelNo = @cLabelNo
                           AND SKU = @cSKU)
            BEGIN
               IF @bDebugFlag = 1
                  SELECT 'Add Qty to existing PackDetail'

               UPDATE PackDetail WITH (ROWLOCK)
               SET Qty = Qty + @nAdjustQty
               WHERE PickSlipNo = @cPSNO
                  AND LabelNo = @cLabelNo
                  AND SKU = @cSKU

               IF @@Error <> 0
               BEGIN
                  SET @nErrNo = 227608
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd Packdetail Fail
                  GOTO RollBackTran
               END
            END -- Update existing toCarton record
            ELSE--Add new label line
            BEGIN
               IF @bDebugFlag = 1
                  SELECT 'Add new label line to the existing carton'

               INSERT INTO PackDetail (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, Qty)
               SELECT PickSlipNo,
                     CartonNO,
                     @cLabelNo,
                     RIGHT( '00000' + CAST( CAST( ISNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5),
                     @cStorerKey,
                     @cSKU,
                     @nQty
               FROM PackDetail WITH (NOLOCK)
               WHERE PickSlipNo = @cPSNO
                  AND LabelNo = @cLabelNo

               IF @@Error <> 0
               BEGIN
                  SET @nErrNo = 227609
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins PackDetail Fail
                  GOTO RollBackTran
               END
            END-- Add new label line
         END -- Existing Carton

         -- Log the label adjustment for pickdetail handling
         BEGIN TRY
            INSERT INTO @tMoveLog (PickSlipNo, LabelNo, SKU, MoveQty)
            VALUES (@cPSNO, @cMasterLableNo, @cSKU, -@nAdjustQty)

            INSERT INTO @tMoveLog (PickSlipNo, LabelNo, SKU, MoveQty)
            VALUES (@cPSNO, @cLableNo, @cSKU, @nAdjustQty)
         END TRY
         BEGIN CATCH
            SET @nErrNo = 227610
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins PackDetail Fail
            GOTO RollBackTran
         END CATCH  
         --Handle toCarton End

         SET @nBalQTY = @nBalQty - @nFromQty

      END -- end while

      --Reorganize the label no in the cases start
      ;WITH LabelRenumbered AS (
      SELECT PickSlipNo, 
             CartonNo, 
             LabelNo, 
             LabelLine, 
             ROW_NUMBER() OVER (PARTITION BY PickSlipNo, CartonNo, LabelNo ORDER BY LabelLine) AS NewLabelNo
      FROM PackDetail WITH (NOLOCK)
         WHERE LabelNo IN (@cMasterLabelNo, @cLabelNo)
      )

      UPDATE PackDetail
         SET LabelNo = RIGHT(REPLICATE('0',5)+CAST(LabelRenumbered.NewLabelNo AS VARCHAR), 5)
      FROM LabelRenumbered
      WHERE PackDetail.PickSlipNo = LabelRenumbered.PickSlipNo
         AND PackDetail.CartonNo = LabelRenumbered.CartonNo
         AND PackDetail.LabelNo = LabelRenumbered.LabelNo
         AND PackDetail.LabelLine = LabelRenumbered.LabelLine;
      --Reorganize the label no in the cases end
      
      
   END -- NEW


   /*
   EXEC RDT.rdt_STD_EventLog           
   @cActionType         = '3',              
   @nMobileNo           = @nMobile,        
   @nFunctionID         = @nFunc,        
   @cFacility           = @cFacility,        
   @cStorerKey          = @cStorerkey,       
   @nQTY                = @nQTY,          
   @cUCC                = @cUCCNo,    
   @cOrderKey           = @cOrderKey,    
   @cSKU                = @cSKU,  
   @cRefNo1             = @nCartonNo,
   @cPickSlipNo         = @cPickSlipNo,   -- ZG01
   @cLabelNo            = @cLabelNo       -- ZG01*/

   COMMIT TRAN rdt_Pack_LVSUSA_Confirm
   GOTO Quit

RollBackTran:
BEGIN
   ROLLBACK TRAN rdt_Pack_LVSUSA_Confirm -- Only rollback change made here
   IF @cNewCarton = 'Y'
   BEGIN
      SET @nCartonNo = 0
      SET @cLabelNo = ''
   END
END

Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
   
   IF @bDebugFlag = 1
      SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_Pack_LVSUSA_Confirm TO NSQL
GO