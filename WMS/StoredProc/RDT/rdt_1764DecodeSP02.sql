
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************************************/
/* Store procedure: rdt_1764DecodeSP02                                                             */
/* Copyright      : Maersk                                                                         */
/*                                                                                                 */
/* Modifications log:                                                                              */
/*                                                                                                 */
/* Date         Author    Ver.    Purposes                                                         */
/* 2025-06-13   Dennis    1.0.0   FCR-3959 Created                                                 */
/***************************************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1764DecodeSP02
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cTaskdetailKey NVARCHAR( 10),
   @cBarcode       NVARCHAR( 60),
   @cFromID        NVARCHAR( 18)  OUTPUT,
   @cSKU           NVARCHAR( 20)  OUTPUT,
   @nQTY           INT            OUTPUT,
   @cDropID        NVARCHAR( 20)  OUTPUT,
   @nErrNo         INT            OUTPUT,
   @cErrMsg        NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount INT,
   @cTempSKU NVARCHAR( 20),
   @nTempQTY INT

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nStep = 4 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT
               @cTempSKU = SKU,
               @nTempQTY = QTY
            FROM dbo.TaskDetail (NoLOCK)
            WHERE CaseID = @cBarcode
            AND TaskDetailKey = @cTaskdetailKey
            IF ISNULL(@cTempSKU,'') <> '' AND @nTempQTY > 0
            BEGIN
               SELECT @cSKU = @cTempSKU, @nQTY = @nTempQTY
            END
         END
      END
   END
   
   GOTO Quit

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764DecodeSP02 TO NSQL
GO