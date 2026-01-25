SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
/************************************************************************/
/* Store procedure: rdt_1812DecodeSP05                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Decode UCC No                                               */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author      Purposes                                */
/* 2025-12-01  1.1  PSJ036      UWP-47565 Validate Task is UOM6 and quit*/
/************************************************************************/
    
CREATE OR ALTER     PROCEDURE [RDT].[rdt_1812DecodeSP05]
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
    
   DECLARE @nUCCQty     INT = 0    
   DECLARE @nTaksQty    INT = 0    
   DECLARE @nRowCnt     INT = 0    
   DECLARE @cTempUCC    NVARCHAR( MAX) = ''    
    
   SET @nErrNo = 0    
   SET @cErrMsg = 0    
    
   -- PSJ036 Start. - Need to configure the Barcode Configuration on SCE
   IF EXISTS (SELECT 1
     FROM  dbo.TASKDETAIL WITH (NOLOCK)
     WHERE TaskDetailKey = @cTaskdetailKey
      AND [Status] = '3'
      AND [UOM] = '6')
   BEGIN
     GOTO Quit
   END
   --PSJ036 END
   
   EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
      @cUCCNo  = @cTempUCC    OUTPUT,
      @nErrNo  = @nErrNo      OUTPUT,
      @cErrMsg = @cErrMsg     OUTPUT,
      @cType   = 'UCCNO'

   IF @nErrNo <> 0
      GOTO Quit
    
   SELECT @nUCCQty = ISNULL( SUM( Qty), 0)
   FROM dbo.UCC WITH (NOLOCK)
   WHERE Storerkey = @cStorerKey
      AND UCCNo = @cTempUCC
      AND [Status] >= '1'
      AND [Status] < '6'

   IF @nUCCQty = 0
   BEGIN    
      SET @nErrNo = 257101
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid UCCNo
      GOTO Quit
   END
    
   SELECT
      @cSKU = SKU,
      @nTaksQTY = ISNULL( SUM( Qty), 0)
   FROM dbo.TASKDETAIL WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskdetailKey
      AND CaseID = @cTempUCC   -- Not support swap ucc
      AND [Status] = '3'
   GROUP BY SKU
   SET @nRowCnt = @@ROWCOUNT

   IF @nRowCnt = 0
   BEGIN
      SET @nErrNo = 257102
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid UCCNo
      GOTO Quit
   END

   IF ISNULL( @cSKU, '') = ''
   BEGIN
      SET @nErrNo = 257103
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Sku
      GOTO Quit
   END

   IF @nUCCQty <> @nTaksQTY
   BEGIN
      SET @nErrNo = 257104
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Qty
      GOTO Quit
   END

   SET @cUCC = @cTempUCC
   SET @nQTY = @nTaksQTY

   Quit:
      RETURN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1812DecodeSP05 TO NSQL
GO

