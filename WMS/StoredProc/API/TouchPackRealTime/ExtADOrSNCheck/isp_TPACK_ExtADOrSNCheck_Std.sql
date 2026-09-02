SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtADOrSNCheck_Std                                 */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Standard AD or SN Check the SKU and prompt user accordingly. */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-08-11   1.0  GCH225     UWP-61712: Created                               */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtADOrSNCheck_Std] (
	  @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @cInputValue1         NVARCHAR(128)     = ''
   , @cInputValue2         NVARCHAR(MAX)     = ''
   , @cInputValue3         NVARCHAR(128)     = ''
   , @cScanType            NVARCHAR(20)      = ''
   , @cSKU                 NVARCHAR(20)      = ''
   , @nCartonNo            INT               = 0
   , @nQty                 INT               = 0       
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @bShowADScreen        BIT               = 0   OUTPUT
   , @bGoToSearchSKU       BIT               = 0   OUTPUT
   , @nDisplayADQty        INT               = 0   OUTPUT
   , @nNumberOfADField     INT               = 0   OUTPUT
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
         , @cConfigValue      NVARCHAR(256)
         , @cSQL              NVARCHAR(MAX)
         , @cSQLParams        NVARCHAR(MAX)
         , @cAuthority        NVARCHAR(1)  

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = ''
   SET @cConfigValue       = ''
   SET @cSQL               = ''
   SET @cSQLParams         = ''
   SET @cAuthority         = ''
   SET @nNumberOfADField   = 0

   IF NOT EXISTS( SELECT 1 
                  FROM CODELKUP (NOLOCK) 
                  WHERE Listname = 'REQEXP'
                  AND Code = 'ADBARCODE'
                  AND StorerKey = @cStorerKey
   ) 
   OR 
   NOT EXISTS ( SELECT 1 
                  FROM SKU (NOLOCK) 
                  WHERE StorerKey = @cStorerKey
                  AND SKU = @cSKU
                  AND SUSR4 = 'AD'
   )
   BEGIN
      GOTO EXIT_SP
   END

   SELECT @cConfigValue = RTRIM(sValue)
   FROM STORERCONFIG (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND ConfigKey = 'TPS-ExtSkipSKUADScn'

   IF @@ROWCOUNT <> 0
   BEGIN
      IF EXISTS(  SELECT 1 
                  FROM dbo.sysobjects 
                  WHERE name = @cConfigValue 
                  AND type = 'P'
      )
      BEGIN
         SET @cSQL   = 'EXEC [API].[' + @cConfigValue + ']' + CHAR(13)
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
                     + ', @cSkipSKUADScn OUTPUT ' + CHAR(13)    
                     + ', @b_Success     OUTPUT ' + CHAR(13)    
                     + ', @n_ErrNo       OUTPUT ' + CHAR(13)    
                     + ', @c_ErrMsg      OUTPUT ' + CHAR(13)      
                        
         SET @cSQLParams   = '  @cType         NVARCHAR(30)          ' + CHAR(13)
                           + ', @bIsDiscrete   BIT                   ' + CHAR(13)
                           + ', @bIsCustom     BIT                   ' + CHAR(13)
                           + ', @cPickSlipNo   NVARCHAR(10)          ' + CHAR(13)
                           + ', @cOrderKey     NVARCHAR(10)          ' + CHAR(13)
                           + ', @cLoadKey      NVARCHAR(10)          ' + CHAR(13)
                           + ', @cDropID       NVARCHAR(20)          ' + CHAR(13)
                           + ', @cStorerKey    NVARCHAR(15)          ' + CHAR(13)
                           + ', @cFacility     NVARCHAR(5)           ' + CHAR(13)  
                           + ', @c_UserID      NVARCHAR(256)         ' + CHAR(13)
                           + ', @cLangCode     NVARCHAR(3)           ' + CHAR(13)
                           + ', @cSkipSKUADScn NVARCHAR(1)    OUTPUT ' + CHAR(13)  
                           + ', @b_Success     INT            OUTPUT ' + CHAR(13)  
                           + ', @n_ErrNo       INT            OUTPUT ' + CHAR(13)  
                           + ', @c_ErrMsg      NVARCHAR(20)   OUTPUT ' + CHAR(13)

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
                           , @c_UserID
                           , @cLangCode
                           , @cConfigValue OUTPUT    
                           , @b_Success    OUTPUT    
                           , @n_ErrNo      OUTPUT    
                           , @c_ErrMsg     OUTPUT    

         IF @b_Success = 0    
         BEGIN    
            SET @n_Continue  = 3
            SET @n_ErrNo = @n_ErrNo    
            SET @c_ErrMsg = @c_ErrMsg    
            GOTO EXIT_SP    
         END    
      END

      IF @cConfigValue = '1'
      BEGIN
         GOTO EXIT_SP
      END
   END

   EXEC nspGetRight    
        @c_Facility  = @cFacility    
      , @c_StorerKey = @cStorerKey   
      , @c_sku       = ''    
      , @c_ConfigKey = 'TPS-SkipUCCADScn'    
      , @c_authority = @cAuthority        OUTPUT    
      , @b_Success   = @b_Success         OUTPUT
      , @n_err       = @n_ErrNo           OUTPUT
      , @c_errmsg    = @c_ErrMsg          OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue  = 3  
      GOTO EXIT_SP
   END

   IF @cAuthority = '1'
   AND @cScanType = 'ucc'
   BEGIN
      GOTO EXIT_SP
   END

   EXEC [API].[isp_TPACK_GetTotalADCount]
            @cType            = @cType            
         , @bIsDiscrete      = @bIsDiscrete      
         , @bIsCustom        = @bIsCustom        
         , @cPickSlipNo      = @cPickSlipNo       
         , @cOrderKey        = @cOrderKey
         , @cLoadKey         = @cLoadKey          
         , @cDropID          = @cDropID
         , @cStorerKey       = @cStorerKey        
         , @cFacility        = @cFacility   
         , @cInputValue1     = @cInputValue1
         , @cInputValue2     = @cInputValue2
         , @cInputValue3     = @cInputValue3
         , @cScanType        = @cScanType
         , @cSKU             = @cSKU
         , @nCartonNo        = @nCartonNo
         , @nQty             = @nQty
         , @c_UserID         = @c_UserID
         , @cLangCode        = @cLangCode
         , @nNumberOfADField = @nNumberOfADField   OUTPUT
         , @nDisplayADQty     = @nDisplayADQty     OUTPUT
         , @b_Success         = @b_Success         OUTPUT
         , @n_ErrNo           = @n_ErrNo           OUTPUT
         , @c_ErrMsg          = @c_ErrMsg          OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue  = 3    
         GOTO EXIT_SP
      END

   IF @nNumberOfADField >= 1
   BEGIN
      SET @bShowADScreen = 1
      SET @bGoToSearchSKU = 1
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
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [API].[isp_TPACK_ExtADOrSNCheck_Std] TO NSQL
GO
