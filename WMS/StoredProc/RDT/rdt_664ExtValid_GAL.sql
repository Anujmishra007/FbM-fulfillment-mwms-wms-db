
/************************************************************************/
/* Store procedure: rdt_664ExtValid01_GAL                                */
/* Purpose: Move By ID Extended Validation                                */
/*                                                                      */
/* Called from: rdtfnc_MoveIDBeforeFinalization                         */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2026-01-20  1.0  JRA432      Created                                 */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER     PROC [RDT].[rdt_664ExtValid_GAL] (
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
	@cLocLevel		INT

   SET @nErrNo = 0

   IF @nFunc = 664
   BEGIN
      IF @nStep = 3
      BEGIN
         IF @nInputKey = 1
         BEGIN	 
               IF EXISTS (SELECT 1
                           FROM LOC WITH(NOLOCK)
                           WHERE Facility = 'NLRT1'
						   AND Loc = @cToLOC)
               BEGIN
                  SELECT TOP 1 @cLocLevel = LocLevel
                  FROM dbo.Loc WITH(NOLOCK)
                  WHERE Facility = 'NLRT1'
				  AND Loc = @cToLOC
                  
                  IF @cLocLevel > 1
                     BEGIN
					 SET @nErrNo = 52754
					 SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InvalidLOC
					 GOTO Quit	
                     END
               END
          END 
	   END
   QUIT:  
   END
                 


