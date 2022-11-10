SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
--KR - Add view to BI schema for LogiReport https://jiralfl.atlassian.net/browse/WMS-21163
/* Date         Author      Ver.  Purposes                                 */
/* 11-Nov-2022  JarekLIM    1.0   Created                                  */
/***************************************************************************/

CREATE  OR ALTER VIEW [BI].[V_PackDetail_DELLOG]  AS  
SELECT *
FROM dbo.PackDetail_DELLOG WITH (NOLOCK)
GO

GRANT SELECT ON BI.V_PackDetail_DELLOG TO [JREPORTROLE]
GO


/*
exec as login ='JreportuserKR'

select suser_sname()

select TOP 99999 * from [BI].[V_PackDetail_DELLOG]


revert;

*/