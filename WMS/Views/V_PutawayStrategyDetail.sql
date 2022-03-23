SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_PutawayStrategyDetail] AS SELECT * FROM PutawayStrategyDetail WITH (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_PutawayStrategyDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_PutawayStrategyDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_PutawayStrategyDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_PutawayStrategyDetail] TO [NSQL]
GO
