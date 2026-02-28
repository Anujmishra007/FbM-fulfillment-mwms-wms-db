
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[RDTDynamicPickLog_DELLOG]') AND type in (N'U'))
BEGIN

CREATE TABLE [RDT].[rdtDynamicPickLog_DELLOG](
	[Rowref] [int] IDENTITY(1,1) NOT NULL,
	[RowRefSource] [int] NOT NULL,
	[Status] [nvarchar](1) NOT NULL CONSTRAINT [DF_rdtDynamicPickLog_DELLOG_Status]  DEFAULT ((0)),
	[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtDynamicPickLog_DELLOG_AddDate]  DEFAULT (getdate()),
	[AddWho] [nvarchar](128) NOT NULL CONSTRAINT [DF_rdtDynamicPickLog_DELLOG_AddWho]  DEFAULT (suser_sname()),
	[ArchiveCop] [nvarchar](1) NULL,
 CONSTRAINT [PK_rdtDynamicPickLog_DELLOG] PRIMARY KEY CLUSTERED 
(
	[Rowref] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END


ELSE
BEGIN 

			 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'RowRefSource' AND Object_ID = Object_ID('RDT.rdtDynamicPickLog_DELLOG'))
			BEGIN

				ALTER TABLE [RDT].[rdtDynamicPickLog_DELLOG] ADD RowRefSource [int] NOT NULL;
				EXEC sp_addextendedproperty N'MS_Description', 'RowRefSource', 'SCHEMA', N'RDT', 'TABLE', N'rdtDynamicPickLog_DELLOG', 'COLUMN', N'RowRefSource'
				
			END

			 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'Status' AND Object_ID = Object_ID('RDT.rdtDynamicPickLog_DELLOG'))
			BEGIN

				ALTER TABLE [RDT].[rdtDynamicPickLog_DELLOG] ADD Status [nvarchar](1) NOT NULL CONSTRAINT [DF_rdtDynamicPickLog_DELLOG_Status]  DEFAULT ((0));
				EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'RDT', 'TABLE', N'rdtDynamicPickLog_DELLOG', 'COLUMN', N'Status'
				
			END



			 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'ArchiveCop' AND Object_ID = Object_ID('RDT.rdtDynamicPickLog_DELLOG'))
			BEGIN

				ALTER TABLE [RDT].[rdtDynamicPickLog_DELLOG] ADD ArchiveCop [nvarchar](1) NULL;
				EXEC sp_addextendedproperty N'MS_Description', 'ArchiveCop', 'SCHEMA', N'RDT', 'TABLE', N'rdtDynamicPickLog_DELLOG', 'COLUMN', N'ArchiveCop'
				
			END

END


