SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_ORD_DELNOTE_007                               */
/* Creation Date: 26-Sep-2023                                              */
/* Copyright: MAERSK                                                       */
/* Written by: WLChooi                                                     */
/*                                                                         */
/* Purpose: WMS-23733 - Migrate WMS report to Logi Report                  */
/*                      RPT_ORD_DELNOTE_007 (SG)                           */
/*                                                                         */
/* Called By: RPT_ORD_DELNOTE_007                                          */
/*                                                                         */
/* GitHub Version: 1.1                                                     */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 26-Sep-2023  WLChooi 1.0   DevOps Combine Script                        */
/* 06-Nov-2023  WLChooi 1.1   WMS-24094 - Update Orders DeliveryNote (WL01)*/
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_RPT_ORD_DELNOTE_007] @c_Orderkey NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_FromStorerkey NVARCHAR(15)
         , @c_Type          NVARCHAR(1)  = N'1'
         , @c_DataWindow    NVARCHAR(60) = N'RPT_ORD_DELNOTE_007'
         , @c_RetVal        NVARCHAR(255)

   --WL01 S
   DECLARE @c_DeliveryNote NVARCHAR(50) = N''
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
        , @c_FromStorerkey = OH.StorerKey
   FROM ORDERS OH (NOLOCK)
   WHERE OH.OrderKey = @c_Orderkey

   EXEC [dbo].[isp_GetCompanyInfo] @c_Storerkey = @c_FromStorerkey
                                 , @c_Type = @c_Type
                                 , @c_DataWindow = @c_DataWindow
                                 , @c_RetVal = @c_RetVal OUTPUT

   IF ISNULL(@c_DeliveryNote, '') = ''
   BEGIN
      EXECUTE nspg_GetKey @c_FromStorerkey
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
         SET @n_Err = 64500 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SET @c_ErrMsg = N'NSQL' + CONVERT(CHAR(5), @n_Err)
                         + N': EXEC nspg_GetKey Failed. (isp_RPT_ORD_DELNOTE_007) ( SQLSvr MESSAGE=' + @c_ErrMsg
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
         SET @n_Err = 64505 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SET @c_ErrMsg = N'NSQL' + CONVERT(CHAR(5), @n_Err)
                         + N': Update ORDERS Failed. (isp_RPT_ORD_DELNOTE_007) ( SQLSvr MESSAGE=' + @c_ErrMsg + N' ) '
         GOTO QUIT_SP
      END
   END
   --WL01 E

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
        , (ORDERDETAIL.QtyPicked + ORDERDETAIL.ShippedQty) AS QtyPicked
        , ORDERDETAIL.Sku
        , ORDERS.DeliveryNote
        , ORDERS.Rdd
        , STORER.Logo
        , ORDERDETAIL.OrderLineNumber
        , ORDERS.BuyerPO
        , ORDERS.StorerKey
        , SKU.RETAILSKU
        , ISNULL(CL.Short, 'N') AS 'ShowField'
        , ISNULL(f.UserDefine02, 'MAERSK') AS 'FCompany'
        , ISNULL(C.Short, 'N') AS 'ShowBuyerPO'
        , ISNULL(ORDERDETAIL.UserDefine03, '') AS 'odudf03'
        , ISNULL(CL1.Short, 'N') AS 'ShowBarcode'
        , ISNULL(CL2.Short, 'N') AS 'ShowDeliveryDate'
        , ORDERS.DeliveryDate
        , ISNULL(CL3.Short, 'N') AS 'ShowSPRemarks'
        , @c_RetVal AS 'LogoName'
        , SumQty = (  SELECT SUM(ORDERDETAIL.QtyPicked + ORDERDETAIL.ShippedQty)
                      FROM ORDERDETAIL (NOLOCK)
                      WHERE OrderKey = @c_Orderkey)
   FROM ORDERS WITH (NOLOCK)
   JOIN ORDERDETAIL WITH (NOLOCK) ON (ORDERS.OrderKey = ORDERDETAIL.OrderKey)
   JOIN SKU WITH (NOLOCK) ON (SKU.Sku = ORDERDETAIL.Sku) AND (ORDERDETAIL.StorerKey = SKU.StorerKey)
   JOIN STORER WITH (NOLOCK) ON (SKU.StorerKey = STORER.StorerKey)
   LEFT JOIN CODELKUP AS CL WITH (NOLOCK) ON  CL.LISTNAME = 'REPORTCFG'
                                          AND CL.Long = 'RPT_ORD_DELNOTE_007'
                                          AND CL.Code = 'SHOWFIELD'
                                          AND CL.Storerkey = STORER.StorerKey
   LEFT JOIN CODELKUP AS C WITH (NOLOCK) ON  C.LISTNAME = 'REPORTCFG'
                                         AND C.Long = 'RPT_ORD_DELNOTE_007'
                                         AND C.Code = 'SHOWBUYERPO'
                                         AND C.Storerkey = STORER.StorerKey
   LEFT JOIN CODELKUP AS CL1 WITH (NOLOCK) ON  CL1.LISTNAME = 'REPORTCFG'
                                           AND CL1.Long = 'RPT_ORD_DELNOTE_007'
                                           AND CL1.Code = 'ShowBarcode'
                                           AND CL1.Storerkey = STORER.StorerKey
   LEFT JOIN CODELKUP AS CL2 WITH (NOLOCK) ON  CL2.LISTNAME = 'REPORTCFG'
                                           AND CL2.Long = 'RPT_ORD_DELNOTE_007'
                                           AND CL2.Code = 'ShowDeliveryDate'
                                           AND CL2.Storerkey = STORER.StorerKey
   LEFT JOIN CODELKUP AS CL3 WITH (NOLOCK) ON  CL3.LISTNAME = 'REPORTCFG'
                                           AND CL3.Long = 'RPT_ORD_DELNOTE_007'
                                           AND CL3.Code = 'SHOWSPREMARKS'
                                           AND CL3.Storerkey = STORER.StorerKey
   LEFT JOIN FACILITY AS f WITH (NOLOCK) ON f.Facility = STORER.Facility
   WHERE ((ORDERS.OrderKey = @c_Orderkey))
   ORDER BY CASE WHEN ISNULL(C.Short, 'N') = 'Y' THEN ORDERDETAIL.UserDefine03 END DESC
          , CASE WHEN ISNULL(C.Short, 'N') = 'Y' THEN ORDERDETAIL.OrderLineNumber END
          , CASE WHEN ISNULL(C.Short, 'N') = 'Y' THEN ORDERDETAIL.Sku END ASC
          , CASE WHEN ISNULL(C.Short, 'N') = 'N' THEN ORDERDETAIL.OrderLineNumber END ASC
          , CASE WHEN ISNULL(C.Short, 'N') = 'N' THEN ORDERDETAIL.Sku END ASC

   --WL01 S
   QUIT_SP:
   IF @n_Continue = 3 -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_RPT_ORD_DELNOTE_007'
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
--WL01 E
END
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ORD_DELNOTE_007] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ORD_DELNOTE_007] TO [LogiReportRoleWM]
GO