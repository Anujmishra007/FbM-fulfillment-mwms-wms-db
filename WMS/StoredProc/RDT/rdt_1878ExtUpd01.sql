/************************************************************************/
/* Store procedure: rdt_1878ExtUpd01                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Extended update for Pallet Consolidate BESE                 */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2026-03-16  1.0  Jackc    FCR-9676 Created                           */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1878ExtUpd01] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cStorerKey     NVARCHAR( 15),
   @cFromID        NVARCHAR( 20),
   @cOption        NVARCHAR( 1),
   @cSKU           NVARCHAR( 20),
   @cLot           NVARCHAR( 10),
   @nQty           INT,
   @cToID          NVARCHAR( 20),
   @cLottable01    NVARCHAR( 18),
   @cLottable02    NVARCHAR( 18),
   @cLottable03    NVARCHAR( 18),
   @dLottable04    DATETIME,
   @dLottable05    DATETIME,
   @cLottable06    NVARCHAR( 30),
   @cLottable07    NVARCHAR( 30),
   @cLottable08    NVARCHAR( 30),
   @cLottable09    NVARCHAR( 30),
   @cLottable10    NVARCHAR( 30),
   @cLottable11    NVARCHAR( 30),
   @cLottable12    NVARCHAR( 30),
   @dLottable13    DATETIME,
   @dLottable14    DATETIME,
   @dLottable15    DATETIME,
   @nScannedCount  INT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 1024) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''

   DECLARE @nDebugFlag INT = 0

   DECLARE
      @bSuccess            INT,
      @cFacility           NVARCHAR(5),
      @cUserName           NVARCHAR(18),
      @cToLottable01       NVARCHAR(18),
      @cToLOC              NVARCHAR(18),
      @cFromLOC            NVARCHAR(18),
      @cSuggestLoc         NVARCHAR(10),
      @cSuggAreaKey        NVARCHAR(10),
      @cPutawayZone        NVARCHAR(10),
      @cTaskDetailKey      NVARCHAR(10)

   IF @nDebugFlag = 1
      SELECT 'Executing 1878ExtUpd01'

   SELECT 
      @cFacility = Facility,
      @cUserName = UserName
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 1878
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF @nStep = 3
         BEGIN
            IF @cFromID = '' AND @nScannedCount > 0
            BEGIN
               GOTO CREATE_TASK
            END
         END

         GOTO QUIT
      END--Enter

      IF @nInputKey = 0 --ESC
      BEGIN
         IF @nStep = 3
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Step3, ESC'
            
            CREATE_TASK:
            IF @nScannedCount > 0
            BEGIN
               IF NOT EXISTS (SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) 
                        WHERE StorerKey = @cStorerKey
                           AND TaskType = 'ASTPA'
                           AND Status IN ('0','3')
                           AND FromID = @cToID)
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'Generate ASTPA task'

                  SELECT TOP 1
                     @cToLottable01  = Lottable01,
                     @cToLOC           = LOC
                  FROM dbo.LotxLocxID LLI WITH (NOLOCK)
                  JOIN dbo.LotAttribute LA WITH (NOLOCK)
                  ON LLI.Lot = LA.Lot
                  WHERE LLI.StorerKey = @cStorerKey
                  AND ID = @cToID
                  AND Qty > 0

                  SET @cToLOC = ISNULL(@cToLOC, '')
                  SET @cToLottable01 = ISNULL(@cToLottable01, '')

                  IF @cToLOC = ''
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT '261302 ToID not exist'
                     ELSE
                        EXEC nspLogAlert
                           @c_modulename = '1878-PALMERGE',
                           @c_AlertMessage = 'PA task creation failed: 261302-MONO: ToID not exist',
                           @n_Severity = 5,
                           @b_Success = @bSuccess OUTPUT,
                           @n_err = @nErrNo OUTPUT,
                           @c_errmsg = @cErrMsg OUTPUT,
                           @c_Activity = 'PALMERGE',
                           @c_Storerkey = @cStorerKey,
                           @c_SKU = '',
                           @c_UOM = '',
                           @c_UOMQty = '',
                           @c_Qty = '',
                           @c_Lot = '',
                           @c_Loc = @cToLOC,
                           @c_ID = @cToID,
                           @c_TaskDetailKey = ''

                     GOTO Quit
                  END

                  -- Get PutawayZone from Consignee Storer
                  SELECT @cPutawayZone = CASE
                        WHEN SUSR5 IS NOT NULL AND SUSR5 <> '' THEN SUSR5
                        ELSE SUSR1 END
                  FROM dbo.STORER WITH (NOLOCK)
                  WHERE Type = '2'
                     AND ConsigneeFor = @cStorerKey
                     AND Address1 = @cToLottable01

                  IF @cPutawayZone IS NULL OR @cPutawayZone = ''
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT '261301-MONO: Storer SUSR values missing'
                     ELSE
                        EXEC nspLogAlert
                           @c_modulename = '1878-PALMERGE',
                           @c_AlertMessage = 'PA task creation failed: 261301-MONO: Storer SUSR values missing',
                           @n_Severity = 5,
                           @b_Success = @bSuccess OUTPUT,
                           @n_err = @nErrNo OUTPUT,
                           @c_errmsg = @cErrMsg OUTPUT,
                           @c_Activity = 'PALMERGE',
                           @c_Storerkey = @cStorerKey,
                           @c_SKU = '',
                           @c_UOM = '',
                           @c_UOMQty = '',
                           @c_Qty = '',
                           @c_Lot = '',
                           @c_Loc = @cToLOC,
                           @c_ID = @cToID,
                           @c_TaskDetailKey = ''

                     GOTO Quit
                  END

                  IF @nDebugFlag = 1
                     SELECT 'Get PA Zone, finding suggest loc', @cPutawayZone AS PAZone

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
                        SELECT '261303-MONO: No available location'
                     ELSE
                        EXEC nspLogAlert
                           @c_modulename = '1878-PALMERGE',
                           @c_AlertMessage = 'PA task creation failed: 261303-MONO: No available location',
                           @n_Severity = 5,
                           @b_Success = @bSuccess OUTPUT,
                           @n_err = @nErrNo OUTPUT,
                           @c_errmsg = @cErrMsg OUTPUT,
                           @c_Activity = 'PALMERGE',
                           @c_Storerkey = @cStorerKey,
                           @c_SKU = '',
                           @c_UOM = '',
                           @c_UOMQty = '',
                           @c_Qty = '',
                           @c_Lot = '',
                           @c_Loc = @cToLOC,
                           @c_ID = @cToID,
                           @c_TaskDetailKey = ''

                     GOTO Quit
                  END
                  ELSE
                  BEGIN
                     SELECT @cSuggAreaKey = AreaKey
                     FROM dbo.LOC LOC WITH (NOLOCK)
                     JOIN dbo.AreaDetail AD WITH (NOLOCK)
                     ON LOC.PutawayZone = AD.PutawayZone
                     WHERE Facility = @cFacility
                        AND LOC = @cSuggestLoc
                        
                     SET @cSuggAreaKey = ISNULL(@cSuggAreaKey, '')
                  END

                  IF @nDebugFlag = 1
                     SELECT 'Ins TaskDetail', @cSuggestLoc AS SuggestLoc, @cSuggAreaKey AS SuggAreaKey, @cToLOC AS FromLoc

                  EXECUTE dbo.nspg_getkey
                        'TaskDetailKey'
                        , 10
                        , @cTaskDetailKey OUTPUT
                        , @bsuccess OUTPUT
                        , @nErrNo    OUTPUT
                        , @cErrMsg   OUTPUT
                     
                  IF @bSuccess <> 1 OR @nErrNo <> 0
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT '261304-Fail to generate TaskKey'
                     ELSE
                        -- Generate alert
                        EXEC nspLogAlert
                           @c_modulename       = '1878-PALMERGE'
                           , @c_AlertMessage     = 'PAtask creation failed: 261304-Fail to generate TaskKey'
                           , @n_Severity         = '5'
                           , @b_Success          = @bSuccess      OUTPUT
                           , @n_err              = @nErrNo        OUTPUT
                           , @c_errmsg           = @cErrMsg       OUTPUT
                           , @c_Activity         = 'PALMERGE'
                           , @c_Storerkey        = @cStorerKey
                           , @c_SKU              = ''
                           , @c_UOM              = ''
                           , @c_UOMQty           = ''
                           , @c_Qty              = ''
                           , @c_Lot              = ''
                           , @c_Loc              = @cToLOC
                           , @c_ID               = @cToID
                           , @c_TaskDetailKey    = ''

                     SET @nErrNo = 0 -- Send alert instead of err msg
                     GOTO Quit
                  END 

                  BEGIN TRY
                     INSERT INTO dbo.TaskDetail (
                        TaskDetailKey, Status, TaskType, Storerkey, FromLOC, LogicalFromLOC, FromID, ToLoc,
                        LogicalToLOC, ToID, PickMethod, Priority, SourcePriority, SourceType, SourceKey, AreaKey)
                     VALUES (
                        @cTaskDetailKey, '0', 'ASTPA', @cStorerKey, @cToLOC, '', @cToID, @cSuggestLoc,
                        '', '', 'FP', '9', '9', 'rdt_1878ExtUpdSP01', @cToID, @cSuggAreaKey)
                  END TRY
                  BEGIN CATCH
                     IF @nDebugFlag = 1
                        SELECT '261305-Insert TaskDetail Fail'
                     ELSE
                        -- Generate alert
                        EXEC nspLogAlert
                           @c_modulename       = '1878-PALMERGE'
                           , @c_AlertMessage     = 'PA task creation failed: 261305-Insert TaskDetail Fail'
                           , @n_Severity         = '5'
                           , @b_Success          = @bSuccess      OUTPUT
                           , @n_err              = @nErrNo        OUTPUT
                           , @c_errmsg           = @cErrMsg       OUTPUT
                           , @c_Activity         = 'PALMERGE'
                           , @c_Storerkey        = @cStorerKey
                           , @c_SKU              = ''
                           , @c_UOM              = ''
                           , @c_UOMQty           = ''
                           , @c_Qty              = ''
                           , @c_Lot              = ''
                           , @c_Loc              = @cToLOC
                           , @c_ID               = @cToID
                           , @c_TaskDetailKey    = ''

                     GOTO Quit
                  END CATCH

                  -- Lock the suggested location by updating PendingMoveIn
                  DECLARE @nPABookingKey INT = 0

                  EXEC rdt.rdt_Putaway_PendingMoveIn
                     @cUserName        = @cUserName,
                     @cType            = 'LOCK',
                     @cFromLOC         = @cToLOC,
                     @cFromID          = @cToID,
                     @cSuggestedLOC    = @cSuggestLoc,
                     @cStorerKey       = @cStorerKey,
                     @nErrNo           = @nErrNo OUTPUT,
                     @cErrMsg          = @cErrMsg OUTPUT,
                     @cSKU             = '',
                     @nPutawayQTY      = NULL,
                     @cUCCNo           = '',
                     @cFromLOT         = '',
                     @cToID            = '',
                     @cTaskDetailKey   = @cTaskDetailKey,
                     @nFunc            = @nFunc,
                     @nPABookingKey    = @nPABookingKey OUTPUT

                  IF @nErrNo <> 0
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT '261306-Fail to lock suggested location'
                     ELSE
                        EXEC nspLogAlert
                           @c_modulename       = '1878-PALMERGE'
                           , @c_AlertMessage     = 'PA task creation failed: 261306-Fail to lock suggested location'
                           , @n_Severity         = '5'
                           , @b_Success          = @bSuccess      OUTPUT
                           , @n_err              = @nErrNo        OUTPUT
                           , @c_errmsg           = @cErrMsg       OUTPUT
                           , @c_Activity         = 'PALMERGE'
                           , @c_Storerkey        = @cStorerKey
                           , @c_SKU              = ''
                           , @c_UOM              = ''
                           , @c_UOMQty           = ''
                           , @c_Qty              = ''
                           , @c_Lot              = ''
                           , @c_Loc              = @cSuggestLoc
                           , @c_ID               = @cToID
                           , @c_TaskDetailKey    = @cTaskDetailKey

                     SET @nErrNo = 0 -- Send alert instead of err msg
                     GOTO Quit
                  END      
               END -- gen ASTPA task
               ELSE
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT '261307-Open ASTPA task exists'
                  ELSE
                     -- Generate alert
                     EXEC nspLogAlert
                        @c_modulename        = '1878-PALMERGE'
                        , @c_AlertMessage     = 'PA task creation failed: 261307-Open ASTPA task exists'
                        , @n_Severity         = '5'
                        , @b_Success          = @bSuccess      OUTPUT
                        , @n_err              = @nErrNo        OUTPUT
                        , @c_errmsg           = @cErrMsg       OUTPUT
                        , @c_Activity         = 'PALMERGE'
                        , @c_Storerkey        = @cStorerKey
                        , @c_SKU              = ''
                        , @c_UOM              = ''
                        , @c_UOMQty           = ''
                        , @c_Qty              = ''
                        , @c_Lot              = ''
                        , @c_Loc              = @cToLOC
                        , @c_ID               = @cToID
                        , @c_TaskDetailKey    = ''

                  SET @nErrNo = 0
                  GOTO Quit
               END--open ASTPA with same id exists
            END --scanned count > 0
         END --St3

         GOTO QUIT
      END -- ESC
   END

QUIT:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1878ExtUpd01 TO NSQL
GO