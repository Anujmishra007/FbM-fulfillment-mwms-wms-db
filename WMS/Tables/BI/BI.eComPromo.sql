CREATE TABLE [BI].[eComPromo]
(
[PromoID] [smallint] NOT NULL IDENTITY(1, 1),
[PromoType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [smalldatetime] NOT NULL,
[EndDate] [smalldatetime] NOT NULL,
[DaysAgo] [smallint] NOT NULL,
[IncludeArchive] [bit] NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_eComPromo_AddDate] DEFAULT (getdate()),
[AddWho] [sys].[sysname] NOT NULL CONSTRAINT [DF_eComPromo_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_eComPromo_EditDate] DEFAULT (getdate()),
[EditWho] [sys].[sysname] NOT NULL CONSTRAINT [DF_eComPromo_EditWho] DEFAULT (suser_sname()),
[FreqInterval] [smallint] NOT NULL CONSTRAINT [DF_eComPromo_FreqInterval] DEFAULT ((10))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [BI].[ntrBIeComPromoUpdate]
ON  [BI].[eComPromo] FOR UPDATE
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

	DECLARE @b_Success    int       -- Populated by calls to stored procedures - was the proc successful?
			, @n_err        int       -- Error number returned by stored procedure or this trigger
			, @n_err2       int       -- For Additional Error Detection
			, @c_errmsg     char(250) -- Error message returned by stored procedure or this trigger
			, @n_continue   int                 
			, @n_starttcnt  int       -- Holds the current transaction count
			, @c_preprocess char(250) -- preprocess
			, @c_pstprocess char(250) -- post process
			, @n_cnt        int                  

	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
	
	IF (@n_continue = 1 or @n_continue=2) AND NOT UPDATE(IncludeArchive)
	BEGIN
		UPDATE BI.eComPromo
		SET EditDate = GETDATE()
		   ,EditWho = SUSER_SNAME()
		FROM BI.eComPromo with (NOLOCK), INSERTED with (NOLOCK)
      WHERE eComPromo.PromoID  = INSERTED.PromoID
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=67890
			SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table eComPromo. (ntrBIeComPromoUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
		END
	END

      /* #INCLUDE <TRTHU2.SQL> */
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
		RAISERROR (@c_errmsg, 16, 1) WITH LOG
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
ALTER TABLE [BI].[eComPromo] ADD CONSTRAINT [PK_eComPromo] PRIMARY KEY CLUSTERED ([PromoID]) ON [PRIMARY]
GO
GRANT INSERT ON  [BI].[eComPromo] TO [NSQL]
GO
GRANT SELECT ON  [BI].[eComPromo] TO [NSQL]
GO
GRANT UPDATE ON  [BI].[eComPromo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'e-Commerce Configuration table for customer forecast & promo period.', 'SCHEMA', N'BI', 'TABLE', N'eComPromo', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date time when added the record', 'SCHEMA', N'BI', 'TABLE', N'eComPromo', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Login name who added the record', 'SCHEMA', N'BI', 'TABLE', N'eComPromo', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date time when edited the record', 'SCHEMA', N'BI', 'TABLE', N'eComPromo', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Login name who edited the record', 'SCHEMA', N'BI', 'TABLE', N'eComPromo', 'COLUMN', N'EditWho'
GO
