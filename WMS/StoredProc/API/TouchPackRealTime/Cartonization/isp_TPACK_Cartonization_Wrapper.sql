SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************************/
/* Store procedure: isp_TPACK_Cartonization_Wrapper                                       */
/* Copyright      : Maersk                                                                */
/*                                                                                        */
/* Purpose        : Cartonization Wrapper                                                 */
/*                                                                                        */
/* Date         Rev  Author     Purposes                                                  */
/* 2026-05-12   1.0  JWF011     UWP-54223: Created                                        */
/******************************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_Cartonization_Wrapper] (
	  @cType          NVARCHAR(30)      = ''
   , @bIsDiscrete    BIT               = 0
   , @bIsCustom      BIT               = 0
   , @cPickSlipNo    NVARCHAR(10)      = ''
   , @cOrderKey      NVARCHAR(10)      = ''
   , @cLoadKey       NVARCHAR(10)      = ''
   , @cDropID        NVARCHAR(20)      = ''
   , @cStorerKey     NVARCHAR(15)      = ''
   , @cFacility      NVARCHAR(5)       = ''
   , @c_UserID       NVARCHAR(256)     = ''  
   , @cLangCode      NVARCHAR(3)       = ''
   , @nCartonNo      INT               = 0
   , @nCartonizeStep INT               = 0
   , @b_Success      INT               = 0   OUTPUT
   , @n_ErrNo        INT               = 0   OUTPUT
   , @c_ErrMsg       NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  

   DECLARE @cAuthority     NVARCHAR(256)
         , @cCustomSP      NVARCHAR(4000)
         , @cSQL           NVARCHAR(MAX)
         , @cSQLParam      NVARCHAR(3000)

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 

   EXEC nspGetRight    
         @c_Facility   = @cFacility    
      ,  @c_StorerKey  = @cStorerKey   
      ,  @c_sku        = ''    
      ,  @c_ConfigKey  = 'TPS-CtnRec'    
      ,  @c_authority  = @cAuthority   OUTPUT    
      ,  @b_Success    = @b_Success    OUTPUT    
      ,  @n_err        = @n_ErrNo      OUTPUT    
      ,  @c_errmsg     = @c_ErrMsg     OUTPUT
      ,  @c_Option5    = @cCustomSP    OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue  = 3  
      GOTO EXIT_SP
   END

   IF @cCustomSP = 'isp_TPACK_Cartonization_Std'
   BEGIN
      EXEC [API].[isp_TPACK_Cartonization_Std]
         @cType         = @cType            
       , @bIsDiscrete   = @bIsDiscrete      
       , @bIsCustom     = @bIsCustom        
       , @cPickSlipNo   = @cPickSlipNo       
       , @cOrderKey     = @cOrderKey
       , @cLoadKey      = @cLoadKey          
       , @cDropID       = @cDropID
       , @cStorerKey    = @cStorerKey        
       , @cFacility     = @cFacility
       , @c_UserID      = @c_UserID
       , @cLangCode     = @cLangCode
       , @nCartonNo     = @nCartonNo
       , @nCartonizeStep = @nCartonizeStep
       , @b_Success     = @b_Success      OUTPUT
       , @n_ErrNo       = @n_ErrNo        OUTPUT
       , @c_ErrMsg      = @c_ErrMsg       OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue  = 3  
         GOTO EXIT_SP
      END
   END
   ELSE
   BEGIN
      IF EXISTS ( SELECT 1 
                  FROM dbo.sysobjects (NOLOCK)
                  WHERE [name] = @cCustomSP 
                  AND type = 'P'
      )
      BEGIN
         SET @cSQL = 'EXEC [API].[' + RTRIM(@cCustomSP) + ']' + CHAR(13)
                   + '  @cType                ' + CHAR(13)
                   + ', @bIsDiscrete          ' + CHAR(13)
                   + ', @bIsCustom            ' + CHAR(13)
                   + ', @cPickSlipNo          ' + CHAR(13)
                   + ', @cOrderKey            ' + CHAR(13)
                   + ', @cLoadKey             ' + CHAR(13)
                   + ', @cDropID              ' + CHAR(13)
                   + ', @cStorerKey           ' + CHAR(13)
                   + ', @cFacility            ' + CHAR(13)
                   + ', @c_UserID             ' + CHAR(13)
                   + ', @cLangCode            ' + CHAR(13)
                   + ', @nCartonNo            ' + CHAR(13)
                   + ', @nCartonizeStep       ' + CHAR(13)
                   + ', @b_Success     OUTPUT ' + CHAR(13)
                   + ', @n_ErrNo       OUTPUT ' + CHAR(13)
                   + ', @c_ErrMsg      OUTPUT ' + CHAR(13)

         SET @cSQLParam = '  @cType          NVARCHAR(30)         ' + CHAR(13)
                        + ', @bIsDiscrete    BIT                  ' + CHAR(13)
                        + ', @bIsCustom      BIT                  ' + CHAR(13)
                        + ', @cPickSlipNo    NVARCHAR(10)         ' + CHAR(13)
                        + ', @cOrderKey      NVARCHAR(10)         ' + CHAR(13)
                        + ', @cLoadKey       NVARCHAR(10)         ' + CHAR(13)
                        + ', @cDropID        NVARCHAR(20)         ' + CHAR(13)
                        + ', @cStorerKey     NVARCHAR(15)         ' + CHAR(13)
                        + ', @cFacility      NVARCHAR(5)          ' + CHAR(13)
                        + ', @c_UserID       NVARCHAR(256)        ' + CHAR(13)
                        + ', @cLangCode      NVARCHAR(3)          ' + CHAR(13)
                        + ', @nCartonNo      INT                  ' + CHAR(13)
                        + ', @nCartonizeStep INT                  ' + CHAR(13)
                        + ', @b_Success      INT           OUTPUT ' + CHAR(13)
                        + ', @n_ErrNo        INT           OUTPUT ' + CHAR(13)
                        + ', @c_ErrMsg       NVARCHAR(250) OUTPUT ' + CHAR(13)

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
                           , @c_UserID         
                           , @cLangCode 
                           , @nCartonNo
                           , @nCartonizeStep
                           , @b_Success      OUTPUT
                           , @n_ErrNo        OUTPUT
                           , @c_ErrMsg       OUTPUT

         IF @b_Success = 0
         BEGIN
            SET @n_Continue  = 3   
            GOTO EXIT_SP
         END
      END
   END

EXIT_SP:
   IF @n_Continue= 3  -- Error Occured - Process And Return      
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



