    IF NOT EXISTS (SELECT *
               FROM sys.tables
               WHERE name = 'DeviceProfilelog'
                 AND type in (N'U'))
   BEGIN

        CREATE TABLE [dbo].[DeviceProfileLog]
        (
        [DeviceProfileKey] [nvarchar] (10) NOT NULL CONSTRAINT [DF_DeviceProfileLog_DeviceProfileKey] DEFAULT (''),
        [DeviceProfileLogKey] [nvarchar] (10) NOT NULL,
        [OrderKey] [nvarchar] (10) NOT NULL CONSTRAINT [DF_DeviceProfileLog_OrderKey] DEFAULT (' '),
        [DropID] [nvarchar] (20) NOT NULL CONSTRAINT [DF_DeviceProfileLog_DropID] DEFAULT ('0'),
        [Status] [nvarchar] (10) NOT NULL CONSTRAINT [DF_DeviceProfileLog_Status] DEFAULT ('0'),
        [AddDate] [datetime] NOT NULL CONSTRAINT [DF_DeviceProfileLog_AddDate] DEFAULT (getdate()),
        [AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_DeviceProfileLog_AddWho] DEFAULT (suser_sname()),
        [EditDate] [datetime] NOT NULL CONSTRAINT [DF_DeviceProfileLog_EditDate] DEFAULT (getdate()),
        [EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_DeviceProfileLog_EditWho] DEFAULT (suser_sname()),
        [TrafficCop] [nvarchar] (1) NULL,
        [UserDefine01] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine01] DEFAULT (' '),
        [UserDefine02] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine02] DEFAULT (' '),
        [UserDefine03] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine03] DEFAULT (' '),
        [UserDefine04] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine04] DEFAULT (' '),
        [UserDefine05] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine05] DEFAULT (' '),
        [UserDefine06] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine06] DEFAULT (' '),
        [UserDefine07] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine07] DEFAULT (' '),
        [UserDefine08] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine08] DEFAULT (' '),
        [UserDefine09] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine09] DEFAULT (' '),
        [UserDefine10] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine10] DEFAULT (' '),
        [ConsigneeKey] [nvarchar] (15) NULL CONSTRAINT [DF_DeviceProfileLog_ConsigneeKey] DEFAULT (''),
        [RowRef] [bigint] NOT NULL IDENTITY(1, 1),
        [Facility] [nvarchar] (5) CONSTRAINT [DF_DeviceProfileLog_Facility] DEFAULT ('')
        ) ON [PRIMARY]
         
      ALTER TABLE [dbo].[DeviceProfileLog] ADD CONSTRAINT [PK_DeviceProfileLog] PRIMARY KEY CLUSTERED ([DeviceProfileKey], [DeviceProfileLogKey], [OrderKey], [DropID]) WITH (FILLFACTOR=90) ON [PRIMARY]

      CREATE NONCLUSTERED INDEX [IDX_DeviceProfileLog_DropID] ON [dbo].[DeviceProfileLog] ([DropID], [OrderKey]) ON [PRIMARY]

	  GRANT DELETE ON  [dbo].[DeviceProfileLog] TO [NSQL]

	  GRANT INSERT ON  [dbo].[DeviceProfileLog] TO [NSQL]
	  
	  GRANT SELECT ON  [dbo].[DeviceProfileLog] TO [NSQL]
	  
	  GRANT UPDATE ON  [dbo].[DeviceProfileLog] TO [NSQL]
	  

    END


    ELSE
    BEGIN

        IF NOT EXISTS (SELECT *
                FROM sys.columns
                WHERE Name = 'RowRef'
                    AND Object_ID = Object_ID('dbo.DeviceProfilelog'))
        BEGIN
            ALTER TABLE dbo.DeviceProfilelog
                ADD [RowRef] [bigint] NOT NULL IDENTITY(1, 1);
        END
 




        IF NOT EXISTS (SELECT *
                FROM sys.columns
                WHERE Name = 'Facility'
                    AND Object_ID = Object_ID('dbo.DeviceProfilelog'))
        BEGIN
            ALTER TABLE dbo.DeviceProfilelog
                ADD Facility NVARCHAR(5)
                CONSTRAINT [DF_DeviceProfileLog_Facility] DEFAULT ('');
        END
    END



--DISABLE TRIGGER [dbo].[ntrDeviceProfileLogUpdate] ON [dbo].[DeviceProfileLog]
--GO

