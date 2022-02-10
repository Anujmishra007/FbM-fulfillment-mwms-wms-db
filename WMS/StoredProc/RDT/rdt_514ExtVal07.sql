IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[RDT].[rdt_514ExtVal07]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_514ExtVal07]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_514ExtVal07                                           */
/* Copyright      : LF Logistics                                              */
/*                                                                            */
/* Purpose: UA custom move check                                              */
/*                                                                            */
/* Date        Rev  Author   Purposes                                         */
/* 2021-06-24  1.0  James    WMS-17322 Created                                */
/******************************************************************************/

CREATE PROC rdt.rdt_514ExtVal07 (
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

   DECLARE @nChkUCC_Qty    INT
   
   DECLARE @tUCC TABLE 
   (
      UCCNo NVARCHAR( 20) NOT NULL PRIMARY KEY CLUSTERED,
      Qty   INT NOT NULL
   )

   IF @nFunc = 514 -- Move by UCC
   BEGIN
      IF @nStep = 2 -- To Loc/To ID
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cUCC1 <> ''
               INSERT INTO @tUCC (UCCNo, Qty) 
               SELECT UCCNo, ISNULL( SUM( qty), 0) FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cUCC1 AND Storerkey = @cStorerKey GROUP BY UCCNo

            IF @cUCC2 <> ''
               INSERT INTO @tUCC (UCCNo, Qty) 
               SELECT UCCNo, ISNULL( SUM( qty), 0) FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cUCC2 AND Storerkey = @cStorerKey GROUP BY UCCNo
            
            IF @cUCC3 <> ''
               INSERT INTO @tUCC (UCCNo, Qty) 
               SELECT UCCNo, ISNULL( SUM( qty), 0) FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cUCC3 AND Storerkey = @cStorerKey GROUP BY UCCNo

            IF @cUCC4 <> ''
               INSERT INTO @tUCC (UCCNo, Qty) 
               SELECT UCCNo, ISNULL( SUM( qty), 0) FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cUCC4 AND Storerkey = @cStorerKey GROUP BY UCCNo

            IF @cUCC5 <> ''
               INSERT INTO @tUCC (UCCNo, Qty) 
               SELECT UCCNo, ISNULL( SUM( qty), 0) FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cUCC5 AND Storerkey = @cStorerKey GROUP BY UCCNo

            IF @cUCC6 <> ''
               INSERT INTO @tUCC (UCCNo, Qty) 
               SELECT UCCNo, ISNULL( SUM( qty), 0) FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cUCC6 AND Storerkey = @cStorerKey GROUP BY UCCNo
            
            IF @cUCC7 <> ''
               INSERT INTO @tUCC (UCCNo, Qty) 
               SELECT UCCNo, ISNULL( SUM( qty), 0) FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cUCC7 AND Storerkey = @cStorerKey GROUP BY UCCNo
            
            IF @cUCC8 <> ''
               INSERT INTO @tUCC (UCCNo, Qty) 
               SELECT UCCNo, ISNULL( SUM( qty), 0) FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cUCC8 AND Storerkey = @cStorerKey GROUP BY UCCNo
            
            IF @cUCC9 <> ''
               INSERT INTO @tUCC (UCCNo, Qty) 
               SELECT UCCNo, ISNULL( SUM( qty), 0) FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cUCC9 AND Storerkey = @cStorerKey GROUP BY UCCNo

            SELECT TOP 1 @nChkUCC_Qty = Qty FROM @tUCC
            
            IF @@ROWCOUNT = 0
               GOTO Quit
                              
            IF EXISTS ( SELECT 1 FROM @tUCC WHERE Qty <> @nChkUCC_Qty)
            BEGIN
               SET @nErrNo = 169501
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Qty not match'
               GOTO Quit
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
GRANT EXEC ON RDT.rdt_514ExtVal07 TO NSQL
GO

