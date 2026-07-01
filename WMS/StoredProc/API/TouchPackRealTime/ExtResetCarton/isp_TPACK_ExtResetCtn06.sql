SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtResetCtn06                                      */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Custom Reset Carton Function For Columbia (CSCUK01)          */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-07-01   1.0  GCH225     UWP-60354: Prevent to reset carton               */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtResetCtn06] (
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
   
   DECLARE @cPackSerialNoKey     NVARCHAR(10)
         , @cSNSerialNoKey       NVARCHAR(10)
         , @cSerialNo            NVARCHAR(50)
         , @cSerialNoCapture     NVARCHAR(1)
         , @cSKU                 NVARCHAR(20)
         , @cUCCNo               NVARCHAR(20)

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 

   -- Block user from resetting carton for temporary solution to prevent the issue of resetting carton for Columbia (CSCUK01)
   IF @cOrderKey <> ''
   AND EXISTS (SELECT 1 
               FROM ORDERS O (NOLOCK)
               WHERE O.OrderKey = @cOrderKey
               AND O.OrderGroup = 'B2B'
   )
   BEGIN
      SET @n_Continue = 3  
      SET @n_ErrNo = 16301    
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + @cStorerKey + ').'  --'Reset carton is not allowed for following Storer(+ @cStorerKey +).'  
      GOTO EXIT_SP  
   END

   BEGIN TRAN

   IF @bResetAll = 1
   BEGIN
      DELETE CT
      FROM CARTONTRACK CT
      WHERE EXISTS ( SELECT 1 
                     FROM PACKDETAIL P (NOLOCK)
                     WHERE P.PickSlipNo = @cPickSlipNo
                     AND P.LabelNo = CT.LabelNo
      )

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 16001    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete from CartonTrack Table.'  
         GOTO EXIT_SP  
      END

      --Delete PACKSERIALNO and SerialNo
      IF EXISTS ( SELECT 1 
                  FROM PACKSERIALNO PSN (NOLOCK)
                  WHERE PSN.PickSlipNo = @cPickSlipNo
                  AND EXISTS (SELECT 1 
                              FROM PACKDETAIL PD(NOLOCK)
                              WHERE PD.PickSlipNo = PSN.PickSlipNo
                              AND (@cDropID = '' OR PD.DropID = @cDropID)
                  )
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
         AND EXISTS (SELECT 1 
                     FROM PACKDETAIL PD(NOLOCK)
                     WHERE PD.PickSlipNo = PSN.PickSlipNo
                     AND (@cDropID = '' OR PD.DropID = @cDropID)
         )

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
                  SET @n_ErrNo = 16002
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
                  SET @n_ErrNo = 16003
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete the SerialNo Table.'  
                  GOTO EXIT_SP  
               END
            END

            FETCH NEXT FROM CURSOR_PSN INTO @cPackSerialNoKey, @cSerialNo, @cSKU, @cSerialNoCapture
         END
         CLOSE CURSOR_PSN  
         DEALLOCATE CURSOR_PSN  

         DELETE PSN
         FROM PACKSERIALNO PSN
         WHERE PSN.PickSlipNo = @cPickSlipNo
         AND EXISTS (SELECT 1 
                     FROM PACKDETAIL PD(NOLOCK)
                     WHERE PD.PickSlipNo = PSN.PickSlipNo
                     AND (@cDropID = '' OR PD.DropID = @cDropID)
         )

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3  
            SET @n_ErrNo = 16004
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete the PACKSERIALNO Table.'  
            GOTO EXIT_SP  
         END
      END

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
            ,U.EditDate = GETDATE()
            ,U.EditWho = @c_UserID
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
            SET @n_ErrNo = 16005
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the UCC Table.'  
            GOTO EXIT_SP  
         END
      END
      
      DELETE FROM PACKDETAIL
      WHERE PickSlipNo = @cPickSlipNo
      AND (@cDropID = '' OR DropID = @cDropID)

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 16006
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete the PACKDETAIL Table.'  
         GOTO EXIT_SP  
      END
   END
   ELSE
   BEGIN
      DELETE CT
      FROM CARTONTRACK CT
      WHERE EXISTS ( SELECT 1 
                     FROM PACKDETAIL P (NOLOCK)
                     WHERE P.PickSlipNo = @cPickSlipNo
                     AND P.CartonNo = @nCartonNo
                     AND P.LabelNo = CT.LabelNo
      )

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 16007
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete from CartonTrack Table.'  
         GOTO EXIT_SP  
      END

      --Delete PACKSERIALNO and SerialNo
      IF EXISTS ( SELECT 1 
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
                  SET @n_ErrNo = 16008
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
                  SET @n_ErrNo = 16009
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete the SerialNo Table.'  
                  GOTO EXIT_SP  
               END
            END

            FETCH NEXT FROM CURSOR_PSN INTO @cPackSerialNoKey, @cSerialNo, @cSKU, @cSerialNoCapture
         END
         CLOSE CURSOR_PSN  
         DEALLOCATE CURSOR_PSN  

         DELETE FROM PACKSERIALNO
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3  
            SET @n_ErrNo = 16010
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete the PACKSERIALNO Table.'  
            GOTO EXIT_SP  
         END
      END

      SELECT @cUCCNo = UCCNo
      FROM PACKINFO (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND UCCNo <> ''

      IF @@ROWCOUNT > 0
      BEGIN
         UPDATE UCC WITH (ROWLOCK)
         SET [Status] = '3'
            ,EditDate = GETDATE()
            ,EditWho = @c_UserID
         WHERE UCCNo = @cUCCNo

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3  
            SET @n_ErrNo = 16011
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the UCC Table.'  
            GOTO EXIT_SP  
         END
      END
      
      DELETE FROM PACKDETAIL
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      
      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 16012
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



