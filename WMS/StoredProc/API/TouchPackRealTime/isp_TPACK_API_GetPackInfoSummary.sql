SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_API_GetPackInfoSummary                             */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get all the pack task info from pickdetail & packinfo        */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-06   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_API_GetPackInfoSummary] (
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
         , @cPackInfoJson        NVARCHAR(MAX)


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
   SET @nCartonNo             = ''
   SET @cPackInfoJson         = ''

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
   )

   --Get the PackInfo Summary
   EXEC [API].[isp_TPACK_GetPackInfoSummary]
        @cType              = @cType            
      , @bIsDiscrete        = @bIsDiscrete      
      , @bIsCustom          = @bIsCustom        
      , @cPickSlipNo        = @cPickSlipNo       
      , @cLoadKey           = @cLoadKey          
      , @cOrderKey          = @cOrderKey         
      , @cDropID            = @cDropID    
      , @cStorerKey         = @cStorerKey
      , @cFacility          = @cFacility
      , @nCartonNo          = @nCartonNo
      , @c_UserID           = @c_UserID
      , @cLangCode          = @cLangCode
      , @cPackInfoJson      = @cPackInfoJson OUTPUT
      , @b_Success          = @b_Success     OUTPUT
      , @n_ErrNo            = @n_ErrNo       OUTPUT
      , @c_ErrMsg           = @c_ErrMsg      OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3   
      GOTO EXIT_SP
   END

   SET @c_ResponseString = ISNULL ((IIF(ISJSON(@cPackInfoJson) = 1, @cPackInfoJson, '{}')
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