CREATE TABLE [RDT].[rdtPreReceiveSort_DELLOG](
	[Rowref] [int] IDENTITY(1,1) NOT NULL,
	[RowRefSource] [int] NOT NULL,
	[Mobile] [int] NOT NULL,
	[Status] [nvarchar](1) NOT NULL,
	[AddDate] [datetime] NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[ArchiveCop] [nvarchar](1) NULL,
 CONSTRAINT [PK_rdtPreReceiveSort_DELLOG] PRIMARY KEY CLUSTERED 
(
	[Rowref] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [RDT].[rdtPreReceiveSort_DELLOG] ADD  CONSTRAINT [DF_rdtPreReceiveSort_DELLOG_Status]  DEFAULT ('0') FOR [Status]
GO

ALTER TABLE [RDT].[rdtPreReceiveSort_DELLOG] ADD  CONSTRAINT [DF_rdtPreReceiveSort_DELLOG_AddDate]  DEFAULT (getdate()) FOR [AddDate]
GO

ALTER TABLE [RDT].[rdtPreReceiveSort_DELLOG] ADD  CONSTRAINT [DF_rdtPreReceiveSort_DELLOG_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
GO


GRANT DELETE ON  [RDT].[rdtPreReceiveSort_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPreReceiveSort_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPreReceiveSort_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPreReceiveSort_DELLOG] TO [NSQL]
GO
