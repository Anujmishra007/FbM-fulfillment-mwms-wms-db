SET ANSI_NULLS OFF;  SET QUOTED_IDENTIFIER OFF;
GO
/***************************************************************************/
--https://jiralfl.atlassian.net/browse/WMS-15595
/* Date         Author      Ver.  Purposes                                 */
/* 28-Sep-2020  KSheng      1.0   Created                                  */
/***************************************************************************/
CREATE OR ALTER VIEW [BI].[V_ReceiptSerialno]
AS
SELECT * 
FROM dbo.ReceiptSerialno (NOLOCK)
GO

GRANT SELECT ON BI.V_ReceiptSerialno TO JREPORTROLE
GO