SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************/
/* Store procedure: isp_TPACK_ExtCtnPostUpd_Wrapper                                 */
/* Copyright      : Maersk                                                          */
/*                                                                                  */
/* Purpose        : Extended Carton Post Update Wrapper.                            */
/*                                                                                  */
/* Date         Rev  Author     Purposes                                            */
/* 2025-11-03   1.0  GCH225     UWP-42602, UWP-42604 Created                        */
/* 2026-01-23   2.0  GCH225     UWP-47567: Handle Open Carton to change WOD Status  */
/************************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtCtnPostUpd_Wrapper] (
	  @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @nCartonNo            INT               = 0   
   , @nPrecedingCartonNo   INT               = 0   
   , @cCartonStatus        NVARCHAR(20)      = ''
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @b_Success            INT               = 0   OUTPUT
   , @n_ErrNo              INT               = 0   OUTPUT
   , @c_ErrMsg             NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  

   DECLARE @cExtCtnPostUpdSP  NVARCHAR(30)
         , @cSQL              NVARCHAR(MAX)
         , @cSQLParam         NVARCHAR(3000)

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 

   EXEC nspGetRight    
         @c_Facility   = @cFacility    
      ,  @c_StorerKey  = @cStorerKey   
      ,  @c_sku        = ''    
      ,  @c_ConfigKey  = 'TPS-ExtCtnPostUpd'    
      ,  @c_authority  = @cExtCtnPostUpdSP   OUTPUT    
      ,  @b_Success    = @b_Success          OUTPUT    
      ,  @n_err        = @n_ErrNo            OUTPUT    
      ,  @c_errmsg     = @c_ErrMsg           OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue  = 3  
      GOTO EXIT_SP
   END

   IF @cExtCtnPostUpdSP = 'isp_TPACK_ExtCtnPostUpd_Std'
   BEGIN
      EXEC [API].[isp_TPACK_ExtCtnPostUpd_Std]
         @cType               = @cType            
       , @bIsDiscrete         = @bIsDiscrete      
       , @bIsCustom           = @bIsCustom        
       , @cPickSlipNo         = @cPickSlipNo       
       , @cOrderKey           = @cOrderKey
       , @cLoadKey            = @cLoadKey          
       , @cDropID             = @cDropID
       , @cStorerKey          = @cStorerKey        
       , @cFacility           = @cFacility
       , @nCartonNo           = @nCartonNo
       , @nPrecedingCartonNo  = @nPrecedingCartonNo
       , @cCartonStatus       = @cCartonStatus
       , @c_UserID            = @c_UserID
       , @cLangCode           = @cLangCode
       , @b_Success           = @b_Success     OUTPUT
       , @n_ErrNo             = @n_ErrNo       OUTPUT
       , @c_ErrMsg            = @c_ErrMsg      OUTPUT

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
                  WHERE [name] = @cExtCtnPostUpdSP 
                  AND type = 'P'
      )
      BEGIN
         SET @cSQL = 'EXEC [API].[' + RTRIM(@cExtCtnPostUpdSP) + ']' + CHAR(13)
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
                   + ', @nPrecedingCartonNo   ' + CHAR(13)
                   + ', @cCartonStatus        ' + CHAR(13)
                   + ', @c_UserID             ' + CHAR(13)
                   + ', @cLangCode            ' + CHAR(13)
                   + ', @b_Success     OUTPUT ' + CHAR(13)
                   + ', @n_ErrNo       OUTPUT ' + CHAR(13)
                   + ', @c_ErrMsg      OUTPUT ' + CHAR(13)

         SET @cSQLParam = '  @cType              NVARCHAR(30)         ' + CHAR(13)
                        + ', @bIsDiscrete        BIT                  ' + CHAR(13)
                        + ', @bIsCustom          BIT                  ' + CHAR(13)
                        + ', @cPickSlipNo        NVARCHAR(10)         ' + CHAR(13)
                        + ', @cOrderKey          NVARCHAR(10)         ' + CHAR(13)
                        + ', @cLoadKey           NVARCHAR(10)         ' + CHAR(13)
                        + ', @cDropID            NVARCHAR(20)         ' + CHAR(13)
                        + ', @cStorerKey         NVARCHAR(15)         ' + CHAR(13)
                        + ', @cFacility          NVARCHAR(5)          ' + CHAR(13)
                        + ', @nCartonNo          INT                  ' + CHAR(13)
                        + ', @nPrecedingCartonNo INT                  ' + CHAR(13)
                        + ', @cCartonStatus      NVARCHAR(20)         ' + CHAR(13)
                        + ', @c_UserID           NVARCHAR(256)        ' + CHAR(13)
                        + ', @cLangCode          NVARCHAR(3)          ' + CHAR(13)
                        + ', @b_Success          INT           OUTPUT ' + CHAR(13)
                        + ', @n_ErrNo            INT           OUTPUT ' + CHAR(13)
                        + ', @c_ErrMsg           NVARCHAR(250) OUTPUT ' + CHAR(13)

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
                           , @nPrecedingCartonNo
                           , @cCartonStatus
                           , @c_UserID         
                           , @cLangCode        
                           , @b_Success     OUTPUT
                           , @n_ErrNo       OUTPUT
                           , @c_ErrMsg      OUTPUT

         IF @b_Success = 0
         BEGIN
            SET @n_Continue  = 3
            GOTO EXIT_SP
         END
      END
      ELSE IF LEN(@cExtCtnPostUpdSP) > 1
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 13401
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Invalid Custom SP Name in StorerConfig TPS-ExtCtnPostUpd
         GOTO EXIT_SP
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



