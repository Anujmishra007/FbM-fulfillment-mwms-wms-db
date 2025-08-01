IF NOT EXISTS (SELECT *
               FROM sys.tables
               WHERE name = 'KIT' AND type = 'U')
BEGIN
    CREATE TABLE [dbo].[KIT]
    (
    [KITKey] [nvarchar] (10) NOT NULL,
    [StorerKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_KIT_StorerKey] DEFAULT (' '),
    [ToStorerKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_KIT_ToStorerKey] DEFAULT (' '),
    [Type] [nvarchar] (12) NOT NULL CONSTRAINT [DF_KIT_Type] DEFAULT (' '),
    [OpenQty] [int] NOT NULL CONSTRAINT [DF_KIT_OpenQty] DEFAULT ((0)),
    [Status] [nvarchar] (10) NOT NULL CONSTRAINT [DF_KIT_Status] DEFAULT ('0'),
    [EffectiveDate] [datetime] NULL CONSTRAINT [DF_KIT_EffectiveDate] DEFAULT (getdate()),
    [ReasonCode] [nvarchar] (10) NULL,
    [CustomerRefNo] [nvarchar] (10) NULL,
    [Remarks] [nvarchar] (200) NULL,
    [AddDate] [datetime] NOT NULL CONSTRAINT [DF_KIT_AddDate] DEFAULT (getdate()),
    [AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_KIT_AddWho] DEFAULT (suser_sname()),
    [EditDate] [datetime] NOT NULL CONSTRAINT [DF_KIT_EditDate] DEFAULT (getdate()),
    [EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_KIT_EditWho] DEFAULT (suser_sname()),
    [TrafficCop] [nvarchar] (1) NULL,
    [ArchiveCop] [nvarchar] (1) NULL,
    [Timestamp] [timestamp] NOT NULL,
    [GenerateHOCharges] [nvarchar] (10) NULL,
    [GenerateIS_HiCharges] [nvarchar] (10) NULL,
    [Facility] [nvarchar] (5) NULL CONSTRAINT [DF_KIT_Facility] DEFAULT ('F1'),
    [USRDEF1] [nvarchar] (18) NULL CONSTRAINT [DF_KIT_USRDEF1] DEFAULT (' '),
    [USRDEF2] [nvarchar] (18) NULL CONSTRAINT [DF_KIT_USRDEF2] DEFAULT (' '),
    [USRDEF3] [nvarchar] (18) NULL CONSTRAINT [DF_KIT_USRDEF3] DEFAULT (' '),
    [ActionFlag] [nvarchar] (1) NULL CONSTRAINT [DF_KIT_ActionFlag] DEFAULT ('0'),
    [ExternKitKey] [nvarchar] (20) NULL CONSTRAINT [DF_KIT_ExternKitKey] DEFAULT (' '),
    [USRDEF4] [nvarchar] (30) NULL CONSTRAINT [DF_KIT_USRDEF4] DEFAULT (''),
    [USRDEF5] [nvarchar] (30) NULL CONSTRAINT [DF_KIT_USRDEF5] DEFAULT (''),
    [USRDEF6] [datetime] NULL,
    [USRDEF7] [datetime] NULL,
    [USRDEF8] [nvarchar] (30) NULL CONSTRAINT [DF_KIT_USRDEF8] DEFAULT (''),
    [USRDEF9] [nvarchar] (30) NULL CONSTRAINT [DF_KIT_USRDEF9] DEFAULT (''),
    [USRDEF10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_KIT_USRDEF10] DEFAULT (''),
    [USRDEF11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_KIT_USRDEF11] DEFAULT (''),
    [USRDEF12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_KIT_USRDEF12] DEFAULT (''),
    [USRDEF13] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_KIT_USRDEF13] DEFAULT (''),
    [USRDEF14] [datetime] NULL,
    [USRDEF15] [datetime] NULL,
    [ExternStatus] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_KIT_ExternStatus] DEFAULT (''),
    ) ON [PRIMARY]

    ALTER TABLE [dbo].[KIT] ADD CONSTRAINT [PK_KIT] PRIMARY KEY CLUSTERED ([KITKey]) WITH (FILLFACTOR=90) ON [PRIMARY]

    GRANT DELETE ON  [dbo].[KIT] TO [NSQL]

    GRANT INSERT ON  [dbo].[KIT] TO [NSQL]

    GRANT SELECT ON  [dbo].[KIT] TO [NSQL]

    GRANT UPDATE ON  [dbo].[KIT] TO [NSQL]

    EXEC sp_addextendedproperty N'MS_Description', 'Kitting is the process of placing two or more items together to form one group or product, to be sold as one single item. Inventory updates itself by accounting for each individual part and crediting the whole thing as a unit. A kit is essentially a BOM (bill of material) that is not part of manufacturing.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', NULL, NULL

    EXEC sp_addextendedproperty N'MS_Description', 'Action flag', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'ActionFlag'

    EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'AddDate'

    EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'AddWho'

    EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'ArchiveCop'

    EXEC sp_addextendedproperty N'MS_Description', 'Customer reference number', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'CustomerRefNo'

    EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'EditDate'

    EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'EditWho'

    EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'EffectiveDate'

    EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Kitting used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'ExternKitKey'

    EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'Facility'

    EXEC sp_addextendedproperty N'MS_Description', 'Calculate a Handling out charge to be applied to the From Storer for service handling charges', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'GenerateHOCharges'

    EXEC sp_addextendedproperty N'MS_Description', 'Calculate both initial storage and handling in charges to be applied to the To Storer for service and handling', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'GenerateIS_HiCharges'

    EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Kitting.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'KITKey'

    EXEC sp_addextendedproperty N'MS_Description', 'Open Quantity', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'OpenQty'

    EXEC sp_addextendedproperty N'MS_Description', 'Reason', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'ReasonCode'

    EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'Remarks'

    EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'Status'

    EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'StorerKey'

    EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'Timestamp'

    EXEC sp_addextendedproperty N'MS_Description', 'Storer to whom the ownership of product is transferred', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'ToStorerKey'

    EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'TrafficCop'

    EXEC sp_addextendedproperty N'MS_Description', 'Type of Shipment Order. The default is Standard', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'Type'

    EXEC sp_addextendedproperty N'MS_Description', 'User defined field 1', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF1'

    EXEC sp_addextendedproperty N'MS_Description', 'User defined field 2', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF2'

    EXEC sp_addextendedproperty N'MS_Description', 'User defined field 3', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF3'

    EXEC sp_addextendedproperty N'MS_Description', 'User defined field 10', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF10'

    EXEC sp_addextendedproperty N'MS_Description', 'User defined field 11', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF11'

    EXEC sp_addextendedproperty N'MS_Description', 'User defined field 12', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF12'

    EXEC sp_addextendedproperty N'MS_Description', 'User defined field 13', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF13'

    EXEC sp_addextendedproperty N'MS_Description', 'User defined field 14', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF14'

    EXEC sp_addextendedproperty N'MS_Description', 'User defined field 15', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF15'

    EXEC sp_addextendedproperty N'MS_Description', 'Extern Status', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'ExternStatus'
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM sys.columns
                   WHERE Name = 'USRDEF10' AND Object_ID = Object_ID('KIT'))
    BEGIN
        ALTER TABLE KIT ADD USRDEF10 NVARCHAR(30) NULL CONSTRAINT [DF_KIT_USRDEF10]  DEFAULT (' ');
        EXEC sp_addextendedproperty N'MS_Description', N'USRDEF10', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF10'
    END

    IF NOT EXISTS (SELECT 1
                   FROM sys.columns
                   WHERE Name = 'USRDEF11' AND Object_ID = Object_ID('KIT'))
    BEGIN
        ALTER TABLE KIT ADD USRDEF11 NVARCHAR(30) NULL CONSTRAINT [DF_KIT_USRDEF11]  DEFAULT (' ');
        EXEC sp_addextendedproperty N'MS_Description', N'USRDEF11', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF11'
    END

    IF NOT EXISTS (SELECT 1
                   FROM sys.columns
                   WHERE Name = 'USRDEF12' AND Object_ID = Object_ID('KIT'))
    BEGIN
        ALTER TABLE KIT ADD USRDEF12 NVARCHAR(30) NULL CONSTRAINT [DF_KIT_USRDEF12]  DEFAULT (' ');
        EXEC sp_addextendedproperty N'MS_Description', N'USRDEF12', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF12'
    END

    IF NOT EXISTS (SELECT 1
                   FROM sys.columns
                   WHERE Name = 'USRDEF13' AND Object_ID = Object_ID('KIT'))
    BEGIN
        ALTER TABLE KIT ADD USRDEF13 NVARCHAR(30) NULL CONSTRAINT [DF_KIT_USRDEF13]  DEFAULT (' ');
        EXEC sp_addextendedproperty N'MS_Description', N'USRDEF13', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF13'
    END

    IF NOT EXISTS (SELECT 1
                   FROM sys.columns
                   WHERE Name = 'USRDEF14' AND Object_ID = Object_ID('KIT'))
    BEGIN
        ALTER TABLE KIT ADD USRDEF14 DATETIME;
        EXEC sp_addextendedproperty N'MS_Description', N'USRDEF14', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF14'
    END

    IF NOT EXISTS (SELECT 1
                   FROM sys.columns
                   WHERE Name = 'USRDEF15' AND Object_ID = Object_ID('KIT'))
    BEGIN
        ALTER TABLE KIT ADD USRDEF15 DATETIME;
        EXEC sp_addextendedproperty N'MS_Description', N'USRDEF15', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF15'
    END

    IF NOT EXISTS (SELECT 1
                   FROM sys.columns
                   WHERE Name = 'ExternStatus' AND Object_ID = Object_ID('KIT'))
    BEGIN
        ALTER TABLE KIT ADD ExternStatus NVARCHAR(30) NULL CONSTRAINT [DF_KIT_ExternStatus]  DEFAULT (' ');
        EXEC sp_addextendedproperty N'MS_Description', N'ExternStatus', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'ExternStatus'
    END


	--ALTER COLUMN 
		IF EXISTS ( SELECT 1 FROM sys.columns sc              
					   JOIN sys.tables so ON so.object_id = sc.object_id
					   WHERE sc.name = 'USRDEF14'
					   AND so.name = 'KIT'
					   AND sc.Max_length <> 8
		   )
		   BEGIN
			  DECLARE @c_ConstraintName NVARCHAR(100) = ''
			  SELECT @c_ConstraintName = default_constraints.name
			  FROM sys.all_columns
			  INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
			  INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
			  INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
			  WHERE  schemas.name = 'dbo'
			  AND tables.name = 'KIT'
			  AND all_columns.name = 'USRDEF14'

			  EXEC ( N'ALTER TABLE dbo.KIT DROP CONSTRAINT ' + @c_ConstraintName );
			  ALTER TABLE dbo.KIT ALTER COLUMN USRDEF14 DATETIME NULL;
			  ALTER TABLE dbo.KIT ADD CONSTRAINT [DF_KIT_USRDEF14] DEFAULT (' ') FOR USRDEF14;
		   END             
		   
		 

		IF EXISTS ( SELECT 1 FROM sys.columns sc              
					   JOIN sys.tables so ON so.object_id = sc.object_id
					   WHERE sc.name = 'USRDEF15'
					   AND so.name = 'KIT'
					   AND sc.Max_length <> 8
		   )
		   BEGIN
			  DECLARE @c_ConstraintNames NVARCHAR(100) = ''
			  SELECT @c_ConstraintNames = default_constraints.name
			  FROM sys.all_columns
			  INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
			  INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
			  INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
			  WHERE  schemas.name = 'dbo'
			  AND tables.name = 'KIT'
			  AND all_columns.name = 'USRDEF15'

			  EXEC ( N'ALTER TABLE dbo.KIT DROP CONSTRAINT ' + @c_ConstraintNames );
			  ALTER TABLE dbo.KIT ALTER COLUMN USRDEF15 DATETIME NULL;
			  ALTER TABLE dbo.KIT ADD CONSTRAINT [DF_KIT_USRDEF15] DEFAULT (' ') FOR USRDEF15;
		   END                        

END


