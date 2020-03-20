if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ntrSKUxLOCdelete]') 
              and OBJECTPROPERTY(id, N'IsTrigger') = 1) 
drop trigger [dbo].[ntrSKUxLOCdelete]
GO

/* 13-Sep-2011  KHLim02     GetRight for Delete log                */
/* 18-Jan-2012  KHLim03     check ArchiveCop                       */
/* 27-Jul-2017  TLTING      SET Option                             */
/* 27-Oct-2017  TLTING      Move up dellog                         */

CREATE TRIGGER [dbo].[ntrSKUxLOCdelete]
ON [dbo].[SKUxLOC]
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
	
   DECLARE @n_err int,
         @c_errmsg NVARCHAR(250),
         @n_continue int,
         @n_starttcnt int
        ,@b_Success     int
        ,@c_authority   NVARCHAR(1)  -- KHLim02

	SELECT @n_continue=1, @n_starttcnt = @@TRANCOUNT   -- KHLim02

   IF @n_continue = 1 or @n_continue = 2  --    Start (KHLim02)
   BEGIN
      SELECT @b_success = 0
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
               ,@c_errmsg = 'ntrSKUxLOCdelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1' 
      BEGIN
         INSERT INTO dbo.SKUxLOC_DELLOG ( StorerKey, Sku, Loc )
         SELECT StorerKey, Sku, Loc FROM DELETED

         SELECT @n_err = @@ERROR
         IF @n_err <> 0
         BEGIN
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table SKUxLOC Failed. (ntrSKUxLOCdelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END                                 --    End   (KHLim02)

   IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9') -- KHLim03
   BEGIN
	   SELECT @n_continue = 4
   END

   if exists (select 1 
              from deleted
              where qty > 0
                 or qtyallocated > 0
                 or qtypicked > 0)
   begin
      SELECT @n_continue = 3
      SELECT @n_err = 63210
      SELECT @c_errmsg = 'NSQL-63210 : Delete Not Allowed on Active Records (ntrSKUxLOCdelete)'
   end

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
      execute nsp_logerror @n_err, @c_errmsg, 'ntrSKUxLOCdelete'
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
