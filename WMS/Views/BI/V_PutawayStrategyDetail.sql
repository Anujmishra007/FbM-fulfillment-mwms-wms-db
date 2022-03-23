SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW   [BI].[V_PutawayStrategyDetail] AS
SELECT * FROM dbo.PutawayStrategyDetail WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_PutawayStrategyDetail] TO [JReportRole]
GO
