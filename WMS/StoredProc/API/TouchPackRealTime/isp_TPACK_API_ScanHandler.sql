SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_API_ScanHandler                                    */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Perform checking by barcode scanner input                    */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-01   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_API_ScanHandler] (
     @b_Debug           INT            = 0  
   , @c_Format          VARCHAR(10)    = ''  
   , @c_UserID          NVARCHAR(256)  = ''  
   , @c_OperationType   NVARCHAR(60)   = ''  
   , @c_RequestString   NVARCHAR(MAX)  = ''  
   , @b_Success         INT            = 0   OUTPUT  
   , @n_ErrNo           INT            = 0   OUTPUT  
   , @c_ErrMsg          NVARCHAR(250)  = ''  OUTPUT  
   , @c_ResponseString  NVARCHAR(MAX)  = ''  OUTPUT  
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  
         , @b_sp_Success         INT  
         , @n_sp_err             INT  
         , @c_sp_errmsg          NVARCHAR(250)  = ''
         , @DBUserName           NVARCHAR(100)
         , @b_sp_ExecuteAs       BIT

   DECLARE @cType                NVARCHAR(30)
         , @bIsDiscrete          BIT
         , @bIsCustom            BIT
         , @cLangCode            NVARCHAR(3)
         , @cStorerKey           NVARCHAR(15)
         , @cFacility            NVARCHAR(5)
         , @cScannerVal          NVARCHAR(128)
         , @nCartonNo            INT
         , @cPickSlipNo          NVARCHAR(10)
         , @cOrderKey            NVARCHAR(10)
         , @cLoadKey             NVARCHAR(10)
         , @cDropID              NVARCHAR(20)
         , @cResponseJson        NVARCHAR(MAX)

   SET @b_Success           = 0  
   SET @n_ErrNo             = 0  
   SET @c_ErrMsg            = ''  
   SET @c_ResponseString    = '' 
   SET @bIsDiscrete         = 1
   SET @bIsCustom           = 0
   SET @cScannerVal         = ''
   SET @nCartonNo           = 0
   SET @cPickSlipNo         = ''
   SET @cOrderKey           = ''
   SET @cLoadKey            = ''
   SET @cDropID             = ''
   SET @cResponseJson       = ''

   EXEC [API].[isp_ECOMP_ValidateAndSetUser]
        @c_UserID      = @c_UserID
      , @c_DBUserName  = @DBUserName OUTPUT
      , @b_ExecuteAs   = @b_sp_ExecuteAs OUTPUT
      , @b_Success     = @b_sp_Success OUTPUT
      , @n_ErrNo       = @n_sp_err OUTPUT
      , @c_ErrMsg      = @c_sp_errmsg OUTPUT

   IF @b_sp_Success = 0
   BEGIN    
      SET @n_Continue = 3
      SET @n_ErrNo = @n_sp_err      
      SET @c_ErrMsg = @c_sp_errmsg     
      GOTO EXIT_SP
   END

   IF @b_sp_ExecuteAs = 1 OR @DBUserName LIKE '%' + @c_UserID + '%'
   BEGIN
      EXECUTE AS LOGIN = @DBUserName
      SET @c_UserID = @DBUserName

      IF OBJECT_ID('dbo.fnc_GetUserName', 'FN') IS NOT NULL
      BEGIN
         IF dbo.fnc_GetUserName() NOT IN ('WMConnect', '')
         BEGIN
            SET @c_UserID = dbo.fnc_GetUserName()
         END
      END
   END

   SELECT  @cType                = cType
         , @bIsDiscrete          = bIsDiscrete
         , @bIsCustom            = bIsCustom
         , @cPickSlipNo          = cPickSlipNo
         , @cOrderKey            = cOrderKey
         , @cLoadKey             = cLoadKey
         , @cDropID              = cDropID
         , @cLangCode            = cLangCode
         , @cStorerKey           = cStorerKey
         , @cFacility            = cFacility
         , @cScannerVal          = cScannerVal
         , @nCartonNo            = nCartonNo
   FROM OPENJSON(@c_RequestString)
   WITH (
         cType                NVARCHAR(30)
	    , bIsDiscrete          BIT
	    , bIsCustom            BIT
       , cPickSlipNo          NVARCHAR(10)
	    , cOrderKey            NVARCHAR(10)
       , cLoadKey             NVARCHAR(10)
       , cDropID              NVARCHAR(20)
       , cLangCode            NVARCHAR(3)
       , cStorerKey           NVARCHAR(15)
       , cFacility            NVARCHAR(5)
       , cScannerVal          NVARCHAR(128)
       , nCartonNo            INT
   )

   --Validate Standard Request Payload
   EXEC [API].[isp_TPACK_ValidateReqPayload]
        @cType             = @cType            
      , @bIsDiscrete       = @bIsDiscrete      
      , @bIsCustom         = @bIsCustom        
      , @cPickSlipNo       = @cPickSlipNo       
      , @cOrderKey         = @cOrderKey
      , @cLoadKey          = @cLoadKey          
      , @cDropID           = @cDropID
      , @cStorerKey        = @cStorerKey        
      , @cFacility         = @cFacility   
      , @cInputValue1      = @cScannerVal
      , @cInputValue2      = ''
      , @cInputValue3      = ''
      , @cScanType         = ''
      , @cSKU              = ''
      , @nCartonNo         = @nCartonNo
      , @nQty              = 1
      , @c_UserID          = @c_UserID
      , @cLangCode         = @cLangCode
      , @nPageIndex        = 0
      , @nPageSize         = 20
      , @b_Success         = @b_Success   OUTPUT
      , @n_ErrNo           = @n_ErrNo     OUTPUT
      , @c_ErrMsg          = @c_ErrMsg    OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue = 3  
      GOTO EXIT_SP
   END

   --Validate User Input
   EXEC [API].[isp_TPACK_ValidateUserInput]
        @cType             = @cType            
      , @bIsDiscrete       = @bIsDiscrete      
      , @bIsCustom         = @bIsCustom        
      , @cPickSlipNo       = @cPickSlipNo       
      , @cOrderKey         = @cOrderKey
      , @cLoadKey          = @cLoadKey          
      , @cDropID           = @cDropID
      , @cStorerKey        = @cStorerKey        
      , @cFacility         = @cFacility   
      , @cInputValue1      = @cScannerVal
      , @cInputValue2      = ''
      , @cInputValue3      = ''
      , @cScanType         = ''
      , @cSKU              = ''
      , @nCartonNo         = @nCartonNo
      , @nQty              = 1
      , @c_UserID          = @c_UserID
      , @cLangCode         = @cLangCode
      , @nPageIndex        = 0
      , @nPageSize         = 20
      , @c_OperationType   = @c_OperationType
      , @cResponseJson     = @cResponseJson  OUTPUT
      , @b_Success         = @b_Success      OUTPUT
      , @n_ErrNo           = @n_ErrNo        OUTPUT
      , @c_ErrMsg          = @c_ErrMsg       OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue = 3  
      GOTO EXIT_SP
   END

   SET @c_ResponseString = ISNULL ((JSON_QUERY(CASE WHEN ISJSON(@cResponseJson) = 1
                                                      THEN @cResponseJson
                                                      ELSE '{}'
                                                      END)
                                    ),'')
EXIT_SP:
   IF @b_sp_ExecuteAs = 1 REVERT
   EXEC [WM].[lsp_ResetUser]

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