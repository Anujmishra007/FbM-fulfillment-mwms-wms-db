
/************************************************************************/
/* Store procedure: rdt_1878ExtValidSP01                                */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Extended validation for Pallet Consolidate BESE             */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev    Author   Purposes                                 */
/* 2026-03-13  1.0.0  Jackc    FCR-9676 Created                         */
/* 2026-05-12  1.0.1  Jackc    FCR-9676 V1.2 FBR                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1878ExtValidSP01] (
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
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 1024) OUTPUT  -- screen limitation, 20 char max
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cFromLottable01  NVARCHAR(18),
      @cFromLottable02  NVARCHAR(18),
      @cToLottable01    NVARCHAR(18),
      @cTaskType        NVARCHAR(10),
      @cTaskStatus      NVARCHAR(10),
      @nRowCount        INT

   SET @nErrNo   = 0
   SET @cErrMsg  = ''

   IF @nFunc = 1878
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF @nStep = 1
         BEGIN
            IF EXISTS (
               SELECT 1
               FROM dbo.LotXLocXID WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND ID = @cToID
               AND Qty > 0
            )
            BEGIN
               SET @nErrNo = 261151
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID Exists
               GOTO QUIT
            END
         END--st1

         IF @nStep = 3
         BEGIN
            SET @nRowCount = 0
            -- Get FromID Lottable01 and Lottable02
            SELECT TOP 1
               @cFromLottable01 = Lottable01,
               @cFromLottable02 = Lottable02
            FROM dbo.LotxLocxID LLI WITH (NOLOCK)
            JOIN dbo.LotAttribute LA WITH (NOLOCK)
            ON LLI.Lot = LA.Lot
            WHERE LLI.StorerKey = @cStorerKey
            AND ID = @cFromID
            AND Qty > 0

            -- Get ToID Lottable01 if exists
            SELECT TOP 1
               @cToLottable01 = Lottable01
            FROM dbo.LotxLocxID LLI WITH (NOLOCK)
            JOIN dbo.LotAttribute LA WITH (NOLOCK)
            ON LLI.Lot = LA.Lot
            WHERE LLI.StorerKey = @cStorerKey
            AND ID = @cToID
            AND Qty > 0

            SET @nRowCount = @@ROWCOUNT

            -- If ToID exists, Lottable01 must match
            IF @nRowCount <> 0
            BEGIN
               IF ISNULL(@cFromLottable01,'') <> ISNULL(@cToLottable01,'')
               BEGIN
                  SET @nErrNo = 261152
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lottable01 Mismatch
                  GOTO QUIT
               END
            END

            -- FromID Lottable02 must be MONO or MIX
            IF @cFromLottable02 NOT IN ('MONO', 'MIX')
            BEGIN
               SET @nErrNo = 261153
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Missing MONO Type
               GOTO QUIT
            END

            --V1.0.1 start
            IF EXISTS (SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                           AND TaskType = 'ASTLO'
                           AND FromID = @cFromID
                           AND Status = '0')
            BEGIN
               SET @nErrNo = 261154
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Open ASTLO exist
               GOTO QUIT
            END

            IF EXISTS (SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                           AND FromID = @cFromID
                           AND Status = '3')
            BEGIN
               SET @nErrNo = 261155
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Task in progress
               GOTO QUIT
            END
            --V1.0.1 end
         END--st3
      END -- inputkey=1
   END

QUIT:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1878ExtValidSP01 TO NSQL
GO