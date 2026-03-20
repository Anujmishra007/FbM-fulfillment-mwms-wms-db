SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: rdt.rdt_855ExtUpd23                                 */
/* Copyright      : Maersk                                              */
/* Purpose        : FCR-10831 Update RDTPPA.Lottable01 on PPA           */
/*                  Parse Lottable01 from ExtendedInfo (O_Field15)      */
/*                  Format: "LOT01:<lottable01_value>"                  */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2026-03-20 1.0.0  NYE018   FCR-10831 Created                         */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_855ExtUpd23] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cStorerKey     NVARCHAR( 15),
   @cRefNo         NVARCHAR( 10),
   @cPickSlipNo    NVARCHAR( 10),
   @cLoadKey       NVARCHAR( 10),
   @cOrderKey      NVARCHAR( 10),
   @cDropID        NVARCHAR( 20),
   @cSKU           NVARCHAR( 20),
   @nQty           INT,
   @cOption        NVARCHAR( 1),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT,
   @cID            NVARCHAR( 18) = '',
   @cTaskDetailKey NVARCHAR( 10) = '',
   @cReasonCode    NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cExtendedInfo   NVARCHAR(20),
      @cLottable01     NVARCHAR(18),
      @nRowRef         INT

   -- Initialize output parameters
   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF @nFunc = 855 -- PPA by DropID
   BEGIN
      -- Step 3 - After entering quantity on SKU screen
      IF @nStep = 3 AND @nInputKey = 1 -- ENTER
      BEGIN
         -- Get ExtendedInfo (O_Field15) from rdtMobRec
         -- Format: "LOT01:<lottable01_value>"
         SELECT @cExtendedInfo = O_Field15
         FROM RDT.RDTMobRec WITH (NOLOCK)
         WHERE Mobile = @nMobile

         -- Remove "LOT01:" prefix to get the actual value
         IF @cExtendedInfo LIKE 'LOT01:%'
         BEGIN
            SET @cLottable01 = LTRIM(RTRIM(SUBSTRING(@cExtendedInfo, 7, LEN(@cExtendedInfo) - 6)))
         END

         -- Validate we have Lottable01
         IF ISNULL(@cLottable01, '') = ''
            GOTO Quit

         -- Find the most recent RDTPPA record for this DropID + SKU (just inserted by main SP)
         SELECT TOP 1 @nRowRef = RowRef
         FROM RDT.RDTPPA WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND DropID = @cDropID
            AND SKU = @cSKU
         ORDER BY RowRef DESC

         -- Update RDTPPA with Lottable01
         IF @nRowRef IS NOT NULL
         BEGIN
            BEGIN TRY
               UPDATE RDT.RDTPPA WITH (ROWLOCK)
               SET Lottable01 = @cLottable01
               WHERE RowRef = @nRowRef
            END TRY
            BEGIN CATCH
               GOTO Quit
            END CATCH
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
GRANT EXECUTE ON [RDT].[rdt_855ExtUpd23] TO nSQL
GO
