SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_803ExtValid04                                   */
/* Copyright      : Maersk                                              */
/* Customer       : AEOMX                                               */
/* Purpose        : PTW/PTL Extended Validation - Force unassign        */
/*                  Block Option 9 (No) on unassign screen, require     */
/*                  Option 1 (Yes) to properly clear user color         */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2026-08-17  1.0  Cuize       UWP-63852 Created                       */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_803ExtValid04] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR(3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR(5),
   @cStorerKey   NVARCHAR(15),
   @cStation     NVARCHAR(10),
   @cMethod      NVARCHAR(1),
   @cSKU         NVARCHAR(20),
   @cLastPos     NVARCHAR(10),
   @cOption      NVARCHAR(1),
   @tExtValid    VariableTable READONLY,
   @nErrNo       INT OUTPUT,
   @cErrMsg      NVARCHAR(20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @nErrNo = 0
   SET @cErrMsg = ''

   -- UWP-63852: Force mandatory unassign
   -- Block Option 9 (No) on the "Unassign Station?" screen (Step 4)
   -- User must select Option 1 (Yes) to properly clear their color assignment
   IF @nStep = 4
   BEGIN
      IF @cOption = '9'
      BEGIN
         SET @nErrNo = 278501
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Must Unassign
         GOTO Quit
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_803ExtValid04 TO NSQL
GO
