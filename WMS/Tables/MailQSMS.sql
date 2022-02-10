CREATE TABLE [dbo].[MailQSMS]
(
[Qid] [int] NOT NULL IDENTITY(1, 1),
[mail_id] [int] NULL,
[UniqueKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_MailQSMS_UniqueKey] DEFAULT (''),
[UniqueKeyName] [nvarchar] (255) NOT NULL CONSTRAINT [DF_MailQSMS_UniqueKeyName] DEFAULT (''),
[StorerKey] [nvarchar] (20) NOT NULL CONSTRAINT [DF_MailQSMS_StorerKey] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_MailQSMS_AddDate] DEFAULT (getdate()),
[AddWho] [sys].[sysname] NOT NULL CONSTRAINT [DF_MailQSMS_AddWho] DEFAULT (suser_sname()),
[AddSource] [nvarchar] (128) NOT NULL CONSTRAINT [DF_MailQSMS_AddSource] DEFAULT (isnull(object_name(@@procid),'')),
[R01Name] [nvarchar] (128) NULL CONSTRAINT [DF_MailQSMS_R01Name] DEFAULT (''),
[R01] [nvarchar] (1000) NOT NULL CONSTRAINT [DF_MailQSMS_R01] DEFAULT (''),
[R02Name] [nvarchar] (128) NOT NULL CONSTRAINT [DF_MailQSMS_R02Name] DEFAULT (''),
[R02] [nvarchar] (1000) NOT NULL CONSTRAINT [DF_MailQSMS_R02] DEFAULT (''),
[R03Name] [nvarchar] (128) NOT NULL CONSTRAINT [DF_MailQSMS_R03Name] DEFAULT (''),
[R03] [nvarchar] (1000) NOT NULL CONSTRAINT [DF_MailQSMS_R03] DEFAULT (''),
[R04Name] [nvarchar] (128) NOT NULL CONSTRAINT [DF_MailQSMS_R04Name] DEFAULT (''),
[R04] [nvarchar] (1000) NOT NULL CONSTRAINT [DF_MailQSMS_R04] DEFAULT (''),
[R05Name] [nvarchar] (128) NOT NULL CONSTRAINT [DF_MailQSMS_R05Name] DEFAULT (''),
[R05] [nvarchar] (1000) NOT NULL CONSTRAINT [DF_MailQSMS_R05] DEFAULT (''),
[R06Name] [nvarchar] (128) NOT NULL CONSTRAINT [DF_MailQSMS_R06Name] DEFAULT (''),
[R06] [nvarchar] (1000) NOT NULL CONSTRAINT [DF_MailQSMS_R06] DEFAULT (''),
[R07Name] [nvarchar] (128) NOT NULL CONSTRAINT [DF_MailQSMS_R07Name] DEFAULT (''),
[R07] [nvarchar] (1000) NOT NULL CONSTRAINT [DF_MailQSMS_R07] DEFAULT (''),
[R08Name] [nvarchar] (128) NOT NULL CONSTRAINT [DF_MailQSMS_R08Name] DEFAULT (''),
[R08] [nvarchar] (1000) NOT NULL CONSTRAINT [DF_MailQSMS_R08] DEFAULT (''),
[R09Name] [nvarchar] (128) NOT NULL CONSTRAINT [DF_MailQSMS_R09Name] DEFAULT (''),
[R09] [nvarchar] (1000) NOT NULL CONSTRAINT [DF_MailQSMS_R09] DEFAULT (''),
[R10Name] [nvarchar] (128) NOT NULL CONSTRAINT [DF_MailQSMS_R10Name] DEFAULT (''),
[R10] [nvarchar] (1000) NOT NULL CONSTRAINT [DF_MailQSMS_R10] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MailQSMS] ADD CONSTRAINT [MailQSMS_mail_id_MustBeUnique] PRIMARY KEY CLUSTERED ([Qid]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MailQSMS] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[MailQSMS] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[MailQSMS] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[MailQSMS] TO [NSQL]
GO
