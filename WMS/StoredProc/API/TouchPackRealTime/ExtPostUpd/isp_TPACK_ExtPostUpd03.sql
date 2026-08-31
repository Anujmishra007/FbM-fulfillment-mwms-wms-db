SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtPostUpd03                                       */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-07-13   1.0  JWF011     FCR-14190: Created                               */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtPostUpd03] (
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
   
   DECLARE @cPickDetailKey       NVARCHAR(10)  = ''
         , @cOrderLineNumber     NVARCHAR(5)  = ''

   SET @b_Success    = 0  
   SET @n_ErrNo      = 0  
   SET @c_ErrMsg     = ''
      
   DECLARE CURSOR_PID CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT PID.PickDetailKey
         ,PID.OrderLineNumber
   FROM PICKDETAIL PID (NOLOCK)
   WHERE PID.StorerKey = @cStorerKey
   AND PID.OrderKey = @cOrderKey
   AND NOT EXISTS (  SELECT 1
                     FROM RefKeyLookup RK(NOLOCK)
                     WHERE RK.PickDetailKey = PID.PickDetailKey
                     AND RK.PickSlipNo = @cPickSlipNo
   )

   OPEN CURSOR_PID
   FETCH NEXT FROM CURSOR_PID INTO @cPickDetailKey, @cOrderLineNumber
   WHILE @@FETCH_STATUS = 0
   BEGIN
      IF @cLoadKey = ''
      BEGIN
         SET @cLoadKey = ISNULL((SELECT TOP 1 LoadKey
                                 FROM RefKeyLookup (NOLOCK)
                                 WHERE PickSlipNo = @cPickSlipNo
                              ), ''
         )
      END

      INSERT INTO RefKeyLookup (
          PickDetailKey
         ,PickSlipNo
         ,OrderKey
         ,OrderLineNumber
         ,LoadKey
      ) VALUES (
          @cPickDetailKey
         ,@cPickSlipNo
         ,@cOrderKey
         ,@cOrderLineNumber
         ,@cLoadKey
      )
      IF @@ERROR <> 0
      BEGIN  
         SET @n_Continue = 3  
         SET @n_ErrNo = 16251    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Insert into RefKeyLookup.'  
         GOTO EXIT_SP  
      END
      FETCH NEXT FROM CURSOR_PID INTO @cPickDetailKey, @cOrderLineNumber
   END
   CLOSE CURSOR_PID
   DEALLOCATE CURSOR_PID

   UPDATE PICKDETAIL
   SET [Status] = '5'
   WHERE StorerKey = @cStorerKey
   AND OrderKey = @cOrderKey
   IF @@ERROR <> 0
   BEGIN  
      SET @n_Continue = 3  
      SET @n_ErrNo = 16252    
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update PICKDETAIL Status.'  
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
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [API].[isp_TPACK_ExtPostUpd03] TO NSQL
GO