IF NOT EXISTS (SELECT *
               FROM sys.tables
               WHERE name = 'LOC'
                 AND type = 'U')
    BEGIN
        CREATE TABLE [dbo].[LOC]
        (
            [Loc]                 [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL
                CONSTRAINT [DF_LOC_Loc] DEFAULT ('UNKNOWN'),
            [Cube]                [float]                                              NULL
                CONSTRAINT [DF_LOC_cube] DEFAULT ((0)),
            [Length]              [float]                                              NULL
                CONSTRAINT [DF_LOC_length] DEFAULT ((0)),
            [Width]               [float]                                              NULL
                CONSTRAINT [DF_LOC_width] DEFAULT ((0)),
            [Height]              [float]                                              NULL
                CONSTRAINT [DF_LOC_height] DEFAULT ((0)),
            [LocationType]        [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL
                CONSTRAINT [DF_LOC_LocationType] DEFAULT ('OTHER'),
            [LocationFlag]        [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL
                CONSTRAINT [DF_LOC_LocationFlag] DEFAULT ('NONE'),
            [LocationHandling]    [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL
                CONSTRAINT [DF_LOC_LocationHandling] DEFAULT ('1'),
            [LocationCategory]    [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL
                CONSTRAINT [DF_LOC_LocationCategory] DEFAULT ('OTHER'),
            [LogicalLocation]     [nvarchar](18) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL
                CONSTRAINT [DF_LOC_LogicalLocation] DEFAULT (' '),
            [CubicCapacity]       [float]                                              NULL
                CONSTRAINT [DF_LOC_CubicCapacity] DEFAULT ((0)),
            [WeightCapacity]      [float]                                              NULL
                CONSTRAINT [DF_LOC_WeightCapacity] DEFAULT ((0)),
            [Status]              [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL
                CONSTRAINT [DF_LOC_Status] DEFAULT ('OK'),
            [LoseId]              [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_Loseid] DEFAULT ('0'),
            [Facility]            [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_Facility] DEFAULT ('F1'),
            [ABC]                 [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_ABC] DEFAULT ('B'),
            [PickZone]            [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL
                CONSTRAINT [DF_LOC_PickZone] DEFAULT (' '),
            [PutawayZone]         [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL
                CONSTRAINT [DF_LOC_PutAwayZone] DEFAULT ('RACK'),
            [SectionKey]          [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL
                CONSTRAINT [DF_LOC_SectionKey] DEFAULT ('FACILITY'),
            [PickMethod]          [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_PickMethod] DEFAULT (' '),
            [CommingleSku]        [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_CommingleSku] DEFAULT ('1'),
            [CommingleLot]        [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_CommingleLot] DEFAULT ('1'),
            [LocLevel]            [int]                                                NOT NULL
                CONSTRAINT [DF_LOC_LocLevel] DEFAULT ((0)),
            [Xcoord]              [int]                                                NOT NULL
                CONSTRAINT [DF_LOC_Xcoord] DEFAULT ((0)),
            [Ycoord]              [int]                                                NOT NULL
                CONSTRAINT [DF_LOC_Ycoord] DEFAULT ((0)),
            [Zcoord]              [int]                                                NOT NULL
                CONSTRAINT [DF_LOC_Zcoord] DEFAULT ((0)),
            [TrafficCop]          [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NULL,
            [ArchiveCop]          [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NULL,
            [MaxPallet]           [int]                                                NULL
                CONSTRAINT [DF_Loc_MaxPallet] DEFAULT ((0)),
            [LocAisle]            [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL
                CONSTRAINT [DF_LOC_LocAisle] DEFAULT (' '),
            [HOSTWHCODE]          [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
            [CCLogicalLoc]        [nvarchar](18) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL
                CONSTRAINT [DF_LOC_CCLogicalLoc] DEFAULT (' '),
            [ChargingPallet]      [float]                                              NULL
                CONSTRAINT [DF_LOC_ChargingPallet] DEFAULT ((0)),
            [EditWho]             [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
                CONSTRAINT [DF_LOC_EditWho] DEFAULT (suser_sname()),
            [EditDate]            [datetime]                                           NULL
                CONSTRAINT [DF_LOC_EditDate] DEFAULT (getdate()),
            [AddWho]              [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
                CONSTRAINT [DF_LOC_AddWho] DEFAULT (suser_sname()),
            [AddDate]             [datetime]                                           NULL
                CONSTRAINT [DF_LOC_AddDate] DEFAULT (getdate()),
            [LocCheckDigit]       [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL
                CONSTRAINT [DF_LOC_LocCheckDigit] DEFAULT (''),
            [LastCycleCount]      [datetime]                                           NULL,
            [CycleCountFrequency] [int]                                                NULL,
            [LoseUCC]             [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NULL
                CONSTRAINT [DF_LOC_LoseUCC] DEFAULT (''),
            [NoMixLottable01]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable01] DEFAULT ('0'),
            [NoMixLottable02]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable02] DEFAULT ('0'),
            [NoMixLottable03]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable03] DEFAULT ('0'),
            [NoMixLottable04]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable04] DEFAULT ('0'),
            [LocBay]              [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL
                CONSTRAINT [DF_LOC_LocBay] DEFAULT (''),
            [PALogicalLoc]        [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL
                CONSTRAINT [DF_LOC_PALogicalLoc] DEFAULT (''),
            [Score]               [int]                                                NOT NULL
                CONSTRAINT [DF_LOC_Score] DEFAULT ((0)),
            [LocationRoom]        [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
            [LocationGroup]       [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL
                CONSTRAINT [DF_LOC_LocationGroup] DEFAULT (''),
            [NoMixLottable05]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable05] DEFAULT ('0'),
            [NoMixLottable06]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable06] DEFAULT ('0'),
            [NoMixLottable07]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable07] DEFAULT ('0'),
            [NoMixLottable08]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable08] DEFAULT ('0'),
            [NoMixLottable09]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable09] DEFAULT ('0'),
            [NoMixLottable10]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable10] DEFAULT ('0'),
            [NoMixLottable11]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable11] DEFAULT ('0'),
            [NoMixLottable12]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable12] DEFAULT ('0'),
            [NoMixLottable13]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable13] DEFAULT ('0'),
            [NoMixLottable14]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable14] DEFAULT ('0'),
            [NoMixLottable15]     [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS   NOT NULL
                CONSTRAINT [DF_LOC_NoMixLottable15] DEFAULT ('0'),
            [Floor]               [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS   NULL
                CONSTRAINT [DF_LOC_Floor] DEFAULT (''),
            [CycleCounter]        [int]                                                NULL
                CONSTRAINT [DF_LOC_CycleCounter] DEFAULT ((0)),
            [Descr]               [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL
                CONSTRAINT [DF_LOC_Descr] DEFAULT (''),
            [MaxCarton]           [int]                                                NOT NULL
                CONSTRAINT [DF_LOC_MaxCarton] DEFAULT ((0)),
            [MaxSKU]              [int]                                                NOT NULL
                CONSTRAINT [DF_LOC_MaxSKU] DEFAULT ((0)),
            [DisableCheckDigitAutoCompute] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS  DEFAULT ('False'),
            [ColorCode]               [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS   NULL
                CONSTRAINT [DF_LOC_ColorCode] DEFAULT (''),
            CONSTRAINT [CK_LOC_Loc_01] CHECK ((NOT [Loc] = ' ')),
            CONSTRAINT [PKLOC] PRIMARY KEY CLUSTERED ([Loc]) WITH (FILLFACTOR = 90) ON [PRIMARY],
            INDEX [IDX_LOC_facility2] NONCLUSTERED ([Facility], [LocAisle]) ON [PRIMARY],
            INDEX [IDX_LOC_LocType] NONCLUSTERED ([Facility], [LocationType], [LocationCategory],
                                                  [Status], [LogicalLocation]) ON [PRIMARY],
            INDEX [IX_LOC] NONCLUSTERED ([LocationFlag], [Status], [HOSTWHCODE]) ON [PRIMARY],
            INDEX [IDX_LOC_pickzone] NONCLUSTERED ([PickZone]) ON [PRIMARY],
            INDEX [IDX_LOC_PUTAWAYZONE] NONCLUSTERED ([PutawayZone]) WITH (FILLFACTOR = 90) ON [PRIMARY],
            INDEX [IDX_LOC_facility_LocationFlag] NONCLUSTERED ([Facility], [LocationFlag]) INCLUDE ([PALogicalLoc]) ON [PRIMARY]
        ) ON [PRIMARY]
    END
ELSE
    BEGIN
        ALTER TABLE LOC
            ALTER COLUMN LocCheckDigit NVARCHAR(10);
        IF NOT EXISTS (SELECT *
                       FROM sys.columns
                       WHERE Name = 'DisableCheckDigitAutoCompute'
                         AND Object_ID = Object_ID('LOC'))
            BEGIN
                ALTER TABLE LOC
                    ADD DisableCheckDigitAutoCompute NVARCHAR(5) DEFAULT 'False';
                EXEC sp_addextendedproperty N'MS_Description', N'If True, the check digit will not be auto computed',
                     'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'DisableCheckDigitAutoCompute';
            END
        IF NOT EXISTS (SELECT * FROM sys.columns
                       WHERE Name = 'ColorCode' AND Object_ID = Object_ID('LOC'))
            BEGIN
                ALTER TABLE LOC ADD ColorCode NVARCHAR(20) DEFAULT '';
                EXEC sp_addextendedproperty N'MS_Description', N'Locations are marked with different colors to aid productivity', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'ColorCode';
            END
    END

GRANT SELECT ON [dbo].[LOC] TO [JReportRole]
GO
GRANT DELETE ON [dbo].[LOC] TO [NSQL]
GO
GRANT INSERT ON [dbo].[LOC] TO [NSQL]
GO
GRANT SELECT ON [dbo].[LOC] TO [NSQL]
GO
GRANT UPDATE ON [dbo].[LOC] TO [NSQL]
GO

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = 0)
    EXEC sp_addextendedproperty N'MS_Description',
         'After a product is received, it is stored at a location in the warehouse. The locations will be physically labeled. It can be of any sizes and dimensions.',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', NULL, NULL;

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'ABC' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'ABC designation of the fixed locations where A - fast mover, B - average mover, C - slow mover',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'ABC';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'AddDate' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'AddDate';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'AddWho' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'AddWho';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'CCLogicalLoc'
                                     AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', 'This is used for sorting the stock count sheet',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'CCLogicalLoc';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'ChargingPallet'
                                     AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', 'Customized for HK for billing purposes',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'ChargingPallet';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'CommingleLot'
                                     AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Indicates whether more than one lot can be stored at the location. Options are Y or N',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'CommingleLot';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'CommingleSku'
                                     AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Indicates whether more than one commodity can be stored at the location. Options are Y or N',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'CommingleSku';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'Cube' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Size of the LocationÆs storage area. (Length * Width * Height) ', 'SCHEMA', N'dbo',
         'TABLE', N'LOC', 'COLUMN', N'Cube';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'CubicCapacity'
                                     AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Maximum cubic capacity of the location (length x width x height)', 'SCHEMA', N'dbo',
         'TABLE', N'LOC', 'COLUMN', N'CubicCapacity';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'CycleCounter'
                                     AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Counter', 'SCHEMA', N'dbo',
         'TABLE', N'LOC', 'COLUMN', N'CycleCounter';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'EditDate' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo',
         'TABLE', N'LOC', 'COLUMN', N'EditDate';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'EditWho' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo',
         'TABLE', N'LOC', 'COLUMN', N'EditWho';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'Facility' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'The warehouse or DC in which the location is residing', 'SCHEMA', N'dbo', 'TABLE', N'LOC',
         'COLUMN', N'Facility';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'Height' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', 'Height of the location''s storage area',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'Height';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'HOSTWHCODE' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Stores the host warehouse code which will be used during the interface process', 'SCHEMA',
         N'dbo', 'TABLE', N'LOC', 'COLUMN', N'HOSTWHCODE';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'Length' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', 'Length of the location''s storage area',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'Length';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'Loc' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Unique code identifying the physical location in the facility', 'SCHEMA', N'dbo', 'TABLE',
         N'LOC', 'COLUMN', N'Loc';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'LocAisle' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', 'Indicates the aisle of the location', 'SCHEMA',
         N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LocAisle';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'LocationCategory'
                                     AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Identifies the physical location type, for example Cantilever Rack, Drive Through Rack, Horizontal Carousel, ASRS, Drive In Rack, Double Deep etc.  This can be setup in CODE Look up where LISTNAME = ''LOCCATEGRY''',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LocationCategory';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'LocationFlag'
                                     AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Identifies the purpose of the location. Option include: DAMAGE, HOLD , NONE and INACTIVE',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LocationFlag';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'LocationHandling'
                                     AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Identifies the type of packaging to be stored in the location. Options include: Pallets only, Cases only, Other',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LocationHandling';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'LocationType'
                                     AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Identifies how the location is used, for example   PICK-CASE - used as a location from which to pick full cases  OTHER - used for bulk/full pallet storage  Staged - indicates the location used when all the details for an order line have moved to a final',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LocationType';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'LocCheckDigit'
                                     AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Calculate Location Check Digit  Purpose is to facilitate future development of Voice Pick',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LocCheckDigit';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'LocLevel' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Indicates the level of the location from the floor', 'SCHEMA', N'dbo', 'TABLE', N'LOC',
         'COLUMN', N'LocLevel';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'LogicalLocation'
                                     AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'In many facilities, the location field is not sequenced in the order in which picking and putaway should occur. The route sequence field is used to sequence locations for picking and putaway purposes',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LogicalLocation';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'LoseId' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'When selected, removes the pallet id from all products moved into the location', 'SCHEMA',
         N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LoseId';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'MaxCarton' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', N'Store value for Maximum carton 1 Loc can have',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'MaxCarton';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'MaxPallet' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Maximum pallets that the location can store at any one time', 'SCHEMA', N'dbo', 'TABLE',
         N'LOC', 'COLUMN', N'MaxPallet';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'MaxSKU' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', N'Store value for Maximum SKU 1 Loc can have',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'MaxSKU';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'PickZone' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Used by RDT to lock the area for picking i.e. once a picker starts picking at this zone, no other pickers can pick at the same zone',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'PickZone';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'PutawayZone' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'Zone to which the location is assigned. Options include DOCK and RACK', 'SCHEMA', N'dbo',
         'TABLE', N'LOC', 'COLUMN', N'PutawayZone';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'SectionKey' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', 'Functional division within the facility',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'SectionKey';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'Status' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'A pre-populated field that notes Location status', 'SCHEMA', N'dbo', 'TABLE', N'LOC',
         'COLUMN', N'Status';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'TrafficCop' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description',
         'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'TrafficCop';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'WeightCapacity'
                                     AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', 'Maximum weight capacity the location can hold',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'WeightCapacity';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'Width' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', 'Width of the storage area', 'SCHEMA', N'dbo',
         'TABLE', N'LOC', 'COLUMN', N'Width';

IF NOT EXISTS (SELECT NULL
               FROM SYS.EXTENDED_PROPERTIES
               WHERE [major_id] = OBJECT_ID('LOC')
                 AND [name] = N'MS_Description'
                 AND [minor_id] = (SELECT [column_id]
                                   FROM SYS.COLUMNS
                                   WHERE [name] = 'DisableCheckDigitAutoCompute' AND [object_id] = OBJECT_ID('LOC')))
    EXEC sp_addextendedproperty N'MS_Description', N'If True, the check digit will not be auto computed',
         'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'DisableCheckDigitAutoCompute';
