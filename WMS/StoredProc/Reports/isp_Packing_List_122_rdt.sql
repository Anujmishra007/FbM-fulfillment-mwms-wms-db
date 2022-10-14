SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* StoredProc: isp_Packing_List_122_rdt                                 */
/* Creation Date: 10-MAR-2022                                           */
/* Copyright: LF Logistics                                              */
/* Written by: MINGLE                                                   */
/*                                                                      */
/* Purpose:                                                             */
/*        :                                                             */
/* Called By: r_dw_packing_list_122_rdt                                 */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 11-MAR-2022 Mingle   1.0   Created(WMS-19075) DevOps Combine Script  */
/* 11-OCT-2022 SYCHUA   1.1   JSM-101387 - Fix for Sum of Field08 and   */
/*                            sum of Pickdetail.Qty (SY01)              */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_Packing_List_122_rdt] (
   @c_Pickslipno NVARCHAR(10)
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
           @n_StartTCnt       INT
         , @n_Continue        INT
         , @n_NoOfLine        INT
         , @c_platfrom        NVARCHAR(20)


   SET @n_StartTCnt = @@TRANCOUNT

   WHILE @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END

   IF LEFT(@c_Pickslipno,1) = 'P' -- Print from ECOM Packing
   BEGIN
      SELECT @c_Pickslipno = Orderkey
      FROM PICKHEADER WITH (NOLOCK)
      WHERE PickHeaderKey = @c_Pickslipno
   END

   SELECT @c_platfrom = ORDERS.ECOM_PLATFORM
   FROM ORDERS(NOLOCK)
   WHERE ORDERS.ORDERKEY = @c_Pickslipno


   IF @c_platfrom IN (SELECT short FROM CODELKUP (NOLOCK) WHERE LISTNAME='ECPlatform' AND Storerkey='fabrique' AND code<>'GW')
   BEGIN
      SET @n_NoOfLine = '4'
   END
   ELSE
   BEGIN
      SET @n_NoOfLine = '6'
   END

   SELECT ORDERS.ExternOrderkey,
          SKU.DESCR,
          SKU.SIZE,
          --PICKDETAIL.QTY,            --SY01
          SUM(PICKDETAIL.QTY) AS QTY,  --SY01
          ORDERDETAIL.ExtendedPrice,
          Orders.M_Contact1,
          --GETDATE(),
          convert(varchar, getdate(), 3),
          --SUM(ORDERDETAIL.ExtendedPrice/2) AS F8,  --SY01
          --SY01 START
          (SELECT SUM(OD.ExtendedPrice*PD.QTY/2)
           FROM ORDERDETAIL OD (NOLOCK)
           JOIN PICKDETAIL PD (NOLOCK) ON OD.ORDERKEY = PD.ORDERKEY AND OD.ORDERLINENUMBER = PD.ORDERLINENUMBER
           WHERE OD.ORDERKEY = ORDERDETAIL.ORDERKEY) AS F8,
          --SY01 END
          (SUM(ORDERDETAIL.ExtendedPrice/2)/10) AS F9,
          (Row_Number() OVER (PARTITION BY orderdetail.OrderKey ORDER BY pickdetail.SKU Asc)-1)/@n_NoOfLine AS RecGrp,
          @n_NoOfLine AS showmaxline
   FROM ORDERS (NOLOCK)
   JOIN ORDERDETAIL (NOLOCK) ON ORDERDETAIL.OrderKey = ORDERS.OrderKey
   JOIN PICKDETAIL (NOLOCK) ON ORDERS.OrderKey = PICKDETAIL.OrderKey AND ORDERDETAIL.OrderLineNumber=PICKDETAIL.OrderLineNumber
   JOIN SKU  (NOLOCK) ON (PICKDETAIL.StorerKey = SKU.StorerKey AND PICKDETAIL.Sku = SKU.Sku)
   WHERE ORDERS.Orderkey = @c_Pickslipno
   GROUP BY ORDERS.ExternOrderkey,
          SKU.DESCR,
          SKU.SIZE,
          --PICKDETAIL.QTY,     --SY01
          ORDERDETAIL.ExtendedPrice,
          Orders.M_Contact1,
          orderdetail.OrderKey,
          pickdetail.SKU

QUIT_SP:
      WHILE @@TRANCOUNT < @n_StartTCnt
      BEGIN
         BEGIN TRAN
      END
END -- procedure
GO
GRANT EXECUTE ON  [dbo].[isp_Packing_List_122_rdt] TO [NSQL]
GO
