
/**************************************************************************/
/* Store procedure: rdt_513ExtVal_GAL                                       */
/* Copyright: Maersk                                                      */
/* Customer : GAL - Galaxy                                                 */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2026-01-20 1.0  JRA432      Intital Version                          */
/**************************************************************************/

CREATE OR ALTER     PROC [RDT].[rdt_513ExtVal_GAL] (
   @nMobile         INT,          
   @nFunc           INT,          
   @cLangCode       NVARCHAR( 3), 
   @nStep           INT,          
   @nInputKey       INT,          
   @cStorerKey      NVARCHAR( 15),
   @cFacility       NVARCHAR(  5),
   @cFromLOC        NVARCHAR( 10),
   @cFromID         NVARCHAR( 18),
   @cSKU            NVARCHAR( 20),
   @nQTY            INT,          
   @cToID           NVARCHAR( 18),
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT           OUTPUT,   
   @cErrMsg         NVARCHAR( 20) OUTPUT
)
AS
BEGIN

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE 

	  @cLocLevel		INT,
	  @cCurrentIDLoc    NVARCHAR(10),
	  @cScreenPalQty	INT,
	  @cSplitPalQty	    INT


   IF @nFunc = 513 -- Move by SKU
   BEGIN
      IF @nStep = 5 -- TO ID
	  BEGIN
         IF @nInputKey = 1 -- ENTER
		 BEGIN	
		    -- Get On Screen Pallet Qty and Entered Pallet Split Qty
            SELECT TOP 1 
			@cScreenPalQty = CAST(O_Field10 AS INT),
			@cSplitPalQty = CAST(O_Field11 AS INT)
            FROM rdt.RdtMobRec WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
			AND Mobile = @nMobile
			AND Func = @nFunc

			-- If pallet qty being split then new ID required
			IF @cScreenPalQty <> @cSplitPalQty 
			AND @cToID = @cFromID 
               BEGIN
			   SET @nErrNo = 60567
			   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Same From To ID
			   GOTO Quit	
               END

		    IF EXISTS (SELECT 1 -- To ID already exists
                      FROM dbo.lotxlocxid WITH(NOLOCK)
                      WHERE Storerkey = @cStorerKey
					  AND ID = @cToID
					  AND Qty > 0) 
            BEGIN
			   IF NOT EXISTS (SELECT 1 --SKU does not exist on pallet - prevent mixing
			              FROM dbo.LotxLocxId WITH(NOLOCK) 
						  WHERE Storerkey = @cStorerKey
					      AND ID = @cToID
						  AND Sku = @cSKU
					      AND Qty > 0)
               BEGIN
			      SET @nErrNo = 70191
			      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DO NOT MIX SKU
			      GOTO Quit	
               END
		    END

		 END
	  END

      IF @nStep = 6 -- TO LOC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN	           
			   IF EXISTS (SELECT 1 -- To Location EXISTS for facility
                           FROM LOC WITH(NOLOCK)
                           WHERE Facility = 'NLRT1'
						   AND Loc = @cToLOC)
               BEGIN
			      -- Get Location Level
                  SELECT TOP 1 @cLocLevel = LocLevel
                  FROM dbo.Loc WITH(NOLOCK)
                  WHERE Facility = 'NLRT1'
				  AND Loc = @cToLOC
                  
                  IF @cLocLevel > 1 --Storage only permitted level 0 / 1 for H&S
                     BEGIN
					 SET @nErrNo = 52754
					 SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InvalidLOC
					 GOTO Quit	
                     END
			      				  
                  IF EXISTS (SELECT 1 -- To ID already exists
                           FROM dbo.lotxlocxid WITH(NOLOCK)
                           WHERE Storerkey = @cStorerKey
						   AND ID = @cToID
						   AND Qty > 0)
                  BEGIN
			         -- Get Current Location of ID
                     SELECT TOP 1 @cCurrentIDLoc = Loc
                     FROM dbo.lotxlocxid WITH(NOLOCK)
                     WHERE Storerkey = @cStorerKey
					 AND ID = @cToID
					 AND Qty > 0		

				     IF @cToLOC <> @cCurrentIDLoc --Entered To location does not match the current location of the entered To ID
                        BEGIN
					    SET @nErrNo = 52754
					    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InvalidLOC
					    GOTO Quit	
                        END
				  END
               END			      
          END 
      END
   END
QUIT:
END



