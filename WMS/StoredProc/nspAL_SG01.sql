SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Stored Procedure: nspAL_SG01                                         */
/* Creation Date: 30-APR-2018                                           */
/* Copyright: LFL                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: WMS-4778 SG BAT Pre-allocation by consignee shelf life      */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver. Purposes                                  */
/* 25-Jun-2025  WLChooi  1.1  UWP-36187-Support Multi Facilities(WL01)  */
/************************************************************************/

CREATE OR ALTER PROC    [dbo].[nspAL_SG01]
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

   DECLARE @c_OrderKey NVARCHAR(10),
           @c_OrderLineNumber NVARCHAR(5),
           @c_Susr1 NVARCHAR(18)

   IF ISNULL(@c_OtherParms,'') <> ''
   BEGIN
      SELECT @c_OrderKey = LEFT(LTRIM(@c_OtherParms), 10)
      SELECT @c_OrderLineNumber = SUBSTRING(RTRIM(@c_OtherParms),11,5)

      SELECT @c_Susr1 = STORER.Susr1
      FROM ORDERS (NOLOCK)
      JOIN STORER (NOLOCK) ON ORDERS.Consigneekey = STORER.Storerkey
      WHERE ORDERS.Orderkey = @c_Orderkey

      IF ISNULL(@c_Susr1,'') <> 'LOOSE' AND @c_UOM IN(6,7)
      BEGIN
          DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR
          SELECT TOP 0 NULL,NULL,0, NULL

          RETURN
      END
   END

   DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT LOTxLOCxID.LOC,LOTxLOCxID.ID,
             QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QTYREPLEN), '1'
      FROM LOTxLOCxID (NOLOCK)
      JOIN SKUXLOC (NOLOCK) ON LOTXLOCXID.Storerkey = SKUXLOC.Storerkey AND LOTXLOCXID.Sku = SKUXLOC.Sku AND LOTXLOCXID.Loc = SKUXLOC.Loc
      JOIN LOC (NOLOCK) ON (LOTxLOCxID.Loc = LOC.LOC)
      JOIN ID (NOLOCK) ON (LOTxLOCxID.Id = ID.ID)
      JOIN LOT (NOLOCK) ON (LOTXLOCXID.LOT = LOT.LOT)
      CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F   --WL01
      WHERE LOTxLOCxID.Lot = @c_lot
      AND LOC.Locationflag <> 'HOLD'
      AND LOC.Locationflag <> 'DAMAGE'
      AND LOC.Status <> 'HOLD'
      --AND LOC.Facility = @c_Facility   --WL01
      AND ID.STATUS <> 'HOLD'
      AND LOT.STATUS <> 'HOLD'
      AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QTYREPLEN) > 0
      ORDER BY F.FacSort, CASE WHEN SKUXLOC.LocationType IN('CASE','PICK') THEN 1 ELSE 2 END, LOC.LogicalLocation, LOC.LOC   --WL01
END
GO
GRANT EXECUTE ON  [dbo].[nspAL_SG01] TO [NSQL]
GO
