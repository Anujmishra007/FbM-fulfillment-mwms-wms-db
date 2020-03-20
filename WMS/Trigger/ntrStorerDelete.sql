if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ntrStorerDelete]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[ntrStorerDelete]
GO

CREATE TRIGGER ntrStorerDelete
ON dbo.STORER

-- Added by YokeBeen on 14-Jan-2003 for SOS#8859.
-- Edited by KHLim02 on 14-Jul-2011 for GetRight for Delete log

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

DECLARE @b_Success  int,       -- Populated by calls to stored procedures - was the proc successful?
@n_err              int,       -- Error number returned by stored procedure or this trigger
@c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
@n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
@n_starttcnt        int,       -- Holds the current transaction count
@n_cnt              int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
,@c_authority       NVARCHAR(1)  -- KHLim02

SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
     /* #INCLUDE <TRRHD1.SQL> */     

IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')
BEGIN
	SELECT @n_continue = 4
END

IF @n_continue = 1 or @n_continue = 2
BEGIN
	DELETE STORERBILLING FROM STORERBILLING, DELETED
	 WHERE STORERBILLING.StorerKey = DELETED.StorerKey
	SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	IF @n_err <> 0
	BEGIN
		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63901   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table STORERBILLING Failed. (ntrStorerDelete) ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
	END

	DELETE STORERSODEFAULT FROM STORERSODEFAULT, DELETED
	 WHERE STORERSODEFAULT.StorerKey = DELETED.StorerKey
	SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	IF @n_err <> 0
	BEGIN
		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63902   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table STORERSODEFAULT Failed. (ntrStorerDelete) ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
	END

	DELETE STORERConfig FROM STORERConfig, DELETED
	 WHERE STORERConfig.StorerKey = DELETED.StorerKey 

	SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	IF @n_err <> 0
	BEGIN
		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63905   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table STORERCONFIG Failed. (ntrStorerDelete) ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
	END
END

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
               ,@c_errmsg = 'ntrStorerDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.STORER_DELLOG ( StorerKey )
         SELECT StorerKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table STORER Failed. (ntrStorerDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

     /* #INCLUDE <TRRHD2.SQL> */
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

	EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrStorerDelete'
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

