SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************/
/* Store procedure: isp_TPACK_ExtCtnPreUpd_Wrapper                                  */
/* Copyright      : Maersk                                                          */
/*                                                                                  */
/* Purpose        : Extended Carton Pre Update Wrapper                              */
/*                                                                                  */
/* Date         Rev  Author     Purposes                                            */
/* 2026-03-13   1.0  GCH225     FCR-11554: Created                                  */
/* 2026-03-14   1.1  GCH225     FCR-11635: Updated parameter order                  */
/************************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtCtnPreUpd_Wrapper] (
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
   , @cCartonStatus        NVARCHAR(20)      = ''
   , @cCartonType          NVARCHAR(10)      = ''
   , @fWeight              FLOAT             = 0
   , @fCube                FLOAT             = 0
   , @cLabelNo             NVARCHAR(20)      = ''
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @bWeightInterface     BIT               = 0   OUTPUT
   , @bPrintPaperFlag      BIT               = 0   OUTPUT
   , @bPrintLabelFlag      BIT               = 0   OUTPUT
   , @bIsLastCarton        BIT               = 0   OUTPUT
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

   DECLARE @n_Continue        INT            = 1  
         , @n_StartCnt        INT            = @@TRANCOUNT  

   DECLARE @cExtCtnPreUpdSP   NVARCHAR(30)
         , @cSQL              NVARCHAR(MAX)  = ''
         , @cSQLParam         NVARCHAR(MAX)  = ''
   
   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 
   
   SET @cSQL               = ''
   SET @cSQLParam          = ''
   
   EXEC nspGetRight    
         @c_Facility   = @cFacility    
      ,  @c_StorerKey  = @cStorerKey   
      ,  @c_sku        = ''    
      ,  @c_ConfigKey  = 'TPS-ExtCtnPreUpd'    
      ,  @c_authority  = @cExtCtnPreUpdSP OUTPUT    
      ,  @b_Success    = @b_Success       OUTPUT    
      ,  @n_err        = @n_ErrNo         OUTPUT    
      ,  @c_errmsg     = @c_ErrMsg        OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue  = 3  
      GOTO EXIT_SP
   END

   IF @cExtCtnPreUpdSP = 'isp_TPACK_ExtCtnPreUpd_Std'
   BEGIN
      EXEC [API].[isp_TPACK_ExtCtnPreUpd_Std]
           @cType             = @cType            
         , @bIsDiscrete       = @bIsDiscrete      
         , @bIsCustom         = @bIsCustom        
         , @cPickSlipNo       = @cPickSlipNo       
         , @cOrderKey         = @cOrderKey
         , @cLoadKey          = @cLoadKey          
         , @cDropID           = @cDropID
         , @cStorerKey        = @cStorerKey        
         , @cFacility         = @cFacility   
         , @nCartonNo         = @nCartonNo
         , @cCartonStatus     = @cCartonStatus
         , @cCartonType       = @cCartonType
         , @fWeight           = @fWeight
         , @fCube             = @fCube
         , @cLabelNo          = @cLabelNo
         , @c_UserID          = @c_UserID
         , @cLangCode         = @cLangCode
         , @bWeightInterface  = @bWeightInterface  OUTPUT
         , @bPrintPaperFlag   = @bPrintPaperFlag   OUTPUT
         , @bPrintLabelFlag   = @bPrintLabelFlag   OUTPUT
         , @bIsLastCarton     = @bIsLastCarton     OUTPUT
         , @b_Success         = @b_Success         OUTPUT
         , @n_ErrNo           = @n_ErrNo           OUTPUT
         , @c_ErrMsg          = @c_ErrMsg          OUTPUT

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
                  WHERE [name] = @cExtCtnPreUpdSP 
                  AND type = 'P'
      )
      BEGIN
         SET @cSQL = 'EXEC [API].[' + RTRIM(@cExtCtnPreUpdSP) + ']' + CHAR(13)
                   + '  @cType                   ' + CHAR(13)
                   + ', @bIsDiscrete             ' + CHAR(13)
                   + ', @bIsCustom               ' + CHAR(13)
                   + ', @cPickSlipNo             ' + CHAR(13)
                   + ', @cOrderKey               ' + CHAR(13)
                   + ', @cLoadKey                ' + CHAR(13)
                   + ', @cDropID                 ' + CHAR(13)
                   + ', @cStorerKey              ' + CHAR(13)
                   + ', @cFacility               ' + CHAR(13)
                   + ', @nCartonNo               ' + CHAR(13)
                   + ', @cCartonStatus           ' + CHAR(13)
                   + ', @cCartonType             ' + CHAR(13)
                   + ', @fWeight                 ' + CHAR(13)
                   + ', @fCube                   ' + CHAR(13)
                   + ', @cLabelNo                ' + CHAR(13)
                   + ', @c_UserID                ' + CHAR(13)
                   + ', @cLangCode               ' + CHAR(13)
                   + ', @bWeightInterface OUTPUT ' + CHAR(13)
                   + ', @bPrintPaperFlag  OUTPUT ' + CHAR(13)
                   + ', @bPrintLabelFlag  OUTPUT ' + CHAR(13)
                   + ', @bIsLastCarton    OUTPUT ' + CHAR(13)
                   + ', @b_Success        OUTPUT ' + CHAR(13)
                   + ', @n_ErrNo          OUTPUT ' + CHAR(13)
                   + ', @c_ErrMsg         OUTPUT ' + CHAR(13)

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
                        + ', @cCartonStatus      NVARCHAR(20)         ' + CHAR(13)
                        + ', @cCartonType        NVARCHAR(20)         ' + CHAR(13)
                        + ', @fWeight            FLOAT                ' + CHAR(13)
                        + ', @fCube              FLOAT                ' + CHAR(13)
                        + ', @cLabelNo           NVARCHAR(50)         ' + CHAR(13)
                        + ', @c_UserID           NVARCHAR(256)        ' + CHAR(13)
                        + ', @cLangCode          NVARCHAR(3)          ' + CHAR(13)
                        + ', @bWeightInterface   BIT           OUTPUT ' + CHAR(13)
                        + ', @bPrintPaperFlag    BIT           OUTPUT ' + CHAR(13)
                        + ', @bPrintLabelFlag    BIT           OUTPUT ' + CHAR(13)
                        + ', @bIsLastCarton      BIT           OUTPUT ' + CHAR(13)
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
                           , @cCartonStatus
                           , @cCartonType
                           , @fWeight
                           , @fCube
                           , @cLabelNo
                           , @c_UserID         
                           , @cLangCode 
                           , @bWeightInterface  OUTPUT
                           , @bPrintPaperFlag   OUTPUT
                           , @bPrintLabelFlag   OUTPUT
                           , @bIsLastCarton     OUTPUT       
                           , @b_Success         OUTPUT
                           , @n_ErrNo           OUTPUT
                           , @c_ErrMsg          OUTPUT

         IF @b_Success = 0
         BEGIN
            SET @n_Continue  = 3
            GOTO EXIT_SP
         END
      END
      ELSE IF LEN(@cExtCtnPreUpdSP) > 1
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 15201
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Invalid Custom SP Name in StorerConfig TPS-ExtCtnPreUpd
         GOTO EXIT_SP
      END
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
