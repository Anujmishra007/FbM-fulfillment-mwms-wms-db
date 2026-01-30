SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_API_GetCartonDetail                                */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Retrieve the carton detail from PackDetail and PackInfo      */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-22   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_API_GetCartonDetail] (
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
         , @cKeyboardVal         NVARCHAR(128)
         , @nCartonNo            INT
         , @cPickSlipNo          NVARCHAR(30)
         , @cOrderKey            NVARCHAR(10)
         , @cLoadKey             NVARCHAR(10)
         , @cDropID              NVARCHAR(30)
         , @cPackDetailList      NVARCHAR(MAX)
         , @nPageSize            INT
         , @nPageIndex           INT
         , @cSKUList             NVARCHAR(MAX)
         , @cScanType            NVARCHAR(20)
         , @bClickAll            BIT  
         , @bClickFirstOnly      BIT
   
   DECLARE @oSKUList TABLE (
      SKU NVARCHAR(20) PRIMARY KEY
   )

   DECLARE @oLoadKeySKUList TABLE (
      SKU NVARCHAR(20) PRIMARY KEY
   )

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = ''  
   SET @c_ResponseString   = '' 
   SET @bIsDiscrete        = 1
   SET @bIsCustom          = 0
   SET @cKeyboardVal       = ''
   SET @nCartonNo          = 0
   SET @cPickSlipNo        = ''
   SET @cOrderKey          = ''
   SET @cLoadKey           = ''
   SET @cDropID            = ''
   SET @cPackDetailList    = ''
   SET @nPageIndex         = 0
   SET @nPageSize          = 20
   SET @cSKUList           = ''
   SET @cScanType          = ''
   SET @bClickAll          = 0
   SET @bClickFirstOnly    = 1

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
         , @cLangCode            = cLangCode
         , @cPickSlipNo          = cPickSlipNo
         , @cOrderKey            = cOrderKey
         , @cLoadKey             = cLoadKey
         , @cDropID              = cDropID
         , @cStorerKey           = cStorerKey
         , @cFacility            = cFacility
         , @nCartonNo            = nCartonNo
         , @nPageIndex           = nPageIndex
   FROM OPENJSON(@c_RequestString)
   WITH (
         cType                NVARCHAR(30)
	    , bIsDiscrete          BIT
	    , bIsCustom            BIT
       , cPickSlipNo          NVARCHAR(30)
	    , cOrderKey            NVARCHAR(10)
       , cLoadKey             NVARCHAR(10)
       , cDropID              NVARCHAR(30)
       , cLangCode            NVARCHAR(3)
       , cStorerKey           NVARCHAR(15)
       , cFacility            NVARCHAR(5)
       , nCartonNo            INT
       , nPageIndex           INT
   )

   IF NOT EXISTS (SELECT 1
                  FROM PACKDETAIL (NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
                  AND CartonNo = @nCartonNo
                 )
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 11701      
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No PackDetail Records Found. '
      GOTO EXIT_SP   
   END

    --Check Multi SKU Selection
   EXEC [API].[isp_TPACK_CheckMultiSKUSelection]
         @cType             = @cType            
      , @bIsDiscrete       = @bIsDiscrete      
      , @bIsCustom         = @bIsCustom        
      , @cPickSlipNo       = @cPickSlipNo       
      , @cOrderKey         = @cOrderKey
      , @cLoadKey          = @cLoadKey          
      , @cDropID           = @cDropID
      , @cStorerKey        = @cStorerKey        
      , @cFacility         = @cFacility   
      , @cInputValue1      = @cKeyboardVal
      , @cInputValue2      = ''
      , @cInputValue3      = ''
      , @cScanType         = @cScanType
      , @c_UserID          = @c_UserID
      , @cLangCode         = @cLangCode
      , @bIsMultiSKU       = ''
      , @bClickAll         = @bClickAll         OUTPUT
      , @bClickFirstOnly   = @bClickFirstOnly   OUTPUT
      , @b_Success         = @b_Success         OUTPUT
      , @n_ErrNo           = @n_ErrNo           OUTPUT
      , @c_ErrMsg          = @c_ErrMsg          OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue = 3
      GOTO EXIT_SP
   END

   EXEC [API].[isp_TPACK_GetPackDetail]
        @cType             = @cType            
      , @bIsDiscrete       = @bIsDiscrete      
      , @bIsCustom         = @bIsCustom        
      , @cPickSlipNo       = @cPickSlipNo       
      , @cOrderKey         = @cOrderKey
      , @cLoadKey          = @cLoadKey          
      , @cDropID           = @cDropID
      , @cStorerKey        = @cStorerKey        
      , @cFacility         = @cFacility   
      , @cScanType         = @cScanType
      , @cSKUList          = @cSKUList
      , @c_UserID          = @c_UserID
      , @cLangCode         = @cLangCode
      , @nCartonNo         = @nCartonNo
      , @nPageIndex        = @nPageIndex
      , @nPageSize         = @nPageSize
      , @cLottableList     = '' 
      , @cPackDetailList   = @cPackDetailList   OUTPUT
      , @b_Success         = @b_Success         OUTPUT
      , @n_ErrNo           = @n_ErrNo           OUTPUT
      , @c_ErrMsg          = @c_ErrMsg          OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue = 3
      GOTO EXIT_SP
   END

   SET @c_ResponseString = ISNULL ((SELECT 
                                     JSON_QUERY((SELECT  @cScanType           AS cScanType
                                                       , @bClickAll           AS bClickAll
                                                       , @bClickFirstOnly     AS bClickFirstOnly
                                                       , CAST(0 AS BIT)       AS bShowADScreen
                                                       , CAST(0 AS BIT)       AS bShowLottableScreen
                                                       , CAST(0 AS BIT)       AS bAutoCloseCarton
                                                       , @nCartonNo           AS nCartonNo
                                                       , 0                    AS nNumberOfADField
                                                       , 0                    AS nDisplayADQty
                                                       , 0                    AS nActualQty
                                     FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                                    )) AS meta
                                  , JSON_QUERY(CASE WHEN ISJSON(@cPackDetailList) = 1
                                                      THEN @cPackDetailList
                                                      ELSE '[]'
                                                      END) AS cPackDetailList
                                  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                           ),'')

EXIT_SP:
   IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'lsp_RevertUser' AND type = 'P') AND SESSION_CONTEXT(N'mwms_user_name') IS NOT NULL
   BEGIN
      EXEC [WM].[lsp_RevertUser]
   END

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