CREATE TABLE [dbo].[CCDetail]
(
[CCKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CCDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CCSheetNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_CCSheetNo] DEFAULT (' '),
[TagNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_TagNo] DEFAULT (' '),
[Storerkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_Sku] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_Lot] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_Loc] DEFAULT (' '),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_id] DEFAULT (' '),
[SystemQty] [int] NOT NULL CONSTRAINT [DF_CCDetail_SystemQty] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_CCDetail_Qty] DEFAULT ((0)),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[FinalizeFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_FinalizeFlag] DEFAULT ('N'),
[Qty_Cnt2] [int] NOT NULL CONSTRAINT [DF_CCDetail_Qty_Cnt2] DEFAULT ((0)),
[Lottable01_Cnt2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02_Cnt2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03_Cnt2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04_Cnt2] [datetime] NULL,
[Lottable05_Cnt2] [datetime] NULL,
[FinalizeFlag_Cnt2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_FinalizeFlag_Cnt2] DEFAULT ('N'),
[Qty_Cnt3] [int] NULL CONSTRAINT [DF_CCDetail_Qty_Cnt3] DEFAULT ((0)),
[Lottable01_Cnt3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02_Cnt3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03_Cnt3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04_Cnt3] [datetime] NULL,
[Lottable05_Cnt3] [datetime] NULL,
[FinalizeFlag_Cnt3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_FinalizeFlag_Cnt3] DEFAULT ('N'),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_Status] DEFAULT ('0'),
[StatusMsg] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_StatusMsg] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CCDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CCDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CCDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[RefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDETAIL_REFNO] DEFAULT (' '),
[EditDate_Cnt1] [datetime] NULL,
[EditWho_Cnt1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate_Cnt2] [datetime] NULL,
[EditWho_Cnt2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate_Cnt3] [datetime] NULL,
[EditWho_Cnt3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Counted_Cnt1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDETAIL_Counted_Cnt1] DEFAULT ('0'),
[Counted_Cnt2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDETAIL_Counted_Cnt2] DEFAULT ('0'),
[Counted_Cnt3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDETAIL_Counted_Cnt3] DEFAULT ('0'),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Lottable06_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable06_Cnt2] DEFAULT (''),
[Lottable07_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable07_Cnt2] DEFAULT (''),
[Lottable08_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable08_Cnt2] DEFAULT (''),
[Lottable09_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable09_Cnt2] DEFAULT (''),
[Lottable10_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable10_Cnt2] DEFAULT (''),
[Lottable11_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable11_Cnt2] DEFAULT (''),
[Lottable12_Cnt2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable12_Cnt2] DEFAULT (''),
[Lottable13_Cnt2] [datetime] NULL,
[Lottable14_Cnt2] [datetime] NULL,
[Lottable15_Cnt2] [datetime] NULL,
[Lottable06_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable06_Cnt3] DEFAULT (''),
[Lottable07_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable07_Cnt3] DEFAULT (''),
[Lottable08_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable08_Cnt3] DEFAULT (''),
[Lottable09_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable09_Cnt3] DEFAULT (''),
[Lottable10_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable10_Cnt3] DEFAULT (''),
[Lottable11_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable11_Cnt3] DEFAULT (''),
[Lottable12_Cnt3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CCDetail_Lottable12_Cnt3] DEFAULT (''),
[Lottable13_Cnt3] [datetime] NULL,
[Lottable14_Cnt3] [datetime] NULL,
[Lottable15_Cnt3] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
  
/************************************************************************/  
/* Trigger: ntrCCDetailDelete                                           */  
/* Creation Date:14-Aug-2009                                            */  
/* Copyright: IDS                                                       */  
/* Written by:TLTing                                                    */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author     Ver   Purposes                               */  
/*  9-Jun-2011  KHLim01    1.1   Insert Delete log                      */
/* 14-Jul-2011  KHLim02    1.2   GetRight for Delete log                */
/* 23-May-2012  TLTING02         DM Data integrity - insert dellog B4   */
/*                               trafficCop                             */
/* 07-May-2014  TKLIM      1.3   Added Lottables 06-15                  */
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrCCDetailDelete]  
ON [dbo].[CCDetail]  
FOR DELETE  
AS  
BEGIN  
   IF @@ROWCOUNT = 0  
   BEGIN  
      RETURN  
   END  
  
   SET NOCOUNT ON   -- SQL 2005 Standard  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @b_Success  int,       -- Populated by calls to stored procedures - was the proc successful?  
   @n_err              int,       -- Error number returned by stored procedure or this trigger  
   @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger  
   @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing  
   @n_starttcnt        int,       -- Holds the current transaction count  
   @n_cnt              int        -- Holds @@ROWCOUNT  
  ,@c_authority        NVARCHAR(1)  -- KHLim02
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   /* #INCLUDE <TRODD1.SQL> */  
   IF (SELECT COUNT(*) FROM DELETED) =  
      (SELECT COUNT(*) FROM DELETED WHERE DELETED.ARCHIVECOP = '9')  
   BEGIN  
      SELECT @n_continue = 4  
   END  
   
   --tlting02
   -- Start (KHLim01) 
   IF EXISTS ( SELECT 1 FROM DELETED WHERE [Status] <> '9' ) AND (@n_continue = 1 or @n_continue = 2)
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
               ,@c_errmsg = 'ntrCCDETAILDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.CCDETAIL_DELLOG ( CCDetailKey )
         SELECT CCDetailKey FROM DELETED
         WHERE [Status] <> '9'

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 62602   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table CCDETAIL Failed. (ntrCCDETAILDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END
   -- End (KHLim01) 

   IF @n_continue = 1 or @n_continue = 2
   BEGIN  
      IF EXISTS(SELECT 1 FROM DEL_CCDETAIL CC  
                JOIN DELETED ON CC.CCDetailKey = DELETED.CCDetailKey )  
      BEGIN  
         DELETE DEL_CCDETAIL  
         FROM DEL_CCDETAIL CC  
                JOIN DELETED ON CC.CCDetailKey = DELETED.CCDetailKey  
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
         IF @n_err <> 0  
         BEGIN  
            SELECT @n_continue = 3  
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 62600   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete DEL_CCDETAIL Failed. (ntrCCDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "  
         END  
      END  
  
      INSERT INTO DEL_CCDETAIL(CCKey, CCDetailKey, CCSheetNo, TagNo, Storerkey, Sku, Lot, Loc, Id, SystemQty,  
                  Qty, Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, FinalizeFlag, 
                  Qty_Cnt2, Lottable01_Cnt2, Lottable02_Cnt2, Lottable03_Cnt2, Lottable04_Cnt2, Lottable05_Cnt2, FinalizeFlag_Cnt2,
                  Qty_Cnt3, Lottable01_Cnt3, Lottable02_Cnt3, Lottable03_Cnt3, Lottable04_Cnt3, Lottable05_Cnt3, FinalizeFlag_Cnt3, 
                  Status, StatusMsg, AddDate, AddWho, EditDate, EditWho,  
                  TrafficCop, ArchiveCop, RefNo, EditDate_Cnt1, EditWho_Cnt1, EditDate_Cnt2,  
                  EditWho_Cnt2, EditDate_Cnt3, EditWho_Cnt3, Counted_Cnt1, Counted_Cnt2, Counted_Cnt3,
                  Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
                  Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
                  Lottable06_Cnt2, Lottable07_Cnt2, Lottable08_Cnt2, Lottable09_Cnt2, Lottable10_Cnt2, 
                  Lottable11_Cnt2, Lottable12_Cnt2, Lottable13_Cnt2, Lottable14_Cnt2, Lottable15_Cnt2,
                  Lottable06_Cnt3, Lottable07_Cnt3, Lottable08_Cnt3, Lottable09_Cnt3, Lottable10_Cnt3, 
                  Lottable11_Cnt3, Lottable12_Cnt3, Lottable13_Cnt3, Lottable14_Cnt3, Lottable15_Cnt3)  
      SELECT CCKey, CCDetailKey, CCSheetNo, TagNo, Storerkey, Sku, Lot, Loc, Id, SystemQty,   
                  Qty,Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, FinalizeFlag, 
                  Qty_Cnt2, Lottable01_Cnt2, Lottable02_Cnt2, Lottable03_Cnt2, Lottable04_Cnt2, Lottable05_Cnt2, FinalizeFlag_Cnt2,
                  Qty_Cnt3, Lottable01_Cnt3, Lottable02_Cnt3, Lottable03_Cnt3, Lottable04_Cnt3, Lottable05_Cnt3, FinalizeFlag_Cnt3, 
                  Status, StatusMsg, getdate(), suser_sname(), getdate(), suser_sname(),  
                  TrafficCop, ArchiveCop, RefNo, EditDate_Cnt1, EditWho_Cnt1, EditDate_Cnt2,  
                  EditWho_Cnt2, EditDate_Cnt3, EditWho_Cnt3, Counted_Cnt1, Counted_Cnt2, Counted_Cnt3,
                  Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
                  Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
                  Lottable06_Cnt2, Lottable07_Cnt2, Lottable08_Cnt2, Lottable09_Cnt2, Lottable10_Cnt2, 
                  Lottable11_Cnt2, Lottable12_Cnt2, Lottable13_Cnt2, Lottable14_Cnt2, Lottable15_Cnt2,
                  Lottable06_Cnt3, Lottable07_Cnt3, Lottable08_Cnt3, Lottable09_Cnt3, Lottable10_Cnt3, 
                  Lottable11_Cnt3, Lottable12_Cnt3, Lottable13_Cnt3, Lottable14_Cnt3, Lottable15_Cnt3 
      FROM DELETED  
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 62600   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert DEL_CCDETAIL Failed. (ntrCCDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "  
      END  
   END  
   
   /* #INCLUDE <TRODD2.SQL> */  
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrCCDetailDelete"  
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

/************************************************************************/  
/* Trigger: ntrCCDetailUpdate                                           */  
/* Creation Date:                                                       */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  Adjustment Header Update Transaction                       */  
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
/* Called By: When update records                                       */  
/*                                                                      */  
/* PVCS Version: 1.2                                                    */  
/*                                                                      */  
/* Version: 6.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Purposes                                      */  
/* 08-July-2005  Vicky    Add STKTAKELOG as Configkey for Interface     */  
/* 10-Nov-2005  Shong     Performance Tuning (SHONG_20051110)           */  
/* 02-Mar-2009  TLTING    SOS130316 update SKU.CycleCountDate tlting01  */  
/* 23 May 2012  TLTING02  DM integrity - add update editdate B4         */
/*                        TrafficCop for status < '9'                   */ 
/* 28-Oct-2013  TLTING    Review Editdate column update                 */
/* 21-Apr-2017  Ung       Fix recompile                                 */
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrCCDetailUpdate] ON [dbo].[CCDetail]   
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
   
   DECLARE @n_continue int  
         , @b_success  int       -- Populated by calls to stored procedures - was the proc successful?  
     , @n_err      int       -- Error number returned by stored procedure or this trigger    
     , @c_errmsg   NVARCHAR(250) -- Error message returned by stored procedure or this trigger   
  
 SELECT @n_continue = 1  

 IF UPDATE(ArchiveCop)  
 BEGIN  
    SELECT @n_continue = 4 /* No error but skip the update */  
 END   
  
 -- tlting02
 IF EXISTS ( SELECT 1 FROM INSERTED, DELETED 
               Where INSERTED.CCDETAILKEY = DELETED.CCDETAILKEY
               AND ( INSERTED.[Status] < '9' OR DELETED.[Status] < '9' ) ) 
       AND ( @n_continue = 1 or @n_continue = 2 )
       AND NOT UPDATE(EditDate)
 BEGIN
 	 UPDATE CCDETAIL with (ROWLOCK)
 	 SET EditDate = GETDATE(), EditWho = Suser_Sname(),
        TrafficCop = NULL
	 FROM CCDETAIL ,	INSERTED, DELETED 
 	 WHERE CCDETAIL.CCDETAILKEY = INSERTED.CCDETAILKEY
 	 AND   INSERTED.CCDETAILKEY = DELETED.CCDETAILKEY
    AND   ( INSERTED.[Status] < '9' OR DELETED.[Status] < '9' )

 END
  
 IF UPDATE(TrafficCop)  
 BEGIN  
    SELECT @n_continue = 4 /* No error but skip the update */  
 END  
   
   -- Added By Vicky 08 July 2005 - STKTAKELOG- Start  
 IF @n_continue = 1 or @n_continue = 2   
 BEGIN  
        DECLARE  @c_CCKey            NVARCHAR(10)  
             , @c_Storerkey        NVARCHAR(20)  
            , @c_finalizecnt3flag NVARCHAR(1)  
               , @c_finalizeflag     NVARCHAR(1)  
               , @c_STKTAKELOG       NVARCHAR(1)  
               , @c_sku              NVARCHAR(20)    -- tlting01  
     
         SELECT @c_STKTAKELOG = '0'  
   
       SELECT TOP 1 
          @c_CCKey = INSERTED.CCKey,  
          @c_Storerkey = INSERTED.Storerkey,  
          @c_sku       = INSERTED.Sku,    -- tlting01  
          @c_finalizecnt3flag = CCDETAIL.FinalizeFlag_Cnt3,  
          @c_finalizeflag = CCDETAIL.FinalizeFlag  
       FROM  CCDETAIL CCDETAIL (NOLOCK), INSERTED,  DELETED  
     WHERE CCDETAIL.CCKey = INSERTED.CCKey  
     AND   INSERTED.CCKey = DELETED.CCKey  
  
       IF @c_finalizecnt3flag = 'Y'  
       BEGIN  
         EXECUTE nspGetRight  
                   NULL,       -- facility  
                 @c_Storerkey, -- Storerkey  
                 NULL,   -- Sku  
                 'STKTAKELOG', -- Configkey  
                   @b_success     OUTPUT,  
                   @c_STKTAKELOG  OUTPUT,  
                   @n_err         OUTPUT,  
               @c_errmsg      OUTPUT  
  
          IF @b_success <> 1  
          BEGIN  
             SELECT @n_continue = 3  
             SELECT @c_errmsg = 'ntrCCDetailUpdate' + dbo.fnc_RTrim(@c_errmsg)  
          END  
          ELSE IF @c_STKTAKELOG = '1'  
          BEGIN  
              EXEC ispGenTransmitLog3 'STKTAKELOG', @c_CCKey, '', @c_Storerkey, ''   
                 , @b_success OUTPUT  
                 , @n_err OUTPUT  
                 , @c_errmsg OUTPUT  
  
             IF @b_success <> 1  
              BEGIN  
                  SELECT @n_continue = 3  
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63811   -- should be set to the sql errmessage but i don't know how to do so.  
               SELECT @c_errmsg = 'nsql' + CONVERT(CHAR(5),@n_err) + ': Unable To Obtain LogKey. (ntrCCDetailUpdate)' + ' ( ' + ' sqlsvr message=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
              END  
         END -- @c_STKTAKELOG = '1'  
           
      END -- @c_FinalizedFlag = 'Y'  
        
       -- tlting01 start  
--       IF EXISTS ( SELECT 1  
--                   FROM  CCDETAIL CCDETAIL (NOLOCK), INSERTED,  DELETED  
--                 WHERE CCDETAIL.CCDETAILKey = INSERTED.CCDETAILKey  
--                 AND   INSERTED.CCDETAILKey = DELETED.CCDETAILKey  
--                 AND   ( ( INSERTED.FinalizeFlag <> DELETED.FinalizeFlag AND   INSERTED.FinalizeFlag = 'Y' )  
--                 OR   ( INSERTED.FinalizeFlag_Cnt2 <> DELETED.FinalizeFlag_Cnt2 AND   INSERTED.FinalizeFlag_Cnt2 = 'Y' )  
--                 OR   ( INSERTED.FinalizeFlag_Cnt3 <> DELETED.FinalizeFlag_Cnt3 AND   INSERTED.FinalizeFlag_Cnt3 = 'Y' )   ))  
         IF @n_continue = 1 or @n_continue = 2   
         BEGIN  
            DECLARE CUR_CCDUPDATE CURSOR LOCAL READ_ONLY FAST_FORWARD FOR   
            SELECT DISTINCT CCDETAIL.sku   
          FROM  CCDETAIL CCDETAIL WITH (NOLOCK), INSERTED,  DELETED  
        WHERE CCDETAIL.CCDETAILKey = INSERTED.CCDETAILKey  
           AND   INSERTED.CCDETAILKey = DELETED.CCDETAILKey  
           AND   ( ( INSERTED.FinalizeFlag <> DELETED.FinalizeFlag AND   INSERTED.FinalizeFlag = 'Y' )  
              OR   ( INSERTED.FinalizeFlag_Cnt2 <> DELETED.FinalizeFlag_Cnt2 AND   INSERTED.FinalizeFlag_Cnt2 = 'Y' )  
              OR   ( INSERTED.FinalizeFlag_Cnt3 <> DELETED.FinalizeFlag_Cnt3 AND   INSERTED.FinalizeFlag_Cnt3 = 'Y' )   )  
            OPEN CUR_CCDUPDATE  
            FETCH NEXT FROM CUR_CCDUPDATE INTO @c_sku  
            WHILE @@FETCH_STATUS <> -1  
            BEGIN  
               UPDATE SKU with (RowLock)  
               SET LastCycleCount = GETDATE(),
                  EditDate = GETDATE(),   --tlting
                  EditWho = SUSER_SNAME()  
               WHERE SKU.Storerkey = @c_Storerkey  
                 AND SKU.Sku = @c_sku  
  
               FETCH NEXT FROM CUR_CCDUPDATE INTO @c_sku  
            END  
            CLOSE CUR_CCDUPDATE  
            DEALLOCATE CUR_CCDUPDATE  
       END   
       --tlting01 end  
           
    END -- Continue = 1 -- End STKTAKELOG  
  
END  
GO
ALTER TABLE [dbo].[CCDetail] ADD CONSTRAINT [PKCCDETAIL] PRIMARY KEY NONCLUSTERED ([CCDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_CCDetail_CCKey] ON [dbo].[CCDetail] ([CCKey], [CCDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CCDetail_CCKey_LOC] ON [dbo].[CCDetail] ([CCKey], [Loc]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CCDetail_LOC] ON [dbo].[CCDetail] ([Loc], [CCKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CCDetail_01] ON [dbo].[CCDetail] ([RefNo], [Storerkey], [Sku]) INCLUDE ([Status]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[CCDetail] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[CCDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CCDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CCDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CCDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Cycle Count Detail.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'CCDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Cycle Count.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'CCKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Cycle Count Sheet.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'CCSheetNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-pupulated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated to the cycle count.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number for references purpose.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'RefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Tag.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'TagNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CCDetail', 'COLUMN', N'TrafficCop'
GO
