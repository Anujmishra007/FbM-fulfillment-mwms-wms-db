SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************/
/* Store procedure: isp_TPACK_UpdatePackInfo                                        */
/* Copyright      : Maersk                                                          */
/*                                                                                  */
/* Purpose        : Update PackInfo                                                 */
/*                                                                                  */
/* Date         Rev  Author     Purposes                                            */
/* 2025-08-21   1.0  GCH225     Created                                             */
/* 2025-11-03   1.1  JWF011     UWP-42640: Update close carton pickQty for tote     */
/* 2025-11-04   1.2  JWF011     UWP-42640: Update close carton packQty for tote     */
/* 2025-11-25   1.3  JWF011     UWP-42902: Add VAS Code QTY validation              */
/* 2025-12-05   1.4  YLI237     UWP-45247: Pack last OrderKey's SKU in 1 carton     */
/* 2025-12-09   1.5  JWF011     UWP-42902: Fix bug of VAS Code QTY validation       */
/* 2025-12-23   1.6  JWF011     UWP-42902: Fix bug of VAS Code QTY validation       */
/* 2026-01-12   1.7  JWF011     UWP-42902: Fix PickQTY with VAS QTY Code            */
/* 2026-01-15   1.8  JWF011     UWP-42902: Fix MaxSKUCarton Rule                    */
/* 2026-01-21   2.0  GCH225     UWP-45700: Update WoWkOrdUDef1 to SKU               */
/* 2026-01-23   3.0  GCH225     UWP-47567: Handle Open Carton to change WOD Status  */
/* 2026-02-03   3.1  JWF011     UWP-48096: Add AuditLog for Carton Type change      */
/* 2026-02-04   3.2  JWF011     UWP-48244: Add Recartonization check rule           */
/* 2026-02-13   3.3  GCH225     UWP-48895: Bug fix AuditLog Carton Type Change      */
/* 2026-02-24   3.4  GCH225     UWP-49353: Fix for Hold status for specific cases   */
/* 2026-03-13   3.5  GCH225     FCR-11554: Add Extended Validate before Close Carton*/
/* 2026-03-16   3.6  GCH225     FCR-11595: New Insert logic UserSessionActivityLog  */
/* 2026-03-16   3.6  GCH225     FCR-11632: Fix for AuditLog part when Status change */
/* 2026-03-16   3.7  JWF011     FCR-11639: Update for ExtMeasurement                */
/* 2026-03-19   3.8  JWF011     FCR-11818: Update TPACK_UserSessionActivityLog      */
/************************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_UpdatePackInfo] (
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
   , @cCartonStatus        NVARCHAR(20)      = ''
   , @cCartonType          NVARCHAR(10)      = ''
   , @fWeight              FLOAT             = 0
   , @fCube                FLOAT             = 0
   , @cLabelNo             NVARCHAR(20)      = ''
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @bWeightInterface     BIT               = 0   OUTPUT
   , @bPrintPaperFlag      BIT               = 0   OUTPUT
   , @bPrintLabelFlag      BIT               = 0   OUTPUT
   , @bIsLastCarton        BIT               = 0   OUTPUT
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

   DECLARE @fTtlWeight           FLOAT
         , @fTtlCube             FLOAT
         , @nCtnWeight           FLOAT
         , @nCtnCube             FLOAT
         , @bCubeByCarton        BIT
         , @bWeightByCarton      BIT
         , @nTtlPickQty          INT
         , @nTtlPackQty          INT
         , @nPrecedingCartonNo   INT
         , @bOpenCartonFlag      BIT
         , @fTtlLength           FLOAT
         , @fTtlWidth            FLOAT
         , @fTtlHeight           FLOAT

   DECLARE @cVASCodeUDF2         NVARCHAR(60)   = ''
         , @cVASCodeUDF3         NVARCHAR(60)   = ''
         , @nWODQTY              INT            = 0
         , @cWODSku              NVARCHAR(20)   = ''
         , @cWODExternLineNo     NVARCHAR(5)    = ''
         , @nOrderLinePickQTY    INT            = 0
         , @cExtMeasurementSP    NVARCHAR(250)  = ''
         , @cSQL                 NVARCHAR(MAX)  = ''
         , @cSQLParam            NVARCHAR(MAX)  = ''
   
   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 

   SET @fTtlWeight         = 0
   SET @fTtlCube           = 0
   SET @nCtnWeight         = 0
   SET @nCtnCube           = 0
   SET @bCubeByCarton      = 0
   SET @bWeightByCarton    = 0
   SET @nTtlPickQty        = 0
   SET @nTtlPackQty        = 0
   SET @nPrecedingCartonNo = 0
   SET @bOpenCartonFlag    = 0
   SET @cExtMeasurementSP  = ''
   SET @cSQL               = ''
   SET @cSQLParam          = ''
   SET @fTtlLength         = 0
   SET @fTtlWidth          = 0
   SET @fTtlHeight         = 0
   
   IF EXISTS ( SELECT 1 
               FROM PACKHEADER (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
               AND [Status] = '9'
   )
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 11553
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Failed to Update PackInfo, Current Pickslip already Status 9 with Pack Confirm.
      GOTO EXIT_SP
   END

   --Insert/Update PackInfo
   IF NOT EXISTS ( SELECT 1 
               FROM PACKINFO (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
               AND CartonNo = @nCartonNo
   )
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 11551
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Failed to Update into PackInfo, Current Carton No. not found.
      GOTO EXIT_SP
   END

   --Perform Extended Carton Pre Update for all the status
   EXEC [API].[isp_TPACK_ExtCtnPreUpd_Wrapper]
           @cType             = @cType            
         , @bIsDiscrete       = @bIsDiscrete      
         , @bIsCustom         = @bIsCustom        
         , @cPickSlipNo       = @cPickSlipNo       
         , @cOrderKey         = @cOrderKey
         , @cLoadKey          = @cLoadKey          
         , @cDropID           = @cDropID
         , @cStorerKey        = @cStorerKey        
         , @cFacility         = @cFacility   
         , @nCartonNo         = @nCartonNo
         , @cCartonStatus     = @cCartonStatus
         , @cCartonType       = @cCartonType
         , @fWeight           = @fWeight
         , @fCube             = @fCube
         , @cLabelNo          = @cLabelNo
         , @c_UserID          = @c_UserID
         , @cLangCode         = @cLangCode
         , @bWeightInterface  = @bWeightInterface  OUTPUT
         , @bPrintPaperFlag   = @bPrintPaperFlag   OUTPUT
         , @bPrintLabelFlag   = @bPrintLabelFlag   OUTPUT
         , @bIsLastCarton     = @bIsLastCarton     OUTPUT
         , @b_Success         = @b_Success         OUTPUT
         , @n_ErrNo           = @n_ErrNo           OUTPUT
         , @c_ErrMsg          = @c_ErrMsg          OUTPUT
   
   IF @b_Success = 0
   BEGIN    
      SET @n_Continue = 3
      GOTO EXIT_SP
   END

   IF @cCartonStatus = 'CLOSED'
   BEGIN
      -- Recartonization Check Rule
      IF EXISTS( SELECT 1 
                  FROM STORERCONFIG (NOLOCK)
                  WHERE Storerkey = @cStorerKey
                  AND ConfigKey = 'TPS-RecartonBlocked'
                  AND SValue = '1'
      )
      BEGIN
         IF EXISTS ( SELECT 1
                     FROM PACKDETAIL (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                     AND CartonNo = @nCartonNo
                     AND ExpQty > 0
                     AND ExpQty <> Qty
         )
         AND NOT EXISTS (  SELECT 1
                           FROM WorkOrderDetail WOD (NOLOCK)
                           JOIN CODELKUP CL (NOLOCK)
                              ON CL.Code = WOD.Type
                           WHERE WOD.ExternWorkOrderKey = @cOrderKey
                           AND CL.Listname = 'WKORDType'
                           AND CL.UDF02 IN ('ExactQTY', 'MAXQTY')
                           AND WOD.QTY > 0
                           AND EXISTS (SELECT 1 FROM PICKDETAIL PID (NOLOCK)
                                       WHERE PID.OrderKey = @cOrderKey
                                       AND PID.OrderLineNumber = WOD.ExternLineNo
                           )
                           AND EXISTS (SELECT 1 FROM PACKDETAIL PAD (NOLOCK)
                                       WHERE PAD.PickSlipNo = @cPickSlipNo
                                       AND PAD.CartonNo = @nCartonNo
                                       AND PAD.SKU = WOD.Sku
                           )
         )
         BEGIN
            SET @n_Continue  = 3
            SET @n_ErrNo = 11558
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Not Allow Recartonization'
            GOTO EXIT_SP
         END
      END
      -- Recartonization Check Rule (END)
   
      IF EXISTS ( SELECT 1 
                  FROM STORERCONFIG WITH (NOLOCK) 
                  WHERE ConfigKey = 'TPS-CubeByCarton' 
                  AND StorerKey = @cStorerKey 
                  AND sValue = '1'
      )    
      BEGIN    
         SET @bCubeByCarton = 1
      END
      
      IF EXISTS ( SELECT 1 
                  FROM STORERCONFIG WITH (NOLOCK) 
                  WHERE ConfigKey ='TPS-WeightByCarton' 
                  AND StorerKey = @cStorerKey 
                  AND sValue = '1'
      )    
      BEGIN    
         SET @bWeightByCarton = 1
      END

      IF EXISTS ( SELECT 1
                  FROM STORERCONFIG (NOLOCK)
                  WHERE Storerkey = @cStorerKey
                  AND ConfigKey = 'TPS-captureWeight'
                  AND SValue IN ('WC',',W', 'C')
      )
      BEGIN
         SET @fTtlWeight = @fWeight
         SET @fTtlCube = @fCube
      END
      ELSE
      BEGIN
         EXEC [API].[isp_TPACK_ExtMeasurement_Wrapper]
           @cType         = @cType            
         , @bIsDiscrete   = @bIsDiscrete      
         , @bIsCustom     = @bIsCustom        
         , @cPickSlipNo   = @cPickSlipNo       
         , @cOrderKey     = @cOrderKey         
         , @cLoadKey      = @cLoadKey          
         , @cDropID       = @cDropID           
         , @cStorerKey    = @cStorerKey        
         , @cFacility     = @cFacility         
         , @nCartonNo     = @nCartonNo
         , @cCartonStatus = @cCartonStatus
         , @cCartonType   = @cCartonType
         , @fWeight       = @fWeight
         , @fCube         = @fCube
         , @cLabelNo      = @cLabelNo
         , @c_UserID      = @c_UserID
         , @cLangCode     = @cLangCode
         , @fTtlWeight    = @fTtlWeight  OUTPUT
         , @fTtlCube      = @fTtlCube    OUTPUT
         , @fTtlLength    = @fTtlLength   OUTPUT
         , @fTtlWidth     = @fTtlWidth   OUTPUT
         , @fTtlHeight    = @fTtlHeight   OUTPUT
         , @b_Success     = @b_Success   OUTPUT
         , @n_ErrNo       = @n_ErrNo     OUTPUT
         , @c_ErrMsg      = @c_ErrMsg    OUTPUT

         IF @b_Success = 0
         BEGIN
            SET @n_Continue = 3  
            GOTO EXIT_SP
         END
      END

      IF EXISTS ( SELECT 1 
                  FROM STORER (NOLOCK) 
                  WHERE StorerKey = @cStorerKey 
                  AND CartonGroup <> ''
      )
      BEGIN
         SELECT   @nCtnCube = IIF( @bCubeByCarton = 1, c.[Cube], 0)
                , @nCtnWeight = IIF( @bWeightByCarton = 1, c.CartonWeight, 0)
         FROM STORER s (NOLOCK)
         INNER JOIN Cartonization c (NOLOCK) 
         ON s.CartonGroup = c.CartonizationGroup
         WHERE s.StorerKey = @cStorerKey
         AND c.CartonType = @cCartonType  
      END
      ELSE
      BEGIN
         SELECT TOP 1 @nCtnCube = IIF( @bCubeByCarton = 1, [Cube], 0)
                    , @nCtnWeight = IIF( @bWeightByCarton = 1, CartonWeight, 0)
         FROM Cartonization (NOLOCK)
         WHERE CartonType = @cCartonType 
         ORDER BY CartonizationKey DESC
      END

      IF @fTtlWeight > 30 OR @nCtnWeight > 30
      BEGIN  
         SET @bWeightInterface = 1  
      END 

      IF @cType = 'pickslip' OR (@cType = 'order' AND @bIsCustom = 0)
      BEGIN
         IF @bIsDiscrete = 1
         BEGIN
            SELECT @nTtlPickQty=ISNULL(SUM(Qty), 0)
            FROM PICKDETAIL (NOLOCK)
            WHERE OrderKey = @cOrderKey
            AND [Status] <= '5'
         END
         ELSE
         BEGIN
            SELECT @nTtlPickQty=ISNULL(SUM(Qty), 0)
            FROM PICKDETAIL PD (NOLOCK)
            WHERE EXISTS ( SELECT 1 
                           FROM LOADPLANDETAIL LPD (NOLOCK)
                           WHERE LPD.OrderKey = PD.OrderKey
                           AND LPD.LoadKey = @cLoadKey
                           )
            AND [Status] <= '5'
         END

         SELECT @nTtlPackQty = ISNULL(SUM(Qty), 0)
         FROM PACKINFO (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
      END
      ELSE IF @cType = 'toteid'
      BEGIN
         IF @bIsDiscrete = 1
         BEGIN
            SELECT @nTtlPickQty=ISNULL(SUM(Qty), 0)
            FROM PICKDETAIL (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND (@cOrderKey = '' OR OrderKey = @cOrderKey)
            AND DropID = @cDropID
            AND [Status] <= '5'

            SELECT @nTtlPackQty = ISNULL(SUM(Qty), 0)
            FROM PACKDETAIL (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
            AND DropID = @cDropID
         END
         ELSE
         BEGIN
            SELECT @nTtlPickQty=ISNULL(SUM(Qty), 0)
            FROM PICKDETAIL (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND DropID = @cDropID
            AND OrderKey = @cOrderKey
            AND [Status] <= '5'

            SELECT @nTtlPackQty = ISNULL(SUM(PD.Qty), 0)
            FROM PACKDETAIL PD (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
            AND PD.DropID = @cDropID
            AND EXISTS ( SELECT 1
                         FROM PACKHEADER PH (NOLOCK)
                         WHERE PH.PickSlipNo = PD.PickSlipNo
                         AND PH.OrderKey = @cOrderKey
            )
         END
      END
      ELSE IF @cType = 'order'
      BEGIN
         SELECT @nTtlPickQty=ISNULL(SUM(Qty), 0)
         FROM PICKDETAIL (NOLOCK)
         WHERE OrderKey = @cOrderKey
         AND [Status] <= '5'

         --Only for those already updated labelno for cartonstatus already been hold or close.
         SELECT @nTtlPackQty = ISNULL(SUM(PD.Qty), 0) --UWP-45247
         FROM PACKDETAIL PD(NOLOCK)
         WHERE PD.PickSlipNo = @cPickSlipNo
         AND EXISTS( SELECT 1 
                     FROM PICKDETAIL PD2 (NOLOCK)
                     WHERE PD2.OrderKey = @cOrderKey
                     AND PD2.CaseID = PD.LabelNo
                     AND PD2.Sku = PD.SKU
                   )
         --Handle for inprogress carton that havent update the labelno into pickdetail CaseID column
         SELECT @nTtlPackQty = @nTtlPackQty + ISNULL(SUM(PD.Qty), 0)
         FROM PACKINFO PD (NOLOCK)
         WHERE PD.PickSlipNo = @cPickSlipNo
         AND PD.CartonNo = @nCartonNo
         AND PD.CartonStatus = 'INPROGRESS'
      END

      IF @nTtlPickQty = @nTtlPackQty 
      BEGIN
         SET @bIsLastCarton = 1
      END

      -- only enabled the print paper flag when total pick vs pack qty is match for pickslip level (discrete and conso)
      IF(@bIsDiscrete = 1
      AND ( SELECT ISNULL(SUM(Qty), 0)
            FROM PACKINFO (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
      ) = ( SELECT ISNULL(SUM(Qty), 0)
            FROM PICKDETAIL (NOLOCK)
            WHERE OrderKey = @cOrderKey
            AND [Status] <= '5'
      )) 
      OR 
      (@bIsDiscrete = 0 AND @cLoadKey <> ''
      AND ( SELECT ISNULL(SUM(Qty), 0)
            FROM PACKINFO (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
      ) = ( SELECT ISNULL(SUM(Qty), 0)
            FROM PICKDETAIL PD (NOLOCK)
            WHERE EXISTS ( SELECT 1 
                           FROM LOADPLANDETAIL LPD (NOLOCK)
                           WHERE LPD.OrderKey = PD.OrderKey
                           AND LPD.LoadKey = @cLoadKey
                           )
            AND PD.[Status] <= '5'
      )) 
      OR 
      (@bIsDiscrete = 0 AND @cLoadKey = ''
      AND ( SELECT ISNULL(SUM(Qty), 0)
            FROM PACKINFO (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
      ) = ( SELECT ISNULL(SUM(Qty), 0)
            FROM PICKDETAIL PD (NOLOCK)
            WHERE PD.StorerKey = @cStorerKey
            AND PD.DropID = @cDropID
            AND PD.OrderKey = @cOrderKey
            AND PD.[Status] <= '5'
      )) 
      BEGIN
         SET @bPrintPaperFlag = 1
      END

      --VAS Code QTY Validation
      DECLARE CUR_VAS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT CL.UDF02
           , CL.UDF03
           , WOD.QTY
           , WOD.Sku
           , WOD.ExternLineNo
      FROM WorkOrderDetail WOD (NOLOCK)
      JOIN CODELKUP CL (NOLOCK)
         ON CL.Code = WOD.Type
      WHERE WOD.ExternWorkOrderKey = @cOrderKey
      AND CL.Listname = 'WKORDType'
      AND (
            (WOD.ExternLineNo = '0H'
            AND CL.UDF02 = 'MaxSKUCarton'
            )
         OR (EXISTS (SELECT 1 FROM PICKDETAIL PID (NOLOCK)
                     WHERE PID.OrderKey = @cOrderKey
                     AND PID.OrderLineNumber = WOD.ExternLineNo
            )
            AND EXISTS (SELECT 1 FROM PACKDETAIL PAD (NOLOCK)
                        WHERE PAD.PickSlipNo = @cPickSlipNo
                        AND PAD.CartonNo = @nCartonNo
                        AND PAD.SKU = WOD.Sku
            )
            AND WOD.QTY > 0
            AND CL.UDF02 IN ('ExactQTY', 'MAXQTY')
         )
      )
      OPEN CUR_VAS
      FETCH NEXT FROM CUR_VAS INTO @cVASCodeUDF2
                                 , @cVASCodeUDF3
                                 , @nWODQTY
                                 , @cWODSku
                                 , @cWODExternLineNo
      WHILE @@FETCH_STATUS = 0
      BEGIN
         IF @cVASCodeUDF2 = 'ExactQTY'
         BEGIN
            IF ISNULL( (SELECT SUM(QTY)
                        FROM PACKDETAIL (NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                        AND CartonNo = @nCartonNo
                        AND SKU = @cWODSku)
                        , 0)
               <> @nWODQTY
            BEGIN
               SET @n_Continue  = 3
               SET @n_ErrNo = 11555
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'All carton QTY must equal to VAS ExactQTY'
               GOTO EXIT_SP
            END
         END
         ELSE IF @cVASCodeUDF2 = 'MAXQTY'
         BEGIN
            SELECT @nOrderLinePickQTY = ISNULL(SUM(QTY), 0)
            FROM PICKDETAIL (NOLOCK)
            WHERE OrderKey = @cOrderKey
            AND OrderLineNumber = @cWODExternLineNo
            AND [Status] <= '5'

            IF (@nTtlPackQty = @nOrderLinePickQTY
               AND
               ISNULL( (SELECT SUM(QTY)
                        FROM PACKDETAIL (NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                        AND CartonNo = @nCartonNo
                        AND SKU = @cWODSku)
                        , 0) > @nWODQTY)
            OR (@nTtlPackQty <> @nOrderLinePickQTY
               AND
               ISNULL( (SELECT SUM(QTY)
                        FROM PACKDETAIL (NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                        AND CartonNo = @nCartonNo
                        AND SKU = @cWODSku)
                        , 0) <> @nWODQTY)
            BEGIN
               SET @n_Continue  = 3
               SET @n_ErrNo = 11556
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'All carton QTY must equal to VAS MAXQTY except the last carton'
               GOTO EXIT_SP
            END
         END
         IF @cVASCodeUDF2 = 'MaxSKUCarton'
            AND TRY_CAST(ISNULL(@cVASCodeUDF3, '') AS INT) > 0
         BEGIN
            IF (SELECT COUNT(DISTINCT SKU)
               FROM PACKDETAIL (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
               AND CartonNo = @nCartonNo
            ) > TRY_CAST(ISNULL(@cVASCodeUDF3, '') AS INT)
            BEGIN
               SET @n_Continue  = 3
               SET @n_ErrNo = 11557
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Number of different SKU in a carton must not exceed VAS MaxSKUCarton'
               GOTO EXIT_SP
            END
         END

         FETCH NEXT FROM CUR_VAS INTO @cVASCodeUDF2
                                    , @cVASCodeUDF3
                                    , @nWODQTY
                                    , @cWODSku
                                    , @cWODExternLineNo
      END
      CLOSE CUR_VAS
      DEALLOCATE CUR_VAS
      --VAS Code QTY Validation (END)
   END
   
   BEGIN TRAN  

   -- Means Open Carton
   IF @cCartonStatus = 'INPROGRESS'
   BEGIN
      SET @bOpenCartonFlag = 1
      SELECT @nPrecedingCartonNo = ISNULL(CartonNo,0)
      FROM PACKINFO (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonStatus = @cCartonStatus
      AND EditWho = @c_UserID


      --Proceed to Hold the InProgress Carton before update other carton to InProgress
      IF @nPrecedingCartonNo > 0 AND @@ROWCOUNT = 1
      BEGIN
         UPDATE PACKINFO WITH (ROWLOCK)
         SET  EditWho = @c_UserID
            , EditDate = GETDATE()
            , CartonStatus = 'HOLD'
            , TrafficCop = NULL
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nPrecedingCartonNo
      END
   END

   IF @cCartonStatus IN ('CLOSED', 'INPROGRESS')
   BEGIN
      -- Add Audit Log for Carton Type change
      SELECT 1 
      FROM PACKINFO (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND (CartonType <> @cCartonType
      OR (CartonStatus = 'PENDAUDIT' AND CartonStatus <> @cCartonStatus)
      )
      
      IF @@ROWCOUNT = 1
      BEGIN
         INSERT INTO PackInfo_AuditLog (
                 ActionType
               , PickSlipNo
               , CartonNo
               , [Weight]
               , [Cube]
               , Qty
               , AddDate
               , AddWho
               , EditDate
               , EditWho
               , TrafficCop
               , ArchiveCop
               , CartonType
               , RefNo
               , [Length]
               , [Width]
               , [Height]
               , UCCNo
               , CartonGID
               , CartonStatus
               , TrackingNo
         )  
         SELECT  'UPDATE'
               , PickSlipNo
               , CartonNo
               , [Weight]
               , [Cube]
               , Qty
               , GETDATE()
               , AddWho
               , GETDATE()
               , EditWho
               , TrafficCop
               , ArchiveCop
               , CartonType
               , RefNo
               , [Length]
               , [Width]
               , [Height]
               , UCCNo
               , CartonGID
               , CartonStatus
               , TrackingNo
         FROM PACKINFO (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 11559
            SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Insert Audit Log for Carton Type change.'
            GOTO EXIT_SP
         END
      END
      -- Add Audit Log for Carton Type change (END)
   END

   UPDATE PACKINFO WITH (ROWLOCK)
   SET  EditWho = @c_UserID
      , EditDate = GETDATE()
      , CartonStatus = @cCartonStatus
      , CartonType = IIF(@cCartonType = '', CartonType, @cCartonType)
      , [Weight] = IIF(@bWeightByCarton = 1
                     , (@fTtlWeight + @nCtnWeight)
                     , IIF(@fTtlWeight = 0
                        , [Weight]
                        , @fTtlWeight)
                     )
      , [Cube] = IIF(@bCubeByCarton = 1
                  , (@fTtlCube + @nCtnCube)
                  , IIF(@fTtlCube = 0
                     , [Cube]
                     , @fTtlCube)
                  )
      , [Length] = IIF(@fTtlLength = 0
                     , [Length]
                     , @fTtlLength)
      , [Width] = IIF(@fTtlWidth = 0
                     , [Width]
                     , @fTtlWidth)
      , [Height] = IIF(@fTtlHeight = 0
                     , [Height]
                     , @fTtlHeight)
      , TrafficCop = NULL
   WHERE PickSlipNo = @cPickSlipNo
   AND CartonNo = @nCartonNo

   IF @@ERROR <> 0
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 11552
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update into PackInfo.'
      GOTO EXIT_SP
   END

   --Perform Extended Carton Post Update for all the status
   EXEC [API].[isp_TPACK_ExtCtnPostUpd_Wrapper]
         @cType               = @cType            
      , @bIsDiscrete          = @bIsDiscrete      
      , @bIsCustom            = @bIsCustom        
      , @cPickSlipNo          = @cPickSlipNo       
      , @cOrderKey            = @cOrderKey
      , @cLoadKey             = @cLoadKey          
      , @cDropID              = @cDropID
      , @cStorerKey           = @cStorerKey        
      , @cFacility            = @cFacility
      , @nCartonNo            = @nCartonNo
      , @nPrecedingCartonNo   = @nPrecedingCartonNo
      , @cCartonStatus        = @cCartonStatus
      , @bIsLastCarton        = @bIsLastCarton
      , @c_UserID             = @c_UserID
      , @cLangCode            = @cLangCode
      , @b_Success            = @b_Success         OUTPUT
      , @n_ErrNo              = @n_ErrNo           OUTPUT
      , @c_ErrMsg             = @c_ErrMsg          OUTPUT
   
   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3   
      GOTO EXIT_SP
   END

   INSERT INTO API.TPACK_UserSessionActivityLog 
   (
        PickSlipNo
      , CartonNo
      , LabelNo
      , OrderKey
      , LoadKey
      , DropID
      , StorerKey
      , Facility
      , Workstation
      , LabelPrinter
      , PaperPrinter
      , AddWho
      , AddDate
      , EditWho
      , EditDate
   )
   SELECT TOP 1 L.PickSlipNo
      , PD.CartonNo
      , PD.LabelNo
      , L.OrderKey
      , L.LoadKey
      , L.DropID
      , L.StorerKey
      , L.Facility 
      , L.Workstation
      , L.LabelPrinter
      , L.PaperPrinter
      , dbo.fnc_GetUserName()
      , dbo.fnc_GetDate()
      , dbo.fnc_GetUserName()
      , dbo.fnc_GetDate()
   FROM API.TPACK_UserSessionActivityLog L WITH (NOLOCK)
   LEFT JOIN PACKDETAIL PD WITH (NOLOCK)
   ON PD.PickSlipNo = L.PickSlipNo
   AND PD.StorerKey = L.StorerKey
   WHERE L.PickSlipNo = @cPickSlipNo
   AND PD.CartonNo = @nCartonNo
   AND L.StorerKey = @cStorerKey
   ORDER BY 1 DESC
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
