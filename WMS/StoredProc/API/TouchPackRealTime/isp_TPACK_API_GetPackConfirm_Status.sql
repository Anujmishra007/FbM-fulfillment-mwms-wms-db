SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_API_GetPackConfirm_Status                          */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get Pack Confirm Status                                      */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-07-20   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_API_GetPackConfirm_Status] (
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

   DECLARE @n_Continue              INT            = 1  
         , @n_StartCnt              INT            = @@TRANCOUNT  
         , @b_sp_Success            INT  
         , @n_sp_err                INT  
         , @c_sp_errmsg             NVARCHAR(250)  = ''
         , @DBUserName              NVARCHAR(100)
         , @b_sp_ExecuteAs          BIT

   DECLARE @cType                   NVARCHAR(30)
         , @bIsDiscrete             BIT
         , @bIsCustom               BIT
         , @cLangCode               NVARCHAR(3)
         , @cPickSlipNo             NVARCHAR(10)
         , @cOrderKey               NVARCHAR(10)
         , @cLoadKey                NVARCHAR(10)
         , @cDropID                 NVARCHAR(20)
         , @cStorerKey              NVARCHAR(15)
         , @cFacility               NVARCHAR(5)
         , @nCartonNo               INT
         , @bIsAutoTriggered        BIT
         , @bConfirmCloseAllFlag    BIT

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
   SET @bIsAutoTriggered      = 0
   SET @bConfirmCloseAllFlag  = 0

   --Decode Json Format
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
         , @nCartonNo            = nCartonNo
         , @bIsAutoTriggered     = bIsAutoTriggered
         , @bConfirmCloseAllFlag = bConfirmCloseAllFlag
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
       , bIsAutoTriggered     BIT
       , bConfirmCloseAllFlag BIT
   )

   IF EXISTS ( SELECT 1      
               FROM PACKHEADER (NOLOCK)       
               WHERE PickSlipNo = @cPickSlipNo
               AND [Status] = '9'
   )      
   BEGIN      
      SET @b_Success =1      
   END      

	SET @c_ResponseString = ISNULL((SELECT CAST ( @b_Success AS BIT ) AS 'Success' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                           ), '') 

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [API].[isp_TPACK_API_GetPackConfirm_Status] TO NSQL
GO