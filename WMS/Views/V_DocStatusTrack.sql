SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE VIEW [dbo].[V_DocStatusTrack]
AS SELECT * FROM dbo.DocStatusTrack (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_DocStatusTrack] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_DocStatusTrack] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_DocStatusTrack] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_DocStatusTrack] TO [NSQL]
GO
