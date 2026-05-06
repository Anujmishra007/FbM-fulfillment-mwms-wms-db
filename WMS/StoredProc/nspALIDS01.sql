SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: nspALIDS01                                         */
/* Creation Date:                                                       */
/* Copyright: MAERSK                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
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
/* 25-Jun-2025  WLChooi 1.1   UWP-36187-Support Multi Facilities(WL01)  */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[nspALIDS01]
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
   FROM LOTxLOCxID (NOLOCK)
   JOIN LOC (NOLOCK) ON LOC.Loc = LOTxLOCxID.Loc   --WL01
   JOIN ID (NOLOCK) ON ID.ID = LOTxLOCxID.ID   --WL01
   CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F   --WL01
   WHERE LOTxLOCxID.Lot = @c_lot
   AND ID.Status <> "HOLD"
   AND LOC.Locationflag <> "HOLD"
   AND LOC.Locationflag <> "DAMAGE"
   AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) >= @n_uombase
   AND LOC.Status <> "HOLD"
   --AND LOC.Facility = @c_Facility   --WL01
   ORDER BY F.FacSort, LOTxLOCxID.LOC   --WL01
END
GO
GRANT EXECUTE ON  [dbo].[nspALIDS01] TO [NSQL]
GO