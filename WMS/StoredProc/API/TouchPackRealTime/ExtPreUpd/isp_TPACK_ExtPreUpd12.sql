SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtPreUpd12                                        */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Extended Pre Update for Logitech Requirement                 */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-08-17   1.0  GCH225     UWP-27857: Created                               */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtPreUpd12] (
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
   , @cLabelNo             NVARCHAR(20)      = ''
   , @cLabelLine           NVARCHAR(20)      = ''
   , @nQty                 INT               = 0       
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

   DECLARE @cSerialNoKey      NVARCHAR(10)
         , @cSerialNo         NVARCHAR(50)  
         , @cStatus           NVARCHAR(10)
         , @cLotNo            NVARCHAR(10)
         , @cID               NVARCHAR(18)
         , @cExternStatus_SN  NVARCHAR(10)  
         , @cOrderLineNumber  NVARCHAR(5)
         , @nSerialQty        INT
         , @nTQty             INT
         , @cSerialNoType     NVARCHAR(1)
         , @cParentTrackingID NVARCHAR(30)
         , @nTrackingIDKey    BIGINT
         , @cPickMethod       NVARCHAR(10)
   
   DECLARE @MInP TABLE                                               
         (  RowRef            INT            NOT NULL IDENTITY(1,1) PRIMARY KEY
         ,  TrackingIDKey     BIGINT         NOT NULL DEFAULT(0)          
         ,  SerialNo          NVARCHAR(30)   NOT NULL    
         ,  ParentTrackingID  NVARCHAR(30)   NOT NULL DEFAULT('')          
         ) 
   
   DECLARE @SCANSERIAL TABLE                                               
         (  RowRef         INT            NOT NULL IDENTITY(1,1) PRIMARY KEY 
         ,  TrackingIDKey  BIGINT         NOT NULL DEFAULT(0)            
         ,  SerialNo       NVARCHAR(30)   NOT NULL                  
         ,  CartonNo       INT            NOT NULL DEFAULT(0)   
         ,  LabelLine      NVARCHAR(5)    NOT NULL DEFAULT('')  
         ,  Qty            INT            NOT NULL DEFAULT(0)  
         ,  PickSlipNo     NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  Orderkey       NVARCHAR(10)   NOT NULL DEFAULT('') 
         ,  [Status]       NVARCHAR(1)    NOT NULL DEFAULT('0')     
         ) 

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = ''
   SET @cSerialNoKey       = ''
   SET @cSerialNo          = ''
   SET @cStatus            = ''
   SET @cLotNo             = ''
   SET @cID                = ''
   SET @cExternStatus_SN   = ''

   SELECT @cSerialNo = ISNULL([value], '')
   FROM OPENJSON(@cInputValue2)
   WITH ([value] NVARCHAR(100) '$') J

   SET @cSerialNoType = RIGHT(RTRIM(@cSerialNo),1) 
   
   IF @cSerialNoType IN ('P')      
   BEGIN  
      INSERT INTO @SCANSERIAL ( TrackingIDKey, SerialNo, Qty )
      SELECT TID.TrackingIDKey
           , TID.TrackingID
           , TID.Qty 
      FROM TRACKINGID TID WITH (NOLOCK)
      WHERE TID.ParentTrackingID = @cSerialNo
      AND   TID.Storerkey = @cStorerkey
      AND   TID.PickMethod <> 'Loose'               
      AND   TID.[Status] >= 1 AND TID.[Status] <= 9 
      ORDER BY TID.TrackingID
   END
   ELSE
   BEGIN
      INSERT INTO @SCANSERIAL ( SerialNo, Qty )
      VALUES (@cSerialNo, @nQty)

      IF @cSerialNoType IN ('M') 
      BEGIN
         SET @cParentTrackingID = ''  
         SELECT TOP 1 @cParentTrackingID = ParentTrackingID
         FROM TRACKINGID TID WITH (NOLOCK)
         WHERE TID.TrackingID = @cSerialNo
         AND   TID.Storerkey = @cStorerkey
         AND   TID.[Status]  = '1'                      
         ORDER BY TID.TrackingIDKey

         IF @cParentTrackingID <> ''
         BEGIN
            INSERT INTO @MInP ( TrackingIDKey, SerialNo, ParentTrackingID )
            SELECT TID.TrackingIDKey
                 , TID.TrackingID
                 , TID.ParentTrackingID 
            FROM TRACKINGID TID WITH (NOLOCK)
            WHERE TID.ParentTrackingID = @cParentTrackingID
            AND   TID.Storerkey = @cStorerkey
            AND   TID.[Status]  = '1'                  
            ORDER BY TID.TrackingIDKey
         END
      END
   END

   IF OBJECT_ID('tempdb..#TMP_SNInfo','U') IS NULL
   BEGIN
      CREATE TABLE #TMP_SNInfo  
         (  SerialNo       NVARCHAR(20)   NOT NULL DEFAULT('')  PRIMARY KEY
         ,  LotNo          NVARCHAR(10)   NULL DEFAULT('')
         ,  ID             NVARCHAR(18)   NULL DEFAULT('')
         ,  ExternStatus   NVARCHAR(10)   NULL DEFAULT('0')
         ,  Status         NVARCHAR(10)   NULL DEFAULT('0')
         )
   END
   ELSE
   BEGIN
      TRUNCATE TABLE #TMP_SNInfo
   END

   EXECUTE dbo.isp_PrePackSN01
      @c_PickSlipNo = @cPickSlipNo      
    , @c_StorerKey  = @cStorerKey       
    , @c_Sku        = @cSKU              
    , @c_SerialNo   = @cSerialNo           
    , @b_Success    = @b_Success OUTPUT 
    , @n_Err        = @n_ErrNo   OUTPUT 
    , @c_ErrMsg     = @c_ErrMsg  OUTPUT 

   IF @b_Success = 0
   BEGIN
      SET @n_Continue  = 3    
      GOTO EXIT_SP
   END

   SELECT TOP 1
         @cLotNo           = ISNULL(RTRIM(LotNo), '')
      ,  @cID              = ISNULL(RTRIM(ID), '')
      ,  @cExternStatus_SN = ISNULL(RTRIM(ExternStatus), '')
      ,  @cStatus          = ISNULL(RTRIM(Status), '')
   FROM #TMP_SNInfo
   WHERE SerialNo = @cSerialNo

   DECLARE CUR_SER CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT PICK_ORD.OrderLineNumber
         ,Qty = PICK_ORD.QtyAllocated - ISNULL(SER.Qty,0)
   FROM (   SELECT PD.OrderLineNumber
                  ,QtyAllocated = ISNULL(SUM(PD.Qty),0)
            FROM PICKDETAIL PD WITH (NOLOCK)
            WHERE PD.Orderkey = @cOrderKey
            AND PD.Storerkey = @cStorerKey
            AND PD.Sku = @cSKU
            AND PD.DropID = @cDropID
            GROUP BY PD.OrderLineNumber
         ) PICK_ORD
   LEFT JOIN ( SELECT SER.OrderLineNumber
                     ,Qty = ISNULL(SUM(SER.Qty),0)
               FROM SERIALNO   SER WITH (NOLOCK) 
               JOIN PACKDETAIL PD  WITH (NOLOCK) 
               ON (SER.PickSlipNo = PD.PickSlipNo)
               AND(SER.CartonNo   = PD.CartonNo)
               AND(SER.LabelLine  = PD.LabelLine)
               AND(SER.Storerkey  = PD.Storerkey)
               AND(SER.Sku        = PD.Sku)
               JOIN PACKHEADER PH  WITH (NOLOCK) 
               ON (PH.PickSlipNo = PD.PickSlipNo) --PY01								   
               WHERE SER.Orderkey = @cOrderKey
               AND SER.Storerkey = @cStorerKey
               AND SER.Sku = @cSKU
               AND PD.DropID = @cDropID
               AND SER.ExternStatus <> 'CANC'
            AND PH.Orderkey = @cOrderKey                              --PY01
               GROUP BY SER.OrderLineNumber
            ) SER ON  (PICK_ORD.OrderLineNumber = SER.OrderLineNumber)
   WHERE PICK_ORD.QtyAllocated - ISNULL(SER.Qty,0) > 0

   OPEN CUR_SER
   FETCH NEXT FROM CUR_SER INTO @cOrderLineNumber
                              , @nSerialQty

   WHILE @@FETCH_STATUS <> -1 AND @nQty > 0 
   BEGIN
      SET @nTQty = @nQty

      IF @nQty > @nSerialQty
      BEGIN
         SET @nTQty = @nSerialQty
      END

      SET @nQty = @nQty - @nTQty

      EXECUTE nspg_GetKey 
              @KeyName     = 'SERIALNO'
            , @fieldlength = 10
            , @keystring   = @cSerialNoKey   OUTPUT
            , @b_success   = @b_Success      OUTPUT
            , @n_err       = @n_ErrNo        OUTPUT
            , @c_errmsg    = @c_ErrMsg       OUTPUT
            , @b_resultset = 0
            , @n_batch     = 1


      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3                                                                                              
         SET @n_ErrNo = 60100                                                                                         
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') -- 'Failed to get SerialNo Key.'                                                                                                  
         GOTO EXIT_SP        
      END
                           
      INSERT INTO SERIALNO
         (  SerialNoKey
         ,  SerialNo
         ,  Orderkey
         ,  OrderLineNumber
         ,  Storerkey
         ,  Sku
         ,  Qty
         ,  LotNo
         ,  ID
         ,  Status
         ,  ExternStatus
         ,  PickSlipNo
         ,  CartonNo
         ,  LabelLine
         )
      VALUES 
         (  @cSerialNoKey
         ,  @cSerialNo
         ,  @cOrderKey
         ,  @cOrderLineNumber
         ,  @cStorerKey
         ,  @cSKU
         ,  @nTQty
         ,  @cLotNo
         ,  @cID
         ,  @cStatus
         ,  @cExternStatus_SN
         ,  @cPickSlipNo
         ,  @nCartonNo
         ,  @cLabelLine
         )

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 60110  
         SET @c_ErrMsg= API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') -- 'Error Insert into SERIALNO Table.'
         GOTO EXIT_SP
      END

      FETCH NEXT FROM CUR_SER INTO @cOrderLineNumber
                                 , @nSerialQty
   END 
   CLOSE CUR_SER
   DEALLOCATE CUR_SER

   IF OBJECT_ID('tempdb..#TMP_SNInfo','U') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_SNInfo
   END
   
   IF EXISTS (SELECT 1 FROM @MInP)
   BEGIN
      DECLARE CUR_MInP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT TrackingIDKey
      FROM @MInP

      OPEN CUR_MInP

      FETCH NEXT FROM CUR_MInP INTO @nTrackingIDKey

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         UPDATE TRACKINGID
            SET [Status]   = '9'
               ,PickMethod = 'Loose'
               ,EditWho    = @c_UserID
               ,EditDate   = GETDATE()
               ,TrafficCop = NULL
         WHERE TrackingIDKey = @nTrackingIDKey                  

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 60115
            SET @c_ErrMsg= API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') -- 'Error Update TRACKINGID Table.'
            GOTO EXIT_SP
         END
         FETCH NEXT FROM CUR_MInP INTO @nTrackingIDKey
      END
      CLOSE CUR_MInP
      DEALLOCATE CUR_MInP
   END

   IF @cSerialNoType = 'P'
   BEGIN
      SET @cPickMethod = 'Full'
      DECLARE CUR_PSN CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT TrackingIDKey
      FROM @SCANSERIAL

      OPEN CUR_PSN

      FETCH NEXT FROM CUR_PSN INTO @nTrackingIDKey

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         UPDATE TRACKINGID
            SET [Status]   = '9'
               ,PickMethod = @cPickMethod
               ,EditWho    = @c_UserID
               ,EditDate   = GETDATE()
               ,TrafficCop = NULL
         WHERE TrackingIDKey = @nTrackingIDKey

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 60135
            SET @c_ErrMsg= API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') -- 'Error Update TRACKINGID Table.'
            GOTO EXIT_SP
         END
         FETCH NEXT FROM CUR_PSN INTO @nTrackingIDKey
      END
      CLOSE CUR_PSN
      DEALLOCATE CUR_PSN
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
GRANT EXECUTE ON [API].[isp_TPACK_ExtPreUpd12] TO NSQL
GO