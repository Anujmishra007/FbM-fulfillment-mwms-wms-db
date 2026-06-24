--USE [GLOWMS]
GO
/****** Object:  StoredProcedure [dbo].[isp_GenReplenishmentARLA]    Script Date: 6/21/2026 3:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************
** Stored Procedure: isp_GenReplenishment
** Creation Date:    2009-11-09
** Modified Date:    2026-06-02
** Copyright:        MAERSK
** Written by:       ChewKP (Original), K Meenakshi Sundaram (Logic Change) UWP-59499
**
** Purpose:          Generate replenishment tasks for PICK/CASE locations
**                   considering only LOTTABLE04 >= Today (FEFO logic)
**                   One Lot, One ID, One Source per replenishment line
**
** Called By:         lsp_Start_Replenishment_Wrapper
**                   nsp_FullPallet_ReplenishmentRpt02
**
** Parameters:
**   @c_Zone01      - Facility code
**   @c_Zone02-12   - Putaway zone filters / SKU & Aisle ranges
**   @c_ReplenFlag  - N = Normal, W = Wave, PP = Pre-Pick,
**                    FP = Full Pallet, WHC = Wave Healthcare,
**                    PPHC = Pre Pick Healthcare,
**                    FP+PARM = Full Pallet with Zone(9,10)=SKU, Zone(11,12)=Aisle
**                    FP+PARM2 = Full Pallet Zone02 to Zone03
**                    FP+UCC = Full Pallet (BULK->CASE) + UCC (CASE->PICK)
**   @c_storerkey   - Storer key ('ALL' for all storers)
**
** Version History:
** Date         Author                  Ver   Purpose
** 09-Nov-2009  ChewKP                  1.0   Original
** 14-Dec-2009  Leong                   1.2   Pass In StorerKey
** 09-Jul-2010  Shong                   1.3   Revised Replenishment Calculation
** 24-Aug-2010  Shong                   1.4   Zone Restriction for Pick Loc
** 20-Dec-2010  NJOW01                  1.5   Fix replenishment qty in piece
** 18-Jul-2012  NJOW02                  1.6   FP+PARM flag
** 23-Aug-2012  NJOW03                  1.7   Fix Replenish whole pallet
** 26-Nov-2012  NJOW04                  1.8   Storerconfig near expiry exclusion
** 15-Apr-2014  TLTING                  2.0   SQL2012 Compatible
** 01-Apr-2019  WLCHOOI                2.1   FP+PARM2 Zone02 to Zone03
** 02-Sep-2025  MICHAEL                2.2   FP+UCC replen flag
** 20-Jan-2026  PREETHAM               2.3   Correct FromQty for N strategy
** 01-Apr-2026  KMS043  3.0   UWP-59499
**                                            - LOTTABLE04 >= Today filter
**                                            - Remove NSPRPFIFO bypass
**                                            - Protect today/future from NJOW04
**                                            - One lot, one ID, one source
******************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_GenReplenishmentARLA]
   @c_Zone01     NVARCHAR(10),
   @c_Zone02     NVARCHAR(10),
   @c_Zone03     NVARCHAR(10),
   @c_Zone04     NVARCHAR(10),
   @c_Zone05     NVARCHAR(10),
   @c_Zone06     NVARCHAR(10),
   @c_Zone07     NVARCHAR(10),
   @c_Zone08     NVARCHAR(10),
   @c_Zone09     NVARCHAR(10),
   @c_Zone10     NVARCHAR(10),
   @c_Zone11     NVARCHAR(10),
   @c_Zone12     NVARCHAR(10),
   @c_ReplenFlag NVARCHAR(10) = 'N',
   @c_storerkey  NVARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    ---------------------------------------------------------------------------
    -- 1. VARIABLE DECLARATIONS
    ---------------------------------------------------------------------------
    DECLARE @n_Continue              INT = 1,
            @n_StartTranCount        INT = @@TRANCOUNT,
            @c_Facility              NVARCHAR(5),
            @b_Debug                 INT = 0,
            @c_ReplenishmentGroup    NVARCHAR(10),
            @c_ReplenishmentKey      NVARCHAR(10),
            @d_Today                 DATE = CAST(GETDATE() AS DATE),
            @b_Success               INT,
            @n_Err                   INT,
            @c_ErrMsg                NVARCHAR(255)

    -- Pick location cursor variables
    DECLARE @c_CurrentStorer         NVARCHAR(15),
            @c_CurrentSKU            NVARCHAR(20),
            @c_CurrentLoc            NVARCHAR(10),
            @c_CurrentPriority       NVARCHAR(5),
            @c_CurrentLocType        NVARCHAR(10),
            @n_Qty                   INT,
            @n_QtyPicked             INT,
            @n_QtyAllocated          INT,
            @n_QtyLocLimit           INT,
            @n_QtyLocMinimum         INT,
            @n_CaseCnt               INT,
            @n_Pallet                INT,
            @c_PickCode              NVARCHAR(10)

    -- Replenishment calculation variables
    DECLARE @n_ReplenQty             INT,
            @n_RemainingQty          INT,
            @n_QtyAvailable          INT,
            @n_FromQty               INT,
            @n_OnHandQty             INT,
            @n_FullPackQty           INT,
            @n_PossibleCases         INT,
            @n_LotSKUQty             INT,
            @c_ReplenQtyFlag         NVARCHAR(1)

    -- Source lot variables
    DECLARE @c_FromLoc               NVARCHAR(10),
            @c_FromLot               NVARCHAR(10),
            @c_FromId                NVARCHAR(18),
            @c_LogicalLocation       NVARCHAR(20),
            @c_SortColumn            NVARCHAR(30),
            @c_PackKey               NVARCHAR(10),
            @c_UOM                   NVARCHAR(10),
            @c_UCCNo                 NVARCHAR(20),
            @c_Priority              NVARCHAR(5)

    -- Near expiry variables
    DECLARE @c_ReplExclNearExpiry    NVARCHAR(10),
            @n_NearExpiryDays        INT = 0

    -- FP+UCC variables
    DECLARE @c_PrevStorer            NVARCHAR(15) = '',
            @c_OPTION5               NVARCHAR(MAX),
            @c_BulkLocType           NVARCHAR(MAX)

    DECLARE @t_Bulk_LocType TABLE (
        LocationType NVARCHAR(10) NULL
    )

    -- ASC199 variable
    DECLARE @cUCCStorerConfig        NVARCHAR(20)

    -- SQL builder variables
    DECLARE @c_SQLStatement          NVARCHAR(4000),
            @c_SQLCondition          NVARCHAR(2000) = ''

    ---------------------------------------------------------------------------
    -- 2. INITIALIZE FROM ZONE PARAMETERS
    ---------------------------------------------------------------------------
    SET @c_Facility = @c_Zone01

    -- Debug mode via Zone12
    IF ISNUMERIC(@c_Zone12) = 1 AND @c_Zone12 <> ''
        SET @b_Debug = CAST(@c_Zone12 AS INT)

    -- Default storerkey
    IF ISNULL(RTRIM(@c_storerkey), '') = ''
        SET @c_storerkey = 'ALL'

    -- FP+PARM defaults
    IF @c_ReplenFlag = 'FP+PARM'
    BEGIN
        IF ISNULL(@c_Zone10, '') = '' SET @c_Zone10 = 'ZZZZZZZZZZ'
        IF ISNULL(@c_Zone12, '') = '' SET @c_Zone12 = 'ZZZZZZZZZZ'
    END

    -- FP+PARM2 defaults
    IF @c_ReplenFlag = 'FP+PARM2'
    BEGIN
        IF ISNULL(@c_Zone02, '') = '' SET @c_Zone02 = ''
        IF ISNULL(@c_Zone03, '') = '' SET @c_Zone03 = ''
    END

    -- ASC199: Get UCC storer config
    SELECT @cUCCStorerConfig = SValue
    FROM dbo.StorerConfig WITH (NOLOCK)
    WHERE StorerKey = @c_storerkey
      AND ConfigKey = 'ReplnMaxqtyCheck'

    ---------------------------------------------------------------------------
    -- 3. TEMP TABLES
    ---------------------------------------------------------------------------
    CREATE TABLE #REPLENISHMENT
    (
        StorerKey    NVARCHAR(15),
        SKU          NVARCHAR(20),
        FromLOC      NVARCHAR(10),
        ToLOC        NVARCHAR(10),
        Lot          NVARCHAR(10),
        Id           NVARCHAR(18),
        Qty          INT,
        QtyMoved     INT,
        QtyInPickLOC INT,
        Priority     NVARCHAR(10),
        UOM          NVARCHAR(10),
        PackKey      NVARCHAR(10),
        UCCNo        NVARCHAR(20)
    )

    CREATE TABLE #LOT_SORT
    (
        LOT          NVARCHAR(10),
        SortColumn   NVARCHAR(20)
    )

    ---------------------------------------------------------------------------
    -- 4. GENERATE REPLENISHMENT GROUP KEY
    ---------------------------------------------------------------------------
    EXECUTE nspg_GetKey
            @keyname     = 'REPLENISHGROUP',
            @fieldlength = 10,
            @keystring   = @c_ReplenishmentGroup OUTPUT,
            @b_success   = @b_Success OUTPUT,
            @n_err       = @n_Err OUTPUT,
            @c_errmsg    = @c_ErrMsg OUTPUT

    IF @b_Success <> 1
    BEGIN
        SET @n_Continue = 3
        GOTO ERROR_HANDLER
    END

    IF @b_Debug = 1
    BEGIN
        PRINT '================================================================='
        PRINT '=== isp_GenReplenishment V3.0 ==='
        PRINT '=== Replenishment Group: ' + @c_ReplenishmentGroup + ' ==='
        PRINT '=== Today: ' + CONVERT(NVARCHAR(10), @d_Today, 120) + ' ==='
        PRINT '=== ReplenFlag: ' + @c_ReplenFlag + ' ==='
        PRINT '=== StorerKey: ' + @c_storerkey + ' ==='
        PRINT '=== Facility: ' + @c_Facility + ' ==='
        PRINT '=== Mode: One Lot, One ID, One Source ==='
        PRINT '================================================================='
    END

    ---------------------------------------------------------------------------
    -- 5. BUILD DYNAMIC PICK LOCATION CURSOR
    ---------------------------------------------------------------------------
    IF @c_Storerkey <> 'ALL'
        SET @c_SQLCondition = @c_SQLCondition +
            ' AND SKUxLOC.StorerKey = ''' + RTRIM(@c_storerkey) + ''''

    IF @c_Zone02 <> 'ALL'
    BEGIN
        IF @c_ReplenFlag = 'FP+PARM'
            SET @c_SQLCondition = @c_SQLCondition +
                ' AND LOC.PutawayZone IN (''' +
                RTRIM(ISNULL(@c_Zone02,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone03,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone04,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone05,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone06,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone07,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone08,'')) + ''')'
        ELSE IF @c_ReplenFlag = 'FP+PARM2'
            SET @c_SQLCondition = @c_SQLCondition +
                ' AND LOC.PutawayZone IN (''' +
                RTRIM(ISNULL(@c_Zone03,'')) + ''')'
        ELSE
            SET @c_SQLCondition = @c_SQLCondition +
                ' AND LOC.PutawayZone IN (''' +
                RTRIM(ISNULL(@c_Zone02,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone03,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone04,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone05,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone06,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone07,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone08,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone09,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone10,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone11,'')) + ''',''' +
                RTRIM(ISNULL(@c_Zone12,'')) + ''')'
    END

    IF @c_ReplenFlag = 'FP+PARM'
        SET @c_SQLCondition = @c_SQLCondition +
            ' AND SKUxLOC.Sku BETWEEN ''' + RTRIM(ISNULL(@c_Zone09,'')) +
            ''' AND ''' + RTRIM(ISNULL(@c_Zone10,'')) + '''' +
            ' AND LOC.LocAisle BETWEEN ''' + RTRIM(ISNULL(@c_Zone11,'')) +
            ''' AND ''' + RTRIM(ISNULL(@c_Zone12,'')) + ''''

    SET @c_SQLStatement =
        'DECLARE Cur_PickLocations CURSOR FAST_FORWARD READ_ONLY FOR ' +
        'SELECT SKUxLOC.ReplenishmentPriority, ' +
               'SKUxLOC.StorerKey, ' +
               'SKUxLOC.SKU, ' +
               'SKUxLOC.LOC, ' +
               'SKUxLOC.Qty, ' +
               'SKUxLOC.QtyPicked, ' +
               'SKUxLOC.QtyAllocated, ' +
               'SKUxLOC.QtyLocationLimit, ' +
               'SKUxLOC.QtyLocationMinimum, ' +
               'PACK.CaseCnt, ' +
               'PACK.Pallet, ' +
               'SKU.PickCode, ' +
               'SKUxLOC.LocationType, ' +
               'SC2.Svalue ' +
        'FROM SKUxLOC WITH (NOLOCK) ' +
        'JOIN LOC WITH (NOLOCK) ON SKUxLOC.Loc = LOC.Loc ' +
        'JOIN SKU WITH (NOLOCK) ON SKU.StorerKey = SKUxLOC.StorerKey ' +
               'AND SKU.SKU = SKUxLOC.SKU ' +
        'JOIN PACK WITH (NOLOCK) ON PACK.PackKey = SKU.PackKey ' +
        'LEFT JOIN V_STORERCONFIG2 SC2 ON SKUxLOC.Storerkey = SC2.Storerkey ' +
               'AND SC2.Configkey = ''REPLEXCLPRODNEAREXPIRY_DAY'' ' +
        'WHERE LOC.Facility = ''' + RTRIM(ISNULL(@c_Facility,'')) + ''' ' +
        'AND SKUxLOC.LocationType IN (''PICK'',''CASE'') ' +
        'AND LOC.LocationFlag NOT IN (''DAMAGE'',''HOLD'') ' +
        RTRIM(ISNULL(@c_SQLCondition,'')) + ' ' +
        'ORDER BY SKUxLOC.ReplenishmentPriority, SKUxLOC.Loc'

    EXEC(@c_SQLStatement)

    OPEN Cur_PickLocations

    FETCH NEXT FROM Cur_PickLocations INTO
        @c_CurrentPriority, @c_CurrentStorer, @c_CurrentSKU, @c_CurrentLoc,
        @n_Qty, @n_QtyPicked, @n_QtyAllocated, @n_QtyLocLimit,
        @n_QtyLocMinimum, @n_CaseCnt, @n_Pallet, @c_PickCode,
        @c_CurrentLocType, @c_ReplExclNearExpiry

    ---------------------------------------------------------------------------
    -- 6. MAIN PROCESSING LOOP
    ---------------------------------------------------------------------------
    WHILE @@FETCH_STATUS <> -1
    BEGIN
        SET @c_ReplenQtyFlag = '0'

        IF @b_Debug = 1
        BEGIN
            PRINT ''
            PRINT '========================================================'
            PRINT 'Storer: ' + @c_CurrentStorer +
                  ' | SKU: ' + @c_CurrentSKU +
                  ' | Loc: ' + @c_CurrentLoc +
                  ' | LocType: ' + @c_CurrentLocType
            PRINT '  Qty: ' + CAST(@n_Qty AS NVARCHAR) +
                  ' | Picked: ' + CAST(@n_QtyPicked AS NVARCHAR) +
                  ' | Allocated: ' + CAST(@n_QtyAllocated AS NVARCHAR) +
                  ' | Limit: ' + CAST(@n_QtyLocLimit AS NVARCHAR) +
                  ' | Minimum: ' + CAST(@n_QtyLocMinimum AS NVARCHAR)
        END

        -----------------------------------------------------------------------
        -- 6a. LOAD BULK LOCATION TYPES PER STORER (FP+UCC)
        -----------------------------------------------------------------------
        IF @c_CurrentStorer <> @c_PrevStorer
        BEGIN
            SET @c_PrevStorer = @c_CurrentStorer
            SET @c_OPTION5 = ''
            SET @c_BulkLocType = ''
            DELETE FROM @t_Bulk_LocType

            SELECT @c_OPTION5 = OPTION5
            FROM dbo.fnc_GetRight2('', @c_CurrentStorer, '', 'CustomReplen_LocType')
            WHERE Authority = '1'

            SET @c_BulkLocType = dbo.fnc_GetParamValueFromString(
                '@c_BulkLocType', @c_OPTION5, @c_BulkLocType)

            INSERT INTO @t_Bulk_LocType (LocationType)
            SELECT DISTINCT TRIM(value)
            FROM STRING_SPLIT(@c_BulkLocType, ',')
            WHERE value <> ''
            ORDER BY 1

            IF @@ROWCOUNT <= 0
                INSERT INTO @t_Bulk_LocType (LocationType) VALUES ('BULK')
        END

        -----------------------------------------------------------------------
        -- 6b. SKIP: DRP task already in progress
        -----------------------------------------------------------------------
        IF EXISTS(
            SELECT 1 FROM dbo.TASKDETAIL WITH (NOLOCK)
            WHERE Status IN ('0','3')
              AND TaskType = 'DRP'
              AND ToLoc = @c_CurrentLoc
              AND StorerKey = @c_CurrentStorer
              AND Sku = @c_CurrentSKU
        )
        BEGIN
            IF @b_Debug = 1
                PRINT '  SKIP: DRP task in progress for this SKU/LOC'
            GOTO NEXT_PICK_LOCATION
        END

        -----------------------------------------------------------------------
        -- 6c. DELETE unconfirmed replenishment records
        -----------------------------------------------------------------------
        IF EXISTS(
            SELECT 1 FROM dbo.REPLENISHMENT R WITH (NOLOCK)
            WHERE R.StorerKey = @c_CurrentStorer
              AND R.Sku = @c_CurrentSKU
              AND R.ToLoc = @c_CurrentLoc
              AND R.Confirmed = 'N'
        )
        BEGIN
            IF @b_Debug = 1
                PRINT '  Deleting previous unconfirmed replenishment records'

            DELETE R
            FROM dbo.REPLENISHMENT R
            JOIN dbo.SKUxLOC SL WITH (NOLOCK)
                ON SL.StorerKey = R.StorerKey
               AND SL.Sku = R.Sku
               AND SL.Loc = R.ToLoc
            WHERE R.StorerKey = @c_CurrentStorer
              AND R.Sku = @c_CurrentSKU
              AND R.ToLoc = @c_CurrentLoc
              AND R.Confirmed = 'N'
              AND SL.LocationType = @c_CurrentLocType
              AND R.ReplenishmentGroup NOT IN ('DYNAMIC')
        END

        -----------------------------------------------------------------------
        -- 6d. CALCULATE REPLENISHMENT QTY
        -----------------------------------------------------------------------
        SET @n_ReplenQty = @n_QtyLocLimit - (@n_Qty - @n_QtyPicked)
        SET @n_QtyAvailable = @n_Qty - @n_QtyPicked

        IF @c_ReplenFlag IN ('W', 'WHC')
        BEGIN
            IF (@n_Qty - (@n_QtyPicked + @n_QtyAllocated)) < 0
                SET @n_ReplenQty = @n_QtyLocLimit +
                    ABS(@n_Qty - (@n_QtyPicked + @n_QtyAllocated))
            ELSE
                SET @n_ReplenQty = @n_QtyLocLimit -
                    (@n_Qty - (@n_QtyPicked + @n_QtyAllocated))

            IF @n_ReplenQty < 0
            BEGIN
                SET @c_ReplenQtyFlag = '1'
                IF @c_CurrentLocType = 'PICK'
                   AND @c_ReplenFlag IN ('WHC','PPHC','W','N')
                    SET @n_ReplenQty = @n_QtyLocLimit
                ELSE
                    SET @n_ReplenQty = @n_Pallet
            END
            SET @n_QtyAvailable = @n_QtyAvailable - @n_QtyAllocated
        END
        ELSE IF @c_ReplenFlag IN ('PP', 'PPHC')
        BEGIN
            SET @n_ReplenQty = @n_ReplenQty + @n_QtyAllocated
            SET @n_QtyAvailable = @n_QtyAvailable - @n_QtyAllocated
        END

        IF @b_Debug = 1
        BEGIN
            PRINT '  QtyAvailable: ' + CAST(@n_QtyAvailable AS NVARCHAR) +
                  ' | QtyLocMinimum: ' + CAST(@n_QtyLocMinimum AS NVARCHAR) +
                  ' | ReplenQty: ' + CAST(@n_ReplenQty AS NVARCHAR) +
                  ' | ReplenQtyFlag: ' + @c_ReplenQtyFlag
        END

        -- Check: does this location need replenishment?
        IF @n_QtyAvailable > @n_QtyLocMinimum
        BEGIN
            IF @b_Debug = 1
                PRINT '  SKIP: Available > Minimum, no replenishment needed'
            GOTO NEXT_PICK_LOCATION
        END

        SET @n_RemainingQty = @n_ReplenQty

        -----------------------------------------------------------------------
        -- 6e. POPULATE #LOT_SORT — LOTTABLE04 >= TODAY (FEFO ORDER)
        -----------------------------------------------------------------------
        DELETE FROM #LOT_SORT

        -- Step 1: Over-allocated lots in current pick location
        INSERT INTO #LOT_SORT (LOT, SortColumn)
        SELECT DISTINCT LOT, ''
        FROM dbo.LOTxLOCxID WITH (NOLOCK)
        WHERE StorerKey = @c_CurrentStorer
          AND SKU = @c_CurrentSKU
          AND LOC = @c_CurrentLoc
          AND (Qty - QtyAllocated - QtyPicked) < 0

        -- Step 2: Eligible source lots
        IF @c_ReplenFlag = 'FP+UCC'
        BEGIN
            ---------------------------------------------------------------
            -- FP+UCC: Source from CASE (for PICK) or BULK (for CASE)
            ---------------------------------------------------------------
            INSERT INTO #LOT_SORT (LOT, SortColumn)
            SELECT DISTINCT
                   LLI.LOT,
                   ISNULL(CONVERT(NVARCHAR(8), LA.LOTTABLE04, 112), '00000000')
                   + ISNULL(CONVERT(NVARCHAR(8), LA.LOTTABLE05, 112), '00000000')
            FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
            JOIN dbo.LOC LOC WITH (NOLOCK) ON LLI.LOC = LOC.LOC
            JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) ON LLI.LOT = LA.LOT
            JOIN dbo.LOT LOT WITH (NOLOCK) ON LOT.LOT = LLI.LOT
            JOIN dbo.ID ID WITH (NOLOCK) ON ID.ID = LLI.ID
            JOIN dbo.SKUxLOC SL WITH (NOLOCK)
                 ON SL.StorerKey = LLI.StorerKey
                AND SL.SKU = LLI.SKU
                AND SL.LOC = LLI.LOC
            WHERE LLI.StorerKey = @c_CurrentStorer
              AND LLI.SKU = @c_CurrentSKU
              AND LOC.LocationFlag NOT IN ('DAMAGE','HOLD')
              AND LOC.Facility = @c_Facility
              AND LOC.Status = 'OK'
              AND LOT.Status = 'OK'
              AND ID.Status = 'OK'
              AND (@c_CurrentLocType = 'PICK' AND LOC.Locationtype = 'CASE'
                OR @c_CurrentLocType = 'CASE' AND LOC.Locationtype IN
                   (SELECT LocationType FROM @t_Bulk_LocType))
              AND LLI.LOC <> @c_CurrentLoc
              AND (LLI.Qty - LLI.QtyPicked - LLI.QtyAllocated) > 0
              AND (@c_CurrentLocType = 'PICK' AND SL.Locationtype <> 'PICK'
                OR @c_CurrentLocType = 'CASE' AND SL.Locationtype NOT IN ('CASE','PICK'))
              AND NOT EXISTS (SELECT 1 FROM #LOT_SORT L WHERE L.LOT = LLI.LOT)
              ---------------------------------------------------------
              -- *** LOTTABLE04 >= TODAY ***
              ---------------------------------------------------------
              AND CAST(LA.LOTTABLE04 AS DATE) >= @d_Today
            ORDER BY 2
        END
        ELSE
        BEGIN
            ---------------------------------------------------------------
            -- ALL OTHER FLAGS: Source from BULK locations
            -- Replaces NSPRPFIFO — all lots go through same filter
            ---------------------------------------------------------------
            INSERT INTO #LOT_SORT (LOT, SortColumn)
            SELECT DISTINCT
                   LLI.LOT,
                   ISNULL(CONVERT(NVARCHAR(8), LA.LOTTABLE04, 112), '99991231')
                   + ISNULL(CONVERT(NVARCHAR(8), LA.LOTTABLE05, 112), '99991231')
            FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
            JOIN dbo.LOC LOC WITH (NOLOCK) ON LLI.LOC = LOC.LOC
            JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) ON LLI.LOT = LA.LOT
            JOIN dbo.LOT LOT WITH (NOLOCK) ON LOT.LOT = LLI.LOT
            JOIN dbo.ID ID WITH (NOLOCK) ON ID.ID = LLI.ID
            JOIN dbo.SKUxLOC SL WITH (NOLOCK)
                 ON SL.StorerKey = LLI.StorerKey
                AND SL.SKU = LLI.SKU
                AND SL.LOC = LLI.LOC
            WHERE LLI.StorerKey = @c_CurrentStorer
              AND LLI.SKU = @c_CurrentSKU
              AND LLI.LOC <> @c_CurrentLoc
              AND LOC.LocationFlag NOT IN ('DAMAGE', 'HOLD')
              AND LOC.Facility = @c_Facility
              AND LOC.Status = 'OK'
              AND LOT.Status = 'OK'
              AND ID.Status = 'OK'
              AND LOC.Locationtype NOT IN ('CASE', 'PICK')
              AND SL.Locationtype NOT IN ('CASE', 'PICK')
              AND (LLI.Qty - LLI.QtyPicked - LLI.QtyAllocated) > 0
              AND NOT EXISTS (SELECT 1 FROM #LOT_SORT L WHERE L.LOT = LLI.LOT)
              AND LOC.PUTAWAYZONE = CASE WHEN @c_ReplenFlag = 'FP+PARM2'
                                         THEN @c_Zone02
                                         ELSE LOC.PUTAWAYZONE END
              ---------------------------------------------------------
              -- *** LOTTABLE04 >= TODAY ***
              ---------------------------------------------------------
              AND CAST(LA.LOTTABLE04 AS DATE) >= @d_Today
            ORDER BY 2
        END

        -----------------------------------------------------------------------
        -- 6f. NEAR-EXPIRY EXCLUSION (with today & future protection)
        -----------------------------------------------------------------------
        SET @n_NearExpiryDays = 0
        IF ISNULL(@c_ReplExclNearExpiry, '0') <> '0'
           AND ISNUMERIC(@c_ReplExclNearExpiry) = 1
        BEGIN
            SET @n_NearExpiryDays = CONVERT(INT, @c_ReplExclNearExpiry) * -1

            IF @b_Debug = 1
                PRINT '  Near-Expiry Days Config: ' +
                      CAST(@c_ReplExclNearExpiry AS NVARCHAR)

            DELETE LS
            FROM #LOT_SORT LS
            JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) ON LS.LOT = LA.LOT
            WHERE ISNULL(LS.SortColumn, '') <> ''
              AND DATEADD(DAY, @n_NearExpiryDays, LA.LOTTABLE04) <= GETDATE()
              ---------------------------------------------------------
              -- *** PROTECTION: Never delete today or future lots ***
              ---------------------------------------------------------
              AND CAST(LA.LOTTABLE04 AS DATE) < @d_Today
        END

        -- Check if any lots available
        IF NOT EXISTS (SELECT 1 FROM #LOT_SORT WHERE ISNULL(SortColumn,'') <> '')
        BEGIN
            IF @b_Debug = 1
                PRINT '  SKIP: No eligible source lots with LOTTABLE04 >= today'
            GOTO NEXT_PICK_LOCATION
        END

        -- Debug: list eligible lots
        IF @b_Debug = 1
        BEGIN
            DECLARE @c_DbgLot NVARCHAR(10), @c_DbgSort NVARCHAR(20)
            DECLARE Cur_Debug CURSOR LOCAL FAST_FORWARD FOR
                SELECT LOT, SortColumn FROM #LOT_SORT
                WHERE ISNULL(SortColumn,'') <> ''
                ORDER BY SortColumn
            OPEN Cur_Debug
            FETCH NEXT FROM Cur_Debug INTO @c_DbgLot, @c_DbgSort
            WHILE @@FETCH_STATUS = 0
            BEGIN
                PRINT '  Eligible LOT: ' + @c_DbgLot + ' | Sort: ' + @c_DbgSort
                FETCH NEXT FROM Cur_Debug INTO @c_DbgLot, @c_DbgSort
            END
            CLOSE Cur_Debug
            DEALLOCATE Cur_Debug
        END

        -----------------------------------------------------------------------
        -- 6g. LOT CURSOR (FEFO ORDER — earliest LOTTABLE04 first)
        -----------------------------------------------------------------------
        DECLARE Cur_Lots CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT DISTINCT LOT, SortColumn
            FROM   #LOT_SORT
            ORDER BY SortColumn
        OPEN Cur_Lots

        FETCH NEXT FROM Cur_Lots INTO @c_FromLot, @c_SortColumn

        WHILE @@FETCH_STATUS <> -1 AND @n_RemainingQty > 0
        BEGIN
            IF @b_Debug = 1
                PRINT '    Processing LOT: ' + @c_FromLot +
                      ' | SortColumn: ' + ISNULL(@c_SortColumn,'')

            -------------------------------------------------------------------
            -- 6h. LOTxLOCxID DETAIL CURSOR
            -------------------------------------------------------------------
            IF @c_ReplenFlag = 'FP+UCC'
                DECLARE Cur_LotDetail CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                    SELECT LLI.LOC,
                           LLI.ID,
                           CASE WHEN ISNULL(UCC.UCCNo,'') <> ''
                                THEN UCC.Qty
                                ELSE (LLI.Qty - LLI.QtyPicked - LLI.QtyAllocated)
                           END AS OnHandQty,
                           LOC.LogicalLocation,
                           ISNULL(UCC.UCCNo,'') AS UCCNo
                    FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                    JOIN dbo.LOC LOC WITH (NOLOCK) ON LLI.LOC = LOC.Loc
                    JOIN dbo.ID ID WITH (NOLOCK) ON LLI.ID = ID.Id
                    JOIN dbo.SKUxLOC SL WITH (NOLOCK)
                         ON SL.StorerKey = LLI.StorerKey
                        AND SL.SKU = LLI.SKU
                        AND SL.LOC = LLI.LOC
                    LEFT JOIN dbo.UCC UCC WITH (NOLOCK)
                         ON LLI.StorerKey = UCC.StorerKey
                        AND LLI.Sku = UCC.Sku
                        AND LLI.Lot = UCC.Lot
                        AND LLI.Loc = UCC.Loc
                        AND LLI.ID = UCC.ID
                        AND UCC.Status = '1'
                        AND UCC.Qty > 0
                        AND LLI.Qty - LLI.QtyPicked - LLI.QtyAllocated >= UCC.Qty
                        AND @c_CurrentLocType = 'PICK'
                    WHERE LLI.LOT = @c_FromLot
                      AND LOC.LocationFlag NOT IN ('DAMAGE','HOLD')
                      AND LOC.Facility = @c_Facility
                      AND LOC.Status = 'OK'
                      AND ID.Status = 'OK'
                      AND (@c_CurrentLocType = 'PICK' AND LOC.Locationtype = 'CASE'
                        OR @c_CurrentLocType = 'CASE' AND LOC.Locationtype IN
                           (SELECT LocationType FROM @t_Bulk_LocType))
                      AND (@c_CurrentLocType = 'PICK' AND SL.Locationtype <> 'PICK'
                        OR @c_CurrentLocType = 'CASE' AND SL.Locationtype NOT IN ('CASE','PICK'))
                      AND (LLI.Qty - LLI.QtyPicked - LLI.QtyAllocated) > 0
                      AND NOT (@c_CurrentLocType = 'CASE' AND LLI.ID = '')
                    ORDER BY
                        (CASE WHEN ISNULL(UCC.UCCNo,'') <> ''
                              THEN UCC.Qty
                              ELSE (LLI.Qty - LLI.QtyPicked - LLI.QtyAllocated)
                         END),
                        LOC.LogicalLocation
            ELSE
                DECLARE Cur_LotDetail CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                    SELECT LLI.LOC,
                           LLI.ID,
                           (LLI.Qty - LLI.QtyPicked - LLI.QtyAllocated) AS OnHandQty,
                           LOC.LogicalLocation,
                           CAST('' AS NVARCHAR(20)) AS UCCNo
                    FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                    JOIN dbo.LOC LOC WITH (NOLOCK) ON LLI.LOC = LOC.Loc
                    JOIN dbo.ID ID WITH (NOLOCK) ON LLI.ID = ID.Id
                    JOIN dbo.SKUxLOC SL WITH (NOLOCK)
                         ON SL.StorerKey = LLI.StorerKey
                        AND SL.SKU = LLI.SKU
                        AND SL.LOC = LLI.LOC
                    WHERE LLI.LOT = @c_FromLot
                      AND LOC.LocationFlag NOT IN ('DAMAGE','HOLD')
                      AND LOC.Facility = @c_Facility
                      AND LOC.Status = 'OK'
                      AND ID.Status = 'OK'
                      AND LOC.Locationtype NOT IN ('CASE','PICK')
                      AND SL.Locationtype NOT IN ('CASE','PICK')
                      AND (LLI.Qty - LLI.QtyPicked - LLI.QtyAllocated) > 0
                      AND LOC.PUTAWAYZONE = CASE WHEN @c_ReplenFlag = 'FP+PARM2'
                                                  THEN @c_Zone02
                                                  ELSE LOC.PUTAWAYZONE END
                    ORDER BY (LLI.Qty - LLI.QtyPicked - LLI.QtyAllocated),
                             LOC.LogicalLocation

            OPEN Cur_LotDetail

            FETCH NEXT FROM Cur_LotDetail INTO
                @c_FromLoc, @c_FromId, @n_OnHandQty,
                @c_LogicalLocation, @c_UCCNo

            WHILE @@FETCH_STATUS <> -1
            BEGIN
                -- Deduct already-allocated replen qty from this lot/loc/id
                SET @n_LotSKUQty = 0
                SELECT @n_LotSKUQty = ISNULL(SUM(Qty), 0)
                FROM #REPLENISHMENT WITH (NOLOCK)
                WHERE Lot = @c_FromLot
                  AND FromLOC = @c_FromLoc
                  AND Id = @c_FromId

                SET @n_OnHandQty = @n_OnHandQty - @n_LotSKUQty

                IF @n_OnHandQty <= 0
                    GOTO NEXT_LOT_DETAIL

                -- FP+PARM: skip partial pallets
                IF @c_ReplenFlag IN ('FP+PARM')
                   AND @n_OnHandQty > @n_RemainingQty
                BEGIN
                    SET @n_RemainingQty = 0
                    BREAK
                END

                IF @b_Debug = 1
                    PRINT '      FromLoc: ' + @c_FromLoc +
                          ' | ID: ' + @c_FromId +
                          ' | OnHand: ' + CAST(@n_OnHandQty AS NVARCHAR) +
                          ' | UCCNo: ' + ISNULL(@c_UCCNo,'')

                -- CaseCnt safety
                IF ISNULL(@n_CaseCnt, 0) = 0
                    SET @n_CaseCnt = 1

                -- Calculate possible cases
                IF @n_OnHandQty < @n_RemainingQty
                    SET @n_PossibleCases = FLOOR(@n_OnHandQty / @n_CaseCnt)
                ELSE
                    SET @n_PossibleCases = CEILING(
                        @n_RemainingQty / (@n_CaseCnt * 1.00))

                -- Get pack info
                SELECT @c_PackKey = P.PackKey,
                       @c_UOM = P.PackUOM3
                FROM dbo.SKU S WITH (NOLOCK)
                JOIN dbo.PACK P WITH (NOLOCK) ON S.PackKey = P.PackKey
                WHERE S.StorerKey = @c_CurrentStorer
                  AND S.SKU = @c_CurrentSKU

                ---------------------------------------------------------------
                -- CALCULATE FULL PACK QTY
                ---------------------------------------------------------------
                IF @c_CurrentLocType = 'PICK'
                BEGIN
                    IF @c_ReplenFlag IN ('PPHC','WHC')
                    BEGIN
                        IF @c_ReplenQtyFlag = '1'
                            SET @n_FullPackQty = @n_QtyLocLimit
                        ELSE
                            SET @n_FullPackQty = @n_OnHandQty
                    END
                    ELSE IF @c_ReplenFlag IN ('W','N')
                    BEGIN
                        IF @n_QtyLocLimit = 0 AND @n_CaseCnt > 1
                            SET @n_FullPackQty = @n_CaseCnt
                        ELSE
                            SET @n_FullPackQty = @n_OnHandQty
                    END
                    ELSE IF @c_ReplenFlag = 'FP+UCC'
                    BEGIN
                        IF @cUCCStorerConfig = '1'
                            SET @n_FullPackQty = CASE
                                WHEN ISNULL(@c_UCCNo,'') <> ''
                                     AND @n_OnHandQty <= @n_QtyLocLimit
                                THEN @n_OnHandQty ELSE 0 END
                        ELSE
                            SET @n_FullPackQty = CASE
                                WHEN ISNULL(@c_UCCNo,'') <> ''
                                THEN @n_OnHandQty ELSE 0 END
                    END
                    ELSE
                        SET @n_FullPackQty = @n_OnHandQty
                END
                ELSE -- CASE location type
                BEGIN
                    IF @c_ReplenFlag = 'FP+UCC'
                        SET @n_FullPackQty = CASE
                            WHEN ISNULL(@c_FromId,'') <> ''
                            THEN @n_OnHandQty ELSE 0 END
                    ELSE
                        SET @n_FullPackQty = @n_Pallet
                END

                IF @b_Debug = 1
                    PRINT '      FullPackQty: ' + CAST(@n_FullPackQty AS NVARCHAR) +
                          ' | PossibleCases: ' + CAST(@n_PossibleCases AS NVARCHAR)

                ---------------------------------------------------------------
                -- CALCULATE FROM QTY
                ---------------------------------------------------------------
                IF (@n_OnHandQty <= @n_FullPackQty)
                   AND (@n_OnHandQty <= @n_RemainingQty)
                BEGIN
                    -- Source has less than or equal to what we need
                    IF @c_CurrentLocType = 'PICK'
                       AND @c_ReplenFlag IN ('WHC','PPHC')
                        SET @n_FromQty = @n_OnHandQty
                    ELSE IF @n_PossibleCases > 0
                    BEGIN
                        IF @c_ReplenFlag IN ('WHC','PPHC')
                            SET @n_FromQty = @n_CaseCnt * @n_PossibleCases
                        ELSE
                            SET @n_FromQty = @n_OnHandQty
                    END
                    ELSE IF @c_ReplenFlag IN ('N','W')
                        SET @n_FromQty = @n_OnHandQty
                    ELSE
                        SET @n_FromQty = 0

                    SET @n_RemainingQty = @n_RemainingQty - @n_FromQty
                END
                ELSE
                BEGIN
                    -- Source has more than what we need
                    IF @c_CurrentLocType = 'CASE'
                    BEGIN
                        IF @c_ReplenFlag IN ('WHC','PPHC')
                        BEGIN
                            IF (@n_OnHandQty % @n_CaseCnt) > 0
                            BEGIN
                                IF @n_OnHandQty < @n_CaseCnt
                                    SET @n_FromQty = 0
                                ELSE
                                    SET @n_FromQty = @n_OnHandQty -
                                        (@n_OnHandQty % @n_CaseCnt)
                            END
                            ELSE
                                SET @n_FromQty = @n_OnHandQty
                        END
                        ELSE
                        BEGIN
                            IF FLOOR(@n_OnHandQty / @n_CaseCnt) > 0
                            BEGIN
                                IF @n_OnHandQty < @n_RemainingQty
                                    SET @n_FromQty = FLOOR(
                                        @n_OnHandQty / @n_CaseCnt) * @n_CaseCnt
                                ELSE
                                    SET @n_FromQty = CEILING(
                                        @n_RemainingQty / (@n_CaseCnt * 1.00))
                                        * @n_CaseCnt
                            END
                            ELSE
                                SET @n_FromQty = 0
                        END
                    END
                    ELSE -- PICK
                    BEGIN
                        IF @n_OnHandQty >= @n_FullPackQty
                        BEGIN
                            IF @c_ReplenFlag IN ('PPHC','WHC')
                                SET @n_FromQty = @n_RemainingQty
                            ELSE
                                SET @n_FromQty = CASE
                                    WHEN @n_FullPackQty >= @n_RemainingQty
                                    THEN @n_RemainingQty
                                    ELSE @n_FullPackQty END
                        END
                        ELSE
                        BEGIN
                            IF @c_ReplenFlag IN ('PPHC','WHC')
                                SET @n_FromQty = @n_RemainingQty
                            ELSE
                                SET @n_FromQty = 0
                        END
                    END

                    SET @n_RemainingQty = @n_RemainingQty - @n_FromQty
                END

                IF @b_Debug = 1
                    PRINT '      FromQty: ' + CAST(@n_FromQty AS NVARCHAR) +
                          ' | RemainingQty: ' + CAST(@n_RemainingQty AS NVARCHAR)

                ---------------------------------------------------------------
                -- INSERT REPLENISHMENT RECORD & BREAK (ONE LOT, ONE ID)
                ---------------------------------------------------------------
                IF @n_FromQty > 0
                BEGIN
                    INSERT INTO #REPLENISHMENT
                        (StorerKey, SKU, FromLOC, ToLOC, Lot, Id,
                         Qty, UOM, PackKey, Priority,
                         QtyMoved, QtyInPickLOC, UCCNo)
                    VALUES
                        (@c_CurrentStorer, @c_CurrentSKU, @c_FromLoc,
                         @c_CurrentLoc, @c_FromLot, @c_FromId,
                         @n_FromQty, @c_UOM, @c_PackKey,
                         @c_CurrentPriority, 0, 0, @c_UCCNo)

                    IF @b_Debug = 1
                        PRINT '      >>> INSERTED: Lot=' + @c_FromLot +
                              ' ID=' + @c_FromId +
                              ' Qty=' + CAST(@n_FromQty AS NVARCHAR)

                    ---------------------------------------------------------
                    -- *** ONE LOT, ONE ID, ONE SOURCE ***
                    -- Stop processing further IDs for this lot
                    -- If more qty needed, next lot in FEFO order is used
                    ---------------------------------------------------------
                    BREAK
                END

                -- If remaining < 90% of case for PICK, stop entirely
                IF @c_CurrentLocType = 'PICK'
                   AND (@n_RemainingQty / (@n_CaseCnt * 1.00)) * 100 < 90
                BEGIN
                    SET @n_RemainingQty = 0
                    BREAK
                END

                NEXT_LOT_DETAIL:
                FETCH NEXT FROM Cur_LotDetail INTO
                    @c_FromLoc, @c_FromId, @n_OnHandQty,
                    @c_LogicalLocation, @c_UCCNo
            END -- Cur_LotDetail

            CLOSE Cur_LotDetail
            DEALLOCATE Cur_LotDetail

            IF @n_RemainingQty <= 0
                BREAK

            FETCH NEXT FROM Cur_Lots INTO @c_FromLot, @c_SortColumn
        END -- Cur_Lots

        CLOSE Cur_Lots
        DEALLOCATE Cur_Lots

        NEXT_PICK_LOCATION:
        FETCH NEXT FROM Cur_PickLocations INTO
            @c_CurrentPriority, @c_CurrentStorer, @c_CurrentSKU,
            @c_CurrentLoc, @n_Qty, @n_QtyPicked, @n_QtyAllocated,
            @n_QtyLocLimit, @n_QtyLocMinimum, @n_CaseCnt, @n_Pallet,
            @c_PickCode, @c_CurrentLocType, @c_ReplExclNearExpiry
    END -- Main Loop

    CLOSE Cur_PickLocations
    DEALLOCATE Cur_PickLocations

    ---------------------------------------------------------------------------
    -- 7. UPDATE QtyInPickLOC
    ---------------------------------------------------------------------------
    IF @n_Continue = 1 OR @n_Continue = 2
    BEGIN
        UPDATE R
        SET    QtyInPickLOC = SL.Qty - SL.QtyPicked
        FROM   #REPLENISHMENT R
        JOIN   dbo.SKUxLOC SL WITH (NOLOCK)
               ON R.StorerKey = SL.StorerKey
              AND R.SKU = SL.SKU
              AND R.ToLOC = SL.LOC
    END

    ---------------------------------------------------------------------------
    -- 8. INSERT INTO LIVE REPLENISHMENT TABLE
    ---------------------------------------------------------------------------
    DECLARE Cur_Final CURSOR FAST_FORWARD READ_ONLY FOR
        SELECT StorerKey, SKU, FromLOC, ToLOC, Lot, Id,
               Qty, UOM, PackKey, Priority, UCCNo
        FROM #REPLENISHMENT

    OPEN Cur_Final

    FETCH NEXT FROM Cur_Final INTO
        @c_CurrentStorer, @c_CurrentSKU, @c_FromLoc, @c_CurrentLoc,
        @c_FromLot, @c_FromId, @n_FromQty, @c_UOM, @c_PackKey,
        @c_Priority, @c_UCCNo

    WHILE @@FETCH_STATUS <> -1
    BEGIN
        EXECUTE nspg_GetKey
                'REPLENISHKEY', 10,
                @c_ReplenishmentKey OUTPUT,
                @b_Success OUTPUT,
                @n_Err OUTPUT,
                @c_ErrMsg OUTPUT

        IF @b_Success <> 1
            BREAK

        INSERT INTO dbo.REPLENISHMENT
            (ReplenishmentGroup, ReplenishmentKey, StorerKey, Sku,
             FromLoc, ToLoc, Lot, Id, Qty, UOM, PackKey,
             Confirmed, RefNo)
        VALUES
            (@c_ReplenishmentGroup, @c_ReplenishmentKey,
             @c_CurrentStorer, @c_CurrentSKU, @c_FromLoc,
             @c_CurrentLoc, @c_FromLot, @c_FromId, @n_FromQty,
             @c_UOM, @c_PackKey, 'N', @c_UCCNo)

        SELECT @n_Err = @@ERROR

        IF @n_Err <> 0
        BEGIN
            SET @n_Continue = 3
            SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) +
                ': Insert into REPLENISHMENT table failed. ' +
                'Preallocated QTY needs manual adjustment. ' +
                '(isp_GenReplenishment)'
            BREAK
        END

        IF @b_Debug = 1
            PRINT 'COMMITTED: Key=' + @c_ReplenishmentKey +
                  ' | SKU=' + @c_CurrentSKU +
                  ' | From=' + @c_FromLoc +
                  ' | To=' + @c_CurrentLoc +
                  ' | Lot=' + @c_FromLot +
                  ' | ID=' + @c_FromId +
                  ' | Qty=' + CAST(@n_FromQty AS NVARCHAR)

        FETCH NEXT FROM Cur_Final INTO
            @c_CurrentStorer, @c_CurrentSKU, @c_FromLoc, @c_CurrentLoc,
            @c_FromLot, @c_FromId, @n_FromQty, @c_UOM, @c_PackKey,
            @c_Priority, @c_UCCNo
    END

    CLOSE Cur_Final
    DEALLOCATE Cur_Final

    ---------------------------------------------------------------------------
    -- 9. ERROR HANDLING & CLEANUP
    ---------------------------------------------------------------------------
    ERROR_HANDLER:

    IF @n_Continue = 3
    BEGIN
        IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTranCount
            ROLLBACK TRAN
        ELSE
        BEGIN
            WHILE @@TRANCOUNT > @n_StartTranCount
                COMMIT TRAN
        END

        EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_GenReplenishment'
        RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR
        RETURN
    END
    ELSE
    BEGIN
        WHILE @@TRANCOUNT > @n_StartTranCount
            COMMIT TRAN
    END

    IF @b_Debug = 1
    BEGIN
        PRINT ''
        PRINT '================================================================='
        PRINT '=== Replenishment Complete ==='
        PRINT '================================================================='
    END
END
