CREATE TABLE [RDT].[rdtSTDEventLog]
(
[EventNum] [int] NOT NULL IDENTITY(1, 1),
[EventType] [int] NOT NULL CONSTRAINT [DF_rdtSTDEventLog_EventType] DEFAULT ((0)),
[ActionType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSTDEventLog_ActionType] DEFAULT (''),
[EventDateTime] [datetime] NOT NULL CONSTRAINT [DF_rdtSTDEventLog_EventDateTime] DEFAULT (getdate()),
[UserID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_UserID] DEFAULT (''),
[MobileNo] [int] NULL CONSTRAINT [DF_rdtSTDEventLog_MobileNo] DEFAULT ((0)),
[FunctionID] [int] NULL CONSTRAINT [DF_rdtSTDEventLog_FunctionID] DEFAULT ((0)),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_Facility] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_StorerKey] DEFAULT (''),
[Location] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_Location] DEFAULT (''),
[ToLocation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_ToLocation] DEFAULT (''),
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_PutawayZone] DEFAULT (''),
[PickZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_PickZone] DEFAULT (''),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_ID] DEFAULT (''),
[ToID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_ToID] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_SKU] DEFAULT (''),
[ComponentSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_ComponentSKU] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_UOM] DEFAULT (''),
[QTY] [int] NULL CONSTRAINT [DF_rdtSTDEventLog_QTY] DEFAULT ((0)),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_Lot] DEFAULT (''),
[ToLot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_ToLot] DEFAULT (''),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_Lottable01] DEFAULT (''),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_Lottable02] DEFAULT (''),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_Lottable03] DEFAULT (''),
[Lottable04] [datetime] NULL CONSTRAINT [DF_rdtSTDEventLog_Lottable04] DEFAULT (''),
[Lottable05] [datetime] NULL CONSTRAINT [DF_rdtSTDEventLog_Lottable05] DEFAULT (''),
[RefNo1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_RefNo1] DEFAULT (''),
[RefNo2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_RefNo2] DEFAULT (''),
[RefNo3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_RefNo3] DEFAULT (''),
[RefNo4] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_RefNo4] DEFAULT (''),
[RefNo5] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_RefNo5] DEFAULT (''),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowRef] [int] NULL CONSTRAINT [DF_rdtSTDEventLog_RowRef] DEFAULT ((0)),
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_ReceiptKey] DEFAULT (''),
[POKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_POKey] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_LoadKey] DEFAULT (''),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_OrderKey] DEFAULT (''),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_PickSlipNo] DEFAULT (''),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_DropID] DEFAULT (''),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_TaskDetailKey] DEFAULT (''),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSTDEventLog_WaveKey] DEFAULT (''),
[TrackingNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_TrackingNo] DEFAULT (''),
[AreaKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_AreaKey] DEFAULT (''),
[TTMStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_TTMStrategyKey] DEFAULT (''),
[ListKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_ListKey] DEFAULT (''),
[UCC] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_UCC] DEFAULT (''),
[ReplenishmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_ReplenishmentKey] DEFAULT (''),
[DeviceID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_DeviceID] DEFAULT (''),
[DevicePosition] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_DevicePosition] DEFAULT (''),
[ToUCC] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_ToUCC] DEFAULT (''),
[SourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_SourceKey] DEFAULT (''),
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_LabelNo] DEFAULT (''),
[CCKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_CCKey] DEFAULT (''),
[SuggestedLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_SuggestedLOC] DEFAULT (''),
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_CaseID] DEFAULT (''),
[ReasonKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_ReasonKey] DEFAULT (''),
[TaskType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_TaskType] DEFAULT (''),
[ExpectedQty] [int] NULL CONSTRAINT [DF_RDTSTDEventLog_ExpectedQty] DEFAULT ('0'),
[SerialNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_SerialNo] DEFAULT (''),
[PickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_PickMethod] DEFAULT (''),
[Step] [int] NULL CONSTRAINT [DF_RDTSTDEventLog_Step] DEFAULT ('0'),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_Status] DEFAULT ('0'),
[RDTOption] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_RDTOption] DEFAULT (''),
[PUOM_Desc] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_PUOM_Desc] DEFAULT (''),
[MUOM_Desc] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_MUOM_Desc] DEFAULT (''),
[PQTY] [int] NULL CONSTRAINT [DF_RDTSTDEventLog_PQTY] DEFAULT ('0'),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_ConsigneeKey] DEFAULT (''),
[CCSheetNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_CCSheetNo] DEFAULT (''),
[SealNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_SealNo] DEFAULT (''),
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_MBOLKey] DEFAULT (''),
[ContainerNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_ContainerNo] DEFAULT (''),
[LicenseNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_LicenseNo] DEFAULT (''),
[TruckID] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_TruckID] DEFAULT (''),
[Remark] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_Remark] DEFAULT (''),
[ToLabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_ToLabelNo] DEFAULT (''),
[ExternKitKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_ExternKitKey] DEFAULT (''),
[ChildID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_ChildID] DEFAULT (''),
[Lane] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_Lane] DEFAULT (''),
[SSCC] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_SSCC] DEFAULT (''),
[SerialNoKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_SerialNoKey] DEFAULT (''),
[Scn] [int] NULL CONSTRAINT [DF_RDTSTDEventLog_Scn] DEFAULT ('0'),
[CartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_CartonType] DEFAULT (''),
[Weight] [float] NULL CONSTRAINT [DF_RDTSTDEventLog_Weight] DEFAULT ('0'),
[ReplenishmentGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_ReplenishmentGroup] DEFAULT (''),
[Length] [float] NULL CONSTRAINT [DF_RDTSTDEventLog_Length] DEFAULT ('0'),
[Width] [float] NULL CONSTRAINT [DF_RDTSTDEventLog_Width] DEFAULT ('0'),
[Height] [float] NULL CONSTRAINT [DF_RDTSTDEventLog_Height] DEFAULT ('0'),
[OptionDefinition] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_OptionDefinition] DEFAULT (''),
[TransType] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_TransType] DEFAULT (''),
[CountNo] [int] NULL CONSTRAINT [DF_rdtSTDEventLog_CountNo] DEFAULT ((0)),
[CartonID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_CartonID] DEFAULT (''),
[Barcode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_Barcode] DEFAULT (''),
[ContainerKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSTDEventLog_ContainerKey] DEFAULT (''),
[CartonNo] [int] NULL CONSTRAINT [DF_rdtSTDEventLog_CartonNo] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtSTDEventLog] ADD CONSTRAINT [PK_rdtSTDEventLog] PRIMARY KEY CLUSTERED ([EventNum]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_rdtSTDEventLog] ON [RDT].[rdtSTDEventLog] ([Facility], [StorerKey], [EventType], [FunctionID], [MobileNo], [UserID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_rdtSTDEventLog_Func] ON [RDT].[rdtSTDEventLog] ([FunctionID], [Facility], [StorerKey], [ActionType], [MobileNo]) INCLUDE ([RefNo1], [RefNo2], [RefNo3]) ON [PRIMARY]
GO
GRANT SELECT ON  [RDT].[rdtSTDEventLog] TO [JReportRole]
GO
GRANT DELETE ON  [RDT].[rdtSTDEventLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtSTDEventLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtSTDEventLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtSTDEventLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Barcode', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLog', 'COLUMN', N'Barcode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton ID', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLog', 'COLUMN', N'CartonID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton No', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLog', 'COLUMN', N'CartonNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Container Key', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLog', 'COLUMN', N'ContainerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Count No', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLog', 'COLUMN', N'CountNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Height', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLog', 'COLUMN', N'Height'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Length', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLog', 'COLUMN', N'Length'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Option Definition', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLog', 'COLUMN', N'OptionDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Replenishment Group', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLog', 'COLUMN', N'ReplenishmentGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trans Type', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLog', 'COLUMN', N'TransType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WaveKey of the record that event is logged', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLog', 'COLUMN', N'WaveKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Width', 'SCHEMA', N'RDT', 'TABLE', N'rdtSTDEventLog', 'COLUMN', N'Width'
GO
