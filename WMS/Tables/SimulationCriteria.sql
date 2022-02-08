CREATE TABLE [dbo].[SimulationCriteria]
(
[FunctionID] [int] NOT NULL CONSTRAINT [DF_SimulationCriteria_FunctionID] DEFAULT ((0)),
[NoOfUser] [int] NOT NULL CONSTRAINT [DF_SimulationCriteria_NoOfUser] DEFAULT ((0)),
[NoOfOrderPerUser] [int] NOT NULL CONSTRAINT [DF_SimulationCriteria_NoOfOrderPerUser] DEFAULT ((0)),
[UserRangeFrom] [int] NOT NULL CONSTRAINT [DF_SimulationCriteria_UserRangeFrom] DEFAULT ((0)),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SimulationCriteria_StorerKey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SimulationCriteria_Facility] DEFAULT (''),
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SimulationCriteria_MBOLKey] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SimulationCriteria_LoadKey] DEFAULT (''),
[Status] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SimulationCriteria_Status] DEFAULT ('0'),
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[AddDate] [datetime] NULL CONSTRAINT [DF_SimulationCriteria_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SimulationCriteria_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_SimulationCriteria_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SimulationCriteria_EditWho] DEFAULT (suser_sname()),
[LoginID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SimulationCriteria_LoginID] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SimulationCriteria] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[SimulationCriteria] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[SimulationCriteria] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[SimulationCriteria] TO [NSQL]
GO
