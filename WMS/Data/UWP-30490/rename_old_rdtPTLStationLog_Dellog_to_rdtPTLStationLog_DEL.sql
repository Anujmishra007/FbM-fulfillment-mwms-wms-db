IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.tables where table_schema = 'rdt' AND table_name = 'rdtPTLStationLog_DELLOG' )
BEGIN
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_AddDate' , 'DF_rdtPTLStationLog_DEL_AddDate'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_AddWho' , 'DF_rdtPTLStationLog_DEL_AddWho'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_BatchKey' , 'DF_rdtPTLStationLog_DEL_BatchKey'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_CartonID' , 'DF_rdtPTLStationLog_DEL_CartonID'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_ConsigneeKey' , 'DF_rdtPTLStationLog_DEL_ConsigneeKey'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_CreatedPTLTran' , 'DF_rdtPTLStationLog_DEL_CreatedPTLTran'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_EditDate' , 'DF_rdtPTLStationLog_DEL_EditDate'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_EditWho' , 'DF_rdtPTLStationLog_DEL_EditWho'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_LoadKey' , 'DF_rdtPTLStationLog_DEL_LoadKey'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_LOC' , 'DF_rdtPTLStationLog_DEL_LOC'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_MaxTask' , 'DF_rdtPTLStationLog_DEL_MaxTask'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_Method' , 'DF_rdtPTLStationLog_DEL_Method'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_OrderKey' , 'DF_rdtPTLStationLog_DEL_OrderKey'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_PickSlipNo' , 'DF_rdtPTLStationLog_DEL_PickSlipNo'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_ShipTo' , 'DF_rdtPTLStationLog_DEL_ShipTo'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_SourceKey' , 'DF_rdtPTLStationLog_DEL_SourceKey'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_SourceType' , 'DF_rdtPTLStationLog_DEL_SourceType'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_StorerKey' , 'DF_rdtPTLStationLog_DEL_StorerKey'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_UserDefine01' , 'DF_rdtPTLStationLog_DEL_UserDefine01'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_UserDefine02' , 'DF_rdtPTLStationLog_DEL_UserDefine02'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_UserDefine03' , 'DF_rdtPTLStationLog_DEL_UserDefine03'
exec sp_rename 'rdt.DF_rdtPTLStationLog_DELLOG_WaveKey' , 'DF_rdtPTLStationLog_DEL_WaveKey'
exec sp_rename 'rdt.PK_rdtPTLStationLog_DELLOG' , 'PK_rdtPTLStationLog_DEL'
exec sp_rename 'rdt.rdtPTLStationLog_DELLOG' , 'rdtPTLStationLog_DEL'

alter table rdt.rdtPTLStationLog_DEL add SKU nvarchar(20)  not null constraint  DF_rdtPTLStationLog_DEL_SKU default ('')
alter table rdt.rdtPTLStationLog_DEL add ItemClass nvarchar(10) not null constraint  DF_rdtPTLStationLog_DEL_ItemClass default ('')
alter table rdt.rdtPTLStationLog_DEL add DelWho nvarchar(128) null constraint  DF_rdtPTLStationLog_DEL_DelWho default (suser_name())
alter table rdt.rdtPTLStationLog_DEL add DelDate datetime constraint DF_rdtPTLStationLog_DEL_DelDate default (getdate())
END
GO