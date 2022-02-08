CREATE TABLE [dbo].[BTB_FTA]
(
[BTB_FTAKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_FormNo] DEFAULT (''),
[FormType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_FormType] DEFAULT (''),
[CustomerCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_CustomerCode] DEFAULT (''),
[HSCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_HSCode] DEFAULT (''),
[COO] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_COO] DEFAULT (''),
[PermitNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_PermitNo] DEFAULT (''),
[IssuedDate] [datetime] NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_Storerkey] DEFAULT (''),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_Sku] DEFAULT (''),
[SkuDescr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_SkuDescr] DEFAULT (''),
[UOM] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UOM] DEFAULT (''),
[QtyImported] [int] NOT NULL CONSTRAINT [DF_BTB_FTA_QtyImported] DEFAULT ((0)),
[QtyExported] [int] NOT NULL CONSTRAINT [DF_BTB_FTA_QtyExported] DEFAULT ((0)),
[OriginCriterion] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnabledFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_EnabledFlag] DEFAULT ('Y'),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine05] DEFAULT (''),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine08] DEFAULT (''),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine10] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_FTA_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_FTA_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssueCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BTB_FTA_IssueCountry] DEFAULT (''),
[IssueAuthority] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BTB_FTA_IssueAuthority] DEFAULT (''),
[BTBShipItem] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_BTBShipItem] DEFAULT (''),
[CustomLotNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_CustomLotNo] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/* 28-dec-2020  kocy    1.0   GetRight for Delete log                */

CREATE TRIGGER [dbo].[ntrBTB_FTADelete]
 ON [dbo].[BTB_FTA]
 FOR DELETE
 AS
 BEGIN
   IF @@ROWCOUNT = 0
   BEGIN
     RETURN
   END
  
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE	@b_Success       int,       -- Populated by calls to stored procedures - was the proc successful?
			@n_err           int,       -- Error number returned by stored procedure or this trigger
			@c_errmsg        NVARCHAR(250), -- Error message returned by stored procedure or this trigger
			@n_continue      int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
			@n_starttcnt     int,       -- Holds the current transaction count
			@n_cnt           int,        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
			@c_authority     NVARCHAR(1)  -- KHLim02

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF (select count(1) from DELETED) = (select count(1) from DELETED where DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END
      /* #INCLUDE <TRTHD1.SQL> */      
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0         --    Start (KHLim02)
      EXECUTE nspGetRight  NULL,             -- facility  
                           NULL,             -- Storerkey  
                           NULL,             -- Sku  
                           'DataMartDELLOG', -- Configkey  
                           @b_success     OUTPUT, 
                           @c_authority   OUTPUT, 
                           @n_err         OUTPUT, 
                           @c_errmsg      OUTPUT  
      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
               ,@c_errmsg = 'ntrBTB_FTADelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.BTB_FTA_DELLOG ( BTB_FTAKey )
         SELECT BTB_FTAKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table BTB_FTA Failed. (ntrBTB_FTADelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

      /* #INCLUDE <TRTHD2.SQL> */
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrBTB_FTADelete"
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
/************************************************************************/
/* Trigger: ntrBTB_FTAUpdate                                            */
/* Creation Date: 20-MAR-2017                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:  WMS-1258 - Back-to-Back FTA Entry                          */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrBTB_FTAUpdate]
ON  [dbo].[BTB_FTA]
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

   DECLARE @n_StartTCnt       INT
         , @n_Continue        INT
         , @n_err             INT
         , @c_errmsg          NVARCHAR(250)

   SET @n_StartTCnt= @@TRANCOUNT
   SET @n_Continue = 1

   IF UPDATE(ArchiveCop)
   BEGIN
      SET @n_continue = 4 
      GOTO QUIT_TR
   END

   IF NOT UPDATE(EditDate) 
   BEGIN
      UPDATE BTB_FTA WITH (ROWLOCK)
      SET EditWho = SUSER_SNAME()
         ,EditDate = GETDATE()
         ,TrafficCop = NULL
      FROM BTB_FTA
      JOIN INSERTED ON (BTB_FTA.BTB_FTAKey = INSERTED.BTB_FTAKey)

      SET @n_err = @@ERROR 
      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @c_errmsg = CONVERT(CHAR(250),@n_err)
         SET @n_err=80010   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table BTB_FTA. (ntrBTB_FTAUpdate)' 
                      + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         GOTO QUIT_TR
      END
   END

   IF UPDATE(TrafficCop)
   BEGIN
      SET @n_continue = 4 
      GOTO QUIT_TR
   END
 
 QUIT_TR:
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ntrBTB_FTAUpdate'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
ALTER TABLE [dbo].[BTB_FTA] ADD CONSTRAINT [PK__BTB_FTA__4AEB7F3AE998DB66] PRIMARY KEY CLUSTERED ([BTB_FTAKey]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [BTB_FTA_IDX_BTB_FTA] ON [dbo].[BTB_FTA] ([FormType], [HSCode], [Storerkey], [Sku], [BTBShipItem], [COO], [FormNo], [CustomLotNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BTB_FTA] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BTB_FTA] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BTB_FTA] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BTB_FTA] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Custom Lot #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_FTA', 'COLUMN', N'CustomLotNo'
GO
