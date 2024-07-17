SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sysObjects WHERE [name] = 'CBOL_DELLOG')
BEGIN
   CREATE TABLE [dbo].[CBOL_DELLOG](
      [Rowref] [INT] IDENTITY(1,1) NOT NULL,
      [CbolKey] [NVARCHAR](10) NOT NULL,
      [Status] [NVARCHAR](1) NOT NULL,
      [AddDate] [DATETIME] NOT NULL,
      [AddWho] [NVARCHAR](128) NOT NULL,
      [ArchiveCop] [NVARCHAR](1) NULL,
   PRIMARY KEY CLUSTERED 
   (
      [Rowref] ASC
   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
   ) ON [PRIMARY];
   
   ALTER TABLE [dbo].[CBOL_DELLOG] ADD  CONSTRAINT [DF_CBOL_DELLOG_Status]  DEFAULT ('0') FOR [Status];
   
   ALTER TABLE [dbo].[CBOL_DELLOG] ADD  CONSTRAINT [DF_CBOL_DELLOG_AddDate]  DEFAULT (GETDATE()) FOR [AddDate];
   
   ALTER TABLE [dbo].[CBOL_DELLOG] ADD  CONSTRAINT [DF_CBOL_DELLOG_AddWho]  DEFAULT (SUSER_SNAME()) FOR [AddWho];

   EXEC sp_addextendedproperty N'MS_Description', N'CBOL Delete Log', 'SCHEMA', N'dbo', 'TABLE', N'CBOL_DELLOG', NULL, NULL;

   EXEC sp_addextendedproperty N'MS_Description', N'Unique running number', 'SCHEMA', N'dbo', 'TABLE', N'CBOL_DELLOG', 'COLUMN', N'Rowref';

   EXEC sp_addextendedproperty N'MS_Description', N'CbolKey', 'SCHEMA', N'dbo', 'TABLE', N'CBOL_DELLOG', 'COLUMN', N'CbolKey';

   EXEC sp_addextendedproperty N'MS_Description', N'Status', 'SCHEMA', N'dbo', 'TABLE', N'CBOL_DELLOG', 'COLUMN', N'Status';
   
   EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CBOL_DELLOG', 'COLUMN', N'AddWho';

   EXEC sp_addextendedproperty N'MS_Description', N'The date in which the record is created', 'SCHEMA', N'dbo', 'TABLE', N'CBOL_DELLOG', 'COLUMN', N'AddDate';
END


