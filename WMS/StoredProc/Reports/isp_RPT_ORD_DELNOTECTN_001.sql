SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_ORD_DELNOTECTN_001                            */
/* Creation Date: 06-Nov-2023                                              */
/* Copyright: MAERSK                                                       */
/* Written by: WLChooi                                                     */
/*                                                                         */
/* Purpose: WMS-19764 & WMS-24091 - [SG] JTM- Delivery Note Carton         */
/*                                                                         */
/* Called By: RPT_ORD_DELNOTECTN_001                                       */
/*                                                                         */
/* GitHub Version: 1.1                                                     */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 06-Nov-2023  WLChooi 1.0   DevOps Combine Script                        */
/* 07-Dec-2023  WLChooi 1.1   WMS-24091 - Change to Maersk (WL01)          */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_RPT_ORD_DELNOTECTN_001] @c_Orderkey NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_DeliveryNote NVARCHAR(50) = N''
         , @c_Storerkey    NVARCHAR(15) = N''
         , @b_Success      INT
         , @n_Err          INT
         , @c_ErrMsg       NVARCHAR(255)
         , @n_StartTCnt    INT
         , @n_Continue     INT

   SELECT @n_StartTCnt = @@TRANCOUNT
        , @n_Continue = 1
        , @b_Success = 1
        , @n_Err = 0
        , @c_ErrMsg = N''

   SELECT @c_DeliveryNote = OH.DeliveryNote
        , @c_Storerkey = OH.StorerKey
   FROM ORDERS OH (NOLOCK)
   WHERE OH.OrderKey = @c_Orderkey

   IF ISNULL(@c_DeliveryNote, '') = '' AND ISNULL(@c_Orderkey,'') <> ''
   BEGIN
      EXECUTE nspg_GetKey @c_Storerkey
                        , 10
                        , @c_DeliveryNote OUTPUT
                        , @b_Success OUTPUT
                        , @n_Err OUTPUT
                        , @c_ErrMsg OUTPUT
                        , 0
                        , 1

      IF @n_Err <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 64510 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SET @c_ErrMsg = N'NSQL' + CONVERT(CHAR(5), @n_Err)
                         + N': EXEC nspg_GetKey Failed. (isp_RPT_ORD_DELNOTECTN_001) ( SQLSvr MESSAGE=' + @c_ErrMsg
                         + N' ) '
         GOTO QUIT_SP
      END

      UPDATE dbo.ORDERS
      SET DeliveryNote = @c_DeliveryNote
        , TrafficCop = NULL
        , EditDate = GETDATE()
        , EditWho = SUSER_SNAME()
      WHERE OrderKey = @c_Orderkey 
      AND (DeliveryNote = '' OR DeliveryNote IS NULL)

      SELECT @n_Err = @@ERROR

      IF @n_Err <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 64515 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SET @c_ErrMsg = N'NSQL' + CONVERT(CHAR(5), @n_Err)
                         + N': Update ORDERS Failed. (isp_RPT_ORD_DELNOTECTN_001) ( SQLSvr MESSAGE=' + @c_ErrMsg
                         + N' ) '
         GOTO QUIT_SP
      END
   END

   SELECT ORDERS.C_Company
        , ORDERS.C_Address1
        , ORDERS.C_Address2
        , ORDERS.C_Address3
        , ORDERS.C_Address4
        , ORDERS.Notes
        , STORER.Company
        , ORDERS.AddDate
        , ORDERS.ExternOrderKey
        , ORDERS.OrderKey
        , ORDERS.Door
        , ORDERS.Route
        , SKU.DESCR
        , SUM(PICKDET.qty) AS ORDERDETAIL_QtyPicked
        , ORDERDETAIL.Sku
        , ORDERS.DeliveryNote
        , PACK.CaseCnt
        , ORDERS.Rdd
        , STORER.Logo
        , ORDERS.BuyerPO
        , Signatory = CASE WHEN ISNULL(RTRIM(STORER.Contact2), '') = '' THEN 'Maersk'   --WL01
                           ELSE STORER.Contact2 END
        , LOTT.Lottable01
        , LOTT.Lottable02
        , MD.ContainerKey
        , ORDERS.StorerKey
        , ORDERS.DeliveryDate
        , ISNULL(CLR.Short, 'N') AS ShowField
        , ISNULL(CLR1.Short, 'N') AS Showlogo
        , ISNULL(CLR3.Short, 'N') AS Showmbolkey
        , ORDERS.MBOLKey AS Mbolkey
        , ISNULL(CLR4.Short, 'N') AS ShowBarcode
        , ISNULL(CLR5.Short, 'N') AS ShowAvailQty
        , CASE WHEN ISNULL(CLR5.Short, 'N') = 'Y' THEN LLI.Qty
               ELSE 0 END AS LLIQty
        , ISNULL(CLR6.Short, 'N') AS ShowLast4CharsOfNRIC
        , ISNULL(CLR7.Short, 'N') AS Showqrcode
        , ISNULL(CLR8.Short, 'N') AS Showupc
        , MAX(UPC.UPC) AS UPC
        , ORDERS.C_Zip
        , GETDATE() AS CurrentDateTime
        , ISNULL(TRIM(ORDERS.C_City),'') + ',' + ISNULL(TRIM(ORDERS.C_Country),'') AS C_Country
   FROM ORDERS WITH (NOLOCK)
   JOIN STORER WITH (NOLOCK) ON (ORDERS.StorerKey = STORER.StorerKey)
   JOIN ORDERDETAIL WITH (NOLOCK) ON (ORDERS.OrderKey = ORDERDETAIL.OrderKey)
   JOIN SKU WITH (NOLOCK) ON (ORDERDETAIL.StorerKey = SKU.StorerKey) AND (ORDERDETAIL.Sku = SKU.Sku)
   JOIN PACK WITH (NOLOCK) ON (SKU.PACKKey = PACK.PackKey)
   --LEFT JOIN STORER ST WITH (NOLOCK) ON (ST.StorerKey = 'IDS')   --WL01
   LEFT JOIN STORER ST1 WITH (NOLOCK) ON (ORDERS.ConsigneeKey = ST1.StorerKey)
   LEFT JOIN MBOLDETAIL MD WITH (NOLOCK) ON (MD.OrderKey = ORDERS.OrderKey)
   LEFT JOIN UPC WITH (NOLOCK) ON  UPC.StorerKey = SKU.StorerKey
                               AND UPC.SKU = SKU.Sku
                               AND UPC.PackKey = SKU.PACKKey
                               AND UPC.UOM = PACK.PackUOM3
   CROSS APPLY (  SELECT DISTINCT Storerkey
                                , Sku
                                , Lot
                                , SUM(Qty) AS qty
                  FROM PICKDETAIL PIDET WITH (NOLOCK)
                  WHERE PIDET.OrderKey = ORDERDETAIL.OrderKey
                  AND   PIDET.Storerkey = ORDERDETAIL.StorerKey
                  AND   PIDET.OrderLineNumber = ORDERDETAIL.OrderLineNumber
                  GROUP BY Storerkey
                         , Sku
                         , Lot) AS PICKDET
   CROSS APPLY (  SELECT SUM(Qty) AS Qty
                  FROM LOTxLOCxID (NOLOCK)
                  WHERE LOTxLOCxID.StorerKey = PICKDET.Storerkey AND LOTxLOCxID.Sku = PICKDET.Sku) AS LLI
   LEFT JOIN LOTATTRIBUTE LOTT WITH (NOLOCK) ON (   LOTT.StorerKey = PICKDET.Storerkey
                                                AND LOTT.Sku = PICKDET.Sku
                                                AND LOTT.Lot = PICKDET.Lot)
   LEFT OUTER JOIN CODELKUP CLR (NOLOCK) ON (   ORDERS.StorerKey = CLR.Storerkey
                                            AND CLR.Code = 'SHOWFIELD'
                                            AND CLR.LISTNAME = 'REPORTCFG'
                                            AND CLR.Long = 'RPT_ORD_DELNOTECTN_001'
                                            AND ISNULL(CLR.Short, '') <> 'N')
   LEFT OUTER JOIN CODELKUP CLR1 (NOLOCK) ON (   ORDERS.StorerKey = CLR1.Storerkey
                                             AND CLR1.Code = 'SHOWLOGO'
                                             AND CLR1.LISTNAME = 'REPORTCFG'
                                             AND CLR1.Long = 'RPT_ORD_DELNOTECTN_001'
                                             AND ISNULL(CLR1.Short, '') <> 'N')
   LEFT OUTER JOIN CODELKUP CLR3 (NOLOCK) ON (   ORDERS.StorerKey = CLR3.Storerkey
                                             AND CLR3.Code = 'SHOWMBOLKEY'
                                             AND CLR3.LISTNAME = 'REPORTCFG'
                                             AND CLR3.Long = 'RPT_ORD_DELNOTECTN_001'
                                             AND ISNULL(CLR3.Short, '') <> 'N')
   LEFT OUTER JOIN CODELKUP CLR4 (NOLOCK) ON (   ORDERS.StorerKey = CLR4.Storerkey
                                             AND CLR4.Code = 'ShowBarcode'
                                             AND CLR4.LISTNAME = 'REPORTCFG'
                                             AND CLR4.Long = 'RPT_ORD_DELNOTECTN_001'
                                             AND ISNULL(CLR4.Short, '') <> 'N')
   LEFT OUTER JOIN CODELKUP CLR5 (NOLOCK) ON (   ORDERS.StorerKey = CLR5.Storerkey
                                             AND CLR5.Code = 'ShowAvailQty'
                                             AND CLR5.LISTNAME = 'REPORTCFG'
                                             AND CLR5.Long = 'RPT_ORD_DELNOTECTN_001'
                                             AND ISNULL(CLR5.Short, '') <> 'N')
   LEFT OUTER JOIN CODELKUP CLR6 (NOLOCK) ON (   ORDERS.StorerKey = CLR6.Storerkey
                                             AND CLR6.Code = 'ShowLast4CharsOfNRIC'
                                             AND CLR6.LISTNAME = 'REPORTCFG'
                                             AND CLR6.Long = 'RPT_ORD_DELNOTECTN_001'
                                             AND ISNULL(CLR6.Short, '') <> 'N')
   LEFT JOIN CODELKUP CLR7 WITH (NOLOCK) ON  CLR7.LISTNAME = 'REPORTCFG'
                                         AND CLR7.Long = 'RPT_ORD_DELNOTECTN_001'
                                         AND CLR7.Code = 'SHOWQRCODE'
                                         AND CLR7.Storerkey = ORDERS.StorerKey
                                         AND ISNULL(CLR7.Short, '') <> 'N'
   LEFT JOIN CODELKUP CLR8 WITH (NOLOCK) ON  CLR8.LISTNAME = 'REPORTCFG'
                                         AND CLR8.Long = 'RPT_ORD_DELNOTECTN_001'
                                         AND CLR8.Code = 'SHOWUPC'
                                         AND CLR8.Storerkey = ORDERS.StorerKey
                                         AND ISNULL(CLR8.Short, '') <> 'N'
   WHERE (ORDERS.OrderKey = @c_Orderkey)
   GROUP BY ORDERS.C_Company
          , ORDERS.C_Address1
          , ORDERS.C_Address2
          , ORDERS.C_Address3
          , ORDERS.C_Address4
          , ORDERS.Notes
          , STORER.Company
          , ORDERS.AddDate
          , ORDERS.ExternOrderKey
          , ORDERS.OrderKey
          , ORDERS.Door
          , ORDERS.Route
          , SKU.DESCR
          , ORDERDETAIL.Sku
          , ORDERS.DeliveryNote
          , PACK.CaseCnt
          , ORDERS.Rdd
          , STORER.Logo
          , ORDERS.BuyerPO
          , STORER.Contact2   --WL01
          , LOTT.Lottable01
          , LOTT.Lottable02
          , MD.ContainerKey
          , ORDERS.StorerKey
          , ORDERS.DeliveryDate
          , ISNULL(CLR.Short, 'N')
          , ISNULL(CLR1.Short, 'N')
          , ISNULL(CLR3.Short, 'N')
          , ORDERS.MBOLKey
          , ISNULL(CLR4.Short, 'N')
          , ISNULL(CLR5.Short, 'N')
          , CASE WHEN ISNULL(CLR5.Short, 'N') = 'Y' THEN LLI.Qty
                 ELSE 0 END
          , ISNULL(CLR6.Short, 'N')
          , ISNULL(CLR7.Short, 'N')
          , ISNULL(CLR8.Short, 'N')
          , ORDERS.C_Zip
          , ISNULL(TRIM(ORDERS.C_City),'') + ',' + ISNULL(TRIM(ORDERS.C_Country),'')
   ORDER BY ORDERDETAIL.Sku

   QUIT_SP:
   IF @n_Continue = 3 -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_RPT_ORD_DELNOTECTN_001'
      RAISERROR(@c_ErrMsg, 16, 1) WITH SETERROR -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN TRAN
END
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ORD_DELNOTECTN_001] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ORD_DELNOTECTN_001] TO [LogiReportRoleWM]
GO