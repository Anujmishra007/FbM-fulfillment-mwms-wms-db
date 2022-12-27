SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
--[CN] WMS Add View To BI Schema For JReport - RDT  https://jiralfl.atlassian.net/browse/WMS-21347
/* Date         Author      Ver.  Purposes                                 */
/* 15-Dec-2022  ziwei       1.1   Created                                  */
/* 27-Dec-2022  JAREKLIM    1.1   Created https://jiralfl.atlassian.net/browse/WMS-21382 */
/***************************************************************************/
--
CREATE OR ALTER   VIEW [BI].[V_RDTPrintJob]
AS
SELECT *
FROM [RDT].[RDTPrintJob] WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_RDTPrintJob] TO [JReportRole]
GO

/*
exec as login ='JreportuserJP'

select suser_sname()

select TOP 9999 * from [BI].[V_RDTPrintJob]


revert;

*/




