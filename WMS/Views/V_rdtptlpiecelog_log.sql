SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Purpose: [CN] WMS Add View To BI Schema For JReport - rdt.rdtptlpiecelog_log	 */
/* https://jiralfl.atlassian.net/browse/WMS-23246                         */
/* Creation Date: 02-AUG-2022                                              */
/*                                                                         */
/* Updates:                                                                */
/* Date          Author		  Ver.  Purposes                               */
/* 02-AUG-2022   JarekLim     1.0   Created                                */
/***************************************************************************/

CREATE  VIEW [BI].[V_rdtptlpiecelog_log]
AS
SELECT *
FROM RDT.rdtPTLPieceLog_Log WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_rdtptlpiecelog_log] TO [JReportRole] AS [dbo]
GO
/*
EXEC AS LOGIN = 'tabrpt'
EXEC AS LOGIN = 'JREPORTUSERCN'

SELECT SUSER_SNAME()

SELECT TOP 999 * FROM BI.V_rdtptlpiecelog_log
revert;
*/
