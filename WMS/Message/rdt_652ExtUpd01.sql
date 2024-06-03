IF EXISTS (SELECT name FROM sysobjects WHERE name = 'rdt_652ExtUpd01' AND type = 'P')
   DROP PROC rdt.rdt_652ExtUpd01
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_652ExtUpd01                                        */
/* Copyright      : Maersk                                                 */
/*                                                                         */
/* Date        Rev  Author       Purposes                                  */
/* 2024-05-27  1.0  Cuize        FCR-242 Created                           */
/***************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_652ExtUpd01(
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
BEGIN
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

            DECLARE @b_success   INT
            DECLARE @n_err       INT
            DECLARE @c_errmsg    NVARCHAR(250)

            EXEC dbo.ispGenTransmitLog2 'WSONLOTLOG', @cContainerNo, '', @cStorerKey, ''
               , @b_success OUTPUT
               , @n_err OUTPUT
               , @c_errmsg OUTPUT

            IF @n_err <> 0
            BEGIN
               SET @nErrNo = 215502
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSERT TransLog Fail
               GOTO Quit
            END

         END

      END

   END

   Quit:

END
GO

GRANT EXECUTE ON rdt.rdt_652ExtUpd01 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

