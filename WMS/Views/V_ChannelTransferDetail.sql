SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

--ChannelTransferDetail
CREATE OR ALTER VIEW [dbo].[V_ChannelTransferDetail] AS SELECT * FROM ChannelTransferDetail WITH (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_ChannelTransferDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ChannelTransferDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ChannelTransferDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ChannelTransferDetail] TO [NSQL]
GO
