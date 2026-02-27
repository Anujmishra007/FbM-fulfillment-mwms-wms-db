
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_838ExtSNVal04                                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date        Rev  Author       Purposes                                     */
/* 11-06-2025  1.0  yeekung      FCR-3145 base on rdt_838ExtSNVal             */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_838ExtSNVal04
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 3),
   @cStorerKey       NVARCHAR( 15),
   @cSKU             NVARCHAR( 20),
   @nQTY             INT, 
   @cSerialNo        NVARCHAR( 30),
   @cType            NVARCHAR( 15), --CHECK/INSERT
   @cDocType         NVARCHAR( 10), 
   @cDocNo           NVARCHAR( 20), 
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nRowCount  INT
   DECLARE @cChkStatus NVARCHAR(10)
   DECLARE @cChkExternStatus NVARCHAR(10)

   IF @nFunc = 838 -- Pack
   BEGIN
      -- Check SNO already scanned
      IF EXISTS( SELECT 1 
         FROM PackSerialNo WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            -- AND SKU = @cSKU
            AND SerialNo = @cSerialNo)
      BEGIN
         SET @nErrNo = 240051
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO ady scan
         GOTO Quit
      END
   END

Quit:

END

GO

GRANT EXECUTE ON rdt.rdt_838ExtSNVal04 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
