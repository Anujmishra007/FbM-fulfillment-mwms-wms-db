SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************/
/* Store procedure: isp_TPACK_ExtCtnPostUpd_Std                                     */
/* Copyright      : Maersk                                                          */
/*                                                                                  */
/* Purpose        : Extended Carton Post Update Standard                            */
/*                                                                                  */
/* Date         Rev  Author     Purposes                                            */
/* 2025-11-03   1.0  GCH225     UWP-42602, UWP-42604: Created                       */
/* 2026-01-09   2.0  GCH225     UWP-46670: WorkOrderDetail Status Update Logic      */
/* 2026-01-14   3.0  GCH225     UWP-46855: Support Hold Carton Logic                */
/* 2026-01-14   3.1  GCH225     UWP-46970: Bug fix the WOD.Status Update            */
/* 2026-01-20   4.0  GCH225     UWP-47142: Bug fix the WOD.Status Update            */
/* 2026-01-21   4.1  GCH225     UWP-45700: Update WoWkOrdUDef1 to SKU               */
/* 2026-01-23   5.0  GCH225     UWP-47567: Handle Open Carton to change WOD Status  */
/* 2026-02-26   5.1  GCH225     UWP-49355: Fix Update ExpQty to Qty in PackDetail   */
/* 2026-03-04   5.2  GCH225     UWP-49845: Fix Update ExpQty to Qty in PackDetail   */
/* 2026-03-05   5.3  GCH225     UWP-50008: Fix Update WOD Status for Conso Pick     */
/* 2026-03-13   5.4  JWF011     UWP-50287: Fix Pre-Carton Logic                     */
/************************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtCtnPostUpd_Std] (
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
   , @nPrecedingCartonNo   INT               = 0   
   , @cCartonStatus        NVARCHAR(20)      = ''
   , @bIsLastCarton        BIT               = 0
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

   DECLARE @cSKU                 NVARCHAR(20)
         , @nPackQty             INT
         , @cLabelNo             NVARCHAR(20)
         --, @cRefNo               NVARCHAR(20)
         --, @cRefNo2              NVARCHAR(30)
         --, @cUPC                 NVARCHAR(30)
         --, @cLOTTABLEVALUE       NVARCHAR(60)
         , @cPickDetailKey       NVARCHAR(18)
         , @cNewPickDetailKey    NVARCHAR(18)
         , @nPickQty             INT
         , @nSplitQty            INT
         , @cWorkOrderKey        NVARCHAR(10)
         , @cWorkOrderLineNumber NVARCHAR(5)
         , @cWkOrdSku            NVARCHAR(20)
         , @nQty                 INT
         , @cStatusUpdate        NVARCHAR(10)
         , @cVASLevel            NVARCHAR(50)
         , @nPastCartonNo        INT
         , @cPastCartonStatus    NVARCHAR(20)
         , @bChangeCartonFlag    BIT
   
   DECLARE @OrderList TABLE(
      OrderKey NVARCHAR(10) PRIMARY KEY
   )

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''
   SET @cSKU                  = ''
   SET @nPackQty              = 0
   SET @cLabelNo              = ''
   --SET @cRefNo                = ''
   --SET @cRefNo2               = ''
   --SET @cUPC                  = ''
   --SET @cLOTTABLEVALUE        = ''
   SET @cPickDetailKey        = ''
   SET @cNewPickDetailKey     = ''
   SET @nPickQty              = 0
   SET @nSplitQty             = 0
   SET @cWorkOrderKey         = ''
   SET @cWorkOrderLineNumber  = ''
   SET @cWkOrdSku             = ''
   SET @nQty                  = 0
   SET @cStatusUpdate         = ''
   SET @nPastCartonNo         = 0
   SET @cPastCartonStatus     = ''
   SET @bChangeCartonFlag     = 0

   -- Only happens when user open another hold/closed carton and hold the inprogress carton.
   --PrecedingCartonNo is keep the user inprogress carton no
   --CartonNo is the carton no that user want to open.

   --Below the process is to assign the precedingCartonNo to CartonNo for the rest of the process. due to precedingCartonNo already become hold status.
   --and CartonNo will become inprogress carton will assign to pastCartonNo variable.
   IF @cCartonStatus = 'INPROGRESS' AND @nPrecedingCartonNo > 0
   BEGIN
      SET @bChangeCartonFlag = 1

      SET @nPastCartonNo = @nCartonNo
      SET @nCartonNo = @nPrecedingCartonNo

      SET @cPastCartonStatus = @cCartonStatus
      SET @cCartonStatus = 'HOLD' 
   END

   IF EXISTS ( SELECT 1 
               FROM STORERCONFIG (NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND ConfigKey = 'TPS-UPD_PICKDET'
               AND sValue = '1'
   ) AND @cCartonStatus IN('HOLD','CLOSED')
   BEGIN
      IF @nCartonNo = 1 
      AND ( SELECT IIF(COUNT(CartonNo) = 0, 1, COUNT(CartonNo))
            FROM PACKINFO (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo) = 1
      BEGIN
         IF @cOrderKey <> ''
         BEGIN
            IF EXISTS ( SELECT 1 
                        FROM PICKDETAIL (NOLOCK)
                        WHERE OrderKey = @cOrderKey
                        AND CaseID <> ''
            )
            BEGIN
               UPDATE PICKDETAIL WITH (ROWLOCK)  
               SET CaseID = ''
                 , TrafficCop = NULL  
               WHERE OrderKey = @cOrderKey
               AND [Status] < '9'
            END
         END
         ELSE IF @cLoadKey <> ''
         BEGIN
            IF EXISTS ( SELECT 1 
                        FROM PICKDETAIL PD (NOLOCK)
                        WHERE EXISTS (SELECT 1 
                                      FROM LOADPLANDETAIL LPD (NOLOCK)
                                      WHERE LPD.LoadKey = @cLoadKey
                                      AND LPD.OrderKey = PD.OrderKey
                                     )
                        AND PD.CaseID <> ''
            )
            BEGIN
               UPDATE PD WITH (ROWLOCK)  
               SET PD.CaseID = ''
                 , PD.TrafficCop = NULL  
               FROM PICKDETAIL PD
               WHERE EXISTS (SELECT 1 
                          FROM LOADPLANDETAIL LPD (NOLOCK)
                          WHERE LPD.LoadKey = @cLoadKey
                          AND LPD.OrderKey = PD.OrderKey
                         )
               AND [Status] < '9'
            END
         END     
      END
      ELSE
      BEGIN
         IF @cOrderKey <> ''
         BEGIN
            UPDATE PID WITH (ROWLOCK)  
            SET  CaseID = ''
               , TrafficCop = NULL  
            FROM PICKDETAIL PID
            WHERE OrderKey = @cOrderKey
            AND [Status] < '9'
            AND EXISTS (SELECT 1 
                        FROM PACKDETAIL PAD (NOLOCK)
                        WHERE PAD.PickSlipNo = @cPickSlipNo
                        AND PAD.CartonNo = @nCartonNo
                        AND PAD.LabelNo = PID.CaseID)
         END
         ELSE IF @cLoadKey <> ''
         BEGIN
            UPDATE PID WITH (ROWLOCK)  
            SET  CaseID = ''
               , TrafficCop = NULL  
            FROM PICKDETAIL PID 
            WHERE EXISTS (SELECT 1 
                          FROM LOADPLANDETAIL LPD (NOLOCK)
                          WHERE LPD.LoadKey = @cLoadKey
                          AND LPD.OrderKey = PID.OrderKey
                         )
            AND [Status] < '9'
            AND EXISTS (SELECT 1 
                        FROM PACKDETAIL PAD (NOLOCK)
                        WHERE PAD.PickSlipNo = @cPickSlipNo
                        AND PAD.CartonNo = @nCartonNo
                        AND PAD.LabelNo = PID.CaseID)
         END
      END

      DECLARE CUR_PACKDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
      SELECT SKU
           , SUM(Qty)
           , LabelNo
      FROM PACKDETAIL (NOLOCK) 
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND (@cDropID = '' OR DropID = @cDropID)
      GROUP BY SKU
             , LabelNo
      ORDER BY SKU  

      OPEN CUR_PACKDET  
  
      FETCH NEXT FROM CUR_PACKDET INTO @cSKU
                                     , @nPackQty 
                                     , @cLabelNo
   
      WHILE @@FETCH_STATUS <> -1  
      BEGIN  
         SET @cPickDetailKey = ''

         WHILE @nPackQty > 0
         BEGIN
            IF @bIsDiscrete = 1
            BEGIN
               IF @cPickDetailKey = '' 
               AND EXISTS (
               SELECT 1
               FROM PICKDETAIL PD (NOLOCK)
               WHERE PD.OrderKey = @cOrderKey
               AND (@cDropID = '' OR PD.DropID = @cDropID)
               AND PD.SKU = @cSKU
               AND PD.StorerKey = @cStorerKey
               AND PD.CaseID = @cLabelNo
               AND PD.Qty = @nPackQty
               )
               BEGIN
                  BREAK
               END

               SELECT TOP 1  @nPickQty = PD.Qty
                           , @cPickDetailKey = PD.PickDetailKey
               FROM PICKDETAIL PD (NOLOCK)
               WHERE PD.OrderKey = @cOrderKey
               AND (@cDropID = '' OR PD.DropID = @cDropID)
               AND PD.SKU = @cSKU
               AND PD.StorerKey = @cStorerKey
               AND (PD.CaseID = '' OR PD.CaseID IS NULL)
               AND PD.PickDetailKey > @cPickDetailKey
               ORDER BY PD.PickDetailKey
            END
            ELSE
            BEGIN
               IF @cPickDetailKey = '' 
               AND EXISTS (
               SELECT 1
               FROM PICKDETAIL PD (NOLOCK)
               WHERE EXISTS(SELECT 1 
                            FROM LOADPLANDETAIL LPD (NOLOCK)
                            WHERE LPD.LoadKey = @cLoadKey
                            AND LPD.OrderKey = PD.OrderKey
                           )
               AND (@cDropID = '' OR PD.DropID = @cDropID)
               AND PD.SKU = @cSKU
               AND PD.StorerKey = @cStorerKey
               AND PD.CaseID = @cLabelNo
               AND PD.Qty = @nPackQty
               )
               BEGIN
                  BREAK
               END

               SELECT TOP 1  @nPickQty = PD.Qty
                           , @cPickDetailKey = PD.PickDetailKey
               FROM PICKDETAIL PD (NOLOCK)
               WHERE EXISTS(SELECT 1 
                            FROM LOADPLANDETAIL LPD (NOLOCK)
                            WHERE LPD.LoadKey = @cLoadKey
                            AND LPD.OrderKey = PD.OrderKey
                           )
               AND (@cDropID = '' OR PD.DropID = @cDropID)
               AND PD.SKU = @cSKU
               AND PD.StorerKey = @cStorerKey
               AND (PD.CaseID = '' OR PD.CaseID IS NULL)
               --AND PD.PickDetailKey > @cPickDetailKey
               ORDER BY PD.OrderKey ASC, PD.PickDetailKey ASC
            END

            IF @@ROWCOUNT = 0
               BREAK

            IF @nPickQty <= @nPackQty  
            BEGIN  
               UPDATE PICKDETAIL WITH (ROWLOCK)  
               SET CaseID = @cLabelNo
                 , TrafficCop = NULL  
               WHERE PickDetailKey = @cPickDetailKey  

               IF @@ERROR <> 0  
               BEGIN  
                  SET @n_Continue = 3
                  SET @n_ErrNo = 13351
                  SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Update CaseID in Pickdetail Table Failed.'
                  GOTO EXIT_SP 
               END  

               SELECT @nPackQty = @nPackQty - @nPickQty  
            END  
            ELSE -- pickqty > packqty  
            BEGIN   
               SELECT @nSplitQty = @nPickQty - @nPackQty  

               EXECUTE nspg_GetKey  
                    'PICKDETAILKEY'
                  , 10  
                  , @cNewPickDetailKey   OUTPUT 
                  , @b_Success           OUTPUT 
                  , @n_ErrNo             OUTPUT 
                  , @c_ErrMsg            OUTPUT

               IF @b_Success <> 1
               BEGIN  
                  GOTO EXIT_SP
               END  
  
               INSERT PICKDETAIL  
                     ( PickDetailKey
                     , CaseID
                     , PickHeaderKey
                     , OrderKey
                     , OrderLineNumber
                     , Lot
                     , StorerKey
                     , Sku
                     , AltSku
                     , UOM
                     , UOMQty
                     , Qty
                     , QtyMoved
                     , [Status]
                     , DropID
                     , Loc
                     , ID
                     , PackKey
                     , UpdateSource
                     , CartonGroup
                     , CartonType
                     , ToLoc
                     , DoReplenish
                     , ReplenishZone
                     , DoCartonize
                     , PickMethod
                     , WaveKey
                     , EffectiveDate
                     , OptimizeCop
                     , ShipFlag
                     , PickSlipNo
                     , Channel_ID
                     , TaskDetailKey
                     )  
               SELECT  @cNewPickDetailKey  
                     , ''
                     , PickHeaderKey
                     , OrderKey
                     , OrderLineNumber
                     , Lot
                     , StorerKey
                     , Sku
                     , AltSku
                     , UOM
                     , IIF(UOM ='6',@nSplitQty, UOMQty)
                     , @nSplitQty
                     , QtyMoved
                     , [Status]
                     , DropID
                     , Loc
                     , ID
                     , PackKey
                     , UpdateSource
                     , CartonGroup
                     , CartonType
                     , ToLoc
                     , DoReplenish
                     , ReplenishZone
                     , DoCartonize
                     , PickMethod
                     , WaveKey
                     , EffectiveDate
                     , '9'
                     , ShipFlag
                     , PickSlipNo
                     , Channel_ID
                     , TaskDetailKey
               FROM PICKDETAIL (NOLOCK)  
               WHERE PickDetailKey = @cPickDetailKey  
   
               IF @@ERROR <> 0  
               BEGIN  
                  SET @n_Continue = 3
                  SET @n_ErrNo = 13352
                  SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to insert new splitted line into PickDetail Table. '
                  GOTO EXIT_SP 
               END  
  
               UPDATE PICKDETAIL WITH (ROWLOCK)  
               SET  CaseID = @cLabelNo
                  , Qty = @nPackQty  
                  , UOMQty = IIF(UOM ='6',@nPackQty, UOMQty)
                  , TrafficCop = NULL  
                WHERE PickDetailKey = @cPickDetailKey  
             
               IF @@ERROR <> 0
               BEGIN  
                  SET @n_Continue = 3
                  SET @n_ErrNo = 13353
                  SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to update CaseID into Pickdetail Table.'
                  GOTO EXIT_SP 
               END  
  
               SET @nPackQty = 0  
            END  
         END
         FETCH NEXT FROM CUR_PACKDET INTO @cSKU
                                        , @nPackQty 
                                        , @cLabelNo
      END
      CLOSE CUR_PACKDET
      DEALLOCATE CUR_PACKDET
      
      --Handle for Pre-Cartonization
      IF EXISTS ( SELECT 1 
                  FROM PACKDETAIL (NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo               
                  AND ExpQty > 0
      ) AND (SELECT SUM(Qty)
             FROM PACKDETAIL (NOLOCK) 
             WHERE PickSlipNo = @cPickSlipNo
             AND CartonNo = @nCartonNo
             AND (@cDropID = '' OR DropID = @cDropID)
            ) > 0
      BEGIN
         UPDATE PACKDETAIL WITH(ROWLOCK)
         SET ExpQty = Qty
           , EditDate = GETDATE()
           , EditWho = @c_UserID
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND Qty > 0
      END
   END

   -- if VAS Level is empty which is SKU level, or CartonStatus is closed then only proceed to update the WOD.Status)
   IF EXISTS(  SELECT 1
               FROM STORERCONFIG (NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND ConfigKey = 'TPS-VAS'
               AND sValue IN ('1', '3')
   )
   BEGIN
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

      IF EXISTS ( SELECT 1
                  FROM WORKORDERDETAIL WOD (NOLOCK)
                  LEFT JOIN CODELKUP CLK (NOLOCK)
                  ON WOD.[Type] = CLK.Code
                  WHERE CLK.LISTNAME = 'WKOrdType'
                  AND WOD.[Status] <= '9'
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
                              AND PD.CartonNo = @nCartonNo
                              AND PD.SKU = WOD.Sku
                              )
      ) 
      BEGIN
         DECLARE CUR_UPDVAS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT  WorkOrderKey
               , WorkOrderLineNumber
               , Sku
         FROM WORKORDERDETAIL WOD (NOLOCK)
         LEFT JOIN CODELKUP CLK (NOLOCK)
         ON WOD.[Type] = CLK.Code
         WHERE CLK.LISTNAME = 'WKOrdType'
         AND WOD.[Status] <= '9'
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
                     AND PD.CartonNo = @nCartonNo
                     AND PD.SKU = WOD.Sku
                     )

         OPEN CUR_UPDVAS
         FETCH NEXT FROM CUR_UPDVAS INTO @cWorkOrderKey
                                       , @cWorkOrderLineNumber
                                       , @cWkOrdSku
         WHILE @@FETCH_STATUS = 0
         BEGIN
            SET @cStatusUpdate = '3'

            IF (  SELECT SUM(Qty)
                  FROM PACKDETAIL (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND SKU = @cWkOrdSku
                  AND PickSlipNo = @cPickSlipNo
            ) = ( SELECT SUM(PD.Qty)
                  FROM PICKDETAIL PD (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND EXISTS (SELECT 1 
                              FROM @OrderList t
                              WHERE t.OrderKey = PD.OrderKey
                              )
                  AND PD.SKU = @cWkOrdSku
            )
            AND @cCartonStatus = 'CLOSED'
            AND NOT EXISTS(SELECT 1
                           FROM PACKINFO P (NOLOCK)
                           INNER JOIN PACKDETAIL PD (NOLOCK)
                           ON PD.PickSlipNo = P.PickSlipNo
                           AND PD.CartonNo = P.CartonNo
                           WHERE P.PickSlipNo = @cPickSlipNo
                           AND P.CartonStatus <> 'CLOSED'
                           AND PD.SKU = @cWkOrdSku
            ) 
            BEGIN
               SET @cStatusUpdate = '9'
            END

            UPDATE WORKORDERDETAIL WITH (ROWLOCK)
            SET [Status] = @cStatusUpdate
            WHERE WorkOrderKey = @cWorkOrderKey
            AND WorkOrderLineNumber = @cWorkOrderLineNumber
 
            IF @@ERROR <> 0
            BEGIN
               SET @n_Continue = 3
               SET @n_ErrNo = 13354
               SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to update Status in WorkOrderDetail Table.'
               GOTO EXIT_SP 
            END

            FETCH NEXT FROM CUR_UPDVAS INTO @cWorkOrderKey
                                          , @cWorkOrderLineNumber
                                          , @cWkOrdSku
         END
         CLOSE CUR_UPDVAS
         DEALLOCATE CUR_UPDVAS

         IF @cWorkOrderKey <> '' AND @bIsLastCarton = 1
         BEGIN
            UPDATE WORKORDER WITH (ROWLOCK)
            SET Status = '9'
            WHERE WorkOrderKey = @cWorkOrderKey

            IF @@ERROR <> 0
            BEGIN
               SET @n_Continue = 3
               SET @n_ErrNo = 13356
               SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to update Status in WorkOrder Table.'
               GOTO EXIT_SP 
            END
         END
      END

      IF @bChangeCartonFlag = 1
      BEGIN
         IF EXISTS ( SELECT 1
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
                                 AND PD.CartonNo = @nPastCartonNo
                                 AND PD.SKU = WOD.Sku
                                 )
         ) 
         BEGIN
            DECLARE CUR_UPDVAS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT  WorkOrderKey
                  , WorkOrderLineNumber
                  , Sku
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
                        AND PD.CartonNo = @nPastCartonNo
                        AND PD.SKU = WOD.Sku
                        )

            OPEN CUR_UPDVAS
            FETCH NEXT FROM CUR_UPDVAS INTO @cWorkOrderKey
                                          , @cWorkOrderLineNumber
                                          , @cWkOrdSku
            WHILE @@FETCH_STATUS = 0
            BEGIN
               SET @cStatusUpdate = '3'

               UPDATE WORKORDERDETAIL WITH (ROWLOCK)
               SET [Status] = @cStatusUpdate
               WHERE WorkOrderKey = @cWorkOrderKey
               AND WorkOrderLineNumber = @cWorkOrderLineNumber

               IF @@ERROR <> 0
               BEGIN
                  SET @n_Continue = 3
                  SET @n_ErrNo = 13355
                  SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to update Status in WorkOrderDetail Table.'
                  GOTO EXIT_SP 
               END

               FETCH NEXT FROM CUR_UPDVAS INTO @cWorkOrderKey
                                             , @cWorkOrderLineNumber
                                             , @cWkOrdSku
            END
            CLOSE CUR_UPDVAS
            DEALLOCATE CUR_UPDVAS
         END
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
