IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MailQDet]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[MailQDet]
(
[QDetid] [int] NOT NULL IDENTITY(1, 1),
[Qid] [int] NULL,
[C01] [nvarchar] (1000) NOT NULL,
[C02] [nvarchar] (1000) NOT NULL,
[C03] [nvarchar] (1000) NOT NULL,
[C04] [nvarchar] (1000) NOT NULL,
[C05] [nvarchar] (1000) NOT NULL,
[C06] [nvarchar] (1000) NOT NULL,
[C07] [nvarchar] (1000) NOT NULL,
[C08] [nvarchar] (1000) NOT NULL,
[C09] [nvarchar] (1000) NOT NULL,
[C10] [nvarchar] (1000) NOT NULL,
[C11] [nvarchar] (1000) NOT NULL,
[C12] [nvarchar] (1000) NOT NULL,
[C13] [nvarchar] (1000) NOT NULL,
[C14] [nvarchar] (1000) NOT NULL,
[C15] [nvarchar] (1000) NOT NULL,
[OrderKey] [nvarchar] (50) NULL,
[ArchiveCop] [nvarchar] (1) NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_MailQDet_AddDate] DEFAULT (getdate())
) ON [PRIMARY]

ALTER TABLE [dbo].[MailQDet] ADD CONSTRAINT [QDetid_MustBeUnique] PRIMARY KEY CLUSTERED ([QDetid]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_MailQDet_OrderKey] ON [dbo].[MailQDet] ([OrderKey]) ON [PRIMARY]

ALTER TABLE [dbo].[MailQDet] ADD CONSTRAINT [FK_MailQDet_MailQ] FOREIGN KEY ([Qid]) REFERENCES [dbo].[MailQDet] ([Qid])

GRANT DELETE ON  [dbo].[MailQDet] TO [NSQL]

GRANT INSERT ON  [dbo].[MailQDet] TO [NSQL]

GRANT SELECT ON  [dbo].[MailQDet] TO [NSQL]

GRANT UPDATE ON  [dbo].[MailQDet] TO [NSQL]

END

ELSE
BEGIN

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'ArchiveCop' AND Object_ID = Object_ID('dbo.MailQDet'))
BEGIN
	ALTER TABLE dbo.[MailQDet] ADD [ArchiveCop] [nvarchar] (1) NULL;
	EXEC sp_addextendedproperty N'MS_Description', 'ArchiveCop', 'SCHEMA', N'dbo', 'TABLE', N'MailQDet', 'COLUMN', N'ArchiveCop'
				
END


END