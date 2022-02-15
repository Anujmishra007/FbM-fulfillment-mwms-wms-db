/***************************************************************************/
/*CN] PVH- Add Views into JREPORT UAT/PROD Catalogs for CNWMS	            */
/*https://jiralfl.atlassian.net/browse/WMS-17423               		      */				       
/*Date         Author      Ver.  Purposes								         	*/
/*02-Jul-2021  GuanYan       1.0   Created                                 */
/***************************************************************************/

CREATE OR ALTER VIEW [BI].[V_PackTaskDetail] AS
SELECT *
FROM dbo.PackTaskDetail WITH (NOLOCK)
GO

GRANT SELECT ON [BI].[V_PackTaskDetail] TO [JReportRole]
GO
/*  Test view, permission, performance, results

EXECUTE AS LOGIN = 'JReportUserCN';  -- Set the execution context to JReport User.

SELECT SUSER_NAME(), USER_NAME();    -- Verify the execution context is now JReport User.

SELECT *
FROM BI.V_PackTaskDetail

REVERT;                              -- The following REVERT statements will reset the execution context to the previous context.

*/