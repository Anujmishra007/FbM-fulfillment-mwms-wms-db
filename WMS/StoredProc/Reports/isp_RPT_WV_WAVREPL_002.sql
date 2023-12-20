SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store Procedure: isp_RPT_WV_WAVREPL_002                              */
/* Creation Date: 14-Dec-2023                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-24392 - [CN] Tamburins_Replenishment Report_New         */
/*                                                                      */
/* Called By: RPT_WV_WAVREPL_002                                        */
/*                                                                      */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver. Purposes                                  */
/* 14-Dec-2023  WLChooi  1.0  DevOps Combine Script                     */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_RPT_WV_WAVREPL_002] 
   @c_Wavekey NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   SET ANSI_NULLS OFF

   DECLARE @c_Sku          NVARCHAR(20)
         , @c_CandidateSku NVARCHAR(20)
         , @n_WaveQty      INT
         , @c_Condition    NVARCHAR(1000) = ''
         , @n_QtyWaved     INT
         , @c_Lot          NVARCHAR(20)
         , @c_Loc          NVARCHAR(20)
         , @c_ID           NVARCHAR(20)
         , @c_Storerkey    NVARCHAR(20)
         , @c_Facility     NVARCHAR(20)
         , @c_Lottable03   NVARCHAR(20)
         , @dt_Lottable04  DATETIME
         , @c_LocationType NVARCHAR(20)
         , @n_QtyAvailable INT
         , @n_QTYLEFT      INT
         , @n_UCCqty       INT
         , @c_UserDefine01 NVARCHAR(20) = N''
         , @n_Err          INT
         , @c_ErrMsg       NVARCHAR(250)
         , @n_Continue     INT
         , @n_Starttcnt    INT
         , @b_Success      INT
         , @c_SQL          NVARCHAR(MAX)
         , @c_DocType      NVARCHAR(10)
         , @c_SKUDescr     NVARCHAR(250)

   SELECT @n_Continue = 1
        , @n_Starttcnt = @@TRANCOUNT
        , @n_Err = 0
        , @c_ErrMsg = N''
        , @b_Success = 1

   IF OBJECT_ID('tempdb..#TMP_LOT') IS NOT NULL
      DROP TABLE #TMP_LOT;

   CREATE TABLE #TMP_LOT
   (
      Storerkey NVARCHAR(20)
    , Lot       NVARCHAR(20)
    , Loc       NVARCHAR(20)
    , ID        NVARCHAR(20)
    , LotQty    INT
    , AllocQty  INT
    , Lot03     NVARCHAR(20)
    , Lot04     DATETIME
    , SKU       NVARCHAR(50)
    , LocType   NVARCHAR(50)
    , UCCqty    NUMERIC(18, 0) DEFAULT 0.0
    , DocType   NVARCHAR(10)
    , SKUDescr  NVARCHAR(250)
   )

   SELECT TOP 1 @c_UserDefine01 = ISNULL(ORDERS.UserDefine01, '')
              , @c_Storerkey = ORDERS.Storerkey
              , @c_DocType = ORDERS.DocType
   FROM WAVEDETAIL WITH (NOLOCK)
   JOIN ORDERS WITH (NOLOCK) ON ORDERS.OrderKey = WAVEDETAIL.OrderKey
   WHERE WAVEDETAIL.WaveKey = @c_Wavekey

   SELECT TOP 1 @c_Condition = ISNULL(TRIM(CL.Notes), '') + ' ' + ISNULL(TRIM(CL.UDF01), '')
   FROM CODELKUP CL WITH (NOLOCK)
   WHERE CL.LISTNAME = 'TBpreAlloc'
   AND CL.Storerkey = @c_Storerkey

   --main cursor
   DECLARE CURSOR_TB_WAVEQTY CURSOR FAST_FORWARD READ_ONLY FOR
   SELECT ODL.SKU
        , SUM(ODL.OpenQty) AS openqty
        , OH.Facility
        , OH.Storerkey
        , ISNULL(TRIM(SKU.DESCR), '')
   FROM WAVEDETAIL WVD WITH (NOLOCK)
   JOIN WAVE WV WITH (NOLOCK) ON WVD.WaveKey = WV.WaveKey
   JOIN ORDERS OH WITH (NOLOCK) ON OH.OrderKey = WVD.OrderKey
   JOIN ORDERDETAIL ODL WITH (NOLOCK) ON OH.OrderKey = ODL.OrderKey
   JOIN SKU SKU WITH (NOLOCK) ON SKU.Sku = ODL.Sku AND SKU.StorerKey = ODL.StorerKey
   WHERE WVD.WaveKey = @c_Wavekey
   AND OH.[Status] = '0'
   GROUP BY ODL.SKU
          , OH.Facility
          , OH.Storerkey
          , ISNULL(TRIM(SKU.DESCR), '')

   OPEN CURSOR_TB_WAVEQTY

   FETCH NEXT FROM CURSOR_TB_WAVEQTY
   INTO @c_Sku
      , @n_QtyWaved
      , @c_Facility
      , @c_Storerkey
      , @c_SKUDescr

   WHILE @@FETCH_STATUS = 0
   BEGIN
      --sub cur
      SET @c_SQL = N' DECLARE CURSOR_TB_AVAILABLE CURSOR FAST_FORWARD READ_ONLY FOR ' + CHAR(13)
                 + N' SELECT Lot.Storerkey ' + CHAR(13)
                 + N'      , Lot.SKU ' + CHAR(13)
                 + N'      , Lot.Lot ' + CHAR(13)
                 + N'      , LOTxLOCxID.Loc ' + CHAR(13)
                 + N'      , LOTxLOCxID.Id ' + CHAR(13)
                 + N'      , QTYAVAILABLE = SUM( ' + CHAR(13)
                 + N'                          LOTxLOCxID.Qty - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyPicked - LOTxLOCxID.QtyReplen ' + CHAR(13)
                 + N'                          + LOTxLOCxID.PendingMoveIN) ' + CHAR(13)
                 + N'      , Lottable03 ' + CHAR(13)
                 + N'      , Lottable04 ' + CHAR(13)
                 + N'      , Loc.LocationType ' + CHAR(13)
                 + N' FROM LOTATTRIBUTE (NOLOCK) ' + CHAR(13)
                 + N' JOIN Lot (NOLOCK) ON Lot.Lot = LOTATTRIBUTE.Lot ' + CHAR(13)
                 + N' JOIN LOTxLOCxID (NOLOCK) ON LOTxLOCxID.Lot = Lot.Lot AND LOTxLOCxID.Lot = LOTATTRIBUTE.Lot ' + CHAR(13)
                 + N' JOIN Loc (NOLOCK) ON LOTxLOCxID.Loc = Loc.Loc ' + CHAR(13)
                 + N' LEFT JOIN ID (NOLOCK) ON LOTxLOCxID.Id = ID.Id ' + CHAR(13)
                 + N' WHERE Lot.Storerkey = @c_Storerkey ' + CHAR(13)
                 + N' AND   Lot.SKU = @c_Sku ' + CHAR(13)
                 + N' AND   Lot.Status = ''OK'' ' + CHAR(13)
                 + N' AND   Loc.Status = ''OK'' ' + CHAR(13)
                 + N' AND   Loc.LocationFlag = ''NONE'' ' + CHAR(13)
                 + N' AND   Loc.Facility = @c_Facility ' + CHAR(13)
                 + N' AND   LOTATTRIBUTE.Storerkey = @c_Storerkey ' + CHAR(13)
                 + N' AND   LOTATTRIBUTE.SKU = @c_Sku ' + CHAR(13)
                 + N' AND   Loc.HOSTWHCODE = @c_UserDefine01 ' + CHAR(13)
                 + N' AND   Loc.LocationType IN ( ''Other'', ''Pick'' ) ' + CHAR(13)
                 + TRIM(ISNULL(@c_Condition,'')) + CHAR(13)
                 + N' GROUP BY Lot.Storerkey ' + CHAR(13)
                 + N'        , Lot.SKU ' + CHAR(13)
                 + N'        , Lot.Lot ' + CHAR(13)
                 + N'        , LOTxLOCxID.Loc ' + CHAR(13)
                 + N'        , LOTxLOCxID.Id ' + CHAR(13)
                 + N'        , Loc.Loc ' + CHAR(13)
                 + N'        , Loc.LogicalLocation ' + CHAR(13)
                 + N'        , LOTATTRIBUTE.Lottable03 ' + CHAR(13)
                 + N'        , LOTATTRIBUTE.Lottable04 ' + CHAR(13)
                 + N'        , Loc.LocLevel ' + CHAR(13)
                 + N'        , LOTATTRIBUTE.Lot ' + CHAR(13)
                 + N'        , Loc.LocationType ' + CHAR(13)
                 + N' HAVING SUM( ' + CHAR(13)
                 + N'           LOTxLOCxID.Qty - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyPicked - LOTxLOCxID.QtyReplen ' + CHAR(13)
                 + N'           + LOTxLOCxID.PendingMoveIN) > 0 ' + CHAR(13)
                 + N' ORDER BY LocationType DESC ' + CHAR(13)
                 + N'        , LOTATTRIBUTE.Lottable04 ' + CHAR(13)
                 + N'        , LOTATTRIBUTE.Lot ' + CHAR(13)
                 + N'        , Loc.LogicalLocation ' + CHAR(13)
                 + N'        , Loc.Loc '

      EXEC sp_executesql @c_SQL 
      , N'@c_Storerkey NVARCHAR(15), @c_Sku NVARCHAR(20), @c_Facility NVARCHAR(5), @c_UserDefine01 NVARCHAR(20) '
      , @c_Storerkey
      , @c_Sku
      , @c_Facility
      , @c_UserDefine01

      OPEN CURSOR_TB_AVAILABLE

      FETCH NEXT FROM CURSOR_TB_AVAILABLE
      INTO @c_Storerkey
         , @c_CandidateSku
         , @c_Lot
         , @c_Loc
         , @c_ID
         , @n_QtyAvailable
         , @c_Lottable03
         , @dt_Lottable04
         , @c_LocationType

      WHILE @@FETCH_STATUS = 0
      BEGIN
         --QTYCHECK	
         IF @n_QtyWaved - @n_QtyAvailable <= 0
         BEGIN
            INSERT INTO #TMP_LOT
            SELECT @c_Storerkey
                 , @c_Lot
                 , @c_Loc
                 , @c_ID
                 , @n_QtyAvailable
                 , @n_QtyWaved
                 , @c_Lottable03
                 , @dt_Lottable04
                 , @c_CandidateSku
                 , @c_LocationType
                 , 0
                 , @c_DocType
                 , @c_SKUDescr

            IF @c_LocationType = 'Other'
            BEGIN
               --Expect the location have same UCC qty 1loc 1lot 1casecnt
               SELECT TOP 1 @n_UCCqty = qty
               FROM UCC (NOLOCK)
               WHERE Storerkey = @c_Storerkey
               AND   SKU = @c_CandidateSku
               AND   Lot = @c_Lot
               AND   Loc = @c_Loc
               AND   Id = @c_ID
               ORDER BY qty DESC

               UPDATE #TMP_LOT
               SET UCCqty = @n_UCCqty
               WHERE Storerkey = @c_Storerkey
               AND   SKU = @c_CandidateSku
               AND   Lot = @c_Lot
               AND   Loc = @c_Loc
               AND   ID = @c_ID
            END

            GOTO QUIT
         END

         IF @n_QtyWaved - @n_QtyAvailable > 0
         BEGIN
            SELECT @n_QTYLEFT = @n_QtyWaved - (@n_QtyWaved - @n_QtyAvailable)
            SELECT @n_QtyWaved = @n_QtyWaved - @n_QtyAvailable

            INSERT INTO #TMP_LOT
            SELECT @c_Storerkey
                 , @c_Lot
                 , @c_Loc
                 , @c_ID
                 , @n_QtyAvailable
                 , @n_QTYLEFT
                 , @c_Lottable03
                 , @dt_Lottable04
                 , @c_CandidateSku
                 , @c_LocationType
                 , 0
                 , @c_DocType
                 , @c_SKUDescr

            IF @c_LocationType = 'Other'
            BEGIN
               --Expect the location have same UCC qty 1loc 1lot 1casecnt
               SELECT TOP 1 @n_UCCqty = qty
               FROM UCC (NOLOCK)
               WHERE Storerkey = @c_Storerkey
               AND   SKU = @c_CandidateSku
               AND   Lot = @c_Lot
               AND   Loc = @c_Loc
               AND   Id = @c_ID
               ORDER BY qty DESC

               UPDATE #TMP_LOT
               SET UCCqty = @n_UCCqty
               WHERE Storerkey = @c_Storerkey
               AND   SKU = @c_CandidateSku
               AND   Lot = @c_Lot
               AND   Loc = @c_Loc
               AND   ID = @c_ID
            END

            FETCH NEXT FROM CURSOR_TB_AVAILABLE
            INTO @c_Storerkey
               , @c_CandidateSku
               , @c_Lot
               , @c_Loc
               , @c_ID
               , @n_QtyAvailable
               , @c_Lottable03
               , @dt_Lottable04
               , @c_LocationType
         END
         --QTYCHECK	
      END
      --sub END
      QUIT:
      CLOSE CURSOR_TB_AVAILABLE; --close sub cur
      DEALLOCATE CURSOR_TB_AVAILABLE;
      --next main cursor record
      FETCH NEXT FROM CURSOR_TB_WAVEQTY
      INTO @c_Sku
         , @n_QtyWaved
         , @c_Facility
         , @c_Storerkey
         , @c_SKUDescr
   END
   --main cursor END	  
   CLOSE CURSOR_TB_WAVEQTY; --close main cur
   DEALLOCATE CURSOR_TB_WAVEQTY;

   SELECT Storerkey
        , Lot
        , Loc
        , ID
        , LotQty
        , AllocQty
        , Lot03
        , Lot04
        , SKU
        , LocType
        , UCCqty
        , CASE WHEN LocType = 'Other' THEN CEILING(AllocQty / UCCqty)
               ELSE 0 END AS UCCToTake
        , DocType
        , @c_Wavekey AS Wavekey
        , CONVERT(NVARCHAR, GETDATE(), 120) AS CurrentDateTime
        , SKUDescr
   FROM #TMP_LOT WITH (NOLOCK)
   WHERE LocType <> 'Pick'

   IF CURSOR_STATUS('GLOBAL', 'CURSOR_TB_AVAILABLE') IN ( 0, 1 )
   BEGIN
      CLOSE CURSOR_TB_AVAILABLE
      DEALLOCATE CURSOR_TB_AVAILABLE
   END

   IF CURSOR_STATUS('GLOBAL', 'CURSOR_TB_WAVEQTY') IN ( 0, 1 )
   BEGIN
      CLOSE CURSOR_TB_WAVEQTY
      DEALLOCATE CURSOR_TB_WAVEQTY
   END

   IF OBJECT_ID('tempdb..#TMP_LOT') IS NOT NULL
      DROP TABLE #TMP_LOT

   IF @n_Continue = 3 -- Error Occured - Process AND Return
   BEGIN
      SELECT @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_Starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_Starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_RPT_WV_WAVREPL_002'
      RAISERROR(@c_ErrMsg, 16, 1) WITH SETERROR -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_Starttcnt
      BEGIN
         COMMIT TRAN
      END
   -- RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[isp_RPT_WV_WAVREPL_002] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_WV_WAVREPL_002] TO [LogiReportRoleWM]
GO