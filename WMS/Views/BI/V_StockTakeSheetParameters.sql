SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW   [BI].[V_StockTakeSheetParameters] AS 
SELECT * FROM dbo.StockTakeSheetParameters WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_StockTakeSheetParameters] TO [JReportRole]
GO
