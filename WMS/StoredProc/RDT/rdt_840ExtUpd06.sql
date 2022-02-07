IF  EXISTS (SELECT * FROM sys.objects WHERE Object_Id = OBJECT_ID(N'[RDT].[rdt_840ExtUpd06]') AND Type in (N'P', N'PC'))
   DROP PROCEDURE [RDT].[rdt_840ExtUpd06]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/    
/* Store procedure: rdt_840ExtUpd06                                     */    
/* Purpose: Trigger HM related interface and misc update                */    
/*          Copy from rdt_840ExtUpd05 and abandon cmdshell method       */    
/* Modifications log:                                                   */    
/*                                                                      */    
/* Date       Rev  Author     Purposes                                  */    
/* 2018-10-09 1.0  James      Created                                   */    
/* 2019-03-15 1.1  James      WMS8270-Add Myntra interface (james01)    */    
/* 2019-08-20 1.2  James      WMS-10299 Move file after print (james02) */    
/* 2019-09-27 1.3  James      WMS-10765 Auto compute weight (james03)   */    
/* 2020-10-01 1.4  James      WMS-15345 Add config to decide whether    */    
/*                            need delete invoice (james04)             */    
/* 2021-03-17 1.5  James      WMS-16580 Add checking on certain orders  */
/*                            cannot split carton when packing (james05)*/
/* 2021-04-01 1.6 YeeKung     WMS-16717 Add serialno and serialqty      */
/*                            Params (yeekung01)                        */
/************************************************************************/    
    
CREATE PROC [RDT].[rdt_840ExtUpd06] (    
   @nMobile     INT,    
   @nFunc       INT,    
   @cLangCode   NVARCHAR( 3),    
   @nStep       INT,    
   @nInputKey   INT,    
   @cStorerkey  NVARCHAR( 15),    
   @cOrderKey   NVARCHAR( 10),    
   @cPickSlipNo NVARCHAR( 10),    
   @cTrackNo    NVARCHAR( 20),    
   @cSKU        NVARCHAR( 20),    
   @nCartonNo   INT,    
   @cSerialNo   NVARCHAR( 30), 
   @nSerialQTY  INT,     
   @nErrNo      INT           OUTPUT,    
   @cErrMsg     NVARCHAR( 20) OUTPUT    
)    
AS    
    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
    
   DECLARE @nTranCount        INT,    
           @nExpectedQty      INT,    
           @nPackedQty        INT,    
           @cReportType       NVARCHAR( 10),    
           @cPrintJobName     NVARCHAR( 50),    
           @cDataWindow       NVARCHAR( 50),    
           @cTargetDB         NVARCHAR( 20),    
           @cPrinter          NVARCHAR( 10),    
           @cPrinter_Paper    NVARCHAR( 10),    
           @cLoadKey          NVARCHAR( 10),    
           @cShipperKey       NVARCHAR( 15),    
           @cTrackingNo       NVARCHAR( 20),    
           @cExternOrderKey   NVARCHAR( 30),    
           @cGUIExtOrderKey   NVARCHAR( 30),    
           @cInvoiceNo        NVARCHAR( 10),    
           @cPrintData        NVARCHAR( MAX),    
           @cLabels           NVARCHAR( MAX),    
           @cVBErrMsg         NVARCHAR( MAX),    
           @nOriginalQty   INT,    
           @nPickQty       INT,    
           @nPackQty       INT,    
           @nRowRef        INT,    
    
          @cWorkingFilePath  NVARCHAR( 250),    
          @cFilePath         NVARCHAR( 250),    
          @cDelFilePath      NVARCHAR( 250),    
          @cFileName         NVARCHAR( 100),    
          @cPrintFilePath    NVARCHAR( 250),    
          @cChkFilePath      NVARCHAR( 250),    
          @cCMD              NVARCHAR( 1000),    
          @cMoveFileCMD      NVARCHAR( MAX),    
          @cFileType         NVARCHAR( 10),    
          @cPrintServer      NVARCHAR( 50),    
          @cStringEncoding   NVARCHAR( 30),    
          @cLineNumber       NVARCHAR( 6),    
          @cCarrierName      NVARCHAR( 30),    
          @cKeyName          NVARCHAR( 30),    
          @cKey2             NVARCHAR( 30),    
          @nReturnCode       INT,    
          @nFileExists       INT,    
          @bSuccess          INT,    
          @nSeasonCodeDiff   INT,    
          @nShortPack        INT,    
          @nShortAlloc       INT,    
          @cPrinterName      NVARCHAR( 100),    
          @cWinPrinter       NVARCHAR( 128),    
          @cFacility         NVARCHAR( 5),    
          @cORDLabel         NVARCHAR( 10),    
          @cCode             NVARCHAR( 10)    
    
   DECLARE @c_AlertMessage       NVARCHAR(512),    
           @c_NewLineChar        NVARCHAR(2),    
           @c_PrintErrmsg        NVARCHAR(250),    
           @b_success            INT,    
           @n_Err                INT    
    
   DECLARE @cErrMsg01        NVARCHAR( 20),    
           @cErrMsg02        NVARCHAR( 20)    
    
   DECLARE @iHr  INT    
   DECLARE @iObjFileSystem INT    
    
   DECLARE @nMyntra        INT    
   DECLARE @cORD_Status    NVARCHAR( 10)    
   DECLARE @cWinPrinterName   NVARCHAR( 100)    
   DECLARE @cFolder2Move   NVARCHAR( 100)    
   DECLARE @fSKUWeight     REAL    
   DECLARE @fCtnWeight     REAL    
   DECLARE @cPrintCommand  NVARCHAR(MAX)        
   DECLARE @cSeasonSwapInvoiceRev   NVARCHAR( 1)   -- (james04)    
   DECLARE @nTtl_OrdQty    INT 
   DECLARE @nTtl_PckQty    INT 

   SET @nMyntra = 0    
    
   SET @cErrMsg01 = ''    
   SET @cErrMsg02 = ''    

   -- (james05)
   IF @nStep = 3
   BEGIN
      IF @nInputKey = 0
      BEGIN
         IF EXISTS ( SELECT 1 FROM dbo.orders WITH (NOLOCK)
                     WHERE OrderKey = @cOrderKey
                     AND   [Type] <> 'R')
         BEGIN
            IF @nCartonNo > 1
            BEGIN
               SET @nErrNo = 133417  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- Only 1 carton
               GOTO Quit
            END
            
            SELECT @nTtl_OrdQty = ISNULL( SUM( QTY), 0)
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE OrderKey = @cOrderkey
            AND   [Status] NOT IN ('4', '9')

            SELECT @nTtl_PckQty = ISNULL( SUM( QTY), 0)
            FROM dbo.PackDetail WITH (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo

            -- If order still has something to pack, not allow 
            -- to split carton. 
            IF @nTtl_OrdQty > @nTtl_PckQty
            BEGIN
               SET @nErrNo = 133418  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- X FINISH PACK
               GOTO Quit
            END
         END
      END   
   END
       
   IF @nStep = 4    
   BEGIN    
      IF @nInputKey = 1    
      BEGIN    
         IF NOT EXISTS ( SELECT 1 FROM dbo.CODELKUP C WITH (NOLOCK)    
                         JOIN dbo.Orders O WITH (NOLOCK) ON (C.Code = O.Type AND C.StorerKey = O.StorerKey)    
                         WHERE C.ListName = 'HMORDTYPE'    
                         AND   C.Short = 'S'    
                         AND   O.OrderKey = @cOrderkey    
                         AND   O.StorerKey = @cStorerKey)    
            -- No need continue process if not customer orders    
            GOTO Quit    
    
         -- Check if myntra orders    
         IF EXISTS ( SELECT 1 FROM dbo.ORDERS WITH (NOLOCK)    
                     WHERE OrderKey = @cOrderKey    
                     AND   StorerKey = @cStorerkey    
                     AND   M_STATE like 'MYN%')    
         BEGIN    
            SET @nMyntra = '1'    
         END    
    
         IF @nMyntra = '1'    
            SET @cCode = 'QSFilePath'    
         ELSE    
            SET @cCode = 'FilePath'    
    
         SET @nSeasonCodeDiff = 0    
         SET @nShortPack = 0    
         SET @nShortAlloc = 0    
    
         SET @cFolder2Move = ''    
    
         -- Get the related printing info, path, file type, etc    
         SELECT @cWorkingFilePath = UDF01,    
                @cFileType = UDF02,    
                @cPrintServer = UDF03,    
                @cStringEncoding = UDF04,    
                @cFolder2Move = UDF05,    
                @cPrintFilePath = Notes   -- foxit program    
         FROM dbo.CODELKUP WITH (NOLOCK)    
         WHERE ListName = 'PrintLabel'    
         AND   Code = @cCode    
         AND   Storerkey = @cStorerKey    
         AND   (( ISNULL( code2, '') = '') OR ( code2 = 'PDF'))    
    
         IF @@ROWCOUNT = 0    
         BEGIN    
            SET @nErrNo = 133401    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Setup CODEKLP'    
            GOTO RollBackTran    
         END    
    
         SELECT @cGUIExtOrderKey = BuyerPO,    
                @cORD_Status = [Status]    
         FROM dbo.ORDERS WITH (NOLOCK)    
         WHERE OrderKey = @cOrderKey    
         AND   StorerKey = @cStorerkey    
    
         -- The Order and Invoice will be 1:1 relationship    
         SELECT TOP 1 @cInvoiceNo = InvoiceNo    
         FROM dbo.GUIDetail WITH (NOLOCK)    
         WHERE StorerKey = @cStorerKey    
         AND   ExternOrderKey = @cGUIExtOrderKey    
         ORDER BY 1    
    
         -- Construct print file    
         SET @cFileName = RTRIM( @cGUIExtOrderKey) + '-' + RTRIM( @cInvoiceNo) + '.' + @cFileType    
         SET @cFilePath = RTRIM( @cWorkingFilePath) + '\' + @cFileName    
         SET @cDelFilePath = 'DEL ' + RTRIM( @cWorkingFilePath) + '\' + @cFileName    
    
         -- Compare SeasonCode (pickdetail.lotattable01, orderdetail.lottable01)    
         CREATE TABLE #PD_Lot01 (    
            ROWREF      INT IDENTITY(1,1) NOT NULL,    
            OrderLineNumber   NVARCHAR( 5),    
            Lottable01        NVARCHAR(18)  NULL)    
    
         CREATE TABLE #OD_Lot01 (    
            ROWREF      INT IDENTITY(1,1) NOT NULL,    
            OrderLineNumber   NVARCHAR( 5),    
            Lottable01        NVARCHAR(18)  NULL)    
    
         INSERT INTO #PD_Lot01 ( OrderLineNumber, Lottable01)    
         SELECT DISTINCT PD.OrderLineNumber, LA.Lottable01    
         FROM dbo.PickDetail PD WITH (NOLOCK)    
         JOIN dbo.LOTAttribute LA WITH (NOLOCK) ON ( PD.LOT = LA.LOT)    
         WHERE PD.StorerKey = @cStorerKey    
         AND   PD.OrderKey = @cOrderKey    
         AND   PD.Status < '9'    
    
         INSERT INTO #OD_Lot01 ( OrderLineNumber, Lottable01)    
         SELECT OrderLineNumber, Lottable01    
         FROM dbo.ORDERDETAIL OD WITH (NOLOCK)    
         WHERE OD.StorerKey = @cStorerKey    
         AND   OD.OrderKey = @cOrderKey    
         AND   OD.Status < '9'    
    
         -- If different, delete invoice and trigger order status I    
         IF EXISTS ( SELECT 1 FROM #PD_Lot01 PD WITH (NOLOCK)    
                     JOIN #OD_Lot01 OD WITH (NOLOCK) ON ( PD.OrderLineNumber = od.OrderLineNumber)    
                     AND   PD.Lottable01 <> OD.Lottable01)    
            SET @nSeasonCodeDiff = 1    
    
         IF EXISTS ( SELECT 1 FROM dbo.OrderDetail WITH (NOLOCK)    
                     WHERE OrderKey = @cOrderKey    
                     AND   StorerKey = @cStorerkey    
                     GROUP BY OrderKey    
                 HAVING SUM( EnteredQty) <> SUM( QtyAllocated + QtyPicked))    
            SET @nShortAlloc = 1    
    
         SELECT @nOriginalQty = ISNULL( SUM( OriginalQty), 0)    
         FROM dbo.Orders O WITH (NOLOCK)    
         JOIN dbo.ORDERDETAIL OD WITH (NOLOCK) ON ( O.OrderKey = OD.OrderKey)    
         WHERE O.OrderKey = @cOrderKey    
         AND   O.StorerKey = @cStorerkey    
    
         SELECT @nPackQty = ISNULL( SUM( QTY), 0)    
         FROM dbo.PackDetail PD WITH (NOLOCK)    
         JOIN dbo.PackHeader PH WITH (NOLOCK) ON ( PD.PickSlipNo = PH.PickSlipNo)    
         WHERE PH.OrderKey = @cOrderKey    
         AND   PH.StorerKey = @cStorerkey    
    
         -- Compare packed qty to order qty to check if short qty    
         IF @nOriginalQty > @nPackQty    
            SET @nShortPack = 1    
    
         SET @cSeasonSwapInvoiceRev = rdt.RDTGetConfig( @nFunc, 'SeasonSwapInvoiceRev', @cStorerKey)    
             
         SET @nTranCount = @@TRANCOUNT    
         BEGIN TRAN  -- Begin our own transaction    
         SAVE TRAN rdt_840ExtUpd06 -- For rollback or commit only our own transaction    
    
         -- Auto calculate weight    
         DECLARE @cCartonType NVARCHAR( 10)    
         DECLARE @curPackInfo CURSOR    
         SET @curPackInfo = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR    
            SELECT CartonNo, CartonType     
            FROM PackInfo WITH (NOLOCK)     
            WHERE PickSlipNo = @cPickSlipNo    
         OPEN @curPackInfo     
         FETCH NEXT FROM @curPackInfo INTO @nCartonNo, @cCartonType    
         WHILE @@FETCH_STATUS = 0    
         BEGIN    
            -- Get SKU weight    
            SET @fSKUWeight = 0    
            SELECT @fSKUWeight = ISNULL( SUM( SKU.STDGROSSWGT * PD.QTY), 0)    
            FROM dbo.PackDetail PD WITH (NOLOCK)     
               JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.StorerKey = PD.StorerKey AND SKU.SKU = PD.SKU)    
            WHERE PD.PickSlipNo = @cPickSlipNo    
               AND PD.CartonNo = @nCartonNo    
    
            -- Get carton weight    
            SET @fCtnWeight = 0    
            SELECT @fCtnWeight = ISNULL( CZ.CartonWeight, 0)    
            FROM Storer S WITH (NOLOCK)    
               JOIN dbo.Cartonization CZ WITH (NOLOCK) ON (S.CartonGroup = CZ.CartonizationGroup)    
            WHERE S.StorerKey = @cStorerKey    
               AND CZ.CartonType = @cCartonType    
    
            SET @fCtnWeight = (@fCtnWeight + @fSKUWeight) * 1000    
    
            UPDATE dbo.PackInfo SET    
               Weight = @fCtnWeight,    
               EditDate = GETDATE(),    
               EditWho = 'rdt.' + SUSER_SNAME()    
            WHERE PickSlipNo = @cPickSliPno    
               AND CartonNo = @nCartonNo    
            IF @@ERROR <> 0    
            BEGIN    
               SET @nErrNo = 133412    
     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPDPKINFO Failed'    
               GOTO RollBackTran    
            END    
                
            FETCH NEXT FROM @curPackInfo INTO @nCartonNo, @cCartonType    
         END    
    
         -- Short pick/pack or partial allocate need trigger order value recalculate    
         IF @nSeasonCodeDiff = 1 OR @nShortAlloc = 1 OR @nShortPack = 1    
         BEGIN    
            IF ( @nSeasonCodeDiff = 1 AND @cSeasonSwapInvoiceRev = '0') OR -- (james04)    
                 @nShortPack = 1 OR     
                 @nShortAlloc = 1    
            BEGIN                
               -- Insert transmitlog2 here (trigger S272)    
               SET @bSuccess = 1    
               EXEC ispGenTransmitLog2    
                   @c_TableName        = 'WSOrdRecalculate'    
                  ,@c_Key1             = @cOrderKey    
                  ,@c_Key2             = ''    
                  ,@c_Key3             = @cStorerkey    
                  ,@c_TransmitBatch    = ''    
                  ,@b_Success          = @bSuccess    OUTPUT    
                  ,@n_err              = @nErrNo      OUTPUT    
                  ,@c_errmsg           = @cErrMsg     OUTPUT    
    
               IF @bSuccess <> 1    
                  GOTO RollBackTran    
    
               UPDATE dbo.Orders WITH (ROWLOCK) SET    
                  SOStatus = 'PENDGET',    
                  Trafficcop = NULL,    
                  EditDate = GETDATE(),    
                  EditWho = sUSER_sNAME()    
               WHERE StorerKey = @cStorerkey    
               AND   OrderKey = @cOrderKey    
               AND   SOStatus <> 'PENDGET'    
    
               IF @@ERROR <> 0    
               BEGIN    
                  SET @nErrNo = 133402    
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPD PGET FAIL'    
                  GOTO RollBackTran    
               END    
            END    
                
            ELSE IF @nSeasonCodeDiff = 1 AND @cSeasonSwapInvoiceRev = '1'    
            BEGIN    
               UPDATE dbo.Orders WITH (ROWLOCK) SET    
                  SOStatus = '0',    
                  Trafficcop = NULL,    
                  EditDate = GETDATE(),    
                  EditWho = sUSER_sNAME()    
               WHERE StorerKey = @cStorerkey    
               AND   OrderKey = @cOrderKey    
               AND   SOStatus <> '0'    
    
               IF @@ERROR <> 0    
               BEGIN    
                  SET @nErrNo = 133416    
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPD PGET FAIL'    
                  GOTO RollBackTran    
               END    
            END                
         END    
    
         -- only pick=pack, season code same and fully allocated then only trigger RR1    
         IF ( @nSeasonCodeDiff = 0 AND @nShortPack = 0 AND @nShortAlloc = 0) OR    
            ( @nSeasonCodeDiff = 1 AND @cSeasonSwapInvoiceRev = '1')    
         BEGIN    
            IF @nMyntra = '1'    
            BEGIN    
               -- Insert transmitlog2 here    
               EXECUTE ispGenTransmitLog2    
                  @c_TableName      = 'WSRDTPCKCFM',    
                  @c_Key1           = @cOrderKey,    
                  @c_Key2           = @cORD_Status,    
                  @c_Key3           = @cStorerkey,    
                  @c_TransmitBatch  = '',    
                  @b_Success        = @bSuccess   OUTPUT,    
                  @n_err            = @nErrNo     OUTPUT,    
                  @c_errmsg         = @cErrMsg    OUTPUT    
    
               IF @bSuccess <> 1    
                  GOTO RollBackTran    
               /*    
               -- Insert transmitlog2 here    
               EXECUTE ispGenTransmitLog2    
                  @c_TableName      = 'WSRDTSHPLBL',    
                  @c_Key1           = @cOrderKey,    
                  @c_Key2           = @cORD_Status,    
                  @c_Key3 = @cStorerkey,    
                  @c_TransmitBatch  = '',    
                  @b_Success        = @bSuccess   OUTPUT,    
                  @n_err            = @nErrNo     OUTPUT,    
                  @c_errmsg         = @cErrMsg    OUTPUT    
    
               IF @bSuccess <> 1    
                  GOTO RollBackTran    
               */    
            END    
            ELSE    
            BEGIN    
       -- Same tracking no might be reused    
               -- So it get rejected when insert TL2    
               -- Get a unique key2 for rowref + key2 + storerkey    
               EXECUTE nspg_getkey    
                  @KeyName       = 'WSCRSOREQMP',    
                  @fieldlength   = 5,    
                  @keystring     = @cKey2      OUTPUT,    
                  @b_Success     = @bSuccess   OUTPUT,    
                  @n_err         = @nErrNo     OUTPUT,    
                  @c_errmsg      = @cErrMsg    OUTPUT,    
                  @b_resultset   = 0,    
                  @n_batch       = 1    
    
               IF @bSuccess <> 1    
                  GOTO RollBackTran    
    
               -- Insert transmitlog2 here    
               EXECUTE ispGenTransmitLog2    
                  @c_TableName      = 'WSCRSOREQMP',    
                  @c_Key1           = @cOrderKey,    
                  @c_Key2   = @cKey2,    
                  @c_Key3           = @cStorerkey,    
                  @c_TransmitBatch  = '',    
                  @b_Success        = @bSuccess   OUTPUT,    
                  @n_err            = @nErrNo     OUTPUT,    
                  @c_errmsg         = @cErrMsg    OUTPUT    
    
               IF @bSuccess <> 1    
                  GOTO RollBackTran    
            END    

            UPDATE dbo.Orders WITH (ROWLOCK) SET    --(yeekung01)
               SOStatus = '0',    
               Trafficcop = NULL,    
               EditDate = GETDATE(),    
               EditWho = sUSER_sNAME()    
            WHERE StorerKey = @cStorerkey    
            AND   OrderKey = @cOrderKey    
            AND   SOStatus = 'PENDGET'      
         END    
             
    
         IF @nSeasonCodeDiff = 1 OR @nShortPack = 1 OR @nShortAlloc = 1    
         BEGIN    
            -- Abnormal scenario: short pack, partial allocate or season code different    
            -- then need delete invoice data and invoice pdf file and trigger interface    
    
            IF ( @nSeasonCodeDiff = 1 AND @cSeasonSwapInvoiceRev = '0') OR -- (james04)    
                 @nShortPack = 1 OR     
                 @nShortAlloc = 1    
            BEGIN    
               -- Delete GUI where  GUI.ExternOrderKey = Orders.ExternOrderKey    
               DECLARE CUR_DEL CURSOR LOCAL READ_ONLY FAST_FORWARD FOR    
               SELECT LineNumber    
               FROM dbo.GUIDetail WITH (NOLOCK)    
               WHERE StorerKey = @cStorerKey    
               AND   ExternOrderKey = @cGUIExtOrderKey    
               AND   InvoiceNo = @cInvoiceNo    
               OPEN CUR_DEL    
               FETCH NEXT FROM CUR_DEL INTO @cLineNumber    
               WHILE @@FETCH_STATUS <> -1    
               BEGIN    
                  DELETE FROM dbo.GUIDetail    
                  WHERE InvoiceNo = @cInvoiceNo    
                  AND   ExternOrderkey = @cGUIExtOrderKey    
                  AND   Storerkey = @cStorerKey    
                  AND   LineNumber = @cLineNumber    
    
                  IF @@ERROR <> 0    
                  BEGIN    
                     SET @nErrNo = 133403    
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DEL INVOICE ER    
                     CLOSE CUR_DEL    
                     DEALLOCATE CUR_DEL    
                     GOTO RollBackTran    
                  END    
    
                  FETCH NEXT FROM CUR_DEL INTO @cLineNumber    
               END    
               CLOSE CUR_DEL    
               DEALLOCATE CUR_DEL    
    
               DELETE FROM dbo.GUI    
               WHERE Storerkey = @cStorerKey    
               AND   InvoiceNo = @cInvoiceNo    
               AND   ExternOrderKey = @cGUIExtOrderKey    
    
               IF @@ERROR <> 0    
               BEGIN    
                  SET @nErrNo = 133404    
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DEL INVOICE ER    
                  GOTO RollBackTran    
               END    
    
               -- Delete invoice pdf    
               EXEC isp_FileExists @cFilePath, @nFileExists OUTPUT, @bSuccess OUTPUT    
    
               IF @nFileExists = 1    
                  EXEC isp_DeleteFile @cFilePath, @bSuccess OUTPUT    
    
               IF @bSuccess <> 1    
               BEGIN    
                  SET @nErrNo = 133405    
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DEL INVOICE ER    
                  GOTO RollBackTran    
               END    
            END    
    
            -- Insert transmitlog3 here (Trigger status I)    
            SET @bSuccess = 1    
            EXEC ispGenTransmitLog3    
                @c_TableName        = 'HHPCKCFMLG'    
               ,@c_Key1             = @cOrderKey    
               ,@c_Key2             = ''    
               ,@c_Key3        = @cStorerkey    
               ,@c_TransmitBatch    = ''    
               ,@b_Success          = @bSuccess   OUTPUT    
               ,@n_err              = @nErrNo      OUTPUT    
               ,@c_errmsg           = @cErrMsg     OUTPUT    
    
            IF @bSuccess <> 1    
               GOTO RollBackTran    
         END    
    
         -- As for HM india use paper pick, pickdetail status will not update before using packing    
         -- so after finish the packing need do pack confirm no matter short pack or not.    
         IF rdt.RDTGetConfig( @nFunc, 'AutoPackConfirm', @cStorerKey) = '1'    
         BEGIN    
            -- Trigger pack confirm    
            UPDATE dbo.PackHeader WITH (ROWLOCK) SET    
               STATUS = '9',    
               EditWho = 'rdt.' + sUser_sName(),    
               EditDate = GETDATE()    
            WHERE PickSlipNo = @cPickSlipNo    
            AND   [Status] < '9'    
    
            IF @@ERROR <> 0    
            BEGIN    
               SET @nErrNo = 133406    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Packcfm fail    
               GOTO RollBackTran    
            END    
         END    
    
         IF rdt.RDTGetConfig( @nFunc, 'Grams2KG', @cStorerKey) = '1'    
         BEGIN    
            DECLARE @nW_CartonNo INT    
    
            DECLARE CUR_UPD CURSOR LOCAL READ_ONLY FAST_FORWARD FOR    
            SELECT CartonNo FROM dbo.PackInfo WITH (NOLOCK)    
            WHERE PickSlipNo = @cPickSlipNo    
            ORDER BY 1    
            OPEN CUR_UPD    
            FETCH NEXT FROM CUR_UPD INTO @nW_CartonNo    
            WHILE @@FETCH_STATUS <> -1    
            BEGIN    
               UPDATE dbo.PackInfo WITH (ROWLOCK) SET    
                  Weight = Weight/1000,    
                  TrafficCop = NULL    
               WHERE PickSlipNo = @cPickSlipNo    
               AND CartonNo = @nW_CartonNo    
    
               IF @@ERROR <> 0    
               BEGIN    
                  SET @nErrNo = 133407    
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd wgt fail    
                  CLOSE CUR_UPD    
                  DEALLOCATE CUR_UPD    
                  GOTO RollBackTran    
               END    
    
               FETCH NEXT FROM CUR_UPD INTO @nW_CartonNo    
            END    
            CLOSE CUR_UPD    
            DEALLOCATE CUR_UPD    
         END    
    
         GOTO CommitTrans    
    
         RollBackTran:    
               ROLLBACK TRAN rdt_840ExtUpd06    
    
         CommitTrans:    
            WHILE @@TRANCOUNT > @nTranCount    
               COMMIT TRAN    
    
         IF ( @nSeasonCodeDiff = 0 AND @nShortPack = 0 AND @nShortAlloc = 0) OR    
            ( @nSeasonCodeDiff = 1 AND @cSeasonSwapInvoiceRev = '1')    
         BEGIN    
            -- Check if invoice pdf file exists    
            --EXEC master.dbo.xp_fileexist @cFilePath, @isExists OUTPUT    
    
            --SET @cChkFilePath = 'DIR ' + @cFilePath    
            --EXEC @isExists=XP_CMDSHELL @cChkFilePath    
            EXEC isp_FileExists @cFilePath, @nFileExists OUTPUT, @bSuccess OUTPUT    
    
            --If @Exists=0, then the file exists. This saves having to declare and query a temp table,    
            --but requires that you know the file name and extension.    
            IF @nFileExists = 0    
            BEGIN    
               SET @nErrNo = 0    
               SET @cErrMsg01 = rdt.rdtgetmessage( 133408, @cLangCode, 'DSP') -- No invoice    
               SET @cErrMsg02 = rdt.rdtgetmessage( 133409, @cLangCode, 'DSP') -- Proceed to hospital    
    
               EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT,    
               @cErrMsg01, @cErrMsg02    
    
               SET @nErrNo = 0    
               GOTO Quit    
            END    
    
            SELECT @cPrinter = Printer,    
                   @cPrinter_Paper = Printer_Paper,    
                   @cFacility = Facility    
            FROM rdt.rdtMobRec WITH (NOLOCK)    
            WHERE Mobile = @nMobile    
    
            -- Check if valid printer    
            IF ISNULL( @cPrinter_Paper, '') = ''    
            BEGIN    
               SET @nErrNo = 133410    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'No Printer'    
           GOTO Quit    
            END    
    
            SELECT @cWinPrinter = WinPrinter    
            FROM rdt.rdtPrinter WITH (NOLOCK)    
            WHERE PrinterID = @cPrinter_Paper    
    
            IF CHARINDEX(',' , @cWinPrinter) > 0    
            BEGIN    
               SET @cWinPrinterName = LEFT( @cWinPrinter , (CHARINDEX(',' , @cWinPrinter) - 1) )    
               SET @cPrinterName = @cPrinter_Paper    
            END    
            ELSE    
            BEGIN    
               SET @cPrinterName =  @cPrinter_Paper    
               SET @cWinPrinterName = @cWinPrinter    
            END    
            /*    
            IF ISNULL( @cFolder2Move, '') <> ''    
            BEGIN    
               SET @cCMD = 'MOVE ' + @cWorkingFilePath + '\' + @cFileName + ' ' + @cWorkingFilePath + '\' + @cFolder2Move + '\' + @cFileName    
               SET @cCMD = RTRIM( @cCMD) + ' && ' + '"' + @cPrintFilePath + '" /t "' + @cWorkingFilePath + '\' + @cFolder2Move + '\' + @cFileName + '" "' + @cWinPrinterName + '"'    
            END    
            ELSE    
               SET @cCMD = '"' + @cPrintFilePath + '" /t "' + @cWorkingFilePath + '\' + @cFileName + '" "' + @cWinPrinterName + '"'    
            */    
            /*    
            IF ISNULL( @cFolder2Move, '') <> ''    
            BEGIN    
               SET @cMoveFileCMD = 'CMD /c MOVE "' + @cWorkingFilePath + '\' + @cFileName + '" "' + @cWorkingFilePath + '\' + @cFolder2Move + '\' + @cFileName + '"'    
                            
               SET @cCMD = '"' + @cPrintFilePath + '" /t "' + @cWorkingFilePath + '\' + @cFolder2Move + '\' + @cFileName + '" "' + @cPrinter + '"'        
            END    
            ELSE    
               SET @cCMD = '""' + @cPrintFilePath + '" /t "' + @cWorkingFilePath + '\' + @cFileName + '" "' + @cPrinter + '"'      
            */    
                
            IF CHARINDEX( 'SEND2PRINTER', @cPrintFilePath) > 0    
               SET @cPrintCommand = '"' + @cPrintFilePath + '" "' + @cWorkingFilePath + '\' + @cFileName + '" "17" "3" "' + @cWinPrinterName + '"'     
            ELSE    
               SET @cPrintCommand = '"' + @cPrintFilePath + '" /t "' + @cWorkingFilePath + '\' + @cFileName + '" "' + @cWinPrinterName + '"'        
                
            --insert into testtest (a, b) values (@cCMD, @cFolder2Move)    
            DECLARE @tRDTPrintJob AS VariableTable    
            SET @nErrNo = 0    
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, @cPrinterName, '',    
               'PDFINVOICE',     -- Report type    
               @tRDTPrintJob,    -- Report params    
               'rdt_840ExtUpd06',    
               @nErrNo  OUTPUT,    
               @cErrMsg OUTPUT,    
               1,    
               @cPrintCommand -- Print pdf file here    
    
            IF @nErrNo <> 0    
               GOTO Quit    
                   
            -- (james01)    
    
            SET @cORDLabel = rdt.RDTGetConfig( @nFunc, 'ORDLabel', @cStorerkey)    
    
            IF @cORDLabel <> ''    
            BEGIN    
               DECLARE @tORDLabel AS VariableTable    
               INSERT INTO @tORDLabel (Variable, Value) VALUES ( '@cBuyerPO',    @cGUIExtOrderKey)    
               INSERT INTO @tORDLabel (Variable, Value) VALUES ( '@cOrderKey',   @cOrderKey)    
    
               -- Print label    
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cPrinter, '',    
                  @cORDLabel, -- Report type    
                  @tORDLabel, -- Report params    
                  'rdt_840ExtUpd06',    
                  @nErrNo  OUTPUT,    
                  @cErrMsg OUTPUT    
    
    
               IF @nErrNo <> 0    
                  GOTO Quit    
            END    
         END    
      END    
   END    
    
   Quit: 
GO


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_840ExtUpd06 TO NSQL
GO