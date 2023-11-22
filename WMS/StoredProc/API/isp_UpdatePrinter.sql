SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO




/******************************************************************************/
/* Store procedure: isp_UpdatePrinter                                         */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2020-04-07   1.0  Chermaine  Created                                       */
/* 2021-09-05   1.1  Chermaine  TPS-11 ErrMsg add to rdtmsg (cc01)            */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_UpdatePrinter] (
   @json       NVARCHAR( MAX),
   @jResult    NVARCHAR( MAX) OUTPUT,
   @b_Success  INT = 1  OUTPUT,
   @n_Err      INT = 0  OUTPUT,
   @c_ErrMsg   NVARCHAR( 255) = ''  OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE
   @cLangCode     NVARCHAR( 3),
   @cUserName     NVARCHAR( 128),
   @cStorerKey    NVARCHAR( 15),
   @cFacility     NVARCHAR( 5),
   @nFunc         INT,
   @cWorkstation  NVARCHAR( 30),
   @cPrinterID    NVARCHAR( 20),
   @cPrinterType  NVARCHAR( 20)


--Decode Json Format
SELECT @nFunc=Func, @cUserName = Username, @cLangCode = LangCode, @cWorkstation = Workstation,@cPrinterID = PrinterID, @cPrinterType = PrinterType
FROM OPENJSON(@json)
WITH (
	   Func        INT,
	   UserName    NVARCHAR( 128),
      LangCode    NVARCHAR( 3),
      Workstation NVARCHAR( 30),
      PrinterID   NVARCHAR( 20),
      PrinterType NVARCHAR( 20)
)
--SELECT @nFunc AS Func, @cLangCode AS LangCode,@cWorkstation as Workstation

--convert login
SET @n_Err = 0
EXEC [WM].[lsp_SetUser] @c_UserName = @cUserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT

EXECUTE AS LOGIN = @cUserName

IF @n_Err <> 0
BEGIN
   --INSERT INTO @errMsg(nErrNo,cErrMsg)
   SET @b_Success = 0
   SET @n_Err = @n_Err
   SET @c_ErrMsg = @c_ErrMsg
   GOTO EXIT_SP
END


----SELECT @cUserName AS username
----select SUSER_SNAME ()

--Data Validate
IF @cWorkstation = ''
BEGIN
   SET @b_Success = 0
   SET @n_Err = 175679
   SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP')--'Unable to retrieve Workstation ID. Function : isp_UpdatePrinter'

   GOTO EXIT_SP
END

IF @cPrinterType = ''
BEGIN
   SET @b_Success = 0
   SET @n_Err = 175680
   SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP')--'Unable to retrieve Printer Type. Function : isp_UpdatePrinter'

   GOTO EXIT_SP
END

IF @cPrinterID = ''
BEGIN
   SET @b_Success = 0
   SET @n_Err = 175681
   SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP')--'Unable to retrieve Printer ID. Function : isp_UpdatePrinter'

   GOTO EXIT_SP
END

IF EXISTS (SELECT TOP 1 1 FROM api.AppPrinter WITH (nolock) WHERE Workstation = @cWorkstation AND PrinterType = @cPrinterType)
BEGIN
	UPDATE api.AppPrinter WITH (ROWLOCK)
   SET PrinterID = @cPrinterID
   WHERE Workstation = @cWorkstation
   AND PrinterType = @cPrinterType

   IF @@ERROR <> 0
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 175682
      SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into PackDetail. Function : isp_UpdatePrinter'

      GOTO EXIT_SP
   END
   ELSE
   BEGIN
	   SET @b_Success = 1
	   SET @jResult = '[{Success}]'
   END
END
ELSE
BEGIN
	INSERT INTO api.AppPrinter (AppName,Workstation,PrinterID,PrinterType)
	VALUES('TouchPad',@cWorkstation,@cPrinterID,@cPrinterType)

	IF @@ERROR <> 0
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 175683
      SET @c_ErrMsg = rdt.rdtgetmessage( @n_Err, @cLangCode, 'DSP')--'Fail to Insert into PackDetail. Function : isp_UpdatePrinter'

      GOTO EXIT_SP
   END
   ELSE
   BEGIN
	   SET @b_Success = 1
	   SET @jResult = '[{Success}]'
   END

END


EXIT_SP:
   REVERT

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_UpdatePrinter TO NSQL
GO


