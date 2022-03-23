SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/*[TW] SPZ Create new BI view for Jreport	                                 */
/*https://jiralfl.atlassian.net/browse/WMS-17442               		      */
/*Date         Author      Ver.  Purposes								         	*/
/*07-Jul-2021  GuanYan       1.0   Created                                 */
/***************************************************************************/
CREATE OR ALTER VIEW [BI].[V_DocStatusTrack] AS
SELECT *
FROM dbo.DocStatusTrack WITH (NOLOCK)
GO

GRANT SELECT ON [BI].[V_DocStatusTrack] TO [JReportRole]
GO
/*  Test view, permission, performance, results

EXECUTE AS LOGIN = 'JReportUserTW';  -- Set the execution context to JReport User.

SELECT SUSER_NAME(), USER_NAME();    -- Verify the execution context is now JReport User.

SELECT *
FROM BI.V_DocStatusTrack

REVERT;                              -- The following REVERT statements will reset the execution context to the previous context.

*/
