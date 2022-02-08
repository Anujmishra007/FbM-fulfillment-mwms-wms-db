SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create view [dbo].[V_rdsMenu]
as
SElect
MenuID	,
SeqNo	,
Type	,
Descr	,
ObjectName	,
BitMap	,
PrevMenuID	,
NextMenuID	,
Visible	,
Enable	
FROM rdsMenu with (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_rdsMenu] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_rdsMenu] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_rdsMenu] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_rdsMenu] TO [NSQL]
GO
