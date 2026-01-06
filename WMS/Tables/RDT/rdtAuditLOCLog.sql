IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[rdtAuditLOCLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [RDT].[rdtAuditLOCLog](
	[RowRef] [int] IDENTITY(1,1) NOT NULL,
	[LOC] [nvarchar](10) NOT NULL,
	[StorerKey] [nvarchar](15) NOT NULL,
	[SKU] [nvarchar](20) NOT NULL,
	[QTY] [int] NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[AddDate] [datetime] NOT NULL,
	[ID] [nvarchar](18)  NULL,
	[UCCNo] [nvarchar](20)  NULL
	
 CONSTRAINT [PK_rdtAuditLOCLog] PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[DF_rdtAuditLOCLog_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtAuditLOCLog] ADD  CONSTRAINT [DF_rdtAuditLOCLog_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[DF_rdtAuditLOCLog_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtAuditLOCLog] ADD  CONSTRAINT [DF_rdtAuditLOCLog_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'rdtAuditLOCLog', NULL,NULL))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Temporary table use by RDT Audit LOC (FN653)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtAuditLOCLog'

END 

ELSE 
BEGIN

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'ID' AND Object_ID = Object_ID('RDT.rdtAuditLOCLog'))
BEGIN
	ALTER TABLE RDT.rdtAuditLOCLog
	ADD ID [nvarchar](18)  NULL CONSTRAINT [DF_rdtAuditLOCLog_ID]  DEFAULT ('');
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Temporary table use by RDT Audit LOC (FN653)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtAuditLOCLog', @level2type=N'COLUMN',@level2name=N'ID'
				
END


IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'UCCNo' AND Object_ID = Object_ID('RDT.rdtAuditLOCLog'))
BEGIN
	ALTER TABLE RDT.rdtAuditLOCLog
	ADD UCCNo [nvarchar](20)  NULL CONSTRAINT [DF_rdtAuditLOCLog_UCCNo]  DEFAULT ('');
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Temporary table use by RDT Audit LOC (FN653)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtAuditLOCLog', @level2type=N'COLUMN',@level2name=N'UCCNo'
				
END


--ALTER COLUMN 
IF EXISTS (SELECT * FROM sys.columns WHERE Name = 'AddWho' AND Object_ID = Object_ID('RDT.rdtAuditLOCLog') AND max_length <> 256)
BEGIN
	ALTER TABLE RDT.rdtAuditLOCLog
	ALTER COLUMN [AddWho] [nvarchar](128) NOT NULL;

	END

END
