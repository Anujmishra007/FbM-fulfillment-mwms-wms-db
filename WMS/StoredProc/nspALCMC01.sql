if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nspALCMC01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nspALCMC01]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROC nspALCMC01
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
 QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), '1'      
 FROM LOTxLOCxID (NOLOCK), LOC (NOLOCK), SKUxLOC (NOLOCK), LOT(NOLOCK), ID(NOLOCK)      
 WHERE LOTxLOCxID.Lot = @c_lot      
 AND LOTxLOCxID.Loc = LOC.LOC      
 AND LOTxLOCxID.Storerkey = SKUxLOC.Storerkey      
 AND LOTxLOCxID.Sku = SKUxLOC.Sku      
 AND LOTxLOCxID.Loc = SKUxLOC.Loc      
 AND LOTXLOCXID.LOT = LOT.LOT --SOS131215 START    
 AND LOTXLOCXID.ID  = ID.ID  ---SOS131215 END    
 AND (loc.locationtype = 'SELECTIVE' or loc.locationtype = 'DOUBLEDEEP')      
 AND  LOT.STATUS = 'OK' AND LOC.STATUS = 'OK' AND ID.STATUS = 'OK' And LOC.LocationFlag <> 'HOLD' --SOS131215 START    
 AND LOC.LocationFlag <> 'DAMAGE'    
 --AND LOC.Locationflag = 'NONE'   SOS131215 END    
 AND LOC.Facility = @c_Facility      
 ORDER BY loc.hostwhcode, LOC.LOC      
 END 
GO
 
GO
SET ANSI_NULLS OFF 
GO

GRANT EXECUTE ON nspALCMC01 to nSQL
GO

