SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_API_GetWorkstationList                             */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get the list of workstation for specific storer and facility */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-01   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_API_GetWorkstationList] (
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
      @cStorerKey          NVARCHAR( 15) = '',
      @cFacility           NVARCHAR( 5) = '',
      @nFunc               INT,
      @cDeviceID           NVARCHAR( 50),
      @cDefaultWorkstation NVARCHAR( 30),
      @cTargetVersion      NVARCHAR( 12),
      @cCurrentVersion     NVARCHAR( 12)

   DECLARE @tempworkstation TABLE (
      workstation NVARCHAR( 30)
   )

   SET @b_Success             = 0 
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  
   SET @c_ResponseString      = ''  
   SET @cDefaultWorkstation   = ''
   SET @cTargetVersion        = ''
   SET @cCurrentVersion       = ''
   
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

   SELECT  @nFunc = Func
         , @cDeviceID = Device
         , @cLangCode = LangCode
         , @cStorerKey = Storerkey
         , @cFacility  = Facility
   FROM OPENJSON (@c_RequestString)  
   WITH (
	      Func        INT,
         Device      NVARCHAR(50),
         LangCode    NVARCHAR(3),
         Storerkey   NVARCHAR(15),
         Facility    NVARCHAR(5)
   )

   IF @cDeviceID <>''
   BEGIN
      IF ISNULL(@cDeviceID,'') NOT LIKE 'Web%'
      BEGIN
         SELECT @cDefaultWorkstation = workstation
              , @cTargetVersion = ISNULL(TargetVersion,'')
              , @cCurrentVersion = ISNULL(CurrentVersion,'')
         FROM API.AppWorkstation (NOLOCK)  
         WHERE DeviceID = @cDeviceID

         IF ISNULL(@cDefaultWorkstation,'') = '' 
         BEGIN
            IF NOT EXISTS (SELECT TOP 1 1 FROM Api.AppWorkstation WITH (NOLOCK) WHERE DeviceID ='')
            BEGIN
               SET @n_Continue = 3
               SET @n_ErrNo = 10351
               SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No workstation available for device setup. Please ensure workstation has been setup.'
               GOTO EXIT_SP
            END
         END

         INSERT INTO @tempworkstation (workstation)
         SELECT WorkStation 
         FROM Api.AppWorkstation WITH (NOLOCK)
         WHERE DeviceID = ''
      END
      ELSE
      BEGIN
         SET @cDeviceID = @cDeviceID + @c_UserID

         SELECT  @cDefaultWorkstation = workstation
               , @cTargetVersion = ISNULL(TargetVersion,'')
               , @cCurrentVersion = ISNULL(CurrentVersion,'')
         FROM API.AppWorkstation (NOLOCK)  
         WHERE DeviceID = @cDeviceID
         AND DefaultStorerkey = @cStorerKey
         AND DefaultFacility = @cFacility

         INSERT INTO @tempworkstation (workstation)
         SELECT WorkStation 
         FROM Api.AppWorkstation (NOLOCK)
         WHERE DeviceID = ''
         AND ((DefaultStorerkey = @cStorerKey AND DefaultFacility = @cFacility)
         OR (DefaultStorerkey = 'SHARE' AND DefaultFacility = @cFacility))
      END

      SET @c_ResponseString = ISNULL((
                                 SELECT  @cDefaultWorkstation AS DefaultWorkstation
                                       , @cCurrentVersion AS CurrentVersion
                                       , @cTargetVersion AS TargetVersion
                                       , (SELECT JSON_QUERY('[' + STRING_AGG(QUOTENAME(workstation, '"'), ',') + ']') as result 
                                          FROM @tempworkstation
                                         ) as WorkStationList
                                 FOR JSON PATH , WITHOUT_ARRAY_WRAPPER
                               ), '') 

      IF ISNULL(@c_RequestString, '') = ''
         SET @c_RequestString = '[]'
   END
   ELSE
   BEGIN
	   SET @n_Continue = 3
      SET @n_ErrNo = 10352
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Device ID setup not done. Please setup the Device ID.'
      GOTO EXIT_SP
   END

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