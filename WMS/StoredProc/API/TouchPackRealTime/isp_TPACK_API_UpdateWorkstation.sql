SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_API_UpdateWorkstation                              */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Update the workstation PrinterGroup                          */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-01   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_API_UpdateWorkstation] (
     @b_Debug           INT            = 0  
   , @c_Format          VARCHAR(10)    = ''  
   , @c_UserID          NVARCHAR(256)  = ''  
   , @c_OperationType   NVARCHAR(60)   = ''  
   , @c_RequestString   NVARCHAR(MAX)  = ''  
   , @b_Success         INT            = 0   OUTPUT  
   , @n_ErrNo           INT            = 0   OUTPUT  
   , @c_ErrMsg          NVARCHAR(250)  = ''  OUTPUT  
   , @c_ResponseString  NVARCHAR(MAX)  = ''  OUTPUT  
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue                    INT            = 1  
         , @n_StartCnt                    INT            = @@TRANCOUNT  
         , @b_sp_Success                  INT  
         , @n_sp_err                      INT  
         , @c_sp_errmsg                   NVARCHAR(250)  = ''
         , @DBUserName                    NVARCHAR(100)
         , @b_sp_ExecuteAs                BIT

   DECLARE
      @cLangCode           NVARCHAR( 3),
      @cStorerKey          NVARCHAR( 15),
      @cFacility           NVARCHAR( 5),
      @nFunc               INT,
      @cWorkstation        NVARCHAR( 30),
      @cCurWorkstation     NVARCHAR(30),
      @cInUseDeviceID      NVARCHAR(50),
      @cDeviceID           NVARCHAR( 50),
      @cTempDeviceID       NVARCHAR( 50),
      @nWebFlag            INT

   SET @cInUseDeviceID = '';

   SET @b_Success                         = 0  
   SET @n_ErrNo                           = 0  
   SET @c_ErrMsg                          = ''  
   SET @c_ResponseString                  = '' 

   EXEC [API].[isp_ECOMP_ValidateAndSetUser]
        @c_UserID      = @c_UserID,
        @c_DBUserName  = @DBUserName OUTPUT,
        @b_ExecuteAs   = @b_sp_ExecuteAs OUTPUT,
        @b_Success     = @b_sp_Success OUTPUT,
        @n_ErrNo       = @n_sp_err OUTPUT,
        @c_ErrMsg      = @c_sp_errmsg OUTPUT;

   IF @b_sp_Success = 0
   BEGIN
      SET @b_Success = 0      
      SET @n_ErrNo = @n_sp_err      
      SET @c_ErrMsg = @c_sp_errmsg     
      GOTO EXIT_SP
   END

   IF @b_sp_ExecuteAs = 1 OR @DBUserName LIKE '%' + @c_UserID + '%'
   BEGIN
      EXECUTE AS LOGIN = @DBUserName
      SET @c_UserID = @DBUserName

      IF OBJECT_ID('dbo.fnc_GetUserName', 'FN') IS NOT NULL
      BEGIN
         IF dbo.fnc_GetUserName() NOT IN ('WMConnect', '')
         BEGIN
            SET @c_UserID = dbo.fnc_GetUserName()
         END
      END
   END

   --Decode Json Format
   SELECT @nFunc = Func
        , @cLangCode = LangCode
        , @cWorkstation = Workstation
        , @cDeviceID = DeviceID
        , @cStorerKey = StorerKey
        , @cFacility = Facility
   FROM OPENJSON(@c_RequestString)
   WITH (
	      Func        INT,
         LangCode    NVARCHAR( 3),
         Workstation NVARCHAR( 30),
         DeviceID    NVARCHAR( 50),
         StorerKey   NVARCHAR( 15),
         Facility    NVARCHAR( 5)
   )

   --Data Validate
   IF @cWorkstation = ''
   BEGIN
      SET @b_Success = 0
      SET @n_ErrNo = 10651
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Unable to retrieve Workstation ID.'

      GOTO EXIT_SP
   END

   IF @cDeviceID = ''
   BEGIN
      SET @b_Success = 0
      SET @n_ErrNo = 10652
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Unable to retrieve Device ID.'

      GOTO EXIT_SP
   END

   --AppendDeviceID
   IF @cDeviceID = 'Web'
   BEGIN
      SET @cDeviceID = @cDeviceID + @c_UserID
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
               SET @n_ErrNo = 10653
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update into AppWorkstation.'

               GOTO EXIT_SP
            END
         END
      END
      ELSE
      BEGIN
         IF @cInUseDeviceID <> @cDeviceID
         BEGIN
            SET @b_Success = 0
            SET @n_ErrNo = 10654
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'The selected workstation already been in used by another user.'

            GOTO EXIT_SP
         END
      END
   END
   ELSE
   BEGIN
      IF EXISTS (SELECT TOP 1 1 FROM api.AppWorkstation (NOLOCK) WHERE DeviceID = @cDeviceID AND workstation <> @cWorkstation)
	   BEGIN
		   SET @b_Success = 0
         SET @n_ErrNo = 10655
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid setup. Current device has been assigned to a workstation.'

         GOTO EXIT_SP
	   END
   END	

   SELECT TOP 1 @cTempDeviceID = ISNULL(deviceID, '')
   FROM API.AppWorkstation (NOLOCK) 
   WHERE Workstation = @cWorkstation

   --update new deviceID
   IF @cTempDeviceID = @cDeviceID
   BEGIN
      GOTO PROCEED
   END
   ELSE IF NOT(@cTempDeviceID = '')
   BEGIN
      SET @b_Success = 0
      SET @n_ErrNo = 10656
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid Workstation, Not Found in AppWorkstation.'
      GOTO EXIT_SP 
   END

   UPDATE api.AppWorkstation WITH (ROWLOCK)
   SET DeviceID = @cDeviceID
   WHERE Workstation = @cWorkstation
   AND deviceID = ''

   IF @@ERROR <> 0
   BEGIN
      SET @b_Success = 0
      SET @n_ErrNo = 10657
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update into AppWorkstation.'
      GOTO EXIT_SP
   END
   ELSE
   BEGIN
PROCEED:
	   SET @b_Success = 1
	   SET @c_ResponseString = ISNULL((SELECT CAST ( 1 AS BIT ) AS 'Success' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                        ), '') 
   END

EXIT_SP:
   IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'lsp_RevertUser' AND type = 'P') AND SESSION_CONTEXT(N'mwms_user_name') IS NOT NULL
   BEGIN
      EXEC [WM].[lsp_RevertUser]
   END
   REVERT
END