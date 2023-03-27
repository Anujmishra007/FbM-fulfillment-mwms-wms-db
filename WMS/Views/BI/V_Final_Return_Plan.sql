SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/*[TW] LogiReport Create New View 										            */
/*https://jiralfl.atlassian.net/browse/WMS-22065           		            */
/*Date         Author      Ver.  Purposes								         	*/
/*27-Mar-2021  ZiWei       1.0   Created                                   */
/***************************************************************************/
CREATE OR ALTER VIEW [BI].[V_Final_Return_Plan] AS
SELECT *
FROM dbo.Final_Return_Plan WITH (NOLOCK)
GO
GRANT SELECT ON [BI].[V_Final_Return_Plan] TO [JReportRole]
GO
/*  Test view, permission, performance, results

EXECUTE AS LOGIN = 'JReportUserTW';  -- Set the execution context to JReport User.

SELECT SUSER_NAME(), USER_NAME();    -- Verify the execution context is now JReport User.

SELECT *
FROM BI.V_Final_Return_Plan

REVERT;                              -- The following REVERT statements will reset the execution context to the previous context.

*/
