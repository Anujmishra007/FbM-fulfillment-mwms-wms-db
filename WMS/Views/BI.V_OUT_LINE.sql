SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* Purpose: [CN] WMS Add View To BI Schema For JReport-CNDTSITF          */
/* https://jiralfl.atlassian.net/browse/WMS-23303                        */
/* Creation Date: 15-AUG-2023                                              */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author		 Ver.  Purposes                                 */
/* 15-AUG-2023  JarekLim     1.0   Created                                  */
/***************************************************************************/
CREATE VIEW [BI].[V_OUT_LINE] 
AS
SELECT * FROM DBO.OUT_LINE WITH (NOLOCK)
GO
--GRANT SELECT ON  [BI].[V_OUT_LINE] TO [HyperionAdmin]
--GO
GRANT SELECT ON  [BI].[V_OUT_LINE] TO [JReportRole]
GO
/*
EXEC AS LOGIN = 'tabrpt'
EXEC AS LOGIN = 'JREPORTUSERCN'

SELECT SUSER_SNAME()

SELECT TOP 999 * FROM BI.V_OUT_LINE
revert;
*/