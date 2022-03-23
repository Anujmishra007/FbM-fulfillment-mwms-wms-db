SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/*[TW] LOR Create new BI view for Jreport										      */
/*https://jiralfl.atlassian.net/browse/WMS-16997               		      */
/*Date         Author      Ver.  Purposes								         	*/
/*24-Mar-2021  GuanYan       1.0   Created                                 */
/*11-May-2021  GuanYan       1.1   Modified                                */
/***************************************************************************/
CREATE OR ALTER VIEW [BI].[V_InventoryQCDetail] AS
SELECT *
FROM dbo.InventoryQCDetail WITH (NOLOCK)
GO

GRANT SELECT ON [BI].[V_InventoryQCDetail] TO [JReportRole]
GO
/*  Test view, permission, performance, results

EXECUTE AS LOGIN = 'JReportUserTW';  -- Set the execution context to JReport User.

SELECT SUSER_NAME(), USER_NAME();    -- Verify the execution context is now JReport User.

SELECT *
FROM BI.V_InventoryQCDetail

REVERT;                              -- The following REVERT statements will reset the execution context to the previous context.

*/
