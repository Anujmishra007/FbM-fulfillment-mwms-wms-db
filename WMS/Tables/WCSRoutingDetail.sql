CREATE TABLE [dbo].[WCSRoutingDetail]
(
[WCSKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToteNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Zone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRoutingDetail_Zone] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRoutingDetail_Status] DEFAULT ('0'),
[ActionFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRoutingDetail_ActionFlag] DEFAULT (' '),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRoutingDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WCSRoutingDetail_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRoutingDetail_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WCSRoutingDetail_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger: ntrWCSRoutingDetailUpdate                                   */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  WCSRoutingDetail Update Transaction                        */
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
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrWCSRoutingDetailUpdate]
ON  [dbo].[WCSRoutingDetail] FOR UPDATE
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
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      UPDATE WCSRoutingDetail
      SET EditDate = GETDATE(),
          EditWho  = SUSER_SNAME(),
          TrafficCop = NULL
      FROM WCSRoutingDetail WD WITH (NOLOCK)
      JOIN INSERTED I ON (WD.WCSKey = I.WCSKey AND WD.RowRef = I.RowRef)

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @n_err = 69849
         SET @c_errmsg = 'NSQL'+CONVERT(char(5), @n_err)+': Update Failed On Table WCSRoutingDetail. (ntrWCSRoutingDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '
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
      EXECUTE nsp_LogError @n_err, @c_errmsg, 'ntrWCSRoutingDetailUpdate'
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
ALTER TABLE [dbo].[WCSRoutingDetail] ADD CONSTRAINT [PK_WCSRoutingDetail] PRIMARY KEY CLUSTERED ([WCSKey], [RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WCSRoutingDetail_ToteNo] ON [dbo].[WCSRoutingDetail] ([ToteNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WCSRoutingDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WCSRoutingDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WCSRoutingDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WCSRoutingDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WCSRoutingDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WCSRoutingDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WCSRoutingDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WCSRoutingDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WCSRoutingDetail', 'COLUMN', N'TrafficCop'
GO
