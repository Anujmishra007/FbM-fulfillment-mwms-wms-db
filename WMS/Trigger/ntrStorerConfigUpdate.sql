SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ntrStorerConfigUpdate]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[ntrStorerConfigUpdate]
GO

/************************************************************************/
/* Trigger: ntrStorerConfigUpdate                                       */
/* Creation Date:                                                       */
/* Copyright: LF                                                        */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
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
/* Called By: When records updated                                      */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver   Purposes                                  */
/* 12-Dec-2008  TLTING  1.0   Revise Promary key - add facility         */
/* 17-Mar-2009  TLTING  1.1   Change user_name() to SUSER_SNAME()       */
/* 28-Oct-2013  TLTING  1.2   Review Editdate column update             */
/* 05-Feb-2015  NJOW01  1.3   330996-update log                         */
/************************************************************************/

CREATE TRIGGER ntrStorerConfigUpdate
ON  StorerConfig
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

   DECLARE @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
      ,         @n_err                int       -- Error number returned by stored procedure or this trigger
      ,         @n_err2 int              -- For Additional Error Detection
      ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
      ,         @n_continue int                 
      ,         @n_starttcnt int                -- Holds the current transaction count
      ,         @c_preprocess NVARCHAR(250)         -- preprocess
      ,         @c_pstprocess NVARCHAR(250)         -- post process
      ,         @n_cnt int                  
   
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   
   /* #INCLUDE <TRPU_1.SQL> */  
   IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE StorerConfig
      SET EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      FROM StorerConfig, INSERTED
      WHERE StorerConfig.Storerkey = INSERTED.Storerkey
         AND StorerConfig.Facility = INSERTED.Facility         -- tlting01
         AND StorerConfig.ConfigKey = INSERTED.ConfigKey
   
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62501   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table StorerConfig. (ntrStorerConfigUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END
   END
   
   --NJOW01
   IF ( @n_continue = 1 or @n_continue = 2 ) AND UPDATE(Svalue)
   BEGIN   	     	  
   	  INSERT INTO TableActionLog (TableName, Action, Description, Userdefine01, Userdefine02, SourceType)
   	  SELECT 'STORERCONFIG','UPDATE', 
   	         'Configkey:'+RTRIM(ISNULL(INSERTED.Configkey,'')) + 
   	         '  Field:SValue  Old Value:' + RTRIM(ISNULL(DELETED.Svalue,'')) + 
   	         '  New Value:' + RTRIM(ISNULL(INSERTED.Svalue,'')),
   	         'SValue',
   	         INSERTED.Configkey,
   	         'ntrStorerConfigUpdate'
   	  FROM INSERTED (NOLOCK)
   	  JOIN DELETED (NOLOCK) ON INSERTED.Configkey = DELETED.Configkey AND INSERTED.Storerkey = DELETED.Storerkey
   	                        AND INSERTED.Facility = DELETED.Facility   	  
   END
      
   /* #INCLUDE <TRPU_2.SQL> */
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
      execute nsp_logerror @n_err, @c_errmsg, "ntrStorerConfigUpdate"
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
