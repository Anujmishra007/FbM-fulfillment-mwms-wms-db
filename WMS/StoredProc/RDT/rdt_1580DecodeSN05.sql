SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1580DecodeSN05                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Decode serial no                                            */
/*                                                                      */
/* Date        Rev  Author       Purposes                               */
/* 2026-07-22  1.0  Navitha      UWP-63241                              */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1580DecodeSN05]
   @nMobile     INT,
   @nFunc       INT,
   @cLangCode   NVARCHAR( 3),
   @nStep       INT,
   @nInputKey   INT,
   @cStorerKey  NVARCHAR( 15),
   @cFacility   NVARCHAR( 5),
   @cSKU        NVARCHAR( 20),
   @cBarcode    NVARCHAR( MAX),
   @cSerialNo   NVARCHAR( 30)  OUTPUT,
   @nSerialQTY  INT            OUTPUT,
   @nBulkSNO    INT            OUTPUT,
   @nErrNo      INT            OUTPUT,
   @cErrMsg     NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF LEFT(@cBarcode, 1) = 'S'
      SET @cSerialNo = SUBSTRING(@cBarcode, 2, LEN(@cBarcode) - 1)
   ELSE
   BEGIN
      SET @nErrNo = 277051
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --277051^InvalidSerialN
      GOTO Quit
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON  [RDT].[rdt_1580DecodeSN05] TO [NSQL]
GO
