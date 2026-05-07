SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/************************************************************************/  
/* Store procedure: rdt_1812ExtUpdAU02                                  */  
/* Purpose: Extended Update                                             */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date         Author    Ver.  Purposes                                */  
/* 2025-05-26   SYC067    1.0   FCR-XXXX Created                        */  
/************************************************************************/  
  
CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ExtUpdAU02]  
   @nMobile         INT,  
   @nFunc           INT,  
   @cLangCode       NVARCHAR( 3),  
   @nStep           INT,  
   @nInputKey       INT,  
   @cTaskdetailKey  NVARCHAR( 10),  
   @cDropID         NVARCHAR( 20),  
   @nQTY            INT,  
   @cToLOC          NVARCHAR( 10),  
   @nErrNo          INT OUTPUT,  
   @cErrMsg         NVARCHAR( 20) OUTPUT,  
   @nAfterStep      INT  
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
   DECLARE @cLabelPrinter    NVARCHAR( 10)  
   DECLARE @cPaperPrinter    NVARCHAR( 10)  
   DECLARE @cOrderKey   NVARCHAR(10)  
   DECLARE @cFromLOC    NVARCHAR(10)  
  
  
   SELECT  
      @cUserName = userName,  
      @cStorerKey = StorerKey,  
      @cFacility = Facility,  
      @cPaperPrinter    = Printer_Paper,  
      @cLabelPrinter    = Printer  
   FROM rdt.RDTMOBREC WITH (NOLOCK)  
   WHERE mobile = @nMobile  
  
   -- Get task info  
   SELECT  
      @cStorerKey = StorerKey,  
      @cFromLOC = FromLOC,  
      @cOrderKey = OrderKey  
   FROM TaskDetail WITH (NOLOCK)  
   WHERE TaskDetailKey = @cTaskdetailKey  
  
   -- TM Case Pick  
   IF @nFunc = 1812  
   BEGIN  
      IF @nStep = 6 -- ToLOC  
      BEGIN  
         IF @nInputKey = 1  
         BEGIN  
            DECLARE @cLabelNo          NVARCHAR(20) = ''  
            DECLARE @cPickSlipNo       NVARCHAR(10) = ''  
            DECLARE @cLoadKey          NVARCHAR(10) = ''  
            DECLARE @nCartonNo         INT = 0  
  
            DECLARE @cClosePLTLbl        NVARCHAR( 10)  
  
            DECLARE @tClosePLTLbl  AS VariableTable  
  
            SET @cClosePLTLbl = rdt.RDTGetConfig( @nFunc, 'ClosePLTLbl', @cStorerKey)  
            IF @cClosePLTLbl = '0'  
               SET @cClosePLTLbl = ''  
  
  
            SELECT @cPickSlipNo = PH.PICKSLIPNO,  
                   @cOrderKey   = ISNULL(PH.ORDERKEY,''),  
                   @cLoadKey    = ISNULL(O.LOADKEY,'')  
            FROM PACKHEADER PH (NOLOCK)  
            JOIN ORDERS O (NOLOCK) ON PH.ORDERKEY = O.ORDERKEY  
            WHERE O.ORDERKEY = @cOrderKey  
  
            IF @cClosePLTLbl <> '' AND ISNULL(@cLabelPrinter,'') <> ''  
            BEGIN  
               DECLARE CUR CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
               SELECT DISTINCT LABELNO,CARTONNO  
               FROM PACKDETAIL WITH (NOLOCK)  
               WHERE STORERKEY = @cStorerKey  
               AND Pickslipno  = @cPickSlipNo  
               AND DROPID      = @cDropID  
               --AND STATUS = '5'  
  
               OPEN CUR  
  
               FETCH NEXT FROM CUR INTO @cLabelNo, @nCartonNo  
  
               WHILE @@FETCH_STATUS <> -1  
               BEGIN  
  
               DELETE FROM @tClosePLTLbl  
               INSERT INTO @tClosePLTLbl (Variable, Value) VALUES  
                  ( '@cStorerKey',     @cStorerKey),  
                  ( '@cPickSlipNo',    @cPickSlipNo),  
                  ( '@cFromDropID',    @cDropID),  
                  ( '@cPackDtlDropID', @cDropID),  
                  ( '@cLabelNo',       @cLabelNo),  
                  ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))  
  
               -- Print label  
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,  
                  @cClosePLTLbl, -- Report type  
                  @tClosePLTLbl, -- Report params  
                  'rdt_1812ExtUpdAU02',  
                  @nErrNo  OUTPUT,  
                  @cErrMsg OUTPUT  
  
                  FETCH NEXT FROM CUR INTO @cLabelNo, @nCartonNo  
               END  
               CLOSE CUR  
               DEALLOCATE CUR  
            END  
  
         /* PRINTING SSCC AT PICK CONFIRM SECTION INSTEAD  
            DECLARE @cConsigneeKey NVARCHAR( 15) = ''  
            DECLARE @cBillToKey    NVARCHAR( 20) = ''  
            DECLARE @cOrderType    NVARCHAR( 20) = ''  
  
            DECLARE @cCustomerType1     NVARCHAR( 20) = '' --PALLET / CASE  
            DECLARE @cCustomerType2     NVARCHAR( 20) = '' --SANDWICH / RAINBOW  
            DECLARE @cCustomerType3     NVARCHAR( 20) = '' --MAX SKU PER PALLET  
            DECLARE @cCustomerType4     NVARCHAR( 20) = '' --PALLET TYPE: CHEP / LOSCAM / PLAIN  
            DECLARE @cPlanningType     NVARCHAR( 20) = '' --WAVE / LOAD  
            DECLARE @cPWaveKey         NVARCHAR( 20) = ''  
            DECLARE @cPLoadkey         NVARCHAR( 20) = ''  
            DECLARE @cPickPalletType   NVARCHAR( 20) = ''  
            DECLARE @cPickCaseType     NVARCHAR( 20) = ''  
            DECLARE @cPickPieceType    NVARCHAR( 20) = ''  
            DECLARE @nLLIQty           INT = 0  
            DECLARE @nTOLLIQty         INT = 0  
            DECLARE @fPDCaseCnt        FLOAT  
            DECLARE @cPDUOM            NVARCHAR( 10) = ''  
  
            DECLARE @cPackMethod       NVARCHAR( 20) = '' --PALLET / CASE / PIECE  
            DECLARE @cPackCaseType     NVARCHAR( 20) = '' --SANDWICH / RAINBOW  
            DECLARE @nPackMaxSku       INT = 0 --MAX SKU PER PALLET  
            DECLARE @cPalletType       NVARCHAR( 20) = '' --CHEP / LOSCAM / PLAIN  
  
            DECLARE @cShipLabel          NVARCHAR( 10),  
                    @cCartonManifest     NVARCHAR( 10),  
                    @cCstLabelSP         NVARCHAR(30)  
  
            DECLARE @nCartonNo         INT  
  
            DECLARE @tShipLabel  AS VariableTable  
  
            SET @cShipLabel = rdt.RDTGetConfig( @nFunc, 'ShipLabel', @cStorerKey)  
            IF @cShipLabel = '0'  
               SET @cShipLabel = ''  
  
            IF @cOrderKey <> ''  
               SELECT @cConsigneeKey = ConsigneeKey, @cBillToKey = BillToKey, @cOrderType = [Type]  
                    , @cPWaveKey = UserDefine09, @cPLoadkey = LoadKey  
               FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey  
  
            --Get Pack config  
  
            --Else Check Pack Type by Customer  
            --1. Check if configured by order type (UDF01 = PALLET / CASE, UDF02 = SANDWICH / RAINBOW, UDF03 = MAX SKU PER PALLET)  
            --2. If no point 1 then Check if configured by storer (storerkey = consigneekey 1st, not exist then billtokey)  
            --                                     (SUSR1 = PALLET / CASE, SUSR2 = SANDWICH / RAINBOW, SUSR3 = MAX SKU PER PALLET)  
            --3. If no point 1/2 then Check if configured by wave/load release (get from:  
            --            DispatchPalletPickMethod = 'PALLET' / 'CASE'  
            --            DispatchCasePickMethod   = 'SWPALLET' (SANDWICH PALLET)  
            --                                      /'SWCASE'   (SANDWICH CASE)  
            --                                      /'RBPALLET' (RAINBOW PALLET)  
            --                                      /'RBCASE'   (RAINBOW CASE)  
            --                                      /'PALLET'   (PALLET)  
            --                                      /'CASE'     (CASE)  
            --            DispatchPiecePickMethod  = 'PIECE')  
  
            --1. check if configured by order type  
            IF ISNULL(@cPackMethod,'') = ''  
            BEGIN  
               SET @cCustomerType1 = ''  
               SET @cCustomerType2 = ''  
               SET @cCustomerType3 = ''  
               SET @cCustomerType4 = ''  
               SET @cPackMethod = ''  
  
               SELECT TOP 1 @cCustomerType1 = UDF01  
                          , @cCustomerType2 = UDF02  
                          , @cCustomerType3 = UDF03  
                 , @cCustomerType4 = UDF04  
               FROM CODELKUP (NOLOCK)  
               WHERE LISTNAME = 'ORDERTYPE'  
               AND STORERKEY = @cStorerKey  
               AND CODE = @cOrderType  
               AND ISNULL(UDF01,'') IN ('PALLET', 'CASE')  
  
               IF ISNULL(@cCustomerType1,'') <> ''  
                  SET @cPackMethod = @cCustomerType1  
            END  
  
            --2. Check if storer configured  
            IF ISNULL(@cPackMethod,'') = ''  
            BEGIN  
               SET @cCustomerType1 = ''  
               SET @cCustomerType2 = ''  
               SET @cCustomerType3 = ''  
               SET @cCustomerType4 = ''  
               SET @cPackMethod = ''  
  
               IF ISNULL(@cConsigneeKey,'') <> ''  
               BEGIN  
                  SELECT TOP 1 @cCustomerType1 = SUSR1  
                             , @cCustomerType2 = SUSR2  
                             , @cCustomerType3 = SUSR3  
                             , @cCustomerType4 = PALLET  
                  FROM STORER WITH (NOLOCK)  
                  WHERE CONSIGNEEFOR = @cStorerKey  
                  AND STORERKEY = @cConsigneeKey  
                  AND ISNULL(SUSR1,'') IN ('PALLET', 'CASE')  
               END  
  
               IF ISNULL(@cCustomerType1,'') = '' AND ISNULL(@cBillToKey,'') <> ''  
               BEGIN  
                  SELECT TOP 1 @cCustomerType1 = SUSR1  
                             , @cCustomerType2 = SUSR2  
                             , @cCustomerType3 = SUSR3  
                             , @cCustomerType4 = PALLET  
                  FROM STORER WITH (NOLOCK)  
                  WHERE CONSIGNEEFOR = @cStorerKey  
                  AND STORERKEY = @cBillToKey  
             AND ISNULL(SUSR1,'') IN ('PALLET', 'CASE')  
               END  
  
               IF ISNULL(@cCustomerType1,'') <> ''  
                  SET @cPackMethod = @cCustomerType1  
  
            END  
  
            --3. Check if configured by wave/load release  
            IF ISNULL(@cPackMethod,'') = ''  
            BEGIN  
               SET @cPlanningType = ''  
               SET @cPackMethod = ''  
               SET @cCustomerType2 = ''  
               SET @cCustomerType3 = ''  
               SET @cCustomerType4 = ''  
  
               SELECT TOP 1 @cPlanningType = CODE  
               FROM CODELKUP (NOLOCK)  
               WHERE LISTNAME = 'AU830PLAN'  
               AND STORERKEY = @cStorerKey  
  
               IF ISNULL(@cPlanningType,'') <> ''  
               BEGIN  
                  IF ISNULL(@cPlanningType,'') = 'WAVE' AND ISNULL(@cPWaveKey,'') <> ''  
                  BEGIN  
                     SELECT @cPickPalletType  = DispatchPalletPickMethod  
                          , @cPickCaseType    = DispatchCasePickMethod  
                          , @cPickPieceType   = DispatchPiecePickMethod  
                          , @cCustomerType3   = UserDefine01  
                          , @cCustomerType4   = UserDefine02  
                     FROM WAVE WITH (NOLOCK)  
                     WHERE WAVEKEY = @cPWaveKey  
                  END  
                  ELSE IF ISNULL(@cPlanningType,'') = 'LOAD' AND ISNULL(@cPLoadkey,'') <> ''  
                  BEGIN  
                     SELECT @cPickPalletType  = DispatchPalletPickMethod  
                          , @cPickCaseType    = DispatchCasePickMethod  
                          , @cPickPieceType   = DispatchPiecePickMethod  
                          , @cCustomerType3   = UserDefine01  
          , @cCustomerType4   = UserDefine02  
                     FROM LOADPLAN WITH (NOLOCK)  
                     WHERE LOADKEY = @cPLoadkey  
                  END  
  
                  SET @cPackMethod = ''  
  
                  IF @cPickCaseType IN ('SWPALLET' ,'RBPALLET', 'PALLET')  
                     SET @cPackMethod = 'PALLET'  
                  ELSE IF @cPickCaseType IN ('SWCASE' ,'RBCASE', 'CASE')  
                     SET @cPackMethod = 'CASE'  
  
                  IF LEFT(@cPickCaseType,2) IN ('SW')  
                     SET @cCustomerType2 = 'SANDWICH'  
                  ELSE IF LEFT(@cPickCaseType,2) IN ('RB')  
                     SET @cCustomerType2 = 'RAINBOW'  
                  ELSE  
                     SET @cCustomerType2 = ''  
               END  
            END  
  
            IF ISNULL(@cCustomerType2,'') IN ('SANDWICH','RAINBOW')  
               SET @cPackCaseType = @cCustomerType2  
            ELSE  
               SET @cPackCaseType = 'RAINBOW' --DEFAULT TO RAINBOW  
  
            IF ISNULL(@cPackCaseType,'') = 'RAINBOW' AND ISNULL(@cPackMethod,'') IN ('PALLET','CASE')  
               AND ISNULL(@cLabelPrinter,'') <> ''  
            BEGIN  
  
               SELECT TOP 1 @cLabelNo = PD.LABELNO, @cPickSlipNo =  PD.PICKSLIPNO, @nCartonNo = PD.CARTONNO  
               FROM PACKDETAIL PD (NOLOCK)  
               JOIN PACKHEADER PH (NOLOCK) ON PD.PICKSLIPNO = PH.PICKSLIPNO  
               WHERE PH.ORDERKEY = @cOrderKey  
               AND PD.DROPID = @cDropID  
               ORDER BY PD.CARTONNO DESC  
  
               INSERT INTO @tShipLabel (Variable, Value) VALUES  
                  ( '@cStorerKey',     @cStorerKey),  
                  ( '@cPickSlipNo',    @cPickSlipNo),  
                  ( '@cFromDropID',    @cDropID),  
                  ( '@cPackDtlDropID', @cDropID),  
                  ( '@cLabelNo',       @cLabelNo),  
                  ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))  
  
         -- Print label  
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,  
                  @cShipLabel, -- Report type  
                  @tShipLabel, -- Report params  
             'rdt_1812ExtUpdAU02',  
                  @nErrNo  OUTPUT,  
                  @cErrMsg OUTPUT  
               --IF @nErrNo <> 0  
               --   GOTO Quit  
            END  
            */  
            /* PALLET CONTENT LABEL PRINTING ON EXTSCN  
            IF EXISTS (SELECT TOP 1 1 FROM PALLET WITH (NOLOCK) WHERE PALLETKEY = @cDropID)  
            BEGIN  
  
               IF ISNULL(@cPalletLabel,'') <> '' AND ISNULL(@cLabelPrinter,'') <> ''  
               BEGIN  
  
                 INSERT INTO @tPalletLabel (Variable, Value) VALUES  
                    ( '@cStorerKey',     @cStorerKey),  
                    ( '@cPalletKey',    @cDropID)  
  
                 -- Print label  
                 EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,  
                    @cPalletLabel, -- Report type  
                    @tPalletLabel, -- Report params  
                    'rdt_1812ExtUpdAU02',  
                    @nErrNo  OUTPUT,  
                    @cErrMsg OUTPUT  
  
               END  
            END  
            */  
  
            IF EXISTS (  
               SELECT TOP 1 1 FROM PACKHEADER (NOLOCK) WHERE PICKSLIPNO = @cPickSlipNo AND STATUS = '9')  
            BEGIN  
               DECLARE @cPackList NVARCHAR( 10)  
  
               SET @cPackList = rdt.RDTGetConfig( @nFunc, 'PackList', @cStorerKey)  
               IF @cPackList = '0'  
                   SET @cPackList = ''  
  
               IF @cPackList <> ''  
               BEGIN  
                  DECLARE @tPackList AS VariableTable  
                  INSERT INTO @tPackList (Variable, Value) VALUES ( '@cLoadKey',     @cLoadKey)  
                  INSERT INTO @tPackList (Variable, Value) VALUES ( '@cOrderKey',    @cOrderKey)  
                  INSERT INTO @tPackList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo)  
               END  
  
               IF @cPackList <> '' AND ISNULL(@cLabelPrinter,'') <> ''  
               BEGIN  
                  IF EXISTS (SELECT TOP 1 1 FROM RDT.RDTREPORTTOPRINTER (NOLOCK)  
                             WHERE PRINTERGROUP = ISNULL(@cLabelPrinter,'')  
                             AND FUNCTION_ID = @nFunc  
                             AND REPORTTYPE = @cPackList)  
                  BEGIN  
                     --DECLARE @tPackList AS VariableTable  
                     --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cLoadKey',     @cLoadKey)  
                     --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cOrderKey',    @cOrderKey)  
                     --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo)  
  
                     -- Print label  
                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cLabelPrinter, @cPaperPrinter,  
                         @cPackList, -- Report type  
                         @tPackList, -- Report params  
                         'rdt_1812ExtUpdAU02',  
                         @nErrNo  OUTPUT,  
                         @cErrMsg OUTPUT  
                  END  
                  ELSE IF @cPackList <> '' AND ISNULL(@cPaperPrinter,'') <> ''  
                  BEGIN  
                     --DECLARE @tPackList AS VariableTable  
                     --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cLoadKey',     @cLoadKey)  
                     --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cOrderKey',    @cOrderKey)  
                     --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo)  
  
                    -- Print label  
                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cLabelPrinter, @cPaperPrinter,  
                         @cPackList, -- Report type  
                         @tPackList, -- Report params  
                         'rdt_1812ExtUpdAU02',  
                         @nErrNo  OUTPUT,  
                         @cErrMsg OUTPUT  
                  END -- Packlist <> ''  
               END -- Packlist <> ''  
               ELSE IF @cPackList <> '' AND ISNULL(@cPaperPrinter,'') <> ''  
               BEGIN  
                  --DECLARE @tPackList AS VariableTable  
                  --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cLoadKey',     @cLoadKey)  
                  --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cOrderKey',    @cOrderKey)  
                  --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo)  
  
                 -- Print label  
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cLabelPrinter, @cPaperPrinter,  
                      @cPackList, -- Report type  
                      @tPackList, -- Report params  
                      'rdt_1812ExtUpdAU02',  
                      @nErrNo  OUTPUT,  
                      @cErrMsg OUTPUT  
               END -- Packlist <> ''  
            END  
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

GRANT EXECUTE ON [RDT].[rdt_1812ExtUpdAU02] TO [NSQL]
GO