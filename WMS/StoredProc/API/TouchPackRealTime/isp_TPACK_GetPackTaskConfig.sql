SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*********************************************************************************/    
/* Stored Proc: isp_TPACK_GetPackTaskConfig                                      */    
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get Check and Get all the storerconfig                       */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-04   1.0  GCH225     Created                                          */
/* 2025-10-30   1.1  JWF011     UWP-42640: Add config TPS-OffToteConfirm         */
/* 2026-03-13   2.0  GCH225     FCR-11597 Add Extended Pack Task Config Logic    */
/*********************************************************************************/
CREATE OR ALTER PROC [API].[isp_TPACK_GetPackTaskConfig] (
     @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @c_UserID             NVARCHAR(256)     = ''
   , @cPackTaskConfigJson  NVARCHAR(MAX)     = ''  OUTPUT
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
         , @cExtPackTaskConfig   NVARCHAR(250)
         , @cLangCode            NVARCHAR(3)   
         , @cSQL                 NVARCHAR(MAX)
         , @cSQLParam            NVARCHAR(3000)

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  
   SET @cExtPackTaskConfig    = ''
   SET @cLangCode             = 'ENG'

   SELECT @cExtPackTaskConfig = ISNULL(sValue,'')
   FROM STORERCONFIG (NOLOCK)
   WHERE Storerkey = @cStorerKey
   AND ConfigKey = 'TPS-ExtPackTaskConfig'
   AND sValue <> ''
   
   IF @@ROWCOUNT = 1
   BEGIN
      IF NOT EXISTS( SELECT 1 
                     FROM dbo.sysobjects 
                     WHERE [name] = @cExtPackTaskConfig
                     AND [type] = 'P'
      )
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 11101    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --Invalid Extended Pack Task Config SP Name in StorerConfig.
         GOTO EXIT_SP  
      END

      SET @cSQL = 'EXEC [API].[' + RTRIM(@cExtPackTaskConfig) + ']' + CHAR(13)
                  + '  @cType                       ' + CHAR(13)
                  + ', @bIsDiscrete                 ' + CHAR(13)
                  + ', @bIsCustom                   ' + CHAR(13)
                  + ', @cPickSlipNo                 ' + CHAR(13)
                  + ', @cOrderKey                   ' + CHAR(13)
                  + ', @cLoadKey                    ' + CHAR(13)
                  + ', @cDropID                     ' + CHAR(13)
                  + ', @cStorerKey                  ' + CHAR(13)
                  + ', @cFacility                   ' + CHAR(13)
                  + ', @c_UserID                    ' + CHAR(13)
                  + ', @cPackTaskConfigJson  OUTPUT ' + CHAR(13)
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
                     + ', @c_UserID            NVARCHAR(256)        ' + CHAR(13)
                     + ', @cPackTaskConfigJson NVARCHAR(MAX) OUTPUT ' + CHAR(13)
                     + ', @b_Success           INT           OUTPUT ' + CHAR(13)
                     + ', @n_ErrNo             INT           OUTPUT ' + CHAR(13)
                     + ', @c_ErrMsg            NVARCHAR(250) OUTPUT ' + CHAR(13)
   
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
                        , @cPackTaskConfigJson  OUTPUT
                        , @b_Success            OUTPUT
                        , @n_ErrNo              OUTPUT
                        , @c_ErrMsg             OUTPUT
   
      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3   
         GOTO EXIT_SP
      END
   END
   ELSE
   BEGIN
      SET @cPackTaskConfigJson = ISNULL ((SELECT  ConfigKey AS configKey
                                                , sValue as configVal
                                                , OPTION1 AS configOpt1
                                                , OPTION2 AS configOpt2
                                                , OPTION3 AS configOpt3
                                                , OPTION4 AS configOpt4
                                                , OPTION5 AS configOpt5
                                          FROM STORERCONFIG sc (NOLOCK) 
                                          WHERE StorerKey = @cStorerKey  
                                          AND (ConfigKey LIKE 'TPS%'
                                          OR ConfigKey IN (
                                          'PackCaptureNewLabelno'
                                          ))
                                          FOR JSON PATH
                                          ),'')
   END

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