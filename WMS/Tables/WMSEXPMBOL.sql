CREATE TABLE [dbo].[WMSEXPMBOL]
(
[ExternOrderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Consigneekey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternLineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OriginalQty] [int] NOT NULL,
[ShippedQty] [int] NOT NULL,
[Shortqty] [int] NULL,
[TRANSFLAG] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NULL,
[EditDate] [datetime] NULL,
[TotalCarton] [int] NULL CONSTRAINT [DF_WMSEXPMBOL_TotalCarton] DEFAULT ((0)),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WMSEXPMBOL_StorerKey] DEFAULT (' ')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE TRIGGER [dbo].[ntrWMSEXPMBOLADD]
 ON  [dbo].[WMSEXPMBOL]
 FOR INSERT
 AS
 BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

 DECLARE @b_debug int
 SELECT @b_debug = 0
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
 IF @n_continue = 1 or @n_continue=2
 BEGIN
    IF @b_debug = 1
    BEGIN
       SELECT "Update EditDate and EditWho"
    END 
    UPDATE WMSEXPMBOL
    SET AddDate = GETDATE()
    FROM  WMSEXPMBOL, INSERTED
    WHERE WMSEXPMBOL.ExternOrderKey = INSERTED.ExternOrderKey
    AND   WMSEXPMBOL.ExternLineNo = INSERTED.ExternLineNo
    AND   WMSEXPMBOL.AddDate IS NULL
    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
    IF @n_err <> 0
    BEGIN
       SELECT @n_continue = 3
       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72804   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table WMSEXPMBOL. (ntrWMSEXPMBOLAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
    END
 END
 /* End of Customization */
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
    execute nsp_logerror @n_err, @c_errmsg, "ntrWMSEXPMBOLAdd"
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

/* 28-Oct-2013  TLTING     Review Editdate column update                */

CREATE TRIGGER [dbo].[ntrWMSEXPMBOLUpdate]
 ON  [dbo].[WMSEXPMBOL]
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

 DECLARE @b_debug int
 SELECT @b_debug = 0
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
 IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
 BEGIN
    IF @b_debug = 1
    BEGIN
       SELECT "Update EditDate and EditWho"
    END 
    UPDATE WMSEXPMBOL
    SET EditDate = GETDATE()
    FROM  WMSEXPMBOL, INSERTED
    WHERE WMSEXPMBOL.ExternOrderKey = INSERTED.ExternOrderKey
    AND   WMSEXPMBOL.ExternLineNo = INSERTED.ExternLineNo
    AND   WMSEXPMBOL.EditDate IS NULL
    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
    IF @n_err <> 0
    BEGIN
       SELECT @n_continue = 3
       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72804   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table WMSEXPMBOL. (ntrWMSEXPMBOLUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
    END
 END
 /* End of Customization */
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
    execute nsp_logerror @n_err, @c_errmsg, "ntrWMSEXPMBOLUpdate"
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
CREATE UNIQUE CLUSTERED INDEX [WMSEXPMBOL_Index_1] ON [dbo].[WMSEXPMBOL] ([ExternOrderkey], [ExternLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_WMSEXPMBOL_TransFlag] ON [dbo].[WMSEXPMBOL] ([TRANSFLAG]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMSEXPMBOL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMSEXPMBOL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMSEXPMBOL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMSEXPMBOL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'Consigneekey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'ExternOrderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'StorerKey'
GO
