SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_Inbound_PalletTempCapture_Confirm               */
/* Copyright      : Maersk                                              */
/* Customer       : BRITISH EGYPTIAN                                    */
/*                                                                      */
/* Purpose: Close working batch                                         */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 2024-12-06 1.0  NLT013      FCR-1398 Created                         */
/************************************************************************/

CREATE PROC rdt.rdt_Inbound_PalletTempCapture_Confirm (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cUserName        NVARCHAR( 18),
   @cFacility        NVARCHAR(5),
   @cStorerKey       NVARCHAR(15),
   @cReceiptKey      NVARCHAR(10),
   @cID              NVARCHAR(18),
   @fTemperature     DECIMAL(5,2),
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @cSQL      NVARCHAR( MAX)
   DECLARE @cSQLParam NVARCHAR( MAX)

   -- Get RDT storer configure
   DECLARE @cConfirmSP NVARCHAR(20)
   SET @cConfirmSP = rdt.RDTGetConfig( @nFunc, 'ConfirmSP', @cStorerKey)
   IF @cConfirmSP = '0'
      SET @cConfirmSP = ''

   /***********************************************************************************************
                                              Custom confirm
   ***********************************************************************************************/
   -- Check confirm SP blank
   IF @cConfirmSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cConfirmSP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cConfirmSP) +
            ' @nMobile, @nFunc, @cLangCode, @cUserName, @cFacility, @cStorerKey, ' +
            ' @cReceiptKey, @cID, @fTemperature, ' +
            ' @nErrNo OUTPUT, @cErrMsg OUTPUT '

         SET @cSQLParam =
            ' @nMobile       INT,           ' +
            ' @nFunc         INT,           ' +
            ' @cLangCode     NVARCHAR( 18), ' +
            ' @cUserName     NVARCHAR( 18), ' +
            ' @cFacility     NVARCHAR( 5),  ' +
            ' @cStorerKey    NVARCHAR( 15), ' +
            ' @cReceiptKey   NVARCHAR( 10), ' +
            ' @cID           NVARCHAR( 18), ' +
            ' @fTemperature  DECIMAL(5,2),  ' +
            ' @nErrNo        INT           OUTPUT, ' +
            ' @cErrMsg       NVARCHAR( 20) OUTPUT  '

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @cUserName, @cFacility, @cStorerKey,
            @cReceiptKey, @cID, @fTemperature,
            @nErrNo OUTPUT, @cErrMsg OUTPUT

         GOTO Quit
      END
   END

   /***********************************************************************************************
                                             Standard confirm
   ***********************************************************************************************/
   INSERT INTO [dbo].[TemperatureLog]
      (Facility, StorerKey, ReceiptKey, PalletID, Temperature, TempCheckPoint, CheckUser, EditDate, EditWho )
   VALUES
      (@cFacility, @cStorerKey, @cReceiptKey, @cID, @fTemperature, 'R', @cUserName, GETDATE(), @cUserName )

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_Inbound_PalletTempCapture_Confirm TO NSQL
GO
