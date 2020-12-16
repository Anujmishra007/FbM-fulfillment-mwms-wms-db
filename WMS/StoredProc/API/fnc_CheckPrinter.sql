IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[API].[fnc_CheckPrinter]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [API].[fnc_CheckPrinter]
GO

/****** Object:  StoredProcedure [API].[fnc_CheckPrinter]    Script Date: 6/3/2020 4:40:55 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/  
/* Store procedure: fnc_CheckPrinter                                          */  
/* Copyright      : LFLogistics                                               */  
/*                                                                            */  
/* Date         Rev  Author     Purposes                                      */  
/* 2020-04-07   1.0  Chermaine  Created                                       */  
/******************************************************************************/  
  
CREATE PROC [API].[fnc_CheckPrinter] (  
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
   @cLangCode        NVARCHAR( 3),  
   @cUserName        NVARCHAR( 128),
   @cStorerKey       NVARCHAR( 15),  
   @cFacility        NVARCHAR( 5),  
   @nFunc            INT,    
   @cWorkstation     NVARCHAR( 30),
   @cReportType      NVARCHAR( 20),
   @cPrinterType     NVARCHAR( 20),
   @cPrinterTypeJson NVARCHAR( 500),
   @curPT            CURSOR
  
DECLARE @PrinterTypeList TABLE (
   PrinterType   NVARCHAR( 20)  
)

  
--Decode Json Format
SELECT @cStorerKey = StorerKey, @cFacility = Facility,  @nFunc=Func, @cUserName = UserName, @cLangCode = LangCode, @cWorkstation = Workstation, @cPrinterTypeJson = PrinterType
FROM OPENJSON(@json)  
WITH (  
	   StorerKey   NVARCHAR( 15),
	   Facility    NVARCHAR( 5),
	   Func        INT,  
	   UserName    NVARCHAR( 128),
      LangCode    NVARCHAR( 3),
      Workstation NVARCHAR( 30),
      PrinterType NVARCHAR( MAX) as json
)  
--SELECT @nFunc AS Func, @cLangCode AS LangCode,@cWorkstation as Workstation

--Data Validate  
IF @cWorkstation = ''  
BEGIN  
   SET @b_Success = 0  
   SET @n_Err = 100500  
   SET @c_ErrMsg = 'Unable to retrieve Workstation ID. Function : fnc_CheckPrinter. Function : fnc_CheckPrinter'
   
   GOTO EXIT_SP  
END  

IF @cStorerKey = ''  
BEGIN  
   SET @b_Success = 0  
   SET @n_Err = 100501
   SET @c_ErrMsg = 'Unable to retrieve StorerKey. Function : fnc_CheckPrinter'
   
   GOTO EXIT_SP  
END 

SET @c_ErrMsg = ''
SET @curPT = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT *
   FROM OPENJSON(@cPrinterTypeJson)
   WITH (
         Printer             NVARCHAR( 20)    '$.Printer'
   )
   
OPEN @curPT
   FETCH NEXT FROM @curPT INTO @cPrinterType
   WHILE @@FETCH_STATUS <> -1
   BEGIN

      IF @cPrinterType = 'Label' 
      BEGIN
	      IF EXISTS (SELECT TOP 1 ReportType FROM rdt.rdtReport WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND paperType = @cprinterType)
	      BEGIN
	         SET @b_Success = 0  
            SET @n_Err = 100502  
            IF @c_ErrMsg = ''
            BEGIN
            	SET @c_ErrMsg = @cPrinterType+ ' printer'
            END
            ELSE
            BEGIN
            	SET @c_ErrMsg = @c_ErrMsg + ' and ' + @cPrinterType+ ' printer'
            END
            
            --SET @c_ErrMsg = @c_ErrMsg +' not setup in Touch Pack config. Function : fnc_CheckPrinter'

            --GOTO EXIT_SP
         END
      END
      ELSE
      BEGIN
	      IF EXISTS (SELECT TOP 1 ReportType FROM rdt.rdtReport WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND (paperType = @cprinterType OR paperType = ''))
	      BEGIN
	         SET @b_Success = 0  
            SET @n_Err = 100503  
            IF @c_ErrMsg = ''
            BEGIN
            	SET @c_ErrMsg =  @cPrinterType+ ' printer'
            END
            ELSE
            BEGIN
            	SET @c_ErrMsg = @c_ErrMsg + ' and ' + @cPrinterType+ ' printer'
            END
            --SET @c_ErrMsg = @c_ErrMsg +' not setup in Touch Pack config. Function : fnc_CheckPrinter'
            --GOTO EXIT_SP
         END
      END
      
      FETCH NEXT FROM @curPT INTO @cPrinterType
   END

IF @c_ErrMsg = ''
BEGIN
	SET @b_Success = 1
   SET @jResult = '[{Success}]'
END
ELSE
BEGIN
	SET @c_ErrMsg = @c_ErrMsg +' not setup in Touch Pack config. Function : fnc_CheckPrinter'
END


EXIT_SP:
   REVERT  


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.fnc_CheckPrinter TO NSQL
GO


