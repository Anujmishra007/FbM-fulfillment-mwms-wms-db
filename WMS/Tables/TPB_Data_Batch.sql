CREATE TABLE [dbo].[TPB_Data_Batch]
(
[Batch_Key] [int] NOT NULL IDENTITY(1, 1),
[Adddate] [datetime] NULL CONSTRAINT [DF_TPB_Data_Batch_ADDDate] DEFAULT (getdate()),
[Status] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TPB_Data_Batch_Status] DEFAULT ('W'),
[Batch_RecRow] [bigint] NOT NULL CONSTRAINT [DF_TPB_Data_Batch_Batch_RecRow] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPB_Data_Batch] ADD CONSTRAINT [PK__TPB_Data__4B769EB7D9EFA2C9] PRIMARY KEY CLUSTERED ([Batch_Key]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TPB_Data_Batch_01] ON [dbo].[TPB_Data_Batch] ([Batch_Key], [Status]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TPB_Data_Batch] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TPB_Data_Batch] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TPB_Data_Batch] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TPB_Data_Batch] TO [NSQL]
GO
