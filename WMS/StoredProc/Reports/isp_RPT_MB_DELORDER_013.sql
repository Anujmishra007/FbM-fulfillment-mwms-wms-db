SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: isp_RPT_MB_DELORDER_013                            */
/* Creation Date: 18-Aug-2023                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-23404 - SG - PMI - Delivery Note Report [CR]            */
/*                                                                      */
/* Called By: RPT_MB_DELORDER_013                                       */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 18-Aug-2023  WLChooi  1.0  DevOps Combine Script                     */
/* 06-DEC-2023   CSCHONG  1.1  WMS-24226 add and revised field (CS01)   */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_RPT_MB_DELORDER_013]
(@c_Mbolkey NVARCHAR(10))
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue INT = 1
         , @c_errmsg   NVARCHAR(255)
         , @b_success  INT
         , @n_err      INT
         , @n_PrtAll   INT = 0
         , @c_GetOrderkey   NVARCHAR(20)    --CS01
         , @n_LineNo        INT             --CS01   
         , @c_PrevOrderkey  NVARCHAR(20)    --CS01

   CREATE TABLE #TMP_ORD
   (
      Orderkey NVARCHAR(10)
    , Sorting  NVARCHAR(500)
    , ORDLineNo INT 
   )

   INSERT INTO #TMP_ORD (Orderkey, Sorting,ORDLineNo)     --CS01
   SELECT DISTINCT POD.OrderKey, ISNULL(STORER.B_Contact2,''), ROW_NUMBER() OVER (PARTITION BY POD.OrderKey   ORDER BY   POD.OrderKey,ISNULL(STORER.B_Contact2,'')) --CS01
   FROM POD (NOLOCK)
   JOIN ORDERS (NOLOCK) ON ORDERS.Orderkey = POD.Orderkey
   JOIN STORER (NOLOCK) ON ORDERS.ConsigneeKey = STORER.StorerKey
   WHERE POD.Mbolkey = @c_Mbolkey 
   AND POD.RedeliveryDate IS NOT NULL
   AND POD.[Status] = '4'

   IF NOT EXISTS ( SELECT 1
                   FROM #TMP_ORD )
   BEGIN
      SET @n_PrtAll = 0

      IF NOT EXISTS ( SELECT 1
                      FROM POD (NOLOCK)
                      WHERE POD.Mbolkey = @c_Mbolkey 
                      AND POD.RedeliveryDate IS NOT NULL )
      BEGIN
         SET @n_PrtAll = 1
      END

      IF NOT EXISTS ( SELECT 1
                      FROM POD (NOLOCK)
                      WHERE POD.Mbolkey = @c_Mbolkey )
      BEGIN
         SET @n_PrtAll = 1
      END

      IF @n_PrtAll = 1
      BEGIN
         INSERT INTO #TMP_ORD (Orderkey, Sorting,ORDLineNo)   --CS01
         SELECT DISTINCT MD.OrderKey, ISNULL(ST.B_Contact2,''),ROW_NUMBER() OVER (PARTITION BY MD.OrderKey   ORDER BY MD.OrderKey,ISNULL(ST.B_Contact2,''))  --CS01
         FROM MBOLDETAIL MD (NOLOCK)
         JOIN ORDERS OH (NOLOCK) ON OH.Orderkey = MD.Orderkey
         JOIN STORER ST (NOLOCK) ON OH.ConsigneeKey = ST.StorerKey
         WHERE MD.MbolKey = @c_Mbolkey
      END
   END

    --CS01 S

   SET @n_LineNo = 1

   DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT Orderkey
   FROM #TMP_ORD
   WHERE ORDLineNo = 1
   ORDER BY Orderkey,ORDLineNo

   OPEN CUR_LOOP

   FETCH NEXT FROM CUR_LOOP INTO @c_GetOrderkey
   WHILE @@FETCH_STATUS <> -1
   BEGIN
         SET @n_LineNo = 2
   --SELECT @c_GetOrderkey '@c_GetOrderkey'
    --SELECT TOP 1 Orderkey,Sorting,ORDLineNo
    --FROM #TMP_ORD
    --WHERE Orderkey = @c_GetOrderkey
    --AND ORDLineNo = 1

   --IF ISNULL(@c_PrevOrderkey,'') = ''
   --BEGIN
   --     SET @n_LineNo = 2
   --END
   --ELSE IF @c_PrevOrderkey <> @c_GetOrderkey
   --BEGIN
   --     SET @n_LineNo = 1
   --END


     INSERT INTO #TMP_ORD
     (
         Orderkey,
         Sorting, ORDLineNo
     )
    SELECT TOP 1 Orderkey,Sorting,@n_LineNo
    FROM #TMP_ORD
    WHERE Orderkey = @c_GetOrderkey


   SET @n_LineNo = @n_LineNo + 1
   SET @c_PrevOrderkey = @c_GetOrderkey

   FETCH NEXT FROM CUR_LOOP INTO @c_GetOrderkey
   END
   CLOSE CUR_LOOP
   DEALLOCATE CUR_LOOP
    --CS01 E

   SELECT T.Orderkey
   FROM #TMP_ORD T (NOLOCK)
   GROUP BY T.Orderkey, T.Sorting,T.ORDLineNo
   ORDER BY T.Sorting,T.Orderkey,T.ORDLineNo

   IF OBJECT_ID('tempdb..#TMP_ORD') IS NOT NULL
      DROP TABLE #TMP_ORD
   --CS01
   IF CURSOR_STATUS('LOCAL', 'CUR_LOOP') IN (0 , 1)
   BEGIN
      CLOSE CUR_LOOP
      DEALLOCATE CUR_LOOP   
   END

END -- procedure     
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_DELORDER_013] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_DELORDER_013] TO [LogiReportRoleWM]
GO