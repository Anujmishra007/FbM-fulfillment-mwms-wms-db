IF NOT EXISTS (SELECT *
               FROM sys.tables
               WHERE name = 'PalletTypeMaster'
                 AND type = 'U')
    BEGIN
        CREATE TABLE [dbo].[PalletTypeMaster]
        (
            [PalletTypeMasterKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
            [Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
            [StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (' '),
            [PalletType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT (''),
            [PalletTypeName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT (''),
            [Length] [float] NOT NULL DEFAULT ((0)),
            [Width] [float] NOT NULL DEFAULT ((0)),
            [Height] [float] NOT NULL DEFAULT ((0)),
            [LoadBearingCapacity] [decimal] (10, 2) NOT NULL DEFAULT ((0)),
            [ExtraLoad] [decimal] (10, 2) NOT NULL DEFAULT ((0)),
            [DeadLoad] [decimal] (10, 2) NOT NULL DEFAULT ((0)),
            [Region] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
            [ISOStandard] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
            [PalletTypeInUse] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        ) ON [PRIMARY]

        ALTER TABLE [dbo].[PalletTypeMaster] ADD CONSTRAINT [PKPALLETTYPEMASTER] PRIMARY KEY NONCLUSTERED ([PalletTypeMasterKey]) WITH (FILLFACTOR=90) ON [PRIMARY]

        GRANT DELETE ON  [dbo].[PalletTypeMaster] TO [NSQL]

        GRANT INSERT ON  [dbo].[PalletTypeMaster] TO [NSQL]

        GRANT SELECT ON  [dbo].[PalletTypeMaster] TO [NSQL]

        GRANT UPDATE ON  [dbo].[PalletTypeMaster] TO [NSQL]

        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Pallet Type Master Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'PalletTypeMasterKey'
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Facility', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'Facility'
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Storer Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'StorerKey'
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Pallet Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'PalletType'
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Pallet Type Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'PalletTypeName'
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Length of Pallet Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'Length'
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Width of Pallet Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'Width'
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Height of Pallet Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'Height'
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Load Bearing Capacity of Pallet Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'LoadBearingCapacity'
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Extra Load of Pallet Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'ExtraLoad'
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Dead Load of Pallet Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'DeadLoad'
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Region of Pallet Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'Region'
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ISO Standard of Pallet Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'ISOStandard'
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Pallet Type In Use', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PalletTypeMaster', @level2type = N'COLUMN', @level2name = N'PalletTypeInUse'
    END
ELSE
    PRINT 'Table already exists'

