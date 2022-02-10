CREATE TABLE [dbo].[idsStkTrfDoc]
(
[STDNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TruckNo] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DriverName] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Finalized] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DestCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WHSEID] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrxType] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_idsStkTrfDoc_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_idsStkTrfDoc_AddWho] DEFAULT (suser_sname()),
[SourceID] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/* 17-Mar-2009  TLTING     Change user_name() to SUSER_SNAME()          */

CREATE TRIGGER [dbo].[ntridsStkTrfDocAdd]
 ON  [dbo].[idsStkTrfDoc]
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
 		UPDATE idsStkTrfDoc SET AddDate = GETDATE(), AddWho=SUSER_SNAME()
 		FROM idsStkTrfDoc, inserted
 		WHERE idsStkTrfDoc.stdno = inserted.stdno
 		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 		IF @n_err <> 0
 		BEGIN
 			SELECT @n_continue = 3
 			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=66700   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table idsStkTrfDoc. (nspidsStkTrfDocAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
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
 		execute nsp_logerror @n_err, @c_errmsg, "ntridsStkTrfDocAdd"
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

CREATE TRIGGER [dbo].[ntridsStkTrfDocdelete]
ON  [dbo].[idsStkTrfDoc]
FOR DELETE
AS
BEGIN
   SET NOCOUNT ON
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
		DELETE idsStkTrfDocDetail
		FROM   idsStkTrfDocDetail, Deleted 
		WHERE  idsStkTrfDocDetail.stdno = Deleted.stdno
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=66700   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Failed On Table idsStkTrfDocDetail. (nspidsStkTrfDocDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
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
		execute nsp_logerror @n_err, @c_errmsg, "ntridsStkTrfDocDelete"
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
ALTER TABLE [dbo].[idsStkTrfDoc] ADD CONSTRAINT [PK_idsStkTrfDoc] PRIMARY KEY CLUSTERED ([STDNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[idsStkTrfDoc] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[idsStkTrfDoc] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[idsStkTrfDoc] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[idsStkTrfDoc] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying destination.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'DestCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of delivery truck driver.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'DriverName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Reason.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Source.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'SourceID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number plate of delivery truck.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'TruckNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Warehouse.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'WHSEID'
GO
