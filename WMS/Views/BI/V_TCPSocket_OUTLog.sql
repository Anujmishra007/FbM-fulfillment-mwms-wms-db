SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

 /***************************************************************************************************************
Title: [JP] WMS_Add_View_To_BI_Schema_For_JReport - TCPSocket_OUTLog
Date		   Author			Ver		Purposes
23/11/2021  JarekLim       1.0      Create BI View https://jiralfl.atlassian.net/browse/WMS-18438
****************************************************************************************************************/
CREATE OR ALTER VIEW [BI].[V_TCPSocket_OUTLog]
AS
SELECT * FROM [dbo].[TCPSocket_OUTLog] WITH (NOLOCK)
GO

GRANT SELECT ON [BI].[V_TCPSocket_OUTLog] TO [JReportRole]
GO
/*  Test view, permission, performance, results
EXECUTE AS LOGIN = 'JReportUserJP';  -- Set the execution context to JReport User.

SELECT SUSER_SNAME()

SELECT top 999 *
FROM BI.V_TCPSocket_OUTLog

REVERT;

sp_refreshview 'BI.V_TCPSocket_OUTLog'
*/
