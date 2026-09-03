
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_830ExtVal08                                     */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Date         Rev   Author   Purposes                                 */
/* 2026-09-01   1.0   PPA374   UWP-65638 Samsung (BnM) picking          */
/*                             validations                              */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_830ExtVal08] (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cPickSlipNo   NVARCHAR( 10),
   @cPickZone     NVARCHAR( 10),
   @cSuggLOC      NVARCHAR( 10),
   @cLOC          NVARCHAR( 10),
   @cDropID       NVARCHAR( 20),
   @cSKU          NVARCHAR( 20),
   @cLottable01   NVARCHAR( 18),
   @cLottable02   NVARCHAR( 18),
   @cLottable03   NVARCHAR( 18),
   @dLottable04   DATETIME,
   @dLottable05   DATETIME,
   @cLottable06   NVARCHAR( 30),
   @cLottable07   NVARCHAR( 30),
   @cLottable08   NVARCHAR( 30),
   @cLottable09   NVARCHAR( 30),
   @cLottable10   NVARCHAR( 30),
   @cLottable11   NVARCHAR( 30),
   @cLottable12   NVARCHAR( 30),
   @dLottable13   DATETIME,
   @dLottable14   DATETIME,
   @dLottable15   DATETIME,
   @nTaskQTY      INT,
   @nQTY          INT,
   @cToLOC        NVARCHAR( 10),
   @cOption       NVARCHAR( 1),
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @LocationType NVARCHAR( 20)
   SELECT TOP 1 @LocationType = LocationType
   FROM LOC WITH (NOLOCK)
   WHERE Facility = @cFacility
     AND Loc      = @cLOC

   IF @nFunc = 830
   BEGIN
      IF @nStep = 2 AND @nInputKey = 1
      BEGIN
         IF (SELECT TOP 1 ISNULL( I_Field05, '') FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile) <> ''
         BEGIN
            UPDATE rdt.RDTMOBREC
            SET C_String30 = I_Field05
            WHERE Mobile = @nMobile
         END

         IF RTRIM( LTRIM( @cDropID)) = ''
         BEGIN
            SET @nErrNo = 217931
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DropIDNeeded
            GOTO Quit
         END

         ELSE IF CHARINDEX(' ', @cDropID) > 0
            OR LEN( @cDropID) <> 18
            OR CONVERT( NVARCHAR( 30), SUBSTRING( @cDropID, 1, 3)) <> '050'
         BEGIN
            SET @nErrNo = 217932
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InvalidFormat
            GOTO Quit
         END

         ELSE IF (
               EXISTS (SELECT 1 FROM PICKDETAIL WITH (NOLOCK)
                       WHERE StorerKey = @cStorerKey
                         AND Status   <> '9'
                         AND DropID   = @cDropID)
            AND NOT EXISTS (SELECT 1 FROM PICKDETAIL WITH (NOLOCK)
                            WHERE StorerKey = @cStorerKey
                              AND OrderKey  = (SELECT TOP 1 OrderKey FROM PICKHEADER WITH (NOLOCK)
                                               WHERE PickHeaderKey = @cPickSlipNo)
                              AND DropID    = @cDropID)
            )
            OR EXISTS (SELECT 1 FROM PackDetail WITH (NOLOCK)
                       WHERE StorerKey = @cStorerKey
                         AND DropID   = @cDropID)
            OR EXISTS (SELECT 1 FROM DropID WITH (NOLOCK)
                       WHERE DropID   = @cDropID)
         BEGIN
            SET @nErrNo = 217933
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DropIDIsUsed
            GOTO Quit
         END
      END

      IF @nStep = 4 AND @nInputKey = 1
      BEGIN
         IF @nTaskQTY <> (SELECT TOP 1 I_Field15 FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile)
         -- AND @LocationType NOT IN ('PICK','CASE')
         BEGIN
            SET @nErrNo = 218000
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Confirm qty as shown
            GOTO Quit
         END
      END
   END
Quit:
END
GO
GRANT EXECUTE ON [RDT].[rdt_830ExtVal08] TO [NSQL]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
