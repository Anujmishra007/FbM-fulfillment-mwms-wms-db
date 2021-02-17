IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[API].[isp_rePrint]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [API].[isp_rePrint]
GO

/****** Object:  StoredProcedure [API].[isp_rePrint]    Script Date: 6/3/2020 5:02:23 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_rePrint                                               */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2020-04-14   1.0  Chermaine  Created                                       */
/******************************************************************************/

CREATE PROC [API].[isp_rePrint] (
   @json       NVARCHAR( MAX),  
   @jResult    NVARCHAR( MAX) ='' OUTPUT,  
   @b_Success  INT = 1  OUTPUT,  
   @n_Err      INT = 0  OUTPUT,  
   @c_ErrMsg   NVARCHAR( 255) = ''  OUTPUT 
)
AS
BEGIN
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE 

   @nMobile          INT,
   @nStep            INT,
   @cLangCode        NVARCHAR( 3),
   @nInputKey        INT,
   @cZone            NVARCHAR( 10),
   @cScanNoType      NVARCHAR( 30),
   @cLot             NVARCHAR( 30),
   @EcomSingle       NVARCHAR( 1),
   @CalOrderSKU      NVARCHAR( 1),
   @cDynamicRightName1  NVARCHAR( 30),
   @cDynamicRightValue1 NVARCHAR( 30),
   
   @cStorerKey       NVARCHAR( 15),
	@cFacility        NVARCHAR( 5),
	@nFunc            NVARCHAR( 5),
	@cUserName        NVARCHAR( 128),
	@cOriUserName     NVARCHAR( 128),
   @cScanNo          NVARCHAR( 50),
   @cDropID          NVARCHAR( 50),
   @cPickSlipNo      NVARCHAR( 30),
   @nCartonNo        INT,
   @cCartonID        NVARCHAR( 20),
   @cType            NVARCHAR( 30),
   @nQTY             INT,
   @cSKU             NVARCHAR( 20),
   @cCartonType      NVARCHAR( 10),
   @cCube            FLOAT,
   @cWeight          FLOAT,
   @cCartonWeight    FLOAT,
   @cCartonCube      FLOAT,
   @cCloseCartonJson NVARCHAR( MAX),
   @cLoadKey         NVARCHAR( 10),
   @cOrderKey        NVARCHAR( 10),
   @cOrderKeyPrint   NVARCHAR( 10),
   @nPickQty         INT,
   @nPackQty         INT,

   @cUPC             NVARCHAR( 30),
   @cLabelLine       NVARCHAR(5),

   @bSuccess         INT,
   @nErrNo           INT, 
   @cErrMsg          NVARCHAR(250),
   @nTranCount       INT,
   @curPD            CURSOR,
   @GetCartonID      NVARCHAR( MAX),
   @cShipLabel       NVARCHAR( 10),
   @nJobID           INT,
   @cWorkstation     NVARCHAR( 30),
   @pickSkuDetailJson   NVARCHAR( MAX),
   @nPrintPackList      NVARCHAR( 1),
   @cSQL                NVARCHAR( MAX)

SET @nPrintPackList = 'N'

--decode json
select @cStorerKey = StorerKey, @cFacility = Facility,@nFunc = Func,@cUserName = UserName,@cLangCode = LangCode,@cScanNo = ScanNo,@nCartonNo = CartonNo, @cType = ctype,  @cWorkstation = Workstation, @cOrderKeyPrint = OrderKey
   FROM OPENJSON(@json)  
   WITH (
	   StorerKey      NVARCHAR( 30),
	   Facility       NVARCHAR( 30),
      Func           NVARCHAR( 5),
      UserName       NVARCHAR( 128),
      LangCode       NVARCHAR( 3),
      ScanNo         NVARCHAR( 30),
      CartonNo       INT,
      cType          NVARCHAR( 30),
      Workstation    NVARCHAR( 30),
      OrderKey       NVARCHAR( 10)
   ) 
   
   --SELECT @cUserName AS cUserNameb4
--SELECT @cStorerKey AS StorerKey, @cFacility AS Facility,@nFunc AS Func,@cUserName AS UserName,@cScanNo AS ScanNo,@nCartonNo AS CartonNo,@ctype AS ctype,@cWeight AS cWeight, @cCube AS cCube
SET @cOriUserName = @cUserName
--convert login 
SET @n_Err = 0 
EXEC [WM].[lsp_SetUser] @c_UserName = @cUserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT

EXECUTE AS LOGIN = @cUserName

IF @n_Err <> 0 
BEGIN  
   --INSERT INTO @errMsg(nErrNo,cErrMsg)  
   SET @b_Success = 0  
   SET @n_Err = @n_Err  
--   SET @c_ErrMsg = @c_ErrMsg 
   GOTO EXIT_SP  
END  
--SELECT @cUserName AS cUserName
--SELECT SUSER_NAME() AS sname

--SELECT @cUserName AS cUserName, @cScanNo AS cScanNo, @c_OriUserName AS c_UserName
--search pickslipNo
IF ISNULL(@cOrderKeyPrint,'') = ''
BEGIN
	--b2b
	SELECT @cPickSlipNo = PickSlipNo FROM api.appSection WITH (NOLOCK) WHERE userID = @cOriUserName AND scanNo = @cScanNo
	IF EXISTS (SELECT TOP 1 1 FROM packHeader WHERE pickslipNo = @cPickSlipNo AND STATUS = 9)
	BEGIN
		SET @nPrintPackList = 'Y'
	END
END
ELSE
BEGIN
	--b2c
	SELECT @cPickSlipNo = PickSlipNo FROM packHeader WITH (NOLOCK) WHERE orderkey = @cOrderKeyPrint AND storerKey = @cStorerKey
	IF EXISTS (SELECT TOP 1 1 FROM packHeader WHERE pickslipNo = @cPickSlipNo AND orderKey = @cOrderKeyPrint AND STATUS = 9)
	BEGIN
		SET @nPrintPackList = 'Y'
	END
END

--SELECT @cPickSlipNo AS picksliNo

-- Common params ofr printing
DECLARE @tShipLabel AS VariableTable
INSERT INTO @tShipLabel (Variable, Value) VALUES 
   ( '@c_StorerKey',     @cStorerKey), 
   ( '@c_PickSlipNo',    @cPickSlipNo), 
   ( '@c_StartCartonNo', CAST( @nCartonNo AS NVARCHAR(10))),
   ( '@c_EndCartonNo',   CAST( @nCartonNo AS NVARCHAR(10)))

--lookup printer
DECLARE @cLabelPrinter NVARCHAR ( 30)
DECLARE @cPaperPrinter NVARCHAR ( 30)
DECLARE @cLabelJobID   NVARCHAR ( 30)
DECLARE @cPackingJobID NVARCHAR ( 30)

set @cLabelJobID = ''
set @cPackingJobID = ''
SELECT @cPaperPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Paper'
SELECT @cLabelPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Label'

-- Print label
IF EXISTS (select TOP 1 1 FROM rdt.rdtReport WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND reportType ='TPSHIPPLBL')
BEGIN
	IF ISNULL(@cLabelPrinter,'') = ''
	BEGIN
		SET @b_Success = 0  
         SET @n_Err = 102100  
         SET @c_ErrMsg = 'Label Printer setup not done. Please setup the Label Printer.'

         GOTO EXIT_SP
	END
	ELSE
	BEGIN
		EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter, 
      'TPSHIPPLBL', -- Report type
      @tShipLabel, -- Report params
      'API.isp_PackConfim', --source Type
      @n_Err  OUTPUT,
      @c_ErrMsg OUTPUT,
      '1', --noOfCopy
      '', --@cPrintCommand
      @nJobID OUTPUT,
      @cUsername

      set @cLabelJobID = @nJobID

      IF @n_Err <> 0 
      BEGIN
         SET @b_Success = 0
         SET @n_Err = @n_Err
         SET @c_ErrMsg = @c_ErrMsg
         GOTO EXIT_SP
      END
	END	
END

IF @nPrintPackList = 'Y' 
BEGIN
   IF EXISTS (select TOP 1 1 FROM rdt.rdtReport WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND reportType ='TPPACKLIST')
   BEGIN
	   IF ISNULL(@cPaperPrinter,'') = ''
	   BEGIN
		   SET @b_Success = 0  
         SET @n_Err = 102101  
         SET @c_ErrMsg = 'Paper Printer setup not done. Please setup the Paper Printer.'

         GOTO EXIT_SP
	   END
	   ELSE
	   BEGIN
		   EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter, 
         'TPPACKLIST', -- Report type
         @tShipLabel, -- Report params
         'API.isp_PackConfim', --source Type
         @n_Err  OUTPUT,
         @c_ErrMsg OUTPUT,
         '1', --noOfCopy
         '', --@cPrintCommand
         @nJobID OUTPUT,
         @cUsername

         SET @cPackingJobID = @nJobID

         IF @n_Err <> 0 
         BEGIN
            SET @b_Success = 0
            SET @n_Err = @n_Err
            SET @c_ErrMsg = @c_ErrMsg
            GOTO EXIT_SP
         END
	   END	
   END
END

               
--set @cPackingJobID = 'test123'
SET @b_Success = 1
SET @jResult = (select @cLabelJobID as LabelJobID, @cPackingJobID as PackingJobID FOR JSON PATH ) 
SET @n_Err = 0
SET @c_ErrMsg = ''
GOTO EXIT_SP
   

         
EXIT_SP:
REVERT

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_rePrint TO NSQL
GO



