SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************/
/* Store procedure: isp_TPACK_API_ExecButtonAction                                  */
/* Copyright      : Maersk                                                          */
/* Purpose        : UWP-42549 Execute Button Actions                                */
/* Date         Rev  Author     Purposes                                            */
/* 2025-11-17   1.0  Sean01     UWP-42549 - Initial version                         */
/* 2026-01-14   1.1  Sean02     UWP-46904 - add Validation before perform operation */
/* 2026-06-10   1.2  GCH225     UWP-58236 - Add condtion check for short pick action*/
/************************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_API_ExecButtonAction] (
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

   DECLARE @n_Continue     INT = 1  
         , @n_StartCnt     INT = @@TRANCOUNT
         , @DBUserName     NVARCHAR(100)
         , @b_sp_ExecuteAs BIT
         , @b_sp_Success   INT
         , @n_sp_err       INT
         , @c_sp_errmsg    NVARCHAR(250) = ''
   
   -- Declare variables to be parsed from JSON
   DECLARE @cType          NVARCHAR(30)
         , @bIsDiscrete    BIT
         , @bIsCustom      BIT
         , @cPickSlipNo    NVARCHAR(10)
         , @cOrderKey      NVARCHAR(10)
         , @cLoadKey       NVARCHAR(10)
         , @cDropID        NVARCHAR(20)
         , @cStorerKey     NVARCHAR(15)
         , @cFacility      NVARCHAR(5)
         , @nCartonNo      INT
         , @cLangCode      NVARCHAR(3)
         , @cAction        NVARCHAR(50)
         , @cDiffListJson  NVARCHAR(MAX)
         , @cAuthority     NVARCHAR(50)
         , @nTempCartonNo  INT

   SET @b_Success = 0
   SET @n_ErrNo = 0
   SET @c_ErrMsg = ''
   SET @cAuthority = ''
   SET @nTempCartonNo = 0

   -- (0) Set user session
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

   -- (1) Parse all required parameters from JSON
   SELECT  
      @cType          = cType,
      @bIsDiscrete    = bIsDiscrete,
      @bIsCustom      = bIsCustom,
      @cPickSlipNo    = cPickSlipNo,
      @cOrderKey      = cOrderKey,
      @cLoadKey       = cLoadKey,
      @cDropID        = cDropID,
      @cStorerKey     = cStorerKey,
      @cFacility      = cFacility,
      @nCartonNo      = nCartonNo,
      @cLangCode      = cLangCode,
      @cAction        = cAction,
      @cDiffListJson  = cDiffListJson
   FROM OPENJSON(@c_RequestString)
   WITH (
      cType           NVARCHAR(30),
      bIsDiscrete     BIT,
      bIsCustom       BIT,
      cPickSlipNo     NVARCHAR(10),
      cOrderKey       NVARCHAR(10),
      cLoadKey        NVARCHAR(10),
      cDropID         NVARCHAR(20),
      cStorerKey      NVARCHAR(15),
      cFacility       NVARCHAR(5),
      nCartonNo       INT,
      cLangCode       NVARCHAR(3),
      cAction         NVARCHAR(50),
      cDiffListJson   NVARCHAR(MAX)
   )

   -- (2) Validate required parameters
   IF @cAction IS NULL OR LTRIM(RTRIM(@cAction)) = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 15101
      SET @c_ErrMsg = 'Action parameter is required'
      GOTO EXIT_SP
   END

   EXEC nspGetRight    
        @c_Facility  = @cFacility    
      , @c_StorerKey = @cStorerKey   
      , @c_sku       = ''    
      , @c_ConfigKey = 'TPS-CtnRec'    
      , @c_authority = @cAuthority        OUTPUT    
      , @b_Success   = @b_Success         OUTPUT
      , @n_err       = @n_ErrNo           OUTPUT
      , @c_errmsg    = @c_ErrMsg          OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue  = 3  
      GOTO EXIT_SP
   END

   IF @cType = 'toteid'
   AND @cAuthority = '1'
   AND EXISTS (SELECT 1
               FROM CODELKUP (NOLOCK)
               WHERE Storerkey = @cStorerKey
               AND ListName = 'TPSCtnRec'
   )
   BEGIN
      SELECT @nTempCartonNo = CartonNo
      FROM PACKINFO (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonStatus IN ('INPROGRESS', 'HOLD')
      AND CartonType <> ''
      AND Qty = 0

      IF @nTempCartonNo > 0
      BEGIN
         DELETE FROM PACKINFO
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nTempCartonNo
      END
   END

   -- Sean02 Start
   -- if some carton status not equal to 'HOLD' or 'CLOSED' then prompt error. 
   IF EXISTS ( SELECT 1 
               FROM PACKINFO (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
               AND CartonStatus NOT IN ('HOLD', 'CLOSED')
   ) 
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 15102
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') 
      + @cAction + ')' 
      + API.TouchPadGetMessage(15103, @cLangCode, 'DSP')
      GOTO EXIT_SP
   END
   -- Sean02 End

   -- (3) Call Wrapper SP
   EXEC [API].[isp_TPACK_ExecButtonAction_Wrapper]
      @cType         = @cType,
      @bIsDiscrete   = @bIsDiscrete,
      @bIsCustom     = @bIsCustom,
      @cPickSlipNo   = @cPickSlipNo,
      @cOrderKey     = @cOrderKey,
      @cLoadKey      = @cLoadKey,
      @cDropID       = @cDropID,
      @cStorerKey    = @cStorerKey,
      @cFacility     = @cFacility,
      @nCartonNo     = @nCartonNo,
      @c_UserID      = @c_UserID,
      @cLangCode     = @cLangCode,
      @cAction       = @cAction,
      @cDiffListJson = @cDiffListJson,
      @b_Success     = @b_Success OUTPUT,
      @n_ErrNo       = @n_ErrNo OUTPUT,
      @c_ErrMsg      = @c_ErrMsg OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3  
      GOTO EXIT_SP
   END

   -- (4) Build response JSON
   SET @c_ResponseString = (
      SELECT 
         @b_Success AS Success,
         @c_ErrMsg AS Message
      FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
   )

EXIT_SP:
   -- Revert user context if needed
   IF @b_sp_ExecuteAs = 1 REVERT
   EXEC [WM].[lsp_ResetUser]

   IF @n_Continue = 3
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
GO
