IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_Id(N'[dbo].[ntrAreaDetailUpdate]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
   DROP TRIGGER [dbo].[ntrAreaDetailUpdate]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/******************************************************************************/
/* Trigger: ntrAreaDetailUpdate                                               */
/* Creation Date:                                                             */
/* Copyright: IDS                                                             */
/* Written by:                                                                */
/*                                                                            */
/* Purpose:                                                                   */
/*                                                                            */
/* Input Parameters:                                                          */
/*                                                                            */
/* Output Parameters:                                                         */
/*                                                                            */
/* Return Status:                                                             */
/*                                                                            */
/* Usage:                                                                     */
/*                                                                            */
/* Local Variables:                                                           */
/*                                                                            */
/* Called By: When records updated                                            */
/*                                                                            */
/* PVCS Version: 1.1                                                          */
/*                                                                            */
/* Version: 5.4                                                               */
/*                                                                            */
/* Data Modifications:                                                        */
/*                                                                            */
/* Updates:                                                                   */
/* Date         Author        Ver   Purposes                                  */
/* 28-Feb-2011  Leong         1.1   SOS# 207014 - Update EditDate & EditWho   */
/* 28-Oct-2013  TLTING        1.2    Review Editdate column update            */
/******************************************************************************/

CREATE TRIGGER ntrAreaDetailUpdate
ON AreaDetail
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

   DECLARE @b_Success   int,       -- Populated by calls to stored procedures - was the proc successful?
           @n_err       int,       -- Error number returned by stored procedure or this trigger
           @c_errmsg    NVARCHAR(250), -- Error message returned by stored procedure or this trigger
           @n_continue  int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
           @n_starttcnt int,       -- Holds the current transaction count
           @n_cnt       int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.

   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT

   IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

   --SOS# 207014 (Start)
   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE AreaDetail with (ROWLOCK)
      SET EditWho = sUser_sName(),
          EditDate = GetDate()
      FROM AreaDetail
      JOIN INSERTED ON AreaDetail.AreaKey = INSERTED.AreaKey
      AND AreaDetail.PutawayZone = INSERTED.PutawayZone

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=86402
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On AreaDetail. (ntrAreaDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '
      END

   END
   --SOS# 207014 (End)

   IF NOT UPDATE(AreaKey)
   BEGIN
      SELECT @n_continue = 4
   END

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      IF EXISTS(SELECT * FROM PutawayStrategyDetail, DELETED
                WHERE PutawayStrategyDetail.AreaTypeExclude01 = DELETED.AreaKey
                OR PutawayStrategyDetail.AreaTypeExclude02 = DELETED.AreaKey
                OR PutawayStrategyDetail.AreaTypeExclude03 = DELETED.AreaKey)
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 86400
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On AreaDetail Failed As Putaway Strategy Details Still Reference Area. (ntrAreaDetailUpdate)"
      END
   END

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      IF EXISTS(SELECT * FROM TaskManagerUserDetail, DELETED
                WHERE TaskManagerUserDetail.AreaKey = DELETED.AreaKey)
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 86401
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On AreaDetail Failed As Task manager User Details Still Reference Area. (ntrAreaDetailUpdate)"
      END
   END

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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrAreaDetailUpdate"
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
