
/*********************************************************************************/    
/* Stored Proc: isp_TPACK_PackDecode_Wrapper                                      */    
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Check the Pack Decode Config                                 */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-04   1.0  GCH225     Created                                          */
/* 2026-03-05   2.0  GCH225     UWP-49985: Support Decode InputValue 2 and 3     */
/*********************************************************************************/
CREATE OR ALTER PROC [API].[isp_TPACK_PackDecode_Wrapper] (
     @cType             NVARCHAR(30)      = ''
   , @bIsDiscrete       BIT               = 0
   , @bIsCustom         BIT               = 0
   , @cPickSlipNo       NVARCHAR(10)      = ''
   , @cOrderKey         NVARCHAR(10)      = ''
   , @cLoadKey          NVARCHAR(10)      = ''
   , @cDropID           NVARCHAR(20)      = ''
   , @cStorerKey        NVARCHAR(15)      = ''
   , @cFacility         NVARCHAR(5)       = ''
   , @cInputValue1      NVARCHAR(128)     = ''
   , @cInputValue2      NVARCHAR(MAX)     = ''  OUTPUT
   , @cInputValue3      NVARCHAR(128)     = ''  OUTPUT
   , @c_UserID          NVARCHAR(256)     = ''
   , @cLangCode         NVARCHAR(3)       = ''
   , @cSKU              NVARCHAR(20)      = ''  OUTPUT
   , @nQty              INT                     OUTPUT
   , @b_Success         INT               = 0   OUTPUT
   , @n_ErrNo           INT               = 0   OUTPUT
   , @c_ErrMsg          NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue     INT            = 1  
         , @n_StartCnt     INT            = @@TRANCOUNT  

         , @cConfigKey     NVARCHAR(30)
         , @cConfigVal     NVARCHAR(30)
         , @cSQL           NVARCHAR(2000)
         , @cSQLParams     NVARCHAR(2000)
   
   SET @b_Success       = 0  
   SET @n_ErrNo         = 0  
   SET @c_ErrMsg        = ''  

   --TPS-GetKeyPadInput
   SET @cConfigKey = 'TPS-PackDecode'
   SET @cConfigVal = ''

   SELECT @cConfigVal = ISNULL(sValue,'')
   FROM STORERCONFIG (NOLOCK)  
   WHERE StorerKey = @cStorerKey  
   AND ConfigKey = @cConfigKey

   IF @@ROWCOUNT = 1
   BEGIN  
      IF EXISTS( SELECT 1 
                 FROM dbo.sysobjects 
                 WHERE [name] = @cConfigVal 
                 AND [type] = 'P'
      )    
      BEGIN 
         SET @cSQL = 'EXEC API.' + RTRIM( @cConfigVal)
                   + '  @cType                    ' + CHAR(13)
                   + ', @bIsDiscrete              ' + CHAR(13)
                   + ', @bIsCustom                ' + CHAR(13)
                   + ', @cPickSlipNo              ' + CHAR(13)
                   + ', @cOrderKey                ' + CHAR(13)
                   + ', @cLoadKey                 ' + CHAR(13)
                   + ', @cDropID                  ' + CHAR(13)
                   + ', @cStorerKey               ' + CHAR(13)
                   + ', @cFacility                ' + CHAR(13)
                   + ', @cInputValue1             ' + CHAR(13)
                   + ', @cInputValue2      OUTPUT ' + CHAR(13)
                   + ', @cInputValue3      OUTPUT ' + CHAR(13)
                   + ', @c_UserID                 ' + CHAR(13)   
                   + ', @cLangCode                ' + CHAR(13)   
                   + ', @cSKU              OUTPUT ' + CHAR(13)
                   + ', @nQty              OUTPUT ' + CHAR(13) 
                   + ', @b_Success         OUTPUT ' + CHAR(13)
                   + ', @n_ErrNo           OUTPUT ' + CHAR(13)
                   + ', @c_ErrMsg          OUTPUT ' + CHAR(13)

         SET @cSQLParams = '  @cType            NVARCHAR(30)         ' + CHAR(13)
                         + ', @bIsDiscrete      BIT                  ' + CHAR(13)
                         + ', @bIsCustom        BIT                  ' + CHAR(13)
                         + ', @cPickSlipNo      NVARCHAR(10)         ' + CHAR(13)
                         + ', @cOrderKey        NVARCHAR(10)         ' + CHAR(13)
                         + ', @cLoadKey         NVARCHAR(10)         ' + CHAR(13)
                         + ', @cDropID          NVARCHAR(20)         ' + CHAR(13)
                         + ', @cStorerKey       NVARCHAR(15)         ' + CHAR(13)
                         + ', @cFacility        NVARCHAR(5)          ' + CHAR(13)
                         + ', @cInputValue1     NVARCHAR(128)        ' + CHAR(13)  
                         + ', @cInputValue2     NVARCHAR(MAX) OUTPUT ' + CHAR(13)
                         + ', @cInputValue3     NVARCHAR(128) OUTPUT ' + CHAR(13)
                         + ', @c_UserID         NVARCHAR(256)        ' + CHAR(13) 
                         + ', @cLangCode        NVARCHAR(3)          ' + CHAR(13) 
                         + ', @cSKU             NVARCHAR(20)  OUTPUT ' + CHAR(13)
                         + ', @nQty             INT           OUTPUT ' + CHAR(13) 
                         + ', @b_Success        INT           OUTPUT ' + CHAR(13) 
                         + ', @n_ErrNo          INT           OUTPUT ' + CHAR(13)
                         + ', @c_ErrMsg         NVARCHAR(20)  OUTPUT ' + CHAR(13)   

         EXEC sp_ExecuteSQL  @cSQL
                           , @cSQLParams
                           , @cType
                           , @bIsDiscrete
                           , @bIsCustom
                           , @cPickSlipNo
                           , @cOrderKey
                           , @cLoadKey
                           , @cDropID
                           , @cStorerKey
                           , @cFacility
                           , @cInputValue1
                           , @cInputValue2      OUTPUT
                           , @cInputValue3      OUTPUT
                           , @c_UserID
                           , @cLangCode
                           , @cSKU              OUTPUT
                           , @nQty              OUTPUT
                           , @b_Success         OUTPUT    
                           , @n_ErrNo           OUTPUT    
                           , @c_ErrMsg          OUTPUT    

         IF @b_Success = 0    
         BEGIN     
            GOTO EXIT_SP    
         END    
      END
      ELSE
      BEGIN
         SET @n_ErrNo = 11251
         SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No Decode SP found in StorerConfig table.'
         GOTO EXIT_SP
      END
   END  

   SET @b_Success = 1

EXIT_SP:
END -- procedure 
