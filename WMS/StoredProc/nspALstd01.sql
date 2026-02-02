SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: nspALstd01                                         */
/* Creation Date: 05-Aug-2002                                           */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.3                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 14-Oct-2004	 Mohit			Change cursor type								*/
/* 18-Jul-2005	 Loon				Add Drop Object statement						*/
/* 11-Aug-2005	 MaryVong		Remove SET ANSI WARNINGS which caused     */
/*										error in DX			                        */
/* 19-Mar-2009  Audrey        SOS131215 : Added in Lot.status <>"HOLD"	*/
/* 26-Apr-2015  TLTING01 1.1  Add Other Parameter default value         */ 
/* 20-Nov-2024  WLChooi  1.2  DevOps Combine Script                     */
/* 20-Nov-2024  WLChooi  1.2  WMS-26556-Support Multi Facilities(WL01)  */
/************************************************************************/

CREATE OR ALTER PROC nspALstd01
@c_lot NVARCHAR(10) ,
@c_uom NVARCHAR(10) ,
@c_HostWHCode NVARCHAR(10),
@c_Facility NVARCHAR(5),
@n_uombase INT ,
@n_qtylefttofulfill INT,  
@c_OtherParms NVARCHAR(200) = ''
AS
BEGIN
   SET NOCOUNT ON 

   DECLARE  CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY
   FOR SELECT LOTxLOCxID.LOC, LOTxLOCxID.ID,
   QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), '1'
   FROM LOTxLOCxID (NOLOCK)
   JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC   --WL01
   JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Loc = SKUxLOC.Loc AND LOTxLOCxID.Sku = SKUxLOC.Sku   --WL01
   JOIN ID (NOLOCK) ON LOTxLOCxID.ID = ID.ID   --WL01
   JOIN LOT (NOLOCK) ON LOTxLOCxID.Lot = LOT.Lot   --WL01
   CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F   --WL01
   WHERE LOTxLOCxID.Lot = @c_lot
   AND ID.Status <> "HOLD"
   --AND LOC.Facility = @c_Facility   --WL01
   AND LOC.Facility = F.Facility   --WL01
   AND LOC.Locationflag <> "HOLD"
   AND LOC.Locationflag <> "DAMAGE"
   AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) >= @n_uombase
   AND LOC.Status <> "HOLD"
   AND LOT.STATUS <> "HOLD"  --SOS131215
   AND SKUxLOC.LocationType NOT IN ("PICK", "CASE")
   ORDER BY F.FacSort, LOTxLOCxID.LOC   --WL01
END
GO
GRANT EXECUTE ON nspALstd01 TO nSQL
GO