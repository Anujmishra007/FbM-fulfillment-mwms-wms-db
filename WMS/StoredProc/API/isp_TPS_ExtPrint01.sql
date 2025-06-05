SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_TPS_ExtPrint01                                        */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2021-11-11   1.0  Chermaine  TPS-594 Created                               */
/* 2023-09-12   1.1  YeeKung    TPS-773/TPS-740 New print (yeekung3)          */
/* 2024-11-06   1.2  YeeKung    TPS-989 Add Facility (yeekung03)              */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPS_ExtPrint01] (
	@cStorerKey       NVARCHAR( 15),
   @cFacility        NVARCHAR( 5),
   @nFunc            INT,
   @cUserName        NVARCHAR( 128),
   @cLangCode        NVARCHAR( 3),
   @cScanNo          NVARCHAR( 50),
   @cpickslipNo      NVARCHAR( 30),
   @cDropID          NVARCHAR( 50),
   @cOrderKey        NVARCHAR( 10),
   @cLoadKey         NVARCHAR( 10),
   @cZone            NVARCHAR( 18),
   @EcomSingle       NVARCHAR( 1),
   @nCartonNo        INT,
   @cCartonType      NVARCHAR( 10),
   @cType            NVARCHAR( 30),
   @fCartonWeight    FLOAT,
   @fCartonCube      FLOAT,
   @cWorkstation     NVARCHAR( 30),
   @cLabelNo         NVARCHAR( 20),
   @cCloseCartonJson NVARCHAR (MAX),
   @cPrintPackList   NVARCHAR(1),
   @cLabelJobID      NVARCHAR ( 30) OUTPUT,
   @cPackingJobID    NVARCHAR ( 30) OUTPUT,
   @b_Success        INT = 1        OUTPUT,
   @n_Err            INT = 0        OUTPUT,
   @c_ErrMsg         NVARCHAR( 255) = ''  OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE @curAD CURSOR
DECLARE
	@cSKU             NVARCHAR(20),
   @cSkuBarcode      NVARCHAR(60),
   @cOrderLineNumber NVARCHAR(5),
   @cWeight          NVARCHAR(10),
   @cCube            NVARCHAR(10),
   @cLottableVal     NVARCHAR(20),
   @cSerialNoKey     NVARCHAR(60),
   @cErrMsg          NVARCHAR(128),
   @nQty             INT,
   @bsuccess         INT,
   @nErrNo           INT,
   @nTranCount       INT

DECLARE @CloseCtnList TABLE (
   SKU             NVARCHAR( 20),
   QTY             INT,
   Weight          FLOAT,
   Cube            FLOAT,
   lottableVal     NVARCHAR(60),
   SkuBarcode      NVARCHAR(60),
   ADCode          NVARCHAR(60)
)

--INSERT INTO @CloseCtnList (SKU, QTY, WEIGHT, CUBE, lottableVal,SkuBarcode, ADCode)
--SELECT
--Hdr.SKU
--, Hdr.Qty
--, Hdr.Weight
--, Hdr.Cube
--, Hdr.lottableValue
--, Det.barcodeVal
--, Det.AntiDiversionCode
--FROM OPENJSON(@cCloseCartonJson)
--WITH (
--   SKU            NVARCHAR( 20)  '$.SKU',
--   Qty            INT            '$.PackedQty',
--   Weight         FLOAT          '$.WEIGHT',
--   Cube           FLOAT          '$.CUBE',
--   lottableValue  NVARCHAR(60)   '$.Lottable',
--   barcodeObj     NVARCHAR(MAX)  '$.barcodeObj' AS JSON
--) AS Hdr
--CROSS APPLY OPENJSON(barcodeObj)
--WITH (
--   barcodeVal        NVARCHAR(60) '$.barcodeVal',
--   AntiDiversionCode NVARCHAR(60) '$.AntiDiversionCode'
--) AS Det

--SELECT 'aa',* FROM @CloseCtnList

DECLARE @tShipLabel AS VariableTable
DECLARE @cConsignee     NVARCHAR(15)
DECLARE @cReportType    nvarchar(20)
DECLARE @cLabelPrinter  NVARCHAR ( 30)
DECLARE @cPaperPrinter  NVARCHAR ( 30)
DECLARE @nJobID         INT
DECLARE @nRC            INT
DECLARE @cSQL           NVARCHAR ( MAX)
DECLARE @cSQLParam      NVARCHAR ( MAX)
DECLARE @cColumn        NVARCHAR( 60)
DECLARE @cValue         NVARCHAR( 60)


DECLARE   @c_ModuleID           NVARCHAR(30) ='TPPack'
      , @c_ReportID           NVARCHAR(10) 
      , @c_PrinterID          NVARCHAR(30)  
      , @c_JobIDs             NVARCHAR(50)   = ''         --(Wan03) -- May return multiple jobs ID.JobID seperate by '|'
      , @c_PrintSource        NVARCHAR(20)
      , @c_AutoPrint          NVARCHAR(1)    = 'N'        --(Wan07)
  

set @cLabelJobID = ''
set @cPackingJobID = ''

BEGIN
	IF @cPickSlipNo <> ''
	BEGIN

		SELECT TOP 1 @cColumn = UDF01, @cValue = Long FROM codelkup WITH (NOLOCK) WHERE storerKey = @cstorerKey AND listname = 'TPPrintFlt' AND code = 'ORDERS'

		--INSERT INTO @tShipLabel (Variable, Value) VALUES
  --    ( '@c_StorerKey',     @cStorerKey),
  --    ( '@c_PickSlipNo',    @cPickSlipNo),
  --    ( '@c_StartCartonNo', CAST( @nCartonNo AS NVARCHAR(10))),
  --    ( '@c_EndCartonNo',   CAST( @nCartonNo AS NVARCHAR(10)))

      SET @cSQL = ' Select 1 ' +
            ' FROM ORDERS WIH (NOLOCK) ' +
            ' WHERE OrderKey = @cOrderKey ' +
            ' AND StorerKey = @cStorerKey ' +
            ' AND ' + @cColumn + ' IN ( SELECT Long FROM codelkup WITH (NOLOCK) WHERE storerKey = @cstorerKey AND listname = ''TPPrintFlt'' AND code = ''ORDERS'') ' +
            ' SET @nRC = @@RowCount '

      SET @cSQLParam =
            ' @cOrderKey   NVARCHAR( 10), ' +
            ' @cStorerKey  NVARCHAR( 15), ' +
            ' @cValue      NVARCHAR( 15), ' +
            ' @nRC         INT OUTPUT '

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam, @cOrderKey, @cStorerKey, @cValue, @nRC OUTPUT
      
		IF @nRC = 0
		BEGIN

         IF ISNULL(@cLabelPrinter,'') = ''
         BEGIN
            SET @b_Success = 0
            SET @n_Err = 175743
            SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP')--'Label Printer setup not done. Please setup the Label Printer. Function : isp_TPS_ExtPrint01'
            GOTO Quit
         END
         ELSE
         BEGIN
            SELECT @c_ReportID = WMR.reportid,
                     @c_PrintSource = CASE WHEN printtype='LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END
            FROM WMReport WMR (NOLOCK)
            JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
            WHERE Storerkey = @cStorerkey
               AND reporttype = 'TPSHIPPLBL'
               AND ModuleID ='TPPack'
               AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  

            EXEC  [WM].[lsp_WM_Print_Report]
               @c_ModuleID = @c_ModuleID           
            , @c_ReportID = @c_ReportID         
            , @c_Storerkey = @cStorerkey         
            , @c_Facility  = @cFacility        
            , @c_UserName  = @cUsername   
            , @c_ComputerName = ''
            , @c_PrinterID = @cLabelPrinter         
            , @n_NoOfCopy  = '1'     
            , @c_KeyValue1 = @cStorerKey        
            , @c_KeyValue2 = @cPickSlipNo        
            , @c_KeyValue3 = @nCartonNo     
            , @c_KeyValue4 = @nCartonNo       
            , @b_Success   = @b_Success         OUTPUT      
            , @n_Err       = @n_Err             OUTPUT
            , @c_ErrMsg    = @c_ErrMsg          OUTPUT
            , @c_PrintSource  = @c_PrintSource        
            , @b_SCEPreView   = 0         
            , @c_JobIDs      = @cLabelJobID         OUTPUT    
            , @c_AutoPrint  = 'N'     

            set @cLabelJobID = @nJobID
         END
		END
		IF @cPrintPackList = 'Y'
      BEGIN
         IF EXISTS (SELECT  TOP 1 1 FROM dbo.WMReport WMR WITH (NOLOCK) 
                     JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
                     WHERE Storerkey = @cStorerKey 
                        AND reporttype ='TPPACKLIST')
         BEGIN
            IF ISNULL(@cPaperPrinter,'') = ''
            BEGIN
               SET @b_Success = 0
               SET @n_Err = 175744
               SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP')--'Paper Printer setup not done. Please setup the Paper Printer. Function : isp_TPS_ExtPrint01'
               GOTO Quit
            END
            ELSE
            BEGIN
               SELECT @c_ReportID = WMR.reportid,
                        @c_PrintSource = CASE WHEN printtype='LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END
               FROM WMReport WMR (NOLOCK)
               JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
               WHERE Storerkey = @cStorerkey
                  AND reporttype = 'TPPACKLIST'
                  AND ModuleID ='TPPack'
                  AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  

               EXEC  [WM].[lsp_WM_Print_Report]
                  @c_ModuleID = @c_ModuleID           
               , @c_ReportID = @c_ReportID         
               , @c_Storerkey = @cStorerkey         
               , @c_Facility  = @cFacility        
               , @c_UserName  = @cUsername   
               , @c_ComputerName = ''
               , @c_PrinterID = @cPaperPrinter         
               , @n_NoOfCopy  = '1'     
               , @c_KeyValue1 = @cStorerKey        
               , @c_KeyValue2 = @cPickSlipNo        
               , @c_KeyValue3 = @nCartonNo     
               , @c_KeyValue4 = @nCartonNo       
               , @b_Success   = @b_Success         OUTPUT      
               , @n_Err       = @n_Err             OUTPUT
               , @c_ErrMsg    = @c_ErrMsg          OUTPUT
               , @c_PrintSource  = @c_PrintSource        
               , @b_SCEPreView   = 0         
               , @c_JobIDs      = @cLabelJobID         OUTPUT    
               , @c_AutoPrint  = 'N'     

               set @cLabelJobID = @nJobID
            END
         END
      END
	END

Quit:

END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtPrint01 TO NSQL
GO


