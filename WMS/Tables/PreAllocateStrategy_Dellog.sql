IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.tables WHERE TABLE_NAME = 'PreAllocateStrategy_Dellog' AND TABLE_SCHEMA = 'dbo' )
BEGIN
CREATE TABLE [dbo].[PreAllocateStrategy_DELLOG](
	[Rowref] [int] IDENTITY(1,1) NOT NULL,
	[PreAllocateStrategyKey] [nvarchar](10) NOT NULL,
	[Status] [nvarchar](1) NOT NULL,
	[AddDate] [datetime] NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[ArchiveCop] [nvarchar](1) NULL,
   CONSTRAINT PK_PreAllocateStrategy_Dellog PRIMARY KEY CLUSTERED 
(
	[Rowref] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [dbo].[PreAllocateStrategy_DELLOG] ADD  CONSTRAINT [DF_PreAllocateStrategy_DELLOG_Status]  DEFAULT ('0') FOR [Status]

ALTER TABLE [dbo].[PreAllocateStrategy_DELLOG] ADD  CONSTRAINT [DF_PreAllocateStrategy_DELLOG_AddDate]  DEFAULT (getdate()) FOR [AddDate]


ALTER TABLE [dbo].[PreAllocateStrategy_DELLOG] ADD  CONSTRAINT [DF_PreAllocateStrategy_DELLOG_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]

END

