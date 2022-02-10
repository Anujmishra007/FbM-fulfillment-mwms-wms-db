CREATE TABLE [dbo].[UploadinvData]
(
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternOrderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Invoice_Number] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Invoice_Date] [datetime] NULL,
[Invoice_Amount] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadinvData_Status] DEFAULT ('0'),
[Remarks] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UploadinvData] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UploadinvData] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UploadinvData] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UploadinvData] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'UploadinvData', 'COLUMN', N'ExternOrderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying the Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'UploadinvData', 'COLUMN', N'Invoice_Number'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'UploadinvData', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'UploadinvData', 'COLUMN', N'Storerkey'
GO
