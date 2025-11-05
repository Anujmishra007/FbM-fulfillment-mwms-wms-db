SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: msp_BEJ_AutoPacking                                */
/* Creation Date: 30-Apr-2025                                           */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-8419 - Auto Packing SO                                  */
/*                                                                      */
/* Called By: Call by SQL Scheduler Job                                 */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Rev   Purposes                                  */
/*2025-10-29    SSA01   1.0   Created - FCR-8419 Auto Packing SO        */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[msp_BEJ_AutoPacking]
    @c_StorerKey NVARCHAR(15) = '',
    @c_Facility NVARCHAR(5) = '',
    @c_OtherConfig NVARCHAR(4000) = '',
    @b_debug INT = 0
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF

    DECLARE @n_Continue INT,
            @b_Success INT,
            @n_Err INT,
            @c_ErrMsg NVARCHAR(250),
            @n_StartTCnt INT, -- Holds the current transaction count
            @c_OrderKey NVARCHAR(10),
            @n_Qty INT,
            @n_QtyAvailable INT,
            @c_Source NVARCHAR(10) = '',
            @c_Priority NVARCHAR(1),
            @c_Status NVARCHAR(10),
            @c_AutoPacking NVARCHAR(1),
            @c_Type NVARCHAR(10),
            @c_OrderLineNo NVARCHAR(5),
            @c_GetLoadkey NVARCHAR(10) = '',
            @c_MBOLKey NVARCHAR(10) = ''

    DECLARE @dt_OrderDate         DATETIME
         , @dt_Delivery_Date     DATETIME
         , @c_Route              NVARCHAR(10)
         , @n_totweight          DECIMAL(20,4)
         , @n_totcube            DECIMAL(20,4)
         , @c_ExternOrderkey     NVARCHAR(50)
         , @c_Loadkey            NVARCHAR(10)
         , @b_ReturnCode         INT
         , @c_GetReason          NVARCHAR(255)
         , @n_TotLines           INT = 0
         , @n_Custcnt            INT = 0
         , @n_Rdscnt             INT = 0

    DECLARE @c_AutoUpdSuperOrderFlag        NVARCHAR(10)
         , @c_SuperOrderFlag               NVARCHAR(10)
         , @c_AutoUpdLoadDefaultStorerStrg NVARCHAR(10)

 DECLARE @c_ConsigneeKey          NVARCHAR(20) = ''
         , @c_OrderLineNumber     NVARCHAR(10) = ''
         , @c_OrderType             NVARCHAR(10) = ''
         , @c_Door                  NVARCHAR(10) = ''
         , @c_DeliveryPlace         NVARCHAR(30) = ''
         , @c_CustomerName          NVARCHAR(100)= ''
         , @c_GetMBOLKey            NVARCHAR(10) = ''
         , @c_ExternReceiptkey      NVARCHAR(50) = ''
         , @c_GetID                 NVARCHAR(18) = ''
         , @c_GetCaseID             NVARCHAR(50) = ''

  DECLARE  @c_GetPickslipno      NVARCHAR(10),
           @c_DropId            NVARCHAR(10),
           @c_GetSKU             NVARCHAR(20),
           @n_GetQty             INT,
           @n_CartonNo           INT = 0,
           @n_PackInfoQty       FLOAT = 0.00,
           @n_PackInfoWeight    FLOAT  = 0.00

    SELECT @n_StartTCnt = @@TRANCOUNT,
           @n_Continue = 1,
           @b_Success = 1,
           @n_Err = 0
    SELECT @c_ErrMsg = ''



    IF @b_debug = 1
    BEGIN
        print ('@c_Facility:' + @c_Facility)
    END

    IF @n_Continue = 1
       OR @n_Continue = 2
    BEGIN
        DECLARE CUR_ORDERKEY CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
        SELECT o.OrderKey,
               sum(od.openqty) as qty
        FROM ORDERS o WITH (NOLOCK)
            JOIN ORDERDETAIL od
                ON o.OrderKey = od.OrderKey
        WHERE o.StorerKey = @c_StorerKey
              AND o.Facility = @c_Facility
              AND o.Type = 'XDOCK'
              AND o.Status = '5'
              AND o.Priority = '1'
              AND o.OrderKey NOT IN (
              SELECT ph.OrderKey FROM PackHeader ph WHERE ph.StorerKey = @c_StorerKey
              )
        group by o.orderkey
        HAVING sum(od.openqty) > 0

        OPEN CUR_ORDERKEY

        FETCH NEXT FROM CUR_ORDERKEY
        INTO @c_OrderKey,
             @n_Qty

        WHILE @@FETCH_STATUS <> -1
        BEGIN
        SET @n_Continue = 1
         print('@c_OrderKey ::'+ @c_OrderKey)
                --generate load
                SET @b_success = 1
                BEGIN TRY
                    EXECUTE nspg_GetKey 'LoadKey',
                                        10,
                                        @c_GetLoadkey OUTPUT,
                                        @b_success OUTPUT,
                                        @n_err OUTPUT,
                                        @c_ErrMsg OUTPUT
                END TRY
                BEGIN CATCH
                    SET @n_Err = 556008
                    SET @c_ErrMsg
                        = 'NSQL' + CONVERT(NVARCHAR(6), @n_Err)
                          + ': Error Executing nspg_GetKey - Loadkey. (msp_BEJ_AutoPacking)'
                    EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
                END CATCH

                IF @b_success <> 1
                   OR @n_Err <> 0
                BEGIN

                    EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
                END

                BEGIN TRY
                 SELECT @n_totcube   = SUM(ORDERDETAIL.OpenQty * SKU.StdGrossWgt)
                 , @n_totweight = SUM(ORDERDETAIL.OpenQty * SKU.StdCube)
                 , @n_Custcnt   = COUNT(DISTINCT ORDERS.C_Company)
                 , @n_Rdscnt    = ISNULL(MAX(CASE WHEN ORDERS.Rds = 'Y' THEN 1 ELSE 0 END),0)
                 , @c_Facility  = MAX(ORDERS.Facility)
                 , @n_TotLines  = COUNT(DISTINCT ORDERDETAIL.OrderLineNumber)
                  FROM ORDERS (NOLOCK)
                  JOIN ORDERDETAIL (NOLOCK) ON ORDERS.OrderKey = ORDERDETAIL.OrderKey
                  JOIN SKU (NOLOCK) ON SKU.StorerKey = ORDERDETAIL.StorerKey AND SKU.SKU = ORDERDETAIL.Sku
                  WHERE ORDERS.OrderKey = @c_OrderKey

                  SET @c_AutoUpdSuperOrderFlag = ''

                  SELECT TOP 1 @c_AutoUpdSuperOrderFlag = ISNULL(RTRIM(Svalue),'')
                  FROM StorerConfig sc WITH (NOLOCK)
                  WHERE sc.ConfigKey = 'AutoUpdSupOrdflag'
                  AND sc.StorerKey = @c_Storerkey
                  AND sc.Facility = CASE WHEN ISNULL(RTRIM(sc.Facility), '') = '' THEN sc.Facility ELSE @c_Facility END

                  IF @c_AutoUpdSuperOrderFlag = ''
                  BEGIN
                     SELECT TOP 1 @c_AutoUpdSuperOrderFlag = ISNULL(RTRIM(Svalue),'')
                     FROM StorerConfig sc WITH (NOLOCK)
                     WHERE sc.ConfigKey = 'AutoUpdSupOrdflag'
                     AND sc.StorerKey = @c_Storerkey
                  END

                  SET @c_AutoUpdLoadDefaultStorerStrg = ''

                  SELECT TOP 1 @c_AutoUpdLoadDefaultStorerStrg = ISNULL(RTRIM(Svalue),'0')
                  FROM StorerConfig sc WITH (NOLOCK)
                  WHERE sc.ConfigKey = 'AutoUpdLoadDefaultStorerStrg'
                  AND sc.StorerKey = @c_Storerkey
                  AND sc.Facility = CASE WHEN ISNULL(RTRIM(sc.Facility), '') = '' THEN sc.Facility ELSE @c_Facility END

                  IF @c_AutoUpdSuperOrderFlag = '1'
                  BEGIN
                     IF @n_Rdscnt > 0
                        SET @c_SuperOrderFlag = 'N'
                     ELSE
                        SET @c_SuperOrderFlag = 'Y'
                  END

                  INSERT INTO LoadPlan(LoadKey, Facility, CustCnt, OrderCnt, [Weight], [Cube], SuperOrderFlag, DefaultStrategykey)
                  VALUES (@c_GetLoadkey, @c_Facility, @n_Custcnt, 1, @n_totweight, @n_totcube, @c_SuperOrderFlag, CASE WHEN @c_AutoUpdLoadDefaultStorerStrg = '1' THEN 'Y' END)

                END TRY
                BEGIN CATCH
                    SET @n_Continue = 3
                    SET @c_ErrMsg = ERROR_MESSAGE()
                    SET @n_Err = 556009
                    SET @c_ErrMsg
                        = 'NSQL' + CONVERT(NVARCHAR(6), @n_Err)
                          + ': Insert Into LOADPLAN Failed. (msp_BEJ_AutoPacking) ' + '(' + @c_ErrMsg + ') '
                    EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
                END CATCH
                BEGIN TRY
                  SELECT @c_ConsigneeKey   = ConsigneeKey
                   , @c_Priority       = [Priority]
                   , @dt_OrderDate     = OrderDate
                   , @dt_Delivery_Date = DeliveryDate
                   , @c_OrderType      = [Type]
                   , @c_Door           = Door
                   , @c_Route          = [Route]
                   , @c_DeliveryPlace  = DeliveryPlace
                   , @c_ExternOrderKey = ExternOrderKey
                   , @c_CustomerName   = C_Company
                   , @c_Status         = [Status]
                    FROM ORDERS (NOLOCK)
                    WHERE OrderKey = @c_OrderKey

                    EXEC isp_InsertLoadplanDetail
                       @cLoadKey        = @c_GetLoadkey
                     , @cFacility       = @c_Facility
                     , @cOrderKey       = @c_OrderKey
                     , @cConsigneeKey   = @c_ConsigneeKey
                     , @cPrioriry       = @c_Priority
                     , @dOrderDate      = @dt_OrderDate
                     , @dDelivery_Date  = @dt_Delivery_Date
                     , @cOrderType      = @c_OrderType
                     , @cDoor           = @c_Door
                     , @cRoute          = @c_Route
                     , @cDeliveryPlace  = @c_DeliveryPlace
                     , @nStdGrossWgt    = @n_totweight
                     , @nStdCube        = @n_totcube
                     , @cExternOrderKey = @c_ExternOrderKey
                     , @cCustomerName   = @c_CustomerName
                     , @nTotOrderLines  = @n_TotLines
                     , @nNoOfCartons    = '1'
                     , @cOrderStatus    = @c_Status
                     , @b_Success       = @b_Success
                     , @n_Err           = @n_Err
                     , @c_ErrMsg        = @c_ErrMsg

                    IF @n_Err <> 0
                    BEGIN
                        EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
                    END

                    SET @c_Status = '0'
                    SELECT @c_Status =   CASE
                                         WHEN MAX(LPD.Status) = '0' THEN '0'
                                         WHEN MIN(LPD.Status) = '0' and MAX(Status) >= '1' THEN '1'
                                         ELSE MIN(LPD.Status)
                                         END
                    FROM  LOADPLANDETAIL LPD WITH (NOLOCK)
                    WHERE LPD.Loadkey = @c_GetLoadkey

                    UPDATE LoadPlan WITH (ROWLOCK)
                    SET [Status]   = @c_Status,
                        Trafficcop = NULL,
                        EditDate = GETDATE(),
                        EditWho = SUSER_SNAME()
                    WHERE LoadKey = @c_GetLoadkey

                    IF EXISTS
                    (SELECT 1
                        FROM dbo.ORDERS AS o (NOLOCK)
                        WHERE o.OrderKey = @c_Orderkey
                        AND (Loadkey = '' OR Loadkey IS NULL)
                    )
                    BEGIN
                        UPDATE ORDERS WITH (ROWLOCK)
                        SET Loadkey = @c_GetLoadkey,
                            EditWho = SUSER_NAME(),
                            EditDate = GETDATE(),
                            ArchiveCop = NULL
                        WHERE Orderkey = @c_Orderkey
                    END

                    DECLARE CUR_OD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                    SELECT od.OrderLineNumber FROM ORDERDETAIL od(NOLOCK)
                    WHERE od.Orderkey = @c_Orderkey
                          AND od.StorerKey = @c_StorerKey
                          AND od.LoadKey IN ( '', NULL )

                    OPEN CUR_OD
                    FETCH NEXT FROM CUR_OD
                    INTO @c_OrderLineNumber

                    WHILE @@FETCH_STATUS <> -1
                    BEGIN
                        UPDATE ORDERDETAIL WITH (ROWLOCK)
                        SET Loadkey = @c_GetLoadkey,
                            EditWho = SUSER_NAME(),
                            EditDate = GETDATE(),
                            ArchiveCop = NULL
                        WHERE Orderkey = @c_Orderkey
                              AND OrderLineNumber = @c_OrderLineNumber
                        FETCH NEXT FROM CUR_OD
                        INTO @c_OrderLineNumber
                    END
                    CLOSE CUR_OD
                    DEALLOCATE CUR_OD
                END TRY
                BEGIN CATCH
                    SET @n_Continue = 3
                    SET @c_ErrMsg = ERROR_MESSAGE()
                    SET @n_Err = 556010
                    SET @c_ErrMsg
                        = 'NSQL' + CONVERT(NVARCHAR(6), @n_Err)
                          + ': Update Orders/Orderdetail Fail. (msp_BEJ_AutoPacking) ' + '(' + @c_ErrMsg + ') '
                    EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
                END CATCH

          --generate MBOL or generate ShipRef

         IF @n_Continue IN (1,2)
         BEGIN
          BEGIN TRY
            SET @c_GetMBOLKey = ''
            IF ISNULL(@c_GetMBOLKey, '') = ''
            BEGIN
               SELECT @b_success = 0
               BEGIN TRY
               EXECUTE nspg_GetKey
                      'MBOL',
                      10,
                      @c_GetMBOLKey OUTPUT,
                      @b_success    OUTPUT,
                      @n_err        OUTPUT,
                      @c_errmsg     OUTPUT
                END TRY
                BEGIN CATCH
                    SET @n_Err = 556011
                    SET @c_ErrMsg
                        = 'NSQL' + CONVERT(NVARCHAR(6), @n_Err)
                          + ': Error Executing nspg_GetKey - MBOLKey. (msp_BEJ_AutoPacking)'
                    EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
                END CATCH

               IF @b_success <> 1
               BEGIN
                  EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
               END

               INSERT INTO MBOL (MBOLKey, Facility, PlaceOfdeliveryQualifier, TransMethod, Userdefine09, Userdefine02, Userdefine04)
               VALUES (@c_GetMBOLKey, @c_Facility, 'D','O', '', 'Y', 'Y')

               SELECT @n_err = @@ERROR
               IF @n_err <> 0
               BEGIN
                  EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
               END

               UPDATE MBOL
               SET DepartureDate = GETDATE()
                 , TrafficCop    = NULL
               WHERE MbolKey = @c_GetMBOLKey

               SELECT @n_err = @@ERROR
               IF @n_err <> 0
               BEGIN
                  EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
               END
            END

            SELECT @dt_OrderDate     = OH.OrderDate,
                   @dt_Delivery_Date = OH.DeliveryDate,
                   @c_Route          = OH.[Route],
                   @n_totweight      = SUM((OD.Qtyallocated + OD.QtyPicked + OD.ShippedQty) * SKU.StdGrossWgt),
                   @n_totcube        = SUM((OD.Qtyallocated + OD.QtyPicked + OD.ShippedQty) * SKU.StdCube),
                   @c_ExternOrderkey = OH.ExternOrderkey,
                   @c_Loadkey        = ISNULL(OH.Loadkey,'')
            FROM ORDERS OH (NOLOCK)
            JOIN Orderdetail OD WITH (NOLOCK) ON (OH.Orderkey = OD.Orderkey)
            JOIN SKU WITH (NOLOCK) ON (OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku)
            WHERE OH.OrderKey = @c_Orderkey
            GROUP BY OH.OrderDate,
                     OH.DeliveryDate,
                     OH.[Route],
                     OH.ExternOrderkey,
                     ISNULL(OH.Loadkey,''),
                     OH.Facility

            IF NOT EXISTS (SELECT 1 FROM MBOLDETAIL (NOLOCK) WHERE Orderkey = @c_Orderkey)
            BEGIN
               EXEC isp_InsertMBOLDetail
                     @cMBOLKey        = @c_GetMBOLKey,
                     @cFacility       = @c_Facility,
                     @cOrderKey       = @c_Orderkey,
                     @cLoadKey        = @c_Loadkey,
                     @nStdGrossWgt    = @n_totweight,
                     @nStdCube        = @n_totcube,
                     @cExternOrderKey = @c_ExternOrderkey,
                     @dOrderDate      = @dt_OrderDate,
                     @dDelivery_Date  = @dt_Delivery_Date,
                     @cRoute          = @c_Route,
                     @b_Success       = @b_Success OUTPUT,
                     @n_err           = @n_err     OUTPUT,
                     @c_errmsg        = @c_errmsg  OUTPUT

               IF @n_err <> 0
               BEGIN
                  EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
               END
            END
            END TRY
            BEGIN CATCH
                    SET @n_Continue = 3
                    SET @c_ErrMsg = ERROR_MESSAGE()
                    SET @n_Err = 556012
                    SET @c_ErrMsg
                        = 'NSQL' + CONVERT(NVARCHAR(6), @n_Err)
                          + ': Insert / Update MBOL/MBODetail Fail. (msp_BEJ_AutoPacking) ' + '(' + @c_ErrMsg + ') '
                    EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
            END CATCH
          END

         --Check AutoPacking Config
         SET @c_AutoPacking = ''
         IF (@n_continue = 1 OR @n_continue = 2)
         BEGIN
                    EXEC nspGetRight @c_Facility = @c_facility,
                                     @c_StorerKey = @c_StorerKey,
                                     @c_sku = NULL,
                                     @c_ConfigKey = 'AutoPacking',
                                     @b_Success = @b_Success OUTPUT,
                                     @c_authority = @c_AutoPacking OUTPUT,
                                     @n_err = @n_err OUTPUT,
                                     @c_errmsg = @c_errmsg OUTPUT

          IF @c_AutoPacking = '1'
          BEGIN
            BEGIN TRY
            --Generate Discrete Pickslip
            EXEC isp_CreatePickSlip
                    @c_Orderkey           = @c_Orderkey
                  , @c_LinkPickSlipToPick = 'Y'
                  , @c_ConsolidateByLoad  = 'N'
                  , @c_AutoScanIn         = 'Y'
                  , @c_Refkeylookup       = 'N'
                  , @c_PickslipType       = '3'
                  , @b_Success            = @b_Success OUTPUT
                  , @n_Err                = @n_err OUTPUT
                  , @c_ErrMsg             = @c_errmsg OUTPUT

            IF @b_Success = 0
            BEGIN
              EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
            END

            SELECT @c_GetPickslipno = PH.Pickheaderkey
            FROM PICKHEADER PH (NOLOCK)
            WHERE PH.OrderKey = @c_Orderkey
            AND PH.[Zone] = '3'

            print('@c_GetPickslipno::'+@c_GetPickslipno)

            IF ISNULL(@c_GetPickslipno, '') <> '' AND NOT EXISTS (SELECT 1 FROM PACKHEADER WITH (NOLOCK) WHERE PickSlipNo = @c_GetPickslipno)
            BEGIN
               INSERT INTO PackHeader ([Route], OrderKey, OrderRefNo, Loadkey, Consigneekey, StorerKey, PickSlipNo)
               SELECT OH.[Route], OH.OrderKey, SUBSTRING(OH.ExternOrderKey, 1, 18), OH.LoadKey, OH.ConsigneeKey, OH.Storerkey, @c_GetPickslipno
               FROM PICKHEADER PH WITH (NOLOCK)
               JOIN ORDERS OH WITH (NOLOCK) ON (PH.Orderkey = OH.Orderkey)
               WHERE PH.PickHeaderKey = @c_GetPickslipno
            END

            IF (SELECT COUNT(1) FROM PACKINFO (NOLOCK) WHERE PickSlipNo = @c_GetPickslipno AND CartonNo = @n_CartonNo) = 0
            BEGIN
               SET @n_PackInfoQty = ISNULL((SELECT SUM(Qty) FROM PICKDETAIL (NOLOCK) WHERE OrderKey = @c_Orderkey),0)
               SET @n_PackInfoWeight = ISNULL((@n_PackInfoQty *
               (SELECT SKU.STDGROSSWGT FROM SKU (NOLOCK)
               JOIN PICKDETAIL WITH (NOLOCK) ON PICKDETAIL.StorerKey = SKU.StorerKey AND PICKDETAIL.SKU = SKU.SKU
               WHERE OrderKey = @c_Orderkey
               )),0)
               INSERT INTO PACKINFO (PickSlipNo, CartonNo, CartonType, AddWho, EditWho, Qty, Weight)
               VALUES (@c_GetPickslipno, @n_CartonNo, 'STD',SUSER_SNAME(),  SUSER_SNAME(), @n_PackInfoQty, @n_PackInfoWeight)
            END

            DECLARE CUR_PICKDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT SKU, ID, CaseID, SUM(QTY), DropId
            FROM   PICKDETAIL WITH (NOLOCK)
            WHERE  OrderKey = @c_Orderkey
            AND    Qty > 0
            GROUP BY SKU, ID, CaseID, DropId

            OPEN CUR_PICKDETAIL

            FETCH NEXT FROM CUR_PICKDETAIL INTO @c_GetSKU, @c_GetID, @c_GetCaseID, @n_GetQty , @c_DropId
            WHILE @@FETCH_STATUS<>-1
            BEGIN
               -- Create packdetail
               SET @n_CartonNo = @n_CartonNo + 1

               INSERT INTO PackDetail (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, AddWho, AddDate, EditWho, EditDate)
               SELECT @c_GetPickslipno, @n_CartonNo,  @c_DropId, '00001', @c_StorerKey, @c_GetSKU,
                      @n_GetQty, SUSER_SNAME(), GETDATE(), SUSER_SNAME(), GETDATE()

               IF @@ERROR <> 0
               BEGIN
                   EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
               END
               FETCH NEXT FROM CUR_PICKDETAIL INTO @c_GetSKU, @c_GetID, @c_GetCaseID, @n_GetQty ,  @c_DropId
            END
            CLOSE CUR_PICKDETAIL
            DEALLOCATE CUR_PICKDETAIL

            --Pack Confirm
            UPDATE PACKHEADER
            SET [Status] = '9'
            WHERE PickSlipNo =  @c_GetPickslipno

            IF @@ERROR <> 0
            BEGIN
               EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
            END
            END TRY
            BEGIN CATCH
                    SET @n_Continue = 3
                    SET @c_ErrMsg = ERROR_MESSAGE()
                    SET @n_Err = 556013
                    SET @c_ErrMsg
                        = 'NSQL' + CONVERT(NVARCHAR(6), @n_Err)+@c_OrderKey
                          + ': Update PACKHeared/PackDetail/PackInfo Fail. (msp_BEJ_AutoPacking) ' + '(' + @c_ErrMsg + ') '
                    EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
             END CATCH
            END
         END
         FETCH NEXT FROM CUR_ORDERKEY
            INTO @c_OrderKey,
                 @n_Qty
        END

        CLOSE CUR_ORDERKEY
        DEALLOCATE CUR_ORDERKEY
    END
    EXIT_SP:

    IF @n_Continue = 3 -- Error Occured - Process And Return
    BEGIN
        SELECT @b_Success = 0
        IF @@TRANCOUNT = 1
           AND @@TRANCOUNT > @n_StartTCnt
        BEGIN
            ROLLBACK TRAN
        END
        ELSE
        BEGIN
            WHILE @@TRANCOUNT > @n_StartTCnt
            BEGIN
                COMMIT TRAN
            END
        END
        EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoPacking'
        RAISERROR(@c_errmsg, 16, 1) WITH SETERROR -- SQL2012
        RETURN
    END
    ELSE
    BEGIN
        SELECT @b_Success = 1
        WHILE @@TRANCOUNT > @n_StartTCnt
        BEGIN
            COMMIT TRAN
        END
        RETURN
    END

END -- Procedure