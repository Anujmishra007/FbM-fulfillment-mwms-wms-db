if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nspAL_FAST]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nspAL_FAST]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
CREATE  PROC    nspAL_FAST
   @c_lot NVARCHAR(10) ,
   @c_uom NVARCHAR(10) ,
   @c_HostWHCode NVARCHAR(10),
   @c_Facility NVARCHAR(5),
   @n_uombase int ,
   @n_qtylefttofulfill INT,
   @c_OtherParms NVARCHAR(200) = ''
AS
BEGIN
   SET NOCOUNT ON 
    
   
   DECLARE  CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY 
   FOR SELECT LOTxLOCxID.LOC,LOTxLOCxID.ID,
   QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), '1'
   FROM LOTxLOCxID (NOLOCK) 
   JOIN LOC (NOLOCK) ON (LOTxLOCxID.Loc = LOC.LOC)
   JOIN ID (NOLOCK) ON (LOTxLOCxID.Id = ID.ID) 
   WHERE LOTxLOCxID.Lot = @c_lot
   AND LOC.Locationflag <> 'HOLD'
   AND LOC.Locationflag <> 'DAMAGE'
   AND LOC.Status <> 'HOLD'
   AND LOC.Facility = @c_Facility
   AND ID.STATUS <> 'HOLD'
   AND LOC.LocationType = 'FAST' 
   ORDER BY LOC.LOC
END

GO
 
GO
SET ANSI_NULLS OFF 
GO

GRANT EXECUTE on nspAL_FAST to nSQL
GO

