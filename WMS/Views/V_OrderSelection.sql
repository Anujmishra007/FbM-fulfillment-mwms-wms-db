SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_OrderSelection] AS SELECT * FROM OrderSelection WITH (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_OrderSelection] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_OrderSelection] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_OrderSelection] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_OrderSelection] TO [NSQL]
GO
