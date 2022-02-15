SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/****************************************************************************/
/* New View required for J report											*/
/* https://jiralfl.atlassian.net/browse/WMS-16190							*/
/* Date         Author      Ver.  Purposes									*/
/* 25-Jan-2021  BLLim       1.0   Created									*/
/****************************************************************************/

CREATE   VIEW [BI].[V_RDTPPA] AS 
SELECT *
FROM RDT.RDTPPA WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_RDTPPA] TO [JReportRole]
GO
