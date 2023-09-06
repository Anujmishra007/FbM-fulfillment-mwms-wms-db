SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* Purpose: [PH] - LogiReport_Add_View to BI Schema_01Sep2023                       */
/* https://jiralfl.atlassian.net/browse/WMS-23570                          */
/* Creation Date: 19-May-2023                                              */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author		 Ver.  Purposes                                 */
/* 06-Sept-2023  ZiWei       1.0   Created                                  */
/***************************************************************************/
CREATE VIEW [BI].[V_WSDT_GENERIC_LBL_HDR_LOG]
AS
SELECT * FROM [dbo].[WSDT_GENERIC_LBL_HDR_LOG] WITH (NOLOCK)
GO

GRANT SELECT ON  [BI].[V_WSDT_GENERIC_LBL_HDR_LOG] TO [JReportRole]
GO

/*
EXEC AS LOGIN ='JReportUserTH'

SELECT SUSER_SNAME()

SELECT TOP 999 * FROM BI.V_WSDT_GENERIC_LBL_HDR_LOG
*/

