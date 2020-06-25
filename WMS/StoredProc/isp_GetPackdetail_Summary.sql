IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetPackdetail_Summary]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_GetPackdetail_Summary]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_GetPackdetail_Summary                               */
/* Creation Date: 2020-04-07                                            */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: WMS-12722 - SG - PMI - Packing [CR]                         */
/*        : Change DW Select to Store Procedure                         */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2020-05-22  Wan01    1.1   Fixed. Conso pack Allocation Qty incorrect*/
/************************************************************************/
CREATE PROC isp_GetPackdetail_Summary
           @c_PickslipNo      NVARCHAR(10)
         , @c_DropID          NVARCHAR(20)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt          INT            = @@TRANCOUNT
         , @c_Orderkey           NVARCHAR(10)   = ''
         , @c_Loadkey            NVARCHAR(10)   = ''
         , @c_Storerkey          NVARCHAR(15)   = ''
         , @c_Facility           NVARCHAR(5)    = ''

         , @c_ScanAsPack         NVARCHAR(30)   = '0'
         , @c_PackByDropID       NVARCHAR(30)   = '0'   

   WHILE @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END

   IF OBJECT_ID('tempdb..#TMP_ORDERS','u') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_ORDERS
   END

   CREATE TABLE #TMP_ORDERS
   (  Orderkey    NVARCHAR(10)   NOT NULL DEFAULT('') PRIMARY KEY
   )

   IF OBJECT_ID('tempdb..#TMP_ORDERSKU','u') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_ORDERSKU
   END

   CREATE TABLE #TMP_ORDERSKU
   (  Orderkey    NVARCHAR(10)   NOT NULL DEFAULT('') 
   ,  Storerkey   NVARCHAR(15)   NOT NULL DEFAULT('')
   ,  Sku         NVARCHAR(20)   NOT NULL DEFAULT('') 
   ,  PickedQty   INT            NOT NULL DEFAULT(0)
   ,  Orddetlot1  NVARCHAR(18)   NOT NULL DEFAULT('')
   )

   IF OBJECT_ID('tempdb..#TMP_PACK','u') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_PACK
   END

   CREATE TABLE #TMP_PACK
   (  Storerkey   NVARCHAR(15)   NOT NULL DEFAULT('')
   ,  Sku         NVARCHAR(20)   NOT NULL DEFAULT('') PRIMARY KEY
   ,  PackedQty   INT            NOT NULL DEFAULT(0)
   )
   
   SELECT @c_Orderkey = PH.Orderkey
         ,@c_Loadkey  = ISNULL(PH.ExternOrderKey,'')
   FROM PICKHEADER PH WITH (NOLOCK) 
   WHERE PH.PickHeaderkey = @c_PickSlipNo

   IF @c_Orderkey <> ''
   BEGIN
      SELECT @c_Storerkey = OH.Storerkey
            ,@c_Facility  = OH.Facility
      FROM ORDERS OH WITH (NOLOCK)
      WHERE OH.Orderkey = @c_Orderkey

      SELECT @c_ScanAsPack = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'SCANASPACK')

      INSERT INTO #TMP_ORDERS
         (  Orderkey )
      VALUES ( @c_Orderkey )
   END
   ELSE
   BEGIN
      INSERT INTO #TMP_ORDERS
         (  Orderkey )
      SELECT LP.Orderkey
      FROM LOADPLANDETAIL LP WITH (NOLOCK)
      WHERE LP.LoadKey = @c_Loadkey

      SELECT TOP 1 
             @c_Storerkey = OH.Storerkey
            ,@c_Facility  = OH.Facility
      FROM #TMP_ORDERS O
      JOIN ORDERS OH WITH (NOLOCK) ON O.Orderkey = OH.Orderkey
      ORDER BY O.Orderkey
   END

   SELECT @c_PackByDropID = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'PackByDropID')

   IF @c_PackByDropID = '1' AND @c_DropID <> ''
   BEGIN
      INSERT INTO #TMP_ORDERSKU
      (  Orderkey
      ,  Storerkey
      ,  Sku
      ,  PickedQty
      ,  Orddetlot1
      )
      SELECT OD.Orderkey
            ,OD.StorerKey   
            ,Sku        = UPPER(OD.Sku)    
            ,PickedQty  = ISNULL(SUM(PD.Qty),0)    
            ,Orddetlot1 = ISNULL(MAX(OD.Lottable01),0)
      FROM #TMP_ORDERS  O
      JOIN ORDERDETAIL  OD WITH (NOLOCK) ON OD.Orderkey = O.Orderkey
      JOIN PICKDETAIL   PD WITH (NOLOCK) ON OD.Orderkey = PD.Orderkey AND OD.OrderLineNumber = PD.OrderLineNumber
      WHERE PD.DropID = @c_DropID
      GROUP BY OD.Orderkey
            ,  OD.StorerKey
            ,  OD.Sku
      HAVING SUM(PD.Qty) > 0

      INSERT INTO #TMP_PACK
         (  Storerkey
         ,  Sku
         ,  PackedQty
         )
      SELECT PD.Storerkey
            ,PD.Sku
            ,PackedQty = ISNULL(SUM(PD.Qty),0)
      FROM PACKDETAIL PD WITH (NOLOCK)
      WHERE PD.PickSlipNo = @c_PickslipNo
      AND   PD.DropID = @c_DropID
      GROUP BY PD.Storerkey
            ,  PD.Sku
   END
   ELSE
   BEGIN
      INSERT INTO #TMP_ORDERSKU
      (  Orderkey
      ,  Storerkey
      ,  Sku
      ,  PickedQty
      ,  Orddetlot1
      )
      SELECT Orderkey = MIN(OD.Orderkey)     --(Wan01)
            ,OD.StorerKey   
            ,Sku        = UPPER(OD.Sku)    
            ,PickedQty  = ISNULL(SUM(OD.QtyAllocated+OD.QtyPicked+OD.ShippedQty),0)    
            ,Orddetlot1 = ISNULL(MAX(OD.Lottable01),0)
      FROM #TMP_ORDERS  O
      JOIN ORDERDETAIL  OD WITH (NOLOCK) ON OD.Orderkey = O.Orderkey
      --GROUP BY OD.Orderkey                 --(Wan01)
      GROUP BY OD.StorerKey                 --(Wan01)
            ,  OD.Sku
      HAVING SUM(OD.QtyAllocated+OD.QtyPicked+OD.ShippedQty) > 0

      INSERT INTO #TMP_PACK
         (  Storerkey
         ,  Sku
         ,  PackedQty
         )
      SELECT PD.Storerkey
            ,PD.Sku
            ,PackedQty = ISNULL(SUM(PD.Qty),0)
      FROM PACKDETAIL PD WITH (NOLOCK)
      WHERE PD.PickSlipNo = @c_PickslipNo
      GROUP BY PD.Storerkey
            ,  PD.Sku
   END

   SELECT OS.StorerKey   
      ,  OS.Sku    
      ,  OS.PickedQty
      ,  PackedQty = ISNULL(P.PackedQty,0) 
      ,  OtherQty   = 0
      ,  Orddetlot1 = CASE WHEN @c_Orderkey = '' THEN '' ELSE OS.Orddetlot1 END
      ,  ScanAsPack = @c_ScanAsPack 
      ,  PACK.Casecnt
      ,  AltSku = ISNULL(SKU.AltSku,'') 
   FROM #TMP_ORDERSKU  OS
   JOIN SKU         WITH (NOLOCK) ON OS.Storerkey = SKU.Storerkey AND OS.Sku = SKU.Sku 
   JOIN PACK        WITH (NOLOCK) ON SKU.Packkey = PACK.Packkey
   LEFT JOIN #TMP_PACK P ON OS.Storerkey = P.Storerkey AND OS.Sku = P.Sku
   
QUIT_SP:
   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_GetPackdetail_Summary] TO nSQL 
GO
