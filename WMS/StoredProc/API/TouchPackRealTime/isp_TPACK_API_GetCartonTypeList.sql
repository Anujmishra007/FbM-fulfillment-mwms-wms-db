SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_API_GetCartonTypeList                              */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get the list of carton type for specific storer              */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-01   1.0  GCH225     Created                                          */
/* 2026-02-05   2.0  GCH225     UWP-48097: Recommended CartonType from PackInfo  */
/* 2026-05-07   3.0  GCH225     UWP-55973: Wrapper to support custom and standard*/
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_API_GetCartonTypeList] (
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

   DECLARE @n_Continue     INT            = 1  
         , @n_StartCnt     INT            = @@TRANCOUNT  
         , @b_sp_Success   INT  
         , @n_sp_err       INT  
         , @c_sp_errmsg    NVARCHAR(250)  = ''
         , @DBUserName     NVARCHAR(100)
         , @b_sp_ExecuteAs BIT

   DECLARE @cType       NVARCHAR(30)
         , @bIsDiscrete BIT
         , @bIsCustom   BIT
         , @cLangCode   NVARCHAR(3)
         , @cPickSlipNo NVARCHAR(10)
         , @cOrderKey   NVARCHAR(10)
         , @cLoadKey    NVARCHAR(10)
         , @cDropID     NVARCHAR(20)
         , @cStorerKey  NVARCHAR(15)
         , @cFacility   NVARCHAR(5)
         , @nCartonNo   INT

   SET @b_Success        = 0  
   SET @n_ErrNo          = 0  
   SET @c_ErrMsg         = ''  
   SET @c_ResponseString = '' 
   SET @bIsDiscrete      = 1
   SET @bIsCustom        = 0
   SET @cLangCode        = ''
   SET @cPickSlipNo      = ''
   SET @cOrderKey        = ''
   SET @cLoadKey         = ''
   SET @cDropID          = ''
   SET @cStorerKey       = ''
   SET @cFacility        = ''
   SET @nCartonNo        = 0

   --Decode Json Format
   SELECT  @cType       = cType
         , @bIsDiscrete = bIsDiscrete
         , @bIsCustom   = bIsCustom
         , @cPickSlipNo = cPickSlipNo
         , @cOrderKey   = cOrderKey
         , @cLoadKey    = cLoadKey
         , @cDropID     = cDropID
         , @cLangCode   = cLangCode
         , @cStorerKey  = cStorerKey
         , @cFacility   = cFacility
         , @nCartonNo   = nCartonNo
   FROM OPENJSON(@c_RequestString)
   WITH (
        cType       NVARCHAR(30)
	   , bIsDiscrete BIT
      , bIsCustom   BIT
      , cPickSlipNo NVARCHAR(10)      
      , cOrderKey   NVARCHAR(10)
      , cLoadKey    NVARCHAR(10)      
      , cDropID     NVARCHAR(20)
      , cLangCode   NVARCHAR(3)
      , cStorerKey  NVARCHAR(15)
      , cFacility   NVARCHAR(5)
      , nCartonNo   INT
   )

   EXEC [API].[isp_TPACK_GetCartonType_Wrapper]
     @cType             = @cType            
   , @bIsDiscrete       = @bIsDiscrete      
   , @bIsCustom         = @bIsCustom        
   , @cPickSlipNo       = @cPickSlipNo       
   , @cOrderKey         = @cOrderKey         
   , @cLoadKey          = @cLoadKey          
   , @cDropID           = @cDropID           
   , @cStorerKey        = @cStorerKey        
   , @cFacility         = @cFacility  
   , @c_UserID          = @c_UserID
   , @cLangCode         = @cLangCode
   , @nCartonNo         = @nCartonNo
   , @c_ResponseString  = @c_ResponseString  OUTPUT
   , @b_Success         = @b_Success         OUTPUT
   , @n_ErrNo           = @n_ErrNo           OUTPUT
   , @c_ErrMsg          = @c_ErrMsg          OUTPUT

   IF @b_Success = 0 OR ISNULL(@c_ResponseString, '') = ''
   BEGIN
      SET @n_Continue = 3  
      GOTO EXIT_SP
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
      SET @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END
