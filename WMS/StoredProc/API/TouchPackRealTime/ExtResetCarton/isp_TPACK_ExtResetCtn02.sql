SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtResetCtn02                                      */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Custom Reset Carton Function                                 */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-12-10   1.0  Sean     Cloned from isp_TPS_ResetCtnP02 (TPS-906)          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtResetCtn02] (
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
   , @bResetAll            BIT               = 0
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
   
   DECLARE @cSerialNo            NVARCHAR(50)
         , @cSKU                 NVARCHAR(20)
         , @cUCCNo               NVARCHAR(20)
         , @cCurOrderKey         NVARCHAR(10)
         , @bDeleteSerialNo      BIT

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 
   SET @bDeleteSerialNo    = 0

   -- Check ADAllowInsertExistingSerialNo config
   IF EXISTS (SELECT 1 
              FROM STORERCONFIG (NOLOCK)
              WHERE StorerKey = @cStorerKey
              AND ConfigKey = 'ADAllowInsertExistingSerialNo'
              AND Option1 = ''
   )
   BEGIN
      SET @bDeleteSerialNo = 1
   END

   BEGIN TRAN

   IF @bResetAll = 1
   BEGIN
      -- Reset SerialNo by PickSlipNo
      IF EXISTS (SELECT 1  
                 FROM SERIALNO (NOLOCK)  
                 WHERE PickSlipNo = @cPickSlipNo    
                 AND StorerKey = @cStorerKey 
                 AND [Status] < '6'
      )
      BEGIN
         IF @bDeleteSerialNo = 1
         BEGIN
            DELETE FROM SERIALNO
            WHERE StorerKey = @cStorerKey    
            AND PickSlipNo = @cPickSlipNo
            AND [Status] < '6'
         END
         ELSE
         BEGIN
            UPDATE SERIALNO WITH (ROWLOCK)  
            SET [Status] = '1'
              , OrderKey = ''
              , OrderLineNumber = ''
              , LabelLine = ''
              , CartonNo = ''
              , PickSlipNo = ''
              , EditDate = GETDATE()
              , EditWho = @c_UserID
            WHERE StorerKey = @cStorerKey    
            AND PickSlipNo = @cPickSlipNo
            AND [Status] < '6'
         END

         IF @@ERROR <> 0  
         BEGIN  
            SET @n_Continue = 3  
            SET @n_ErrNo = 14653    
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update/Delete the SerialNo Table.'  
            GOTO EXIT_SP  
         END
      END

      -- Reset SerialNo by OrderKey (for records without PickSlipNo)
      SET @cCurOrderKey = @cOrderKey

      IF ISNULL(@cCurOrderKey, '') = ''
      BEGIN
         SELECT @cCurOrderKey = OrderKey
         FROM PICKHEADER (NOLOCK)
         WHERE PickHeaderKey = @cPickSlipNo
      END

      IF ISNULL(@cCurOrderKey, '') <> ''
      AND EXISTS (SELECT 1
                  FROM SERIALNO (NOLOCK)
                  WHERE OrderKey = @cCurOrderKey
                  AND StorerKey = @cStorerKey
                  AND [Status] IN ('1', '6')
                  AND ISNULL(OrderKey, '') <> ''
      )
      BEGIN
         IF @bDeleteSerialNo = 1
         BEGIN
            DELETE FROM SERIALNO
            WHERE StorerKey = @cStorerKey    
            AND OrderKey = @cCurOrderKey
            AND [Status] IN ('1', '6')
            AND ISNULL(OrderKey, '') <> ''
         END
         ELSE
         BEGIN
            UPDATE SERIALNO WITH (ROWLOCK)  
            SET [Status] = '1'
              , OrderKey = ''
              , OrderLineNumber = ''
              , LabelLine = ''
              , CartonNo = ''
              , PickSlipNo = ''
              , EditDate = GETDATE()
              , EditWho = @c_UserID
            WHERE StorerKey = @cStorerKey    
            AND OrderKey = @cCurOrderKey
            AND [Status] IN ('1', '6')
            AND ISNULL(OrderKey, '') <> ''
         END

         IF @@ERROR <> 0  
         BEGIN  
            SET @n_Continue = 3  
            SET @n_ErrNo = 14654    
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update/Delete the SerialNo Table.'  
            GOTO EXIT_SP  
         END
      END

      -- Reset UCC Status
      IF EXISTS ( SELECT 1 
                  FROM PACKINFO P(NOLOCK)
                  WHERE P.PickSlipNo = @cPickSlipNo
                  AND P.UCCNo <> ''
                  AND EXISTS (SELECT 1 
                              FROM PACKDETAIL PD(NOLOCK)
                              WHERE PD.PickSlipNo = P.PickSlipNo
                              AND (@cDropID = '' OR PD.DropID = @cDropID)
                             )
      )
      BEGIN
         UPDATE U WITH (ROWLOCK)
         SET U.[Status] = '3'
           , U.EditDate = GETDATE()
           , U.EditWho = @c_UserID
         FROM UCC U
         WHERE EXISTS ( SELECT 1 
                        FROM PACKINFO P(NOLOCK)
                        WHERE P.PickSlipNo = @cPickSlipNo
                        AND P.UCCNo = U.UCCNo
                        AND EXISTS (SELECT 1 
                                    FROM PACKDETAIL PD(NOLOCK)
                                    WHERE PD.PickSlipNo = P.PickSlipNo
                                    AND (@cDropID = '' OR PD.DropID = @cDropID)
                                   )
                      )

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3  
            SET @n_ErrNo = 14652    
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the UCC Table.'  
            GOTO EXIT_SP  
         END
      END
      
      -- Delete PackDetail
      DELETE FROM PACKDETAIL
      WHERE PickSlipNo = @cPickSlipNo
      AND (@cDropID = '' OR DropID = @cDropID)

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 14655    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete the PACKDETAIL Table.'  
         GOTO EXIT_SP  
      END
   END
   ELSE -- IF @bResetAll <> 1
   BEGIN
      -- Reset SerialNo by CartonNo
      IF EXISTS (SELECT 1  
                 FROM SERIALNO (NOLOCK)  
                 WHERE PickSlipNo = @cPickSlipNo    
                 AND CartonNo = @nCartonNo    
                 AND StorerKey = @cStorerKey 
                 AND [Status] < '6'
      )
      BEGIN
         IF @bDeleteSerialNo = 1
         BEGIN
            DELETE FROM SERIALNO
            WHERE StorerKey = @cStorerKey    
            AND PickSlipNo = @cPickSlipNo
            AND CartonNo = @nCartonNo
            AND [Status] < '6'
         END
         ELSE
         BEGIN
            UPDATE SERIALNO WITH (ROWLOCK)  
            SET [Status] = '1'
              , OrderKey = ''
              , OrderLineNumber = ''
              , LabelLine = ''
              , CartonNo = ''
              , PickSlipNo = ''
              , EditDate = GETDATE()
              , EditWho = @c_UserID
            WHERE StorerKey = @cStorerKey    
            AND PickSlipNo = @cPickSlipNo
            AND CartonNo = @nCartonNo
            AND [Status] < '6'
         END

         IF @@ERROR <> 0  
         BEGIN  
            SET @n_Continue = 3  
            SET @n_ErrNo = 14656    
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update/Delete the SerialNo Table.'  
            GOTO EXIT_SP  
         END
      END
      ELSE
      BEGIN
         -- Reset SerialNo by OrderKey (for records without CartonNo)
         SET @cCurOrderKey = @cOrderKey

         IF ISNULL(@cCurOrderKey, '') = ''
         BEGIN
            SELECT @cCurOrderKey = OrderKey
            FROM PICKHEADER (NOLOCK)
            WHERE PickHeaderKey = @cPickSlipNo
         END

         IF ISNULL(@cCurOrderKey, '') <> ''
         AND EXISTS (SELECT 1
                     FROM SERIALNO (NOLOCK)
                     WHERE OrderKey = @cCurOrderKey
                     AND StorerKey = @cStorerKey
                     AND [Status] IN ('1', '6')
         )
         BEGIN
            IF @bDeleteSerialNo = 1
            BEGIN
               DELETE FROM SERIALNO
               WHERE StorerKey = @cStorerKey    
               AND OrderKey = @cCurOrderKey
               AND [Status] IN ('1', '6')
               AND ISNULL(OrderKey, '') <> ''
            END
            ELSE
            BEGIN
               UPDATE SERIALNO WITH (ROWLOCK)  
               SET [Status] = '1'
                 , OrderKey = ''
                 , OrderLineNumber = ''
                 , LabelLine = ''
                 , CartonNo = ''
                 , PickSlipNo = ''
                 , EditDate = GETDATE()
                 , EditWho = @c_UserID
               WHERE StorerKey = @cStorerKey    
               AND OrderKey = @cCurOrderKey
               AND [Status] IN ('1', '6')
               AND ISNULL(OrderKey, '') <> ''
            END

            IF @@ERROR <> 0  
            BEGIN  
               SET @n_Continue = 3  
               SET @n_ErrNo = 14657    
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update/Delete the SerialNo Table.'  
               GOTO EXIT_SP  
            END
         END
      END

      -- Reset UCC Status
      SELECT @cUCCNo = UCCNo
      FROM PACKINFO (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND UCCNo <> ''

      IF @@ROWCOUNT > 0
      BEGIN
         UPDATE UCC WITH (ROWLOCK)
         SET [Status] = '3'
           , EditDate = GETDATE()
           , EditWho = @c_UserID
         WHERE UCCNo = @cUCCNo

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3  
            SET @n_ErrNo = 14658   
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the UCC Table.'  
            GOTO EXIT_SP  
         END
      END
      
      -- Delete PackDetail
      DELETE FROM PACKDETAIL
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      
      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 14659  
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete the PACKDETAIL Table.'  
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