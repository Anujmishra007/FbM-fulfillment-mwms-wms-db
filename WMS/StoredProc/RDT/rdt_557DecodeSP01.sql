SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************/
/* Store procedure: rdt_557DecodeSP01                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose:                                                                   */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-06-30  Dennis    1.0.0 FCR-3400 Created                               */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_557DecodeSP01] (
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cFacility           NVARCHAR( 5),
   @cStorerKey          NVARCHAR( 15),
   @cBarcode            NVARCHAR( 60),
   @cID                 NVARCHAR( 18)  OUTPUT,
   @cUCC                NVARCHAR( 20) OUTPUT,
   @nErrNo              INT            OUTPUT,
   @cErrMsg             NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLocalUCC AS NVARCHAR(20)
   DECLARE @cInField01 NVARCHAR( 60)

   SELECT    
      @cInField01 = I_Field01
   FROM rdt.rdtMobRec (NOLOCK)
   WHERE Mobile = @nMobile


   IF @nFunc = 557
   BEGIN
      IF @nStep IN (1,3)
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SET @cBarcode = @cInField01
            IF @cBarcode <> '' --Barcode
            BEGIN
               IF LEN( LTRIM(RTRIM( @cBarcode))) < 20
               BEGIN
                  SET @nErrNo = 226801
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               SET @cUCC = RIGHT(@cBarcode,20)
               GOTO Quit
            END
         END
      END
   END

   Quit:

END
GO

GRANT EXECUTE ON [rdt].[rdt_557DecodeSP01] TO NSQL
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO