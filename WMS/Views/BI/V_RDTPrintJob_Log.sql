SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
--[CN] Create new BI view for Jreport https://jiralfl.atlassian.net/browse/WMS-20516
/* Date         Author      Ver.  Purposes                                 */
/* 12-Aug-2022  Gywong      1.0   Created IN TH                            */
/* 11-Nov-2022  JarekLIM    1.0   Created IN KR https://jiralfl.atlassian.net/browse/WMS-21163 */
/* 27-Dec-2022  JAREKLIM    1.1   Created IN JP https://jiralfl.atlassian.net/browse/WMS-21382 */
/***************************************************************************/

CREATE  OR ALTER VIEW [BI].[V_RDTPrintJob_Log]  AS  
SELECT *
FROM RDT.RDTPrintJob_Log WITH (NOLOCK)
GO

GRANT SELECT ON BI.V_RDTPrintJob_Log TO [JREPORTROLE]
GO


/*
exec as login ='JreportuserJP'

select suser_sname()

select TOP 9999 * from [BI].[V_RDTPrintJob_Log]

revert;

*/