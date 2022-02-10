CREATE TABLE [dbo].[SKULog]
(
[Person] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKULog_Person] DEFAULT (suser_sname()),
[ActionTime] [datetime] NOT NULL CONSTRAINT [DF_SKULog_ActionTime] DEFAULT (getdate()),
[ActionDescr] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKULog_ActionDescr] DEFAULT (' ')
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SKULog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[SKULog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[SKULog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[SKULog] TO [NSQL]
GO
