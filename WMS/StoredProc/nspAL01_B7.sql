if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nspAL01_B7]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nspAL01_B7]
GO
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
/* Date         Author        Purposes                                  */
/************************************************************************/

CREATE PROC  nspAL01_B7  -- rename from IDSSG:nspAL01_07
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
   FROM LOTxLOCxID (NOLOCK), LOC (NOLOCK), ID (NOLOCK)
   WHERE LOTxLOCxID.Lot = @c_lot
   AND LOTxLOCxID.Loc = LOC.LOC
   AND LOTxLOCxID.Id = ID.ID
   AND LOC.Facility = @c_Facility
   AND LOC.Locationflag <>"HOLD"
   AND LOC.Locationflag <> "DAMAGE"
   AND LOC.Status <> "HOLD"
   AND ID.STATUS <> "HOLD"
   AND LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED > 0
   ORDER BY LOC.LogicalLocation, LOC.LOC
END

GO

GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON nspAL01_B7 to nSQL
GO
