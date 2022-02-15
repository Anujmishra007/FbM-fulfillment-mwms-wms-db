SET ANSI_NULLS OFF;
GO
SET QUOTED_IDENTIFIER OFF;
GO
/***************************************************************************/
-- https://jiralfl.atlassian.net/browse/WMS-15782
/* Updates:                                                                */
/* Date         Author      Ver.  Purposes                                 */
/* 07-Dec-2020  KSheng      1.0   Created                                  */
/***************************************************************************/
CREATE OR ALTER VIEW [BI].[V_WMS_TPB_BASE]
AS
SELECT * FROM dbo.WMS_TPB_BASE WITH (NOLOCK)
GO

GRANT SELECT ON BI.V_WMS_TPB_BASE TO JReportRole
GO