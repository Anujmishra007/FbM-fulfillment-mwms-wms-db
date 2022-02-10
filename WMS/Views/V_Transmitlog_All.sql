SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE VIEW [dbo].[V_Transmitlog_All]
AS
SELECT     dbo.Transmitlog.*
FROM       dbo.Transmitlog (nolock)




GO
GRANT DELETE ON  [dbo].[V_Transmitlog_All] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_Transmitlog_All] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_Transmitlog_All] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_Transmitlog_All] TO [NSQL]
GO
