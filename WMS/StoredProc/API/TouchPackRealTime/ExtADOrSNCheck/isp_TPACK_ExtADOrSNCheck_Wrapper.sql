SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtADOrSNCheck_Wrapper                             */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Extended AD or SN Check the SKU and prompt user accordingly. */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-08-11   1.0  GCH225     UWP-61712: Created                               */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtADOrSNCheck_Wrapper] (
	  @cType            NVARCHAR(30)   = ''
   , @bIsDiscrete      BIT            = 0
   , @bIsCustom        BIT            = 0
   , @cPickSlipNo      NVARCHAR(10)   = ''
   , @cOrderKey        NVARCHAR(10)   = ''
   , @cLoadKey         NVARCHAR(10)   = ''
   , @cDropID          NVARCHAR(20)   = ''
   , @cStorerKey       NVARCHAR(15)   = ''
   , @cFacility        NVARCHAR(5)    = ''
   , @cInputValue1     NVARCHAR(128)  = ''
   , @cInputValue2     NVARCHAR(MAX)  = ''
   , @cInputValue3     NVARCHAR(128)  = ''
   , @cScanType        NVARCHAR(20)   = ''
   , @cSKU             NVARCHAR(20)   = ''
   , @nCartonNo        INT            = 0
   , @nQty             INT            = 0       
   , @c_UserID         NVARCHAR(256)  = ''  
   , @cLangCode        NVARCHAR(3)    = ''
   , @bShowADScreen    BIT            = 0   OUTPUT
   , @bGoToSearchSKU   BIT            = 0   OUTPUT
   , @nDisplayADQty    INT            = 0   OUTPUT
   , @nNumberOfADField INT            = 0   OUTPUT
   , @b_Success        INT            = 0   OUTPUT
   , @n_ErrNo          INT            = 0   OUTPUT
   , @c_ErrMsg         NVARCHAR(250)  = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue        INT            = 1  
         , @n_StartCnt        INT            = @@TRANCOUNT  

   DECLARE @cExtADOrSNCheck   NVARCHAR(256)
         , @cSQL              NVARCHAR(MAX)
         , @cSQLParam         NVARCHAR(3000)

   SET @b_Success = 0  
   SET @n_ErrNo   = 0  
   SET @c_ErrMsg  = '' 

   EXEC nspGetRight    
         @c_Facility   = @cFacility    
      ,  @c_StorerKey  = @cStorerKey   
      ,  @c_sku        = ''    
      ,  @c_ConfigKey  = 'TPS-ExtADOrSNCheck'    
      ,  @c_authority  = @cExtADOrSNCheck OUTPUT    
      ,  @b_Success    = @b_Success       OUTPUT    
      ,  @n_err        = @n_ErrNo         OUTPUT    
      ,  @c_errmsg     = @c_ErrMsg        OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue  = 3  
      GOTO EXIT_SP
   END

   IF EXISTS ( SELECT 1 
               FROM dbo.sysobjects (NOLOCK)
               WHERE [name] = @cExtADOrSNCheck 
               AND type = 'P'
   )
   BEGIN
      SET @cSQL = 'EXEC [API].[' + RTRIM(@cExtADOrSNCheck) + ']' + CHAR(13)
                  + '  @cType                   ' + CHAR(13)
                  + ', @bIsDiscrete             ' + CHAR(13)
                  + ', @bIsCustom               ' + CHAR(13)
                  + ', @cPickSlipNo             ' + CHAR(13)
                  + ', @cOrderKey               ' + CHAR(13)
                  + ', @cLoadKey                ' + CHAR(13)
                  + ', @cDropID                 ' + CHAR(13)
                  + ', @cStorerKey              ' + CHAR(13)
                  + ', @cFacility               ' + CHAR(13)
                  + ', @cInputValue1            ' + CHAR(13)
                  + ', @cInputValue2            ' + CHAR(13)
                  + ', @cInputValue3            ' + CHAR(13)
                  + ', @cScanType               ' + CHAR(13)
                  + ', @cSKU                    ' + CHAR(13)
                  + ', @nCartonNo               ' + CHAR(13)
                  + ', @nQty                    ' + CHAR(13)
                  + ', @c_UserID                ' + CHAR(13)
                  + ', @cLangCode               ' + CHAR(13)
                  + ', @bShowADScreen    OUTPUT ' + CHAR(13)
                  + ', @bGoToSearchSKU   OUTPUT ' + CHAR(13)
                  + ', @nDisplayADQty    OUTPUT ' + CHAR(13)
                  + ', @nNumberOfADField OUTPUT ' + CHAR(13)
                  + ', @b_Success        OUTPUT ' + CHAR(13)
                  + ', @n_ErrNo          OUTPUT ' + CHAR(13)
                  + ', @c_ErrMsg         OUTPUT ' + CHAR(13)

      SET @cSQLParam = '  @cType            NVARCHAR(30)         ' + CHAR(13)
                     + ', @bIsDiscrete      BIT                  ' + CHAR(13)
                     + ', @bIsCustom        BIT                  ' + CHAR(13)
                     + ', @cPickSlipNo      NVARCHAR(10)         ' + CHAR(13)
                     + ', @cOrderKey        NVARCHAR(10)         ' + CHAR(13)
                     + ', @cLoadKey         NVARCHAR(10)         ' + CHAR(13)
                     + ', @cDropID          NVARCHAR(20)         ' + CHAR(13)
                     + ', @cStorerKey       NVARCHAR(15)         ' + CHAR(13)
                     + ', @cFacility        NVARCHAR(5)          ' + CHAR(13)
                     + ', @cInputValue1     NVARCHAR(128)        ' + CHAR(13)
                     + ', @cInputValue2     NVARCHAR(MAX)        ' + CHAR(13)
                     + ', @cInputValue3     NVARCHAR(128)        ' + CHAR(13)
                     + ', @cScanType        NVARCHAR(20)         ' + CHAR(13)
                     + ', @cSKU             NVARCHAR(20)         ' + CHAR(13)
                     + ', @nCartonNo        INT                  ' + CHAR(13)
                     + ', @nQty             INT                  ' + CHAR(13)
                     + ', @c_UserID         NVARCHAR(256)        ' + CHAR(13)
                     + ', @cLangCode        NVARCHAR(3)          ' + CHAR(13)
                     + ', @bShowADScreen    BIT           OUTPUT ' + CHAR(13)
                     + ', @bGoToSearchSKU   BIT           OUTPUT ' + CHAR(13)
                     + ', @nDisplayADQty    INT           OUTPUT ' + CHAR(13)
                     + ', @nNumberOfADField INT           OUTPUT ' + CHAR(13)
                     + ', @b_Success        INT           OUTPUT ' + CHAR(13)
                     + ', @n_ErrNo          INT           OUTPUT ' + CHAR(13)
                     + ', @c_ErrMsg         NVARCHAR(250) OUTPUT ' + CHAR(13)

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
                        , @cInputValue1     
                        , @cInputValue2     
                        , @cInputValue3     
                        , @cScanType        
                        , @cSKU             
                        , @nCartonNo 
                        , @nQty             
                        , @c_UserID         
                        , @cLangCode        
                        , @bShowADScreen    OUTPUT
                        , @bGoToSearchSKU   OUTPUT
                        , @nDisplayADQty    OUTPUT
                        , @nNumberOfADField OUTPUT
                        , @b_Success        OUTPUT
                        , @n_ErrNo          OUTPUT
                        , @c_ErrMsg         OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue  = 3   
         GOTO EXIT_SP
      END
   END
   ELSE
   BEGIN
      EXEC [API].[isp_TPACK_ExtADOrSNCheck_Std]
         @cType             = @cType            
       , @bIsDiscrete       = @bIsDiscrete      
       , @bIsCustom         = @bIsCustom        
       , @cPickSlipNo       = @cPickSlipNo       
       , @cOrderKey         = @cOrderKey
       , @cLoadKey          = @cLoadKey          
       , @cDropID           = @cDropID
       , @cStorerKey        = @cStorerKey        
       , @cFacility         = @cFacility   
       , @cInputValue1      = @cInputValue1
       , @cInputValue2      = @cInputValue2
       , @cInputValue3      = @cInputValue3
       , @cScanType         = @cScanType
       , @cSKU              = @cSKU
       , @nCartonNo         = @nCartonNo
       , @nQty              = @nQty
       , @c_UserID          = @c_UserID
       , @cLangCode         = @cLangCode
       , @bShowADScreen     = @bShowADScreen    OUTPUT
       , @bGoToSearchSKU    = @bGoToSearchSKU   OUTPUT
       , @nDisplayADQty     = @nDisplayADQty    OUTPUT
       , @nNumberOfADField  = @nNumberOfADField OUTPUT
       , @b_Success         = @b_Success        OUTPUT
       , @n_ErrNo           = @n_ErrNo          OUTPUT
       , @c_ErrMsg          = @c_ErrMsg         OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue  = 3  
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
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [API].[isp_TPACK_ExtADOrSNCheck_Wrapper] TO NSQL
GO