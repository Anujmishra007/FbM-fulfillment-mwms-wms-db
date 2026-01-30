SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_API_DeleteSKU                                      */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Delete SKU in PackDetail/PackInfo/PackSerialNo and etc.      */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-XX-XX   1.0             Created                                          */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_API_DeleteSKU] (
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

   DECLARE @n_Continue     INT            = 1  
         , @n_StartCnt     INT            = @@TRANCOUNT  
         , @b_sp_Success   INT  
         , @n_sp_err       INT  
         , @c_sp_errmsg    NVARCHAR(250)  = ''
         , @DBUserName     NVARCHAR(100)
         , @b_sp_ExecuteAs BIT

   DECLARE @cType          NVARCHAR(30)
         , @bIsDiscrete    BIT
         , @bIsCustom      BIT
         , @cLangCode      NVARCHAR(3)
         , @cPickSlipNo    NVARCHAR(10)
         , @cOrderKey      NVARCHAR(10)
         , @cLoadKey       NVARCHAR(10)
         , @cDropID        NVARCHAR(20)
         , @cStorerKey     NVARCHAR(15)
         , @cFacility      NVARCHAR(5)
         , @nCartonNo      INT
         , @cSKU           NVARCHAR(20)
         , @c_authority    NVARCHAR(10)
         , @cSQL           NVARCHAR(MAX)
         , @cSQLParam      NVARCHAR(MAX)
         , @cExtResetSKUSP NVARCHAR(30)

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = ''  
   SET @c_ResponseString   = '' 
   SET @bIsDiscrete        = 1
   SET @bIsCustom          = 0
   SET @cLangCode          = ''
   SET @cPickSlipNo        = ''
   SET @cOrderKey          = ''
   SET @cLoadKey           = ''
   SET @cDropID            = ''
   SET @cStorerKey         = ''
   SET @cFacility          = ''
   SET @nCartonNo          = 0
   SET @cSKU               = ''
   SET @cExtResetSKUSP     = ''

   EXEC [API].[isp_ECOMP_ValidateAndSetUser]
        @c_UserID      = @c_UserID
      , @c_DBUserName  = @DBUserName OUTPUT
      , @b_ExecuteAs   = @b_sp_ExecuteAs OUTPUT
      , @b_Success     = @b_sp_Success OUTPUT
      , @n_ErrNo       = @n_sp_err OUTPUT
      , @c_ErrMsg      = @c_sp_errmsg OUTPUT

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
   SELECT  @cType             = cType
         , @bIsDiscrete       = bIsDiscrete
         , @bIsCustom         = bIsCustom
         , @cLangCode         = cLangCode
         , @cPickSlipNo       = cPickSlipNo
         , @cOrderKey         = cOrderKey
         , @cLoadKey          = cLoadKey
         , @cDropID           = cDropID
         , @cStorerKey        = cStorerKey
         , @cFacility         = cFacility
         , @nCartonNo         = nCartonNo
         , @cSKU              = cSKU
   FROM OPENJSON(@c_RequestString)
   WITH (
	      cType                NVARCHAR(30)
	    , bIsDiscrete          BIT
	    , bIsCustom            BIT
       , cLangCode            NVARCHAR(3)
       , cPickSlipNo          NVARCHAR(10)      
       , cLoadKey             NVARCHAR(10)      
       , cOrderKey            NVARCHAR(10)
       , cDropID              NVARCHAR(20)
       , cStorerKey           NVARCHAR(15)
       , cFacility            NVARCHAR(5)
       , nCartonNo            INT
       , cSKU                 NVARCHAR(20)
   )

   IF @cPickSlipNo = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 11901
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'PickSlipNo cannot be empty.'
      GOTO EXIT_SP
   END

   IF @nCartonNo = 0
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 11901
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Carton No. cannot be empty.'
      GOTO EXIT_SP
   END

   IF @cSKU = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 11901
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'SKU cannot be empty.'
      GOTO EXIT_SP
   END

   IF EXISTS ( SELECT 1 
               FROM PACKHEADER (NOLOCK) 
               WHERE PickSlipNo = @cPickSlipNo
               AND [Status] = '9'
   )  
   BEGIN  
      SET @n_Continue = 3
      SET @n_ErrNo = 1000714  
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Current pickslip already status 9 cannot perform delete sku.'  
      GOTO EXIT_SP  
   END 
   
   IF EXISTS ( SELECT 1 
               FROM PACKINFO (NOLOCK) 
               WHERE PickSlipNo = @cPickSlipNo
               AND CartonNo = @nCartonNo
               AND CartonStatus <> 'INPROGRESS'
   )  
   BEGIN  
      SET @n_Continue = 3
      SET @n_ErrNo = 1000714  
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Current carton status is not InProgress. Not allow to delete SKU.'  
      GOTO EXIT_SP  
   END

   EXEC nspGetRight    
         @c_Facility   = @cFacility    
      ,  @c_StorerKey  = @cStorerKey   
      ,  @c_sku        = ''    
      ,  @c_ConfigKey  = 'TPS-ExtResetSKU'    
      ,  @c_authority  = @cExtResetSKUSP  OUTPUT    
      ,  @b_Success    = @b_Success       OUTPUT    
      ,  @n_err        = @n_ErrNo         OUTPUT    
      ,  @c_errmsg     = @c_ErrMsg        OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3    
      GOTO EXIT_SP
   END

   IF EXISTS( SELECT 1 
              FROM sys.objects 
              WHERE [name] = @cExtResetSKUSP 
              AND [type] = 'P'
   )    
   BEGIN  
      SET @cSQL = 'EXEC [API].[' + RTRIM(@cExtResetSKUSP) + ']' + CHAR(13)
                + '  @cType                ' + CHAR(13)
                + ', @bIsDiscrete          ' + CHAR(13)
                + ', @bIsCustom            ' + CHAR(13)
                + ', @cPickSlipNo          ' + CHAR(13)
                + ', @cOrderKey            ' + CHAR(13)
                + ', @cLoadKey             ' + CHAR(13)
                + ', @cDropID              ' + CHAR(13)
                + ', @cStorerKey           ' + CHAR(13)
                + ', @cFacility            ' + CHAR(13)
                + ', @nCartonNo            ' + CHAR(13)
                + ', @cSKU                 ' + CHAR(13)
                + ', @c_UserID             ' + CHAR(13)
                + ', @cLangCode            ' + CHAR(13)
                + ', @b_Success     OUTPUT ' + CHAR(13)
                + ', @n_ErrNo       OUTPUT ' + CHAR(13)
                + ', @c_ErrMsg      OUTPUT ' + CHAR(13)

      SET @cSQLParam = '  @cType       NVARCHAR(30)         ' + CHAR(13)
                     + ', @bIsDiscrete BIT                  ' + CHAR(13)
                     + ', @bIsCustom   BIT                  ' + CHAR(13)
                     + ', @cPickSlipNo NVARCHAR(10)         ' + CHAR(13)
                     + ', @cOrderKey   NVARCHAR(10)         ' + CHAR(13)
                     + ', @cLoadKey    NVARCHAR(10)         ' + CHAR(13)
                     + ', @cDropID     NVARCHAR(20)         ' + CHAR(13)
                     + ', @cStorerKey  NVARCHAR(15)         ' + CHAR(13)
                     + ', @cFacility   NVARCHAR(5)          ' + CHAR(13)
                     + ', @nCartonNo   INT                  ' + CHAR(13)
                     + ', @cSKU        NVARCHAR(20)         ' + CHAR(13)
                     + ', @c_UserID    NVARCHAR(256)        ' + CHAR(13)
                     + ', @cLangCode   NVARCHAR(3)          ' + CHAR(13)
                     + ', @b_Success   INT           OUTPUT ' + CHAR(13)
                     + ', @n_ErrNo     INT           OUTPUT ' + CHAR(13)
                     + ', @c_ErrMsg    NVARCHAR(250) OUTPUT ' + CHAR(13)

      EXEC sp_ExecuteSQL  @cSQL
                        , @cSQLParam
                        , @cType            
                        , @bIsDiscrete      
                        , @bIsCustom        
                        , @cPickSlipNo      
                        , @cOrderKey        
                        , @cLoadKey         
                        , @cDropID          
                        , @cStorerKey       
                        , @cFacility 
                        , @nCartonNo                   
                        , @cSKU
                        , @c_UserID         
                        , @cLangCode        
                        , @b_Success     OUTPUT
                        , @n_ErrNo       OUTPUT
                        , @c_ErrMsg      OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3  
         GOTO EXIT_SP
      END                 
   END
   ELSE
   BEGIN
      EXEC [API].[isp_TPACK_ResetSKU_Std]
         @cType       = @cType            
       , @bIsDiscrete = @bIsDiscrete      
       , @bIsCustom   = @bIsCustom        
       , @cPickSlipNo = @cPickSlipNo       
       , @cOrderKey   = @cOrderKey
       , @cLoadKey    = @cLoadKey          
       , @cDropID     = @cDropID
       , @cStorerKey  = @cStorerKey        
       , @cFacility   = @cFacility 
       , @nCartonNo   = @nCartonNo
       , @cSKU        = @cSKU 
       , @c_UserID    = @c_UserID
       , @cLangCode   = @cLangCode
       , @b_Success   = @b_Success     OUTPUT
       , @n_ErrNo     = @n_ErrNo       OUTPUT
       , @c_ErrMsg    = @c_ErrMsg      OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3     
         GOTO EXIT_SP
      END
   END

   SET @b_Success = 1
   SET @c_ResponseString = ISNULL ((SELECT CAST(@b_Success AS BIT)   AS Success 
                                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                           ),'')

EXIT_SP:
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