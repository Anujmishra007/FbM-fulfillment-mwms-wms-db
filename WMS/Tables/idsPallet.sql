CREATE TABLE [dbo].[idsPallet]
(
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[uom] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[packkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[batchno] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[productiondate] [datetime] NOT NULL,
[clearingdate] [datetime] NULL,
[printed] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_idsPallet_printed] DEFAULT ('N'),
[addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_idsPallet_addwho] DEFAULT (suser_sname()),
[adddate] [datetime] NOT NULL CONSTRAINT [DF_idsPallet_adddate] DEFAULT (getdate()),
[editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_idsPallet_editwho] DEFAULT (suser_sname()),
[editdate] [datetime] NOT NULL CONSTRAINT [DF_idsPallet_editdate] DEFAULT (getdate()),
[SYSID] [int] NULL,
[lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_idsPallet_lottable01] DEFAULT (' '),
[lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_idsPallet_lottable03] DEFAULT (' ')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/* 17-Mar-2009  TLTING     Change user_name() to SUSER_SNAME()          */

CREATE TRIGGER [dbo].[ntrIdsPalletAdd]
 ON  [dbo].[idsPallet]
 FOR INSERT
 AS
 BEGIN
    SET NOCOUNT ON
    SET ANSI_NULLS OFF 
    SET QUOTED_IDENTIFIER OFF
 	SET CONCAT_NULL_YIELDS_NULL OFF
 	
 	DECLARE
 	@b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
 	,         @n_err                int       -- Error number returned by stored procedure or this trigger
 	,         @n_err2 int              -- For Additional Error Detection
 	,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
 	,         @n_continue int                 
 	,         @n_starttcnt int                -- Holds the current transaction count
 	,         @c_preprocess NVARCHAR(250)         -- preprocess
 	,         @c_pstprocess NVARCHAR(250)         -- post process
 	,         @n_cnt int                  
 	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
 	     /* #INCLUDE <TRAHA1.SQL> */  
 	
 	IF @n_continue=1 or @n_continue=2
 	BEGIN
 		UPDATE idsPallet SET AddDate = GETDATE(), AddWho=SUSER_SNAME(), EditDate = GETDATE(), EditWho=SUSER_SNAME() 
 		FROM idsPallet, inserted
 		WHERE idsPallet.id = inserted.id
 		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 		IF @n_err <> 0
 		BEGIN
 			SELECT @n_continue = 3
 			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=66700   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert Failed On Table idsPallet. (nspidsPalletAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 		END
 	END
 	
 	     /* #INCLUDE <TRAHA2.SQL> */
 	IF @n_continue=3  -- Error Occured - Process And Return
 	BEGIN
 		IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
 		BEGIN
 			ROLLBACK TRAN
 		END
 		ELSE
 		BEGIN
 			WHILE @@TRANCOUNT > @n_starttcnt
 			BEGIN
 				COMMIT TRAN
 			END
 		END
 		execute nsp_logerror @n_err, @c_errmsg, "ntridsPalletAdd"
 		RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
 		RETURN
 	END
 	ELSE
 	BEGIN
 		WHILE @@TRANCOUNT > @n_starttcnt
 		BEGIN
 			COMMIT TRAN
 		END
 		RETURN
 	END
 END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/* 17-Mar-2009  TLTING     Change user_name() to SUSER_SNAME()          */
/* 28-Oct-2013  TLTING    Review Editdate column update                 */

CREATE TRIGGER [dbo].[ntrIdsPalletUpdate]
 ON  [dbo].[idsPallet]
 FOR UPDATE
 AS
 BEGIN
 IF @@ROWCOUNT = 0
 BEGIN
 RETURN
 END    
    SET NOCOUNT ON
    SET ANSI_NULLS OFF 
    SET QUOTED_IDENTIFIER OFF
    SET CONCAT_NULL_YIELDS_NULL OFF
 	
 	DECLARE
 	@b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
 	,         @n_err                int       -- Error number returned by stored procedure or this trigger
 	,         @n_err2 int              -- For Additional Error Detection
 	,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
 	,         @n_continue int                 
 	,         @n_starttcnt int                -- Holds the current transaction count
 	,         @c_preprocess NVARCHAR(250)         -- preprocess
 	,         @c_pstprocess NVARCHAR(250)         -- post process
 	,         @n_cnt int                  
 	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
 	     /* #INCLUDE <TRAHA1.SQL> */  
 	
 	IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
 	BEGIN
 		UPDATE idsPallet with (ROWLOCK)
 		SET AddDate = GETDATE(), AddWho=SUSER_SNAME(), EditDate = GETDATE(), EditWho=SUSER_SNAME() 
 		FROM idsPallet, inserted
 		WHERE idsPallet.id = inserted.id
 		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 		IF @n_err <> 0
 		BEGIN
 			SELECT @n_continue = 3
 			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=66700   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table idsPallet. (nspidsPalletAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 		END
 	END
 	
 	     /* #INCLUDE <TRAHA2.SQL> */
 	IF @n_continue=3  -- Error Occured - Process And Return
 	BEGIN
 		IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
 		BEGIN
 			ROLLBACK TRAN
 		END
 		ELSE
 		BEGIN
 			WHILE @@TRANCOUNT > @n_starttcnt
 			BEGIN
 				COMMIT TRAN
 			END
 		END
 		execute nsp_logerror @n_err, @c_errmsg, "ntridsPalletUpdate"
 		RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
 		RETURN
 	END
 	ELSE
 	BEGIN
 		WHILE @@TRANCOUNT > @n_starttcnt
 		BEGIN
 			COMMIT TRAN
 		END
 		RETURN
 	END
 END

GO
CREATE NONCLUSTERED INDEX [IX_idsPallet_sku] ON [dbo].[idsPallet] ([SKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[idsPallet] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[idsPallet] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[idsPallet] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[idsPallet] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'packkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of production.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'productiondate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying system. ', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'SYSID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'uom'
GO
