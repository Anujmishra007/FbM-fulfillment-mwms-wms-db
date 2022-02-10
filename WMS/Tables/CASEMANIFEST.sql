CREATE TABLE [dbo].[CASEMANIFEST]
(
[CaseId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_Sku] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_Loc] DEFAULT ('UNKNOWN'),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_Status] DEFAULT ('0'),
[ExpectedReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ExpectedReceiptKey] DEFAULT (' '),
[ExpectedPOKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ExpectedPOKey] DEFAULT (' '),
[ReceivedReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ReceivedReceiptKey] DEFAULT (' '),
[ReceivedPOKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ReceivedPOKey] DEFAULT (' '),
[ReceiptDate] [datetime] NOT NULL CONSTRAINT [DF_CASEMANIFEST_ReceiptDate] DEFAULT (getdate()),
[ExpectedClpOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ExpectedClpOrderKey] DEFAULT (' '),
[ShippedClpOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ShippedClpOrderKey] DEFAULT (' '),
[Qty] [int] NOT NULL CONSTRAINT [DF_CASEMANIFEST_Qty] DEFAULT ((0)),
[ShipStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ShipStatus] DEFAULT ('0'),
[Shipdate] [datetime] NOT NULL CONSTRAINT [DF_CASEMANIFEST_Shipdate] DEFAULT (getdate()),
[OSDCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_OSDCode] DEFAULT (' '),
[OSDQTY] [int] NOT NULL CONSTRAINT [DF_CASEMANIFEST_OSDQTY] DEFAULT ((0)),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ID] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CASEMANIFEST_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CASEMANIFEST_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CASEMANIFEST] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CASEMANIFEST] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CASEMANIFEST] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CASEMANIFEST] TO [NSQL]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/* 17-Mar-2009  TLTING     Change user_name() to SUSER_SNAME()          */
/* 24-Apr-2014  CSCHONG    Add Lottable06-15                            */

CREATE TRIGGER [dbo].[ntrCaseManifestAdd]
ON [dbo].[CASEMANIFEST]
FOR  INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @b_Success     INT -- Populated by calls to stored procedures - was the proc successful?
          ,@n_err         INT -- Error number returned by stored procedure or this trigger
          ,@n_err2        INT -- For Additional Error Detection
          ,@c_errmsg      NVARCHAR(250) -- Error message returned by stored procedure or this trigger
          ,@n_continue    INT
          ,@n_starttcnt   INT -- Holds the current transaction count
          ,@c_preprocess  NVARCHAR(250) -- preprocess
          ,@c_pstprocess  NVARCHAR(250) -- post process
          ,@n_cnt         INT
   
   SELECT @n_continue = 1
         ,@n_starttcnt = @@TRANCOUNT
   /* #INCLUDE <TRMAN1.SQL> */ 
   --     IF @n_continue = 1 or @n_continue = 2
   --     BEGIN
   --          UPDATE RECEIPTDETAIL
   --               SET  QtyExpected = QtyExpected +
   --                (select sum(inserted.qty) from inserted
   --                  where RECEIPTDETAIL.ReceiptKey = INSERTED.ExpectedReceiptKey
   --                    AND RECEIPTDETAIL.StorerKey = INSERTED.StorerKey
   --                    AND RECEIPTDETAIL.Sku = INSERTED.Sku
   --                    AND RECEIPTDETAIL.POKey = INSERTED.ExpectedPOKey)
   --                   FROM RECEIPTDETAIL, INSERTED I2
   --               WHERE RECEIPTDETAIL.ReceiptKey = I2.ExpectedReceiptKey
   --                    AND RECEIPTDETAIL.StorerKey = I2.StorerKey
   --                    AND RECEIPTDETAIL.Sku = I2.Sku
   --                    AND RECEIPTDETAIL.POKey = I2.ExpectedPOKey
   --          SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   --          IF @n_err <> 0
   --          BEGIN
   --               SELECT @n_continue = 3
   --
   --               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68601   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
   --               SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update ON Table RECEIPTDETAIL Failed. (ntrCaseManifestAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
   --
   --          END
   --     END
   
   BEGIN
      UPDATE RECEIPTDETAIL
      SET    QtyReceived = QtyReceived + (
                 SELECT SUM(INSERTED.qty)
                 FROM   INSERTED
                 WHERE  RECEIPTDETAIL.ReceiptKey = INSERTED.ReceivedReceiptKey
                 AND    receiptdetail.pokey = INSERTED.ReceivedPOKey
                 AND    receiptdetail.sku = INSERTED.sku
                 AND    receiptdetail.storerkey = INSERTED.storerkey
             )
      FROM   RECEIPTDETAIL
            ,INSERTED I1
      WHERE  RECEIPTDETAIL.ReceiptKey = I1.ReceivedReceiptKey
      AND    RECEIPTDETAIL.StorerKey = I1.StorerKey
      AND    RECEIPTDETAIL.Sku = I1.Sku
      AND    RECEIPTDETAIL.POKey = I1.ReceivedPOKey
      AND    I1.Status = "9"
      
      SELECT @n_err = @@ERROR
            ,@n_cnt = @@ROWCOUNT
      
      IF @n_err <> 0
      BEGIN
          SELECT @n_continue = 3
          SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                ,@n_err = 68602 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
          SELECT @c_errmsg = "NSQL" + CONVERT(CHAR(5) ,@n_err) + ": Update ON Table RECEIPTDETAIL Failed. (ntrCaseManifestAdd)" +
                 " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END
   END
   
   IF @n_continue = 1
   OR @n_continue = 2
   BEGIN
      DECLARE @c_storerkey NVARCHAR(15)
             ,@c_sku NVARCHAR(20)
             ,@n_qty INT
             ,@c_loc NVARCHAR(10)
             ,@d_effectivedate DATETIME
             ,@c_itrnkey NVARCHAR(10)
      
      DECLARE @c_controlbreak NVARCHAR(20)
      SELECT @c_controlbreak = SPACE(20)
      WHILE (1 = 1)
      BEGIN
          SET ROWCOUNT 1
          SELECT @c_controlbreak = caseid
          FROM   INSERTED
          WHERE  caseid > @c_controlbreak
          AND    INSERTED.Status = "9"
          AND    dbo.fnc_LTrim(dbo.fnc_RTrim(ReceivedReceiptKey)) IS NULL
          ORDER BY
                 caseid
          
          IF @@ROWCOUNT = 1
          BEGIN
             SET ROWCOUNT 0
             SELECT @c_storerkey = storerkey
                   ,@c_sku = sku
                   ,@n_qty = Qty
                   ,@c_loc = Loc
                   ,@d_effectivedate = GETDATE()
             FROM   INSERTED
             WHERE  caseid = @c_controlbreak
             AND    INSERTED.Status = "9"
             AND    dbo.fnc_LTrim(dbo.fnc_RTrim(ReceivedReceiptKey)) IS NULL
             
             IF @@ROWCOUNT = 1
             BEGIN
                 SELECT @b_success = 0
                 EXECUTE nspItrnAddDeposit
                 @n_ItrnSysId = NULL,
                 @c_StorerKey = @c_storerkey,
                 @c_Sku = @c_sku,
                 @c_Lot = "",
                 @c_ToLoc = @c_loc,
                 @c_ToID = "",
                 @c_Status = "",
                 @c_lottable01 = "",
                 @c_lottable02 = "",
                 @c_lottable03 = "",
                 @d_lottable04 = NULL,
                 @d_lottable05 = NULL,
                 @c_lottable06 = "", --(CS01)
                 @c_lottable07 = "", --(CS01)
                 @c_lottable08 = "", --(CS01)
                 @c_lottable09 = "", --(CS01)
                 @c_lottable10 = "", --(CS01)
                 @c_lottable11 = "", --(CS01)
                 @c_lottable12 = "", --(CS01)
                 @d_lottable13 = NULL, --(CS01)
                 @d_lottable14 = NULL, --(CS01)
                 @d_lottable15 = NULL, --(CS01)
                 @n_casecnt = 1,
                 @n_innerpack = 0,
                 @n_qty = @n_qty,
                 @n_pallet = 0,
                 @f_cube = 0,
                 @f_grosswgt = 0,
                 @f_netwgt = 0,
                 @f_otherunit1 = 0,
                 @f_otherunit2 = 0,
                 @c_SourceKey = @c_controlbreak,
                 @c_SourceType = "ntrCaseManifestAdd",
                 @c_PackKey = "",
                 @c_UOM = "",
                 @b_UOMCalc = 0,
                 @d_EffectiveDate = @d_effectiveDate,
                 @c_itrnkey = @c_itrnkey OUTPUT,
                 @b_Success = @b_Success OUTPUT,
                 @n_err = @n_err OUTPUT,
                 @c_errmsg = @c_errmsg OUTPUT
                 IF NOT @b_success = 1
                 BEGIN
                     SELECT @n_continue = 3
                     BREAK
                 END
             END
          END
          ELSE
          BEGIN
              BREAK
          END
      END
      SET ROWCOUNT 0
   END
   
   IF @n_continue = 1
   OR @n_continue = 2
   BEGIN
       UPDATE CASEMANIFEST
       SET    TrafficCop = NULL
             ,AddDate = GETDATE()
             ,AddWho = SUSER_SNAME()
             ,EditDate = GETDATE()
             ,EditWho = SUSER_SNAME()
       FROM   CASEMANIFEST
             ,INSERTED
       WHERE  CASEMANIFEST.CaseId = INSERTED.CaseId
       
       SELECT @n_err = @@ERROR
             ,@n_cnt = @@ROWCOUNT
       
       IF @n_err <> 0
       BEGIN
           SELECT @n_continue = 3
           SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                 ,@n_err = 68600 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
           SELECT @c_errmsg = "NSQL" + CONVERT(CHAR(5) ,@n_err) + ": Insert Failed On Table CASEMANIFEST. (nspCaseManifestAdd)" +
                  " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
       END
   END
   /* #INCLUDE <TRMAN2.SQL> */
   IF @n_continue = 3 -- Error Occured - Process And Return
   BEGIN
       IF @@TRANCOUNT = 1
       AND @@TRANCOUNT >= @n_starttcnt
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
       EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrCaseManifestAdd"
       RAISERROR (@c_errmsg ,16 ,1) WITH SETERROR -- SQL2012
       RETURN
   END
   ELSE
   BEGIN
       WHILE @@TRANCOUNT > @n_starttcnt
       BEGIN
           COMMIT TRAN
       END
   END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE TRIGGER [dbo].[ntrCaseManifestDelete]
 ON [dbo].[CASEMANIFEST]
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

 DECLARE @b_Success       int,       -- Populated by calls to stored procedures - was the proc successful?
 @n_err              int,       -- Error number returned by stored procedure or this trigger
 @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
 @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
 @n_starttcnt        int,       -- Holds the current transaction count
 @n_cnt              int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
 if (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END
      /* #INCLUDE <TRMAND1.SQL> */     
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS (SELECT * FROM DELETED WHERE Status = "9")
 or EXISTS (SELECT * FROM DELETED WHERE ShipStatus = "9")
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 68800
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": DELETE rejected. CASEMANIFEST.Status = 'Received' or 'Shipped'. (ntrCaseManifestDelete)"
 END
 END
 --      IF @n_continue = 1 or @n_continue = 2
 --      BEGIN
 --           UPDATE RECEIPTDETAIL
 --                SET  QtyExpected = QtyExpected -
 --                     (select sum(DELETED.Qty) from DELETED
 --                           WHERE RECEIPTDETAIL.ReceiptKey = DELETED.ExpectedReceiptKey
 --                             AND RECEIPTDETAIL.StorerKey = DELETED.StorerKey
 --                             AND RECEIPTDETAIL.Sku = DELETED.Sku
 --                             AND RECEIPTDETAIL.POKey = DELETED.ExpectedPOKey)
 --                FROM RECEIPTDETAIL, DELETED D1
 --                WHERE RECEIPTDETAIL.ReceiptKey = D1.ExpectedReceiptKey
 --                     AND RECEIPTDETAIL.StorerKey = D1.StorerKey
 --                     AND RECEIPTDETAIL.Sku = D1.Sku
 --                     AND RECEIPTDETAIL.POKey = D1.ExpectedPOKey
 --           SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 --           IF @n_err <> 0
 --           BEGIN
 --                SELECT @n_continue = 3
 --                
 --                SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68801   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 --                SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update ON Table RECEIPTDETAIL Failed. (ntrCaseManifestDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 --                
 --           END
 --      END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 DELETE PalletDetail
 FROM PalletDetail, Pallet, DELETED
 WHERE PalletDetail.CaseID = DELETED.CaseId
 AND Pallet.PalletKey = PalletDetail.PalletKey
 AND Pallet.Status <> "9"
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68802   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Cascade Delete ON Table PalletDetail Failed. (ntrCaseManifestDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
      /* #INCLUDE <TRMAND2.SQL> */
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrCaseManifestDelete"
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

/* Date         Author    Ver.  Purposes                                         */  
/* 17-Mar-2009  TLTING    1.1   Change user_name() to SUSER_SNAME()              */
/* 28-Oct-2013  TLTING    1.2   Review Editdate column update                    */
/* 24-Apr-2014  CSCHONG   1.3   Add Lottable06-15                                */

CREATE TRIGGER [dbo].[ntrCaseManifestUpdate]  
 ON  [dbo].[CASEMANIFEST]  
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

 DECLARE @b_debug int  
 SELECT @b_debug = 0  
 DECLARE  
 @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?  
 ,         @n_err                int       -- Error number returned by stored procedure or this trigger  
 ,         @n_err2 int              -- For Additional Error Detection  
 ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger  
 ,         @n_continue int                   
 ,         @n_starttcnt int                -- Holds the current transaction count  
 ,         @c_preprocess NVARCHAR(250)         -- preprocess  
 ,         @c_pstprocess NVARCHAR(250)         -- post process  
 ,         @n_cnt int                    
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  
 IF UPDATE(TrafficCop)  
 BEGIN  
 SELECT @n_continue = 4   
 END  
 IF UPDATE(ArchiveCop)  
 BEGIN  
 SELECT @n_continue = 4   
 END  
      /* #INCLUDE <TRMANU1.SQL> */       
 IF @n_continue=1 or @n_continue=2  
 BEGIN  
 IF @b_debug = 1  
 BEGIN  
 SELECT "Reject UPDATE when CASEMANIFEST.Status already 'Received'"  
 END  
 IF EXISTS(SELECT * FROM DELETED WHERE Status = "9")  
 AND (     UPDATE(Storerkey)  
 OR UPDATE(Sku)  
 OR UPDATE(ExpectedPOKey)  
 OR UPDATE(ExpectedReceiptKey)  
 OR UPDATE(ReceivedPOKey)  
 OR UPDATE(ReceivedReceiptKey)  
 OR UPDATE(Status)  
 OR UPDATE(Qty)  
 )  
 BEGIN  
 SELECT @n_continue=3  
 SELECT @n_err=68700  
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE rejected. CASEMANIFEST.Status = 'RECEIVED'. (ntrCaseManifestUpdate)"  
 END  
 END  
 IF @n_continue=1 or @n_continue=2  
 BEGIN  
 IF @b_debug = 1  
 BEGIN  
 SELECT "Reject UPDATE when CASEMANIFEST.Status already 'SHIPPED'"  
 END  
 IF EXISTS(SELECT * FROM DELETED WHERE ShipStatus = "9")  
 AND (     UPDATE(Storerkey)  
 OR UPDATE(Sku)  
 OR UPDATE(ExpectedPOKey)  
 OR UPDATE(ExpectedReceiptKey)  
 OR UPDATE(ReceivedPOKey)  
 OR UPDATE(ReceivedReceiptKey)  
 OR UPDATE(Status)  
 OR UPDATE(ShipStatus)  
 OR UPDATE(Qty)  
 OR UPDATE(ExpectedCLPOrderKey)  
 OR UPDATE(ShippedCLPOrderKey)  
 )  
 BEGIN  
 SELECT @n_continue=3  
 SELECT @n_err=68701  
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE rejected. CASEMANIFEST.ShipStatus = 'SHIPPED'. (ntrCaseManifestUpdate)"  
 END  
 END  
 IF @n_continue = 1 or @n_continue = 2  
 BEGIN  
 IF UPDATE(caseid)  
 BEGIN  
 IF EXISTS(Select Palletkey FROM palletdetail,deleted  
 where palletdetail.caseid = deleted.caseid)  
 BEGIN  
 UPDATE PALLETDETAIL  with (ROWLOCK)
 SET PALLETDETAIL.CaseId = INSERTED.CaseId,
      EditDate = GETDATE(),
      EditWho = SUSER_SNAME()  
 FROM PALLETDETAIL, INSERTED, DELETED  
 WHERE PALLETDETAIL.CaseId = DELETED.CaseId  
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
 IF @n_err <> 0  
 BEGIN  
 SELECT @n_continue = 3  
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68706   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE rejected. The CaseId Exists but NOT Updated In The Pallet Tables. (ntrCaseManifestUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTRIM(dbo.fnc_RTRIM(@c_errmsg)) + " ) "  
 END  
 END  
 END  
 END  
 -- IF @n_continue = 1 or @n_continue = 2  
 --      BEGIN  
 --           UPDATE RECEIPTDETAIL  
 --                SET QtyExpected = QtyExpected -  
 --                 (select sum(DELETED.Qty) from deleted  
 --                   where RECEIPTDETAIL.ReceiptKey = DELETED.ExpectedReceiptKey  
 --                     AND RECEIPTDETAIL.StorerKey = DELETED.StorerKey  
 --                     AND RECEIPTDETAIL.Sku = DELETED.Sku  
 --                     AND RECEIPTDETAIL.POKey = DELETED.ExpectedPOKey)  
 --                FROM RECEIPTDETAIL, DELETED D1  
 --                WHERE RECEIPTDETAIL.ReceiptKey = D1.ExpectedReceiptKey  
 --                     AND RECEIPTDETAIL.StorerKey = D1.StorerKey  
 --                     AND RECEIPTDETAIL.Sku = D1.Sku  
 --                     AND RECEIPTDETAIL.POKey = D1.ExpectedPOKey  
 --           SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
 --           IF @n_err <> 0  
 --           BEGIN  
 --    SELECT @n_continue = 3  
 --                  
 --                SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68702   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
 --                SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update ON Table RECEIPTDETAIL Failed. (ntrCaseManifestUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTRIM(dbo.fnc_RTRIM(@c_errmsg)) + " ) "  
 --                  
 --           END  
 --      END  
 --      IF @n_continue = 1 or @n_continue = 2  
 --      BEGIN  
 --           UPDATE RECEIPTDETAIL  
 --                SET QtyExpected = QtyExpected +  
 --                 (select sum(INSERTED.Qty) from inserted  
 --                 WHERE RECEIPTDETAIL.ReceiptKey = INSERTED.ExpectedReceiptKey  
 --                     AND RECEIPTDETAIL.StorerKey = INSERTED.StorerKey  
 --                     AND RECEIPTDETAIL.Sku = INSERTED.Sku  
 --                     AND RECEIPTDETAIL.POKey = INSERTED.ExpectedPOKey)  
 --                FROM RECEIPTDETAIL, INSERTED I1  
 --                WHERE RECEIPTDETAIL.ReceiptKey = I1.ExpectedReceiptKey  
 --                     AND RECEIPTDETAIL.StorerKey = I1.StorerKey  
 --                     AND RECEIPTDETAIL.Sku = I1.Sku  
 --                     AND RECEIPTDETAIL.POKey = I1.ExpectedPOKey  
 --           SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
 --           IF @n_err <> 0  
 --           BEGIN  
 --                SELECT @n_continue = 3  
 --                  
 --                SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68703   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
 --                SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update ON Table RECEIPTDETAIL Failed. (ntrCaseManifestUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTRIM(dbo.fnc_RTRIM(@c_errmsg)) + " ) "  
 --                  
 --           END  
 --      END  
 IF @n_continue = 1 or @n_continue = 2  
 BEGIN  
 IF UPDATE(Status)  
 BEGIN  
 UPDATE RECEIPTDETAIL  
 SET QtyReceived = QtyReceived +  
 (select sum(INSERTED.Qty)
 from inserted  
 WHERE   RECEIPTDETAIL.ReceiptKey = INSERTED.ReceivedReceiptKey  
 AND RECEIPTDETAIL.StorerKey = INSERTED.StorerKey  
 AND RECEIPTDETAIL.Sku = INSERTED.Sku  
 AND RECEIPTDETAIL.POKey = INSERTED.ReceivedPOKey  
 AND INSERTED.Status = "9"),
     EditDate = GETDATE(),   --tlting
     EditWho = SUSER_SNAME()  
 FROM RECEIPTDETAIL, INSERTED I2  
 WHERE  
 RECEIPTDETAIL.ReceiptKey = I2.ReceivedReceiptKey  
 AND RECEIPTDETAIL.StorerKey = I2.StorerKey  
 AND RECEIPTDETAIL.Sku = I2.Sku  
 AND RECEIPTDETAIL.POKey = I2.ReceivedPOKey  
 AND I2.Status = "9"  
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
 IF @n_err <> 0  
 BEGIN  
 SELECT @n_continue = 3  
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68704   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update ON Table RECEIPTDETAIL Failed. (ntrCaseManifestUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTRIM(dbo.fnc_RTRIM(@c_errmsg)) + " ) "  
 END  
 END  
 END  
 IF @n_continue = 1 or @n_continue = 2  
 BEGIN  
 DECLARE @c_storerkey NVARCHAR(15), @c_sku NVARCHAR(20), @n_qty int ,  
 @c_loc NVARCHAR(10), @d_effectivedate datetime, @c_itrnkey NVARCHAR(10)  
 DECLARE @c_controlbreak NVARCHAR(20)  
 SELECT @c_controlbreak = SPACE(20)  
 WHILE (1=1)  
 BEGIN  
 SET ROWCOUNT 1  
 SELECT @c_controlbreak = inserted.caseid FROM INSERTED,DELETED  
 WHERE inserted.caseid > @c_controlbreak  
 AND INSERTED.Status = "9"  
 AND dbo.fnc_LTRIM(dbo.fnc_RTRIM(INSERTED.ReceivedReceiptKey)) IS NULL  
 AND DELETED.Status < "9"  
 ORDER BY INSERTED.caseid  
 IF @@ROWCOUNT = 1  
 BEGIN  
 SET ROWCOUNT 0  
 SELECT @c_storerkey = INSERTED.storerkey ,  
 @c_sku = INSERTED.sku ,  
 @n_qty = INSERTED.Qty ,  
 @c_loc = INSERTED.Loc ,  
 @d_effectivedate = getdate()  
 FROM INSERTED , DELETED  
 WHERE INSERTED.caseid = @c_controlbreak  
 AND INSERTED.Status = "9"  
 AND dbo.fnc_LTRIM(dbo.fnc_RTRIM(INSERTED.ReceivedReceiptKey)) IS NULL  
 AND DELETED.Status < "9"  
 IF @@ROWCOUNT = 1  
 BEGIN  
 SELECT @b_success = 0  
 EXECUTE nspItrnAddDeposit  
 @n_ItrnSysId  = NULL,  
 @c_StorerKey  = @c_storerkey,  
 @c_Sku        = @c_sku,  
 @c_Lot        = "",  
 @c_ToLoc      = @c_loc,  
 @c_ToID       = "",  
 @c_Status     = "",  
 @c_lottable01 = "",  
 @c_lottable02 = "",  
 @c_lottable03 = "",  
 @d_lottable04 = NULL,  
 @d_lottable05 = NULL, 
 @c_lottable06 = "",    --(CS01)
 @c_lottable07 = "",		--(CS01)
 @c_lottable08 = "",		--(CS01)
 @c_lottable09 = "",		--(CS01)
 @c_lottable10 = "",		--(CS01)
 @c_lottable11 = "",		--(CS01)
 @c_lottable12 = "",		--(CS01)
 @d_lottable13 = NULL,	--(CS01)
 @d_lottable14 = NULL,	--(CS01)
 @d_lottable15 = NULL,	--(CS01) 
 @n_casecnt    = 1,  
 @n_innerpack  = 0,  
 @n_qty        = @n_qty,  
 @n_pallet     = 0,  
 @f_cube       = 0,  
 @f_grosswgt   = 0,  
 @f_netwgt     = 0,  
 @f_otherunit1 = 0,  
 @f_otherunit2 = 0,  
 @c_SourceKey  = @c_controlbreak,  
 @c_SourceType = "ntrCaseManifestUpdate",  
 @c_PackKey    = "",  
 @c_UOM        = "",  
 @b_UOMCalc    = 0,  
 @d_EffectiveDate = @d_effectiveDate,  
 @c_itrnkey    = @c_itrnkey OUTPUT,  
 @b_Success    = @b_Success OUTPUT,  
 @n_err        = @n_err     OUTPUT,  
 @c_errmsg     = @c_errmsg  OUTPUT  
 IF NOT @b_success = 1  
 BEGIN  
 SELECT @n_continue = 3  
 BREAK  
 END  
 END  
 END  
 ELSE  
 BEGIN  
 BREAK  
 END  
 END  
 SET ROWCOUNT 0  
 END  
 IF (@n_continue = 1 or @n_continue=2  ) AND NOT UPDATE(EditDate)
 BEGIN  
 IF @b_debug = 1  
 BEGIN  
 SELECT "Update EditDate and EditWho"  
 END  
 UPDATE CASEMANIFEST with (ROWLOCK)
 SET  EditDate = GETDATE(),  
 EditWho = SUSER_SNAME()  
 FROM CASEMANIFEST, INSERTED  
 WHERE CASEMANIFEST.CaseId = INSERTED.CaseId  
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
 IF @n_err <> 0  
 BEGIN  
 SELECT @n_continue = 3  
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=68705   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table CASEMANIFEST. (ntrCaseManifestUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTRIM(dbo.fnc_RTRIM(@c_errmsg)) + " ) "  
 END  
 END  
      /* #INCLUDE <TRMANU2.SQL> */  
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
 execute nsp_logerror @n_err, @c_errmsg, "ntrCaseManifestUpdate"  
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
ALTER TABLE [dbo].[CASEMANIFEST] WITH NOCHECK ADD CONSTRAINT [CK_CASEMANIFEST_CaseId] CHECK ((NOT [CaseId]=' '))
GO
ALTER TABLE [dbo].[CASEMANIFEST] WITH NOCHECK ADD CONSTRAINT [CK_CASMAN_ShipStatus] CHECK (([ShipStatus]>='0' AND [ShipStatus]<='9'))
GO
ALTER TABLE [dbo].[CASEMANIFEST] WITH NOCHECK ADD CONSTRAINT [CK_CASMAN_Status] CHECK (([Status]>='0' AND [Status]<='9'))
GO
ALTER TABLE [dbo].[CASEMANIFEST] ADD CONSTRAINT [PKCASEMANIFEST] PRIMARY KEY CLUSTERED ([CaseId]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CASEMANIFEST] ADD CONSTRAINT [FK_CASEMANIFEST_LOC_01] FOREIGN KEY ([Loc]) REFERENCES [dbo].[LOC] ([Loc])
GO
ALTER TABLE [dbo].[CASEMANIFEST] WITH NOCHECK ADD CONSTRAINT [FK_CASEMANIFEST_SKU_01] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Case ID', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'CaseId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying expected CLP order.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ExpectedClpOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Expected Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ExpectedPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Expected Receipt.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ExpectedReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated to case manifest.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of receipt issued.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ReceiptDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Received Purchase Orders. ', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ReceivedPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Received Receipt.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ReceivedReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of shipping.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'Shipdate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying shipped CLP order.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ShippedClpOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'TrafficCop'
GO
