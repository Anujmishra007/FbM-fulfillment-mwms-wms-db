
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
/* 2021-08-17   1.1  Chermaine  TPS-623 use pass in b2b pickslipNo (cc01)     */
/* 2021-09-05   1.2  Chermaine  TPS-11 ErrMsg add to rdtmsg (cc02)            */
/* 2021-12-08   1.3  Chermaine  TPS-600 Split Print button (cc03)             */
/* 2023-05-30   1.4  yeekung  TPS-708 All print all config                    */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_rePrint] (
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
   @PrinterType      NVARCHAR(10), --(cc03)

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
select @cStorerKey = StorerKey, @cFacility = Facility,@nFunc = Func,@cUserName = UserName,@cLangCode = LangCode
,@cScanNo = ScanNo,@nCartonNo = CartonNo, @cType = ctype,  @cWorkstation = Workstation, @cOrderKeyPrint = OrderKey
,@PrinterType = PrinterType  --(cc03)
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
      OrderKey       NVARCHAR( 10),
      PrinterType    NVARCHAR( 10)
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
	IF @cType <> 'pickslip' --(cc01)
	BEGIN
		SELECT @cPickSlipNo = PickSlipNo FROM api.appSection WITH (NOLOCK) WHERE userID = @cOriUserName AND scanNo = @cScanNo
	END
	ELSE
	BEGIN
		SET @cPickSlipNo = @cScanNo
	END

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

SELECT @cPickSlipNo AS picksliNo, @nPrintPackList '@nPrintPackList'


--lookup printer
DECLARE @cLabelPrinter NVARCHAR ( 30)
DECLARE @cPaperPrinter NVARCHAR ( 30)
DECLARE @cLabelJobID   NVARCHAR ( 30)
DECLARE @cPackingJobID NVARCHAR ( 30)
DECLARE @curPrint      CURSOR
DECLARE @cPrintAllLbl  NVARCHAR( 30)
-- Common params ofr printing
DECLARE @tShipLabel AS VariableTable

set @cLabelJobID = ''
set @cPackingJobID = ''
SELECT @cPaperPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Paper'
SELECT @cLabelPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Label'

SELECT @cPrintAllLbl=1 FROM storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey = 'TPS-PrintAllLbl' AND sValue = '1'


IF ISNULL(@cPrintAllLbl,'') <> ''
BEGIN
   --Close: packDetail  
   SET @curPrint = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
   SELECT  cartonno 
   FROM packdetail WITH (NOLOCK) 
   WHERE pickslipno = @cPickSlipNo
      AND storerKey = @cStorerKey
   group by cartonno
   order by CAST(cartonno AS  INT)
   OPEN @curPrint  
   FETCH NEXT FROM @curPrint INTO @nCartonNo  
   WHILE @@FETCH_STATUS <> -1  
   BEGIN  

      select @cStorerKey,@cPickSlipNo,@nCartonNo

      INSERT INTO @tShipLabel (Variable, Value) VALUES
         ( '@c_StorerKey',     @cStorerKey),
         ( '@c_PickSlipNo',    @cPickSlipNo),
         ( '@c_StartCartonNo', CAST( @nCartonNo AS NVARCHAR(10))),
         ( '@c_EndCartonNo',   CAST( @nCartonNo AS NVARCHAR(10)))


      IF @PrinterType = 'Label' --(cc03)
      BEGIN
         -- Print label
         IF EXISTS (select TOP 1 1 FROM rdt.rdtReport WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND reportType ='TPSHIPPLBL')
         BEGIN
	         IF ISNULL(@cLabelPrinter,'') = ''
	         BEGIN
		         SET @b_Success = 0
                  SET @n_Err = 175625
                  SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP')--'Label Printer setup not done. Please setup the Label Printer. Function : isp_rePrint'

                  GOTO EXIT_SP
	         END
	         ELSE
	         BEGIN
		         EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
               'TPSHIPPLBL', -- Report type
               @tShipLabel, -- Report params
               'API.isp_RePrint', --source Type
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
      END

      delete @tShipLabel

      FETCH NEXT FROM @curPrint INTO @nCartonNo  
   END
   CLOSE @curPrint
   DEALLOCATE  @curPrint
END
ELSE
BEGIN
   IF ISNULL(@cOrderKeyPrint,'') = ''
   BEGIN
	   --b2b
	   IF @cType <> 'pickslip' --(cc01)
	   BEGIN
		   SELECT @cPickSlipNo = PickSlipNo FROM api.appSection WITH (NOLOCK) WHERE userID = @cOriUserName AND scanNo = @cScanNo
	   END
	   ELSE
	   BEGIN
		   SET @cPickSlipNo = @cScanNo
	   END

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

   SELECT @cPickSlipNo AS picksliNo, @nPrintPackList '@nPrintPackList'


   INSERT INTO @tShipLabel (Variable, Value) VALUES
      ( '@c_StorerKey',     @cStorerKey),
      ( '@c_PickSlipNo',    @cPickSlipNo),
      ( '@c_StartCartonNo', CAST( @nCartonNo AS NVARCHAR(10))),
      ( '@c_EndCartonNo',   CAST( @nCartonNo AS NVARCHAR(10)))

   set @cLabelJobID = ''
   set @cPackingJobID = ''
   SELECT @cPaperPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Paper'
   SELECT @cLabelPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Label'

   IF @PrinterType = 'Label' --(cc03)
   BEGIN
      -- Print label
      IF EXISTS (select TOP 1 1 FROM rdt.rdtReport WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND reportType ='TPSHIPPLBL')
      BEGIN
	      IF ISNULL(@cLabelPrinter,'') = ''
	      BEGIN
		      SET @b_Success = 0
               SET @n_Err = 175625
               SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP')--'Label Printer setup not done. Please setup the Label Printer. Function : isp_rePrint'

               GOTO EXIT_SP
	      END
	      ELSE
	      BEGIN
		      EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
            'TPSHIPPLBL', -- Report type
            @tShipLabel, -- Report params
            'API.isp_RePrint', --source Type
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
   END
END

-- Common params ofr printing
DECLARE @tPackList AS VariableTable
INSERT INTO @tPackList (Variable, Value) VALUES
( '@c_StorerKey',     @cStorerKey),
( '@c_PickSlipNo',    @cPickSlipNo),
( '@c_StartCartonNo', CAST( @nCartonNo AS NVARCHAR(10))),
( '@c_EndCartonNo',   CAST( @nCartonNo AS NVARCHAR(10)))

IF @PrinterType = 'Paper' --(cc03)
BEGIN
	IF @nPrintPackList = 'Y'
   BEGIN
      IF EXISTS (select TOP 1 1 FROM rdt.rdtReport WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND reportType ='TPPACKLIST')
      BEGIN
	      IF ISNULL(@cPaperPrinter,'') = ''
	      BEGIN
		      SET @b_Success = 0
            SET @n_Err = 175626
            SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP')--'Paper Printer setup not done. Please setup the Paper Printer. Function : isp_rePrint'

            GOTO EXIT_SP
	      END
	      ELSE
	      BEGIN
		      EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
            'TPPACKLIST', -- Report type
            @tPackList, -- Report params
            'API.isp_RePrint', --source Type
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


IF @PrinterType = 'Paper' --(cc03)
BEGIN
	IF @nPrintPackList = 'Y'
   BEGIN
      IF EXISTS (select TOP 1 1 FROM rdt.rdtReport WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND reportType ='TPPACKLIST')
      BEGIN
	      IF ISNULL(@cPaperPrinter,'') = ''
	      BEGIN
		      SET @b_Success = 0
            SET @n_Err = 175626
            SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP')--'Paper Printer setup not done. Please setup the Paper Printer. Function : isp_rePrint'

            GOTO EXIT_SP
	      END
	      ELSE
	      BEGIN
		      EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
            'TPPACKLIST', -- Report type
 @tShipLabel, -- Report params
            'API.isp_RePrint', --source Type
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
