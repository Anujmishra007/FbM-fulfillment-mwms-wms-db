CREATE TABLE [dbo].[ADJUSTMENTDETAIL]
(
[AdjustmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdjustmentLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Sku] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Loc] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lot] DEFAULT (' '),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Id] DEFAULT (' '),
[ReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_ReasonCode] DEFAULT ('0'),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UOM] DEFAULT (' '),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_PackKey] DEFAULT ('STD'),
[Qty] [int] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Qty] DEFAULT ((0)),
[CaseCnt] [int] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_CaseCnt] DEFAULT ((0)),
[InnerPack] [int] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_InnerPack] DEFAULT ((0)),
[Pallet] [int] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Pallet] DEFAULT ((0)),
[Cube] [float] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Cube] DEFAULT ((0)),
[GrossWgt] [float] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_GrossWgt] DEFAULT ((0)),
[NetWgt] [float] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_NetWgt] DEFAULT ((0)),
[OtherUnit1] [float] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_OtherUnit1] DEFAULT ((0)),
[OtherUnit2] [float] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_OtherUnit2] DEFAULT ((0)),
[ItrnKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_ItrnKey] DEFAULT (' '),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [timestamp] NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine10] DEFAULT (' '),
[FinalizedFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_FinalizedFlag] DEFAULT ('N'),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable01] DEFAULT (' '),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable02] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable03] DEFAULT (' '),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UCCNo] DEFAULT (''),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AdjustmentDetail_Channel] DEFAULT (''),
[Channel_ID] [bigint] NULL CONSTRAINT [DF_AdjustmentDetail_Channel_ID] DEFAULT ((0))
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[ADJUSTMENTDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[ADJUSTMENTDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ADJUSTMENTDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ADJUSTMENTDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ADJUSTMENTDETAIL] TO [NSQL]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*******************************************************************************/
/* Trigger: ntrAdjustmentDetailAdd                                             */
/* Creation Date:                                                              */
/* Copyright: IDS                                                              */
/* Written by:                                                                 */
/*                                                                             */
/* Purpose:                                                                    */
/*                                                                             */
/* Usage:                                                                      */
/*                                                                             */
/* Called By: When records add into AdjustmentDetail                           */
/*                                                                             */
/* PVCS Version: 1.9                                                           */
/*                                                                             */
/* Version: 5.4                                                                */
/*                                                                             */
/* Data Modifications:                                                         */
/*                                                                             */
/* Updates:                                                                    */
/* Date         Author       Ver.   Purposes                                   */
/* 30-Aug-2004  Shong        1.0    Move from Branch                           */
/* 30-Jun-2005  Shong        1.0    Check Finalize option by Storer            */
/* 19-Oct-2006  MaryVong     1.0    Add in RDT compatible error messages       */
/* 28-Jun-2007  MaryVong     1.0    Remove dbo.fnc_RTRIM and dbo.fnc_LTRIM     */
/* 05-Jul-2007  Shong        1.0    SOS75806 - UCC Adjustment                  */
/* 24-Mar-2010  YokeBeen     1.1    SOS#165421 - New Trigger point - "OWADJWO" */
/*                                  for WMS-E1 Work Order process.             */
/*                                  - (YokeBeen01)                             */
/* 31-Jan-2011  YTWan        1.2    Adjustment Status Control. (Wan01)         */
/* 05-Sep-2013  NJOW01       1.3    288779-fix to skip update UCC if adj create*/
/*                                  from CC UCC adj posting                    */
/* 07-May-2014  TKLIM        1.4    Added Lottables 06-15                      */
/* 28-Sep-2016  Leong        1.5    Skip trigger if ArchiveCop = '9'.          */
/* 27-Jul-2017  TLTING       1.6    Remove SETROWCOUNT                         */
/* 06-Feb-2018  SWT02        1.7    Added Channel Management Logic             */
/* 23-JUL-2019  Wan02        1.8    WMS-9872 - CN_NIKESDC_Exceed_Channel       */
/* 01-Jun-2020  Wan03        1.9    WMS-13117 - [CN] Sephora_WMS_ITRN_Add_UCC_CR*/
/*******************************************************************************/

CREATE TRIGGER [dbo].[ntrAdjustmentDetailAdd]
ON  [dbo].[ADJUSTMENTDETAIL]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS oFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
         , @n_err                int       -- Error number returned by stored procedure or this trigger
         , @n_err2               int       -- For Additional Error Detection
         , @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
         , @n_continue           int
         , @n_starttcnt          int       -- Holds the current transaction count
         , @c_preprocess         NVARCHAR(250) -- preprocess
         , @c_pstprocess         NVARCHAR(250) -- post process
         , @n_cnt                int

   DECLARE @c_authority_OWITF    NVARCHAR(1)   -- (YokeBeen01)
         , @c_authority_OWADJWO  NVARCHAR(1)   -- (YokeBeen01)
         , @c_cckey              NVARCHAR(10)  -- NJOW01

   DECLARE @c_UCCStatus          NVARCHAR(10) = '' --(Wan03)

   SELECT @n_continue=1, @n_starttcnt = @@TRANCOUNT
   /* #INCLUDE <TRADA1.SQL> */
  
   -- To Skip all the trigger process when Insert the history records from Archive as user request
   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

   IF @n_continue=1 or @n_continue=2
   BEGIN
      DECLARE @c_FinalizeAdjustment NVARCHAR(1) -- Flag to see if overallocations are allowed.
      DECLARE @c_StorerKey NVARCHAR(15), 
              @c_Facility  NVARCHAR(10)
              
            , @c_ChannelInventoryMgmt      NVARCHAR(10) = '0' -- (SWT02)
            
      SELECT TOP 1
             @c_StorerKey = INSERTED.StorerKey, 
             @c_Facility  = LOC.Facility 
      FROM   INSERTED 
      JOIN   LOC WITH (NOLOCK) ON LOC.LOC = INSERTED.LOC 

      SELECT @b_success = 0
      EXECUTE nspGetRight
               NULL,                    -- Facility
               @c_StorerKey,            -- Storer
               NULL,                    -- No Sku in this Case
               'FinalizeAdjustment',    -- ConfigKey
               @b_success               output,
               @c_FinalizeAdjustment    output,
               @n_err                   output,
               @c_errmsg                output

      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 62701  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                          + ': Retrieve Failed On GetRight (FinalizeAdjustment). (ntrAdjustmentDetailAdd)'
      END

      --(Wan01) - START
      IF @n_continue=1 or @n_continue=2
      BEGIN
         DECLARE @c_ADJStatusCtrl      NVARCHAR(10)

         SET @c_ADJStatusCtrl = ''
         SET @b_success = 0
         EXECUTE nspGetRight
                  NULL                     -- Facility
                , @c_StorerKey             -- Storer
                , NULL                     -- No Sku in this Case
                , 'AdjStatusControl'       -- ConfigKey
                , @b_success               OUTPUT
                , @c_ADJStatusCtrl         OUTPUT
                , @n_err                   OUTPUT
                , @c_errmsg                OUTPUT

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3
            SELECT @n_err = 62702  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                             + ': Retrieve Failed On GetRight (AdjStatusControl). (ntrAdjustmentDetailAdd)'
         END
      END
      --(Wan01) - END

      IF @c_FinalizeAdjustment = '1' OR @c_ADJStatusCtrl = '1'                                     --(Wan01)
      BEGIN
         SELECT @n_continue = '4'
      END

      -- (Wan02) - START
      -- (SWT02)
      --SET @c_ChannelInventoryMgmt = '0'
      --If @n_continue = 1 or @n_continue = 2
      --Begin
      --   Select @b_success = 0
      --   Execute nspGetRight      
      --   @c_facility,
      --   @c_StorerKey,           -- Storer
      --   '',                     -- Sku
      --   'ChannelInventoryMgmt', -- ConfigKey
      --   @b_success    output,
      --   @c_ChannelInventoryMgmt  output,
      --   @n_err        output,
      --   @c_errmsg     output
      --   If @b_success <> 1
      --   Begin
      --      Select @n_continue = 3, @n_err = 61961, @c_errmsg = 'nspItrnAddAdjustmentCheck:' + ISNULL(RTRIM(@c_errmsg),'')
      --   End
      --END      
       
   END -- IF @n_continue=1 or @n_continue=2

   IF @n_continue=1 or @n_continue=2
   BEGIN
      DECLARE  @c_ADJ_AdjustmentKey        NVARCHAR(10)
             , @c_ADJ_AdjustmentLineNumber NVARCHAR(5)
             , @c_ADJ_StorerKey            NVARCHAR(15)
             , @c_ADJ_Sku                  NVARCHAR(20)
             , @c_ADJ_Loc                  NVARCHAR(10)
             , @c_ADJ_Lot                  NVARCHAR(10)
             , @c_ADJ_Id                   NVARCHAR(18)
             , @c_ADJ_ReasonCode           NVARCHAR(10)
             , @n_ADJ_Qty                  int
             , @n_ADJ_CaseCnt              int
             , @n_ADJ_InnerPack            int
             , @n_ADJ_Pallet               int
             , @n_ADJ_Cube                 float
             , @n_ADJ_GrossWgt             float
             , @n_ADJ_NetWgt               float
             , @n_ADJ_OtherUnit1           float
             , @n_ADJ_OtherUnit2           float
             , @c_ADJ_packkey              NVARCHAR(10)
             , @c_ADJ_uom                  NVARCHAR(10)
             , @d_ADJ_EffectiveDate        datetime
             , @c_ItrnKey                  NVARCHAR(10)
             , @c_SourceKey                NVARCHAR(15)
             , @c_AdjustmentKey            NVARCHAR(10)
             , @c_AdjustmentLineNumber     NVARCHAR(5)
             , @c_ADJ_UCCNo                NVARCHAR(20)  -- SOS75806
             , @c_Channel                  NVARCHAR(20) = '' --(SWT02)
             , @n_Channel_ID               BIGINT = 0 --(SWT02)
 
      DECLARE  @c_lottable01     NVARCHAR(18)   -- Lot lottable01
            ,  @c_lottable02     NVARCHAR(18)   -- Lot lottable02
            ,  @c_lottable03     NVARCHAR(18)   -- Lot lottable03
            ,  @d_lottable04     DATETIME       -- Lot lottable04
            ,  @d_lottable05     DATETIME       -- Lot lottable05
            ,  @c_Lottable06     NVARCHAR(30)
            ,  @c_Lottable07     NVARCHAR(30)
            ,  @c_Lottable08     NVARCHAR(30)
            ,  @c_Lottable09     NVARCHAR(30)
            ,  @c_Lottable10     NVARCHAR(30)
            ,  @c_Lottable11     NVARCHAR(30)
            ,  @c_Lottable12     NVARCHAR(30)
            ,  @d_Lottable13     DATETIME
            ,  @d_Lottable14     DATETIME
            ,  @d_Lottable15     DATETIME
                             
      SELECT @c_ADJ_AdjustmentKey = SPACE(10)
      WHILE (1=1)
      BEGIN
         SELECT TOP 1 @c_ADJ_AdjustmentKey = AdjustmentKey
           FROM INSERTED
          WHERE AdjustmentKey > @c_ADJ_AdjustmentKey
          ORDER BY AdjustmentKey

         IF @@ROWCOUNT = 0
         BEGIN
            BREAK
         END

         --(Wan02) - START
         SET @c_ChannelInventoryMgmt = ''
         SELECT TOP 1 @c_ChannelInventoryMgmt = SC.Authority
         FROM ADJUSTMENT ADJ WITH (NOLOCK)
         CROSS APPLY fnc_SelectGetRight (ADJ.facility, ADJ.StorerKey, '', 'ChannelInventoryMgmt') SC
         WHERE ADJ.AdjustmentKey = @c_ADJ_AdjustmentKey
         --(Wan02) - END

         --NJOW01
         SET @c_cckey = ''
         SELECT TOP 1 @c_cckey = StockTakeSheetParameters.StockTakeKey
         FROM ADJUSTMENT (NOLOCK)
         JOIN StockTakeSheetParameters (NOLOCK) ON ADJUSTMENT.CustomerRefNo = StockTakeSheetParameters.StockTakeKey
         WHERE ADJUSTMENT.Adjustmentkey = @c_ADJ_AdjustmentKey

         SELECT @c_ADJ_AdjustmentLineNumber = SPACE(5)
         WHILE (1=1)
         BEGIN
            SELECT TOP 1 @c_ADJ_AdjustmentKey  = AdjustmentKey
                 , @c_ADJ_AdjustmentLineNumber = AdjustmentLineNumber
                 , @c_ADJ_StorerKey            = StorerKey
                 , @c_ADJ_Sku                  = Sku
                 , @c_ADJ_Loc                  = Loc
                 , @c_ADJ_Lot                  = Lot
                 , @c_ADJ_Id                   = Id
                 , @c_ADJ_ReasonCode           = ReasonCode
                 , @n_ADJ_Qty                  = Qty
                 , @n_ADJ_CaseCnt              = CaseCnt
                 , @n_ADJ_InnerPack            = InnerPack
                 , @n_ADJ_Pallet               = Pallet
                 , @n_ADJ_Cube                 = Cube
                 , @n_ADJ_GrossWgt             = GrossWgt
                 , @n_ADJ_NetWgt               = NetWgt
                 , @n_ADJ_OtherUnit1           = OtherUnit1
                 , @n_ADJ_OtherUnit2           = OtherUnit2
                 , @c_ADJ_packkey              = Packkey
                 , @c_ADJ_uom                  = UOM
                 , @d_ADJ_EffectiveDate        = EffectiveDate
                 , @c_ItrnKey                  = ItrnKey
                 , @c_ADJ_UCCNo                = ISNULL(INSERTED.UCCNo, '') -- SOS75806
                 , @c_Channel                  = INSERTED.Channel    --(SWT02)
                 , @n_Channel_ID               = INSERTED.Channel_ID --(SWT02)
              FROM INSERTED
             WHERE AdjustmentKey = @c_ADJ_AdjustmentKey
               AND AdjustmentLineNumber > @c_ADJ_AdjustmentLineNumber
             ORDER BY AdjustmentKey,AdjustmentLineNumber

            IF @@ROWCOUNT = 0
            BEGIN
               BREAK
            END
            -- Add by June 29.Jan.02
            -- HK Phase II : To Update Itrn's lottable details

            IF @c_ChannelInventoryMgmt = '1'
            BEGIN
               IF ISNULL(RTRIM(@c_Channel),'') = ''
               BEGIN
                   SELECT @n_err = 70001
                   SELECT @c_errmsg = "NSQL"+CONVERT(char(5),@n_err)+": Channel Management Enabled, Channel Cannot be BLANK. (ntrAdjustmentDetailAdd)"
                   Select @n_continue = 3
                   BREAK                                 
               END
            END   

            --(Wan03) - START
            IF @c_ADJ_UCCNo <> ''
            BEGIN
               SET @c_UCCStatus = ''
               SELECT TOP 1 @c_UCCStatus = UCC.[Status]
               FROM UCC WITH (NOLOCK)
               WHERE UCC.Storerkey = @c_ADJ_Storerkey
               AND   UCC.UCCNo = @c_ADJ_UCCNo
               AND   UCC.Sku = @c_ADJ_Sku
               AND   UCC.Lot = @c_ADJ_lot
               AND   UCC.Loc = @c_ADJ_loc
               AND   UCC.ID  = @c_ADJ_ID
            END
            --(Wan03) - END
            
            SELECT   @c_lottable01 = lottable01
                  ,  @c_lottable02 = lottable02
                  ,  @c_lottable03 = lottable03
                  ,  @d_lottable04 = lottable04
                  ,  @d_lottable05 = lottable05
                  ,  @c_lottable06 = lottable06
                  ,  @c_lottable07 = lottable07
                  ,  @c_lottable08 = lottable08
                  ,  @c_lottable09 = lottable09
                  ,  @c_lottable10 = lottable10
                  ,  @c_lottable11 = lottable11
                  ,  @c_lottable12 = lottable12
                  ,  @d_lottable13 = lottable13
                  ,  @d_lottable14 = lottable14
                  ,  @d_lottable15 = lottable15
              FROM LOTATTRIBUTE WITH (NOLOCK)
             WHERE Lot = @c_ADJ_lot

            -- End - Add by June 29.Jan.02
            SELECT @c_SourceKey = dbo.fnc_LTRIM(dbo.fnc_RTrim((@c_ADJ_AdjustmentKey)))
                                + dbo.fnc_LTRIM(dbo.fnc_RTRIM(@c_ADJ_AdjustmentLineNumber))
            SELECT @b_success = 0

            EXECUTE  nspItrnAddAdjustment
                     @n_ItrnSysId     = NULL,
                     @c_StorerKey     = @c_ADJ_StorerKey,
                     @c_Sku           = @c_ADJ_Sku,
                     @c_Lot           = @c_ADJ_Lot,
                     @c_ToLoc         = @c_ADJ_Loc,
                     @c_ToID          = @c_ADJ_Id,
                     @c_Status        = '',
                     @c_lottable01    = @c_lottable01, -- Changed by June 29.Jan.02
                     @c_lottable02    = @c_lottable02, -- Changed by June 29.Jan.02
                     @c_lottable03    = @c_lottable03, -- Changed by June 29.Jan.02
                     @d_lottable04    = @d_lottable04, -- Changed by June 29.Jan.02
                     @d_lottable05    = @d_lottable05, -- Changed by June 29.Jan.02
                     @c_lottable06    = @c_lottable06,
                     @c_lottable07    = @c_lottable07,
                     @c_lottable08    = @c_lottable08,
                     @c_lottable09    = @c_lottable09,
                     @c_lottable10    = @c_lottable10,
                     @c_lottable11    = @c_lottable11,
                     @c_lottable12    = @c_lottable12,
                     @d_lottable13    = @d_lottable13,
                     @d_lottable14    = @d_lottable14,
                     @d_lottable15    = @d_lottable15,
                     @c_Channel       = @c_Channel, 
                     @n_Channel_ID    = @n_Channel_ID,
                     @n_casecnt       = @n_ADJ_CaseCnt,
                     @n_innerpack     = @n_ADJ_InnerPack,
                     @n_qty           = @n_ADJ_Qty,
                     @n_pallet        = @n_ADJ_Pallet,
                     @f_cube          = @n_ADJ_Cube,
                     @f_grosswgt      = @n_ADJ_GrossWgt,
                     @f_netwgt        = @n_ADJ_NetWgt,
                     @f_otherunit1    = @n_ADJ_OtherUnit1,
                     @f_otherunit2    = @n_ADJ_OtherUnit2,
                     @c_SourceKey     = @c_SourceKey,
                     @c_SourceType    = 'ntrAdjustmentDetailAdd',
                     @c_PackKey       = @c_AdJ_packkey,
                     @c_UOM           = @c_ADJ_uom,
                     @b_UOMCalc       = 0,
                     @d_EffectiveDate = @d_ADJ_EffectiveDate,
                     @c_itrnkey       = @c_ItrnKey OUTPUT,
                     @b_Success       = @b_Success OUTPUT,
                     @n_err           = @n_err     OUTPUT,
                     @c_errmsg        = @c_errmsg  OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3 /* Other Error flags Set By nspItrnAddAdjustment */
               BREAK
            END
            ELSE
            BEGIN
               -- SOS75806 UCC Adjustment
               IF @c_ADJ_UCCNo <> ''
               BEGIN
                  IF NOT EXISTS( SELECT 1 FROM UCC WITH (NOLOCK)
                                  WHERE StorerKey = @c_ADJ_StorerKey AND UCCNo = @c_ADJ_UCCNo)
                  BEGIN
                     INSERT INTO UCC (UCCNo, Storerkey, ExternKey, SKU, qty, Sourcekey,
                                      Sourcetype, Status, Lot, Loc, Id)
                     VALUES (@c_ADJ_UCCNo, @c_ADJ_StorerKey, '', @c_ADJ_Sku, @n_ADJ_Qty, @c_SourceKey,
                    'ADJUSTMENT', '1', @c_ADJ_Lot, @c_ADJ_Loc, @c_ADJ_ID)

                     SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
                     IF @n_err <> 0
                     BEGIN
                        SELECT @n_continue = 3
                        SELECT @n_err = 62703 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                        SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                         + ': Insert Failed On Table UCC. (ntrAdjustmentDetailAdd)'
                        BREAK
                     END
                  END
                  ELSE
                  BEGIN
                      IF ISNULL(@c_cckey,'') = '' --NJOW01
                      BEGIN
                        UPDATE UCC WITH (ROWLOCK)
                           SET Qty = Qty + @n_ADJ_Qty,
                               Lot = @c_ADJ_Lot,
                               LOC = @c_ADJ_Loc,
                               ID  = @c_ADJ_ID,
                               Status = CASE WHEN (Qty + @n_ADJ_Qty) = 0 THEN '0'
                                             ELSE '1'
                                        END
                         WHERE StorerKey = @c_ADJ_StorerKey
                           AND UCCNo = @c_ADJ_UCCNo
                           AND Status IN ('0','1')

                        SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
                        IF @n_err <> 0
                        BEGIN
                           SELECT @n_continue = 3
                           SELECT @n_err = 62704 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                           SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                            + ': Update Failed On Table UCC. (ntrAdjustmentDetailAdd)'
                           BREAK
                        END
                     END
                  END

                  EXEC isp_ItrnUCCAdd
                       @c_Storerkey       = @c_ADJ_StorerKey 
                     , @c_UCCNo           = @c_ADJ_UCCNo     
                     , @c_Sku             = @c_ADJ_Sku  
                     , @c_UCCStatus       = @c_UCCStatus            
                     , @c_SourceKey       = @c_Sourcekey         
                     , @c_ItrnSourceType  = 'ntrAdjustmentDetailAdd' 
                     , @c_ToStorerkey     = '' 
                     , @c_ToUCCNo         = ''     
                     , @c_ToSku           = ''  
                     , @c_ToUCCStatus     = ''                         
                     , @b_Success         = @b_Success          OUTPUT
                     , @n_Err             = @n_Err              OUTPUT
                     , @c_ErrMsg          = @c_ErrMsg           OUTPUT

                  IF @b_Success <> 1  
                  BEGIN
                     SET @n_continue = 3     
                     SET @n_err = 62709 
                     SET @c_ErrMsg='NSQL'+CONVERT(char(5),@n_err)+': Add ITRN UCC Fail. (isp_FinalizeADJ)' 
                                    + ' ( ' + ' SQLSvr MESSAGE=' + RTrim(@c_ErrMsg) + ' ) '  
                     ROLLBACK TRAN
                     BREAK
                  END
               END -- IF @c_ADJ_UCCNo <> ''
            END -- IF @b_success = 1

            IF @n_continue = 1 OR @n_continue = 2
            BEGIN
               UPDATE ADJUSTMENTDETAIL WITH (ROWLOCK)
                  SET TrafficCop = NULL,
                      ItrnKey = @c_itrnkey,
                      AddDate = GETDATE(),
                      AddWho  = suser_sname(),
                      EditDate = GETDATE(),
                      EditWho = suser_sname(),
                      FinalizedFlag = 'Y'
                WHERE AdjustmentKey = @c_ADJ_AdjustmentKey
                  AND AdjustmentLineNumber = @c_ADJ_AdjustmentLineNumber

               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @n_err = 62705 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                   + ': Update Failed On Table ADJUSTMENTDETAIL. (ntrAdjustmentDetailAdd)'
                  BREAK
               END
               IF @n_cnt = 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @n_err = 62706 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                   + ': No record updated into Table ADJUSTMENTDETAIL. (ntrAdjustmentDetailAdd)'
                  BREAK
               END
            END -- IF @n_continue = 1 OR @n_continue = 2

            -- (YokeBeen01) - Start
            SELECT @b_success = 0
            EXECUTE nspGetRight
                     NULL,                  -- Facility
                     @c_StorerKey,          -- Storer
                     NULL,                  -- No Sku in this Case
                     'OWITF',               -- ConfigKey
                @b_success             output,
                     @c_authority_OWITF     output,
                     @n_err                 output,
                     @c_errmsg              output

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3
               SELECT @n_err = 62707
               SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                + ': Retrieve Failed On GetRight (OWITF). (ntrAdjustmentDetailAdd)'
            END
            ELSE IF @c_authority_OWITF = '1'
            BEGIN
               SELECT @c_authority_OWADJWO = STORERCONFIG.sValue
                 FROM ADJUSTMENT WITH (NOLOCK)
                 JOIN ADJUSTMENTDETAIL WITH (NOLOCK) ON ( ADJUSTMENT.AdjustmentKey = ADJUSTMENTDETAIL.AdjustmentKey )
                 JOIN STORERCONFIG WITH (NOLOCK) ON ( ADJUSTMENTDETAIL.StorerKey = STORERCONFIG.StorerKey
                                                  AND STORERCONFIG.ConfigKey = 'OWADJWO' AND sValue = '1' )
                 JOIN CODELKUP WITH (NOLOCK) ON ( ADJUSTMENT.AdjustmentType = CODELKUP.Code
                                              AND CODELKUP.Listname = 'ADJTYPE' AND CODELKUP.Long = 'OWADJWO' )
                WHERE ADJUSTMENTDETAIL.AdjustmentKey = @c_ADJ_AdjustmentKey
                  AND ADJUSTMENTDETAIL.AdjustmentLineNumber = @c_ADJ_AdjustmentLineNumber
                  AND ADJUSTMENTDETAIL.FinalizedFlag = 'Y'

               IF @c_authority_OWADJWO = '1'
               BEGIN
                  EXEC ispGenTransmitLog 'OWADJWO', @c_ADJ_AdjustmentKey, @c_ADJ_AdjustmentLineNumber, @c_StorerKey, ''
                     , @b_success OUTPUT
                     , @n_err OUTPUT
                     , @c_errmsg OUTPUT

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @n_err = 62708
                     SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                      + ': Insert Into TransmitLog Table (OWADJWO) Failed (ntrItrnAdd)'
                                      + ' ( SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
                  END
               END -- IF @c_authority_OWADJWO = '1'
            END -- IF @c_authority_OWITF = '1'
            -- (YokeBeen01) - End
         END -- WHILE (1=1) -- AdjustmentLineNumber
      END -- WHILE (1=1) -- Adjustmentkey
   END

   /* #INCLUDE <TRADA2.SQL> */
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      DECLARE @n_IsRDT INT
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT

      IF @n_IsRDT = 1
      BEGIN
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
         -- Instead we commit and raise an error back to parent, let the parent decide

         -- Commit until the level we begin with
         WHILE @@TRANCOUNT > @n_starttcnt
            COMMIT TRAN

         -- Raise error with severity = 10, instead of the default severity 16.
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger
         RAISERROR (@n_err, 10, 1) WITH SETERROR

         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten
      END
      ELSE
      BEGIN
         IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt
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
         EXECUTE dbo.nsp_logerror @n_err, @c_errmsg, 'ntrAdjustmentDetailAdd'
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
         RETURN
      END
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
/* Trigger: ntrAdjustmentDetailDelete                                   */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: When records delete from AdjustmentDetail                 */
/*                                                                      */
/* PVCS Version: 1.3                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 15-Jul-2004  June          SOS25237 Not allow deletion if finalized  */
/* 06-Jun-2005  Shong         Reindent codes                            */
/* 19-Oct-2006  MaryVong      Add in RDT compatible error messages      */
/* 27-Apr-2011  KHLim01       Insert Delete log                         */
/* 14-Jul-2011  KHLim02       GetRight for Delete log                   */
/* 22-May-2012  TLTING02      DM Data integrity - insert dellog 4       */
/*                            status < '9'                              */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrAdjustmentDetailDelete]
ON [dbo].[ADJUSTMENTDETAIL]
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
   
   DECLARE @b_Success  int,       -- Populated by calls to stored procedures - was the proc successful?
   @n_err              int,       -- Error number returned by stored procedure or this trigger
   @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
   @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
   @n_starttcnt        int,       -- Holds the current transaction count
   @n_cnt              int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
  ,@c_authority        NVARCHAR(1)  -- KHLim02


   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   if (select count(*) from DELETED) =
      (select count(*) from DELETED where DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END
   
   -- tlting02
   IF EXISTS ( SELECT 1 FROM DELETED WHERE  FinalizedFlag <> 'Y') AND ( @n_continue = 1 or @n_continue = 2 )
   BEGIN
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
                  ,@c_errmsg = 'ntrAdjustmentDetailDelete' + dbo.fnc_RTrim(@c_errmsg)
         END
         ELSE 
         IF @c_authority = '1'         --    End   (KHLim02)
         BEGIN
            INSERT INTO dbo.ADJUSTMENTDETAIL_DELLOG ( AdjustmentKey, AdjustmentLineNumber )
            SELECT AdjustmentKey, AdjustmentLineNumber FROM DELETED
            WHERE  FinalizedFlag <> 'Y'

            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table ADJUSTMENTDETAIL Failed. (ntrAdjustmentDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
            END
         END
      END
   END

   /* #INCLUDE <TRADD1.SQL> */
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      -- SELECT @n_continue = 3
      SELECT @n_err = 62726 --67201
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': DELETE not allowed. (ntrAdjustmentDetailDelete)'
   END

   -- Start : Add by June 15.Jul.2004 (SOS25237)
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      IF EXISTS ( SELECT *
      FROM  DELETED
      WHERE FinalizedFlag = "Y" )
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 62727 --70101
         SELECT @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Posted rows may not be deleted. (ntrAdjustmentDetailDelete)'
      END
   END
   -- End : SOS25237

   /* #INCLUDE <TRADD2.SQL> */   
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      DECLARE @n_IsRDT INT
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT
   
      IF @n_IsRDT = 1
      BEGIN
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
         -- Instead we commit and raise an error back to parent, let the parent decide
   
         -- Commit until the level we begin with
         WHILE @@TRANCOUNT > @n_starttcnt
            COMMIT TRAN
   
         -- Raise error with severity = 10, instead of the default severity 16. 
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger
         RAISERROR (@n_err, 10, 1) WITH SETERROR 
   
         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten
      END
      ELSE
      BEGIN
         IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrAdjustmentDetailDelete'
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
         RETURN
      END
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


/*******************************************************************************/
/* Trigger: ntrAdjustmentDetailUpdate                                          */
/* Creation Date:                                                              */
/* Copyright: IDS                                                              */
/* Written by:                                                                 */
/*                                                                             */
/* Purpose:                                                                    */
/*                                                                             */
/* Usage:                                                                      */
/*                                                                             */
/* Called By: When records update into AdjustmentDetail                        */
/*                                                                             */
/* PVCS Version: 2.2                                                           */
/*                                                                             */
/* Version: 5.4                                                                */
/*                                                                             */
/* Data Modifications:                                                         */
/*                                                                             */
/* Updates:                                                                    */
/* Date         Author       Ver.   Purposes                                   */
/* 30-Aug-2004  Shong        1.0    Move from Branch                           */
/* 18-Oct-2004  Wally        1.0    Enable trafficcop / archivecop checking    */
/* 30-Jun-2005  Shong        1.0    Check Finalize option by Storer            */
/* 19-Oct-2006  MaryVong     1.0    Add in RDT compatible error messages       */
/* 28-Jun-2007  MaryVong     1.0    Remove dbo.fnc_RTRIM and dbo.fnc_LTRIM     */
/* 05-Jul-2007  Shong        1.0    SOS75806 - UCC Adjustment                  */
/* 04 Jan 2009  TLTING       1.0    Update eidtwho and editdate (tlting01)     */
/* 24-Mar-2010  YokeBeen     1.1    SOS#165421 - New Trigger point - "OWADJWO" */
/*                                  for WMS-E1 Work Order process.             */
/*                                  - (YokeBeen01)                             */
/* 31-Jan-2012  YTWan        1.3    Adjustment Status Control. (Wan01)         */
/* 28-Feb-2012  YTWan        1.4    Fixed. SOS#236991-NO Itrn & Not update     */
/*                                  inventory when finalized. (Wan02)          */
/* 07-May-2012  YTWan        1.5    SOS#242809-Continue to process if fail for */
/*                                  Storerconfig 'ADJStatusControl' turn on.   */
/*                                  (Wan03)                                    */
/* 23-May-2012  TLTING02     1.6    DM integrity - add update editdate B4      */
/*                                  TrafficCop for status < '9'                */     
/* 23-Jul-2013  KHLim        1.7    Insert ver. SOS162898 - Bond-Lock (KH01)   */
/* 05-Sep-2013  NJOW01       1.8    288779-fix to skip update UCC if adj create*/
/*                                  from CC UCC adj posting                    */
/* 18-Sep-2013  YTWan        1.82   Add Sku to UCC Checking (for Multisku).    */
/*                                  (Wan04)                                    */
/* 28-Oct-2013  TLTING       1.9    Review Editdate column update              */
/* 07-May-2014  TKLIM        1.10   Added Lottables 06-15                      */
/* 27-Jul-2017  TLTING       1.11   Remove SETROWCOUNT                         */
/* 09-Jan-2018  AikLiang     2.0    INC0093779 - Increase lottable06-12 size   */
/*                                  to 30, tally with itrn table (AL01)        */
/* 06-Feb-2018  SWT02        2.1    Added Channel Management Logic             */
/* 23-JUL-2019  Wan05        2.2    WMS-9872 - CN_NIKESDC_Exceed_Channel       */
/*******************************************************************************/

CREATE TRIGGER [dbo].[ntrAdjustmentDetailUpdate]
ON  [dbo].[ADJUSTMENTDETAIL]
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
         , @n_err                int       -- Error number returned by stored procedure or this trigger
         , @n_err2               int       -- For Additional Error Detection
         , @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
         , @n_continue           int
         , @n_starttcnt          int       -- Holds the current transaction count
         , @c_preprocess         NVARCHAR(250) -- preprocess
         , @c_pstprocess         NVARCHAR(250) -- post process
         , @n_cnt                int

   DECLARE @c_authority_OWITF    NVARCHAR(1)   -- (YokeBeen01)
         , @c_authority_OWADJWO  NVARCHAR(1)   -- (YokeBeen01)
         , @c_cckey              NVARCHAR(10)  -- NJOW01      
         
         , @c_ChannelInventoryMgmt  NVARCHAR(10) = '0' -- (SWT02)         
         
         
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   /* #INCLUDE <TRADA1.SQL> */

   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4
   END
   
   -- tlting02
   IF EXISTS ( SELECT 1 FROM INSERTED, DELETED 
               WHERE  INSERTED.AdjustmentKey = DELETED.AdjustmentKey
               AND INSERTED.AdjustmentLineNumber = DELETED.AdjustmentLineNumber
               AND ( INSERTED.FinalizedFlag <> 'Y' OR DELETED.FinalizedFlag <> 'Y' ) ) 
         AND ( @n_continue = 1 or @n_continue = 2 )
         AND NOT UPDATE(EditDate)  
   BEGIN
      UPDATE ADJUSTMENTDETAIL WITH (ROWLOCK) 
         SET TrafficCop = NULL, 
             EditDate = GETDATE(), 
             EditWho = SUSER_SNAME() 
        FROM ADJUSTMENTDETAIL 
        JOIN INSERTED ON ( ADJUSTMENTDETAIL.AdjustmentKey = inserted.AdjustmentKey 
                       AND ADJUSTMENTDETAIL.AdjustmentLineNumber = inserted.AdjustmentLineNumber )
      WHERE  ADJUSTMENTDETAIL.FinalizedFlag <> 'Y'
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 62810 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) 
                          + ': Update Failed On Table ADJUSTMENT. (ntrAdjustmentDetailUpdate) ( ' 
                          + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END

   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4
   END


   -- tlting01
   IF ( @n_continue=1 OR @n_continue=2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE ADJUSTMENTDETAIL WITH (ROWLOCK)
         SET TrafficCop = NULL,
             EditDate = GETDATE(),
             EditWho = SUSER_SNAME()
        FROM ADJUSTMENTDETAIL
        JOIN INSERTED ON ( ADJUSTMENTDETAIL.AdjustmentKey = inserted.AdjustmentKey
                       AND ADJUSTMENTDETAIL.AdjustmentLineNumber = inserted.AdjustmentLineNumber )
      WHERE  INSERTED.FinalizedFlag = 'Y'       -- tlting02

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 62800 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                          + ': Update Failed On Table ADJUSTMENT. (ntrAdjustmentDetailUpdate) ( '
                          + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END

   IF @n_continue=1 OR @n_continue=2
   BEGIN
      DECLARE @c_FinalizeAdjustment NVARCHAR(1) -- Flag to see if overallocations are allowed.
      DECLARE @c_StorerKey NVARCHAR(15), 
              @c_Facility  NVARCHAR(10)

      DECLARE @c_Bondedflag Char(1)    --KH01
      
      SELECT TOP 1
             @c_StorerKey = INSERTED.StorerKey, 
             @c_Facility  = LOC.Facility 
      FROM   INSERTED 
      JOIN   LOC WITH (NOLOCK) ON LOC.LOC = INSERTED.LOC 

      SELECT @b_success = 0

      EXECUTE nspGetRight
               NULL,  -- Facility
               @c_StorerKey,      -- Storer
               NULL,              -- No Sku in this Case
               'FinalizeAdjustment', -- ConfigKey
               @b_success             output,
               @c_FinalizeAdjustment  output,
               @n_err                 output,
               @c_errmsg              output

      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 62801 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                          + ': Retrieve Failed On GetRight. (ntrAdjustmentDetailUpdate)'
      END

      --(Wan01) - START
      IF @n_continue=1 or @n_continue=2
      BEGIN
         DECLARE @c_ADJStatusCtrl      NVARCHAR(10)  
                                                      
         SET @c_ADJStatusCtrl = ''                                                                    
         SET @b_success = 0
         EXECUTE nspGetRight
                  NULL                     -- Facility
                , @c_StorerKey             -- Storer
                , NULL                     -- No Sku in this Case
                , 'AdjStatusControl'       -- ConfigKey
                , @b_success               OUTPUT 
                , @c_ADJStatusCtrl         OUTPUT 
                , @n_err                   OUTPUT 
                , @c_errmsg                OUTPUT

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3
            SELECT @n_err = 62802  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                             + ': Retrieve Failed On GetRight (AdjStatusControl). (ntrAdjustmentDetailUpdate)'
         END
      END 
      --(Wan01) - END

      IF @c_FinalizeAdjustment = '1' OR @c_ADJStatusCtrl = '1'
      BEGIN
         SELECT @n_continue = '1'
      END
      ELSE
      BEGIN
         SELECT @n_continue = 4
      END

      --(Wan05) - START
      -- (SWT02)
      --SET @c_ChannelInventoryMgmt = '0'
      --If @n_continue = 1 or @n_continue = 2
      --BEGIN
      --   SELECT @b_success = 0
      --   Execute nspGetRight     
      --   @c_Facility,
      --   @c_StorerKey,           -- Storer
      --   '',                     -- Sku
      --   'ChannelInventoryMgmt', -- ConfigKey
      --   @b_success    output,
      --   @c_ChannelInventoryMgmt  output,
      --   @n_err        output,
      --   @c_errmsg     output
      --   If @b_success <> 1
      --   BEGIN
      --      SELECT @n_continue = 3, @n_err = 61961, @c_errmsg = 'nspItrnAddAdjustmentCheck:' + ISNULL(RTRIM(@c_errmsg),'')
      --   END
      --END   
      --(Wan05) - END      
   END

   IF @n_continue=1 OR @n_continue=2
   BEGIN
      IF EXISTS( SELECT 1 FROM DELETED WHERE FinalizedFlag = 'Y' )
      BEGIN
         SELECT @n_continue = 3,
                @n_err = 62803,
                @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + ': UPDATE not allowed. (ntrAdjustmentDetailUpdate)'
      END
   END

   IF @n_continue=1 or @n_continue=2      --KH01 start
   BEGIN
       SELECT @c_Bondedflag = '' 
       SELECT @b_Success = 0
      
       Execute nspGetRight null,         -- Facility
               @c_StorerKey, -- Storer
               null,         -- Sku
               'BondLocked',      -- ConfigKey
               @b_success    output, 
               @c_Bondedflag     output, 
               @n_err        output, 
               @c_errmsg     output
       If @b_success <> 1
       BEGIN
         SELECT @n_continue = 3 
         SELECT @n_err = 62758 --60119 --62311   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Retrieve Failed On GetRight. (ntrAdjustmentDetailUpdate)'
       END
   END
   
   IF @n_continue=1 OR @n_continue=2
   BEGIN
      DECLARE  @c_ADJ_AdjustmentKey        NVARCHAR(10),
               @c_ADJ_AdjustmentLineNumber NVARCHAR(5),
               @c_ADJ_StorerKey            NVARCHAR(15),
               @c_ADJ_Sku                  NVARCHAR(20),
               @c_ADJ_Loc                  NVARCHAR(10),
               @c_ADJ_Lot                  NVARCHAR(10),
               @c_ADJ_Id                   NVARCHAR(18),
               @c_ADJ_ReasonCode           NVARCHAR(10),
               @n_ADJ_Qty                  int,
               @n_ADJ_CaseCnt              int,
               @n_ADJ_InnerPack            int,
               @n_ADJ_Pallet               int,
               @n_ADJ_Cube                 float,
               @n_ADJ_GrossWgt             float,
               @n_ADJ_NetWgt               float,
               @n_ADJ_OtherUnit1           float,
               @n_ADJ_OtherUnit2           float,
               @c_ADJ_packkey              NVARCHAR(10) ,
               @c_ADJ_uom                  NVARCHAR(10) ,
               @d_ADJ_EffectiveDate        datetime,
               @c_ItrnKey                  NVARCHAR(10),
               @c_SourceKey                NVARCHAR(15),
               @c_AdjustmentKey            NVARCHAR(10),
               @c_AdjustmentLineNumber     NVARCHAR(5),
               @c_ADJ_UCCNo                NVARCHAR(20) -- SOS75806
             , @c_Channel                  NVARCHAR(20) = '' --(SWT02)
             , @n_Channel_ID               BIGINT = 0 --(SWT02)

      DECLARE  @c_lottable01     NVARCHAR(18)   -- Lot lottable01
            ,  @c_lottable02     NVARCHAR(18)   -- Lot lottable02
            ,  @c_lottable03     NVARCHAR(18)   -- Lot lottable03
            ,  @d_lottable04     DATETIME       -- Lot lottable04
            ,  @d_lottable05     DATETIME       -- Lot lottable05
            ,  @c_Lottable06     NVARCHAR(30)   -- NVARCHAR(20)  AL01  
            ,  @c_Lottable07     NVARCHAR(30)   -- NVARCHAR(20)  AL01
            ,  @c_Lottable08     NVARCHAR(30)   -- NVARCHAR(20)  AL01
            ,  @c_Lottable09     NVARCHAR(30)   -- NVARCHAR(20)  AL01
            ,  @c_Lottable10     NVARCHAR(30)   -- NVARCHAR(20)  AL01
            ,  @c_Lottable11     NVARCHAR(30)   -- NVARCHAR(20)  AL01
            ,  @c_Lottable12     NVARCHAR(30)   -- NVARCHAR(20)  AL01
            ,  @d_Lottable13     DATETIME
            ,  @d_Lottable14     DATETIME
            ,  @d_Lottable15     DATETIME

             
      SELECT @c_ADJ_AdjustmentKey = SPACE(10)
      WHILE (1=1)
      BEGIN
         SELECT TOP 1 @c_ADJ_AdjustmentKey = INSERTED.AdjustmentKey
           FROM INSERTED
           JOIN DELETED ON ( INSERTED.AdjustmentKey = DELETED.AdjustmentKey )
          WHERE INSERTED.AdjustmentKey > @c_ADJ_AdjustmentKey
            AND INSERTED.FinalizedFlag = 'Y'
            --(Wan02) - START
            --AND DELETED.FinalizedFlag = 'N'
            AND   DELETED.FinalizedFlag IN ( 'N', 'A' )
            --(Wan02) - END
          ORDER BY INSERTED.AdjustmentKey

         IF @@ROWCOUNT = 0
         BEGIN
            BREAK
         END

         --(Wan05) - START
         SELECT TOP 1 @c_ChannelInventoryMgmt = SC.Authority
         FROM ADJUSTMENT ADJ WITH (NOLOCK)
         CROSS APPLY fnc_SelectGetRight (ADJ.facility, ADJ.StorerKey, '', 'ChannelInventoryMgmt') SC
         WHERE ADJ.AdjustmentKey = @c_ADJ_AdjustmentKey
         --(Wan05) - END

         --NJOW01
         SET @c_cckey = ''
         SELECT TOP 1 @c_cckey = StockTakeSheetParameters.StockTakeKey
         FROM ADJUSTMENT (NOLOCK)
         JOIN StockTakeSheetParameters (NOLOCK) ON ADJUSTMENT.CustomerRefNo = StockTakeSheetParameters.StockTakeKey 
         WHERE ADJUSTMENT.Adjustmentkey = @c_ADJ_AdjustmentKey          
             
         SELECT @c_ADJ_AdjustmentLineNumber = SPACE(5)
         WHILE (1=1)
         BEGIN
            SELECT TOP 1 @c_ADJ_AdjustmentKey       = INSERTED.AdjustmentKey,
                  @c_ADJ_AdjustmentLineNumber = INSERTED.AdjustmentLineNumber,
                  @c_ADJ_StorerKey            = INSERTED.StorerKey,
                  @c_ADJ_Sku                  = INSERTED.Sku,
                  @c_ADJ_Loc                  = INSERTED.Loc,
                  @c_ADJ_Lot                  = INSERTED.Lot,
                  @c_ADJ_Id                   = INSERTED.Id,
                  @c_ADJ_ReasonCode           = INSERTED.ReasonCode,
                  @n_ADJ_Qty                  = INSERTED.Qty,
                  @n_ADJ_CaseCnt              = INSERTED.CaseCnt,
                  @n_ADJ_InnerPack            = INSERTED.InnerPack,
                  @n_ADJ_Pallet               = INSERTED.Pallet,
                  @n_ADJ_Cube                 = INSERTED.Cube,
                  @n_ADJ_GrossWgt             = INSERTED.GrossWgt,
                  @n_ADJ_NetWgt               = INSERTED.NetWgt,
                  @n_ADJ_OtherUnit1           = INSERTED.OtherUnit1,
                  @n_ADJ_OtherUnit2           = INSERTED.OtherUnit2,
                  @c_ADJ_packkey              = INSERTED.Packkey ,
                  @c_ADJ_uom                  = INSERTED.UOM,
                  @d_ADJ_EffectiveDate        = INSERTED.EffectiveDate,
                  @c_ItrnKey                  = INSERTED.ItrnKey,
                  @c_ADJ_UCCNo                = ISNULL(INSERTED.UCCNo, '') -- SOS75806
                 , @c_Channel                  = INSERTED.Channel    --(SWT02)
                 , @n_Channel_ID               = INSERTED.Channel_ID --(SWT02)                  
            FROM INSERTED
            JOIN DELETED ON ( INSERTED.AdjustmentKey = DELETED.AdjustmentKey AND
                              INSERTED.AdjustmentLineNumber = DELETED.AdjustmentLineNumber )
            WHERE INSERTED.AdjustmentKey = @c_ADJ_AdjustmentKey
            AND   INSERTED.AdjustmentLineNumber > @c_ADJ_AdjustmentLineNumber
            AND   INSERTED.FinalizedFlag = 'Y'
            --(Wan02) - START
            --AND   DELETED.FinalizedFlag = 'N'
            AND   DELETED.FinalizedFlag IN ( 'N', 'A' )
            --(Wan02) - END
            ORDER BY INSERTED.AdjustmentKey, INSERTED.AdjustmentLineNumber

            IF @@ROWCOUNT = 0
            BEGIN
               BREAK
            END
            -- Add by June 29.Jan.02
            -- HK Phase II : To Update Itrn's lottable details

            SELECT   @c_lottable01 = lottable01
                  ,  @c_lottable02 = lottable02
                  ,  @c_lottable03 = lottable03
                  ,  @d_lottable04 = lottable04
                  ,  @d_lottable05 = lottable05
                  ,  @c_lottable06 = lottable06
                  ,  @c_lottable07 = lottable07
                  ,  @c_lottable08 = lottable08
                  ,  @c_lottable09 = lottable09
                  ,  @c_lottable10 = lottable10
                  ,  @c_lottable11 = lottable11
                  ,  @c_lottable12 = lottable12
                  ,  @d_lottable13 = lottable13
                  ,  @d_lottable14 = lottable14
                  ,  @d_lottable15 = lottable15
            FROM  LOTATTRIBUTE WITH (NOLOCK)
            WHERE Lot = @c_ADJ_lot

            --KH01                
            IF @c_Bondedflag = '1' AND
               EXISTS ( SELECT 1 FROM Inventoryhold with (NOLOCK)
                           WHERE Hold = '1' 
                           AND Storerkey  = @c_ADJ_StorerKey
                           AND Sku        = @c_ADJ_Sku
                           AND Lottable02 = @c_lottable02 
                           AND LEN(RTRIM(Lottable02)) > 0 )
            BEGIN
                SELECT @n_err = 70000
                SELECT @c_errmsg = "NSQL"+CONVERT(char(5),@n_err)+": Bond-locked Stock. Adjustment Stock not allow. (ntrAdjustmentDetailUpdate)"
                Select @n_continue = 3
                BREAK  
            END   

            IF @c_ChannelInventoryMgmt = '1' 
            BEGIN 
               IF ISNULL(RTRIM(@c_Channel),'') = '' 
               BEGIN
                   SELECT @n_err = 70001
                   SELECT @c_errmsg = "NSQL"+CONVERT(char(5),@n_err)+": Channel Management Enabled, Channel Cannot be BLANK. (ntrAdjustmentDetailUpdate)"
                   Select @n_continue = 3
                   BREAK                                 
               END 
            END            

             /* (Wan03) - START */
            IF @c_ADJStatusCtrl = '1' 
            BEGIN
               IF @n_ADJ_Qty < 0 
               BEGIN
                  IF EXISTS  (SELECT 1 
                              FROM LOTXLOCXID WITH (NOLOCK) 
                              WHERE Lot = @c_ADJ_Lot
                              AND   Loc = @c_ADJ_Loc
                              AND   ID  = @c_ADJ_ID
                              AND   (Qty + @n_ADJ_Qty < 0
                              OR     Qty + @n_ADJ_Qty + QtyExpected < QtyAllocated + QtyPicked))
                  BEGIN
                     GOTO UPDATE_FAIL
                  END

                  IF EXISTS  (SELECT 1 
                              FROM LOT WITH (NOLOCK) 
                              WHERE Lot = @c_ADJ_Lot
                              AND   Qty + @n_ADJ_Qty < QtyPreAllocated + QtyAllocated + QtyPicked )
                  BEGIN
                     GOTO UPDATE_FAIL
                  END

                  GOTO QUIT_CHECK

                  UPDATE_FAIL:
                     UPDATE ADJUSTMENTDETAIL WITH (ROWLOCK)
                     SET TrafficCop = NULL
                       , Finalizedflag = 'F'
                       , AddDate = GETDATE()
                       , AddWho  = SUSER_NAME()
                       , EditDate= GETDATE()
                       , EditWho = SUSER_NAME()
                     WHERE AdjustmentKey = @c_ADJ_AdjustmentKey
                     AND AdjustmentLineNumber = @c_ADJ_AdjustmentLineNumber

                     CONTINUE
                  QUIT_CHECK:
               END
            END
            /* (Wan03) - END */

            -- END - Add by June 29.Jan.02
            SELECT @c_SourceKey = dbo.fnc_LTRIM(dbo.fnc_RTRIM((@c_ADJ_AdjustmentKey)))
                                + dbo.fnc_LTRIM(dbo.fnc_RTRIM(@c_ADJ_AdjustmentLineNumber))
            SELECT @b_success = 0

            EXECUTE  nspItrnAddAdjustment
                     @n_ItrnSysId  = NULL,
                     @c_StorerKey  = @c_ADJ_StorerKey,
                     @c_Sku        = @c_ADJ_Sku,
                     @c_Lot        = @c_ADJ_Lot,
                     @c_ToLoc      = @c_ADJ_Loc,
                     @c_ToID       = @c_ADJ_Id,
                     @c_Status     = '',
                     @c_lottable01 = @c_lottable01, -- Changed by June 29.Jan.02
                     @c_lottable02 = @c_lottable02, -- Changed by June 29.Jan.02
                     @c_lottable03 = @c_lottable03, -- Changed by June 29.Jan.02
                     @d_lottable04 = @d_lottable04, -- Changed by June 29.Jan.02
                     @d_lottable05 = @d_lottable05, -- Changed by June 29.Jan.02
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
                     @c_Channel    = @c_Channel, 
                     @n_Channel_ID = @n_Channel_ID OUTPUT,                     
                     @n_casecnt    = @n_ADJ_CaseCnt,
                     @n_innerpack  = @n_ADJ_InnerPack,
                     @n_qty        = @n_ADJ_Qty,
                     @n_pallet     = @n_ADJ_Pallet,
                     @f_cube       = @n_ADJ_Cube,
                     @f_grosswgt   = @n_ADJ_GrossWgt,
                     @f_netwgt     = @n_ADJ_NetWgt,
                     @f_otherunit1 = @n_ADJ_OtherUnit1,
                     @f_otherunit2 = @n_ADJ_OtherUnit2,
                     @c_SourceKey  = @c_SourceKey,
                     @c_SourceType = 'ntrAdjustmentDetailUpdate',
                     @c_PackKey    = @c_AdJ_packkey,
                     @c_UOM        = @c_ADJ_uom,
                     @b_UOMCalc    = 0,
                     @d_EffectiveDate = @d_ADJ_EffectiveDate,
                     @c_itrnkey    = @c_ItrnKey OUTPUT,
                     @b_Success    = @b_Success OUTPUT,
                     @n_err        = @n_err     OUTPUT,
                     @c_errmsg     = @c_errmsg  OUTPUT
            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3 /* Other Error flags Set By nspItrnAddAdjustment */
               BREAK
            END
            ELSE
            BEGIN
               -- SOS75806 UCC Adjustment
               IF @c_ADJ_UCCNo <> ''
               BEGIN
                  IF NOT EXISTS (SELECT 1 FROM UCC WITH (NOLOCK)
                                  WHERE StorerKey = @c_ADJ_StorerKey AND UCCNo = @c_ADJ_UCCNo)
                  BEGIN
                     INSERT INTO UCC (UCCNo, Storerkey, ExternKey, SKU, qty, Sourcekey,
                                      Sourcetype, Status, Lot, Loc, Id)

                     VALUES (@c_ADJ_UCCNo, @c_ADJ_StorerKey, '', @c_ADJ_Sku, @n_ADJ_Qty, @c_SourceKey,
                             'ADJUSTMENT', '1', @c_ADJ_Lot, @c_ADJ_Loc, @c_ADJ_ID)

                     SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
                     IF @n_err <> 0
                     BEGIN
                        SELECT @n_continue = 3
                        SELECT @n_err = 62804 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                        SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                         + ': Insert Failed On Table UCC. (ntrAdjustmentDetailUpdate)'
                        BREAK
                     END
                  END
                  ELSE
                  BEGIN
                      IF ISNULL(@c_cckey,'') = '' --NJOW01
                      BEGIN
                        UPDATE UCC WITH (ROWLOCK)
                           SET Qty = Qty + @n_ADJ_Qty,
                               Lot = @c_ADJ_Lot,
                               LOC = @c_ADJ_Loc,
                               ID  = @c_ADJ_ID,
                               Status = CASE WHEN (Qty + @n_ADJ_Qty) = 0 THEN '0'
                                        ELSE '1'
                                        END,
                               EditDate = GETDATE(),           -- tlting
                               EditWho = SUSER_SNAME()
                        WHERE StorerKey = @c_ADJ_StorerKey  
                        AND   Sku   = @c_ADJ_Sku                     --(Wan04)
                        AND   UCCNo = @c_ADJ_UCCNo
                        AND   Status IN ('1','0')
                        
                        SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
                        IF @n_err <> 0
                        BEGIN
                           SELECT @n_continue = 3
                           SELECT @n_err = 62805 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                           SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                            + ': Update Failed On Table UCC. (ntrAdjustmentDetailUpdate)'
                           BREAK
                        END
                     END
                  END
               END -- IF @c_ADJ_UCCNo <> ''
            END -- IF @b_success = 1

            IF @n_continue = 1 OR @n_continue = 2
            BEGIN
               UPDATE ADJUSTMENTDETAIL WITH (ROWLOCK)
                  SET TrafficCop = NULL,
                      ItrnKey = @c_itrnkey,
                      AddDate = GETDATE(),
                      AddWho  = suser_sname(),
                      EditDate = GETDATE(),
                      EditWho = suser_sname(), 
                      Channel_ID = @n_Channel_ID -- (SWT02)                      
                WHERE AdjustmentKey = @c_ADJ_AdjustmentKey
                  AND AdjustmentLineNumber = @c_ADJ_AdjustmentLineNumber

               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @n_err = 62806 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                   + ': Update Failed On Table ADJUSTMENTDETAIL. (ntrAdjustmentDetailUpdate)'
                  BREAK
               END

               IF @n_cnt = 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @n_err = 62807 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                   + ': No record updated into Table ADJUSTMENTDETAIL. (ntrAdjustmentDetailUpdate)'
                  BREAK
               END
            END

            -- (YokeBeen01) - Start
            SELECT @b_success = 0
            EXECUTE nspGetRight
                     NULL,                  -- Facility
                     @c_StorerKey,          -- Storer
                     NULL,                  -- No Sku in this Case
                     'OWITF',               -- ConfigKey
                     @b_success             output,
                     @c_authority_OWITF     output,
                     @n_err                 output,
                     @c_errmsg              output

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3
               SELECT @n_err = 62808
               SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                + ': Retrieve Failed On GetRight (OWITF). (ntrAdjustmentDetailUpdate)'
            END
            ELSE IF @c_authority_OWITF = '1'
            BEGIN
               SELECT @c_authority_OWADJWO = STORERCONFIG.sValue
                 FROM ADJUSTMENT WITH (NOLOCK)
                 JOIN ADJUSTMENTDETAIL WITH (NOLOCK) ON ( ADJUSTMENT.AdjustmentKey = ADJUSTMENTDETAIL.AdjustmentKey )
                 JOIN STORERCONFIG WITH (NOLOCK) ON ( ADJUSTMENTDETAIL.StorerKey = STORERCONFIG.StorerKey
                                                  AND STORERCONFIG.ConfigKey = 'OWADJWO' AND sValue = '1' )
                 JOIN CODELKUP WITH (NOLOCK) ON ( ADJUSTMENT.AdjustmentType = CODELKUP.Code
                                              AND CODELKUP.Listname = 'ADJTYPE' AND CODELKUP.Long = 'OWADJWO' )
                WHERE ADJUSTMENTDETAIL.AdjustmentKey = @c_ADJ_AdjustmentKey
                  AND ADJUSTMENTDETAIL.AdjustmentLineNumber = @c_ADJ_AdjustmentLineNumber
                  AND ADJUSTMENTDETAIL.FinalizedFlag = 'Y'

               IF @c_authority_OWADJWO = '1'
               BEGIN
                  EXEC ispGenTransmitLog 'OWADJWO', @c_ADJ_AdjustmentKey, @c_ADJ_AdjustmentLineNumber, @c_StorerKey, ''
                     , @b_success OUTPUT
                     , @n_err OUTPUT
                     , @c_errmsg OUTPUT

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @n_err = 62809
                     SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                      + ': Insert Into TransmitLog Table (OWADJWO) Failed (ntrItrnAdd)'
                                      + ' ( SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
                  END
               END -- IF @c_authority_OWADJWO = '1'
            END -- IF @c_authority_OWITF = '1'
            -- (YokeBeen01) - END
         END -- WHILE (1=1) -- @c_ADJ_AdjustmentLineNumber
      END -- WHILE (1=1) -- @c_ADJ_AdjustmentKey
   END

   /* #INCLUDE <TRADA2.SQL> */
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      DECLARE @n_IsRDT INT
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT

      IF @n_IsRDT = 1
      BEGIN
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
         -- Instead we commit and raise an error back to parent, let the parent decide

         -- Commit until the level we begin with
         WHILE @@TRANCOUNT > @n_starttcnt
            COMMIT TRAN

         -- Raise error with severity = 10, instead of the default severity 16.
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger
         RAISERROR (@n_err, 10, 1) WITH SETERROR

         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten
      END
      ELSE
      BEGIN
         IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt
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

         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrAdjustmentDetailUpdate'
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012

         RETURN
      END
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
ALTER TABLE [dbo].[ADJUSTMENTDETAIL] ADD CONSTRAINT [PKAdjustmentDetail] PRIMARY KEY CLUSTERED ([AdjustmentKey], [AdjustmentLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ADJUSTMENTDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_ADJUSTMENTDETAIL_SKU_01] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Adjustment.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'AdjustmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line number in sequence', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'AdjustmentLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'total case count', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'CaseCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'confirm the adjustment by detail line', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'FinalizedFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'GrossWgt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'pallet id of the goods to be adjusted', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking inner packs in the zone.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'InnerPack'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Inventory Transaction.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'ItrnKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'physical location of the goods to be adjusted', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'lot number associated with the product being adjusted', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable01 - depends on Commodity lottable label01 set-up', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable02 - depends on Commodity lottable label02 set-up', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable03 - depends on Commodity lottable label03 set-up', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable04 - manufacturing date/expiry date', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable05 - receipt date', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable07', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable08', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable09', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable10', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable11', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable11'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable12', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable12'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable13', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable13'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable14', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable14'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable15', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable15'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Net weight', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'NetWgt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total quantity not found in the actual receiving 1', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'OtherUnit1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total quantity not found in the actual receiving 2', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'OtherUnit2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack key of the SKU', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A portable platform designed to allow a forklift or pallet jack to lift, move, and store various loads.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Pallet'
GO
EXEC sp_addextendedproperty N'MS_Description', 'unit of quantity to be adjusted for the sku', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'reason code to be adjusted', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'SKU being adjusted', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the storer record.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'TimeStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique number to identify the carton or pallet which is standard and will be used from suppliers to customers', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UCCNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measurement in which the SKU will be adjusted', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine01', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine02', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine06 (datetime)', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine07 (datetime)', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine08', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine09', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine10'
GO
