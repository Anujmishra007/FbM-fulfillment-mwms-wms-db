
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: [rdt_511ExtValJCB]                                        */
/* Copyright      : MAERSK                                                    */
/*                                                                            */
/* Purpose: CHECK LOC IS DAMAGE   && CHECK THE MAX PALLET of existing stock   */
/*                                                                            */
/* Date        Rev  Author     Purposes                                       */
/* 26-04-2024  1.0  SOMA       WMS-12635 Created                              */
/* 28-07-2025  2.0  PPA374     Restricting move when task exists              */
/******************************************************************************/

ALTER   PROC [RDT].[rdt_511ExtValJCB] (
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
   
   DECLARE @cFacility  AS NVARCHAR( 5)
   DECLARE @nMaxPallet AS INT
   DECLARE @cLocCat    AS NVARCHAR( 20)
   DECLARE @cLocStatus AS NVARCHAR( 10)
   DECLARE @cLocFlag   AS NVARCHAR( 10)

   SET @nErrNo = 0

   SELECT @cFacility = FACILITY
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
  
IF @nFunc = 511 -- Move by ID
BEGIN
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
			   
         END
      END
   END
END
QUIT:

GO
GRANT EXECUTE ON [RDT].[rdt_511ExtValJCB] TO [NSQL]
GO

