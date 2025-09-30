SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: nspALIDS06                                         */
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
/* 26-Jul-2005  June			   SOS38045 - bug fix zero Qtyavail return	*/
/* 26-Apr-2015  TLTING01 1.1  Add Other Parameter default value         */
/* 25-Jun-2025  WLChooi  1.2  UWP-36187-Support Multi Facilities(WL01)  */
/************************************************************************/

CREATE OR ALTER PROC    [dbo].[nspALIDS06]
   @c_lot NVARCHAR(10) ,
   @c_uom NVARCHAR(10) ,
   --@c_sectionkey NVARCHAR(3),
   --@c_oskey NVARCHAR(10),
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
   FROM LOTxLOCxID (NOLOCK)
   JOIN LOC (NOLOCK) ON LOC.Loc = LOTxLOCxID.Loc   --WL01
   JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey --WL01
                        AND LOTxLOCxID.Sku = SKUxLOC.Sku    --WL01
                        AND LOTxLOCxID.Loc = SKUxLOC.Loc    --WL01
   JOIN ID (NOLOCK) ON ID.Id = LOTxLOCxID.Id                --WL01
   CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F   --WL01
   WHERE LOTxLOCxID.Lot = @c_lot
     AND id.status = 'OK'
     AND SKUxLOC.Locationtype <> "OTHER"
     --AND LOC.Facility = @c_Facility   --WL01
     AND LOC.Locationflag <>"HOLD"
     AND LOC.Locationflag <> "DAMAGE"
     AND LOC.Status <> "HOLD"
     AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) > 0 -- SOS38045
   ORDER BY F.FacSort, LogicalLocation, LOC.LOC   --WL01
END
GO
GRANT EXECUTE ON  [dbo].[nspALIDS06] TO [NSQL]
GO
