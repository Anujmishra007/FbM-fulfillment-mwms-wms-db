SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ResetCarton_Std                                    */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Generic Reset Carton Function                                */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-09-22   1.0  GCH225     Created                                          */
/* 2026-01-21   2.0  GCH225     UWP-46886: Handling for WOD.Status               */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ResetCarton_Std] (
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
         , @cWorkOrderKey        NVARCHAR(10)
         , @cWorkOrderLineNumber NVARCHAR(5)

   DECLARE @OrderList TABLE(
      OrderKey NVARCHAR(10) PRIMARY KEY
   )

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = '' 
   SET @cWorkOrderKey         = ''
   SET @cWorkOrderLineNumber  = ''

   IF @cOrderKey <> ''
   BEGIN
      INSERT INTO @OrderList (OrderKey)
      VALUES (@cOrderKey)
   END
   ELSE IF @cLoadKey <> ''
   BEGIN
      INSERT INTO @OrderList (OrderKey)
      SELECT OrderKey
      FROM LOADPLANDETAIL (NOLOCK)
      WHERE LoadKey = @cLoadKey
   END

   BEGIN TRAN

   IF @bResetAll = 1
   BEGIN
      IF EXISTS(SELECT 1 
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
                  SET @n_ErrNo = 12051    
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
                  SET @n_ErrNo = 12052    
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
            SET @n_ErrNo = 12053    
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
            SET @n_ErrNo = 12054    
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the UCC Table.'  
            GOTO EXIT_SP  
         END
      END
      
      --Reset PickDetail CaseID if TPS-UPD_PICKDET config enabled
      IF EXISTS(SELECT 1 
                FROM STORERCONFIG (NOLOCK)
                WHERE StorerKey = @cStorerKey
                AND ConfigKey = 'TPS-UPD_PICKDET'
                AND sValue = '1'
      )
      BEGIN
         IF @bIsDiscrete = 1
         BEGIN
            UPDATE PD WITH(ROWLOCK)
            SET PD.CaseID = ''
              , PD.TrafficCop = NULL
            FROM PICKDETAIL PD
            WHERE OrderKey = @cOrderKey
            AND (@cDropID = '' OR PD.DropID = @cDropID)
            AND EXISTS ( SELECT 1 
                         FROM PACKDETAIL PD2 (NOLOCK)
                         WHERE PD2.PickSlipNo = @cPickSlipNo
                         AND (@cDropID = '' OR PD2.DropID = @cDropID)
                         AND PD2.LabelNo = PD.CaseID
                       )
            AND PD.[Status] < '5'
         END
         ELSE
         BEGIN
            UPDATE PD WITH(ROWLOCK)
            SET PD.CaseID = ''
              , PD.TrafficCop = NULL
            FROM PICKDETAIL PD
            WHERE EXISTS (SELECT 1
                          FROM LOADPLANDETAIL LPD (NOLOCK)
                          WHERE LPD.LoadKey = @cLoadKey
                          AND LPD.OrderKey = PD.OrderKey
                          )
            AND (@cDropID = '' OR PD.DropID = @cDropID)
            AND EXISTS ( SELECT 1 
                         FROM PACKDETAIL PD2 (NOLOCK)
                         WHERE PD2.PickSlipNo = @cPickSlipNo
                         AND (@cDropID = '' OR PD2.DropID = @cDropID)
                         AND PD2.LabelNo = PD.CaseID
                       )
            AND PD.[Status] < '5'
         END
      END

      -- Reset WorkOrderDetail Status to 3
      IF EXISTS(  SELECT 1
                  FROM STORERCONFIG (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND ConfigKey = 'TPS-VAS'
                  AND sValue IN ('1', '3')
      )
      BEGIN
         IF EXISTS ( SELECT 1
                     FROM WORKORDERDETAIL WOD (NOLOCK)
                     LEFT JOIN CODELKUP CLK (NOLOCK)
                     ON WOD.[Type] = CLK.Code
                     WHERE CLK.LISTNAME = 'WKOrdType'
                     AND EXISTS (SELECT 1
                                 FROM WORKORDER WO (NOLOCK)
                                 WHERE EXISTS ( SELECT 1 
                                                FROM @OrderList t
                                                WHERE t.OrderKey = WO.ExternWorkOrderKey
                                                )
                                 AND StorerKey = @cStorerKey
                                 AND Facility = @cFacility
                                 AND WO.[Type] IN('PACK', 'VAS')
                                 AND WO.WorkOrderKey = WOD.WorkOrderKey
                                 )
                     AND EXISTS (SELECT 1 
                                 FROM PACKDETAIL PD(NOLOCK)
                                 WHERE PD.PickSlipNo = @cPickSlipNo
                                 AND PD.SKU = WOD.Sku
                                )
         )
         BEGIN
            DECLARE CUR_UPDVAS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT  WorkOrderKey
                  , WorkOrderLineNumber
            FROM WORKORDERDETAIL WOD (NOLOCK)
            LEFT JOIN CODELKUP CLK (NOLOCK)
            ON WOD.[Type] = CLK.Code
            WHERE CLK.LISTNAME = 'WKOrdType'
            AND WOD.[Status] = '9'
            AND EXISTS (SELECT 1
                        FROM WORKORDER WO (NOLOCK)
                        WHERE EXISTS ( SELECT 1 
                                       FROM @OrderList t
                                       WHERE t.OrderKey = WO.ExternWorkOrderKey
                                       )
                        AND StorerKey = @cStorerKey
                        AND Facility = @cFacility
                        AND WO.[Type] IN('PACK', 'VAS')
                        AND WO.WorkOrderKey = WOD.WorkOrderKey
                        )
            AND EXISTS (SELECT 1 
                        FROM PACKDETAIL PD(NOLOCK)
                        WHERE PD.PickSlipNo = @cPickSlipNo
                        AND PD.SKU = WOD.Sku
                        )

            OPEN CUR_UPDVAS
            FETCH NEXT FROM CUR_UPDVAS INTO @cWorkOrderKey
                                          , @cWorkOrderLineNumber
            WHILE @@FETCH_STATUS = 0
            BEGIN
               UPDATE WORKORDERDETAIL WITH (ROWLOCK)
               SET [Status] = '3'
               WHERE WorkOrderKey = @cWorkOrderKey
               AND WorkOrderLineNumber = @cWorkOrderLineNumber

               IF @@ERROR <> 0
               BEGIN
                  SET @n_Continue = 3
                  SET @n_ErrNo = 12061
                  SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to update Status in WorkOrderDetail Table.'
                  GOTO EXIT_SP 
               END

               FETCH NEXT FROM CUR_UPDVAS INTO @cWorkOrderKey
                                             , @cWorkOrderLineNumber
            END
            CLOSE CUR_UPDVAS
            DEALLOCATE CUR_UPDVAS

            UPDATE WORKORDERDETAIL 
            SET [Status] = '3'
            WHERE WorkOrderKey = @cWorkOrderKey

            UPDATE WORKORDER
            SET [Status] = '0'
            WHERE WorkOrderKey = @cWorkOrderKey
         END
      END

      DELETE FROM PACKDETAIL
      WHERE PickSlipNo = @cPickSlipNo
      AND (@cDropID = '' OR DropID = @cDropID)

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 12055    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete the PACKDETAIL Table.'  
         GOTO EXIT_SP  
      END
   END
   ELSE
   BEGIN
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
                  SET @n_ErrNo = 12056    
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
                  SET @n_ErrNo = 12057    
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
            SET @n_ErrNo = 12058    
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
           , EditDate = GETDATE()
           , EditWho = @c_UserID
         WHERE UCCNo = @cUCCNo

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3  
            SET @n_ErrNo = 12059    
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the UCC Table.'  
            GOTO EXIT_SP  
         END
      END
      
      --Reset PickDetail CaseID if TPS-UPD_PICKDET config enabled
      IF EXISTS(SELECT 1 
                FROM STORERCONFIG (NOLOCK)
                WHERE StorerKey = @cStorerKey
                AND ConfigKey = 'TPS-UPD_PICKDET'
                AND sValue = '1'
      )
      BEGIN
         IF @bIsDiscrete = 1
         BEGIN
            UPDATE PD WITH(ROWLOCK)
            SET PD.CaseID = ''
              , PD.TrafficCop = NULL
            FROM PICKDETAIL PD
            WHERE OrderKey = @cOrderKey
            AND (@cDropID = '' OR PD.DropID = @cDropID)
            AND EXISTS ( SELECT 1 
                         FROM PACKDETAIL PD2 (NOLOCK)
                         WHERE PD2.PickSlipNo = @cPickSlipNo
                         AND PD2.CartonNo = @nCartonNo
                         AND (@cDropID = '' OR PD2.DropID = @cDropID)
                         AND PD2.LabelNo = PD.CaseID
                       )
            AND PD.[Status] < '5'
         END
         ELSE
         BEGIN
            UPDATE PD WITH(ROWLOCK)
            SET PD.CaseID = ''
              , PD.TrafficCop = NULL
            FROM PICKDETAIL PD
            WHERE EXISTS (SELECT 1
                          FROM LOADPLANDETAIL LPD (NOLOCK)
                          WHERE LPD.LoadKey = @cLoadKey
                          AND LPD.OrderKey = PD.OrderKey
                          )
            AND (@cDropID = '' OR PD.DropID = @cDropID)
            AND EXISTS ( SELECT 1 
                         FROM PACKDETAIL PD2 (NOLOCK)
                         WHERE PD2.PickSlipNo = @cPickSlipNo
                         AND PD2.CartonNo = @nCartonNo
                         AND (@cDropID = '' OR PD2.DropID = @cDropID)
                         AND PD2.LabelNo = PD.CaseID
                       )
            AND PD.[Status] < '5'
         END
      END

      -- Reset WorkOrderDetail Status to 3
      IF EXISTS(  SELECT 1
                  FROM STORERCONFIG (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND ConfigKey = 'TPS-VAS'
                  AND sValue IN ('1', '3')
      )
      BEGIN
         SELECT TOP 1 @cWorkOrderKey = WorkOrderKey
                     FROM WORKORDERDETAIL WOD (NOLOCK)
                     LEFT JOIN CODELKUP CLK (NOLOCK)
                     ON WOD.[Type] = CLK.Code
                     WHERE CLK.LISTNAME = 'WKOrdType'
                     AND EXISTS (SELECT 1
                                 FROM WORKORDER WO (NOLOCK)
                                 WHERE EXISTS ( SELECT 1 
                                                FROM @OrderList t
                                                WHERE t.OrderKey = WO.ExternWorkOrderKey
                                                )
                                 AND StorerKey = @cStorerKey
                                 AND Facility = @cFacility
                                 AND WO.[Type] IN('PACK', 'VAS')
                                 AND WO.WorkOrderKey = WOD.WorkOrderKey
                                 )
                     AND EXISTS (SELECT 1 
                                 FROM PACKDETAIL PD(NOLOCK)
                                 WHERE PD.PickSlipNo = @cPickSlipNo
                                 AND PD.SKU = WOD.Sku
                                )

         IF ISNULL(@cWorkOrderKey, '') <> ''
         AND EXISTS (SELECT 1
                     FROM WORKORDER WO (NOLOCK)
                     WHERE WO.WorkOrderKey = @cWorkOrderKey
                     AND WO.[Status] = '9'
         )
         BEGIN
            UPDATE WORKORDERDETAIL 
            SET [Status] = '3'
            WHERE WorkOrderKey = @cWorkOrderKey
            
            UPDATE WORKORDER
            SET [Status] = '0'
            WHERE WorkOrderKey = @cWorkOrderKey
         END
      END
      
      DELETE FROM PACKDETAIL
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      
      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 12060    
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



