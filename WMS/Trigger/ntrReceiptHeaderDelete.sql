if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ntrReceiptHeaderDelete]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[ntrReceiptHeaderDelete]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Trigger: ntrReceiptHeaderDelete                                      */
/* Creation Date:                                                       */
/* Copyright: LFL                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: When Udpate Order Header Record                           */
/*                                                                      */
/* PVCS Version: 1.30                                                   */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 14-Jul-2011  KHLim02   1.0   GetRight for Delete log                 */
/* 24-May-2012  TLTING01  1.1   Data integrity - insert dellog 4        */
/*                              status < '9'                            */ 
/* 07-Apr-2017  NJOW01    1.2   Call custom trigger stored proc         */
/* 01-Aug-20195 Wan01     1.3   WMS-9995 [CN] NIKESDC_Exceed_Hold ASN   */
/*                              for Channel                             */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrReceiptHeaderDelete]
 ON [dbo].[RECEIPT]
 FOR DELETE
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

 DECLARE @b_Success       int,       -- Populated by calls to stored procedures - was the proc successful?
 @n_err              int,       -- Error number returned by stored procedure or this trigger
 @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
 @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
 @n_starttcnt        int,       -- Holds the current transaction count
 @n_cnt              int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
,@c_authority        NVARCHAR(1)  -- KHLim02
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
      /* #INCLUDE <TRRHD1.SQL> */    

 IF (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END
 
   --TLTING01
   IF EXISTS ( SELECT 1 FROM DELETED WHERE [STATUS] < '9' ) AND ( @n_continue = 1 or @n_continue = 2 )
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
               ,@c_errmsg = 'ntrReceiptHeaderDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.RECEIPT_DELLOG ( ReceiptKey )
         SELECT ReceiptKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table RECEIPT Failed. (ntrReceiptHeaderDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

 --NJOW01
 IF @n_continue=1 or @n_continue=2          
 BEGIN   	  
    IF EXISTS (SELECT 1 FROM DELETED d   ----->Put INSERTED if INSERT action
               JOIN storerconfig s WITH (NOLOCK) ON  d.storerkey = s.storerkey    
               JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue
               WHERE  s.configkey = 'ReceiptTrigger_SP')   -----> Current table trigger storerconfig
    BEGIN        	  
       IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
          DROP TABLE #INSERTED
 
    	 SELECT * 
    	 INTO #INSERTED
    	 FROM INSERTED
        
       IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
          DROP TABLE #DELETED
 
    	 SELECT * 
    	 INTO #DELETED
    	 FROM DELETED
 
       EXECUTE dbo.isp_ReceiptTrigger_Wrapper ----->wrapper for current table trigger
                 'DELETE'  -----> @c_Action can be INSERTE, UPDATE, DELETE
               , @b_Success  OUTPUT  
               , @n_Err      OUTPUT   
               , @c_ErrMsg   OUTPUT  
 
       IF @b_success <> 1  
       BEGIN  
          SELECT @n_continue = 3  
                ,@c_errmsg = 'ntrReceiptHeaderDelete' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))  -----> Put current trigger name
       END  
       
       IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
          DROP TABLE #INSERTED
 
       IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
          DROP TABLE #DELETED
    END
 END   

--(Wan01) - START 
IF @n_continue=1 or @n_continue=2          
BEGIN   	
   IF EXISTS ( SELECT 1
               FROM  DELETED WITH (NOLOCK)
               JOIN  RECEIPTDETAIL RD WITH (NOLOCK)
                     ON DELETED.ReceiptKey = RD.ReceiptKey
               WHERE DELETED.HoldChannel = '1'
               AND   RD.QtyReceived > 0
               AND   RD.FinalizeFlag = 'Y'
               AND   RD.Channel_ID > 0 
              )
   BEGIN
      SET @n_continue = 3
      SET @n_err = 68102
      SET @c_errmsg  = CONVERT(char(5),@n_err)+': ASN With Channel Hold found'
                     + '. Delete Abort. (ntrReceiptHeaderDelete)'
   END   
END
--(Wan01) - END

 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 DELETE ReceiptDetail FROM ReceiptDetail, Deleted
 WHERE ReceiptDetail.ReceiptKey=Deleted.ReceiptKey
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63901   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On Table RECEIPTDETAIL Failed. (ntrReceiptHeaderDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrReceiptHeaderDelete"
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
