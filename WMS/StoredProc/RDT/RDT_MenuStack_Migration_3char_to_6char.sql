/*
 * PR2301 / UWP-56557  --  MenuStack 3-char to 6-char migration
 * ---------------------------------------------------------------
 * Background:
 *   PR #2301 changes rdtProcessMenu to write 6-char slots (was 3-char).
 *   rdtPrevScreen now reads RIGHT(MenuStack, 6) and trims 6 chars.
 *   Any active session whose MenuStack was built before this deployment
 *   still holds 3-char slots.  After deployment, rdtPrevScreen would
 *   misread the old stacks, causing wrong-screen navigation.
 *
 * Old encoding:  RIGHT('000'    + CAST(@nMenu AS NVARCHAR(3)), 3)
 * New encoding:  RIGHT('000000' + CAST(@nMenu AS NVARCHAR(6)), 6)
 *
 * Examples:
 *   Old '005'        → New '000005'   (menu  5)
 *   Old '015'        → New '000015'   (menu 15)
 *   Old '499'        → New '000499'   (menu 499)
 *   Old '005015499'  → New '000005000015000499'  (3-level stack)
 *
 * Detection rules:
 *   (A) LEN(MenuStack) % 3 = 0  AND  LEN(MenuStack) % 6 <> 0
 *       → odd number of 3-char slots; unambiguously old format.
 *       e.g. '234265213' (9 chars, 3 slots)
 *
 *   (B) LEN(MenuStack) % 6 = 0
 *       AND TRY_CAST(SUBSTRING(MenuStack,1,3) AS INT) BETWEEN 5 AND 499
 *       → even number of old 3-char slots, detected via first-slot value.
 *       e.g. '034265213005' (12 chars, 4 slots: 34, 265, 213, 5)
 *       New 6-char format always starts with '000' (menus 5–499) or
 *       '00-' (negative menus) — TRY_CAST of those first 3 chars gives
 *       0 or NULL, never 5–499, so no false positives.
 *
 * Capacity note:
 *   NVARCHAR(60) holds up to 20 old 3-char slots or 10 new 6-char
 *   slots.  If an old stack has more than 10 levels (> 30 chars),
 *   only the 10 most-recent (rightmost) slots are kept.
 *
 * When to run:
 *   Run in the same maintenance window as the PR #2301 deployment,
 *   preferably AFTER deploying the new SPs so that any sessions
 *   started between now and the SP deployment do not need re-migration.
 *   Ideally run while mobile users are logged off (shift break/EOD).
 *
 * ---------------------------------------------------------------
 * STEP 1  -  DRY RUN: inspect what will be converted
 * Comment this section out after review.
 * ---------------------------------------------------------------
 */

PRINT '=== DRY RUN: Sessions targeted for conversion (rules A + B) ==='
SELECT
    Mobile,
    MenuStack                     AS MenuStack_Old,
    LEN(MenuStack)                AS StackLen,
    LEN(MenuStack) / 3            AS SlotCount_Old,
    CASE
        WHEN LEN(MenuStack) % 6 <> 0
        THEN 'A: odd slot count'
        ELSE 'B: even slot count — first-slot heuristic'
    END                           AS DetectionRule,
    CASE
        WHEN LEN(MenuStack) / 3 > 10
        THEN 'WARNING: > 10 slots — will keep last 10 only'
        ELSE 'OK'
    END                           AS Note
FROM  RDT.RDTMOBREC WITH (NOLOCK)
WHERE ISNULL(MenuStack, '') <> ''
  AND LEN(MenuStack) % 3 = 0
  AND (
        LEN(MenuStack) % 6 <> 0                                            -- rule A
        OR TRY_CAST(SUBSTRING(MenuStack, 1, 3) AS INT) BETWEEN 5 AND 499  -- rule B
      )

PRINT '=== Stacks not auto-detected (likely new format — left unchanged) ==='
SELECT
    Mobile,
    MenuStack,
    LEN(MenuStack)             AS StackLen,
    LEN(MenuStack) / 6         AS PossibleNew6charSlots,
    SUBSTRING(MenuStack, 1, 3) AS First3Chars,
    'First 3 chars not 5–499; assumed new format' AS Note
FROM  RDT.RDTMOBREC WITH (NOLOCK)
WHERE ISNULL(MenuStack, '') <> ''
  AND LEN(MenuStack) % 6 = 0
  AND (   TRY_CAST(SUBSTRING(MenuStack, 1, 3) AS INT) NOT BETWEEN 5 AND 499
       OR TRY_CAST(SUBSTRING(MenuStack, 1, 3) AS INT) IS NULL
      )

/*
 * ---------------------------------------------------------------
 * STEP 2  -  CONVERSION
 * Wrapped in a transaction so you can ROLLBACK if anything looks wrong.
 * After reviewing PRINT output, change ROLLBACK to COMMIT.
 * ---------------------------------------------------------------
 */

SET NOCOUNT ON

DECLARE @Mobile         INT
DECLARE @OldStack       NVARCHAR(120)
DECLARE @NewStack       NVARCHAR(120)
DECLARE @SlotCount      INT
DECLARE @i              INT
DECLARE @slotRaw        NVARCHAR(6)
DECLARE @slotVal        INT
DECLARE @ConvertedRows  INT = 0
DECLARE @SkippedRows    INT = 0
DECLARE @ErrorMobile    INT = -1

BEGIN TRY
    BEGIN TRANSACTION

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT Mobile, MenuStack
        FROM   RDT.RDTMOBREC WITH (UPDLOCK, ROWLOCK)   -- lock rows we will update
        WHERE  ISNULL(MenuStack, '') <> ''
          AND  LEN(MenuStack) % 3 = 0
          AND  (
                 LEN(MenuStack) % 6 <> 0                                            -- rule A: odd 3-char slot count
                 OR TRY_CAST(SUBSTRING(MenuStack, 1, 3) AS INT) BETWEEN 5 AND 499  -- rule B: even 3-char, first-slot heuristic
               )

    OPEN cur
    FETCH NEXT FROM cur INTO @Mobile, @OldStack

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @ErrorMobile = @Mobile

        -- Trim to last 10 slots (30 chars) when stack is deeper than NVARCHAR(60) / 6 allows
        IF LEN(@OldStack) > 30
        BEGIN
            PRINT 'WARNING Mobile ' + CAST(@Mobile AS NVARCHAR(10))
                + ': ' + CAST(LEN(@OldStack)/3 AS NVARCHAR(3))
                + ' old slots — keeping last 10 only (old stack: ' + @OldStack + ')'
            SET @OldStack = RIGHT(@OldStack, 30)
        END

        SET @SlotCount = LEN(@OldStack) / 3
        SET @NewStack  = ''
        SET @i         = 1

        WHILE @i <= @SlotCount
        BEGIN
            SET @slotRaw = SUBSTRING(@OldStack, (@i - 1) * 3 + 1, 3)
            SET @slotVal = TRY_CAST(@slotRaw AS INT)

            IF @slotVal IS NULL
            BEGIN
                -- Slot is not a valid integer (e.g. corrupted negative entry from pre-PR#1229 era).
                -- Re-encode as '000000' (menu 0 = login screen) as a safe neutral fallback.
                PRINT 'WARNING Mobile ' + CAST(@Mobile AS NVARCHAR(10))
                    + ': slot ' + CAST(@i AS NVARCHAR(3))
                    + ' is not a valid integer (''' + @slotRaw + ''') — replaced with 000000'
                SET @NewStack = @NewStack + '000000'
            END
            ELSE
            BEGIN
                SET @NewStack = @NewStack + RIGHT('000000' + CAST(@slotVal AS NVARCHAR(6)), 6)
            END

            SET @i = @i + 1
        END

        PRINT 'Mobile ' + CAST(@Mobile AS NVARCHAR(10))
            + ': [' + @OldStack + '] → [' + @NewStack + ']'

        UPDATE RDT.RDTMOBREC WITH (ROWLOCK)
        SET    MenuStack = @NewStack,
               EditDate  = GETDATE()
        WHERE  Mobile = @Mobile

        SET @ConvertedRows = @ConvertedRows + 1
        FETCH NEXT FROM cur INTO @Mobile, @OldStack
    END

    CLOSE cur
    DEALLOCATE cur

    PRINT ''
    PRINT '=== Conversion summary ==='
    PRINT 'Rows converted : ' + CAST(@ConvertedRows AS NVARCHAR(10))
    PRINT ''
    PRINT '*** Review the output above, then change ROLLBACK to COMMIT. ***'

    -- Change to ROLLBACK TRANSACTION to do a dry run without persisting changes.
    COMMIT TRANSACTION

END TRY
BEGIN CATCH
    IF CURSOR_STATUS('local', 'cur') >= 0
    BEGIN
        CLOSE cur
        DEALLOCATE cur
    END

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    PRINT 'ERROR while processing Mobile ' + CAST(@ErrorMobile AS NVARCHAR(10))
    PRINT 'Error ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)) + ': ' + ERROR_MESSAGE()
END CATCH

/*
 * ---------------------------------------------------------------
 * STEP 3  -  VERIFY (run after committing)
 * ---------------------------------------------------------------
 */

-- All MenuStack values should now have LEN % 6 = 0 (or be NULL / empty)
SELECT
    Mobile,
    MenuStack,
    LEN(MenuStack)      AS StackLen,
    LEN(MenuStack) % 6  AS Len_Mod_6,    -- should be 0 for all converted rows
    LEN(MenuStack) % 3  AS Len_Mod_3
FROM  RDT.RDTMOBREC WITH (NOLOCK)
WHERE ISNULL(MenuStack, '') <> ''
ORDER BY Mobile
