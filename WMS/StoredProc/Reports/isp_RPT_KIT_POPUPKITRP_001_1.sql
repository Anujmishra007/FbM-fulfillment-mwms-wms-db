SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Stored Procedure: isp_RPT_KIT_POPUPKITRP_001_1                          */
/* Creation Date: 21-JAN-2022                                              */
/* Copyright: LFL                                                          */
/* Written by: Harshitha                                                   */
/*                                                                         */
/* Purpose: WMS-18809                                                      */
/*                                                                         */
/* Called By: RPT_KIT_POPUPKITRP_001_1                                     */
/*                                                                         */
/* GitLab Version: 1.0                                                     */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 21-Jan-2022  WLChooi 1.0   DevOps Combine Script                        */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_RPT_KIT_POPUPKITRP_001_1]
      @c_KITKey        NVARCHAR(20)

AS
BEGIN

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @c_storerkey      NVARCHAR(15)
          , @c_fromsku        NVARCHAR(20)
          , @n_qty            INT
          , @n_qtytotake      INT
          , @c_lot            NVARCHAR(10)
          , @c_loc            NVARCHAR(10)
          , @c_id             NVARCHAR(18)
          , @n_qtyavailable   INT
          , @dt_lottable04    DATETIME


   CREATE Table #TempAlloc
   (  Storerkey      NVARCHAR(15) NULL,
      FromSku        NVARCHAR(20) NULL,
      Lot            NVARCHAR(10) NULL,
      Loc            NVARCHAR(10) NULL,
      ID             NVARCHAR(18) NULL,
      Qty            INT   NULL DEFAULT (0),
      Lottable04     DATETIME NULL)

   SELECT @c_fromsku = ''

   WHILE (1=1)
   BEGIN

      SET ROWCOUNT 1
      SELECT @c_storerkey = KITDETAIL.StorerKey,
             @c_fromsku     = KITDETAIL.SKU,
             @n_qty         = SUM(KITDETAIL.ExpectedQty)
      FROM KITDETAIL (NOLOCK), KIT (NOLOCK)
      WHERE KITDETAIL.Kitkey = KIT.Kitkey
      AND   KITDETAIL.[TYPE] = 'F'
      AND   KIT.[Status]     < '9'
      AND   KITDETAIL.Sku  > @c_fromsku
      AND   KIT.Kitkey     = @c_kitkey
      GROUP BY KITDETAIL.StorerKey, KITDETAIL.SKU
      ORDER BY KITDETAIL.SKU

      IF @@ROWCOUNT = 0
      BEGIN
         SET ROWCOUNT 0
         BREAK
      END
      SET ROWCOUNT 0

      WHILE @n_qty > 0 AND (1=1)
      BEGIN

         SET ROWCOUNT 1
         SELECT @c_lot = LOTxLOCxID.LOT,
                @c_loc = LOTxLOCxID.LOC,
                @c_id  = LOTxLOCxID.ID,
                @n_qtyavailable = ( LOTxLOCxID.Qty - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyPicked ),
                @dt_lottable04 = LOTATTRIBUTE.Lottable04
         FROM LOTxLOCxID (NOLOCK), LOTATTRIBUTE (NOLOCK), LOT (NOLOCK), LOC (NOLOCK), ID (NOLOCK)
         WHERE LOTxLOCxID.Lot    = LOT.Lot
         AND LOT.[Status]        = 'OK'
         AND LOTxLOCxID.ID       = ID.ID
         AND ID.[Status]         = 'OK'
         AND LOTxLOCxID.LOC      = LOC.LOC
         AND (LOC.LocationFlag   <> 'DAMAGE'
         AND LOC.LocationFlag    <> 'HOLD')
         AND LOC.[Status]        = 'OK'
         AND LOTxLOCxID.Lot      = LOTATTRIBUTE.Lot
         AND LOTxLOCxID.Storerkey = @c_storerkey
         AND LOTxLOCxID.Sku = @c_fromsku
         AND (LOTxLOCxID.Qty - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyPicked > 0)
         AND NOT EXISTS ( SELECT 1 FROM #TempAlloc
                            WHERE  #TempAlloc.LOT = LOTxLOCxID.LOT
                            AND    #TempAlloc.LOC = LOTxLOCxID.LOC
                            AND    #TempAlloc.ID = LOTxLOCxID.ID )
         ORDER BY LOTATTRIBUTE.Lottable04, LOTxLOCxID.LOT, LOTxLOCxID.LOC, LOTxLOCxID.ID
         IF @@ROWCOUNT = 0
         BEGIN
            SET ROWCOUNT 0
            BREAK
         END

         SET ROWCOUNT 0

         IF @n_qtyavailable > @n_qty
         BEGIN
            SELECT @n_qtytotake = @n_qty
         END
         ELSE
         BEGIN
            SELECT @n_qtytotake = @n_qtyavailable
         END

         INSERT INTO #TempAlloc
         SELECT @c_storerkey,
                  @c_fromsku,
                  @c_lot,
                  @c_loc,
                  @c_id,
                  @n_qtytotake,
                  @dt_lottable04

         SELECT @n_qty = @n_qty - @n_QtyToTake

      END
   END

   SELECT KITDETAIL.KitKey,
          KITDETAIL.StorerKey,
          KITDETAIL.Sku,
          Sku.Descr,
          #TempAlloc.Loc,
          SUM(#TempAlloc.Qty) QtySuggested ,
          #TempAlloc.Lottable04
   FROM   KITDETAIL (NOLOCK),  #TempAlloc, SKU (NOLOCK)
   WHERE KITDETAIL.Storerkey = #TempAlloc.Storerkey
   AND   KITDETAIL.Sku   = #TempAlloc.FromSku
   AND   KITDETAIL.Storerkey = SKU.Storerkey
   AND   KITDETAIL.Sku   = SKU.Sku
   AND   KITDETAIL.[Type] = 'F'
   AND   KITDETAIL.KitKey = @c_kitkey
   GROUP BY KITDETAIL.KitKey,
            KITDETAIL.StorerKey,
            KITDETAIL.Sku,
            Sku.Descr,
            #TempAlloc.Loc,
            #TempAlloc.Lottable04
   ORDER BY KITDETAIL.Sku, #TempAlloc.Loc

   IF OBJECT_ID('tempdb..#TempAlloc') IS NOT NULL
      DROP TABLE #TempAlloc

END
GO
GRANT EXECUTE ON  [dbo].[isp_RPT_KIT_POPUPKITRP_001_1] TO [JReportRole]
GO
GRANT EXECUTE ON  [dbo].[isp_RPT_KIT_POPUPKITRP_001_1] TO [NSQL]
GO
