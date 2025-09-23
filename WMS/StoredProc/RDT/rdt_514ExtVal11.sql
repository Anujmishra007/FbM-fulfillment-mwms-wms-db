SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 

/**************************************************************************/
/* Store procedure: rdt_514ExtVal11                                       */
/* Purpose: Validate ToLoc                                                */
/* Copyright      : Maersk                                                */
/* Customer       : USA Levis                                             */
/*                                                                        */
/* Modifications log:                                                     */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2025-09-19 1.0.0  NickT      FCR-8145 Created                          */
/**************************************************************************/
  
CREATE OR ALTER PROC [RDT].[rdt_514ExtVal11] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cStorerKey     NVARCHAR( 15),
   @cToID          NVARCHAR( 18),
   @cToLoc         NVARCHAR( 10),
   @cFromLoc       NVARCHAR( 10),
   @cFromID        NVARCHAR( 18),
   @cUCC           NVARCHAR( 20),
   @cUCC1          NVARCHAR( 20),
   @cUCC2          NVARCHAR( 20),
   @cUCC3          NVARCHAR( 20),
   @cUCC4          NVARCHAR( 20),
   @cUCC5          NVARCHAR( 20),
   @cUCC6          NVARCHAR( 20),
   @cUCC7          NVARCHAR( 20),
   @cUCC8          NVARCHAR( 20),
   @cUCC9          NVARCHAR( 20),
   @nErrNo         INT           OUTPUT, 
   @cErrMsg        NVARCHAR( 20) OUTPUT
)  
AS  
BEGIN
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  

   DECLARE 
      @cFacility        NVARCHAR(5),
      @nRowCount        INT,
      @nLoopIndex       INT,
      @nOutput          INT,
      @cConditions      NVARCHAR(MAX),
      @cSQL             NVARCHAR(MAX),
      @cSQLParam        NVARCHAR(MAX),
      @cConditionDetail NVARCHAR(30)

   SELECT @cFacility = Facility
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile



   DECLARE @tConditions TABLE 
   ( 
      RowIndex INT IDENTITY(1,1), 
      Condition NVARCHAR(30) 
   )
  
   IF @nFunc = 514  
   BEGIN  
      IF @nStep = 2 -- ToLOC
      BEGIN
         DECLARE 
            @cMaxCartonCheck        NVARCHAR(5),
            @cCheckCommingleSKU     NVARCHAR(5),
            @nMaxCarton             INT,
            @nMaxSKU                INT,
            @nLocCaronQty           INT,
            @nScannedUCCQty         INT,
            @nLocSKUQty             INT,
            @nScannedSKUQty         INT

         SELECT 
            @nScannedUCCQty = COUNT(DISTINCT UCC.UCCNo),
            @nScannedSKUQty = COUNT(DISTINCT UCC.SKU)
         FROM dbo.UCC WITH (NOLOCK)
         INNER JOIN rdt.rdtMoveUCCLog MU WITH (NOLOCK) ON (MU.UCCNo = UCC.UCCNo AND MU.StorerKey = @cStorerKey )
         WHERE UCC.StorerKey = @cStorerKey
            AND MU.AddWho = SUSER_SNAME()

         INSERT INTO @tConditions (Condition)
         SELECT Code
         FROM dbo.CODELKUP WITH (NOLOCK)
         WHERE LISTNAME = '514LocCHK'
            AND StorerKey = @cStorerKey
            AND Code <> ''

         SELECT @nRowCount = @@ROWCOUNT
         SET @nOutput = 0

         IF @nRowCount > 0
         BEGIN
            SET @cSQL = 'SELECT @nOutput = IIF(@cToLoc LIKE @cConditionDetail, 1, 0)'
            SET @cSQLParam = '@cToLoc NVARCHAR(30), @cConditionDetail NVARCHAR(30), @nOutput INT OUTPUT'

            SET @nLoopIndex = -1
            WHILE 1 = 1
            BEGIN
               SELECT TOP 1
                  @nLoopIndex = RowIndex,
                  @cConditionDetail  = Condition
               FROM @tConditions
               WHERE RowIndex > @nLoopIndex
               ORDER BY RowIndex

               SELECT @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0
                  BREAK
               
               SET @nOutput = 0
               EXEC sp_executesql @cSQL, @cSQLParam, @cToLoc, @cConditionDetail, @nOutput OUTPUT

               IF ISNULL(@nOutput, 0) = 1
                  BREAK
            END
         END

         IF @nOutput <> 1
            GOTO Quit

         SET @cMaxCartonCheck = rdt.rdtGetConfig( @nFunc, 'MaxCartonCheck', @cStorerKey)
         IF @cMaxCartonCheck = '0'
            SET @cMaxCartonCheck = ''

         IF @cMaxCartonCheck = '1'
         BEGIN
            IF EXISTS ( SELECT 1 FROM dbo.LOC WITH (NOLOCK)
                        WHERE LOC = @cToLOC
                           AND Facility = @cFacility
                           AND LoseUCC = '0')
            BEGIN
               SELECT @nMaxCarton = MaxCarton
               FROM dbo.LOC WITH(NOLOCK)
               WHERE Facility = @cFacility
                  AND Loc = @cToLoc

               IF @nMaxCarton > 0
               BEGIN
                  SELECT @nLocCaronQty = COUNT(DISTINCT UCCNO ) 
                  FROM dbo.LOTXLOCXID LLI WITH(NOLOCK)
                  INNER JOIN dbo.UCC WITH(NOLOCK) ON LLI.StorerKey = UCC.StorerKey AND LLI.Loc = UCC.Loc AND LLI.ID = UCC.ID
                  WHERE UCC.StorerKey = @cStorerKey
                     AND LLI.QTY - LLI.QTYPicked > 0
                     AND UCC.Status IN ('1', '3', '4', '5')
                     AND LLI.Loc = @cToLoc

                  SELECT @nLocCaronQty = @nLocCaronQty + COUNT(DISTINCT UCC.UCCNo)
                  FROM dbo.UCC WITH(NOLOCK)
                  INNER JOIN dbo.RFPUTAWAY RP WITH(NOLOCK) ON UCC.StorerKey = RP.StorerKey AND UCC.UCCNo = RP.CaseID
                  WHERE UCC.StorerKey = @cStorerKey
                     AND RP.SuggestedLoc = @cToLoc
                     AND UCC.Loc <> @cToLoc
                     AND UCC.Status IN ('1', '3', '4', '5')

                  IF @nMaxCarton < @nScannedUCCQty + @nLocCaronQty
                  BEGIN
                     SET @nErrNo = 247251
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Exceed max carton for location
                     GOTO Quit
                  END
               END
            END
         END
      END
   END  
  
Quit:  

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXEC ON RDT.rdt_514ExtVal11 TO NSQL
GO