if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nspALSTDE1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nspALSTDE1]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO  
/************************************************************************/  
/* Stored Procedure: nspALstdE1                                         */  
/* Copyright: IDS                                                       */  
/* PVCS Version: 1.1                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author        Purposes                                  */  
/* Aug 11 2006  Shong         If HostWHCode BLANK, do not filter        */  
/* Oct 11 2004  Admin         Changed by SHONG                          */  
/* Aug 05 2002  Admin         Initial revision.                         */  
/* Jan 12 2011  Shong         Add Other Parms                           */  
/************************************************************************/  
CREATE PROC  nspALSTDE1     
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
      
     
  
IF dbo.fnc_RTrim(@c_HostWHCode) IS NOT NULL AND dbo.fnc_RTrim(@c_HostWHCode) <> ''  
BEGIN  
   DECLARE  CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR    
   SELECT LOTxLOCxID.LOC, LOTxLOCxID.ID,  
   QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), '1'  
   FROM LOTxLOCxID (NOLOCK), LOC (NOLOCK), ID (NOLOCK), SKUxLOC (NOLOCK)  
   WHERE LOTxLOCxID.Lot = @c_lot  
   AND LOTxLOCxID.Loc = LOC.LOC  
   AND LOTxLOCxID.Loc = SKUxLOC.Loc  
   AND LOTxLOCxID.Sku = SKUxLOC.Sku  
   AND LOTxLOCxID.ID = ID.ID  
   AND ID.Status <> 'HOLD'  
   AND LOC.Facility = @c_Facility   
   AND LOC.Locationflag <> 'HOLD'  
   AND LOC.Locationflag <> 'DAMAGE'  
   AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) >= @n_uombase  
   AND LOC.Status <> 'HOLD'  
   AND SKUxLOC.LocationType NOT IN ('PICK', 'CASE')  
   AND LOC.HostWhCode = @c_HostWHCode  
   ORDER BY LOTxLOCxID.LOC  
END  
ELSE  
BEGIN  
   DECLARE  CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR    
   SELECT LOTxLOCxID.LOC, LOTxLOCxID.ID,  
   QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), '1'  
   FROM LOTxLOCxID (NOLOCK), LOC (NOLOCK), ID (NOLOCK), SKUxLOC (NOLOCK)  
   WHERE LOTxLOCxID.Lot = @c_lot  
   AND LOTxLOCxID.Loc = LOC.LOC  
   AND LOTxLOCxID.Loc = SKUxLOC.Loc  
   AND LOTxLOCxID.Sku = SKUxLOC.Sku  
   AND LOTxLOCxID.ID = ID.ID  
   AND ID.Status <> 'HOLD'  
   AND LOC.Facility = @c_Facility   
   AND LOC.Locationflag <> 'HOLD'  
   AND LOC.Locationflag <> 'DAMAGE'  
   AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) >= @n_uombase  
   AND LOC.Status <> 'HOLD'  
   AND SKUxLOC.LocationType NOT IN ('PICK', 'CASE')  
   ORDER BY LOTxLOCxID.LOC  
END  
  
END  
GO

SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON nspALSTDE1 TO nSQL
GO

