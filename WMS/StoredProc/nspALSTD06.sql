SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: nspALstd06                                         */
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
/* 11-MAR-2026  surya    1.2  Reverse the eirlier chages                */
/************************************************************************/
CREATE OR ALTER PROC nspALSTD06
@c_lot NVARCHAR(10) ,
@c_uom NVARCHAR(10) ,
@c_HostWHCode NVARCHAR(10),
@c_Facility NVARCHAR(5),
@n_uombase int ,
@n_qtylefttofulfill int,
@c_OtherParms       NVARCHAR(200) = ''
AS
BEGIN
   SET NOCOUNT ON

   --debug
   PRINT '@c_uom=' + @c_uom +  ', @n_uombase=' + CONVERT(NVARCHAR, @n_uombase)+ 
   ',@n_qtylefttofulfill=' + CONVERT(NVARCHAR, @n_qtylefttofulfill)+ ', @c_Facility=' + @c_Facility+
   ', @c_HostWHCode=' + @c_HostWHCode + ', @c_OtherParms=' + @c_OtherParms + ', @c_lot=' + @c_lot

   DECLARE  CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY
   FOR SELECT LOTxLOCxID.LOC, LOTxLOCxID.ID,
   QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), '1'
   FROM LOTxLOCxID (NOLOCK)
   JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC   --WL01
   JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey   --WL01
                        AND LOTxLOCxID.Sku = SKUxLOC.Sku   --WL01
                        AND LOTxLOCxID.Loc = SKUxLOC.Loc   --WL01
   CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F   --WL01
   WHERE LOTxLOCxID.Lot = @c_lot
   AND SKUxLOC.Locationtype ="PICK"
   AND LOC.Locationflag <>"HOLD"
   AND LOC.Locationflag <> "DAMAGE"
   AND LOC.Status <> "HOLD"
   --AND LOC.Facility = @c_Facility   --WL01
   AND LOC.Facility = F.Facility   --WL01
   -- Changed by June 17.Jul.03 SOS12446, sort by Logicalloc first
   ORDER BY F.FacSort, LOC.LogicalLocation, LOC.LOC   --WL01
END
GO
GRANT EXECUTE ON nspALSTD06 TO NSQL
GO