SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* Purpose: [PH] - LogiReport_Add_View in PRD Catalog_18July2022          */
/* https://jiralfl.atlassian.net/browse/WMS-20268                          */
/* Creation Date: 21-JUL-2021                                              */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author		 Ver.  Purposes                                 */
/* 21-JUL-2022  JarekLim     1.0   Created                                  */
/***************************************************************************/
CREATE VIEW [BI].[V_Booking_Event] 
AS
SELECT * FROM dbo.Booking_Event WITH (NOLOCK)
GO
--GRANT SELECT ON  [BI].[V_Booking_Event] TO [HyperionAdmin]
--GO
GRANT SELECT ON  [BI].[V_Booking_Event] TO [JReportRole]
GO
/*
EXEC AS LOGIN = 'tabrpt'
EXEC AS LOGIN = 'JREPORTUSERPH'

SELECT SUSER_SNAME()

SELECT * FROM BI.V_Booking_Event
revert;
*/
