SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtPreUpd05                                        */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Extended Pre Update for JIT Orders - Insert TransmitLog      */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-12-06   1.0  Sean     Cloned from isp_TPS_ExtUpd05 (TPS-970)           */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtPreUpd05] (
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

   DECLARE @n_Continue        INT            = 1  
         , @n_StartCnt        INT            = @@TRANCOUNT  

   DECLARE @cJITOrders        NVARCHAR(20)
         , @nPickslipPackQty  INT
         , @nPickslipPickQty  INT
         , @cCartonNoStr      NVARCHAR(5)
         , @bSuccess          INT
         , @b_Debug           INT
         , @cTransmitLogKey   NVARCHAR(20)
         , @c_QCmdClass       NVARCHAR(10)   = ''
         , @cEPC              NVARCHAR(100)

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = ''
   SET @cJITOrders         = ''
   SET @nPickslipPackQty   = 0
   SET @nPickslipPickQty   = 0
   SET @cCartonNoStr       = ''
   SET @bSuccess           = 0
   SET @b_Debug            = 0
   SET @cTransmitLogKey    = ''
   SET @cEPC               = ''

   -- Get OrderKey from PickHeader if not provided
   IF ISNULL(@cOrderKey, '') = ''
   BEGIN
      SELECT @cOrderKey = OrderKey
      FROM PickHeader (NOLOCK)
      WHERE PickHeaderkey = @cPickSlipNo
   END

   IF ISJSON(@cInputValue2) = 1 
   AND (SELECT COUNT(1) 
               FROM OPENJSON(@cInputValue2) 
               WITH ([value] NVARCHAR(100) '$')
   ) = 1
   BEGIN
      SELECT @cEPC = [value]
      FROM OPENJSON(@cInputValue2)
      WITH ([value] NVARCHAR(100) '$') J

      INSERT INTO PACKSERIALNO( PickSlipNo
                              , CartonNo
                              , LabelNo
                              , LabelLine
                              , StorerKey
                              , SKU
                              , SerialNo
                              , Qty
                              , PickDetailKey
                              , AddWho
                              , AddDate
                              , EditWho
                              , EditDate)    
                        VALUES( @cPickSlipNo
                              , @nCartonNo
                              , @cLabelNo
                              , @cLabelLine
                              , @cStorerKey
                              , @cSKU
                              , @cEPC
                              , 1
                              , ''
                              , @c_UserID
                              , GETDATE()
                              , @c_UserID
                              , GETDATE())  

      IF @@ERROR <> 0         
      BEGIN         
         SET @b_Success = 0;
         SET @n_ErrNo = 15651        
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo ,@cLangCode ,'DSP') -- 'Failed to insert into PACKSERIALNO
         GOTO EXIT_SP        
      END
   END

   -- Check TPS-JITOrders config
   EXEC nspGetRight    
      @c_Facility   = @cFacility   
   ,  @c_StorerKey  = @cStorerKey   
   ,  @c_sku        = ''    
   ,  @c_ConfigKey  = 'TPS-JITOrders'    
   ,  @b_Success    = @bSuccess        OUTPUT    
   ,  @c_authority  = @cJITOrders      OUTPUT    
   ,  @n_err        = @n_ErrNo         OUTPUT    
   ,  @c_errmsg     = @c_ErrMsg        OUTPUT  
   
   IF ISNULL(@cJITOrders,'') = '1'
   BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM Transmitlog2 (NOLOCK)
                     WHERE TableName = 'WSCRSOLBLJTV2'
                        AND Key1 = @cOrderKey 
                        AND Key2 = (@nCartonNo + 1)
                        AND Key3 = @cStorerKey)
      BEGIN

         -- Calculate packed qty from closed cartons
         SELECT @nPickslipPackQty = ISNULL(SUM(PD.Qty),0)   
         FROM PackDetail PD WITH (NOLOCK)   
         JOIN packInfo PKI WITH (NOLOCK) 
         ON (PD.PickSlipNo = PKI.PickSlipNo AND PD.CartonNo = PKI.CartonNo)  
         WHERE PD.pickslipno = @cPickSlipNo 
            AND PD.Storerkey = @cStorerKey 
            AND PKI.CartonStatus = 'Closed'  

         DECLARE @nTtlPickQty  INT = 0

         --Calculate total Pick Qty    
         DECLARE @PickQtyStatus TABLE(
            TtlPickedQty INT,
            Sku NVARCHAR(20),
            [Status] NVARCHAR(10)
         )

         IF @bIsDiscrete = 1  -- Discrete mode
         BEGIN
            INSERT INTO @PickQtyStatus (TtlPickedQty, Sku, [Status])
            SELECT SUM(Qty), Sku, [Status] 
            FROM PICKDETAIL (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND OrderKey = @cOrderKey
            AND (@cDropID = '' OR DropID = @cDropID)
            GROUP BY Sku, [Status]
         END
         ELSE  -- Consolidate mode
         BEGIN
            IF @bIsCustom = 0
            BEGIN
                  -- Normal consolidate mode
                  INSERT INTO @PickQtyStatus (TtlPickedQty, Sku, [Status])
                  SELECT SUM(Qty), Sku, [Status] 
                  FROM PICKDETAIL PD (NOLOCK)
                  WHERE PD.StorerKey = @cStorerKey
                  AND EXISTS (SELECT 1 
                              FROM LOADPLANDETAIL LPD (NOLOCK)
                              WHERE LPD.OrderKey = PD.OrderKey
                              AND LPD.LoadKey = @cLoadKey
                  )
                  AND (@cDropID = '' OR PD.DropID = @cDropID)
                  GROUP BY Sku, [Status]
            END
            ELSE
            BEGIN
                  -- Custom consolidate mode
                  INSERT INTO @PickQtyStatus (TtlPickedQty, Sku, [Status])
                  SELECT SUM(Qty), Sku, [Status] 
                  FROM PICKDETAIL PD (NOLOCK)
                  WHERE PD.StorerKey = @cStorerKey
                  AND PD.PickSlipNo = @cPickSlipNo
                  GROUP BY Sku, [Status]
            END
         END

         -- Apply config-based filtering for Status '4' (Short Picked)
         IF NOT EXISTS (SELECT 1
                        FROM STORERCONFIG (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                        AND ConfigKey = 'TPS-ShowShortPickQty' 
                        AND sValue = '1'
         )
         BEGIN
            DELETE FROM @PickQtyStatus WHERE [Status] = '4'
         END

         -- Calculate total Pick Qty from filtered results
         SELECT @nTtlPickQty = SUM(TtlPickedQty)
         FROM @PickQtyStatus

         IF @nPickslipPackQty <> @nTtlPickQty
         BEGIN
            SET @cCartonNoStr = CAST(@nCartonNo + 1 AS NVARCHAR(5))

            -- Insert transmitlog2  
            EXECUTE ispGenTransmitLog2   
               @c_TableName      = 'WSCRSOLBLJTV2',   
               @c_Key1           = @cOrderKey,   
               @c_Key2           = @cCartonNoStr,   
               @c_Key3           = @cStorerKey,   
               @c_TransmitBatch  = '',   
               @b_Success        = @bSuccess      OUTPUT,      
               @n_err            = @n_ErrNo       OUTPUT,      
               @c_errmsg         = @c_ErrMsg      OUTPUT      
   
            IF @bSuccess <> 1      
            BEGIN
               SET @n_Continue = 3
               GOTO EXIT_SP
            END
   
            SELECT @cTransmitLogKey = transmitlogkey  
            FROM dbo.TRANSMITLOG2 WITH (NOLOCK)  
            WHERE tablename = 'WSCRSOLBLJTV2'  
               AND key1 = @cOrderKey
               AND key2 = @cCartonNoStr
               AND key3 = @cStorerKey  

            EXEC dbo.isp_QCmd_WSTransmitLogInsertAlert   
               @c_QCmdClass         = @c_QCmdClass,   
               @c_FrmTransmitlogKey = @cTransmitLogKey,   
               @c_ToTransmitlogKey  = @cTransmitLogKey,   
               @b_Debug             = @b_Debug,   
               @b_Success           = @bSuccess         OUTPUT,   
               @n_Err               = @n_ErrNo          OUTPUT,   
               @c_ErrMsg            = @c_ErrMsg         OUTPUT   

            IF @bSuccess <> 1      
            BEGIN
               SET @n_Continue = 3
               GOTO EXIT_SP
            END
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
GO