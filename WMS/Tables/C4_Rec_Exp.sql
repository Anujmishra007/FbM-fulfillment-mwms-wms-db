CREATE TABLE [dbo].[C4_Rec_Exp]
(
[Messageh] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageDate] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rev_Date] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PO_Number] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Buyer] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_C4_Rec_Exp_Buyer] DEFAULT ('888'),
[SupplyCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Head] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_C4_Rec_Exp_Head] DEFAULT ('900'),
[Line] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NULL CONSTRAINT [DF_C4_Rec_Exp_Qty] DEFAULT ('0'),
[Best_Before_Date] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_C4_Rec_Exp_Status] DEFAULT ('0'),
[Documentkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Adddate] [datetime] NULL CONSTRAINT [DF_C4_Rec_Exp_Adddate] DEFAULT (getdate()),
[EditDate] [datetime] NULL CONSTRAINT [DF_C4_Rec_Exp_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[C4_Rec_Exp] ADD CONSTRAINT [PK_C4_Rec_Exp] PRIMARY KEY CLUSTERED ([Documentkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[C4_Rec_Exp] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[C4_Rec_Exp] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[C4_Rec_Exp] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[C4_Rec_Exp] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'C4_Rec_Exp', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the buyer.', 'SCHEMA', N'dbo', 'TABLE', N'C4_Rec_Exp', 'COLUMN', N'Buyer'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying document.', 'SCHEMA', N'dbo', 'TABLE', N'C4_Rec_Exp', 'COLUMN', N'Documentkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'C4_Rec_Exp', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying purchase orders.', 'SCHEMA', N'dbo', 'TABLE', N'C4_Rec_Exp', 'COLUMN', N'PO_Number'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'C4_Rec_Exp', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying supply.', 'SCHEMA', N'dbo', 'TABLE', N'C4_Rec_Exp', 'COLUMN', N'SupplyCode'
GO
