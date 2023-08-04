SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
--https://jiralfl.atlassian.net/browse/WMS-23024
/* Date         Author      Ver.  Purposes                                 */
/* 06-JUL-2023  JAREKLIM    1.0   Created                                  */
/* 04-AUG-2023  JAREKLIM    1.0   Created https://jiralfl.atlassian.net/browse/WMS-23189  */
/***************************************************************************/
CREATE VIEW [BI].[V_WMSCustSOH]
AS
SELECT *
FROM dbo.WMSCustSOH (NOLOCK)
GO

GRANT SELECT ON BI.V_WMSCustSOH TO JREPORTROLE
GO

/*
EXEC AS LOGIN ='JReportUserAU'

SELECT SUSER_SNAME()

SELECT TOP 999 * FROM BI.V_WMSCustSOH
REVERT;
*/