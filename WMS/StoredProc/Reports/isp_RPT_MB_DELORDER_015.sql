SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_MB_DELORDER_015                               */
/* Creation Date: 09-Nov-2023                                              */
/* Copyright: MAERSK                                                       */
/* Written by: WLChooi                                                     */
/*                                                                         */
/* Purpose: WMS-24088 - WMS Logi Report Delivery Note By MBol              */
/*                                                                         */
/* Called By: RPT_MB_DELORDER_015                                          */
/*                                                                         */
/* GitHub Version: 1.0                                                     */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 09-Nov-2023  WLChooi 1.0   DevOps Combine Script                        */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_RPT_MB_DELORDER_015] (
   @c_Mbolkey NVARCHAR(10)
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success      INT
         , @n_Err          INT
         , @c_ErrMsg       NVARCHAR(255)
         , @n_StartTCnt    INT
         , @n_Continue     INT

   DECLARE @T_Orderkey TABLE ( Orderkey NVARCHAR(10) )

   SELECT @n_StartTCnt = @@TRANCOUNT
        , @n_Continue = 1
        , @b_Success = 1
        , @n_Err = 0
        , @c_ErrMsg = N''

   INSERT INTO @T_Orderkey (Orderkey)
   SELECT DISTINCT MD.Orderkey
   FROM MBOLDETAIL MD (NOLOCK)
   JOIN ORDERS OH (NOLOCK) ON OH.OrderKey = MD.OrderKey
   JOIN CODELKUP CL (NOLOCK) ON CL.LISTNAME = 'REPORTCFG'
                            AND CL.Long = 'RPT_MB_DELORDER_015'
                            AND CL.Code = 'PrintDN'
                            AND CL.Storerkey = OH.Storerkey
                            AND CL.Short = 'Y'
   WHERE MD.MbolKey = @c_Mbolkey

   SELECT Orderkey
   FROM @T_Orderkey
   ORDER BY Orderkey

   QUIT_SP:
   IF @n_Continue = 3 -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_RPT_MB_DELORDER_015'
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
GRANT EXECUTE ON [dbo].[isp_RPT_MB_DELORDER_015] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_DELORDER_015] TO [LogiReportRoleWM]
GO