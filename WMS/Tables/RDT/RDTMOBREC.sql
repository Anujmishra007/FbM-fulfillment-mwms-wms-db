IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[RDTMOBREC]') AND type in (N'U'))
BEGIN

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
   [MenuStack] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_MenuStack] DEFAULT (''),
   [V_TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMobRec_V_TaskDetailKey] DEFAULT (''),
   [V_Max] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_Max] DEFAULT (''),
   [V_Barcode] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_Barcode] DEFAULT (''),
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
   [V_String51] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_V_String51] DEFAULT (''),
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
   [V_SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_SerialNo] DEFAULT (''),
   [ScreenFormat] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_ScreenFormat] DEFAULT (''),
   [V_EventNo1] [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_V_EventNo1] DEFAULT ((0)),
   [V_EventNo2] [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_V_EventNo2] DEFAULT ((0)),
   [V_EventNo3] [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_V_EventNo3] DEFAULT ((0)),
   [V_EventNo4] [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_V_EventNo4] DEFAULT ((0)),
   [V_EventNo5] [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_V_EventNo5] DEFAULT ((0)),
   [V_FromID] [nvarchar](18)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_FromID] DEFAULT (''),
   [V_FromLOC] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_FromLOC] DEFAULT (''),
   [V_MUOMDesc] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_MUOMDesc] DEFAULT (''),
   [V_PUOMDesc] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_PUOMDesc] DEFAULT (''),
   [V_SKUDesc1] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_SKUDesc1] DEFAULT (''),
   [V_SKUDesc2] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_SKUDesc2] DEFAULT (''),
   [V_TaskMQTY] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_TaskMQTY] DEFAULT (''),
   [V_TaskPQTY] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_TaskPQTY] DEFAULT (''),
   [V_ToID] [nvarchar](18)		COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_ToID] DEFAULT (''),
   [V_ToLOC] [nvarchar](10)	COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_ToLOC] DEFAULT (''),
   [V_UOMDiv] [nvarchar](10)	COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_UOMDiv] DEFAULT (''),
   [V_UOMRatio] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_UOMRatio] DEFAULT (''),
   [C_String1] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String1] DEFAULT (''),
   [C_String2] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String2] DEFAULT (''),
   [C_String3] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String3] DEFAULT (''),
   [C_String4] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String4] DEFAULT (''),
   [C_String5] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String5] DEFAULT (''),
   [C_String6] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String6] DEFAULT (''),
   [C_String7] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String7] DEFAULT (''),
   [C_String8] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String8] DEFAULT (''),
   [C_String9] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String9] DEFAULT (''),
   [C_String10] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String10] DEFAULT (''),
   [C_String11] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String11] DEFAULT (''),
   [C_String12] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String12] DEFAULT (''),
   [C_String13] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String13] DEFAULT (''),
   [C_String14] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String14] DEFAULT (''),
   [C_String15] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String15] DEFAULT (''),
   [C_String16] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String16] DEFAULT (''),
   [C_String17] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String17] DEFAULT (''),
   [C_String18] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String18] DEFAULT (''),
   [C_String19] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String19] DEFAULT (''),
   [C_String20] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String20] DEFAULT (''),
   [C_String21] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String21] DEFAULT (''),
   [C_String22] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String22] DEFAULT (''),
   [C_String23] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String23] DEFAULT (''),
   [C_String24] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String24] DEFAULT (''),
   [C_String25] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String25] DEFAULT (''),
   [C_String26] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String26] DEFAULT (''),
   [C_String27] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String27] DEFAULT (''),
   [C_String28] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String28] DEFAULT (''),
   [C_String29] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String29] DEFAULT (''),
   [C_String30] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMOBREC_C_String30] DEFAULT (''),
   [C_Integer1] [int] NULL CONSTRAINT [DF_RDTMOBREC_C_Integer1] DEFAULT ((0)),
   [C_Integer2] [int] NULL CONSTRAINT [DF_RDTMOBREC_C_Integer2] DEFAULT ((0)),
   [C_Integer3] [int] NULL CONSTRAINT [DF_RDTMOBREC_C_Integer3] DEFAULT ((0)),
   [C_Integer4] [int] NULL CONSTRAINT [DF_RDTMOBREC_C_Integer4] DEFAULT ((0)),
   [C_Integer5] [int] NULL CONSTRAINT [DF_RDTMOBREC_C_Integer5] DEFAULT ((0)),
   [C_DateTime1] [datetime] NULL CONSTRAINT [DF_RDTMOBREC_C_DateTime1] DEFAULT (NULL),
   [C_DateTime2] [datetime] NULL CONSTRAINT [DF_RDTMOBREC_C_DateTime2] DEFAULT (NULL),
   [C_DateTime3] [datetime] NULL CONSTRAINT [DF_RDTMOBREC_C_DateTime3] DEFAULT (NULL),
   [C_DateTime4] [datetime] NULL CONSTRAINT [DF_RDTMOBREC_C_DateTime4] DEFAULT (NULL),
   [C_DateTime5] [datetime] NULL CONSTRAINT [DF_RDTMOBREC_C_DateTime5] DEFAULT (NULL),
   [V_String52] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String52] DEFAULT (''),
   [V_String53] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String53] DEFAULT (''),
   [V_String54] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String54] DEFAULT (''),
   [V_String55] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String55] DEFAULT (''),
   [V_String56] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String56] DEFAULT (''),
   [V_String57] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String57] DEFAULT (''),
   [V_String58] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String58] DEFAULT (''),
   [V_String59] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String59] DEFAULT (''),
   [V_String60] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String60] DEFAULT (''),
   [V_String61] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String61] DEFAULT (''),
   [V_String62] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String62] DEFAULT (''),
   [V_String63] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String63] DEFAULT (''),
   [V_String64] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String64] DEFAULT (''),
   [V_String65] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String65] DEFAULT (''),
   [V_String66] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String66] DEFAULT (''),
   [V_String67] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String67] DEFAULT (''),
   [V_String68] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String68] DEFAULT (''),
   [V_String69] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String69] DEFAULT (''),
   [V_String70] [nvarchar](60)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String70] DEFAULT ('')
   ) ON [PRIMARY]

   ALTER TABLE [RDT].[RDTMOBREC] ADD CONSTRAINT [PK_RDTMOBREC] PRIMARY KEY CLUSTERED ([Mobile]) WITH (FILLFACTOR=90) ON [PRIMARY]

   IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[RDT].[RDTMOBREC]') AND name = N'IX_rdtMobRec_Username')
   CREATE NONCLUSTERED INDEX [IX_rdtMobRec_Username] ON [RDT].[RDTMOBREC] ([UserName]) ON [PRIMARY]

   GRANT DELETE ON  [RDT].[RDTMOBREC] TO [NSQL]
   GRANT INSERT ON  [RDT].[RDTMOBREC] TO [NSQL]
   GRANT SELECT ON  [RDT].[RDTMOBREC] TO [NSQL]
   GRANT UPDATE ON  [RDT].[RDTMOBREC] TO [NSQL]


IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Cartonno'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store Carton No', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Cartonno'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_DropID'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store DropID Value', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_DropID'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_FromScn'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store current screen no before go to next screen', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_FromScn'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_FromStep'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store current step no before go to next step', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_FromStep'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer1'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer1'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer10'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer10'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer11'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer11'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer12'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer12'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer13'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer13'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer14'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer14'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer15'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer15'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer2'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer2'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer3'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer3'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer4'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer4'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer5'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer5'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer6'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer6'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer7'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer7'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer8'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer8'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_Integer9'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store misc integer variable', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_Integer9'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_MQTY'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store qty in master uom', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_MQTY'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_MTaskQty'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store task qty in master uom', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_MTaskQty'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_PQTY'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store qty in prefered uom', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_PQTY'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_PTaskQty'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store task qty in prefered uom ', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_PTaskQty'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_PUOM_Div'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store prefered uom configuration', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_PUOM_Div'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_SerialNo'))
   EXEC sp_addextendedproperty N'MS_Description', 'Serial no', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_SerialNo'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_TaskQTY'))
  EXEC sp_addextendedproperty N'MS_Description', N'Store task qty', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_TaskQTY'

 IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTMOBREC', N'COLUMN',N'V_WaveKey'))
  EXEC sp_addextendedproperty N'MS_Description', 'WaveKey for RDT session', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_WaveKey'


END
ELSE
BEGIN


   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String1')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String1 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String1 DEFAULT('')
   END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String2')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String2 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String2 DEFAULT('')

   END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String3')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String3 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String3 DEFAULT('')
   END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String4')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String4 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String4 DEFAULT('')

   END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String5')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String5 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String5 DEFAULT('')

   END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String6')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String6 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String6 DEFAULT('')
	END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String7')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String7 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String7 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String8')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String8 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String8 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String9')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String9 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String9 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String10')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String10 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String10 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String11')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String11 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String11 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String12')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String12 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String12 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String13')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String13 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String13 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String14')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String14 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String14 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String15')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String15 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String15 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String16')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String16 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String16 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String17')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String17 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String17 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String18')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String18 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String18 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String19')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String19 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String19 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String20')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String20 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String20 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String21')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String21 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String21 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String22')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String22 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String22 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String23')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String23 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String23 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String24')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String24 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String24 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String25')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String25 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String25 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String26')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String26 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String26 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String27')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String27 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String27 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String28')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String28 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String28 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String29')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String29 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String29 DEFAULT('')
	  END

   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'C_String30')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD C_String30 NVARCHAR(250)  NULL CONSTRAINT DF_RDTMOBREC_C_String30 DEFAULT('')
	  END

   -- rdtMobRec.C_Integer1
   IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'rdtMobRec' AND COLUMN_NAME = 'C_Integer1')
   BEGIN
      ALTER TABLE rdt.rdtMobRec ADD C_Integer1 INT NOT NULL CONSTRAINT DF_rdtMobRec_C_Integer1 DEFAULT (0) WITH VALUES
	  END

   -- rdtMobRec.C_Integer2
   IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'rdtMobRec' AND COLUMN_NAME = 'C_Integer2')
   BEGIN
      ALTER TABLE rdt.rdtMobRec ADD C_Integer2 INT NOT NULL CONSTRAINT DF_rdtMobRec_C_Integer2 DEFAULT (0) WITH VALUES

	END
   -- rdtMobRec.C_Integer3
   IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'rdtMobRec' AND COLUMN_NAME = 'C_Integer3')
   BEGIN
      ALTER TABLE rdt.rdtMobRec ADD C_Integer3 INT NOT NULL CONSTRAINT DF_rdtMobRec_C_Integer3 DEFAULT (0) WITH VALUES
	  END

   -- rdtMobRec.C_Integer4
   IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'rdtMobRec' AND COLUMN_NAME = 'C_Integer4')
   BEGIN
      ALTER TABLE rdt.rdtMobRec ADD C_Integer4 INT NOT NULL CONSTRAINT DF_rdtMobRec_C_Integer4 DEFAULT (0) WITH VALUES
	  END

   -- rdtMobRec.C_Integer5
   IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'rdtMobRec' AND COLUMN_NAME = 'C_Integer5')
   BEGIN
      ALTER TABLE rdt.rdtMobRec ADD C_Integer5 INT NOT NULL CONSTRAINT DF_rdtMobRec_C_Integer5 DEFAULT (0) WITH VALUES
	  END

   -- rdtMobRec.C_DateTime1
   IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'rdtMobRec' AND COLUMN_NAME = 'C_DateTime1')
   BEGIN
      ALTER TABLE rdt.rdtMobRec ADD C_DateTime1 DATETIME NULL CONSTRAINT DF_rdtMobRec_C_DateTime1 DEFAULT (NULL) WITH VALUES
	  END

   -- rdtMobRec.C_DateTime2
   IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'rdtMobRec' AND COLUMN_NAME = 'C_DateTime2')
   BEGIN
      ALTER TABLE rdt.rdtMobRec ADD C_DateTime2 DATETIME NULL CONSTRAINT DF_rdtMobRec_C_DateTime2 DEFAULT (NULL) WITH VALUES
	  END

   -- rdtMobRec.C_DateTime3
   IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'rdtMobRec' AND COLUMN_NAME = 'C_DateTime3')
   BEGIN
      ALTER TABLE rdt.rdtMobRec ADD C_DateTime3 DATETIME NULL CONSTRAINT DF_rdtMobRec_C_DateTime3 DEFAULT (NULL) WITH VALUES
	  END

   -- rdtMobRec.C_DateTime4
   IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'rdtMobRec' AND COLUMN_NAME = 'C_DateTime4')
   BEGIN
      ALTER TABLE rdt.rdtMobRec ADD C_DateTime4 DATETIME NULL CONSTRAINT DF_rdtMobRec_C_DateTime4 DEFAULT (NULL) WITH VALUES

	END

   -- rdtMobRec.C_DateTime5
   IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'rdtMobRec' AND COLUMN_NAME = 'C_DateTime5')
   BEGIN
      ALTER TABLE rdt.rdtMobRec ADD C_DateTime5 DATETIME NULL CONSTRAINT DF_rdtMobRec_C_DateTime5 DEFAULT (NULL) WITH VALUES

	END

   -- rdtMobRec.V_String51
   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTMOBREC' AND COLUMN_NAME = 'V_String51')
   BEGIN
      ALTER TABLE RDT.RDTMOBREC ADD V_String51 NVARCHAR(60)  NULL CONSTRAINT DF_RDTMOBREC_V_String51 DEFAULT('')
	END


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String52' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String52 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String52] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String53' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String53 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String53] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String54' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String54 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String54] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String55' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String55 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String55] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String56' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String56 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String56] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String57' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String57 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String57] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String58' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String58 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String58] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String59' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String59 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String59] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String60' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String60 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String60] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String61' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String61 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String61] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String62' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String62 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String62] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String63' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String63 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String63] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String64' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String64 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String64] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String65' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String65 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String65] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String66' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String66 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String66] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String67' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String67 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String67] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String68' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String68 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String68] DEFAULT ('');
				
			END

			
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String69' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String69 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String69] DEFAULT ('');
				
			END

						
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_String70' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD  V_String70 [nvarchar](60)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_String70] DEFAULT ('');
				
			END


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'ScreenFormat' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD ScreenFormat [nvarchar](10) NOT NULL CONSTRAINT [DF_RDTMOBREC_V_ScreenFormat] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'ScreenFormat', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'ScreenFormat'
				
			END



		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_EventNo1' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_EventNo1 [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_V_EventNo1] DEFAULT ((0));
				EXEC sp_addextendedproperty N'MS_Description', 'V_EventNo1', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_EventNo1'
				
			END

		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_EventNo2' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_EventNo2 [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_V_EventNo2] DEFAULT ((0));
				EXEC sp_addextendedproperty N'MS_Description', 'V_EventNo2', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_EventNo2'
				
			END


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_EventNo3' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_EventNo3 [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_V_EventNo3] DEFAULT ((0));
				EXEC sp_addextendedproperty N'MS_Description', 'V_EventNo3', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_EventNo3'
				
			END

		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_EventNo4' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_EventNo4 [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_V_EventNo4] DEFAULT ((0));
				EXEC sp_addextendedproperty N'MS_Description', 'V_EventNo4', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_EventNo4'
				
			END


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_EventNo5' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_EventNo5 [int] NOT NULL CONSTRAINT [DF_RDTMOBREC_V_EventNo5] DEFAULT ((0));
				EXEC sp_addextendedproperty N'MS_Description', 'V_EventNo5', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_EventNo5'
				
			END


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_FromID' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_FromID [nvarchar](18) NOT NULL CONSTRAINT [DF_RDTMOBREC_V_FromID] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'Store current ID before go to next step', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_FromID'
				
			END



		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_FromLOC' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_FromLOC [nvarchar](10) NOT NULL CONSTRAINT [DF_RDTMOBREC_V_FromLOC] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'Store current location before go to next step', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_FromLOC'
				
			END


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_MUOMDesc' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_MUOMDesc [nvarchar](10) NOT NULL CONSTRAINT [DF_RDTMOBREC_V_MUOMDesc] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'Store description in master uom', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_MUOMDesc'
				
			END


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_PUOMDesc' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_PUOMDesc [nvarchar](10) NOT NULL CONSTRAINT [DF_RDTMOBREC_V_PUOMDesc] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'Store description in preffered uom', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_PUOMDesc'
				
			END


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_SKUDesc1' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_SKUDesc1 [nvarchar](20) NOT NULL CONSTRAINT [DF_RDTMOBREC_V_SKUDesc1] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'Store SKU description', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_SKUDesc1'
				
			END

		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_SKUDesc2' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_SKUDesc2 [nvarchar](20) NOT NULL CONSTRAINT [DF_RDTMOBREC_V_SKUDesc2] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'Store SKU description', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_SKUDesc2'
				
			END


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_TaskMQTY' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_TaskMQTY [nvarchar](10) NOT NULL CONSTRAINT [DF_RDTMOBREC_V_TaskMQTY] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'Store task qty in master uom', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_TaskMQTY'
				
			END


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_TaskPQTY' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_TaskPQTY [nvarchar](10) NOT NULL CONSTRAINT [DF_RDTMOBREC_V_TaskPQTY] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'Store qty in prefered uom', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_TaskPQTY'
				
			END




		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_ToID' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_ToID [nvarchar](18)	 NOT NULL CONSTRAINT [DF_RDTMOBREC_V_ToID] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'Store destination ID', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_ToID'
				
			END


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_ToLOC' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_ToLOC [nvarchar](10) NOT NULL CONSTRAINT [DF_RDTMOBREC_V_ToLOC] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'Store destination Location', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_ToLOC'
				
			END



		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_UOMDiv' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_UOMDiv [nvarchar](10) NOT NULL CONSTRAINT [DF_RDTMOBREC_V_UOMDiv] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'Store uom configuration', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_UOMDiv'
				
			END


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'V_UOMRatio' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
			BEGIN

				ALTER TABLE [RDT].[RDTMOBREC] ADD V_UOMRatio [nvarchar](10) NOT NULL CONSTRAINT [DF_RDTMOBREC_V_UOMRatio] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'Store uom ratio', 'SCHEMA', N'RDT', 'TABLE', N'RDTMOBREC', 'COLUMN', N'V_UOMRatio'
				
			END


-- ALTER COLUMN


	IF EXISTS (SELECT 1
   FROM sys.columns
   WHERE Name = 'C_String1' AND Object_ID = Object_ID('RDT.RDTMOBREC') and max_length < 500)
   BEGIN
      alter table rdt.RDTMOBREC
      Alter column  C_String1 nvarchar(250) NULL
   END
	IF EXISTS (SELECT 1
   FROM sys.columns
   WHERE Name = 'C_String2' AND Object_ID = Object_ID('RDT.RDTMOBREC') and max_length < 500)
   BEGIN
      alter table rdt.RDTMOBREC
      Alter column  C_String2 nvarchar(250) NULL
   END
	IF EXISTS (SELECT 1
   FROM sys.columns
   WHERE Name = 'C_String3' AND Object_ID = Object_ID('RDT.RDTMOBREC') and max_length < 500)
   BEGIN
      alter table rdt.RDTMOBREC
      Alter column  C_String3 nvarchar(250) NULL
   END
	IF EXISTS (SELECT 1
   FROM sys.columns
   WHERE Name = 'C_String4' AND Object_ID = Object_ID('RDT.RDTMOBREC') and max_length < 500)
   BEGIN
      alter table rdt.RDTMOBREC
      Alter column  C_String4 nvarchar(250) NULL
   END
	IF EXISTS (SELECT 1
   FROM sys.columns
   WHERE Name = 'C_String5' AND Object_ID = Object_ID('RDT.RDTMOBREC') and max_length < 500)
   BEGIN
      alter table rdt.RDTMOBREC
      Alter column  C_String5 nvarchar(250) NULL
   END
	IF EXISTS (SELECT 1
   FROM sys.columns
   WHERE Name = 'C_String6' AND Object_ID = Object_ID('RDT.RDTMOBREC') and max_length < 500)
   BEGIN
      alter table rdt.RDTMOBREC
      Alter column  C_String6 nvarchar(250) NULL
   END
	IF EXISTS (SELECT 1
   FROM sys.columns
   WHERE Name = 'C_String7' AND Object_ID = Object_ID('RDT.RDTMOBREC') and max_length < 500)
   BEGIN
      alter table rdt.RDTMOBREC
      Alter column  C_String7 nvarchar(250) NULL
   END
	IF EXISTS (SELECT 1
   FROM sys.columns
   WHERE Name = 'C_String8' AND Object_ID = Object_ID('RDT.RDTMOBREC') and max_length < 500)
   BEGIN
      alter table rdt.RDTMOBREC
      Alter column  C_String8 nvarchar(250) NULL
   END
	IF EXISTS (SELECT 1
   FROM sys.columns
   WHERE Name = 'C_String9' AND Object_ID = Object_ID('RDT.RDTMOBREC') and max_length < 500)
   BEGIN
      alter table rdt.RDTMOBREC
      Alter column  C_String9 nvarchar(250) NULL
   END
	IF EXISTS (SELECT 1
   FROM sys.columns
   WHERE Name = 'C_String10' AND Object_ID = Object_ID('RDT.RDTMOBREC') and max_length < 500)
   BEGIN
      alter table rdt.RDTMOBREC
      Alter column  C_String10  nvarchar(250) NULL
    END

   -- UWP-56557 Extend MenuStack column to 120 characters to support longer menu stack values
   IF EXISTS (
    SELECT 1
    FROM sys.columns c
    INNER JOIN sys.objects o ON c.object_id = o.object_id
    INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
    WHERE s.name    = 'RDT'
      AND o.name    = 'RDTMOBREC'
      AND c.name    = 'MenuStack'
      AND c.max_length = 120   -- nvarchar(60) stores as 120 bytes (2 bytes/char)
   )
   BEGIN
      ALTER TABLE [RDT].[RDTMOBREC] ALTER COLUMN [MenuStack] NVARCHAR(120)
   END

   -- FCR-13666 Add V_Barcode column to RDTMOBREC table to store barcode value for mobile transactions
   IF NOT EXISTS (SELECT 1
               FROM sys.columns
               WHERE Name = 'V_Barcode' AND Object_ID = Object_ID('RDT.RDTMOBREC'))
   BEGIN
      ALTER TABLE [RDT].[RDTMOBREC] ADD  V_Barcode [nvarchar](MAX)  NOT NULL CONSTRAINT [DF_RDTMOBREC_V_Barcode] DEFAULT ('')
   END

END

--END
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--SET ANSI_NULLS ON
--GO

--FCR-2435 Comment out the trigger creation.The trigger generation are in the independent scripts. by JCH507
/*
IF OBJECT_ID ('RDT.ntrRDTMobRecDelete', 'TR') IS NOT NULL  
   DROP TRIGGER [RDT].[ntrRDTMobRecDelete]
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
GO*/

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
/*
IF OBJECT_ID ('RDT.ntrRDTMobRecUpdate', 'TR') IS NOT NULL  
   DROP TRIGGER [RDT].[ntrRDTMobRecUpdate]
GO
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
*/