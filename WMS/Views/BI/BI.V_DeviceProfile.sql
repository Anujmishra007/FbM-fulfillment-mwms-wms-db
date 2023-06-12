SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* [CN] Logi Report Add View to BI Schema							       */
/* https://jiralfl.atlassian.net/browse/WMS-22777                          */
/* Creation Date: 12-JUNE-2023                                             */
/*                                                                         */
/* Updates:                                                                */
/* Date          Author		 Ver.  Purposes                                 */
/* 12-JUNE-2023  JarekLim     1.0   Created                                 */
/***************************************************************************/
CREATE VIEW [BI].[V_DeviceProfile] 
AS
SELECT * FROM dbo.DeviceProfile WITH (NOLOCK)
GO
--GRANT SELECT ON  [BI].[V_DeviceProfile] TO [HyperionAdmin]
--GO
GRANT SELECT ON  [BI].[V_DeviceProfile] TO [JReportRole]
GO
/*
EXEC AS LOGIN = 'tabrpt'
EXEC AS LOGIN = 'JREPORTUSERCN'

SELECT SUSER_SNAME()

SELECT TOP 999 * FROM BI.V_DeviceProfile
revert;
*/