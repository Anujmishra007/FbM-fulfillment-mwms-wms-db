SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_LoadPlanLaneDetail]
AS
SELECT     LoadKey, ExternOrderKey, ConsigneeKey, LP_LaneNumber, LocationCategory, LOC, Status, Notes, AddWho, AddDate, EditWho, EditDate, TrafficCop,
                      ArchiveCop, MBOLKey
FROM         dbo.LoadPlanLaneDetail WITH (nolock)

GO
GRANT DELETE ON  [dbo].[V_LoadPlanLaneDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_LoadPlanLaneDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_LoadPlanLaneDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_LoadPlanLaneDetail] TO [NSQL]
GO
