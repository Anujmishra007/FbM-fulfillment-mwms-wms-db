SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store Procedure: isp_RPT_WV_WAVLOADSHT_001                           */
/* Creation Date: 03-Jul-2023                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-22840 - [TW] PMA Wave Replenishment Report              */
/*                                                                      */
/* Called By: RPT_WV_WAVLOADSHT_001                                     */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver. Purposes                                  */
/* 03-Jul-2023  WLChooi  1.0  DevOps Combine Script                     */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_RPT_WV_WAVLOADSHT_001]
   @c_Wavekey          NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   SET ANSI_NULLS OFF

   DECLARE @n_continue  INT           = 1
         , @n_starttcnt INT
         , @b_Success   INT           = 1
         , @b_debug     INT           = 0
         , @c_errmsg    NVARCHAR(255) = N''
         , @n_err       INT
         , @c_Storerkey NVARCHAR(15)

   SELECT R.Storerkey
        , R.WaveKey
        , OH.LoadKey
        , R.Sku
        , ISNULL(S.DESCR,'') AS SDESCR
        , SUM(OD.OriginalQty) AS Qty
   FROM REPLENISHMENT R (NOLOCK)
   JOIN WAVEDETAIL WD (NOLOCK) ON R.Wavekey = WD.WaveKey
   JOIN ORDERS OH (NOLOCK) ON OH.OrderKey = WD.OrderKey
   JOIN ORDERDETAIL OD (NOLOCK) ON OH.Orderkey = OD.Orderkey AND OD.Sku = R.SKU AND OD.StorerKey = R.Storerkey
   JOIN SKU S (NOLOCK) ON S.StorerKey = R.Storerkey AND S.Sku = R.Sku
   WHERE WD.WaveKey = @c_Wavekey
   GROUP BY R.Storerkey
          , R.WaveKey
          , OH.LoadKey
          , R.Sku
          , S.DESCR
   ORDER BY R.Storerkey
          , R.WaveKey
          , OH.LoadKey
          , R.Sku

   IF @n_continue = 3 -- Error Occured - Process AND Return
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_RPT_WV_WAVLOADSHT_001'
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
   -- RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[isp_RPT_WV_WAVLOADSHT_001] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_WV_WAVLOADSHT_001] TO [LogiReportRoleWM]
GO