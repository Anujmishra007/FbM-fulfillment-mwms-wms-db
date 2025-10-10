
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************/
/* Trigger: ntrReceiptSerialNoDelete                                                */
/*  Author  : kelvinongcy                                                           */
/*  Date    : 2023-01-18                                                            */
/*  Purpose : Trigger point upon any Delete on the ReceiptSerialNo                  */
/*                                                                                  */
/* Date        Rev     Author       Purposes                                        */
/* 2023-01-18  1.0     kelvinongcy  WMS-21538 Created                               */
/* 2025-10-02  1.1     SPC040      UWP-42005 Insert full deleted record into ReceiptSerialNo_Del on delete */
/* 2025-10-02  1.2     AYD01        UWP-42138 Reflect deleted ReceiptSerialNo QTY into Receipt Details  */
/************************************************************************************/
  
CREATE OR ALTER   TRIGGER [dbo].[ntrReceiptSerialNoDelete]  
ON  [dbo].[ReceiptSerialNo]   
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
   
   DECLARE  
        @b_Success         int       -- Populated by calls to stored procedures - was the proc successful?  
      , @n_err             int       -- Error number returned by stored procedure or this trigger  
      , @n_err2            int       -- For Additional Error Detection  
      , @c_errmsg          NVARCHAR(250) -- Error message returned by stored procedure or this trigger  
      , @n_continue        int                   
      , @n_starttcnt       int       -- Holds the current transaction count  
      , @c_preprocess      NVARCHAR(250) -- preprocess  
      , @c_pstprocess      NVARCHAR(250) -- post process  
      , @n_cnt             int        
      , @c_authority       NVARCHAR(1)  -- KHLim02
 
   DECLARE @cStorerkey     NVARCHAR(15) -- (Vicky01)  
   
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   IF (select count(*) from DELETED WITH (NOLOCK)) = (select count(*) from DELETED WITH (NOLOCK) where DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
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
               ,@c_errmsg = 'ntrReceiptSerialNoDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN

         -- ✅ Insert full deleted record into ReceiptSerialNo_Del
         INSERT INTO dbo.ReceiptSerialNo_DEL
         (
             ReceiptSerialNoKey,
             ReceiptKey,
             ReceiptLineNumber,
             StorerKey,
             SKU,
             SerialNo,
             QTY,
             UCCNo
         )
         SELECT
             d.ReceiptSerialNoKey,
             d.ReceiptKey,
             d.ReceiptLineNumber,
             d.StorerKey,
             d.SKU,
             d.SerialNo,
             d.QTY,
             d.UCCNo
         FROM DELETED d WITH (NOLOCK);

         INSERT INTO dbo.ReceiptSerialNo_DELLOG ( ReceiptSerialNoKey )
         SELECT ReceiptSerialNoKey
         FROM DELETED WITH (NOLOCK);

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Err message but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table ReceiptSerialNo Failed. (ntrReceiptSerialNoDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

   IF ( (SELECT COUNT(1) FROM Deleted WITH (NOLOCK) ) > 100 )    --kocy01
       AND NOT EXISTS (SELECT Code FROM dbo.CODELKUP WITH (NOLOCK) WHERE Listname = 'TrgUserID' AND Short = '1' AND Code = SUSER_NAME()) 
   BEGIN      
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68102   -- Should Be Set To The SQL Err message but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Failed On Table ReceiptSerialNo. Batch Delete not allow! (ntrReceiptSerialNoDelete)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
   END

   -- AYD01 STARTS
   IF (@n_continue = 1 or @n_continue = 2) 
      AND EXISTS (SELECT 1 FROM DELETED d WITH (NOLOCK) INNER JOIN dbo.ReceiptDetail rd WITH (NOLOCK) 
      ON d.ReceiptKey = rd.ReceiptKey AND d.ReceiptLineNumber = rd.ReceiptLineNumber AND rd.FinalizeFlag <> 'Y')
   BEGIN
      SELECT @n_continue = 3
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68104   -- Should Be Set To The SQL Err message but I don't know how to do so.
      SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Failed On Table ReceiptSerialNo: Not allowed to delete before finalizing. (ntrReceiptSerialNoDelete)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
   END
   --==============================================================   
   -- ✅ Reflect deleted ReceiptSerialNo QTY into Receipt Details
   --==============================================================
   IF (@n_continue = 1 or @n_continue = 2)
   BEGIN
      UPDATE rd
      SET rd.BeforeReceivedQty = rd.BeforeReceivedQty - ISNULL(d.QTY, 0)
         FROM dbo.ReceiptDetail rd WITH (NOLOCK)
      INNER JOIN DELETED d WITH (NOLOCK)
         ON d.ReceiptKey = rd.ReceiptKey AND d.ReceiptLineNumber = rd.ReceiptLineNumber
      WHERE rd.FinalizeFlag = 'Y'
         AND ISNULL(d.QTY, 0) <> 0
         AND rd.BeforeReceivedQty >= ISNULL(d.QTY, 0)

      IF @@ERROR <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68106
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + ': Update Failed On Table RECEIPTDETAIL. (ntrReceiptSerialNoDelete) ( SQLSvr MESSAGE='
               + LTRIM(RTRIM(@c_errmsg)) + ' ) '
      END
   END
   -- AYD01 ENDS

   IF @n_continue=3  -- Error Occured - Process And Return  
   BEGIN  
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt  
      BEGIN  
         ROLLBACK TRAN  
      END    
      execute nsp_logerror @n_err, @c_errmsg, "ntrReceiptSerialNoDelete"  
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

ALTER TABLE [dbo].[ReceiptSerialNo] ENABLE TRIGGER [ntrReceiptSerialNoDelete]
GO


