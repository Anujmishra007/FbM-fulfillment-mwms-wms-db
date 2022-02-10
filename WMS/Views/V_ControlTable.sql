SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_ControlTable] 
AS 
SELECT [type]
, [filename]
, [trandate]
, [rec_upload]
, [rec_posted]
, [totalqty]
, [addwho]
FROM [ControlTable] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_ControlTable] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ControlTable] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ControlTable] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ControlTable] TO [NSQL]
GO
