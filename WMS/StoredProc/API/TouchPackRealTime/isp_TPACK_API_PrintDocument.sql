SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_API_PrintDocument                                  */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Print Label and Paper Function                               */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-09-08   1.0  GCH225     Created                                          */
/* 2026-01-23   1.1  YLI237     Modify for UWP-45422                             */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_API_PrintDocument] (
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
         , @cPickSlipNo          NVARCHAR(10)
         , @cOrderKey            NVARCHAR(10)
         , @cLoadKey             NVARCHAR(10)
         , @cDropID              NVARCHAR(20)
         , @cStorerKey           NVARCHAR(15)
         , @cFacility            NVARCHAR(5)
         , @nCartonNo            INT
         , @bIsLastCarton        BIT
         , @bPrintLabelFlag      BIT
         , @bPrintPaperFlag      BIT
         , @cPrintLabelJobIDs    NVARCHAR(MAX)
         , @cPrintPaperJobIDs    NVARCHAR(MAX)
         , @cLabelPrinter        NVARCHAR(10)
         , @cPaperPrinter        NVARCHAR(10)
         , @oPrintConfigJson     NVARCHAR(MAX)
         , @bIsAutoPrint         BIT
         , @nCopy                INT
         , @cSKU                 NVARCHAR(20)


   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  
   SET @c_ResponseString      = '' 
   SET @bIsDiscrete           = 1
   SET @bIsCustom             = 0
   SET @cLangCode             = ''
   SET @cPickSlipNo           = ''
   SET @cOrderKey             = ''
   SET @cLoadKey              = ''
   SET @cDropID               = ''
   SET @cStorerKey            = ''
   SET @cFacility             = ''
   SET @nCartonNo             = 0
   SET @bIsLastCarton         = 0
   SET @bPrintLabelFlag       = 0
   SET @bPrintPaperFlag       = 0
   SET @cPrintLabelJobIDs     = ''
   SET @cPrintPaperJobIDs     = ''
   SET @cLabelPrinter         = ''
   SET @cPaperPrinter         = ''
   SET @oPrintConfigJson      = ''
   SET @bIsAutoPrint          = 0
   SET @nCopy                 = 1
   SET @cSKU                  = ''


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

   --Decode Json Format
   SELECT  @cType             = cType
         , @bIsDiscrete       = bIsDiscrete
         , @bIsCustom         = bIsCustom
         , @cPickSlipNo       = cPickSlipNo
         , @cOrderKey         = cOrderKey
         , @cLoadKey          = cLoadKey
         , @cDropID           = cDropID
         , @cLangCode         = cLangCode
         , @cStorerKey        = cStorerKey
         , @cFacility         = cFacility
         , @nCartonNo         = nCartonNo
         , @bIsLastCarton     = bIsLastCarton
         , @bPrintPaperFlag   = bPrintPaperFlag
         , @bPrintLabelFlag   = bPrintLabelFlag
         , @cLabelPrinter     = cLabelPrinter
         , @cPaperPrinter     = cPaperPrinter
         , @oPrintConfigJson  = CASE 
                                    WHEN oPrintConfigJson IS NULL THEN ''
                                    WHEN oPrintConfigJson IN ('{}', '[]') THEN ''
                                    ELSE oPrintConfigJson
                                END
         , @bIsAutoPrint      = bIsAutoPrint
         , @nCopy             = nCopy
         , @cSKU              = cSKU
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
       , nCartonNo            INT
       , bIsLastCarton        BIT
       , bPrintPaperFlag      BIT
       , bPrintLabelFlag      BIT
       , cLabelPrinter        NVARCHAR(30)  
       , cPaperPrinter        NVARCHAR(30)
       , oPrintConfigJson     NVARCHAR(MAX) AS JSON
       , bIsAutoPrint         BIT
       , nCopy                INT
       , cSKU                 NVARCHAR(20)
   )

   IF @cPickSlipNo = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 11751
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'PickSlipNo cannot be empty.'
      GOTO EXIT_SP
   END

   -- IF @nCartonNo = 0 AND @isSKUScan <> 1
   -- BEGIN
   --    SET @n_Continue = 3
   --    SET @n_ErrNo = 11752
   --    SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'CartonNo cannot be empty.'
   --    GOTO EXIT_SP
   -- END

   EXEC [API].[isp_TPACK_PrintDocument_Wrapper]
     @cType                = @cType            
   , @bIsDiscrete          = @bIsDiscrete      
   , @bIsCustom            = @bIsCustom        
   , @cPickSlipNo          = @cPickSlipNo       
   , @cOrderKey            = @cOrderKey         
   , @cLoadKey             = @cLoadKey          
   , @cDropID              = @cDropID           
   , @cStorerKey           = @cStorerKey        
   , @cFacility            = @cFacility         
   , @nCartonNo            = @nCartonNo
   , @c_UserID             = @c_UserID
   , @cLangCode            = @cLangCode
   , @bIsLastCarton        = @bIsLastCarton
   , @bPrintLabelFlag      = @bPrintLabelFlag
   , @bPrintPaperFlag      = @bPrintPaperFlag
   , @cLabelPrinter        = @cLabelPrinter
   , @cPaperPrinter        = @cPaperPrinter
   , @oPrintConfigJson     = @oPrintConfigJson
   , @bIsAutoPrint         = @bIsAutoPrint
   , @nCopy                = @nCopy
   , @cSKU                 = @cSKU
   , @cPrintLabelJobIDs    = @cPrintLabelJobIDs OUTPUT
   , @cPrintPaperJobIDs    = @cPrintPaperJobIDs OUTPUT
   , @b_Success            = @b_Success         OUTPUT
   , @n_ErrNo              = @n_ErrNo           OUTPUT
   , @c_ErrMsg             = @c_ErrMsg          OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3  
      
      IF @n_ErrNo = 0
      BEGIN
         SET @n_ErrNo = 11753
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + @c_ErrMsg --'Print document failed.'
      END
      GOTO EXIT_SP
   END

   SET @c_ResponseString = ISNULL ((SELECT CAST(@b_Success AS BIT)   AS Success 
                                         , @cPrintLabelJobIDs     AS PrintLabelJobIDs
                                         , @cPrintPaperJobIDs     AS PrintPaperJobIDs
                                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                           ),'')

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