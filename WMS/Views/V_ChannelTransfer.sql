SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--ChannelTransfer
CREATE VIEW [dbo].[V_ChannelTransfer] AS SELECT * FROM ChannelTransfer WITH (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_ChannelTransfer] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ChannelTransfer] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ChannelTransfer] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ChannelTransfer] TO [NSQL]
GO
