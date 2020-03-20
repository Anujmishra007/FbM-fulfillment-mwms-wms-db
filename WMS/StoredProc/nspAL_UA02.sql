if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nspAL_UA02]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nspAL_UA02]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: nspAL_UA02                                         */
/* Creation Date: 12-Jun-2015                                           */
/* Copyright: LF                                                        */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: 342109-CN Under Armour (UA) Allocation Strategy             */
/*          Allocate loose from DPP                                     */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.4                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver. Purposes                                   */
/* 27-Feb-2017  TLTING  1.1  Variable Nvarchar                          */
/************************************************************************/

CREATE PROC nspAL_UA02 
@c_lot Nvarchar(10) ,
@c_uom Nvarchar(10) ,
@c_HostWHCode Nvarchar(10),
@c_Facility Nvarchar(5),
@n_uombase int ,
@n_qtylefttofulfill int,
@c_OtherParms NVARCHAR(200) = ''         
AS
BEGIN
   SET NOCOUNT ON 
   
	 DECLARE @c_OrderKey     NVARCHAR(10),
	         @c_OrderLineNumber NVARCHAR(5)
	                     
   IF LEN(@c_OtherParms) > 0  -- when storerconfig 'Orderinfo4Allocation' is turned on
   BEGIN        
      SET @c_OrderKey = LEFT(@c_OtherParms,10)         
      SET @c_OrderLineNumber = SUBSTRING(@c_OtherParms,11,5)
   END   
   
   DECLARE  CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY
   FOR SELECT LOTxLOCxID.LOC, LOTxLOCxID.ID,
   QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QtyReplen), '1'
   FROM LOTxLOCxID (NOLOCK)
   JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC
   JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey AND LOTxLOCxID.Sku = SKUxLOC.Sku
                            AND LOTxLOCxID.Loc = SKUxLOC.Loc
   JOIN ID (NOLOCK) ON LOTxLOCxID.ID = ID.ID 
   WHERE LOTxLOCxID.Lot = @c_lot
   AND LOC.Facility = @c_Facility
   AND LOC.Locationflag <>'HOLD'
   AND LOC.Locationflag <> 'DAMAGE'
   AND LOC.Status <> 'HOLD'
   AND ID.Status = 'OK'
   AND LOC.Locationtype IN ('DYNPPICK')       
   AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QtyReplen) > 0 
   ORDER BY 3, LOC.LogicalLocation, LOC.LOC   	
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON nspAL_UA02 TO nSQL
GO
