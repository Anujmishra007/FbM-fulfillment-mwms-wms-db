SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************************/
/* Store procedure: isp_TPACK_ResetSKU_Std                                                */
/* Copyright      : Maersk                                                                */
/*                                                                                        */
/* Purpose        : Generic Reset SKU Function                                            */
/*                                                                                        */
/* Date         Rev  Author     Purposes                                                  */
/* 2025-10-09   1.0  YLI237     Created                                                   */
/* 2025-11-13   2.0  GCH225     UWP-44076 Incorrect PackInfo Qty after Delete PackDetail  */
/******************************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ResetSKU_Std] (
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
   , @cSKU                 NVARCHAR(20)      = ''
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
         , @b_sp_Success         INT  
         , @n_sp_err             INT  
         , @c_sp_errmsg          NVARCHAR(250)  = ''
         , @DBUserName           NVARCHAR(100)
         , @b_sp_ExecuteAs       BIT  
   
   DECLARE @cPackSerialNoKey     NVARCHAR(10)
         , @cSNSerialNoKey       NVARCHAR(10)
         , @cSerialNo            NVARCHAR(50)
         , @cSerialNoCapture     NVARCHAR(1)
         , @cUCCNo               NVARCHAR(20)
         , @cLabelNo             NVARCHAR(20)
         , @cLabelLine           NVARCHAR(5)
         , @nCntLabelLine        INT

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 
   SET @nCntLabelLine      = 0

   -- Get LabelNo for the given parameters
   SELECT top 1 @cLabelNo = LabelNo 
   FROM PACKDETAIL (NOLOCK)
   WHERE PickSlipNo = @cPickSlipNo
   AND CartonNo = @nCartonNo
   AND SKU = @cSKU

   IF @@ROWCOUNT = 0
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 14101
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No record found in PackDetail for the given parameters.'
      GOTO EXIT_SP
   END

   BEGIN TRAN

   IF EXISTS(SELECT 1 
                FROM PACKSERIALNO (NOLOCK)
                WHERE PickSlipNo = @cPickSlipNo
                AND CartonNo = @nCartonNo
      )
      BEGIN
         
         DECLARE CURSOR_PSN CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         SELECT  PSN.PackSerialNoKey
               , PSN.SerialNo
               , PSN.SKU
               , ISNULL(S.SerialNoCapture,'')
         FROM PACKSERIALNO PSN (NOLOCK)
         INNER JOIN SKU S (NOLOCK)
         ON S.StorerKey = PSN.StorerKey
         AND S.SKU = PSN.SKU
         WHERE PSN.PickSlipNo = @cPickSlipNo
         AND PSN.CartonNo = @nCartonNo
         AND PSN.SKU = @cSKU

         OPEN CURSOR_PSN
         FETCH NEXT FROM CURSOR_PSN INTO @cPackSerialNoKey, @cSerialNo, @cSKU, @cSerialNoCapture
         WHILE @@FETCH_STATUS = 0  
         BEGIN
            SET @cSNSerialNoKey = ''

            IF @cSerialNoCapture = '1'
            BEGIN
               SELECT @cSNSerialNoKey = SerialNoKey
               FROM SERIALNO (NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND SerialNo = @cSerialNo
               AND SKU = @cSKU

               IF @@ROWCOUNT > 1
               BEGIN
                  UPDATE SERIALNO WITH(ROWLOCK)
                  SET [Status] = '1'
                    , EditDate = GETDATE()
                    , EditWho = @c_UserID
                  WHERE StorerKey = @cStorerKey
                  AND SerialNo = @cSerialNo
                  AND SKU = @cSKU
               END
               ELSE
               BEGIN
                  UPDATE SERIALNO WITH(ROWLOCK)
                  SET [Status] = '1'
                    , EditDate = GETDATE()
                    , EditWho = @c_UserID
                  WHERE SerialNoKey = @cSNSerialNoKey
               END

               IF @@ERROR <> 0
               BEGIN
                  SET @n_Continue = 3  
                  SET @n_ErrNo = 14102    
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the SerialNo Table.'  
                  GOTO EXIT_SP  
               END
            END
            ELSE 
            BEGIN
               SELECT @cSNSerialNoKey = SerialNoKey
               FROM SERIALNO (NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND SerialNo = @cSerialNo
               AND SKU = @cSKU

               IF @@ROWCOUNT > 1
               BEGIN
                  DELETE FROM SERIALNO
                  WHERE StorerKey = @cStorerKey
                  AND SerialNo = @cSerialNo
                  AND SKU = @cSKU
               END
               ELSE
               BEGIN
                  DELETE FROM SERIALNO
                  WHERE SerialNoKey = @cSNSerialNoKey
               END

               IF @@ERROR <> 0
               BEGIN
                  SET @n_Continue = 3  
                  SET @n_ErrNo = 14103    
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete the SerialNo Table.'  
                  GOTO EXIT_SP  
               END
            END

            FETCH NEXT FROM CURSOR_PSN INTO @cPackSerialNoKey, @cSerialNo, @cSKU, @cSerialNoCapture
         END
         CLOSE CURSOR_PSN  
         DEALLOCATE CURSOR_PSN  
      END

   -- Check if there are UCC numbers associated with this packed SKU
   SELECT @cUCCNo = UCCNo
   FROM PACKINFO (NOLOCK)
   WHERE PickSlipNo = @cPickSlipNo
   AND CartonNo = @nCartonNo
   AND UCCNo <> ''
   AND EXISTS (SELECT 1
               FROM PACKDETAIL PD (NOLOCK)
               WHERE PD.PickSlipNo = PACKINFO.PickSlipNo
               AND PD.CartonNo = PACKINFO.CartonNo
               AND PD.SKU = @cSKU)

   IF @@ROWCOUNT > 0
   BEGIN
      -- Update UCC status to indicate it's no longer in use
      UPDATE U WITH (ROWLOCK)
      SET U.[Status] = '3'
        , U.EditDate = GETDATE()
        , U.EditWho = @c_UserID
      FROM UCC U
      WHERE U.UCCNo = @cUCCNo

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 14104    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the UCC Table.'  
         GOTO EXIT_SP  
      END
   END
   
   -- Get the quantity to be deleted for updating PACKINFO
   SELECT @nCntLabelLine = COUNT(LabelLine)
   FROM PACKDETAIL WITH (ROWLOCK)
   WHERE PickSlipNo = @cPickSlipNo
   AND CartonNo = @nCartonNo
   AND LabelNo = @cLabelNo
   AND SKU = @cSKU
   
   IF @nCntLabelLine = 0
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 14105
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No SKU found in PackDetail for deletion.'
      GOTO EXIT_SP
   END

   WHILE @nCntLabelLine > 0
   BEGIN
      SET @cLabelLine = ''

      SELECT TOP 1 @cLabelLine = LabelLine
      FROM PACKDETAIL (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND LabelNo = @cLabelNo
      AND SKU = @cSKU
      ORDER BY LabelLine ASC

      -- Delete the specific SKU from PACKDETAIL
      DELETE FROM PACKDETAIL WITH (ROWLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND LabelNo = @cLabelNo
      AND LabelLine = @cLabelLine

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 14106
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to delete from PackDetail.'
         GOTO EXIT_SP
      END
      SET @nCntLabelLine = @nCntLabelLine - 1
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