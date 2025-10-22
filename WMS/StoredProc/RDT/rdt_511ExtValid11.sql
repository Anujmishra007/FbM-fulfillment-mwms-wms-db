SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_511ExtValid11                                   */
/* Purpose: Move By ID Extended Validate                                */
/*                                                                      */
/* Called from: rdtfnc_Move_ID                                          */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2025-07-14  1.0  Cuize     FCR-6091 Created                         */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_511ExtValid11] (
   @nMobile          INT,
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15),
   @cFromID          NVARCHAR( 18),    
   @cFromLOC         NVARCHAR( 10),
   @cToLOC           NVARCHAR( 10),
   @cToID            NVARCHAR( 18),
   @nErrNo           INT           OUTPUT, 
   @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cFacility   NVARCHAR( 5)

   SET @nErrNo = 0

   SELECT @cFacility = Facility
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 511
   BEGIN
      IF @nStep = 3
      BEGIN
         IF @nInputKey = 1
         BEGIN
            DECLARE @cLottable03 NVARCHAR( 30)

            SELECT @cLottable03 = ISNULL(LOT.Lottable03,'')
            FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
               INNER JOIN dbo.LOTATTRIBUTE LOT WITH(NOLOCK)
                  ON (LLI.Lot = LOT.Lot
                     AND LLI.Sku = LOT.Sku
                     AND LLI.StorerKey = LOT.StorerKey)
            WHERE LLI.StorerKey = @cStorerKey
              AND LLI.Id = @cFromID
              AND LLI.Qty > 0


            IF @cLottable03 = ''
            BEGIN
               --@cLottable03 empty
               IF NOT EXISTS( SELECT 1
                  FROM LOC (NOLOCK)
                  WHERE LOC = @cToLOC
                  AND LocationType = 'CASE')
               BEGIN
                  SET @nErrNo = 242151
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Location not in Pickface Zone
                  GOTO QUIT
               END
            END
            ELSE
            BEGIN
               --@cLottable03 has value
               IF NOT EXISTS(SELECT 1
                  FROM LOC (NOLOCK)
                  WHERE LOC = @cToLOC
                     AND LocationType = 'CASE'
                     AND Putawayzone IN
                     (
                        SELECT Code
                        FROM codelkup (NOLOCK)
                        WHERE Listname = 'LVSCTZONE'
                        AND Storerkey = @cStorerkey
                        AND Long = @cLottable03)
                     )
               BEGIN
                  SET @nErrNo = 242152
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Location not in assigned Zone
                  GOTO QUIT
               END
            END

         END
      END
   END

QUIT:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_511ExtValid11] TO [NSQL]
GO
