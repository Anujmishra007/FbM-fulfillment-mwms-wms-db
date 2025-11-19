SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************************************/
/* Store procedure: rdt_838ExtUpd22                                                                */
/* Copyright      : Maersk                                                                         */
/*                                                                                                 */
/* Date       Rev  Author      Purposes                                                            */
/* 2025-11-17 1.0  NickT       UWP-43907 Merge from V0 WMS-25533                                   */
/***************************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ExtUpd22] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cPickSlipNo      NVARCHAR( 10),
   @cFromDropID      NVARCHAR( 20),
   @nCartonNo        INT,
   @cLabelNo         NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),
   @nQTY             INT,
   @cUCCNo           NVARCHAR( 20),
   @cCartonType      NVARCHAR( 10),
   @cCube            NVARCHAR( 10),
   @cWeight          NVARCHAR( 10),
   @cRefNo           NVARCHAR( 20),
   @cSerialNo        NVARCHAR( 30),
   @nSerialQTY       INT,
   @cOption          NVARCHAR( 1),
   @cPackDtlRefNo    NVARCHAR( 20),
   @cPackDtlRefNo2   NVARCHAR( 20),
   @cPackDtlUPC      NVARCHAR( 30),
   @cPackDtlDropID   NVARCHAR( 20),
   @cPackData1       NVARCHAR( 30),
   @cPackData2       NVARCHAR( 30),
   @cPackData3       NVARCHAR( 30),
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount        INT
   DECLARE @cOrderKey         NVARCHAR( 10)
   DECLARE @nWeight           FLOAT
   DECLARE @nCube             FLOAT
   DECLARE @nCartonWeight     FLOAT
   DECLARE @nCartonCube       FLOAT
   DECLARE @nCartonLength     FLOAT
   DECLARE @nCartonWidth      FLOAT
   DECLARE @nCartonHeight     FLOAT

   SET @nTranCount = @@TRANCOUNT

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 4-- Pack info
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE @cLabelPrinter NVARCHAR( 10)
            DECLARE @cPaperPrinter NVARCHAR( 10)

            IF @cCartonType = 'SKIP'
            BEGIN
               -- Get report info
               DECLARE @cPreLabelNo NVARCHAR( 10)
               SET @cPreLabelNo = rdt.RDTGetConfig( @nFunc, 'PreLabelNo', @cStorerKey)
               IF @cPreLabelNo = '0'
                  SET @cPreLabelNo = ''

               -- Print pre-labelno (for 1st screen, scan at TO DROP ID, to continue packing that carton)
               IF @cPreLabelNo <> ''
               BEGIN
                  -- Get session info
                  SELECT 
                     @cLabelPrinter = Printer, 
                     @cPaperPrinter = Printer_Paper
                  FROM rdt.rdtMobRec WITH (NOLOCK)
                  WHERE Mobile = @nMobile

                  -- Get report param
                  DECLARE @tPreLabelNo AS VariableTable
                  INSERT INTO @tPreLabelNo (Variable, Value) VALUES
                     ( '@cStorerKey',     @cStorerKey),
                     ( '@cLabelNo',       @cLabelNo)

                  -- Print pre-labelno list
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                     @cPreLabelNo, -- Report type
                     @tPreLabelNo, -- Report params
                     'rdt_838ExtUpd22',
                     0, -- @nErrNo  OUTPUT,
                     '' -- @cErrMsg OUTPUT
                  -- IF @nErrNo <> 0
                  --    GOTO Quit
               END
            END
            
            IF @cCartonType <> 'SKIP'
            BEGIN
               -- Get PackHeader info
               SELECT @cOrderKey = OrderKey FROM PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo
               
               -- Get PackDetail info
               SELECT
                  @nQTY = SUM( PD.QTY),
                  @nWeight = SUM( PD.QTY * SKU.Weight)
               FROM PackDetail PD WITH (NOLOCK)
                  JOIN SKU WITH (NOLOCK) ON (PD.StorerKey = SKU.StorerKey AND PD.SKU = SKU.SKU)
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.CartonNo = @nCartonNo

               -- Get carton info
               SELECT TOP 1
                  @nCartonWeight = ISNULL( CartonWeight, 0),
                  @nCartonLength = ISNULL( CartonLength, 0),
                  @nCartonWidth  = ISNULL( CartonWidth, 0),
                  @nCartonHeight = ISNULL( CartonHeight, 0)
               FROM Storer S WITH (NOLOCK)
                  JOIN Cartonization C WITH (NOLOCK) ON (S.CartonGroup = C.CartonizationGroup)
               WHERE S.StorerKey = @cStorerKey
                  AND C.CartonType = @cCartonType

               -- Get SKU info
               IF @nCartonLength = 0 OR
                  @nCartonWidth  = 0 OR
                  @nCartonHeight = 0
                  SELECT
                     @nCartonLength = CASE WHEN @nCartonLength = 0 THEN MAX( ISNULL( SKU.Length, 0)) ELSE @nCartonLength END, 
                     @nCartonWidth  = CASE WHEN @nCartonWidth  = 0 THEN MAX( ISNULL( SKU.Width, 0))  ELSE @nCartonWidth  END, 
                     @nCartonHeight = CASE WHEN @nCartonHeight = 0 THEN MAX( ISNULL( SKU.Height, 0)) ELSE @nCartonHeight END 
                  FROM PackDetail PD WITH (NOLOCK)
                     JOIN SKU WITH (NOLOCK) ON (PD.StorerKey = SKU.StorerKey AND PD.SKU = SKU.SKU)
                  WHERE PD.PickSlipNo = @cPickSlipNo
                     AND PD.CartonNo = @nCartonNo
               
               -- Calc weight, cube
               SET @nWeight = @nWeight + @nCartonWeight
               SET @nCartonCube = @nCartonLength * @nCartonWidth * @nCartonHeight
               
               -- Handling transaction
               BEGIN TRAN  -- Begin our own transaction
               SAVE TRAN rdt_838ExtUpd22 -- For rollback or commit only our own transaction
               
               -- Pack info
               UPDATE dbo.PackInfo SET
                  Weight = @nWeight,
                  Cube = @nCartonCube, 
                  QTY = @nQTY, 
                  CartonType = @cCartonType, 
                  Length = @nCartonLength, 
                  Width = @nCartonWidth, 
                  Height = @nCartonHeight, 
                  EditDate = GETDATE(), 
                  EditWho = SUSER_SNAME()
               WHERE PickSlipNo = @cPickSlipNo
                  AND CartonNo = @nCartonNo

               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 217401
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- UPD PKInf Fail
                  GOTO RollBackTran
               END
               
               DECLARE @bSuccess INT = 0
               EXEC isp_Carrier_Middleware_Interface 
                  @cOrderKey, 
                  '', -- MBOLKey
                  @nFunc, 
                  @nCartonNo, 
                  @nStep, 
                  @bSuccess OUTPUT, 
                  @nErrNo   OUTPUT, 
                  @cErrMsg  OUTPUT
               IF @bSuccess <> 1 OR @nErrNo <> 0
               BEGIN
                  SET @nErrNo = 217402
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Interface Fail
                  GOTO RollBackTran
               END
               
               COMMIT TRAN rdt_838ExtUpd22
               WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                  COMMIT TRAN
               
               -- Get session info
               SELECT 
                  @cLabelPrinter = Printer, 
                  @cPaperPrinter = Printer_Paper
               FROM rdt.rdtMobRec WITH (NOLOCK)
               WHERE Mobile = @nMobile  
               
               -- Get report info
               DECLARE @cSSCCLabel     NVARCHAR( 10)
               DECLARE @cReturnFlyer   NVARCHAR( 10)
               DECLARE @cVASLabel      NVARCHAR( 10)
               
               SET @cSSCCLabel = rdt.RDTGetConfig( @nFunc, 'SSCCLabel', @cStorerKey)
               IF @cSSCCLabel = '0'
                  SET @cSSCCLabel = ''
               SET @cReturnFlyer = rdt.RDTGetConfig( @nFunc, 'RTNFlyer', @cStorerKey)
               IF @cReturnFlyer = '0'
                  SET @cReturnFlyer = ''
               SET @cVASLabel = rdt.RDTGetConfig( @nFunc, 'VASLabel', @cStorerKey)
               IF @cVASLabel = '0'
                  SET @cVASLabel = ''
               
               -- Print SSCC label
               IF @cSSCCLabel <> ''
               BEGIN
                  -- Get report param
                  DECLARE @tSSCCLabel AS VariableTable
                  INSERT INTO @tSSCCLabel (Variable, Value) VALUES
                     ( '@cStorerKey',     @cStorerKey),
                     ( '@cPickSlipNo',    @cPickSlipNo),
                     ( '@cFromDropID',    @cFromDropID),
                     ( '@cPackDtlDropID', @cPackDtlDropID),
                     ( '@cLabelNo',       @cLabelNo),
                     ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))

                  -- Print packing list
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                     @cSSCCLabel, -- Report type
                     @tSSCCLabel, -- Report params
                     'rdt_838ExtUpd22',
                     0, -- @nErrNo  OUTPUT,
                     '' -- @cErrMsg OUTPUT
                  -- IF @nErrNo <> 0
                  --    GOTO Quit
               END

               -- Return flyer
               IF @cReturnFlyer <> ''
               BEGIN
                  -- Common params
                  DECLARE @tReturnFlyer VariableTable
                  INSERT INTO @tReturnFlyer (Variable, Value) VALUES 
                     ( '@cStorerKey',     @cStorerKey), 
                     ( '@cLabelNo',       @cLabelNo)

                  -- Print label
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter, 
                     @cReturnFlyer, -- Report type
                     @tReturnFlyer, -- Report params
                     'rdt_838ExtUpd22', 
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT 
                  IF @nErrNo <> 0
                     GOTO Quit
               END

               -- VAS label
               IF @cVASLabel <> ''
               BEGIN
                  -- Common params
                  DECLARE @tVASLabel VariableTable
                  INSERT INTO @tVASLabel (Variable, Value) VALUES 
                     ( '@cStorerKey',     @cStorerKey), 
                     ( '@cLabelNo',       @cLabelNo)

                  -- Print label
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter, 
                     @cVASLabel, -- Report type
                     @tVASLabel, -- Report params
                     'rdt_838ExtUpd22', 
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT 
                  IF @nErrNo <> 0
                     GOTO Quit

               END
               
               -- Pack confirm
               EXEC rdt.rdt_Pack_PackConfirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
                  ,@cPickSlipNo
                  ,@cFromDropID
                  ,@cPackDtlDropID
                  ,'' -- @cPrintPackList OUTPUT
                  ,@nErrNo         OUTPUT
                  ,@cErrMsg        OUTPUT
               IF @nErrNo <> 0
                  GOTO Quit
                  
               -- Print pack list, delivery note, gift card
               IF EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status = '9')
               BEGIN
                  -- Get report info
                  DECLARE @cPackList      NVARCHAR( 10)
                  DECLARE @cDeliveryNote  NVARCHAR( 10)
                  DECLARE @cGiftCard      NVARCHAR( 10)

                  SET @cPackList = rdt.RDTGetConfig( @nFunc, 'PackList1', @cStorerKey) -- If using the standard PACKLIST, it will prompt to confirm print
                  IF @cPackList = '0'
                     SET @cPackList = ''
                  SET @cDeliveryNote = rdt.RDTGetConfig( @nFunc, 'DeliveryNote', @cStorerKey)
                  IF @cDeliveryNote = '0'
                     SET @cDeliveryNote = ''                    
                  SET @cGiftCard = rdt.RDTGetConfig( @nFunc, 'GiftCard', @cStorerKey)
                  IF @cGiftCard = '0'
                     SET @cGiftCard = ''
                  
                  -- Print pack list
                  IF @cPackList <> ''
                  BEGIN
                     -- Get report param
                     DECLARE @tPackList AS VariableTable
                     INSERT INTO @tPackList (Variable, Value) VALUES
                        ( '@cStorerKey',     @cStorerKey),
                        ( '@cOrderKey',      @cOrderKey)

                     -- Print packing list
                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                        @cPackList, -- Report type
                        @tPackList, -- Report params
                        'rdt_838ExtUpd22',
                        0, -- @nErrNo  OUTPUT,
                        '' -- @cErrMsg OUTPUT
                     -- IF @nErrNo <> 0
                     --    GOTO Quit
                  END
                  
                  -- Print delivery note
                  IF @cDeliveryNote <> ''
                  BEGIN
                     -- Get report param
                     DECLARE @tDeliveryNote AS VariableTable
                     INSERT INTO @tDeliveryNote (Variable, Value) VALUES
                        ( '@cStorerKey',     @cStorerKey),
                        ( '@cOrderKey',      @cOrderKey)

                     -- Print packing list
                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                        @cDeliveryNote, -- Report type
                        @tDeliveryNote, -- Report params
                        'rdt_838ExtUpd22',
                        0, -- @nErrNo  OUTPUT,
                        '' -- @cErrMsg OUTPUT
                     -- IF @nErrNo <> 0
                     --    GOTO Quit
                  END
                  
                  -- Gift Card
                  IF @cGiftCard <> '' 
                  BEGIN
                     IF EXISTS( SELECT 1 FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey AND Notes2 LIKE 'Z20%')
                     BEGIN
                        -- Common params
                        DECLARE @tGiftCard VariableTable
                        INSERT INTO @tGiftCard (Variable, Value) VALUES 
                           ( '@cStorerKey',     @cStorerKey), 
                           ( '@cOrderKey',      @cOrderKey)

                        -- Print label
                        EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter, 
                           @cGiftCard, -- Report type
                           @tGiftCard, -- Report params
                           'rdt_838ExtUpd22', 
                           @nErrNo  OUTPUT,
                           @cErrMsg OUTPUT 
                        IF @nErrNo <> 0
                           GOTO Quit
                     END
                  END
                  
                  -- For ECOM
                  IF EXISTS( SELECT 1 FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey AND DocType = 'E')
                  BEGIN
                     -- Packing instruction 
                     DECLARE @cMsg1 NVARCHAR( 20) = '' 
                     DECLARE @cMsg2 NVARCHAR( 20) = '' 
                     DECLARE @cMsg3 NVARCHAR( 20) = '' 
                     DECLARE @cMsg4 NVARCHAR( 20) = '' 
                     DECLARE @cMsg5 NVARCHAR( 20) = '' 
                     DECLARE @cMsg6 NVARCHAR( 20) = '' 
                     DECLARE @cMsg7 NVARCHAR( 20) = '' 
                     DECLARE @cMsg8 NVARCHAR( 20) = '' 
                     DECLARE @cMsg9 NVARCHAR( 20) = '' 
                     DECLARE @cNotes NVARCHAR( MAX)
                     DECLARE @tPackInstruction VariableTable

                     DECLARE @tMsg TABLE
                     (
                        RowRef INT NOT NULL IDENTITY( 1, 1), 
                        Msg    NVARCHAR( 20) NOT NULL
                     ) 

                     -- Notify operator put report into last carton
                     INSERT INTO @tMsg (Msg) VALUES (rdt.rdtgetmessage( 217403, @cLangCode,'DSP')) -- ORDER PACKED
                     INSERT INTO @tMsg (Msg) VALUES ('')
                     INSERT INTO @tMsg (Msg) VALUES (rdt.rdtgetmessage( 217404, @cLangCode,'DSP')) -- RETFLYER REQUIRED
                     
                     -- Get order detail info
                     SELECT @cNotes = STRING_AGG( Notes, '|') FROM dbo.OrderDetail WITH (NOLOCK) WHERE OrderKey = @cOrderKey AND ISNULL( Notes, '') <> ''
                     INSERT INTO @tPackInstruction (Variable, Value) 
                     SELECT '', value
                     FROM STRING_SPLIT( @cNotes, '|')
                     WHERE value <> ''

                     -- Gift card
                     IF EXISTS( SELECT TOP 1 1 FROM @tPackInstruction WHERE value in ('YGM')) INSERT INTO @tMsg (Msg) VALUES (rdt.rdtgetmessage( 217405, @cLangCode,'DSP')) -- GIFT CARD REQUIRED        
                     IF EXISTS( SELECT TOP 1 1 FROM @tPackInstruction WHERE value in ('YGW')) INSERT INTO @tMsg (Msg) VALUES (rdt.rdtgetmessage( 217406, @cLangCode,'DSP')) -- GIFT BOX REQUIRED
                     IF EXISTS( SELECT TOP 1 1 FROM @tPackInstruction WHERE value in ('PRV')) INSERT INTO @tMsg (Msg) VALUES (rdt.rdtgetmessage( 217407, @cLangCode,'DSP')) -- HB SHIPPING PAPERBAG

                     -- Get order info
                     DECLARE @cBuyerPO NVARCHAR( 20)
                     SELECT @cBuyerPO = ISNULL( BuyerPO, '') FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey

                     IF @cBuyerPO LIKE '%ZPU%' OR @cBuyerPO LIKE '%ZTO%' INSERT INTO @tMsg (Msg) VALUES ('')                 -- Blank line
                     IF @cBuyerPO LIKE '%ZPU%' INSERT INTO @tMsg (Msg) VALUES (rdt.rdtgetmessage( 217408, @cLangCode,'DSP')) -- NEED PICK-UP LABEL
                     IF @cBuyerPO LIKE '%ZTO%' INSERT INTO @tMsg (Msg) VALUES (rdt.rdtgetmessage( 217409, @cLangCode,'DSP')) -- NEED TRY-ON LABEL
                     
                     -- Get instruction
                     SELECT 
                        @cMsg1 = CASE WHEN RowRef = 1 THEN Msg ELSE @cMsg1 END, 
                        @cMsg2 = CASE WHEN RowRef = 2 THEN Msg ELSE @cMsg2 END, 
                        @cMsg3 = CASE WHEN RowRef = 3 THEN Msg ELSE @cMsg3 END, 
                        @cMsg4 = CASE WHEN RowRef = 4 THEN Msg ELSE @cMsg4 END, 
                        @cMsg5 = CASE WHEN RowRef = 5 THEN Msg ELSE @cMsg5 END, 
                        @cMsg6 = CASE WHEN RowRef = 6 THEN Msg ELSE @cMsg6 END, 
                        @cMsg7 = CASE WHEN RowRef = 7 THEN Msg ELSE @cMsg7 END, 
                        @cMsg8 = CASE WHEN RowRef = 8 THEN Msg ELSE @cMsg8 END, 
                        @cMsg9 = CASE WHEN RowRef = 9 THEN Msg ELSE @cMsg9 END 
                     FROM @tMsg
                     
                     -- Prompt
                     EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @cMsg1, @cMsg2, @cMsg3, @cMsg4, @cMsg5, @cMsg6, @cMsg7, @cMsg8, @cMsg9
                  END
                  ELSE
                  BEGIN
                     -- Notify operator put report into last carton
                     IF @cPackList <> '' OR @cDeliveryNote <> ''
                     BEGIN
                        SET @cMsg1 = rdt.rdtgetmessage( 217410, @cLangCode,'DSP') -- ORDER PACKED        
                        SET @cMsg2 = rdt.rdtgetmessage( 217411, @cLangCode,'DSP') -- PUT PACKLIST/DELNOTE
                        SET @cMsg3 = rdt.rdtgetmessage( 217412, @cLangCode,'DSP') -- IN LAST CARTON      
                        
                        EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', @cMsg1, '', @cMsg2, @cMsg3
                     END
                  END
               END
            END
         END
      END
   END
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_838ExtUpd22 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO
GRANT EXECUTE ON  [RDT].[rdt_838ExtUpd22] TO [NSQL]
GO
