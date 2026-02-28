SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_ValidateReqPayload                                 */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Validate Standard Request Payload and ensure all the data    */
/*                  flow in are correct.                                         */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-22   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_ValidateReqPayload] (
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
   , @nPageIndex           INT               = 0
   , @nPageSize            INT               = 0
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

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  

   IF @cPickSlipNo = ''
   BEGIN
      SET @n_Continue  = 3
      SET @n_ErrNo = 11651
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'@cPickSlipNo cannot be empty in pickslip cType.'
      GOTO EXIT_SP
   END

   IF EXISTS ( SELECT 1 
               FROM PACKHEADER (NOLOCK) 
               WHERE PickSlipNo = @cPickSlipNo 
               AND [Status] = '9'
   )
   BEGIN
      SET @n_Continue  = 3
      SET @n_ErrNo = 11652
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Current pickslip already pack confirm.'
      GOTO EXIT_SP
   END

   IF @cType = 'order'
   BEGIN
      IF @bIsDiscrete <> 1
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 11653
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Consolidated order is not allow with order cType.  '
         GOTO EXIT_SP
      END

      --IF @bIsCustom = 1
      --BEGIN
      --   SET @n_Continue  = 3
      --   SET @n_ErrNo = 11654
      --   SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Order cType is not allow with IsCustom flag is true.  '
      --   GOTO EXIT_SP
      --END

      IF @cOrderKey = ''
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 11655
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'@cOrderKey cannot be empty in order cType.  '
         GOTO EXIT_SP
      END
   END
   ELSE IF @cType = 'pickslip'
   BEGIN
      IF @bIsDiscrete = 1
      BEGIN
         IF @bIsCustom = 1
         BEGIN
            SET @n_Continue  = 3
            SET @n_ErrNo = 11656
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Pickslip cType is not allow with IsDiscrete and IsCustom flag are true.  '
            GOTO EXIT_SP
         END
         ELSE
         BEGIN
            IF @cOrderKey = ''
            BEGIN
               SET @n_Continue  = 3
               SET @n_ErrNo = 11657
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'@cOrderKey cannot be empty in pickslip cType.  '
               GOTO EXIT_SP
            END
         END
      END
      ELSE
      BEGIN
         IF @bIsCustom = 0
         BEGIN
            IF @cLoadKey = ''
            BEGIN
               SET @n_Continue  = 3
               SET @n_ErrNo = 11658
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'@cLoadKey cannot be empty in pickslip cType.  '
               GOTO EXIT_SP
            END
         END
      END
   END
   ELSE IF @cType = 'toteid'
   BEGIN
      IF @bIsDiscrete <> 1
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 11659
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Consolidated toteId is not allow with toteid cType.  '
         GOTO EXIT_SP
      END

      --IF @bIsCustom = 1
      --BEGIN
      --   SET @n_Continue  = 3
      --   SET @n_ErrNo = 11660
      --   SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Toteid cType is not allow with IsCustom flag is true.  '
      --   GOTO EXIT_SP
      --END

      IF @cDropID = ''
      BEGIN     
         SET @n_Continue  = 3
         SET @n_ErrNo = 11661
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'@cDropID cannot be empty in toteid cType.  '
         GOTO EXIT_SP
      END

      IF @cOrderKey = ''
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 11662
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'@cOrderKey cannot be empty in toteid cType.  '
         GOTO EXIT_SP
      END
   END
   ELSE
   BEGIN
      SET @n_Continue  = 3
      SET @n_ErrNo = 11663
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Unknown ctype Detected.  '
      GOTO EXIT_SP
   END

EXIT_SP:
   IF @n_Continue= 3  -- Error Occured - Process And Return      
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