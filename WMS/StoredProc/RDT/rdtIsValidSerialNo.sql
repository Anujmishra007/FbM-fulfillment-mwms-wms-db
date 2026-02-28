SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdtIsValidSerialNo                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Validate common serial no data error                        */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2025-10-27 1.0  Ung      FCR-8307 base rdtIsValidUCC                 */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdtIsValidSerialNo] (
   @cLangCode  NVARCHAR( 3),
   @nErrNo     INT           OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT, 
   @cSerialNo  NVARCHAR( 30),   -- Compulsory
   @cStorerKey NVARCHAR( 15),   -- Compulsory
   @cStatus    NVARCHAR( 10),   -- Compulsory
   @cChkSKU    NVARCHAR( 20)    = NULL,
   @nChkQTY    INT              = NULL,
   @cChkLOT    NVARCHAR( 10)    = NULL,
   @cChkLOC    NVARCHAR( 10)    = NULL,
   @cChkID     NVARCHAR( 18)    = NULL
) AS
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nRowCount   INT
   DECLARE @cSNSKU     NVARCHAR( 20)
   DECLARE @cSNStatus  NVARCHAR( 1)
   DECLARE @cSNLOT     NVARCHAR( 10)
   DECLARE @cSNLOC     NVARCHAR( 10)
   DECLARE @cSNID      NVARCHAR( 18)
   DECLARE @nSNQTY     INT
   DECLARE @nCaseCnt    INT

   SET @nErrNo = 0

   -- Check parameter
   IF @cSerialNo = '' OR @cSerialNo IS NULL
   BEGIN
      SET @nErrNo = 62976
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SN needed
      GOTO Fail
   END
   IF @cStorerKey = '' OR @cStorerKey IS NULL
   BEGIN
      SET @nErrNo = 62977
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Storer needed
      GOTO Fail
   END
   IF @cStatus IS NULL
   BEGIN
      SET @nErrNo = 62978
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Status needed
      GOTO Fail
   END

   -- Get serial no
   SELECT
      @cSNSKU = SKU,
      @cSNStatus = Status,
      @cSNLOT = LOT,
      @cSNLOC = LOC,
      @cSNID = [ID],
      @nSNQTY = QTY
   FROM dbo.SerialNo WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND SerialNo = @cSerialNo

   SET @nRowCount = @@ROWCOUNT

   -- Validate serial no exist
   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 62979
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SN not exist
      GOTO Fail
   END

   IF @nRowCount > 1
   BEGIN
      -- Get SCE storer config
      DECLARE @cSerialNoUniqueAtStorerLevel NVARCHAR( 1) = '0' -- Default Off
      SELECT @cSerialNoUniqueAtStorerLevel = CASE WHEN SValue = '1' THEN '1' ELSE '0' END
      FROM dbo.StorerConfig (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND ConfigKey = 'SerialNoUniqueAtStorerLevel'
      
       -- Same serial no multi rec, different SKU
      IF @cSerialNoUniqueAtStorerLevel = '1'
      BEGIN
         IF @cChkSKU IS NULL
         BEGIN
            SET @nErrNo = 62980
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SN SKU needed
            GOTO Fail
         END
         
         -- Get serial no
         SELECT
            @cSNSKU = SKU,
            @cSNStatus = Status,
            @cSNLOT = LOT,
            @cSNLOC = LOC,
            @cSNID = [ID],
            @nSNQTY = QTY
         FROM dbo.SerialNo WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND SerialNo = @cSerialNo
            AND SKU = @cChkSKU

         SET @nRowCount = @@ROWCOUNT
         
         -- Validate serial no exist
         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 62981
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SN not exist
            GOTO Fail
         END
      END
      
      IF @nRowCount > 1
      BEGIN
         SET @nErrNo = 62982
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Multi SNO rec
         GOTO Fail
      END
   END

   -- Validate SKU
   IF (@cChkSKU IS NOT NULL) AND
      (@cSNSKU <> @cChkSKU)
   BEGIN
      SET @nErrNo = 62983
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SN SKU Diff
      GOTO Fail
   END

   -- Validate LOT
   IF (@cChkLOT IS NOT NULL) AND
      (@cSNLOT <> @cChkLOT)
   BEGIN
      SET @nErrNo = 62984
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SN LOT Diff
      GOTO Fail
   END

   -- Validate LOC
   IF (@cChkLOC IS NOT NULL) AND
      (@cSNLOC <> @cChkLOC)
   BEGIN
      SET @nErrNo = 62985
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SN LOC Diff
      GOTO Fail
   END

   -- Validate ID
   IF (@cChkID IS NOT NULL) AND
      (@cSNID <> @cChkID)
   BEGIN
      SET @nErrNo = 62986
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SN ID Diff
      GOTO Fail
   END

   -- Validate QTY
   IF (@nChkQTY IS NOT NULL) AND
      (@nSNQTY <> @nChkQTY)
   BEGIN
      BEGIN
         SET @nErrNo = 62987
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SN QTY Diff
         GOTO Fail
      END
   END
   
   -- Validate status
   IF CHARINDEX( @cSNStatus, @cStatus) = 0
   BEGIN
      SET @nErrNo = 62988
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SN Status Diff
      GOTO Fail
   END
      
Fail:

GO
GRANT EXECUTE ON  [RDT].[rdtIsValidSerialNo] TO [NSQL]
GO
