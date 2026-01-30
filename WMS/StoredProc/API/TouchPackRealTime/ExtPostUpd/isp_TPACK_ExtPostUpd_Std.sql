SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtPostUpd_Std                                     */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Extended Post Update Standard SP                             */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-11-13   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtPostUpd_Std] (
	  @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @nCartonNo            INT               = 0
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
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

   DECLARE @n_Continue     INT            = 1  
         , @n_StartCnt     INT            = @@TRANCOUNT  

   SET @b_Success    = 0  
   SET @n_ErrNo      = 0  
   SET @c_ErrMsg     = ''

   IF EXISTS(SELECT 1 
             FROM STORERCONFIG (NOLOCK)
             WHERE StorerKey = @cStorerKey
             AND ConfigKey = 'TPS-VAS'
             AND sValue IN ('1','3')
   ) AND @cOrderKey <> ''
   AND @bIsDiscrete = 1
   BEGIN

      UPDATE WORKORDER
      SET [Status] = '9'
      WHERE ExternWorkOrderKey = @cOrderKey
      AND StorerKey = @cStorerKey
      AND Facility = @cFacility
      AND [Type] IN ('PACK','VAS')

      IF @@ERROR <> 0  
      BEGIN  
         SET @n_Continue = 3  
         SET @n_ErrNo = 13451    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the WorkOrder Status.'  
         GOTO EXIT_SP  
      END 
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

