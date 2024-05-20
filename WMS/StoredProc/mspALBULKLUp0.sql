SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: mspALBULKLUp0                                      */
/* Creation Date: 2024-05-13                                            */
/* Copyright: Maersk                                                    */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */ 
/* 2024-05-20  Wan      1.0   Created.                                  */
/************************************************************************/

CREATE  OR ALTER PROC mspALBULKLUp0
   @c_lot               NVARCHAR(10)    
,  @c_uom               NVARCHAR(10)    
,  @c_HostWHCode        NVARCHAR(10) 
,  @c_Facility          NVARCHAR(5) 
,  @n_uombase           INT  
,  @n_qtylefttofulfill  INT
AS
BEGIN
   SET NOCOUNT ON 

   DECLARE  CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY
   FOR SELECT LOTxLOCxID.LOC, LOTxLOCxID.ID,
   QTYAVAILABLE = SUM(LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), '1'
   FROM LOTxLOCxID (NOLOCK), LOC (NOLOCK), SKUxLOC (NOLOCK)
   WHERE LOTxLOCxID.Lot = @c_lot
   AND LOTxLOCxID.Loc = LOC.LOC
   AND LOTxLOCxID.Storerkey = SKUxLOC.Storerkey
   AND LOTxLOCxID.Sku = SKUxLOC.Sku
   AND LOTxLOCxID.Loc = SKUxLOC.Loc
   AND SKUxLOC.Locationtype NOT IN ('CASE','PICK')
   AND LOC.Locationflag <>"HOLD"
   AND LOC.Locationflag <> "DAMAGE"
   AND LOC.Status <> "HOLD"
   AND LOC.Facility = @c_facility
   AND LOC.LocLevel > 0
   AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) > 0
   GROUP BY LOTxLOCxID.LOC, LOTxLOCxID.ID
   ORDER BY LOTXLOCXID.LOC
END

GO

GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON mspALBULKLUp0 TO nSQL
GO
