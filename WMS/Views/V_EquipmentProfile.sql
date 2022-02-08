SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE VIEW [dbo].[V_EquipmentProfile]  AS  SELECT [EquipmentProfileKey] , [Descr] , [MaximumWeight] , [WeightReductionPerLevel] , [AddDate] , [AddWho] , [EditDate] , [EditWho] , [TrafficCop] , [ArchiveCop] 
,MaximumLevel
,MaximumHeight
FROM [EquipmentProfile] (NOLOCK)  

GO
GRANT DELETE ON  [dbo].[V_EquipmentProfile] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_EquipmentProfile] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_EquipmentProfile] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_EquipmentProfile] TO [NSQL]
GO
