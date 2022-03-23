SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

--ChannelAttributeConfig
CREATE OR ALTER VIEW [dbo].[V_ChannelAttributeConfig] AS SELECT * FROM ChannelAttributeConfig WITH (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_ChannelAttributeConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ChannelAttributeConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ChannelAttributeConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ChannelAttributeConfig] TO [NSQL]
GO
