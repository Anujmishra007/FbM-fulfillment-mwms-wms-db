IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[API].[fnc_GetPrinter]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [API].[fnc_GetPrinter]
GO

/****** Object:  StoredProcedure [API].[fnc_GetPrinter]    Script Date: 6/3/2020 4:50:51 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/  
/* Store procedure: fnc_GetPrinter                                            */  
/* Copyright      : LFLogistics                                               */  
/*                                                                            */  
/* Date         Rev  Author     Purposes                                      */  
/* 2020-04-06   1.0  Chermaine  Created                                       */  
/******************************************************************************/  
  
Create PROC [API].[fnc_GetPrinter] (  
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
   @cLangCode           NVARCHAR( 3),  
   @cUserName           NVARCHAR( 30),
   @cStorerKey          NVARCHAR( 15),  
   @cFacility           NVARCHAR( 5),  
   @nFunc               INT,    
   @cWorkstation        NVARCHAR( 30),
   @cLabelPrinterConfig NVARCHAR( 20),
   @cPaperPrinterConfig NVARCHAR( 20)

  
--Decode Json Format
SELECT @nFunc=Func, @cLangCode = LangCode, @cWorkstation = Workstation
FROM OPENJSON(@json)  
WITH (  
	   Func        INT,  
      LangCode    NVARCHAR( 3),
      Workstation NVARCHAR( 30)
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

--Data Validate  - ScanNo
IF @cWorkstation = ''  
BEGIN  
   SET @b_Success = 0  
   SET @n_Err = 101000  
   SET @c_ErrMsg = 'Unable to retrieve Workstation ID. Function : fnc_GetPrinter'
   
   GOTO EXIT_SP  
END  

SELECT @cLabelPrinterConfig = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND PrinterType = 'Label'
SELECT @cPaperPrinterConfig = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND PrinterType = 'Paper'

SET @b_Success = 1
SET @jResult =(
SELECT @cLabelPrinterConfig AS LabelPrinterConfig,@cPaperPrinterConfig AS PaperPrinterConfig,* FROM (SELECT 
'[' +STUFF(( SELECT ',' + '"' + printerID  + '"' 
FROM rdt.rdtPrinter WITH (NOLOCK) FOR XML PATH('')),1,1,'')+ ']' as LabelPrinter
,
'[' +STUFF(( SELECT ',' + '"' + printerID + '"' 
FROM rdt.rdtPrinter WITH (NOLOCK) FOR XML PATH('')),1,1,'')+ ']' as PaperPrinter
)PrinterList 
FOR JSON AUTO 
)

--SET @jResult =(
--SELECT JSON_QUERY('[' + STUFF(( SELECT ',' + '"' + printerID + '"' 
--FROM rdt.rdtPrinter WITH (NOLOCK) FOR XML PATH('')),1,1,'') + ']' ) LabelPrinter  
--FOR JSON PATH , WITHOUT_ARRAY_WRAPPER
--)



EXIT_SP:
   REVERT  

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.fnc_GetPrinter TO NSQL
GO


