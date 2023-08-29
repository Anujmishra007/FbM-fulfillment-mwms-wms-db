SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* Purpose: [ID] WMS Add View to BI Schema for Jreport                     */
/* https://jiralfl.atlassian.net/browse/WMS-23513                          */
/* Creation Date: 28-AUG-2023                                              */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author		 Ver.  Purposes                                 */
/* 28-AUG-2023  ZiWei       1.0   Created                                  */
/***************************************************************************/
CREATE OR ALTER VIEW [BI].[V_WOLInbound_Log] 
AS
SELECT * FROM DBO.WOLInbound_Log WITH (NOLOCK)
GO

--GRANT SELECT ON  [BI].[V_WOLInbound_Log] TO [HyperionAdmin]
--GO
GRANT SELECT ON  [BI].[V_WOLInbound_Log] TO [JReportRole]
GO
/*
EXEC AS LOGIN = 'tabrpt'
EXEC AS LOGIN = 'JREPORTUSERID'

SELECT SUSER_SNAME()

SELECT TOP 999 * FROM BI.V_WOLInbound_Log
revert;
*/