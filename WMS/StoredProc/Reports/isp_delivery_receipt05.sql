SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: isp_Delivery_Receipt05                             */
/* Creation Date: 28-Jan-2019                                           */
/* Copyright: LF                                                        */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: WMS-7782 - [PH] Alcon - DR Modification                     */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver. Purposes                                  */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_Delivery_Receipt05]
(@cMBOLkey NVARCHAR(10))
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cExternOrderKey NVARCHAR(30)
         , @cStorerkey      NVARCHAR(15)
         , @cUserdefine10   NVARCHAR(10)
         , @cDRCounterKey   NVARCHAR(10)
         , @cCurrExternKey  NVARCHAR(30)
         , @cPrevExternKey  NVARCHAR(30)
         , @cCurrSKU        NVARCHAR(20)
         , @cPrevSKU        NVARCHAR(20)
         , @nSeqNum         INT
         , @nTotalOrderQty  INT
         , @cPrintFlag      NVARCHAR(1)
         , @nRecCnt         INT
         , @c_AllowZeroQTY  NVARCHAR(1)

   DECLARE @n_err       INT
         , @n_continue  INT
         , @b_success   INT
         , @c_errmsg    NVARCHAR(255)
         , @n_starttcnt INT
         , @b_debug     INT

   CREATE TABLE #TempFlag
   (
      ExternOrderkey [NVARCHAR](30) NULL
    , PrintFlag      [NCHAR](1)     NULL
   )


   CREATE CLUSTERED INDEX [PK_tempFlag] ON #TempFlag (ExternOrderkey)

   DECLARE @TempData TABLE
   (
      MBOLKey         [NVARCHAR](10)   NULL
    , UserDefine10    [NVARCHAR](10)   NULL
    , ExternOrderKey  [NVARCHAR](30)   NULL
    , PrintFlag       [NVARCHAR](1)    NULL
    , Consigneekey    [NVARCHAR](15)   NULL
    , C_Company       [NVARCHAR](45)   NULL
    , C_Address1      [NVARCHAR](45)   NULL
    , C_Address2      [NVARCHAR](45)   NULL
    , C_Address3      [NVARCHAR](45)   NULL
    , C_Address4      [NVARCHAR](45)   NULL
    , C_City          [NVARCHAR](45)   NULL
    , C_Country       [NVARCHAR](30)   NULL
    , BuyerPO         [NVARCHAR](20)   NULL
    , OrderDate       [DATETIME]       NULL
    , DeliveryDate    [DATETIME]       NULL
    , DepartureDate   [DATETIME]       NULL
    , CarrierAgent    [NVARCHAR](30)   NULL
    , VesselQualifier [NVARCHAR](10)   NULL
    , DriverName      [NVARCHAR](30)   NULL
    , Vessel          [NVARCHAR](30)   NULL
    , OtherReference  [NVARCHAR](30)   NULL
    , SKU             [NVARCHAR](20)   NULL
    , SkuDescr        [NVARCHAR](60)   NULL
    , Company         [NVARCHAR](45)   NULL
    , Lot02           [NVARCHAR](18)   NULL
    , ShippedQty      [DECIMAL](12, 2) NULL
    , DRDate          [DATETIME]       NULL
    , Lot01           [NVARCHAR](18)   NULL
    , Lot04           [NVARCHAR](50)   NULL
    , Remark          [NVARCHAR](250)  NULL
    , QtyEA           [INT]            NULL
    , QtyInner        [DECIMAL](12, 2) NULL
    , QtyCtn          [DECIMAL](12, 2) NULL
    , UOM             [NVARCHAR](10)   NULL
    , Billtokey       [NVARCHAR](15)   NULL
    , b_Company       [NVARCHAR](45)   NULL
    , b_Address1      [NVARCHAR](45)   NULL
    , b_Address2      [NVARCHAR](45)   NULL
    , Shippedby       [NVARCHAR](250)  NULL
    , Lot06           [NVARCHAR](18)   NULL
    , AllowZeroQty    [NVARCHAR](1)    NULL
    , TariffKey       [NVARCHAR](20)   NULL
    , ExternPOKey     [NVARCHAR](40)   NULL
    , OrdDetNotes     [NVARCHAR](250)  NULL
    , AltSku          [NVARCHAR](40)   NULL
    , IsParentSKU     [NVARCHAR](10)   NULL
   )

   SELECT @n_starttcnt = @@TRANCOUNT
        , @n_continue = 1
        , @b_debug = 0
        , @n_err = 0
   SET @cPrintFlag = N''
   SET @c_AllowZeroQTY = N''

   SELECT @nRecCnt = COUNT(1)
   FROM ORDERS (NOLOCK)
   WHERE MBOLKey = @cMBOLkey

   IF @nRecCnt <= 0
   BEGIN
      SELECT @n_continue = 4
      IF @b_debug = 1
         PRINT 'No Data Found'
   END
   ELSE IF @b_debug = 1
      PRINT 'Start Processing...  MBOLKey=' + @cMBOLkey

   -- Assign DR Number (at externorderkey level) to all orders under this MBOLKey!   
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      DECLARE CurExternOrder CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT StorerKey
           , ExternOrderKey
           , UserDefine10
      FROM ORDERS (NOLOCK)
      WHERE MBOLKey = @cMBOLkey
      GROUP BY StorerKey
             , ExternOrderKey
             , UserDefine10
      ORDER BY ExternOrderKey

      OPEN CurExternOrder
      FETCH NEXT FROM CurExternOrder
      INTO @cStorerkey
         , @cExternOrderKey
         , @cUserdefine10

      WHILE @@FETCH_STATUS <> -1 -- CurExternOrder Loop   
      BEGIN
         IF @b_debug = 1
            PRINT 'Storerkey=' + @cStorerkey + ' ;ExternOrderKey=' + @cExternOrderKey + ' ;UserDefine10'
                  + @cUserdefine10

         IF ISNULL(@cUserdefine10, '') = ''
         BEGIN
            SET @cPrintFlag = N'N'
            SET @cDRCounterKey = N''

            SELECT @cDRCounterKey = Code
            FROM CODELKUP (NOLOCK)
            WHERE LISTNAME = 'DR_NCOUNT' AND Short = @cStorerkey

            IF @cDRCounterKey = ''
            BEGIN
               SELECT @n_continue = 3
               SELECT @n_err = 63500 -- should assign new error code  
               SELECT @c_errmsg = "NSQL" + CONVERT(NVARCHAR(5), @n_err)
                                  + ": No Setup for CodeLkUp.ListName = DR_NCOUNT. (isp_Delivery_Receipt05)"
            END

            IF @b_debug = 1
               PRINT 'Check this: SELECT Code FROM CodeLkUp (NOLOCK) WHERE ListName = ''DR_NCOUNT'' AND SHORT =N'''
                     + dbo.fnc_RTRIM(@cStorerkey) + ''''



            IF @n_continue = 1 OR @n_continue = 2
            BEGIN
               SELECT @b_success = 0

               EXECUTE nspg_GetKey @cDRCounterKey
                                 , 10
                                 , @cUserdefine10 OUTPUT
                                 , @b_success OUTPUT
                                 , @n_err OUTPUT
                                 , @c_errmsg OUTPUT

               IF @b_debug = 1
                  PRINT ' GET UserDefine10 (DR)= ' + @cUserdefine10 + master.dbo.fnc_GetCharASCII(13)

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @n_err = 63500 -- should assign new error code  
                  SELECT @c_errmsg = "NSQL" + CONVERT(NVARCHAR(5), @n_err)
                                     + ": Fail to Generate Userdeine10 . (isp_Delivery_Receipt05)"
               END
               ELSE
               BEGIN
                  UPDATE ORDERS
                  SET UserDefine10 = @cUserdefine10
                    , UserDefine07 = GETDATE()
                  WHERE MBOLKey = @cMBOLkey AND StorerKey = @cStorerkey AND ExternOrderKey = @cExternOrderKey

                  SELECT @n_err = @@ERROR

                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @n_err = 63501 -- should assign new error code  
                     SELECT @c_errmsg = "NSQL" + CONVERT(NVARCHAR(5), @n_err)
                                        + ": UPDATE ORDERS Failed. (isp_Delivery_Receipt05)"
                  END
               END
            END -- @n_continue = 1 or @n_continue = 2  
         END
         ELSE
         BEGIN
            SET @cPrintFlag = N'Y'
         END

         INSERT INTO #TempFlag (PrintFlag, ExternOrderkey)
         VALUES (@cPrintFlag, @cExternOrderKey)

         FETCH NEXT FROM CurExternOrder
         INTO @cStorerkey
            , @cExternOrderKey
            , @cUserdefine10
      END

      CLOSE CurExternOrder
      DEALLOCATE CurExternOrder
   END -- @nRecCnt > 0  

   IF @b_debug = 1
      SELECT *
      FROM #TempFlag

   -- Insert into @TempData table  
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      INSERT INTO @TempData
      SELECT ORDERS.MBOLKey
           , ORDERS.UserDefine10
           , ORDERS.ExternOrderKey
           , T.PrintFlag
           , ORDERS.ConsigneeKey
           , ORDERS.C_Company
           , ISNULL(ORDERS.C_Address1, '')
           , ISNULL(ORDERS.C_Address2, '')
           , ISNULL(ORDERS.C_Address3, '')
           , ISNULL(ORDERS.C_Address4, '')
           , ISNULL(ORDERS.C_City, '')
           , ISNULL(ORDERS.C_Country, '')
           , ORDERS.BuyerPO
           , ORDERS.OrderDate
           , ORDERS.DeliveryDate
           , MBOL.DepartureDate
           , MBOL.Carrieragent
           , MBOL.VesselQualifier
           , MBOL.DRIVERName
           , MBOL.Vessel
           , MBOL.OtherReference
           , ORDERDETAIL.Sku
           , SKU.DESCR AS SkuDescr
           , STORER.Company
           , LOTATTRIBUTE.Lottable02 AS Lot02
           , CONVERT(
                DECIMAL(12, 2)
              , SUM(PICKDETAIL.Qty) / (CASE WHEN ORDERDETAIL.UOM = PACK.PackUOM1 THEN PACK.CaseCnt
                                            WHEN ORDERDETAIL.UOM = PACK.PackUOM2 THEN PACK.InnerPack
                                            ELSE 1 END)) AS ShippedQty
           , MBOL.EditDate
           , '' AS Lot01
           , CONVERT(NVARCHAR, LOTATTRIBUTE.Lottable04, 104) AS Lot04
           , ORDERS.Notes AS Remark
           , CONVERT(DECIMAL(12, 2)
                   , CASE WHEN ORDERDETAIL.UOM = PACK.PackUOM1 THEN 0
                          WHEN ORDERDETAIL.UOM = PACK.PackUOM2 THEN 0
                          ELSE SUM(PICKDETAIL.Qty)END) AS QtyEA
           , CONVERT(
                DECIMAL(12, 2)
              , CASE WHEN ORDERDETAIL.UOM = PACK.PackUOM1 THEN 0
                     WHEN ORDERDETAIL.UOM = PACK.PackUOM2 THEN SUM(PICKDETAIL.Qty) / PACK.InnerPack
                     ELSE 0 END) AS QtyInner
           , CONVERT(DECIMAL(12, 2)
                   , CASE WHEN ORDERDETAIL.UOM = PACK.PackUOM1 THEN SUM(PICKDETAIL.Qty) / PACK.CaseCnt
                          WHEN ORDERDETAIL.UOM = PACK.PackUOM2 THEN 0
                          ELSE 0 END) AS QtyCtn
           , ORDERDETAIL.UOM
           , ISNULL(ORDERS.BillToKey, '')
           , ISNULL(ORDERS.B_Company, '')
           , ISNULL(ORDERS.B_Address1, '')
           , ISNULL(ORDERS.B_Address2, '')
           , LEFT(ISNULL(CL2.Notes, ''), 250)
           , LOTATTRIBUTE.Lottable06 AS Lot06
           , ISNULL(CL3.Short, '') AS AllowZeroQty
           , ORDERDETAIL.TariffKey
           , ORDERS.ExternPOKey
           , ORDERDETAIL.Notes
           , ORDERDETAIL.AltSku
           , CASE WHEN PICKDETAIL.OrderKey = NULL THEN 'Parent'
                  ELSE '' END
      --CASE WHEN (ORDERDETAIL.QtyPreAllocated + ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked) = 0 THEN 'Parent' ELSE '' END
      FROM ORDERS (NOLOCK)
      JOIN ORDERDETAIL (NOLOCK) ON ORDERS.OrderKey = ORDERDETAIL.OrderKey
      JOIN MBOLDETAIL (NOLOCK) ON MBOLDETAIL.OrderKey = ORDERS.OrderKey
      JOIN STORER (NOLOCK) ON ORDERS.StorerKey = STORER.StorerKey
      JOIN SKU (NOLOCK) ON SKU.Sku = ORDERDETAIL.Sku AND SKU.StorerKey = ORDERDETAIL.StorerKey --NJOW03
      JOIN MBOL (NOLOCK) ON MBOL.MbolKey = MBOLDETAIL.MbolKey
      JOIN PICKDETAIL (NOLOCK) ON (   PICKDETAIL.OrderKey = ORDERDETAIL.OrderKey
                                  AND PICKDETAIL.OrderLineNumber = ORDERDETAIL.OrderLineNumber)
      JOIN LOTATTRIBUTE (NOLOCK) ON PICKDETAIL.Lot = LOTATTRIBUTE.Lot
      JOIN PACK (NOLOCK) ON SKU.PACKKey = PACK.PackKey
      LEFT OUTER JOIN #TempFlag T ON T.ExternOrderkey = ORDERS.ExternOrderKey -- tlting01
      LEFT OUTER JOIN CODELKUP CL (NOLOCK) ON (   ORDERS.StorerKey = CL.Short
                                              AND 'DR_' + ORDERS.StorerKey = CL.Code
                                              AND CL.LISTNAME = 'DR_NCOUNT')
      LEFT OUTER JOIN CODELKUP CL2 (NOLOCK) ON (ORDERS.StorerKey = CL2.Code AND CL2.LISTNAME = 'Storer')
      LEFT OUTER JOIN CODELKUP CL3 (NOLOCK) ON (   ORDERS.StorerKey = CL3.Storerkey
                                               AND CL3.LISTNAME = 'REPORTCFG'
                                               AND CL3.Long = 'r_dw_delivery_receipt05'
                                               AND CL3.Code = 'AllowZeroQty'
                                               AND CL3.Short IN ( 'Y', 'N' ))
      WHERE ORDERS.MBOLKey = @cMBOLkey
      --AND (ORDERDETAIL.QtyPreAllocated + ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked) > 0 
      AND   ORDERS.Status >= '5'
      GROUP BY ORDERS.MBOLKey
             , ORDERS.UserDefine10
             , ORDERS.ExternOrderKey
             , T.PrintFlag
             , ORDERS.ConsigneeKey
             , ORDERS.C_Company
             , ISNULL(ORDERS.C_Address1, '')
             , ISNULL(ORDERS.C_Address2, '')
             , ISNULL(ORDERS.C_Address3, '')
             , ISNULL(ORDERS.C_Address4, '')
             , ISNULL(ORDERS.C_City, '')
             , ISNULL(ORDERS.C_Country, '')
             , ORDERS.BuyerPO
             , ORDERS.OrderDate
             , ORDERS.DeliveryDate
             , MBOL.DepartureDate
             , MBOL.Carrieragent
             , MBOL.VesselQualifier
             , MBOL.DRIVERName
             , MBOL.Vessel
             , MBOL.OtherReference
             , ORDERDETAIL.Sku
             , SKU.DESCR
             , STORER.Company
             , LOTATTRIBUTE.Lottable02
             , ORDERDETAIL.UOM
             , PACK.PackUOM1
             , PACK.PackUOM2
             , PACK.CaseCnt
             , PACK.InnerPack
             , MBOL.EditDate
             , LOTATTRIBUTE.Lottable04
             , ORDERS.Notes
             , ISNULL(ORDERS.BillToKey, '')
             , ISNULL(ORDERS.B_Company, '')
             , ISNULL(ORDERS.B_Address1, '')
             , ISNULL(ORDERS.B_Address2, '')
             , LEFT(ISNULL(CL2.Notes, ''), 250)
             , LOTATTRIBUTE.Lottable06
             , ISNULL(CL3.Short, '')
             , ORDERDETAIL.TariffKey
             , ORDERS.ExternPOKey
             , ORDERDETAIL.Notes
             , ORDERDETAIL.AltSku
             , CASE WHEN PICKDETAIL.OrderKey = NULL THEN 'Parent'
                    ELSE '' END
      --CASE WHEN (ORDERDETAIL.QtyPreAllocated + ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked) = 0 THEN 'Parent' ELSE '' END
      UNION ALL
      SELECT ORDERS.MBOLKey
           , ORDERS.UserDefine10
           , ORDERS.ExternOrderKey
           , T.PrintFlag
           , ORDERS.ConsigneeKey
           , ORDERS.C_Company
           , ISNULL(ORDERS.C_Address1, '')
           , ISNULL(ORDERS.C_Address2, '')
           , ISNULL(ORDERS.C_Address3, '')
           , ISNULL(ORDERS.C_Address4, '')
           , ISNULL(ORDERS.C_City, '')
           , ISNULL(ORDERS.C_Country, '')
           , ORDERS.BuyerPO
           , ORDERS.OrderDate
           , ORDERS.DeliveryDate
           , MBOL.DepartureDate
           , MBOL.Carrieragent
           , MBOL.VesselQualifier
           , MBOL.DRIVERName
           , MBOL.Vessel
           , MBOL.OtherReference
           , ORDERDETAIL.Sku
           , SKU.DESCR AS SkuDescr
           , STORER.Company
           , '' AS Lot02
           , 0 AS ShippedQty
           , MBOL.EditDate
           , '' AS Lot01
           , '00.00.0000' AS Lot04
           , ORDERS.Notes AS Remark
           , 0 AS QtyEA
           , 0 AS QtyInner
           , 0 AS QtyCtn
           , ORDERDETAIL.UOM
           , ISNULL(ORDERS.BillToKey, '')
           , ISNULL(ORDERS.B_Company, '')
           , ISNULL(ORDERS.B_Address1, '')
           , ISNULL(ORDERS.B_Address2, '')
           , LEFT(ISNULL(CL2.Notes, ''), 250)
           , '' AS Lot06
           , ISNULL(CL3.Short, '') AS AllowZeroQty
           , ORDERDETAIL.TariffKey
           , ORDERS.ExternPOKey
           , ORDERDETAIL.Notes
           , ORDERDETAIL.AltSku
           --CASE WHEN (ORDERDETAIL.QtyPreAllocated + ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked) = 0 THEN 'Parent' ELSE '' END
           , CASE WHEN PICKDETAIL.OrderKey = NULL THEN 'Parent'
                  ELSE '' END
      FROM ORDERS (NOLOCK)
      JOIN ORDERDETAIL (NOLOCK) ON ORDERS.OrderKey = ORDERDETAIL.OrderKey
      JOIN MBOLDETAIL (NOLOCK) ON MBOLDETAIL.OrderKey = ORDERS.OrderKey
      JOIN STORER (NOLOCK) ON ORDERS.StorerKey = STORER.StorerKey
      JOIN SKU (NOLOCK) ON SKU.Sku = ORDERDETAIL.Sku AND SKU.StorerKey = ORDERDETAIL.StorerKey --NJOW03
      JOIN MBOL (NOLOCK) ON MBOL.MbolKey = MBOLDETAIL.MbolKey
      LEFT JOIN PICKDETAIL (NOLOCK) ON (   PICKDETAIL.OrderKey = ORDERDETAIL.OrderKey
                                       AND PICKDETAIL.OrderLineNumber = ORDERDETAIL.OrderLineNumber)
      --JOIN LOTATTRIBUTE (NOLOCK) ON PICKDETAIL.lot = LOTATTRIBUTE.LOT  
      JOIN PACK (NOLOCK) ON SKU.PACKKey = PACK.PackKey
      LEFT OUTER JOIN #TempFlag T ON T.ExternOrderkey = ORDERS.ExternOrderKey -- tlting01
      LEFT OUTER JOIN CODELKUP CL (NOLOCK) ON (   ORDERS.StorerKey = CL.Short
                                              AND 'DR_' + ORDERS.StorerKey = CL.Code
                                              AND CL.LISTNAME = 'DR_NCOUNT')
      LEFT OUTER JOIN CODELKUP CL2 (NOLOCK) ON (ORDERS.StorerKey = CL2.Code AND CL2.LISTNAME = 'Storer')
      LEFT OUTER JOIN CODELKUP CL3 (NOLOCK) ON (   ORDERS.StorerKey = CL3.Storerkey
                                               AND CL3.LISTNAME = 'REPORTCFG'
                                               AND CL3.Long = 'r_dw_delivery_receipt05'
                                               AND CL3.Code = 'AllowZeroQty'
                                               AND CL3.Short IN ( 'Y', 'N' ))
      WHERE ORDERS.MBOLKey = @cMBOLkey AND PICKDETAIL.OrderKey = NULL
      --AND (ORDERDETAIL.QtyPreAllocated + ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked) = 0
      AND   ORDERS.Status >= '5'
      GROUP BY ORDERS.MBOLKey
             , ORDERS.UserDefine10
             , ORDERS.ExternOrderKey
             , T.PrintFlag
             , ORDERS.ConsigneeKey
             , ORDERS.C_Company
             , ISNULL(ORDERS.C_Address1, '')
             , ISNULL(ORDERS.C_Address2, '')
             , ISNULL(ORDERS.C_Address3, '')
             , ISNULL(ORDERS.C_Address4, '')
             , ISNULL(ORDERS.C_City, '')
             , ISNULL(ORDERS.C_Country, '')
             , ORDERS.BuyerPO
             , ORDERS.OrderDate
             , ORDERS.DeliveryDate
             , MBOL.DepartureDate
             , MBOL.Carrieragent
             , MBOL.VesselQualifier
             , MBOL.DRIVERName
             , MBOL.Vessel
             , MBOL.OtherReference
             , ORDERDETAIL.Sku
             , SKU.DESCR
             , STORER.Company
             , ORDERDETAIL.UOM
             , PACK.PackUOM1
             , PACK.PackUOM2
             , PACK.CaseCnt
             , PACK.InnerPack
             , MBOL.EditDate
             , ORDERS.Notes
             , ISNULL(ORDERS.BillToKey, '')
             , ISNULL(ORDERS.B_Company, '')
             , ISNULL(ORDERS.B_Address1, '')
             , ISNULL(ORDERS.B_Address2, '')
             , LEFT(ISNULL(CL2.Notes, ''), 250)
             , ISNULL(CL3.Short, '')
             , ORDERDETAIL.TariffKey
             , ORDERS.ExternPOKey
             , ORDERDETAIL.Notes
             , ORDERDETAIL.AltSku
             --CASE WHEN (ORDERDETAIL.QtyPreAllocated + ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked) = 0 THEN 'Parent' ELSE '' END  
             , CASE WHEN PICKDETAIL.OrderKey = NULL THEN 'Parent'
                    ELSE '' END
      ORDER BY ORDERS.ExternOrderKey
             , ORDERS.UserDefine10
             , ORDERDETAIL.Sku
             , LOTATTRIBUTE.Lottable02
   END

   --Get Codelkup.Short value from TempData
   SELECT TOP 1 @c_AllowZeroQTY = AllowZeroQty
   FROM @TempData

   IF (   (@n_continue = 1 OR @n_continue = 2)
      AND (ISNULL(@c_AllowZeroQTY, '') <> '' AND ISNULL(@c_AllowZeroQTY, '') = 'N'))
   BEGIN
      --SELECT * FROM @TempData WHERE ShippedQty > 0 
      SELECT *
      FROM @TempData
      WHERE IsParentSKU <> 'Parent'
   END

   IF (   (@n_continue = 1 OR @n_continue = 2)
      AND (ISNULL(@c_AllowZeroQTY, '') <> '' AND ISNULL(@c_AllowZeroQTY, '') = 'Y'))
   BEGIN
      --SELECT * FROM @TempData WHERE ShippedQty >= 0
      SELECT *
      FROM @TempData
   END

   IF (   (@n_continue = 1 OR @n_continue = 2)
      AND (ISNULL(@c_AllowZeroQTY, '') = '' AND ISNULL(@c_AllowZeroQTY, '') NOT IN ( 'Y', 'N' )))
   BEGIN
      SELECT *
      FROM @TempData
   --SELECT 'NO SETUP'
   END
   -- SELECT * FROM @TempData

   IF @n_continue = 3 -- Error Occured - Process And Return  
   BEGIN
      EXECUTE nsp_logerror @n_err, @c_errmsg, "isp_Delivery_Receipt05"
      RAISERROR(@c_errmsg, 16, 1) WITH SETERROR -- SQL2012  
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END

END /* main procedure */
GO
GRANT EXECUTE ON [dbo].[isp_Delivery_Receipt05] TO [NSQL]
GO