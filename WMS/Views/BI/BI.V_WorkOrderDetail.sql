SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* Purpose: CN logireport Add View to BI Schema -lululemon          */
/* https://jiralfl.atlassian.net/browse/WMS-22713                         */
/* Creation Date: 30-May-2023                                              */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author		 Ver.  Purposes                                 */
/* 30-May-2023  JarekLim     1.0   Created                                  */
/***************************************************************************/
CREATE OR ALTER VIEW [BI].[V_WorkOrderDetail] 
AS
SELECT * FROM DBO.WorkOrderDetail WITH (NOLOCK)
GO
--GRANT SELECT ON  [BI].[V_WorkOrderDetail] TO [HyperionAdmin]
--GO
GRANT SELECT ON  [BI].[V_WorkOrderDetail] TO [JReportRole]
GO
/*
EXEC AS LOGIN = 'tabrpt'
EXEC AS LOGIN = 'JREPORTUSERCN'

SELECT SUSER_SNAME()

SELECT top 999 * FROM BI.V_WorkOrderDetail
revert;
*/