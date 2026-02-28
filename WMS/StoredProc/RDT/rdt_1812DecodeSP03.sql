

/************************************************************************/
/* Store procedure: rdt_1812DecodeSP03                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: For JCB                                                     */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev    Author      Purposes                              */
/* 2025-06-10  1.0.0  Jackc       FCR-3959 Created                      */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1812DecodeSP03
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cTaskdetailKey NVARCHAR( 10),
   @cBarcode       NVARCHAR( MAX),
   @cFromID        NVARCHAR( 18)  OUTPUT,
   @cSKU           NVARCHAR( 20)  OUTPUT,
   @nQTY           INT            OUTPUT,
   @cUCC           NVARCHAR( 20)  OUTPUT,
   @cDropID        NVARCHAR( 20)  OUTPUT,
   @nErrNo         INT            OUTPUT,
   @cErrMsg        NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE @nUCCQty     INT = 0
   DECLARE @nTaksQty    INT = 0
   DECLARE @nRowCnt     INT = 0
   DECLARE @cTempUCC    NVARCHAR( MAX) = ''
   DECLARE @cTDCaseID   NVARCHAR( 20)

   SET @nErrNo = 0
   SET @cErrMsg = 0

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1812DecodeSP03', @cBarcode AS Barcode
   --
   IF @nFunc = 1812
   BEGIN
      IF @nStep = 4 --SKU/Qty
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Step4, SKU/QTY screen'

         IF EXISTS (
            SELECT 1
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskdetailKey
               AND SKU = @cBarcode
         )
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'SKU Scanned', @cBarcode AS SKU, @cTaskdetailKey AS TaskKey
            --If SKU is scanned, then do nothing
            SET @nQTY = 0
            GOTO Quit
         END
         ELSE -- not scan SKU
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Not scan SKU'

            IF LEN(@cBarcode) > 20
            BEGIN
               SET @nErrNo = 239701
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid CaseID
               GOTO Quit
            END

            SELECT
               @cSKU = SKU,
               @nTaksQTY = ISNULL( SUM( Qty), 0),
               @cTDCaseID = MAX(Caseid)
            FROM dbo.TASKDETAIL WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskdetailKey
            AND   CaseID = @cBarcode   -- Not support swap ucc
            AND   [Status] = '3'
            GROUP BY SKU

            SET @nRowCnt = @@ROWCOUNT

            IF @nRowCnt = 0
            BEGIN
               SET @nErrNo = 239702
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid CaseID
               GOTO Quit
            END

            IF ISNULL( @cSKU, '') = ''
            BEGIN
               SET @nErrNo = 223653
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Missing SKU
               GOTO Quit
            END

            IF @nTaksQty = 0
            BEGIN
               SET @nErrNo = 223654
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Task Qty = 0
               GOTO Quit
            END

            SET @nQTY = @nTaksQTY

            GOTO Quit
         END--not scan sku
      END -- st4
   END --1812
END

Quit:
   IF @nDebugFlag = 1
      SELECT 'rdt_1812DecodeSP03 Quit', @cSKU AS SKU, @nQty AS Qty
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1812DecodeSP03 TO NSQL
GO
