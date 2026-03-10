SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: nspALDAM02                                         */  
/* Creation Date:   19-Feb-2026                                         */  
/* Copyright: Maersk                                                    */  
/* Written by: JihHaur                                                  */  
/*                                                                      */  
/* Purpose: For FCR-11072 DAMIND XDOCK Allocation Strategy              */    
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
/* 19-Feb-2026  JH01    1.0   Created.                                  */     
/************************************************************************/  
  
CREATE  OR ALTER PROC  [dbo].[nspALDAM02]  
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
   FOR SELECT LOTxLOCxID.LOC, LOTxLOCxID.ID,  
   QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), '1' Type  
   FROM LOTxLOCxID (NOLOCK)  
   JOIN LOC (NOLOCK) ON LOTxLOCxID.LOC = LOC.LOC  
   WHERE LOTxLOCxID.Lot = @c_lot  
   AND LOC.Locationflag <>"HOLD"  
   AND LOC.Locationflag <> "DAMAGE"  
   AND LOC.Status <> "HOLD"  
   AND LOC.LocationType = "XDOCK"     
   AND LOC.Facility = @c_Facility  
   AND LOTxLOCxID.Qty - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyPicked > 0  
     
END  
GO
GRANT EXECUTE ON [dbo].[nspALDAM02] TO [NSQL]
GO