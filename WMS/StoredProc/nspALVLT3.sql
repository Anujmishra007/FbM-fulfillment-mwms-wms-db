SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: nspALVLT                                           */
/*                                                                      */
/* Purpose: Allocating FROM WA / VNA THEN checking FIFO AND THEN PICK   */
/*                                                                      */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver.  Purposes                                  */
/* 05-MAY-2024  PPA374  1.0   Violet Allocation                         */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[nspALVLT3]
   @c_DocumentNo              NVARCHAR(10),
   @c_Facility                NVARCHAR(5),
   @c_StorerKey               NVARCHAR(15),
   @c_SKU                     NVARCHAR(20),
   @c_Lottable01              NVARCHAR(18),
   @c_Lottable02              NVARCHAR(18),
   @c_Lottable03              NVARCHAR(18),
   @d_Lottable04              DATETIME,
   @d_Lottable05              DATETIME,
   @c_Lottable06              NVARCHAR(30),
   @c_Lottable07              NVARCHAR(30),
   @c_Lottable08              NVARCHAR(30),
   @c_Lottable09              NVARCHAR(30),
   @c_Lottable10              NVARCHAR(30),
   @c_Lottable11              NVARCHAR(30),
   @c_Lottable12              NVARCHAR(30),
   @d_Lottable13              DATETIME,
   @d_Lottable14              DATETIME,
   @d_Lottable15              DATETIME,
   @c_UOM                     NVARCHAR(10),
   @c_HostWHCode              NVARCHAR(10),
   @n_UOMBase                 INT,
   @n_QtyLeftToFulfill        INT,
   @c_OtherParms              NVARCHAR(200)=''
AS
BEGIN
   SET NOCOUNT ON
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   DECLARE
   @c_SQL                NVARCHAR(MAX),
   @c_SQLParm            NVARCHAR(MAX),
   @n_QtyAvailable       INT,
   @c_LOT                NVARCHAR(10),
   @c_LOC                NVARCHAR(10),
   @c_ID                 NVARCHAR(18),
   @c_OtherValue         NVARCHAR(20),
   @n_QtyToTake          INT,
   @n_StorerMinShelfLife INT,
   @n_LotQtyAvailable    INT,
   @c_ExpireCode         NVARCHAR(30),
   @c_FromDay            NVARCHAR(10),
   @c_ToDay              NVARCHAR(10),
   @c_ShelfLifeRange     NCHAR(1),
   @c_packkey            NVARCHAR(20),
   @n_casecnt            INT,
   @n_LeftQtyToFulfill   INT,
   @n_caseqty            INT,
   @ParcelOrder          INT
   SET @n_QtyAvailable = 0
   SET @c_OtherValue = case when @c_UOM = 1 then '@c_FULLPALLET=Y' else '1' end
   SET @n_QtyToTake = 0
   SET @n_LeftQtyToFulfill = 0
   SET @n_caseqty          = 0
   SET @ParcelOrder = case when (select isnull(UserDefine10,0) from orders (NOLOCK) where StorerKey = @c_StorerKey
   and orderkey = left(@c_OtherParms,10)) not in ('Non-Parcel','') then 1 else 0 end
   EXEC isp_Init_Allocate_Candidates
   DECLARE CURSOR_AVAILABLE CURSOR FAST_FORWARD READ_ONLY FOR
   SELECT LOT,LOC,ID,QTYAVAILABLE FROM
   (SELECT LOT,LOC,ID,QTYAVAILABLE,minlot, qtyinloc, PutawayZone, Sku, locationtype, lottable05,
   sum(QTYAVAILABLE)OVER(ORDER BY
   CASE WHEN qtyinloc =
   (SELECT OpenQty - QtyAllocated - QtyPicked - QtyPreAllocated - ShippedQty FROM ORDERDETAIL (NOLOCK)
   WHERE storerkey = @c_StorerKey and OrderKey = left(@c_OtherParms,10) AND orderlinenumber = right(left(@c_OtherParms,15),5)) THEN 1 ELSE 99 END,
   CASE WHEN exists
   (SELECT code FROM CODELKUP (NOLOCK) WHERE LISTNAME = 'VNAZONHUSQ' and storerkey = @c_Storerkey and PutawayZone = code)
   THEN 1
   WHEN exists (SELECT code FROM CODELKUP (NOLOCK) WHERE LISTNAME = 'WAZONEHUSQ' and storerkey = @c_Storerkey and PutawayZone = code) THEN 1 ELSE 2 END
   ,case when Lottable05 is null then 'XX'+minlot else convert(nvarchar,Lottable05)end, qtyinloc DESC, Loc, Lot)RollingSum
   ,(SELECT OpenQty - QtyAllocated - QtyPicked - QtyPreAllocated - ShippedQty FROM ORDERDETAIL (NOLOCK)
   WHERE storerkey = @c_StorerKey and OrderKey = left(@c_OtherParms,10) AND orderlinenumber = right(left(@c_OtherParms,15),5))TotalQtyToPick
   FROM
   (SELECT LOT,LOC,ID,QTYAVAILABLE,minlot, qtyinloc, PutawayZone, Sku, LocationType, lottable05 FROM
   (SELECT LOC,ID,QTYAVAILABLE,sku,putawayzone,lot,locationtype,min(lot)OVER(PARTITION BY loc,id,sku)minlot, lottable05,
   (SELECT sum(qty-QtyAllocated-QtyPicked-QtyReplen) FROM LOTxLOCxID (NOLOCK) WHERE qty-QtyAllocated-QtyPicked-QtyReplen > 0
   AND loc = T1.loc AND id = t1.Id AND t1.sku = sku AND StorerKey = @c_StorerKey)qtyinloc FROM
   (SELECT LLI.Loc,LLI.ID,LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen QTYAVAILABLE,PutawayZone,LLI.LOT
   ,lot.Sku,LocationType, Lottable05
   FROM LOTXLOCXID (NOLOCK) LLI
   JOIN LOC (NOLOCK) ON LLI.LOC = LOC.LOC
   JOIN ID  (NOLOCK) ON LLI.ID = ID.ID
   JOIN LOT (NOLOCK) ON LLI.LOT = LOT.LOT
   JOIN LOTATTRIBUTE LA (NOLOCK) on LOT.LOT = LA.LOT
   WHERE LOC.Facility = @c_Facility
   AND lli.StorerKey = @c_StorerKey
   AND ISNULL(LOC.LocationFlag,'') IN ('','NONE')
   AND NOT exists (SELECT ID FROM INVENTORYHOLD (NOLOCK) WHERE hold = 1 AND ID <>'' and LLI.ID = ID)
   AND NOT exists (SELECT LOC FROM INVENTORYHOLD (NOLOCK) WHERE hold = 1 AND LOC <>'' and LOC.Loc = Loc)
   AND LOC.Status = 'OK'
   AND ID.Status = 'OK'
   AND LOT.Status = 'OK'
   AND exists (select code from CODELKUP (NOLOCK) where PutawayZone = code and Storerkey = 'HUSQ' and LISTNAME = 'HUSQALLZON' and ((short <> 'PICK' and @c_UOM = 1) or (short IN ('PICK','DAMAGED') and @c_UOM <> 1)))
   AND exists (select code from CODELKUP (NOLOCK) where PutawayZone = code and Storerkey = 'HUSQ' and LISTNAME = 'HUSQALLZON' and ((@ParcelOrder = 0) or (short IN ('PICK','DAMAGED') and @ParcelOrder = 1)))
   AND LOC.HOSTWHCODE = (SELECT IIF(ISNULL(UserDefine01,'A')='','A',ISNULL(UserDefine01,'A')) FROM ORDERDETAIL (NOLOCK) WHERE OrderKey = left(@c_OtherParms,10) AND orderlinenumber = right(left(@c_OtherParms,15),5))
   AND lli.sku = (SELECT top 1 sku FROM orderdetail (NOLOCK)WHERE OrderKey = left(@c_OtherParms,10) AND orderlinenumber = right(left(@c_OtherParms,15),5))
   AND exists (SELECT Code FROM CODELKUP WITH (NOLOCK) WHERE LOC.LocationType = code and listname = 'HUSQALLLOC' AND Storerkey = 'HUSQ')
   AND exists (SELECT code2 FROM CODELKUP WITH (NOLOCK) WHERE LocationCategory = code2 and listname = 'HUSQALLLOC' AND Storerkey = 'HUSQ')
   AND LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen > 0
   AND (LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen <=
   (SELECT OpenQty - QtyAllocated - QtyPicked - ShippedQty FROM ORDERDETAIL (NOLOCK)
   WHERE StorerKey = @c_StorerKey and OrderKey = left(@c_OtherParms,10) AND orderlinenumber = right(left(@c_OtherParms,15),5))
   or LOC.LocationType in ('PICK','SHELF','DAMAGED'))
   AND exists (SELECT Code FROM CODELKUP WITH (NOLOCK) WHERE PutawayZone = code and listname = 'HUSQALLZON' AND Storerkey = @c_StorerKey))T1)T2
   WHERE qtyinloc<=
   (SELECT OpenQty - QtyAllocated - QtyPicked - ShippedQty FROM ORDERDETAIL (NOLOCK)
   WHERE StorerKey = @c_StorerKey AND OrderKey = left(@c_OtherParms,10) AND orderlinenumber = right(left(@c_OtherParms,15),5))
   or LocationType in ('PICK','SHELF','DAMAGED'))T3)T4
   WHERE RollingSum <= TotalQtyToPick or LocationType in ('PICK','SHELF','DAMAGED')
   Order By CASE WHEN qtyinloc =
   (SELECT OpenQty - QtyAllocated - QtyPicked - QtyPreAllocated - ShippedQty FROM ORDERDETAIL (NOLOCK)
      WHERE StorerKey = @c_StorerKey AND OrderKey = left(@c_OtherParms,10) AND orderlinenumber = right(left(@c_OtherParms,15),5)) THEN 1 ELSE 99 END,
   CASE WHEN exists
   (SELECT code FROM CODELKUP (NOLOCK) WHERE PutawayZone = code and LISTNAME = 'VNAZONHUSQ' and Storerkey = @c_StorerKey)
   THEN 1
   WHEN exists (SELECT code FROM CODELKUP (NOLOCK) WHERE PutawayZone = code and LISTNAME = 'WAZONEHUSQ' and Storerkey = @c_StorerKey) THEN 1 ELSE 2 END
   , case when Lottable05 is null then 'XX'+minlot else convert(nvarchar,Lottable05)end, qtyinloc DESC, Loc, Lot
   OPEN CURSOR_AVAILABLE
   FETCH NEXT FROM CURSOR_AVAILABLE INTO @c_LOT, @c_LOC, @c_ID, @n_QtyAvailable
   WHILE (@@FETCH_STATUS <> -1) AND (@n_QtyLeftToFulfill > 0)
   BEGIN
      EXEC isp_Insert_Allocate_Candidates
      @c_Lot = @c_Lot
      ,@c_Loc = @c_Loc
      ,@c_ID  = @c_ID
      ,@n_QtyAvailable = @n_QtyAvailable
      ,@c_OtherValue = @c_OtherValue
      FETCH NEXT FROM CURSOR_AVAILABLE INTO @c_LOT, @c_LOC, @c_ID, @n_QtyAvailable
   END -- END WHILE FOR CURSOR_AVAILABLE
   EXIT_SP:
   IF CURSOR_STATUS('GLOBAL' , 'CURSOR_AVAILABLE') IN (0 , 1)
   BEGIN
      CLOSE CURSOR_AVAILABLE
      DEALLOCATE CURSOR_AVAILABLE
   END
   EXEC isp_Cursor_Allocate_Candidates
   @n_SkipPreAllocationFlag = 1
END
GO
