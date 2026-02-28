SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: nspAL_SG12                                         */
/* Creation Date: 21-Aug-2024                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-26017 - SG - Multi Storer  - ASRS Allocation Strategy   */
/*          UOM 1,2,6 FIFO                                              */
/*          SkipPreallocation = '1'                                     */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* Github Version: 1.1                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver.  Purposes                                  */
/* 21-Aug-2024  WLChooi 1.0   DevOps Combine Script                     */
/* 25-Jun-2025  WLChooi 1.1   UWP-36187-Support Multi Facilities(WL01)  */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[nspAL_SG12]        
   @c_Orderkey   NVARCHAR(10),  
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
   @c_OtherParms NVARCHAR(200)=''
AS    
BEGIN    
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_debug       INT,      
           @c_SQL         NVARCHAR(MAX),    
           @c_SQLParm     NVARCHAR(MAX)    
          
   DECLARE @n_QtyAvailable     INT,  
           @c_LOT              NVARCHAR(10),
           @c_LOC              NVARCHAR(10),
           @c_ID               NVARCHAR(18), 
           @c_OtherValue       NVARCHAR(20),
           @n_QtyToTake        INT,
           @c_PrevLOT          NVARCHAR(10),
           @n_LotQtyAvailable  INT,
           @n_LocQty           INT,
           @n_NoOfLot          INT, 
           @c_Conditions       NVARCHAR(2000), 
           @c_Key1             NVARCHAR(10),
           @c_Key2             NVARCHAR(5), 
           @c_Key3             NVARCHAR(1), 
           @c_SORTUOM1         NVARCHAR(1000), 
           @c_SORTNOTUOM1      NVARCHAR(1000),
           @n_RowID            INT,
           @dt_Lottable05      DATETIME,
           @dt_GetLottable05   DATETIME,
           @n_PrevLotQtyAvailable INT

   SET @b_debug = 0
   SET @n_QtyAvailable = 0          
   SET @c_OtherValue = '1' 
   SET @n_QtyToTake = 0
   SET @c_Conditions = '' 
   
   EXEC isp_Init_Allocate_Candidates

   IF LEN(@c_OtherParms) > 0 
   BEGIN
      SET @c_OrderKey = LEFT(@c_OtherParms,10) 
      SET @c_key1 = LEFT(@c_OtherParms, 10) --Orderkey, Loadkey(conso), Wavekey(conso)
      SET @c_key2 = SUBSTRING(@c_OtherParms, 11, 5) --OrderLineNumber             
      SET @c_key3 = SUBSTRING(@c_OtherParms, 16, 1) --W=Wave                     
   END

   CREATE TABLE #T_INV
   (
      RowID        INT NOT NULL IDENTITY(1, 1)
    , Lot          NVARCHAR(10)
    , Loc          NVARCHAR(10)
    , ID           NVARCHAR(18)
    , QtyAvailable INT
    , CaseQty      INT
    , LooseQty     INT
    , Casecnt      INT
    , UsedFlag     INT DEFAULT 0
    , Lottable05   DATETIME
   )
   
   SET @c_SORTUOM1 = ' ORDER BY F.FacSort, LA.Lottable05, CASE WHEN ((LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QtyReplen - ISNULL(TRFLLI.FromQty,0)) % @n_QtyLeftToFulfill) = 0 THEN 1 ELSE 2 END '  + CHAR(13)   --WL01
                   + '        , 4, CASE WHEN LOC.LocationCategory <> ''ASRS'' THEN 1 ELSE 2 END, LOC.LogicalLocation, LOC.LOC '
   SET @c_SORTNOTUOM1 = ' ORDER BY F.FacSort, LA.Lottable05, 4, CASE WHEN LOC.LocationCategory <> ''ASRS'' THEN 1 ELSE 2 END, LOC.LogicalLocation, LOC.LOC '   --WL01

   SET @c_SQL = N'   
      INSERT INTO #T_INV ( Lot, Loc, ID, QtyAvailable, CaseQty, LooseQty, Casecnt, Lottable05 )
      SELECT LOTxLOCxID.LOT,
             LOTxLOCxID.LOC,
             LOTxLOCxID.ID,
             QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QtyReplen - ISNULL(TRFLLI.FromQty,0)),
             CaseQty  = (LOTxLOCxID.Qty - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyPicked - LOTxLOCxID.QtyReplen - ISNULL(TRFLLI.FromQty,0)) / CAST(PACK.CaseCnt AS INT) * PACK.CaseCnt,
             LooseQty = (LOTxLOCxID.Qty - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyPicked - LOTxLOCxID.QtyReplen - ISNULL(TRFLLI.FromQty,0)) % CAST(PACK.CaseCnt AS INT),
             Casecnt = PACK.CaseCnt,
             LA.Lottable05
      FROM LOTxLOCxID (NOLOCK)
      JOIN LOC (NOLOCK) ON (LOTxLOCxID.Loc = LOC.LOC)
      JOIN ID (NOLOCK) ON (LOTxLOCxID.Id = ID.ID)
      JOIN LOT (NOLOCK) ON (LOTXLOCXID.LOT = LOT.LOT)
      JOIN LOTATTRIBUTE LA (NOLOCK) ON (LOT.LOT = LA.LOT)
      JOIN SKU (NOLOCK) ON (LOTxLOCxID.Storerkey = SKU.Storerkey AND LOTxLOCxID.Sku = SKU.Sku)
      JOIN PACK (NOLOCK) ON (SKU.Packkey = PACK.Packkey)
      JOIN SKUXLOC SL (NOLOCK) ON (LOTxLOCxID.Storerkey = SL.Storerkey AND LOTxLOCxID.Sku = SL.Sku AND LOTxLOCxID.Loc = SL.Loc)
      JOIN ( SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(@c_Storerkey, @c_Facility)) F ON LOC.Facility = F.Facility   --WL01
      LEFT JOIN (SELECT TD.FromLot, TD.FromLoc, TD.FromID, SUM(TD.FromQty) AS FromQty
                 FROM TRANSFER T (NOLOCK)
                 JOIN TRANSFERDETAIL TD (NOLOCK) ON T.Transferkey = TD.Transferkey
                 WHERE TD.Status <> ''9''
                 AND TD.FromStorerkey = @c_StorerKey' +
               ' AND TD.FromSku = @c_Sku ' +
               ' GROUP BY TD.FromLot, TD.FromLoc, TD.FromID) AS TRFLLI ON LOTxLOCxID.Lot = TRFLLI.FromLot 
                                                                      AND LOTxLOCxID.Loc = TRFLLI.FromLoc 
                                                                      AND LOTxLOCxID.ID = TRFLLI.FromID 
      WHERE LOC.LocationFlag <> ''HOLD''
      AND LOC.LocationFlag <> ''DAMAGE''
      AND LOC.Status <> ''HOLD''
      AND LOT.Status <> ''HOLD''
      AND ID.Status <> ''HOLD''
      /*AND LOC.Facility = @c_Facility*/   --WL01
      AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QtyReplen - ISNULL(TRFLLI.FromQty,0)) > 0
      AND LOTxLOCxID.STORERKEY = @c_StorerKey
      AND LOTxLOCxID.SKU = @c_SKU 
      AND SL.LocationType NOT IN (''PICK'',''CASE'') ' +
      CASE WHEN @c_UOM = '1' THEN '  AND (LOTxLOCxID.QTYALLOCATED + LOTxLOCxID.QtyReplen - ISNULL(TRFLLI.FromQty,0)) = 0 ' ELSE ' ' END + 
      CASE WHEN ISNULL(RTRIM(@c_Lottable01),'') = '' THEN '' ELSE ' AND LA.Lottable01 = @c_Lottable01 ' END +
      CASE WHEN ISNULL(RTRIM(@c_Lottable02),'') = '' THEN '' ELSE ' AND LA.Lottable02 = @c_Lottable02 ' END +
      CASE WHEN ISNULL(RTRIM(@c_Lottable03),'') = '' THEN '' ELSE ' AND LA.Lottable03 = @c_Lottable03 ' END +
      CASE WHEN CONVERT(NVARCHAR(8) ,@d_Lottable04 ,112) <> '19000101' AND @d_Lottable04 IS NOT NULL THEN ' AND LA.Lottable04 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable04, 106)) ' ELSE ' ' END +
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
      --CASE WHEN @c_UOM = '1' THEN ' AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QtyReplen) <= @n_QtyLeftToFulfill ' ELSE ' ' END +
      --CASE WHEN @c_UOM = '1' THEN ' AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QtyReplen) >= ISNULL(PACK.CaseCnt,0) ' ELSE ' ' END +
      CASE WHEN @c_UOM <> '1' THEN ' AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QtyReplen - ISNULL(TRFLLI.FromQty,0)) >= 1 ' ELSE ' ' END  +
      ' ' + TRIM(ISNULL(@c_Conditions,'')) + ' ' + 
      CASE WHEN @c_UOM = '1' THEN @c_SORTUOM1 ELSE ' ' END +   
      CASE WHEN @c_UOM <> '1' THEN @c_SORTNOTUOM1 ELSE ' ' END  

   SET @c_SQLParm =  N'@c_Facility   NVARCHAR(5),  @c_StorerKey  NVARCHAR(15), @c_SKU NVARCHAR(20), @n_QtyLeftToFulfill INT, @n_UOMBase INT, ' +
                      '@c_Lottable01 NVARCHAR(18), @c_Lottable02 NVARCHAR(18), @c_Lottable03 NVARCHAR(18), @d_Lottable04 DATETIME, @d_Lottable05 DATETIME, ' +
                      '@c_Lottable06 NVARCHAR(30), @c_Lottable07 NVARCHAR(30), @c_Lottable08 NVARCHAR(30), @c_Lottable09 NVARCHAR(30), @c_Lottable10 NVARCHAR(30), ' +
                      '@c_Lottable11 NVARCHAR(30), @c_Lottable12 NVARCHAR(30), @d_Lottable13 DATETIME, @d_Lottable14 DATETIME, @d_Lottable15 DATETIME ' 

   EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm, @c_Facility, @c_StorerKey, @c_SKU, @n_QtyLeftToFulfill, @n_UOMBase, @c_Lottable01, @c_Lottable02, @c_Lottable03,
                      @d_Lottable04, @d_Lottable05, @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10, @c_Lottable11, @c_Lottable12,
                      @d_Lottable13, @d_Lottable14, @d_Lottable15

   --UOM 1,2
   --Steps:
   --1. Allocate Full Pallet only with no loose Qty
   --UOM 6
   --Steps:
   --1. Allocate Loose Qty only
   --2. If no more Loose Qty, allocate from Pallet
   --SELECT @c_UOM AS UOM,@n_QtyLeftToFulfill AS QtyLeftToFulfill,* FROM #T_INV
   IF @c_UOM IN ('1', '2')
   BEGIN
      DECLARE CURSOR_AVAILABLE CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT Lot, Loc, ID, QtyAvailable = CaseQty, RowID, Lottable05
      FROM #T_INV
      WHERE QtyAvailable > 0
      ORDER BY Lottable05, CASE WHEN LooseQty = 0 THEN 1 ELSE 2 END, RowID
   END
   ELSE
   BEGIN
      DECLARE CURSOR_AVAILABLE CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT Lot, Loc, ID, QtyAvailable = LooseQty, RowID, Lottable05
      FROM #T_INV
      WHERE LooseQty > 0
      ORDER BY Lottable05, RowID
   END

   SET @c_SQL = ''
   SET @c_PrevLOT = ''
   SET @n_LotQtyAvailable = 0
   
   OPEN CURSOR_AVAILABLE                    
   FETCH NEXT FROM CURSOR_AVAILABLE INTO @c_LOT, @c_LOC, @c_ID, @n_QtyAvailable, @n_RowID, @dt_GetLottable05
       
   WHILE (@@FETCH_STATUS <> -1) AND (@n_QtyLeftToFulfill > 0)          
   BEGIN
      IF @c_LOT <> @c_PrevLOT 
      BEGIN
         SELECT @n_LotQtyAvailable = SUM(Qty - QtyAllocated - QtyPicked)
                - (SELECT ISNULL(SUM(TD.FromQty),0) 
                   FROM TRANSFER T (NOLOCK)
                   JOIN TRANSFERDETAIL TD (NOLOCK) ON T.Transferkey = TD.Transferkey
                   AND TD.Status <> '9' 
                   AND TD.FromLot = LOT.Lot) 
         FROM LOT (NOLOCK)
         WHERE LOT = @c_LOT
         GROUP BY Lot
      END
   
      IF @n_LotQtyAvailable < @n_QtyAvailable 
      BEGIN
         IF @c_UOM = '1' 
            SET @n_QtyAvailable = 0
         ELSE
            SET @n_QtyAvailable = @n_LotQtyAvailable
      END
      
      --Strict FIFO
      SET @n_PrevLotQtyAvailable = 0
      SELECT @n_PrevLotQtyAvailable = SUM(QtyAvailable)
      FROM #T_INV
      WHERE DATEDIFF(DAY, Lottable05, @dt_GetLottable05) > 0
      AND QtyAvailable > 0
      
      SET @n_PrevLotQtyAvailable = ISNULL(@n_PrevLotQtyAvailable, 0)

      IF @n_PrevLotQtyAvailable >= @n_QtyLeftToFulfill       
         BREAK

      IF @c_UOM = '1' --Pallet
      BEGIN
         SELECT @n_LocQty = 0, @n_NoOfLot = 0
           
         SELECT @n_LocQty = SUM(LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen),
                @n_NoOfLot = COUNT(DISTINCT LLI.Lot)
         FROM LOTXLOCXID LLI (NOLOCK)
         WHERE LLI.Loc = @c_LOC
         AND LLI.ID = @c_ID
         AND LLI.Storerkey = @c_Storerkey
         AND LLI.Sku = @c_Sku 
         AND LLI.Qty > 0
                        
         IF (@n_QtyLeftToFulfill - @n_PrevLotQtyAvailable) >= @n_QtyAvailable 
            AND @n_NoOfLot = 1 -- if multi lot per sku/loc/id then proceed to next strategy allocation by carton
         BEGIN                       
            SET @n_QtyToTake = @n_QtyAvailable  
         END
         ELSE
         BEGIN
            SET @n_QtyToTake = 0
         END

         IF @n_QtyAvailable > @n_QtyLeftToFulfill --not to proceed to next plt since the current lot no more fit plt, next fit plt could be new lot
         BEGIN
            GOTO EXIT_SP 
         END
      END
      
      IF @c_UOM <> '1' --Case/Piece 
      BEGIN
         IF (@n_QtyLeftToFulfill - @n_PrevLotQtyAvailable) >= @n_QtyAvailable
         BEGIN
            SET @n_QtyToTake = FLOOR(@n_QtyAvailable / @n_UOMBase) * @n_UOMBase
         END
         ELSE
         BEGIN
            SET @n_QtyToTake = Floor((@n_QtyLeftToFulfill - @n_PrevLotQtyAvailable) / @n_UOMBase) * @n_UOMBase
         END    
      END
   
      IF @n_QtyToTake > 0
      BEGIN
         IF @n_QtyToTake = @n_QtyAvailable AND @c_UOM = '1'
            SET @c_OtherValue = 'FULLPALLET' 
         ELSE
            SET @c_OtherValue = '1'          
      
         EXEC isp_Insert_Allocate_Candidates
              @c_Lot = @c_Lot
           ,  @c_Loc = @c_Loc
           ,  @c_ID  = @c_ID
           ,  @n_QtyAvailable = @n_QtyToTake
           ,  @c_OtherValue = @c_OtherValue

         SET @n_QtyLeftToFulfill = @n_QtyLeftToFulfill - @n_QtyToTake       
         SET @n_LotQtyAvailable = @n_LotQtyAvailable - @n_QtyToTake    
      END

      UPDATE #T_INV
      SET UsedFlag = IIF(@c_UOM = '6', 1, UsedFlag)
        , QtyAvailable = QtyAvailable - @n_QtyToTake
      WHERE RowID = @n_RowID
   
      --Refresh INV balance
      UPDATE #T_INV
      SET CaseQty = QtyAvailable / Casecnt * Casecnt
        , LooseQty = QtyAvailable % Casecnt
      WHERE RowID = @n_RowID

      NEXT_LOOP:
      SET @c_PrevLOT = @c_LOT
   
      FETCH NEXT FROM CURSOR_AVAILABLE INTO @c_LOT, @c_LOC, @c_ID, @n_QtyAvailable, @n_RowID, @dt_GetLottable05
   END -- END WHILE FOR CURSOR_AVAILABLE
   CLOSE CURSOR_AVAILABLE          
   DEALLOCATE CURSOR_AVAILABLE 
   
   --For UOM 6 Step 2 - If no more Loose Qty, allocate from Pallet
   --Prioritize those pallet which had loose qty before - UsedFlag = 1
   IF @c_UOM = '6' AND @n_QtyLeftToFulfill > 0
   BEGIN
      DECLARE CURSOR_AVAILABLE CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT Lot, Loc, ID, QtyAvailable, RowID, Lottable05
      FROM #T_INV
      WHERE LooseQty = 0
      AND QtyAvailable > 0
      ORDER BY UsedFlag DESC
             , RowID ASC
   
      SET @c_SQL = ''
      SET @c_PrevLOT = ''
      SET @n_LotQtyAvailable = 0
   
      OPEN CURSOR_AVAILABLE                    
      FETCH NEXT FROM CURSOR_AVAILABLE INTO @c_LOT, @c_LOC, @c_ID, @n_QtyAvailable, @n_RowID, @dt_GetLottable05
          
      WHILE (@@FETCH_STATUS <> -1) AND (@n_QtyLeftToFulfill > 0)          
      BEGIN
         IF @c_LOT <> @c_PrevLOT 
         BEGIN
            SELECT @n_LotQtyAvailable = SUM(Qty - QtyAllocated - QtyPicked)            
                   - (SELECT ISNULL(SUM(TD.FromQty),0) 
                      FROM TRANSFER T (NOLOCK)
                      JOIN TRANSFERDETAIL TD (NOLOCK) ON T.Transferkey = TD.Transferkey
                      AND TD.Status <> '9' 
                      AND TD.FromLot = LOT.Lot)
            FROM LOT (NOLOCK)
            WHERE LOT = @c_LOT
            GROUP BY Lot
         END
      
         IF @n_LotQtyAvailable < @n_QtyAvailable 
         BEGIN
            SET @n_QtyAvailable = @n_LotQtyAvailable
         END

         --Strict FIFO
         SET @n_PrevLotQtyAvailable = 0
         SELECT @n_PrevLotQtyAvailable = SUM(QtyAvailable)
         FROM #T_INV
         WHERE DATEDIFF(Day, Lottable05, @dt_GetLottable05) > 0
         AND QtyAvailable > 0
         
         SET @n_PrevLotQtyAvailable = ISNULL(@n_PrevLotQtyAvailable, 0)
         
         IF @n_PrevLotQtyAvailable >= @n_QtyLeftToFulfill       
            BREAK
   
         IF (@n_QtyLeftToFulfill - @n_PrevLotQtyAvailable) >= @n_QtyAvailable
         BEGIN
            SET @n_QtyToTake = Floor(@n_QtyAvailable / @n_UOMBase) * @n_UOMBase
         END
         ELSE
         BEGIN
            SET @n_QtyToTake = Floor((@n_QtyLeftToFulfill - @n_PrevLotQtyAvailable) / @n_UOMBase) * @n_UOMBase
         END         
      
         IF @n_QtyToTake > 0
         BEGIN
            SET @c_OtherValue = '1'          
         
            EXEC isp_Insert_Allocate_Candidates
                 @c_Lot = @c_Lot
              ,  @c_Loc = @c_Loc
              ,  @c_ID  = @c_ID
              ,  @n_QtyAvailable = @n_QtyToTake
              ,  @c_OtherValue = @c_OtherValue
   
            SET @n_QtyLeftToFulfill = @n_QtyLeftToFulfill - @n_QtyToTake       
            SET @n_LotQtyAvailable = @n_LotQtyAvailable - @n_QtyToTake   
         
            UPDATE #T_INV
            SET UsedFlag = 1
              , QtyAvailable = QtyAvailable - @n_QtyToTake
            WHERE RowID = @n_RowID
         END
      
         --Refresh INV balance
         UPDATE #T_INV
         SET CaseQty = QtyAvailable / Casecnt * Casecnt
           , LooseQty = QtyAvailable % Casecnt
         WHERE RowID = @n_RowID

         SET @c_PrevLOT = @c_LOT
      
         FETCH NEXT FROM CURSOR_AVAILABLE INTO @c_LOT, @c_LOC, @c_ID, @n_QtyAvailable, @n_RowID, @dt_GetLottable05
      END -- END WHILE FOR CURSOR_AVAILABLE
      CLOSE CURSOR_AVAILABLE          
      DEALLOCATE CURSOR_AVAILABLE 
   END

   EXIT_SP:

   IF CURSOR_STATUS('GLOBAL' , 'CURSOR_AVAILABLE') IN (0 , 1)          
   BEGIN          
      CLOSE CURSOR_AVAILABLE
      DEALLOCATE CURSOR_AVAILABLE
   END    

   EXEC isp_Cursor_Allocate_Candidates
         @n_SkipPreAllocationFlag = 1    --Return Lot column
END -- Procedure
GO
GRANT EXECUTE ON [dbo].[nspAL_SG12] TO [nSQL]
GO