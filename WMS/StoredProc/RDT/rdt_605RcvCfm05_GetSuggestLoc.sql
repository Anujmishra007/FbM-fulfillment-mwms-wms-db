SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_605RcvCfm05_GetSuggestLoc                        */
/*                                                                      */
/* Purpose:       Find suggested putaway location for ASTPA task       */
/*                based on DAMAGED/OVERSIZE/MIX/MONO scenarios         */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2026-02-27 1.0.0  Jackc    FCR-9673 - Initial version               */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_605RcvCfm05_GetSuggestLoc]
(
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR(3),
   @cStorerKey   NVARCHAR(15),
   @cFacility    NVARCHAR(5),
   @cReceiptKey  NVARCHAR(10),
   @cToID        NVARCHAR(18),
   @cSuggestLoc  NVARCHAR(10) OUTPUT,
   @nErrNo       INT OUTPUT,
   @cErrMsg      NVARCHAR(1024) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag        INT = 0

   DECLARE @cConditionCode    NVARCHAR(10)
   DECLARE @cLottable01       NVARCHAR(18)
   DECLARE @cLottable02       NVARCHAR(18)
   DECLARE @cLottable11       NVARCHAR(30)
   DECLARE @cUserDefine08     NVARCHAR(30)
   DECLARE @cUserDefine09     NVARCHAR(30)
   DECLARE @cUserDefine10     NVARCHAR(30)
   DECLARE @cRPDToLoc         NVARCHAR(10)
   DECLARE @cPutawayZone      NVARCHAR(10)
   DECLARE @cDimThreshold01   NVARCHAR(60)
   DECLARE @cDimThreshold02   NVARCHAR(60)
   DECLARE @cDimThreshold03   NVARCHAR(60)
   DECLARE @bSuccess          INT

   -- Initialize outputs
   SET @cSuggestLoc = ''
   SET @nErrNo = 0
   SET @cErrMsg = ''

   SELECT
      @cConditionCode = ConditionCode,
      @cLottable01 = Lottable01,
      @cLottable02 = Lottable02,
      @cLottable11 = Lottable11,
      @cUserDefine08 = UserDefine08,
      @cUserDefine09 = UserDefine09,
      @cUserDefine10 = UserDefine10,
      @cRPDToLoc = ToLOC
   FROM dbo.ReceiptDetail WITH (NOLOCK)
   WHERE ReceiptKey = @cReceiptKey
      AND ToID = @cToID

   IF @@ROWCOUNT = 0
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'No ASN Detail found'

      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Executing 605RcvCfm05 get suggest loc', @cConditionCode AS ConditionCode,
         @cLottable01 AS Lot1, @cLottable02 AS Lot2, @cLottable11 AS Lot11

   -- Step 2: Check scenarios in priority order

   -- SCENARIO 1: DAMAGED/VAS
   IF @cConditionCode = 'DAMAGE'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Scenario: DAMAGED/VAS'

      -- Get PutawayZone from CODELKUP
      SELECT @cPutawayZone = Notes
      FROM dbo.CODELKUP WITH (NOLOCK)
      WHERE ListName = 'ASTTMZone'
         AND Code = 'VAS'
         AND StorerKey = @cStorerKey

      IF @cPutawayZone IS NULL OR @cPutawayZone = ''
      BEGIN
         IF @nDebugFlag = 1
            SELECT '260201-VAS: ASTTMZone missing'
         ELSE
            EXEC nspLogAlert
               @c_modulename = '605-PALRCPT',
               @c_AlertMessage = 'PA task creation failed: 260201-VAS: ASTTMZone missing',
               @n_Severity = 5,
               @b_Success = @bSuccess OUTPUT,
               @n_err = @nErrNo OUTPUT,
               @c_errmsg = @cErrMsg OUTPUT,
               @c_Activity = 'PALRCPT',
               @c_Storerkey = @cStorerKey,
               @c_SKU = '',
               @c_UOM = '',
               @c_UOMQty = '',
               @c_Qty = '',
               @c_Lot = '',
               @c_Loc = @cRPDToLoc,
               @c_ID = @cToID,
               @c_TaskDetailKey = ''

         GOTO Quit
      END

      -- Find available location: prefer locations with inventory (ID count < MaxPallet), then empty locations
      SELECT TOP 1 @cSuggestLoc = LOC.Loc
      FROM dbo.LOC LOC WITH (NOLOCK)
      LEFT JOIN (
         SELECT LLI2.Loc, LLI2.ID
         FROM dbo.LOTxLOCxID LLI2 WITH (NOLOCK)
         INNER JOIN dbo.LOC LOC2 WITH (NOLOCK) 
            ON LLI2.Loc = LOC2.Loc
         WHERE LLI2.StorerKey = @cStorerKey
           AND LOC2.PutawayZone = @cPutawayZone
           AND (LLI2.Qty - LLI2.QtyPicked + LLI2.PendingMoveIn) > 0
         GROUP BY LLI2.Loc, LLI2.ID
      ) LLI
      ON LOC.Loc = LLI.Loc
      WHERE LOC.PutawayZone = @cPutawayZone
         AND LOC.Facility = @cFacility
         AND LOC.LocationFlag = 'NONE'
         AND LOC.Status = 'OK'
         AND LOC.LoseID = '0'
      GROUP BY LOC.Loc, LOC.MaxPallet, LOC.LogicalLocation
      HAVING LOC.MaxPallet = 0 OR ISNULL(COUNT(DISTINCT LLI.ID), 0) < LOC.MaxPallet
      ORDER BY
         CASE WHEN ISNULL(COUNT(DISTINCT LLI.ID), 0) > 0 THEN 0 ELSE 1 END,
         LOC.LogicalLocation,
         LOC.Loc

      IF @cSuggestLoc IS NULL OR @cSuggestLoc = ''
      BEGIN
         IF @nDebugFlag = 1
            SELECT '260202-VAS: No available location'
         ELSE
            EXEC nspLogAlert
               @c_modulename = '605-PALRCPT',
               @c_AlertMessage = 'PA task creation failed: 260202-VAS: No available location',
               @n_Severity = 5,
               @b_Success = @bSuccess OUTPUT,
               @n_err = @nErrNo OUTPUT,
               @c_errmsg = @cErrMsg OUTPUT,
               @c_Activity = 'PALRCPT',
               @c_Storerkey = @cStorerKey,
               @c_SKU = '',
               @c_UOM = '',
               @c_UOMQty = '',
               @c_Qty = '',
               @c_Lot = '',
               @c_Loc = @cRPDToLoc,
               @c_ID = @cToID,
               @c_TaskDetailKey = ''
         GOTO Quit
      END

      GOTO Quit
   END -- Damage Vas

   -- SCENARIO 2: OVERSIZE
   IF @nDebugFlag = 1
         SELECT 'Checking OVERSIZE'

   -- Get dimension thresholds from CODELKUP
   SELECT
      @cPutawayZone = Notes,
      @cDimThreshold01 = UDF01,
      @cDimThreshold02 = UDF02,
      @cDimThreshold03 = UDF03
   FROM dbo.CODELKUP WITH (NOLOCK)
   WHERE ListName = 'ASTTMZone'
      AND Code = 'OVERSIZE'
      AND StorerKey = @cStorerKey

   IF @cPutawayZone IS NULL OR @cPutawayZone = ''
   BEGIN
      IF @nDebugFlag = 1
         SELECT '260203-Oversize: ASTTMZone missing'
      ELSE
         EXEC nspLogAlert
            @c_modulename = '605-PALRCPT',
            @c_AlertMessage = 'PA task creation failed: 260203-Oversize: ASTTMZone missing',
            @n_Severity = 5,
            @b_Success = @bSuccess OUTPUT,
            @n_err = @nErrNo OUTPUT,
            @c_errmsg = @cErrMsg OUTPUT,
            @c_Activity = 'PALRCPT',
            @c_Storerkey = @cStorerKey,
            @c_SKU = '',
            @c_UOM = '',
            @c_UOMQty = '',
            @c_Qty = '',
            @c_Lot = '',
            @c_Loc = @cRPDToLoc,
            @c_ID = @cToID,
            @c_TaskDetailKey = ''

      GOTO Quit
   END

   -- Check if any dimension exceeds threshold (cast to DECIMAL for numeric comparison)
   IF (ISNULL(TRY_CAST(@cUserDefine08 AS DECIMAL(7,2)), 0) > ISNULL(TRY_CAST(@cDimThreshold01 AS DECIMAL(7,2)), 0))
      OR (ISNULL(TRY_CAST(@cUserDefine09 AS DECIMAL(7,2)), 0) > ISNULL(TRY_CAST(@cDimThreshold02 AS DECIMAL(7,2)), 0))
      OR (ISNULL(TRY_CAST(@cUserDefine10 AS DECIMAL(7,2)), 0) > ISNULL(TRY_CAST(@cDimThreshold03 AS DECIMAL(7,2)), 0))
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Scenario Oversize'

      -- Find available location: prefer locations with inventory (ID count < MaxPallet), then empty locations
      SELECT TOP 1 @cSuggestLoc = LOC.Loc
      FROM dbo.LOC LOC WITH (NOLOCK)
      LEFT JOIN (
         SELECT LLI2.Loc, LLI2.ID
         FROM dbo.LOTxLOCxID LLI2 WITH (NOLOCK)
         INNER JOIN dbo.LOC LOC2 WITH (NOLOCK) 
            ON LLI2.Loc = LOC2.Loc
         WHERE LLI2.StorerKey = @cStorerKey
           AND LOC2.PutawayZone = @cPutawayZone
           AND (LLI2.Qty - LLI2.QtyPicked + LLI2.PendingMoveIn) > 0
         GROUP BY LLI2.Loc, LLI2.ID
      ) LLI
      ON LOC.Loc = LLI.Loc
      WHERE LOC.PutawayZone = @cPutawayZone
         AND LOC.Facility = @cFacility
         AND LOC.LocationFlag = 'NONE'
         AND LOC.Status = 'OK'
         AND LOC.LoseID = '0'
      GROUP BY LOC.Loc, LOC.MaxPallet, LOC.LogicalLocation
      HAVING LOC.MaxPallet = 0 OR ISNULL(COUNT(DISTINCT LLI.ID), 0) < LOC.MaxPallet
      ORDER BY
         CASE WHEN ISNULL(COUNT(DISTINCT LLI.ID), 0) > 0 THEN 0 ELSE 1 END,
         LOC.LogicalLocation,
         LOC.Loc

      IF @cSuggestLoc IS NULL OR @cSuggestLoc = ''
      BEGIN
         IF @nDebugFlag = 1
            SELECT '260204-OVERSIZE: No available location'
         ELSE
            EXEC nspLogAlert
               @c_modulename = '605-PALRCPT',
               @c_AlertMessage = 'PA task creation failed: 260204-OVERSIZE: No available location',
               @n_Severity = 5,
               @b_Success = @bSuccess OUTPUT,
               @n_err = @nErrNo OUTPUT,
               @c_errmsg = @cErrMsg OUTPUT,
               @c_Activity = 'PALRCPT',
               @c_Storerkey = @cStorerKey,
               @c_SKU = '',
               @c_UOM = '',
               @c_UOMQty = '',
               @c_Qty = '',
               @c_Lot = '',
               @c_Loc = @cRPDToLoc,
               @c_ID = @cToID,
               @c_TaskDetailKey = ''

         GOTO Quit
      END

      GOTO Quit
   END

   -- SCENARIO 3: MIX
   IF @cSuggestLoc = '' AND @cLottable02 = 'MIX'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Scenario: MIX'

      -- Get PutawayZone from CODELKUP
      SELECT @cPutawayZone = Notes
      FROM dbo.CODELKUP WITH (NOLOCK)
      WHERE ListName = 'ASTTMZone'
         AND Code = 'MIX'
         AND StorerKey = @cStorerKey

      IF @cPutawayZone IS NULL OR @cPutawayZone = ''
      BEGIN
         IF @nDebugFlag = 1
            SELECT '260205-MIX: ASTTMZone missing'
         ELSE
            EXEC nspLogAlert
               @c_modulename = '605-PALRCPT',
               @c_AlertMessage = 'PA task creation failed: 260205-MIX: ASTTMZone missing',
               @n_Severity = 5,
               @b_Success = @bSuccess OUTPUT,
               @n_err = @nErrNo OUTPUT,
               @c_errmsg = @cErrMsg OUTPUT,
               @c_Activity = 'PALRCPT',
               @c_Storerkey = @cStorerKey,
               @c_SKU = '',
               @c_UOM = '',
               @c_UOMQty = '',
               @c_Qty = '',
               @c_Lot = '',
               @c_Loc = @cRPDToLoc,
               @c_ID = @cToID,
               @c_TaskDetailKey = ''

         GOTO Quit
      END

      -- First try: Find location with matching inventory (same Lottable01 AND Lottable11)
      SELECT TOP 1 @cSuggestLoc = LOC.Loc
      FROM dbo.LOC LOC WITH (NOLOCK)
      JOIN (
         -- Count ALL IDs per location (regardless of lottable attributes)
         SELECT Loc, COUNT(DISTINCT ID) AS TotalIDCount
         FROM dbo.LOTxLOCxID WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND (Qty - QtyPicked + PendingMoveIn) > 0
         GROUP BY Loc
      ) IDCount ON LOC.Loc = IDCount.Loc
      JOIN dbo.LOTxLOCxID LLI WITH (NOLOCK) ON LOC.Loc = LLI.Loc
      JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) ON LLI.Lot = LA.Lot
      WHERE LOC.PutawayZone = @cPutawayZone
         AND LOC.Facility = @cFacility
         AND LOC.LocationFlag = 'NONE'
         AND LOC.Status = 'OK'
         AND LOC.LoseID = '0'
         AND LA.Lottable01 = @cLottable01
         AND LA.Lottable11 = @cLottable11
         AND LLI.StorerKey = @cStorerKey
         AND LLI.Qty - LLI.QtyPicked + LLI.PendingMoveIn > 0
         AND (LOC.MaxPallet = 0 OR IDCount.TotalIDCount < LOC.MaxPallet)
      ORDER BY LOC.LogicalLocation, LOC.Loc

      -- Second try: Find empty location if no matching inventory
      IF @cSuggestLoc IS NULL OR @cSuggestLoc = ''
      BEGIN
         SELECT TOP 1 @cSuggestLoc = LOC.Loc
         FROM dbo.LOC LOC WITH (NOLOCK)
         LEFT JOIN (
            SELECT LLI2.Loc, LLI2.ID
            FROM dbo.LOTxLOCxID LLI2 WITH (NOLOCK)
            INNER JOIN dbo.LOC LOC2 WITH (NOLOCK) 
               ON LLI2.Loc = LOC2.Loc
            WHERE LLI2.StorerKey = @cStorerKey
            AND LOC2.PutawayZone = @cPutawayZone
            AND (LLI2.Qty - LLI2.QtyPicked + LLI2.PendingMoveIn) > 0
            GROUP BY LLI2.Loc, LLI2.ID
          ) LLI
         ON LOC.Loc = LLI.Loc
         WHERE LOC.PutawayZone = @cPutawayZone
            AND LOC.Facility = @cFacility
            AND LOC.LocationFlag = 'NONE'
            AND LOC.Status = 'OK'
            AND LOC.LoseID = '0'
         GROUP BY LOC.Loc, LOC.MaxPallet, LOC.LogicalLocation
         HAVING ISNULL(COUNT(DISTINCT LLI.ID), 0) = 0
         ORDER BY LOC.LogicalLocation, LOC.Loc
      END

      IF @cSuggestLoc IS NULL OR @cSuggestLoc = ''
      BEGIN
         IF @nDebugFlag = 1
            SELECT '260206-MIX: No available location'
         ELSE
            EXEC nspLogAlert
               @c_modulename = '605-PALRCPT',
               @c_AlertMessage = 'PA task creation failed: 260206-MIX: No available location',
               @n_Severity = 5,
               @b_Success = @bSuccess OUTPUT,
               @n_err = @nErrNo OUTPUT,
               @c_errmsg = @cErrMsg OUTPUT,
               @c_Activity = 'PALRCPT',
               @c_Storerkey = @cStorerKey,
               @c_SKU = '',
               @c_UOM = '',
               @c_UOMQty = '',
               @c_Qty = '',
               @c_Lot = '',
               @c_Loc = @cRPDToLoc,
               @c_ID = @cToID,
               @c_TaskDetailKey = ''

         GOTO Quit
      END

      GOTO Quit
   END -- Mix

   -- SCENARIO 4: MONO
   IF @cSuggestLoc = '' AND @cLottable02 = 'MONO'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Scenario: MONO'

      -- Get PutawayZone from Consignee Storer
      SELECT @cPutawayZone = CASE
            WHEN SUSR5 IS NOT NULL AND SUSR5 <> '' THEN SUSR5
            ELSE SUSR1 END
      FROM dbo.STORER WITH (NOLOCK)
      WHERE Type = '2'
         AND ConsigneeFor = @cStorerKey
         AND Address1 = @cLottable01

      IF @cPutawayZone IS NULL OR @cPutawayZone = ''
      BEGIN
         IF @nDebugFlag = 1
            SELECT '260207-MONO: Storer SUSR values missing'
         ELSE
            EXEC nspLogAlert
               @c_modulename = '605-PALRCPT',
               @c_AlertMessage = 'PA task creation failed: 260207-MONO: Storer SUSR values missing',
               @n_Severity = 5,
               @b_Success = @bSuccess OUTPUT,
               @n_err = @nErrNo OUTPUT,
               @c_errmsg = @cErrMsg OUTPUT,
               @c_Activity = 'PALRCPT',
               @c_Storerkey = @cStorerKey,
               @c_SKU = '',
               @c_UOM = '',
               @c_UOMQty = '',
               @c_Qty = '',
               @c_Lot = '',
               @c_Loc = @cRPDToLoc,
               @c_ID = @cToID,
               @c_TaskDetailKey = ''

         GOTO Quit
      END

      -- Find available location: prefer locations with inventory, then empty locations
      SELECT TOP 1 @cSuggestLoc = LOC.Loc
      FROM dbo.LOC LOC WITH (NOLOCK)
      LEFT JOIN (
         SELECT LLI2.Loc, LLI2.ID
         FROM dbo.LOTxLOCxID LLI2 WITH (NOLOCK)
         INNER JOIN dbo.LOC LOC2 WITH (NOLOCK) 
            ON LLI2.Loc = LOC2.Loc
         WHERE LLI2.StorerKey = @cStorerKey
           AND LOC2.PutawayZone = @cPutawayZone
           AND (LLI2.Qty - LLI2.QtyPicked + LLI2.PendingMoveIn) > 0
         GROUP BY LLI2.Loc, LLI2.ID
      ) LLI
      ON LOC.Loc = LLI.Loc
      WHERE LOC.PutawayZone = @cPutawayZone
         AND LOC.Facility = @cFacility
         AND LOC.LocationFlag = 'NONE'
         AND LOC.Status = 'OK'
         AND LOC.LoseID = '0'
      GROUP BY LOC.Loc, LOC.MaxPallet, LOC.LogicalLocation
      HAVING LOC.MaxPallet = 0 OR ISNULL(COUNT(DISTINCT LLI.ID), 0) < LOC.MaxPallet
      ORDER BY
         CASE WHEN ISNULL(COUNT(DISTINCT LLI.ID), 0) > 0 THEN 0 ELSE 1 END,
         LOC.LogicalLocation,
         LOC.Loc

      IF @cSuggestLoc IS NULL OR @cSuggestLoc = ''
      BEGIN
         IF @nDebugFlag = 1
            SELECT '260207-MONO: No available location'
         ELSE
            EXEC nspLogAlert
               @c_modulename = '605-PALRCPT',
               @c_AlertMessage = 'PA task creation failed: 260207-MONO: No available location',
               @n_Severity = 5,
               @b_Success = @bSuccess OUTPUT,
               @n_err = @nErrNo OUTPUT,
               @c_errmsg = @cErrMsg OUTPUT,
               @c_Activity = 'PALRCPT',
               @c_Storerkey = @cStorerKey,
               @c_SKU = '',
               @c_UOM = '',
               @c_UOMQty = '',
               @c_Qty = '',
               @c_Lot = '',
               @c_Loc = @cRPDToLoc,
               @c_ID = @cToID,
               @c_TaskDetailKey = ''

         GOTO Quit
      END

      GOTO Quit
   END

   IF @cSuggestLoc = ''
   BEGIN
      IF @nDebugFlag = 1
         SELECT '260209: No PA logic found'
      ELSE
         EXEC nspLogAlert
            @c_modulename = '605-PALRCPT',
            @c_AlertMessage = 'PA task creation failed: 260209: No putaway logic is found',
            @n_Severity = 5,
            @b_Success = @bSuccess OUTPUT,
            @n_err = @nErrNo OUTPUT,
            @c_errmsg = @cErrMsg OUTPUT,
            @c_Activity = 'PALRCPT',
            @c_Storerkey = @cStorerKey,
            @c_SKU = '',
            @c_UOM = '',
            @c_UOMQty = '',
            @c_Qty = '',
            @c_Lot = '',
            @c_Loc = @cRPDToLoc,
            @c_ID = @cToID,
            @c_TaskDetailKey = ''

      GOTO Quit
   END

Quit:
   IF @nDebugFlag = 1
      SELECT 'Quit', @cSuggestLoc AS SuggestLoc

   --Do not block finalization process, only create alert
   SET @nErrNo = 0
   SET @cErrMsg = ''

END--sp
GO

GRANT EXECUTE ON [RDT].[rdt_605RcvCfm05_GetSuggestLoc] TO [NSQL]
GO