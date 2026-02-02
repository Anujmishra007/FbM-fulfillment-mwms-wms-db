IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[RDTUser]') AND type in (N'U'))
BEGIN
   CREATE TABLE [RDT].[RDTUser]
   (
   [UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
   [Password] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
   [FullName] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
   [DefaultStorer] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
   [DefaultFacility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
   [DefaultLangCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
   [DefaultMenu] [int] NULL,
   [DefaultUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
   [LastLogin] [datetime] NULL CONSTRAINT [DF_RDTUser_LastLogin] DEFAULT (getdate()),
   [MultiLogin] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUser_MultiLogin] DEFAULT ('Y'),
   [DefaultPrinter] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
   [MobileNo_Display] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUSER_MobileNo_Display] DEFAULT ('Y'),
   [Date_Format] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUSER_Date_Format] DEFAULT (' '),
   [SQLUserAddDate] [datetime] NULL,
   [DefaultPrinter_Paper] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
   [Active] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUSER_Active] DEFAULT ('1'),
   [DefaultLightColor] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUser_DefaultLightColor] DEFAULT (''),
   [DefaultStorerGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTUSER_DefaultStorerGroup] DEFAULT (''),
   [VoiceProfileNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
   [DefaultDeviceID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtUser_DefaultDeviceID] DEFAULT (''),
   [AreaKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTUSER_AreaKey] DEFAULT (''),
   [OPSPosition] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtuser_OPSPosition] DEFAULT (''),
   [AllowResumeSession] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUser_AllowResumeSession] DEFAULT (''),
   [SCEPrinterGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTUser_SCEPrinterGroup] DEFAULT (''),
   [ScreenFormat] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTUser_ScreenFormat]  DEFAULT (''),
   [SoundLevel] NVARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTUser_SoundLevel] DEFAULT(''),
   [VibrationLevel] NVARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTUser_VibrationLevel]  DEFAULT (''),
   [FirstDayOfWeek] [tinyint] NULL CONSTRAINT [CK_RDTUser_FirstDayOfWeek] CHECK  (([FirstDayOfWeek]=(1) OR [FirstDayOfWeek]=(7) OR [FirstDayOfWeek]=NULL)),
   [ModulesDirectAccess] [nvarchar](1) NULL

   ) ON [PRIMARY]

   ALTER TABLE [RDT].[RDTUser] ADD CONSTRAINT [PK_RDTUser] PRIMARY KEY CLUSTERED ([UserName]) WITH (FILLFACTOR=90) ON [PRIMARY]
   GRANT DELETE ON  [RDT].[RDTUser] TO [NSQL]
   GRANT INSERT ON  [RDT].[RDTUser] TO [NSQL]
   GRANT SELECT ON  [RDT].[RDTUser] TO [NSQL]
   GRANT UPDATE ON  [RDT].[RDTUser] TO [NSQL]



 IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTUser', N'COLUMN',N'AllowResumeSession'))
   EXEC sp_addextendedproperty N'MS_Description', N'Allow/Disallow Resume RDT User Session', 'SCHEMA', N'RDT', 'TABLE', N'RDTUser', 'COLUMN', N'AllowResumeSession'


IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTUser', N'COLUMN',N'AreaKey'))
   EXEC sp_addextendedproperty N'MS_Description', N'Store AreaKey Value', 'SCHEMA', N'RDT', 'TABLE', N'RDTUser', 'COLUMN', N'AreaKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTUser', N'COLUMN',N'DefaultDeviceID'))
   EXEC sp_addextendedproperty N'MS_Description', N'User Default Device ID', 'SCHEMA', N'RDT', 'TABLE', N'RDTUser', 'COLUMN', N'DefaultDeviceID'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTUser', N'COLUMN',N'OPSPosition'))
   EXEC sp_addextendedproperty N'MS_Description', N'Operation Position', 'SCHEMA', N'RDT', 'TABLE', N'RDTUser', 'COLUMN', N'OPSPosition'


 IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTUser', N'COLUMN',N'FirstDayOfWeek'))
  EXEC sp_addextendedproperty N'MS_Description', N'First Day of the Week', 'SCHEMA', N'RDT', 'TABLE', N'RDTUser', 'COLUMN', N'FirstDayOfWeek'


 IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'RDTUser', N'COLUMN',N'ModulesDirectAccess'))
  EXEC sp_addextendedproperty N'MS_Description', N'ModulesDirectAccess', 'SCHEMA', N'RDT', 'TABLE', N'RDTUser', 'COLUMN', N'ModulesDirectAccess'

END
ELSE
BEGIN
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'Password' AND Object_ID = Object_ID('RDT.RDTUser'))
			BEGIN

			 ALTER TABLE RDT.RDTUser ALTER COLUMN Password NVARCHAR(32) NOT NULL
				
			END
END

BEGIN


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'FirstDayOfWeek' AND Object_ID = Object_ID('RDT.RDTUser'))
			BEGIN

				ALTER TABLE [RDT].[RDTUser] ADD [FirstDayOfWeek] [tinyint] NULL CONSTRAINT [CK_RDTUser_FirstDayOfWeek] CHECK  (([FirstDayOfWeek]=(1) OR [FirstDayOfWeek]=(7) OR [FirstDayOfWeek]=NULL));
			    EXEC sp_addextendedproperty N'MS_Description', N'First Day of the Week', 'SCHEMA', N'RDT', 'TABLE', N'RDTUser', 'COLUMN', N'FirstDayOfWeek'

				
			END

END

BEGIN

		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'ModulesDirectAccess' AND Object_ID = Object_ID('RDT.RDTUser'))
			BEGIN

				ALTER TABLE [RDT].[RDTUser] ADD [ModulesDirectAccess] [nvarchar](1) NULL;
				EXEC sp_addextendedproperty N'MS_Description', N'ModulesDirectAccess', 'SCHEMA', N'RDT', 'TABLE', N'RDTUser', 'COLUMN', N'ModulesDirectAccess'
				
			END

END
--FCR-3926
IF NOT EXISTS (SELECT 1 FROM sys.columns 
            WHERE object_id = OBJECT_ID('RDT.RDTUser') AND name = 'DisableResumePrompt')
BEGIN
   ALTER TABLE RDT.RDTUser ADD DisableResumePrompt NVARCHAR(1) NULL
END



--ALTER COLUMN
IF EXISTS( SELECT 1 
				FROM SYS.columns WHERE NAME ='ScreenFormat' AND Object_ID = OBJECT_ID('RDT.RDTUser') AND  max_length <> 80)
BEGIN
   ALTER TABLE RDT.RDTUser 
   ALTER COLUMN  [ScreenFormat] [nvarchar](40) NOT NULL;
END
