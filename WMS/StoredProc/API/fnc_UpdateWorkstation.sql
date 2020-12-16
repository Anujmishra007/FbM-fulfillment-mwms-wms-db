IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[API].[fnc_UpdateWorkstation]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [API].[fnc_UpdateWorkstation]
GO

/****** Object:  StoredProcedure [API].[fnc_UpdateWorkstation]    Script Date: 6/3/2020 5:13:01 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/  
/* Store procedure: fnc_UpdateWorkStation                                     */  
/* Copyright      : LFLogistics                                               */  
/*                                                                            */  
/* Date         Rev  Author     Purposes                                      */  
/* 2020-04-07   1.0  Chermaine  Created                                       */  
/******************************************************************************/  
  
CREATE PROC [API].[fnc_UpdateWorkstation] (  
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
   @cDeviceID     NVARCHAR( 50)

  
--Decode Json Format
SELECT @nFunc=Func, @cUserName = Username, @cLangCode = LangCode , @cWorkstation = Workstation, @cDeviceID = DeviceID
FROM OPENJSON(@json)  
WITH (  
	   Func        INT,  
	   UserName    NVARCHAR( 128),
      LangCode    NVARCHAR( 3),
      Workstation NVARCHAR( 30),
      DeviceID    NVARCHAR( 50)
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
   SET @n_Err = 101900  
   SET @c_ErrMsg = 'Unable to retrieve Workstation ID. Function : fnc_UpdateWorkstation'
   
   GOTO EXIT_SP  
END  

IF @cDeviceID = ''  
BEGIN  
   SET @b_Success = 0  
   SET @n_Err = 101901  
   SET @c_ErrMsg = 'Unable to retrieve Device ID. Function : fnc_UpdateWorkstation'
   
   GOTO EXIT_SP  
END 
ELSE
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM api.AppWorkstation WHERE DeviceID = @cDeviceID AND workstation <> @cWorkstation)
	BEGIN
		SET @b_Success = 0  
      SET @n_Err = 101902  
      SET @c_ErrMsg = 'Invalid setup. This device has been assigned to a workstation. Function : fnc_UpdateWorkstation' 
      
      GOTO EXIT_SP
	END
END

----remove deviceID from prev workstation
--IF EXISTS (SELECT TOP 1 1 FROM api.AppWorkstation WHERE DeviceID = @cDeviceID AND workstation <> @cWorkstation)
--BEGIN
--	UPDATE api.AppWorkstation WITH (ROWLOCK)
--   SET DeviceID = ''
--   WHERE deviceID = @cDeviceID 
   
--   IF @@ERROR <> 0
--   BEGIN         
--      SET @b_Success = 0  
--      SET @n_Err = 100351  
--      SET @c_ErrMsg = 'Fail update prev Workstation' 
      
--      GOTO EXIT_SP
--   END
--END

--update new deviceID
IF EXISTS (SELECT TOP 1 1 FROM api.AppWorkstation WHERE Workstation = @cWorkstation AND deviceID ='')
BEGIN
	UPDATE api.AppWorkstation WITH (ROWLOCK)
   SET DeviceID = @cDeviceID
   WHERE Workstation = @cWorkstation
   AND deviceID = ''
   
   IF @@ERROR <> 0
   BEGIN         
      SET @b_Success = 0  
      SET @n_Err = 101903  
      SET @c_ErrMsg = 'Fail to update into Workstation. Function : fnc_UpdateWorkstation' 
      
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
	SET @b_Success = 0  
   SET @n_Err = 101904  
   SET @c_ErrMsg = 'Invalid Workstation. Please use other Workstation. Function : fnc_UpdateWorkstation' 
               
   GOTO EXIT_SP
END


EXIT_SP:
   REVERT  

SET QUOTED_IDENTIFIER OFF
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.fnc_UpdateWorkstation TO NSQL
GO

