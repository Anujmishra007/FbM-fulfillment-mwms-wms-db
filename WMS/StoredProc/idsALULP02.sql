if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[idsALULP02]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[idsALULP02]
GO

 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROC idsALULP02
       @c_lot NVARCHAR(10) ,
       @c_uom NVARCHAR(10) ,
       @c_HostWHCode NVARCHAR(10),
       @c_Facility NVARCHAR(5),
       @n_uombase int ,
       @n_qtylefttofulfill int
 AS
 BEGIN
    DECLARE  CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR 
       SELECT LOTxLOCxID.LOC, LOTxLOCxID.ID,
       QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), '1'
       FROM LOTxLOCxID (NOLOCK), LOC (NOLOCK), SKUxLOC (NOLOCK),LOT(NOLOCK), ID(NOLOCK)  
       WHERE LOTxLOCxID.Lot = @c_lot
       AND LOTxLOCxID.Loc = LOC.LOC
       AND LOTxLOCxID.Storerkey = SKUxLOC.Storerkey
       AND LOTxLOCxID.Sku = SKUxLOC.Sku
       AND LOTxLOCxID.Loc = SKUxLOC.Loc
       AND LOTXLOCXID.LOT = LOT.LOT --SOS131215 START ang01   
       AND LOTXLOCXID.ID  = ID.ID  ---SOS131215 END ang01    
       and (loc.locationtype = 'CASE' or loc.locationtype = 'PICK')
       AND LOT.STATUS = 'OK' --SOS131215 START ang01 
       AND LOC.STATUS = 'OK'
       AND ID.STATUS = 'OK' ---SOS131215 END ang01   
       AND LOC.Locationflag = 'NONE' 
       AND LOC.Facility = @c_Facility
       ORDER BY loc.hostwhcode, LOC.LOC
 END
GO
 
GO
SET ANSI_NULLS OFF 
GO

GRANT EXECUTE ON idsALULP02 to nSQL
GO
