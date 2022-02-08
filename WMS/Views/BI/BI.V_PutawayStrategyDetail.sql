SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW   [BI].[V_PutawayStrategyDetail] AS 
SELECT * FROM dbo.PutawayStrategyDetail WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_PutawayStrategyDetail] TO [JReportRole]
GO
