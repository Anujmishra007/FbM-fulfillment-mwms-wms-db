SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/********************************************************************************/
/* Trigger: ntrKitHeaderAdd                                                     */
/* Creation Date:                                                               */
/* Copyright: IDS                                                               */
/* Written by:                                                                  */
/*                                                                              */
/* Purpose:  KIT Header Add Transaction                                         */
/*                                                                              */
/* Input Parameters:                                                            */
/*                                                                              */
/* Output Parameters:                                                           */
/*                                                                              */
/* Return Status:                                                               */
/*                                                                              */
/* Usage:                                                                       */
/*                                                                              */
/* Local Variables:                                                             */
/*                                                                              */
/* Called By: When insert new records                                           */
/*                                                                              */
/* PVCS Version: 1.3                                                            */
/*                                                                              */
/* Version: 6.0                                                                 */
/*                                                                              */
/* Data Modifications:                                                          */
/*                                                                              */
/* Updates:                                                                     */
/* Date         Author      Ver. Purposes                                       */
/* 30-May-2007  Shong       1.0  Add Checking on TrifficCop and ArchiveCop      */
/* 17-Mar-2009  TLTING      1.1  Change user_name() to SUSER_SNAME()            */
/* 03-Apr-2025  WLChooi     1.2  UWP-32362 Log DocStatusTrack (WL01)            */
/* 15-May-2025  Shreekanth  1.3  UWP-33751 AddWho & EditWho Nameduser (SG01)    */
/********************************************************************************/
CREATE OR ALTER TRIGGER [dbo].[ntrKitHeaderAdd]
ON [dbo].[KIT]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
	SET CONCAT_NULL_YIELDS_NULL OFF
	
   DECLARE   @b_Success            INT       -- Populated by calls to stored procedures - was the proc successful?
   ,         @n_err                INT       -- Error number returned by stored procedure or this trigger
   ,         @n_err2               INT       -- For Additional Error Detection
   ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
   ,         @n_continue           INT
   ,         @n_starttcnt          INT       -- Holds the current transaction count
   ,         @c_preprocess         NVARCHAR(250) -- preprocess
   ,         @c_pstprocess         NVARCHAR(250) -- post process
   ,         @n_cnt                INT
   ,         @c_Kitkey             NVARCHAR(10)   --WL01
   ,         @c_Storerkey          NVARCHAR(15)   --WL01
   ,         @c_ExternStatus       NVARCHAR(10)   --WL01
   ,         @c_NamedUser          NVARCHAR(128)  --SG01
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   /* #INCLUDE <TRTHA1.SQL> */
   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
      SELECT @n_continue = 4

   IF EXISTS( SELECT 1 FROM INSERTED WHERE TrafficCop = '9')
      SELECT @n_continue = 4

   -- 10.8.99 WALLY
   -- set reasoncode as mandatory field
   IF @n_continue=1 or @n_continue=2
   BEGIN
      DECLARE @c_reasoncode NVARCHAR(10)
      SELECT @c_reasoncode = reasoncode 
      FROM   INSERTED
      IF ISNULL(dbo.fnc_RTrim(@c_reasoncode), '') = ''
      BEGIN
         SELECT @n_continue = 3, @n_err = 50000
         SELECT @c_errmsg = 'VALIDATION ERROR: Reason Code Required.'
      END
   END
   
   IF @n_continue=1 or @n_continue=2
   BEGIN
      UPDATE KIT
      SET TrafficCop = NULL,
          AddDate  = GETDATE(),
          AddWho   = IIF(INSERTED.AddWho = '', SUSER_SNAME(), INSERTED.AddWho),   --To cater for the case when the user explicitly set the Addwho to blank --SG01
          EditDate = GETDATE(),
          EditWho  = IIF(INSERTED.EditWho = '', SUSER_SNAME(), INSERTED.EditWho)   --To cater for the case when the user explicitly set the EditWho to blank --SG01
      FROM KIT
      JOIN INSERTED ON KIT.KitKey = INSERTED.KitKey
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69601   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert Failed On Table KIT. (nspKitHeaderAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END

      --WL01 S
      SELECT @b_success = 1

      DECLARE CUR_DST CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT Kitkey, StorerKey, ISNULL(ExternStatus, '0')
                    , IIF(EditWho = '', SUSER_SNAME(), EditWho)  --To cater for the case when the user explicitly set the EditWho to blank --SG01
      FROM INSERTED

      OPEN CUR_DST

      FETCH NEXT FROM CUR_DST INTO @c_Kitkey, @c_Storerkey, @c_ExternStatus, @c_NamedUser       --SG01

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         IF NOT EXISTS ( SELECT 1 FROM DocStatusTrack WITH (NOLOCK)
                         WHERE TableName = 'KITEXTNSTS'
                         AND DocumentNo = @c_Kitkey
                         AND Key1 = '0' )
         BEGIN
            BEGIN TRY
               EXEC dbo.ispGenDocStatusLog @c_TableName = N'KITEXTNSTS'
                                         , @c_StorerKey = @c_Storerkey
                                         , @c_DocumentNo = @c_Kitkey
                                         , @c_Key1 = '0'
                                         , @c_Key2 = ''
                                         , @c_DocStatus = @c_ExternStatus
                                         , @c_NamedUser = @c_NamedUser                  --SG01
                                         , @b_Success = @b_Success OUTPUT
                                         , @n_err = @n_err OUTPUT
                                         , @c_errmsg = @c_errmsg OUTPUT

            END TRY
            BEGIN CATCH
               SELECT @n_continue = 3
               SELECT @n_err = 69605
               SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_err) + ': Failed to execute ispGenDocStatusLog. (nspKitHeaderAdd)'
                                + ' ( ' + ' SQLSvr MESSAGE=' + TRIM(@c_errmsg) + ' ) '
            END CATCH
         END

         FETCH NEXT FROM CUR_DST INTO @c_Kitkey, @c_Storerkey, @c_ExternStatus, @c_NamedUser            --SG01
      END
      CLOSE CUR_DST
      DEALLOCATE CUR_DST
      --WL01 E
   END
   /* #INCLUDE <TRTHA2.SQL> */

   --WL01 S
   IF CURSOR_STATUS('LOCAL', 'CUR_DST') IN (0 , 1)
   BEGIN
      CLOSE CUR_DST
      DEALLOCATE CUR_DST
   END
   --WL01 E

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
      execute nsp_logerror @n_err, @c_errmsg, 'ntrKitHeaderAdd'
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
