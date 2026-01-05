SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************/
/* Store procedure: rdt_514ExtVal12_BNT                                    */
/* Purpose: Move By UCC Extended Validate                                  */
/*                                                                         */
/* Called from: rdtfnc_Move_ID                                             */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date        Rev  Author     Purposes                                    */
/* 2025-12-24  1.0  ASC199    on pick loc UCC Move allow for same sku only */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_514ExtVal12_BNT]
(
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
   @nErrNo         INT OUTPUT, 
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cFacility   NVARCHAR(5)
   DECLARE @nSku        NVARCHAR(20)
   DECLARE @nmaxSku     NVARCHAR(20)
   DECLARE @nmaxqty     INT
   DECLARE @nmaxqtylimit INT
   DECLARE @nloc        NVARCHAR(10)

   SET @nErrNo = 0

   SELECT @cFacility = Facility
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF (@cUCC ='' OR @cUCC IS NULL)
   BEGIN
      SELECT @cUCC = V_String1
      FROM rdt.rdtMobRec WITH (NOLOCK)
      WHERE Mobile = @nMobile
   END

   IF @nFunc = 514
   BEGIN
      IF @nStep = 2
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF EXISTS (SELECT 1 
                       FROM dbo.loc WITH (NOLOCK)
                       WHERE LOC = @cToLOC
                         AND Facility = @cFacility
                         AND LocationType IN ('CASE', 'BULK'))
            BEGIN
               IF (@cToID = '')
               BEGIN
                  SET @nErrNo = 255701
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 255701^ID is blank
               END
            END
            ELSE IF EXISTS (SELECT 1 
                            FROM dbo.loc WITH (NOLOCK)
                            WHERE LOC = @cToLOC
                              AND Facility = @cFacility
                              AND LocationType = 'PICK')
            BEGIN
               SELECT @nSku = SKU 
               FROM dbo.skuxloc WITH (NOLOCK)
               WHERE LOC = @cToLOC
                 AND StorerKey = @cStorerKey
                 AND LocationType = ''
                 AND Qty > 0

               IF (@nSku <> '')
               BEGIN
                  SET @nErrNo = 255702
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 255702 Different SKU in PICK location
                  GOTO Quit
               END

               SELECT @nSku = SKU, 
                      @nmaxqtylimit = (QtyLocationLimit - Qty)
               FROM dbo.skuxloc WITH (NOLOCK)
               WHERE LOC = @cToLOC
                 AND StorerKey = @cStorerKey
                 AND LocationType = 'PICK'

               SELECT @nmaxSku = SKU, 
                      @nmaxqty = Qty
               FROM dbo.ucc WITH (NOLOCK)
               WHERE UCCNo = @cUCC
                 AND StorerKey = @cStorerKey

               IF (@nSku = @nmaxSku AND @nSku <> '' AND @nmaxqtylimit < @nmaxqty)
               BEGIN
                  SET @nErrNo = 255703
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 255703^Over UCC Qty
                  GOTO Quit
               END

               IF (@nSku <> @nmaxSku AND @nSku <> '')
               BEGIN
                  SET @nErrNo = 255704
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')-- 255704^Over Max SKU
                  GOTO Quit
               END
            END
         END
      END
   END

Quit:
END
GO
GRANT EXECUTE ON [RDT].[rdt_514ExtVal12_BNT] TO [NSQL]
GO

           
