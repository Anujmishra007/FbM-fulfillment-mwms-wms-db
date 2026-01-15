
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: [rdt_511ExtValJCB]                                           */
/* Copyright      : MAERSK                                                       */
/*                                                                               */
/* Purpose: CHECK LOC IS DAMAGE   && CHECK THE MAX PALLET of existing stock      */
/*                                                                               */
/* Date        Rev  Author     Purposes                                          */
/* 26-04-2024  1.0  SOMA       WMS-12635 Created                                 */
/* 28-07-2025  2.0  PPA374     Restricting move when task exists                 */
/* 20-11-2025  3.0  SKE140     Restricting FROMLOC if HOLD                       */
/* 06-01-2026  4.0  PPA374     Adding weight validation for the ID, loc and beam */
/*********************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_511ExtValJCB] (
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
   
   DECLARE @cFacility          AS NVARCHAR( 5)
   DECLARE @nMaxPallet         AS INT
   DECLARE @cLocCat            AS NVARCHAR( 20)
   DECLARE @cLocStatus         AS NVARCHAR( 10)
   DECLARE @cLocFlag           AS NVARCHAR( 10)
   DECLARE @fMaxLocWeight      AS Float
   DECLARE @fCurrentLocWeight  AS Float
   DECLARE @fMaxLocLength      AS Float
   DECLARE @fMaxLocWidth       AS Float
   DECLARE @fMaxLocHeight      AS Float
   DECLARE @nLocLevel          AS INT
   DECLARE @cLocBeam           AS NVARCHAR( 10)
   DECLARE @fMaxBeamWeight     AS Float
   DECLARE @fCurrentBeamWeight AS Float
   DECLARE @fIDWeight          AS Float
   DECLARE @fIDLength          AS Float
   DECLARE @fIDWidth           AS Float
   DECLARE @fIDHeight          AS Float

   SET @nErrNo = 0

   SELECT @cFacility = FACILITY
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
  
IF @nFunc = 511 -- Move by ID
BEGIN
   IF @nStep = 1
   BEGIN
      IF @nInputKey = 1 -- ENTER key pressed
	  BEGIN
	     IF EXISTS (
		    SELECT 1 
			FROM SKU S WITH(NOLOCK) 
			   INNER JOIN LOTxLOCxID LLI WITH(NOLOCK) 
			      ON LLI.SKU = S.SKU 
				  AND LLI.StorerKey = S.StorerKey
			WHERE ISNULL(STDGROSSWGT,0) = 0 
			   AND LLI.Qty > 0 
			   AND LLI.StorerKey = @cStorerKey
			   AND LLI.ID = @cFromID
		 ) 
		 BEGIN
            SET @nErrNo = 218247
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'ID got 0 weight SKU'
			GOTO QUIT
		 END
	  END
   END

   IF @nStep ='2'
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
            IF @cLocFlag = 'HOLD'
            BEGIN
               SET @nErrNo = 218236  -- Error number for FROMLOC is HOLD
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               -- If message doesn't exist, set default message
            
			   IF @cErrMsg IS NULL OR @cErrMsg = ''
                  SET @cErrMsg = 'FROMLOC is HOLD'
                  
               GOTO Quit
            END
         END
      END
   END -- End of Step 1/2 validation

   IF @nStep = 3 -- To LOC
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         SELECT @cLocCat = LocationCategory, 
		    @cLocStatus = Status,
			@cLocFlag = LocationFlag
         FROM dbo.LOC WITH(NOLOCK)
         WHERE LOC = @cToLOC
            AND Facility = @cFacility

         BEGIN
            IF EXISTS (
               SELECT 1 
               FROM dbo.TaskDetail WITH(NOLOCK) 
               WHERE FromID = @cFromID 
                  AND Status NOT IN ('X', '9')
				  AND Storerkey = @cStorerKey
            )
            BEGIN
               SET @nErrNo = 218233
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'LPN got an open task'
			   GOTO QUIT
            END

            IF (
               SELECT MaxPallet - ISNULL(COUNT(DISTINCT ID), 0) 
               FROM dbo.LOC L WITH(NOLOCK)
                  LEFT JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
                     ON L.Loc = LLI.Loc AND LLI.StorerKey = @cStorerKey AND L.Facility = @cFacility
               WHERE L.Loc = @cToLOC
                  AND (Qty + PendingMoveIN > 0 OR LLI.Loc IS NULL)
				  AND L.Facility = @cFacility
               GROUP BY MaxPallet
               ) <= 0
               AND EXISTS (
                  SELECT 1
                  FROM dbo.CODELKUP C WITH(NOLOCK)
                  WHERE Code = @cLocCat
                     AND LISTNAME = 'JCBMBILOC'
                     AND Short = 1
					 AND C.Storerkey = @cStorerKey
               )
            BEGIN
               SET @nErrNo = 218234
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'Loc got task / stock'
			   GOTO QUIT
            END

			IF (ISNULL(@cLocStatus,'') <> 'OK' 
			   OR ISNULL(@cLocFlag,'') NOT IN ('','NONE'))
			   AND EXISTS (
                  SELECT 1
                  FROM dbo.CODELKUP C WITH(NOLOCK)
                  WHERE Code = @cLocCat
                     AND LISTNAME = 'JCBMBILOC'
                     AND Short = 1
					 AND Storerkey = @cStorerKey
               )
			BEGIN
               SET @nErrNo = 218236
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'Loc on hold or flag'   
			   GOTO QUIT
			END
			
			SELECT TOP 1 @nLocLevel = ISNULL(LocLevel,0), @cLocBeam = ISNULL(LocationRoom,'') FROM dbo.LOC WITH(NOLOCK) WHERE LOC = @cToLOC AND Facility = @cFacility

			SELECT @fIDWeight = ISNULL(SUM(Qty * ISNULL(STDGROSSWGT,0)),0) 
			FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
			   INNER JOIN dbo.SKU S WITH(NOLOCK)
			      ON S.Sku = LLI.SKU
				  AND LLI.StorerKey = S.StorerKey
			WHERE LLI.StorerKey = @cStorerKey 
			   AND LLI.ID = @cFromID 
			   AND LLI.Qty > 0

			SELECT @fCurrentLocWeight = ISNULL(SUM(Qty * ISNULL(STDGROSSWGT,0)),0) 
			FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
			   INNER JOIN dbo.SKU S WITH(NOLOCK)
			      ON S.Sku = LLI.SKU
				  AND LLI.StorerKey = S.StorerKey
			WHERE LLI.StorerKey = @cStorerKey 
			   AND LLI.LOC = @cToLOC
			   AND LLI.Qty > 0 

			SELECT @fCurrentBeamWeight = ISNULL(SUM(Qty * ISNULL(STDGROSSWGT,0)),0) 
			FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
			   INNER JOIN dbo.SKU S WITH(NOLOCK)
			      ON S.Sku = LLI.SKU
				  AND LLI.StorerKey = S.StorerKey
			WHERE LLI.StorerKey = @cStorerKey 
			   AND LLI.LOC IN (SELECT LOC FROM LOC L WITH(NOLOCK) WHERE LocationRoom = @cLocBeam AND @cLocBeam <> '')
			   AND LLI.Qty > 0 

			SELECT TOP 1 
			   @fMaxLocWeight  = UDF04,
			   @fMaxBeamWeight = UDF05
			FROM dbo.CODELKUP WITH(NOLOCK) 
			WHERE LISTNAME = 'JCBLOCCAP' 
			   AND StorerKey = @cStorerKey
			   AND Long = @nLocLevel 
			   AND Short = @cLocCat

			IF @fMaxLocWeight IS NULL SET @fMaxLocWeight = 999999999
			IF @fMaxBeamWeight IS NULL SET @fMaxBeamWeight = 999999999

			IF @fMaxLocWeight - @fCurrentLocWeight - @fIDWeight < 0
			   OR @fMaxBeamWeight - @fCurrentBeamWeight - @fIDWeight < 0
			BEGIN
               SET @nErrNo = 218248
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'Over weight limit'   
			   GOTO QUIT			   
			END
         END
      END
   END
QUIT:
END
	
GO
GRANT EXECUTE ON [RDT].[rdt_511ExtValJCB] TO [NSQL]
GO

