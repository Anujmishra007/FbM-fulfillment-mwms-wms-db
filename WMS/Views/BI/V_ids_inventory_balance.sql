SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Purpose: TH - LogiReport(JReport) - Publish Query- TH_WMS.cat				   */
/* https://jiralfl.atlassian.net/browse/WMS-22922                          */
/* Creation Date: 3-JUL-2023                                              */
/*                                                                         */
/* Updates:                                                                */
/* Date          Author		  Ver.  Purposes                               */
/* 3-JUL-2023      ZiWei     1.0   Created                                */
/***************************************************************************/

CREATE OR ALTER VIEW [BI].[V_ids_inventory_balance]
AS
SELECT *
FROM dbo.V_ids_inventory_balance WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_ids_inventory_balance] TO [JReportRole] AS [dbo]
GO
/*
EXEC AS LOGIN = 'tabrpt'
EXEC AS LOGIN = 'JREPORTUSERTH'

SELECT SUSER_SNAME()

SELECT * FROM BI.V_ids_inventory_balance
revert;
*/

