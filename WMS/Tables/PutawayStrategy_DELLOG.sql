IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.tables WHERE TABLE_NAME = 'PutawayStrategy_DELLOG' AND TABLE_SCHEMA = 'dbo' )
BEGIN
CREATE TABLE [dbo].[PutawayStrategy_DELLOG](
	[Rowref] [int] IDENTITY(1,1) NOT NULL,
	[PutawayStrategyKey] [nvarchar](10) NOT NULL,
	[Status] [nvarchar](1) NOT NULL,
	[AddDate] [datetime] NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[ArchiveCop] [nvarchar](1) NULL,
   CONSTRAINT PK_PutawayStrategy_Dellog PRIMARY KEY CLUSTERED 
(
	[Rowref] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[PutawayStrategy_DELLOG] ADD  CONSTRAINT [DF_PutawayStrategy_DELLOG_Status]  DEFAULT ('0') FOR [Status]


ALTER TABLE [dbo].[PutawayStrategy_DELLOG] ADD  CONSTRAINT [DF_PutawayStrategy_DELLOG_AddDate]  DEFAULT (getdate()) FOR [AddDate]


ALTER TABLE [dbo].[PutawayStrategy_DELLOG] ADD  CONSTRAINT [DF_PutawayStrategy_DELLOG_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]

END