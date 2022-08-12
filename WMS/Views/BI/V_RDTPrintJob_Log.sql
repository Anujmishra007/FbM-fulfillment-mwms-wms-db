SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
--[CN] Create new BI view for Jreport https://jiralfl.atlassian.net/browse/WMS-20516
/* Date         Author      Ver.  Purposes                                 */
/* 12-Aug-2022  Gywong      1.0   Created                                  */
/***************************************************************************/

CREATE  OR ALTER VIEW [BI].[V_RDTPrintJob_Log]  AS  
SELECT *
FROM RDT.RDTPrintJob_Log WITH (NOLOCK)
GO

GRANT SELECT ON BI.V_RDTPrintJob_Log TO [JREPORTROLE]
GO


/*
exec as login ='JreportuserTH'

select suser_sname()

select * from [BI].[V_RDTPrintJob_Log]


revert;

*/