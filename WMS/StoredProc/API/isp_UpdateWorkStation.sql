SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO




/******************************************************************************/
/* Store procedure: isp_UpdateWorkStation                                     */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2020-04-07   1.0  Chermaine  Created                                       */
/* 2021-09-05   1.1  Chermaine  TPS-11 ErrMsg add to rdtmsg (cc01)            */
/* 2025-04-25   2.1  GhChan     Enhanced the whole logic with support V0 & V2 */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_UpdateWorkstation] (
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
   @cCurWorkstation  NVARCHAR(30),
   @cInUseDeviceID   NVARCHAR(50),
   @cDeviceID        NVARCHAR( 50),
   @nWebFlag         INT,
   @cSCEUsername     NVARCHAR(128)


SET @cInUseDeviceID = '';

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
SET @cSCEUsername = @cUserName
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
   SET @n_Err = 1000401
   SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to retrieve Workstation ID. Function : isp_UpdateWorkstation'

   GOTO EXIT_SP
END

IF @cDeviceID = ''
BEGIN
   SET @b_Success = 0
   SET @n_Err = 1000402
   SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Unable to retrieve Device ID. Function : isp_UpdateWorkstation'

   GOTO EXIT_SP
END
ELSE
BEGIN
   
   --AppendDeviceID
   IF @cDeviceID = 'Web'
   BEGIN
      SET @cDeviceID = @cDeviceID + @cSCEUsername
      SET @nWebFlag = 1
      SELECT TOP 1 @cInUseDeviceID = ISNULL(DeviceID,'') FROM api.AppWorkstation (NOLOCK) WHERE Workstation = @cWorkstation

      IF @cInUseDeviceID = ''
      BEGIN
         IF EXISTS (SELECT TOP 1 1 FROM api.AppWorkstation (NOLOCK) WHERE DeviceID = @cDeviceID)
         BEGIN
            UPDATE api.AppWorkstation WITH (ROWLOCK)
            SET DeviceID = ''
            WHERE DeviceID = @cDeviceID

            IF @@ERROR <> 0
            BEGIN
               SET @b_Success = 0
               SET @n_Err = 1000403
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into Workstation. Function : isp_UpdateWorkstation'

               GOTO EXIT_SP
            END
         END
      END
      ELSE
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1000404
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'The selected workstation already been in use by another user, kindly re-select a new one. Function : isp_UpdateWorkstation'

         GOTO EXIT_SP
      END
   END
   ELSE
   BEGIN
      IF EXISTS (SELECT TOP 1 1 FROM api.AppWorkstation (NOLOCK) WHERE DeviceID = @cDeviceID AND workstation <> @cWorkstation)
	   BEGIN
		   SET @b_Success = 0
         SET @n_Err = 1000405
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Invalid setup. This device has been assigned to a workstation. Function : isp_UpdateWorkstation'

         GOTO EXIT_SP
	   END
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
      SET @n_Err = 1000406
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into Workstation. Function : isp_UpdateWorkstation'

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
   SET @n_Err = 1000407
   SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Invalid Workstation. Please use other Workstation. Function : isp_UpdateWorkstation'

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
GRANT EXECUTE ON api.isp_UpdateWorkstation TO NSQL
GO

