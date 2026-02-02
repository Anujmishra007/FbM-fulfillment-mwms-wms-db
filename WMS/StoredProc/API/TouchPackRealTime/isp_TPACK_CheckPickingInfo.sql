SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_CheckPickingInfo                                   */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Check the picking info before start pack                     */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-18   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_CheckPickingInfo] (
     @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
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

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  

         , @cAutoScanOutWhenPack NVARCHAR(10)
         , @cAutoScanOutStatus   NVARCHAR(10)

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''
   SET @cAutoScanOutWhenPack  = ''
   SET @cAutoScanOutStatus    = ''
   
   IF NOT EXISTS (SELECT 1 
                  FROM PICKINGINFO (NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
   )
   BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM STORERCONFIG (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                     AND ConfigKey = 'AutoScanInWhenPack'
                     AND sValue = '1'
      )
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 10701    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Packing Cannot Be Done Without Scanning In Pickslips.'    
         GOTO EXIT_SP    
      END
   END

   IF NOT EXISTS ( SELECT 1 
               FROM STORERCONFIG (NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND ConfigKey = 'CheckPickB4Pack'
               AND sValue = '1'    
   )
   BEGIN
      GOTO EXIT_SP
   END

   SELECT @cAutoScanOutWhenPack = sValue
        , @cAutoScanOutStatus = Option1
   FROM STORERCONFIG (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND ConfigKey = 'AutoScanOutWhenPack'

   IF @cOrderKey = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 10702    
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No Orderkey Found.'    
      GOTO EXIT_SP    
   END

   IF @cAutoScanOutWhenPack <> '1'
   OR NOT EXISTS( SELECT 1 
               FROM ORDERS (NOLOCK)
               WHERE OrderKey = @cOrderKey
               AND [Status] > @cAutoScanOutStatus
   )
   BEGIN
      GOTO EXIT_SP
   END

   IF NOT EXISTS (SELECT 1
                  FROM PICKINGINFO (NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
   )
   BEGIN
      INSERT INTO PICKINGINFO (PickSlipNo, ScanInDate, PickerID)
      VALUES (@cPickSlipNo, GETDATE(), @c_UserID)

      IF @@ERROR <> 0    
      BEGIN    
         SET @n_Continue = 3
         SET @n_ErrNo = 10703    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Insert into PickingInfo.'    
         GOTO EXIT_SP    
      END 
   END
   ELSE
   BEGIN
      UPDATE PICKINGINFO WITH (ROWLOCK)
      SET  ScanInDate = GETDATE()
         , PickerID  = @c_UserID
      WHERE PickSlipNo = @cPickSlipNo

      IF @@ERROR <> 0    
      BEGIN    
         SET @n_Continue = 3
         SET @n_ErrNo = 10704    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update into PickingInfo.'    
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