SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* Purpose: TH- LogiReport - Create SPs in BI Schema                       */
/* https://jiralfl.atlassian.net/browse/WMS-22573                          */
/* Creation Date: 19-May-2023                                              */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author		 Ver.  Purposes                                 */
/* 19-May-2023  ZiWei       1.0   Created                                  */
/***************************************************************************/
CREATE VIEW [BI].[V_WSDT_GENERIC_LBL_HDR]
AS
SELECT * FROM [DTS].[WSDT_GENERIC_LBL_HDR] WITH (NOLOCK)
GO

GRANT SELECT ON  [BI].[V_WSDT_GENERIC_LBL_HDR] TO [JReportRole]
GO

/*
EXEC AS LOGIN ='JReportUserTH'

SELECT SUSER_SNAME()

SELECT TOP 999 * FROM BI.V_WSDT_GENERIC_LBL_HDR
*/

