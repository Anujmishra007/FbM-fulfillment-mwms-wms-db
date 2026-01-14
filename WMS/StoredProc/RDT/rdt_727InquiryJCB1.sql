SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_727InquiryJCB1                                     */
/* Copyright      : Maersk                                                 */
/*                                                                         */
/*                                                                         */
/* Date            Author     Purposes                                     */
/* 08/01/2026      PPA374     Unloads DropID                        	     */
/***************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_727InquiryJCB1] (
   @nMobile      INT,  
   @nFunc        INT,  
   @nStep        INT,  
   @cLangCode    NVARCHAR(3),  
   @cStorerKey   NVARCHAR(15),  
   @cOption      NVARCHAR(1),  
   @cParam1      NVARCHAR(60),  
   @cParam2      NVARCHAR(60),  
   @cParam3      NVARCHAR(60),  
   @cParam4      NVARCHAR(60),  
   @cParam5      NVARCHAR(60),  
   @c_oFieled01  NVARCHAR(20) OUTPUT,  
   @c_oFieled02  NVARCHAR(20) OUTPUT,  
   @c_oFieled03  NVARCHAR(20) OUTPUT,  
   @c_oFieled04  NVARCHAR(20) OUTPUT,  
   @c_oFieled05  NVARCHAR(20) OUTPUT,  
   @c_oFieled06  NVARCHAR(20) OUTPUT,  
   @c_oFieled07  NVARCHAR(20) OUTPUT,  
   @c_oFieled08  NVARCHAR(20) OUTPUT,  
   @c_oFieled09  NVARCHAR(20) OUTPUT,  
   @c_oFieled10  NVARCHAR(20) OUTPUT,  
   @c_oFieled11  NVARCHAR(20) OUTPUT,  
   @c_oFieled12  NVARCHAR(20) OUTPUT,  
   @nNextPage    INT          OUTPUT,  
   @nErrNo       INT          OUTPUT,  
   @cErrMsg      NVARCHAR(20) OUTPUT  
)
AS

IF @nFunc = 727 and @nStep = 2
BEGIN

   -- Handling transaction
   BEGIN TRAN

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @nErrNo = 0

   SET @c_oFieled01 = ''
   SET @c_oFieled02 = ''
   SET @c_oFieled03 = ''
   SET @c_oFieled04 = ''
   SET @c_oFieled05 = ''
   SET @c_oFieled06 = ''
   SET @c_oFieled07 = ''
   SET @c_oFieled08 = ''
   SET @c_oFieled09 = ''
   SET @c_oFieled10 = ''
   SET @c_oFieled11 = ''
   SET @c_oFieled12 = ''

   DECLARE @cMBOLKey           AS NVARCHAR(20)
   DECLARE @cMBOLKeyNew        AS NVARCHAR(20)
   DECLARE @cFacility          AS NVARCHAR(20)
   DECLARE @cOrderKey          AS NVARCHAR(20)
   DECLARE @nRollBack          AS INT = 0
   DECLARE @nCounter           AS INT = 0
   DECLARE @prevParentOrderKey AS NVARCHAR(20)
   DECLARE @cMBOLLine          AS NVARCHAR(5)

   IF @cParam1 = ''
   BEGIN
   	  --Info
      SET @c_oFieled01 = 'Need DropID!'
	  SET @nRollBack = 1
      GOTO RollBackTran
   END

   IF @cParam2 = ''
   BEGIN
   	  --Info
	  SET @c_oFieled01 = 'Need Reference!'
      SET @nRollBack = 1
      GOTO RollBackTran
   END

   IF EXISTS (
      SELECT 1
      FROM rdt.rdtScanToTruck ST WITH (NOLOCK)
         INNER JOIN ORDERS O WITH (NOLOCK)
            ON O.OrderKey = ST.OrderKey
      WHERE ST.URNNo = @cParam1
         AND O.StorerKey = @cStorerKey
   )
   BEGIN   
      SELECT TOP 1 
	     @cMBOLKey = O.MBOLKey,
		 @cOrderKey = O.OrderKey
      FROM dbo.PICKDETAIL PD WITH (NOLOCK)
         INNER JOIN dbo.ORDERS O WITH (NOLOCK)
            ON O.OrderKey = PD.OrderKey
      WHERE PD.DropID = @cParam1
         AND O.StorerKey = @cStorerKey
	  
	  IF (SELECT COUNT(DISTINCT OrderKey) FROM dbo.PICKDETAIL WITH(NOLOCK) WHERE DropID = @cParam1) > 1
	  BEGIN
	  
         --Info
         SET @c_oFieled01 = 'DropID got more'
		 SET @c_oFieled02 = 'than 1 order'
		 SET @c_oFieled03 = 'Cannot unload'
		 SET @nRollBack = 1
		 GOTO RollBackTran
	  END

	  IF @cOrderKey IS NULL OR @cMBOLKey IS NULL
	  BEGIN

         --Info
         SET @c_oFieled01 = 'No order for DropID'
		 SET @nRollBack = 1
		 GOTO RollBackTran
	  END

	  SELECT TOP 1 @cFacility = Facility FROM dbo.ORDERS WITH(NOLOCK) WHERE OrderKey = @cOrderKey

	  IF NOT EXISTS (
	  SELECT 1 
	  FROM dbo.MBOL M WITH(NOLOCK) 
	  WHERE MbolKey = @cMBOLKey
	     AND Facility = @cFacility
		 AND Status <> '0'
	  )
	  BEGIN
	     DELETE FROM rdt.rdtScanToTruck
	     WHERE URNNo = @cParam1

         --Info
         SET @c_oFieled01 = 'DropID is unloaded'

		    BEGIN
               DECLARE @n_Err       INT
               DECLARE @c_ErrMsg    NVARCHAR( 250)
               DECLARE @b_Success   INT

               DECLARE @cChildOrderKey  NVARCHAR( 10)
               DECLARE @cParentOrderKey NVARCHAR( 10)
               DECLARE @cExternOrderKey NVARCHAR( 50)
               DECLARE @cOrderLineNumber NVARCHAR( 5)
               DECLARE @cStatus         NVARCHAR( 10)
               DECLARE @nQtyAllocated   INT
               DECLARE @nQtyPicked      INT
               DECLARE @nQty            INT

               /***********************************************************************************************
                Orders, OrderInfo, OrderDetail, PickDetail, RefKeyLookup, LoadPlanDetail, MBOLDetail
               ***********************************************************************************************/
			   -- Loop parent PickDetail (could be multiple orders)
               DECLARE @curPD CURSOR 
               SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT O.ExternOrderKey, PD.OrderKey, PD.OrderLineNumber, PD.Status, SUM( PD.QTY)
                  FROM dbo.Orders O WITH (NOLOCK)
                     JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.OrderKey = O.OrderKey)
                  WHERE O.StorerKey = @cStorerKey
                     AND O.Facility = @cFacility
                     --AND PD.OrderKey = @cOrderKey
                     AND PD.DROPID = @cParam1      
                     AND PD.Status = '5'
                  GROUP BY O.ExternOrderKey, PD.OrderKey, PD.OrderLineNumber, PD.SKU, PD.Status
               OPEN @curPD
               FETCH NEXT FROM @curPD INTO @cExternOrderKey, @cParentOrderKey, @cOrderLineNumber, @cStatus, @nQTY
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  SET @nQtyAllocated = CASE WHEN @cStatus < '5' THEN @nQTY ELSE 0 END
                  SET @nQtyPicked    = CASE WHEN @cStatus = '5' THEN @nQTY ELSE 0 END

				  IF @prevParentOrderKey IS NULL
                     OR @prevParentOrderKey <> @cParentOrderKey
                  BEGIN
                     SET @cChildOrderKey = NULL;
                     SET @prevParentOrderKey = @cParentOrderKey;
                  END

                  -- Create child order
				  IF ISNULL(@cChildOrderKey,'') = ''
                  BEGIN
                     -- Get new OrderKey
                     EXECUTE nspg_GetKey
                        'ORDER',
                        10,
                        @cChildOrderKey   OUTPUT,
                        @b_Success        OUTPUT,
                        @n_Err            OUTPUT,
                        @c_ErrMsg         OUTPUT
                     IF @b_Success <> 1
                     BEGIN

                        --Info
                        SET @c_oFieled01 = 'Unloading failed'
	                    SET @nRollBack = 1
	                    GOTO RollBackTran
                     END

                     EXECUTE nspg_GetKey                                                                                                                                      
                     'MBOL'                                                                                                                                           
                     , 10                                                                                                                                                 
                     , @cMBOLkeyNew  OUTPUT                                                                                                                                 
                     , @b_success    OUTPUT                                                                                                                                   
                     , @n_err        OUTPUT                                                                                                                                       
                     , @c_ErrMsg     OUTPUT                                                                                                                                    
                     IF @b_Success <> 1
                     BEGIN

                        --Info
                        SET @c_oFieled01 = 'Unloading failed'
	                    SET @nRollBack = 1
	                    GOTO RollBackTran
                     END

                     INSERT INTO dbo.Orders (
                        OrderKey,         StorerKey,           ExternOrderKey,      OrderDate,
                        DeliveryDate,     Priority,            ConsigneeKey,        C_contact1,
                        C_Contact2,       C_Company,           C_Address1,          C_Address2,
                        C_Address3,       C_Address4,          C_City,              C_State,
                        C_Zip,            C_Country,           C_ISOCntryCode,      C_Phone1,
                        C_Phone2,         C_Fax1,              C_Fax2,              C_vat,
                        BuyerPO,          BillToKey,           B_contact1,          B_Contact2,
                        B_Company,        B_Address1,          B_Address2,          B_Address3,
                        B_Address4,       B_City,              B_State,             B_Zip,
                        B_Country,        B_ISOCntryCode,      B_Phone1,            B_Phone2,
                        B_Fax1,           B_Fax2,              B_Vat,               IncoTerm,
                        PmtTerm,          OpenQty,             [Status],            DischargePlace,
                        DeliveryPlace,    IntermodalVehicle,   CountryOfOrigin,     CountryDestination,
                        UpdateSource,     [Type],              OrderGroup,          Door,
                        [Route],          [Stop],              Notes,               EffectiveDate,
                        ContainerType,    ContainerQty,        BilledContainerQty,  SOStatus,
                        MBOLKey,          InvoiceNo,           InvoiceAmount,       Salesman,
                        GrossWeight,      Capacity,            PrintFlag,           LoadKey,
                        Rdd,              Notes2,              SequenceNo,          Rds,
                        SectionKey,       Facility,            PrintDocDate,        LabelPrice,
                        POKey,            ExternPOKey,         XDockFlag,           UserDefine01,
                        UserDefine02,     UserDefine03,        UserDefine04,        UserDefine05,
                        UserDefine06,     UserDefine07,        UserDefine08,        UserDefine09,
                        UserDefine10,     Issued,              DeliveryNote,        PODCust,
                        PODArrive,        PODReject,           PODUser,             xdockpokey,
                        SpecialHandling,  RoutingTool,         MarkforKey,          M_Contact1,
                        M_Contact2,       M_Company,           M_Address1,          M_Address2,
                        M_Address3,       M_Address4,          M_City,              M_State,
                        M_Zip,            M_Country,           M_ISOCntryCode,      M_Phone1,
                        M_Phone2,         M_Fax1,              M_Fax2,              M_vat,
                        ShipperKey,       DocType,             TrackingNo,          ECOM_PRESALE_FLAG,
                        ECOM_SINGLE_Flag, CurrencyCode,        RTNTrackingNo,       BizUnit,
                        HashValue,        ECOM_OAID,           ECOM_Platform)
                     SELECT
                        @cChildOrderKey,  StorerKey,           ExternOrderKey,      OrderDate,
                        DeliveryDate,     Priority,            ConsigneeKey,        C_contact1,
                        C_Contact2,       C_Company,           C_Address1,          C_Address2,
                        C_Address3,       C_Address4,          C_City,              C_State,
                        C_Zip,            C_Country,           C_ISOCntryCode,      C_Phone1,
                        C_Phone2,         C_Fax1,              C_Fax2,              C_vat,
                        BuyerPO,          BillToKey,           B_contact1,          B_Contact2,
                        B_Company,        B_Address1,          B_Address2,          B_Address3,
                        B_Address4,       B_City,              B_State,             B_Zip,
                        B_Country,        B_ISOCntryCode,      B_Phone1,            B_Phone2,
                        B_Fax1,           B_Fax2,              B_Vat,               IncoTerm,
                        PmtTerm,          OpenQty=@nQty,       [Status]='5',        DischargePlace,
                        DeliveryPlace,    IntermodalVehicle,   CountryOfOrigin,     CountryDestination,
                        UpdateSource,     [Type],              OrderGroup,          Door,
                        [Route],          [Stop],              Notes,               EffectiveDate,
                        ContainerType,    ContainerQty,        BilledContainerQty,  SOStatus,
                        @cMBOLKeyNew,     InvoiceNo,           InvoiceAmount,       Salesman,
                        GrossWeight=0,    Capacity=0,          PrintFlag,           LoadKey,
                        Rdd='SplitOrder', Notes2,              SequenceNo,          Rds,
                        SectionKey,       Facility,            PrintDocDate,        LabelPrice,
                        POKey,            ExternPOKey,         XDockFlag,           UserDefine01,
                        UserDefine02,     UserDefine03,        UserDefine04,        UserDefine05,
                        UserDefine06,     UserDefine07,        UserDefine08,        UserDefine09,
                        UserDefine10,     Issued,              DeliveryNote,        PODCust,
                        PODArrive,        PODReject,           PODUser,             XDOCKPOKEY,
                        SpecialHandling,  RoutingTool,         MarkforKey,          M_Contact1,
                        M_Contact2,       M_Company,           M_Address1,          M_Address2,
                        M_Address3,       M_Address4,          M_City,              M_State,
                        M_Zip,            M_Country,           M_ISOCntryCode,      M_Phone1,
                        M_Phone2,         M_Fax1,              M_Fax2,              M_vat,
                        ShipperKey,       DocType,             TrackingNo,          ECOM_PRESALE_FLAG,
                        ECOM_SINGLE_Flag, CurrencyCode,        RTNTrackingNo,       BizUnit,
                        HashValue,        ECOM_OAID,           ECOM_Platform
                     FROM dbo.Orders WITH (NOLOCK)
                     WHERE OrderKey = @cParentOrderKey
                     IF @@ERROR <> 0
                     BEGIN
                     
                        --Info
                        SET @c_oFieled01 = 'Unloading failed'
	                    SET @nRollBack = 1
	                    GOTO RollBackTran
                     END

                     -- OrderInfo
                     INSERT INTO dbo.OrderInfo (
                        OrderKey, OrderInfo01, OrderInfo02, OrderInfo03, OrderInfo04, OrderInfo05, OrderInfo06, OrderInfo07, OrderInfo08, OrderInfo09, OrderInfo10, 
                        EcomOrderId, ReferenceId, StoreName, Platform, InvoiceType, PmtDate, InsuredAmount, CarrierCharges, OtherCharges, PayableAmount,
                        DeliveryMode, CarrierName, DeliveryCategory, Notes, Notes2, OTM_OrderOwner, OTM_BillTo, OTM_NotifyParty, CourierTimeStamp)
                     SELECT
                        @cChildOrderKey, OrderInfo01, OrderInfo02, OrderInfo03, OrderInfo04, OrderInfo05, OrderInfo06, OrderInfo07, OrderInfo08, OrderInfo09, OrderInfo10,
                        EcomOrderId, ReferenceId, StoreName, Platform, InvoiceType, PmtDate, InsuredAmount, CarrierCharges, OtherCharges, PayableAmount,
                        DeliveryMode, CarrierName, DeliveryCategory, Notes, Notes2, OTM_OrderOwner, OTM_BillTo, OTM_NotifyParty, CourierTimeStamp
                     FROM dbo.OrderInfo WITH (NOLOCK)
                     WHERE OrderKey = @cParentOrderKey
                     IF @@ERROR <> 0
                     BEGIN
                        --Info
                        SET @c_oFieled01 = 'Unloading failed'
	                    SET @nRollBack = 1
	                    GOTO RollBackTran
                     END

				     -- MBOL
				     IF NOT EXISTS( SELECT 1 FROM dbo.MBOL WHERE MBOLKey = @cMBOLKeyNew)
                     BEGIN
                        INSERT INTO dbo.MBOL (MBOLKey, ExternMBOLKey, Facility, Status) 
                        VALUES (@cMBOLKeyNew, @cParam2, @cFacility, '0')

                        IF @@ERROR <> 0  
                        BEGIN
						
						   --Info
                           SET @c_oFieled01 = 'Unloading failed'
	                       SET @nRollBack = 1
	                       GOTO RollBackTran
                        END 
                     END

				     -- MBOLDetail
	                 IF NOT EXISTS( SELECT 1 FROM dbo.MBOLDetail WHERE MBOLKey = @cMBOLKeyNew AND OrderKey = @cChildOrderKey)
                     BEGIN
                        IF ISNULL(@cMBOLLine,'') = ''
                        BEGIN
                           SET @cMBOLLine = '00001'
                        END 
                        ELSE 
                        BEGIN
                           SET @cMBOLLine = RIGHT('00000' + CAST(CAST(@cMBOLLine AS INT) + 1 AS NVARCHAR(5)), 5)
                        END

						INSERT INTO dbo.MBOLDetail 
                           (MBOLKey, MBOLLineNumber, OrderKey)
                        VALUES 
                           (@cMBOLKeyNew, @cMBOLLine, @cChildOrderKey)
                        IF @@ERROR <> 0  
                        BEGIN
						
						   --Info
                           SET @c_oFieled01 = 'Unloading failed'
	                       SET @nRollBack = 1
	                       GOTO RollBackTran
                        END 
                     END
                  END
                  
                  -- Top up / create child OrderDetail
                  IF NOT EXISTS( SELECT 1 FROM dbo.OrderDetail WITH (NOLOCK) WHERE OrderKey = @cChildOrderKey AND OrderLineNumber = @cOrderLineNumber)  
                  BEGIN
                     INSERT INTO dbo.OrderDetail (  
                        OrderKey,            OrderLineNumber,  OrderDetailSysId,    ExternOrderKey,  
                        ExternLineNo,        Sku,              StorerKey,           ManufacturerSku,  
                        RetailSku,           AltSku,           OriginalQty,         OpenQty,  
                        ShippedQty,          AdjustedQty,      QtyPreAllocated,     QtyAllocated,  
                        QtyPicked,           UOM,              PackKey,             PickCode,  
                        CartonGroup,         Lot,              ID,                  Facility,  
                        [Status],            UnitPrice,        Tax01,               Tax02,  
                        ExtendedPrice,       UpdateSource,     Lottable01,          Lottable02,  
                        Lottable03,          Lottable04,       Lottable05,          FreeGoodQty,  
                        GrossWeight,         Capacity,         LoadKey,             MBOLKey,  
                        QtyToProcess,        MinShelfLife,     UserDefine01,        UserDefine02,  
                        UserDefine03,        UserDefine04,     UserDefine05,        UserDefine06,  
                        UserDefine07,        UserDefine08,     UserDefine09,        POkey,  
                        ExternPOKey,         UserDefine10,     EnteredQTY,          ConsoOrderKey,  
                        ExternConsoOrderKey, ConsoOrderLineNo, Lottable06,          Lottable07,            
                        Lottable08,          Lottable09,       Lottable10,          Lottable11,
                        Lottable12,          Lottable13,       Lottable14,          Lottable15,  
                        Notes,               Notes2,           Channel,             HashValue, 
                        SalesChannel)  
                     SELECT  
                        @cChildOrderKey,     OrderLineNumber,  OrderDetailSysId,    ExternOrderKey,  
                        ExternLineNo,        Sku,              StorerKey,           ManufacturerSku,  
                        RetailSku,           AltSku,           OriginalQty=@nQty,   OpenQty=@nQty,  
                        ShippedQty,          AdjustedQty=0,    QtyPreAllocated=0,   @nQtyAllocated,  
                        @nQtyPicked,         UOM,              PackKey,             PickCode,  
                        CartonGroup,         Lot,              ID,                  Facility,  
                        [Status]='5',        UnitPrice,        Tax01,               Tax02,  
                        ExtendedPrice,       UpdateSource,     Lottable01,          Lottable02,  
                        Lottable03,          Lottable04,       Lottable05,          FreeGoodQty,  
                        GrossWeight,         Capacity,         LoadKey,             @cMBOLKeyNew,  
                        QtyToProcess,        MinShelfLife,     UserDefine01,        UserDefine02,  
                        UserDefine03,        UserDefine04,     UserDefine05,        UserDefine06,  
                        UserDefine07,        UserDefine08,     UserDefine09,        POkey,  
                        ExternPOKey,         UserDefine10,     EnteredQTY=0,        ConsoOrderKey,       
                        ExternConsoOrderKey, ConsoOrderLineNo, Lottable06,          Lottable07,            
                        Lottable08,          Lottable09,       Lottable10,          Lottable11,
                        Lottable12,          Lottable13,       Lottable14,          Lottable15,        
                        Notes,               Notes2,           Channel,             HashValue, 
                        SalesChannel
                     FROM dbo.OrderDetail WITH (NOLOCK)  
                     WHERE OrderKey = @cParentOrderKey  
                        AND OrderLineNumber = @cOrderLineNumber  
                     IF @@ERROR <> 0  
                     BEGIN
	                    
						--Info
                        SET @c_oFieled01 = 'Unloading failed'
	                    SET @nRollBack = 1
	                    GOTO RollBackTran
                     END
                  END
                  ELSE
                  BEGIN
                     UPDATE dbo.OrderDetail WITH(ROWLOCK) SET 
                        OriginalQty  =  OriginalQty + @nQTY,  
                        OpenQty      =  OpenQty + @nQTY,  
                        QtyPicked    =  QtyPicked + @nQtyPicked, 
                        QtyAllocated =  QtyAllocated + @nQtyAllocated,  
                        Status       =  '5',  
                        EditDate     = GETDATE(),  
						EditWho = SUSER_SNAME(),
                        TrafficCop   = NULL  
                     WHERE OrderKey = @cChildOrderKey  
                        AND OrderLineNumber = @cOrderLineNumber  
                     IF @@ERROR <> 0  
                     BEGIN
						--Info
                        SET @c_oFieled01 = 'Unloading failed'
	                    SET @nRollBack = 1
	                    GOTO RollBackTran
                     END
                  END
                  
                  -- Reduce parent OrderDetail
                  UPDATE dbo.OrderDetail WITH(ROWLOCK) SET
                     OriginalQty  = OriginalQty - @nQTY,  
                     OpenQty      = OpenQty - @nQTY,  
                     QtyPicked    = QtyPicked - @nQtyPicked, 
                     QtyAllocated = QtyAllocated - @nQtyAllocated, 
                     EditDate = GETDATE(),  
                     TrafficCop = NULL 
                  WHERE OrderKey = @cParentOrderKey
                     AND OrderLineNumber = @cOrderLineNumber
                  IF @@ERROR <> 0  
                  BEGIN
					 
					 --Info
                     SET @c_oFieled01 = 'Unloading failed'
	                 SET @nRollBack = 1
	                 GOTO RollBackTran
                  END
                  
               --Reset OpenQty and Status for child order
               DECLARE @nChildTotalQty INT
               SELECT @nChildTotalQty = SUM(OpenQty)
               FROM dbo.OrderDetail WITH(NOLOCK)
               WHERE OrderKey = @cChildOrderKey  
                  AND StorerKey = @cStorerKey
               UPDATE dbo.ORDERS WITH(ROWLOCK)
               SET 
                  OpenQty      = @nChildTotalQty, 
                  Status         = '5',
                  EditDate     = GETDATE(),  
                  EditWho = SUSER_SNAME(), 
                  TrafficCop   = NULL  
               WHERE OrderKey = @cChildOrderKey  
               AND StorerKey = @cStorerKey

               UPDATE dbo.OrderDetail WITH(ROWLOCK)
               SET
                  Status         = '5',
                  EditDate     = GETDATE(),  
                  EditWho = SUSER_SNAME(), 
                  TrafficCop   = NULL  
               WHERE OrderKey = @cChildOrderKey  
                  AND StorerKey = @cStorerKey

              --Reset OpenQty for parent order
              DECLARE @nParentTotalQty INT
              SELECT @nParentTotalQty = SUM(OpenQty)
              FROM dbo.OrderDetail WITH(NOLOCK)
              WHERE OrderKey = @cParentOrderKey  
                 AND StorerKey = @cStorerKey

               UPDATE dbo.ORDERS WITH(ROWLOCK)
               SET 
                  OpenQty      = @nParentTotalQty, 
                  EditDate     = GETDATE(),  
                  EditWho = SUSER_SNAME(), 
                  TrafficCop   = NULL  
               WHERE OrderKey = @cParentOrderKey  
                  AND StorerKey = @cStorerKey

               -- Change RefKeyLookUp (from parent to child)
               IF EXISTS( SELECT TOP 1 1 FROM dbo.RefKeyLookUp WITH (NOLOCK) WHERE OrderKey = @cParentOrderKey AND OrderLineNumber = @cOrderLineNumber)
               BEGIN
                  UPDATE dbo.RefKeyLookUp WITH(ROWLOCK) SET
                     OrderKey = @cChildOrderKey, 
                     EditDate = GETDATE() 
                  FROM dbo.RefKeyLookUp RKL  
                     JOIN dbo.PicKDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  WHERE PD.OrderKey = @cParentOrderKey  
                     AND PD.OrderLineNumber = @cOrderLineNumber  
                     --AND PD.CaseID = @cLabelNo  
                     AND PD.Status = '5'
                     AND PD.DROPID = @cParam1  
                  IF @@ERROR <> 0  
                  BEGIN
					    
				     --Info
                     SET @c_oFieled01 = 'Unloading failed'
	                 SET @nRollBack = 1
	                 GOTO RollBackTran
                  END 
               END
                  
               -- Change PickDetail (from parent to child)
               UPDATE dbo.PickDetail WITH(ROWLOCK) SET
                  OrderKey = @cChildOrderKey, 
                  EditDate = GETDATE(),  
                  TrafficCop = NULL 
               WHERE OrderKey = @cParentOrderKey  
                  AND OrderLineNumber = @cOrderLineNumber
                  --AND CaseID = @cLabelNo
                  AND Status = '5'
                  AND DROPID = @cParam1     
               IF @@ERROR <> 0  
               BEGIN

				  --Info
                  SET @c_oFieled01 = 'Unloading failed'
	              SET @nRollBack = 1
	              GOTO RollBackTran
               END
                  
			   /*-- Moving 0 qty parent orders
			   IF (SELECT TOP 1 OpenQty FROM ORDERS O WITH(NOLOCK) WHERE OrderKey = @cParentOrderKey) = 0
			   BEGIN     
				  DELETE FROM MBOLDETAIL 
				  WHERE MbolKey = @cMBOLKey
				     AND OrderKey = @cParentOrderKey

				  UPDATE ORDERS WITH(ROWLOCK)
				  SET MBOLKey = @cMBOLKeyNew
				  WHERE OrderKey = @cParentOrderKey

	              IF NOT EXISTS( SELECT 1 FROM dbo.MBOLDetail WHERE MBOLKey = @cMBOLKeyNew AND OrderKey = @cParentOrderKey)
                  BEGIN
                     IF ISNULL(@cMBOLLine,'') = ''
                     BEGIN
                        SET @cMBOLLine = '00001'
                     END 
                     ELSE 
                     BEGIN
                        SET @cMBOLLine = RIGHT('00000' + CAST(CAST(@cMBOLLine AS INT) + 1 AS NVARCHAR(5)), 5)
                     END

					 INSERT INTO dbo.MBOLDetail 
                        (MBOLKey, MBOLLineNumber, OrderKey)
                     VALUES 
                        (@cMBOLKeyNew, @cMBOLLine, @cParentOrderKey)
                     IF @@ERROR <> 0  
                     BEGIN
						
					    --Info
                        SET @c_oFieled01 = 'Unloading failed'
	                    SET @nRollBack = 1
	                    GOTO RollBackTran
                     END 
                  END
			   END*/
               FETCH NEXT FROM @curPD INTO @cExternOrderKey, @cParentOrderKey, @cOrderLineNumber, @cStatus, @nQTY

			   /*IF EXISTS (SELECT 1 FROM PICKDETAIL PD WITH(NOLOCK) WHERE DropID = @cParam1 AND OrderKey = @cParentOrderKey)
				  AND @nCounter < 100
			   BEGIN
			      SET @nCounter = @nCounter + 1
			      GOTO Repeat
		       END*/
            END
         END
      END
	  ELSE
	  BEGIN
	     
		 --Info
		 SET @c_oFieled01 = 'Denied! MBOL shipped'
		 SET @nRollBack = 1
		 GOTO RollBackTran
	  END
   END
   ELSE
   BEGIN

      --Info
      SET @c_oFieled01 = 'DropID is not loaded'
	  SET @nRollBack = 1
	  GOTO RollBackTran
   END

   RollBackTran:
   IF @nRollBack = 1 
   BEGIN
      ROLLBACK TRAN 
	  GOTO Quit
   END
   
   COMMIT TRAN 

Quit:
END

GO
GRANT EXECUTE ON [RDT].[rdt_727InquiryJCB1] TO [NSQL]
GO
