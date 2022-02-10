CREATE TABLE [dbo].[StockTakeSheetParameters]
(
[StockTakeKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ZoneParm] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_ZoneParm] DEFAULT ('ALL'),
[AisleParm] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_AisleParm] DEFAULT ('ALL'),
[LevelParm] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_LevelParm] DEFAULT ('0 - 99'),
[HostWHCodeParm] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_HostWHCodeParm] DEFAULT ('ALL'),
[SKUParm] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_SKUParm] DEFAULT ('ALL'),
[AgencyParm] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_AgencyParm] DEFAULT ('ALL'),
[ABCParm] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_ABCParm] DEFAULT ('ALL'),
[Protect] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_Protect] DEFAULT ('N'),
[Password] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_Password] DEFAULT (' '),
[WithQuantity] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_WithQuantity] DEFAULT ('Y'),
[ClearHistory] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_ClearHistory] DEFAULT ('Y'),
[EmptyLocation] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_EmptyLocation] DEFAULT ('Y'),
[LinesPerPage] [int] NULL,
[FinalizeStage] [int] NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_FinalizeStage] DEFAULT ((0)),
[PopulateStage] [int] NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_PopulateStage] DEFAULT ((0)),
[GroupLottable05] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_GroupLottable05] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_EditWho] DEFAULT (suser_sname()),
[AdjReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_AdjReasonCode] DEFAULT (' '),
[AdjType] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_AdjType] DEFAULT (' '),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BlankCSheetHideLoc] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_BlankCSheetHideLoc] DEFAULT ('N'),
[BlankCSheetNoOfPage] [int] NULL CONSTRAINT [DF_StockTakeSheetParameters_BlankCSheetNoOfPage] DEFAULT ((0)),
[SkugroupParm] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_SkugroupParm] DEFAULT ('ALL'),
[ExcludeQtyPicked] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_ExcludeQtyPicked] DEFAULT ('N'),
[CountType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_CountType] DEFAULT (''),
[ExtendedParm1Field] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExtendedParm1Field] DEFAULT (''),
[ExtendedParm1] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExtendedParm1] DEFAULT (''),
[ExtendedParm2Field] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExtendedParm2Field] DEFAULT (''),
[ExtendedParm2] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExtendedParm2] DEFAULT (''),
[ExtendedParm3Field] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExtendedParm3Field] DEFAULT (''),
[ExtendedParm3] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExtendedParm3] DEFAULT (''),
[ExcludeQtyAllocated] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExcludeQtyAllocated] DEFAULT ('N'),
[StrategyKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_StrategyKey] DEFAULT (''),
[Parameter01] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_Parameter01] DEFAULT (''),
[Parameter02] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_Parameter02] DEFAULT (''),
[Parameter03] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_Parameter03] DEFAULT (''),
[Parameter04] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_Parameter04] DEFAULT (''),
[Parameter05] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_Parameter05] DEFAULT (''),
[CountSheetGroupBy01] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetGroupBy01] DEFAULT ('LOC.PutawayZone'),
[CountSheetGroupBy02] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetGroupBy02] DEFAULT ('LOC.LocAisle'),
[CountSheetGroupBy03] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetGroupBy03] DEFAULT ('LOC.LocLevel'),
[CountSheetGroupBy04] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetGroupBy04] DEFAULT (''),
[CountSheetGroupBy05] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetGroupBy05] DEFAULT (''),
[CountSheetSortBy01] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy01] DEFAULT ('LOC.CCLogicalLoc'),
[CountSheetSortBy02] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy02] DEFAULT ('LOC.Loc'),
[CountSheetSortBy03] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy03] DEFAULT ('LOTxLOCxID.ID'),
[CountSheetSortBy04] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy04] DEFAULT ('LOTxLOCxID.Sku'),
[CountSheetSortBy05] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy05] DEFAULT ('LOTxLOCxID.Lot'),
[CountSheetSortBy06] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy06] DEFAULT (''),
[CountSheetSortBy07] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy07] DEFAULT (''),
[CountSheetSortBy08] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy08] DEFAULT (''),
[BlankCSheetLineByMaxPLT] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_BlankCSheetLineByMaxPLT] DEFAULT ('N'),
[BlankCSheetDPTRNOnly] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_BlankCSheetDPTRNOnly] DEFAULT ('N'),
[QueryinJSON] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_QueryinJSON] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_Status] DEFAULT (''),
[LocPerPage] [int] NULL CONSTRAINT [DF_StockTakeSheetParameters_LocPerPage] DEFAULT ((0))
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[StockTakeSheetParameters] ADD CONSTRAINT [PK_StockTakeSheetParameters] PRIMARY KEY CLUSTERED ([StockTakeKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[StockTakeSheetParameters] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[StockTakeSheetParameters] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[StockTakeSheetParameters] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[StockTakeSheetParameters] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[StockTakeSheetParameters] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'The system will print the stock count blind sheets based on the parameters configuration in Stock Take Parameters window. The WMS will list all the locations in the area/zone specified. Automatic stock quantity withdrawal from these locations will occur once the posting is executed.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet Group By Field 1', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet By Group Field 2', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet Group By Field 3', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet By Group Field 4', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet By Group Field 5', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 1', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 2', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 3', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 4', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 5', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 6', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 7', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 8', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Exclude QtyAllocated Option', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExcludeQtyAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 1', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 1', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm1Field'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 2 Value', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 2', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm2Field'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 3 Value', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 3', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm3Field'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Loc Per Page', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'LocPerPage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 01', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 02', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 03', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 04', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 05', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Stock Take.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'StockTakeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy Key', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'StrategyKey'
GO
