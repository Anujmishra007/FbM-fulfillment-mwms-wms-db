IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WCSTran]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[WCSTran]
(
[MessageID] [int] NOT NULL IDENTITY(1, 1),
[MessageName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageNum] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_MessageNum] DEFAULT (''),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_TaskDetailKey] DEFAULT (''),
[WCSMessageID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_WCSMessageID] DEFAULT (''),
[OrigMessageID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_OrigMessageID] DEFAULT (''),
[PalletID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_FromLoc] DEFAULT (''),
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ToLoc] DEFAULT (''),
[Priority] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Priority] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Status] DEFAULT (''),
[ReasonCode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ReasonCode] DEFAULT (''),
[ErrMsg] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ErrMsg] DEFAULT (''),
[UD1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_UD1] DEFAULT (''),
[UD2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_UD2] DEFAULT (''),
[UD3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_UD3] DEFAULT (''),
[UD4] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_UD4] DEFAULT (''),
[UD5] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_UD5] DEFAULT (''),
[ImgFolderPath] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ImgFolderPath] DEFAULT (''),
[ImgFileName1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ImgFileName1] DEFAULT (''),
[ImgFileName2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ImgFileName2] DEFAULT (''),
[ImgFileName3] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ImgFileName3] DEFAULT (''),
[ImgFileName4] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ImgFileName4] DEFAULT (''),
[ImgFileName5] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ImgFileName5] DEFAULT (''),
[Param1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param1] DEFAULT (''),
[Param2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param2] DEFAULT (''),
[Param3] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param3] DEFAULT (''),
[Param4] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param4] DEFAULT (''),
[Param5] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param5] DEFAULT (''),
[Param6] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param6] DEFAULT (''),
[Param7] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param7] DEFAULT (''),
[Param8] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param8] DEFAULT (''),
[Param9] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param9] DEFAULT (''),
[Param10] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param10] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_WCSTran_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WCSTran_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]

ALTER TABLE [dbo].[WCSTran] ADD CONSTRAINT [PK_WCSTran] PRIMARY KEY CLUSTERED ([MessageID]) ON [PRIMARY]

GRANT DELETE ON  [dbo].[WCSTran] TO [NSQL]

GRANT INSERT ON  [dbo].[WCSTran] TO [NSQL]

GRANT SELECT ON  [dbo].[WCSTran] TO [NSQL]

GRANT UPDATE ON  [dbo].[WCSTran] TO [NSQL]

END

ELSE 
BEGIN

--ALTER COLUMN 
	IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='Param1' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [Param1] [nvarchar] (100) NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='Param2' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [Param2] [nvarchar] (100) NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='Param3' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [Param3] [nvarchar] (100) NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='Param4' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [Param4] [nvarchar] (100) NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='Param5' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [Param5] [nvarchar] (100) NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='Param6' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [Param6] [nvarchar] (100) NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='Param7' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [Param7] [nvarchar] (100) NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='Param8' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [Param8] [nvarchar] (100) NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='Param9' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [Param9] [nvarchar] (100) NULL;

	END


		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='Param10' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [Param10] [nvarchar] (100) NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='ErrMsg' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>1000)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [ErrMsg] [nvarchar] (500) NULL ;


	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='MessageName' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [MessageName] [nvarchar] (100) NOT NULL;



	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='MessageNum' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [MessageNum] [nvarchar] (100) NULL;



	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='MessageType' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>100)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [MessageType] [nvarchar] (50) NOT NULL;


	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='OrigMessageID' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [OrigMessageID] [nvarchar] (100)  NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='ReasonCode' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [ReasonCode] [nvarchar] (100)  NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='UD1' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>100)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [UD1] [nvarchar] (50)  NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='UD2' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>100)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [UD2] [nvarchar] (50)  NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='UD3' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>100)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [UD3] [nvarchar] (50)  NULL;

	END

	   

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='UD4' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>100)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [UD4] [nvarchar] (50)  NULL;

	END



		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='UD5' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>100)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [UD5] [nvarchar] (50)  NULL;

	END

		IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name ='WCSMessageID' AND Object_ID = Object_ID('[dbo].[WCSTran]') AND max_length <>200)
	BEGIN

	ALTER TABLE [dbo].[WCSTran]
	ALTER COLUMN [WCSMessageID] [nvarchar] (100)  NULL;

	END


END

