SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW   [BI].[V_StockTakeSheetParameters] AS
SELECT * FROM dbo.StockTakeSheetParameters WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_StockTakeSheetParameters] TO [JReportRole]
GO
