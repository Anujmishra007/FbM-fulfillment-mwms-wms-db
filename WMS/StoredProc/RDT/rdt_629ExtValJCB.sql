SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************************/
/* Stored procedure: rdt_629ExtValJCB                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Validate ToLOC status and flags for Move SKU Lottable       */
/*   - Check if LPN has open task                                       */
/*   - Check if location has max pallet reached                         */
/*   - Check if location status is OK and flag is NONE                  */
/*                                                                      */
/* Called from: rdtfnc_Move_SKU_Lottable_V7 (Step 7 - ToLOC)            */
/*                                                                      */
/* Modifications log:                                                   */
/* Date         Rev  Author      Purposes                               */
/* 03-Dec-2025  1.0  SKE140      Created for ToLOC validation           */
/* 15-Dec-2025  1.1  PPA374      Adding check against case in tasks     */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_629ExtValJCB]
(
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR(3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR(5),
   @cStorerKey     NVARCHAR(15),
   @cFromLOC       NVARCHAR(10),
   @cFromID        NVARCHAR(18),
   @cSKU           NVARCHAR(20),
   @nQTY           INT,
   @cToID          NVARCHAR(18),
   @cToLOC         NVARCHAR(10),
   @cLottableCode  NVARCHAR(30),
   @cLottable01    NVARCHAR(18),
   @cLottable02    NVARCHAR(18),
   @cLottable03    NVARCHAR(18),
   @dLottable04    DATETIME,
   @dLottable05    DATETIME,
   @cLottable06    NVARCHAR(30),
   @cLottable07    NVARCHAR(30),
   @cLottable08    NVARCHAR(30),
   @cLottable09    NVARCHAR(30),
   @cLottable10    NVARCHAR(30),
   @cLottable11    NVARCHAR(30),
   @cLottable12    NVARCHAR(30),
   @dLottable13    DATETIME,
   @dLottable14    DATETIME,
   @dLottable15    DATETIME,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR(400) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON;

   -- Local variables
   DECLARE
      @cLocCat    NVARCHAR(10),
      @cLocStatus NVARCHAR(10),
      @cLocFlag   NVARCHAR(20);

   SET @nErrNo = 0;
   SET @cErrMsg = N'';

IF @nStep ='1'
      BEGIN
         IF @nInputKey = 1 -- ENTER key pressed
         BEGIN
            -- Check if FROMLOC is provided (it might be populated after Step 1 or Step 2)
            IF @cFromLOC IS NOT NULL AND @cFromLOC <> ''
            BEGIN
               -- Get the LocationFlag from LOC table
               SELECT @cLocFlag = LocationFlag
               FROM dbo.LOC WITH (NOLOCK)
               WHERE Loc = @cFromLOC
                 AND Facility = @cFacility

               -- Check if location is on HOLD
         IF --(ISNULL(@cLocFlag, '') NOT IN ('', 'NONE'))
         (ISNULL(@cLocFlag,'') = 'INACTIVE' OR ISNULL(@cLocFlag,'') = 'HOLD' OR ISNULL(@cLocFlag,'') = 'DAMAGED' OR ISNULL(@cLocFlag,'') = 'DAMAGE' OR ISNULL(@cLocFlag,'') = 'INLOCKED' )
               BEGIN
                  SET @nErrNo = 218236  -- Error number for FROMLOC is HOLD
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  -- If message doesn't exist, set default message
                  IF @cErrMsg IS NULL OR @cErrMsg = ''
                     SET @cErrMsg = 'FROMLOC has flag'
                  
                  GOTO Quit
               END
            END
         END
      END -- End of Step 1/2 validation


   -- Only validate on Step 7 (ToLOC)
   IF @nStep = 7
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         -- Get location info
         SELECT
            @cLocCat    = LocationCategory,
            @cLocStatus = Status,
            @cLocFlag   = LocationFlag
         FROM dbo.LOC WITH (NOLOCK)
         WHERE LOC = @cToLOC
           AND Facility = @cFacility;

         -- Validation 1: Check if LPN has open task
         IF EXISTS (
            SELECT 1
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE FromID = @cFromID
              AND Status NOT IN ('X', '9')
              AND StorerKey = @cStorerKey
			  AND CaseID = @cLottable11
         )
         BEGIN
            SET @nErrNo = 218233;
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP'); -- 'LPN got an open task'
            GOTO QUIT;
         END

         -- Validation 2: Check if location has max pallet reached
         IF (
            SELECT L.MaxPallet - ISNULL(COUNT(DISTINCT LLI.ID), 0)
            FROM dbo.LOC L WITH (NOLOCK)
            LEFT JOIN dbo.LOTxLOCxID LLI WITH (NOLOCK)
               ON L.Loc = LLI.Loc
               AND LLI.StorerKey = @cStorerKey
               AND L.Facility = @cFacility
            WHERE L.Loc = @cToLOC
              AND (LLI.Qty + ISNULL(LLI.PendingMoveIN, 0) > 0 OR LLI.Loc IS NULL)
              AND L.Facility = @cFacility
            GROUP BY L.MaxPallet
         ) <= 0
         AND EXISTS (
            SELECT 1
            FROM dbo.CODELKUP C WITH (NOLOCK)
            WHERE C.Code = @cLocCat
              AND C.LISTNAME = 'JCBMBILOC'
              AND C.Short = 1
              AND C.StorerKey = @cStorerKey
         )
         BEGIN
            SET @nErrNo = 218234;
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP'); -- 'Loc got task / stock'
            GOTO QUIT;
         END

         -- Validation 3: Check if location status is not OK or has a flag
         IF (ISNULL(@cLocFlag, '') NOT IN ('', 'NONE'))
         AND EXISTS (
            SELECT 1
            FROM dbo.CODELKUP C WITH (NOLOCK)
            WHERE C.Code = @cLocCat
              AND C.LISTNAME = 'JCBMBILOC'
              AND C.Short = 1
              AND C.StorerKey = @cStorerKey
         )
         BEGIN
            SET @nErrNo = 218236;
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP'); -- 'Loc on hold or flag'
            GOTO QUIT;
         END

      END
   END

QUIT:
   RETURN;
END

GO
GRANT EXECUTE ON rdt.rdt_629ExtValJCB TO NSQL
GO
