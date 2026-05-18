SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*********************************************************************************/    
/* Stored Proc: isp_TPACK_ExtPackInfo_Wrapper                                    */    
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get extended pack info                                       */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-04-16   1.0  GCH225     Created                                          */
/*********************************************************************************/
CREATE OR ALTER PROC [API].[isp_TPACK_ExtPackInfo_Wrapper] (
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
   , @c_UserID             NVARCHAR(256)     = ''
   , @cLangCode            NVARCHAR(10)      = ''
   , @cExtPackInfoJson     NVARCHAR(MAX)     = 0   OUTPUT
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
         , @cExtPackInfoConfig   NVARCHAR(250)
         , @cSQL                 NVARCHAR(MAX)
         , @cSQLParam            NVARCHAR(3000)

   DECLARE @DynamicData TABLE (
        rowRef       INT IDENTITY(1,1) PRIMARY KEY
      , fieldName    NVARCHAR(100)
      , fieldValue   NVARCHAR(1000)
   )

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  
   SET @cExtPackInfoConfig    = ''

   SELECT @cExtPackInfoConfig = ISNULL(sValue,'')
   FROM STORERCONFIG (NOLOCK)
   WHERE Storerkey = @cStorerKey
   AND ConfigKey = 'TPS-ExtPackInfo'
   AND sValue <> ''
   
   IF @@ROWCOUNT = 1
   BEGIN
      IF NOT EXISTS( SELECT 1 
                     FROM dbo.sysobjects 
                     WHERE [name] = @cExtPackInfoConfig
                     AND [type] = 'P'
      )
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 15551    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --Invalid Extended Pack Info Config SP Name in StorerConfig.
         GOTO EXIT_SP  
      END

      SET @cSQL = 'EXEC [API].[' + RTRIM(@cExtPackInfoConfig) + ']' + CHAR(13)
                  + '  @cType                       ' + CHAR(13)
                  + ', @bIsDiscrete                 ' + CHAR(13)
                  + ', @bIsCustom                   ' + CHAR(13)
                  + ', @cPickSlipNo                 ' + CHAR(13)
                  + ', @cOrderKey                   ' + CHAR(13)
                  + ', @cLoadKey                    ' + CHAR(13)
                  + ', @cDropID                     ' + CHAR(13)
                  + ', @cStorerKey                  ' + CHAR(13)
                  + ', @cFacility                   ' + CHAR(13)
                  + ', @nCartonNo                   ' + CHAR(13)
                  + ', @c_UserID                    ' + CHAR(13)
                  + ', @cLangCode                   ' + CHAR(13)
                  + ', @b_Success            OUTPUT ' + CHAR(13)
                  + ', @n_ErrNo              OUTPUT ' + CHAR(13)
                  + ', @c_ErrMsg             OUTPUT ' + CHAR(13)

      SET @cSQLParam = '  @cType               NVARCHAR(30)         ' + CHAR(13)
                     + ', @bIsDiscrete         BIT                  ' + CHAR(13)
                     + ', @bIsCustom           BIT                  ' + CHAR(13)
                     + ', @cPickSlipNo         NVARCHAR(10)         ' + CHAR(13)
                     + ', @cOrderKey           NVARCHAR(10)         ' + CHAR(13)
                     + ', @cLoadKey            NVARCHAR(10)         ' + CHAR(13)
                     + ', @cDropID             NVARCHAR(20)         ' + CHAR(13)
                     + ', @cStorerKey          NVARCHAR(15)         ' + CHAR(13)
                     + ', @cFacility           NVARCHAR(5)          ' + CHAR(13)
                     + ', @nCartonNo           INT                  ' + CHAR(13)
                     + ', @c_UserID            NVARCHAR(256)        ' + CHAR(13)
                     + ', @cLangCode           NVARCHAR(3)          ' + CHAR(13)
                     + ', @b_Success           INT           OUTPUT ' + CHAR(13)
                     + ', @n_ErrNo             INT           OUTPUT ' + CHAR(13)
                     + ', @c_ErrMsg            NVARCHAR(250) OUTPUT ' + CHAR(13)

      INSERT INTO @DynamicData (fieldName, fieldValue)
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
                        , @c_UserID         
                        , @cLangCode
                        , @b_Success         OUTPUT
                        , @n_ErrNo           OUTPUT
                        , @c_ErrMsg          OUTPUT
   
      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3   
         GOTO EXIT_SP
      END
   END
   ELSE
   BEGIN
      INSERT INTO @DynamicData (fieldName, fieldValue)
      EXEC [API].[isp_TPACK_ExtPackInfo_Std]
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
       , @c_UserID    = @c_UserID
       , @cLangCode   = @cLangCode
       , @b_Success   = @b_Success   OUTPUT
       , @n_ErrNo     = @n_ErrNo     OUTPUT
       , @c_ErrMsg    = @c_ErrMsg    OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue  = 3     
         GOTO EXIT_SP
      END
   END

   SET @cExtPackInfoJson = ISNULL ((SELECT  rowRef
                                          , fieldName
                                          , fieldValue 
                                          FROM @DynamicData 
                                          FOR JSON PATH
                                          ),'[]')
   
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
      SET @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END