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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 28-Oct-2013  TLTING    1.1     Review Editdate column update         */

CREATE TRIGGER [dbo].[ntrC4recEXPUpdate]
 ON  [dbo].[C4_Rec_Exp]
 FOR UPDATE
 AS
 BEGIN
 	IF @@ROWCOUNT = 0
 	BEGIN
 		RETURN
 	END 
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

 	DECLARE @n_err int, @n_cnt int, @n_continue int, @c_errmsg NVARCHAR(250)
 	
 	IF NOT UPDATE(EditDate)
 	BEGIN
 	   UPDATE c4_rec_exp 
    	   SET EditDate = GETDATE()
       	       
           FROM C4_rec_exp, INSERTED
          WHERE C4_REC_Exp.DOcumentkey = INSERTED.DOcumentkey
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 	   IF @n_err <> 0
    	BEGIN
       		SELECT @n_continue = 3
       		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72804   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       		SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table C4_REC_EXP. (ntrC4RECEXPUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
    	END
   END
 END

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
