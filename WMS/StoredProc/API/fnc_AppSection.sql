IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[API].[fnc_AppSection]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [API].[fnc_AppSection]
GO

/****** Object:  StoredProcedure [API].[fnc_AppSection]    Script Date: 6/3/2020 4:35:06 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO



/******************************************************************************/  
/* Store procedure: fnc_AppSection                                            */  
/* Copyright      : LFLogistics                                               */  
/*                                                                            */  
/* Date         Rev  Author     Purposes                                      */  
/* 2020-03-13   1.0  Chermaine  Created                                       */  
/******************************************************************************/  
  
--App,DeviceID,UserID,ScanNo
CREATE PROC [API].[fnc_AppSection] (  
   @json       NVARCHAR( MAX),  
   @jResult    NVARCHAR( MAX) OUTPUT,  
   @b_Success  INT = 1  OUTPUT,  
   @n_Err      INT = 0  OUTPUT,  
   @c_ErrMsg   NVARCHAR( 255) = ''  OUTPUT,
   @n_LogOut   INT = 0  OUTPUT
)  
AS  
  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
SET CONCAT_NULL_YIELDS_NULL OFF  
  
DECLARE   
	@cStorerKey    NVARCHAR( 30),
	@cFacility     NVARCHAR( 5),  
	@cLangCode     NVARCHAR( 3),  
	@cAppName      NVARCHAR( 30),
	@cDeviceID     NVARCHAR( 50),
	@cUserID       NVARCHAR( 128), 
   @cScanNo       NVARCHAR( 30),
   @cType         NVARCHAR( 30),
   @timeOut       INT,
   @dNow          DATETIME,
   @c_UserName    NVARCHAR( 128),
   @cSCEUserName  NVARCHAR( 128)
   
SET @dNow = GETDATE()

DECLARE @errMsg TABLE (  
    nErrNo    INT,  
    cErrMsg   NVARCHAR( 1024)  
)  
  
--Decode Json Format
--'[{"StorerKey":"NIKESG","Facility":"","AppName":"TouchPad","DeviceID":"Device2","UserID":"chermainecheng","ScanNo":"","cType":"Login"}]
SELECT @cStorerKey = StorerKey, @cFacility = Facility, @cAppName = AppName, @cDeviceID = DeviceID,  @cUserID=UserID, @cScanNo=ScanNo, @cType = cType
FROM OPENJSON(@json)  
WITH (  
	   StorerKey   NVARCHAR( 30),
	   Facility    NVARCHAR( 15),
	   AppName     NVARCHAR( 30),
	   DeviceID    NVARCHAR( 50),
	   UserID      NVARCHAR( 128), 
      ScanNo      NVARCHAR( 30),
      cType       NVARCHAR( 30)
)  

SET @cSCEUserName = @cUserID
--SELECT @cStorerKey, @cFacility, @cAppName, @cDeviceID,  @cUserID, @cScanNo, @cType

--convert login 
SET @n_Err = 0 
EXEC [WM].[lsp_SetUser] @c_UserName = @cUserID OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT

EXECUTE AS LOGIN = @cUserID

IF @n_Err <> 0 
BEGIN  
   --INSERT INTO @errMsg(nErrNo,cErrMsg)  
   SET @b_Success = 0  
   SET @n_Err = @n_Err  
--   SET @c_ErrMsg = @c_ErrMsg 
   GOTO EXIT_SP  
END  



--SELECT @c_UserName AS c_UserName
--SELECT @cUserID AS cUserID
--select SUSER_SNAME () AS sname

--Data Validate : Check ScanNo blank  
IF  @cAppName = '' OR @cDeviceID = ''  OR @cSCEUserName = ''
BEGIN  
   SET @b_Success = 0  
   SET @n_Err = 100200  
   SET @c_ErrMsg = 'Insufficient parameter for application process execution. Function : fnc_AppSection'
                                                                  
   GOTO EXIT_SP  
END  

--get StorerConfig

EXECUTE dbo.nspGetRight @cFacility    
                        , @cStorerKey         -- Storer    
                        , ''                   -- Sku    
                        , 'TPSectionTime'          -- ConfigKey    
                        , @b_success   OUTPUT    
                        , @timeOut     OUTPUT    
                        , @n_err       OUTPUT    
                        , @c_errmsg    OUTPUT    
  
   IF @b_success <> 1  
   BEGIN        
      SET @b_Success = 0  
      SET @n_Err = 100201  
      SET @c_ErrMsg = 'Error in executing nspGetRight. Function : fnc_AppSection'
      SET @n_LogOut = 0
                                                                  
      GOTO EXIT_SP   
   END  
  --SELECT @timeOut
  
 

--type: login 
IF @cType = 'LogIn'
BEGIN
	--1a. DeviceID not in db
	IF NOT EXISTS (SELECT TOP 1 1 FROM API.AppSection WITH (NOLOCK) WHERE deviceID = @cDeviceID)
	BEGIN
		--SELECT  '1a'
	   --User lock by others device: user not yet expired
		IF EXISTS (SELECT TOP 1 1 FROM API.AppSection WITH (NOLOCK) WHERE UserID = @cSCEUserName AND (DATEADD(s,@timeOut,SectionTime) > @dNow OR SectionTime IS NULL)) 
      BEGIN
      	--SELECT  '1ab'
      	SET @b_Success = 0  
         SET @n_Err = 100202
         SET @c_ErrMsg = 'User login in another device. Please logout from previous device before proceed to login in this device. Function : fnc_AppSection'
         SET @n_LogOut = 1
                                                                  
         GOTO EXIT_SP
      END
      ELSE
      BEGIN
      	--SELECT  '1aa'
		   INSERT INTO API.AppSection (APPName,DeviceID,UserID,SectionTime,ScanNo,AddWho,AddDate,EditWho,EditDate)
		   VALUES (@cAppName,@cDeviceID,@cSCEUserName,@dNow,@cScanNo,SUSER_SNAME (),@dNow,SUSER_SNAME (),@dNow)
      END
		
		
		
		GOTO SUCCESS_SP
	END
	ELSE
	--1b. DeviceID in db
	BEGIN
		--SELECT  '1b'
		GOTO DEVICE_SP
	END
	
   DEVICE_SP:	
   -- 2a. Device expired 
   IF EXISTS (SELECT TOP 1 1 FROM API.AppSection WITH (NOLOCK) WHERE deviceID = @cDeviceID AND (DATEADD(s,@timeOut,SectionTime) < @dNow OR SectionTime IS NULL))
   BEGIN
   	--SELECT  '2a'
   	GOTO CHECK_USER_SP
   END
   ELSE
   --2b. Device still using
   BEGIN
   	--SELECT  '2b'
   	GOTO USER_SP
   END
   
   SCANNO_SP:
   --3a. No ScanNo - can direct update
	IF @cScanNo = ''
	BEGIN
		--SELECT  '3a'
		UPDATE API.AppSection
		SET userID = @cSCEUserName, 
			SectionTime = @dNow,
			editWho = SUSER_SNAME (),
			editDate = @dNow
		WHERE deviceID = @cDeviceID 
		
		GOTO SUCCESS_SP
	END
	ELSE
	--3b. got ScanNo 
	BEGIN 
		--SELECT  '3b'
      GOTO SCANNO_LOCK_SP
	END
	
   SCANNO_LOCK_SP:
   --4a pickslip locked - not yet expired
   IF EXISTS (SELECT TOP 1 1 FROM API.AppSection WITH (NOLOCK) WHERE ScanNo = @cScanNo AND (DATEADD(s,@timeOut,SectionTime) > @dNow))
   BEGIN
   	--SELECT  '4a'
   	GOTO SCANNO_LOCKBYWHO_SP
   END
   ELSE
   --4b pickslip No locked
   BEGIN
   	--SELECT  '4b'
   	UPDATE API.AppSection
		SET userID = @cSCEUserName, 
			SectionTime = @dNow,
			ScanNo = @cScanNo,
			EditWho = SUSER_SNAME (),
			EditDate = @dNow
		WHERE deviceID = @cDeviceID 
		
		GOTO SUCCESS_SP
   END
  
   SCANNO_LOCKBYWHO_SP:
   --5a pickslip locked by user himself
   IF EXISTS (SELECT TOP 1 1 FROM API.AppSection WITH (NOLOCK) WHERE ScanNo = @cScanNo AND UserID = @cSCEUserName)
   BEGIN
   	--SELECT  '5a'
   	UPDATE API.AppSection
		SET SectionTime = @dNow,
			ScanNo = @cScanNo,
			EditWho = SUSER_SNAME (),
			EditDate = @dNow
		WHERE deviceID = @cDeviceID
		
		GOTO SUCCESS_SP
   END
   ELSE
   --5b. locked by others user
   BEGIN
   	--SELECT  '5b'
   	SET @b_Success = 0  
      SET @n_Err = 100203  
      SET @c_ErrMsg = 'The scanned document ID is process by another user. Please use another document ID. Function : fnc_AppSection'
      SET @n_LogOut = 0
                                                                  
      GOTO EXIT_SP  
   END
   
   USER_SP:
   --6a device locked: by same user himself
   IF EXISTS (SELECT TOP 1 1 FROM API.AppSection WITH (NOLOCK) WHERE DeviceID = @cDeviceID AND UserID = @cSCEUserName AND (DATEADD(s,@timeOut,SectionTime) > @dNow OR SectionTime IS NULL)) 
   BEGIN
   	--SELECT  '6a'
   	GOTO SCANNO_SP
   END
   ELSE
   --6b device locked: by others user
   BEGIN
   	--SELECT  '6b'
   	SET @b_Success = 0  
      SET @n_Err = 100204  
      SET @c_ErrMsg = 'Other user login to this device. Please ensure no other user login in this device before proceed to login. Function : fnc_AppSection'
      SET @n_LogOut = 1
                                                                  
      GOTO EXIT_SP 
   END
   
   CHECK_USER_SP:
   --7a. User lock by others device: user not yet expired
		IF EXISTS (SELECT TOP 1 1 FROM API.AppSection WITH (NOLOCK) WHERE UserID = @cSCEUserName AND (DATEADD(s,@timeOut,SectionTime) > @dNow OR SectionTime IS NULL)) 
   BEGIN
   	--SELECT  '7a'
   	SET @b_Success = 0  
      SET @n_Err = 100205  
      SET @c_ErrMsg = 'User found login in another device. Please logout from previous device before proceed to login in this device. Function : fnc_AppSection'
      SET @n_LogOut = 1
                                                                  
      GOTO EXIT_SP 
   END
   ELSE
   --7b user locked by others device
   BEGIN
   	--SELECT  '7b'
   	GOTO SCANNO_SP
   END
 END 
 
--type: logout 
IF @cType = 'LogOut'	
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM API.AppSection WITH (NOLOCK) WHERE DeviceID = @cDeviceID)
	UPDATE API.AppSection
	SET userID = '', 
		SectionTime = Null,
		ScanNo = '',
		EditWho = SUSER_SNAME (),
		EditDate = @dNow
	WHERE deviceID = @cDeviceID  
	
	GOTO SUCCESS_SP
END

--type: unlock 
IF @cType = 'Unlock'	
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM API.AppSection WITH (NOLOCK) WHERE DeviceID = @cDeviceID and userID = @cSCEUserName)
	UPDATE API.AppSection
	SET ScanNo = '',
	EditWho = SUSER_SNAME (),
	EditDate = @dNow
	WHERE deviceID = @cDeviceID  
	and userID = @cSCEUserName
	
	GOTO SUCCESS_SP
END

SUCCESS_SP:
   SET @b_Success = 1
	SET @jResult = (SELECT @dNow AS SectionTime, @timeOut AS ConfigInSec FOR JSON PATH)
	GOTO EXIT_SP


EXIT_SP:
   REVERT  
GO


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.fnc_AppSection TO NSQL
GO
