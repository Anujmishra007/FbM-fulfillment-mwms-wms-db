/***************************************************************************/
/*[TW] LOR Create new BI view for Jreport										      */
/*https://jiralfl.atlassian.net/browse/WMS-16997               		      */				       
/*Date         Author      Ver.  Purposes								         	*/
/*12-May-2021  GuanYan     1.0   Created                                   */
/***************************************************************************/

CREATE OR ALTER VIEW [BI].[V_LOTXLOCXIDXSTATUS] AS

select inv.storerkey, inv.sku,inv.lot,inv.id,inv.loc,inv.qty,
inv.qtyallocated,inv.qtypicked,loc.locationflag as LOCHOLD, 
loc.status as HOLDLOC, lot.status as HOLDLOT,ID.status as HOLDID  
from 
dbo.LOTxLOCxID inv with (nolock)
left join loc (nolock) on  loc.loc=inv.loc
left join lot  (nolock) on lot.lot=inv.lot
left join id  (nolock) on  id.id=inv.id and id.id<>'' and inv.id<>''

GO

GRANT SELECT ON [BI].[V_LOTXLOCXIDXSTATUS] TO [JReportRole]
GO
/*  Test view, permission, performance, results

EXECUTE AS LOGIN = 'JReportUserTW';  -- Set the execution context to JReport User.

SELECT SUSER_NAME(), USER_NAME();    -- Verify the execution context is now JReport User.

SELECT *
FROM BI.V_LOTXLOCXIDXSTATUS

REVERT;                              -- The following REVERT statements will reset the execution context to the previous context.

*/