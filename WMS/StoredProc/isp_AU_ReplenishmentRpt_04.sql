SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************/
/* Stored Procedure: isp_AU_ReplenishmentRpt_04                            */
/* Creation Date:  07-MAY-2025                                             */
/* Copyright: Maersk                                                       */
/* Written by: SYC067                                                      */
/*                                                                         */
/* Purpose: FCR-XXXX HILLS AU FMCG Replenishment, generate                 */
/*          replenishment from allocated qty                               */
/*                                                                         */
/* Called By: Replenishment Report                                         */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 2025-05-07   SYC067  1.0   Created                                      */
/* 2025-05-21   SYC067  1.1   Revise Split PDQty                           */
/* 2025-09-16   SYC067  1.2   Allow fixed pickface as candidate (SY02)     */
/* 2026-06-22   Michael 1.3   FCR-13583 correct REPORTCFG.Long value (ML01)*/
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_AU_ReplenishmentRpt_04]
               @c_zone01           NVARCHAR(10)
,              @c_zone02           NVARCHAR(10)
,              @c_zone03           NVARCHAR(10)
,              @c_zone04           NVARCHAR(10)
,              @c_zone05           NVARCHAR(10)
,              @c_zone06           NVARCHAR(10)
,              @c_zone07           NVARCHAR(10)
,              @c_zone08           NVARCHAR(10)
,              @c_zone09           NVARCHAR(10)
,              @c_zone10           NVARCHAR(10)
,              @c_zone11           NVARCHAR(10)
,              @c_zone12           NVARCHAR(10)
,              @c_storerkey        NVARCHAR(15)
,              @c_ReplGrp          NVARCHAR(30)       --PickZone
,              @c_Functype         NCHAR(1) = ''      --(Wan01)   --Wan02
,              @c_backendjob       NVARCHAR(10) = 'N' --NJOW02    --Wan02s
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE        @n_continue int          /* continuation flag
   1=Continue
   2=failed but continue processsing
   3=failed do not continue processing
   4=successful but skip furthur processing */
   DECLARE @b_debug           INT
         , @b_Success         INT
         , @n_Err             INT
         , @c_ErrMsg          NVARCHAR(255)
         , @c_SQL             NVARCHAR(MAX)=''
         , @c_SQLParm         NVARCHAR(MAX)=''
         , @c_Condition       NVARCHAR(MAX)=''
         , @c_ToCondition     NVARCHAR(MAX)=''
         , @c_Packkey         NVARCHAR(10)
         , @c_UOM             NVARCHAR(10)
         , @c_ToLocationType  NVARCHAR(10)
         , @n_CaseCnt         FLOAT
         , @n_InnerPack       FLOAT
         , @n_Pallet          FLOAT
         , @c_ReplenishmentGroup NVARCHAR(10)  --NJOW02
         , @c_FromLocType      NVARCHAR(10) = ''
         , @c_FromLocCat       NVARCHAR(20) = ''
         , @c_ToLocCat         NVARCHAR(20) = ''
         , @n_FromLessThanCase INT = 0
         , @n_FromLessThanInner INT = 0
         , @c_FromLocAisle    NVARCHAR(100) = ''
         , @c_FromLocBay  NVARCHAR(100) = ''
         , @c_OPriority       NVARCHAR(100) = ''
         , @c_LPPriority      NVARCHAR(100) = ''

   DECLARE @c_AlertMessage NVARCHAR(255)

   DECLARE @c_priority        NVARCHAR(5)
         , @c_ReplLottable01  NVARCHAR(18) --NJOW03
         , @c_ReplLottable02  NVARCHAR(18)
         , @c_ReplLottable03  NVARCHAR(18) --NJOW03
         , @d_ReplLottable04  DATETIME     --NJOW04
         , @d_ReplLottable05  DATETIME     --NJOW04
         , @c_ReplLottable06  NVARCHAR(30) --NJOW04
         , @c_ReplLottable07  NVARCHAR(30) --NJOW04
         , @c_ReplLottable08  NVARCHAR(30) --NJOW04
         , @c_ReplLottable09  NVARCHAR(30) --NJOW04
         , @c_ReplLottable10  NVARCHAR(30) --NJOW04
         , @c_ReplLottable11  NVARCHAR(30) --NJOW04
         , @c_ReplLottable12  NVARCHAR(30) --NJOW04
         , @d_ReplLottable13  DATETIME     --NJOW04
         , @d_ReplLottable14  DATETIME     --NJOW04
         , @d_ReplLottable15  DATETIME     --NJOW04
         , @c_NoReplenAlloPlt NVARCHAR(10)='N' --NJOW04
         , @c_CommingleSKUFlag NVARCHAR(10)='' --NJOW04
         , @c_ForceSKUABCFlag  NVARCHAR(10)=''
         , @c_CurrABCFlag     NVARCHAR(10)=''
         , @c_SKUABCFlag      NVARCHAR(10)=''
         , @c_PDString         NVARCHAR(MAX)=''
         , @c_PDRPLString      NVARCHAR(MAX)=''
         , @c_MoveRefKey      NVARCHAR(20)=''
         , @c_PickDetailKey   NVARCHAR(10)= ''
         , @c_Orderkey        NVARCHAR(10)= ''
         , @n_PDQty           INT
         , @n_SystemQty       INT
         , @c_CurrPickdetailKey NVARCHAR(10)= ''
         , @n_CurrPDQty       INT
         , @n_SplitQty        INT
         , @c_NewPickdetailKey NVARCHAR(10) = ''
         , @nLLITTLQty        INT
         , @n_SourceAvailQty  INT = 0

   SET @n_continue=1
   SET @b_debug = 0

   IF @c_zone12 = '1'
   BEGIN
      SET @b_debug = CAST( @c_zone12 AS int)
      SET @c_zone12 = ''
   END

   --(Wan01) - START
   IF RTRIM(@c_ReplGrp) = ''
   BEGIN
      SET @c_ReplGrp = 'ALL'
   END

   IF @c_FuncType IN ( 'P' )
   BEGIN
      GOTO QUIT_SP
   END
   --(Wan01) - END

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      --NJOW04
      CREATE TABLE #REPLENISHMENT (Storerkey      NVARCHAR(15),
                                   Sku            NVARCHAR(20),
                                   FromLoc        NVARCHAR(10),
                                   ToLoc          NVARCHAR(10),
                                   Lot            NVARCHAR(10),
                                   ID             NVARCHAR(18),
                                   Qty            INT,
                                   QtyMoved       INT,
                                   QtyInPickLoc   INT,
                                   Priority     NVARCHAR(5),
                                   UOM            NVARCHAR(10),
                                   Packkey        NVARCHAR(10),
                                   ReplLottable01 NVARCHAR(18) NULL,
                                   ReplLottable02 NVARCHAR(18) NULL,
                                   ReplLottable03 NVARCHAR(18) NULL,
                                   ReplLottable04 DATETIME     NULL,
                                   ReplLottable05 DATETIME     NULL,
                                   ReplLottable06 NVARCHAR(30) NULL,
                                   ReplLottable07 NVARCHAR(30) NULL,
                                   ReplLottable08 NVARCHAR(30) NULL,
                                   ReplLottable09 NVARCHAR(30) NULL,
                                   ReplLottable10 NVARCHAR(30) NULL,
                                   ReplLottable11 NVARCHAR(30) NULL,
                                   ReplLottable12 NVARCHAR(30) NULL,
                                   ReplLottable13 DATETIME     NULL,
                                   ReplLottable14 DATETIME     NULL,
                                   ReplLottable15 DATETIME     NULL,
                                   PDString       NVARCHAR(MAX) NULL
      )
      /*
      SELECT StorerKey
            ,SKU
            ,FromLOC  = LOC
            ,ToLOC        = LOC
            ,Lot
            ,Id              ,Qty
            ,QtyMoved     = Qty
            ,QtyInPickLOC = Qty
            ,Priority     = @c_priority
            ,UOM          = Lot
            ,PackKey      = Lot
            ,ReplLottable01  = @c_ReplLottable01  --NJOW03
            ,ReplLottable02  = @c_ReplLottable02
            ,ReplLottable03  = @c_ReplLottable03  --NJOW03
            ,ReplLottable04  = @d_ReplLottable04  --NJOW04
            ,ReplLottable05  = @d_ReplLottable05  --NJOW04
            ,ReplLottable06  = @c_ReplLottable06  --NJOW04
            ,ReplLottable07  = @c_ReplLottable07  --NJOW04
            ,ReplLottable08  = @c_ReplLottable08  --NJOW04
            ,ReplLottable09  = @c_ReplLottable09  --NJOW04
            ,ReplLottable10  = @c_ReplLottable10  --NJOW04
            ,ReplLottable11  = @c_ReplLottable11  --NJOW04
            ,ReplLottable12  = @c_ReplLottable12  --NJOW04
            ,ReplLottable13  = @d_ReplLottable13  --NJOW04
            ,ReplLottable14  = @d_ReplLottable14  --NJOW04
            ,ReplLottable15  = @d_ReplLottable15  --NJOW04
      INTO #REPLENISHMENT
      FROM LOTXLOCXID (NOLOCK)
      WHERE 1 = 2
      */
   END

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      DECLARE @n_InvCnt2                     INT
            , @n_InvCnt1                     INT      --NJOW03
            , @n_InvCnt3                     INT      --NJOW03
            , @n_InvCnt4                     INT      --NJOW04
            , @n_InvCnt5                     INT      --NJOW04
            , @n_InvCnt6                     INT      --NJOW04
            , @n_InvCnt7                     INT      --NJOW04
            , @n_InvCnt8                     INT      --NJOW04
            , @n_InvCnt9                     INT      --NJOW04
            , @n_InvCnt10                    INT      --NJOW04
            , @n_InvCnt11                    INT      --NJOW04
            , @n_InvCnt12                    INT      --NJOW04
            , @n_InvCnt13                    INT      --NJOW04
            , @n_InvCnt14                    INT      --NJOW04
            , @n_InvCnt15                    INT      --NJOW04
            , @n_InvCntSKU                   INT
            , @c_InvSKU                      NVARCHAR(20)
            , @c_CurrentStorer               NVARCHAR(15)
            , @c_CurrentSKU                  NVARCHAR(20)
            , @c_CurrentLoc                  NVARCHAR(10)
            , @c_CurrentPriority             NVARCHAR(5)
            , @n_Currentfullcase             INT
            , @n_CurrentSeverity             INT
            , @c_FromLOC                     NVARCHAR(10)
            , @c_Fromlot                     NVARCHAR(10)
            , @c_Fromid                      NVARCHAR(18)
            , @n_FromQty                     INT
            , @n_QtyAllocated                INT
            , @n_QtyPicked                   INT
            , @n_RemainingQty                INT
            , @n_numberofrecs                INT
            , @c_ReplenishmentKey            NVARCHAR(10)
            , @c_NoMixLottable02             NVARCHAR(10)
            , @c_Lottable02                  NVARCHAR(18)
            , @c_ReplValidationRules         NVARCHAR(10)
            , @c_NoMixLottable01             NVARCHAR(10)  --NJOW03
            , @c_Lottable01                  NVARCHAR(18)  --NJOW03
            , @c_NoMixLottable03             NVARCHAR(10)  --NJOW03
            , @c_Lottable03                  NVARCHAR(18)  --NJOW03
            , @c_NoMixLottable04             NVARCHAR(10)='0'  --NJOW04
            , @d_Lottable04                  DATETIME          --NJOW04
            , @c_NoMixLottable05             NVARCHAR(10)='0'  --NJOW04
            , @d_Lottable05                  DATETIME          --NJOW04
            , @c_NoMixLottable06             NVARCHAR(10)='0'  --NJOW04
            , @c_Lottable06                  NVARCHAR(18)=''   --NJOW04
            , @c_NoMixLottable07             NVARCHAR(10)='0'  --NJOW04
            , @c_Lottable07                  NVARCHAR(18)=' '  --NJOW04
            , @c_NoMixLottable08             NVARCHAR(10)='0'  --NJOW04
            , @c_Lottable08                  NVARCHAR(18)=''   --NJOW04
            , @c_NoMixLottable09             NVARCHAR(10)='0'  --NJOW04
            , @c_Lottable09                  NVARCHAR(18)=''   --NJOW04
            , @c_NoMixLottable10             NVARCHAR(10)='0'  --NJOW04
            , @c_Lottable10                  NVARCHAR(18)=''   --NJOW04
            , @c_NoMixLottable11             NVARCHAR(10)='0'  --NJOW04
            , @c_Lottable11                  NVARCHAR(18)=''   --NJOW04
            , @c_NoMixLottable12             NVARCHAR(10)='0'  --NJOW04
            , @c_Lottable12                  NVARCHAR(18)=''   --NJOW04
            , @c_NoMixLottable13             NVARCHAR(10)='0'  --NJOW04
            , @d_Lottable13                  DATETIME          --NJOW04
            , @c_NoMixLottable14             NVARCHAR(10)='0'  --NJOW04
            , @d_Lottable14                  DATETIME          --NJOW04
            , @c_NoMixLottable15             NVARCHAR(10)='0'  --NJOW04
            , @d_Lottable15                  DATETIME          --NJOW04
            , @cSkipReplenInner01            NVARCHAR(10) = ''

      SET @c_CurrentStorer    = ''
      SET @c_CurrentSKU       = ''
      SET @c_CurrentLoc       = ''
      SET @c_CurrentPriority  = ''
      SET @n_currentfullcase  = 0
      SET @n_CurrentSeverity  = 9999999
      SET @n_FromQty          = 0
      SET @n_RemainingQty     = 0
      SET @n_numberofrecs     = 0
      SET @c_ReplenishmentGroup = '' --NJOW02
      SET @c_NoMixLottable01  = '0'  --NJOW03
      SET @c_Lottable01       = ''   --NJOW03
      SET @c_NoMixLottable02  = '0'
      SET @c_Lottable02       = ''
      SET @c_NoMixLottable03  = '0'  --NJOW03
      SET @c_Lottable03       = ''   --NJOW03

      --NJOW04
      IF EXISTS(SELECT 1
                FROM CODELKUP (NOLOCK)
                WHERE Code =  'NoReplenAlloPlt'
                AND ListName = 'REPORTCFG'
                AND Long = 'r_AU_replenishment_report_04'   --ML01
                AND Storerkey = @c_storerkey
                AND ISNULL(Short,'') <> 'N')
      BEGIN
         SET @c_NoReplenAlloPlt = 'Y'
      END
      ELSE
      BEGIN
        SET @c_NoReplenAlloPlt = 'N'
      END

      SET @c_ForceSKUABCFlag = ''
      SELECT @c_ForceSKUABCFlag = SHORT
      FROM CODELKUP (NOLOCK)
      WHERE CODE = 'REPLForceSKUABC'
      AND ListName = 'REPORTCFG'
      AND Long = 'r_AU_replenishment_report_04'   --ML01
      AND Storerkey = @c_storerkey

      SET @cSkipReplenInner01 = ''
      SELECT @cSkipReplenInner01 = SHORT
      FROM CODELKUP (NOLOCK)
      WHERE CODE = 'SkipReplenInner01'
      AND ListName = 'REPORTCFG'
      AND Long = 'r_AU_replenishment_report_04'   --ML01
      AND Storerkey = @c_storerkey

      SELECT @c_Condition = Notes
      FROM CODELKUP (NOLOCK)
      WHERE Code =  'REPLCustomCondSQL'
      AND ListName = 'REPORTCFG'
      AND Long = 'r_AU_replenishment_report_04'   --ML01
      AND Storerkey = @c_storerkey
      AND ISNULL(Short,'') <> 'N'
      AND ISNULL(NOTES,'') <> ''
      AND ISNULL(NOTES,'') LIKE 'AND%'

      --not added yet
      SELECT @c_ToCondition = Notes
      FROM CODELKUP (NOLOCK)
      WHERE Code =  'REPLToCustomCondSQL'
      AND ListName = 'REPORTCFG'
      AND Long = 'r_AU_replenishment_report_04'   --ML01
      AND Storerkey = @c_storerkey
      AND ISNULL(Short,'') <> 'N'
      AND ISNULL(NOTES,'') <> ''
      AND ISNULL(NOTES,'') LIKE 'AND%'

      /* Make a temp version of SKUxLOC */
      --this is to group candidates of Tolocation for each SKU that was allocated
      --from empty Locations where Locationtype IN ('CASE', 'PICK')
      SELECT ORDERS.StorerKey
            ,LOC.Facility
            --,SKUXLOC.SKU
            ,LOC.LOC
            ,LOC.LocationType
            ,LOC.LogicalLocation
            ,LOC.LOCAISLE
            ,LOC.LOCBAY
      INTO #TempSKUxLOC
      FROM LOC (NOLOCK)
      JOIN ORDERS (NOLOCK) ON 1=2
      JOIN LOADPLAN (NOLOCK) ON 1=2
      --JOIN SKUXLOC (NOLOCK) ON 1=2
      WHERE 1=2

      INSERT #TempSKUxLOC
      SELECT @c_storerkey
       , L.Facility
       , L.Loc
       , L.LocationType
       , L.LogicalLocation
       , L.LocAisle
       , L.LocBay
      FROM LOC L WITH (NOLOCK)
      OUTER APPLY
      (
         SELECT SUM(QTY - QTYPICKED + PENDINGMOVEIN) AS qtyavail
         FROM LOTXLOCXID WITH (NOLOCK)
         WHERE LOC = L.LOC
      ) AS LLI
      WHERE L.FACILITY = @c_Zone01
      AND   L.LocationFlag NOT IN ('HOLD', 'DAMAGE')
      AND   L.LOCATIONTYPE NOT IN ('OTHER')
      AND   L.Status <> 'HOLD'

      -- DC - START
      -- Allow CLS pick shelving to be considered for CASE -> PICK replenishment.
      -- Original logic required CLS qtyavail = -1, which normally prevents CLS locations
      -- from being inserted into #TempSKUxLOC.
      AND (
         L.LOCATIONCATEGORY = 'CLS'

         OR ISNULL(LLI.qtyavail,0) =
         CASE
            WHEN EXISTS
            (
               SELECT TOP 1 1
               FROM SKUXLOC S WITH (NOLOCK)
               WHERE S.LOCATIONTYPE IN ('PICK','CASE')
                AND S.LOC = L.LOC
            )
            THEN ISNULL(LLI.qtyavail,0)
            ELSE 0
         END
      )
      -- DC - END
      --SY02 END

      /*
      SELECT ISNULL(SKUxLOC.ReplenishmentPriority, '')
            --,ReplenishmentSeverity = SKUxLOC.QtyLocationLimit - (SKUxLOC.Qty - SKUxLOC.QtyPicked)
            ,ReplenishmentSeverity = ISNULL(SKUxLOC.QtyLocationLimit,0) - ISNULL(SUM((LOTXLOCXID.Qty - LOTXLOCXID.QtyPicked) + LOTXLOCXID.PendingMoveIN),0) --NJOW02
            ,ISNULL(SKUxLOC.StorerKey,'')
            ,ISNULL(SKUxLOC.SKU, '')
            ,ISNULL(SKUxLOC.LOC,'')
            ,ISNULL(SKUxLOC.QtyLocationLimit,0)
            ,ISNULL(LOC.Locationtype,'')
      FROM SKUxLOC    WITH (NOLOCK)
      JOIN LOC        WITH (NOLOCK) ON (SKUxLOC.Loc = LOC.Loc)
      LEFT JOIN LOTXLOCXID WITH (NOLOCK) ON (SKUxLOC.Storerkey = LOTXLOCXID.Storerkey AND SKUxLOC.Sku = LOTXLOCXID.Sku AND SKUxLOC.Loc = LOTXLOCXID.Loc) --NJOW02
      OUTER APPLY (
      SELECT SUM(QTYALLOCATED) AS ALLOCQTY
           FROM LOTXLOCXID WITH (NOLOCK)
           WHERE STORERKEY = SKUXLOC.STORERKEY
           AND SKU = SKUXLOC.SKU
           ) AS AL --CHECK SKUS THAT HAS ALLOCATED STOCKS ONLY
      WHERE (SKUxLOC.Storerkey = @c_Storerkey OR @c_Storerkey = 'ALL')
      AND   (SKUxLOC.LOCationtype = 'CASE' or SKUxLOC.LOCationtype = 'PALLET' or SKUxLOC.LOCationtype = 'PICK')
      --AND   SKUxLOC.ReplenishmentCasecnt > 0
      AND   SKUxLOC.QtyExpected <= 0
      AND   SKUXLOC.QtyAllocated > 0
      AND   SKUxLOC.Qty - SKUxLOC.QtyPicked <= SKUxLOC.QtyLocationMinimum
      AND   (LOC.PutawayZone IN (@c_zone02, @c_zone03, @c_zone04, @c_zone05, @c_zone06, @c_zone07, @c_zone08, @c_zone09, @c_zone10, @c_zone11, @c_zone12)
      OR    @c_zone02 = 'ALL')
      AND   LOC.FACILITY = @c_Zone01
      AND   (LOC.PickZone= @c_ReplGrp OR @c_ReplGrp = 'ALL')
      AND   LOC.LocationFlag NOT IN ('HOLD', 'DAMAGE')
      AND   LOC.Status <> 'HOLD'
      AND   ISNULL(AL.ALLOCQTY,0) > 0
      GROUP BY SKUxLOC.ReplenishmentPriority
             , SKUxLOC.StorerKey
             , SKUxLOC.SKU
             , SKUxLOC.LOC
             , SKUxLOC.Qty
             , SKUxLOC.QtyPicked
             , SKUxLOC.QtyAllocated
             , SKUxLOC.QtyLocationMinimum
             , SKUxLOC.QtyLocationLimit
             , LOC.Locationtype
      HAVING  ISNULL(SKUxLOC.Qty,0)- ISNULL(SKUxLOC.QtyPicked,0) + SUM(ISNULL(LOTXLOCXID.PendingMoveIN,0)) <= ISNULL(SKUxLOC.QtyLocationMinimum,0) --NJOW02
      --HAVING SKUxLOC.QtyLocationLimit - ISNULL(SUM((LOTXLOCXID.Qty - LOTXLOCXID.QtyPicked) + LOTXLOCXID.PendingMoveIN),0) <= SKUxLOC.QtyLocationMinimum --NJOW02
      ORDER  By SKUxLOC.StorerKey
            , SKUxLOC.SKU
             , SKUxLOC.LOC
      */

      IF @@ROWCOUNT > 0  AND ISNULL(@c_ReplGrp,'') IN ('ALL','') --NJOW02
      BEGIN
         EXECUTE nspg_GetKey
            'REPLENGROUP',
            9,
            @c_ReplenishmentGroup OUTPUT,
            @b_success OUTPUT,
            @n_err OUTPUT,
            @c_errmsg OUTPUT

         IF @b_success = 1
            SELECT @c_ReplenishmentGroup = 'T' + @c_ReplenishmentGroup
      END
      ELSE
         SET @c_ReplenishmentGroup = @c_ReplGrp

      /* Loop through List of Replen Required (from locations)*/
      --1. CHECK IF LOCATION IS ALLOCATED TO MORE THAN 1 ORDERS
      --LOTxLOCxID.LOC <> @c_CurrentLoc
      --AND LOTxLOCxID.StorerKey = @c_CurrentStorer
      --AND LOTxLOCxID.SKU = @c_CurrentSku
      --AND LOC.LocationType IN (CASE WHEN @c_ReplGrp = ''CASE'' THEN @c_ReplGrp ELSE ''PALLET'' END
      --                           ,''CASE'',''PICK'')
      --CASE WHEN @c_NoMixLottable01 = '1' AND @n_InvCnt1 > 0 THEN ' AND LOTATTRIBUTE.Lottable01 = @c_Lottable01 ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable02 = '1' AND @n_InvCnt2 > 0 THEN  ' AND LOTATTRIBUTE.Lottable02 = @c_Lottable02 ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable03 = '1' AND @n_InvCnt3 > 0 THEN ' AND LOTATTRIBUTE.Lottable03 = @c_Lottable03 ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable04 = '1' AND @n_InvCnt4 > 0  AND CONVERT(NVARCHAR(8) ,@d_Lottable04 ,112) <> '19000101' AND @d_Lottable04 IS NOT NULL
      --     THEN ' AND LOTATTRIBUTE.Lottable04 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable04, 106)) ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable05 = '1' AND @n_InvCnt5 > 0  AND CONVERT(NVARCHAR(8) ,@d_Lottable05 ,112) <> '19000101' AND @d_Lottable05 IS NOT NULL
      --     THEN ' AND LOTATTRIBUTE.Lottable05 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable05, 106)) ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable06 = '1' AND @n_InvCnt6 > 0 THEN ' AND LOTATTRIBUTE.Lottable06 = @c_Lottable06 ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable07 = '1' AND @n_InvCnt7 > 0 THEN ' AND LOTATTRIBUTE.Lottable07 = @c_Lottable07 ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable08 = '1' AND @n_InvCnt8 > 0 THEN ' AND LOTATTRIBUTE.Lottable08 = @c_Lottable08 ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable09 = '1' AND @n_InvCnt9 > 0 THEN ' AND LOTATTRIBUTE.Lottable09 = @c_Lottable09 ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable10 = '1' AND @n_InvCnt10 > 0 THEN ' AND LOTATTRIBUTE.Lottable10 = @c_Lottable10 ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable11 = '1' AND @n_InvCnt11 > 0 THEN ' AND LOTATTRIBUTE.Lottable11 = @c_Lottable11 ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable12 = '1' AND @n_InvCnt12 > 0 THEN ' AND LOTATTRIBUTE.Lottable12 = @c_Lottable12 ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable13 = '1' AND @n_InvCnt13 > 0  AND CONVERT(NVARCHAR(8) ,@d_Lottable13 ,112) <> '19000101' AND @d_Lottable13 IS NOT NULL
      --     THEN ' AND LOTATTRIBUTE.Lottable13 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable13, 106)) ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable14 = '1' AND @n_InvCnt14 > 0  AND CONVERT(NVARCHAR(8) ,@d_Lottable14 ,112) <> '19000101' AND @d_Lottable14 IS NOT NULL
      --     THEN ' AND LOTATTRIBUTE.Lottable14 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable14, 106)) ' ELSE ' ' END +
      --CASE WHEN @c_NoMixLottable15 = '1' AND @n_InvCnt15 > 0  AND CONVERT(NVARCHAR(8) ,@d_Lottable15 ,112) <> '19000101' AND @d_Lottable15 IS NOT NULL
      --     THEN ' AND LOTATTRIBUTE.Lottable15 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable15, 106)) ' ELSE ' ' END +

      --      ,  CASE WHEN (LOTxLOCxID.Qty - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyPicked - LOTxLOCxID.QtyReplen) < @n_Pallet THEN 1   --NJOW02
      --              ELSE 2
      --              END
      --NJOW04 S
      SET @c_SQL = N'
      DECLARE CUR_REPL CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT LOTxLOCxID.LOT
            ,LOTxLOCxID.Loc
            ,LOTxLOCxID.ID
            ,LOTXLOCXID.SKU
            ,LOTxLOCxID.Qty
            --,LOTxLOCxID.Qty - LOTxLOCxID.QtyPicked - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyReplen   -- (ang01)  --NJOW02
            ,LOTxLOCxID.QtyAllocated
            ,LOTxLOCxID.QtyPicked
            ,LOTATTRIBUTE.Lottable01, LOTATTRIBUTE.Lottable02 ,LOTATTRIBUTE.Lottable03 ,LOTATTRIBUTE.Lottable04 ,LOTATTRIBUTE.Lottable05
            ,LOTATTRIBUTE.Lottable06 ,LOTATTRIBUTE.Lottable07 ,LOTATTRIBUTE.Lottable08 ,LOTATTRIBUTE.Lottable09 ,LOTATTRIBUTE.Lottable10
            ,LOTATTRIBUTE.Lottable11 ,LOTATTRIBUTE.Lottable12 ,LOTATTRIBUTE.Lottable13 ,LOTATTRIBUTE.Lottable14 ,LOTATTRIBUTE.Lottable15
            ,LOC.LocationType
            ,LOC.LocationCategory
            ,DEMAND.LESSTHANCASE
            ,DEMAND.LESSTHANINNER
            ,DEMAND.OPRIORITY
            ,DEMAND.LPPRIORITY
            ,DEMAND.PDSTRING
      FROM LOT          WITH (NOLOCK)
      JOIN LOTATTRIBUTE WITH (NOLOCK) ON (LOT.Lot      = LOTATTRIBUTE.LOT)
      JOIN LOTxLOCxID   WITH (NOLOCK) ON (LOT.Lot        = LOTxLOCxID.Lot)
      JOIN LOC          WITH (NOLOCK) ON (LOTxLOCxID.Loc = LOC.Loc)
      JOIN SKU          WITH (NOLOCK) ON SKU.SKU = LOTXLOCXID.Sku AND SKU.Storerkey = LOTXLOCXID.STORERKEY
      JOIN PACK         WITH (NOLOCK) ON SKU.PackKey = PACK.PackKey
      CROSS APPLY (
           SELECT COUNT(DISTINCT PD.ORDERKEY) AS ORDCNT
                , SUM(PD.QTY) AS ALLOCQTY
                , MIN(LP.PRIORITY) AS LPPRIORITY
                , MIN(O.PRIORITY) AS OPRIORITY
                , SUM(CASE WHEN P.CASECNT>0 THEN
                           CASE WHEN (PD.QTY % CAST(P.CASECNT AS INT)) > 0 THEN PD.QTY % CAST(P.CASECNT AS INT) ELSE 0 END
                           ELSE 0 END) AS LESSTHANCASE
                , SUM(CASE WHEN P.InnerPack > 0 THEN
                           CASE WHEN (PD.QTY % CAST(P.InnerPack AS INT)) > 0 THEN PD.QTY % CAST(P.InnerPack AS INT) ELSE 0 END
                           ELSE 0 END) AS LESSTHANINNER
                , STRING_AGG(PD.PICKDETAILKEY, '','') AS PDSTRING
                , MAX(PD.UOM) AS PDUOM
           FROM PICKDETAIL PD (NOLOCK)
           JOIN ORDERS O (NOLOCK) ON PD.ORDERKEY = O.ORDERKEY
           JOIN SKU S (NOLOCK) ON PD.SKU = S.SKU AND PD.STORERKEY = S.STORERKEY
           JOIN PACK P (NOLOCK) ON S.PACKKEY = P.PACKKEY
           LEFT JOIN LOADPLAN LP (NOLOCK) ON O.LOADKEY = LP.LOADKEY
           WHERE PD.STORERKEY = LOTXLOCXID.STORERKEY
           AND PD.LOC = LOC.LOC AND PD.STATUS IN (''0'')
           AND PD.SKU = LOTXLOCXID.SKU
           AND PD.LOT = LOT.LOT
           AND PD.ID  = LOTXLOCXID.ID
           AND ISNULL(PD.MOVEREFKEY,'''') <> ''CHECKED''
           AND ISNULL(PD.TASKDETAILKEY,'''') <> ''CHECKED''
           AND NOT EXISTS (SELECT TOP 1 1 FROM REPLENISHMENT (NOLOCK) WHERE CONFIRMED <> ''Y'' AND MOVEREFKEY = ISNULL(PD.MOVEREFKEY,'''')
                           AND ISNULL(PD.MOVEREFKEY,'''') <> '''')
           AND NOT EXISTS (SELECT TOP 1 1 FROM TASKDETAIL (NOLOCK) WHERE STATUS NOT IN (''9'',''X'') AND TASKDETAILKEY = ISNULL(PD.TASKDETAILKEY,'''')
                           AND ISNULL(PD.TASKDETAILKEY,'''') <> '''')
      ) AS DEMAND
      WHERE LOTxLOCxID.StorerKey = @c_storerkey
      AND ISNULL(LOTXLOCXID.QTY,0) > CASE WHEN DEMAND.PDUOM <> ''1'' AND LOC.LOCATIONTYPE IN (''BULK'',''PALLET'') THEN 0
                                          WHEN LOC.LOCATIONTYPE IN (''PICK'') AND LOC.LOCATIONCATEGORY <> ''CLS'' THEN ISNULL(LOTXLOCXID.QTY,0)
                                          WHEN LOC.LOCATIONTYPE IN (''PICK'') AND LOC.LOCATIONCATEGORY = ''CLS'' AND DEMAND.LESSTHANINNER <= 0 THEN ISNULL(LOTXLOCXID.QTY,0)
                                          WHEN DEMAND.LESSTHANCASE = 0 AND LOC.LOCATIONTYPE IN (''CASE'') THEN ISNULL(LOTXLOCXID.QTY,0)
                                          WHEN DEMAND.LESSTHANCASE > 0 AND LOC.LOCATIONTYPE NOT IN (''PICK'') THEN IIF(DEMAND.ORDCNT>1,0,DEMAND.ALLOCQTY)
                                          WHEN DEMAND.ORDCNT > 1 AND LOC.LOCATIONTYPE IN (''BULK'',''PALLET'') THEN 0
                                          ELSE DEMAND.ALLOCQTY END --ONLY select locations that was not fully allocated to single order
      AND LOC.Status <> ''HOLD''
      AND LOC.Facility = @c_Zone01
      AND(LOC.PutawayZone IN (@c_zone02, @c_zone03, @c_zone04, @c_zone05, @c_zone06, @c_zone07, @c_zone08, @c_zone09, @c_zone10, @c_zone11, @c_zone12)
      OR  @c_zone02 = ''ALL'')
      AND LOT.Status = ''OK''
      AND NOT EXISTS (SELECT TOP 1 1 FROM TASKDETAIL (NOLOCK) WHERE STORERKEY = @c_storerkey AND TASKTYPE IN (''FCP'',''FPK'') AND STATUS NOT IN (''9'',''X'')
                      AND FROMLOC = LOTXLOCXID.LOC AND LOC.LOCATIONTYPE = ''BULK'')
      AND NOT EXISTS (SELECT TOP 1 1 FROM TASKDETAIL (NOLOCK) WHERE STORERKEY = @c_storerkey AND TASKTYPE IN (''RPF'') AND PICKMETHOD = ''FP'' AND STATUS NOT IN (''9'',''X'')
                      AND FROMLOC = LOTXLOCXID.LOC AND FROMID = LOTXLOCXID.ID)
      AND LOC.LocationType NOT IN(''DAMAGE'')

      AND
      (
       NOT
       (
             LOC.LocationType = ''CASE''
             AND ISNULL(LOC.LocationCategory,'''') = ''MIXED''
       )
       OR
       (
             UPPER(LTRIM(RTRIM(ISNULL(SKU.PickCode,'''')))) = ''CS OR EA''
             AND CAST(ISNULL(PACK.CaseCnt,0) AS INT) > 0
             AND ISNULL(DEMAND.LESSTHANCASE,0) > 0
         )
     )
'
      + @c_Condition + '
      ORDER BY DEMAND.LPPRIORITY
            ,  DEMAND.OPRIORITY
            ,  ISNULL(LOTATTRIBUTE.LOTTABLE04, ''1900-01-01'')  --NJOW01
            ,  ISNULL(LOTATTRIBUTE.LOTTABLE05, ''1900-01-01'')
            ,  (LOTxLOCxID.Qty - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyPicked)
            ,  LOTxLOCxID.LOT
            ,  LOTxLOCxID.ID'

      SET @c_SQLParm =  N'@c_CurrentLoc NVARCHAR(10), @c_storerkey NVARCHAR(15), @c_CurrentSku NVARCHAR(20), @c_ReplGrp NVARCHAR(30),
                          @c_Zone01 NVARCHAR(10), @c_Zone02 NVARCHAR(10), @c_Zone03 NVARCHAR(10), @c_Zone04 NVARCHAR(10), @c_Zone05 NVARCHAR(10), @c_Zone06 NVARCHAR(10),
                          @c_Zone07 NVARCHAR(10), @c_Zone08 NVARCHAR(10), @c_Zone09 NVARCHAR(10), @c_Zone10 NVARCHAR(10), @c_Zone11 NVARCHAR(10), @c_Zone12 NVARCHAR(10),
                          @c_Lottable01 NVARCHAR(18), @c_Lottable02 NVARCHAR(18), @c_Lottable03 NVARCHAR(18), @d_Lottable04 DATETIME, @d_Lottable05 DATETIME,
                          @c_Lottable06 NVARCHAR(30), @c_Lottable07 NVARCHAR(30), @c_Lottable08 NVARCHAR(30), @c_Lottable09 NVARCHAR(30), @c_Lottable10 NVARCHAR(30),
                          @c_Lottable11 NVARCHAR(30), @c_Lottable12 NVARCHAR(30), @d_Lottable13 DATETIME, @d_Lottable14 DATETIME, @d_Lottable15 DATETIME, @n_Pallet INT'


      EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm, @c_CurrentLoc, @c_storerkey, @c_CurrentSku, @c_ReplGrp, @c_Zone01, @c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06,
                         @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10, @c_Zone11, @c_Zone12, @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05,
                         @c_Lottable06, @c_Lottable07, @c_Lottable08,@c_Lottable09, @c_Lottable10, @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15, @n_Pallet
      --NJOW04 E

      OPEN CUR_REPL

      FETCH NEXT FROM CUR_REPL INTO @c_FromLot
                                 ,  @c_FromLoc
                                 ,  @c_FromID
                                 ,  @c_CurrentSku
                                 ,  @n_FromQty
                                 ,  @n_QtyAllocated
                                 ,  @n_QtyPicked
                                 ,  @c_ReplLottable01 --NJOW04
                                 ,  @c_ReplLottable02
                                 ,  @c_ReplLottable03 --NJOW04
                                 ,  @d_ReplLottable04 --NJOW04
                                 ,  @d_ReplLottable05 --NJOW04
                                 ,  @c_ReplLottable06 --NJOW04
                                 ,  @c_ReplLottable07 --NJOW04
                                 ,  @c_ReplLottable08 --NJOW04
                                 ,  @c_ReplLottable09 --NJOW04
                                 ,  @c_ReplLottable10 --NJOW04
                                 ,  @c_ReplLottable11 --NJOW04
                                 ,  @c_ReplLottable12 --NJOW04
                                 ,  @d_ReplLottable13 --NJOW04
                                 ,  @d_ReplLottable14 --NJOW04
                                 ,  @d_ReplLottable15 --NJOW04
                                 ,  @c_FromLocType
                                 ,  @c_FromLocCat
                                 ,  @n_FromLessThanCase
                                 ,  @n_FromLessThanInner
                                 ,  @c_OPriority
                                 ,  @c_LPPriority
                                 ,  @c_PDString

      WHILE @@Fetch_Status <> -1 --AND @n_RemainingQty > 0
      BEGIN

         /* We now have a pickLOCation that needs to be replenished! */
         /* Figure out which LOCations in the warehouse to pull this product from */
         /* End figure out which LOCations in the warehouse to pull this product from */
         --SET @c_FromLOC = ''
         --SET @c_FromLot = ''
         --SET @c_FromId  = ''
         --SET @c_FromLocAisle = ''
         --SET @n_FromQty = 0

         --SET @n_RemainingQty  = @n_CurrentSeverity

         SELECT @c_ReplValidationRules = SC.sValue
         FROM STORERCONFIG SC (NOLOCK)
         JOIN CODELKUP CL (NOLOCK) ON SC.sValue = CL.Listname
         WHERE SC.StorerKey = @c_StorerKey
         AND SC.Configkey = 'ReplenValidation'

         IF ISNULL(@c_ReplValidationRules,'') <> ''
         BEGIN
            EXEC isp_REPL_ExtendedValidation @c_fromlot = @c_fromlot
                                          ,  @c_FromLOC = @c_FromLOC
                                          ,  @c_fromid  = @c_fromid
                                          ,  @c_ReplValidationRules=@c_ReplValidationRules
                                          ,  @b_Success = @b_Success OUTPUT
                                          ,  @c_ErrMsg  = @c_ErrMsg OUTPUT

            IF @b_Success = 0
            BEGIN
               GOTO NEXT_SKUxLOC
            END
         END

         SET @n_Pallet = 0.00
         SET @n_CaseCnt = 0.00
         SET @n_InnerPack = 0.00
         SELECT @n_Pallet = ISNULL(P.Pallet,0)
               ,@n_CaseCnt= ISNULL(P.CaseCnt,0)
               ,@n_InnerPack= ISNULL(P.InnerPack,0)
               ,@c_Packkey = P.PackKey
               ,@c_UOM = P.PackUOM3
         FROM SKU  S WITH (NOLOCK)
         JOIN PACK P WITH (NOLOCK) ON (S.Packkey = P.Packkey)
         WHERE S.StorerKey = @c_Storerkey
         AND   S.Sku = @c_CurrentSku

         --IF @c_ToLocationType = 'PALLET' AND @n_Pallet = 0
         --BEGIN
         --   GOTO NEXT_SKUxLOC
         --END

         IF EXISTS(SELECT 1 FROM #REPLENISHMENT
                   WHERE FromLOC = @c_FromLOC AND ID = @c_fromid)
            AND @c_FromLocType IN ('BULK','PALLET')
         BEGIN
            GOTO NEXT_SKUxLOC
         END

         --Initiate SKU ABC Flag
         SET @c_SKUABCFlag = ''
         SELECT @c_SKUABCFlag = SKU.ABC
         FROM SKU WITH (NOLOCK)
         WHERE STORERKEY = @c_CurrentStorer
         AND SKU = @c_CurrentSku

         SET @c_CurrentPriority = ''

         IF ISNULL(@c_LPPriority,'') <> ''
            SET @c_CurrentPriority = @c_LPPriority
         ELSE IF ISNULL(@c_OPriority,'') <> ''
            SET @c_CurrentPriority = @c_OPriority
         ELSE
            SET @c_CurrentPriority = '8'

         SELECT @c_FromLocAisle = LOCAISLE
              , @c_FromLocBay = LOCBAY
         FROM LOC WITH (NOLOCK)
         WHERE LOC = @c_FromLOC

         /* DC - START
         Qty control before ToLoc search.

         BULK/PALLET -> CASE
          Uses PACK.Pallet qty.

         CASE -> PICK shelving
          Uses PACK.CaseCnt qty.

         This must run BEFORE declaring CUR_SKUxLOC because @n_FromQty is used
         in fixed pickface capacity checking.
         */
         SET @n_SourceAvailQty = ISNULL(@n_FromQty,0)

         IF @c_FromLocType IN ('BULK','PALLET')
         BEGIN
            IF ISNULL(@n_Pallet,0) <= 0
                GOTO NEXT_SKUxLOC

            IF @n_SourceAvailQty < @n_Pallet
                GOTO NEXT_SKUxLOC

            SET @n_FromQty = FLOOR(@n_SourceAvailQty / @n_Pallet) * @n_Pallet

            IF ISNULL(@n_FromQty,0) <= 0
                GOTO NEXT_SKUxLOC
         END
         ELSE IF @c_FromLocType = 'CASE'
         BEGIN
            -- DC - Only allow CASE source when LocationCategory = MIXED
            IF ISNULL(@c_FromLocCat,'') <> 'MIXED'
               GOTO NEXT_SKUxLOC

            IF ISNULL(@n_CaseCnt,0) <= 0
               GOTO NEXT_SKUxLOC

            SET @nLLITTLQty = 0

            SELECT @nLLITTLQty = SUM(QTY - QTYPICKED)
            FROM LOTXLOCXID WITH (NOLOCK)
            WHERE LOC = @c_FromLOC
             AND SKU = @c_CurrentSku
             AND LOT = @c_fromlot
             AND ID  = @c_fromid

            IF ISNULL(@nLLITTLQty,0) > 0
               SET @n_SourceAvailQty = @nLLITTLQty

            IF @n_SourceAvailQty < @n_CaseCnt
               GOTO NEXT_SKUxLOC

            IF ISNULL(@n_FromLessThanCase,0) > 0
            BEGIN
               SET @n_FromQty =
                   CEILING(CAST(@n_FromLessThanCase AS FLOAT) / @n_CaseCnt) * @n_CaseCnt
            END
            ELSE
            BEGIN
               SET @n_FromQty = @n_CaseCnt
            END

            IF @n_FromQty > @n_SourceAvailQty
               SET @n_FromQty = FLOOR(@n_SourceAvailQty / @n_CaseCnt) * @n_CaseCnt

            IF ISNULL(@n_FromQty,0) <= 0
               GOTO NEXT_SKUxLOC
         END
         /* DC - END */

         IF @c_FromLocType = 'PICK' AND @c_FromLocCat = 'CLS'
         BEGIN
            IF @cSkipReplenInner01 = 'Y'
               GOTO NEXT_SKUxLOC
            ELSE
            BEGIN
               SET @n_FromQty = CEILING(CAST(@n_FromLessThanInner AS FLOAT)/@n_InnerPack) * @n_InnerPack

               SET @nLLITTLQty = 0
               SELECT @nLLITTLQty = SUM(QTY-QTYPICKED) FROM
               LOTXLOCXID (NOLOCK) WHERE LOC = @c_FromLOC
               AND SKU = @c_CurrentSku AND LOT = @c_fromlot
               AND ID = @c_fromid

               IF ISNULL(@nLLITTLQty,0) < @n_FromQty
                  SET @n_FromQty = @nLLITTLQty
            END
         END

         SET @n_RemainingQty = @n_FromQty


         --LOOP TO Look For To Location. Ordering as follow:
         --1. If SKU+LOT exists, suggest the same location
         --2. If there is a replenishment record created that has the same SKU+LOT, then suggest the same location
         --3. If fixed pickface configured for SKU, suggest Loc as long as qtylocationlimit does not exceed
         --   if there is multiple, order by Logicallocation
         --4. If ABC is configured for both SKU and Loc, suggest the same ABC Loc order by logicallocation
         --5. suggest an empty location order by logicallocation
         DECLARE CUR_SKUxLOC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT CurrentStorer = StorerKey
             --,CurrentSKU = SKU
               ,CurrentLoc = T.LOC
               --,CurrentSeverity = ReplenishmentSeverity
               --,ReplenishmentPriority = ReplenishmentPriority
               ,ToLocationType        = LocationType
               ,CurrentABCFlag = ISNULL(ABCLOC.ABC,'')
         FROM #TempSKUxLOC T
         OUTER APPLY (
               SELECT TOP 1 LOTTABLE01 FROM LOTATTRIBUTE LA (NOLOCK)
               JOIN LOTXLOCXID LLI (NOLOCK) ON LA.LOT = LLI.LOT
               WHERE LLI.LOC = T.LOC AND LLI.STORERKEY = @c_Storerkey
               AND LLI.QTY + LLI.PENDINGMOVEIN > 0 AND LLI.LOC <> @c_FromLOC
         ) AS LI
         OUTER APPLY (
               SELECT TOP 1 ReplLottable01 AS LOTTABLE01 FROM #REPLENISHMENT (NOLOCK)
               WHERE TOLOC = T.LOC AND STORERKEY = @c_Storerkey
         ) AS RP
         OUTER APPLY (
               SELECT TOP 1 ABC FROM LOC (NOLOCK)
               WHERE LOC.LOC = T.LOC
               AND LOC.ABC = @c_SKUABCFlag
         ) AS ABCLOC
         OUTER APPLY (
               SELECT TOP 1 SKUXLOC.LOC, SKUXLOC.LocationType AS SLType FROM SKUXLOC (NOLOCK)
               OUTER APPLY (SELECT  SUM(QTY) QTY, SUM(QTYPICKED) QTYPICKED, sum(PENDINGMOVEIN) PENDINGMOVEIN
                            FROM LOTXLOCXID (NOLOCK) where
                            LOC = SKUXLOC.LOC
                           AND SKU = SKUXLOC.SKU) AS SKULLI
               WHERE SKUXLOC.LOC = T.LOC
               AND SKUXLOC.STORERKEY = @c_Storerkey
               AND SKUXLOC.SKU = @c_CurrentSku
               AND SKUXLOC.LOCATIONTYPE = CASE WHEN @c_FromLocType IN ('BULK','PALLET') THEN 'CASE' ELSE 'PICK' END
               AND SKUXLOC.QTYLOCATIONLIMIT >= CASE WHEN SKUXLOC.QTYLOCATIONLIMIT > 0
                                            THEN ISNULL(SKULLI.QTY, 0) - ISNULL(SKULLI.QTYPICKED, 0) + ISNULL(SKULLI.PENDINGMOVEIN, 0) + @n_FromQty
                                            ELSE SKUXLOC.QTYLOCATIONLIMIT END
         ) AS FIXEDPF
         --WHERE LocationType = CASE WHEN @c_FromLocType = 'CASE' THEN 'PICK' ELSE 'CASE' END
         WHERE NOT EXISTS (SELECT TOP 1 1 FROM SKUXLOC (NOLOCK) --SY02
                           WHERE STORERKEY = @c_Storerkey AND LOCATIONTYPE IN ('CASE','PICK') AND LOC = T.LOC AND SKU <> @c_CurrentSku) --SY02 EXC FIXED FOR OTHER SKU
         ORDER BY
                CASE WHEN SLType = 'CASE' THEN 1 WHEN SLType = 'PICK' THEN 2 ELSE 3 END
                , CASE WHEN ISNULL(LI.LOTTABLE01,'') = @c_ReplLottable01 THEN 1
                  WHEN ISNULL(RP.LOTTABLE01,'') = @c_ReplLottable01 THEN 2
                ELSE 3 END --GET SAME BATCH LOCATIONS FIRST
                , CASE WHEN ISNUMERIC(LOCAISLE)=1 AND ISNUMERIC(@c_FromLocAisle)=1 --GET CLOSEST LOCAISLE
                       THEN ABS(CAST(LOCAISLE AS INT)-CAST(@c_FromLocAisle AS INT)) ELSE 999999 END
                , CASE WHEN ISNUMERIC(LOCAISLE)=1 AND ISNUMERIC(LOCBAY)=1 AND ISNUMERIC(@c_FromLocBay)=1 --GET CLOSEST LOCBAY NEXT
                       THEN ABS(CAST(LOCAISLE AS INT)-CAST(@c_FromLocBay AS INT)) ELSE 999999 END
                , CASE WHEN ISNULL(FIXEDPF.LOC,'') <> '' THEN 1 ELSE 2 END
                , CASE WHEN ISNULL(ABCLOC.ABC,'') <> '' THEN 1 ELSE 2 END
                , LogicalLocation

         OPEN CUR_SKUxLOC

         FETCH NEXT FROM CUR_SKUxLOC INTO @c_CurrentStorer
                                     --,  @c_CurrentSKU
                                       ,  @c_CurrentLoc
                                     --,  @n_CurrentSeverity
                                     --,  @c_CurrentPriority
                                       ,  @c_ToLocationType
                                       ,  @c_CurrABCFlag
         WHILE @@Fetch_Status <> -1 AND @n_RemainingQty > 0
         BEGIN

            IF @b_debug = 1
            BEGIN
               SELECT 'LOC CHECK : ' as Title, @c_CurrentSKU ' SKU', @c_fromlot 'LOT',  @c_CurrentLoc 'LOC', @c_fromid 'ID',
                      @n_FromQty 'Qty'
                  ,  @c_UOM
                  ,  @c_Packkey
            END

            IF EXISTS (SELECT TOP 1 1 FROM SKUXLOC WITH (NOLOCK)
                       WHERE LOC = @c_CurrentLoc
                       AND STORERKEY = @c_CurrentStorer
                       AND LOCATIONTYPE IN ('CASE','PICK')
                       AND SKU <> @c_CurrentSku)
               GOTO NEXT_CANDIDATE

            IF @c_FromLocType = @c_ToLocationType AND @c_FromLocType <> 'PICK'
               GOTO NEXT_CANDIDATE

            IF @c_FromLocType = 'PICK' AND @c_ToLocationType <> 'PICK'
               GOTO NEXT_CANDIDATE

            IF @c_FromLocType = @c_ToLocationType AND @c_FromLocType = 'PICK'
            BEGIN
               SET @c_ToLocCat = ''
               SELECT @c_ToLocCat = LocationCategory
               FROM LOC (NOLOCK)
               WHERE LOC = @c_CurrentLoc

               IF @c_ToLocCat = 'CLS' AND @c_FromLocCat = 'CLS'
                  GOTO NEXT_CANDIDATE
            END

            IF @c_FromLocType = 'CASE' AND @c_ToLocationType IN ('PICK')
            BEGIN
               SET @c_ToLocCat = ''
               SELECT @c_ToLocCat = LocationCategory
               FROM LOC WITH (NOLOCK)
               WHERE LOC = @c_CurrentLoc
               -- DC - Only allow CASE/MIXED source to replenish PICK/CLS destination
               IF ISNULL(@c_FromLocCat,'') <> 'MIXED'
                  GOTO NEXT_CANDIDATE
               IF ISNULL(@c_ToLocCat,'') <> 'CLS'
                  GOTO NEXT_CANDIDATE
            END

            IF @c_FromLocType = 'CASE' AND @c_ToLocationType IN ('BULK','PALLET')
               GOTO NEXT_CANDIDATE

            IF @c_FromLocType IN ('BULK','PALLET') AND @c_ToLocationType = 'PICK'
               GOTO NEXT_CANDIDATE

            --If force ABC turned on for ALL ABC types, check if found ABC locations
            IF ISNULL(@c_ForceSKUABCFlag,'') = 'Y' AND ISNULL(@c_CurrABCFlag,'') NOT IN ('A','B','C')
               GOTO NEXT_CANDIDATE

            --If force ABC specified and check if force ABC applies to the current SKU
            IF ISNULL(@c_ForceSKUABCFlag,'') IN ('A','B','C') AND ISNULL(@c_SKUABCFlag,'') = ISNULL(@c_ForceSKUABCFlag,'')
            BEGIN
               IF ISNULL(@c_SKUABCFlag,'') <> ISNULL(@c_CurrABCFlag,'')
                  GOTO NEXT_CANDIDATE
            END

            SET @c_CommingleSKUFlag = '0'

            SELECT @c_CommingleSKUFlag = CommingleSKU
            FROM LOC WITH (NOLOCK)
            WHERE Loc = @c_CurrentLoc
            AND FACILITY = @c_Zone01

            IF @c_CommingleSKUFlag IN ('0','N')
            BEGIN
               SET @n_InvCntSKU = 0
               SELECT TOP 1 @n_InvCntSKU = 1
                     , @c_InvSKU = LLI.SKU
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0

               IF @n_InvCntSKU = 0
                  SELECT TOP 1 @n_InvCntSKU = 1
                        , @c_InvSKU = LLI.SKU
                  FROM #REPLENISHMENT LLI WITH (NOLOCK)
                  WHERE LLI.Storerkey = @c_CurrentStorer
                  AND LLI.ToLoc = @c_CurrentLoc
                  AND LLI.Qty > 0

               IF @n_InvCntSKU >= 1 AND @c_CurrentSKU <> @c_InvSKU --SY02
                  GOTO NEXT_CANDIDATE
            END

            --continue check lottable if commingleSku
            IF @n_continue=1 OR @n_continue=2
            BEGIN
               --NJOW03 Start
               SET @c_NoMixLottable01  = '0'
               SELECT @c_NoMixLottable01 = ISNULL(RTRIM(NoMixLottable01),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt1 = 0
               SET @c_Lottable01 = ''
               SELECT TOP 1 @n_InvCnt1 = 1
                     , @c_Lottable01 = ISNULL(RTRIM(LA.lottable01),'')
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0  --NJOW04
               --NJOW03 End

               SET @c_NoMixLottable02  = '0'
               SELECT @c_NoMixLottable02 = ISNULL(RTRIM(NoMixLottable02),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt2 = 0
               SET @c_Lottable02 = ''
               SELECT TOP 1 @n_InvCnt2 = 1
                     , @c_Lottable02 = ISNULL(RTRIM(LA.lottable02),'')
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0  --NJOW04

               --NJOW03 Start
               SET @c_NoMixLottable03  = '0'
               SELECT @c_NoMixLottable03 = ISNULL(RTRIM(NoMixLottable03),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc
               SET @n_InvCnt3 = 0
               SET @c_Lottable03 = ''
               SELECT TOP 1 @n_InvCnt3 = 1
                     , @c_Lottable03 = ISNULL(RTRIM(LA.lottable03),'')
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0  --NJOW04
               --NJOW03 End

               --NJOW04 Start
               SET @c_NoMixLottable04  = '0'
               SELECT @c_NoMixLottable04 = ISNULL(RTRIM(NoMixLottable04),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt4 = 0
               SET @d_Lottable04 = NULL
               SELECT TOP 1 @n_InvCnt4 = 1
                     , @d_Lottable04 = LA.lottable04
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0

               SET @c_NoMixLottable05  = '0'
               SELECT @c_NoMixLottable05 = ISNULL(RTRIM(NoMixLottable05),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt5 = 0
               SET @d_Lottable05 = NULL
               SELECT TOP 1 @n_InvCnt5 = 1
                     , @d_Lottable05 = LA.lottable05
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0

               SET @c_NoMixLottable06  = '0'
               SELECT @c_NoMixLottable06 = ISNULL(RTRIM(NoMixLottable06),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt6 = 0
               SET @c_Lottable06 = ''
               SELECT TOP 1 @n_InvCnt6 = 1
                     , @c_Lottable06 = ISNULL(RTRIM(LA.lottable06),'')
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0

               SET @c_NoMixLottable07  = '0'
               SELECT @c_NoMixLottable07 = ISNULL(RTRIM(NoMixLottable07),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt7 = 0
               SET @c_Lottable07 = ''
               SELECT TOP 1 @n_InvCnt7 = 1
                     , @c_Lottable07 = ISNULL(RTRIM(LA.lottable07),'')
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0

               SET @c_NoMixLottable08  = '0'
               SELECT @c_NoMixLottable08 = ISNULL(RTRIM(NoMixLottable08),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt8 = 0
               SET @c_Lottable08 = ''
               SELECT TOP 1 @n_InvCnt8 = 1
               , @c_Lottable08 = ISNULL(RTRIM(LA.lottable08),'')
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0

               SET @c_NoMixLottable09  = '0'
               SELECT @c_NoMixLottable09 = ISNULL(RTRIM(NoMixLottable09),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt9 = 0
               SET @c_Lottable09 = ''
               SELECT TOP 1 @n_InvCnt9 = 1
                     , @c_Lottable09 = ISNULL(RTRIM(LA.lottable09),'')
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0

               SET @c_NoMixLottable10  = '0'
               SELECT @c_NoMixLottable10 = ISNULL(RTRIM(NoMixLottable10),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt10 = 0
               SET @c_Lottable10 = ''
               SELECT TOP 1 @n_InvCnt10 = 1
               , @c_Lottable10 = ISNULL(RTRIM(LA.lottable10),'')
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0

               SET @c_NoMixLottable11  = '0'
               SELECT @c_NoMixLottable11 = ISNULL(RTRIM(NoMixLottable11),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt11 = 0
               SET @c_Lottable11 = ''
               SELECT TOP 1 @n_InvCnt11 = 1
                     , @c_Lottable11 = ISNULL(RTRIM(LA.lottable11),'')
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0

               SET @c_NoMixLottable12  = '0'
               SELECT @c_NoMixLottable12 = ISNULL(RTRIM(NoMixLottable12),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt12 = 0
               SET @c_Lottable12 = ''
               SELECT TOP 1 @n_InvCnt12 = 1
                     , @c_Lottable12 = ISNULL(RTRIM(LA.lottable12),'')
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0

               SET @c_NoMixLottable13  = '0'
               SELECT @c_NoMixLottable13 = ISNULL(RTRIM(NoMixLottable13),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt13 = 0
               SET @d_Lottable13 = NULL
               SELECT TOP 1 @n_InvCnt5 = 1
                     , @d_Lottable13 = LA.lottable13
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0

               SET @c_NoMixLottable14  = '0'
               SELECT @c_NoMixLottable14 = ISNULL(RTRIM(NoMixLottable14),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt14 = 0
               SET @d_Lottable14 = NULL
               SELECT TOP 1 @n_InvCnt14 = 1
                     , @d_Lottable14 = LA.lottable14
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0

               SET @c_NoMixLottable15  = '0'
               SELECT @c_NoMixLottable15 = ISNULL(RTRIM(NoMixLottable15),'0')
               FROM LOC WITH (NOLOCK)
               WHERE Loc = @c_CurrentLoc

               SET @n_InvCnt15 = 0
               SET @d_Lottable15 = NULL
               SELECT TOP 1 @n_InvCnt15 = 1
                     , @d_Lottable15 = LA.lottable15
               FROM LOTxLOCxID LLI WITH (NOLOCK)
               JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.Lot = LA.Lot)
               WHERE LLI.Storerkey = @c_CurrentStorer
               AND LLI.Sku = @c_CurrentSku
               AND LLI.Loc = @c_CurrentLoc
               AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0
               --NJOW04 End

               IF @b_debug = 1
               BEGIN
                  SELECT 'NOMIXLOTTABLE FLAG'
                       , @c_NoMixLottable01, @n_InvCnt1  , @c_Lottable01
                       , @c_NoMixLottable02, @n_InvCnt2  , @c_Lottable02
                       , @c_NoMixLottable03, @n_InvCnt3  , @c_Lottable03
                       , @c_NoMixLottable06, @n_InvCnt6  , @c_Lottable06
                       , @c_NoMixLottable07, @n_InvCnt7  , @c_Lottable07
                       , @c_NoMixLottable08, @n_InvCnt8  , @c_Lottable08
                       , @c_NoMixLottable09, @n_InvCnt9  , @c_Lottable09
                       , @c_NoMixLottable10, @n_InvCnt10 , @c_Lottable10
                       , @c_NoMixLottable11, @n_InvCnt11 , @c_Lottable11
                       , @c_NoMixLottable12, @n_InvCnt12 , @c_Lottable12
                       , @c_NoMixLottable04, @n_InvCnt4  , @d_Lottable04
                       , @c_NoMixLottable05, @n_InvCnt5  , @d_Lottable05
                       , @c_NoMixLottable13, @n_InvCnt13 , @d_Lottable13
                       , @c_NoMixLottable14, @n_InvCnt14 , @d_Lottable14
                       , @c_NoMixLottable15, @n_InvCnt15 , @d_Lottable15
               END

               --Start: Check if nomixlottables and inv exists, but lottable not match
               IF @c_NoMixLottable01 = '1' AND @n_InvCnt1  >= 1 AND @c_Lottable01 <> @c_ReplLottable01  --SY02
                  GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable02 = '1' AND @n_InvCnt2  >= 1 AND @c_Lottable02 <> @c_ReplLottable02  --SY02
                  GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable03 = '1' AND @n_InvCnt3  >= 1 AND @c_Lottable03 <> @c_ReplLottable03  --SY02
               GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable06 = '1' AND @n_InvCnt6  >= 1 AND @c_Lottable06 <> @c_ReplLottable06  --SY02
                  GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable07 = '1' AND @n_InvCnt7  >= 1 AND @c_Lottable07 <> @c_ReplLottable07  --SY02
                  GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable08 = '1' AND @n_InvCnt8  >= 1 AND @c_Lottable08 <> @c_ReplLottable08  --SY02
                  GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable09 = '1' AND @n_InvCnt9  >= 1 AND @c_Lottable09 <> @c_ReplLottable09  --SY02
                  GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable10 = '1' AND @n_InvCnt10 >= 1 AND @c_Lottable10 <> @c_ReplLottable10  --SY02
                  GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable11 = '1' AND @n_InvCnt11 >= 1 AND @c_Lottable11 <> @c_ReplLottable11  --SY02
                  GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable12 = '1' AND @n_InvCnt12 >= 1 AND @c_Lottable12 <> @c_ReplLottable12  --SY02
                  GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable04 = '1' AND @n_InvCnt4  >= 1 AND @d_Lottable04 <> @d_ReplLottable04  --SY02
                  GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable05 = '1' AND @n_InvCnt5  >= 1 AND @d_Lottable05 <> @d_ReplLottable05  --SY02
                  GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable13 = '1' AND @n_InvCnt13 >= 1 AND @d_Lottable13 <> @d_ReplLottable13  --SY02
                  GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable14 = '1' AND @n_InvCnt14 >= 1 AND @d_Lottable14 <> @d_ReplLottable14  --SY02
                  GOTO NEXT_CANDIDATE
               IF @c_NoMixLottable15 = '1' AND @n_InvCnt15 >= 1 AND @d_Lottable15 <> @d_ReplLottable15  --SY02
                  GOTO NEXT_CANDIDATE
               --End: Check if nomixlottables and inv exists, but lottable not match
               --Start: Check if nomixlottables and generated replen whether lottable match
               IF @c_NoMixLottable01 = '1' AND @n_InvCnt1 = 0 --NJOW04
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable01 <> @c_ReplLottable01
                              GROUP BY Storerkey, Sku, ToLoc                                  HAVING COUNT(1) > 0)
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END

               IF @c_NoMixLottable02 = '1' AND @n_InvCnt2 = 0
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable02 <> @c_ReplLottable02
                              GROUP BY Storerkey, Sku, ToLoc
                              HAVING COUNT(1) > 0)
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END

               --NJOW04 S
               IF @c_NoMixLottable03 = '1' AND @n_InvCnt3 = 0
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable03 <> @c_ReplLottable03
                              GROUP BY Storerkey, Sku, ToLoc
                             HAVING COUNT(1) > 0)
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END

               IF @c_NoMixLottable04 = '1' AND @n_InvCnt4 = 0 AND CONVERT(NVARCHAR(8) ,@d_ReplLottable04 ,112) <> '19000101' AND @d_ReplLottable04 IS NOT NULL
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable04 <> @d_ReplLottable04
                              AND CONVERT(NVARCHAR(8) ,ReplLottable04 ,112) <> '19000101'
                              AND ReplLottable04 IS NOT NULL
                              GROUP BY Storerkey, Sku, ToLoc
                              HAVING COUNT(1) > 0)
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END

               IF @c_NoMixLottable05 = '1' AND @n_InvCnt5 = 0 AND CONVERT(NVARCHAR(8) ,@d_ReplLottable05 ,112) <> '19000101' AND @d_ReplLottable05 IS NOT NULL
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                    WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable05 <> @d_ReplLottable05
                              AND CONVERT(NVARCHAR(8) ,ReplLottable05 ,112) <> '19000101'
                              AND ReplLottable05 IS NOT NULL
                              GROUP BY Storerkey, Sku, ToLoc
                              HAVING COUNT(1) > 0)
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END

               IF @c_NoMixLottable06 = '1' AND @n_InvCnt6 = 0
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable06 <> @c_ReplLottable06
                              GROUP BY Storerkey, Sku, ToLoc
                              HAVING COUNT(1) > 0)
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END


               IF @c_NoMixLottable07 = '1' AND @n_InvCnt7 = 0
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable07 <> @c_ReplLottable07
                              GROUP BY Storerkey, Sku, ToLoc
                              HAVING COUNT(1) > 0)
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END

               IF @c_NoMixLottable08 = '1' AND @n_InvCnt8 = 0
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable08 <> @c_ReplLottable08
                              GROUP BY Storerkey, Sku, ToLoc
                              HAVING COUNT(1) > 0)                    BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END

               IF @c_NoMixLottable09 = '1' AND @n_InvCnt9 = 0
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable09 <> @c_ReplLottable09
                              GROUP BY Storerkey, Sku, ToLoc
                              HAVING COUNT(1) > 0)
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END

               IF @c_NoMixLottable10 = '1' AND @n_InvCnt10 = 0
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable10 <> @c_ReplLottable10
                              GROUP BY Storerkey, Sku, ToLoc
                              HAVING COUNT(1) > 0)
                  BEGIN
                    GOTO NEXT_CANDIDATE
                  END
               END

               IF @c_NoMixLottable11 = '1' AND @n_InvCnt11 = 0
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable11 <> @c_ReplLottable11
                              GROUP BY Storerkey, Sku, ToLoc
                              HAVING COUNT(1) > 0)
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END

               IF @c_NoMixLottable12 = '1' AND @n_InvCnt12 = 0
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable12 <> @c_ReplLottable12
                              GROUP BY Storerkey, Sku, ToLoc
                              HAVING COUNT(1) > 0)
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END

               IF @c_NoMixLottable13 = '1' AND @n_InvCnt13 = 0 AND CONVERT(NVARCHAR(8) ,@d_ReplLottable13 ,112) <> '19000101' AND @d_ReplLottable13 IS NOT NULL
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable13 <> @d_ReplLottable13
                              AND CONVERT(NVARCHAR(8) ,ReplLottable13 ,112) <> '19000101'
                              AND ReplLottable13 IS NOT NULL
                              GROUP BY Storerkey, Sku, ToLoc
                              HAVING COUNT(1) > 0)
                  BEGIN
                    GOTO NEXT_CANDIDATE
                  END
               END

              IF @c_NoMixLottable14 = '1' AND @n_InvCnt14 = 0 AND CONVERT(NVARCHAR(8) ,@d_ReplLottable14 ,112) <> '19000101' AND @d_ReplLottable14 IS NOT NULL
              BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable14 <> @d_ReplLottable14
                              AND CONVERT(NVARCHAR(8) ,ReplLottable14 ,112) <> '19000101'
                              AND ReplLottable14 IS NOT NULL
                              GROUP BY Storerkey, Sku, ToLoc
                              HAVING COUNT(1) > 0)
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END

               IF @c_NoMixLottable15 = '1' AND @n_InvCnt15 = 0 AND CONVERT(NVARCHAR(8) ,@d_ReplLottable15 ,112) <> '19000101' AND @d_ReplLottable15 IS NOT NULL
               BEGIN
                  IF EXISTS ( SELECT 1 FROM #REPLENISHMENT
                              WHERE Storerkey = @c_CurrentStorer AND Sku = @c_CurrentSku AND ToLOC = @c_CurrentLoc
                              AND ReplLottable15 <> @d_ReplLottable15
                              AND CONVERT(NVARCHAR(8) ,ReplLottable15 ,112) <> '19000101'
                              AND ReplLottable15 IS NOT NULL
                              GROUP BY Storerkey, Sku, ToLoc
                              HAVING COUNT(1) > 0)
                  BEGIN
                     GOTO NEXT_CANDIDATE
                  END
               END
               --NJOW04 E
            END

            IF EXISTS(SELECT 1 FROM ID (NOLOCK) WHERE ID = @c_FromID AND STATUS = 'HOLD')
            BEGIN
               GOTO NEXT_CANDIDATE
            END

            IF EXISTS(SELECT 1 FROM #REPLENISHMENT
                      WHERE LOT =  @c_fromlot AND FromLOC = @c_FromLOC AND ID = @c_fromid)
            BEGIN
               GOTO NEXT_CANDIDATE
            END


            --IF @n_QtyAllocated > 0 AND @c_NoReplenAlloPlt = 'Y' --NJOW04
            --   GOTO NEXT_CANDIDATE

            --IF @c_ToLocationType = 'PALLET'
            --BEGIN
            --   IF @n_FromQty < @n_Pallet
            --   BEGIN
            --      GOTO NEXT_CANDIDATE
            --   END
            --
            --   IF @n_FromQty > @n_RemainingQty
            --   BEGIN
            --      SET @n_FromQty = FLOOR(@n_RemainingQty/@n_Pallet) * @n_Pallet
            --   END
            --   ELSE
            --   BEGIN
            --      SET @n_FromQty = FLOOR(@n_FromQty/@n_Pallet) * @n_Pallet
            --   END
            --END
            --ELSE IF @c_ToLocationType = 'CASE'
            --BEGIN
            --   IF @n_FromQty < @n_CaseCnt
            --   BEGIN
            --      GOTO NEXT_CANDIDATE
            --   END
            --
            -- IF @n_FromQty > @n_RemainingQty
            --   BEGIN
            --      SET @n_FromQty = 0
            --   END
            --   ELSE
            --   BEGIN
            --      IF @n_FromQty < @n_Pallet
            --      BEGIN
            --         SET @n_FromQty = FLOOR(@n_FromQty/@n_CaseCnt) * @n_CaseCnt
            --      END
            --      ELSE
            --      BEGIN
            --         SET @n_FromQty = FLOOR(@n_FromQty/@n_Pallet) * @n_Pallet
            --      END
            --   END
            --END

            --SET @n_RemainingQty = @n_RemainingQty - @n_FromQty

            IF @n_FromQty > 0 --AND @n_RemainingQty >= 0
            BEGIN
               INSERT #REPLENISHMENT
                     (
                        StorerKey
                     ,  SKU
                     ,  FromLOC
                     ,  ToLOC
                     ,  Lot
                     ,  Id
                     ,  Qty
                     ,  UOM
                     ,  PackKey
                     ,  Priority
                     ,  QtyMoved
                     ,  QtyInPickLOC
                     ,  ReplLottable01
                     ,  ReplLottable02
                     ,  ReplLottable03
                     ,  ReplLottable04
                     ,  ReplLottable05
                     ,  ReplLottable06
                     ,  ReplLottable07
                     ,  ReplLottable08
                     ,  ReplLottable09
                     ,  ReplLottable10
                     ,  ReplLottable11
                     ,  ReplLottable12
                     ,  ReplLottable13
                     ,  ReplLottable14
                     ,  ReplLottable15
                     ,  PDString
                     )
                        VALUES
                     (
                        @c_CurrentStorer
                     ,  @c_CurrentSKU
                     ,  @c_FromLOC
                     ,  @c_CurrentLoc
                     ,  @c_FromLot
                     ,  @c_Fromid
                     ,  @n_FromQty
                     ,  @c_UOM
                     ,  @c_Packkey
                     ,  @c_CurrentPriority
                     ,  @n_QtyAllocated
                     ,  @n_QtyPicked
                     ,  @c_ReplLottable01 --NJOW04
                     ,  @c_ReplLottable02
                     ,  @c_ReplLottable03 --NJOW04
                     ,  @d_ReplLottable04 --NJOW04
                     ,  @d_ReplLottable05 --NJOW04
                     ,  @c_ReplLottable06 --NJOW04
                     ,  @c_ReplLottable07 --NJOW04
                     ,  @c_ReplLottable08 --NJOW04
                     ,  @c_ReplLottable09 --NJOW04
                     ,  @c_ReplLottable10 --NJOW04
                     ,  @c_ReplLottable11 --NJOW04
                     ,  @c_ReplLottable12 --NJOW04
                     ,  @d_ReplLottable13 --NJOW04
                     ,  @d_ReplLottable14 --NJOW04
                     ,  @d_ReplLottable15 --NJOW04
                     ,  @c_PDString
                     )

               SET @n_numberofrecs = @n_numberofrecs + 1

               SET @n_RemainingQty = @n_RemainingQty - @n_FromQty

               IF @b_debug = 1
               BEGIN
                  SELECT 'INSERTED : ' as Title, @c_CurrentSKU ' SKU', @c_fromlot 'LOT',  @c_CurrentLoc 'LOC', @c_fromid 'ID',
                         @n_FromQty 'Qty'
                     ,  @c_UOM
                     ,  @c_Packkey
               END

            END

            IF @b_debug = 1
            BEGIN
               select @c_CurrentSKU ' SKU', @c_CurrentLoc 'LOC', @c_CurrentPriority 'priority', @n_currentfullcase 'full case', @n_CurrentSeverity 'severity'
               select @n_RemainingQty '@n_RemainingQty', @c_CurrentLoc + ' SKU = ' + @c_CurrentSKU, @c_fromlot 'from lot', @c_fromid
            END

            NEXT_CANDIDATE:
            FETCH NEXT FROM CUR_SKUxLOC INTO @c_CurrentStorer
                                     --,  @c_CurrentSKU
                                       ,  @c_CurrentLoc
                                     --,  @n_CurrentSeverity
                                     --,  @c_CurrentPriority
                                       ,  @c_ToLocationType
                                       ,  @c_CurrABCFlag

         END -- -- FOR SKUxLOC

         CLOSE CUR_SKUxLOC
         DEALLOCATE CUR_SKUxLOC

         IF @n_RemainingQty > 0 --Exists Records not found
         BEGIN
            SET @c_AlertMessage = 'To Loc Not Found! SKU: '+@c_CurrentSKU
                                 +'LOC: '+@c_FromLoc + 'Qty: '+CAST(@n_FromQty AS NVARCHAR)
            EXECUTE nspLogAlert
            @c_ModuleName   = 'isp_AU_ReplenishmentRpt_04',   --ML01
            @c_AlertMessage = @c_AlertMessage,
            @n_Severity     = NULL,
            @b_success       = @b_success OUTPUT,
            @n_err          = @n_err OUTPUT,
            @c_errmsg       = @c_errmsg OUTPUT
           ,@c_SKU          = @c_CurrentSKU
           ,@c_Qty          = @n_FromQty
           ,@c_Lot          = @c_FromLot
           ,@c_Loc          = @c_FromLoc
           ,@c_ID           = @c_FromID
         END

         NEXT_SKUxLOC:

         FETCH NEXT FROM CUR_REPL INTO @c_FromLot
                                    ,  @c_FromLoc
                                    ,  @c_FromID
                                    ,  @c_CurrentSku
                                    ,  @n_FromQty
                                    ,  @n_QtyAllocated
                                    ,  @n_QtyPicked
                                    ,  @c_ReplLottable01 --NJOW04
                                    ,  @c_ReplLottable02
                                    ,  @c_ReplLottable03 --NJOW04
                                    ,  @d_ReplLottable04 --NJOW04
                                    ,  @d_ReplLottable05 --NJOW04
                                    ,  @c_ReplLottable06 --NJOW04
                                    ,  @c_ReplLottable07 --NJOW04
                                    ,  @c_ReplLottable08 --NJOW04
                                    ,  @c_ReplLottable09 --NJOW04
                                    ,  @c_ReplLottable10 --NJOW04
                                    ,  @c_ReplLottable11 --NJOW04
                                    ,  @c_ReplLottable12 --NJOW04
                                    ,  @d_ReplLottable13 --NJOW04
                                    ,  @d_ReplLottable14 --NJOW04
                                    ,  @d_ReplLottable15 --NJOW04
                                    ,  @c_FromLocType
                                    ,  @c_FromLocCat
                                    ,  @n_FromLessThanCase
                                    ,  @n_FromLessThanInner
                                    ,  @c_OPriority
                                    ,  @c_LPPriority
                                    ,  @c_PDString
      END -- LOT
      CLOSE CUR_REPL
      DEALLOCATE CUR_REPL
   END

   IF @n_continue=1 OR @n_continue=2
   BEGIN
      /* Update the column QtyInPickLOC in the Replenishment Table */
      IF @n_continue = 1 or @n_continue = 2
      BEGIN
        UPDATE #REPLENISHMENT SET QtyInPickLOC = SKUxLOC.Qty - SKUxLOC.QtyPicked
         FROM SKUxLOC WITH (NOLOCK)
         WHERE #REPLENISHMENT.StorerKey = SKUxLOC.StorerKey AND
         #REPLENISHMENT.SKU = SKUxLOC.SKU AND
         #REPLENISHMENT.toLOC = SKUxLOC.LOC
      END
   END
   /* Insert Into Replenishment Table Now */
--   DECLARE @b_success   INT
--       , @n_err       INT
--         , @c_errmsg    NVARCHAR(255)

   DECLARE CUR1 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT R.FromLoc
         ,R.Id
         ,R.ToLoc
         ,R.Sku
         ,R.Qty
         ,R.StorerKey
         ,R.Lot
         ,R.PackKey
         ,R.Priority
         ,R.UOM
         ,R.PDString
   FROM #REPLENISHMENT R

   OPEN CUR1
   FETCH NEXT FROM CUR1 INTO @c_FromLOC
                           , @c_FromID
                           , @c_CurrentLoc
                           , @c_CurrentSKU
                           , @n_FromQty
                           , @c_CurrentStorer
                           , @c_FromLot
                           , @c_PackKey
                           , @c_Priority
                   , @c_UOM
                           , @c_PDRPLString
   WHILE @@FETCH_STATUS <> -1
   BEGIN
      EXECUTE nspg_GetKey
            'REPLENISHKEY'
         ,  10
         ,  @c_ReplenishmentKey  OUTPUT
         ,  @b_success           OUTPUT
         ,  @n_err               OUTPUT
         ,  @c_errmsg            OUTPUT

      IF NOT @b_success = 1
      BEGIN
         BREAK
      END

      IF @b_success = 1
      BEGIN
         SET @c_MoveRefKey = ''

         SET @c_MoveRefKey = CASE WHEN ISNULL(@c_PDRPLString,'') <> '' THEN @c_ReplenishmentKey ELSE '' END

         SET @c_Orderkey = ''

         SELECT @c_Orderkey = CASE WHEN COUNT(DISTINCT PD.ORDERKEY) > 1 THEN 'MULTI' ELSE MIN(PD.ORDERKEY) END
         FROM PICKDETAIL PD WITH (NOLOCK)
         CROSS APPLY (
               SELECT [VALUE]
               FROM STRING_SPLIT(@c_PDRPLString,',')
               WHERE [VALUE] = PD.PICKDETAILKEY) AS PDSTRINGSPLIT
         WHERE PD.STORERKEY = @c_CurrentStorer

         SET @c_Orderkey = ISNULL(@c_Orderkey,'')

         INSERT REPLENISHMENT
            (
               replenishmentgroup
            ,  ReplenishmentKey
            ,  StorerKey
            ,  Sku
            ,  FromLoc
            ,  ToLoc
            ,  Lot
            ,  Id
            ,  Qty
            ,  UOM
            ,  PackKey
            ,  Confirmed
            ,  RefNo  --NJOW02
            ,  MoveRefKey
            ,  Priority
            )
               VALUES (
               @c_ReplenishmentGroup  --@c_ReplGrp  NJOW02
            ,  @c_ReplenishmentKey
            ,  @c_CurrentStorer
            ,  @c_CurrentSKU
            ,  @c_FromLOC
            ,  @c_CurrentLoc
            ,  @c_FromLot
            ,  @c_FromId
            ,  @n_FromQty
            ,  @c_UOM
            ,  @c_PackKey
            ,  'N'
            ,  @c_Orderkey --'AU01'  --NJOW02
            ,  @c_MoveRefKey
            ,  @c_Priority
            )
         SET @n_err = @@ERROR

         IF @n_err = 0 AND @n_FromQty > 0 AND ISNULL(@c_MoveRefKey,'') <> ''
         BEGIN
            SET @n_SystemQty = 0
            SET @c_CurrPickdetailKey = ''

            DECLARE CUR1_DET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT PD.PickdetailKey, PD.QTY, P.CASECNT, P.INNERPACK, LOC.LOCATIONTYPE
            FROM PICKDETAIL PD (NOLOCK)
            JOIN SKU S (NOLOCK) ON PD.SKU = S.SKU AND PD.STORERKEY = S.StorerKey
            JOIN PACK P (NOLOCK) ON S.PACKKEY = P.PACKKEY
            JOIN LOC (NOLOCK) ON PD.LOC = LOC.LOC
            CROSS APPLY (
               SELECT [VALUE]
               FROM STRING_SPLIT(@c_PDRPLString,',')
               WHERE [VALUE] = PD.PICKDETAILKEY) AS PDSTRINGSPLIT
            WHERE PD.STORERKEY = @c_CurrentStorer
            AND PD.QTY < CASE WHEN LOC.LOCATIONTYPE = 'CASE' AND P.CASECNT > 0 THEN P.CASECNT* CEILING(CAST(PD.QTY AS FLOAT)/P.CASECNT)
                              WHEN LOC.LOCATIONTYPE = 'PICK' AND P.INNERPACK > 0 THEN P.INNERPACK* CEILING(CAST(PD.QTY AS FLOAT)/P.INNERPACK)
                              WHEN LOC.LOCATIONTYPE = 'BULK' THEN PD.QTY+1
                 ELSE PD.QTY END
            ORDER BY 1

            OPEN CUR1_DET
            FETCH FROM CUR1_DET INTO @c_PickDetailKey, @n_PDQty
            , @n_CaseCnt
            , @n_InnerPack , @c_FromLocType
            WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)
            BEGIN

               IF @c_FromLocType = 'BULK'
               BEGIN
                  SET @n_SystemQty = @n_FromQty

                  UPDATE PICKDETAIL WITH (ROWLOCK)
                  SET MoveRefKey = @c_MoveRefKey
                     , ARCHIVECOP = NULL
                     , Editdate = getdate()
                  WHERE PICKDETAILKEY = @c_PickDetailKey
               END
               ELSE
               BEGIN
                  SET @n_SplitQty = 0
                  IF @c_FromLocType = 'CASE'
                  BEGIN
                     IF @n_PDQty < @n_CaseCnt
                     BEGIN
                        UPDATE PICKDETAIL WITH (ROWLOCK)
                        SET MOVEREFKEY = @c_MoveRefKey, TRAFFICCOP = NULL, Editdate = getdate()
                        WHERE PickdetailKey = @c_PickDetailKey
                     END
                     ELSE IF @n_CaseCnt > 0
                        SET @n_SplitQty = @n_PDQty - (@n_CaseCnt * FLOOR(CAST(@n_PDQty AS FLOAT)/@n_CaseCnt))
                  END
                  ELSE IF @c_FromLocType = 'PICK'
                  BEGIN
                     IF @n_PDQty < @n_InnerPack
                     BEGIN
                        UPDATE PICKDETAIL WITH (ROWLOCK)
                        SET MOVEREFKEY = @c_MoveRefKey, TRAFFICCOP = NULL, Editdate = getdate()
                        WHERE PickdetailKey = @c_PickDetailKey
                     END
                     ELSE IF @n_InnerPack > 0
                        SET @n_SplitQty = @n_PDQty - (@n_InnerPack * FLOOR(CAST(@n_PDQty AS FLOAT)/@n_InnerPack))
                  END

                  IF @n_SplitQty > 0 AND @n_SplitQty < @n_PDQty
                  BEGIN
                     SET @c_NewPickdetailKey = ''

                     EXECUTE nspg_GetKey
                        'PICKDETAILKEY',
                        10,
                        @c_NewPickdetailKey OUTPUT,
                        @b_success OUTPUT,
                        @n_err OUTPUT,
                        @c_errmsg OUTPUT

                     IF ISNULL(@c_NewPickdetailKey,'') <> ''
                     BEGIN
                        INSERT INTO PICKDETAIL  (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot,
                                                      Storerkey, Sku, AltSku, UOM, UOMQty, Qty, QtyMoved, [Status],
                                                      DropID, Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                                                      ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod,
                                                      WaveKey, EffectiveDate, OptimizeCop, ShipFlag, PickSlipNo,
                                                      TaskDetailKey, TaskManagerReasonKey, Notes, MoveRefKey )
                        SELECT @c_NewpickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot,
                               Storerkey, Sku, AltSku, UOM, CASE UOM WHEN '6' THEN @n_SplitQty ELSE UOMQty END , @n_SplitQty, QtyMoved, Status,
                               '', Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                               ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod,
                               WaveKey, EffectiveDate, '9', ShipFlag, PickSlipNo,
                               TaskDetailKey, TaskManagerReasonKey, Notes, @c_MoveRefKey
                        FROM PICKDETAIL WITH (NOLOCK)
                        WHERE PickdetailKey = @c_PickDetailKey

                        UPDATE PICKDETAIL WITH (ROWLOCK)
                        SET QTY = QTY - @n_SplitQty, MOVEREFKEY = 'CHECKED', TRAFFICCOP = NULL, Editdate = getdate()
                        WHERE PickdetailKey = @c_PickDetailKey

                     END
                  END

                  SET @n_SystemQty = @n_SystemQty + @n_PDQty
               END

               FETCH FROM CUR1_DET INTO @c_PickDetailKey, @n_PDQty
                   , @n_CaseCnt
                   , @n_InnerPack , @c_FromLocType
            END
            CLOSE CUR1_DET
            DEALLOCATE CUR1_DET


            DECLARE CUR1_DET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT PD.PickdetailKey, PD.QTY
            FROM PICKDETAIL PD (NOLOCK)
            JOIN SKU S (NOLOCK) ON PD.SKU = S.SKU AND PD.STORERKEY = S.StorerKey
            JOIN PACK P (NOLOCK) ON S.PACKKEY = P.PACKKEY
            JOIN LOC (NOLOCK) ON PD.LOC = LOC.LOC
            CROSS APPLY (
               SELECT [VALUE]
               FROM STRING_SPLIT(@c_PDRPLString,',')
               WHERE [VALUE] = PD.PICKDETAILKEY) AS PDSTRINGSPLIT
            WHERE PD.STORERKEY = @c_CurrentStorer
            AND ISNULL(PD.MOVEREFKEY,'') = ''
            ORDER BY 1

            OPEN CUR1_DET
            FETCH FROM CUR1_DET INTO @c_PickDetailKey, @n_PDQty
            WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)
            BEGIN


               UPDATE PICKDETAIL WITH (ROWLOCK)
               SET MoveRefKey = 'CHECKED'
                  , ARCHIVECOP = NULL
                  , Editdate = getdate()
               WHERE PICKDETAILKEY = @c_PickDetailKey


               FETCH FROM CUR1_DET INTO @c_PickDetailKey, @n_PDQty
            END
            CLOSE CUR1_DET
            DEALLOCATE CUR1_DET


            SET @nLLITTLQty = 0
            SELECT @nLLITTLQty = SUM(QTY-QTYALLOCATED-QTYPICKED) FROM
            LOTXLOCXID (NOLOCK) WHERE LOC = @c_FromLOC
            AND SKU = @c_CurrentSku AND LOT = @c_fromlot
            AND ID = @c_fromid

            IF @n_SystemQty > 0 AND @n_SystemQty < @n_FromQty AND @nLLITTLQty = 0
               UPDATE REPLENISHMENT WITH (ROWLOCK)
               SET Qty = @n_SystemQty, ARCHIVECOP = NULL
               WHERE ReplenishmentKey = @c_ReplenishmentKey

         END

      END -- IF @b_success = 1

      FETCH NEXT FROM CUR1 INTO @c_FromLOC
                              , @c_FromID
                              , @c_CurrentLoc
                              , @c_CurrentSKU
                              , @n_FromQty
                              , @c_CurrentStorer
                              , @c_FromLot
                              , @c_PackKey
                              , @c_Priority
                              , @c_UOM
                              , @c_PDRPLString
   END -- While
   CLOSE CUR1
   DEALLOCATE CUR1
   -- End Insert Replenishment

   QUIT_SP:

   IF @c_backendjob <> 'Y' --NJOW02
   BEGIN
      --(Wan01) - START
      IF @c_FuncType IN ( 'G' )
      BEGIN
         RETURN
      END
      --(Wan01) - END

      --(Wan02) - START
      IF @c_FuncType IN ( 'P' )
      BEGIN
         SET @c_ReplenishmentGroup = @c_ReplGrp
      END
      --(Wan02) - END

      SELECT R.FromLoc
            ,R.Id
            ,R.ToLoc
            ,R.Sku
            ,R.Qty
            ,R.StorerKey
            ,R.Lot
            ,R.PackKey
            ,SKU.Descr
            ,R.Priority
            ,LOC.PutawayZone
            ,PACK.CaseCnt
            ,PACK.Pallet
            ,NoOfCSInPL = CASE WHEN PACK.CaseCnt > 0 THEN PACK.Pallet / PACK.CaseCnt ELSE 0 END
            ,SuggestPL  = CASE WHEN PACK.Pallet  > 0 THEN FLOOR(R.Qty / PACK.Pallet) ELSE 0 END
            ,SuggestCS  = CASE WHEN PACK.CaseCnt > 0 THEN FLOOR((R.Qty % CONVERT(INT, PACK.Pallet)) / PACK.CaseCnt) ELSE 0 END
            ,TotalCS    = CASE WHEN PACK.CaseCnt > 0 THEN FLOOR(R.Qty / PACK.CaseCnt) ELSE 0 END
            ,PACK.PackUOM1
            ,PACK.PackUOM3
            ,R.ReplenishmentKey
            ,LA.Lottable02
      FROM  REPLENISHMENT R WITH (NOLOCK)
      JOIN  SKU             WITH (NOLOCK) ON (SKU.Sku = R.Sku AND  SKU.StorerKey = R.StorerKey)
      JOIN  LOC             WITH (NOLOCK) ON (LOC.Loc = R.ToLoc)
      JOIN  PACK            WITH (NOLOCK) ON (SKU.PackKey = PACK.PackKey)
      JOIN LOTATTRIBUTE LA  WITH (NOLOCK) ON (R.Lot = LA.Lot)
      WHERE (R.Replenishmentgroup = @c_ReplenishmentGroup OR @c_ReplenishmentGroup = 'ALL')  --(Wan01) --(Wan02)
      --WHERE R.ReplenishmentGroup = @c_ReplenishmentGroup --@c_ReplGrp NJOW02   --(Wan02)
      AND  (LOC.PickZone = @c_ReplGrp OR @c_ReplGrp = 'ALL')
      AND   LOC.facility = @c_zone01
      AND  (R.Storerkey = @c_Storerkey OR @c_Storerkey = 'ALL')
      AND  (LOC.PutawayZone IN (@c_zone02, @c_zone03, @c_zone04, @c_zone05, @c_zone06, @c_zone07, @c_zone08, @c_zone09, @c_zone10, @c_zone11, @c_zone12)
      OR  @c_zone02 = 'ALL')
      AND R.Confirmed = 'N'

      ORDER BY LOC.PutawayZone
            ,  R.FromLoc
            ,  R.Id
            ,  LA.Lottable02
            ,  R.Sku
   END
END
GO
GRANT EXECUTE ON isp_AU_ReplenishmentRpt_04 TO nSQL
GO
