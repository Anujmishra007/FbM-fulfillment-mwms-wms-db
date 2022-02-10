CREATE TABLE [dbo].[CLPDETAIL]
(
[CLPOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CLPOrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[POKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[POLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[CaseId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CLPDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CLPDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CLPDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CLPDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CLPDETAIL] ADD CONSTRAINT [PKCLPDETAIL] PRIMARY KEY CLUSTERED ([CLPOrderKey], [CLPOrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CLPDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_CLPDETAIL_PODETAIL_01] FOREIGN KEY ([POKey], [POLineNumber]) REFERENCES [dbo].[PODETAIL] ([POKey], [POLineNumber])
GO
GRANT DELETE ON  [dbo].[CLPDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CLPDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CLPDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CLPDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CLPDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CLPDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Case.', 'SCHEMA', N'dbo', 'TABLE', N'CLPDETAIL', 'COLUMN', N'CaseId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying CLP order.', 'SCHEMA', N'dbo', 'TABLE', N'CLPDETAIL', 'COLUMN', N'CLPOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CLPDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CLPDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the purchase order.', 'SCHEMA', N'dbo', 'TABLE', N'CLPDETAIL', 'COLUMN', N'POKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'CLPDETAIL', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CLPDETAIL', 'COLUMN', N'TrafficCop'
GO
