SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [RDT].[RDTWatTeamLog_Dellog](
	[RowRef] [int] IDENTITY(1,1) NOT NULL,
	[RowRefSource] [int] NOT NULL, 
	[Status] [nvarchar](1) NOT NULL  constraint DF_rdtWATTeamLog_Dellog_Status default ('0'),
	[AddDate] datetime not null constraint DF_rdtWATTeamLog_Dellog_AddDate default (getdate()),
   	[AddWho] nvarchar(128) not null constraint DF_rdtWATTeamLog_Dellog_AddWho default (suser_name()),
	[ArchiveCop] nvarchar(1) NULL
 CONSTRAINT [PK_rdtWATTeamLog_Dellog] PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
