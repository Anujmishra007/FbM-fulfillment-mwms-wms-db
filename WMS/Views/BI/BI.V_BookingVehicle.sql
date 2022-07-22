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
CREATE VIEW [BI].[V_BookingVehicle] 
AS
SELECT * FROM DBO.BookingVehicle WITH (NOLOCK)
GO
--GRANT SELECT ON  [BI].[V_BookingVehicle] TO [HyperionAdmin]
--GO
GRANT SELECT ON  [BI].[V_BookingVehicle] TO [JReportRole]
GO
/*
EXEC AS LOGIN = 'tabrpt'
EXEC AS LOGIN = 'JREPORTUSERPH'

SELECT SUSER_SNAME()

SELECT * FROM BI.V_BookingVehicle
revert;
*/

