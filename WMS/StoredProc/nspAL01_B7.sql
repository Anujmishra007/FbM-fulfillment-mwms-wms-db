SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Stored Procedure: nspAL01_B7                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver. Purposes                                  */
/* 20-Nov-2024  WLChooi  1.1  DevOps Combine Script                     */
/* 20-Nov-2024  WLChooi  1.1  WMS-26556-Support Multi Facilities(WL01)  */
/************************************************************************/

CREATE OR ALTER PROC nspAL01_B7  -- rename from IDSSG:nspAL01_07
@c_lot NVARCHAR(10) ,
@c_uom NVARCHAR(10) ,
@c_HostWHCode NVARCHAR(10),
@c_Facility NVARCHAR(5),
@n_uombase int ,
@n_qtylefttofulfill int
AS
BEGIN
   SET NOCOUNT ON 

   DECLARE  CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY
   FOR SELECT LOTxLOCxID.LOC,LOTxLOCxID.ID,
   QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), '1'
   FROM LOTxLOCxID (NOLOCK)
   JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC   --WL01
   JOIN ID (NOLOCK) ON LOTxLOCxID.Id = ID.ID   --WL01
   CROSS APPLY ( SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F   --WL01
   WHERE LOTxLOCxID.Lot = @c_lot
   AND LOC.Facility = F.Facility   --WL01
   --AND LOC.Facility = @c_Facility   --WL01
   AND LOC.Locationflag <>"HOLD"
   AND LOC.Locationflag <> "DAMAGE"
   AND LOC.Status <> "HOLD"
   AND ID.STATUS <> "HOLD"
   AND LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED > 0
   ORDER BY F.FacSort, LOC.LogicalLocation, LOC.LOC   --WL01
END

GO

GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON nspAL01_B7 to nSQL
GO
