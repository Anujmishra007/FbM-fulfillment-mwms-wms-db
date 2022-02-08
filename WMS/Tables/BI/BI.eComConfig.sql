CREATE TABLE [BI].[eComConfig]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Brand] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FacilityDesc] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_eComConfig_FacilityDesc] DEFAULT (''),
[IsActive] [bit] NOT NULL CONSTRAINT [DF_eComConfig_IsActive] DEFAULT ((1)),
[OrdersForecast] [int] NOT NULL CONSTRAINT [DF_eComConfig_OrdersForecast] DEFAULT ((0)),
[OpsDays] [int] NOT NULL CONSTRAINT [DF_eComConfig_OpsDays] DEFAULT ((0)),
[PickHours] [int] NOT NULL CONSTRAINT [DF_eComConfig_PickHours] DEFAULT ((0)),
[AllocHours] [int] NOT NULL CONSTRAINT [DF_eComConfig_AllocHours] DEFAULT ((0)),
[PresaleStart] [datetime] NULL,
[PromoStart] [datetime] NULL,
[CompletionDate] [datetime] NULL,
[HoursOverrun] [int] NOT NULL CONSTRAINT [DF_eComConfig_HoursOverrun] DEFAULT ((0)),
[SLADescription] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_eComConfig_SLADescription] DEFAULT (''),
[SLAMinimum] [int] NOT NULL CONSTRAINT [DF_eComConfig_SLAMinimum] DEFAULT ((0)),
[ShowPreSales] [bit] NOT NULL CONSTRAINT [DF_eComConfig_ShowPreSales] DEFAULT ((0)),
[DashboardDescription] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_eComConfig_DashboardDescription] DEFAULT (''),
[ShowCourier] [bit] NOT NULL CONSTRAINT [DF_eComConfig_ShowCourier] DEFAULT ((0)),
[UnitsForecast] [int] NOT NULL CONSTRAINT [DF_eComConfig_UnitsForecast] DEFAULT ((0)),
[DocType] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_eComConfig_DocType] DEFAULT ('E'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_eComConfig_AddDate] DEFAULT (getdate()),
[AddWho] [sys].[sysname] NOT NULL CONSTRAINT [DF_eComConfig_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_eComConfig_EditDate] DEFAULT (getdate()),
[EditWho] [sys].[sysname] NOT NULL CONSTRAINT [DF_eComConfig_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  TRIGGER [BI].[ntrBIeComConfigUpdate]
ON  [BI].[eComConfig] FOR UPDATE
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
	
	IF @n_continue = 1 or @n_continue=2
	BEGIN
		UPDATE BI.eComConfig
		SET EditDate = GETDATE()
		   ,EditWho = SUSER_SNAME()
		FROM BI.eComConfig with (NOLOCK), INSERTED with (NOLOCK)
      WHERE eComConfig.StorerKey = INSERTED.StorerKey
        AND eComConfig.Facility  = INSERTED.Facility
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=67890
			SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table eComConfig. (ntrBIeComConfigUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
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
ALTER TABLE [BI].[eComConfig] ADD CONSTRAINT [PK_eComConfig] PRIMARY KEY CLUSTERED ([StorerKey], [Facility]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [BI].[eComConfig] ADD CONSTRAINT [FK_eComConfig_FACILITY] FOREIGN KEY ([Facility]) REFERENCES [dbo].[FACILITY] ([Facility])
GO
GRANT INSERT ON  [BI].[eComConfig] TO [NSQL]
GO
GRANT SELECT ON  [BI].[eComConfig] TO [NSQL]
GO
GRANT UPDATE ON  [BI].[eComConfig] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'e-Commerce Configuration table for customer forecast & promo period.', 'SCHEMA', N'BI', 'TABLE', N'eComConfig', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date time when added the record', 'SCHEMA', N'BI', 'TABLE', N'eComConfig', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Login name who added the record', 'SCHEMA', N'BI', 'TABLE', N'eComConfig', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Brand name for display on dashboard', 'SCHEMA', N'BI', 'TABLE', N'eComConfig', 'COLUMN', N'Brand'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date time when edited the record', 'SCHEMA', N'BI', 'TABLE', N'eComConfig', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Login name who edited the record', 'SCHEMA', N'BI', 'TABLE', N'eComConfig', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Facility code (foreign key to FACILITY table)', 'SCHEMA', N'BI', 'TABLE', N'eComConfig', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Facility Description preferred by customer for dashboard', 'SCHEMA', N'BI', 'TABLE', N'eComConfig', 'COLUMN', N'FacilityDesc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Presales start date until PromoStart.', 'SCHEMA', N'BI', 'TABLE', N'eComConfig', 'COLUMN', N'PresaleStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key of STORER table (type=''1'')', 'SCHEMA', N'BI', 'TABLE', N'eComConfig', 'COLUMN', N'StorerKey'
GO
