SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: msp_CreateSOPickMBOLTask                           */
/* Creation Date: 03-Apr-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: FCR-11898 BEL Create SO Pickdetail MBOL and Taskdetail      */
/*                                                                      */
/* Called By: Q-Commander                                               */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Rev   Purposes                                  */
/*2026-04-03    JihHaur 1.0   Initial Version                           */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[msp_CreateSOPickMBOLTask]
(
    @c_StorerKey     NVARCHAR(15)
  , @c_Facility      NVARCHAR(5)
  , @c_Loc           NVARCHAR(10)
  , @b_Success          INT            = 0   OUTPUT
  , @n_Err              INT            = 0   OUTPUT
  , @c_ErrMsg           NVARCHAR(225)  = ''  OUTPUT
  , @b_Debug            INT            = 0   
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue         INT,
           @n_StartTranCount   INT

   DECLARE @c_OrderKey         NVARCHAR(10),
           @c_ExternOrderKey   NVARCHAR(50),
           @c_ConsigneeKey     NVARCHAR(18),
           @c_MBOLKey          NVARCHAR(10),
           @c_PickDetailKey    NVARCHAR(18),
           @c_PickHeaderKey    NVARCHAR(18),
           @c_TaskDetailKey    NVARCHAR(10),
           @n_OrderLineNo      INT,
           @n_MBOLLineNo       INT

   DECLARE @c_AutoAllocate     NVARCHAR(30),
           @c_AutoPick         NVARCHAR(30)

   DECLARE @c_Notes2           NVARCHAR(4000),
           @c_StorerCountry    NVARCHAR(30),
           @c_StorerSUSR3     NVARCHAR(18),
           @n_TotalGrossWgt    FLOAT,
           @n_TotalCube        FLOAT,
           @n_PalletCnt        INT

   SELECT @b_success = 1, @n_err = 0, @c_errmsg = '', @n_Continue = 1, @n_StartTranCount = @@TRANCOUNT

   ---------------------------------------------------------------------------
   -- STEP 0: Validate - Check if any SO already created for this LOC
   --         (ORDERS.UserDefine04 = LOC, Status <> '9' and <> 'CANC')
   ---------------------------------------------------------------------------
   IF @n_Continue = 1
   BEGIN
      IF EXISTS (
         SELECT 1
         FROM ORDERS WITH (NOLOCK)
         WHERE StorerKey = @c_StorerKey
           AND RTRIM(UserDefine04) = @c_Loc
           AND [Status] NOT IN ('9', 'CANC')
      )
      BEGIN
         -- SO already exists for this location, skip all processing
         SET @n_Continue = 3
         SET @n_err = 64000
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                       + ': SO already exists for LOC ' + RTRIM(@c_Loc)
                       + ' (msp_CreateSOPickMBOLTask)'
         GOTO RETURN_SP
      END
   END

   ---------------------------------------------------------------------------
   -- STEP 0.1: Validate - Check inventory exists in this LOC
   ---------------------------------------------------------------------------
   IF @n_Continue = 1
   BEGIN
      IF NOT EXISTS (
         SELECT 1
         FROM LOTXLOCXID WITH (NOLOCK)
         WHERE StorerKey = @c_StorerKey
           AND Loc = @c_Loc
           AND Qty > 0
      )
      BEGIN
         SET @n_Continue = 3
         SET @n_err = 64001
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                       + ': No inventory found in LOC ' + RTRIM(@c_Loc)
                       + ' for Storer ' + RTRIM(@c_StorerKey)
                       + ' (msp_CreateSOPickMBOLTask)'
         GOTO RETURN_SP
      END
   END

   ---------------------------------------------------------------------------
   -- STEP 0.2: Validate - Check if PickDetail already exists for this LOC
   --           (Status <> '9' means not yet shipped)
   ---------------------------------------------------------------------------
   IF @n_Continue = 1
   BEGIN
      IF EXISTS (
         SELECT 1
         FROM PICKDETAIL WITH (NOLOCK)
         WHERE Loc = @c_Loc
           AND [Status] <> '9'
      )
      BEGIN
         SET @n_Continue = 3
         SET @n_err = 64002
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                       + ': Active PickDetail already exists for LOC ' + RTRIM(@c_Loc)
                       + ' (msp_CreateSOPickMBOLTask)'
         GOTO RETURN_SP
      END
   END

   ---------------------------------------------------------------------------
   -- STEP 0.3: Read StorerConfig flags
   ---------------------------------------------------------------------------
   IF @n_Continue = 1
   BEGIN
      -- AutoAllocate flag
      SET @c_AutoAllocate = '0'
      SELECT TOP 1 @c_AutoAllocate = ISNULL(RTRIM(SValue), '0')
      FROM StorerConfig WITH (NOLOCK)
      WHERE StorerKey = @c_StorerKey
        AND ConfigKey = 'AutoAllocate'
        AND Facility = CASE WHEN ISNULL(RTRIM(Facility), '') = '' THEN Facility ELSE @c_Facility END
        AND SValue = '1'

      -- AutoPick flag
      SET @c_AutoPick = '0'
      SELECT TOP 1 @c_AutoPick = ISNULL(RTRIM(SValue), '0')
      FROM StorerConfig WITH (NOLOCK)
      WHERE StorerKey = @c_StorerKey
        AND ConfigKey = 'AutoPick'
        AND Facility = CASE WHEN ISNULL(RTRIM(Facility), '') = '' THEN Facility ELSE @c_Facility END
        AND SValue = '1'
   END

   ---------------------------------------------------------------------------
   -- Prepare temp table for inventory grouped by Lottable01 (ConsigneeKey)
   -- Each distinct Lottable01 = 1 SO (Order)
   -- Within each order, group by SKU+LOC+ID (different SKU in same LOC/ID
   -- = different order lines, same SKU grouped together ignoring LOT)
   ---------------------------------------------------------------------------
   IF @n_Continue = 1
   BEGIN
      CREATE TABLE #TMP_CONSIGNEE (
         ConsigneeKey   NVARCHAR(18),
         RowNum         INT IDENTITY(1,1)
      )

      INSERT INTO #TMP_CONSIGNEE (ConsigneeKey)
      SELECT DISTINCT LA.Lottable01
      FROM LOTXLOCXID LLI WITH (NOLOCK)
      JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON LA.Lot = LLI.Lot
      WHERE LLI.StorerKey = @c_StorerKey
        AND LLI.Loc = @c_Loc
        AND LLI.Qty > 0

      -- Order detail level: group by ConsigneeKey, SKU, LOC, ID
      -- (1 LOT per pickdetail, but order lines group same SKU ignoring LOT)
      CREATE TABLE #TMP_ORDERLINE (
         ConsigneeKey   NVARCHAR(18),
         SKU            NVARCHAR(20),
         Loc            NVARCHAR(10),
         ID             NVARCHAR(18),
         TotalQty       INT,
         PackKey        NVARCHAR(10),
         PackUOM3       NVARCHAR(10),
         Facility       NVARCHAR(5)
      )

      INSERT INTO #TMP_ORDERLINE (ConsigneeKey, SKU, Loc, ID, TotalQty, PackKey, PackUOM3, Facility)
      SELECT LA.Lottable01,
             LLI.SKU,
             LLI.Loc,
             LLI.ID,
             SUM(LLI.Qty),
             MAX(S.PackKey),
             MAX(P.PackUOM3),
             MAX(S.Facility)
      FROM LOTXLOCXID LLI WITH (NOLOCK)
      JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON LA.Lot = LLI.Lot
      JOIN SKU S WITH (NOLOCK) ON S.StorerKey = LLI.StorerKey AND S.SKU = LLI.SKU
      JOIN PACK P WITH (NOLOCK) ON P.PackKey = S.PackKey
      WHERE LLI.StorerKey = @c_StorerKey
        AND LLI.Loc = @c_Loc
        AND LLI.Qty > 0
      GROUP BY LA.Lottable01, LLI.SKU, LLI.Loc, LLI.ID

      -- LOT-level detail for pickdetail (1 LOT = 1 pickdetail)
      CREATE TABLE #TMP_PICKLINE (
         ConsigneeKey   NVARCHAR(18),
         SKU            NVARCHAR(20),
         Lot            NVARCHAR(10),
         Loc            NVARCHAR(10),
         ID             NVARCHAR(18),
         Qty            INT,
         PackKey        NVARCHAR(10),
         PackUOM3       NVARCHAR(10),
         Facility       NVARCHAR(5),
         Lottable01     NVARCHAR(18),
         Lottable02     NVARCHAR(18),
         Lottable03     NVARCHAR(18),
         Lottable04     DATETIME NULL,
         Lottable05     DATETIME NULL,
         Lottable06     NVARCHAR(30),
         Lottable07     NVARCHAR(30),
         Lottable08     NVARCHAR(30),
         Lottable09     NVARCHAR(30),
         Lottable10     NVARCHAR(30),
         Lottable11     NVARCHAR(30),
         Lottable12     NVARCHAR(30),
         Lottable13     DATETIME NULL,
         Lottable14     DATETIME NULL,
         Lottable15     DATETIME NULL,
         OrderKey       NVARCHAR(10) NULL,
         OrderLineNo    NVARCHAR(5) NULL
      )

      INSERT INTO #TMP_PICKLINE (ConsigneeKey, SKU, Lot, Loc, ID, Qty,
                                  PackKey, PackUOM3, Facility,
                                  Lottable01, Lottable02, Lottable03,
                                  Lottable04, Lottable05,
                                  Lottable06, Lottable07, Lottable08,
                                  Lottable09, Lottable10, Lottable11,
                                  Lottable12, Lottable13, Lottable14, Lottable15)
      SELECT LA.Lottable01,
             LLI.SKU,
             LLI.Lot,
             LLI.Loc,
             LLI.ID,
             LLI.Qty,
             S.PackKey,
             P.PackUOM3,
             S.Facility,
             LA.Lottable01, LA.Lottable02, LA.Lottable03,
             LA.Lottable04, LA.Lottable05,
             LA.Lottable06, LA.Lottable07, LA.Lottable08,
             LA.Lottable09, LA.Lottable10, LA.Lottable11,
             LA.Lottable12, LA.Lottable13, LA.Lottable14, LA.Lottable15
      FROM LOTXLOCXID LLI WITH (NOLOCK)
      JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON LA.Lot = LLI.Lot
      JOIN SKU S WITH (NOLOCK) ON S.StorerKey = LLI.StorerKey AND S.SKU = LLI.SKU
      JOIN PACK P WITH (NOLOCK) ON P.PackKey = S.PackKey
      WHERE LLI.StorerKey = @c_StorerKey
        AND LLI.Loc = @c_Loc
        AND LLI.Qty > 0
   END

   ---------------------------------------------------------------------------
   -- Get Storer info for MBOL and ORDERS.Notes2
   ---------------------------------------------------------------------------
   IF @n_Continue = 1
   BEGIN
      -- Notes2 = Storer.Address1 - Storer.Address2
      -- where Storer.Type = 2 AND Storer.ConsigneeFor = LOTATTRIBUTE.StorerKey
      -- AND Storer.Address1 = LOTATTRIBUTE.lottable01
      -- We will set this per order inside the cursor

      -- Storer Country and SUSR3 for MBOL
      SELECT TOP 1 @c_StorerCountry = ISNULL(RTRIM(S.Country), ''),
                    @c_StorerSUSR3 = ISNULL(RTRIM(S.SUSR3), '')
      FROM STORER S WITH (NOLOCK)
      WHERE S.StorerKey = @c_StorerKey
   END

   ---------------------------------------------------------------------------
   -- STEP 1: Create Orders - Loop per ConsigneeKey (Lottable01)
   ---------------------------------------------------------------------------
   DECLARE CUR_CONSIGNEE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT ConsigneeKey
      FROM #TMP_CONSIGNEE
      ORDER BY RowNum

   OPEN CUR_CONSIGNEE
   FETCH NEXT FROM CUR_CONSIGNEE INTO @c_ConsigneeKey

   WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
   BEGIN
      -- Get new OrderKey
      SET @b_success = 1
      EXECUTE nspg_GetKey
             'ORDER',
             10,
             @c_OrderKey OUTPUT,
             @b_success  OUTPUT,
             @n_err      OUTPUT,
             @c_errmsg   OUTPUT

      IF NOT @b_success = 1
      BEGIN
         SET @n_Continue = 3
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                       + ': Error getting OrderKey for ConsigneeKey '
                       + RTRIM(@c_ConsigneeKey) + ' (msp_CreateSOPickMBOLTask)'
         GOTO RETURN_SP
      END

      SET @c_ExternOrderKey = RTRIM(@c_StorerKey) + RTRIM(@c_OrderKey)

      -- Get Notes2: Storer.Address1 - Storer.Address2 where Type=2, ConsigneeFor=StorerKey, Address1=Lottable01
      SET @c_Notes2 = ''
      SELECT TOP 1 @c_Notes2 = ISNULL(RTRIM(S.Address1), '') + '-' + ISNULL(RTRIM(S.Address2), '')
      FROM STORER S WITH (NOLOCK)
      WHERE S.[Type] = '2'
        AND S.ConsigneeFor = @c_StorerKey
        AND RTRIM(S.Address1) = RTRIM(@c_ConsigneeKey)

      -- Begin transaction for this order group
      BEGIN TRAN

      -----------------------------------------------------------------------
      -- INSERT INTO ORDERS
      -----------------------------------------------------------------------
      INSERT INTO ORDERS (
         OrderKey, StorerKey, ExternOrderKey, OrderDate, DeliveryDate,
         ConsigneeKey, OpenQty, [Status], [Type], OrderGroup,
         EffectiveDate, SOStatus, Facility, UserDefine04, Notes2
      )
      VALUES (
         @c_OrderKey,
         @c_StorerKey,
         @c_ExternOrderKey,
         GETDATE(),
         GETDATE(),
         @c_ConsigneeKey,
         0,          -- Will be updated after OD inserts
         '0',        -- Normal
         '0',        -- Standard
         '',
         GETDATE(),
         '0',
         @c_Facility,
         @c_Loc,
         @c_Notes2
      )

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_err = 64010
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                       + ': Error inserting ORDERS for ConsigneeKey '
                       + RTRIM(@c_ConsigneeKey) + ' (msp_CreateSOPickMBOLTask)'
         GOTO RETURN_SP
      END

      -----------------------------------------------------------------------
      -- INSERT INTO ORDERDETAIL - one line per distinct SKU+LOC+ID
      -----------------------------------------------------------------------
      SET @n_OrderLineNo = 0

      DECLARE CUR_ORDERLINE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT OL.SKU, OL.ID, OL.TotalQty, OL.PackKey, OL.PackUOM3, OL.Facility
         FROM #TMP_ORDERLINE OL
         WHERE OL.ConsigneeKey = @c_ConsigneeKey
         ORDER BY OL.SKU, OL.ID

      OPEN CUR_ORDERLINE

      DECLARE @c_OL_SKU        NVARCHAR(20),
              @c_OL_ID         NVARCHAR(18),
              @n_OL_Qty        INT,
              @c_OL_PackKey    NVARCHAR(10),
              @c_OL_UOM        NVARCHAR(10),
              @c_OL_Facility   NVARCHAR(5),
              @c_OL_Lot        NVARCHAR(10),
              @n_OL_Capacity   FLOAT,
              @n_OL_GrossWgt   FLOAT

      FETCH NEXT FROM CUR_ORDERLINE INTO @c_OL_SKU, @c_OL_ID, @n_OL_Qty,
                                          @c_OL_PackKey, @c_OL_UOM, @c_OL_Facility

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         SET @n_OrderLineNo = @n_OrderLineNo + 1

         -- Get first LOT for this SKU+ID combination (for orderdetail.Lot)
         SELECT TOP 1 @c_OL_Lot = PL.Lot
         FROM #TMP_PICKLINE PL
         WHERE PL.ConsigneeKey = @c_ConsigneeKey
           AND PL.SKU = @c_OL_SKU
           AND PL.ID = @c_OL_ID

         -- Get Pallet dimensions for Capacity and GrossWeight
         SET @n_OL_Capacity = 0
         SET @n_OL_GrossWgt = 0
         SELECT @n_OL_Capacity = ISNULL(PAL.[Length] * PAL.Width * PAL.Height, 0),
                @n_OL_GrossWgt = ISNULL(PAL.GrossWgt, 0)
         FROM PALLET PAL WITH (NOLOCK)
         WHERE PAL.PalletKey = @c_OL_ID

         -- Get Lottable values from first LOT record for this line
         DECLARE @c_Lottable01 NVARCHAR(18), @c_Lottable02 NVARCHAR(18), @c_Lottable03 NVARCHAR(18),
                 @d_Lottable04 DATETIME, @d_Lottable05 DATETIME,
                 @c_Lottable06 NVARCHAR(30), @c_Lottable07 NVARCHAR(30), @c_Lottable08 NVARCHAR(30),
                 @c_Lottable09 NVARCHAR(30), @c_Lottable10 NVARCHAR(30), @c_Lottable11 NVARCHAR(30),
                 @c_Lottable12 NVARCHAR(30), @d_Lottable13 DATETIME, @d_Lottable14 DATETIME, @d_Lottable15 DATETIME

         SELECT TOP 1
                @c_Lottable01  = PL.Lottable01,  @c_Lottable02  = PL.Lottable02,
                @c_Lottable03  = PL.Lottable03,  @d_Lottable04  = PL.Lottable04,
                @d_Lottable05  = PL.Lottable05,  @c_Lottable06  = PL.Lottable06,
                @c_Lottable07  = PL.Lottable07,  @c_Lottable08  = PL.Lottable08,
                @c_Lottable09  = PL.Lottable09,  @c_Lottable10  = PL.Lottable10,
                @c_Lottable11  = PL.Lottable11,  @c_Lottable12  = PL.Lottable12,
                @d_Lottable13  = PL.Lottable13,  @d_Lottable14  = PL.Lottable14,
                @d_Lottable15  = PL.Lottable15
         FROM #TMP_PICKLINE PL
         WHERE PL.ConsigneeKey = @c_ConsigneeKey
           AND PL.SKU = @c_OL_SKU
           AND PL.ID = @c_OL_ID

         INSERT INTO ORDERDETAIL (
            OrderKey, OrderLineNumber, ExternOrderKey, ExternLineNo,
            Sku, StorerKey, OriginalQty, OpenQty, UOM, PackKey,
            Lot, ID, Facility, [Status],
            Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
            EffectiveDate, Capacity, GrossWeight,
            UserDefine01, UserDefine05, UserDefine06, UserDefine07,
            Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
            Lottable11, Lottable12, Lottable13, Lottable14, Lottable15
         )
         VALUES (
            @c_OrderKey,
            RIGHT('00000' + CAST(@n_OrderLineNo AS NVARCHAR(5)), 5),
            @c_ExternOrderKey,
            RIGHT('00000' + CAST(@n_OrderLineNo AS NVARCHAR(5)), 5),   -- ExternLineNo = OrderLineNumber
            @c_OL_SKU,
            @c_StorerKey,
            @n_OL_Qty,           -- OriginalQty
            @n_OL_Qty,           -- OpenQty
            @c_OL_UOM,           -- PACK.PackUOM3
            @c_OL_PackKey,       -- SKU.PackKey
            @c_OL_Lot,           -- LOTATTRIBUTE.LOT (first lot for this SKU+ID)
            @c_OL_ID,            -- LOTxLOCxID.ID
            @c_OL_Facility,      -- SKU.Facility
            '0',                 -- NORMAL
            @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05,
            GETDATE(),
            @n_OL_Capacity,      -- Pallet.Length * Width * Height
            @n_OL_GrossWgt,      -- Pallet.GrossWeight
            RIGHT('00000' + CAST(@n_OrderLineNo AS NVARCHAR(5)), 5),   -- UserDefine01 = OrderLineNo
            CAST(@n_OL_Qty AS NVARCHAR(18)),                           -- UserDefine05 = OpenQty
            CAST(@n_OL_Capacity AS NVARCHAR(18)),                      -- UserDefine06 = Capacity
            CAST(@n_OL_GrossWgt AS NVARCHAR(18)),                      -- UserDefine07 = GrossWeight
            @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10,
            @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15
         )

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_err = 64020
            SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                          + ': Error inserting ORDERDETAIL for Order '
                          + RTRIM(@c_OrderKey) + ' Line '
                          + CAST(@n_OrderLineNo AS NVARCHAR(5))
                          + ' (msp_CreateSOPickMBOLTask)'
            GOTO RETURN_SP
         END

         -- Update #TMP_PICKLINE with OrderKey and OrderLineNo for pickdetail creation later
         UPDATE #TMP_PICKLINE
         SET OrderKey = @c_OrderKey,
             OrderLineNo = RIGHT('00000' + CAST(@n_OrderLineNo AS NVARCHAR(5)), 5)
         WHERE ConsigneeKey = @c_ConsigneeKey
           AND SKU = @c_OL_SKU
           AND ID = @c_OL_ID

         FETCH NEXT FROM CUR_ORDERLINE INTO @c_OL_SKU, @c_OL_ID, @n_OL_Qty,
                                             @c_OL_PackKey, @c_OL_UOM, @c_OL_Facility
      END

      CLOSE CUR_ORDERLINE
      DEALLOCATE CUR_ORDERLINE

      -----------------------------------------------------------------------
      -- STEP 2: Create PickSlip (PickHeader) for this Order
      --         then Auto-Allocate (insert PickDetail with Status = 0)
      --         1 LOT = 1 PickDetail record
      -----------------------------------------------------------------------
      IF @n_Continue = 1 AND @c_AutoAllocate = '1'
      BEGIN
         -- Create PickSlip (PickHeader) for this OrderKey
         SET @c_PickHeaderKey = ''
         EXEC isp_CreatePickSlip
                  @c_Orderkey           = @c_OrderKey
                , @c_LinkPickSlipToPick = 'N'
                , @c_ConsolidateByLoad  = 'N'
                , @c_AutoScanIn         = 'Y'
                , @c_Refkeylookup       = ''
                , @c_PickslipType       = ''
                , @b_Success            = @b_Success OUTPUT
                , @n_Err                = @n_err     OUTPUT
                , @c_ErrMsg             = @c_errmsg  OUTPUT

         IF @b_Success = 0
         BEGIN
            SET @n_Continue = 3
            SET @n_err = 64015
            SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                          + ': Error executing isp_CreatePickSlip for Order# '
                          + RTRIM(@c_OrderKey) + ' (msp_CreateSOPickMBOLTask)'
            GOTO RETURN_SP
         END

         -- Retrieve the PickHeaderKey created by isp_CreatePickSlip
         SELECT @c_PickHeaderKey = PH.PickHeaderKey
         FROM PICKHEADER PH WITH (NOLOCK)
         WHERE PH.OrderKey = @c_OrderKey

         DECLARE CUR_PICKLINE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT PL.SKU, PL.Lot, PL.Loc, PL.ID, PL.Qty,
                   PL.PackKey, PL.PackUOM3, PL.OrderKey, PL.OrderLineNo
            FROM #TMP_PICKLINE PL
            WHERE PL.ConsigneeKey = @c_ConsigneeKey
            ORDER BY PL.OrderLineNo, PL.Lot

         OPEN CUR_PICKLINE

         DECLARE @c_PD_SKU       NVARCHAR(20),
                 @c_PD_Lot       NVARCHAR(10),
                 @c_PD_Loc       NVARCHAR(10),
                 @c_PD_ID        NVARCHAR(18),
                 @n_PD_Qty       INT,
                 @c_PD_PackKey   NVARCHAR(10),
                 @c_PD_UOM       NVARCHAR(10),
                 @c_PD_OrderKey  NVARCHAR(10),
                 @c_PD_OrdLine   NVARCHAR(5)

         FETCH NEXT FROM CUR_PICKLINE INTO @c_PD_SKU, @c_PD_Lot, @c_PD_Loc,
                                            @c_PD_ID, @n_PD_Qty,
                                            @c_PD_PackKey, @c_PD_UOM,
                                            @c_PD_OrderKey, @c_PD_OrdLine

         WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
         BEGIN
            -- Get PickDetailKey
            SET @b_success = 1
            EXECUTE nspg_GetKey
                   'PickDetailKey',
                   10,
                   @c_PickDetailKey OUTPUT,
                   @b_success       OUTPUT,
                   @n_err           OUTPUT,
                   @c_errmsg        OUTPUT

            IF NOT @b_success = 1
            BEGIN
               SET @n_Continue = 3
               SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                             + ': Error getting PickDetailKey for Order '
                             + RTRIM(@c_PD_OrderKey)
                             + ' (msp_CreateSOPickMBOLTask)'
               GOTO RETURN_SP
            END

            INSERT INTO PICKDETAIL (
               PickDetailKey, PickHeaderKey, OrderKey, OrderLineNumber,
               Lot, StorerKey, Sku, UOM, UOMQty, Qty,
               [Status], Loc, ID, PackKey, PickMethod, WaveKey
            )
            VALUES (
               @c_PickDetailKey,
               @c_PickHeaderKey,
               @c_PD_OrderKey,
               @c_PD_OrdLine,
               @c_PD_Lot,
               @c_StorerKey,
               @c_PD_SKU,
               @c_PD_UOM,
               @n_PD_Qty,
               @n_PD_Qty,
               '0',            -- Allocated status
               @c_PD_Loc,
               @c_PD_ID,
               @c_PD_PackKey,
               'D',            -- Discrete
               ''
            )

            IF @@ERROR <> 0
            BEGIN
               SET @n_Continue = 3
               SET @n_err = 64030
               SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                             + ': Error inserting PICKDETAIL for Order '
                             + RTRIM(@c_PD_OrderKey) + ' Lot '
                             + RTRIM(@c_PD_Lot) + ' (msp_CreateSOPickMBOLTask)'
               GOTO RETURN_SP
            END

            -----------------------------------------------------------------
            -- STEP 3: Auto-Pick (update PickDetail.Status = 5)
            -----------------------------------------------------------------
            IF @c_AutoPick = '1'
            BEGIN
               UPDATE PICKDETAIL
               SET [Status]    = '5',
                   EditDate    = GETDATE(),
                   EditWho     = SUSER_SNAME()
               WHERE PickDetailKey = @c_PickDetailKey

               IF @@ERROR <> 0
               BEGIN
                  SET @n_Continue = 3
                  SET @n_err = 64035
                  SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                                + ': Error updating PICKDETAIL status to 5 for '
                                + RTRIM(@c_PickDetailKey)
                                + ' (msp_CreateSOPickMBOLTask)'
                  GOTO RETURN_SP
               END
            END

            FETCH NEXT FROM CUR_PICKLINE INTO @c_PD_SKU, @c_PD_Lot, @c_PD_Loc,
                                               @c_PD_ID, @n_PD_Qty,
                                               @c_PD_PackKey, @c_PD_UOM,
                                               @c_PD_OrderKey, @c_PD_OrdLine
         END

         CLOSE CUR_PICKLINE
         DEALLOCATE CUR_PICKLINE
      END -- End AutoAllocate

      COMMIT TRAN

      FETCH NEXT FROM CUR_CONSIGNEE INTO @c_ConsigneeKey
   END -- End ConsigneeKey Loop

   CLOSE CUR_CONSIGNEE
   DEALLOCATE CUR_CONSIGNEE

   ---------------------------------------------------------------------------
   -- STEP 4: Create MBOL and MBOLDetail
   --         Only if AutoPick = 1 (pickdetail updated to 5)
   --         1 MbolKey per LOC (all SOs in same LOC share 1 MBOL)
   ---------------------------------------------------------------------------
   IF @n_Continue = 1 AND @c_AutoAllocate = '1' AND @c_AutoPick = '1'
   BEGIN
      BEGIN TRAN

      -- Get MBOLKey
      SET @b_success = 1
      EXECUTE nspg_GetKey
             'MBOL',
             10,
             @c_MBOLKey OUTPUT,
             @b_success  OUTPUT,
             @n_err      OUTPUT,
             @c_errmsg   OUTPUT

      IF NOT @b_success = 1
      BEGIN
         SET @n_Continue = 3
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                       + ': Error getting MBOLKey (msp_CreateSOPickMBOLTask)'
         GOTO RETURN_SP
      END

      -- Calculate aggregates for MBOL from Pallet table
      SELECT @n_TotalGrossWgt = ISNULL(SUM(PAL.GrossWgt), 0),
             @n_TotalCube     = ISNULL(SUM(PAL.[Length] * PAL.Width * PAL.Height), 0),
             @n_PalletCnt     = COUNT(DISTINCT LLI.ID)
      FROM LOTXLOCXID LLI WITH (NOLOCK)
      JOIN PALLET PAL WITH (NOLOCK) ON PAL.PalletKey = LLI.ID
      WHERE LLI.StorerKey = @c_StorerKey
        AND LLI.Loc = @c_Loc
        AND LLI.Qty > 0

      INSERT INTO MBOL (
         MbolKey, [Status], DestinationCountry, VesselQualifier,
         PlaceOfdelivery, VoyageNumber,
         DepartureDate, ArrivalDate, ArrivalDateFinalDestination,
         OtherReference, EffectiveDate, LoadingDate,
         TotalInvoiceValue, GrossWeight, Capacity, InvoiceAmount,
         [Weight], Cube, PalletCnt, CaseCnt,
         Facility, COD_Status, DepotStatus,
         UserDefine06, UserDefine07, UserDefine08,
         ShipCounter, CTNTYPE, NoofContainer,
         Route
      )
      VALUES (
         @c_MBOLKey,
         '0',                          -- Status = 0 (No need to ship)
         ISNULL(@c_StorerCountry, ''), -- STORER.COUNTRY
         'VM',
         ISNULL(@c_StorerSUSR3, ''),  -- STORER.SUSR3
         '99',
         GETDATE(),                    -- DepartureDate
         GETDATE(),                    -- ArrivalDate
         GETDATE(),                    -- ArrivalDateFinalDestination
         @c_Loc,                       -- OtherReference = LOTxLOCxID.LOC
         GETDATE(),                    -- EffectiveDate
         GETDATE(),                    -- LoadingDate
         0,                            -- TotalInvoiceValue
         @n_TotalGrossWgt,             -- GrossWeight = SUM Pallet.GrossWeight
         0,                            -- Capacity
         0,                            -- InvoiceAmount
         @n_TotalGrossWgt,             -- Weight = SUM Pallet.GrossWeight
         @n_TotalCube,                 -- Cube = SUM Pallet.L*W*H
         @n_PalletCnt,                 -- PalletCnt
         0,                            -- CaseCnt
         @c_Facility,                  -- Facility
         '0',                          -- COD_Status
         '0',                          -- DepotStatus
         NULL,                         -- UserDefine06
         NULL,                         -- UserDefine07
         'N',                          -- UserDefine08
         0,                            -- ShipCounter
         NULL,                         -- CTNTYPE
         NULL,                         -- NoofContainer
         @c_Loc                        -- Route = LOTxLOCxID.LOC
      )

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_err = 64040
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                       + ': Error inserting MBOL (msp_CreateSOPickMBOLTask)'
         GOTO RETURN_SP
      END

      -----------------------------------------------------------------------
      -- INSERT MBOLDetail - 1 line per pallet (ID) across all orders in this LOC
      -----------------------------------------------------------------------
      SET @n_MBOLLineNo = 0

      DECLARE CUR_MBOLDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT DISTINCT PL.OrderKey, PL.ID
         FROM #TMP_PICKLINE PL
         WHERE PL.OrderKey IS NOT NULL
         ORDER BY PL.OrderKey, PL.ID

      OPEN CUR_MBOLDETAIL

      DECLARE @c_MD_OrderKey  NVARCHAR(10),
              @c_MD_ID        NVARCHAR(18),
              @n_MD_GrossWgt  FLOAT

      FETCH NEXT FROM CUR_MBOLDETAIL INTO @c_MD_OrderKey, @c_MD_ID

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         SET @n_MBOLLineNo = @n_MBOLLineNo + 1

         -- Get Pallet GrossWeight for this MBOLDetail line
         SET @n_MD_GrossWgt = 0
         SELECT @n_MD_GrossWgt = ISNULL(PAL.GrossWgt, 0)
         FROM PALLET PAL WITH (NOLOCK)
         WHERE PAL.PalletKey = @c_MD_ID

         INSERT INTO MBOLDETAIL (
            MbolKey, MbolLineNumber, OrderKey, PalletKey,
            OrderDate, ExternOrderKey, DeliveryDate, DeliveryStatus,
            GrossWeight, Capacity, InvoiceAmount, [Weight], Cube,
            TotalCartons, UserDefine06, UserDefine07, UserDefine08,
            CtnCnt1, CtnCnt2, CtnCnt3, CtnCnt4, CtnCnt5,
            TotCtnCube, TotCtnWeight
         )
         VALUES (
            @c_MBOLKey,
            RIGHT('00000' + CAST(@n_MBOLLineNo AS NVARCHAR(5)), 5),
            @c_MD_OrderKey,
            @c_MD_ID,                  -- PalletKey = LOTxLOCxID.ID
            GETDATE(),                 -- OrderDate
            @c_MD_OrderKey,            -- ExternOrderKey = Orders.OrderKey
            GETDATE(),                 -- DeliveryDate
            '0',                       -- DeliveryStatus
            @n_MD_GrossWgt,            -- GrossWeight = Pallet.GrossWeight
            0,                         -- Capacity
            0,                         -- InvoiceAmount
            0,                         -- Weight
            0,                         -- Cube
            0,                         -- TotalCartons
            NULL,                      -- UserDefine06
            NULL,                      -- UserDefine07
            'N',                       -- UserDefine08
            0, 0, 0, 0, 0,            -- CtnCnt1-5
            0, 0                       -- TotCtnCube, TotCtnWeight
         )

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_err = 64045
            SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                          + ': Error inserting MBOLDETAIL line '
                          + CAST(@n_MBOLLineNo AS NVARCHAR(5))
                          + ' (msp_CreateSOPickMBOLTask)'
            GOTO RETURN_SP
         END

         FETCH NEXT FROM CUR_MBOLDETAIL INTO @c_MD_OrderKey, @c_MD_ID
      END

      CLOSE CUR_MBOLDETAIL
      DEALLOCATE CUR_MBOLDETAIL

      -----------------------------------------------------------------------
      -- Update all created Orders with MBOLKey
      -----------------------------------------------------------------------
      UPDATE OH
      SET OH.MBOLKey    = @c_MBOLKey,
          OH.TrafficCop = NULL,
          OH.EditDate   = GETDATE(),
          OH.EditWho    = SUSER_SNAME()
      FROM ORDERS OH
      WHERE OH.OrderKey IN (SELECT DISTINCT PL.OrderKey FROM #TMP_PICKLINE PL WHERE PL.OrderKey IS NOT NULL)

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_err = 64046
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                       + ': Error updating ORDERS.MBOLKey (msp_CreateSOPickMBOLTask)'
         GOTO RETURN_SP
      END

      -- Update all ORDERDETAIL with MBOLKey
      UPDATE OD
      SET OD.MBOLKey = @c_MBOLKey
      FROM ORDERDETAIL OD
      WHERE OD.OrderKey IN (SELECT DISTINCT PL.OrderKey FROM #TMP_PICKLINE PL WHERE PL.OrderKey IS NOT NULL)

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_err = 64047
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                       + ': Error updating ORDERDETAIL.MBOLKey (msp_CreateSOPickMBOLTask)'
         GOTO RETURN_SP
      END

      -----------------------------------------------------------------------
      -- Run isp_MBOLToTransportOrder to create TMS records
      -----------------------------------------------------------------------
      EXEC isp_MBOLToTransportOrder
               @c_MBOLkey  = @c_MBOLkey   
            ,  @b_Success  = @b_Success   OUTPUT 
            ,  @n_err      = @n_err       OUTPUT 
            ,  @c_errmsg   = @c_errmsg    OUTPUT
            
      IF @b_Success = 0 
      BEGIN
         SET @n_Continue = 3
         GOTO RETURN_SP
      END       

      COMMIT TRAN

      -----------------------------------------------------------------------
      -- STEP 5: Create TaskDetail (ASTLO) - 1 task per ID (pallet)
      --         Only created after SO generated, Allocated, Picked and MBOL created
      -----------------------------------------------------------------------
      BEGIN TRAN

      DECLARE CUR_TASK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT DISTINCT PL.Loc, PL.ID
         FROM #TMP_PICKLINE PL
         WHERE PL.OrderKey IS NOT NULL
         ORDER BY PL.ID

      OPEN CUR_TASK

      DECLARE @c_TD_Loc       NVARCHAR(10),
              @c_TD_ID        NVARCHAR(18)

      FETCH NEXT FROM CUR_TASK INTO @c_TD_Loc, @c_TD_ID

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         -- Get TaskDetailKey
         SET @b_success = 1
         EXECUTE nspg_GetKey
                'TaskDetailKey',
                10,
                @c_TaskDetailKey OUTPUT,
                @b_success       OUTPUT,
                @n_err           OUTPUT,
                @c_errmsg        OUTPUT

         IF NOT @b_success = 1
         BEGIN
            SET @n_Continue = 3
            GOTO RETURN_SP
         END

         INSERT INTO TaskDetail (
            TaskDetailKey, TaskType, StorerKey, Sku, Lot, UOM, UOMQty, Qty,
            FromLoc, LogicalFromLoc, FromID,
            ToLoc, LogicalToLoc, ToID,
            CaseID, PickMethod, [Status], StatusMsg,
            [Priority], SourcePriority,
            HoldKey, UserKey, UserPosition, UserKeyOverRide,
            StartTime, EndTime,
            SourceType, SourceKey, PickDetailKey,
            OrderKey, OrderLineNumber,
            ListKey, WaveKey, ReasonKey,
            Message01, Message02, Message03,
            TrafficCop, ArchiveCop,
            SystemQty, RefTaskKey, LoadKey,
            AreaKey, DropID, TransitCount, TransitLOC,
            FinalLOC, FinalID, PendingMoveIn, QtyReplen
         )
         VALUES (
            @c_TaskDetailKey,
            'ASTLO',            -- TaskType
            @c_StorerKey,       -- StorerKey
            '',                 -- Sku (empty - 1 task per pallet, not per SKU)
            '',                 -- Lot (empty - 1 task per pallet, not per LOT)
            '',                 -- UOM (empty)
            0,                  -- UOMQty
            0,                  -- Qty (empty - pallet level task)
            @c_TD_Loc,          -- FromLoc = LOTxLOCxID.LOC
            @c_TD_Loc,          -- LogicalFromLoc = LOTxLOCxID.LOC
            @c_TD_ID,           -- FromID = LOTxLOCxID.ID
            '',                 -- ToLoc (unknown at this point)
            '',                 -- LogicalToLoc
            '',                 -- ToID
            '',                 -- CaseID
            'FP',               -- PickMethod
            '0',                -- Status
            '',                 -- StatusMsg
            '5',                -- Priority
            '9',                -- SourcePriority
            '',                 -- HoldKey
            '',                 -- UserKey
            '1',                -- UserPosition
            '',                 -- UserKeyOverRide
            GETDATE(),          -- StartTime
            GETDATE(),          -- EndTime
            '',                 -- SourceType
            '',                 -- SourceKey
            '',                 -- PickDetailKey
            '',                 -- OrderKey
            '',                 -- OrderLineNumber
            '',                 -- ListKey
            '',                 -- WaveKey
            '',                 -- ReasonKey
            '',                 -- Message01
            '',                 -- Message02
            '',                 -- Message03
            NULL,               -- TrafficCop
            NULL,               -- ArchiveCop
            0,                  -- SystemQty (empty - pallet level task)
            '',                 -- RefTaskKey
            '',                 -- LoadKey
            'BESE_ALL',         -- AreaKey
            '',                 -- DropID
            0,                  -- TransitCount
            '',                 -- TransitLOC
            '',                 -- FinalLOC (unknown at this point)
            '',                 -- FinalID
            0,                  -- PendingMoveIn
            0                   -- QtyReplen
         )

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_err = 64050
            SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                          + ': Error inserting TaskDetail for ID '
                          + RTRIM(@c_TD_ID) + ' (msp_CreateSOPickMBOLTask)'
            GOTO RETURN_SP
         END

         FETCH NEXT FROM CUR_TASK INTO @c_TD_Loc, @c_TD_ID
      END

      CLOSE CUR_TASK
      DEALLOCATE CUR_TASK

      COMMIT TRAN

   END -- End MBOL + TaskDetail creation

   ---------------------------------------------------------------------------
   -- RETURN_SP: Error handling and cleanup
   ---------------------------------------------------------------------------
RETURN_SP:

   -- Cleanup temp tables
   IF OBJECT_ID('tempdb..#TMP_CONSIGNEE') IS NOT NULL
      DROP TABLE #TMP_CONSIGNEE

   IF OBJECT_ID('tempdb..#TMP_ORDERLINE') IS NOT NULL
      DROP TABLE #TMP_ORDERLINE

   IF OBJECT_ID('tempdb..#TMP_PICKLINE') IS NOT NULL
      DROP TABLE #TMP_PICKLINE

   -- Cleanup cursors
   IF CURSOR_STATUS('LOCAL', 'CUR_CONSIGNEE') IN (0, 1)
   BEGIN
      CLOSE CUR_CONSIGNEE
      DEALLOCATE CUR_CONSIGNEE
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_ORDERLINE') IN (0, 1)
   BEGIN
      CLOSE CUR_ORDERLINE
      DEALLOCATE CUR_ORDERLINE
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_PICKLINE') IN (0, 1)
   BEGIN
      CLOSE CUR_PICKLINE
      DEALLOCATE CUR_PICKLINE
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_MBOLDETAIL') IN (0, 1)
   BEGIN
      CLOSE CUR_MBOLDETAIL
      DEALLOCATE CUR_MBOLDETAIL
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_TASK') IN (0, 1)
   BEGIN
      CLOSE CUR_TASK
      DEALLOCATE CUR_TASK
   END

   IF @n_Continue = 3  -- Error Occurred
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT > 0 AND @@TRANCOUNT > @n_StartTranCount
      BEGIN
         ROLLBACK TRAN
      END

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'msp_CreateSOPickMBOLTask'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTranCount
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO