CREATE TABLE [RDT].[RDTMOBREC]
(
[Mobile] [int] NOT NULL,
[Func] [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_Func] DEFAULT ((0)),
[Scn] [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_Scn] DEFAULT ((0)),
[Step] [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_Step] DEFAULT ((0)),
[Menu] [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_Menu] DEFAULT ((0)),
[Lang_Code] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InputKey] [int] NOT NULL,
[ErrMsg] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_UserName] DEFAULT ('RDT'),
[Printer] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MsgQueueNo] [int] NULL CONSTRAINT [DF_RDTMOBREC_MsgQueueNo] DEFAULT ((0)),
[V_ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_ReceiptKey] DEFAULT (''),
[V_POKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[V_LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LoadKey] DEFAULT (''),
[V_OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_OrderKey] DEFAULT (''),
[V_PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_PickSlipNo] DEFAULT (''),
[V_Zone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_Zone] DEFAULT (''),
[V_Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_Loc] DEFAULT (''),
[V_SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_SKU] DEFAULT (''),
[V_UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_UOM] DEFAULT (''),
[V_ID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_ID] DEFAULT (''),
[V_ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_ConsigneeKey] DEFAULT (''),
[V_CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_CaseID] DEFAULT (''),
[V_SKUDescr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_SKUDescr] DEFAULT (''),
[V_QTY] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_QTY] DEFAULT ((0)),
[V_UCC] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_UCC] DEFAULT (''),
[V_Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_Lot] DEFAULT (''),
[V_Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_Lottable01] DEFAULT (''),
[V_Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_Lottable02] DEFAULT (''),
[V_Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_Lottable03] DEFAULT (''),
[V_Lottable04] [datetime] NULL,
[V_Lottable05] [datetime] NULL,
[V_Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_Lottable06] DEFAULT (''),
[V_Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_Lottable07] DEFAULT (''),
[V_Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_Lottable08] DEFAULT (''),
[V_Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_Lottable09] DEFAULT (''),
[V_Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_Lottable10] DEFAULT (''),
[V_Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_Lottable11] DEFAULT (''),
[V_Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[V_Lottable13] [datetime] NULL,
[V_Lottable14] [datetime] NULL,
[V_Lottable15] [datetime] NULL,
[V_LottableLabel01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel01] DEFAULT (''),
[V_LottableLabel02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel02] DEFAULT (''),
[V_LottableLabel03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel03] DEFAULT (''),
[V_LottableLabel04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel04] DEFAULT (''),
[V_LottableLabel05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel05] DEFAULT (''),
[V_LottableLabel06] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel06] DEFAULT (''),
[V_LottableLabel07] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel07] DEFAULT (''),
[V_LottableLabel08] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel08] DEFAULT (''),
[V_LottableLabel09] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel09] DEFAULT (''),
[V_LottableLabel10] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel10] DEFAULT (''),
[V_LottableLabel11] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel11] DEFAULT (''),
[V_LottableLabel12] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel12] DEFAULT (''),
[V_LottableLabel13] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel13] DEFAULT (''),
[V_LottableLabel14] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel14] DEFAULT (''),
[V_LottableLabel15] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_LottableLabel15] DEFAULT (''),
[I_Field01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field05] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field06] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field07] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field08] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field09] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field10] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field11] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field12] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field13] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field14] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[I_Field15] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field05] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field06] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field07] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field08] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field09] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field10] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field11] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field12] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field13] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field14] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[O_Field15] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[V_String1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String1] DEFAULT (''),
[V_String2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String2] DEFAULT (''),
[V_String3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String3] DEFAULT (''),
[V_String4] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String4] DEFAULT (''),
[V_String5] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String5] DEFAULT (''),
[V_String6] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String6] DEFAULT (''),
[V_String7] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String7] DEFAULT (''),
[V_String8] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String8] DEFAULT (''),
[V_String9] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String9] DEFAULT (''),
[V_String10] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String10] DEFAULT (''),
[V_String11] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String11] DEFAULT (''),
[V_String12] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String12] DEFAULT (''),
[V_String13] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String13] DEFAULT (''),
[V_String14] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String14] DEFAULT (''),
[V_String15] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String15] DEFAULT (''),
[V_String16] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String16] DEFAULT (''),
[V_String17] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String17] DEFAULT (''),
[V_String18] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String18] DEFAULT (''),
[V_String19] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String19] DEFAULT (''),
[V_String20] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String20] DEFAULT (''),
[V_String21] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String21] DEFAULT (''),
[V_String22] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String22] DEFAULT (''),
[V_String23] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String23] DEFAULT (''),
[V_String24] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String24] DEFAULT (''),
[V_String25] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String25] DEFAULT (''),
[V_String26] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String26] DEFAULT (''),
[V_String27] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String27] DEFAULT (''),
[V_String28] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String28] DEFAULT (''),
[V_String29] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String29] DEFAULT (''),
[V_String30] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String30] DEFAULT (''),
[V_String31] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String31] DEFAULT (''),
[V_String32] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String32] DEFAULT (''),
[V_String33] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String33] DEFAULT (''),
[V_String34] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String34] DEFAULT (''),
[V_String35] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String35] DEFAULT (''),
[V_String36] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String36] DEFAULT (''),
[V_String37] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String37] DEFAULT (''),
[V_String38] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String38] DEFAULT (''),
[V_String39] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String39] DEFAULT (''),
[V_String40] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String40] DEFAULT (''),
[FieldAttr01] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr01] DEFAULT (''),
[FieldAttr02] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr02] DEFAULT (''),
[FieldAttr03] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr03] DEFAULT (''),
[FieldAttr04] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr04] DEFAULT (''),
[FieldAttr05] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr05] DEFAULT (''),
[FieldAttr06] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr06] DEFAULT (''),
[FieldAttr07] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr07] DEFAULT (''),
[FieldAttr08] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr08] DEFAULT (''),
[FieldAttr09] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr09] DEFAULT (''),
[FieldAttr10] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr10] DEFAULT (''),
[FieldAttr11] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr11] DEFAULT (''),
[FieldAttr12] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr12] DEFAULT (''),
[FieldAttr13] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr13] DEFAULT (''),
[FieldAttr14] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr14] DEFAULT (''),
[FieldAttr15] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_FieldAttr15] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_RDTMOBREC_AddDate] DEFAULT (getdate()),
[EditDate] [datetime] NULL CONSTRAINT [DF_RDTMOBREC_EditDate] DEFAULT (getdate()),
[Printer_Paper] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MenuStack] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_MenuStack] DEFAULT (''),
[V_TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMobRec_V_TaskDetailKey] DEFAULT (''),
[V_Max] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_Max] DEFAULT (''),
[RemotePrint] [int] NULL CONSTRAINT [DF_RDTMOBREC_RemotePrint] DEFAULT ((0)),
[DeviceID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_DeviceID] DEFAULT (''),
[LightMode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_LightMode] DEFAULT (''),
[StorerGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_StorerGroup] DEFAULT (''),
[V_StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_StorerKey] DEFAULT (''),
[V_String41] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String41] DEFAULT (''),
[V_String42] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String42] DEFAULT (''),
[V_String43] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String43] DEFAULT (''),
[V_String44] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String44] DEFAULT (''),
[V_String45] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String45] DEFAULT (''),
[V_String46] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String46] DEFAULT (''),
[V_String47] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String47] DEFAULT (''),
[V_String48] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String48] DEFAULT (''),
[V_String49] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String49] DEFAULT (''),
[V_String50] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String50] DEFAULT (''),
[V_WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_WaveKey] DEFAULT (''),
[V_Cartonno] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Cartonno] DEFAULT ((0)),
[V_PUOM_Div] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_PUOM_Div] DEFAULT ((0)),
[V_MQTY] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_MQTY] DEFAULT ((0)),
[V_PQTY] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_PQTY] DEFAULT ((0)),
[V_FromScn] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_FromScn] DEFAULT ((0)),
[V_FromStep] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_FromStep] DEFAULT ((0)),
[V_MTaskQty] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_MTaskQty] DEFAULT ((0)),
[V_PTaskQty] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_PTaskQty] DEFAULT ((0)),
[V_TaskQTY] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_TaskQty] DEFAULT ((0)),
[V_Integer1] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer1] DEFAULT ((0)),
[V_Integer2] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer2] DEFAULT ((0)),
[V_Integer3] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer3] DEFAULT ((0)),
[V_Integer4] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer4] DEFAULT ((0)),
[V_Integer5] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer5] DEFAULT ((0)),
[V_Integer6] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer6] DEFAULT ((0)),
[V_Integer7] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer7] DEFAULT ((0)),
[V_Integer8] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer8] DEFAULT ((0)),
[V_Integer9] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer9] DEFAULT ((0)),
[V_Integer10] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer10] DEFAULT ((0)),
[V_Integer11] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer11] DEFAULT ((0)),
[V_Integer12] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer12] DEFAULT ((0)),
[V_Integer13] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer13] DEFAULT ((0)),
[V_Integer14] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer14] DEFAULT ((0)),
[V_Integer15] [int] NULL CONSTRAINT [DF_RDTMOBREC_V_Integer15] DEFAULT ((0)),
[V_DateTime1] [datetime] NULL CONSTRAINT [DF_RDTMOBREC_V_DateTime1] DEFAULT (NULL),
[V_DateTime2] [datetime] NULL CONSTRAINT [DF_RDTMOBREC_V_DateTime2] DEFAULT (NULL),
[V_DateTime3] [datetime] NULL CONSTRAINT [DF_RDTMOBREC_V_DateTime3] DEFAULT (NULL),
[V_DateTime4] [datetime] NULL CONSTRAINT [DF_RDTMOBREC_V_DateTime4] DEFAULT (NULL),
[V_DateTime5] [datetime] NULL CONSTRAINT [DF_RDTMOBREC_V_DateTime5] DEFAULT (NULL),
[I_Field16] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_I_Field16] DEFAULT (''),
[I_Field17] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_I_Field17] DEFAULT (''),
[I_Field18] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_I_Field18] DEFAULT (''),
[I_Field19] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_I_Field19] DEFAULT (''),
[I_Field20] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_I_Field20] DEFAULT (''),
[O_Field16] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_O_Field16] DEFAULT (''),
[O_Field17] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_O_Field17] DEFAULT (''),
[O_Field18] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_O_Field18] DEFAULT (''),
[O_Field19] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_O_Field19] DEFAULT (''),
[O_Field20] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_O_Field20] DEFAULT (''),
[FieldAttr16] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_FieldAttr16] DEFAULT (''),
[FieldAttr17] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_FieldAttr17] DEFAULT (''),
[FieldAttr18] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_FieldAttr18] DEFAULT (''),
[FieldAttr19] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_FieldAttr19] DEFAULT (''),
[FieldAttr20] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMobRec_FieldAttr20] DEFAULT (''),
[V_DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_DropID] DEFAULT (''),
[V_SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_SerialNo] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  TRIGGER [RDT].[ntrRDTMobRecDelete] ON [RDT].[RDTMOBREC] 
FOR DELETE 
AS
IF EXISTS(SELECT 1 FROM DELETED 
          JOIN rdtXML ON DELETED.Mobile = rdtXML.Mobile)
BEGIN
   DELETE rdtXML
   FROM rdtXML
   JOIN DELETED ON DELETED.Mobile = rdtXML.Mobile

   DELETE rdtXML_Elm
   FROM rdtXML_Elm
   JOIN DELETED ON DELETED.Mobile = rdtXML_Elm.Mobile

   DELETE rdtXML_Root
   FROM rdtXML_Root
   JOIN DELETED ON DELETED.Mobile = rdtXML_Root.Mobile

   DELETE rdtSessionData
   FROM rdtSessionData
   JOIN DELETED ON DELETED.Mobile = rdtSessionData.Mobile
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/************************************************************************/
/* Trigger: ntrRDTMobRecUpdate                                          */
/* Creation Date: 01-Jan-2011                                           */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: Update RDTMobRec Trigger                                    */
/*                                                                      */
/* Called By: trigger                                                   */
/*                                                                      */
/* PVCS Version: 1.3                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 06-Jun-2011  TLTING    1.1 SOS 212003 - performance tune             */
/* 03-Jan-2012  KPChew    1.2 LCI Project changes.                      */
/* 03-Jan-2012  Leong     1.3 SOS 233333 - Add RDTCCLock deletion       */
/*                                         (james01)                    */
/* 28-Apr-2012  Shong     1.4   Transfer the Delete RDTDynamicPickLog   */
/*                              When User RESET                         */
/* 28-Oct-2013  TLTING    1.5 Review Editdate column update             */
/* 28-Mar-2015  James     1.6 SOS330761-Fix fieldattr not reset(james02)*/
/************************************************************************/

CREATE TRIGGER [RDT].[ntrRDTMobRecUpdate]
ON [RDT].[RDTMOBREC]
FOR UPDATE
AS
BEGIN
   IF @@ROWCOUNT = 0
   BEGIN
      RETURN
   END

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
 
   IF NOT UPDATE(EditDate)
   BEGIN
      
      UPDATE RDTMOBREC WITH (ROWLOCK)
         SET EditDate = GetDate()
      FROM RDTMOBREC
      JOIN INSERTED ON INSERTED.Mobile = RDTMOBREC.Mobile
   END
   
   IF UPDATE(UserName)
   BEGIN
      IF EXISTS ( SELECT 1 FROM RDT.RDTPickLock RPL WITH (NOLOCK)
                  JOIN INSERTED INSERTED ON INSERTED.Mobile = RPL.Mobile
                  WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
                  AND INSERTED.Mobile IS NOT NULL
                  AND RPL.Status = '1')
      BEGIN
         DELETE RPL WITH (ROWLOCK)
         FROM RDT.RDTPickLock RPL
         JOIN INSERTED INSERTED ON INSERTED.Mobile = RPL.Mobile
         WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
         AND INSERTED.Mobile IS NOT NULL
         AND RPL.Status = '1'
      END

      IF EXISTS (     Select 1 FROM RDT.RDTDynamicPickLog RPL (NOLOCK)  
            JOIN DELETED DELETED ON DELETED.UserName = RPL.AddWho  
            JOIN INSERTED INSERTED ON DELETED.MOBILE = INSERTED.MOBILE
            WHERE INSERTED.UserName IN ('RESET', 'RETIRED')  
            AND INSERTED.Mobile IS NOT NULL  )
      BEGIN
         DELETE RPL WITH (ROWLOCK) 
         FROM RDT.RDTDynamicPickLog RPL 
         JOIN DELETED DELETED ON DELETED.UserName = RPL.AddWho
         JOIN INSERTED INSERTED ON DELETED.Mobile = INSERTED.Mobile
         WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
         AND INSERTED.Mobile IS NOT NULL
      END
      
      IF EXISTS ( SELECT 1 FROM RDT.RDTCCLOCK CCL WITH (NOLOCK)
                  JOIN INSERTED INSERTED ON INSERTED.Mobile = CCL.Mobile
                  WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
                  AND INSERTED.Mobile IS NOT NULL
                  AND CCL.Status < '9')
      BEGIN
         -- delete rdtcclock when doing reset (james01)
         DELETE CCL WITH (ROWLOCK)
         FROM RDT.RDTCCLOCK CCL
         JOIN INSERTED INSERTED ON INSERTED.Mobile = CCL.Mobile
         WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
         AND INSERTED.Mobile IS NOT NULL
         AND CCL.Status < '9'
      END

      IF EXISTS ( SELECT 1 FROM RDT.RDTMobRec RDTMOB WITH (NOLOCK)
                  JOIN INSERTED INSERTED ON INSERTED.Mobile = RDTMOB.Mobile
                  WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
                  AND INSERTED.Mobile IS NOT NULL )
      BEGIN
         -- If perform RESET, force user go back to main menu to
         -- avoid user from continue using RESET as username
         UPDATE RDTMOB WITH (ROWLOCK) SET
            Func = 0,
            Scn  = 0,
            Step = 0,
            Menu = 0,
            ErrMsg = '',
            RDTMOB.I_Field01 = '',
            RDTMOB.I_Field02 = '',
            RDTMOB.I_Field03 = '',
            RDTMOB.I_Field04 = '',
            RDTMOB.O_Field01 = '',
            RDTMOB.O_Field02 = '',
            RDTMOB.O_Field03 = '',
            RDTMOB.O_Field04 = '',
            RDTMOB.FieldAttr01 = '', -- (james02)
            RDTMOB.FieldAttr02 = '', 
            RDTMOB.FieldAttr03 = '', 
            RDTMOB.FieldAttr04 = '', 
            RDTMOB.FieldAttr05 = ''  
         FROM RDT.RDTMobRec RDTMOB
         JOIN INSERTED INSERTED ON INSERTED.Mobile = RDTMOB.Mobile
         WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
         AND INSERTED.Mobile IS NOT NULL
      END
   END
END
GO
ALTER TABLE [RDT].[RDTMOBREC] ADD CONSTRAINT [PK_RDTMOBREC] PRIMARY KEY CLUSTERED ([Mobile]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtMobRec_Username] ON [RDT].[RDTMOBREC] ([UserName]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTMOBREC] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTMOBREC] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTMOBREC] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTMOBREC] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store Carton No', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Cartonno'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store DropID Value', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_DropID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store current screen no before go to next screen', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_FromScn'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store current step no before go to next step', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_FromStep'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer11'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer12'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer13'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer14'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer15'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer4'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer5'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer9'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store qty in master uom', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_MQTY'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store task qty in master uom', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_MTaskQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store qty in prefered uom', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_PQTY'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store task qty in prefered uom ', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_PTaskQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store prefered uom configuration', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_PUOM_Div'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Serial no', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_SerialNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store task qty', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_TaskQTY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'WaveKey for RDT session', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_WaveKey'
GO
