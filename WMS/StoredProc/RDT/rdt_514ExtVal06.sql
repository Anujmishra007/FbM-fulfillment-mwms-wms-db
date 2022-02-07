IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[RDT].[rdt_514ExtVal06]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_514ExtVal06]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_514ExtVal06                                           */
/* Copyright      : LF Logistics                                              */
/*                                                                            */
/* Purpose: UA custom move check                                              */
/*                                                                            */
/* Date        Rev  Author   Purposes                                         */
/* 26-03-2020  1.0  Ung      WMS-12637 Created                                */
/******************************************************************************/

CREATE PROC rdt.rdt_514ExtVal06 (
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
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @tUCC TABLE 
   (
      UCCNo NVARCHAR( 20) NOT NULL PRIMARY KEY CLUSTERED
   )

   IF @nFunc = 514 -- Move by UCC
   BEGIN
      IF @nStep = 2 -- To Loc/To ID
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cUCC1 <> '' INSERT INTO @tUCC (UCCNo) VALUES (@cUCC1)
            IF @cUCC2 <> '' INSERT INTO @tUCC (UCCNo) VALUES (@cUCC2)
            IF @cUCC3 <> '' INSERT INTO @tUCC (UCCNo) VALUES (@cUCC3)
            IF @cUCC4 <> '' INSERT INTO @tUCC (UCCNo) VALUES (@cUCC4)
            IF @cUCC5 <> '' INSERT INTO @tUCC (UCCNo) VALUES (@cUCC5)
            IF @cUCC6 <> '' INSERT INTO @tUCC (UCCNo) VALUES (@cUCC6)
            IF @cUCC7 <> '' INSERT INTO @tUCC (UCCNo) VALUES (@cUCC7)
            IF @cUCC8 <> '' INSERT INTO @tUCC (UCCNo) VALUES (@cUCC8)
            IF @cUCC9 <> '' INSERT INTO @tUCC (UCCNo) VALUES (@cUCC9)

            DECLARE @curUCC CURSOR
            SET @curUCC = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
               SELECT DISTINCT UCC.LOC
               FROM UCC WITH (NOLOCK)
                  JOIN @tUCC T ON (T.UCCNo = UCC.UCCNo)
               WHERE UCC.StorerKey = @cStorerKey
            OPEN @curUCC
            FETCH NEXT FROM @curUCC INTO @cFromLOC
            WHILE @@FETCH_STATUS = 0
            BEGIN
               EXEC rdt.rdt_UAMoveCheck @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, ''
                  ,@cFromLOC 
                  ,@cToLOC 
                  ,'M' -- Type
                  ,''  -- SwapLOT
                  ,''  -- ChkQuality
                  ,@nErrNo  OUTPUT
                  ,@cErrMsg OUTPUT
               
               IF @nErrNo <> 0
                  GOTO Quit
               
               FETCH NEXT FROM @curUCC INTO @cFromLOC
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
GRANT EXEC ON RDT.rdt_514ExtVal06 TO NSQL
GO

