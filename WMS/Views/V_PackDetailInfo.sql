SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


Create VIEW [dbo].[V_PackDetailInfo] 
AS 
SELECT * FROM PackDetailInfo (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_PackDetailInfo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_PackDetailInfo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_PackDetailInfo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_PackDetailInfo] TO [NSQL]
GO
