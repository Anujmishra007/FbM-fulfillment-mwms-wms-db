SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: nspALTRF03                                         */
/* Creation Date: 11-MAR-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-3051 CN CAPRI Transfer allocation                       */
/*                                                                      */
/* Called By: Transfer allocation                                       */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver.  Purposes                                  */
/* 2025-07-29   Michael 1.1   FCR-6779 - CN-Capri-Add UCC handling(ML01)*/
/************************************************************************/
CREATE OR ALTER PROC [dbo].[nspALTRF03]
   @c_Orderey    NVARCHAR(10),
   @c_Facility   NVARCHAR(5),
   @c_StorerKey  NVARCHAR(15),
   @c_SKU        NVARCHAR(20),
   @c_Lottable01 NVARCHAR(18),
   @c_Lottable02 NVARCHAR(18),
   @c_Lottable03 NVARCHAR(18),
   @d_Lottable04 DATETIME,
   @d_Lottable05 DATETIME,
   @c_Lottable06 NVARCHAR(30),
   @c_Lottable07 NVARCHAR(30),
   @c_Lottable08 NVARCHAR(30),
   @c_Lottable09 NVARCHAR(30),
   @c_Lottable10 NVARCHAR(30),
   @c_Lottable11 NVARCHAR(30),
   @c_Lottable12 NVARCHAR(30),
   @d_Lottable13 DATETIME,
   @d_Lottable14 DATETIME,
   @d_Lottable15 DATETIME,
   @c_UOM        NVARCHAR(10),
   @c_HostWHCode NVARCHAR(10),
   @n_UOMBase    INT,
   @n_QtyLeftToFulfill INT,
   @c_OtherParms NVARCHAR(200)='',
   @c_AllocateUCC NVARCHAR(1)=''   --ML01
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE @b_debug       INT,
           @c_SQL         NVARCHAR(MAX),
           @c_SQLParm     NVARCHAR(MAX)

   DECLARE --@n_QtyAvailable     INT,
           --@c_LOT              NVARCHAR(10),
           --@c_LOC              NVARCHAR(10),
           @c_ID               NVARCHAR(18),
           @c_FromID           NVARCHAR(18),
           --@c_OtherValue       NVARCHAR(20),
           --@n_QtyToTake        INT,
           --@c_LogicalLocation  NVARCHAR(18),
           @n_StorerMinShelfLife INT,
           --@c_PrevLOT          NVARCHAR(10),
           --@n_cnt              INT,
           --@n_LotQtyAvailable  INT,
           @c_Source           NCHAR(1)

   DECLARE @c_key1        NVARCHAR(10)
          ,@c_key2        NVARCHAR(5)

   SET @b_debug = 0
   --SET @n_QtyAvailable = 0
   --SET @c_OtherValue = '1'
   --SET @n_QtyToTake = 0

   EXEC isp_Init_Allocate_Candidates 

   IF LEN(@c_OtherParms) > 0
   BEGIN
      SET @c_key1 = LEFT(@c_OtherParms, 10) --Orderkey, Loadkey(conso), Wavekey(conso), Transferkey
      SET @c_key2 = SUBSTRING(@c_OtherParms, 11, 5) --OrderLineNumber, TransferLineNumber
      SET @c_Source = SUBSTRING(@c_OtherParms, 16, 1) --W=Wave, T=Transfer
   END

   IF @c_Source = 'T' AND ISNULL(@c_Key2,'') <> ''
   BEGIN
   	  SELECT @c_Id = @c_FromId
   	  FROM TRANSFERDETAIL(NOLOCK)
   	  WHERE Transferkey = @c_Key1
   	  AND TransferLineNumber = @c_Key2
   END

   SELECT @n_StorerMinShelfLife = ((Sku.Shelflife * Storer.MinShelflife/100) * -1)
   FROM Sku (nolock)
   JOIN Storer (nolock) ON Sku.Storerkey = Storer.Storerkey
   WHERE Sku.Sku = @c_sku
   AND Sku.Storerkey = @c_storerkey

   IF @n_StorerMinShelfLife IS NULL
      SELECT @n_StorerMinShelfLife = 0

   --ML01-S
   IF OBJECT_ID('tempdb..#TEMP_INV','u') IS NOT NULL
      DROP TABLE #TEMP_INV;

   CREATE TABLE #TEMP_INV
   (  RowID          INT            NOT NULL IDENTITY(1,1)
   ,  Lot            NVARCHAR(10)   NULL DEFAULT('')
   ,  Loc            NVARCHAR(10)   NULL DEFAULT('')
   ,  ID             NVARCHAR(18)   NULL DEFAULT('')
   ,  QtyAvailable   INT            NULL DEFAULT(0)
   ,  LocType        NVARCHAR(20)   NULL DEFAULT('')
   ,  UCCNo          NVARCHAR(20)   NULL DEFAULT('')
   ,  SeqNo          INT            NULL
   ,  SeqNo2         INT            NULL
   )
   --ML01-E

--ML01   SET @c_SQL = N'
--ML01      DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR '
   --ML01-S
   SET @c_SQL = 'INSERT INTO #TEMP_INV(Lot, Loc, ID, QtyAvailable, LocType' + CASE WHEN @c_AllocateUCC='Y' THEN ', UCCNo)' ELSE ')' END
+  'SELECT INV.LOT
         , INV.LOC
         , INV.ID '
+  CASE WHEN @c_AllocateUCC='Y' THEN ', QTYAVAILABLE = CASE WHEN UCC.UCCNo<>'''' THEN UCC.Qty ELSE INV.QTYAVAILABLE END ' ELSE ', INV.QTYAVAILABLE ' END
+      ', ''1'''
+  CASE WHEN @c_AllocateUCC='Y' THEN ', ISNULL(UCC.UCCNo,'''') ' ELSE '' END
+' FROM ('
   --ML01-E
+   ' SELECT LOTxLOCxID.LOT,
             LOTxLOCxID.LOC,
             LOTxLOCxID.ID,
             QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QtyReplen - ISNULL(TRFLLI.FromQty,0)) '
+         ', LOTxLOCxID.Storerkey, LOTxLOCxID.Sku, LA.Lottable05, LOC.LogicalLocation '   --ML01
+   ' FROM LOTxLOCxID (NOLOCK)
      JOIN LOC (NOLOCK) ON (LOTxLOCxID.Loc = LOC.LOC)
      JOIN ID (NOLOCK) ON (LOTxLOCxID.Id = ID.ID)
      JOIN LOT (NOLOCK) ON (LOTXLOCXID.LOT = LOT.LOT)
      JOIN LOTATTRIBUTE LA (NOLOCK) ON LOT.LOT = LA.LOT
      JOIN SKUXLOC SL (NOLOCK) ON (LOTxLOCxID.Storerkey = SL.Storerkey AND LOTxLOCxID.Sku = SL.Sku AND LOTxLOCxID.Loc = SL.Loc)
      LEFT JOIN (SELECT TD.FromLot, TD.FromLoc, TD.FromID, SUM(TD.FromQty) AS FromQty
                 FROM TRANSFER T (NOLOCK)
                 JOIN TRANSFERDETAIL TD (NOLOCK) ON T.Transferkey = TD.Transferkey
                 WHERE TD.Status <> ''9''
                 AND TD.FromStorerkey = ''' + RTRIM(@c_StorerKey) + ''' ' +
               ' AND TD.FromSku = ''' + RTRIM(@c_Sku) + ''' ' +
               ' GROUP BY TD.FromLot, TD.FromLoc, TD.FromID) AS TRFLLI ON LOTXLOCXID.Lot = TRFLLI.FromLot
                                                                          AND LOTXLOCXID.Loc = TRFLLI.FromLoc
                                                                          AND LOTXLOCXID.ID = TRFLLI.FromID
      WHERE LOC.LocationFlag = ''NONE''
      AND LOC.Status <> ''HOLD''
      AND LOT.Status <> ''HOLD''
      AND ID.Status <> ''HOLD''
      AND LOC.Facility = @c_Facility
      AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QtyReplen - ISNULL(TRFLLI.FromQty,0)) > 0
      AND LOTxLOCxID.STORERKEY = @c_StorerKey
      AND LOTxLOCxID.SKU = @c_SKU      
      AND LOTxLOCxID.Id = CASE WHEN ISNULL(@c_ID,'''') <> '''' THEN @c_ID ELSE LOTxLOCxID.Id END ' +
      CASE WHEN @c_UOM = '1' THEN '  AND (LOTxLOCxID.QTYALLOCATED + LOTxLOCxID.QtyReplen + ISNULL(TRFLLI.FromQty,0)) = 0 ' ELSE ' ' END +
      CASE WHEN ISNULL(RTRIM(@c_Lottable01),'') = '' THEN '' ELSE ' AND LA.Lottable01 = @c_Lottable01 ' END +
      CASE WHEN ISNULL(RTRIM(@c_Lottable02),'') = '' THEN '' ELSE ' AND LA.Lottable02 = @c_Lottable02 ' END +
      CASE WHEN ISNULL(RTRIM(@c_Lottable03),'') = '' THEN '' ELSE ' AND LA.Lottable03 = @c_Lottable03 ' END +
      CASE WHEN CONVERT(NVARCHAR(8) ,@d_Lottable04 ,112) <> '19000101' AND @d_Lottable04 IS NOT NULL THEN ' AND LA.Lottable04 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable04, 106)) ' ELSE ' ' END +
      CASE WHEN @n_StorerMinShelfLife <> 0 THEN ' AND DateAdd(Day, ' + CAST(@n_StorerMinShelfLife AS NVARCHAR(10)) + ', LA.Lottable04) > GetDate() ' ELSE ' ' END +
      CASE WHEN CONVERT(NVARCHAR(8) ,@d_Lottable05 ,112) <> '19000101' AND @d_Lottable05 IS NOT NULL THEN ' AND LA.Lottable05 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable05, 106)) ' ELSE ' ' END +
      CASE WHEN ISNULL(RTRIM(@c_Lottable06),'') = '' THEN '' ELSE ' AND LA.Lottable06 = @c_Lottable06 ' END +
      CASE WHEN ISNULL(RTRIM(@c_Lottable07),'') = '' THEN '' ELSE ' AND LA.Lottable07 = @c_Lottable07 ' END +
      CASE WHEN ISNULL(RTRIM(@c_Lottable08),'') = '' THEN '' ELSE ' AND LA.Lottable08 = @c_Lottable08 ' END +
      CASE WHEN ISNULL(RTRIM(@c_Lottable09),'') = '' THEN '' ELSE ' AND LA.Lottable09 = @c_Lottable09 ' END +
      CASE WHEN ISNULL(RTRIM(@c_Lottable10),'') = '' THEN '' ELSE ' AND LA.Lottable10 = @c_Lottable10 ' END +
      CASE WHEN ISNULL(RTRIM(@c_Lottable11),'') = '' THEN '' ELSE ' AND LA.Lottable11 = @c_Lottable11 ' END +
      CASE WHEN ISNULL(RTRIM(@c_Lottable12),'') = '' THEN '' ELSE ' AND LA.Lottable12 = @c_Lottable12 ' END +
      CASE WHEN CONVERT(NVARCHAR(8) ,@d_Lottable13 ,112) <> '19000101' AND @d_Lottable13 IS NOT NULL THEN ' AND LA.Lottable13 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable13, 106)) ' ELSE ' ' END +
      CASE WHEN CONVERT(NVARCHAR(8) ,@d_Lottable14 ,112) <> '19000101' AND @d_Lottable14 IS NOT NULL THEN ' AND LA.Lottable14 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable14, 106)) ' ELSE ' ' END +
      CASE WHEN CONVERT(NVARCHAR(8) ,@d_Lottable15 ,112) <> '19000101' AND @d_Lottable15 IS NOT NULL THEN ' AND LA.Lottable15 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable15, 106)) ' ELSE ' ' END +
      ' AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QtyReplen - ISNULL(TRFLLI.FromQty,0)) >= @n_UOMBase '  +
--ML01      ' ORDER BY LA.Lottable05, LA.Lot, LOC.LogicalLocation, LOC.LOC '
   --ML01-S
   ') INV '
   +  CASE WHEN @c_AllocateUCC='Y' THEN
      ' LEFT JOIN UCC (NOLOCK) ON INV.Storerkey=UCC.Storerkey AND INV.Sku=UCC.Sku AND INV.Lot=UCC.Lot AND INV.Loc=UCC.Loc AND INV.ID=UCC.ID AND UCC.Status=''1'' AND INV.QTYAVAILABLE>=UCC.Qty '
      ELSE '' END
   +    ' ORDER BY INV.Lottable05, INV.Lot, INV.LogicalLocation, INV.LOC '
   --ML01-E

   SET @c_SQLParm =  N'@c_Facility   NVARCHAR(5),  @c_StorerKey  NVARCHAR(15), @c_SKU NVARCHAR(20), @n_QtyLeftToFulfill INT, @n_UOMBase INT, ' +
                      '@c_Lottable01 NVARCHAR(18), @c_Lottable02 NVARCHAR(18), @c_Lottable03 NVARCHAR(18), @d_Lottable04 DATETIME, @d_Lottable05 DATETIME, ' +
                      '@c_Lottable06 NVARCHAR(30), @c_Lottable07 NVARCHAR(30), @c_Lottable08 NVARCHAR(30), @c_Lottable09 NVARCHAR(30), @c_Lottable10 NVARCHAR(30), ' +
                      '@c_Lottable11 NVARCHAR(30), @c_Lottable12 NVARCHAR(30), @d_Lottable13 DATETIME, @d_Lottable14 DATETIME, @d_Lottable15 DATETIME, @c_ID NVARCHAR(18) '

   EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm, @c_Facility, @c_StorerKey, @c_SKU, @n_QtyLeftToFulfill, @n_UOMBase, @c_Lottable01, @c_Lottable02, @c_Lottable03,
                      @d_Lottable04, @d_Lottable05, @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10, @c_Lottable11, @c_Lottable12,
                      @d_Lottable13, @d_Lottable14, @d_Lottable15, @c_ID

   --ML01-S
   IF @c_AllocateUCC='Y'
   BEGIN
      DECLARE @n_Qty2Fulfill INT = @n_QtyLeftToFulfill
            , @n_SeqNo INT = 0
            , @n_SeqNo2 INT = 0
            , @n_RowID INT
            , @n_Qty   INT

     -- Loop 1
      WHILE @n_Qty2Fulfill > 0
      BEGIN
         SET @n_RowID = 0
         SET @n_Qty   = 0

         SELECT TOP 1
                @n_RowID = RowID
              , @n_Qty = QtyAvailable
         FROM #TEMP_INV
         WHERE SeqNo IS NULL
         ORDER BY CASE WHEN UCCNo<>'' THEN
                  CASE WHEN QtyAvailable = @n_Qty2Fulfill THEN 10
                       WHEN QtyAvailable < @n_Qty2Fulfill THEN 20
                       ELSE 40 END
                  ELSE 30 END
             , CASE WHEN UCCNo<>'' THEN IIF(QtyAvailable <= @n_Qty2Fulfill,-1,1) * QtyAvailable ELSE 0 END
             , RowID

         IF @n_RowID = 0
            BREAK
         ELSE
         BEGIN
            SET @n_SeqNo = @n_SeqNo + 1
            UPDATE #TEMP_INV
               SET SeqNo = @n_SeqNo
             WHERE RowID = @n_RowID

            SET @n_Qty2Fulfill = @n_Qty2Fulfill - @n_Qty
         END
      END


      SET  @n_Qty2Fulfill = @n_QtyLeftToFulfill

     -- Loop 2
      WHILE @n_Qty2Fulfill > 0
      BEGIN
         SET @n_RowID = 0
         SET @n_Qty   = 0

         SELECT TOP 1
                @n_RowID = RowID
              , @n_Qty = QtyAvailable
         FROM #TEMP_INV
         WHERE SeqNo2 IS NULL
         ORDER BY CASE WHEN UCCNo<>'' THEN
                  CASE WHEN QtyAvailable = @n_Qty2Fulfill THEN 10
                       WHEN QtyAvailable < @n_Qty2Fulfill THEN 20
                       ELSE 40 END
                  ELSE 30 END
             , CASE WHEN UCCNo<>'' THEN QtyAvailable ELSE 0 END
             , RowID

         IF @n_RowID = 0
            BREAK
         ELSE
         BEGIN
            SET @n_SeqNo2 = @n_SeqNo2 + 1
            UPDATE #TEMP_INV
               SET SeqNo2 = @n_SeqNo2
             WHERE RowID = @n_RowID

            SET @n_Qty2Fulfill = @n_Qty2Fulfill - @n_Qty
         END
      END

      IF (SELECT SUM(QtyAvailable) FROM #TEMP_INV WHERE SeqNo  IS NOT NULL) <>@n_QtyLeftToFulfill AND
         (SELECT SUM(QtyAvailable) FROM #TEMP_INV WHERE SeqNo2 IS NOT NULL) = @n_QtyLeftToFulfill
         INSERT INTO #ALLOCATE_CANDIDATES (Lot, Loc, ID, QtyAvailable, OtherValue)
         SELECT Lot, Loc, ID, QtyAvailable, UCCNo
         FROM #TEMP_INV
         ORDER BY ISNULL(SeqNo2,100000000), RowID
      ELSE
         INSERT INTO #ALLOCATE_CANDIDATES (Lot, Loc, ID, QtyAvailable, OtherValue)
         SELECT Lot, Loc, ID, QtyAvailable, UCCNo
         FROM #TEMP_INV
         ORDER BY ISNULL(SeqNo,100000000), RowID
   END
   ELSE
   BEGIN
      INSERT INTO #ALLOCATE_CANDIDATES (Lot, Loc, ID, QtyAvailable)
      SELECT Lot, Loc, ID, QtyAvailable
      FROM #TEMP_INV
      ORDER BY RowID
   END

   IF @c_AllocateUCC='Y'
      DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT Lot, Loc, ID, QtyAvailable, '1', OtherValue
      FROM #ALLOCATE_CANDIDATES
      ORDER BY RowID
   ELSE
      DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT Lot, Loc, ID, QtyAvailable, '1'
      FROM #ALLOCATE_CANDIDATES
      ORDER BY RowID

   --ML01-E

   /*
   SET @c_SQL = ''
   SET @c_PrevLOT = ''
   SET @n_LotQtyAvailable = 0

   OPEN CURSOR_AVAILABLE
   FETCH NEXT FROM CURSOR_AVAILABLE INTO @c_LOT, @c_LOC, @c_ID, @n_QtyAvailable

   WHILE (@@FETCH_STATUS <> -1) AND (@n_QtyLeftToFulfill > 0)
   BEGIN
      IF @c_LOT <> @c_PrevLOT
      BEGIN
      	 SELECT @n_LotQtyAvailable = SUM(Qty - QtyAllocated - QtyPicked)
      	        - (SELECT SUM(TD.FromQty)
      	           FROM TRANSFER T (NOLOCK)
      	           JOIN TRANSFERDETAIL TD (NOLOCK) ON T.Transferkey = TD.Transferkey
      	           AND TD.Status <> '9'
      	           AND TD.FromLot = LOT.Lot)
      	 FROM LOT (NOLOCK)
      	 WHERE LOT = @c_LOT
       	 GROUP BY Lot
      END

      IF @n_LotQtyAvailable < @n_QtyAvailable
         SET @n_QtyAvailable = @n_LotQtyAvailable

      IF @n_QtyLeftToFulfill >= @n_QtyAvailable
      BEGIN
      		 SET @n_QtyToTake = Floor(@n_QtyAvailable / @n_UOMBase) * @n_UOMBase
      END
      ELSE
      BEGIN
      	  SET @n_QtyToTake = Floor(@n_QtyLeftToFulfill / @n_UOMBase) * @n_UOMBase
      END

      IF @n_QtyToTake > 0
      BEGIN
      	 EXEC isp_Insert_Allocate_Candidates
               @c_Lot = @c_Lot
            ,  @c_Loc = @c_Loc
            ,  @c_ID  = @c_ID
            ,  @n_QtyAvailable = @n_QtyToTake
            ,  @c_OtherValue = @c_OtherValue
         
         SET @n_QtyLeftToFulfill = @n_QtyLeftToFulfill - @n_QtyToTake
         SET @n_LotQtyAvailable = @n_LotQtyAvailable - @n_QtyToTake
      END

      SET @c_PrevLOT = @c_LOT

      FETCH NEXT FROM CURSOR_AVAILABLE INTO @c_LOT, @c_LOC, @c_ID, @n_QtyAvailable
   END -- END WHILE FOR CURSOR_AVAILABLE

   EXIT_SP:

   IF CURSOR_STATUS('GLOBAL' , 'CURSOR_AVAILABLE') in (0 , 1)
   BEGIN
      CLOSE CURSOR_AVAILABLE
      DEALLOCATE CURSOR_AVAILABLE
   END
   
   EXEC isp_Cursor_Allocate_Candidates
        @n_SkipPreAllocationFlag = 1          
   */     
END -- Procedure
GO
GRANT EXECUTE ON  [dbo].[nspALTRF03] TO [NSQL]
GO
