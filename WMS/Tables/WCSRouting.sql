CREATE TABLE [dbo].[WCSRouting]
(
[WCSKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToteNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Initial_Final_Zone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRouting_Initial_Final_Zone] DEFAULT (' '),
[Final_Zone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRouting_Final_Zone] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRouting_Status] DEFAULT ('0'),
[ActionFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRouting_ActionFlag] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRouting_OrderType] DEFAULT (' '),
[TaskType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRouting_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WCSRouting_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRouting_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WCSRouting_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSRouting_LoadKey] DEFAULT (''),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSRouting_WaveKey] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger: ntrWCSRoutingUpdate                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  WCSRouting Update Transaction                              */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When update records                                       */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date       Author       Rev   Purposes                               */
/* 28Sep2015  TLTING       1.1   Update(Editdate)                       */
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrWCSRoutingUpdate]
ON  [dbo].[WCSRouting] FOR UPDATE
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

   DECLARE @b_Success    INT
         , @n_err        INT
         , @n_err2       INT
         , @c_errmsg     NVARCHAR(250)
         , @n_continue   INT
         , @n_starttcnt  INT
         , @c_preprocess NVARCHAR(250)
         , @c_pstprocess NVARCHAR(250)
         , @n_cnt        INT
         , @c_authority  NVARCHAR(1)

   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4
   END

   -- tlting01
   IF ( @n_continue = 1 OR @n_continue = 2 ) OR UPDATE (EditDate)
   BEGIN
      UPDATE WCSRouting
      SET EditDate = GETDATE(),
          EditWho  = SUSER_SNAME(),
          TrafficCop = NULL
      FROM WCSRouting W WITH (NOLOCK)
      JOIN INSERTED I ON W.WCSKey = I.WCSKey

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @n_err = 69843
         SET @c_errmsg = 'NSQL'+CONVERT(char(5), @n_err)+': Update Failed On Table WCSRouting. (ntrWCSRoutingUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '
      END
   END

   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4
   END

   IF @n_continue = 3
   BEGIN
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt
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
      EXECUTE nsp_LogError @n_err, @c_errmsg, 'ntrWCSRoutingUpdate'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR -- SQL2012
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
ALTER TABLE [dbo].[WCSRouting] ADD CONSTRAINT [PK_WCSRouting] PRIMARY KEY CLUSTERED ([WCSKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WCSRouting_ToteNo] ON [dbo].[WCSRouting] ([ToteNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WCSRouting] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WCSRouting] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WCSRouting] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WCSRouting] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WCSRouting', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WCSRouting', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WCSRouting', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WCSRouting', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'WCSRouting', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WCSRouting', 'COLUMN', N'TrafficCop'
GO
