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
      @nRowRef         INT,
      @cUserName       NVARCHAR(128),
      @cDescr          NVARCHAR(60),
      @nPQty           INT

   -- Initialize output parameters
   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF @nFunc = 855 -- PPA by DropID
   BEGIN
      -- Step 3 - After entering quantity on SKU screen
      IF @nStep = 3 AND @nInputKey = 1 -- ENTER
      BEGIN
         -- Get ExtendedInfo (O_Field15) and UserName from rdtMobRec
         -- Format: "LOT01:<lottable01_value>"
         SELECT @cExtendedInfo = O_Field15,
                @cUserName = UserName
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

         -- Check if record exists for this StorerKey + DropID + SKU + Lottable01
         SELECT @nRowRef = RowRef
         FROM RDT.RDTPPA WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND DropID = @cDropID
            AND SKU = @cSKU
            AND Lottable01 = @cLottable01

         BEGIN TRY
            IF @nRowRef IS NOT NULL
            BEGIN
               -- Record exists: UPDATE CQty (add to existing count)
               -- This handles Scenario 3: partial count, come back later
               UPDATE RDT.RDTPPA WITH (ROWLOCK)
               SET CQty = ISNULL(CQty, 0) + @nQty,
                   NoOfCheck = ISNULL(NoOfCheck, 0) + 1,
                   EditDate = GETDATE(),
                   EditWho = SUSER_SNAME()
               WHERE RowRef = @nRowRef
            END
            ELSE
            BEGIN
               -- Get SKU description
               SELECT @cDescr = Descr
               FROM dbo.SKU WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND SKU = @cSKU

               -- Get expected PQty from LOTxLOCxID for this Lottable01
               SELECT @nPQty = SUM(LLI.Qty)
               FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
               INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
                  ON LLI.StorerKey = LA.StorerKey
                  AND LLI.SKU = LA.SKU
                  AND LLI.Lot = LA.Lot
               WHERE LLI.StorerKey = @cStorerKey
                  AND LLI.ID = @cDropID
                  AND LLI.SKU = @cSKU
                  AND LA.Lottable01 = @cLottable01

               -- Record does not exist: INSERT new record for this Lottable01
               INSERT INTO RDT.RDTPPA (
                  StorerKey,
                  SKU,
                  Descr,
                  DropID,
                  Lottable01,
                  PQty,
                  CQty,
                  NoOfCheck,
                  Status,
                  UserName,
                  AddDate,
                  EditDate,
                  EditWho
               )
               VALUES (
                  @cStorerKey,
                  @cSKU,
                  @cDescr,
                  @cDropID,
                  @cLottable01,
                  ISNULL(@nPQty, 0),  -- Expected qty from LOTxLOCxID
                  @nQty,               -- Counted qty
                  1,                   -- First check
                  '0',
                  @cUserName,
                  GETDATE(),
                  GETDATE(),
                  SUSER_SNAME()
               )
            END
         END TRY
         BEGIN CATCH
            SET @nErrNo = 262051
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 262051^UpdRDTPPAFail
            GOTO Quit
         END CATCH
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
