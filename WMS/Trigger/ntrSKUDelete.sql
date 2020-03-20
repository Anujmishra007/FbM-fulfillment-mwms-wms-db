if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ntrSKUDelete]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[ntrSKUDelete]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/***************************************************************************/
/* Trigger: ntrSKUDelete                                                   */
/* Creation Date:                                                          */
/* Copyright: IDS                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: Update/Delete other records while SKU line is being deleted.   */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Deleted                                         */
/*                                                                         */
/* PVCS Version: 1.4                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author   Ver  Purposes                                     */
/* 17-Mar-2009  TLTING        Change user_name() to SUSER_SNAME()          */
/* 28-Apr-2011  KHLim01  1.2  Insert Delete log                            */
/* 14-Jul-2011  KHLim02  1.3  GetRight for Delete log                      */
/* 18-Jan-2012  KHLim03  1.4  check ArchiveCop                             */
/* 22-May-2012  YTWan    1.5  SOS#244027: SkuInfo (Wan01)                  */
/***************************************************************************/

CREATE TRIGGER ntrSKUDelete
 ON  SKU
 FOR DELETE
 AS
 BEGIN
   IF @@ROWCOUNT = 0 -- KHLim03
   BEGIN
	   RETURN
   END
    SET NOCOUNT ON
    SET ANSI_NULLS OFF 
    SET QUOTED_IDENTIFIER OFF
 	 SET CONCAT_NULL_YIELDS_NULL OFF
 	 
    DECLARE @b_Success       int,
            @n_err           int,       
            @c_errmsg        NVARCHAR(250),
	         @n_cnt           int, 
            @c_Action        NVARCHAR(100)
           ,@c_authority     NVARCHAR(1)  -- KHLim02
           ,@n_continue      int  -- KHLim03
           ,@n_starttcnt     int  -- KHLim03
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  -- KHLim03

   IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9') -- KHLim03
   BEGIN
	   SELECT @n_continue = 4
   END

   --(Wan01) - START
   IF EXISTS (SELECT 1
              FROM SKUInfo WITH (NOLOCK)
              JOIN DELETED
              ON  ( SKUInfo.Storerkey = DELETED.Storerkey )
              AND ( SKUInfo.Sku = DELETED.Sku ))
   BEGIN
      DELETE FROM SKUInfo WITH (ROWLOCK)  
      FROM SkuInfo
      JOIN DELETED ON  ( SKUInfo.Storerkey = DELETED.Storerkey )
                   AND ( SKUInfo.Sku = DELETED.Sku )
       SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
       IF @n_err <> 0
       BEGIN
          SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68103   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
          SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger Failed on SkuInfo table update. (ntrSKUDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
       END                   
   END
   --(Wan01) - END
   
   IF @n_continue = 1 or @n_continue = 2   -- KHLim03
   BEGIN
       SELECT @c_Action = 'Delete '
       INSERT INTO SKULog
             (Person, ActionTime, ActionDescr)
       SELECT SUSER_SNAME(), GetDate(), 'Deleting ' + dbo.fnc_RTrim(SKU) + dbo.fnc_RTrim(DESCR)
       FROM  DELETED

       DELETE SKUCONFIG FROM DELETED 
        WHERE SKUCONFIG.STORERKEY = DELETED.STORERKEY 
          AND SKUCONFIG.SKU = DELETED.SKU

       SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
       IF @n_err <> 0
       BEGIN
          SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63750   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
          SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On Table SKU Failed. (ntrSKUDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
       END
   END


   IF @n_continue = 1 or @n_continue = 2   -- KHLim03
   BEGIN
   -- Start (KHLim01) 
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
         SELECT @c_errmsg = 'ntrSKUDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.SKU_DELLOG ( StorerKey, Sku )
         SELECT StorerKey, Sku FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table SKU Failed. (ntrSKUDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   -- End (KHLim01) 
   END

 END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

