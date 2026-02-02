
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
/* 2025-10-13  1.2     AYD01        UWP-42138 Reflect deleted ReceiptSerialNo QTY into Receipt Details  */
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
      , @c_StorerKey       NVARCHAR(10) -- AYD01
      , @c_Facility        NVARCHAR(5)  -- AYD01
      , @n_DeductQty       INT          -- AYD01
      , @c_ReceiptKey      NVARCHAR(10) -- AYD01
      , @c_ReceiptLineNumber NVARCHAR(10) -- AYD01
      , @b_RCPTSNLOG       NVARCHAR(1)  -- AYD01
      , @n_BeforeReceivedQty INT        -- AYD01
   
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
   IF @n_continue IN (1, 2) 
      AND EXISTS (SELECT 1 FROM DELETED d WITH (NOLOCK) INNER JOIN dbo.ReceiptDetail rd WITH (NOLOCK) 
      ON d.ReceiptKey = rd.ReceiptKey AND d.ReceiptLineNumber = rd.ReceiptLineNumber AND rd.FinalizeFlag = 'Y')
   BEGIN
      SELECT @n_continue = 3
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68104   -- Should Be Set To The SQL Err message but I don't know how to do so.
      SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Failed On Table ReceiptSerialNo: Only allowed to delete before finalizing. (ntrReceiptSerialNoDelete)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
      GOTO QUIT
   END
   --==============================================================   
   -- ✅ Reflect deleted ReceiptSerialNo QTY into Receipt Details
   --==============================================================
   IF @n_continue IN (1, 2)
   BEGIN
      DECLARE CUR_SN CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT rd.StorerKey, r.facility, rs.ReceiptKey, rs.ReceiptLineNumber, rd.BeforeReceivedQty, SUM(rs.qty)
      FROM RECEIPTDETAIL rd (NOLOCK)
      JOIN RECEIPT r (NOLOCK) ON rd.ReceiptKey = r.ReceiptKey
      JOIN DELETED rs (NOLOCK) ON rd.ReceiptKey=rs.ReceiptKey AND rs.ReceiptLineNumber=rd.ReceiptLineNumber 
      GROUP BY rs.ReceiptKey, rs.ReceiptLineNumber, rd.StorerKey, r.Facility, rd.BeforeReceivedQty

      OPEN CUR_SN
      FETCH NEXT FROM CUR_SN INTO @c_StorerKey, @c_Facility, @c_ReceiptKey, @c_ReceiptLineNumber, @n_BeforeReceivedQty, @n_DeductQty  
      WHILE @@FETCH_STATUS <> -1 AND @n_continue IN (1, 2)
      BEGIN
         SELECT @b_RCPTSNLOG = SC.Authority FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey,'','RCPTSNLOG') AS SC
         IF @b_RCPTSNLOG = '1'
         BEGIN
            IF ISNULL(@n_BeforeReceivedQty, 0) < ISNULL(@n_DeductQty, 0)
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68105
               SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) 
                     + ': Delete Failed On Table RECEIPTSERIALNO, BeforeReceivedQty not tally (ntrReceiptSerialNoDelete) ( SQLSvr MESSAGE='
                     + LTRIM(RTRIM(@c_errmsg)) + ' ) '
            END

            UPDATE rd
            SET rd.BeforeReceivedQty = ISNULL(@n_BeforeReceivedQty, 0) - ISNULL(@n_DeductQty, 0)
               FROM dbo.ReceiptDetail rd WITH (NOLOCK)
            INNER JOIN DELETED d WITH (NOLOCK)
               ON d.ReceiptKey = rd.ReceiptKey AND d.ReceiptLineNumber = rd.ReceiptLineNumber
            WHERE rd.FinalizeFlag <> 'Y'
               AND ISNULL(@n_DeductQty, 0) <> 0
               AND rd.BeforeReceivedQty >= ISNULL(@n_DeductQty, 0)

            IF @@ERROR <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68106
               SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) 
                     + ': Update Failed On Table RECEIPTDETAIL. (ntrReceiptSerialNoDelete) ( SQLSvr MESSAGE='
                     + LTRIM(RTRIM(@c_errmsg)) + ' ) '
            END
         END
         FETCH NEXT FROM CUR_SN INTO @c_StorerKey, @c_Facility, @c_ReceiptKey, @c_ReceiptLineNumber, @n_BeforeReceivedQty, @n_DeductQty 
      END
      CLOSE CUR_SN
      DEALLOCATE CUR_SN
   END
   -- AYD01 ENDS

   QUIT: -- AYD01

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


