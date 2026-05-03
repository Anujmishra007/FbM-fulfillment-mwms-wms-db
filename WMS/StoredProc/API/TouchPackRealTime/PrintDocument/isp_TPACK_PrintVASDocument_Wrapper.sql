SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_PrintVASDocument_Wrapper                           */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Print  VAS Label or Paper Wrapper                            */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-04-29   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_PrintVASDocument_Wrapper] (
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
   , @cLangCode            NVARCHAR(3)       = ''
   , @bIsLastCarton        BIT               = 0
   , @bPrintLabelFlag      BIT               = 0   OUTPUT
   , @bPrintPaperFlag      BIT               = 0   OUTPUT
   , @cLabelPrinter        NVARCHAR(30)      = ''
   , @cPaperPrinter        NVARCHAR(30)      = ''
   , @oPrintConfigJson     NVARCHAR(MAX)     = ''
   , @bIsAutoPrint         BIT               = 0
   , @nCopy                INT               = 1   
   , @cSKU                 NVARCHAR(20)      = ''
   , @cReportType          NVARCHAR(30)      = ''
   , @cPrintLabelJobIDs    NVARCHAR(MAX)     = ''  OUTPUT
   , @cPrintPaperJobIDs    NVARCHAR(MAX)     = ''  OUTPUT
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

   DECLARE @n_Continue        INT   = 1  
         , @n_StartCnt        INT   = @@TRANCOUNT  

   DECLARE @cExtendedPrintSP  NVARCHAR(250)
         , @cSQL              NVARCHAR(MAX)
         , @cSQLParam         NVARCHAR(MAX)
         , @cConfigKey        NVARCHAR(30)
         , @nContinuePrint    INT


   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 

   SET @cExtendedPrintSP   = ''
   SET @cSQL               = ''
   SET @cSQLParam          = ''
   SET @cConfigKey         = ''
   SET @nContinuePrint     = 1 -- Default to call the standard print SP if Extended Print SP is not configured or print config JSON is not provided.

   SELECT @cExtendedPrintSP = ISNULL(OPTION5,'')
   FROM STORERCONFIG (NOLOCK) 
   WHERE StorerKey = @cStorerKey 
   AND ConfigKey = 'TPS-VAS'
   AND sValue IN('1', '3')

   IF @@ROWCOUNT = 1
   BEGIN
      IF @cExtendedPrintSP <> '' 
      BEGIN
         IF NOT EXISTS( SELECT 1 
                        FROM dbo.sysobjects 
                        WHERE [name] = @cExtendedPrintSP 
                        AND [type] = 'P'
         )
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 15801    
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --Invalid Extended Print SP Name in StorerConfig.
            GOTO EXIT_SP  
         END

         SET @cSQL = 'EXEC [API].[' + RTRIM(@cExtendedPrintSP) + ']' + CHAR(13)
                   + '  @cType                      ' + CHAR(13)
                   + ', @bIsDiscrete                ' + CHAR(13)
                   + ', @bIsCustom                  ' + CHAR(13)
                   + ', @cPickSlipNo                ' + CHAR(13)
                   + ', @cOrderKey                  ' + CHAR(13)
                   + ', @cLoadKey                   ' + CHAR(13)
                   + ', @cDropID                    ' + CHAR(13)
                   + ', @cStorerKey                 ' + CHAR(13)
                   + ', @cFacility                  ' + CHAR(13)
                   + ', @nCartonNo                  ' + CHAR(13)
                   + ', @c_UserID                   ' + CHAR(13)
                   + ', @cLangCode                  ' + CHAR(13)
                   + ', @bIsLastCarton              ' + CHAR(13)
                   + ', @bPrintLabelFlag     OUTPUT ' + CHAR(13)
                   + ', @bPrintPaperFlag     OUTPUT ' + CHAR(13)
                   + ', @cLabelPrinter              ' + CHAR(13)
                   + ', @cPaperPrinter              ' + CHAR(13)
                   + ', @bIsAutoPrint               ' + CHAR(13)
                   + ', @nCopy                      ' + CHAR(13)
                   + ', @cSKU                       ' + CHAR(13)
                   + ', @cReportType                ' + CHAR(13)
                   + ', @cPrintLabelJobIDs   OUTPUT ' + CHAR(13)
                   + ', @cPrintPaperJobIDs   OUTPUT ' + CHAR(13)
                   + ', @nContinuePrint      OUTPUT ' + CHAR(13)
                   + ', @b_Success           OUTPUT ' + CHAR(13)
                   + ', @n_ErrNo             OUTPUT ' + CHAR(13)
                   + ', @c_ErrMsg            OUTPUT ' + CHAR(13)

         SET @cSQLParam = '  @cType             NVARCHAR(30)         ' + CHAR(13)
                        + ', @bIsDiscrete       BIT                  ' + CHAR(13)
                        + ', @bIsCustom         BIT                  ' + CHAR(13)
                        + ', @cPickSlipNo       NVARCHAR(10)         ' + CHAR(13)
                        + ', @cOrderKey         NVARCHAR(10)         ' + CHAR(13)
                        + ', @cLoadKey          NVARCHAR(10)         ' + CHAR(13)
                        + ', @cDropID           NVARCHAR(20)         ' + CHAR(13)
                        + ', @cStorerKey        NVARCHAR(15)         ' + CHAR(13)
                        + ', @cFacility         NVARCHAR(5)          ' + CHAR(13)
                        + ', @nCartonNo         INT                  ' + CHAR(13)
                        + ', @c_UserID          NVARCHAR(256)        ' + CHAR(13)
                        + ', @cLangCode         NVARCHAR(3)          ' + CHAR(13)
                        + ', @bIsLastCarton     BIT                  ' + CHAR(13)
                        + ', @bPrintLabelFlag   BIT           OUTPUT ' + CHAR(13)
                        + ', @bPrintPaperFlag   BIT           OUTPUT ' + CHAR(13)
                        + ', @cLabelPrinter     NVARCHAR(30)         ' + CHAR(13)
                        + ', @cPaperPrinter     NVARCHAR(30)         ' + CHAR(13)
                        + ', @bIsAutoPrint      BIT                  ' + CHAR(13)
                        + ', @nCopy             INT                  ' + CHAR(13)
                        + ', @cSKU              NVARCHAR(20)         ' + CHAR(13)
                        + ', @cReportType       NVARCHAR(30)         ' + CHAR(13)
                        + ', @cPrintLabelJobIDs NVARCHAR(MAX) OUTPUT ' + CHAR(13)
                        + ', @cPrintPaperJobIDs NVARCHAR(MAX) OUTPUT ' + CHAR(13)
                        + ', @nContinuePrint    INT           OUTPUT ' + CHAR(13)
                        + ', @b_Success         INT           OUTPUT ' + CHAR(13)
                        + ', @n_ErrNo           INT           OUTPUT ' + CHAR(13)
                        + ', @c_ErrMsg          NVARCHAR(250) OUTPUT ' + CHAR(13)
      
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
                           , @bIsLastCarton 
                           , @bPrintLabelFlag   OUTPUT
                           , @bPrintPaperFlag   OUTPUT
                           , @cLabelPrinter    
                           , @cPaperPrinter    
                           , @bIsAutoPrint
                           , @nCopy
                           , @cSKU
                           , @cReportType
                           , @cPrintLabelJobIDs OUTPUT
                           , @cPrintPaperJobIDs OUTPUT
                           , @nContinuePrint    OUTPUT
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
         EXEC [API].[isp_TPACK_PrintDocument_VAS]
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
         , @c_UserID          = @c_UserID
         , @cLangCode         = @cLangCode
         , @bIsLastCarton     = @bIsLastCarton
         , @bPrintLabelFlag   = @bPrintLabelFlag     OUTPUT
         , @bPrintPaperFlag   = @bPrintPaperFlag     OUTPUT
         , @cLabelPrinter     = @cLabelPrinter    
         , @cPaperPrinter     = @cPaperPrinter    
         , @bIsAutoPrint      = @bIsAutoPrint
         , @nCopy             = @nCopy
         , @cSKU              = @cSKU
         , @cReportType       = @cReportType
         , @cPrintLabelJobIDs = @cPrintLabelJobIDs   OUTPUT
         , @cPrintPaperJobIDs = @cPrintPaperJobIDs   OUTPUT
         , @nContinuePrint    = @nContinuePrint      OUTPUT
         , @b_Success         = @b_Success           OUTPUT
         , @n_ErrNo           = @n_ErrNo             OUTPUT
         , @c_ErrMsg          = @c_ErrMsg            OUTPUT

         IF @b_Success = 0
         BEGIN
            SET @n_Continue  = 3    
            GOTO EXIT_SP
         END
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