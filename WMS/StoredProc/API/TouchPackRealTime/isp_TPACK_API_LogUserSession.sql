SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/*********************************************************************************/
/* Store procedure: isp_TPACK_API_LogUserSession                                 */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Log the user session                                         */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-01   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_API_LogUserSession] (
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
	   @cStorerKey          NVARCHAR(15),
	   @cFacility           NVARCHAR(5),
	   @cLangCode           NVARCHAR(3),
	   @cAppName            NVARCHAR(30),
	   @cDeviceID           NVARCHAR(50),
      @cScanNo             NVARCHAR(30),
      @cType               NVARCHAR(30),
      @timeOut             INT,
      @dNow                DATETIME,
      @cWorkStation        NVARCHAR(30),
      @nWebFlag            INT,
      @cSelWorkStation     NVARCHAR(30),
      @cClrDeviceID        NVARCHAR(10),
      @cIsSinglePKStation  NVARCHAR(10)

   SET @dNow = GETDATE()
   SET @nWebFlag = 0
   SET @cSelWorkStation = ''
   SET @cClrDeviceID = '0'
   
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
      SET @n_Continue = 3
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
   SELECT @cType        = cType
        , @cLangCode    = LangCode
        , @cStorerKey   = StorerKey
        , @cFacility    = Facility
        , @cAppName     = AppName
        , @cDeviceID    = DeviceID
        , @cScanNo      = ScanNo
        , @cWorkStation = WorkStation
   FROM OPENJSON(@c_RequestString)
   WITH (
         cType       NVARCHAR(30)
       , LangCode    NVARCHAR(3)
	    , StorerKey   NVARCHAR(15)
	    , Facility    NVARCHAR(5)
	    , AppName     NVARCHAR(30)
	    , DeviceID    NVARCHAR(50)
       , ScanNo      NVARCHAR(30)
       , WorkStation NVARCHAR(30)
   )

   --Data Validate : Check ScanNo blank
   IF  @cAppName = '' OR @cDeviceID = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 10401
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'AppName or DeviceID cannot be empty.'
      GOTO EXIT_SP
   END

   --AppendDeviceID
   IF @cDeviceID = 'Web'
   BEGIN
      SET @cDeviceID = @cDeviceID + @c_UserID
      SET @nWebFlag = 1

      SET @cSelWorkStation = @cWorkStation
      
      IF ISNULL(@cSelWorkStation, '') = ''
      BEGIN
         SELECT @cSelWorkStation = ISNULL(Workstation,'') 
         FROM Api.AppWorkstation (NOLOCK)
         WHERE DeviceID = @cDeviceID
      END

      SELECT @cClrDeviceID = ISNULL(SValue,'0') 
      FROM StorerConfig (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND ConfigKey = 'TPS-ClrDeviceID'
   END

   --get StorerConfig
   EXECUTE dbo.nspGetRight 
        @cFacility
      , @cStorerKey        
      , ''                 
      , 'TPSectionTime'    
      , @b_success   OUTPUT
      , @timeOut     OUTPUT
      , @n_ErrNo     OUTPUT
      , @c_errmsg    OUTPUT
   
   --get StorerConfig
   EXECUTE dbo.nspGetRight 
        @cFacility
      , @cStorerKey         
      , ''                  
      , 'TPS-SinglePKStation'    
      , @b_success            OUTPUT
      , @cIsSinglePKStation   OUTPUT
      , @n_ErrNo              OUTPUT
      , @c_errmsg             OUTPUT

   IF @b_success <> 1
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 10402
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to get the TPS-SinglePKStation from nspGetRight.'
      GOTO EXIT_SP
   END
  --SELECT @timeOut

	IF @timeOut = 0  
		SET @timeOut = 900  

   --type: login
   IF @cType IN( 'LOGIN' , 'PING', 'LOCK', 'CHANGE')
   BEGIN
	   --1a. DeviceID not in db
	   IF NOT EXISTS (SELECT 1 
                     FROM API.AppSection WITH (NOLOCK) 
                     WHERE DeviceID = @cDeviceID
      )
	   BEGIN
         --SELECT  '1a'
         --User lock by others device: user not yet expired
         IF EXISTS ( SELECT 1
                     FROM API.AppSection WITH (NOLOCK) 
                     WHERE UserID = @c_UserID 
                     AND (DATEADD(s,@timeOut,SectionTime) > @dNow OR SectionTime IS NULL)
         )
         BEGIN
            --SELECT  '1ab'
            SET @n_Continue = 3
            SET @n_ErrNo = 10403
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Current User still active in another device.'
            GOTO EXIT_SP
         END

         --SELECT  '1aa'
         IF @cScanNo <> '' AND
         @cIsSinglePKStation = '1' AND
         EXISTS(SELECT 1 
                  FROM API.AppSection WITH (NOLOCK) 
                  WHERE ScanNo = @cScanNo 
                  AND UserID <> @c_UserID
         )
         BEGIN
            GOTO SCANNO_LOCKBYWHO_SP
         END

         INSERT INTO API.AppSection ( APPName
                                    , DeviceID
                                    , UserID
                                    , SectionTime
                                    , ScanNo
                                    , AddWho
                                    , AddDate
                                    , EditWho
                                    , EditDate
                                    )
                              VALUES (@cAppName
                                    , @cDeviceID
                                    , @c_UserID
                                    , @dNow
                                    , @cScanNo
                                    , @c_UserID
                                    , @dNow
                                    , @c_UserID
                                    , @dNow
                                    )

         GOTO SUCCESS_SP
	   END

DEVICE_SP:
      -- 2a. Device expired
      IF EXISTS ( SELECT 1 
                  FROM API.AppSection WITH (NOLOCK) 
                  WHERE DeviceID = @cDeviceID 
                  AND (DATEADD(s,@timeOut,SectionTime) < @dNow OR SectionTime IS NULL)
      )
      BEGIN
         --SELECT  '2a'
         DELETE FROM API.AppSection
         WHERE DeviceID = @cDeviceID
         AND (DATEADD(s,@timeOut,SectionTime) < @dNow OR SectionTime IS NULL)
         GOTO CHECK_USER_SP
      END

      --2b. Device still using
      GOTO USER_SP

SCANNO_SP:
      --3a. No ScanNo - can direct update
      IF @cScanNo = ''
      BEGIN
         --SELECT  '3a'
         UPDATE API.AppSection WITH (ROWLOCK)
         SET SectionTime = @dNow
           , EditWho = @c_UserID
           , EditDate = @dNow
         WHERE DeviceID = @cDeviceID
            AND UserID = @c_UserID

         GOTO SUCCESS_SP
      END

SCANNO_LOCK_SP:
      --4a pickslip locked - not yet expired
      IF NOT (EXISTS ( SELECT 1 
                  FROM API.AppSection WITH (NOLOCK) 
                  WHERE ScanNo = @cScanNo 
                  AND (DATEADD(s,@timeOut,SectionTime) > @dNow)
      )
      AND @cIsSinglePKStation = '1')
      BEGIN
         --SELECT  '4b'
         UPDATE API.AppSection WITH (ROWLOCK)
         SET SectionTime = @dNow,
            ScanNo = @cScanNo,
            EditWho = @c_UserID,
            EditDate = @dNow
         WHERE DeviceID = @cDeviceID
            AND UserID = @c_UserID

         IF @cSelWorkStation <> '' 
         AND EXISTS (SELECT 1
                     FROM API.AppWorkstation (NOLOCK)
                     WHERE DeviceID = @cDeviceID
                     AND (DefaultStorerkey <> @cStorerKey
                     OR DefaultFacility <> @cFacility)
                     AND DefaultStorerKey <> 'SHARE')
         BEGIN
            UPDATE API.AppWorkstation WITH (ROWLOCK)
            SET DefaultStorerkey = @cStorerKey
              , DefaultFacility  = @cFacility
              , EditWho          = @c_UserID
              , EditDate         = @dNow
            WHERE DeviceID    = @cDeviceID
            AND WorkStation   = @cSelWorkStation
         END

         GOTO SUCCESS_SP
      END

SCANNO_LOCKBYWHO_SP:
      --5a pickslip locked by user himself
      IF NOT EXISTS ( SELECT 1 
                  FROM API.AppSection WITH (NOLOCK) 
                  WHERE ScanNo = @cScanNo 
                  AND UserID = @c_UserID
      )
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 10404
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP')--'Current Pickslip/ToteId/OrderKey still in used by another user.'
         GOTO EXIT_SP
      END

      UPDATE API.AppSection WITH (ROWLOCK)
      SET SectionTime   = @dNow
         , EditWho       = @c_UserID
         , EditDate      = @dNow
      WHERE DeviceID = @cDeviceID
      AND UserID     = @c_UserID

      GOTO SUCCESS_SP

USER_SP:
      --6a device locked: by same user himself
      IF NOT (EXISTS ( SELECT 1 
                  FROM API.AppSection WITH (NOLOCK) 
                  WHERE DeviceID = @cDeviceID 
                  AND UserID = @c_UserID 
                  AND (DATEADD(s,@timeOut,SectionTime) > @dNow OR SectionTime IS NULL)
      ) OR @nWebFlag = 1)
      BEGIN
         --6a device locked: by others user for windows only
         SET @n_Continue = 3
         SET @n_ErrNo = 10405
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Current device still in used by another user.'
         GOTO EXIT_SP
      END

      --6b Go to ScanNo_SP
      GOTO SCANNO_SP

CHECK_USER_SP:
      --7a. User lock by others device: user not yet expired
      -- IF User no proper logout, username still in section, remove user from expired secion (cc01)
      IF EXISTS (SELECT 1
                 FROM API.AppSection WITH (NOLOCK) 
                 WHERE UserID = @c_UserID 
                 AND (DATEADD(s,@timeOut,SectionTime) < @dNow OR SectionTime IS NULL)
      )
      BEGIN
         DELETE FROM API.AppSection
         WHERE UserID = @c_UserID
         AND (DATEADD(s,@timeOut,SectionTime) < @dNow OR SectionTime IS NULL)
      END

      IF EXISTS ( SELECT 1
                  FROM API.AppSection WITH (NOLOCK) 
                  WHERE UserID = @c_UserID 
                  AND (DATEADD(s,@timeOut,SectionTime) > @dNow OR SectionTime IS NULL)
      )
      BEGIN
         --SELECT  '7a'
         SET @n_Continue = 3
         SET @n_ErrNo = 10406
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Current User still active in another device.'
         GOTO EXIT_SP
      END

      --7b user locked by others device
      GOTO SCANNO_SP
   END

   --type: logout
   IF @cType = 'LOGOUT'
   BEGIN
	   IF EXISTS ( SELECT TOP 1 1 
                  FROM API.AppSection WITH (NOLOCK) 
                  WHERE DeviceID = @cDeviceID 
                  AND UserID = @c_UserID)
      DELETE FROM API.AppSection 
      WHERE DeviceID = @cDeviceID
      AND UserID = @c_UserID

      IF @nWebFlag = 1 
      AND @cSelWorkStation <> ''
      AND (@cClrDeviceID = '1' OR 
      EXISTS ( SELECT 1 
               FROM Api.AppWorkstation (NOLOCK) 
               WHERE Workstation = @cSelWorkStation 
               AND DefaultStorerKey = 'SHARE')
      )
      BEGIN
         UPDATE Api.AppWorkstation WITH (ROWLOCK)
         SET DeviceID = ''
         WHERE Workstation = @cSelWorkStation
      END

	   GOTO SUCCESS_SP
   END

   --type: unlock
   IF @cType = 'UNLOCK'
   BEGIN
	   IF EXISTS ( SELECT 1
                  FROM API.AppSection WITH (NOLOCK) 
                  WHERE DeviceID = @cDeviceID 
                  AND UserID = @c_UserID
      )
      BEGIN
	      UPDATE API.AppSection WITH (ROWLOCK)
	      SET ScanNo        = ''
           , SectionTime   = @dNow
	        , EditWho       = @c_UserID
	        , EditDate      = @dNow
	      WHERE DeviceID = @cDeviceID
	      AND UserID     = @c_UserID

	      GOTO SUCCESS_SP
      END
   END

SUCCESS_SP:
      SET @b_Success = 1
	   SET @c_ResponseString = ISNULL((
                                 SELECT  @dNow AS SectionTime
                                       , @timeOut AS ConfigInSec 
                                 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                              ), '') 

      IF ISNULL(@c_RequestString, '') = ''
         SET @c_RequestString = '[]'
	   GOTO EXIT_SP


EXIT_SP:
   IF @b_sp_ExecuteAs = 1 REVERT
   EXEC [WM].[lsp_ResetUser]

   IF @n_Continue = 3  -- Error Occured - Process And Return      
   BEGIN      
      SET @b_Success = 0      
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1 
      BEGIN               
         ROLLBACK TRAN      
      END      
      ELSE      
      BEGIN      
         WHILE @@TRANCOUNT > @n_StartCnt      
         BEGIN      
            COMMIT TRAN      
         END      
      END   
      RETURN      
   END      
   ELSE      
   BEGIN      
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END
