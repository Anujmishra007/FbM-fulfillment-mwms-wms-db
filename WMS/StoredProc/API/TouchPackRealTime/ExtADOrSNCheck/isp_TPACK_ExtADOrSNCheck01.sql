SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtADOrSNCheck01                                   */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Custom AD or SN Check for Logitech                           */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-08-21   1.0  GCH225     UWP-61712: Created                               */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtADOrSNCheck01] (
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

   IF ISJSON(@cInputValue2) = 1
   AND EXISTS (SELECT 1 FROM OPENJSON(@cInputValue2))
   BEGIN
      GOTO EXIT_SP
   END

   IF NOT EXISTS ( SELECT 1 
                  FROM SKU (NOLOCK) 
                  WHERE StorerKey = @cStorerKey
                  AND SKU = @cSKU
                  AND BUSR7 = 'Yes'
   )
   BEGIN
      GOTO EXIT_SP
   END

   SET @bShowADScreen = 1
   SET @bGoToSearchSKU = 1
   SET @nDisplayADQty = 1

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
GRANT EXECUTE ON [API].[isp_TPACK_ExtADOrSNCheck01] TO NSQL
GO
