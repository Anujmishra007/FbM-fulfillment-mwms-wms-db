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
/* 2026-02-06   2.0  GCH225     UWP-48119: 1 tote, 1 carton, 1 sku Scenario      */
/* 2026-03-16   2.1  GCH225     FCR-11632: Check AuditLog with Status PENDAUDIT  */
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
         , @bAutoCloseCarton     BIT
         , @nLabelLineCount      INT
         , @nTtlQty              INT
         , @cSKU                 NVARCHAR(20)
         , @nExpQty              INT
         , @nActualQty           INT
         , @cResponseJson        NVARCHAR(MAX)
   
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
   SET @bAutoCloseCarton   = 0
   SET @nLabelLineCount    = 0
   SET @nTtlQty            = 0
   SET @cSKU               = ''
   SET @nExpQty            = 0
   SET @nActualQty         = 0
   SET @cResponseJson      = ''

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

   -- one row count means only 1 carton case scenario only perform auto close carton.
   -- pre-cartonization case only can proceed.
   -- single SKU only proceed
   -- Qty in packdetail is zero only proceed
   -- DocType is not 'E' in Order table only proceed

   IF EXISTS ( SELECT 1 
               FROM STORERCONFIG (NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND ConfigKey = 'TPS-AutoCloseCarton'
               AND sValue = '1'
   ) AND NOT EXISTS (SELECT 1 
                     FROM PACKINFO_AUDITLOG (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                     AND CartonNo = @nCartonNo
                     AND CartonStatus = 'PENDAUDIT'
   )
   BEGIN
      SELECT  @nExpQty = ISNULL(SUM(ExpQty), 0)
            , @nTtlQty = ISNULL(SUM(Qty), 0)
            , @nLabelLineCount = COUNT(DISTINCT LabelLine)
            , @cSKU = MAX(SKU)
      FROM PACKDETAIL (NOLOCK) 
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND DropID = @cDropID

      SELECT 1
      FROM PACKINFO (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND CartonStatus = 'INPROGRESS'

      IF @@ROWCOUNT = 1  
      AND @nExpQty > 0
      AND @nTtlQty = 0  
      AND @nLabelLineCount = 1 
      AND EXISTS (SELECT 1 
                  FROM ORDERS (NOLOCK)
                  WHERE OrderKey = @cOrderKey
                  AND DocType <> 'E'
      )
      BEGIN 
         SET @bAutoCloseCarton = 1
         SET @nActualQty = @nExpQty
         IF NOT EXISTS (SELECT 1
                        FROM STORERCONFIG (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                        AND ConfigKey = 'TPS-VAS'
                        AND sValue IN ('1', '3')
         )
         BEGIN
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
               , @cInputValue1      = @cSKU
               , @cInputValue2      = ''
               , @cInputValue3      = ''
               , @cScanType         = 'sku'
               , @cSKU              = @cSKU
               , @nCartonNo         = @nCartonNo
               , @nQty              = @nActualQty
               , @c_UserID          = @c_UserID
               , @cLangCode         = @cLangCode
               , @nPageIndex        = 0
               , @nPageSize         = 20
               , @c_OperationType   = @c_OperationType
               , @cResponseJson     = @cResponseJson OUTPUT
               , @b_Success         = @b_Success     OUTPUT
               , @n_ErrNo           = @n_ErrNo       OUTPUT
               , @c_ErrMsg          = @c_ErrMsg      OUTPUT

            IF @b_Success = 0
            BEGIN    
               SET @n_Continue = 3  
               GOTO EXIT_SP
            END
            
            IF (TRY_CAST(JSON_VALUE(@cResponseJson, '$.meta.bAutoCloseCarton') AS BIT) = 0 
            AND TRY_CAST(JSON_VALUE(@cResponseJson, '$.meta.bShowLottableScreen') AS BIT) = 0
            )
            BEGIN
               SET @cResponseJson = JSON_MODIFY(@cResponseJson, '$.meta.bAutoCloseCarton', @bAutoCloseCarton);
            END
            
            SET @c_ResponseString = ISNULL ((JSON_QUERY(@cResponseJson)),'')
            GOTO EXIT_SP
         END
      END
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
                                                       , @bAutoCloseCarton    AS bAutoCloseCarton
                                                       , @nCartonNo           AS nCartonNo
                                                       , 0                    AS nNumberOfADField
                                                       , 0                    AS nDisplayADQty
                                                       , @nActualQty          AS nActualQty
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