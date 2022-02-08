SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--ChannelTransferDetail
CREATE VIEW [dbo].[V_ChannelTransferDetail] AS SELECT * FROM ChannelTransferDetail WITH (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_ChannelTransferDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ChannelTransferDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ChannelTransferDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ChannelTransferDetail] TO [NSQL]
GO
