SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_664ExtValid01HRP                                */
/* Purpose: Move By ID Extended Validate                                */
/*                                                                      */
/* Called from: rdtfnc_MoveIDBeforeFinalization                         */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2025-07-02  1.0  WSE016      Created                                 */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_664ExtValid01HRP] (
   @nMobile            INT,
   @nFunc              INT, 
   @cLangCode          NVARCHAR( 3), 
   @nStep              INT, 
   @nInputKey          INT, 
   @cFacility          NVARCHAR( 5),
   @cStorerKey         NVARCHAR( 15),
   @cID                NVARCHAR( 18),    
   @cFromLOC           NVARCHAR( 10),
   @cToLOC             NVARCHAR( 10),
   @c_SKU              NVARCHAR(20),
   @cReceiptKey        NVARCHAR( 10),
   @cReceiptLineNumber NVARCHAR( 5),
   @nErrNo             INT           OUTPUT, 
   @cErrMsg            NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
     @c_AsnSKU   NVARCHAR(20)
   , @c_AsnSKU1   NVARCHAR(20)
   , @c_LocSKU NVARCHAR(20)
   , @c_SKUCnt  INT
   , @c_SKUCOD INT
   , @c_LocLLI NVARCHAR(20)
   , @c_LocType NVARCHAR( 10) 


   SET @nErrNo = 0


   IF @nFunc = 664
   BEGIN
      IF @nStep = 3
      BEGIN
         IF @nInputKey = 1
         BEGIN

-- get LocationType
    SELECT @c_LocType = locationType 
    FROM LOC WITH (NOLOCK) 
    WHERE Facility = @cFacility and LOC = @cToLOC


    IF @c_LocType = 'OTHER'
    BEGIN

           -- Not allow to move Pallet to location with Stock where locationType <> PICK
            SELECT  @c_LocLLI = LLI.LOC
                FROM LOTxLOCxID LLI WITH (NOLOCK) 
                INNER JOIN LOC LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)
                WHERE LOC.Facility = @cFacility
                AND   LOC.Loc = @cToLOC
                AND LOC.LocationType ='OTHER'
                --AND LLI.QTY <>0
                GROUP BY LLI.LOC  
                HAVING ISNULL(SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.PendingMoveIn), 0) <> 0


          IF @c_LocLLI = @cToLOC

               BEGIN
                  SET @nErrNo = 218372  --LOC in use
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

          IF EXISTS (SELECT  1
                FROM RECEIPTDETAIL WITH (NOLOCK) 
                WHERE StorerKey = @cStorerKey 
                AND receiptkey = @cReceiptKey
                AND ToLoc = @cToLOC)

               BEGIN
                  SET @nErrNo = 218373  -- Loc Allocated on ASN
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END
  END



    IF @c_LocType = 'PICK'
     BEGIN

            -- Not allow to Mix SKU in locationType = PICK

        IF EXISTS (
            SELECT 1
            FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
            INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON LLI.LOC = LOC.LOC
            WHERE LLI.StorerKey = @cStorerKey
            AND LOC.Facility = @cFacility
            AND LOC.Loc = @cToLOC
            AND LOC.LocationType = 'PICK'
            AND LLI.Qty > 0
        )
        OR EXISTS (
            SELECT 1
            FROM RECEIPTDETAIL WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND ReceiptKey = @cReceiptKey
            AND ToLoc = @cToLOC
        )
            BEGIN
                    SELECT TOP 1
                    @c_LocSKU = ISNULL(LLI.SKU, '')
                        FROM dbo.LOTxLOCxID LLI WITH (NOLOCK) 
                        INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)
                        WHERE LLI.StorerKey = @cStorerKey 
                        AND LOC.Facility =  @cFacility 
                        AND   LOC.Loc = @cToLOC
                        AND LOC.LocationType ='PICK'
                        AND  ISNULL(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.PendingMoveIn, 0) <> 0

                    SELECT  @c_AsnSKU = ISNULL(MIN(SKU), '') 
                     ,  @c_SKUCnt = count(distinct SKU)
                     ,  @c_SKUCOD = LEN(Lottable03)
                        FROM RECEIPTDETAIL WITH (NOLOCK) 
                        WHERE StorerKey = @cStorerKey 
                        AND receiptkey = @cReceiptKey
                        AND ToId = @cID
                        --AND LEN(Lottable03) >3
                        GROUP BY Lottable03
                     
                     
                      SELECT  @c_AsnSKU1 = ISNULL(MIN(SKU), '') 
                        FROM RECEIPTDETAIL WITH (NOLOCK) 
                        WHERE StorerKey = @cStorerKey 
                        AND receiptkey = @cReceiptKey
                        AND ToLoc = @cToLOC



                    IF @c_LocSKU  <> @c_AsnSKU  and @c_AsnSKU <> @c_AsnSKU1 --and Sum(@c_SKUCnt) >1 and @c_SKUCOD <4

                        BEGIN
                        SET @nErrNo = 218374  --Different SKU in PICK location
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                        GOTO Quit
                    END
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
GRANT EXECUTE ON RDT.rdt_664ExtValid01HRP TO NSQL
GO

