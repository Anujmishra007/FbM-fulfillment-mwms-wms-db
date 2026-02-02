
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************************************/
/* Store procedure: rdt_922ExtUpd07                                                                */
/* Copyright      : Maersk                                                                         */
/*                                                                                                 */
/*                                                                                                 */
/* Date       Rev  Author     Purposes                                                             */
/* 2025-08-06 1.0  Dennis     FCR-6434  Created                                                    */
/***************************************************************************************************/

CREATE OR ALTER PROC rdt.rdt_922ExtUpd07 (
   @nMobile     INT,
   @nFunc       INT,
   @cLangCode   NVARCHAR( 3),
   @nStep       INT,
   @nInputKey   INT,
   @cStorerKey  NVARCHAR( 15),
   @cType       NVARCHAR( 1),
   @cMBOLKey    NVARCHAR( 10),
   @cLoadKey    NVARCHAR( 10),
   @cOrderKey   NVARCHAR( 10),
   @cLabelNo    NVARCHAR( 20),
   @cPackInfo   NVARCHAR( 3),
   @cWeight     NVARCHAR( 10),
   @cCube       NVARCHAR( 10),
   @cCartonType NVARCHAR( 10),
   @cDoor       NVARCHAR( 10),
   @cRefNo      NVARCHAR( 40),
   @nErrNo      INT           OUTPUT,
   @cErrMsg     NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nRowCount INT = 0,
   @cDropID NVARCHAR(20) = ''

   DECLARE @nTranCount  INT
   SET @nTranCount = @@TRANCOUNT
   -- Handling transaction
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_922ExtUpd07 -- For rollback or commit only our own transaction

   IF @nFunc = 922 -- Scan to truck (by label no)
   BEGIN
      IF @nStep = 2 -- LabelNo/DropID
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN

            SELECT TOP 1 @cDropID = DropID FROM dbo.DROPIDDETAIL
            WHERE Childid = @cLabelNo

            SELECT @nRowCount = @@ROWCOUNT
            IF @nRowCount <> 0 -- No record found
            BEGIN
               DELETE FROM dbo.DROPIDDETAIL
               WHERE Childid = @cLabelNo

               IF NOT EXISTS (SELECT 1 FROM dbo.DROPIDDETAIL WHERE DropID = @cDropID)
               BEGIN
                  DELETE FROM dbo.DROPID
                  WHERE DropID = @cDropID
               END
            END
         END
      END
   END
   COMMIT TRAN rdt_922ExtUpd07 -- Commit our own transaction
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_922ExtUpd07 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_922ExtUpd07 TO NSQL
GO