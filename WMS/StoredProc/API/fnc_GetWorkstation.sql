IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[API].[fnc_GetWorkstation]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [API].[fnc_GetWorkstation]
GO

/****** Object:  StoredProcedure [API].[fnc_GetWorkstation]    Script Date: 6/3/2020 4:55:57 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/  
/* Store procedure: fnc_GetWorkstation                                        */  
/* Copyright      : LFLogistics                                               */  
/*                                                                            */  
/* Date         Rev  Author     Purposes                                      */  
/* 2020-05-05   1.0  Chermaine  Created                                       */  
/******************************************************************************/  
  
CREATE PROC [API].[fnc_GetWorkstation] (  
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
   @cUserName        NVARCHAR( 30),
   @cStorerKey       NVARCHAR( 15),  
   @cFacility        NVARCHAR( 5),  
   @nFunc            INT,    
   @cDeviceID        NVARCHAR( 50),
   @cDefaultWorkstation     NVARCHAR( 30)

  
--Decode Json Format
SELECT @nFunc=Func, @cLangCode = LangCode, @cDeviceID = Device
FROM OPENJSON(@json)  
WITH (  
	   Func        INT,  
      LangCode    NVARCHAR( 3),
      Device      NVARCHAR( 50)
)  
--SELECT @nFunc AS Func, @cLangCode AS LangCode,@cWorkstation as Workstation

----convert login 
--SET @n_Err = 0 
--EXEC [WM].[lsp_SetUser] @c_UserName = @cUserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT

--EXECUTE AS LOGIN = @cUserName

--IF @n_Err <> 0 
--BEGIN  
--   --INSERT INTO @errMsg(nErrNo,cErrMsg)  
--   SET @b_Success = 0  
--   SET @n_Err = @n_Err  
--   SET @c_ErrMsg = @c_ErrMsg 
--   GOTO EXIT_SP  
--END  


----SELECT @cUserName AS username
----select SUSER_SNAME ()

IF @cDeviceID <>''
BEGIN
	SELECT @cDefaultWorkstation = workstation FROM API.AppWorkstation WHERE deviceid = @cDeviceID 
	
	IF ISNULL(@cDefaultWorkstation,'') = ''
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM Api.AppWorkstation WITH (NOLOCK) WHERE deviceID ='')
	   BEGIN
		   SET @b_Success = 0  
         SET @n_Err = 102000  
         SET @c_ErrMsg = 'No workstation available for device setup. Please ensure workstation has been setup to proceed for device setup. Funtion : fnc_GetWorkstation'
      
         GOTO EXIT_SP
	   END
	END
END
ELSE
BEGIN
	SET @b_Success = 0  
   SET @n_Err = 102001  
   SET @c_ErrMsg = 'Device ID setup not done. Please setup the Device ID. Funtion : fnc_GetWorkstation'
      
   GOTO EXIT_SP
END	

SET @b_Success = 1

--SET @jResult =( 
--SELECT @cDefaultWorkstation AS DefaultWorkstation,workstation 
--FROM Api.AppWorkstation WITH (NOLOCK)
--FOR JSON AUTO
--)

SET @jResult =(
SELECT @cDefaultWorkstation AS DefaultWorkstation,* FROM (SELECT 
'[' +STUFF(( SELECT ',' + '"' + workstation  + '"' 
FROM Api.AppWorkstation WITH (NOLOCK) WHERE deviceID ='' FOR XML PATH('')),1,1,'')+ ']' as WorkStationList
)WorkStationList1 
FOR JSON AUTO 
)


EXIT_SP:
   REVERT  

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.fnc_GetWorkstation TO NSQL
GO


