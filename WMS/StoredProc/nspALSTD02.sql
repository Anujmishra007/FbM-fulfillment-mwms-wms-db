SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: nspALstd02                                         */
/* Creation Date:                                                       */
/* Copyright:                                                           */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver. Purposes                                  */
/* 20-Nov-2024  WLChooi  1.1  DevOps Combine Script                     */
/* 20-Nov-2024  WLChooi  1.1  WMS-26556-Support Multi Facilities(WL01)  */
/************************************************************************/

CREATE OR ALTER PROC nspALSTD02
@c_lot NVARCHAR(10) ,
@c_uom NVARCHAR(10) , 
@c_HostWHCode NVARCHAR(10),
@c_Facility NVARCHAR(5),
@n_uombase int ,
@n_qtylefttofulfill int,  
@c_OtherParms NVARCHAR(200) = ''
AS
BEGIN 
   SET NOCOUNT ON 

   DECLARE  CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY
   FOR SELECT LOTxLOCxID.LOC, LOTxLOCxID.ID,
   QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), '1'
   FROM LOTxLOCxID (NOLOCK)   --WL01
   JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC   --WL01
   JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey   --WL01
                        AND LOTxLOCxID.Sku = SKUxLOC.Sku   --WL01
                        AND LOTxLOCxID.Loc = SKUxLOC.Loc   --WL01
   JOIN LOT (NOLOCK) ON LOTXLOCXID.LOT = LOT.LOT --SOS131215 START   --WL01  
   JOIN ID (NOLOCK) ON LOTXLOCXID.ID  = ID.ID  ---SOS131215 END   --WL01  
   CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F   --WL01
   WHERE LOTxLOCxID.Lot = @c_lot
   AND SKUxLOC.Locationtype = "CASE" 
   --AND LOC.Facility = @c_Facility   --WL01
   AND LOC.Facility = F.Facility   --WL01
   AND LOC.Locationflag <>"HOLD"
   AND LOC.Locationflag <> "DAMAGE"
   AND LOC.Status <> "HOLD"
   AND LOT.Status <> "HOLD" --SOS131215 START  
   AND ID.Status <> "HOLD" ---SOS131215 END  
   ORDER BY F.FacSort, LOC.LOC   --WL01
END
GO 
GRANT EXECUTE ON nspALSTD02 TO NSQL 
GO