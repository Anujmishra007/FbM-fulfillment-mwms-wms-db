SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/*[PH] - JReport_Add_View in UAT Catalog                    	            */
/*https://jiralfl.atlassian.net/browse/WMS-14420               		      */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author    Ver.  Purposes                                   */
/* 24-Jun-2020  Billy    1.0   Created                                     */
/* 28-Sep-2021  KHLim    1.1   WMS-18038 CN Jreport Add View to BI Schema  */
/***************************************************************************/
CREATE OR ALTER VIEW [BI].[V_ConsigneeSKU]
AS
SELECT *
FROM dbo.ConsigneeSKU WITH (NOLOCK)
GO

GRANT SELECT ON BI.V_ConsigneeSKU TO JReportRole
GO

/*  Test view, permission, performance, results
EXECUTE AS LOGIN = 'JReportUserCN';  -- Set the execution context to JReport User.

SELECT SUSER_NAME(), USER_NAME();    -- Verify the execution context is now JReport User.

SELECT *  FROM  BI.V_ConsigneeSKU

REVERT;                              -- The following REVERT statements will reset the execution context to the previous context.

*/
