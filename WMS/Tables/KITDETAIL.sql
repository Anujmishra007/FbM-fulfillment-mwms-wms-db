CREATE TABLE [dbo].[KITDETAIL]
(
[KITKey] [nvarchar] (10) NOT NULL,
[KITLineNumber] [nvarchar] (5) NOT NULL,
[Type] [nvarchar] (5) NOT NULL CONSTRAINT [DF_KITDETAIL_Type] DEFAULT ('F'),
[StorerKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_KITDETAIL_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) NOT NULL CONSTRAINT [DF_KITDETAIL_Sku] DEFAULT (' '),
[Lot] [nvarchar] (10) NOT NULL CONSTRAINT [DF_KITDETAIL_Lot] DEFAULT (' '),
[Loc] [nvarchar] (10) NOT NULL CONSTRAINT [DF_KITDETAIL_Loc] DEFAULT (' '),
[Id] [nvarchar] (18) NOT NULL CONSTRAINT [DF_KITDETAIL_Id] DEFAULT (' '),
[ExpectedQty] [int] NOT NULL CONSTRAINT [DF_KITDETAIL_ExpectedQty] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_KITDETAIL_Qty] DEFAULT ((0)),
[PackKey] [nvarchar] (10) NOT NULL CONSTRAINT [DF_KITDETAIL_PackKey] DEFAULT ('STD'),
[UOM] [nvarchar] (10) NOT NULL CONSTRAINT [DF_KITDETAIL_UOM] DEFAULT ('EA'),
[LOTTABLE01] [nvarchar] (18) NULL CONSTRAINT [DF_KITDETAIL_Lottable01] DEFAULT (' '),
[LOTTABLE02] [nvarchar] (18) NULL CONSTRAINT [DF_KITDETAIL_Lottable02] DEFAULT (' '),
[LOTTABLE03] [nvarchar] (18) NULL CONSTRAINT [DF_KITDETAIL_Lottable03] DEFAULT (' '),
[LOTTABLE04] [datetime] NULL,
[LOTTABLE05] [datetime] NULL,
[Status] [nvarchar] (10) NULL CONSTRAINT [DF_KITDETAIL_Status] DEFAULT ('0'),
[EffectiveDate] [datetime] NULL CONSTRAINT [DF_KITDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_KITDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_KITDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_KITDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_KITDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) NULL,
[ArchiveCop] [nvarchar] (1) NULL,
[Timestamp] [timestamp] NOT NULL,
[ExternKitKey] [nvarchar] (20) NULL CONSTRAINT [DF_KITDETAIL_ExternKitKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (10) NULL CONSTRAINT [DF_KITDETAIL_ExternLineNo] DEFAULT (' '),
[Lottable06] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Channel] [nvarchar] (20) NOT NULL CONSTRAINT [DF_BTB_KITDETAIL_Channel] DEFAULT (''),
[Channel_ID] [bigint] NOT NULL CONSTRAINT [DF_BTB_KITDETAIL_Channel_ID] DEFAULT ((0)),
[UCCNo] [nvarchar] (20) NULL CONSTRAINT [DF_KITDETAIL_UCCNo] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrKitDetailAdd                                             */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: When Add Kit Detail Record                                */
/*                                                                      */
/* PVCS Version: 1.3                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 14-June-2006 Vicky         Modify Update OpenQty to cater ManyToMany */
/*                            Kitting                                   */ 
/* 30-May-2007  Shong     Add Checking on TrifficCop and ArchiveCop     */
/* 02-May-2014  Shong         1.1  Added Lottables 06-15                */
/* 27-Nov-2017  Leong         INC0028640 - Cater for <TO> Explode BOM.  */
/*                            [Exceed will delete Type F detail and     */
/*                            insert new Type F detail based on BOM]    */
/* 20-Dec-2018  TLTING01 1.2  missing nolock                            */
/* 2021-01-19   Wan01    1.3  WMS-16051 - ANFQHW_Exceed_Channel_Kitting */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrKitDetailAdd]
ON  [dbo].[KITDETAIL]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_debug int
   SELECT @b_debug = 0
   IF @b_debug = 1
   BEGIN
      SELECT 'INSERTED ', * FROM INSERTED
   END
   ELSE IF @b_debug = 2
   BEGIN
      DECLARE @profiler NVARCHAR(80)
      SELECT @profiler = 'PROFILER,888,00,0,ntrKitDetailAdd Trigger                       ,' + CONVERT(char(12), getdate(), 114)
      PRINT @profiler
   END
   
   DECLARE
   @b_Success             int       -- Populated by calls to stored procedures - was the proc successful?
   ,         @n_err       int       -- Error number returned by stored procedure OR this trigger
   ,         @n_err2      int       -- For Additional Error Detection
   ,         @c_errmsg    NVARCHAR(250) -- Error message returned by stored procedure OR this trigger
   ,         @n_continue   int                 
   ,         @n_starttcnt  int                -- Holds the current transaction count
   ,         @c_preprocess NVARCHAR(250)         -- preprocess
   ,         @c_pstprocess NVARCHAR(250)         -- post process
   ,         @n_cnt int            

   DECLARE @c_authority_kitting  NVARCHAR(1)
       , @c_kitstorer            NVARCHAR(15)
       , @c_KitKey               NVARCHAR(10) --INC0028640
       , @c_KitType              NVARCHAR(5)  --INC0028640

   --(Wan01) - START
   DECLARE @n_Channel_ID                  BIGINT      = 0   
         , @c_Channel                     NVARCHAR(20)= ''  
         , @c_ChannelInventoryMgmt_From   NVARCHAR(30)= ''  
         , @c_ChannelInventoryMgmt_To     NVARCHAR(30)= ''  
         , @c_Facility                    NVARCHAR(5) = ''
         , @c_KitLineNumber               NVARCHAR(5) = ''
  --(Wan01) - END       
      
   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT
      /* #INCLUDE <TRTDA1.SQL> */  

   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
      SELECT @n_continue = 4
            
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      UPDATE KitDetail SET LOTTABLE01 = KitDetail.PACKKEY, TrafficCop = NULL
      FROM  inserted, SKU (NOLOCK)
      WHERE KitDetail.KitKey = inserted.KitKey
      AND   KitDetail.KitLineNumber = inserted.KitLineNumber
      AND   INSERTED.TYPE  = KITDETAIL.TYPE
      AND   INSERTED.StorerKey = SKU.Storerkey
      AND   INSERTED.SKU = SKU.SKU
      AND   SKU.OnReceiptCopyPackKey = '1'
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 88804   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Update failed on table KitDetail. (ntrKitDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE = ' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,888,01,0,ITRN Process                                      ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
      END
      DECLARE @c_KitPrimaryKey NVARCHAR(15),
      @c_FromStorerKey       NVARCHAR(15),
      @c_FromSku             NVARCHAR(20),
      @c_FromLoc             NVARCHAR(10),
      @c_FromLot             NVARCHAR(10),
      @c_FromId              NVARCHAR(18),
      @c_FromPackKey         NVARCHAR(10),
      @c_FromUOM             NVARCHAR(10),
      @c_StorerKey           NVARCHAR(15),
      @c_ToSku               NVARCHAR(20),
      @c_ToLoc               NVARCHAR(10),
      @c_ToLot               NVARCHAR(10),
      @c_ToId                NVARCHAR(18),
      @c_ToPackKey           NVARCHAR(10),
      @c_ToUOM               NVARCHAR(10),
      @c_lottable01          NVARCHAR(18),
      @c_lottable02          NVARCHAR(18),
      @c_lottable03          NVARCHAR(18),
      @d_lottable04          datetime,
      @d_lottable05          datetime,
      @c_lottable06          NVARCHAR(30), 
      @c_lottable07          NVARCHAR(30),
      @c_lottable08          NVARCHAR(30),
      @c_lottable09          NVARCHAR(30),
      @c_lottable10          NVARCHAR(30),
      @c_lottable11          NVARCHAR(30),
      @c_lottable12          NVARCHAR(30),
      @d_lottable13          datetime,
      @d_lottable14          datetime,
      @d_lottable15          datetime,        
      @d_EffectiveDate       datetime,
      @n_FromQty             int,
      @n_ToQty               int
      SELECT @c_KitPrimaryKey = ' '
      WHILE (1 = 1)
      BEGIN
         SET @n_Channel_ID = 0                     --(Wan01)
         SET @c_Channel = ''                       --(Wan01)
         
         SELECT TOP 1   
               @c_KitPrimaryKey = KitKey + KitLineNumber,
               @c_FromStorerKey = StorerKey,
               @c_FromSku       = Sku,
               @c_FromLoc       = Loc,
               @c_FromLot       = Lot,
               @c_FromId        = Id,
               @n_FromQty       = Qty,
               @c_FromPackKey   = PackKey,
               @c_FromUOM       = UOM
            , @n_Channel_ID     = Channel_ID    --(Wan01)
            , @c_Channel        = Channel       --(Wan01)  
         FROM INSERTED
         WHERE KitKey + KitLineNumber > @c_KitPrimaryKey
         AND Status = '9'
         AND Type = 'F'
         ORDER BY KitKey, KitLineNumber
         IF @@ROWCOUNT = 0
         BEGIN 
            BREAK
         END 
         
         --(Wan01) - START
         SELECT @c_KitKey  = LEFT(dbo.fnc_RTrim(dbo.fnc_LTrim(@c_KitPrimaryKey)), 10)
         SELECT @c_KitLineNumber = RIGHT(dbo.fnc_RTrim(dbo.fnc_LTrim(@c_KitPrimaryKey)), 5)
         
         SELECT TOP 1 @c_Facility = Facility
         FROM KIT AS k WITH (NOLOCK)
         WHERE k.KITKey = @c_KitKey
         
         --(Wan01) - START
         SET @c_ChannelInventoryMgmt_From = ''
         SELECT @c_ChannelInventoryMgmt_From = SC.Authority FROM dbo.fnc_SelectGetRight (@c_Facility, @c_FromStorerKey, '', 'ChannelInventoryMgmt') SC
    
         IF @c_ChannelInventoryMgmt_From = '1' AND (@c_Channel = '' OR @c_Channel IS NULL)
         BEGIN
            SET @n_continue = 3
            SET @n_err=88805   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SET @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + ': From Channel Cannot be BLANK. (ntrKitDetailUpdate)'   
            BREAK
         END
         --(Wan01) - END
       
         EXECUTE nspItrnAddWithdrawal
                   @n_ItrnSysId  = NULL,
                   @c_StorerKey  = @c_FromStorerKey,
                   @c_Sku        = @c_FromSku,
                   @c_Lot        = @c_FromLot,
                   @c_ToLoc      = @c_FromLoc,
                   @c_ToID       = @c_FromId,
                   @c_Status     = '',
                   @c_lottable01 = '',
                   @c_lottable02 = '',
                   @c_lottable03 = '',
                   @d_lottable04 = NULL,
                   @d_lottable05 = NULL,
                   @c_lottable06 = '',
                   @c_lottable07 = '',
                   @c_lottable08 = '',
                   @c_lottable09 = '',
                   @c_lottable10 = '',
                   @c_lottable11 = '',
                   @c_lottable12 = '',
                   @d_lottable13 = NULL,
                   @d_lottable14 = NULL,
                   @d_lottable15 = NULL,
                   @n_casecnt    = 0,
                   @n_innerpack  = 0,
                   @n_Qty        = @n_FromQty,
                   @n_pallet     = 0,
                   @f_cube       = 0,
                   @f_grosswgt   = 0,
                   @f_netwgt     = 0,
                   @f_otherunit1 = 0,
                   @f_otherunit2 = 0,
                   @c_SourceKey  = @c_KitPrimaryKey,
                   @c_SourceType = 'ntrKitDetailAdd',
                   @c_PackKey    = @c_FromPackKey,
                   @c_UOM        = @c_FromUOM,
                   @b_UOMCalc    = 0,
                   @d_EffectiveDate = @d_EffectiveDate,
                   @c_ItrnKey    = '',
                   @b_Success    = @b_Success OUTPUT,
                   @n_err        = @n_err     OUTPUT,
                   @c_errmsg     = @c_errmsg  OUTPUT
               ,  @c_Channel    = @c_Channel             -- Wan01  
               ,  @n_Channel_ID = @n_Channel_ID  OUTPUT  -- Wan01 
                                                         --  
         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3
            BREAK
         END
       
         --(Wan01) - START
         IF @n_continue = 1 OR @n_continue = 2
         BEGIN
            UPDATE KD WITH (ROWLOCK)
               SET  Channel_ID = @n_Channel_ID
                  , EditWho  = SUSER_SNAME()
                  , EditDate = GETDATE()
                  , Trafficcop = NULL
            FROM KITDETAIL KD
            WHERE KD.KItKey = @c_KitKey
            AND KD.KItLineNumber = @c_KitLineNumber
            AND KD.[TYPE] = 'F'
                 
            SET @n_err = @@ERROR
            IF @n_err <> 0
            BEGIN
               SET @n_continue = 3
               SET @c_errmsg = CONVERT(CHAR(250), @n_err)
               SET @n_err = 63813
               SET @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + ': Update Kitdetail fail. (ntrKitDetailAdd)'  
                              + ' ( SQLSvr MESSAGE= ' + @c_errmsg + ' ) '
            END      
         END
         --(Wan01) - END 
      END -- WHILE From
   
      SELECT @c_KitPrimaryKey = ' '
      WHILE (1 = 1) AND @n_continue IN (1,2)             --(Wan01)
      BEGIN 
         SET @n_Channel_ID = 0                           --(Wan01) 
         SET @c_Channel = ''                             --(Wan01) 

         SELECT TOP 1                                    --(Wan01)
               @c_KitPrimaryKey = KitKey + KitLineNumber,
               @c_StorerKey     = StorerKey,
               @c_ToSku         = Sku,
               @c_ToLoc         = Loc,
               @c_ToLot         = Lot,
               @c_ToId          = Id,
               @n_ToQty         = Qty,
               @c_ToPackKey     = PackKey,
               @c_ToUOM         = UOM,
               @c_lottable01    = lottable01,
               @c_lottable02    = lottable02,
               @c_lottable03    = lottable03,
               @d_lottable04    = lottable04,
               @d_lottable05    = lottable05,
               @c_lottable06    = lottable06,
               @c_lottable07    = lottable07,
               @c_lottable08    = lottable08,
               @c_lottable09    = lottable09,
               @c_lottable10    = lottable10,
               @c_lottable11    = lottable11,
               @c_lottable12    = lottable12,
               @d_lottable13    = lottable13,
               @d_lottable14    = lottable14,
               @d_lottable15    = lottable15,              
               @d_EffectiveDate = EffectiveDate
            , @n_Channel_ID     = Channel_ID    --(Wan01)
            , @c_Channel        = Channel       --(Wan01) 
         FROM INSERTED
         WHERE KitKey + KitLineNumber > @c_KitPrimaryKey
         AND Status = '9'
         AND Type = 'T'
         ORDER BY KitKey, KitLineNumber
         IF @@ROWCOUNT = 0
         BEGIN 
            BREAK
         END 

         --(Wan01) - START
         SET @c_KitKey  = LEFT(dbo.fnc_RTrim(dbo.fnc_LTrim(@c_KitPrimaryKey)), 10)
         SET @c_KitLineNumber = RIGHT(dbo.fnc_RTrim(dbo.fnc_LTrim(@c_KitPrimaryKey)), 5)

         SELECT TOP 1 @c_Facility = Facility
         FROM KIT AS k WITH (NOLOCK)
         WHERE k.KITKey = @c_KitKey
      
         SET @c_ChannelInventoryMgmt_To = ''
         SELECT @c_ChannelInventoryMgmt_To = SC.Authority FROM   dbo.fnc_SelectGetRight (@c_Facility, @c_StorerKey, '', 'ChannelInventoryMgmt') SC
         IF @c_ChannelInventoryMgmt_To = '1' AND (@c_Channel = '' OR @c_Channel IS NULL)
         BEGIN
            SET @n_continue = 3
            SET @n_err=88806   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SET @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + ': To Channel Cannot be BLANK. (ntrKitDetailAdd)'   
            BREAK
         END
         --(Wan01) - END
       
         EXECUTE nspItrnAddDeposit
                  @n_ItrnSysId  = NULL,
                  @c_StorerKey  = @c_StorerKey,
                  @c_Sku        = @c_ToSku,
                  @c_Lot        = @c_ToLot,
                  @c_ToLoc      = @c_ToLoc,
                  @c_ToID       = @c_ToId,
                  @c_Status     = '',
                  @c_lottable01 = @c_lottable01,
                  @c_lottable02 = @c_lottable02,
                  @c_lottable03 = @c_lottable03,
                  @d_lottable04 = @d_lottable04,
                  @d_lottable05 = @d_lottable05,
                  @c_lottable06 = @c_lottable06,
                  @c_lottable07 = @c_lottable07,
                  @c_lottable08 = @c_lottable08,
                  @c_lottable09 = @c_lottable09,
                  @c_lottable10 = @c_lottable10,
                  @c_lottable11 = @c_lottable11,
                  @c_lottable12 = @c_lottable12,
                  @d_lottable13 = @d_lottable13,
                  @d_lottable14 = @d_lottable14,
                  @d_lottable15 = @d_lottable15,              
                  @n_casecnt    = 0,
                  @n_innerpack  = 0,
                  @n_Qty        = @n_ToQty,
                  @n_pallet     = 0,
                  @f_cube       = 0,
                  @f_grosswgt   = 0,
                  @f_netwgt     = 0,
                  @f_otherunit1 = 0,
                  @f_otherunit2 = 0,
                  @c_SourceKey  = @c_KitPrimaryKey,
                  @c_SourceType = 'ntrKitDetailAdd',
                  @c_PackKey    = @c_ToPackKey,
                  @c_UOM        = @c_ToUOM,
                  @b_UOMCalc    = 0,
                  @d_EffectiveDate = @d_EffectiveDate,
                  @c_ItrnKey    = '',
                  @b_Success    = @b_Success OUTPUT,
                  @n_err        = @n_err     OUTPUT,
                  @c_errmsg     = @c_errmsg  OUTPUT
               , @n_Channel_ID= @n_Channel_ID OUTPUT  --(Wan01)
               , @c_Channel   = @c_Channel            --(Wan01) 
         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3
            BREAK
         END
 
         --(Wan01) - START
         IF @n_continue = 1 OR @n_continue = 2
         BEGIN
            UPDATE KD WITH (ROWLOCK)
               SET  Channel_ID = @n_Channel_ID
                  , EditWho  = SUSER_SNAME()
                  , EditDate = GETDATE()
                  , Trafficcop = NULL
            FROM KITDETAIL KD
            WHERE KD.KItKey = @c_KitKey
            AND KD.KItLineNumber = @c_KitLineNumber
            AND KD.[TYPE] = 'T'
                 
            SET @n_err = @@ERROR 
            IF @n_err <> 0
            BEGIN
               SET @n_continue = 3
               SET @c_errmsg = CONVERT(CHAR(250), @n_err)
               SET @n_err = 63814
               SET @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + ': Update Kitdetail fail. (ntrKitDetailUpdate)'  
                              + ' ( SQLSvr MESSAGE= ' + @c_errmsg + ' ) '
            END      
         END
         --(Wan01) - END
      END -- WHILE

      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,888,01,9,ITRN Process                                      ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
      END
   END

   -- Added By Vicky on 14-June-2006 (Start) 
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SELECT @c_kitstorer = ''
           , @c_KitKey    = ''
           , @c_KitType   = ''
           
      SELECT @c_kitstorer = INSERTED.Storerkey
           , @c_KitKey    = INSERTED.KitKey --INC0028640
           , @c_KitType   = INSERTED.[Type] --INC0028640
      FROM  KIT WITH (NOLOCK), INSERTED   --tlting01
      WHERE KIT.KitKey = INSERTED.KitKey
      --AND   INSERTED.Type = 'T'           --INC0028640
   
      SELECT @b_success = 0
      Execute dbo.nspGetRight NULL,
               @c_kitstorer,         -- Storer
               '',                   -- Sku
               'ManyToManyKitting',  -- ConfigKey
               @b_success             OUTPUT,
               @c_authority_kitting   OUTPUT,
               @n_err                 OUTPUT,
               @c_errmsg              OUTPUT
   
      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
      End
   END
   -- Added By Vicky on 14-June-2006 (End)

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,888,02,0,KIT Update                                   ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
      END
      DECLARE @n_insertedcount int

      -- Modified By Vicky on 14-June-2006 (Start)
      IF @c_authority_kitting = '1'
      BEGIN
         IF @c_KitType = 'T' --INC0028640
         BEGIN
            UPDATE KIT WITH (ROWLOCK)
            SET KIT.OpenQty = ( SELECT ISNULL(SUM(KitDetail.ExpectedQty), 0)
                                FROM KitDetail WITH (NOLOCK)
                                WHERE KitDetail.KitKey = KIT.KitKey
                                AND   KitDetail.Type = 'T')
              , KIT.TrafficCop = NULL
            FROM KIT, INSERTED
            WHERE KIT.KitKey = @c_KitKey
            AND KIT.KitKey = INSERTED.KitKey
            AND INSERTED.Type = 'T'
         END
         IF @c_KitType = 'F' --INC0028640
         BEGIN
            UPDATE KIT WITH (ROWLOCK)
            SET KIT.OpenQty = ( SELECT ISNULL(SUM(KitDetail.ExpectedQty), 0)
                                FROM KitDetail WITH (NOLOCK)
                                WHERE KitDetail.KitKey = KIT.KitKey
                                AND   KitDetail.Type = 'T')
              , KIT.TrafficCop = NULL
            FROM KIT, INSERTED
            WHERE KIT.KitKey = @c_KitKey
            AND KIT.KitKey = INSERTED.KitKey
         END

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      END -- @c_authority_kitting = '1'
      ELSE
      BEGIN
         SELECT @n_insertedcount = (select count(1) FROM inserted)
         IF @n_insertedcount = 1
         BEGIN
            UPDATE KIT WITH (ROWLOCK)
            SET   KIT.OpenQty = KIT.OpenQty + INSERTED.ExpectedQty, TrafficCop = NULL
            FROM  KIT, INSERTED
            WHERE KIT.KitKey = INSERTED.KitKey
            AND   INSERTED.Type = 'T'
            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         END
   --        ELSE
   --        BEGIN
   --           UPDATE KIT SET KIT.OpenQty
   --           = (Select Sum(KitDetail.ExpectedQty) From KitDetail
   --           Where KitDetail.KitKey = KIT.KitKey
   --           And   KitDetail.Type = 'T')
   --           FROM KIT,INSERTED
   --           WHERE KIT.KitKey IN (Select Distinct KitKey From Inserted)
   --           AND KIT.KitKey = Inserted.KitKey
   --           AND INSERTED.Type = 'T'
   --           SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   --       END
      END -- @c_authority_kitting <> '1'
      -- Modified By Vicky on 14-June-2006 (End)
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 88801   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Insert failed on table KIT. (ntrKitDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE = ' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   /*
   ELSE IF @n_cnt = 0
   BEGIN
      SELECT @n_continue = 3
      SELECT @n_err = 88802
      SELECT @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Zero rows affected updating table KIT. (ntrKitDetailAdd)'
   END
   */
      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,888,02,9,KIT Update                                   ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
      END
   END
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,888,03,0,KIT Update for ''POSTED''                      ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
      END
      UPDATE KIT WITH (ROWLOCK)
      SET   KIT.OpenQty = KIT.OpenQty - INSERTED.Qty, TrafficCop = NULL
      FROM  KIT, INSERTED
      WHERE KIT.KitKey = INSERTED.KitKey
      AND INSERTED.Status = '9'
      AND INSERTED.Type = 'T'
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 88803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Insert failed on table KIT. (ntrKitDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE = ' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,888,03,9,KIT Update for ''POSTED''                      ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
      END
   END
      /* #INCLUDE <TRTDA2.SQL> */
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > = @n_starttcnt
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
      execute nsp_logerror @n_err, @c_errmsg, 'ntrKitDetailAdd'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,888,00,9,ntrKitDetailAdd Tigger                       ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
      END
      RETURN
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,888,00,9,ntrKitDetailAdd Trigger                       ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
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
/* Trigger: ntrKitDetailDelete                                          */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: When Delete Kit Detail Record                             */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 14-June-2006 Vicky         Modify Update OpenQty to cater ManyToMany */
/*                            Kitting                                   */ 
/* 28-Apr-2011  KHLim01       Insert Delete log                         */
/* 14-Jul-2011  KHLim02       GetRight for Delete log                   */
/* 22-May-2012  TLTING01      Data integrity - insert dellog 4 status   */
/*                             < '9'                                    */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrKitDetailDelete]
 ON [dbo].[KITDETAIL]
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

 DECLARE @b_debug int
 SELECT @b_debug = 0
 IF @b_debug = 1
 BEGIN
 SELECT "DELETED ", * FROM DELETED
 END
 ELSE IF @b_debug = 2
 BEGIN
 DECLARE @profiler NVARCHAR(80)
 SELECT @profiler = "PROFILER,701,00,0,ntrKitDetailDelete Trigger                    ," + CONVERT(char(12), getdate(), 114)
 PRINT @profiler
 END
 DECLARE @b_Success       int,  -- Populated by calls to stored procedures - was the proc successful?
 @n_err              int,       -- Error number returned by stored procedure or this trigger
 @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
 @n_continue         int,       -- continuation flag: 1 = Continue, 2 = failed but continue processsing, 3 = failed do not continue processing, 4 = successful but skip further processing
 @n_starttcnt        int,       -- Holds the current transaction count
 @n_cnt              int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
,@c_authority        NVARCHAR(1)  -- KHLim02
 SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT
      /* #INCLUDE <TRTDD1.SQL> */     

 IF (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END
 
   -- TLTING01
    -- Start (KHLim01) 
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
               ,@c_errmsg = 'ntrKITDETAILDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.KITDETAIL_DELLOG ( KITKey, KITLineNumber, Type )
         SELECT DELETED.KITKey, DELETED.KITLineNumber, DELETED.Type 
         FROM DELETED
         JOIN KIT (NOLOCK) ON KIT.KITKey = DELETED.KITKey
         WHERE KIT.STATUS < '9'

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table KITDETAIL Failed. (ntrKITDETAILDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END

         IF @n_cnt = 0
         BEGIN
            INSERT INTO dbo.KITDETAIL_DELLOG ( KITKey, KITLineNumber, Type )
            SELECT DELETED.KITKey, DELETED.KITLineNumber, DELETED.Type 
            FROM DELETED
            WHERE DELETED.STATUS < '9'

            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68102   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table KITDETAIL Failed. (ntrKITDETAILDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
            END
         END
      END
   END
   -- End (KHLim01) 

 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS ( SELECT *
 FROM DELETED
 WHERE Status = "9" )
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 70101
 SELECT @c_errmsg = "NSQL"+CONVERT(char(5),@n_err)+": Posted rows may not be deleted. (ntrKitDetailDelete)"
 END
 END
 IF @n_continue = 1 OR @n_continue = 2
 BEGIN
 IF @b_debug = 2
 BEGIN
 SELECT @profiler = "PROFILER,701,02,0,KIT Update                                   ," + CONVERT(char(12), getdate(), 114)
 PRINT @profiler
 END
 DECLARE @n_deletedcount int
 SELECT @n_deletedcount = (select count(*) FROM deleted)
 IF @n_deletedcount = 1
 BEGIN
    UPDATE KIT
    SET  KIT.OpenQty = KIT.OpenQty - DELETED.ExpectedQty
    FROM KIT, DELETED
    WHERE  KIT.KitKey = DELETED.KitKey
    AND  DELETED.TYPE = "F"  

    -- Added By Vicky on 14-June-2006 (Start)
    UPDATE KIT
    SET  KIT.OpenQty = KIT.OpenQty - DELETED.ExpectedQty
    FROM KIT, DELETED
    WHERE  KIT.KitKey = DELETED.KitKey
    AND  DELETED.TYPE = "T"  
    -- Added By Vicky on 14-June-2006 (End)
 END
 ELSE
 BEGIN
    UPDATE KIT SET KIT.OpenQty = (KIT.Openqty - (Select Sum(DELETED.ExpectedQty) From DELETED
          Where DELETED.KitKey = KIT.KitKey AND DELETED.TYPE = "F"))
    FROM KIT,DELETED
    WHERE KIT.KitKey IN (SELECT Distinct KitKey From DELETED)
    AND KIT.KitKey = DELETED.KitKey
    AND DELETED.TYPE = "F"

    -- Added By Vicky on 14-June-2006 (Start)
    UPDATE KIT SET KIT.OpenQty = (KIT.Openqty - (Select Sum(DELETED.ExpectedQty) From DELETED
          Where DELETED.KitKey = KIT.KitKey AND DELETED.TYPE = "T"))
    FROM KIT,DELETED
    WHERE KIT.KitKey IN (SELECT Distinct KitKey From DELETED)
    AND KIT.KitKey = DELETED.KitKey
    AND DELETED.TYPE = "T"
    -- Added By Vicky on 14-June-2006 (End)
 END
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 70102   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg = "NSQL"+CONVERT(char(5),@n_err)+": Insert failed on table KIT. (ntrKitDetailDelete)" + " ( " + " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 IF @b_debug = 2
 BEGIN
 SELECT @profiler = "PROFILER,701,02,9,KIT Update                                   ," + CONVERT(char(12), getdate(), 114)
 PRINT @profiler
 END
 END
 END

      /* #INCLUDE <TRTDD2.SQL> */
 IF @n_continue = 3  -- Error Occured - Process And Return
 BEGIN
 IF @@TRANCOUNT = 1 and @@TRANCOUNT > = @n_starttcnt
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrKitDetailDelete"
 RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
 IF @b_debug = 2
 BEGIN
 SELECT @profiler = "PROFILER,701,00,9,ntrKitDetailDelete Trigger                    ," + CONVERT(char(12), getdate(), 114)
 PRINT @profiler
 END
 RETURN
 END
 ELSE
 BEGIN
 WHILE @@TRANCOUNT > @n_starttcnt
 BEGIN
 COMMIT TRAN
 END
 IF @b_debug = 2
 BEGIN
 SELECT @profiler = "PROFILER,701,00,9,ntrKitDetailDelete Trigger         ," + CONVERT(char(12), getdate(), 114)
 PRINT @profiler
 END
 RETURN
 END
 END


GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/************************************************************************/
/* Trigger: ntrKitDetailUpdate                                          */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: When Delete Kit Detail Record                             */
/*                                                                      */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 14-June-2006 Vicky         Modify Update OpenQty to cater ManyToMany */
/*                            Kitting                                   */ 
/* 18-Sept-2006 June          SOS58266 - C4KIT for C4 GOLD Interface    */
/* 27-Sept-2006 Vicky         Take out the Kit.OpenQty for status <> 9  */
/* 31-May-2007  Shong         Update Kit with TrafficCop                */ 
/* 23-May-2012  TLTING01 1.2  DM Integrity issue - Update editdate for  */
/*                            status < '9'                              */
/* 06-Sep-2012  KHLim    1.3  Move up ArchiveCop (KH01)                 */
/* 28-Oct-2013  TLTING   1.4  Review Editdate column update             */
/* 30-May-2007  Shong         Add Checking on TrifficCop and ArchiveCop */
/* 02-May-2014  Shong    1.5  Added Lottables 06-15                     */
/* 24-Jan-2017  TLTING01 1.6  Remove Set ROWCOUNT                       */
/* 2021-01-19   Wan01    1.7  WMS-16051 - ANFQHW_Exceed_Channel_Kitting */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrKitDetailUpdate]
ON  [dbo].[KITDETAIL]
FOR UPDATE
AS
BEGIN
   -- tlting01 start
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
   IF @b_debug = 1
   BEGIN
      SELECT 'INSERTED ', * FROM INSERTED
      SELECT 'DELETED  ', * FROM DELETED
   END
   ELSE IF @b_debug = 2
   BEGIN
      DECLARE @profiler NVARCHAR(80)
      SELECT @profiler = 'PROFILER,700,00,0,ntrKitDetailUpdate Trigger                    ,' + CONVERT(char(12), getdate(), 114)
      PRINT @profiler
   END
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
   ,          @c_KittingITF NVARCHAR(1)   -- Add by June 1.Jul.02 for IDSV5             
   ,       @c_C4ITF      NVARCHAR(1)   -- SOS58266
 
   --(Wan01) - START
   DECLARE @n_Channel_ID                  BIGINT      = 0   
         , @c_Channel                     NVARCHAR(20)= ''  
         , @c_ChannelInventoryMgmt_From   NVARCHAR(30)= ''  
         , @c_ChannelInventoryMgmt_To     NVARCHAR(30)= ''  
         , @c_Facility                    NVARCHAR(5) = ''
   --(Wan01) - END
   
   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4 
   END
   
   IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate)  --KH01
   BEGIN 
      -- tlting01
      IF EXISTS ( SELECT 1 FROM INSERTED, DELETED 
                  WHERE INSERTED.KitKey = DELETED.KitKey
                  AND INSERTED.KitLineNumber = DELETED.KitLineNumber
                  AND INSERTED.Type = DELETED.Type
                  AND ( INSERTED.[status] < '9' OR DELETED.[status] < '9' ) )
      BEGIN
         UPDATE KitDetail with (ROWLOCK)
         SET   EditDate = GetDate(), EditWho = Suser_Sname(), --Added By Vicky 18Juky 2002 Patch from IDSHK
               TrafficCop = NULL  
         FROM  INSERTED, DELETED
         WHERE KitDetail.KitKey = INSERTED.KitKey
         AND   KitDetail.KitLineNumber = INSERTED.KitLineNumber
         AND   KITDETAIL.Type = INSERTED.Type
         AND   KitDetail.KitKey = DELETED.KitKey
         AND   KitDetail.KitLineNumber = DELETED.KitLineNumber
         AND   KITDETAIL.Type = DELETED.Type
         AND   KITDETAIL.[status] < '9'
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 70014   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Update failed on table KitDetail. (ntrKitDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE = ' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
         END
      END
   END
 
   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4 
   END
      /* #INCLUDE <TRTDU1.SQL> */     
   -- Added By Shong
   DECLARE @c_KitKey NVARCHAR(10), 
         @c_trmlogkey NVARCHAR(10), 
         @c_KitLineNumber NVARCHAR(5)
   DECLARE @n_toqty   int,
   @n_fromqty int
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      IF EXISTS ( SELECT *
      FROM DELETED
      WHERE Status = '9' )
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 70000
         SELECT @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Posted rows may not be edited. (ntrKitDetailUpdate)'
      END
   END
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      UPDATE KitDetail 
      SET   EditDate = GetDate(), EditWho = Suser_Sname(), --Added By Vicky 18Juky 2002 Patch from IDSHK
            TrafficCop = NULL 
      FROM  INSERTED, DELETED
      WHERE KitDetail.KitKey = INSERTED.KitKey
      AND   KitDetail.KitLineNumber = INSERTED.KitLineNumber
      AND   KITDETAIL.Type = INSERTED.Type
      AND   KitDetail.KitKey = DELETED.KitKey
      AND   KitDetail.KitLineNumber = DELETED.KitLineNumber
      AND   KITDETAIL.Type = DELETED.Type
      AND   KITDETAIL.[STATUS]  in ( '9' , 'CANC' )     -- tlting01
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 70004   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Update failed on table KitDetail. (ntrKitDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE = ' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
   UPDATE KitDetail with (ROWLOCK)
      SET   LOTTABLE01 = KitDetail.PACKKEY, TrafficCop = NULL,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
      FROM  INSERTED, SKU (NOLOCK)
      WHERE KitDetail.KitKey = INSERTED.KitKey
      AND   KitDetail.KitLineNumber = INSERTED.KitLineNumber
      AND   KITDETAIL.Type = 'T'
      AND   INSERTED.StorerKey = SKU.Storerkey
      AND   INSERTED.SKU = SKU.SKU
      AND   SKU.OnReceiptCopyPackKey = '1'
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 70004   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Update failed on table KitDetail. (ntrKitDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE = ' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END
   
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,700,01,0,ITRN Process                                      ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
      END
      DECLARE 
      @c_KitPrimaryKey          NVARCHAR(15),
      @c_FromStorerKey          NVARCHAR(15),
      @c_FromSku                NVARCHAR(20),
      @c_FromLoc                NVARCHAR(10),
      @c_FromLot                NVARCHAR(10),
      @c_FromId                 NVARCHAR(18),
      @c_FromPackKey            NVARCHAR(10),
      @c_FromUOM                NVARCHAR(10),
      @c_StorerKey              NVARCHAR(15),
      @c_ToSku                  NVARCHAR(20),
      @c_ToLoc                  NVARCHAR(10),
      @c_ToLot                  NVARCHAR(10),
      @c_ToId                   NVARCHAR(18),
      @c_ToPackKey              NVARCHAR(10),
      @c_ToUOM                  NVARCHAR(10),
      @c_lottable01             NVARCHAR(18),
      @c_lottable02             NVARCHAR(18),
      @c_lottable03             NVARCHAR(18),
      @d_lottable04             datetime,
      @d_lottable05             datetime,
      @c_lottable06             NVARCHAR(30), 
      @c_lottable07             NVARCHAR(30),
      @c_lottable08             NVARCHAR(30),
      @c_lottable09             NVARCHAR(30),
      @c_lottable10             NVARCHAR(30),
      @c_lottable11             NVARCHAR(30),
      @c_lottable12             NVARCHAR(30),
      @d_lottable13             datetime,
      @d_lottable14             datetime,
      @d_lottable15             datetime,        
      @d_EffectiveDate          DATETIME
      
      SELECT @c_KitPrimaryKey = ' '
      WHILE (1 = 1)
      BEGIN
         SET @n_Channel_ID = 0                     --(Wan01)
         SET @c_Channel = ''                       --(Wan01)
         
         SELECT TOP 1 @c_KitPrimaryKey = KitKey + KitLineNumber,
               @c_FromStorerKey = StorerKey,
               @c_FromSku       = Sku,
               @c_FromLoc       = Loc,
               @c_FromLot       = Lot,
               @c_FromId        = Id,
               @n_FromQty       = Qty,
               @c_FromPackKey   = PackKey,
               @c_FromUOM       = UOM
            , @n_Channel_ID     = Channel_ID    --(Wan01)
            , @c_Channel        = Channel       --(Wan01)  
         FROM INSERTED
         WHERE KitKey + KitLineNumber > @c_KitPrimaryKey
         AND Status = '9'
         AND Type = 'F'
         ORDER BY KitKey, KitLineNumber
         
         IF @@ROWCOUNT = 0
         BEGIN
            BREAK
         END
       
         -- Start : SOS58266
         SELECT @c_KitKey  = LEFT(dbo.fnc_RTrim(dbo.fnc_LTrim(@c_KitPrimaryKey)), 10)
         SELECT @c_KitLineNumber = RIGHT(dbo.fnc_RTrim(dbo.fnc_LTrim(@c_KitPrimaryKey)), 5)
         -- End : SOS58266

         --(Wan01) - START
         SELECT TOP 1 @c_Facility = Facility
         FROM KIT AS k WITH (NOLOCK)
         WHERE k.KITKey = @c_KitKey
         
         --(Wan01) - START
         SET @c_ChannelInventoryMgmt_From = ''
         SELECT @c_ChannelInventoryMgmt_From = SC.Authority FROM dbo.fnc_SelectGetRight (@c_Facility, @c_FromStorerKey, '', 'ChannelInventoryMgmt') SC
    
         IF @c_ChannelInventoryMgmt_From = '1' AND (@c_Channel = '' OR @c_Channel IS NULL)
         BEGIN
            SET @n_continue = 3
            SET @n_err=63811   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SET @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + ': From Channel Cannot be BLANK. (ntrKitDetailUpdate)'   
            BREAK
         END
         --(Wan01) - END

         EXECUTE nspItrnAddWithdrawal
                  @n_ItrnSysId  = NULL,
                  @c_StorerKey  = @c_FromStorerKey,
                  @c_Sku        = @c_FromSku,   
                  @c_Lot        = @c_FromLot,
                  @c_ToLoc      = @c_FromLoc,
                  @c_ToID       = @c_FromId,
                  @c_Status     = '',
                  @c_lottable01 = '',
                  @c_lottable02 = '',
                  @c_lottable03 = '',
                  @d_lottable04 = NULL,
                  @d_lottable05 = NULL,
                  @c_lottable06 = "",
                  @c_lottable07 = "",
                  @c_lottable08 = "",
                  @c_lottable09 = "",
                  @c_lottable10 = "",
                  @c_lottable11 = "",
                  @c_lottable12 = "",
                  @d_lottable13 = NULL,
                  @d_lottable14 = NULL,
                  @d_lottable15 = NULL,         
                  @n_casecnt    = 0,
                  @n_innerpack  = 0,
                  @n_Qty        = @n_FromQty,
                  @n_pallet     = 0,
                  @f_cube       = 0,
                  @f_grosswgt   = 0,
                  @f_netwgt     = 0,
                  @f_otherunit1 = 0,
                  @f_otherunit2 = 0,
                  @c_SourceKey  = @c_KitPrimaryKey,
                  @c_SourceType = 'ntrKitDetailUpdate',
                  @c_PackKey    = @c_FromPackKey,
                  @c_UOM        = @c_FromUOM,   
                  @b_UOMCalc    = 0,
                  @d_EffectiveDate = @d_EffectiveDate,
                  @c_ItrnKey    = '',
                  @b_Success    = @b_Success OUTPUT,
                  @n_err        = @n_err     OUTPUT,
                  @c_errmsg     = @c_errmsg  OUTPUT
               ,  @c_Channel    = @c_Channel             -- Wan01  
               ,  @n_Channel_ID = @n_Channel_ID  OUTPUT  -- Wan01  

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3
            BREAK
         END
         ELSE
         BEGIN
            --(Wan01) - START
            IF @n_continue = 1 OR @n_continue = 2
            BEGIN
               UPDATE KD WITH (ROWLOCK)
                  SET  Channel_ID = @n_Channel_ID
                     , EditWho  = SUSER_SNAME()
                     , EditDate = GETDATE()
                     , Trafficcop = NULL
               FROM KITDETAIL KD
               WHERE KD.KItKey = @c_KitKey
               AND KD.KItLineNumber = @c_KitLineNumber
               AND KD.[TYPE] = 'F'
                 
               SET @n_err = @@ERROR
               IF @n_err <> 0
               BEGIN
                  SET @n_continue = 3
                  SET @c_errmsg = CONVERT(CHAR(250), @n_err)
                  SET @n_err = 63813
                  SET @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + ': Update Kitdetail fail. (ntrKitDetailUpdate)'  
                                + ' ( SQLSvr MESSAGE= ' + @c_errmsg + ' ) '
               END      
            END
            --(Wan01) - END
            
            IF @n_continue = 1 OR @n_continue = 2
            BEGIN
               -- Added for IDSV5 by June 1.Jul.02, (extract from IDSMY & IDSTW) *** Start
               SELECT @b_success = 0
               Execute nspGetRight null,  -- facility
                           @c_FromStorerKey,    -- Storerkey
                           null,          -- Sku
                           'KITTINGITF',        -- Configkey
                           @b_success     output,
                           @c_KittingITF  output, 
                           @n_err         output,
                           @c_errmsg      output

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3, @c_errmsg = 'ntrKitDetailUpdate' + dbo.fnc_RTrim(@c_errmsg)
               END
               ELSE IF @c_KittingITF = '1'
               BEGIN 
                  -- Added for IDSV5 by June 1.Jul.02, (extract from IDSMY & IDSTW) *** End
                  -- Author : Shong Wan Toh
                  -- Purpose: Interface
                  -- Date   : 04th Sep 2000
                  -- Modification - to add records in transmitlog 
                  IF EXISTS (SELECT 1 FROM INSERTED WHERE INSERTED.STATUS = '9')
                  BEGIN
                     SELECT @b_success = 1
                     EXECUTE nspg_getkey
                     "transmitlogkey"
                     , 10
                     , @c_trmlogkey OUTPUT
                     , @b_success OUTPUT
                     , @n_err OUTPUT
                     , @c_errmsg OUTPUT
                     IF NOT @b_success = 1
                     BEGIN
                        SELECT @n_continue = 3
                        SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63810   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                        SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Unable to obtain transmitlogkey (ntrKitDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
                     END
                     ELSE                
                     BEGIN
                        INSERT INTO transmitlog (transmitlogkey, tablename, key1, key2, key3, transmitflag)
                        SELECT @c_trmlogkey, 'Kitting', INSERTED.KitKey, INSERTED.KitLineNumber, INSERTED.TYPE, '0'
                        FROM   INSERTED
                        WHERE  INSERTED.KitKey + INSERTED.KitLineNumber = @c_KitPrimaryKey
                        AND    INSERTED.TYPE = "F"
                        AND    INSERTED.Status = "9"
                        SELECT @n_err = @@ERROR
                        IF @n_err <> 0
                        BEGIN
                           SELECT @n_continue = 3
                           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63810   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                           SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Unable to Insert Transmitlog (ntrKitDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
                        END
                     END -- insert transmitlog
                  END -- KitDetail.status = '9'
               END -- KittingITF = 1
            END  
            -- End Modification     

            -- Start : SOS58266
            -- Add by June 18.Sept.2006, insert into Transmitlog2
            IF @n_continue = 1 OR @n_continue = 2
            BEGIN
               SELECT @b_success = 0
               Execute nspGetRight null,     -- facility
                           @c_FromStorerKey,    -- Storerkey
                           null,          -- Sku
                           'C4ITF',       -- Configkey
                           @b_success     output,
                           @c_C4ITF    output, 
                           @n_err         output,
                           @c_errmsg      output

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3, @c_errmsg = 'ntrKitDetailUpdate' + dbo.fnc_RTrim(@c_errmsg)
               END
               ELSE IF @c_C4ITF = '1'
               BEGIN 
                  EXEC ispGenTransmitLog2 'C4KIT', @c_KitKey, @c_KitLineNumber, 'F', ''
                        , @b_success OUTPUT
                        , @n_err OUTPUT
                        , @c_errmsg OUTPUT
               END -- C4ITF            
            END -- Continue
         -- End : SOS58266
         END -- Success = 1
      END -- WHILE From
     
      SELECT @c_KitPrimaryKey = ' '
      WHILE (1 = 1)
      BEGIN
         SET @n_Channel_ID = 0                           --(Wan01) 
         SET @c_Channel = ''                             --(Wan01) 
         
         SELECT TOP 1  
                     @c_KitPrimaryKey = KitKey + KitLineNumber,
                     @c_StorerKey     = StorerKey,
                     @c_ToSku         = Sku,
                     @c_ToLoc         = Loc,
                     @c_ToLot         = Lot,
                     @c_ToId          = Id,
                     @n_ToQty         = Qty,
                     @c_ToPackKey     = PackKey,
                     @c_ToUOM         = UOM, 
                     @c_lottable01    = lottable01,
                     @c_lottable02    = lottable02,   
                     @c_lottable03    = lottable03,
                     @d_lottable04    = lottable04,
                     @d_lottable05    = lottable05,
                     @c_lottable06    = lottable06,
                     @c_lottable07    = lottable07,
                     @c_lottable08    = lottable08,
                     @c_lottable09    = lottable09,
                     @c_lottable10    = lottable10,
                     @c_lottable11    = lottable11,
                     @c_lottable12    = lottable12,
                     @d_lottable13    = lottable13,
                     @d_lottable14    = lottable14,
                     @d_lottable15    = lottable15,            
                     @d_EffectiveDate = EffectiveDate
                  , @n_Channel_ID     = Channel_ID       --(Wan01)
                  , @c_Channel        = Channel          --(Wan01) 
         FROM INSERTED
         WHERE KitKey + KitLineNumber > @c_KitPrimaryKey
         AND Status = '9'
         AND Type = 'T'
         ORDER BY KitKey, KitLineNumber
         IF @@ROWCOUNT = 0
         BEGIN
            BREAK
         END

         -- Start : SOS58266
         SELECT @c_KitKey  = LEFT(dbo.fnc_RTrim(dbo.fnc_LTrim(@c_KitPrimaryKey)), 10)
         SELECT @c_KitLineNumber = RIGHT(dbo.fnc_RTrim(dbo.fnc_LTrim(@c_KitPrimaryKey)), 5)
         -- End : SOS58266
    
         --(Wan01) - START
         SELECT TOP 1 @c_Facility = Facility
         FROM KIT AS k WITH (NOLOCK)
         WHERE k.KITKey = @c_KitKey
      
         SET @c_ChannelInventoryMgmt_To = ''
         SELECT @c_ChannelInventoryMgmt_To = SC.Authority FROM   dbo.fnc_SelectGetRight (@c_Facility, @c_StorerKey, '', 'ChannelInventoryMgmt') SC
         IF @c_ChannelInventoryMgmt_To = '1' AND (@c_Channel = '' OR @c_Channel IS NULL)
         BEGIN
            SET @n_continue = 3
            SET @n_err=63812   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SET @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + ': To Channel Cannot be BLANK. (ntrKitDetailUpdate)'   
            BREAK
         END
         --(Wan01) - END
         
         EXECUTE nspItrnAddDeposit
                  @n_ItrnSysId  = NULL,
                  @c_StorerKey  = @c_StorerKey,
                  @c_Sku        = @c_ToSku,
                  @c_Lot        = @c_ToLot,
                  @c_ToLoc      = @c_ToLoc,
                  @c_ToID       = @c_ToId,
                  @c_Status     = '',
                  @c_lottable01 = @c_lottable01,
                  @c_lottable02 = @c_lottable02,
                  @c_lottable03 = @c_lottable03,
                  @d_lottable04 = @d_lottable04,
                  @d_lottable05 = @d_lottable05,
                  @c_lottable06 = @c_lottable06,
                  @c_lottable07 = @c_lottable07,
                  @c_lottable08 = @c_lottable08,
                  @c_lottable09 = @c_lottable09,
                  @c_lottable10 = @c_lottable10,
                  @c_lottable11 = @c_lottable11,
                  @c_lottable12 = @c_lottable12,
                  @d_lottable13 = @d_lottable13,
                  @d_lottable14 = @d_lottable14,
                  @d_lottable15 = @d_lottable15,            
                  @n_casecnt    = 0,
                  @n_innerpack  = 0,
                  @n_Qty        = @n_ToQty,
                  @n_pallet     = 0,
                  @f_cube       = 0,
                  @f_grosswgt   = 0,
                  @f_netwgt     = 0,
                  @f_otherunit1 = 0,
                  @f_otherunit2 = 0,
                  @c_SourceKey  = @c_KitPrimaryKey,
                  @c_SourceType = 'ntrKitDetailAdd',
                  @c_PackKey    = @c_ToPackKey,
                  @c_UOM        = @c_ToUOM,
                  @b_UOMCalc    = 0,
                  @d_EffectiveDate = @d_EffectiveDate,   
                  @c_ItrnKey    = '',
                  @b_Success    = @b_Success OUTPUT,
                  @n_err        = @n_err     OUTPUT,
                  @c_errmsg     = @c_errmsg OUTPUT
               ,  @c_Channel    = @c_Channel             -- Wan01  
               ,  @n_Channel_ID = @n_Channel_ID  OUTPUT  -- Wan01     
         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3
            BREAK
         END
         ELSE
         BEGIN
            --(Wan01) - START
            IF @n_continue = 1 OR @n_continue = 2
            BEGIN
               UPDATE KD WITH (ROWLOCK)
                  SET  Channel_ID = @n_Channel_ID
                     , EditWho  = SUSER_SNAME()
                     , EditDate = GETDATE()
                     , Trafficcop = NULL
               FROM KITDETAIL KD
               WHERE KD.KItKey = @c_KitKey
               AND KD.KItLineNumber = @c_KitLineNumber
               AND KD.[TYPE] = 'T'
                 
               SET @n_err = @@ERROR 
               IF @n_err <> 0
               BEGIN
                  SET @n_continue = 3
                  SET @c_errmsg = CONVERT(CHAR(250), @n_err)
                  SET @n_err = 63814
                  SET @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + ': Update Kitdetail fail. (ntrKitDetailUpdate)'  
                                + ' ( SQLSvr MESSAGE= ' + @c_errmsg + ' ) '
               END      
            END
            --(Wan01) - END
            IF @n_continue = 1 OR @n_continue = 2  
            BEGIN
               SELECT @b_success = 0
               Execute nspGetRight null,  -- facility
                        @c_StorerKey,     -- Storerkey
                        null,             -- Sku
                        'KITTINGITF',        -- Configkey
                        @b_success     output,
                        @c_KittingITF  output, 
                        @n_err         output,
                        @c_errmsg      output

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3, @c_errmsg = 'ntrKitDetailUpdate' + dbo.fnc_RTrim(@c_errmsg)
               END
               ELSE IF @c_KittingITF = '1'
               BEGIN
                     /* Modification - to add records in transmitlog */
                     -- Author : Shong Wan Toh
                     -- Purpose: Interface
                     -- Date   : 04th Sep 2000
                  IF EXISTS (SELECT 1 FROM INSERTED WHERE INSERTED.STATUS = '9')
                  BEGIN
                     SELECT @b_success = 1
               
                     EXECUTE nspg_getkey
                     "transmitlogkey"
                     , 10
                     , @c_trmlogkey OUTPUT
                     , @b_success OUTPUT
                     , @n_err OUTPUT
                     , @c_errmsg OUTPUT
                     IF NOT @b_success = 1
                     BEGIN
                        SELECT @n_continue = 3
                        SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63810   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                        SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Unable to obtain transmitlogkey (ntrKitDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
                     END
                     ELSE               
                     BEGIN
                        INSERT INTO transmitlog (transmitlogkey, tablename, key1, key2, key3, transmitflag)
                        SELECT @c_trmlogkey, 'Kitting', INSERTED.KitKey, INSERTED.KitLineNumber, INSERTED.TYPE, '0'
                        FROM   INSERTED
                        WHERE  INSERTED.KitKey + INSERTED.KitLineNumber = @c_KitPrimaryKey
                        AND    INSERTED.TYPE = "T"
                        AND    INSERTED.Status = "9"
                        SELECT @n_err = @@ERROR
                        IF @n_err <> 0
                        BEGIN
                           SELECT @n_continue = 3
                           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63810   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                           SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Unable to Insert Transmitlog (ntrKitDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
                        END
                     END -- Insert Transmitlog  
                  END -- Kitdetail.Status = '9'
                  /* End Modification */     
               END -- KittingITF = 1 
            END 

            -- Start : SOS58266
            -- Add by June 18.Sept.2006, insert into Transmitlog2
            IF @n_continue = 1 OR @n_continue = 2
            BEGIN
               SELECT @b_success = 0
               Execute nspGetRight null,     -- facility
                           @c_FromStorerKey,    -- Storerkey
                           null,          -- Sku
                           'C4ITF',       -- Configkey
                           @b_success     output,
                           @c_C4ITF    output, 
                           @n_err         output,
                           @c_errmsg      output

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3, @c_errmsg = 'ntrKitDetailUpdate' + dbo.fnc_RTrim(@c_errmsg)
               END
               ELSE IF @c_C4ITF = '1'
               BEGIN 
                  EXEC ispGenTransmitLog2 'C4KIT', @c_KitKey, @c_KitLineNumber, 'T', ''
                        , @b_success OUTPUT
                        , @n_err OUTPUT
                        , @c_errmsg OUTPUT
               END -- C4ITF            
            END -- Continue
            -- End : SOS58266
         END -- Success = 1
      END -- WHILE
      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,888,01,9,ITRN Process                                      ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
      END
   END

   -- Start - Add by YokeBeen on 01-Oct-2002 (ULVHK Interface - ispExportKitUIINV)
   IF @n_continue=1 or @n_continue=2
   BEGIN
      IF UPDATE(Status)
      BEGIN
         DECLARE  @c_XKitKey      NVARCHAR(10), 
                  @c_XKitLineNumber NVARCHAR(5), 
                  @c_XStorerKey   NVARCHAR(15), 
                  @c_XExternKitKey NVARCHAR(20),
                  @c_XCustomerRefNo NVARCHAR(10), 
                  @c_XTablename   NVARCHAR(10),  
                  @c_XRectype     NVARCHAR(12) 
         SELECT   @c_XKitKey        = SPACE(10),
                  @c_XKitLineNumber = SPACE(5), 
                  @c_XStorerKey     = SPACE(15),
                  @c_XExternKitKey  = SPACE(20),
                  @c_XCustomerRefNo = SPACE(10), 
                  @c_XTablename     = SPACE(10),  
                  @c_XRectype       = SPACE(12) 
   
         WHILE 1=1
         BEGIN
            
            SELECT TOP 1   @c_XKitKey = KITDETAIL.KitKey,
                     @c_XKitLineNumber = KITDETAIL.KITLineNumber, 
                     @c_XStorerkey = KIT.Storerkey, 
                     @c_XExternKitKey = KIT.ExternKitKey,
                     @c_XCustomerRefNo = KIT.CustomerRefNo, 
                     @c_XRectype = KIT.Type  
               FROM  INSERTED
               JOIN  DELETED ON (DELETED.Kitkey = INSERTED.Kitkey)
               JOIN  KITDETAIL (NOLOCK) ON (INSERTED.Kitkey = KITDETAIL.Kitkey)
               JOIN  KIT (NOLOCK) ON (KITDETAIL.Kitkey = KIT.Kitkey and KITDETAIL.Storerkey = KIT.Storerkey)
               JOIN  StorerConfig (NOLOCK) ON (KIT.StorerKey = StorerConfig.StorerKey
                                                AND StorerConfig.ConfigKey = 'ULVITF' AND StorerConfig.sValue = '1')
               WHERE INSERTED.Status = '9'
               AND   DELETED.Status <> '9'
               AND   KIT.KitKey > @c_XKitKey 
               AND   KITDETAIL.Type = 'T' 
               ORDER BY KITDETAIL.KitKey, KITDETAIL.KITLineNumber 
   
            IF @@ROWCOUNT = 0
               BREAK

            -- Added by YokeBeen on 02-Nov-2002.
            -- Checking on ExternKitKey and CustomerRefNo, either one must exists then only to create the record 
            -- under Transmitlog2 for Outbound.
            IF (@c_XExternKitKey = NULL OR @c_XExternKitKey = '') 
               BEGIN
                  IF (@c_XCustomerRefNo = NULL OR @c_XCustomerRefNo = '') 
                     BEGIN
                        BREAK
                     END
               END
   
            IF EXISTS (SELECT 1 FROM StorerConfig (NOLOCK) WHERE (StorerConfig.StorerKey = @c_XStorerkey
                                 AND StorerConfig.ConfigKey = 'ULVITF' AND StorerConfig.sValue = '1'))
            BEGIN
               -- Added by YokeBeen on 19-Nov-2002. (FBR8621)
               IF (@c_XExternKitKey = NULL OR @c_XExternKitKey = '') 
                  BEGIN 
                     IF EXISTS ( SELECT 1 FROM KIT (NOLOCK) WHERE (CustomerRefNo = @c_XCustomerRefNo)
                                    AND (StorerKey = @c_XStorerkey) AND (Type = @c_XRectype) 
                                    AND (UPPER(@c_XRectype) IN ('LABEL')) ) 
                        SELECT @c_XTablename = 'ULVKITLBL'

                     ELSE IF EXISTS ( SELECT 1 FROM KIT (NOLOCK) WHERE (CustomerRefNo = @c_XCustomerRefNo) 
                                          AND (StorerKey = @c_XStorerkey) AND (Type = @c_XRectype) 
                                          AND (UPPER(@c_XRectype) <> ('LABEL')) ) 
                              SELECT @c_XTablename = 'ULVKIT'
                  END
               ELSE
                  BEGIN
                     IF EXISTS ( SELECT 1 FROM KIT (NOLOCK) WHERE (ExternKitKey = @c_XExternKitKey) 
                                    AND (StorerKey = @c_XStorerkey) AND (Type = @c_XRectype) 
                                    AND (UPPER(@c_XRectype) IN ('LABEL')) ) 
                        SELECT @c_XTablename = 'ULVKITLBL'

                     ELSE IF EXISTS ( SELECT 1 FROM KIT (NOLOCK) WHERE (ExternKitKey = @c_XExternKitKey)
                                          AND (StorerKey = @c_XStorerkey) AND (Type = @c_XRectype) 
                                          AND (UPPER(@c_XRectype) <> ('LABEL')) ) 
                              SELECT @c_XTablename = 'ULVKIT'
                  END
   
               IF NOT EXISTS (SELECT 1 FROM TRANSMITLOG2 (NOLOCK) WHERE TableName IN ('ULVKIT', 'ULVKITLBL')
               AND    Key3 = @c_XKitLineNumber )
               BEGIN
                  SELECT @b_success = 1

                  EXECUTE nspg_getkey
                           'TransmitlogKey2'
                        , 10
                        , @c_trmlogkey OUTPUT
                        , @b_success OUTPUT
                        , @n_err OUTPUT
                        , @c_errmsg OUTPUT
      
                  IF NOT @b_success = 1
                  BEGIN
                        SELECT @n_continue = 3
                        SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63810   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                        SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Unable to obtain transmitlogkey2 (ntrKitDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
                  END
                  ELSE
                  BEGIN
                     INSERT INTO TRANSMITLOG2 (transmitlogkey, tablename, key1, key2, key3)
                     VALUES (@c_trmlogkey, @c_XTablename, @c_XKitKey , @c_XKitLineNumber, @c_XStorerKey)
      
                     SELECT @n_err = @@ERROR
                     IF @n_err <> 0
                     BEGIN
                        SELECT @n_continue = 3
                        SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63810   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                        SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Unable to obtain transmitlogkey2 (ntrKitDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
                     END
                  END -- if getkey successful
               END -- not exists in transmitlog2
   
            END -- if update to status '9', ULV_INTERFACE
         END -- while
      END -- Update Status
   END -- End - (ULVHK Interface - ispExportKitUIINV)

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,700,02,0,KIT Update                                   ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
      END

      Declare @cStatus NVARCHAR(1)

      SELECT @cStatus = Status FROM INSERTED

         UPDATE KIT with (ROWLOCK)
         SET   KIT.OpenQty = KIT.OpenQty - (SELECT SUM(INSERTED.Qty) FROM INSERTED, DELETED
                                                WHERE INSERTED.KitKey = KIT.KitKey
                                                and INSERTED.KitKey = DELETED.KitKey
                                                AND INSERTED.KitLineNumber = DELETED.KitLineNumber -- Added By June 5.Jan.02 (OpenQty x updated Correctly)
                                                AND INSERTED.Type = DELETED.Type -- Added By June 5.Jan.02 (OpenQty x updated Correctly)
                                                AND INSERTED.Status = '9'
                                                AND DELETED.Status <> '9'
                                                AND INSERTED.Type = 'T' -- Added By June 5.Jan.02 (OpenQty x updated Correctly)
                                             ), 
               TrafficCop = NULL, -- SHONG001 
               EditDate = GETDATE(),    --tlting
               EditWho = SUSER_SNAME()
         FROM  KIT, INSERTED, DELETED
         WHERE KIT.KitKey = INSERTED.KitKey
         AND INSERTED.KitKey = DELETED.KitKey
         AND INSERTED.KitLineNumber = DELETED.KitLineNumber -- Added By June 5.Jan.02 (OpenQty x updated Correctly)
         AND INSERTED.Type = DELETED.Type -- Added By June 5.Jan.02 (OpenQty x updated Correctly)
         AND INSERTED.Status = '9'
         AND INSERTED.Type = 'T' -- Added By June 5.Jan.02 (OpenQty x updated Correctly)
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 70001   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Insert failed on table KIT. (ntrKitDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE = ' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,700,02,9,KIT Update                                   ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
      END
   END
   /* #INCLUDE <TRTDU2.SQL> */
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > = @n_starttcnt
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
      execute nsp_logerror @n_err, @c_errmsg, 'ntrKitDetailUpdate'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,700,00,9,ntrKitDetailUpdate Trigger                       ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
      END
      RETURN
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,700,00,9,ntrKitDetailUpdate Trigger                       ,' + CONVERT(char(12), getdate(), 114)
         PRINT @profiler
      END
      RETURN
   END
END

GO
ALTER TABLE [dbo].[KITDETAIL] ADD CONSTRAINT [PK_KITDETAIL] PRIMARY KEY CLUSTERED ([KITKey], [KITLineNumber], [Type]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[KITDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[KITDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[KITDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[KITDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[KITDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Channel', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Channel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Channel ID', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Channel_ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently expected in the location.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'ExpectedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Kitting used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'ExternKitKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External order detail line number imported', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'ExternLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Kitting.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'KITKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Kit line number', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'KITLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical location in a facility.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric values associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable01', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'LOTTABLE01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable02', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'LOTTABLE02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable03', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'LOTTABLE03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable04', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'LOTTABLE04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable05', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'LOTTABLE05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable07', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable08', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable09', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable10', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable11', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable11'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable12', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable12'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable13', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable13'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable14', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable14'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable15', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable15'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Timestamp'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of Shipment Order. The default is Standard', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'UOM'
GO
