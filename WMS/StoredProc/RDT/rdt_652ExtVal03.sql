IF EXISTS (SELECT name FROM sysobjects WHERE name = 'rdt_652ExtVal03' AND type = 'P')
   DROP PROC rdt.rdt_652ExtVal03
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_652ExtVal03                                        */
/* Copyright      : Maersk                                                 */
/* Customer       : Cajamar                                                */
/*                                                                         */
/* Date        Rev  Author       Purposes                                  */
/* 2025-11-17  1.0  Jackc        FCR-8974 Created                          */
/***************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_652ExtVal03(
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cStorerKey          NVARCHAR( 15),
   @cFacility           NVARCHAR( 5),
   @cContainerNo        NVARCHAR( 20),
   @cAppointmentNo      NVARCHAR( 20), --ReceiptKey
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

   DECLARE @tASN TABLE
   (
      ID          INT IDENTITY,
      ReceiptKey  NVARCHAR(10) NOT NULL
   )
   
   DECLARE @nMobrecScn  INT

   IF @nFunc = 652
   BEGIN
      SELECT @nMobrecScn = Scn
      FROM rdt.RDTMobRec WITH (NOLOCK)
      WHERE Mobile = @nMobile

      IF @nStep = 99 AND @nMobrecScn = 6704
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF ISNULL(@cAppointmentNo, '') <> '' AND ISNULL (@cContainerNo, '') <> ''
            BEGIN
               SET @nErrNo = 251201
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Only input 1
               GOTO Quit
            END

            IF ISNULL (@cContainerNo, '') <> ''
            BEGIN
               IF NOT EXISTS (SELECT 1 FROM dbo.Receipt WITH (NOLOCK)
                           WHERE StorerKey = @cStorerKey
                              AND ContainerKey = @cContainerNo
               )
               BEGIN
                  SET @nErrNo = 251202
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid container
                  GOTO Quit
               END
            END

            IF ISNULL (@cAppointmentNo, '') <> ''
            BEGIN
               IF NOT EXISTS (SELECT 1 FROM dbo.Receipt WITH (NOLOCK)
                           WHERE StorerKey = @cStorerKey
                              AND ReceiptKey = @cAppointmentNo
               )
               BEGIN
                  SET @nErrNo = 251203
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid container
                  GOTO Quit
               END
            END
            
         END --enter
      END --st2
   END--652

Quit:


GO

GRANT EXECUTE ON rdt.rdt_652ExtVal03 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
