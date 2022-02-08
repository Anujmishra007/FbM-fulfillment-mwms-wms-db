CREATE TABLE [dbo].[PICKDETAIL]
(
[PickDetailKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_CaseID] DEFAULT (' '),
[PickHeaderKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AltSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_AltSku] DEFAULT (' '),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_UOM] DEFAULT (' '),
[UOMQty] [int] NOT NULL CONSTRAINT [DF_PICKDETAIL_UOMQty] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_PICKDETAIL_Qty] DEFAULT ((0)),
[QtyMoved] [int] NOT NULL CONSTRAINT [DF_PICKDETAIL_QtyMoved] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_Status] DEFAULT ('0'),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_DropID] DEFAULT (''),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_Loc] DEFAULT ('UNKNOWN'),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_ID] DEFAULT (' '),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_PackKey] DEFAULT (' '),
[UpdateSource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_UpdateSource] DEFAULT ('0'),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_ToLoc] DEFAULT (' '),
[DoReplenish] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_DoReplenish] DEFAULT ('N'),
[ReplenishZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_ReplenishZone] DEFAULT (' '),
[DoCartonize] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_DoCartonize] DEFAULT ('N'),
[PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_PickMethod] DEFAULT (' '),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_WaveKey] DEFAULT (' '),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_PICKDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PICKDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PICKDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptimizeCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickDetail_ShipFlag] DEFAULT ('0'),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskManagerReasonKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MoveRefKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_MoveRefKey] DEFAULT (''),
[Channel_ID] [bigint] NULL CONSTRAINT [DF_PICKDETAIL_Channel_ID] DEFAULT ((0)),
[SourceType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_SourceType] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrPickDetailAdd                                            */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: When records Added                                        */
/*                                                                      */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 10-Apr-2009  SHONG         Added ConfigKey "ForceAllocLottable"      */
/*                            Prevent user to choose wrong Lottable     */
/* 11-Sep-2010  SHONG         Prevent Overallocation for non pick loc   */
/*                            AND Diff Facility with Orders             */
/* 06-May-2011  Shong         Fixing bug for Preallocate Detail Off set */
/*                            issues SHONG01                            */
/* 24-Jun-2011  NJOW01        Allow over allocation for dynamic         */
/*                            permenent loc                             */
/* 02-Dec-2011  MCTang        Add WAVEUPDLOG for WCS-WAVE Status Change */
/*                            Export(MC01)                              */
/* 22-May-2012  KHLim01       Update LOT & LOTxLOCxID.EditDate          */
/* 05-Jun-2013  James         SOS276541 - Prevent allocation from       */
/*                            WS01 - Temporarily (james01)              */
/* 03-Jun-2014  Leong         SOS# 312878 - Enhance to unique @n_err.   */          
/* 29-Jun-2015  NJOW02        342109-Update SKUXLOC cater for DYNPPICK  */
/* 15-Sep-2015  NJOW03        352837 - update pickslip# to pickdetail   */
/* 20-Sep-2016  TLTING        Change SET ROWCOUNT 1 to TOP 1            */
/* 28-Oct-2016  SHONG02       Performance Tuning Update OrderDetail     */
/* 28-Sep-2017  TLTING01      Performance Tuning Update OrderDetail     */
/* 20-Sep-2017  SHONG03       Change update sequence to prevent Deadlock*/
/* 06-Feb-2018  SHONG04       Added Channel Management Logic            */
/* 28-Sep-2018  TLTING  1.1   remove #tmp , remmove update row lock     */
/* 23-JUL-2019  Wan01   3.8   ChannelInventoryMgmt use fnc_SelectGetRight*/
/************************************************************************/
CREATE  TRIGGER [dbo].[ntrPickDetailAdd]
ON  [dbo].[PICKDETAIL]
FOR INSERT
AS
SET NOCOUNT ON
SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE
     @b_Success         INT           -- Populated by calls to stored procedures - was the proc successful?
   , @n_err             INT           -- Error number returned by stored procedure OR this trigger
   , @n_err2            INT           -- For Additional Error Detection
   , @c_errmsg          NVARCHAR(250) -- Error message returned by stored procedure OR this trigger
   , @n_Continue        INT
   , @n_starttcnt       INT           -- Holds the current transaction count
   , @c_preprocess      NVARCHAR(250) -- preprocess
   , @c_pstprocess      NVARCHAR(250) -- post process
   , @n_cnt             INT
   , @n_PickDetailSysId INT
   , @c_facility        NVARCHAR(5)
   , @c_Storerkey       NVARCHAR(15)
   , @c_UpdPickslipToPickDet NVARCHAR(10)  --NJOW03          
   , @c_Pickheaderkey   NVARCHAR(10) --NJOW03
   , @c_PrevOrderKey    NVARCHAR(10) --NJOW03
   , @c_OrderLineNumber NVARCHAR(5)
   , @n_InsertedRows    INT = 0 


SELECT @n_InsertedRows = COUNT(*)
FROM   INSERTED 

SELECT @n_Continue = 1, @n_starttcnt = @@TRANCOUNT
DECLARE @c_AllowOverAllocations NVARCHAR(1) -- Flag to see if overallocations are allowed.
/* #INCLUDE <TRPDA1.SQL> */
DECLARE @b_debug INT
SELECT @b_debug = 0

DECLARE @c_LOC_LocationType NVARCHAR(10)  --NJOW01

-- Added By SHONG
-- 30t Apr 2003
-- Do Nothing when ArchiveCop = '9'
IF @n_Continue = 1 OR @n_Continue = 2
BEGIN
   IF EXISTS (SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   BEGIN
      SELECT @n_Continue = 4
   END
END
-- End 30th Apr 2003


IF (SELECT COUNT(*) FROM INSERTED WHERE OptimizeCop is not NULL ) > 0
BEGIN
   -- SHONG03 Bug Fixing
   UPDATE PICKDETAIL  
      SET OptimizeCop = NULL, TrafficCop = NULL
   FROM PICKDETAIL
   JOIN INSERTED ON PICKDETAIL.PickDetailKey = INSERTED.PickDetailKey   

   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   IF @n_err <> 0
   BEGIN
      SELECT @n_Continue = 3
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63110   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert Trigger On PickDetail Failed. (ntrPickDetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
   END
   ELSE
   BEGIN
      SELECT @n_Continue = 4
   END
END


-- Add by June 1.JUL.02 for IDSV5, extract from IDSSG *** Start
-- Added By SHONG
-- To Force not to accept STATUS equal to PICKED, when INSERTED
IF @n_Continue = 1 OR @n_Continue = 2
BEGIN
   IF EXISTS(SELECT PickDetailKey FROM INSERTED WHERE STATUS IN ('3','4','5','6','7','8','9'))
   BEGIN
      SELECT @n_Continue = 3
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63112   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert Trigger On PickDetail Failed. Status Must Equal to NORMAL (ntrPickDetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
   END -- Add by June 1.JUL.02 for IDSV5, extract from IDSSG *** End
END

IF @n_Continue = 1 OR @n_Continue = 2
BEGIN
   DECLARE @c_OrderKey         NVARCHAR(10),
           @c_Line             NVARCHAR(5),
           @c_LOT              NVARCHAR(10),
           @c_Lottable01_order NVARCHAR(18),
           @c_Lottable02_order NVARCHAR(18),
           @c_Lottable03_order NVARCHAR(18),
           @c_Lottable01       NVARCHAR(18),
           @c_Lottable02       NVARCHAR(18),
           @c_Lottable03       NVARCHAR(18)

   SELECT @c_OrderKey  = OrderKey,
          @c_Line      = OrderLineNumber,
          @c_LOT       = LOT,
          @c_StorerKey = StorerKey
   FROM INSERTED

   IF EXISTS(SELECT 1 FROM StorerConfig WITH (NOLOCK)
             WHERE StorerKey = @c_StorerKey AND ConfigKey = 'ForceAllocLottable' AND sValue = '1')
   BEGIN
      SELECT @c_Lottable01_order = Lottable01,
             @c_Lottable02_order = Lottable02,
             @c_Lottable03_order = Lottable03
      FROM ORDERDETAIL (NOLOCK)
      WHERE OrderKey        = @c_OrderKey
        AND OrderLineNumber = @c_Line

      SELECT @c_Lottable01 = Lottable01,
             @c_Lottable02 = Lottable02,
             @c_Lottable03 = Lottable03
      FROM LOTATTRIBUTE (NOLOCK)
      WHERE lot = @c_LOT

      IF ( ISNULL(@c_Lottable01_order, '') <> '' AND @c_Lottable01_order <> @c_Lottable01) OR
         ( ISNULL(@c_Lottable02_order, '') <> '' AND @c_Lottable02_order <> @c_Lottable02) OR
         ( ISNULL(@c_Lottable03_order, '') <> '' AND @c_Lottable03_order <> @c_Lottable03)
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63113   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': LOT CHOSEN IS INVALID! Lot Attributes Does Not Match'
      END
   END
END

IF @n_Continue = 1 OR @n_Continue = 2
BEGIN
   DECLARE @c_PrevStorerKey   NVARCHAR(15),
           @c_PrevFacility    NVARCHAR(10),
           @n_SL_QtyAllocated INT,
           @n_SL_QtyPicked    INT,
           @n_SL_Qty          INT,
           @c_LOC             NVARCHAR(10),
           @c_LocationType    NVARCHAR(10),
           @n_Qty             INT,
           @c_SKU             NVARCHAR(20)

   SET @c_PrevStorerKey = ''
   SET @c_PrevFacility  = ''
   SET @c_PrevOrderKey = '' --NJOW03

   DECLARE Cursor_SKUxLOC_Check CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT INSERTED.OrderKey, LOC.FACILITY, INSERTED.Loc, INSERTED.StorerKey, INSERTED.SKU, SUM(INSERTED.Qty)
      FROM INSERTED
      JOIN  LOC (NOLOCK) ON LOC.LOC = INSERTED.Loc
      JOIN  SKUxLOC WITH (NOLOCK) ON SKUxLOC.StorerKey = INSERTED.StorerKey AND
            SKUxLOC.SKU = INSERTED.SKU AND
            SKUxLOC.LOC = INSERTED.Loc
      GROUP BY INSERTED.OrderKey, LOC.FACILITY, INSERTED.Loc, INSERTED.StorerKey, INSERTED.SKU
      ORDER BY LOC.FACILITY, INSERTED.StorerKey, INSERTED.OrderKey

   OPEN Cursor_SKUxLOC_Check

   FETCH NEXT FROM Cursor_SKUxLOC_Check INTO
                   @c_OrderKey, @c_Facility, @c_LOC, @c_StorerKey, @c_SKU, @n_Qty

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      IF @c_PrevStorerKey <> @c_StorerKey OR @c_PrevFacility <> @c_Facility
      BEGIN
         SELECT @b_success = 0
         EXECUTE nspGetRight @c_facility, -- facility
                             @c_Storerkey,    -- StorerKey
                             NULL,   -- Sku
                             'ALLOWOVERALLOCATIONS', -- Configkey
                             @b_success    OUTPUT,
                             @c_AllowOverAllocations OUTPUT,
                             @n_err        OUTPUT,
                             @c_errmsg     OUTPUT
         IF @b_success <> 1
         BEGIN
            SELECT @n_Continue = 3, @c_errmsg = 'ntrPickDetailAdd' + ISNULL(RTrim(@c_errmsg),'')
         END
         
         SET @c_PrevStorerKey = @c_StorerKey
         SET @c_PrevFacility  = @c_Facility

         IF NOT EXISTS(SELECT 1 FROM ORDERS WITH (NOLOCK) WHERE OrderKey = @c_OrderKey AND
                       Facility = @c_Facility)
         BEGIN
            SELECT @n_Continue = 3
            SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err = 63114   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(varchar(5),@n_err)+'Location Facility NOT Match with Order Facility (ntrPickDetailAdd)'
         END
         
         --NJOW03
         SELECT @c_UpdPickslipToPickDet = ''
         SELECT @b_success = 0
         EXECUTE nspGetRight @c_facility, -- facility
                             @c_Storerkey,    -- StorerKey
                             NULL,   -- Sku
                             'UpdPickslipToPickDet', -- Configkey
                             @b_success    OUTPUT,
                             @c_UpdPickslipToPickDet OUTPUT,
                             @n_err        OUTPUT,
                             @c_errmsg     OUTPUT
         IF @b_success <> 1
         BEGIN
            SELECT @n_Continue = 3, @c_errmsg = 'ntrPickDetailAdd' + ISNULL(RTrim(@c_errmsg),'')
         END
      END -- @c_PrevStorerKey <> @c_StorerKey OR @c_PrevFacility <> @c_Facility

      SET @n_SL_Qty=0
      SET @n_SL_QtyAllocated = 0
      SET @n_SL_QtyPicked = 0

      SELECT @n_SL_QtyAllocated = QtyAllocated, @n_SL_QtyPicked = QtyPicked, @n_SL_Qty = Qty,
             @c_LocationType = LocationType
      FROM SKUxLOC WITH (NOLOCK)
      WHERE StorerKey = @c_StorerKey
      AND SKU = @c_SKU
      AND LOC = @c_LOC

      --NJOW01
      SELECT @c_LOC_LocationType = LocationType
      FROM LOC WITH (NOLOCK)
      WHERE LOC = @c_LOC

      IF @n_SL_Qty < (@n_SL_QtyAllocated + @n_SL_QtyPicked + @n_Qty)
      BEGIN
         IF @c_AllowOverAllocations <> '1' AND (@c_LOC_LocationType NOT IN ('DYNPICKP', 'DYNPICKR','DYNPPICK'))  --NJOW01
         BEGIN
            SELECT @n_Continue = 3
            SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err = 63115   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(varchar(5),@n_err)+'Over Allocation NOT Allow (ntrPickDetailAdd)'
         END
         ELSE IF @c_LocationType NOT IN ('PICK', 'CASE') AND (@c_LOC_LocationType NOT IN ('DYNPICKP', 'DYNPICKR','DYNPPICK'))  --NJOW01
         BEGIN
            SELECT @n_Continue = 3
            SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err = 63116   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(varchar(5),@n_err)+'Over Allocation NOT Allow for Non Pick Location (ntrPickDetailAdd)'
         END
      END
      
      --NJOW03
      IF @n_Continue IN (1,2) AND @c_UpdPickslipToPickDet = '1'      
      BEGIN
          IF @c_PrevOrderKey <> @c_OrderKey 
          BEGIN               
             SET @c_Pickheaderkey = ''
             
             SELECT TOP 1 @c_Pickheaderkey = Pickheaderkey
             FROM PICKHEADER (NOLOCK) 
             WHERE OrderKey = @c_OrderKey
             
             IF ISNULL(@c_Pickheaderkey ,'') = ''
             BEGIN
                 SELECT TOP 1 @c_Pickheaderkey  = PH.Pickheaderkey
                 FROM PICKHEADER PH (NOLOCK)
                 JOIN ORDERS O (NOLOCK) ON PH.ExternOrderKey = O.Loadkey 
                 WHERE ISNULL(PH.OrderKey,'') = ''
                 AND ISNULL(O.Loadkey,'') <> ''
                 AND O.OrderKey = @c_OrderKey
             END
             
             IF ISNULL(@c_Pickheaderkey,'') <> ''
             BEGIN
                UPDATE PICKDETAIL  
                SET PICKDETAIL.Pickslipno = @c_Pickheaderkey,
                    PICKDETAIL.TrafficCop = NULL            
                FROM PICKDETAIL
                JOIN INSERTED I ON PICKDETAIL.PickDetailKey = I.PickDetailKey
                WHERE I.OrderKey = @c_OrderKey        
             END
          END
      END                
      SET @c_PrevOrderKey = @c_OrderKey

      FETCH NEXT FROM Cursor_SKUxLOC_Check INTO
                      @c_OrderKey, @c_Facility, @c_LOC, @c_StorerKey, @c_SKU, @n_Qty
   END -- WHILE
   CLOSE Cursor_SKUxLOC_Check
   DEALLOCATE Cursor_SKUxLOC_Check
END

--  IF @n_Continue = 1 OR @n_Continue = 2
--  BEGIN
--      IF EXISTS (SELECT 1 FROM INSERTED WHERE Status = '0')
--      BEGIN
--          Update PickDetail WITH (ROWLOCK) SET status="0" , TrafficCop = NULL
--          FROM PickDetail, INSERTED, DELETED
--          WHERE PickDetail.PickDetailKey = INSERTED.PickDetailKey
--            AND PICKDETAIL.PickDetailKey = DELETED.PickDetailKey
--            AND INSERTED.PickDetailKey = DELETED.PickDetailKey
--          SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
--          IF @n_err <> 0
--          BEGIN
--              SELECT @n_Continue = 3
--              SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63105   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
--              SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert Trigger On PickDetail Failed. (ntrPickDetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
--          END
--      END
--  END

IF @n_Continue = 1 OR @n_Continue = 2
BEGIN
   DECLARE @c_sPickDetailKey            NVARCHAR(20),
           @c_sOrderKey                 NVARCHAR(10),
           @c_sOrderLineNumber          NVARCHAR(5),
           @c_sLot                      NVARCHAR(10),
           @c_sPreAllocatePickDetailKey NVARCHAR(10)

   DECLARE @n_sPreAllocatePickDetailQty INT, 
           @n_sPickDetailQty            INT, 
           @n_sQtyToReduce              INT
           
   SELECT @c_sPickDetailKey = SPACE(20)

   WHILE (1=1)
   BEGIN
      IF @b_debug = 1
      BEGIN
         SELECT 'Data From INSERTED'
      END

      SELECT TOP 1 @c_sPickDetailKey = PickDetailKey, @n_sPickDetailQty = QTY, @c_sOrderKey = OrderKey,
             @c_sOrderLineNumber = OrderLineNumber, @c_sLot = LOT
      FROM INSERTED
      WHERE PickDetailKey > @c_sPickDetailKey AND QTY > 0
      ORDER BY PickDetailKey

      IF @@ROWCOUNT = 0
      BEGIN
         BREAK
      END

      SELECT @c_sPreAllocatePickDetailKey = SPACE(10)
      WHILE (1=1)
      BEGIN
         IF @b_debug = 1
         BEGIN
            SELECT 'Data From PreAllocatePickDetail'
         END

         SELECT TOP 1 
             @c_sPreAllocatePickDetailKey = PreAllocatePickDetailKey, 
             @n_sPreAllocatePickDetailQty = qty
         FROM PreAllocatePickDetail (NOLOCK)
         WHERE PreAllocatePickDetailKey > @c_sPreAllocatePickDetailKey
         AND OrderKey = @c_sOrderKey
         AND OrderLineNumber = @c_sOrderLineNumber
         AND LOT = @c_sLot AND QTY > 0
         ORDER BY PreAllocatePickDetailKey

         IF @@ROWCOUNT = 0
         BEGIN
            BREAK
         END

         IF @b_debug = 1
         BEGIN
            SELECT 'PreKey, PreQty, PickQty',@c_sPreAllocatePickDetailKey , @n_sPreAllocatePickDetailQty, @n_sPickDetailQty
         END

         IF @n_sPickDetailQty > @n_sPreAllocatePickDetailQty
         BEGIN
            --SELECT @n_sQtyToReduce = @n_sPickDetailQty - @n_sPreAllocatePickDetailQty
            --SHONG01
            SET @n_sQtyToReduce = @n_sPreAllocatePickDetailQty
            SELECT @n_sPickDetailQty = @n_sPickDetailQty - @n_sQtyToReduce
         END
         ELSE
         BEGIN
            SELECT @n_sQtyToReduce = @n_sPickDetailQty
            SELECT @n_sPickDetailQty = @n_sPickDetailQty - @n_sQtyToReduce
         END

         IF @b_debug = 1
         BEGIN
            SELECT 'qty to reduce', @c_sPreAllocatePickDetailKey, @n_sQtyToReduce
         END

         UPDATE PreAllocatePickDetail  
         SET QTY = QTY - @n_sQtyToReduce,
             Editdate = GETDATE(),
             Editwho = SUSER_SNAME()
         WHERE PreAllocatePickDetailKey = @c_sPreAllocatePickDetailKey

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_Continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63117   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On PickDetail Could Not Update PreAllocatePickDetail. (ntrPickDetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
         END

         IF @n_sPickDetailQty <=0
         BEGIN
            BREAK
         END
      END
   END
END

-- SHONG04 Channel Management 
IF @n_Continue = 1 OR @n_Continue = 2
BEGIN
   SELECT TOP 1 @c_StorerKey = StorerKey
   FROM INSERTED
   
   IF EXISTS(SELECT 1 FROM StorerConfig WITH (NOLOCK)
             WHERE StorerKey = @c_StorerKey AND ConfigKey = 'ChannelInventoryMgmt' AND sValue = '1')
   BEGIN
      DECLARE @n_Channel_ID     BIGINT, 
              @c_Channel        NVARCHAR(20), 
              @c_cStorerKey     NVARCHAR(15), 
              @c_cFacility      NVARCHAR(10),
              @c_cLOT           NVARCHAR(10),
              @c_cSKU           NVARCHAR(20),
              @n_cQty           INT,
              @c_cPickDetailKey NVARCHAR(10) 
      
      DECLARE CUR_CHANNEL_MGMT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT INSERTED.PickDetailKey,
             INSERTED.Storerkey, 
             INSERTED.Sku, 
             LOC.Facility, 
             ISNULL(OD.Channel,''), 
             INSERTED.Lot, 
             ISNULL(INSERTED.Channel_ID,0), 
             INSERTED.Qty
      FROM INSERTED WITH (NOLOCK) 
      JOIN LOC LOC WITH (NOLOCK) ON LOC.Loc = INSERTED.Loc 
      CROSS APPLY fnc_SelectGetRight (LOC.Facility, INSERTED.Storerkey, '', 'ChannelInventoryMgmt') SC--(Wan01) 
      --JOIN StorerConfig AS sc WITH(NOLOCK) ON INSERTED.Storerkey = SC.StorerKey                     --(Wan01)
      --          AND SC.ConfigKey = 'ChannelInventoryMgmt' AND SC.sValue = '1'                       --(Wan01)
      JOIN ORDERDETAIL AS OD WITH(NOLOCK)
             ON  OD.OrderKey = INSERTED.OrderKey AND OD.OrderLineNumber = INSERTED.OrderLineNumber 
      WHERE SC.Authority = '1'                                                                        --(Wan01) 
      
      OPEN CUR_CHANNEL_MGMT 
      
      FETCH NEXT FROM CUR_CHANNEL_MGMT INTO @c_cPickDetailKey, @c_cStorerKey, @c_cSKU, @c_cFacility, @c_Channel, @c_cLOT, @n_Channel_ID, @n_cQty
      
      WHILE @@FETCH_STATUS = 0 
      BEGIN
         IF ISNULL(RTRIM(@c_Channel),'') = ''
         BEGIN
            SELECT @n_Continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63125   
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)
                  + ': Order Detail Channel Cannot be BLANK. (ntrPickDetailAdd)' 
                  + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) ' 
            BREAK                
         END
         IF @n_Channel_ID = 0 
         BEGIN
            EXEC isp_ChannelGetID 
                @c_StorerKey   = @c_cStorerKey
               ,@c_Sku         = @c_cSKU
               ,@c_Facility    = @c_cFacility
               ,@c_Channel     = @c_Channel
               ,@c_LOT         = @c_cLOT
               ,@n_Channel_ID  = @n_Channel_ID OUTPUT
            
         END
         IF ISNULL(@n_Channel_ID,0) > 0 
         BEGIN
            IF EXISTS(SELECT 1 FROM ChannelInv AS ci WITH(NOLOCK)
                      WHERE ci.Channel_ID = @n_Channel_ID 
                      AND ci.Qty < ci.QtyAllocated + @n_cQty)
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63126   
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)
                     + ': Update Channel Inventory Failed, Channel Qty less than Qty Allocated. (ntrPickDetailAdd)' 
                     + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '              
            END
            ELSE
            BEGIN
               UPDATE ChannelInv  
                  SET QtyAllocated = QtyAllocated + @n_cQty, 
                      EditDate = GETDATE(),
                      EditWho = SUSER_SNAME()
               WHERE Channel_ID = @n_Channel_ID 
            
               UPDATE PICKDETAIL 
                  SET Channel_ID = @n_Channel_ID, 
                      EditDate = GETDATE(),
                      EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @c_cPickDetailKey               
            END
         END
         
         FETCH NEXT FROM CUR_CHANNEL_MGMT INTO @c_cPickDetailKey, @c_cStorerKey, @c_cSKU, @c_cFacility, @c_Channel, @c_cLOT, @n_Channel_ID, @n_cQty
      END -- While 
         
   END   
END 

IF @n_Continue = 1 OR @n_Continue = 2
BEGIN
   IF @b_debug = 1
   BEGIN
      SELECT 'Update Data In LOT'
   END

   IF @n_InsertedRows = 1
   BEGIN
      UPDATE LOT 
      SET  QtyAllocated = (LOT.QtyAllocated + INSERTED.Qty),
           EditDate = GETDATE(),    
           EditWho = SUSER_SNAME(), 
           TrafficCop = NULL        
      FROM LOT 
      JOIN INSERTED ON INSERTED.LOT = LOT.LOT
      
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
   END
   ELSE 
   BEGIN
      DECLARE  @tLOT TABLE   (
         LOT          NVARCHAR(10) NOT NULL,
         QtyAllocated INT 
         PRIMARY KEY CLUSTERED (LOT)
       )

      INSERT INTO @tLOT  ( LOT, QtyAllocated )
      SELECT LOT,
             SUM (Qty) AS QtyAllocated 
      FROM INSERTED
      GROUP BY LOT
   
      UPDATE LOT  
      SET  QtyAllocated = (LOT.QtyAllocated + tL.QtyAllocated),
           EditDate = GETDATE(),   --tlting
           EditWho = SUSER_SNAME(), 
           TrafficCop = NULL        
      FROM LOT
      JOIN @tLOT tL ON tL.LOT = LOT.LOT
      
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT    
   END
   IF @n_err <> 0
   BEGIN
      SELECT @n_Continue = 3
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63120   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On PickDetail Failed. (ntrPickDetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
   END
END

IF (@n_Continue = 1 OR @n_Continue = 2)  
BEGIN
   IF @b_debug = 1
   BEGIN
      SELECT 'Update Data In LOTxLOCxID'
   END

   IF @n_InsertedRows = 1
   BEGIN
      UPDATE LOTxLOCxID  
      SET  QtyAllocated = (LOTxLOCxID.QtyAllocated + INSERTED.Qty),
           QtyExpected  = CASE WHEN (SL.LocationType NOT IN ('CASE','PICK') AND                
                                     LOC.LocationType NOT IN ('DYNPICKP', 'DYNPICKR','DYNPPICK')) THEN 0   
                               WHEN (( LOTxLOCxID.QtyAllocated + INSERTED.Qty) +
                                       LOTxLOCxID.QtyPicked ) > LOTxLOCxID.Qty
                               THEN (( LOTxLOCxID.QtyAllocated +  INSERTED.Qty) +
                                       LOTxLOCxID.QtyPicked - LOTxLOCxID.Qty ) 
                               ELSE 0
                          END,
            EditDate = GETDATE(),  
            EditWho = SUSER_SNAME()
      FROM LOTxLOCxID
      JOIN INSERTED ON INSERTED.LOT = LOTxLOCxID.LOT AND
                       INSERTED.LOC = LOTxLOCxID.LOC AND
                       INSERTED.ID = LOTxLOCxID.ID
      JOIN SKUxLOC SL WITH (NOLOCK) ON SL.StorerKey = LOTxLOCxID.StorerKey
                     AND SL.SKU = LOTxLOCxID.SKU
                     AND SL.LOC = LOTxLOCxID.LOC
      JOIN LOC LOC WITH (NOLOCK) ON LOC.LOC = LOTxLOCxID.LOC

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT             
   END
   ELSE
   BEGIN

      DECLARE @tLOTxLOCxID TABLE   (
         LOT          NVARCHAR(10) NOT NULL,
         LOC          NVARCHAR(10) NOT NULL,
         ID           NVARCHAR(18) NOT NULL,
         QtyAllocated int DEFAULT (0) 
         PRIMARY KEY CLUSTERED (LOT, LOC, ID)
         )

      INSERT INTO @tLOTxLOCxID  ( LOT, LOC, ID, QtyAllocated )
      SELECT LOT, LOC, ID,
             SUM (Qty) AS QtyAllocated
      FROM INSERTED
      GROUP BY LOT, LOC, ID
   
      UPDATE LOTxLOCxID 
      SET  QtyAllocated = (LOTxLOCxID.QtyAllocated + tLLI.QtyAllocated),
           QtyExpected  = CASE WHEN (SL.LocationType NOT IN ('CASE','PICK') AND                
                                     LOC.LocationType NOT IN ('DYNPICKP', 'DYNPICKR','DYNPPICK')) THEN 0   
                               WHEN (( LOTxLOCxID.QtyAllocated + tLLI.QtyAllocated) +
                                       LOTxLOCxID.QtyPicked ) > LOTxLOCxID.Qty
                               THEN (( LOTxLOCxID.QtyAllocated +  tLLI.QtyAllocated) +
                                       LOTxLOCxID.QtyPicked - LOTxLOCxID.Qty ) 
                               ELSE 0
                          END,
            EditDate = GETDATE(),  
            EditWho = SUSER_SNAME()
      FROM LOTxLOCxID
      JOIN @tLOTxLOCxID tLLI ON tLLI.LOT = LOTxLOCxID.LOT AND
                                tLLI.LOC = LOTxLOCxID.LOC AND
                                tLLI.ID = LOTxLOCxID.ID
      JOIN SKUxLOC SL WITH (NOLOCK) ON SL.StorerKey = LOTxLOCxID.StorerKey
                     AND SL.SKU = LOTxLOCxID.SKU
                     AND SL.LOC = LOTxLOCxID.LOC
      JOIN LOC LOC WITH (NOLOCK) ON LOC.LOC = LOTxLOCxID.LOC

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT    
   END

   IF @n_err <> 0
   BEGIN
      SELECT @n_Continue = 3
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63122   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On PickDetail Failed. (ntrPickDetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
   END
END

IF (@n_Continue = 1 OR @n_Continue = 2)  
BEGIN
   IF @b_debug = 1
   BEGIN
      SELECT 'Update Data In SKUxLOC'
   END

   IF @n_InsertedRows = 1
   BEGIN
      UPDATE SKUxLOC 
      SET  QtyAllocated = (SKUxLOC.QtyAllocated + INSERTED.Qty),
           QtyExpected  = CASE WHEN SKUxLOC.QtyAllocated + SKUxLOC.QtyPicked +
                                    INSERTED.Qty > (SKUxLOC.Qty )
                               THEN ( SKUxLOC.QtyAllocated + SKUxLOC.QtyPicked +
                                      INSERTED.Qty ) - (SKUxLOC.Qty)
                               ELSE 0
                          END, 
            EditDate = GETDATE(),    
            EditWho = SUSER_SNAME()
      FROM SKUxLOC
      JOIN INSERTED ON INSERTED.StorerKey = SKUxLOC.StorerKey 
                   AND INSERTED.SKU = SKUxLOC.SKU 
                   AND INSERTED.LOC = SKUxLOC.LOC

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT          
   END
   ELSE 
   BEGIN
      DECLARE  @tSKUxLOC Table   (
         StorerKey    NVARCHAR(15) NOT NULL,
         SKU          NVARCHAR(20) NOT NULL,
         LOC          NVARCHAR(10) NOT NULL,
         QtyAllocated int DEFAULT (0) 
         PRIMARY KEY CLUSTERED (StorerKey, SKU, LOC) 
         )

      INSERT INTO @tSKUxLOC ( StorerKey, SKU, LOC, QtyAllocated )
      SELECT StorerKey, SKU, LOC,
             SUM (Qty) AS QtyAllocated 
      FROM INSERTED
      GROUP BY StorerKey, SKU, LOC
   
      UPDATE SKUxLOC  
      SET  QtyAllocated = (SKUxLOC.QtyAllocated + tSL.QtyAllocated),
           QtyExpected  = CASE WHEN SKUxLOC.QtyAllocated + SKUxLOC.QtyPicked +
                                    tSL.QtyAllocated > (SKUxLOC.Qty )
                               THEN ( SKUxLOC.QtyAllocated + SKUxLOC.QtyPicked +
                                      tSL.QtyAllocated ) - (SKUxLOC.Qty)
                               ELSE 0
                          END, 
            EditDate = GETDATE(),    
            EditWho = SUSER_SNAME()
      FROM SKUxLOC
      JOIN @tSKUxLOC tSL ON tSL.StorerKey = SKUxLOC.StorerKey 
                        AND tSL.SKU = SKUxLOC.SKU 
                        AND tSL.LOC = SKUxLOC.LOC

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT    
   END
   IF @n_err <> 0
   BEGIN
      SELECT @n_Continue = 3
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63121   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On PickDetail Failed. (ntrPickDetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
   END
END

IF @n_Continue = 1 OR @n_Continue = 2
BEGIN
   IF @b_debug = 1
   BEGIN
      SELECT 'Update Data In ORDERDETAIL'
   END
   
   -- TLTING01
   DECLARE Cursor_item CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT  INSERTED.OrderKey, INSERTED.OrderLineNumber, SUM(INSERTED.Qty) Qty
   FROM INSERTED 
   GROUP BY INSERTED.OrderKey, INSERTED.OrderLineNumber 

   OPEN Cursor_item

   FETCH NEXT FROM Cursor_item INTO @c_OrderKey, @c_OrderLineNumber, @n_Qty

   WHILE @@FETCH_STATUS <> -1
   BEGIN    
      -- SHONG02
      UPDATE OrderDetail  
      SET OrderDetail.QtyAllocated = OrderDetail.QtyAllocated + @n_Qty,
          OrderDetail.Editdate = GETDATE(),
          OrderDetail.Editwho = SUSER_SNAME()
      WHERE OrderDetail.OrderKey = @c_OrderKey
      AND OrderDetail.OrderLineNumber = @c_OrderLineNumber
   
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63118   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On ORDERDETAIL Failed. (ntrPickDetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END

      FETCH NEXT FROM Cursor_item INTO @c_OrderKey, @c_OrderLineNumber, @n_Qty
   END -- WHILE
   CLOSE Cursor_item
   DEALLOCATE Cursor_item   
END

-- UnComment By SHONG
-- Need to refresh when doing manual allocation
-- Only Manual Allocation
IF @n_Continue = 1 OR @n_Continue = 2
BEGIN
   -- this option only valid when manual allocation
   IF EXISTS (SELECT 1 FROM INSERTED WHERE PickMethod = '' OR CaseID <> '' OR TrafficCop <> 'U' )
   BEGIN
      UPDATE ORDERS  
      SET EditDate = GETDATE()
      FROM ORDERS, INSERTED
      WHERE ORDERS.OrderKey = INSERTED.OrderKey

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63119   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On ORDERS Failed. (ntrPickDetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END
   END
END

IF @n_Continue = 1 OR @n_Continue = 2
BEGIN
   IF @c_AllowOverAllocations = "1"
   BEGIN
      IF EXISTS(SELECT 1 FROM LOTxLOCxID (NOLOCK), INSERTED, SKUxLOC (NOLOCK), LOC (NOLOCK) --NJOW02
                WHERE INSERTED.Lot = LOTxLOCxID.Lot
                AND INSERTED.Loc = LOTxLOCxID.Loc
                AND INSERTED.Id = LOTxLOCxID.Id
                AND LOTxLOCxID.StorerKey = SKUxLOC.StorerKey
                AND LOTxLOCxID.SKU = SKUxLOC.SKU
                AND LOTxLOCxID.Loc = SKUxLOC.LOC
                AND LOTxLOCxID.Loc = LOC.Loc --NJOW01
                AND SKUxLOC.LOCATIONTYPE <> "PICK"
                AND SKUxLOC.LOCATIONTYPE <> "CASE"
                AND LOC.LocationType NOT IN ('DYNPICKP', 'DYNPICKR','DYNPPICK') --NJOW02
                AND (LOTxLOCxID.QTYALLOCATED + LOTxLOCxID.QTYPICKED) > LOTxLOCxID.QTY)                
      BEGIN
         SELECT @n_Continue = 3 , @n_err = 63124
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": An Attempt Was Made To OverAllocate A Location That Is Not a Case Pick OR Piece Pick Location. (ntrPickDetailAdd)"
      END
   END
END

-- MC01-S
IF EXISTS(SELECT 1 FROM StorerConfig WITH (NOLOCK)
          WHERE StorerKey = @c_StorerKey AND ConfigKey = 'WAVEUPDLOG' AND sValue = '1')
BEGIN
   INSERT INTO PickDetail_Log (OrderKey ,OrderLineNumber ,WaveKey ,StorerKey
                              ,B_SKU, B_LOT, B_LOC, B_ID, B_QTY
                              ,A_SKU, A_LOT, A_LOC, A_ID, A_QTY
                              ,Status, PickDetailKey)
   SELECT INSERTED.OrderKey, INSERTED.OrderLineNumber, WaveDetail.Wavekey, INSERTED.StorerKey
         , '', '', '', '', 0
         , INSERTED.Sku, INSERTED.Lot, INSERTED.Loc, INSERTED.Id, INSERTED.Qty
         ,'0', INSERTED.PickDetailKey
   FROM INSERTED
   JOIN WaveDetail WITH (NOLOCK) ON ( WaveDetail.OrderKey = INSERTED.OrderKey )
   WHERE EXISTS ( SELECT 1 FROM Transmitlog3 WITH (NOLOCK)
                  WHERE Tablename = 'WAVERESLOG'
                  AND Key1 = WaveDetail.Wavekey
                  AND Key3 = INSERTED.StorerKey
                  AND TransmitFlag > '0' )

END -- IF EXISTS(StorerConfig - 'WAVEUPDLOG')
-- MC01-E

SET NOCOUNT OFF
/* #INCLUDE <TRPDA2.SQL> */
IF @n_Continue = 3  -- Error Occured - Process AND Return
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
   EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrPickDetailAdd"
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
GO
/***************************************************************************/  
/* Trigger: ntrPickDetailDelete                                            */  
/* Creation Date:                                                          */  
/* Copyright: IDS                                                          */  
/* Written by:                                                             */  
/*                                                                         */  
/* Purpose:                                                                */  
/*                                                                         */  
/* Usage:                                                                  */  
/*                                                                         */  
/* Called By: When records delete from PickDetail                          */  
/*                                                                         */  
/* PVCS Version: 1.9                                                       */  
/*                                                                         */  
/* Version: 5.4                                                            */  
/*                                                                         */  
/* Modifications:                                                          */  
/* Date         Author     Ver.  Purposes                                  */  
/* 17-Mar-2009  TLTING     1.1   Change user_name() to SUSER_SNAME()       */  
/* 10-JUN-2009  NJOW       1.2   'SA' LOCKDOWN. The checking has been      */  
/*                               shift to front-end (PB)                   */  
/* 26-Mar-2010  Vicky      1.3   Comment out the update of                 */  
/*                               QtyPickInProcess (Vicky01)                */  
/* 08-Nov-2010  James      1.4   Cancel TM task when delete pickdetail     */  
/*                               (james01)                                 */  
/* 09-Nov-2010  ChewKP     1.5   Insert Delete PickDetail to PickDet_Log   */
/*                               By StorerConfig = 'PickDET_InsertLog'     */
/*                               SOS#195929 (ChewKP01)                     */
/* 22-Dec-2010  Shong      1.6   Performance Tuning                        */
/*  9-Jun-2011  KHLim01    1.7   Insert Delete log                         */
/* 14-Jul-2011  KHLim02    1.8   GetRight for Delete log                   */
/* 02-Dec-2011  MCTang     1.9   Add WAVEUPDLOG for WCS-WAVE Status Change */
/*                               Export(MC01)                              */
/*  8-Mar-2011  KHLim03    1.10  Delete log for backend shipped records    */
/* 22-May-2012  TLTING01   1.10  DM data integrity issue - insert DELLOG   */
/*                               if status < '9'                           */
/* 11-JUN-2012  YTWan      1.11  SOS#246450:Delete short pick at MBOL&CBOL */
/*                               and auto packconfirm improvement(Wan01)   */
/* 25-Feb-2014  Chee       1.12  Add StorerConfig - UCC to revert          */
/*                               UCC.Status when unallocate (Chee01)       */
/* 02-Mar-2015  Shong      1.13  Prevent PickDetail delete if Packdetail   */
/*                               Exists (Shong01)                          */
/*                               Revise Update TaskDetail When Deletion    */
/* 23-Apr-2015  TLTING02   1.14  Deadlock tune, Taskdetail delete          */
/* 20-APR-2015  YTWan      1.15  SOS#337957 - ANF - CR on unallocation     */
/*                               logic (for handling shared UCC in multiple*/
/*                               orders). (Wan02)                          */
/* 29-Apr-2015  NJOW02     1.16  315021-Call pickdetail delete custom sp   */
/* 15-Dec-2015  NJOW03     1.17  357827-Allow Un-Allocation for            */
/*                               IDS_Supervisor When PICK-TRF='1'          */
/* 19-Aep-2017  TLTING02   1.18  deadlock tune                             */
/* 06-Feb-2018  SHONG04    1.19  Added Channel Management Logic            */
/* 04-SEP-2019  Wan03      1.20  WMS-10156 - NIKE - PH Allocation Strategy */
/*                               Enhancement                               */
/* 23-JUL-2019  Wan04      1.20  ChannelInventoryMgmt use fnc_SelectGetRight*/
/* 01-Dec-2021  TLTING03   1.21  Perfromance tune                          */
/***************************************************************************/  
CREATE TRIGGER [dbo].[ntrPickDetailDelete]
ON [dbo].[PICKDETAIL]
FOR  DELETE
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
    
    DECLARE @b_Success          INT -- Populated by calls to stored procedures - was the proc successful?
           ,@n_err              INT -- Error number returned by stored procedure or this trigger
           ,@n_err2             INT -- For Additional Error Detection
           ,@c_errmsg           NVARCHAR(250) -- Error message returned by stored procedure or this trigger
           ,@n_continue         INT
           ,@n_starttcnt        INT -- Holds the current transaction count
           ,@c_preprocess       NVARCHAR(250) -- preprocess
           ,@c_pstprocess       NVARCHAR(250) -- post process
           ,@n_cnt              INT
           ,@n_PickDetailSysId  INT
           ,@c_authority        NVARCHAR(1)
           ,@c_Facility         NVARCHAR(5)
           ,@c_Storerkey        NVARCHAR(15)
           ,@c_Taskdetailkey    NVARCHAR(10) 
    
    SELECT @n_continue = 1
          ,@n_starttcnt = @@TRANCOUNT
  
    DECLARE @c_AllowOverAllocations  NVARCHAR(1) -- Flag to see if overallocations are allowed.  
    DECLARE @c_CatchWeight           NVARCHAR(1) -- Flag to see if catch weight processing is allowed.  

   --(Wan02) - START
   DECLARE @c_UnAllocUCCPickCode    NVARCHAR(10)
         , @c_UnAllocStorerkey      NVARCHAR(15)
         , @c_SQL                   NVARCHAR(MAX)
         , @c_SQLParm               NVARCHAR(MAX)
   --(Wan02) - END
   
   --NJOW03
   DECLARE @c_username   NVARCHAR(18)  
          ,@c_Flag       NVARCHAR(10)  

            
   -- TLTING01
   IF EXISTS ( SELECT 1 FROM DELETED WHERE [STATUS] < '9')
   BEGIN
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
                  ,@c_errmsg = 'ntrPICKDETAILDelete' + dbo.fnc_RTrim(@c_errmsg)
         END
         ELSE 
         IF @c_authority = '1'         --    End   (KHLim02)
         BEGIN
            INSERT INTO dbo.PICKDETAIL_DELLOG ( PickDetailKey )
            SELECT PickDetailKey  FROM DELETED
            WHERE [STATUS] < '9'
   
            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PICKDETAIL Failed. (ntrPICKDETAILDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
            END
         END
      END
      -- End (KHLim01)
   END
    
    IF (SELECT COUNT(*) FROM   DELETED) =
       (SELECT COUNT(*) FROM   DELETED WHERE  DELETED.ArchiveCop = '9')
    BEGIN
        SELECT @n_continue = 4
    END 
    
    --NJOW02
    IF @n_continue = 1 or @n_continue = 2
    BEGIN
       IF EXISTS (SELECT 1 FROM DELETED d  
                  JOIN storerconfig s WITH (NOLOCK) ON  d.storerkey = s.storerkey    
                  JOIN sys.objects sys WITH (NOLOCK) ON sys.type = 'P' AND sys.name = s.Svalue
                  WHERE  s.configkey = 'PickDetailTrigger_SP')  
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
          
          EXECUTE dbo.isp_PickDetailTrigger_Wrapper
                   'DELETE' --@c_Action
                  , @b_Success  OUTPUT  
                  , @n_Err      OUTPUT   
                  , @c_ErrMsg   OUTPUT  
    
          IF @b_success <> 1  
          BEGIN  
             SELECT @n_continue = 3  
                   ,@c_errmsg = 'ntrPICKDETAILDelete' + dbo.fnc_RTrim(@c_errmsg)
          END  
    
          IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
             DROP TABLE #INSERTED
          
          IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
             DROP TABLE #DELETED
       END
    END    
    
    /* #INCLUDE <TRPDD1.SQL> */       
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
        SELECT TOP 1 
               @c_Facility = FACILITY
        FROM   LOC(NOLOCK)   
        JOIN   DELETED ON LOC.LOC = DELETED.LOC    
        
        SELECT TOP 1 
               @c_Storerkey = Storerkey
        FROM   DELETED  
        
        SELECT @b_success = 0 
        EXECUTE nspGetRight @c_Facility, -- facility  
        @c_Storerkey, -- Storerkey  
        NULL, -- Sku  
        'ALLOWOVERALLOCATIONS', -- Configkey  
        @b_success OUTPUT, 
        @c_AllowOverAllocations OUTPUT, 
        @n_err OUTPUT, 
        @c_errmsg OUTPUT  
        
        IF @b_success <> 1
        BEGIN
            SELECT @n_continue = 3 ,@c_errmsg = 'ntrPickDetailDelete' + dbo.fnc_RTrim(@c_errmsg)
        END 
        
        -- SELECT @c_AllowOverAllocations = NSQLValue
        -- FROM NSQLCONFIG (NOLOCK)
        -- WHERE CONFIGKEY = "ALLOWOVERALLOCATIONS"  
        
        SELECT @c_CatchWeight = NSQLValue
        FROM   NSQLCONFIG(NOLOCK)
        WHERE  CONFIGKEY = "CATCHWEIGHT"  
        
        IF @c_AllowOverAllocations IS NULL
        BEGIN
            SELECT @c_AllowOverAllocations = "0"
        END  
        IF @c_CatchWeight IS NULL
        BEGIN
            SELECT @c_CatchWeight = "0"
        END 
    END 
    
    -- SOS 14880: prevent delete of pick confirmed detail if PICK-TRF is on  
    IF (@n_continue=1 OR @n_continue=2) 
    BEGIN
        IF EXISTS (SELECT 1 FROM DELETED d
                      JOIN storerconfig s(NOLOCK) ON  d.storerkey = s.storerkey
               WHERE  s.configkey = 'PICK-TRF'
               AND    s.svalue = '1'
               AND    d.status = '5'
           )
        BEGIN
           --NJOW03 Start
           SET ANSI_NULLS ON
            SET ANSI_WARNINGS ON
            
            SET @c_username = SUSER_SNAME()
            SET @c_flag = 'N'
            
            EXEC isp_CheckSupervisorRole
                 @c_username  
               , @c_Flag        OUTPUT
               , @b_Success     OUTPUT  
               , @n_Err         OUTPUT  
               , @c_ErrMsg      OUTPUT
                        
            SET ANSI_NULLS OFF
            SET ANSI_WARNINGS OFF
            --NJOW03 End
            
            IF ISNULL(@c_Flag,'N') <> 'Y'  --NJOW03
            BEGIN               
               SELECT @n_continue = 3
                     ,@n_err = 63201  
               SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                      ": Delete Not Allowed on Pick Confirmed Record - Delete Failed. (ntrPickDetailDelete)"
            END
        END
    END 

    -- (Shong01)
    IF (@n_continue=1 OR @n_continue=2)     
    BEGIN  
        IF EXISTS (SELECT 1 FROM DELETED d  
                   JOIN storerconfig s WITH (NOLOCK) ON  d.storerkey = s.storerkey    
               WHERE  s.configkey = 'DisallowDeleteIfPacked01'  
               AND    s.svalue = '1'  
               AND    d.status BETWEEN '5' AND '8') 
        BEGIN  
           -- Checking the Store Orders (UK JackWill)
           IF EXISTS(SELECT 1 FROM DELETED D 
                     JOIN ORDERS AS SO WITH (NOLOCK) ON D.OrderKey = SO.OrderKey 
                     JOIN PackDetail AS pd WITH (NOLOCK) 
                        ON  D.StorerKey = PD.StorerKey 
                        AND D.SKU = PD.SKU 
                        AND D.PickSlipNo = PD.PickSlipNo 
                        AND D.AltSKU = PD.DropID 
                        AND (D.DropID IS NOT NULL AND D.DropID <> '')
                     WHERE SO.TYPE LIKE 'STORE%')
                     
            BEGIN
               SELECT @n_continue = 3  
                     ,@n_err = 63217    
               SELECT @c_errmsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+  
                      ': Delete Not Allowed on Pack Confirmed Record - Delete Failed. (ntrPickDetailDelete)'
               
            END
           -- Checking the ECOM Orders (UK JackWill)
           IF EXISTS(SELECT 1 FROM DELETED D 
                     JOIN ORDERS AS SO WITH (NOLOCK) ON D.OrderKey = SO.OrderKey 
                     JOIN PackDetail AS pd WITH (NOLOCK) 
                        ON  D.StorerKey = PD.StorerKey 
                        AND D.SKU = PD.SKU 
                        AND D.PickSlipNo = PD.PickSlipNo 
                        AND D.Dropid = PD.DropID 
                        AND (D.DropID IS NOT NULL AND D.DropID <> '')
                     WHERE SO.TYPE LIKE 'ECOMM%')
            BEGIN
               SELECT @n_continue = 3  
                     ,@n_err = 63217    
               SELECT @c_errmsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+  
                      ': Delete Not Allowed on Pack Confirmed Record - Delete Failed. (ntrPickDetailDelete)'               
            END
        END  
    END   
    
    IF @n_continue=1
    OR @n_continue=2 --Added by vicky 29 July 2002 to control the unallocation of pickdetail
    BEGIN
        SELECT @b_success = 0 
        EXECUTE nspGetRight NULL, -- facility  
        NULL, -- Storerkey  
        NULL, -- Sku  
        'OWITF', -- Configkey  
        @b_success OUTPUT, 
        @c_authority OUTPUT, 
        @n_err OUTPUT, 
        @c_errmsg OUTPUT  
        IF @b_success <> 1
        BEGIN
            SELECT @n_continue = 3
                  ,@c_errmsg = 'ntrPickDetailDelete' + dbo.fnc_RTrim(@c_errmsg)
        END
        ELSE 
        IF @c_authority = '1'
        BEGIN
            IF EXISTS (SELECT 1 FROM   DELETED WHERE  STATUS IN ("3" ,"4"))
            BEGIN
                SELECT @n_continue = 3
                      ,@n_err = 63201  
                SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                       ": Item(s) Are InProcess - Delete Failed. (ntrPickDetailDelete)"
            END 
            --END --commented by Vicky 11 Dec 2002 because other country need to delete pickdetail even status is > 2
            -- customized for HK, once pickdetail is Pick in Progress ('3') should not be DELETED. Coz interface has been done  
            IF @n_continue=1
            OR @n_continue=2
            BEGIN
                IF EXISTS (SELECT 1 FROM   DELETED WHERE  STATUS > '2') -- not in ("0","1","2","3","4","5","6,","7","8"))
                BEGIN
                    SELECT @n_continue = 3
                          ,@n_err = 63301  
                    SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                           ": Deletion of Allocated Order lines are not allowed. (ntrPickDetailDelete)"
                END
            END
        END
    END-- END OWITF configkey  
    
    IF @n_continue=1
    OR @n_continue=2
    BEGIN
        IF EXISTS (SELECT 1 FROM   DELETED WHERE  STATUS = "9")
        BEGIN
            SELECT @n_continue = 3
                  ,@n_err = 63202  
            SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                   ": Item(s) Are Shipped - Delete Failed. (ntrPickDetailDelete)"
        END
    END 
    -- Add by June for IDSV5 1.JUL.02, Extract from IDSMY *** Start  
    IF @n_continue=1
    OR @n_continue=2
    BEGIN
        IF EXISTS (SELECT 1 FROM DELETED WHERE  ShipFlag = "Y")
        BEGIN
            SELECT @n_continue = 3
                  ,@n_err = 63202  
            SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                   ": Item(s) Are Shipped - Delete Failed. (ntrPickDetailDelete)"
        END
    END 
    
    -- TBL UCC un-allocate  
    IF @n_continue=1 OR @n_continue=2
    BEGIN
        IF EXISTS (SELECT 1 FROM   DELETED d
                   JOIN StorerConfig s(NOLOCK) ON  d.StorerKey = s.StorerKey
                   WHERE  s.ConfigKey IN ('UCCTracking', 'UCC') -- Chee01
                   AND    s.SValue = '1')
        BEGIN
            --(Wan02) - START
            IF EXISTS(  SELECT 1                 
                        FROM DELETED D
                        JOIN STORERCONFIG S1 WITH (NOLOCK) ON (D.StorerKey = S1.StorerKey AND S1.ConfigKey IN ('UCCTracking', 'UCC')
                                                           AND S1.SVAlue = '1')
                        JOIN STORERCONFIG S2 WITH (NOLOCK) ON (D.StorerKey = S2.StorerKey AND S2.ConfigKey = 'UnAllocUCCPickCode')
                        WHERE S2.SValue <> '' AND S2.SValue IS NOT NULL
                        AND NOT EXISTS (SELECT 1 FROM sys.objects O WHERE NAME = S2.SValue
                                        AND O.TYPE = 'P')
                      )
            BEGIN
               SET @n_Continue= 3    
               SET @n_Err     = 63218    
               SET @c_ErrMsg  = 'NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': Invalid UnallocUCCPickCode (ntrPickDetailDelete)'
            END

            IF ( @n_continue = 1  OR @n_continue=2 )  
            BEGIN
               SELECT D.PickDetailKey        
                  , D.CaseID               
                  , D.PickHeaderKey        
                  , D.OrderKey             
                  , D.OrderLineNumber      
                  , D.Lot                  
                  , D.Storerkey            
                  , D.Sku                  
                  , D.AltSku               
                  , D.UOM                  
                  , D.UOMQty               
                  , D.Qty                  
                  , D.QtyMoved             
                  , D.Status               
                  , D.DropID               
                  , D.Loc                  
                  , D.ID                   
                  , D.PackKey              
                  , D.UpdateSource         
                  , D.CartonGroup          
                  , D.CartonType           
                  , D.ToLoc                
                  , D.DoReplenish          
                  , D.ReplenishZone        
                  , D.DoCartonize          
                  , D.PickMethod           
                  , D.WaveKey              
                  , D.EffectiveDate        
                  , D.TrafficCop           
                  , D.ArchiveCop           
                  , D.OptimizeCop          
                  , D.ShipFlag             
                  , D.PickSlipNo           
                  , D.TaskDetailKey        
                  , D.TaskManagerReasonKey 
                  , D.Notes                
--                  , D.MoveRefKey                  
               INTO #D_PICKDETAIL
               FROM DELETED D
               JOIN STORERCONFIG S1 WITH (NOLOCK) ON (D.StorerKey = S1.StorerKey AND S1.ConfigKey IN ('UCCTracking', 'UCC')
                                                  AND S1.SVAlue = '1')
               JOIN STORERCONFIG S2 WITH (NOLOCK) ON (D.StorerKey = S2.StorerKey AND S2.ConfigKey = 'UnAllocUCCPickCode')
               WHERE S2.SValue <> '' AND S2.SValue IS NOT NULL
               AND EXISTS (SELECT 1 FROM sys.objects O WHERE NAME = S2.SValue
                           AND O.TYPE = 'P')

               DECLARE CUR_UNALLOCSP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT DISTINCT D.Storerkey
                    , S2.SValue 
               FROM DELETED D
               JOIN STORERCONFIG S1 WITH (NOLOCK) ON (D.StorerKey = S1.StorerKey AND S1.ConfigKey IN ('UCCTracking', 'UCC')
                                                  AND S1.SVAlue = '1')
               JOIN STORERCONFIG S2 WITH (NOLOCK) ON (D.StorerKey = S2.StorerKey AND S2.ConfigKey = 'UnAllocUCCPickCode')
               WHERE S2.SValue <> '' AND S2.SValue IS NOT NULL
               AND EXISTS (SELECT 1 FROM sys.objects O WITH (NOLOCK) WHERE NAME = S2.SValue
                           AND O.TYPE = 'P')

               OPEN CUR_UNALLOCSP

               FETCH NEXT FROM CUR_UNALLOCSP INTO  @c_UnAllocStorerkey
                                                ,  @c_UnAllocUCCPickCode                    
 
               WHILE @@FETCH_STATUS <> -1
               BEGIN
                  SET @c_SQL = ''
                  SET @c_SQL = N'EXECUTE ' + @c_UnallocUCCPickCode   
                             +  '  @c_Storerkey = @c_UnAllocStorerkey '    
                             +  ', @b_Success   = @b_Success     OUTPUT '    
                             +  ', @n_Err       = @n_Err         OUTPUT '  
                             +  ', @c_ErrMsg    = @c_ErrMsg      OUTPUT '   

                  SET @c_SQLParm = '' 
                  SET @c_SQLParm =  N'@c_UnAllocStorerkey NVARCHAR(15)'
                                 +  ',@b_Success INT OUTPUT'
                                 +  ',@n_Err     INT OUTPUT'
                                 +  ',@c_ErrMsg  NVARCHAR(250) OUTPUT'

                  EXEC sp_ExecuteSQL  @c_SQL
                                    , @c_SQLParm 
                                    , @c_UnAllocStorerkey 
                                    , @b_Success   OUTPUT
                                    , @n_Err       OUTPUT
                                    , @c_ErrMsg    OUTPUT 
 
                  IF @@ERROR <> 0 OR @b_Success <> 1  
                  BEGIN  
                     SET @n_Continue= 3    
                     SET @n_Err     = 63219    
                     SET @c_ErrMsg  = 'NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': Failed to EXEC ' + @c_UnallocUCCPickCode +   
                                       CASE WHEN ISNULL(@c_ErrMsg, '') <> '' THEN ' - ' + @c_ErrMsg ELSE '' END + ' (ntrPickDetailDelete)'
                  END 
                  FETCH NEXT FROM CUR_UNALLOCSP INTO  @c_UnAllocStorerkey
                                                   ,  @c_UnAllocUCCPickCode  
               END
            END
     

            -- Call Standard Unallocate UCC If No customize Unallocate Pick Code being Setup
            IF ( @n_continue = 1  OR @n_continue=2 ) 
            BEGIN
            --(Wan02) - END
               UPDATE U with (ROWLOCK)
               SET STATUS = '1'
                     ,PickdetailKey = ''
                     ,OrderKey = ''
                     ,OrderLineNumber = ''
                     ,WaveKey = ''
               FROM   DELETED d
                      JOIN UCC U ON  D.PickDetailKey = U.PickDetailKey
                      -- (Wan02) - START
                      LEFT JOIN StorerConfig s2(NOLOCK) ON  d.StorerKey = s2.StorerKey AND s2.ConfigKey = 'UnAllocUCCPickCode'
                      -- (Wan02) - END
               WHERE  U.Status > '2' AND U.Status < '6' -- Chee01
               AND    (RTRIM(s2.SVALUE) = '' OR s2.SVALUE IS NULL)         -- (Wan02)
               AND    U.Storerkey = @c_Storerkey   --tlting03

               SELECT @n_err = @@ERROR
                     ,@n_cnt = @@ROWCOUNT  
               IF @n_err <> 0
               BEGIN
                   SELECT @n_continue = 3  
                   SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)  
                   SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                          ": Update on UCC Failed. (ntrPickDetailDelete)" + " ( " + 
                          " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) 
                          + " ) "
               END
            END --(Wan02) 
        END
    END 

-- SHONG04 Channel Management 
IF @n_Continue = 1 OR @n_Continue = 2
BEGIN
   SELECT TOP 1 @c_StorerKey = StorerKey
   FROM DELETED
   
   IF EXISTS(SELECT 1 FROM StorerConfig WITH (NOLOCK)
             WHERE StorerKey = @c_StorerKey AND ConfigKey = 'ChannelInventoryMgmt' AND sValue = '1')
   BEGIN
      DECLARE @n_Channel_ID     BIGINT, 
              @c_Channel        NVARCHAR(20), 
              @c_cStorerKey     NVARCHAR(15), 
              @c_cFacility      NVARCHAR(10),
              @c_cLOT           NVARCHAR(10),
              @c_cSKU           NVARCHAR(20),
              @n_cQty           INT,
              @c_cPickDetailKey NVARCHAR(10) 
      
      DECLARE CUR_CHANNEL_MGMT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DELETED.PickDetailKey,
             DELETED.Storerkey, 
             DELETED.Sku, 
             LOC.Facility, 
             ISNULL(OD.Channel,''), 
             DELETED.Lot, 
             ISNULL(DELETED.Channel_ID,0), 
             DELETED.Qty
      FROM DELETED WITH (NOLOCK) 
      JOIN LOC LOC WITH (NOLOCK) ON LOC.Loc = DELETED.Loc 
      CROSS APPLY fnc_SelectGetRight (LOC.Facility, DELETED.Storerkey, '', 'ChannelInventoryMgmt') SC --(Wan04) 
      --JOIN StorerConfig AS sc WITH(NOLOCK) ON DELETED.Storerkey = SC.StorerKey                      --(Wan04)
      --          AND SC.ConfigKey = 'ChannelInventoryMgmt' AND SC.sValue = '1'                       --(Wan04)
      JOIN ORDERDETAIL AS OD WITH(NOLOCK)
             ON  OD.OrderKey = DELETED.OrderKey AND OD.OrderLineNumber = DELETED.OrderLineNumber 
      WHERE SC.Authority = '1'                                                                        --(Wan04) 
      
      OPEN CUR_CHANNEL_MGMT 
      
      FETCH NEXT FROM CUR_CHANNEL_MGMT INTO @c_cPickDetailKey, @c_cStorerKey, @c_cSKU, @c_cFacility, @c_Channel, @c_cLOT, @n_Channel_ID, @n_cQty
      
      WHILE @@FETCH_STATUS = 0 
      BEGIN
         IF ISNULL(RTRIM(@c_Channel),'') = ''
         BEGIN
            SELECT @n_Continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63125   
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)
                  + ': Order Detail Channel Cannot be BLANK. (ntrPickDetailDelete)' 
                  + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) ' 
            BREAK                
         END
         IF @n_Channel_ID = 0 
         BEGIN
            EXEC isp_ChannelGetID 
                @c_StorerKey   = @c_cStorerKey
               ,@c_Sku         = @c_cSKU
               ,@c_Facility    = @c_cFacility
               ,@c_Channel     = @c_Channel
               ,@c_LOT         = @c_cLOT
               ,@n_Channel_ID  = @n_Channel_ID OUTPUT
            
         END
         IF ISNULL(@n_Channel_ID,0) > 0 
         BEGIN
            IF EXISTS(SELECT 1 FROM ChannelInv AS ci WITH(NOLOCK)
                      WHERE ci.Channel_ID = @n_Channel_ID 
                      AND ci.QtyAllocated < @n_cQty)
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63126   
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)
                     + ': Update Channel Inventory Failed, Channel Qty less than Qty Allocated. (ntrPickDetailDelete)' 
                     + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '              
            END
            ELSE
            BEGIN
               UPDATE ChannelInv WITH (ROWLOCK)
                  SET QtyAllocated = QtyAllocated - @n_cQty, 
                      EditDate = GETDATE(),
                      EditWho = SUSER_SNAME()
               WHERE Channel_ID = @n_Channel_ID 
            
            END
         END
         
         FETCH NEXT FROM CUR_CHANNEL_MGMT INTO @c_cPickDetailKey, @c_cStorerKey, @c_cSKU, @c_cFacility, @c_Channel, @c_cLOT, @n_Channel_ID, @n_cQty
      END -- While 
         
   END   
END 
    
    -- Add by June for IDSV5 1.JUL.02, Extract from IDSMY *** End  
   IF @n_continue=1 OR @n_continue=2
   BEGIN

      CREATE TABLE #DEL_LOT
         (LOT           NVARCHAR(10) NOT NULL
         ,QtyAllocated  INT NOT NULL
         ,QtyPicked     INT NOT NULL
         ,PRIMARY KEY (LOT)
         ,UNIQUE (LOT) )

      INSERT INTO #DEL_LOT (QtyAllocated, QtyPicked, LOT)         
      SELECT ISNULL(SUM(CASE WHEN DELETED.Status IN ('0' ,'1' ,'2' ,'3' ,'4') THEN DELETED.Qty ELSE 0 END),0) AS QtyAllocated
      ,ISNULL(SUM(CASE WHEN DELETED.Status IN ('5' ,'6' ,'7' ,'8') THEN DELETED.Qty ELSE 0 END),0) AS QtyPicked 
      ,DELETED.LOT 
      FROM   DELETED
      GROUP BY DELETED.LOT
      
      UPDATE LOT WITH (ROWLOCK)
         SET QtyPicked    = (LOT.QtyPicked - DEL_LOT.QtyPicked), 
             QtyAllocated = (LOT.QtyAllocated - DEL_LOT.QtyAllocated)   
      FROM LOT 
      JOIN #DEL_LOT AS DEL_LOT ON DEL_LOT.LOT = LOT.LOT 

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
               ,@n_err = 63203 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                ": Delete trigger On PickDetail Failed. (ntrPickDetailDelete)" 
                + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) 
                + " ) "
      END  
       
      IF @n_continue=1 OR @n_continue=2
      BEGIN                   
         CREATE TABLE #DEL_LOTxLOCxID
            (LOT           NVARCHAR(10) NOT NULL
            ,LOC           NVARCHAR(10) NOT NULL
            ,ID            NVARCHAR(18) NOT NULL
            ,QtyAllocated  INT NOT NULL
            ,QtyPicked     INT NOT NULL
            ,PRIMARY KEY (LOT, LOC, ID)
            ,UNIQUE (LOT, LOC, ID) )
         
         INSERT INTO #DEL_LOTxLOCxID(QtyAllocated, QtyPicked, LOT, LOC, ID)
         SELECT ISNULL(SUM(CASE WHEN DELETED.Status IN ('0' ,'1' ,'2' ,'3' ,'4') THEN DELETED.Qty ELSE 0 END),0) AS QtyAllocated
                  ,ISNULL(SUM(CASE WHEN DELETED.Status IN ('5' ,'6' ,'7' ,'8') THEN DELETED.Qty ELSE 0 END),0) AS QtyPicked 
                  ,DELETED.LOT 
                  ,DELETED.LOC 
                  ,DELETED.ID   
         FROM   DELETED
         GROUP BY DELETED.LOT, DELETED.LOC, DELETED.ID
                     
         UPDATE LOTxLOCxID WITH (ROWLOCK) 
         SET QtyPicked = (LOTxLOCxID.QtyPicked - DEL_LLI.QtyPicked), 
             QtyAllocated = (LOTxLOCxID.QtyAllocated - DEL_LLI.QtyAllocated), 
             QtyExpected = CASE 
                              WHEN (((LOTxLOCxID.QtyAllocated - DEL_LLI.QtyAllocated) + (LOTxLOCxID.QtyPicked - DEL_LLI.QtyPicked)) - LOTxLOCxID.Qty) >= 0 
                              AND @c_AllowOverAllocations = '1' 
                              THEN (((LOTxLOCxID.QtyPicked - DEL_LLI.QtyPicked) + (LOTxLOCxID.QtyAllocated - DEL_LLI.QtyAllocated)) - LOTxLOCxID.Qty)
                              ELSE 0
                           END
         FROM LOTxLOCxID 
         JOIN #DEL_LOTxLOCxID AS DEL_LLI ON 
                   LOTxLOCxID.lot = DEL_LLI.LOT AND 
                   LOTxLOCxID.loc = DEL_LLI.LOC AND 
                   LOTxLOCxID.id  = DEL_LLI.ID

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
         IF @n_err <> 0
         BEGIN
             SELECT @n_continue = 3  
             SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                   ,@n_err = 63208 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
             SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                    ": Delete trigger On PickDetail Failed. (ntrPickDetailDelete)" 
                    + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) 
                    + " ) "
         END
      END 

      IF @n_continue=1 OR @n_continue=2
      BEGIN
         CREATE TABLE #DEL_SKUxLOC
            (StorerKey     NVARCHAR(15) NOT NULL
            ,SKU           NVARCHAR(20) NOT NULL
            ,LOC           NVARCHAR(10) NOT NULL
            ,QtyAllocated  INT NOT NULL
            ,QtyPicked     INT NOT NULL
            ,PRIMARY KEY (StorerKey, SKU, LOC)
            ,UNIQUE (StorerKey, SKU, LOC) )

           INSERT INTO #DEL_SKUxLOC(QtyAllocated, QtyPicked, StorerKey, SKU, LOC)                  
           SELECT ISNULL(SUM(CASE WHEN DELETED.Status IN ('0' ,'1' ,'2' ,'3' ,'4') THEN DELETED.Qty ELSE 0 END),0) AS QtyAllocated
                  ,ISNULL(SUM(CASE WHEN DELETED.Status IN ('5' ,'6' ,'7' ,'8') THEN DELETED.Qty ELSE 0 END),0) AS QtyPicked 
                  ,DELETED.StorerKey 
                  ,DELETED.SKU 
                  ,DELETED.LOC 
            FROM   DELETED
            GROUP BY DELETED.StorerKey, DELETED.SKU, DELETED.LOC
                     
         UPDATE SKUxLOC WITH (ROWLOCK)
         SET QtyPicked    = SKUxLOC.QtyPicked - DEL_SKUxLOC.QtyPicked, 
             QtyAllocated = SKUxLOC.QtyAllocated - DEL_SKUxLOC.QtyAllocated,
             QtyExpected  = CASE 
                                 WHEN (((SKUxLOC.QtyAllocated - DEL_SKUxLOC.QtyAllocated) + 
                                        (SKUxLOC.QtyPicked - DEL_SKUxLOC.QtyPicked)) - SKUxLOC.Qty) >= 0 
                                      AND @c_AllowOverAllocations = '1'  
                                 THEN (((SKUxLOC.QtyAllocated - DEL_SKUxLOC.QtyAllocated) + (SKUxLOC.QtyPicked - DEL_SKUxLOC.QtyPicked)) 
                                          - SKUxLOC.Qty) 
                                 ELSE 0
                            END
         FROM SKUxLOC 
         JOIN #DEL_SKUxLOC AS DEL_SKUxLOC ON 
                 DEL_SKUxLOC.StorerKey = SKUxLOC.StorerKey AND 
                 DEL_SKUxLOC.SKU = SKUxLOC.SKU AND
                 DEL_SKUxLOC.LOC = SKUxLOC.LOC
               
         SELECT @n_err = @@ERROR
               ,@n_cnt = @@ROWCOUNT  
         IF @n_err <> 0
         BEGIN
             SELECT @n_continue = 3  
             SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                   ,@n_err = 63208 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
             SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                    ": Delete trigger On PickDetail Failed. (ntrPickDetailDelete)" 
                    + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) 
                    + " ) "
         END
      END
            
      IF @n_continue=1 OR @n_continue=2
      BEGIN
         CREATE TABLE #DEL_ORD
            (OrderKey           NVARCHAR(10) NOT NULL
            ,OrderLineNumber    NVARCHAR(5) NOT NULL
            ,QtyAllocated  INT NOT NULL
            ,QtyPicked     INT NOT NULL
            ,PRIMARY KEY (OrderKey, OrderLineNumber)
            ,UNIQUE (OrderKey, OrderLineNumber) )
                     
         INSERT INTO #DEL_ORD(QtyAllocated, QtyPicked, OrderKey, OrderLineNumber)
         SELECT ISNULL(SUM(CASE WHEN DELETED.Status IN ('0' ,'1' ,'2' ,'3' ,'4') THEN DELETED.Qty ELSE 0 END),0) AS QtyAllocated
               ,ISNULL(SUM(CASE WHEN DELETED.Status IN ('5' ,'6' ,'7' ,'8') THEN DELETED.Qty ELSE 0 END),0) AS QtyPicked 
               ,DELETED.OrderKey 
               ,DELETED.OrderLineNumber   
         FROM   DELETED
         GROUP BY DELETED.OrderKey, DELETED.OrderLineNumber
                     
         UPDATE OrderDetail WITH (ROWLOCK) 
            SET    QtyPicked = OrderDetail.QtyPicked - DEL_OD.QtyPicked, 
                   QtyAllocated = OrderDetail.QtyAllocated - DEL_OD.QtyAllocated
         FROM OrderDetail 
         JOIN #DEL_ORD AS DEL_OD ON 
                OrderDetail.OrderKey = DEL_OD.OrderKey AND 
                OrderDetail.OrderLineNumber = DEL_OD.OrderLineNumber
               
         SELECT @n_err = @@ERROR
               ,@n_cnt = @@ROWCOUNT  
         IF @n_err <> 0
         BEGIN
             SELECT @n_continue = 3  
             SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                   ,@n_err = 63206 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
             SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                    ": Delete trigger On PickDetail Failed. (ntrPickDetailDelete)" 
                    + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) 
                    + " ) "
         END
       END
    END  
    
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
        --(Shong01) 
        DECLARE @n_PickDetQty    INT, 
                @n_TaskStatus    NVARCHAR(1), 
                @c_TaskStatus    NVARCHAR(10), 
                @n_TaskQty       INT,
                @c_DelPickDetKey NVARCHAR(10)
         --(Wan01) - START
         DECLARE @c_DelPickCommTaskQtysUpd   NVARCHAR(10) = '' 
               , @c_FacilityD                NVARCHAR(15) = ''                                                   
               , @c_StorerkeyDLast           NVARCHAR(15) = ''                                                 
               , @c_StorerkeyD               NVARCHAR(15) = ''                                                            
               , @c_SkuD                     NVARCHAR(20) = ''                                                            
               , @c_FromLoc                  NVARCHAR(10) = '' 
               , @n_Qty                      INT          = 0                                                             
               , @n_SystemQty                INT          = 0                                                             
               , @b_Case                     BIT          = 0                                                             
                          
                        
        --(james01)  
        DECLARE CUR_DELETE_TASK CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
        SELECT DISTINCT DELETED.TaskDetailKey, DELETED.Qty, DELETED.PickDetailKey
               , DELETED.Storerkey, DELETED.Sku, LOC.Facility                                                  --(Wan03) 
        FROM   DELETED  
        JOIN LOC WITH (NOLOCK) ON LOC.Loc = DELETED.Loc                                                        --(Wan03) 
        ORDER BY DELETED.Storerkey        

        OPEN CUR_DELETE_TASK   
        FETCH NEXT FROM CUR_DELETE_TASK INTO @c_TaskDetailKey, @n_PickDetQty, @c_DelPickDetKey
                                          ,  @c_StorerkeyD, @c_SkuD, @c_FacilityD                              --(Wan03)    
        WHILE @@FETCH_STATUS <> -1  
        BEGIN  
           SET @c_TaskStatus = ''
           SET @n_TaskQty = 0 
           
           SELECT @c_TaskStatus = Status, 
                  @n_TaskQty = Qty
                , @c_FromLoc  = FromLoc                                                                        --(Wan03) 
           FROM TASKDETAIL WITH (NOLOCK) 
           WHERE TASKDETAIL.TaskDetailKey = @c_TaskDetailKey 
           
           IF ( @c_TaskStatus <> '9' AND @c_TaskStatus <> '')
           BEGIN
              IF NOT EXISTS(SELECT 1 FROM PICKDETAIL(NOLOCK)  
                            WHERE  TaskDetailKey = @c_TaskDetailKey
                            AND    PickDetailKey <> @c_DelPickDetKey)             
              BEGIN  
                 --         UPDATE TASKDETAIL WITH (ROWLOCK) SET  
                 --            STATUS = 'X', TRAFFICCOP = NULL  
                 --         WHERE TaskDetailKey = @c_TaskDetailKey    
                    
                 DELETE TASKDETAIL with (ROWLOCK) 
                 WHERE  TaskDetailKey = @c_TaskDetailKey  
                 AND    [Status] <> '9'    
                   
                 IF @@ERROR <> 0  
                 BEGIN  
                     SELECT @n_continue = 3    
                     SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)  
                           ,@n_err = 63214    
                     SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+  
                            ": Delete trigger On PickDetail Failed. (ntrPickDetailDelete)"   
                            + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg))   
                            + " ) "  
                 END  
              END 
              ELSE
              BEGIN
                  --(Wan03) - START
                  IF @c_StorerkeyD <> @c_StorerkeyDLast
                  BEGIN
                     SELECT @c_DelPickCommTaskQtysUpd = SC.Authority
                     FROM fnc_SelectGetRight (@c_FacilityD, @c_StorerkeyD, '', 'DelPickCommTaskQtysUpd') SC
                     
                     SET @c_StorerkeyDLast = @c_StorerkeyD
                  END  

                  IF @c_DelPickCommTaskQtysUpd = '1'
                  BEGIN 
                     SET @b_Case = 0
                     SET @n_SystemQty = @n_PickDetQty
                     SET @n_Qty = @n_PickDetQty

                     IF EXISTS ( SELECT 1 
                                 FROM LOC WITH (NOLOCK)
                                 JOIN UCC WITH (NOLOCK) ON LOC.Loc = UCC.Loc
                                 WHERE LOC.Loc = @c_FromLOC
                                 AND LOC.LoseUCC = '0'
                                 )
                     BEGIN
                        SET @b_Case = 1
                     END    

                     IF @b_Case = 0
                     BEGIN
                        IF EXISTS ( SELECT 1
                                    FROM SKU S WITH (NOLOCK)
                                    JOIN PACK P WITH (NOLOCK) ON P.Packkey = S.Packkey
                                    WHERE S.Storerkey = @c_StorerkeyD
                                    AND S.Sku = @c_SkuD
                                    GROUP BY P.Packkey, P.CaseCnt
                                    HAVING @n_TaskQty % CONVERT(INT, P.CaseCnt) = 0
                                  )
                        BEGIN
                           SET @b_Case = 1
                        END                                                             
                     END

                     IF @b_Case = 1 
                     BEGIN
                        SET @n_Qty = 0
                     END

                     UPDATE TASKDETAIL with (ROWLOCK)
                       SET Qty        = Qty - @n_Qty 
                         , SystemQty  = SystemQty - @n_SystemQty
                         , EditWho    = sUser_sName()  
                         , EditDate   = GetDate() 
                         , TrafficCop = NULL 
                    WHERE TASKDETAIL.TaskDetailKey = @c_TaskDetailKey
                    AND TASKDETAIL.Status <> '9'
                 
                    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT 
                    IF @n_err <> 0 
                    BEGIN
                       SELECT @n_continue = 3
                       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63214
                       SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update TaskDetail Failed. (ntrPickDetailDelete)" + 
                              " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
                    END
                                                      
                  END
                  ELSE
                  BEGIN
                    UPDATE TASKDETAIL with (ROWLOCK)
                       SET Qty = Qty - @n_PickDetQty,
                           EditWho    = sUser_sName(), 
                           EditDate   = GetDate(), 
                           TrafficCop = NULL 
                    WHERE TASKDETAIL.TaskDetailKey = @c_TaskDetailKey
                    AND TASKDETAIL.Status <> '9'
                 
                    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT 
                    IF @n_err <> 0 
                    BEGIN
                       SELECT @n_continue = 3
                       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63214
                       SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update TaskDetail Failed. (ntrPickDetailDelete)" + 
                              " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
                    END
                  END
                  --(Wan03) - END
              END 
           END    
           
           FETCH NEXT FROM CUR_DELETE_TASK INTO @c_TaskDetailKey, @n_PickDetQty, @c_DelPickDetKey
                                              , @c_StorerkeyD, @c_SkuD,  @c_FacilityD                             --(Wan03)    
        END   
        CLOSE CUR_DELETE_TASK   
        DEALLOCATE CUR_DELETE_TASK  
    END  

    IF (@n_continue = 1 OR @n_continue = 2)
    BEGIN
         -- tlting02
        IF EXISTS ( SELECT 1 FROM TASKDETAIL (NOLOCK),  DELETED
        WHERE  TASKDETAIL.PickDetailKey = DELETED.PickDetailKey
        AND    TASKDETAIL.TaskType = 'PK'
        AND    TASKDETAIL.Status <> '9'    )
        BEGIN 
           DELETE TASKDETAIL with (ROWLOCK)
           FROM   DELETED
           WHERE  TASKDETAIL.PickDetailKey = DELETED.PickDetailKey
           AND    TASKDETAIL.TaskType = 'PK'
           AND    TASKDETAIL.Status <> '9'  
           SELECT @n_err = @@ERROR
                 ,@n_cnt = @@ROWCOUNT  
           IF @n_err <> 0
           BEGIN
               SELECT @n_continue = 3  
               SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                     ,@n_err = 63214  
               SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                      ": Delete trigger On PickDetail Failed. (ntrPickDetailDelete)" 
                      + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) 
                      + " ) "
           END 
        END
    END
            
    IF (@c_CatchWeight = '1')
    AND (@n_continue = 1 OR @n_continue = 2)
    BEGIN
        DELETE LOTxIDDETAIL with (ROWLOCK)
        FROM   DELETED
        WHERE  LOTxIDDETAIL.PickDetailKey = DELETED.PickDetailKey  
        SELECT @n_err = @@ERROR
              ,@n_cnt = @@ROWCOUNT  
        IF @n_err <> 0
        BEGIN
            SELECT @n_continue = 3  
            SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                  ,@n_err = 63215  
            SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                   ": Delete LOTxIDDETAIL Failed. (ntrPickDetailDelete)" + " ( " 
                   + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) 
                   + " ) "
        END
    END  
    
    
    IF (@n_continue=1 OR @n_continue=2) -- (ChewKP01)
    BEGIN
        IF EXISTS (
               SELECT 1
               FROM   DELETED d
                      JOIN storerconfig s(NOLOCK)
                           ON  d.storerkey = s.storerkey
               WHERE  s.configkey = 'PickDet_InsertLog'
               AND    s.svalue = '1'
           )
        BEGIN
            INSERT INTO PickDet_LOG
              (
                PickDetailKey     ,OrderKey    ,OrderLineNumber
               ,Storerkey         ,Sku         ,Lot
               ,Loc               ,ID          ,UOM
               ,Qty               ,STATUS      ,DropID
               ,PackKey           ,WaveKey     ,AddDate
               ,AddWho            ,PickSlipNo  ,TaskDetailKey
               ,CaseID
              )
            SELECT PickDetailKey  ,OrderKey    ,OrderLineNumber
                  ,Storerkey      ,Sku         ,Lot
                  ,Loc            ,ID          ,UOM
                  ,Qty            ,STATUS      ,DropID
                  ,PackKey        ,WaveKey     ,AddDate
                  ,AddWho         ,PickSlipNo  ,TaskDetailKey
                  ,CaseID
            FROM   DELETED      
            
            
            SELECT @n_err = @@ERROR
                  ,@n_cnt = @@ROWCOUNT  
            IF @n_err <> 0
            BEGIN
                SELECT @n_continue = 3
                      ,@n_err = 63216
                SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                       ": Insert into PickDet_Log Failed - Insert Failed. (ntrPickDetailDelete)"
            END
        END
    END 
    
   -- MC01-S   
   IF EXISTS(SELECT 1 FROM StorerConfig WITH (NOLOCK)  
             WHERE StorerKey = @c_StorerKey AND ConfigKey = 'WAVEUPDLOG' AND sValue = '1')  
   BEGIN
      
      INSERT INTO PickDetail_Log (OrderKey ,OrderLineNumber ,WaveKey ,StorerKey
                                 ,B_SKU ,B_LOT ,B_LOC ,B_ID ,B_QTY  
                                 ,A_SKU ,A_LOT ,A_LOC ,A_ID ,A_QTY  
                                 ,Status ,PickDetailKey)      
      SELECT DELETED.OrderKey ,DELETED.OrderLineNumber ,WaveDetail.Wavekey ,DELETED.Storerkey     
            ,DELETED.Sku      ,DELETED.Lot             ,DELETED.Loc        ,DELETED.ID         ,DELETED.Qty            
            ,''               ,''                      ,''                 ,''                 ,0 
            ,'0'              ,DELETED.PickDetailKey 
      FROM  DELETED   
      JOIN  WaveDetail WITH (NOLOCK) ON ( WaveDetail.Orderkey = DELETED.Orderkey )
      WHERE EXISTS ( SELECT 1 FROM Transmitlog3 WITH (NOLOCK)  
                     WHERE Tablename = 'WAVERESLOG' 
                     AND Key1 = WaveDetail.Wavekey
                     AND Key3 = DELETED.Storerkey 
                     AND TransmitFlag > '0' )     
          
   END -- IF EXISTS(StorerConfig - 'WAVEUPDLOG')
   -- MC01-E
   
    /* #INCLUDE <TRPDD2.SQL> */ 
    
    -- Added By SHONG
    -- 25th Jul 2002
    -- To refresh the Order Header Status  
    --IF @n_continue=1 OR @n_continue=2
    --BEGIN
    --    UPDATE ORDERS with (ROWLOCK)
    --    SET    EditWho = SUSER_SNAME()
    --    FROM   ORDERS
    --          ,DELETED
    --    WHERE  DELETED.OrderKey = ORDERS.OrderKey  
    --    SELECT @n_err = @@ERROR
    --          ,@n_cnt = @@ROWCOUNT  
    --    IF @n_err <> 0
    --    BEGIN
    --        SELECT @n_continue = 3  
    --        SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
    --              ,@n_err = 63210 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
    --        SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
    --               ": Delete trigger On ORDERS Failed. (ntrPickDetailDelete)" + 
    --               " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) 
    --               + " ) "
    --    END
    --END  
    
    IF @n_continue=1
    OR @n_continue=2
    BEGIN
        DELETE RefKeyLookup with (ROWLOCK)
        FROM   RefKeyLookup
              ,DELETED
        WHERE  RefKeyLookup.Pickdetailkey = DELETED.Pickdetailkey   
        
        SELECT @n_err = @@ERROR
              ,@n_cnt = @@ROWCOUNT  
        IF @n_err <> 0
        BEGIN
            SELECT @n_continue = 3  
            SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                  ,@n_err = 63212 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
            SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                   ": Delete trigger On RefKeyLookup Failed. (ntrPickDetailDelete)" 
                   + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) 
                   + " ) "

        END
    END 
   --(Wan01) -- START 
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      IF EXISTS (SELECT 1 FROM DELETED WHERE STATUS = '4')
      BEGIN
         INSERT INTO dbo.ShortPickLog
           (
             MBOLKey, DeleteWho, DeleteDate, PickDetailKey, CaseID, PickHeaderKey, 
             OrderKey, OrderLineNumber, Lot, Storerkey, Sku, AltSku, UOM, UOMQty, Qty, 
             QtyMoved, STATUS, DropID, Loc, ID, PackKey, UpdateSource, CartonGroup, 
             CartonType, ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, 
             WaveKey, EffectiveDate, TrafficCop, ArchiveCop, OptimizeCop, ShipFlag, 
             PickSlipNo, TaskDetailKey, TaskManagerReasonKey, AddDate, AddWho, EditDate, 
             EditWho
           )
         SELECT MBOLDETAIL.MBOLKey, SUSER_NAME(), GETDATE(), DELETED.PickDetailKey, 
                DELETED.CaseID, DELETED.PickHeaderKey, DELETED.OrderKey, 
                DELETED.OrderLineNumber, DELETED.Lot, DELETED.Storerkey, DELETED.Sku, 
                DELETED.AltSku, DELETED.UOM, DELETED.UOMQty, DELETED.Qty, DELETED.QtyMoved, 
                DELETED.Status, DELETED.DropID, DELETED.Loc, DELETED.ID, DELETED.PackKey, 
                DELETED.UpdateSource, DELETED.CartonGroup, DELETED.CartonType, DELETED.ToLoc, 
                DELETED.DoReplenish, DELETED.ReplenishZone, DELETED.DoCartonize, DELETED.PickMethod, 
                DELETED.WaveKey, DELETED.EffectiveDate, DELETED.TrafficCop, DELETED.ArchiveCop, 
                DELETED.OptimizeCop, DELETED.ShipFlag, DELETED.PickSlipNo, DELETED.TaskDetailKey, 
                DELETED.TaskManagerReasonKey, DELETED.AddDate, DELETED.AddWho, DELETED.EditDate, 
                DELETED.EditWho
         FROM   DELETED
         LEFT JOIN MBOLDETAIL WITH (NOLOCK)
               ON  (DELETED.Orderkey = MBOLDETAIL.Orderkey) 

         SET @n_err = @@ERROR 
         IF @n_err <> 0
         BEGIN
            SET @n_continue = 3
            SET @n_err = 63209   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': INSERT Record On to SHORTPICKLOG Table Failed. (ntrPICKDETAILDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END
   --(Wan01) -- END 

   IF @n_continue=3 -- Error Occured - Process And Return
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
        EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrPickDetailDelete" 
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
/* Trigger: ntrPickDetailPreAdd                                         */
/* Creation Date:                                                       */
/* Copyright: LFL                                                       */
/* Written by: Shong                                                    */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: When records Added                                        */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 17-May-2021  Shong         Created                                   */
/************************************************************************/

CREATE  TRIGGER [dbo].[ntrPickDetailPreAdd]
ON  [dbo].[PICKDETAIL]
INSTEAD OF INSERT 
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
        @b_Success         INT           -- Populated by calls to stored procedures - was the proc successful?
      , @n_err             INT           -- Error number returned by stored procedure OR this trigger
      , @c_errmsg          NVARCHAR(250) -- Error message returned by stored procedure OR this trigger
      , @n_Continue        INT
      , @n_starttcnt       INT           -- Holds the current transaction count
      , @c_Facility        NVARCHAR(5)
      , @c_Storerkey       NVARCHAR(15)
      , @c_UpdPickslipToPickDet NVARCHAR(10)  --NJOW03          
      , @c_Pickheaderkey   NVARCHAR(10) --NJOW03

   DECLARE  
      @n_SL_QtyAllocated      INT,
      @n_SL_QtyPicked         INT,
      @n_SL_Qty               INT,
      @c_LOC                  NVARCHAR(10),
      @c_LocationType         NVARCHAR(10),
      @n_Qty                  INT,
      @c_SKU                  NVARCHAR(20),
      @c_ID                   NVARCHAR(18) = ''
               
   SELECT @n_Continue = 1, @n_starttcnt = @@TRANCOUNT
   
   DECLARE @c_AllowOverAllocations NVARCHAR(1) -- Flag to see if overallocations are allowed.
         , @c_ForceAllocLottable   NVARCHAR(1) = '0'

   DECLARE @b_debug INT
   SELECT @b_debug = 0

   DECLARE @c_LOC_LocationType NVARCHAR(10)  --NJOW01

   DECLARE @t_PickDetail TABLE (
	   [PickDetailKey] [nvarchar](18) NOT NULL,
	   [CaseID] [nvarchar](20) NOT NULL DEFAULT (' '),
	   [Pickheaderkey] [nvarchar](18) NOT NULL,
	   [OrderKey] [nvarchar](10) NOT NULL,
	   [OrderLineNumber] [nvarchar](5) NOT NULL,
	   [Lot] [nvarchar](10) NOT NULL,
	   [Storerkey] [nvarchar](15) NOT NULL,
	   [Sku] [nvarchar](20) NOT NULL,
	   [AltSku] [nvarchar](20) NOT NULL  DEFAULT (''),
	   [UOM] [nvarchar](10) NOT NULL  DEFAULT (''),
	   [UOMQty] [int] NOT NULL  DEFAULT (0),
	   [Qty] [int] NOT NULL  DEFAULT (0),
	   [QtyMoved] [int] NOT NULL DEFAULT (0),
	   [Status] [nvarchar](10) NOT NULL DEFAULT ('0'),
	   [DropID] [nvarchar](20) NOT NULL DEFAULT (''),
	   [Loc] [nvarchar](10) NOT NULL DEFAULT ('UNKNOWN'),
	   [ID] [nvarchar](18) NOT NULL DEFAULT (''),
	   [PackKey] [nvarchar](10) NULL DEFAULT (''),
	   [UpdateSource] [nvarchar](10) NULL  DEFAULT ('0'),
	   [CartonGroup] [nvarchar](10) NULL,
	   [CartonType] [nvarchar](10) NULL,
	   [ToLoc] [nvarchar](10) NULL DEFAULT (''),
	   [DoReplenish] [nvarchar](1) NULL DEFAULT ('N'),
	   [ReplenishZone] [nvarchar](10) NULL DEFAULT (''),
	   [DoCartonize] [nvarchar](1) NULL DEFAULT ('N'),
	   [PickMethod] [nvarchar](1) NOT NULL DEFAULT (''),
	   [WaveKey] [nvarchar](10) NOT NULL DEFAULT (''),
	   [EffectiveDate] [datetime] NOT NULL DEFAULT (getdate()),
	   [AddDate] [datetime] NOT NULL DEFAULT (getdate()),
	   [AddWho] [nvarchar](128) NULL,
	   [EditDate] [datetime] NOT NULL,
	   [EditWho] [nvarchar](128) NULL,
	   [TrafficCop] [nvarchar](1) NULL,
	   [ArchiveCop] [nvarchar](1) NULL,
	   [OptimizeCop] [nvarchar](1) NULL,
	   [ShipFlag] [nvarchar](1) NULL DEFAULT ('0'),
	   [PickSlipNo] [nvarchar](10) NULL DEFAULT (''),
	   [TaskDetailKey] [nvarchar](10) NULL  DEFAULT (''),
	   [TaskManagerReasonKey] [nvarchar](10) NULL  DEFAULT (''),
	   [Notes] [nvarchar](4000) NULL  DEFAULT (''),
	   [MoveRefKey] [nvarchar](10) NULL DEFAULT (''),
	   [Channel_ID] [bigint] NULL  DEFAULT (0),
	   [SourceType] [nvarchar](50) NULL DEFAULT (''),
      [Facility] [NVARCHAR](5) NULL DEFAULT('')
       ) 
 
   
   INSERT INTO @t_PickDetail
   (
      PickDetailKey,
      CaseID,
      Pickheaderkey,
      OrderKey,
      OrderLineNumber,
      Lot,
      Storerkey,
      Sku,
      AltSku,
      UOM,
      UOMQty,
      Qty,
      QtyMoved,
      [Status],
      DropID,
      Loc,
      ID,
      PackKey,
      UpdateSource,
      CartonGroup,
      CartonType,
      ToLoc,
      DoReplenish,
      ReplenishZone,
      DoCartonize,
      PickMethod,
      WaveKey,
      EffectiveDate,
      AddDate,
      AddWho,
      EditDate,
      EditWho,
      TrafficCop,
      ArchiveCop,
      OptimizeCop,
      ShipFlag,
      PickSlipNo,
      TaskDetailKey,
      TaskManagerReasonKey,
      Notes,
      MoveRefKey,
      Channel_ID,
      SourceType,
      Facility
   )
   SELECT INS.PickDetailKey,
      INS.CaseID,
      INS.Pickheaderkey,
      INS.OrderKey,
      INS.OrderLineNumber,
      INS.Lot,
      INS.Storerkey,
      INS.Sku,
      INS.AltSku,
      INS.UOM,
      INS.UOMQty,
      INS.Qty,
      INS.QtyMoved,
      INS.[Status],
      INS.DropID,
      INS.Loc,
      INS.ID,
      INS.PackKey,
      INS.UpdateSource,
      INS.CartonGroup,
      INS.CartonType,
      INS.ToLoc,
      INS.DoReplenish,
      INS.ReplenishZone,
      INS.DoCartonize,
      INS.PickMethod,
      INS.WaveKey,
      INS.EffectiveDate,
      INS.AddDate,
      INS.AddWho,
      INS.EditDate,
      INS.EditWho,
      INS.TrafficCop,
      INS.ArchiveCop,
      INS.OptimizeCop,
      INS.ShipFlag,
      INS.PickSlipNo,
      INS.TaskDetailKey,
      INS.TaskManagerReasonKey,
      INS.Notes,
      INS.MoveRefKey,
      INS.Channel_ID,
      INS.SourceType,
      LOC.Facility
   FROM INSERTED AS INS 
   JOIN dbo.LOC AS LOC WITH(NOLOCK) ON INS.LOC = LOC.LOC 
   
   IF EXISTS(SELECT 1 FROM @t_PickDetail WHERE OptimizeCop IS NOT NULL)  
   BEGIN
      SELECT @n_Continue = 4
   END
   
   IF EXISTS (SELECT 1 FROM @t_PickDetail WHERE ArchiveCop = '9')
   BEGIN
      SELECT @n_Continue = 4
   END

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      IF EXISTS(SELECT 1 FROM @t_PickDetail WHERE STATUS IN ('3','4','5','6','7','8','9'))
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63112   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert Trigger On PickDetail Failed. Status Must Equal to NORMAL (ntrPickDetailPreAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + TRIM(@c_errmsg) + ' ) '
      END  
   END

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      IF EXISTS(SELECT 1 FROM @t_PickDetail AS tpd
               JOIN dbo.ORDERS OD WITH (NOLOCK) ON OD.OrderKey = tpd.OrderKey  
               WHERE OD.Facility <> tpd.Facility)
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err = 63114   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(varchar(5),@n_err)+' Location Facility NOT Match with Order Facility (ntrPickDetailPreAdd)'
      END      
   END
            
   -- Check Lottables
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      DECLARE @c_OrderKey         NVARCHAR(10),
              @c_Line             NVARCHAR(5),
              @c_LOT              NVARCHAR(10),
              @c_Lottable01_order NVARCHAR(18),
              @c_Lottable02_order NVARCHAR(18),
              @c_Lottable03_order NVARCHAR(18),
              @c_Lottable01       NVARCHAR(18),
              @c_Lottable02       NVARCHAR(18),
              @c_Lottable03       NVARCHAR(18),
              @n_LLI_PQty         INT = 0 
            
      DECLARE CUR_StorerFacility CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT tpd.Storerkey, tpd.Facility
      FROM @t_PickDetail AS tpd   
      
      OPEN CUR_StorerFacility 
      
      FETCH FROM CUR_StorerFacility INTO @c_Storerkey, @c_Facility
      
      WHILE @@FETCH_STATUS = 0
      BEGIN
         SELECT @b_success = 0
         SET @c_AllowOverAllocations = '0'
         EXECUTE dbo.nspGetRight 
               @c_Facility = @c_facility, 
               @c_StorerKey = @c_Storerkey, 
               @c_sku = NULL, 
               @c_ConfigKey='ALLOWOVERALLOCATIONS', 
               @b_Success = @b_success    OUTPUT, 
               @c_authority = @c_AllowOverAllocations OUTPUT, 
               @n_err = @n_err OUTPUT, 
               @c_errmsg = @c_errmsg OUTPUT

         -- @c_ForceAllocLottable
         SELECT @b_success = 0
         SET @c_ForceAllocLottable = '0'
         EXECUTE dbo.nspGetRight 
               @c_Facility = @c_facility, 
               @c_StorerKey = @c_Storerkey, 
               @c_sku = NULL, 
               @c_ConfigKey='ForceAllocLottable', 
               @b_Success = @b_success    OUTPUT, 
               @c_authority = @c_ForceAllocLottable OUTPUT, 
               @n_err = @n_err OUTPUT, 
               @c_errmsg = @c_errmsg OUTPUT

         SELECT @c_UpdPickslipToPickDet = ''
         SELECT @b_success = 0
         EXECUTE dbo.nspGetRight 
               @c_Facility = @c_facility, 
               @c_StorerKey = @c_Storerkey, 
               @c_sku = NULL, 
               @c_ConfigKey='UpdPickslipToPickDet', 
               @b_Success = @b_success OUTPUT, 
               @c_authority = @c_UpdPickslipToPickDet OUTPUT, 
               @n_err = @n_err OUTPUT, 
               @c_errmsg = @c_errmsg OUTPUT
         
         IF @c_ForceAllocLottable = '1'
         BEGIN
            DECLARE CUR_PD_LOTTABLES CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT  PD.OrderKey, PD.OrderLineNumber, PD.LOT, PD.StorerKey
            FROM @t_PickDetail PD 
            WHERE PD.Storerkey = @c_Storerkey 
            AND PD.Facility = @c_Facility
      
            OPEN CUR_PD_LOTTABLES 
      
            FETCH FROM CUR_PD_LOTTABLES INTO @c_OrderKey, @c_Line, @c_LOT, @c_StorerKey 
      
            WHILE @@FETCH_STATUS = 0
            BEGIN
               SELECT @c_Lottable01_order = Lottable01,
                      @c_Lottable02_order = Lottable02,
                      @c_Lottable03_order = Lottable03
               FROM dbo.ORDERDETAIL WITH (NOLOCK)
               WHERE OrderKey        = @c_OrderKey
                 AND OrderLineNumber = @c_Line

               SELECT @c_Lottable01 = Lottable01,
                      @c_Lottable02 = Lottable02,
                      @c_Lottable03 = Lottable03
               FROM dbo.LOTATTRIBUTE (NOLOCK)
               WHERE lot = @c_LOT

               IF ( ISNULL(@c_Lottable01_order, '') <> '' AND @c_Lottable01_order <> @c_Lottable01) OR
                  ( ISNULL(@c_Lottable02_order, '') <> '' AND @c_Lottable02_order <> @c_Lottable02) OR
                  ( ISNULL(@c_Lottable03_order, '') <> '' AND @c_Lottable03_order <> @c_Lottable03)
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63113   
                  SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': LOT CHOSEN IS INVALID! Lot Attributes Does Not Match'
                  BREAK
               END
      
               FETCH FROM CUR_PD_LOTTABLES INTO @c_OrderKey, @c_Line, @c_LOT, @c_StorerKey
            END
      
            CLOSE CUR_PD_LOTTABLES
            DEALLOCATE CUR_PD_LOTTABLES            
         END -- @c_ForceAllocLottable = '1'   
         
         IF @n_Continue = 1 OR @n_Continue = 2
         BEGIN
            DECLARE CUR_SKUxLOC_Check CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT PD.Loc, PD.SKU, SUM(PD.Qty), LOC.LocationType
               FROM @t_PickDetail PD
               JOIN dbo.LOC AS LOC WITH(NOLOCK) ON PD.Loc = LOC.LOC
               WHERE PD.Facility = @c_Facility
               AND PD.Storerkey = @c_Storerkey               
               GROUP BY PD.Loc, PD.SKU, LOC.LocationType
 
            OPEN CUR_SKUxLOC_Check

            FETCH NEXT FROM CUR_SKUxLOC_Check INTO
                        @c_LOC, @c_SKU, @n_Qty, @c_LOC_LocationType   
                          
            WHILE @@FETCH_STATUS <> -1
            BEGIN
               SET @n_SL_Qty=0
               SET @n_SL_QtyAllocated = 0
               SET @n_SL_QtyPicked = 0

               SELECT @n_SL_QtyAllocated = QtyAllocated, 
                        @n_SL_QtyPicked = QtyPicked, 
                        @n_SL_Qty = Qty,
                        @c_LocationType = LocationType
               FROM dbo.SKUxLOC WITH (NOLOCK)
               WHERE StorerKey = @c_StorerKey
               AND SKU = @c_SKU
               AND LOC = @c_LOC

               IF @n_SL_Qty < (@n_SL_QtyAllocated + @n_SL_QtyPicked + @n_Qty)
               BEGIN
                  IF @c_AllowOverAllocations <> '1' AND (@c_LOC_LocationType NOT IN ('DYNPICKP', 'DYNPICKR','DYNPPICK'))  --NJOW01
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err = 63115   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                     SELECT @c_errmsg='NSQL'+CONVERT(varchar(5),@n_err)+'Over Allocation NOT Allow (ntrPickDetailPreAdd)'
                  END
                  ELSE IF @c_LocationType NOT IN ('PICK', 'CASE') AND (@c_LOC_LocationType NOT IN ('DYNPICKP', 'DYNPICKR','DYNPPICK'))  --NJOW01
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err = 63116   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                     SELECT @c_errmsg='NSQL'+CONVERT(varchar(5),@n_err)+'Over Allocation NOT Allow for Non Pick Location (ntrPickDetailPreAdd)'
                  END
               END
               
               -- Check LOTxLOCxID
               IF @c_AllowOverAllocations = '1' 
                  AND (@c_LocationType NOT IN ('PICK', 'CASE') 
                  AND (@c_LOC_LocationType NOT IN ('DYNPICKP', 'DYNPICKR','DYNPPICK')) )
               BEGIN                  
                  DECLARE CUR_LOTxLOCxID_Check CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT tpd.Lot, tpd.ID, SUM(tpd.Qty)  
                  FROM @t_PickDetail AS tpd
                  WHERE tpd.Storerkey = @c_Storerkey
                  AND tpd.Sku = @c_SKU
                  AND tpd.Loc = @c_LOC
                  GROUP BY tpd.Lot, tpd.ID                  
                  
                  OPEN CUR_LOTxLOCxID_Check 
                  
                  FETCH NEXT FROM CUR_LOTxLOCxID_Check INTO @c_Lot, @c_ID, @n_LLI_PQty 
                  
                  WHILE @@FETCH_STATUS = 0
                  BEGIN
                     IF EXISTS(SELECT 1 
                     FROM dbo.LOTxLOCxID AS LLI WITH (NOLOCK) 
                     WHERE LLI.Lot = @c_LOT
                        AND LLI.Loc = @c_LOC
                        AND LLI.Id = @c_ID
                        AND (LLI.QTYALLOCATED + @n_LLI_PQty + LLI.QTYPICKED) > LLI.QTY)                                
                     BEGIN
                        SELECT @n_Continue = 3 , @n_err = 63124
                        SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)
                           +': An Attempt Was Made To OverAllocate A Location That Is Not a Case Pick OR Piece Pick Location. (ntrPickDetailPreAdd)'
                        BREAK
                     END
                  
                     FETCH FROM CUR_LOTxLOCxID_Check INTO @c_Lot, @c_ID, @n_LLI_PQty
                  END
                  
                  CLOSE CUR_LOTxLOCxID_Check
                  DEALLOCATE CUR_LOTxLOCxID_Check                  
               END -- IF @c_AllowOverAllocations = '1'
               
               FETCH NEXT FROM CUR_SKUxLOC_Check INTO
                              @c_LOC, @c_SKU, @n_Qty, @c_LOC_LocationType
            END -- WHILE                       
            CLOSE CUR_SKUxLOC_Check
            DEALLOCATE CUR_SKUxLOC_Check                             
         END -- IF @n_Continue = 1 OR @n_Continue = 2               
                           
      
         IF @n_Continue IN (1,2) AND @c_UpdPickslipToPickDet = '1'      
         BEGIN
            DECLARE CUR_UpdatePickDet CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT OrderKey
            FROM @t_PickDetail           
            WHERE Storerkey = @c_Storerkey
            AND Facility = @c_Facility
         
            OPEN CUR_UpdatePickDet 
         
            FETCH FROM CUR_UpdatePickDet INTO @c_OrderKey
         
            WHILE @@FETCH_STATUS = 0
            BEGIN
               SET @c_Pickheaderkey = ''
             
               SELECT TOP 1 
               @c_Pickheaderkey = Pickheaderkey
               FROM dbo.PICKHEADER AS PH WITH(NOLOCK) 
               WHERE OrderKey = @c_OrderKey
               ORDER BY PH.Pickheaderkey 
             
               IF ISNULL(@c_Pickheaderkey ,'') = ''
               BEGIN
                  SELECT TOP 1 @c_Pickheaderkey  = PH.Pickheaderkey
                  FROM dbo.PICKHEADER PH (NOLOCK)
                  JOIN dbo.ORDERS O (NOLOCK) ON PH.ExternOrderKey = O.Loadkey 
                  WHERE (PH.OrderKey = '' OR PH.OrderKey IS NULL)
                  AND (O.Loadkey <> '' AND O.Loadkey IS NOT NULL) 
                  AND O.OrderKey = @c_OrderKey
                  ORDER BY PH.Pickheaderkey
               END
             
               IF ISNULL(@c_Pickheaderkey,'') <> ''
               BEGIN
                  UPDATE @t_PickDetail                  
                  SET Pickslipno = @c_Pickheaderkey 
                  WHERE OrderKey = @c_OrderKey        
               END
               FETCH FROM CUR_UpdatePickDet INTO @c_OrderKey
            END
         
            CLOSE CUR_UpdatePickDet
            DEALLOCATE CUR_UpdatePickDet
         END -- @c_UpdPickslipToPickDet = '1'
                   
         FETCH FROM CUR_StorerFacility INTO @c_Storerkey, @c_Facility
      END
      
      CLOSE CUR_StorerFacility
      DEALLOCATE CUR_StorerFacility
   END -- IF @n_Continue = 1 OR @n_Continue = 2
   
   /* #INCLUDE <TRPDA2.SQL> */
   IF @n_Continue = 3  -- Error Occured - Process AND Return
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
      EXECUTE dbo.nsp_logerror @n_err, @c_errmsg, 'ntrPickDetailPreAdd'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      INSERT INTO PICKDETAIL
      (
         PickDetailKey,   CaseID,            PickHeaderKey,
         OrderKey,        OrderLineNumber,   Lot,
         Storerkey,       Sku,               AltSku,
         UOM,             UOMQty,            Qty,
         QtyMoved,        [Status],          DropID,
         Loc,             ID,                PackKey,
         UpdateSource,    CartonGroup,       CartonType,
         ToLoc,           DoReplenish,       ReplenishZone,
         DoCartonize,     PickMethod,        WaveKey,
         EffectiveDate,   AddDate,           AddWho,
         EditDate,        EditWho,           TrafficCop,
         ArchiveCop,      OptimizeCop,       ShipFlag,
         PickSlipNo,      TaskDetailKey,     TaskManagerReasonKey,
         Notes,           MoveRefKey,        Channel_ID,
         SourceType
      )
      SELECT 
         PickDetailKey,   CaseID,            PickHeaderKey,
         OrderKey,        OrderLineNumber,   Lot,
         Storerkey,       Sku,               AltSku,
         UOM,             UOMQty,            Qty,
         QtyMoved,        [Status],          DropID,
         Loc,             ID,                PackKey,
         UpdateSource,    CartonGroup,       CartonType,
         ToLoc,           DoReplenish,       ReplenishZone,
         DoCartonize,     PickMethod,        WaveKey,
         EffectiveDate,   AddDate,           AddWho,
         EditDate,        EditWho,           TrafficCop,
         ArchiveCop,      OptimizeCop,       ShipFlag,
         PickSlipNo,      TaskDetailKey,     TaskManagerReasonKey,
         Notes,           MoveRefKey,        Channel_ID,
         SourceType      
      FROM @t_PickDetail AS tpd  
      
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
/* Trigger: ntrPickDetailPreUpdate                                      */
/* Creation Date: 18-May-2021                                           */
/* Copyright: LFL                                                       */
/* Written by: Shong                                                    */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Input Parameters: NONE                                               */
/*                                                                      */
/* Output Parameters: NONE                                              */
/*                                                                      */
/* Return Status: NONE                                                  */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records updated                                      */
/*                                                                      */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver   Purposes                                  */
/* 18-May-2021  SHONG   1.0   Created                                   */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrPickDetailPreUpdate]
ON  [dbo].[PICKDETAIL] 
INSTEAD OF UPDATE
AS
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
          @b_Success                      int
,         @n_err                int
,         @n_err2               int
,         @c_errmsg             NVARCHAR(250)
,         @n_Continue           int
,         @n_starttcnt          int
,         @c_preprocess         NVARCHAR(250)
,         @c_pstprocess         NVARCHAR(250)
,         @n_cnt                int
,         @n_PickDetailSysId    int
,         @c_facility           NVARCHAR(5)   -- Added for IDSV5 by June 26.Jun.02
,         @c_authority          NVARCHAR(10)   -- Added for IDSV5 by June 26.Jun.02  --NJOW03
,         @c_StorerKey          NVARCHAR(15)
,         @c_pckdtl_loc         NVARCHAR(10) -- added to remove the max function
,         @c_lottable01         NVARCHAR(18)
,         @c_lottable02         NVARCHAR(18)
,         @c_lottable03         NVARCHAR(18)
,         @d_lottable04         datetime
,         @d_lottable05         datetime
,         @c_lottable06         NVARCHAR(30)          --(CS01)
,         @c_lottable07         NVARCHAR(30)          --(CS01)
,         @c_lottable08         NVARCHAR(30)          --(CS01)
,         @c_lottable09         NVARCHAR(30)          --(CS01)
,         @c_lottable10         NVARCHAR(30)          --(CS01)
,         @c_lottable11         NVARCHAR(30)          --(CS01)
,         @c_lottable12         NVARCHAR(30)          --(CS01)
,         @d_lottable13         datetime              --(CS01)
,         @d_lottable14         datetime              --(CS01)
,         @d_lottable15         datetime              --(CS01)

DECLARE   @cPickDetailKey NVARCHAR(10)     -- (james02)
        , @cPD_DropID     NVARCHAR(18)     -- (james02)
        , @cTD_DropID     NVARCHAR(18)     -- (james02)
        , @cTaskDetailKey NVARCHAR(10)     -- (james02)
        , @c_PDKey        NVARCHAR(10)     -- SOS# 264916

         ,@c_AllocateByConsNewExpiry   NVARCHAR(10)
         ,@c_Consigneekey              NVARCHAR(15)
         ,@c_Sku                       NVARCHAR(20)

SET @c_AllocateByConsNewExpiry= ''
SET @c_Consigneekey           = ''
SET @c_Sku                    = ''

   DECLARE @t_Inserted TABLE (
	   [PickDetailKey] [nvarchar](18) NOT NULL,
	   [CaseID] [nvarchar](20) NOT NULL DEFAULT (' '),
	   [Pickheaderkey] [nvarchar](18) NOT NULL,
	   [OrderKey] [nvarchar](10) NOT NULL,
	   [OrderLineNumber] [nvarchar](5) NOT NULL,
	   [Lot] [nvarchar](10) NOT NULL,
	   [Storerkey] [nvarchar](15) NOT NULL,
	   [Sku] [nvarchar](20) NOT NULL,
	   [AltSku] [nvarchar](20) NOT NULL  DEFAULT (''),
	   [UOM] [nvarchar](10) NOT NULL  DEFAULT (''),
	   [UOMQty] [int] NOT NULL  DEFAULT (0),
	   [Qty] [int] NOT NULL  DEFAULT (0),
	   [QtyMoved] [int] NOT NULL DEFAULT (0),
	   [Status] [nvarchar](10) NOT NULL DEFAULT ('0'),
	   [DropID] [nvarchar](20) NOT NULL DEFAULT (''),
	   [Loc] [nvarchar](10) NOT NULL DEFAULT ('UNKNOWN'),
	   [ID] [nvarchar](18) NOT NULL DEFAULT (''),
	   [PackKey] [nvarchar](10) NULL DEFAULT (''),
	   [UpdateSource] [nvarchar](10) NULL  DEFAULT ('0'),
	   [CartonGroup] [nvarchar](10) NULL,
	   [CartonType] [nvarchar](10) NULL,
	   [ToLoc] [nvarchar](10) NULL DEFAULT (''),
	   [DoReplenish] [nvarchar](1) NULL DEFAULT ('N'),
	   [ReplenishZone] [nvarchar](10) NULL DEFAULT (''),
	   [DoCartonize] [nvarchar](1) NULL DEFAULT ('N'),
	   [PickMethod] [nvarchar](1) NOT NULL DEFAULT (''),
	   [WaveKey] [nvarchar](10) NOT NULL DEFAULT (''),
	   [EffectiveDate] [datetime] NOT NULL DEFAULT (getdate()),
	   [AddDate] [datetime] NOT NULL DEFAULT (getdate()),
	   [AddWho] [nvarchar](128) NULL,
	   [EditDate] [datetime] NOT NULL,
	   [EditWho] [nvarchar](128) NULL,
	   [TrafficCop] [nvarchar](1) NULL,
	   [ArchiveCop] [nvarchar](1) NULL,
	   [OptimizeCop] [nvarchar](1) NULL,
	   [ShipFlag] [nvarchar](1) NULL DEFAULT ('0'),
	   [PickSlipNo] [nvarchar](10) NULL DEFAULT (''),
	   [TaskDetailKey] [nvarchar](10) NULL  DEFAULT (''),
	   [TaskManagerReasonKey] [nvarchar](10) NULL  DEFAULT (''),
	   [Notes] [nvarchar](4000) NULL  DEFAULT (''),
	   [MoveRefKey] [nvarchar](10) NULL DEFAULT (''),
	   [Channel_ID] [bigint] NULL  DEFAULT (0),
	   [SourceType] [nvarchar](50) NULL DEFAULT (''),
      [Facility] [NVARCHAR](5) NULL DEFAULT('')
       ) 

   DECLARE @t_Deleted TABLE (
	   [PickDetailKey] [nvarchar](18) NOT NULL,
	   [CaseID] [nvarchar](20) NOT NULL DEFAULT (' '),
	   [Pickheaderkey] [nvarchar](18) NOT NULL,
	   [OrderKey] [nvarchar](10) NOT NULL,
	   [OrderLineNumber] [nvarchar](5) NOT NULL,
	   [Lot] [nvarchar](10) NOT NULL,
	   [Storerkey] [nvarchar](15) NOT NULL,
	   [Sku] [nvarchar](20) NOT NULL,
	   [AltSku] [nvarchar](20) NOT NULL  DEFAULT (''),
	   [UOM] [nvarchar](10) NOT NULL  DEFAULT (''),
	   [UOMQty] [int] NOT NULL  DEFAULT (0),
	   [Qty] [int] NOT NULL  DEFAULT (0),
	   [QtyMoved] [int] NOT NULL DEFAULT (0),
	   [Status] [nvarchar](10) NOT NULL DEFAULT ('0'),
	   [DropID] [nvarchar](20) NOT NULL DEFAULT (''),
	   [Loc] [nvarchar](10) NOT NULL DEFAULT ('UNKNOWN'),
	   [ID] [nvarchar](18) NOT NULL DEFAULT (''),
	   [PackKey] [nvarchar](10) NULL DEFAULT (''),
	   [UpdateSource] [nvarchar](10) NULL  DEFAULT ('0'),
	   [CartonGroup] [nvarchar](10) NULL,
	   [CartonType] [nvarchar](10) NULL,
	   [ToLoc] [nvarchar](10) NULL DEFAULT (''),
	   [DoReplenish] [nvarchar](1) NULL DEFAULT ('N'),
	   [ReplenishZone] [nvarchar](10) NULL DEFAULT (''),
	   [DoCartonize] [nvarchar](1) NULL DEFAULT ('N'),
	   [PickMethod] [nvarchar](1) NOT NULL DEFAULT (''),
	   [WaveKey] [nvarchar](10) NOT NULL DEFAULT (''),
	   [EffectiveDate] [datetime] NOT NULL DEFAULT (getdate()),
	   [AddDate] [datetime] NOT NULL DEFAULT (getdate()),
	   [AddWho] [nvarchar](128) NULL,
	   [EditDate] [datetime] NOT NULL,
	   [EditWho] [nvarchar](128) NULL,
	   [TrafficCop] [nvarchar](1) NULL,
	   [ArchiveCop] [nvarchar](1) NULL,
	   [OptimizeCop] [nvarchar](1) NULL,
	   [ShipFlag] [nvarchar](1) NULL DEFAULT ('0'),
	   [PickSlipNo] [nvarchar](10) NULL DEFAULT (''),
	   [TaskDetailKey] [nvarchar](10) NULL  DEFAULT (''),
	   [TaskManagerReasonKey] [nvarchar](10) NULL  DEFAULT (''),
	   [Notes] [nvarchar](4000) NULL  DEFAULT (''),
	   [MoveRefKey] [nvarchar](10) NULL DEFAULT (''),
	   [Channel_ID] [bigint] NULL  DEFAULT (0),
	   [SourceType] [nvarchar](50) NULL DEFAULT (''),
      [Facility] [NVARCHAR](5) NULL DEFAULT('')
       ) 

   INSERT INTO @t_Inserted
   (
      PickDetailKey, CaseID, Pickheaderkey,
      OrderKey, OrderLineNumber, Lot,
      Storerkey, Sku, AltSku,
      UOM, UOMQty, Qty, 
      QtyMoved, [Status], DropID,
      Loc, ID, PackKey,
      UpdateSource, CartonGroup, CartonType,
      ToLoc, DoReplenish, ReplenishZone,
      DoCartonize, PickMethod, WaveKey,
      EffectiveDate, AddDate, AddWho,
      EditDate, EditWho, TrafficCop,
      ArchiveCop, OptimizeCop, ShipFlag,
      PickSlipNo, TaskDetailKey, TaskManagerReasonKey,
      Notes, MoveRefKey, Channel_ID,
      SourceType, Facility
   )
   SELECT INS.PickDetailKey, INS.CaseID, INS.Pickheaderkey,
      INS.OrderKey, INS.OrderLineNumber, INS.Lot,
      INS.Storerkey, INS.Sku, INS.AltSku,
      INS.UOM, INS.UOMQty, INS.Qty,
      INS.QtyMoved, INS.[Status], INS.DropID,
      INS.Loc, INS.ID, INS.PackKey,
      INS.UpdateSource, INS.CartonGroup, INS.CartonType,
      INS.ToLoc, INS.DoReplenish, INS.ReplenishZone,
      INS.DoCartonize, INS.PickMethod, INS.WaveKey,
      INS.EffectiveDate, INS.AddDate, INS.AddWho,
      INS.EditDate, INS.EditWho, INS.TrafficCop,
      INS.ArchiveCop, INS.OptimizeCop, INS.ShipFlag,
      INS.PickSlipNo, INS.TaskDetailKey, INS.TaskManagerReasonKey,
      INS.Notes, INS.MoveRefKey, INS.Channel_ID,
      INS.SourceType, LOC.Facility
   FROM INSERTED AS INS 
   JOIN dbo.LOC AS LOC WITH(NOLOCK) ON INS.LOC = LOC.LOC 

   INSERT INTO @t_Inserted
   (
      PickDetailKey, CaseID, Pickheaderkey,
      OrderKey, OrderLineNumber, Lot,
      Storerkey, Sku, AltSku,
      UOM, UOMQty, Qty, 
      QtyMoved, [Status], DropID,
      Loc, ID, PackKey,
      UpdateSource, CartonGroup, CartonType,
      ToLoc, DoReplenish, ReplenishZone,
      DoCartonize, PickMethod, WaveKey,
      EffectiveDate, AddDate, AddWho,
      EditDate, EditWho, TrafficCop,
      ArchiveCop, OptimizeCop, ShipFlag,
      PickSlipNo, TaskDetailKey, TaskManagerReasonKey,
      Notes, MoveRefKey, Channel_ID,
      SourceType, Facility
   )
   SELECT DEL.PickDetailKey, DEL.CaseID, DEL.Pickheaderkey,
      DEL.OrderKey, DEL.OrderLineNumber, DEL.Lot,
      DEL.Storerkey, DEL.Sku, DEL.AltSku,
      DEL.UOM, DEL.UOMQty, DEL.Qty,
      DEL.QtyMoved, DEL.[Status], DEL.DropID,
      DEL.Loc, DEL.ID, DEL.PackKey,
      DEL.UpdateSource, DEL.CartonGroup, DEL.CartonType,
      DEL.ToLoc, DEL.DoReplenish, DEL.ReplenishZone,
      DEL.DoCartonize, DEL.PickMethod, DEL.WaveKey,
      DEL.EffectiveDate, DEL.AddDate, DEL.AddWho,
      DEL.EditDate, DEL.EditWho, DEL.TrafficCop,
      DEL.ArchiveCop, DEL.OptimizeCop, DEL.ShipFlag,
      DEL.PickSlipNo, DEL.TaskDetailKey, DEL.TaskManagerReasonKey,
      DEL.Notes, DEL.MoveRefKey, DEL.Channel_ID,
      DEL.SourceType, LOC.Facility
   FROM DELETED AS DEL 
   JOIN dbo.LOC AS LOC WITH(NOLOCK) ON DEL.LOC = LOC.LOC 
                    
   SELECT @n_Continue=1, @n_starttcnt=@@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_Continue = 4
      GOTO QUIT
   END

   IF (@n_Continue = 1 OR @n_Continue = 2) AND UPDATE(LOC)  
   BEGIN
      DECLARE @c_HoldLoc NVARCHAR(10), @c_PD_StorerKey NVARCHAR(15)
      SELECT @c_PDKey = '', @c_HoldLoc = '', @c_PD_StorerKey = ''

      SELECT @c_PDKey = INSERTED.PickDetailKey
           , @c_HoldLoc = INSERTED.Loc
           , @c_PD_StorerKey = INSERTED.StorerKey
      FROM INSERTED
      JOIN PICKDETAIL WITH (NOLOCK) ON (PICKDETAIL.PickDetailKey = INSERTED.PickDetailKey)

      IF EXISTS ( SELECT 1 FROM CodeLkUp WITH (NOLOCK)
                  WHERE ListName = 'HOLDLOC'
                  AND Code = ISNULL(RTRIM(@c_HoldLoc),'')
                  AND StorerKey = ISNULL(RTRIM(@c_PD_StorerKey),'') )
      BEGIN
         IF EXISTS (SELECT 1 FROM LOC WITH (NOLOCK) WHERE Loc = ISNULL(RTRIM(@c_HoldLoc),'')
                    AND LocationFlag = 'HOLD')
         BEGIN
            SELECT @n_Continue = 3 , @n_err = 61601
            SELECT @c_ErrMsg = 'NSQL'+CONVERT(Nchar(5),@n_err)+': Update denied. Not allow change location to ' + ISNULL(RTRIM(@c_HoldLoc),'') + '. PickDetailKey: ' + ISNULL(RTRIM(@c_PDKey),'') + ' (ntrPickDetailPreUpdate)'
            GOTO QUIT
         END
      END
   END


IF UPDATE(TrafficCop)
BEGIN
   SELECT @n_Continue = 4
   GOTO QUIT
END

-- tlting01
IF (@n_Continue=1 or @n_Continue=2)
BEGIN
   IF NOT UPDATE(ShipFlag) AND 
      NOT UPDATE(Status) AND 
      EXISTS(SELECT 1 FROM INSERTED WHERE ShipFlag = 'Y' OR [Status] = '9')   
   BEGIN
      SET @c_PDKey = '' -- SOS# 264916
      
      SELECT TOP 1 
           @c_PDKey = INSERTED.PickDetailKey
      FROM INSERTED
            
      SELECT @n_Continue = 3 , @n_err = 61603
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update denied. Item Already Shipped. PickDetailKey: ' + ISNULL(RTRIM(@c_PDKey),'') + ' (ntrPickDetailPreUpdate)'
      GOTO QUIT
   END
END

--IN00071638
IF @n_continue = 1 OR @n_continue = 2
BEGIN
   IF UPDATE(LOT)
   BEGIN
      IF EXISTS(
         SELECT 1
         FROM INSERTED P WITH (NOLOCK)
         JOIN LOTATTRIBUTE AS LA (NOLOCK) ON LA.Lot = p.Lot
         JOIN StorerConfig SC WITH (NOLOCK) ON SC.StorerKey = P.StorerKey
                                     AND ConfigKey = 'ForceAllocLottable'
                                     AND sValue = '1'
         JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.OrderKey = p.OrderKey AND OD.OrderLineNumber = p.OrderLineNumber
         WHERE ((OD.Lottable01 <> LA.Lottable01 AND (OD.Lottable01 IS NOT NULL AND OD.Lottable01 <> '')) OR
                (OD.Lottable02 <> LA.Lottable02 AND (OD.Lottable02 IS NOT NULL AND OD.Lottable02 <> '')) OR
                (OD.Lottable03 <> LA.Lottable03 AND (OD.Lottable03 IS NOT NULL AND OD.Lottable03 <> '')))
         )
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61604   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': LOT CHOSEN IS INVALID! Lot Attributes Does Not Match'
      END
   END
END

IF (@n_Continue=1 or @n_Continue=2)
   AND UPDATE(Status)
   AND EXISTS(SELECT 1 FROM INSERTED WHERE STATUS='5')
BEGIN
  IF EXISTS(SELECT 1
             FROM   INSERTED
             JOIN   DELETED ON INSERTED.PickDetailKey = DELETED.PickDetailKey
             JOIN   STORERCONFIG (NOLOCK) ON INSERTED.StorerKey = STORERCONFIG.StorerKey
                    AND STORERCONFIG.ConfigKey = 'PKDetEcomDropIdRequired' AND STORERCONFIG.SValue='1'
             JOIN   TASKDETAIL WITH (NOLOCK) ON TASKDETAIL.TaskDetailKey = INSERTED.TaskDetailKey
                    AND TASKDETAIL.TaskType in('PK', 'SPK')
                    AND TASKDETAIL.pickmethod in ('DOUBLES', 'SINGLES', 'MULTIS', 'PIECE') --SOS223517 END
             WHERE INSERTED.Status = '5' AND DELETED.STATUS < '5'
             AND   ( ISNULL(RTRIM(INSERTED.DropID),'')  = '' OR
                     ISNULL(RTRIM(INSERTED.DropID),'') <> TASKDETAIL.DropID ) )
   BEGIN
      -- for debug purpose (james01)
      SET @cPickDetailKey = ''
      SET @cPD_DropID = ''
      SET @cTD_DropID = ''
      SELECT
         @cPickDetailKey = INSERTED.PickDetailKey,
         @cPD_DropID = INSERTED.DropID,
         @cTD_DropID = TASKDETAIL.DropID
      FROM INSERTED
      JOIN TASKDETAIL WITH (NOLOCK) ON TASKDETAIL.TaskDetailKey = INSERTED.TaskDetailKey
      WHERE INSERTED.Status = '5'

      SELECT @n_Continue = 3 , @n_err = 61605
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': DropID for Orders Cannot be BLANK/Not Match. (ntrPickDetailPreUpdate) PDKEY: ' + @cPickDetailKey + ' PD.DID: ' + @cPD_DropID + ' TD.DID: ' + @cTD_DropID
      GOTO QUIT
   END

END

   --(Wan01) - START
   SELECT TOP 1
         @c_Storerkey = RTRIM(Storerkey)
   FROM INSERTED
   
-- SOS 14880: prevent updates of pick confirmed detail if PICK-TRF is on
IF (@n_Continue=1 or @n_Continue=2) and UPDATE(qty)
BEGIN
   if EXISTS (SELECT 1
              FROM  DELETED d JOIN StorerConfig s (NOLOCK)
              ON    d.StorerKey = s.StorerKey
              WHERE s.Configkey = 'PICK-TRF'
              AND   s.sValue = '1'
              AND   d.Status = '5') AND
      EXISTS (SELECT 1
              FROM  INSERTED i JOIN StorerConfig s (NOLOCK)
              ON    i.StorerKey = s.StorerKey
              WHERE s.Configkey = 'PICK-TRF'
              AND   s.sValue = '1'
              AND   i.qty = 0 )
   BEGIN
      SELECT @n_Continue = 3 , @n_err = 61608
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update on QTY not Allowed After Pick Confirmed - Update Failed. (ntrPickDetailPreUpdate)'
      GOTO QUIT
   END

   --(Wan02) - START
   IF NOT EXISTS ( SELECT 1
                  FROM STORERCONFIG WITH (NOLOCK)
                  JOIN ORDERS WITH (NOLOCK) ON (STORERCONFIG.Storerkey = ORDERS.Storerkey)
                                            AND(STORERCONFIG.Facility = ORDERS.Facility OR STORERCONFIG.facility = '')
                  JOIN INSERTED ON (ORDERS.Orderkey = INSERTED.Orderkey)
                  WHERE STORERCONFIG.Configkey = 'ValidateSOStatus_SP'
                  AND   STORERCONFIG.SValue = 'ispVSOST01' )
   BEGIN
      -- james01
      IF EXISTS (SELECT 1 FROM INSERTED
                 JOIN Orders WITH (NOLOCK) ON INSERTED.OrderKey = Orders.OrderKey
                 WHERE (Orders.SOSTATUS = 'CANC' OR Orders.Status = 'CANC')
                 AND INSERTED.QTY > 0)
      BEGIN
         SELECT @n_Continue = 3 , @n_err = 61609
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update on QTY not Allowed After Orders is Cancelled - Update Failed. (ntrPickDetailPreUpdate)'
         GOTO QUIT
      END
   END
   --(Wan02) - END
END

IF (@n_Continue=1 or @n_Continue=2) and update(Status)
BEGIN
   if EXISTS (SELECT 1
              FROM  DELETED d JOIN StorerConfig s (NOLOCK)
              ON    d.StorerKey = s.StorerKey
              WHERE s.Configkey = 'PICK-TRF'
              AND   s.sValue = '1'
              AND   d.Status = '5') and
      EXISTS (SELECT 1
              FROM  INSERTED i JOIN StorerConfig s (NOLOCK)
              ON    i.StorerKey = s.StorerKey
              WHERE s.Configkey = 'PICK-TRF'
              AND   s.sValue = '1'
              AND   i.Status < '5')
   BEGIN
      SELECT @n_Continue = 3 , @n_err = 61610
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update on Status not Allowed After Pick Confirmed - Update Failed. (ntrPickDetailPreUpdate)'
      GOTO QUIT
   END

   --(Wan02) - START
   IF NOT EXISTS ( SELECT 1
                  FROM STORERCONFIG WITH (NOLOCK)
                  JOIN ORDERS WITH (NOLOCK) ON (STORERCONFIG.Storerkey = ORDERS.Storerkey)
                                            AND(STORERCONFIG.Facility = ORDERS.Facility OR ISNULL(RTRIM(STORERCONFIG.Facility),'') = '')
                  JOIN INSERTED ON (ORDERS.Orderkey = INSERTED.Orderkey)
                  WHERE STORERCONFIG.Configkey = 'ValidateSOStatus_SP'
                  AND   STORERCONFIG.SValue = 'ispVSOST01' )
   BEGIN
      -- james01
      IF EXISTS (SELECT 1 FROM INSERTED
                 JOIN Orders WITH (NOLOCK) ON INSERTED.OrderKey = Orders.OrderKey
                 WHERE (Orders.SOSTATUS = 'CANC' OR Orders.Status = 'CANC')
                 AND INSERTED.Status <> '4')
      BEGIN
         SELECT @n_Continue = 3 , @n_err = 61611
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update on Status not Allowed After Orders is Cancelled - Update Failed. (ntrPickDetailPreUpdate)'
         GOTO QUIT
      END
   END
   --(Wan02) - END

   -- Added By Shong on 22nd Nov 2006
   -- If BackendShip Turn ON
   -- Not allow to update Status to 9 if the ShipFlag <> 'Y'
   -- To Prevent user do Mass Ship FROM Front End
   -- Might not accurate if bulk update pickdetail more then 1 storer, don't think it will happen in frontend
   -- reason not check is due to performance issues

   SELECT TOP 1 @c_StorerKey = StorerKey    FROM   INSERTED

   IF NOT EXISTS(SELECT 1 FROM StorerConfig (NOLOCK) WHERE StorerKey = @c_StorerKey
                 AND Configkey = 'REALTIMESHIP' AND sValue = 1)
   BEGIN
      IF EXISTS(SELECT 1 FROM INSERTED WHERE Status = '9' and ShipFlag <> 'Y' and StorerKey = @c_StorerKey)
      BEGIN
         SELECT @n_Continue = 3 , @n_err = 61612
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': SHIP not Allowed without MBOL - Update Failed. (ntrPickDetailPreUpdate)'
         GOTO QUIT
      END
   END
END

/* #INCLUDE <TRPDU1.SQL> */
IF @n_Continue = 1 or @n_Continue = 2
BEGIN
   DECLARE @c_AllowOverAllocations NVARCHAR(1)

   SELECT TOP 1 @c_pckdtl_loc = LOC,
          @c_StorerKey = StorerKey
   FROM  INSERTED

   SELECT TOP 1 @c_facility = FACILITY
   FROM  LOC (NOLOCK)
   WHERE LOC = @c_pckdtl_loc

   SELECT @b_success = 0
   Execute nspGetRight @c_facility, -- facility
         @c_StorerKey,  -- StorerKey
         null, -- Sku
         'ALLOWOVERALLOCATIONS', -- Configkey
         @b_success     output,
         @c_AllowOverAllocations output,
         @n_err         output,
         @c_errmsg      output

   IF @b_success <> 1
   BEGIN
     SELECT @n_Continue = 3, @c_errmsg = 'ntrPickDetailPreUpdate' + rtrim(@c_errmsg)
   END
END

IF @n_Continue = 1 or @n_Continue = 2
BEGIN
   DECLARE @c_catchweight NVARCHAR(1)

   SELECT @c_catchweight = IsNull(NSQLValue, '0')
   FROM NSQLCONFIG (NOLOCK)
   WHERE Configkey = 'CATCHWEIGHT'
END

IF @b_debug = 1
BEGIN
   SELECT 'Reject changes if the line item is shipped (Status = ''9'')'
   SELECT 'Reject changes if the sourcetype is not ''0'' or ''1'''
END
IF @n_Continue = 1 or @n_Continue = 2
BEGIN
   IF EXISTS (SELECT 1 FROM INSERTED where updatesource NOT IN ('0','1') )
   BEGIN
      SELECT @n_Continue = 3 , @n_err = 61613
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update source is invalid. (ntrPickDetailPreUpdate)'
      GOTO QUIT
   END
END
-- customized for HK, once pickdetail is Pick in Progress ('3') should not be DELETED. Coz interface has been done
IF @n_Continue=1 or @n_Continue=2
BEGIN
   SELECT @b_success = 0
   Execute nspGetRight null,  -- facility
             @c_StorerKey,    -- StorerKey
             null,            -- Sku
             'OWITF',      -- Configkey
             @b_success    output,
             @c_authority  output,
             @n_err        output,
             @c_errmsg     output
   IF @b_success <> 1
   BEGIN
      SELECT @n_Continue = 3, @c_errmsg = 'ntrPickDetailPreUpdate' + rtrim(@c_errmsg)
      GOTO QUIT
   END
   ELSE IF @c_authority = '1'
   BEGIN
      IF EXISTS (SELECT 1 FROM INSERTED, DELETED
                 WHERE INSERTED.PickDetailKey = DELETED.PickDetailKey
                 AND DELETED.Status  > '2'
                 AND INSERTED.Status < '3')
      BEGIN
         SELECT @n_Continue = 3 , @n_err = 61614
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Picking in process, Changes to items not allowed. (ntrPickDetailPreUpdate)'
         GOTO QUIT
      END
   END
END

QUIT:

IF @n_continue=3
BEGIN
   DECLARE @n_IsRDT INT
   EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT

   IF @n_IsRDT = 1
   BEGIN
      -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
      -- Instead we commit AND raise an error back to parent, let the parent decide

      -- Commit until the level we BEGIN with
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
   EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPickDetailPreUpdate'
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
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrPickDetailUpdate                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Input Parameters: NONE                                               */
/*                                                                      */
/* Output Parameters: NONE                                              */
/*                                                                      */
/* Return Status: NONE                                                  */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records updated                                      */
/*                                                                      */
/* PVCS Version: 3.9                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver   Purposes                                  */
/* 13-Apr-2006  SHONG   1.0   Performance Tuning (SHONG_13042006)       */
/* 22-Nov-2006  SHONG   1.0   Not allow ship without MBOL if Backend    */
/*                            Ship turn on.                             */
/* 22-Jul-2008  SHONG   1.0   No update on QtyPickInprogress            */
/* 16-Sep-2008  SHONG   1.0   New Release                               */
/* 17-Mar-2009  TLTING  1.1   Change user_name() to SUSER_SNAME()       */
/* 28-May-2009  SHONG   1.2   Bug Fixing for Status 4                   */
/* 07-Apr-2009  ACM     1.3   SOS#131697 Pass 5 Lottable To ITRN        */
/* 08-Oct-2010  Shong   1.4   Add New StorerConfigKey Control (Shong01) */
/*                            DropId for ECOM <> Blank and Match to     */
/*                            TaskDetail.DropId                         */
/* 10-Nov-2010  TLTING  1.5   Avoid Update after ship (tlting01)        */
/*                            Do not use variable table                 */
/* 02-Dec-2010  James   1.5   Not allow to change Pickdetail status/qty */
/*                            if orders status/sostatus is CANC(james01)*/
/* 28-Dec-2010  SHONG   1.5   Set LOTxLOCxID.QtyExpected = 0 WHEN Loc   */
/*                            Type <> PICK/CASE (SHONG01)               */
/* 27-Jan-2011  TLTING  1.6   Set LOTxLOCxID.QtyExpected = 0 WHEN Loc   */
/*                            Type <> DYNPICKP/DYNPICKR (TLTING01)      */
/* 24-Jun-2011  NJOW01  1.7   Allow over allocation for dynamic         */
/*                            permenent loc                             */
/* 16-Aug-2011  James   1.7   SOS223517 - To have dropid in pickdetail  */
/*                            if status picked (james02)                */
/* 02-Dec-2011  MCTang  1.7   Add WAVEUPDLOG for WCS-WAVE Status Change */
/*                            Export(MC01)                           */
/* 16-Jan-2012  TLTING  1.7   SOS# 233330 - Convert error msg to RDT    */
/*                            compatible (Msg Range: 61601 - 61650)     */
/* 18-Apr-2012  Leong   1.8   SOS# 241911 - Additional DropId checking  */
/* 22-May-2012  TLTING  1.8   DM Integrity issue - Update editdate for  */
/*                            status < '9'(TLTING01)                    */
/* 08-Jun-2012  TLTING  1.8   Deadlock tune - add nolock Orders         */
/* 30-Oct-2012  NJOW02  1.9   259289-StorerConfig to populate ID to     */
/*                            DropID in PickDetail SC='IDToDropID'      */
/* 18-JUL-2012  YTWan   2.0   SOS#248737:06700-Diversey Hygience TH_CR_ */
/*                            Allocation Strategy.(Wan01)               */
/* 17-Dec-2012  Leong   2.0   SOS# 264916 - Include pickdetailkey when  */
/*                                          item already shipped.       */
/* 10-May-2013  Leong         SOS#278118 - Prompt error when user update*/
/*                                         Loc = 'WS01'.                */
/*                                       - (Temp. for IDSUK only)       */
/* 15-MAY-2013  YTWan   2.1   SOS#276826-VFDC SO Cancel.(Wan02)         */
/* 28-Oct-2013  TLTING  2.2   Review Editdate column update             */
/* 25-Nov-2013  CSCHONG 2.3   Add Lottable06-15 (CS01)                  */
/* 26-Jan-2015  NJOW03  2.4   331723-Auto-Move Short Pick               */
/* 15-Apr-2015  TLTING  2.5   SQL2012 Bug fix                           */
/* 19-Aug-2015  SHONG01 2.6   Added Backend Pick Confirm                */
/* 19-Aug-2015  James   2.7   Bug fix (james02)                         */
/* 29-Aug-2015  NJOW04  2.8   315021-Call pickdetail update custom sp   */
/* 21-Jun-2016  SHONG   2.9   IN00071638 - Added ConfigKey              */
/*                            "ForceAllocLottable"                      */
/* 20-Sep-2016  TLTING  3.0   Change SET ROWCOUNT 1 to TOP 1            */
/* 15-Feb-2017  TLTING  3.1   Add Continue 3 skip                       */
/* 15-Feb-2017  Ung     3.2   RDT compatible errno                      */
/* 10-Jan-2017  NJOW05  3.3   WMS-684 AllocateByConsNewExpiry include Y */
/*                            value at susr1 and change to looping      */
/* 16-Oct-2017  SHONG   3.4   Performance Tuning (SWT01)                */
/* 06-Feb-2018  SWT02   3.5   Added Channel Management Logic            */
/* 16-May-2018  TLTING02 3.6  Check no over allocate when               */
/*                            AllowOverAllocations turn off             */
/* 28-Sep-2018  TLTIN   3.6   remove #tmp , remmove update row lock     */
/* 16-May-2019  CheeMun 3.7   INC0683213 - Cater for ShowPicks update   */
/*                            status syn ChannelInv.QtyAllocated        */ 
/* 23-JUL-2019  Wan03   3.8   ChannelInventoryMgmt use fnc_SelectGetRight*/
/* 04-MAR-2021  Wan04   3.9   WMS-16390 - [CN] NIKE_O2_Ecompacking_Check*/
/*                            _Pickdetail_status_CR                     */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrPickDetailUpdate]
ON  [dbo].[PICKDETAIL]
FOR UPDATE
AS
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
@b_Success                      int
,         @n_err                int
,         @n_err2               int
,         @c_errmsg             NVARCHAR(250)
,         @n_Continue           int
,         @n_starttcnt          int
,         @c_preprocess         NVARCHAR(250)
,         @c_pstprocess         NVARCHAR(250)
,         @n_cnt                int
,         @n_PickDetailSysId    int
,         @c_facility           NVARCHAR(5)   -- Added for IDSV5 by June 26.Jun.02
,         @c_authority          NVARCHAR(10)   -- Added for IDSV5 by June 26.Jun.02  --NJOW03
,         @c_StorerKey          NVARCHAR(15)
,         @c_pckdtl_loc         NVARCHAR(10) -- added to remove the max function
,         @c_lottable01         NVARCHAR(18)
,         @c_lottable02         NVARCHAR(18)
,         @c_lottable03         NVARCHAR(18)
,         @d_lottable04         datetime
,         @d_lottable05         datetime
,         @c_lottable06         NVARCHAR(30)          --(CS01)
,         @c_lottable07         NVARCHAR(30)          --(CS01)
,         @c_lottable08         NVARCHAR(30)          --(CS01)
,         @c_lottable09         NVARCHAR(30)          --(CS01)
,         @c_lottable10         NVARCHAR(30)          --(CS01)
,         @c_lottable11         NVARCHAR(30)          --(CS01)
,         @c_lottable12         NVARCHAR(30)          --(CS01)
,         @d_lottable13         datetime              --(CS01)
,         @d_lottable14         datetime              --(CS01)
,         @d_lottable15         datetime              --(CS01)

DECLARE   @cPickDetailKey NVARCHAR(10)     -- (james02)
        , @cPD_DropID     NVARCHAR(18)     -- (james02)
        , @cTD_DropID     NVARCHAR(18)     -- (james02)
        , @cTaskDetailKey NVARCHAR(10)     -- (james02)
        , @c_PDKey        NVARCHAR(10)     -- SOS# 264916
        
        , @c_EPACK4PickedOrder         NVARCHAR(30)   --(Wan04)

--(Wan01) - START
         ,@c_AllocateByConsNewExpiry   NVARCHAR(10)
         ,@c_Consigneekey              NVARCHAR(15)
         ,@c_Sku                       NVARCHAR(20)

SET @c_AllocateByConsNewExpiry= ''
SET @c_Consigneekey           = ''
SET @c_Sku                    = ''

--(Wan01) - END
SELECT @n_Continue=1, @n_starttcnt=@@TRANCOUNT

IF UPDATE(ArchiveCop)
BEGIN
   SELECT @n_Continue = 4
   GOTO QUIT
END

IF (@n_Continue = 1 OR @n_Continue = 2) AND UPDATE(LOC) -- SOS#278118
BEGIN
   DECLARE @c_HoldLoc NVARCHAR(10), @c_PD_StorerKey NVARCHAR(15)
   SELECT @c_PDKey = '', @c_HoldLoc = '', @c_PD_StorerKey = ''

   SELECT @c_PDKey = INSERTED.PickDetailKey
        , @c_HoldLoc = INSERTED.Loc
        , @c_PD_StorerKey = INSERTED.StorerKey
   FROM INSERTED
   JOIN PICKDETAIL WITH (NOLOCK) ON (PICKDETAIL.PickDetailKey = INSERTED.PickDetailKey)

   IF EXISTS ( SELECT 1 FROM CodeLkUp WITH (NOLOCK)
               WHERE ListName = 'HOLDLOC'
               AND Code = ISNULL(RTRIM(@c_HoldLoc),'')
               AND StorerKey = ISNULL(RTRIM(@c_PD_StorerKey),'') )
   BEGIN
      IF EXISTS (SELECT 1 FROM LOC WITH (NOLOCK) WHERE Loc = ISNULL(RTRIM(@c_HoldLoc),'')
                 AND LocationFlag = 'HOLD')
      BEGIN
         SELECT @n_Continue = 3 , @n_err = 61601
         SELECT @c_ErrMsg = 'NSQL'+CONVERT(Nchar(5),@n_err)+': Update denied. Not allow change location to ' + ISNULL(RTRIM(@c_HoldLoc),'') + '. PickDetailKey: ' + ISNULL(RTRIM(@c_PDKey),'') + ' (ntrPickDetailUpdate)'
         GOTO QUIT
      END
   END
END

-- tlting01
IF EXISTS ( SELECT 1 FROM INSERTED, DELETED
            WHERE INSERTED.PickDetailKey = DELETED.PickDetailKey
            AND ( INSERTED.[status] < '9' OR DELETED.[status] < '9' )  )
      AND ( @n_continue = 1 OR @n_continue = 2 )
      AND NOT UPDATE(EditDate)
BEGIN
   UPDATE PICKDETAIL  
   SET EditDate = GETDATE(), EditWho=SUSER_SNAME(),
         TrafficCop = NULL
   FROM PICKDETAIL,INSERTED
   WHERE PICKDETAIL.PickDetailKey=INSERTED.PickDetailKey
   AND PICKDETAIL.[status] < '9'
   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   IF @n_err <> 0
   BEGIN
      SELECT @n_continue = 3
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61602
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On PickDetail. (ntrPickDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '
   END
END

IF UPDATE(TrafficCop)
BEGIN
   SELECT @n_Continue = 4
   GOTO QUIT
END

--NJOW04
IF @n_continue = 1 or @n_continue = 2
BEGIN
   IF EXISTS (SELECT 1 FROM INSERTED i
              JOIN storerconfig s WITH (NOLOCK) ON  i.storerkey = s.storerkey
              JOIN sys.objects sys with (NOLOCK) ON sys.type = 'P' AND sys.name = s.Svalue
              WHERE  s.configkey = 'PickDetailTrigger_SP')
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

      EXECUTE dbo.isp_PickDetailTrigger_Wrapper
               'UPDATE' --@c_Action
              , @b_Success  OUTPUT
              , @n_Err      OUTPUT
              , @c_ErrMsg   OUTPUT

      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
               ,@c_errmsg = 'ntrPickDetailUpdate' + RTrim(@c_errmsg)
      END

      IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
         DROP TABLE #INSERTED

      IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
         DROP TABLE #DELETED
   END
END

-- SHONG01
IF UPDATE(ShipFlag) AND (@n_Continue=1 or @n_Continue=2)
BEGIN
   DECLARE @c_OrderKey NVARCHAR(10)

   IF EXISTS(SELECT 1 FROM INSERTED WHERE ShipFlag='P' AND STATUS < '4')
   BEGIN
      DECLARE CUR_ORDERS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT ORDERKEY FROM INSERTED
      WHERE  ShipFlag='P' AND STATUS < '4'

      OPEN CUR_ORDERS
      FETCH NEXT FROM CUR_ORDERS INTO @c_OrderKey
      WHILE @@FETCH_STATUS <> -1
      BEGIN
         EXEC isp_ConfirmPick @c_OrderKey=@c_OrderKey, @c_LoadKey = '',
              @b_Success=@b_Success OUTPUT, @n_err=@n_err OUTPUT, @c_errmsg = @c_errmsg OUTPUT

         FETCH NEXT FROM CUR_ORDERS INTO @c_OrderKey
      END
      CLOSE CUR_ORDERS
      DEALLOCATE CUR_ORDERS
   END
END
-- tlting01
IF (@n_Continue=1 or @n_Continue=2)
BEGIN
   -- (SWT01) Performance Tuning 
   --IF NOT EXISTS ( SELECT 1 -- not changing ShipFlag
   --                 FROM  INSERTED, DELETED
   --                 WHERE INSERTED.PICKDETAILKEY = DELETED.PICKDETAILKEY
   --                 AND   INSERTED.ShipFlag <> DELETED.ShipFlag )
   --                 AND   NOT EXISTS ( SELECT 1  -- not changing [Status]
   --                                    FROM INSERTED, DELETED
   --                                    WHERE INSERTED.PICKDETAILKEY = DELETED.PICKDETAILKEY
   --                                    AND INSERTED.[Status] <> DELETED.[Status] )
   --                                    AND EXISTS( SELECT 1 -- user shipped
   --                                                FROM INSERTED
   --                                                WHERE ShipFlag = 'Y' OR [Status] = '9'  )
   IF NOT UPDATE(ShipFlag) AND 
      NOT UPDATE(Status) AND 
      EXISTS(SELECT 1 FROM INSERTED WHERE ShipFlag = 'Y' OR [Status] = '9')   
   BEGIN
      SET @c_PDKey = '' -- SOS# 264916
      
      SELECT TOP 1 
           @c_PDKey = INSERTED.PickDetailKey
      FROM INSERTED
            
      SELECT @n_Continue = 3 , @n_err = 61603
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update denied. Item Already Shipped. PickDetailKey: ' + ISNULL(RTRIM(@c_PDKey),'') + ' (ntrPickDetailUpdate)'
      GOTO QUIT
   END
END

--IN00071638
IF @n_continue = 1 OR @n_continue = 2
BEGIN
   IF UPDATE(LOT)
   BEGIN
      IF EXISTS(
         SELECT 1
         FROM INSERTED P WITH (NOLOCK)
         JOIN LOTATTRIBUTE AS LA (NOLOCK) ON LA.Lot = p.Lot
         JOIN StorerConfig SC WITH (NOLOCK) ON SC.StorerKey = P.StorerKey
                                     AND ConfigKey = 'ForceAllocLottable'
                                     AND sValue = '1'
         JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.OrderKey = p.OrderKey AND OD.OrderLineNumber = p.OrderLineNumber
         WHERE ((OD.Lottable01 <> LA.Lottable01 AND (OD.Lottable01 IS NOT NULL AND OD.Lottable01 <> '')) OR
                (OD.Lottable02 <> LA.Lottable02 AND (OD.Lottable02 IS NOT NULL AND OD.Lottable02 <> '')) OR
                (OD.Lottable03 <> LA.Lottable03 AND (OD.Lottable03 IS NOT NULL AND OD.Lottable03 <> '')))
         )
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61604   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': LOT CHOSEN IS INVALID! Lot Attributes Does Not Match'
      END
   END
END

-- (Shong01)
IF (@n_Continue=1 or @n_Continue=2)
   AND UPDATE(Status)
   AND EXISTS(SELECT 1 FROM INSERTED WHERE STATUS='5')
BEGIN
  IF EXISTS(SELECT 1
             FROM   INSERTED
             JOIN   DELETED ON INSERTED.PickDetailKey = DELETED.PickDetailKey
             JOIN   STORERCONFIG (NOLOCK) ON INSERTED.StorerKey = STORERCONFIG.StorerKey
                    AND STORERCONFIG.ConfigKey = 'PKDetEcomDropIdRequired' AND STORERCONFIG.SValue='1'
             JOIN   TASKDETAIL WITH (NOLOCK) ON TASKDETAIL.TaskDetailKey = INSERTED.TaskDetailKey
                   /* AND TASKDETAIL.TaskType='PK'  --SOS223517 Start
                    AND TASKDETAIL.PickMethod IN ('DOUBLES','SINGLES','MULTIS') */
                    AND TASKDETAIL.TaskType in('PK', 'SPK')
                    AND TASKDETAIL.pickmethod in ('DOUBLES', 'SINGLES', 'MULTIS', 'PIECE') --SOS223517 END
             WHERE INSERTED.Status = '5' AND DELETED.STATUS < '5'
             AND   ( ISNULL(RTRIM(INSERTED.DropID),'')  = '' OR
                     ISNULL(RTRIM(INSERTED.DropID),'') <> TASKDETAIL.DropID ) )
             -- Comment by james02
             -- AND ( ISNULL(RTRIM(@cPD_DropID),'') <> ISNULL(RTRIM(@cTD_DropID),'') OR ISNULL(RTRIM(@cPD_DropID),'') = '' ) -- SOS# 241911
   BEGIN
      -- for debug purpose (james01)
      SET @cPickDetailKey = ''
      SET @cPD_DropID = ''
      SET @cTD_DropID = ''
      SELECT
         @cPickDetailKey = INSERTED.PickDetailKey,
         @cPD_DropID = INSERTED.DropID,
         @cTD_DropID = TASKDETAIL.DropID
      FROM INSERTED
      JOIN TASKDETAIL WITH (NOLOCK) ON TASKDETAIL.TaskDetailKey = INSERTED.TaskDetailKey
      WHERE INSERTED.Status = '5'

      SELECT @n_Continue = 3 , @n_err = 61605
      --SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': DropID for ECOM Orders Cannot be BLANK/Not Match. (ntrPickDetailUpdate)' --SOS223517
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': DropID for Orders Cannot be BLANK/Not Match. (ntrPickDetailUpdate) PDKEY: ' + @cPickDetailKey + ' PD.DID: ' + @cPD_DropID + ' TD.DID: ' + @cTD_DropID
      GOTO QUIT
   END

   --(Wan01) - START
   SELECT TOP 1
         @c_Storerkey = RTRIM(Storerkey)
   FROM INSERTED

   SET @b_success = 0
   EXECUTE dbo.nspGetRight @c_facility
         ,  @c_Storerkey                     -- Storerkey
         ,  NULL                             -- Sku
         ,  'AllocateByConsNewExpiry'        -- Configkey
         ,  @b_Success                 OUTPUT
         ,  @c_AllocateByConsNewExpiry OUTPUT
         ,  @n_Err                     OUTPUT
         ,  @c_errmsg                  OUTPUT

   IF @c_AllocateByConsNewExpiry = '1'                  
      AND EXISTS (SELECT 1
                  FROM INSERTED
                  JOIN ORDERS WITH (NOLOCK) ON (INSERTED.Orderkey = ORDERS.Orderkey)
                  JOIN STORER WITH (NOLOCK) ON (ORDERS.Consigneekey = STORER.Storerkey)
                  AND STORER.SUSR1 IN('nspPRTH01','Y')) --NJOW05
                  
   BEGIN
     --NJOW05
      DECLARE CUR_Consignee CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT DISTINCT ISNULL(RTRIM(ORDERS.Consigneekey),'')
               ,ISNULL(RTRIM(INSERTED.Sku),'')
               ,ISNULL(RTRIM(INSERTED.Storerkey),'')
               ,ISNULL(CONVERT(NVARCHAR(10), LOTATTRIBUTE.Lottable04,120),'1900-01-01')
         FROM INSERTED
         JOIN ORDERS       WITH (NOLOCK) ON (INSERTED.Orderkey = ORDERS.Orderkey)
         JOIN LOTATTRIBUTE WITH (NOLOCK) ON (INSERTED.Lot = LOTATTRIBUTE.Lot)
         JOIN STORER       WITH (NOLOCK) ON (ORDERS.Consigneekey = STORER.Storerkey)
                                             AND STORER.SUSR1 IN('nspPRTH01','Y') 
         
      OPEN CUR_Consignee
      FETCH NEXT FROM CUR_Consignee INTO @c_Consigneekey, @c_Sku, @c_Storerkey, @d_Lottable04 
      
      WHILE @@FETCH_STATUS = 0
      BEGIN
         IF EXISTS ( SELECT 1
                     FROM CONSIGNEESKU WITH (NOLOCK)
                     WHERE Consigneekey = @c_Consigneekey
                     AND   ConsigneeSku = @c_Sku )
         BEGIN
            UPDATE CONSIGNEESKU 
            SET AddDate = @d_Lottable04
               ,EditWho = SUSER_SNAME()
               ,EditDate= GETDATE()
            WHERE Consigneekey = @c_Consigneekey
            AND   ConsigneeSku = @c_Sku
            AND   AddDate < @d_Lottable04
         
            SET @n_err = @@ERROR
            SET @n_cnt = @@ROWCOUNT
            IF @n_err <> 0
            BEGIN
               SET @n_continue = 3
               SET @n_err = 63211
               SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update CONSIGNEESKU Table Failed. (ntrPickDetailUpdate)'
               GOTO QUIT
            END
         END
         ELSE
         BEGIN
            INSERT INTO CONSIGNEESKU (Consigneekey, ConsigneeSku, Storerkey, Sku, AddDate)
            VALUES (@c_Consigneekey, @c_Sku, @c_Storerkey, @c_Sku, @d_Lottable04)
         
            SET @n_err = @@ERROR
            SET @n_cnt = @@ROWCOUNT
            IF @n_err <> 0
            BEGIN
               SET @n_continue = 3
               SET @n_err = 63212
               SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert into CONSIGNEESKU Failed. (ntrPickDetailUpdate)'
               GOTO QUIT
            END
         END         
         FETCH NEXT FROM CUR_Consignee INTO @c_Consigneekey, @c_Sku, @c_Storerkey, @d_Lottable04 
      END
      CLOSE CUR_Consignee
      DEALLOCATE CUR_Consignee      
      
      /*    
      SELECT @c_Consigneekey = ISNULL(RTRIM(ORDERS.Consigneekey),'')
            ,@c_Sku          = ISNULL(RTRIM(INSERTED.Sku),'')
            ,@c_Storerkey    = ISNULL(RTRIM(INSERTED.Storerkey),'')
            ,@d_Lottable04   = ISNULL(CONVERT(NVARCHAR(10), LOTATTRIBUTE.Lottable04,120),'1900-01-01')
      FROM INSERTED
      JOIN ORDERS       WITH (NOLOCK) ON (INSERTED.Orderkey = ORDERS.Orderkey)
      JOIN LOTATTRIBUTE WITH (NOLOCK) ON (INSERTED.Lot = LOTATTRIBUTE.Lot)

      IF EXISTS ( SELECT 1
                  FROM CONSIGNEESKU WITH (NOLOCK)
                  WHERE Consigneekey = @c_Consigneekey
                  AND   ConsigneeSku = @c_Sku )
      BEGIN       
         UPDATE CONSIGNEESKU WITH (ROWLOCK)
         SET AddDate = @d_Lottable04
            ,EditWho = SUSER_SNAME()
            ,EditDate= GETDATE()
         WHERE Consigneekey = @c_Consigneekey
         AND   ConsigneeSku = @c_Sku
         AND   AddDate < @d_Lottable04

         SET @n_err = @@ERROR
         SET @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SET @n_continue = 3
            SET @n_err = 61606
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update CONSIGNEESKU Table Failed. (ntrPickDetailUpdate)'
            GOTO QUIT
         END
      END
      ELSE
      BEGIN
         INSERT INTO CONSIGNEESKU (Consigneekey, ConsigneeSku, Storerkey, Sku, AddDate)
         VALUES (@c_Consigneekey, @c_Sku, @c_Storerkey, @c_Sku, @d_Lottable04)

         SET @n_err = @@ERROR
         SET @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SET @n_continue = 3
            SET @n_err = 61607
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert into CONSIGNEESKU Failed. (ntrPickDetailUpdate)'
            GOTO QUIT
         END
      END
      */
   END
   --(Wan01) - END
   /*
   IF EXISTS(SELECT 1 FROM INSERTED
             JOIN DELETED ON INSERTED.PickDetailKey = DELETED.PickDetailKey
             JOIN   TASKDETAIL WITH (NOLOCK) ON TASKDETAIL.TaskDetailKey = INSERTED.TaskDetailKey
                    AND TASKDETAIL.TaskType='PK'
                    AND TASKDETAIL.PickMethod IN ('DOUBLES','SINGLES','MULTIS')
             WHERE INSERTED.Status = '5' AND DELETED.STATUS < '5')
   BEGIN
      UPDATE TASKDETAIL
         SET [STATUS] = '9', TASKDETAIL.UserKey = 'wms.' + SUSER_SNAME(), TASKDETAIL.TrafficCop = NULL
      FROM TASKDETAIL
       JOIN   INSERTED WITH (NOLOCK) ON TASKDETAIL.TaskDetailKey = INSERTED.TaskDetailKey
              AND TASKDETAIL.TaskType='PK'
              AND TASKDETAIL.PickMethod IN ('DOUBLES','SINGLES','MULTIS')
       JOIN   DELETED ON INSERTED.PickDetailKey = DELETED.PickDetailKey
      WHERE INSERTED.Status = '5' AND DELETED.STATUS < '5'
   END
   ELSE
   IF EXISTS(SELECT 1 FROM INSERTED
             JOIN DELETED ON INSERTED.PickDetailKey = DELETED.PickDetailKey
             JOIN   TASKDETAIL WITH (NOLOCK) ON TASKDETAIL.TaskDetailKey = INSERTED.TaskDetailKey
                    AND TASKDETAIL.TaskType='PK'
                    AND TASKDETAIL.PickMethod IN ('PIECE','CASE')
             WHERE INSERTED.Status = '5' AND DELETED.STATUS < '5')
   BEGIN
      DECLARE @cTaskDetailKey NVARCHAR(10)

      DECLARE CUR_TaskDetailKey CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT INSERTED.TaskDetailKey
      FROM INSERTED
      JOIN DELETED ON INSERTED.PickDetailKey = DELETED.PickDetailKey
      JOIN   TASKDETAIL WITH (NOLOCK) ON TASKDETAIL.TaskDetailKey = INSERTED.TaskDetailKey
             AND TASKDETAIL.TaskType='PK'
             AND TASKDETAIL.PickMethod IN ('PIECE','CASE')
      WHERE INSERTED.Status = '5' AND DELETED.STATUS < '5'

      OPEN  CUR_TaskDetailKey
      FETCH NEXT FROM CUR_TaskDetailKey INTO @cTaskDetailKey
      BEGIN
          IF NOT EXISTS(SELECT 1 FROM PICKDETAIL p (NOLOCK)
                        WHERE p.TaskDetailKey = @cTaskDetailKey
                        AND   P.Status < '5')
          BEGIN
             UPDATE TASKDETAIL WITH (ROWLOCK)
         SET [STATUS] = '9', TASKDETAIL.UserKey = 'wms.' + SUSER_SNAME(), TASKDETAIL.TrafficCop = NULL
             WHERE TaskDetailKey = @cTaskDetailKey
          END
      END
      CLOSE CUR_TaskDetailKey
      DEALLOCATE CUR_TaskDetailKey

   END
   */
END

-- SOS 14880: prevent updates of pick confirmed detail if PICK-TRF is on
IF (@n_Continue=1 or @n_Continue=2) and UPDATE(qty)
BEGIN
   if EXISTS (SELECT 1
              FROM  DELETED d JOIN StorerConfig s (NOLOCK)
              ON    d.StorerKey = s.StorerKey
              WHERE s.Configkey = 'PICK-TRF'
              AND   s.sValue = '1'
              AND   d.Status = '5') AND
      EXISTS (SELECT 1
              FROM  INSERTED i JOIN StorerConfig s (NOLOCK)
              ON    i.StorerKey = s.StorerKey
              WHERE s.Configkey = 'PICK-TRF'
              AND   s.sValue = '1'
              AND   i.qty = 0 )
   BEGIN
      SELECT @n_Continue = 3 , @n_err = 61608
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update on QTY not Allowed After Pick Confirmed - Update Failed. (ntrPickDetailUpdate)'
      GOTO QUIT
   END

   --(Wan02) - START
   IF NOT EXISTS ( SELECT 1
                  FROM STORERCONFIG WITH (NOLOCK)
                  JOIN ORDERS WITH (NOLOCK) ON (STORERCONFIG.Storerkey = ORDERS.Storerkey)
                                            AND(STORERCONFIG.Facility = ORDERS.Facility OR STORERCONFIG.facility = '')
                  JOIN INSERTED ON (ORDERS.Orderkey = INSERTED.Orderkey)
                  WHERE STORERCONFIG.Configkey = 'ValidateSOStatus_SP'
                  AND   STORERCONFIG.SValue = 'ispVSOST01' )
   BEGIN
      -- james01
      IF EXISTS (SELECT 1 FROM INSERTED
                 JOIN Orders WITH (NOLOCK) ON INSERTED.OrderKey = Orders.OrderKey
                 WHERE (Orders.SOSTATUS = 'CANC' OR Orders.Status = 'CANC')
                 AND INSERTED.QTY > 0)
      BEGIN
         SELECT @n_Continue = 3 , @n_err = 61609
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update on QTY not Allowed After Orders is Cancelled - Update Failed. (ntrPickDetailUpdate)'
         GOTO QUIT
      END
   END
   --(Wan02) - END
END

IF (@n_Continue=1 or @n_Continue=2) and update(Status)
BEGIN
   if EXISTS (SELECT 1
              FROM  DELETED d JOIN StorerConfig s (NOLOCK)
              ON    d.StorerKey = s.StorerKey
              WHERE s.Configkey = 'PICK-TRF'
              AND   s.sValue = '1'
              AND   d.Status = '5') and
      EXISTS (SELECT 1
              FROM  INSERTED i JOIN StorerConfig s (NOLOCK)
              ON    i.StorerKey = s.StorerKey
              WHERE s.Configkey = 'PICK-TRF'
              AND   s.sValue = '1'
              AND   i.Status < '5')
   BEGIN
      SELECT @n_Continue = 3 , @n_err = 61610
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update on Status not Allowed After Pick Confirmed - Update Failed. (ntrPickDetailUpdate)'
      GOTO QUIT
   END

   --(Wan02) - START
   IF NOT EXISTS ( SELECT 1
                  FROM STORERCONFIG WITH (NOLOCK)
                  JOIN ORDERS WITH (NOLOCK) ON (STORERCONFIG.Storerkey = ORDERS.Storerkey)
                                            AND(STORERCONFIG.Facility = ORDERS.Facility OR ISNULL(RTRIM(STORERCONFIG.Facility),'') = '')
                  JOIN INSERTED ON (ORDERS.Orderkey = INSERTED.Orderkey)
                  WHERE STORERCONFIG.Configkey = 'ValidateSOStatus_SP'
                  AND   STORERCONFIG.SValue = 'ispVSOST01' )
   BEGIN
      -- james01
      IF EXISTS (SELECT 1 FROM INSERTED
                 JOIN Orders WITH (NOLOCK) ON INSERTED.OrderKey = Orders.OrderKey
                 WHERE (Orders.SOSTATUS = 'CANC' OR Orders.Status = 'CANC')
                 AND INSERTED.Status <> '4')
      BEGIN
         SELECT @n_Continue = 3 , @n_err = 61611
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update on Status not Allowed After Orders is Cancelled - Update Failed. (ntrPickDetailUpdate)'
         GOTO QUIT
      END
   END
   --(Wan02) - END

   -- Added By Shong on 22nd Nov 2006
   -- If BackendShip Turn ON
   -- Not allow to update Status to 9 if the ShipFlag <> 'Y'
   -- To Prevent user do Mass Ship FROM Front End
   -- Might not accurate if bulk update pickdetail more then 1 storer, don't think it will happen in frontend
   -- reason not check is due to performance issues

   SELECT TOP 1 @c_StorerKey = StorerKey    FROM   INSERTED

   IF NOT EXISTS(SELECT 1 FROM StorerConfig (NOLOCK) WHERE StorerKey = @c_StorerKey
                 AND Configkey = 'REALTIMESHIP' AND sValue = 1)
   BEGIN
      IF EXISTS(SELECT 1 FROM INSERTED WHERE Status = '9' and ShipFlag <> 'Y' and StorerKey = @c_StorerKey)
      BEGIN
         SELECT @n_Continue = 3 , @n_err = 61612
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': SHIP not Allowed without MBOL - Update Failed. (ntrPickDetailUpdate)'
         GOTO QUIT
      END
   END
   --SET ROWCOUNT 0
END

/* #INCLUDE <TRPDU1.SQL> */
IF @n_Continue = 1 or @n_Continue = 2
BEGIN
   DECLARE @c_AllowOverAllocations NVARCHAR(1)

   SELECT TOP 1 @c_pckdtl_loc = LOC,
          @c_StorerKey = StorerKey
   FROM  INSERTED

   SELECT TOP 1 @c_facility = FACILITY
   FROM  LOC (NOLOCK)
   WHERE LOC = @c_pckdtl_loc

   SELECT @b_success = 0
   Execute nspGetRight @c_facility, -- facility
         @c_StorerKey,  -- StorerKey
         null, -- Sku
         'ALLOWOVERALLOCATIONS', -- Configkey
         @b_success     output,
         @c_AllowOverAllocations output,
         @n_err         output,
         @c_errmsg      output

   IF @b_success <> 1
   BEGIN
     SELECT @n_Continue = 3, @c_errmsg = 'ntrPickDetailUpdate' + rtrim(@c_errmsg)
   END
END

IF @n_Continue = 1 or @n_Continue = 2
BEGIN
   DECLARE @c_catchweight NVARCHAR(1)

   SELECT @c_catchweight = IsNull(NSQLValue, '0')
   FROM NSQLCONFIG (NOLOCK)
   WHERE Configkey = 'CATCHWEIGHT'
END

IF @b_debug = 1
BEGIN
   SELECT 'Reject changes if the line item is shipped (Status = ''9'')'
   SELECT 'Reject changes if the sourcetype is not ''0'' or ''1'''
END
IF @n_Continue = 1 or @n_Continue = 2
BEGIN
   IF EXISTS (SELECT 1 FROM INSERTED where updatesource NOT IN ('0','1') )
   BEGIN
      SELECT @n_Continue = 3 , @n_err = 61613
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update source is invalid. (ntrPickDetailUpdate)'
      GOTO QUIT
   END
END
-- customized for HK, once pickdetail is Pick in Progress ('3') should not be DELETED. Coz interface has been done
IF @n_Continue=1 or @n_Continue=2
BEGIN
   SELECT @b_success = 0
   Execute nspGetRight null,  -- facility
             @c_StorerKey,    -- StorerKey
             null,            -- Sku
             'OWITF',      -- Configkey
             @b_success    output,
             @c_authority  output,
             @n_err        output,
             @c_errmsg     output
   IF @b_success <> 1
   BEGIN
      SELECT @n_Continue = 3, @c_errmsg = 'ntrPickDetailUpdate' + rtrim(@c_errmsg)
      GOTO QUIT
   END
   ELSE IF @c_authority = '1'
   BEGIN
      IF EXISTS (SELECT 1 FROM INSERTED, DELETED
                 WHERE INSERTED.PickDetailKey = DELETED.PickDetailKey
                 AND DELETED.Status  > '2'
                 AND INSERTED.Status < '3')
      BEGIN
         SELECT @n_Continue = 3 , @n_err = 61614
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Picking in process, Changes to items not allowed. (ntrPickDetailUpdate)'
         GOTO QUIT
      END
   END
END

IF @n_continue = 1 or @n_continue = 2
BEGIN
   IF UPDATE (Qty) OR UPDATE (OrderKey) OR UPDATE (OrderLineNumber)
   BEGIN
      DECLARE @c_sPickDetailKey            NVARCHAR(20),
              @c_sOrderKey                 NVARCHAR(10),
              @c_sOrderLineNumber          NVARCHAR(5),
              @c_sLot                      NVARCHAR(10),
              @c_sPreAllocatePickDetailKey NVARCHAR(10)

      DECLARE @n_sPreAllocatePickDetailQty int,
              @n_sPickDetailQty            int,
              @n_sQtyToReduce              int

      SELECT @c_sPickDetailKey = SPACE(20)
      WHILE (1=1)
      BEGIN

         SELECT TOP 1 @c_sPickDetailKey = INSERTED.PickDetailKey ,
                @n_sPickDetailQty = INSERTED.QTY - DELETED.QTY,
                @c_sOrderKey = INSERTED.ORDERKEY ,
                @c_sOrderLineNumber = INSERTED.OrderLineNumber ,
                @c_sLot = INSERTED.LOT
         FROM  INSERTED, DELETED
         WHERE INSERTED.PickDetailKey = DELETED.PickDetailKey
         AND INSERTED.PickDetailKey > @c_sPickDetailKey
         AND INSERTED.QTY - DELETED.QTY > 0
         ORDER BY INSERTED.PickDetailKey

         IF @@ROWCOUNT = 0
         BEGIN
            BREAK
         END

         SELECT @c_sPreAllocatePickDetailKey = SPACE(10)

         WHILE (1=1)
         BEGIN
            SELECT TOP 1 @c_sPreAllocatePickDetailKey = PreAllocatePickDetailKey ,
                   @n_sPreAllocatePickDetailQty = qty
            FROM PreAllocatePickDetail (NOLOCK)
            WHERE PreAllocatePickDetailKey > @c_sPreAllocatePickDetailKey
            AND ORDERKEY = @c_sOrderKey
            AND OrderLineNumber = @c_sOrderLineNumber
            AND LOT = @c_sLot
            AND QTY > 0
            ORDER BY PreAllocatePickDetailKey

            IF @@ROWCOUNT = 0
            BEGIN
               --SET ROWCOUNT 0
               BREAK
            END
            --SET ROWCOUNT 0
            IF @n_sPickDetailQty > @n_sPreAllocatePickDetailQty
            BEGIN
               SELECT @n_sQtyToReduce = @n_sPickDetailQty - @n_sPreAllocatePickDetailQty
               SELECT @n_sPickDetailQty = @n_sPickDetailQty - @n_sQtyToReduce
            END
            ELSE
            BEGIN
               SELECT @n_sQtyToReduce = @n_sPickDetailQty
               SELECT @n_sPickDetailQty = @n_sPickDetailQty - @n_sQtyToReduce
            END

            UPDATE PreAllocatePickDetail  
            SET QTY = QTY - @n_sQtyToReduce,
                  EditDate = GETDATE(),   --tlting
                  EditWho = SUSER_SNAME()
            WHERE PreAllocatePickDetailKey = @c_sPreAllocatePickDetailKey

            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
            IF @n_err <> 0
            BEGIN
           SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61615
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Trigger On PickDetail Could Not Update PreAllocatePickDetail. (ntrPickDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
            END
            IF @n_sPickDetailQty <=0
            BEGIN
               BREAK
            END
         END -- 2nd While Loop
         --SET ROWCOUNT 0
      END -- 1st While Loop
      --SET ROWCOUNT 0
   END -- IF UPDATE (Qty) OR UPDATE (OrderKey) OR UPDATE (OrderLineNumber)
END -- IF @n_continue = 1 or @n_continue = 2

-- SWT02 Channel Management 
IF @n_Continue = 1 OR @n_Continue = 2
BEGIN
   SELECT TOP 1 @c_StorerKey = StorerKey
   FROM INSERTED
 
   IF EXISTS(SELECT 1 FROM StorerConfig WITH (NOLOCK)
             WHERE StorerKey = @c_StorerKey AND ConfigKey = 'ChannelInventoryMgmt' AND sValue = '1')
   BEGIN
      DECLARE @n_Channel_ID     BIGINT, 
              @c_Channel        NVARCHAR(20), 
              @c_cStorerKey     NVARCHAR(15), 
              @c_cFacility      NVARCHAR(10),
              @c_InsertedLOT    NVARCHAR(10),
              @c_DeletedLOT     NVARCHAR(10),
              @c_cSKU           NVARCHAR(20),
              @n_InsertedQty    INT,
              @n_DeletedQty     INT,
              @c_InsertedStatus NVARCHAR(10),
              @c_DeletedStatus  NVARCHAR(10),
              @c_cPickDetailKey NVARCHAR(10), 
              @n_DeletedChn_ID  BIGINT 
      
      IF ( UPDATE(LOT) OR UPDATE(STATUS) OR UPDATE(Qty) )  
      BEGIN  
         DECLARE CUR_CHANNEL_MGMT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT INSERTED.PickDetailKey,  
                INSERTED.Storerkey,   
                INSERTED.Sku,   
                LOC.Facility,   
                ISNULL(OD.Channel,''),   
                INSERTED.Lot,   
                DELETED.LOT,   
                ISNULL(DELETED.Channel_ID,0),   
                INSERTED.Qty,   
                DELETED.Qty,  
                INSERTED.Status,   
                DELETED.Status   
         FROM INSERTED   
         JOIN DELETED ON INSERTED.PickDetailKey = DELETED.PickDetailKey     
         JOIN LOC LOC WITH (NOLOCK) ON LOC.Loc = INSERTED.Loc 
         CROSS APPLY fnc_SelectGetRight (LOC.Facility, INSERTED.Storerkey, '', 'ChannelInventoryMgmt') SC--(Wan03) 
         --JOIN StorerConfig AS sc WITH(NOLOCK) ON INSERTED.Storerkey = SC.StorerKey                     --(Wan03) 
         --          AND SC.ConfigKey = 'ChannelInventoryMgmt' AND SC.sValue = '1'                       --(Wan03) 
         JOIN ORDERDETAIL AS OD WITH(NOLOCK)  
                ON  OD.OrderKey = INSERTED.OrderKey AND OD.OrderLineNumber = INSERTED.OrderLineNumber  
         WHERE ( INSERTED.Qty <> DELETED.Qty OR   
               ( INSERTED.Status <= '9' AND DELETED.Status IN ('0','1','2','3','4','5','6','7','8') ) )  --INC0683213 
         AND SC.Authority = '1'                                                                          --(Wan03) 
   
               
         OPEN CUR_CHANNEL_MGMT   
        
         FETCH NEXT FROM CUR_CHANNEL_MGMT INTO @c_cPickDetailKey, @c_cStorerKey, @c_cSKU, @c_cFacility, @c_Channel, @c_InsertedLOT, @c_DeletedLOT,   
            @n_Channel_ID, @n_InsertedQty, @n_DeletedQty, @c_InsertedStatus, @c_DeletedStatus 
      
         WHILE @@FETCH_STATUS = 0 
         BEGIN
            IF ISNULL(RTRIM(@c_Channel),'') = ''
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63125   
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)
                     + ': Order Detail Channel Cannot be BLANK. (ntrPickDetailUpdate)' 
                     + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) ' 
               BREAK                
            END
            IF ISNULL(@n_Channel_ID,0) = 0 
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63126   
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)
                     + ': Channel ID Cannot be BLANK. (ntrPickDetailUpdate)' 
                     + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) ' 
               BREAK       
      
            END
            IF @c_InsertedLOT = @c_DeletedLOT 
            BEGIN
               IF ISNULL(@n_Channel_ID,0) > 0 
               BEGIN
                  IF (@c_InsertedStatus = @c_DeletedStatus) OR (@c_InsertedStatus < '9')  --INC0683213 
                  BEGIN
                     UPDATE ChannelInv  
                        SET QtyAllocated = QtyAllocated - @n_DeletedQty + @n_InsertedQty , 
                              EditDate = GETDATE(),
                              EditWho = SUSER_SNAME()
                     WHERE Channel_ID = @n_Channel_ID                      
                  END -- IF @c_InsertedStatus = @c_DeletedStatus 
                  ELSE 
                  BEGIN
                     IF @c_InsertedStatus = '9' AND @c_DeletedStatus IN ('0','1','2','3','4','5','6','7','8') 
                     BEGIN
                        UPDATE ChannelInv  
                           SET QtyAllocated = QtyAllocated - @n_DeletedQty, 
                                 EditDate = GETDATE(),
                                 EditWho = SUSER_SNAME()
                        WHERE Channel_ID = @n_Channel_ID                                                                         
                     END                     
                  END -- IF @c_InsertedStatus <> @c_DeletedStatus                   
               END -- IF ISNULL(@n_Channel_ID,0) > 0           
            END -- IF @c_InsertedLOT = @c_DeletedLOT 
            ELSE 
            BEGIN
               SET @n_DeletedChn_ID = 0
                
               EXEC isp_ChannelGetID 
                   @c_StorerKey   = @c_cStorerKey
                  ,@c_Sku         = @c_cSKU
                  ,@c_Facility    = @c_cFacility
                  ,@c_Channel     = @c_Channel
                  ,@c_LOT         = @c_DeletedLOT
                  ,@n_Channel_ID  = @n_DeletedChn_ID OUTPUT

                IF @n_DeletedChn_ID > 0 
                BEGIN
                  UPDATE ChannelInv  
                     SET QtyAllocated = QtyAllocated - @n_DeletedQty, 
                         EditDate = GETDATE(),
                         EditWho = SUSER_SNAME()
                  WHERE Channel_ID = @n_DeletedChn_ID                      
                END                                
                IF ISNULL(@n_Channel_ID,0) > 0 
                BEGIN
                  UPDATE ChannelInv  
                     SET QtyAllocated = QtyAllocated + @n_InsertedQty , 
                         EditDate = GETDATE(),
                         EditWho = SUSER_SNAME()
                  WHERE Channel_ID = @n_Channel_ID                   
                END  
            END -- IF @c_InsertedLOT <> @c_DeletedLOT 
         
            FETCH NEXT FROM CUR_CHANNEL_MGMT INTO @c_cPickDetailKey, @c_cStorerKey, @c_cSKU, @c_cFacility, @c_Channel, @c_InsertedLOT, @c_DeletedLOT,   
               @n_Channel_ID, @n_InsertedQty, @n_DeletedQty, @c_InsertedStatus, @c_DeletedStatus  
         END -- While 
         CLOSE CUR_CHANNEL_MGMT
         DEALLOCATE CUR_CHANNEL_MGMT
      END -- NOT UPDATE(LOT) AND ( UPDATE(STATUS) OR UPDATE(Qty) )         
   END   
END 

---- Process LOT Table Update
IF ( @n_continue = 1 or @n_continue = 2 ) AND 
   ( UPDATE(STORERKEY) OR UPDATE(SKU) OR UPDATE(LOT) OR UPDATE(STATUS) OR UPDATE(QTY) )
BEGIN
   -- tlting01

   Declare @tLOT TABLE   (
      LOT          NVARCHAR(10) NOT NULL,
      QtyAllocated int,
      QtyPicked    int,
      QtyShipped   int
      PRIMARY KEY CLUSTERED (LOT)
      )

   INSERT INTO @tLOT  ( LOT, QtyAllocated, QtyPicked, QtyShipped )
   SELECT LOT,
          SUM (CASE WHEN Status IN ('0','1','2','3','4') THEN Qty ELSE 0 END) AS QtyAllocated,
          SUM (CASE WHEN Status IN ('5','6','7','8') THEN Qty ELSE 0 END) AS QtyPicked,
          SUM (CASE WHEN Status = '9' THEN Qty ELSE 0 END) AS QtyShipped
   FROM INSERTED
   GROUP BY LOT

   UPDATE tLOT
      SET QtyAllocated = tLOT.QtyAllocated + DEL_PD.QtyAllocated,
          QtyPicked    = tLOT.QtyPicked + DEL_PD.QtyPicked,
          QtyShipped   = tLOT.QtyShipped + DEL_PD.QtyShipped
   FROM  @tLOT tLOT
   JOIN (SELECT LOT,
          SUM (CASE WHEN Status IN ('0','1','2','3','4') THEN Qty * -1 ELSE 0 END) AS QtyAllocated,
          SUM (CASE WHEN Status IN ('5','6','7','8') THEN Qty * -1 ELSE 0 END) AS QtyPicked,
          SUM (CASE WHEN Status = '9' THEN Qty * -1 ELSE 0 END) AS QtyShipped
         FROM DELETED
         GROUP BY LOT) AS DEL_PD ON DEL_PD.LOT = tLOT.LOT

   INSERT INTO @tLOT  ( LOT, QtyAllocated, QtyPicked, QtyShipped )
   SELECT DELETED.LOT,
          SUM (CASE WHEN DELETED.Status IN ('0','1','2','3','4') THEN DELETED.Qty * -1 ELSE 0 END) AS QtyAllocated,
          SUM (CASE WHEN DELETED.Status IN ('5','6','7','8') THEN DELETED.Qty * -1 ELSE 0 END) AS QtyPicked,
          SUM (CASE WHEN Status = '9' THEN Qty * -1 ELSE 0 END) AS QtyShipped
   FROM DELETED
   LEFT OUTER JOIN @tLOT LOT ON LOT.LOT = DELETED.LOT
   WHERE LOT.LOT IS NULL
   GROUP BY DELETED.LOT


   UPDATE LOT  
   SET  Lot.QtyAllocated = (Lot.QtyAllocated + tL.QtyAllocated),
        Lot.QtyPicked    = (Lot.QtyPicked + tL.QtyPicked),
        -- LOT.Qty = (LOT.Qty - tl.QtyShipped)
        EditDate = GETDATE(),   --tlting
        EditWho = SUSER_SNAME()
   FROM LOT
   JOIN @tLOT tL ON tL.LOT = LOT.LOT
   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   IF @n_err <> 0
   BEGIN
     SELECT @n_continue = 3
     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61616
     SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update trigger On LOT Failed. (ntrPickDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '
     GOTO QUIT
   END
END -- IF UPDATE LOT

---- Process LOTxLOCxID Table Update
IF ( @n_continue = 1 or @n_continue = 2 ) AND 
( UPDATE(STORERKEY) OR UPDATE(SKU) OR UPDATE(LOT) OR UPDATE(LOC) OR UPDATE(ID) OR UPDATE(STATUS) OR UPDATE(QTY) )
BEGIN
   -- tlting01
   DECLARE @tLOTxLOCxID     TABLE  (
      LOT          NVARCHAR(10) NOT NULL,
      LOC          NVARCHAR(10) NOT NULL,
      ID           NVARCHAR(18) NOT NULL,
      QtyAllocated int DEFAULT (0),
      QtyPicked    int DEFAULT (0),
      QtyShipped   int DEFAULT (0)
      PRIMARY KEY CLUSTERED (LOT, LOC, ID)
      )
   INSERT INTO @tLOTxLOCxID  ( LOT, LOC, ID, QtyAllocated, QtyPicked, QtyShipped )
   SELECT LOT, LOC, ID,
          SUM (CASE WHEN Status IN ('0','1','2','3','4') THEN Qty ELSE 0 END) AS QtyAllocated,
          SUM (CASE WHEN Status IN ('5','6','7','8') THEN Qty ELSE 0 END) AS QtyPicked,
          SUM (CASE WHEN Status = '9' THEN Qty ELSE 0 END) AS QtyShipped
   FROM INSERTED
   GROUP BY LOT, LOC, ID

   UPDATE tLLI
      SET tLLI.QtyAllocated = tLLI.QtyAllocated + DEL_PD.QtyAllocated,
          tLLI.QtyPicked    = tLLI.QtyPicked + DEL_PD.QtyPicked,
          tLLI.QtyShipped   = tLLI.QtyShipped + DEL_PD.QtyShipped
   FROM  @tLOTxLOCxID tLLI
   JOIN (SELECT LOT, LOC, ID,
          SUM (CASE WHEN Status IN ('0','1','2','3','4') THEN Qty * -1 ELSE 0 END) AS QtyAllocated,
          SUM (CASE WHEN Status IN ('5','6','7','8') THEN Qty * -1 ELSE 0 END) AS QtyPicked,
          SUM (CASE WHEN Status = '9' THEN Qty * -1 ELSE 0 END) AS QtyShipped
         FROM DELETED
         GROUP BY LOT, LOC, ID) AS DEL_PD ON DEL_PD.LOT = tLLI.LOT AND DEL_PD.LOC = tLLI.LOC
                               AND DEL_PD.ID = tLLI.ID

   INSERT INTO @tLOTxLOCxID  ( LOT, LOC, ID, QtyAllocated, QtyPicked, QtyShipped )
   SELECT DELETED.LOT, DELETED.LOC, DELETED.ID,
          SUM (CASE WHEN DELETED.Status IN ('0','1','2','3','4') THEN DELETED.Qty * -1 ELSE 0 END) AS QtyAllocated,
          SUM (CASE WHEN DELETED.Status IN ('5','6','7','8') THEN DELETED.Qty * -1 ELSE 0 END) AS QtyPicked,
          SUM (CASE WHEN DELETED.Status = '9' THEN DELETED.Qty * -1 ELSE 0 END) AS QtyShipped
   FROM DELETED
   LEFT OUTER JOIN @tLOTxLOCxID LLI ON LLI.LOT = DELETED.LOT AND LLI.LOC = DELETED.LOC AND LLI.ID = DELETED.ID
   WHERE LLI.LOT IS NULL
   GROUP BY DELETED.LOT, DELETED.LOC, DELETED.ID

   UPDATE LOTxLOCxID  
   SET  QtyAllocated = (LOTxLOCxID.QtyAllocated + tLLI.QtyAllocated),
        QtyPicked    = (LOTxLOCxID.QtyPicked + tLLI.QtyPicked),
        QtyExpected  = CASE WHEN SL.LocationType NOT IN ('CASE','PICK') AND               -- (SHONG01)
                                 LOC.LocationType NOT IN ('DYNPICKP', 'DYNPICKR','DYNPPICK') THEN 0  -- (TLTING01) (NJOW01)
                            WHEN (( LOTxLOCxID.QtyAllocated +  tLLI.QtyAllocated) +
                                  ( LOTxLOCxID.QtyPicked  + tLLI.QtyPicked )) > (LOTxLOCxID.Qty - tLLI.QtyShipped)
                            THEN (( LOTxLOCxID.QtyAllocated +  tLLI.QtyAllocated) +
                                  ( LOTxLOCxID.QtyPicked  + tLLI.QtyPicked ))  - (LOTxLOCxID.Qty - tLLI.QtyShipped)
                            ELSE 0
                       END,
        /*
        Qty = (LOTxLOCxID.Qty - tLLI.QtyShipped)
        */
         EditDate = GETDATE(),   --tlting
         EditWho = SUSER_SNAME()
   FROM LOTxLOCxID
   JOIN @tLOTxLOCxID tLLI ON tLLI.LOT = LOTxLOCxID.LOT AND
                             tLLI.LOC = LOTxLOCxID.LOC AND
                             tLLI.ID = LOTxLOCxID.ID
   JOIN SKUxLOC SL WITH (NOLOCK) ON SL.StorerKey = LOTxLOCxID.StorerKey
                  AND SL.SKU = LOTxLOCxID.SKU
                  AND SL.LOC = LOTxLOCxID.LOC
   JOIN LOC LOC WITH (NOLOCK) ON LOC.LOC = LOTxLOCxID.LOC
   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   IF @n_err <> 0
   BEGIN
     SELECT @n_continue = 3
     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61617
     SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update trigger On LOTxLOCxID Failed. (ntrPickDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '
     GOTO QUIT
   END
END -- IF UPDATE LOTXLOCXID

--- Process SKUxLOC Table Update
IF ( @n_continue = 1 or @n_continue = 2 ) AND 
( UPDATE(STORERKEY) OR UPDATE(SKU) OR UPDATE(LOC) OR UPDATE(STATUS) OR UPDATE(QTY) )
BEGIN
   -- tlting01
  DECLARE @tSKUxLOC Table    (
      StorerKey    NVARCHAR(15) NOT NULL,
      SKU          NVARCHAR(20) NOT NULL,
      LOC          NVARCHAR(10) NOT NULL,
      QtyAllocated int DEFAULT (0),
      QtyPicked    int DEFAULT (0),
      QtyShipped   int DEFAULT (0)
      PRIMARY KEY CLUSTERED (StorerKey, SKU, LOC)
      )

   INSERT INTO @tSKUxLOC ( StorerKey, SKU, LOC, QtyAllocated, QtyPicked, QtyShipped )
   SELECT StorerKey, SKU, LOC,
          SUM (CASE WHEN Status IN ('0','1','2','3','4') THEN Qty ELSE 0 END) AS QtyAllocated,
          SUM (CASE WHEN Status IN ('5','6','7','8') THEN Qty ELSE 0 END) AS QtyPicked,
          SUM (CASE WHEN Status = '9' THEN Qty ELSE 0 END) AS QtyShipped
   FROM INSERTED
   GROUP BY StorerKey, SKU, LOC

   UPDATE tSL         SET tSL.QtyAllocated = tSL.QtyAllocated + DEL_PD.QtyAllocated,
          tSL.QtyPicked    = tSL.QtyPicked + DEL_PD.QtyPicked ,
          tSL.QtyShipped   = tSL.QtyShipped + DEL_PD.QtyShipped
   FROM  @tSKUxLOC tSL
   JOIN (SELECT StorerKey, SKU, LOC,
          SUM (CASE WHEN Status IN ('0','1','2','3','4') THEN Qty * -1 ELSE 0 END) AS QtyAllocated,
          SUM (CASE WHEN Status IN ('5','6','7','8') THEN Qty * -1 ELSE 0 END) AS QtyPicked,
          SUM (CASE WHEN Status = '9' THEN Qty * -1 ELSE 0 END) AS QtyShipped
         FROM DELETED
         GROUP BY StorerKey, SKU, LOC) AS DEL_PD ON DEL_PD.StorerKey = tSL.StorerKey AND
                                          DEL_PD.SKU = tSL.SKU AND
                                          DEL_PD.LOC = tSL.LOC

   INSERT INTO @tSKUxLOC  ( StorerKey, SKU, LOC, QtyAllocated, QtyPicked, QtyShipped )
   SELECT DELETED.StorerKey, DELETED.SKU, DELETED.LOC,
          SUM (CASE WHEN DELETED.Status IN ('0','1','2','3','4') THEN DELETED.Qty * -1 ELSE 0 END) AS QtyAllocated,
          SUM (CASE WHEN DELETED.Status IN ('5','6','7','8') THEN DELETED.Qty * -1 ELSE 0 END) AS QtyPicked,
          SUM (CASE WHEN DELETED.Status = '9' THEN DELETED.Qty * -1 ELSE 0 END) AS QtyShipped
   FROM DELETED
   LEFT OUTER JOIN @tSKUxLOC tSL ON tSL.StorerKey = DELETED.StorerKey AND tSL.SKU = DELETED.SKU
                                AND tSL.LOC =  DELETED.LOC
   WHERE tSL.SKU IS NULL
   GROUP BY DELETED.StorerKey, DELETED.SKU, DELETED.LOC

   UPDATE SKUxLOC  
   SET  QtyAllocated = (SKUxLOC.QtyAllocated + tSL.QtyAllocated),
        QtyPicked    = (SKUxLOC.QtyPicked + tSL.QtyPicked),
        QtyExpected  = CASE WHEN SKUxLOC.QtyAllocated + SKUxLOC.QtyPicked +
                                 tSL.QtyAllocated + tSL.QtyPicked > (SKUxLOC.Qty - QtyShipped)
                            THEN ( SKUxLOC.QtyAllocated + SKUxLOC.QtyPicked +
                                   tSL.QtyAllocated + tSL.QtyPicked ) - (SKUxLOC.Qty - QtyShipped)
                            ELSE 0
                       END,
   /*     QtyExpected  = CASE WHEN @c_AllowOverAllocations <> '1' THEN 0
                            WHEN SKUxLOC.QtyAllocated + SKUxLOC.QtyPicked +
                                 tSL.QtyAllocated + tSL.QtyPicked > SKUxLOC.Qty
                            THEN ( SKUxLOC.QtyAllocated + SKUxLOC.QtyPicked +
                                   tSL.QtyAllocated + tSL.QtyPicked ) - SKUxLOC.Qty
                            ELSE 0
                       END
         ,
         Qty    = (SKUxLOC.Qty - tSL.QtyShipped)
         */
         EditDate = GETDATE(),   --tlting
         EditWho = SUSER_SNAME()
   FROM SKUxLOC
   JOIN @tSKUxLOC tSL ON tSL.StorerKey = SKUxLOC.StorerKey AND
                     tSL.SKU = SKUxLOC.SKU AND
                     tSL.LOC = SKUxLOC.LOC
   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   IF @n_err <> 0
   BEGIN
     SELECT @n_continue = 3
     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61618
     SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update trigger On SKUxLOC Failed. (ntrPickDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '
     GOTO QUIT
   END
END -- IF UPDATE...

--- Proccess OrderDetail Update
IF ( @n_continue = 1 or @n_continue = 2 ) AND 
( UPDATE(ORDERKEY) OR UPDATE(OrderLineNumber) OR UPDATE(QTY) OR UPDATE(STATUS) )
BEGIN
 -- tlting01
 Declare @tOrderDetail TABLE  (
      OrderKey NVARCHAR(10),
      OrderLineNumber NVARCHAR(5),
      QtyAllocated    int,
      QtyPicked       int,
      QtyShipped      int
      PRIMARY KEY CLUSTERED (OrderKey, OrderLineNumber) )

   INSERT INTO @tOrderDetail   (OrderKey, OrderLineNumber, QtyAllocated, QtyPicked, QtyShipped )
   SELECT OrderKey, OrderLineNumber,
          SUM (CASE WHEN Status IN ('0','1','2','3','4') THEN Qty ELSE 0 END) AS QtyAllocated,
          SUM (CASE WHEN Status IN ('5','6','7','8') THEN Qty ELSE 0 END) AS QtyPicked,
          SUM (CASE WHEN Status = '9' THEN Qty ELSE 0 END) AS QtyShipped
   FROM INSERTED
   GROUP BY OrderKey, OrderLineNumber

   UPDATE tOrdDet
      SET tOrdDet.QtyAllocated = tOrdDet.QtyAllocated + DEL_PD.QtyAllocated,
          tOrdDet.QtyPicked    = tOrdDet.QtyPicked + DEL_PD.QtyPicked,
         tOrdDet.QtyShipped   = tOrdDet.QtyShipped + DEL_PD.QtyShipped
   FROM  @tOrderDetail tOrdDet
   JOIN (SELECT OrderKey, OrderLineNumber,
          SUM (CASE WHEN Status IN ('0','1','2','3','4') THEN Qty * -1 ELSE 0 END) AS QtyAllocated,
          SUM (CASE WHEN Status IN ('5','6','7','8') THEN Qty * -1 ELSE 0 END) AS QtyPicked,
          SUM (CASE WHEN Status = '9' THEN Qty * -1 ELSE 0 END) AS QtyShipped
         FROM DELETED
         GROUP BY OrderKey, OrderLineNumber) AS DEL_PD ON DEL_PD.OrderKey = tOrdDet.OrderKey AND
                                                          DEL_PD.OrderLineNumber = tOrdDet.OrderLineNumber

   INSERT INTO @tOrderDetail  (OrderKey, OrderLineNumber, QtyAllocated, QtyPicked, QtyShipped )
   SELECT DELETED.OrderKey, DELETED.OrderLineNumber,
          SUM (CASE WHEN DELETED.Status IN ('0','1','2','3','4') THEN DELETED.Qty * -1 ELSE 0 END) AS QtyAllocated,
          SUM (CASE WHEN DELETED.Status IN ('5','6','7','8') THEN DELETED.Qty * -1 ELSE 0 END) AS QtyPicked,
          SUM (CASE WHEN DELETED.Status = '9' THEN DELETED.Qty * -1 ELSE 0 END) AS QtyShipped
   FROM DELETED
   LEFT OUTER JOIN @tOrderDetail tOrdDet ON tOrdDet.OrderKey = DELETED.OrderKey
                                        AND tOrdDet.OrderLineNumber = DELETED.OrderLineNumber
   WHERE tOrdDet.OrderKey IS NULL
   GROUP BY DELETED.OrderKey, DELETED.OrderLineNumber

   -- (SWT01) Performance Tuning 
   --UPDATE OrderDetail WITH (RowLock)
   --SET  OrderDetail.QtyAllocated = (OrderDetail.QtyAllocated + tOrdDet.QtyAllocated),
   --     OrderDetail.QtyPicked    = (OrderDetail.QtyPicked + tOrdDet.QtyPicked),
   --     OrderDetail.ShippedQty   = (OrderDetail.ShippedQty + tOrdDet.QtyShipped),
   --     OrderDetail.OpenQty      = (OrderDetail.OpenQty - tOrdDet.QtyShipped),
   --     OrderDetail.EditDate     = GETDATE(),   --tlting
   --     OrderDetail.EditWho      = SUSER_SNAME()
   --FROM OrderDetail
   --JOIN #tOrderDetail AS tOrdDet ON (OrderDetail.OrderKey = tOrdDet.OrderKey AND OrderDetail.OrderLineNumber = tOrdDet.OrderLineNumber)   
   IF EXISTS(SELECT 1 FROM @tOrderDetail WHERE QtyShipped > 0) 
   BEGIN
      UPDATE OrderDetail  
      SET  OrderDetail.QtyAllocated = (OrderDetail.QtyAllocated + tOrdDet.QtyAllocated),
           OrderDetail.QtyPicked    = (OrderDetail.QtyPicked + tOrdDet.QtyPicked),
           OrderDetail.ShippedQty   = (OrderDetail.ShippedQty + tOrdDet.QtyShipped),
           OrderDetail.OpenQty      = (OrderDetail.OpenQty - tOrdDet.QtyShipped),
           OrderDetail.EditDate     = GETDATE(),   --tlting
           OrderDetail.EditWho      = SUSER_SNAME()
      FROM OrderDetail
      JOIN @tOrderDetail AS tOrdDet ON (OrderDetail.OrderKey = tOrdDet.OrderKey AND OrderDetail.OrderLineNumber = tOrdDet.OrderLineNumber)      
   END
   ELSE 
   BEGIN
      UPDATE OrderDetail  
      SET  OrderDetail.QtyAllocated = (OrderDetail.QtyAllocated + tOrdDet.QtyAllocated),
           OrderDetail.QtyPicked    = (OrderDetail.QtyPicked + tOrdDet.QtyPicked),
           OrderDetail.EditDate     = GETDATE(),   --tlting
           OrderDetail.EditWho      = SUSER_SNAME()
      FROM OrderDetail
      JOIN @tOrderDetail AS tOrdDet ON (OrderDetail.OrderKey = tOrdDet.OrderKey AND OrderDetail.OrderLineNumber = tOrdDet.OrderLineNumber)      
   END

   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   IF @n_err <> 0
   BEGIN
     SELECT @n_continue = 3
     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61619
     SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update trigger On PickDetail Failed. (ntrPickDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '
     GOTO QUIT
   END
END -- UPDATE ORDERDETAIL

--(Wan04) - START
IF @n_Continue IN ( 1 ,2 ) AND UPDATE(STATUS) AND  -- UPDATE PACKTASKDETAIL
   EXISTS (SELECT 1 FROM INSERTED INS JOIN DELETED DEL ON INS.PickdetailKey = DEL.PickDetailKey 
           WHERE INS.[STATUS] <> DEL.[STATUS] 
           AND INS.[STATUS] = '3'
           )
BEGIN
   
   DECLARE @tPickOrd TABLE (Orderkey   NVARCHAR(10) NOT NULL DEFAULT(''))
   
   DECLARE @tFullPickOrd TABLE (Orderkey   NVARCHAR(10) NOT NULL DEFAULT(''))
   
   INSERT INTO @tPickOrd (Orderkey)
   SELECT INS.Orderkey 
   FROM INSERTED INS JOIN DELETED DEL ON INS.PickdetailKey = DEL.PickDetailKey 
   JOIN LOC L WITH (NOLOCK) ON INS.Loc = L.Loc
   CROSS APPLY fnc_SelectGetRight (L.Facility, INS.Storerkey, '', 'EPACK4PickedOrder') SC
   WHERE INS.[STATUS] <> DEL.[STATUS]
   AND INS.[STATUS] = '3'   
   AND SC.Authority = '1'
   GROUP BY INS.Orderkey 
     
   IF EXISTS (SELECT 1 
              FROM @tPickOrd pck
              JOIN PACKTASKDETAIL AS p WITH (NOLOCK) ON pck.Orderkey = p.Orderkey
              WHERE p.[Status] = 'P')
   BEGIN
      INSERT INTO @tFullPickOrd ( Orderkey )
      SELECT pd.Orderkey
      FROM @tPICKORD pck
      JOIN PICKDETAIL AS pd WITH (NOLOCK) ON pd.OrderKey = pck.Orderkey
      GROUP BY pd.OrderKey
      HAVING MIN(pd.[Status]) BETWEEN '3' AND '5'
      AND MAX(pd.[Status]) < '9' 
      AND MAX(pd.ShipFlag) NOT IN ('Y')

      IF EXISTS (  SELECT 1 FROM @tFullPickOrd fpck JOIN PACKTASKDETAIL AS p WITH (NOLOCK) ON fpck.Orderkey = p.Orderkey
                   WHERE  p.[Status] = 'P'
      )
      BEGIN
         ;WITH PTD ( RowRef )
          AS ( SELECT RowRef FROM @tFullPickOrd fpck JOIN PACKTASKDETAIL AS p WITH (NOLOCK) ON fpck.Orderkey = p.Orderkey
               WHERE  p.[Status] = 'P'
             )
                 
         UPDATE p
            SET [Status] = '0'
            , Editwho  = SUSER_SNAME()
            , Editdate = GETDATE()
            , Trafficcop = NULL
         FROM PACKTASKDETAIL AS p 
         JOIN PTD ON PTD.RowRef = p.RowRef
         WHERE p.[Status] = 'P'
               
         SET @n_err = @@ERROR
         IF @n_err <> 0
         BEGIN
            SET @n_continue = 3
            SET @c_errmsg = CONVERT(CHAR(250),@n_err)
            SET @n_err=61621   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0))
                              + ': Update Failed On PACKTASKDETAIL. (ntrPickDetailUpdate) ( SQLSvr MESSAGE='
                              + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
         END
      END
   END
END 
--(Wan04) - END

IF @b_debug=1
BEGIN
    SELECT 'Should We Update Inventory Here??'
END

IF @n_continue=1 OR @n_continue=2
BEGIN
    DECLARE @c_uPickDetailKey    NVARCHAR(18)
           ,@c_uOrderKey         NVARCHAR(10)
           ,@c_uOrderLineNumber  NVARCHAR(5)
           ,@c_uLot              NVARCHAR(10)
           ,@c_uStorerKey        NVARCHAR(15)
           ,@c_uSku              NVARCHAR(20)
           ,@n_uQty              INT
           ,@c_uToloc            NVARCHAR(10)
           ,@c_uToid             NVARCHAR(18)
           ,@d_uEffectiveDate    DATETIME
           ,@c_uUom              NVARCHAR(10)
           ,@c_uPackkey          NVARCHAR(10)
           ,@n_uChannel_ID       BIGINT -- SWT02 
           ,@c_uChannel          NVARCHAR(20) -- SWT02 

    DECLARE @n_Pallet            INT
           ,@n_CaseCnt           INT
           ,@n_InnerPack         INT
           ,@f_OtherUnit1        FLOAT
           ,@f_OtherUnit2        FLOAT
           ,@f_NetWgt            FLOAT
           ,@f_GrossWgt          FLOAT
           ,@f_Tare              FLOAT
           ,@c_Ioflag            NVARCHAR(1)
           ,@c_PrevStorerKey     NVARCHAR(15)
           ,@c_PrevSKU          NVARCHAR(20)

    SELECT @c_uPickDetailKey = master.dbo.fnc_GetCharASCII(14)
          ,@c_PrevStorerKey = master.dbo.fnc_GetCharASCII(14)
          ,@c_PrevSKU = master.dbo.fnc_GetCharASCII(14)

    WHILE (1=1)
    BEGIN

        SELECT TOP 1 @c_uPickDetailKey = PickDetailKey
              ,@c_uOrderKey = OrderKey
              ,@c_uOrderLineNumber = OrderLineNumber
              ,@c_ulot = lot
              ,@c_uStorerKey = StorerKey
              ,@c_usku = sku
              ,@c_uuom = uom
              ,@c_uPackKey = PackKey
              ,@n_uqty = qty
              ,@c_utoloc = loc
              ,@c_utoid = id
              ,@d_uEffectiveDate = EffectiveDate
              ,@n_uChannel_ID = Channel_ID -- SWT02 
        FROM   INSERTED
        WHERE  PickDetailKey > @c_uPickDetailKey
               AND STATUS = '9'
               AND updatesource = '0'
        ORDER BY PickDetailKey
        IF @@ROWCOUNT=0
        BEGIN
           BREAK
        END
                
        SELECT @c_uChannel = Channel -- SWT02 
        FROM ORDERDETAIL AS o WITH (NOLOCK)
        WHERE o.OrderKey = @c_uOrderKey
        AND o.OrderLineNumber = @c_uOrderLineNumber 

        IF @n_continue=1 OR @n_continue=2
        BEGIN
            SELECT @n_pallet = 0
                  ,@n_CaseCnt = 0
                  ,@n_InnerPack = 0
                  ,@f_OtherUnit1 = 0.0
                  ,@f_OtherUnit2 = 0.0
                  ,@f_NetWgt = 0.0
                  ,@f_GrossWgt = 0.0
                  ,@f_tare = 0.0

            SELECT @c_uuom =  dbo.fnc_RTRIM(@c_uuom)
            IF @c_uuom='1'
                SELECT @n_pallet = 1

            IF @c_uuom='2'
                SELECT @n_CaseCnt = 1

            IF @c_uuom='3'
                SELECT @n_InnerPack = 1

            IF @c_uuom='4'
                SELECT @f_OtherUnit1 = 1.0

            IF @c_uuom='5'
                SELECT @f_OtherUnit2 = 1.0

            IF @c_catchweight='1'
            BEGIN
                IF @c_PrevStorerKey<>@c_uStorerKey
                   OR @c_PrevSKU<>@c_usku
                BEGIN
                    SELECT @c_ioflag = ISNULL(IOFlag ,'N')
                          ,@f_tare = ISNULL(TareWeight ,0)
                    FROM   SKU WITH (NOLOCK)
                    WHERE  Sku = @c_usku
                           AND StorerKey = @c_uStorerKey

                    SELECT @c_PrevStorerKey = @c_uStorerKey
                          ,@c_PrevSKU = @c_usku
                END

                IF @c_ioflag IN ('O' ,'B')
                BEGIN
                    SELECT @f_NetWgt = ISNULL(SUM(Wgt) ,0)
                    FROM   LOTxIDDETAIL WITH (NOLOCK)
                    WHERE  PickDetailKey = @c_uPickDetailKey
                           AND IOFlag = 'O'

                    IF @f_NetWgt>0
                    BEGIN
                        SELECT @f_GrossWgt = @f_NetWgt+@f_tare*@n_uqty
                    END
                END
            END

            /*SOS 131697*/
            /*CS01 start*/
            SELECT @c_Lottable01 = Lottable01
                  ,@c_Lottable02 = Lottable02
                  ,@c_Lottable03 = Lottable03
                  ,@d_Lottable04 = Lottable04
                  ,@d_Lottable05 = Lottable05
                  ,@c_Lottable06 = Lottable06
                  ,@c_Lottable07 = Lottable07
                  ,@c_Lottable08 = Lottable08
                  ,@c_Lottable09 = Lottable09
                  ,@c_Lottable10 = Lottable10
                  ,@c_Lottable11 = Lottable11
                  ,@c_Lottable12 = Lottable12
                  ,@d_Lottable13 = Lottable13
                  ,@d_Lottable14 = Lottable14
                  ,@d_Lottable15 = Lottable15
            FROM   LOTATTRIBUTE WITH (NOLOCK)
            WHERE  LOT = @c_ulot
            
            SELECT @c_uChannel = ci.Channel 
            FROM ChannelInv AS ci WITH(NOLOCK)
     WHERE ci.Channel_ID = @n_uChannel_ID

            SELECT @b_success = 0
            EXECUTE nspItrnAddWithdrawal 
               @n_ItrnSysId     =   NULL,
               @c_StorerKey     =   @c_uStorerKey,
               @c_Sku           =   @c_usku,
               @c_Lot           =   @c_ulot,
               @c_ToLoc         =   @c_utoloc,
               @c_ToID          =   @c_utoid,
               @c_Status        =   '',
               @c_Lottable01    =   @c_Lottable01,
               @c_Lottable02    =   @c_Lottable02,
               @c_Lottable03    =   @c_Lottable03,
               @d_Lottable04    =   @d_Lottable04,
               @d_Lottable05    =   @d_Lottable05,
               @c_Lottable06    =   @c_Lottable06,
               @c_Lottable07    =   @c_Lottable07,
               @c_Lottable08    =   @c_Lottable08,
               @c_Lottable09    =   @c_Lottable09,
               @c_Lottable10    =   @c_Lottable10,
               @c_Lottable11    =   @c_Lottable11,
               @c_Lottable12    =   @c_Lottable12,
               @d_Lottable13    =   @d_Lottable13,
               @d_Lottable14    =   @d_Lottable14,
               @d_Lottable15    =   @d_Lottable15,
               @c_Channel       =   @c_uChannel, 
               @n_Channel_ID    =   @n_uChannel_ID, 
               @n_casecnt       =   @n_CaseCnt,
               @n_innerpack     =   @n_InnerPack,
               @n_qty           =   @n_uqty,
               @n_pallet        =   @n_pallet,
               @f_cube          =   0,
               @f_grosswgt      =   @f_GrossWgt,
               @f_netwgt        =   @f_NetWgt,
               @f_otherunit1    =   @f_OtherUnit1,
               @f_otherunit2    =   @f_OtherUnit2,
               @c_SourceKey     =   @c_uPickDetailKey,
               @c_SourceType    =   'ntrPickDetailUpdate',
               @c_PackKey       =   @c_uPackkey,
               @c_UOM           =   @c_uuom,
               @b_UOMCalc       =   0,
               @d_EffectiveDate =   @d_uEffectiveDate,
               @c_itrnkey       =   '',
               @b_Success       =   @b_success OUTPUT,  
               @n_err           =   @n_err     OUTPUT,
               @c_errmsg        =   @c_errmsg  OUTPUT
               
            /*Cs01 End*/
            IF @b_success<>1
            BEGIN
                SELECT @n_continue = 3
            END
        END-- IF @n_continue =1 or @n_continue = 2
    END -- WHILE
    --SET ROWCOUNT 0
END -- IF @n_continue = 1 or @n_continue=2

-- MC01-S
IF ( @n_continue = 1 or @n_continue = 2 ) AND 
( UPDATE(QTY) OR UPDATE(LOT) OR UPDATE(LOC) OR UPDATE(ID) )
BEGIN
   IF EXISTS(SELECT 1 FROM StorerConfig WITH (NOLOCK)
             WHERE StorerKey = @c_StorerKey AND ConfigKey = 'WAVEUPDLOG' AND sValue = '1')
   BEGIN

      INSERT INTO PickDetail_Log (OrderKey ,OrderLineNumber ,WaveKey ,StorerKey
                                 ,B_SKU ,B_LOT ,B_LOC ,B_ID ,B_QTY
                                 ,A_SKU ,A_LOT ,A_LOC ,A_ID ,A_QTY
                                 ,Status ,PickDetailKey)
      SELECT DELETED.OrderKey ,DELETED.OrderLineNumber ,WaveDetail.Wavekey ,DELETED.Storerkey
            ,DELETED.Sku      ,DELETED.Lot             ,DELETED.Loc        ,DELETED.ID         ,DELETED.Qty
            ,INSERTED.Sku     ,INSERTED.Lot            ,INSERTED.Loc       ,INSERTED.ID        ,INSERTED.Qty
            ,'0'              ,DELETED.PickDetailKey
      FROM  INSERTED
      JOIN  DELETED ON INSERTED.PickDetailKey = DELETED.PickDetailKey
      JOIN  WaveDetail WITH (NOLOCK) ON ( WaveDetail.Orderkey = DELETED.Orderkey )
      WHERE EXISTS ( SELECT 1 FROM Transmitlog3 WITH (NOLOCK)
                     WHERE Tablename = 'WAVERESLOG'
                     AND Key1 = WaveDetail.Wavekey
                     AND Key3 = DELETED.Storerkey
                     AND TransmitFlag > '0' )

   END -- IF EXISTS(StorerConfig - 'WAVEUPDLOG')
END
-- MC01-E

--NJOW02 -S
IF (@n_Continue=1 or @n_Continue=2)
   AND UPDATE(Status)
   AND EXISTS(SELECT 1 FROM INSERTED
              JOIN DELETED ON INSERTED.Pickdetailkey = DELETED.Pickdetailkey
              WHERE INSERTED.Status='5' AND DELETED.Status <> INSERTED.Status)
BEGIN
    SELECT @b_success = 0
   Execute nspGetRight @c_Facility,  -- facility
             @c_StorerKey,    -- StorerKey
             null,            -- Sku
             'IDToDropID',      -- Configkey
             @b_success    output,
             @c_authority  output,
             @n_err        output,
             @c_errmsg     output
   IF @b_success <> 1
   BEGIN
      SELECT @n_Continue = 3, @c_errmsg = 'ntrPickDetailUpdate' + rtrim(@c_errmsg)
      GOTO QUIT
   END
   ELSE IF @c_authority = '1'
   BEGIN
        UPDATE PICKDETAIL  
        SET PICKDETAIL.DropID = PICKDETAIL.ID,
           PICKDETAIL.TrafficCop = NULL
        FROM PICKDETAIL
        JOIN INSERTED ON PICKDETAIL.Pickdetailkey = INSERTED.Pickdetailkey
        JOIN ORDERS (NOLOCK) ON INSERTED.Orderkey = ORDERS.Orderkey
        JOIN CODELKUP CL (NOLOCK) ON ORDERS.Storerkey = CL.Storerkey AND ORDERS.Type = CL.Code
                                  AND CL.Listname = 'IDTODROPID'
   END
END
--NJOW02 -E

--NJOW03 -S
IF (@n_Continue=1 or @n_Continue=2)
   AND UPDATE(Qty)
   AND EXISTS(SELECT 1 FROM INSERTED
              JOIN DELETED ON INSERTED.Pickdetailkey = DELETED.Pickdetailkey
              WHERE INSERTED.Status='4' AND DELETED.Qty > INSERTED.Qty)
BEGIN

   DECLARE @n_ShortQty INT

   SELECT @b_success = 0
   Execute nspGetRight @c_Facility,  -- facility
            @c_StorerKey,    -- StorerKey
            null,            -- Sku
            'AutoMoveShortPick_SP',      -- Configkey
            @b_success    output,
            @c_authority  output,
            @n_err        output,
            @c_errmsg     output

   IF @b_success <> 1
   BEGIN
      SELECT @n_Continue = 3, @c_errmsg = 'ntrPickDetailUpdate' + rtrim(@c_errmsg)
      GOTO QUIT
   END
   ELSE IF LEN(ISNULL(RTRIM(@c_authority),'')) > 1
   BEGIN

        SET @c_uPickDetailKey = ''
        WHILE (1=1) AND (@n_Continue=1 or @n_Continue=2)
        BEGIN

         SELECT TOP 1 @c_uPickDetailKey = INSERTED.PickDetailKey,
                @n_ShortQty = DELETED.Qty - INSERTED.Qty
         FROM INSERTED
         JOIN DELETED ON INSERTED.Pickdetailkey = DELETED.Pickdetailkey
         WHERE INSERTED.PickDetailKey > @c_uPickDetailKey
         AND INSERTED.Status='4' AND DELETED.Qty > INSERTED.Qty
         ORDER BY INSERTED.PickDetailKey

         IF @@ROWCOUNT = 0
         BEGIN
             BREAK
         END

         SELECT @b_Success = 0

         EXECUTE dbo.isp_AutoMoveShortPick_Wrapper
                 @c_uPickDetailKey
               , @n_ShortQty
               , @b_Success OUTPUT
               , @n_Err     OUTPUT
               , @c_ErrMsg  OUTPUT

         IF @b_Success <> 1
         BEGIN
            SELECT @n_Continue = 3, @c_errmsg = 'ntrPickDetailUpdate ' + rtrim(@c_errmsg)
         END
      END
   END
END
--NJOW03 -E

-- tlting02
IF @n_Continue = 1 OR @n_Continue = 2
BEGIN
   IF @c_AllowOverAllocations = "0"
   BEGIN
      IF EXISTS(SELECT 1 FROM LOTxLOCxID (NOLOCK), INSERTED --NJOW02
                WHERE INSERTED.Lot = LOTxLOCxID.Lot
                AND INSERTED.Loc = LOTxLOCxID.Loc
                AND INSERTED.Id = LOTxLOCxID.Id
                AND (LOTxLOCxID.QTYALLOCATED + LOTxLOCxID.QTYPICKED) > LOTxLOCxID.QTY)
      BEGIN
         SELECT @n_Continue = 3 , @n_err = 61620
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": An Attempt Was Made by OverAllocate is Turn OFF. (ntrPickDetailUpdate)"
      END
   END
END

IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
BEGIN
   UPDATE PICKDETAIL  
   SET EditDate = GETDATE(), EditWho=SUSER_SNAME(),
       TrafficCop = NULL                            -- tlting01
   FROM PICKDETAIL,INSERTED
   WHERE PICKDETAIL.PickDetailKey=INSERTED.PickDetailKey
   AND INSERTED.[status] = '9'                     -- tlting01
   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   IF @n_err <> 0
   BEGIN
      SELECT @n_continue = 3
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61620
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On PickDetail. (ntrPickDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '
   END
END

   /* #INCLUDE <TRPDU2.SQL> */

QUIT:

IF @n_continue=3
BEGIN
   DECLARE @n_IsRDT INT
   EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT

   IF @n_IsRDT = 1
   BEGIN
      -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
      -- Instead we commit AND raise an error back to parent, let the parent decide

      -- Commit until the level we BEGIN with
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
   EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPickDetailUpdate'
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
GO
ALTER TABLE [dbo].[PICKDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_PICKDETAIL_Qty] CHECK (([Qty]>=(0)))
GO
ALTER TABLE [dbo].[PICKDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_PICKDETAIL_Status] CHECK ((rtrim([Status]) like '[0-9]'))
GO
ALTER TABLE [dbo].[PICKDETAIL] ADD CONSTRAINT [PKPickDetail] PRIMARY KEY CLUSTERED ([PickDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PICKDETAIL_CASEID] ON [dbo].[PICKDETAIL] ([CaseID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PICKDETAIL_DropID] ON [dbo].[PICKDETAIL] ([DropID], [Storerkey], [Status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PICKDETAIL_ID] ON [dbo].[PICKDETAIL] ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PICKDETAIL9] ON [dbo].[PICKDETAIL] ([Loc]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_PICKDETAIL_Lotxlocxid] ON [dbo].[PICKDETAIL] ([Lot], [Loc], [ID]) INCLUDE ([ShipFlag], [Status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PICKDETAIL_ORDERKEY] ON [dbo].[PICKDETAIL] ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PICKDETAIL_OrderDetStatus] ON [dbo].[PICKDETAIL] ([OrderKey], [OrderLineNumber], [Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PICKDETAIL12] ON [dbo].[PICKDETAIL] ([OrderKey], [PickHeaderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PICKDETAIL10] ON [dbo].[PICKDETAIL] ([OrderKey], [Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_pickdetail_pickslipno] ON [dbo].[PICKDETAIL] ([PickSlipNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PICKDETAIL_TaskDetailKey] ON [dbo].[PICKDETAIL] ([TaskDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PICKDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_PICKDETAIL_LOT_01] FOREIGN KEY ([Storerkey], [Sku], [Lot]) REFERENCES [dbo].[LOTATTRIBUTE] ([StorerKey], [Sku], [Lot])
GO
ALTER TABLE [dbo].[PICKDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_PICKDETAIL_LOTLOCID_01] FOREIGN KEY ([Lot], [Loc], [ID]) REFERENCES [dbo].[LOTxLOCxID] ([Lot], [Loc], [Id])
GO
ALTER TABLE [dbo].[PICKDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_PICKDETAIL_SKU_01] FOREIGN KEY ([Storerkey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
GRANT SELECT ON  [dbo].[PICKDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PICKDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PICKDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PICKDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PICKDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodities in the warehouse can be identified with a variety of labels, each referring to the product by a different name or item number', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'AltSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton Group', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'CartonGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton Type', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'CartonType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Case id', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'CaseID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Do Cartonization', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'DoCartonize'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Drop Id refers to the pallet in which the items', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'DropID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Effective Date', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable Unit ID for the Commodity being picked', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location Picked', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique re-populated numeric value associated with a specific product.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment Order number. It''s used to identify a specific shipment order record. Automatically generated', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order detail line number. System generated', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'OrderLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack code associated with the transaction when it was entered', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of pickdetail which is picking and system will auto generated pickdetail number', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'PickDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick Ticket #', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'PickHeaderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Pick Slip.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick Qty', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity Moved', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'QtyMoved'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'SourceType', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'SourceType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Picked Status', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer/seller of the products being shipped (Owner of the goods)', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Task number', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'TaskDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location to which to move the Commodity to', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'ToLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure associated with the transaction when it was entered', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated with the transaction, calculated in the UOM associated with the transaction', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'UOMQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update Source', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'UpdateSource'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'WaveKey'
GO
