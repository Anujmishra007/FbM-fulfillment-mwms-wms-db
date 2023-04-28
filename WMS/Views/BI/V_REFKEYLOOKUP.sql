SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
--[[KR] Create SP in BI schema for LogiReport  https://jiralfl.atlassian.net/browse/WMS-22303
/* Date           Author      Ver.  Purposes                                 */
/* 28-April-2023  JAREKLIM    1.1   Created                                 */
/***************************************************************************/
--
CREATE OR ALTER   VIEW [BI].[V_REFKEYLOOKUP]
AS
SELECT *
FROM [DBO].[REFKEYLOOKUP] WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_REFKEYLOOKUP] TO [JReportRole]
GO

/*
exec as login ='JreportuserKR'

select suser_sname()

select TOP 9999 * from [BI].[V_REFKEYLOOKUP]


revert;

*/

