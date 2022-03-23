SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

--ChannelTransfer
CREATE OR ALTER VIEW [dbo].[V_ChannelTransfer] AS SELECT * FROM ChannelTransfer WITH (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_ChannelTransfer] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ChannelTransfer] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ChannelTransfer] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ChannelTransfer] TO [NSQL]
GO
