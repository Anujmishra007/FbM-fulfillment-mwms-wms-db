IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.tables WHERE TABLE_NAME = 'PreAllocateStrategyDetail_Dellog' AND TABLE_SCHEMA = 'dbo' )
BEGIN
CREATE TABLE [dbo].[PreAllocateStrategyDetail_DELLOG](
	[Rowref] [int] IDENTITY(1,1) NOT NULL,
	[PreAllocateStrategyKey] [nvarchar](10) NOT NULL,
   [PreAllocateStrategyLineNumber] [nvarchar](5) NOT NULL,
	[Status] [nvarchar](1) NOT NULL,
	[AddDate] [datetime] NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[ArchiveCop] [nvarchar](1) NULL,
   CONSTRAINT PK_PreAllocateStrategyDetail_Dellog PRIMARY KEY CLUSTERED 
(
	[Rowref] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [dbo].[PreAllocateStrategyDetail_DELLOG] ADD  CONSTRAINT [DF_PreAllocateStrategyDetail_DELLOG_Status]  DEFAULT ('0') FOR [Status]


ALTER TABLE [dbo].[PreAllocateStrategyDetail_DELLOG] ADD  CONSTRAINT [DF_PreAllocateStrategyDetail_DELLOG_AddDate]  DEFAULT (getdate()) FOR [AddDate]


ALTER TABLE [dbo].[PreAllocateStrategyDetail_DELLOG] ADD  CONSTRAINT [DF_PreAllocateStrategyDetail_DELLOG_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]

END


