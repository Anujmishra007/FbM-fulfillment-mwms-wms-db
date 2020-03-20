IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[nspAL01_BK]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[nspAL01_BK]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
--
-- Definition for stored procedure nspAL01_BK : 
--

/************************************************************************/
/* Trigger: nspAL01_BK                             	                  */
/* Creation Date: 13-Jul-2005                                           */
/* Copyright: IDS                                                       */
/* Written by: MaryVong                                                 */
/*                                                                      */
/* Purpose: Allocate from only BULK location	(request by KCPI)		      */
/*                                                                      */
/* Input Parameters: @c_lot,        -  Lot                              */
/*                   @c_uom,        -  UOM                              */
/*                   @c_HostWHCode, - Hose Warehouse Code               */ 
/*                   @c_Facility,   - Facility                          */
/*                   @n_uombase,    - UOM Based                         */
/*                   @n_qtylefttofulfill  -  Qty to fulfill             */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: 		                                                      */
/*                                                                      */
/* PVCS Version: 1.0		                                                */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/*                                                                      */
/************************************************************************/

CREATE PROCEDURE [nspAL01_BK]
@c_lot NVARCHAR(10) ,
@c_uom NVARCHAR(10) ,
@c_HostWHCode NVARCHAR(10),
@c_Facility NVARCHAR(5),
@n_uombase int ,
@n_qtylefttofulfill int
AS
BEGIN
DECLARE  CURSOR_CANDIDATES  CURSOR FAST_FORWARD READ_ONLY
FOR SELECT LOTxLOCxID.LOC,LOTxLOCxID.ID,
QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), '1'
FROM LOTxLOCxID (NOLOCK),LOC (NOLOCK),ID (NOLOCK), SKUxLOC (NOLOCK)
WHERE LOTxLOCxID.Lot = @c_lot
AND LOTxLOCxID.Loc = LOC.LOC
AND LOTxLOCxID.Id = ID.ID
AND LOTxLOCxID.Storerkey = SKUxLOC.Storerkey
AND LOTxLOCxID.Sku = SKUxLOC.Sku
AND LOTxLOCxID.Loc = SKUxLOC.Loc
AND SKUxLOC.Locationtype <> "PICK"
AND SKUxLOC.Locationtype <> "CASE" 
AND LOC.Locationflag <>"HOLD"
AND LOC.Locationflag <> "DAMAGE"
AND LOC.Status <> "HOLD"
AND LOC.Facility = @c_Facility
AND ID.STATUS <> "HOLD"
ORDER BY loc.locationtype desc, LOC.LOC 
END
GO
GRANT EXECUTE ON [dbo].[nspAL01_BK] TO nSQL 
GO
