SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create View [dbo].[V_TraceTM] as
Select Seqno,
SP,
TaskDetailKey,
UserKey,
AddDate
FROM TraceTM With (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_TraceTM] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TraceTM] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TraceTM] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TraceTM] TO [NSQL]
GO
