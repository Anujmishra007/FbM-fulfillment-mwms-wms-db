SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: ispPAARLA2                                         */
/* Creation Date : 26-Feb-2026                                          */
/* Copyright     : LFL                                                  */
/* Written by    : SYO054                                               */
/*  FCR:UWP-59480                                                       */
/* Purpose:                                                             */
/*   ARLA-specific Putaway Release logic with location sequencing,      */
/*   zone matching, AGV/Manual operation mode routing, and              */
/*   LocationGroup-based filtering.                                     */
/*                                                                      */
/*   - Release Putaway From (PAF) tasks for ASN pallets.                */
/*   - Suggest PA (putaway) location sequenced by LOC.PALogicalLoc.     */
/*   - Match SKU.PutawayZone to LOC.PutawayZone.                       */
/*   - RECEIPTDETAIL.ToID = PALLET.PalletKey.                           */
/*   - SKU.StorerKey = RECEIPTDETAIL.StorerKey.                         */
/*   - Only use empty target locations (no stock, no pending PA tasks). */
/*   - Location must fit pallet L/W/H/Weight and be the closest fit.   */
/*   - AGV/Manual mode: SKU.ItemClass + pallet type + weight decide    */
/*     whether task is routed to AGV or Manual operator.                */
/*   - When Message01 = AGV, skip TASKDETAIL insert (AGV handles it).  */
/*   - Restrict SuggestedLoc to same LocationGroup as ToLoc.           */
/*                                                                      */
/* Input Parameters:                                                    */
/*   @c_ReceiptKey  NVARCHAR(10)  - Receipt key to release PA tasks for */
/*   @b_Debug       INT           - 0 = silent, 1 = print debug info    */
/*                                                                      */
/* Output Parameters:                                                   */
/*   @b_Success     INT           - 1 = success, 0 = failure            */
/*   @n_err         INT           - Error number (if any)               */
/*   @c_errmsg      NVARCHAR(250) - Error message text                  */
/*                                                                      */
/* Return Status:  None                                                 */
/*                                                                      */
/* Called By: isp_ASNReleasePATask_Wrapper                              */
/*            Storerconfig: ASNReleasePATask_SP = 'ispPAARLA2'          */
/*                                                                      */
/* Version: 2.0                                                         */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purpose                                   */
/* ----------   ------   ---  ----------------------------------------  */
/* 26-Feb-2026  SYO054   1.0  Initial ARLA implementation with          */
/*                            best-fit dimensional logic (ispPAARLA)     */
/* 12-Mar-2026  SYO054   1.0  ispPAARLA2: AGV/Manual mode routing       */
/* 05-Jun-2026  SYO054   1.1  Fallback to PalletTypeMaster for L/W/H   */
/*                            and RECEIPTDETAIL.Lottable09 for weight   */
/*                            when PALLET table has no data             */
/* 05-Jun-2026  SYO054   1.2  Added @b_Debug parameter with PRINT      */
/*                            statements for runtime troubleshooting    */
/* 05-Jun-2026  SYO054   1.3  Replaced AISLEPRIOR CODELKUP sequencing  */
/*                            with LOC.PALogicalLoc for location order; */
/*                            LocationGroup-based SuggestedLoc filter;  */
/*                            Skip TASKDETAIL insert when Message01=AGV */
/* 08-Jun-2026  SYO054   2.0  Merged ispPAARLA + ispPAARLA2 into one   */
/*                            procedure combining robust pallet dim     */
/*                            fallback chain, #LOC_Candidates temp      */
/*                            table, FitScore CTE, AGV/Manual routing,  */
/*                            and LocationGroup filtering.              */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[ispPAARLA2]
    @c_ReceiptKey  NVARCHAR(10),
    @b_Success     INT OUTPUT,
    @n_err         INT OUTPUT,
    @c_errmsg      NVARCHAR(250) OUTPUT,
    @b_Debug       INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET QUOTED_IDENTIFIER OFF;
    SET ANSI_NULLS OFF;
    SET CONCAT_NULL_YIELDS_NULL OFF;

    --------------------------------------------------------------------
    -- Debug: Entry point
    --------------------------------------------------------------------
    IF @b_Debug = 1
        PRINT '=== [ispPAARLA2] START === ReceiptKey=' + ISNULL(@c_ReceiptKey,'NULL')
              + ' | Debug=1 | Time=' + CONVERT(NVARCHAR(30), GETDATE(), 121);

    --------------------------------------------------------------------
    -- Local variable declarations
    --------------------------------------------------------------------
    DECLARE @n_continue          INT
          , @n_StartTCnt         INT
          , @n_NoOfTasks         INT
          , @c_TaskDetailKey     NVARCHAR(10)
          , @c_Storerkey         NVARCHAR(15)
          , @c_SourceKey         NVARCHAR(30)
          , @c_PickMethod        NVARCHAR(10)
          , @c_ToID              NVARCHAR(18)
          , @c_ToLoc             NVARCHAR(10)
          , @c_ToLogicalLoc      NVARCHAR(18)
          , @c_SuggestLoc        NVARCHAR(10)
          , @c_UserId            NVARCHAR(30)
          , @c_PickAndDropLOC    NVARCHAR(10)
          , @c_FitCasesInAisle   NVARCHAR(1)
          , @n_PABookingKey      INT
          , @c_Facility          NVARCHAR(5)
          -- SKU / Receipt attributes
          , @c_Sku               NVARCHAR(50)
          , @n_ReceiptLineNumber INT
          , @c_ItemClass         NVARCHAR(20)
          , @c_SkuPutawayZone    NVARCHAR(50)
          , @c_CasePick          NVARCHAR(30)
          , @c_UserDefine01      NVARCHAR(50)
          , @n_UserDefine02      INT
          -- AGV / Manual mode
          , @c_Message01         NVARCHAR(20)
          , @c_UserKey           NVARCHAR(18)
          , @c_agvOperationMode  NVARCHAR(20)
          , @c_manualOperationMode NVARCHAR(20)
          , @c_agvUserKey        NVARCHAR(20)
          , @c_manualUserKey     NVARCHAR(20)
          -- Pallet dimensions
          , @d_PalletLength      DECIMAL(18,4)
          , @d_PalletWidth       DECIMAL(18,4)
          , @d_PalletHeight      DECIMAL(18,4)
          , @d_PalletGrossWgt    DECIMAL(18,4)
          -- Pallet data tracking
          , @c_PalletId          NVARCHAR(30)
          , @b_PalletDataFound   BIT
          -- LocationGroup
          , @c_LocationGroup     NVARCHAR(50)
          -- Debug / control
          , @n_RowCount          INT
          , @n_LocCandidateCount INT
          , @n_CursorRowNum      INT;

    --------------------------------------------------------------------
    -- Initialize control variables
    --------------------------------------------------------------------
    SET @n_StartTCnt     = @@TRANCOUNT;
    SET @n_continue      = 1;
    SET @n_NoOfTasks     = 0;
    SET @c_TaskDetailKey = '';
    SET @c_SourceKey     = '';
    SET @c_PickMethod    = '';
    SET @c_ToID          = '';
    SET @c_ToLoc         = '';
    SET @c_ToLogicalLoc  = '';
    SET @n_CursorRowNum  = 0;

    SELECT @c_UserId = SUSER_NAME();

    IF @b_Debug = 1
        PRINT '[ispPAARLA2] UserId=' + ISNULL(@c_UserId,'NULL')
              + ' | StartTranCount=' + CAST(@n_StartTCnt AS NVARCHAR(5));

    --------------------------------------------------------------------
    -- Start transaction if none active
    --------------------------------------------------------------------
    IF @n_StartTCnt = 0
    BEGIN
        BEGIN TRAN;
        IF @b_Debug = 1
            PRINT '[ispPAARLA2] Transaction started. @@TRANCOUNT=' + CAST(@@TRANCOUNT AS NVARCHAR(5));
    END

    --------------------------------------------------------------------
    -- Arla AGV / Manual Operating Mode (from CODELKUP ARLAMODE)
    --------------------------------------------------------------------
    SELECT @c_agvOperationMode = Short,
           @c_agvUserKey       = Long
    FROM CODELKUP
    WHERE LISTNAME  = 'ARLAMODE'
      AND StorerKey = ISNULL(@c_Storerkey, 'ARLA')
      AND Code      = 'AGV';

    SELECT @c_manualOperationMode = Short,
           @c_manualUserKey       = Long
    FROM CODELKUP
    WHERE LISTNAME  = 'ARLAMODE'
      AND StorerKey = ISNULL(@c_Storerkey, 'ARLA')
      AND Code      = 'MANUAL';

    IF @b_Debug = 1
    BEGIN
        PRINT '[ispPAARLA2] AGV mode='    + ISNULL(@c_agvOperationMode,'NULL')
              + ' | AGV UserKey='         + ISNULL(@c_agvUserKey,'NULL');
        PRINT '[ispPAARLA2] Manual mode=' + ISNULL(@c_manualOperationMode,'NULL')
              + ' | Manual UserKey='      + ISNULL(@c_manualUserKey,'NULL');
    END

    --------------------------------------------------------------------
    -- Pre-build candidate BUFFERT locations (#LOC_Candidates)
    -- Sequenced by LOC.PALogicalLoc; includes LocationGroup
    --------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#LOC_Candidates') IS NOT NULL
        DROP TABLE #LOC_Candidates;

    CREATE TABLE #LOC_Candidates
    (
        Loc             NVARCHAR(10)  NOT NULL,
        Facility        NVARCHAR(5)   NOT NULL,
        PutawayZone     NVARCHAR(10)  NOT NULL,
        LOCAisle        NVARCHAR(10)  NULL,
        PALogicalLoc    NVARCHAR(18)  NULL,
        LocationGroup   NVARCHAR(50)  NULL,
        LocLength       DECIMAL(18,4) NULL,
        LocWidth        DECIMAL(18,4) NULL,
        LocHeight       DECIMAL(18,4) NULL,
        LocWeightCap    DECIMAL(18,4) NULL
    );

    INSERT INTO #LOC_Candidates
           (Loc, Facility, PutawayZone, LOCAisle, PALogicalLoc, LocationGroup,
            LocLength, LocWidth, LocHeight, LocWeightCap)
    SELECT  L.Loc,
            L.Facility,
            L.PutawayZone,
            L.LOCAisle,
            L.PALogicalLoc,
            ISNULL(L.LocationGroup, ''),
            CAST(L.Length         AS DECIMAL(18,4)),
            CAST(L.Width          AS DECIMAL(18,4)),
            CAST(L.Height         AS DECIMAL(18,4)),
            CAST(L.WeightCapacity AS DECIMAL(18,4))
    FROM LOC L WITH (NOLOCK)
    JOIN CODELKUP CLK_CAT WITH (NOLOCK)
         ON CLK_CAT.Short     = L.LocationCategory
        AND CLK_CAT.StorerKey = 'ARLA'
    WHERE CLK_CAT.Short = 'BUFFERT'
      AND L.Status      = 'OK'
      AND ISNULL(L.PALogicalLoc, '') <> '';

    IF @b_Debug = 1
    BEGIN
        SELECT @n_LocCandidateCount = COUNT(*) FROM #LOC_Candidates;
        PRINT '[ispPAARLA2] #LOC_Candidates loaded: ' + CAST(@n_LocCandidateCount AS NVARCHAR(10))
              + ' BUFFERT locations (sequenced by PALogicalLoc).';
    END

    --------------------------------------------------------------------
    -- Cursor over receipt lines eligible for PA tasks
    -- Includes Sku, ReceiptLineNumber, LocationGroup for AGV logic
    --------------------------------------------------------------------
    IF @b_Debug = 1
        PRINT '[ispPAARLA2] Building CursorASNDetail...';

    DECLARE CursorASNDetail CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
        SELECT RD.Storerkey,
               RD.ReceiptKey,
               'FP' AS PickMethod,
               RD.ToID,
               RD.ToLoc,
               ISNULL(LOC.LogicalLocation, '') AS LogicalLocation,
               LOC.Facility,
               RD.Sku,
               RD.ReceiptLineNumber,
               ISNULL(LOC.LocationGroup, '')   AS LocationGroup
        FROM ReceiptDetail RD WITH (NOLOCK)
        JOIN LOC LOC WITH (NOLOCK)
          ON (RD.Toloc = LOC.Loc)
        WHERE RD.ReceiptKey   = @c_ReceiptKey
          AND RD.FinalizeFlag = 'Y'
          AND RD.QtyReceived  > 0
          AND ISNULL(RD.ToID, '') <> ''
          AND NOT EXISTS (SELECT 1
                          FROM TASKDETAIL WITH (NOLOCK)
                          WHERE SourceKey  = RD.ReceiptKey
                            AND FromID     = RD.ToID
                            AND TaskType   = 'PAF'
                            AND SourceType = 'ispPAARLA2'
                            AND Storerkey  = RD.Storerkey
                            AND Status     = '0')
        GROUP BY RD.Storerkey,
                 RD.ReceiptKey,
                 RD.ToID,
                 RD.ToLoc,
                 ISNULL(LOC.LogicalLocation, ''),
                 LOC.Facility,
                 RD.Sku,
                 RD.ReceiptLineNumber,
                 ISNULL(LOC.LocationGroup, '');

    OPEN CursorASNDetail;

    FETCH NEXT FROM CursorASNDetail
      INTO @c_Storerkey,
           @c_SourceKey,
           @c_PickMethod,
           @c_ToID,
           @c_ToLoc,
           @c_ToLogicalLoc,
           @c_Facility,
           @c_Sku,
           @n_ReceiptLineNumber,
           @c_LocationGroup;

    IF @b_Debug = 1
    BEGIN
        IF @@FETCH_STATUS = -1
            PRINT '[ispPAARLA2] WARNING: Cursor returned NO rows. No pallets to process.';
        ELSE
            PRINT '[ispPAARLA2] First cursor fetch successful.';
    END

    --------------------------------------------------------------------
    -- Main loop per pallet / receipt line
    --------------------------------------------------------------------
    WHILE @@FETCH_STATUS <> -1 AND @n_continue IN (1, 2)
    BEGIN
        SET @n_CursorRowNum = @n_CursorRowNum + 1;

        -- Reset per-iteration variables
        SET @c_SuggestLoc      = '';
        SET @n_PABookingKey    = 0;
        SET @c_PalletId        = @c_ToID;
        SET @c_Message01       = NULL;
        SET @c_UserKey         = NULL;
        SET @c_ItemClass       = NULL;
        SET @c_SkuPutawayZone  = NULL;
        SET @c_CasePick        = NULL;
        SET @c_UserDefine01    = NULL;
        SET @n_UserDefine02    = NULL;
        SET @d_PalletLength    = 0;
        SET @d_PalletWidth     = 0;
        SET @d_PalletHeight    = 0;
        SET @d_PalletGrossWgt  = 0;
        SET @b_PalletDataFound = 0;

        IF @b_Debug = 1
            PRINT '-----------------------------------------------------'
                + CHAR(13) + CHAR(10)
                + '[ispPAARLA2] >>> Row #' + CAST(@n_CursorRowNum AS NVARCHAR(5))
                + ' | PalletId=' + ISNULL(@c_PalletId,'NULL')
                + ' | StorerKey=' + ISNULL(@c_Storerkey,'NULL')
                + ' | SourceKey=' + ISNULL(@c_SourceKey,'NULL')
                + ' | FromLoc=' + ISNULL(@c_ToLoc,'NULL')
                + ' | Facility=' + ISNULL(@c_Facility,'NULL')
                + ' | Sku=' + ISNULL(@c_Sku,'NULL')
                + ' | ReceiptLine=' + CAST(@n_ReceiptLineNumber AS NVARCHAR(20))
                + ' | LocationGroup=' + ISNULL(@c_LocationGroup,'');

        -----------------------------------------------------------------
        -- Step 1: Get SKU.ItemClass, PutawayZone, CasePick (busr10)
        -----------------------------------------------------------------
        SELECT @c_ItemClass      = S.ItemClass,
               @c_SkuPutawayZone = S.PutawayZone,
               @c_CasePick       = S.busr10
        FROM SKU S WITH (NOLOCK)
        WHERE S.StorerKey = ISNULL(@c_Storerkey, 'ARLA')
          AND S.Sku       = @c_Sku;

        SET @n_RowCount = @@ROWCOUNT;

        IF @b_Debug = 1
            PRINT '[ispPAARLA2]   Step1 - SKU lookup: Rows=' + CAST(@n_RowCount AS NVARCHAR(10))
                  + ' | ItemClass=' + ISNULL(@c_ItemClass,'')
                  + ' | PutawayZone=' + ISNULL(@c_SkuPutawayZone,'')
                  + ' | CasePick=' + ISNULL(@c_CasePick,'');

        -- Validate PutawayZone
        IF ISNULL(@c_SkuPutawayZone, '') = ''
        BEGIN
            SET @b_Success = 0;
            SET @n_err     = 90003;
            SET @c_errmsg  = 'PutawayZone not found for pallet ' + @c_PalletId
                           + ' (SKU.PutawayZone is blank).';
            IF @b_Debug = 1
                PRINT '[ispPAARLA2]   ERROR 90003 - PutawayZone is blank.';
            EXEC nsp_logerror @n_err, @c_errmsg, 'ispPAARLA2_PalletCheck';
            SET @n_continue = 3;
            GOTO QUIT_SP;
        END

        -----------------------------------------------------------------
        -- Step 2: Get RECEIPTDETAIL.UserDefine01, UserDefine02
        --         (for AGV/Manual decision)
        -----------------------------------------------------------------
        SELECT @c_UserDefine01 = P.UserDefine01,
               @n_UserDefine02 = TRY_CONVERT(DECIMAL(18,4), P.UserDefine02)
        FROM RECEIPTDETAIL P WITH (NOLOCK)
        WHERE P.StorerKey         = ISNULL(@c_Storerkey, 'ARLA')
          AND P.ReceiptKey        = @c_SourceKey
          AND P.ReceiptLineNumber = @n_ReceiptLineNumber;

        IF @b_Debug = 1
            PRINT '[ispPAARLA2]   Step2 - RECEIPTDETAIL: UserDefine01=' + ISNULL(@c_UserDefine01,'')
                  + ' | UserDefine02=' + ISNULL(CAST(@n_UserDefine02 AS NVARCHAR(20)),'');

        -----------------------------------------------------------------
        -- Step 3: Message01 decision logic (AGV vs Manual)
        -----------------------------------------------------------------
        IF UPPER(ISNULL(@c_ItemClass, '')) = 'EXTRA CHIL'
           OR UPPER(ISNULL(@c_CasePick, '')) = 'CASEPICK'
        BEGIN
            SET @c_Message01 = @c_manualOperationMode;
            SET @c_UserKey   = @c_manualUserKey;
            IF @b_Debug = 1
                PRINT '[ispPAARLA2]   Step3 - MANUAL: ItemClass=EXTRA CHIL or CasePick';
        END
        ELSE
        BEGIN
            IF UPPER(ISNULL(@c_ItemClass, '')) = 'CHILLED'
               AND ISNULL(@c_UserDefine01, '') IN (
                       SELECT DISTINCT Code
                       FROM CODELKUP
                       WHERE StorerKey = ISNULL(@c_Storerkey, 'ARLA')
                         AND LISTNAME  = 'ARLAPALTYP'
                         AND Short     = 'AGV')
               AND ISNULL(@n_UserDefine02, 0) < 1500
            BEGIN
                SET @c_Message01 = @c_agvOperationMode;
                SET @c_UserKey   = @c_agvUserKey;
                IF @b_Debug = 1
                    PRINT '[ispPAARLA2]   Step3 - AGV condition met: ' + ISNULL(@c_Message01,'');
            END
            ELSE IF UPPER(ISNULL(@c_ItemClass, '')) = 'CHILLED'
                 OR ISNULL(@c_UserDefine01, '') IN (
                        SELECT DISTINCT Code
                        FROM CODELKUP
                        WHERE StorerKey = ISNULL(@c_Storerkey, 'ARLA')
                          AND LISTNAME  = 'ARLAPALTYP'
                          AND Short     = 'MANUAL')
                 OR ISNULL(@n_UserDefine02, 0) > 1500
            BEGIN
                SET @c_Message01 = @c_manualOperationMode;
                SET @c_UserKey   = @c_manualUserKey;
                IF @b_Debug = 1
                    PRINT '[ispPAARLA2]   Step3 - MANUAL condition met';
            END
        END

        -- Default to Manual if still NULL
        IF @c_Message01 IS NULL
        BEGIN
            SET @c_Message01 = @c_manualOperationMode;
            SET @c_UserKey   = @c_manualUserKey;
        END

        IF @b_Debug = 1
            PRINT '[ispPAARLA2]   Step3 - Final Message01=' + ISNULL(@c_Message01,'')
                  + ' | UserKey=' + ISNULL(@c_UserKey,'');

        -----------------------------------------------------------------
        -- *** When Message01 = AGV, skip location suggestion, booking,
        --     key generation and TASKDETAIL insert entirely.
        -----------------------------------------------------------------
        IF UPPER(ISNULL(@c_Message01, '')) <> 'AGV'
        BEGIN

            -----------------------------------------------------------------
            -- Step 4: Get pallet dimensions and weight
            --         Chain: PALLET → PalletTypeMaster → Lottable09
            -----------------------------------------------------------------

            -- Step 4A: Try primary source (PALLET table)
            SELECT TOP 1
                   @d_PalletLength    = ISNULL(CAST(P.Length   AS DECIMAL(18,4)), 0),
                   @d_PalletWidth     = ISNULL(CAST(P.Width    AS DECIMAL(18,4)), 0),
                   @d_PalletHeight    = ISNULL(CAST(P.Height   AS DECIMAL(18,4)), 0),
                   @d_PalletGrossWgt  = ISNULL(CAST(P.GrossWgt AS DECIMAL(18,4)), 0),
                   @b_PalletDataFound = 1
            FROM PALLET P WITH (NOLOCK)
            WHERE P.StorerKey = ISNULL(@c_Storerkey, 'ARLA')
              AND P.PalletKey = @c_PalletId;

            IF @b_Debug = 1
            BEGIN
                IF @b_PalletDataFound = 1
                    PRINT '[ispPAARLA2]   Step4A (PALLET): FOUND | L='
                          + CAST(@d_PalletLength AS NVARCHAR(20))
                          + ' W=' + CAST(@d_PalletWidth AS NVARCHAR(20))
                          + ' H=' + CAST(@d_PalletHeight AS NVARCHAR(20))
                          + ' Wgt=' + CAST(@d_PalletGrossWgt AS NVARCHAR(20));
                ELSE
                    PRINT '[ispPAARLA2]   Step4A (PALLET): NO ROW FOUND for PalletKey=' + ISNULL(@c_PalletId,'NULL');
            END

            -- Step 4B: Verify pallet existence if no PALLET row
            IF @b_PalletDataFound = 0
            BEGIN
                IF NOT EXISTS
                (
                    SELECT 1
                    FROM RECEIPTDETAIL WITH (NOLOCK)
                    WHERE StorerKey  = ISNULL(@c_Storerkey, 'ARLA')
                      AND ToID       = @c_PalletId
                      AND ReceiptKey = @c_SourceKey
                )
                BEGIN
                    SET @b_Success = 0;
                    SET @n_err     = 90001;
                    SET @c_errmsg  = 'Pallet does not exist for PalletKey ' + @c_PalletId;
                    IF @b_Debug = 1
                        PRINT '[ispPAARLA2]   Step4B: ERROR 90001 - Pallet not found anywhere.';
                    EXEC nsp_logerror @n_err, @c_errmsg, 'ispPAARLA2_PalletCheck';
                    SET @n_continue = 3;
                    GOTO QUIT_SP;
                END

                IF @b_Debug = 1
                    PRINT '[ispPAARLA2]   Step4B: No PALLET row but RECEIPTDETAIL exists. Trying fallbacks.';
            END

            -- Step 4C: Fallback dimensions from PalletTypeMaster
            IF @d_PalletLength = 0 OR @d_PalletWidth = 0 OR @d_PalletHeight = 0
            BEGIN
                IF @b_Debug = 1
                    PRINT '[ispPAARLA2]   Step4C: Dimensions incomplete. Trying PalletTypeMaster...';

                SELECT TOP 1
                       @d_PalletLength = ISNULL(CAST(PTM.Length AS DECIMAL(18,4)), 0),
                       @d_PalletWidth  = ISNULL(CAST(PTM.Width  AS DECIMAL(18,4)), 0),
                       @d_PalletHeight = ISNULL(CAST(PTM.Height AS DECIMAL(18,4)), 0)
                FROM RECEIPTDETAIL RD WITH (NOLOCK)
                JOIN PalletTypeMaster PTM WITH (NOLOCK)
                     ON  PTM.StorerKey          = 'ARLA'
                     AND PTM.PalletTypeMasterKey = RD.UserDefine01
                WHERE RD.StorerKey         = ISNULL(@c_Storerkey, 'ARLA')
                  AND RD.ToID              = @c_PalletId
                  AND RD.ReceiptKey        = @c_SourceKey;

                IF @b_Debug = 1
                    PRINT '[ispPAARLA2]   Step4C result: L=' + CAST(@d_PalletLength AS NVARCHAR(20))
                          + ' W=' + CAST(@d_PalletWidth AS NVARCHAR(20))
                          + ' H=' + CAST(@d_PalletHeight AS NVARCHAR(20));
            END

            -- Step 4D: Fallback weight from RECEIPTDETAIL.Lottable09
            IF @d_PalletGrossWgt = 0
            BEGIN
                IF @b_Debug = 1
                    PRINT '[ispPAARLA2]   Step4D: Weight is zero. Trying RECEIPTDETAIL.Lottable09...';

                SELECT TOP 1
                       @d_PalletGrossWgt = ISNULL(CAST(RD.Lottable09 AS DECIMAL(18,4)), 0)
                FROM RECEIPTDETAIL RD WITH (NOLOCK)
                WHERE RD.StorerKey  = ISNULL(@c_Storerkey, 'ARLA')
                  AND RD.ToID       = @c_PalletId
                  AND RD.ReceiptKey = @c_SourceKey;

                IF @b_Debug = 1
                    PRINT '[ispPAARLA2]   Step4D result: Wgt=' + CAST(@d_PalletGrossWgt AS NVARCHAR(20));
            END

            -- Step 4E: Final dimension/weight validation
            IF @d_PalletLength = 0 OR @d_PalletWidth = 0
               OR @d_PalletHeight = 0 OR @d_PalletGrossWgt = 0
            BEGIN
                SET @b_Success = 0;
                SET @n_err     = 90004;
                SET @c_errmsg  = 'Pallet dimensions and/or weight not captured for pallet '
                               + @c_PalletId
                               + '. Checked PALLET, PalletTypeMaster, and RECEIPTDETAIL.Lottable09.';
                IF @b_Debug = 1
                    PRINT '[ispPAARLA2]   Step4E: ERROR 90004 - Dims/weight still incomplete.'
                          + ' L=' + CAST(@d_PalletLength AS NVARCHAR(20))
                          + ' W=' + CAST(@d_PalletWidth AS NVARCHAR(20))
                          + ' H=' + CAST(@d_PalletHeight AS NVARCHAR(20))
                          + ' Wgt=' + CAST(@d_PalletGrossWgt AS NVARCHAR(20));
                EXEC nsp_logerror @n_err, @c_errmsg, 'ispPAARLA2_PalletDimCheck';
                SET @n_continue = 3;
                GOTO QUIT_SP;
            END

            IF @b_Debug = 1
                PRINT '[ispPAARLA2]   FINAL DIMS: L=' + CAST(@d_PalletLength AS NVARCHAR(20))
                      + ' W=' + CAST(@d_PalletWidth AS NVARCHAR(20))
                      + ' H=' + CAST(@d_PalletHeight AS NVARCHAR(20))
                      + ' Wgt=' + CAST(@d_PalletGrossWgt AS NVARCHAR(20));

            -----------------------------------------------------------------
            -- Step 5: Find best-fit EMPTY location using #LOC_Candidates
            --         Filtered by PutawayZone + LocationGroup + FitScore
            -----------------------------------------------------------------
            IF @b_Debug = 1
                PRINT '[ispPAARLA2]   Step5 - Location search: Facility=' + ISNULL(@c_Facility,'NULL')
                      + ' | Zone=' + ISNULL(@c_SkuPutawayZone,'NULL')
                      + ' | LocationGroup=' + ISNULL(@c_LocationGroup,'<empty>')
                      + ' | Ordering by FitScore, PALogicalLoc';

            ;WITH FitCandidates AS
            (
                SELECT
                    C.Loc,
                    C.Facility,
                    C.PutawayZone,
                    C.LOCAisle,
                    C.PALogicalLoc,
                    C.LocLength,
                    C.LocWidth,
                    C.LocHeight,
                    C.LocWeightCap,
                    CAST(CASE WHEN (C.LocLength    >= @d_PalletLength
                                AND C.LocWidth     >= @d_PalletWidth
                                AND C.LocHeight    >= @d_PalletHeight
                                AND C.LocWeightCap >= @d_PalletGrossWgt)
                              THEN 1 ELSE 0 END AS BIT) AS Fits,
                    (
                        (C.LocLength    - @d_PalletLength)   +
                        (C.LocWidth     - @d_PalletWidth)    +
                        (C.LocHeight    - @d_PalletHeight)   +
                        (C.LocWeightCap - @d_PalletGrossWgt)
                    ) AS FitScore
                FROM #LOC_Candidates C
                WHERE C.Facility    = @c_Facility
                  AND C.PutawayZone = @c_SkuPutawayZone
                  AND ISNULL(C.LocationGroup, '') = ISNULL(@c_LocationGroup, '')
                  AND NOT EXISTS
                      (
                          SELECT 1
                          FROM TASKDETAIL TD WITH (NOLOCK)
                          WHERE TD.ToLoc     = C.Loc
                            AND TD.StorerKey = ISNULL(@c_Storerkey, 'ARLA')
                            AND TD.TaskType  = 'PAF'
                            AND TD.Status    < '9'
                            AND TD.Status    <> 'X'
                      )
                  AND NOT EXISTS
                      (
                          SELECT 1
                          FROM LOTXLOCXID LL WITH (NOLOCK)
                          WHERE LL.Loc       = C.Loc
                            AND LL.StorerKey = ISNULL(@c_Storerkey, 'ARLA')
                            AND LL.Qty       > 0
                      )
            )
            SELECT TOP 1
                   @c_SuggestLoc = F.Loc
            FROM FitCandidates F
            WHERE F.Fits = 1
            ORDER BY
                   F.FitScore ASC,
                   F.PALogicalLoc ASC,
                   F.Loc ASC;

            IF @b_Debug = 1
            BEGIN
                IF ISNULL(@c_SuggestLoc, '') = ''
                    PRINT '[ispPAARLA2]   Step5 - NO FITTING LOCATION FOUND';
                ELSE
                    PRINT '[ispPAARLA2]   Step5 - SuggestLoc=' + @c_SuggestLoc;
            END

            -----------------------------------------------------------------
            -- Step 6: Fallback to current ToLoc if no suggestion
            -----------------------------------------------------------------
            IF ISNULL(@c_SuggestLoc, '') = ''
            BEGIN
                SET @c_SuggestLoc = @c_ToLoc;
                IF @b_Debug = 1
                    PRINT '[ispPAARLA2]   Step6 - No LOC selected; defaulting to ToLoc=' + ISNULL(@c_ToLoc,'');
            END
            ELSE IF @b_Debug = 1
                PRINT '[ispPAARLA2]   Step6 - Final SuggestLoc (before booking)=' + @c_SuggestLoc;

            -----------------------------------------------------------------
            -- Step 7: Lock PA booking
            -----------------------------------------------------------------
            IF ISNULL(@c_SuggestLoc, '') <> '' AND ISNULL(@n_PABookingKey, 0) = 0
            BEGIN
                SET @n_PABookingKey = 0;

                IF @b_Debug = 1
                    PRINT '[ispPAARLA2]   Step7 - Calling rdt_Putaway_PendingMoveIn LOCK: FromLoc='
                          + ISNULL(@c_ToLoc,'NULL') + ' FromID=' + ISNULL(@c_ToID,'NULL')
                          + ' SuggestLoc=' + ISNULL(@c_SuggestLoc,'NULL');

                EXEC rdt.rdt_Putaway_PendingMoveIn
                    @cUserName      = @c_UserId,
                    @cType          = 'LOCK',
                    @cFromLoc       = @c_ToLoc,
                    @cFromID        = @c_ToID,
                    @cSuggestedLOC  = @c_SuggestLoc,
                    @cStorerKey     = @c_Storerkey,
                    @nErrNo         = @n_Err OUTPUT,
                    @cErrMsg        = @c_Errmsg OUTPUT,
                    @cTaskDetailKey = @c_TaskDetailKey,
                    @nFunc          = 0,
                    @nPABookingKey  = @n_PABookingKey OUTPUT;

                IF @b_Debug = 1
                    PRINT '[ispPAARLA2]   Step7 - PendingMoveIn result: ErrNo='
                          + CAST(@n_Err AS NVARCHAR(10))
                          + ' PABookingKey=' + CAST(ISNULL(@n_PABookingKey,0) AS NVARCHAR(10));

                IF @n_Err <> 0
                BEGIN
                    SET @n_Continue = 3;
                END
            END

            -----------------------------------------------------------------
            -- Step 8: Get new TaskDetailKey
            -----------------------------------------------------------------
            IF @b_Debug = 1
                PRINT '[ispPAARLA2]   Step8 - Getting new TaskDetailKey...';

            EXECUTE nspg_GetKey
                'TaskDetailKey',
                10,
                @c_TaskDetailKey OUTPUT,
                @b_success       OUTPUT,
                @n_err           OUTPUT,
                @c_errmsg        OUTPUT;

            IF @b_Debug = 1
                PRINT '[ispPAARLA2]   Step8 - nspg_GetKey result: b_success=' + ISNULL(CAST(@b_Success AS NVARCHAR(10)),'')
                      + ' | TaskDetailKey=' + ISNULL(@c_TaskDetailKey,'');

            IF NOT @b_success = 1
            BEGIN
                SET @n_Continue = 3;
                SET @n_Err      = 30101;
                SET @c_Errmsg   = 'NSQL' + CONVERT(CHAR(5), @n_err)
                                + ': Error Getting New TaskDetailKey. (ispPAARLA2)';
                IF @b_Debug = 1
                    PRINT '[ispPAARLA2]   ERROR 30101 - ' + ISNULL(@c_Errmsg,'');
                GOTO QUIT_SP;
            END

            -----------------------------------------------------------------
            -- Step 9: Insert TASKDETAIL with Message01, UserKey, etc.
            -----------------------------------------------------------------
            IF @b_Debug = 1
                PRINT '[ispPAARLA2]   Step9 - Inserting TASKDETAIL: Key=' + ISNULL(@c_TaskDetailKey,'NULL')
                      + ' From=' + ISNULL(@c_ToLoc,'NULL')
                      + ' FromID=' + ISNULL(@c_ToID,'NULL')
                      + ' To=' + ISNULL(@c_SuggestLoc,'NULL')
                      + ' Message01=' + ISNULL(@c_Message01,'NULL')
                      + ' UserKey=' + ISNULL(@c_UserKey,'NULL');

            INSERT INTO TASKDETAIL
                   (    TaskDetailKey
                      , Storerkey
                      , TaskType
                      , Fromloc
                      , LogicalFromLoc
                      , FromID
                      , PickMethod
                      , ToLoc
                      , LogicalToLoc
                      , Status
                      , Priority
                      , SourcePriority
                      , SourceType
                      , SourceKey
                      , Message01
                      , Message02
                      , AreaKey
                      , UserKey
                   )
            VALUES (    @c_TaskDetailKey
                      , ISNULL(@c_Storerkey, 'ARLA')
                      , 'PAF'
                      , @c_ToLoc
                      , @c_ToLogicalLoc
                      , @c_ToID
                      , @c_PickMethod
                      , @c_SuggestLoc
                      , @c_SuggestLoc
                      , '0'
                      , '1'
                      , '1'
                      , 'ispPAARLA2'
                      , @c_SourceKey
                      , @c_Message01
                      , 'NEW'
                      , 'ARLARDT'
                      , @c_UserKey
                   );

            SET @n_NoOfTasks = @n_NoOfTasks + 1;

            IF @b_Debug = 1
                PRINT '[ispPAARLA2]   Step9 - TASKDETAIL inserted OK. Total tasks: ' + CAST(@n_NoOfTasks AS NVARCHAR(5));

        END  -- END IF @c_Message01 <> 'AGV'
        ELSE
        BEGIN
            IF @b_Debug = 1
                PRINT '[ispPAARLA2]   Skipping TASKDETAIL insert — Message01=AGV for ToID=' + ISNULL(@c_ToID,'');
        END

        -----------------------------------------------------------------
        -- Fetch next row
        -----------------------------------------------------------------
        FETCH NEXT FROM CursorASNDetail
          INTO @c_Storerkey,
               @c_SourceKey,
               @c_PickMethod,
               @c_ToID,
               @c_ToLoc,
               @c_ToLogicalLoc,
               @c_Facility,
               @c_Sku,
               @n_ReceiptLineNumber,
               @c_LocationGroup;

        IF @b_Debug = 1 AND @@FETCH_STATUS = -1
            PRINT '[ispPAARLA2] No more rows to fetch. Exiting loop.';
    END

QUIT_SP:
    CLOSE CursorASNDetail;
    DEALLOCATE CursorASNDetail;

    IF @b_Debug = 1
        PRINT '[ispPAARLA2] Cursor closed and deallocated.';

    -- Clean up temp table
    IF OBJECT_ID('tempdb..#LOC_Candidates') IS NOT NULL
        DROP TABLE #LOC_Candidates;

    --------------------------------------------------------------------
    -- Transaction and error handling
    --------------------------------------------------------------------
    IF @n_continue = 3  -- Error occurred
    BEGIN
        SELECT @b_success = 0;

        IF @b_Debug = 1
            PRINT '[ispPAARLA2] ERROR PATH: n_continue=3 | ErrNo=' + CAST(ISNULL(@n_err,0) AS NVARCHAR(10))
                  + ' | ErrMsg=' + ISNULL(@c_errmsg,'(none)')
                  + ' | @@TRANCOUNT=' + CAST(@@TRANCOUNT AS NVARCHAR(5));

        IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
        BEGIN
            ROLLBACK TRAN;
            IF @b_Debug = 1
                PRINT '[ispPAARLA2] Transaction ROLLED BACK.';
        END
        ELSE
        BEGIN
            WHILE @@TRANCOUNT > @n_StartTCnt
            BEGIN
                COMMIT TRAN;
            END
            IF @b_Debug = 1
                PRINT '[ispPAARLA2] Committed nested transactions down to start level.';
        END

        EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispPAARLA2';

        IF @b_Debug = 1
            PRINT '=== [ispPAARLA2] END (FAILURE) === Time=' + CONVERT(NVARCHAR(30), GETDATE(), 121);

        RETURN;
    END
    ELSE
    BEGIN
        IF @n_NoOfTasks > 0
            SET @c_errmsg = 'Total ' + CONVERT(NVARCHAR(5), @n_NoOfTasks) + ' Putaway From tasks released sucessfully.';
        ELSE
            SET @c_errmsg = 'No Putaway From tasks released.';

        SELECT @b_success = 1;

        IF @b_Debug = 1
            PRINT '[ispPAARLA2] SUCCESS: ' + ISNULL(@c_errmsg,'');

        WHILE @@TRANCOUNT > @n_StartTCnt
        BEGIN
            COMMIT TRAN;
        END

        IF @b_Debug = 1
            PRINT '=== [ispPAARLA2] END (SUCCESS) === Tasks=' + CAST(@n_NoOfTasks AS NVARCHAR(5))
                  + ' | Time=' + CONVERT(NVARCHAR(30), GETDATE(), 121);

        RETURN;
    END
END
GO
