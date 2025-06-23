IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[StockTakeSheetParameters]') AND type in (N'U'))
BEGIN
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
[LocPerPage] [int] NULL CONSTRAINT [DF_StockTakeSheetParameters_LocPerPage] DEFAULT ((0)),
[IncludeZeroSkuQty] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_IncludeZeroSkuQty]  DEFAULT (''),
[Userdefine01] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine01]  DEFAULT (''),
[Userdefine02] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine02]  DEFAULT (''),
[Userdefine03] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine03]  DEFAULT (''),
[Userdefine04] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine04]  DEFAULT (''),
[Userdefine05] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine05]  DEFAULT (''),
[Userdefine06] [datetime] NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine06]  DEFAULT (''),
[Userdefine07] [datetime] NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine07]  DEFAULT (''),
[Userdefine08] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine08]  DEFAULT (''),
[Userdefine09] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine09]  DEFAULT (''),
[Userdefine10] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine10]  DEFAULT (''),
) ON [PRIMARY]


ALTER TABLE [dbo].[StockTakeSheetParameters] ADD CONSTRAINT [PK_StockTakeSheetParameters] PRIMARY KEY CLUSTERED ([StockTakeKey]) WITH (FILLFACTOR=90) ON [PRIMARY]

--GRANT SELECT ON  [dbo].[StockTakeSheetParameters] TO [JReportRole]

GRANT DELETE ON  [dbo].[StockTakeSheetParameters] TO [NSQL]

GRANT INSERT ON  [dbo].[StockTakeSheetParameters] TO [NSQL]

GRANT SELECT ON  [dbo].[StockTakeSheetParameters] TO [NSQL]

GRANT UPDATE ON  [dbo].[StockTakeSheetParameters] TO [NSQL]

EXEC sp_addextendedproperty N'MS_Description', 'The system will print the stock count blind sheets based on the parameters configuration in Stock Take Parameters window. The WMS will list all the locations in the area/zone specified. Automatic stock quantity withdrawal from these locations will occur once the posting is executed.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', NULL, NULL

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'AddDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'AddWho'

EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet Group By Field 1', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy01'

EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet By Group Field 2', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy02'

EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet Group By Field 3', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy03'

EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet By Group Field 4', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy04'

EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet By Group Field 5', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy05'

EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 1', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy01'

EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 2', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy02'

EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 3', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy03'

EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 4', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy04'

EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 5', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy05'

EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 6', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy06'

EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 7', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy07'

EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 8', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy08'

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'EditDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'EditWho'

EXEC sp_addextendedproperty N'MS_Description', N'Exclude QtyAllocated Option', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExcludeQtyAllocated'

EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 1', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm1'

EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 1', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm1Field'

EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 2 Value', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm2'

EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 2', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm2Field'

EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 3 Value', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm3'

EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 3', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm3Field'

EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Facility'

EXEC sp_addextendedproperty N'MS_Description', N'Loc Per Page', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'LocPerPage'

EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 01', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter01'

EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 02', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter02'

EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 03', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter03'

EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 04', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter04'

EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 05', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter05'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Stock Take.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'StockTakeKey'

EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'StorerKey'

EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy Key', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'StrategyKey'

END

ELSE 
BEGIN 

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'IncludeZeroSkuQty' AND Object_ID = Object_ID('dbo.StockTakeSheetParameters'))
BEGIN
	ALTER TABLE dbo.StockTakeSheetParameters ADD IncludeZeroSkuQty [nvarchar](1) NULL CONSTRAINT [DF_StockTakeSheetParameters_IncludeZeroSkuQty]  DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'IncludeZeroSkuQty', 'SCHEMA', N'DBO', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'IncludeZeroSkuQty'
				
END


IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'SKUParm' AND Object_ID = Object_ID('dbo.StockTakeSheetParameters'))
BEGIN
	ALTER TABLE dbo.StockTakeSheetParameters ADD [SKUParm] [nvarchar] (125) NULL CONSTRAINT [DF_StockTakeSheetParameters_SKUParm] DEFAULT ('ALL');
	EXEC sp_addextendedproperty N'MS_Description', 'SKUParm', 'SCHEMA', N'DBO', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'SKUParm'
				
END


IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'Userdefine01' AND Object_ID = Object_ID('dbo.StockTakeSheetParameters'))
BEGIN
	ALTER TABLE dbo.StockTakeSheetParameters ADD [Userdefine01] [nvarchar](50) NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine01]  DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'Userdefine01', 'SCHEMA', N'DBO', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Userdefine01'
				
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'Userdefine02' AND Object_ID = Object_ID('dbo.StockTakeSheetParameters'))
BEGIN
	ALTER TABLE dbo.StockTakeSheetParameters ADD [Userdefine02] [nvarchar](50) NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine02]  DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'Userdefine02', 'SCHEMA', N'DBO', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Userdefine02'
				
END


IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'Userdefine03' AND Object_ID = Object_ID('dbo.StockTakeSheetParameters'))
BEGIN
	ALTER TABLE dbo.StockTakeSheetParameters ADD [Userdefine03] [nvarchar](50) NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine03]  DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'Userdefine03', 'SCHEMA', N'DBO', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Userdefine03'
				
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'Userdefine04' AND Object_ID = Object_ID('dbo.StockTakeSheetParameters'))
BEGIN
	ALTER TABLE dbo.StockTakeSheetParameters ADD [Userdefine04] [nvarchar](50) NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine04]  DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'Userdefine04', 'SCHEMA', N'DBO', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Userdefine04'
				
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'Userdefine05' AND Object_ID = Object_ID('dbo.StockTakeSheetParameters'))
BEGIN
	ALTER TABLE dbo.StockTakeSheetParameters ADD [Userdefine05] [nvarchar](50) NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine05]  DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'Userdefine05', 'SCHEMA', N'DBO', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Userdefine05'
				
END


IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'Userdefine06' AND Object_ID = Object_ID('dbo.StockTakeSheetParameters'))
BEGIN
	ALTER TABLE dbo.StockTakeSheetParameters ADD [Userdefine06]  [datetime] NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine06]  DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'Userdefine06', 'SCHEMA', N'DBO', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Userdefine06'
				
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'Userdefine07' AND Object_ID = Object_ID('dbo.StockTakeSheetParameters'))
BEGIN
	ALTER TABLE dbo.StockTakeSheetParameters ADD [Userdefine07]  [datetime] NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine07]  DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'Userdefine07', 'SCHEMA', N'DBO', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Userdefine07'
				
END


IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'Userdefine08' AND Object_ID = Object_ID('dbo.StockTakeSheetParameters'))
BEGIN
	ALTER TABLE dbo.StockTakeSheetParameters ADD [Userdefine08] [nvarchar](50) NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine08]  DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'Userdefine08', 'SCHEMA', N'DBO', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Userdefine08'
				
END


IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'Userdefine09' AND Object_ID = Object_ID('dbo.StockTakeSheetParameters'))
BEGIN
	ALTER TABLE dbo.StockTakeSheetParameters ADD [Userdefine09] [nvarchar](50) NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine09]  DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'Userdefine09', 'SCHEMA', N'DBO', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Userdefine09'
				
END


IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'Userdefine10' AND Object_ID = Object_ID('dbo.StockTakeSheetParameters'))
BEGIN
	ALTER TABLE dbo.StockTakeSheetParameters ADD [Userdefine10] [nvarchar](50) NULL CONSTRAINT [DF_StockTakeSheetParameters_Userdefine10]  DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'Userdefine10', 'SCHEMA', N'DBO', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Userdefine10'
				
END


END
