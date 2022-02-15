/***************************************************************************/
/*[TW] LOR Create new BI view for Jreport										      */
/*https://jiralfl.atlassian.net/browse/WMS-16997               		      */				       
/*Date         Author      Ver.  Purposes								         	*/
/*11-May-2021  GuanYan     1.0   Created                                   */
/***************************************************************************/

CREATE OR ALTER VIEW [BI].[V_WorkOrderRouting] AS
SELECT *
FROM dbo.WorkOrderRouting WITH (NOLOCK)
GO

GRANT SELECT ON [BI].[V_WorkOrderRouting] TO [JReportRole]
GO
/*  Test view, permission, performance, results

EXECUTE AS LOGIN = 'JReportUserTW';  -- Set the execution context to JReport User.

SELECT SUSER_NAME(), USER_NAME();    -- Verify the execution context is now JReport User.

SELECT *
FROM BI.V_WorkOrderRouting

REVERT;                              -- The following REVERT statements will reset the execution context to the previous context.

*/