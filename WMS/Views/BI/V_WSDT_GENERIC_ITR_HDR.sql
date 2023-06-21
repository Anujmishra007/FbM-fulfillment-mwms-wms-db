SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* Purpose: CN logireport Add View to BI Schema -HM&NEW BRANDS             */
/* https://jiralfl.atlassian.net/browse/WMS-22902                         */
/* Creation Date: 20-JUNE-2023                                              */
/*                                                                         */
/* Updates:                                                                */
/* Date          Author		  Ver.  Purposes                               */
/* 20-JUNE-2023  JarekLim     1.0   Created                                */
/***************************************************************************/
CREATE VIEW [BI].[V_WSDT_GENERIC_ITR_HDR]
AS
SELECT * FROM [dbo].[WSDT_GENERIC_ITR_HDR] WITH (NOLOCK)
GO

GRANT SELECT ON  [BI].[V_WSDT_GENERIC_ITR_HDR] TO [JReportRole]
GO

/*
EXEC AS LOGIN ='JReportUserCN'

SELECT SUSER_SNAME()

SELECT TOP 999 * FROM BI.V_WSDT_GENERIC_ITR_HDR
REVERT;
*/