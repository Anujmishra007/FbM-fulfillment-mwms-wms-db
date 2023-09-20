
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: rdt_840ExtInsPack19                                */
/*                                                                      */
/* Purpose: Insert/Update packdetail.                                   */
/*          Print sku label                                             */
/*                                                                      */
/* Called By: RDT Pack By Track No                                      */ 
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 2023-03-31   James     1.0   WMS-22084. Created                      */
/* 2023-04-22   YeeKung   1.1   WMS-22236 Add ZPL method (yeekung01)    */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_840ExtInsPack19] (
   @nMobile                   INT, 
   @nFunc                     INT, 
   @cLangCode                 NVARCHAR( 3), 
   @nStep                     INT, 
   @nInputKey                 INT, 
   @cStorerkey                NVARCHAR( 15), 
   @cOrderKey                 NVARCHAR( 10), 
   @cPickSlipNo               NVARCHAR( 10), 
   @cTrackNo                  NVARCHAR( 20), 
   @cSKU                      NVARCHAR( 20), 
   @nQty                      INT, 
   @nCartonNo                 INT, 
   @cSerialNo                 NVARCHAR( 30), 
   @nSerialQTY                INT,  
   @cLabelNo                  NVARCHAR( 20) OUTPUT, 
   @nErrNo                    INT           OUTPUT, 
   @cErrMsg                   NVARCHAR( 20) OUTPUT  
)
AS
BEGIN

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount        INT,
           @nPD_QTY           INT,
           @cReportType       NVARCHAR( 10),
           @cPrintJobName     NVARCHAR( 50),
           @cDataWindow       NVARCHAR( 50),
           @cTargetDB         NVARCHAR( 20),
           @cPaperPrinter     NVARCHAR( 10),
           @cLabelPrinter     NVARCHAR( 10),
           @cPickDetailKey    NVARCHAR( 10), 
           @cCarrierName      NVARCHAR( 30), 
           @cKeyName          NVARCHAR( 30), 
           @cUserName         NVARCHAR( 18), 
           @cLoadKey          NVARCHAR( 10),
           @cRoute            NVARCHAR( 10),
           @cConsigneeKey     NVARCHAR( 15), 
           @cCurLabelNo       NVARCHAR( 20),
           @cCurLabelLine     NVARCHAR( 5), 
           @cPack_LblNo       NVARCHAR( 20), 
           @cPack_SKU         NVARCHAR( 20), 
           @cShipLabel        NVARCHAR( 10),
           @cDelNotes         NVARCHAR( 10),
           @cFacility         NVARCHAR( 5),
           @nPack_QTY         INT, 
           @nPickQty          INT, 
           @nPackQty          INT,
           @nNewCarton        INT,
           @bSuccess          INT,
           @cShipperKey       NVARCHAR( 15),
           @cDefEcomCartonCnt INT,
           @nCurrentCtnNo     INT,
           @nNewCartonNo      INT,
           @cTrackingNo       NVARCHAR( 20)

   DECLARE @b_success         INT,
           @n_err             INT,
           @c_errmsg          NVARCHAR( 20)

   DECLARE @cData1            NVARCHAR( 60)
   DECLARE @cRefType          NVARCHAR( 10)
   DECLARE @nRowCount         INT
   DECLARE @cOrderLineNumber  NVARCHAR( 5)
   DECLARE @nOriginalQty      INT
   DECLARE @cOrdType          NVARCHAR( 10)
   DECLARE @cC_Country        NVARCHAR( 30)
   DECLARE @cC_ISOCntryCode   NVARCHAR( 10)
   DECLARE @cStartNo          NVARCHAR( 10)
   DECLARE @cEndNo            NVARCHAR( 10)
   DECLARE @cTemplateSP       NVARCHAR( 80)  
   DECLARE @cTemplate         NVARCHAR( MAX) 
   DECLARE @cValue01          NVARCHAR( 30)  
   DECLARE @cValue02          NVARCHAR( 30)  
   DECLARE @cValue03          NVARCHAR( 30)  
   DECLARE @cValue04          NVARCHAR( 30)  
   DECLARE @cValue05          NVARCHAR( 30)  
   DECLARE @cValue06          NVARCHAR( 30)  
   DECLARE @cValue07          NVARCHAR( 30)  
   DECLARE @cValue08          NVARCHAR( 30)  
   DECLARE @cValue09          NVARCHAR( 30)  
   DECLARE @cValue10          NVARCHAR( 30)  
   DECLARE @cPrintData        NVARCHAR( MAX)
   DECLARE @cSQL              NVARCHAR( MAX)
   DECLARE @cSQLParam         NVARCHAR( MAX)
   
   SET @nTranCount = @@TRANCOUNT    

   BEGIN TRAN    
   SAVE TRAN rdt_840ExtInsPack19    

   SELECT @cUserName = UserName,
          @cFacility = Facility,
          @cData1    = I_Field02
   FROM rdt.rdtMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Piece scanning
   SET @nQty = 1
   SET @cLabelNo = ''
   SET @nNewCarton = 0

   IF EXISTS (SELECT 1 FROM rdt.rdtTrackLog WITH (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
               AND Storerkey = @cStorerkey
               AND CartonNo = @nCartonNo
               AND UserName = @cUserName
               AND SKU = @cSKU)   -- can scan many sku into 1 carton
   BEGIN
      UPDATE rdt.rdtTrackLog WITH (ROWLOCK) SET
         Qty = ISNULL(Qty, 0) + 1,
         EditWho = @cUserName,
         EditDate = GetDate()
      WHERE PickSlipNo = @cPickSlipNo
      AND Storerkey = @cStorerkey
      AND CartonNo = @nCartonNo
      AND UserName = @cUserName
      AND SKU = @cSKU

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 198751
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UpdLog Failed'
         GOTO RollBackTran
      END
   END
   ELSE
   BEGIN
      INSERT INTO rdt.rdtTrackLog ( PickSlipNo, Mobile, UserName, Storerkey, Orderkey, TrackNo, SKU, Qty, CartonNo )
      VALUES (@cPickSlipNo, @nMobile, @cUserName, @cStorerkey, @cOrderKey, @cTrackNo, @cSKU, 1, @nCartonNo  )

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 198752
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InsLog Failed'
         GOTO RollBackTran
      END
   END

   SELECT @cLoadKey = ISNULL(RTRIM(LoadKey),'')
         , @cRoute = ISNULL(RTRIM(Route),'')
         , @cConsigneeKey = ISNULL(RTRIM(ConsigneeKey),'') 
         , @cShipperKey = ShipperKey
         , @cOrdType = [Type]
         , @cC_Country = C_Country
         , @cC_ISOCntryCode = C_ISOCntryCode
   FROM dbo.Orders WITH (NOLOCK)
   WHERE Orderkey = @cOrderkey
      
   -- Create PackHeader if not yet created
   IF NOT EXISTS (SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo)
   BEGIN
      INSERT INTO dbo.PACKHEADER
      (PickSlipNo, StorerKey, OrderKey, LoadKey, Route, ConsigneeKey, OrderRefNo, TtlCnts, [STATUS])
      VALUES
      (@cPickSlipNo, @cStorerkey, @cOrderkey, @cLoadKey, @cRoute, @cConsigneeKey, '', 0, '0')

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 198753
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InsPKHDR Failed'
         GOTO RollBackTran
      END
   END

   -- Update PackDetail.Qty if it is already exists
   IF EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerkey
               AND PickSlipNo = @cPickSlipNo
               AND CartonNo = @nCartonNo
               AND SKU = @cSKU)   -- can scan many sku into 1 carton
   BEGIN
      UPDATE dbo.PackDetail WITH (ROWLOCK) SET
         Qty = Qty + @nQty,
         EditDate = GETDATE(),
         EditWho = 'rdt.' + sUser_sName()
      WHERE StorerKey = @cStorerkey
      AND PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND SKU = @cSKU

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 198754
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPDPKDET Failed'
         GOTO RollBackTran
      END
   END
   ELSE     -- Insert new PackDetail
   BEGIN
      -- Check if same carton exists before. Diff sku can scan into same carton
      IF NOT EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerkey
                  AND PickSlipNo = @cPickSlipNo
                  AND CartonNo = @nCartonNo)
      BEGIN
      	SELECT 
      	   @cStartNo = UDF01,
      	   @cEndNo = UDF02,
      	   @cKeyName = UDF03
      	FROM dbo.CODELKUP WITH (NOLOCK)
      	WHERE LISTNAME = 'LVSCTNNO'
      	AND   Code = @cOrdType
      	AND   ((Short = @cC_Country) OR (Short = @cC_ISOCntryCode)) 
      	AND   Storerkey = @cStorerkey
      	
      	SET @nRowCount =  @@ROWCOUNT
      	
      	IF @nRowCount > 0
         BEGIN
            DECLARE @cRunningNo NVARCHAR( 10)  
            EXECUTE dbo.nspg_GetKey  
               @cKeyName,  
               10 ,  
               @cRunningNo        OUTPUT,  
               @b_success         OUTPUT,  
               @n_err             OUTPUT,  
               @c_errmsg          OUTPUT  
  
            IF @b_success <> 1  
            BEGIN  
               SET @nErrNo = 198755  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'GET LABEL Fail'  
               GOTO RollBackTran  
            END  
            
            --SELECT 79305000 + (NCOUNTER % (79330000 - 79305000) )
            SET @cLabelNo = CAST( @cStartNo AS INT) + ( CAST( @cRunningNo AS INT) % (CAST( @cEndNo AS INT) - CAST( @cStartNo AS INT)) )
         END
         ELSE
         BEGIN
            -- Get new LabelNo  
            EXECUTE isp_GenUCCLabelNo  
                     @cStorerKey,  
                     @cLabelNo     OUTPUT,  
                     @bSuccess     OUTPUT,  
                     @nErrNo       OUTPUT,  
                     @cErrMsg      OUTPUT  
  
            IF @bSuccess <> 1  
            BEGIN  
               SET @nErrNo = 198756  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'GET LABEL Fail'  
               GOTO RollBackTran  
            END  
         END
         
         IF ISNULL( @cLabelNo, '') = ''
         BEGIN
            SET @nErrNo = 198757
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'GET LABEL Fail'
            GOTO RollBackTran
         END

         -- CartonNo = 0 & LabelLine = '0000', trigger will auto assign
         INSERT INTO dbo.PackDetail
            (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, Refno, AddWho, AddDate, EditWho, EditDate, DropID)
         VALUES
            (@cPickSlipNo, 0, @cLabelNo, '00000', @cStorerKey, @cSku, @nQty,
            '', 'rdt.' + sUser_sName(), GETDATE(), 'rdt.' + sUser_sName(), GETDATE(), '')

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 198758
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'INS PACK Fail'
            GOTO RollBackTran
         END
         ELSE
            SELECT @nNewCarton = CartonNo 
            FROM dbo.PackDetail WITH (NOLOCK) 
            WHERE PickSlipNo = @cPickSlipNo
            AND   LabelNo = @cLabelNo
            AND   StorerKey = @cStorerKey

         -- Create a dummy label and a cartontrack record
         IF EXISTS ( SELECT 1 
                     FROM dbo.CODELKUP WITH (NOLOCK)
                     WHERE LISTNAME = 'LVSPLTCUST'
                     AND   Code = @cConsigneeKey
                     AND   Short = '1'
                     AND   Storerkey = @cStorerkey)
         BEGIN
         	DECLARE @c_ZPLCode   NVARCHAR( MAX)
         	
            -- EXEC isp_GenZPL_interface 'LVS', '', 'ZPLCONFIG','P000008985', '0000002227', '1','LVS','','MANUAL',  @ZPLCODE OUTPUT,0,0,''
            EXEC isp_GenZPL_interface
                 @c_StorerKey    = @cStorerkey        
               , @c_Facility     = @cFacility                         
               , @c_ReportType   = 'ZPLCONFIG'                
               , @c_Param01      = @cPickSlipNo     
               , @c_Param02      = @cLabelNo   
               , @c_Param03      = @nNewCarton   
               , @c_Param04      = @cStorerkey   
               , @c_Param05      = ''        
               , @c_SourceType   = @nFunc  
               , @c_ZPLCode      = @c_ZPLCode   OUTPUT     
               , @b_success      = @bSuccess    OUTPUT            
               , @n_err          = @nErrNo      OUTPUT                
               , @c_errmsg       = @cErrMsg     OUTPUT                            
         END
         ELSE
         BEGIN
            -- EXEC isp_Carrier_Middleware_Interface @c_OrderKey, @c_Mbolkey, @c_FunctionID,@n_CartonNo,@n_Step, @b_Success output, @n_Err output, @c_ErrMsg output
            EXEC [dbo].[isp_Carrier_Middleware_Interface]        
                 @c_OrderKey    = @cOrderKey     
               , @c_Mbolkey     = ''  
               , @c_FunctionID  = @nFunc      
               , @n_CartonNo    = @nNewCarton  
               , @n_Step        = @nStep  
               , @b_Success     = @bSuccess  OUTPUT        
               , @n_Err         = @nErrNo    OUTPUT        
               , @c_ErrMsg      = @cErrMsg   OUTPUT        
         END
         
         IF @bSuccess = 0
         BEGIN
            SET @nErrNo = 198759
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Exec ITF Fail
            GOTO RollBackTran
         END
      END
      ELSE
      BEGIN
         SET @cCurLabelNo = ''
         SET @cCurLabelLine = ''

         SELECT TOP 1 @cCurLabelNo = LabelNo FROM dbo.PackDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo

         SELECT @cCurLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)
         FROM PACKDETAIL WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo

         -- need to use the existing labelno
         INSERT INTO dbo.PackDetail
            (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, Refno, AddWho, AddDate, EditWho, EditDate, DropID)
         VALUES
            (@cPickSlipNo, @nCartonNo, @cCurLabelNo, @cCurLabelLine, @cStorerKey, @cSku, @nQty,
            '', 'rdt.' + sUser_sName(), GETDATE(), 'rdt.' + sUser_sName(), GETDATE(), '')

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 198760
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'INS PACK Fail'
            GOTO RollBackTran
         END
      END
   END

   -- Capture COO here
   IF @nStep = 9
   BEGIN
      IF @nInputKey = 1
      BEGIN
         SELECT TOP 1 
            @cOrderLineNumber = OrderLineNumber,
            @nOriginalQty = OriginalQty
         FROM dbo.ORDERDETAIL WITH (NOLOCK)
         WHERE OrderKey = @cOrderKey
         AND   Sku = @cSKU
         ORDER BY 1
         
         SELECT @cRefType = RefType
         FROM dbo.OrderDetailRef WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND   Orderkey = @cOrderKey
         AND   RetailSKU = @cSKU

         SET @nRowCount =  @@ROWCOUNT
         
         IF @nRowCount = 0
         BEGIN
         	INSERT INTO dbo.OrderDetailRef( Orderkey, OrderLineNumber, RetailSKU, BOMQty, RefType, StorerKey, ParentSKU) VALUES 
         	(@cOrderKey, @cOrderLineNumber, @cSKU, @nOriginalQty, SUBSTRING( @cData1, 1, 10), @cStorerkey, @cLabelNo)
         	
         	IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 198761
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'INS COO Fail'
               GOTO RollBackTran
            END
         END
         ELSE
         BEGIN
         	UPDATE dbo.OrderDetailRef SET 
         	   @cRefType = SUBSTRING( @cData1, 1, 10),
         	   BOMQty = @nOriginalQty,
         	   Editwho = SUSER_SNAME(),
         	   Editdate = GETDATE()
         	WHERE Orderkey = @cOrderKey
         	AND   OrderLineNumber = @cOrderLineNumber
         	AND   RetailSKU = @cSKU

         	IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 198762
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPD COO Fail'
               GOTO RollBackTran
            END
         END
      END
   END

   GOTO Quit
   
   RollBackTran:  
         ROLLBACK TRAN rdt_840ExtInsPack19  
   Quit:  
      WHILE @@TRANCOUNT > @nTranCount  
         COMMIT TRAN  

   IF EXISTS ( SELECT 1 
               FROM dbo.STORER WITH (NOLOCK)
               WHERE StorerKey = @cConsigneeKey
               AND   Facility = @cFacility
               AND   [type] = '2'
               AND   LabelPrice = 'Y')
   BEGIN
   	IF EXISTS ( SELECT 1
   	            FROM dbo.ORDERDETAIL WITH (NOLOCK)
   	            WHERE OrderKey = @cOrderKey
   	            AND   Sku = @cSKU
   	            AND   ISNULL( Tax02, '') = '')
      BEGIN
      	DECLARE @cPriceLabel1   NVARCHAR( 10)
      	DECLARE @tPriceLabel1   VariableTable

         SET @cPriceLabel1 = rdt.RDTGetConfig( @nFunc, 'PriceLbl01', @cStorerKey)
         IF @cPriceLabel1 = '0'
            SET @cPriceLabel1 = ''
                  
         IF @cPriceLabel1 <> ''
         BEGIN
            -- Get report info  
            SELECT
               @cTemplate = ISNULL( PrintTemplate, ''),  
               @cTemplateSP = ISNULL( PrintTemplateSP, '')
            FROM rdt.rdtReport WITH (NOLOCK)  
            WHERE StorerKey = @cStorerKey  
               AND ReportTYpe = @cPriceLabel1  
               AND (Function_ID = @nFunc OR Function_ID = 0)  
            ORDER BY Function_ID DESC  


             -- Execute SP to merge data and template, output print data as ZPL code  
            SET @cSQL = 'EXEC ' + RTRIM( @cTemplateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @cStorerKey, ' +  
               ' @cValue01, @cValue02, @cValue03, @cValue04, @cValue05, @cValue06, @cValue07, @cValue08, @cValue09, @cValue10, ' +  
               ' @cTemplate, @cPrintData OUTPUT, @nErrNo OUTPUT, @cErrMSG OUTPUT '  
            SET @cSQLParam =  
               '@nMobile      INT,            ' +  
               '@nFunc        INT,            ' +  
               '@cLangCode    NVARCHAR( 3),   ' +  
               '@cStorerKey   NVARCHAR( 15),  ' +  
               '@cValue01     NVARCHAR( 20),  ' +  
               '@cValue02     NVARCHAR( 20),  ' +  
               '@cValue03     NVARCHAR( 20),  ' +  
               '@cValue04     NVARCHAR( 20),  ' +  
               '@cValue05     NVARCHAR( 20),  ' +  
               '@cValue06     NVARCHAR( 20),  ' +  
               '@cValue07     NVARCHAR( 20),  ' +  
               '@cValue08     NVARCHAR( 20),  ' +  
               '@cValue09     NVARCHAR( 20),  ' +  
               '@cValue10     NVARCHAR( 20),  ' +  
               '@cTemplate    NVARCHAR( MAX), ' +  
               '@cPrintData   NVARCHAR( MAX) OUTPUT, ' +  
               '@nErrNo       INT            OUTPUT, ' +  
               '@cErrMsg      NVARCHAR( 20)  OUTPUT  '  
  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @cStorerKey,  
               @cPickSlipNo, @cOrderkey, @nCartonNo, @cLabelNo, @cSKU, @cValue06, @cValue07, @cValue08, @cValue09, @cValue10,  
               @cTemplate, @cPrintData OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0  
               GOTO Quit  


            EXECUTE dbo.isp_PrintZplLabel      
             @cStorerKey        = @cStorerKey      
            ,@cLabelNo          = @cOrderKey  --(JH02)    
            ,@cTrackingNo       = @cTrackingNo      
            ,@cPrinter          = @cLabelPrinter      
            ,@nErrNo            = @nErrNo    OUTPUT      
            ,@cErrMsg           = @cErrMsg   OUTPUT   
            ,@cPrintMsg         = @cPrintData

            --INSERT INTO @tPriceLabel1 (Variable, Value) VALUES ( '@cPickSlipNo',    @cPickSlipNo)
            --INSERT INTO @tPriceLabel1 (Variable, Value) VALUES ( '@cOrderkey',      @cOrderkey)
            --INSERT INTO @tPriceLabel1 (Variable, Value) VALUES ( '@nCartonNo',      @nCartonNo)
            --INSERT INTO @tPriceLabel1 (Variable, Value) VALUES ( '@cLabelNo',       @cLabelNo)
            --INSERT INTO @tPriceLabel1 (Variable, Value) VALUES ( '@cSKU',           @cSKU)

            ---- Print label
            --EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, @cLabelPrinter, '',
            --   @cPriceLabel1, -- Report type
            --   @tPriceLabel1, -- Report params
            --   'rdt_840ExtInsPack19',
            --   @nErrNo  OUTPUT,
            --   @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO QUIT
         END
      END
      ELSE
      BEGIN
      	DECLARE @cPriceLabel2   NVARCHAR( 10)
      	DECLARE @tPriceLabel2   VariableTable

         SET @cPriceLabel2 = rdt.RDTGetConfig( @nFunc, 'PriceLbl02', @cStorerKey)
         IF @cPriceLabel2 = '0'
            SET @cPriceLabel2 = ''

                  
         IF @cPriceLabel2 <> ''
         BEGIN
            -- Get report info  
            SELECT
               @cTemplate = ISNULL( PrintTemplate, ''),  
               @cTemplateSP = ISNULL( PrintTemplateSP, '')
            FROM rdt.rdtReport WITH (NOLOCK)  
            WHERE StorerKey = @cStorerKey  
               AND ReportTYpe = @cPriceLabel2  
               AND (Function_ID = @nFunc OR Function_ID = 0)  
            ORDER BY Function_ID DESC  


             -- Execute SP to merge data and template, output print data as ZPL code  
            SET @cSQL = 'EXEC ' + RTRIM( @cTemplateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @cStorerKey, ' +  
               ' @cValue01, @cValue02, @cValue03, @cValue04, @cValue05, @cValue06, @cValue07, @cValue08, @cValue09, @cValue10, ' +  
               ' @cTemplate, @cPrintData OUTPUT, @nErrNo OUTPUT, @cErrMSG OUTPUT '  
            SET @cSQLParam =  
               '@nMobile      INT,            ' +  
               '@nFunc        INT,            ' +  
               '@cLangCode    NVARCHAR( 3),   ' +  
               '@cStorerKey   NVARCHAR( 15),  ' +  
               '@cValue01     NVARCHAR( 20),  ' +  
               '@cValue02     NVARCHAR( 20),  ' +  
               '@cValue03     NVARCHAR( 20),  ' +  
               '@cValue04     NVARCHAR( 20),  ' +  
               '@cValue05     NVARCHAR( 20),  ' +  
               '@cValue06     NVARCHAR( 20),  ' +  
               '@cValue07     NVARCHAR( 20),  ' +  
               '@cValue08     NVARCHAR( 20),  ' +  
               '@cValue09     NVARCHAR( 20),  ' +  
               '@cValue10     NVARCHAR( 20),  ' +  
               '@cTemplate    NVARCHAR( MAX), ' +  
               '@cPrintData   NVARCHAR( MAX) OUTPUT, ' +  
               '@nErrNo       INT            OUTPUT, ' +  
               '@cErrMsg      NVARCHAR( 20)  OUTPUT  '  
  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @cStorerKey,  
               @cPickSlipNo, @cOrderkey, @nCartonNo, @cLabelNo, @cSKU, @cValue06, @cValue07, @cValue08, @cValue09, @cValue10,  
               @cTemplate, @cPrintData OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0  
               GOTO Quit  


            EXECUTE dbo.isp_PrintZplLabel      
             @cStorerKey        = @cStorerKey      
            ,@cLabelNo          = @cOrderKey  --(JH02)    
            ,@cTrackingNo       = @cTrackingNo      
            ,@cPrinter          = @cLabelPrinter      
            ,@nErrNo            = @nErrNo    OUTPUT      
            ,@cErrMsg           = @cErrMsg   OUTPUT   
            ,@cPrintMsg         = @cPrintData

            
            IF @nErrNo <> 0
               GOTO QUIT
            --INSERT INTO @tPriceLabel2 (Variable, Value) VALUES ( '@cPickSlipNo',    @cPickSlipNo)
            --INSERT INTO @tPriceLabel2 (Variable, Value) VALUES ( '@cOrderkey',      @cOrderkey)
            --INSERT INTO @tPriceLabel2 (Variable, Value) VALUES ( '@nCartonNo',      @nCartonNo)
            --INSERT INTO @tPriceLabel2 (Variable, Value) VALUES ( '@cLabelNo',       @cLabelNo)
            --INSERT INTO @tPriceLabel2 (Variable, Value) VALUES ( '@cSKU',           @cSKU)

            --  -- Print label
            --EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, @cLabelPrinter, '',
            --   @cPriceLabel2, -- Report type
            --   @tPriceLabel2, -- Report params
            --   'rdt_840ExtInsPack19',
            --   @nErrNo  OUTPUT,
            --   @cErrMsg OUTPUT

            --IF @nErrNo <> 0
            --   GOTO Fail
         END
      END
   END
   
   Fail:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_840ExtInsPack19 TO NSQL
GO

