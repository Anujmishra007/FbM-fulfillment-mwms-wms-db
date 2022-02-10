SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_rdsOrderDetail] AS SELECT * FROM rdsOrderDetail WITH (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_rdsOrderDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_rdsOrderDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_rdsOrderDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_rdsOrderDetail] TO [NSQL]
GO
