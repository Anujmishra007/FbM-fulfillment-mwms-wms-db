SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE VIEW [dbo].[V_StorerConfig] 
AS 
SELECT *
FROM dbo.[StorerConfig] (NOLOCK) 

GO
GRANT DELETE ON  [dbo].[V_StorerConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_StorerConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_StorerConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_StorerConfig] TO [NSQL]
GO
