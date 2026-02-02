
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_652ExtVal02                                        */
/* Copyright      : Maersk                                                 */
/*                                                                         */
/* Date        Rev  Author       Purposes                                  */
/* 2025-10-28  1.0  YeeKung      FCR-8146 Created                          */
/***************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_652ExtVal02(
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cStorerKey          NVARCHAR( 15),
   @cFacility           NVARCHAR( 5),
   @cContainerNo        NVARCHAR( 20),
   @cAppointmentNo      NVARCHAR( 20),
   @cMenuOption         NVARCHAR( 10),
   @cActionType         NVARCHAR( 10),
   @cRefNo1             NVARCHAR( 10),
   @cDefaultOption      NVARCHAR( 10),
   @cDefaultCursor      NVARCHAR( 10),
   @cActivityStatus     NVARCHAR( 20),
   @nErrNo              INT           OUTPUT,
   @cErrMsg             NVARCHAR( 20) OUTPUT
)
AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 652
   BEGIN

      IF @nStep = 2
      BEGIN

         IF @nInputKey = 1
         BEGIN
            -- Validate Appointment No
            IF ISNULL(@cAppointmentNo, '') <> ''
            BEGIN
               SET @nErrNo = 250151
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ApptNoRequired
               GOTO QUIT
            END
         END

      END

   END

Quit:


GO

GRANT EXECUTE ON rdt.rdt_652ExtVal02 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
