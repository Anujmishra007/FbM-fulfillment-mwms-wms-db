CREATE TABLE [dbo].[JReportFolder]
(
[SecondLvl] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_JReportFolder_SecondLvl] DEFAULT ('WMS'),
[FolderPath] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Remark] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_JReportFolder_Remark] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_JReportFolder_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_JReportFolder_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_JReportFolder_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_JReportFolder_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE TRIGGER [dbo].[ntrJReportFolderUpdate] ON [dbo].[JReportFolder]
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

   DECLARE @b_debug INT
   SELECT @b_debug = 0
   
   DECLARE @n_err       INT       -- Error number returned by stored procedure or this trigger
         , @n_continue  INT
         , @n_starttcnt INT       -- Holds the current transaction count
         , @c_errmsg    NVARCHAR(250)

   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT

   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE JReportFolder
         SET EditDate = GETDATE(),
             EditWho  = SUSER_SNAME()
      FROM JReportFolder WITH (NOLOCK), INSERTED WITH (NOLOCK)
      WHERE JReportFolder.StorerKey = INSERTED.StorerKey
      AND   JReportFolder.SecondLvl = INSERTED.SecondLvl
		SELECT @n_err = @@ERROR

		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=67890
			SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table ConfigFlow. (ntrConfigFlowUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
		END
   END


	IF @n_continue = 3  -- Error Occured - Process And Return
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
ALTER TABLE [dbo].[JReportFolder] ADD CONSTRAINT [PKJReportFolder] PRIMARY KEY CLUSTERED ([SecondLvl], [StorerKey]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[JReportFolder] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[JReportFolder] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[JReportFolder] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[JReportFolder] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[JReportFolder] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'JReport Folder - StorerKey Mapping in JReport Server Console Public Reports', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Folder path of third level folder or including subfolders if applicable', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'FolderPath'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Internal remark for reference', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'Remark'
GO
EXEC sp_addextendedproperty N'MS_Description', N'JReport 2nd level folder name (usually application name, i.e. WMS, OMS, TMS, LMS, TPB, etc.', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'SecondLvl'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique customer key from STORER table Type=''1''', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'StorerKey'
GO
