
/**************************************************************************/
/* Store procedure: rdt_1819ExtVal_GAL                                      */
/*                                                                        */
/* Purpose:         GAL - Galaxy Extended Validation SP                   */
/*                                                                        */
/* Date        Rev  Author   Purposes                                     */
/* 19-01-2026  1.0  JRA432   Initial Version                              */
/**************************************************************************/

CREATE OR ALTER     PROC [RDT].[rdt_1819ExtVal_GAL] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cFromID         NVARCHAR( 18),
   @cSuggLOC        NVARCHAR( 10),
   @cPickAndDropLOC NVARCHAR( 10),
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
	  @cStorerKey          NVARCHAR(15),	  
	  @cLocLevel		INT,
	  @cI_Field01		nvarchar(60)
               
              
   SELECT @cStorerKey = StorerKey , @cI_Field01 = I_Field01
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 1819 -- Putaway by ID
   BEGIN
      IF @nStep = 99 -- Change location confirmation
      BEGIN
         IF @nInputKey = 1 -- ENTER
		 AND @cI_Field01 = 1 -- Confirm location change
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
            --END            
         END
      END
   END

Quit:

END
