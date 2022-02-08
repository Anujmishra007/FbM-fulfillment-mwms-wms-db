SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create view [dbo].[V_rdsGrantedStorer]
as
SElect
UserId	,
StorerKey	,
AddDate	,
AddWho	
from rdsGrantedStorer with (NOLOCK)


GO
GRANT DELETE ON  [dbo].[V_rdsGrantedStorer] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_rdsGrantedStorer] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_rdsGrantedStorer] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_rdsGrantedStorer] TO [NSQL]
GO
