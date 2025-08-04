
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_957SwapUCC01                                          */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev    Author   Purposes                                        */
/* 2024-07-10 1.0    NLT013   FCR-7106 Created                                */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_957SwapUCC01] (
   @nMobile            INT,
   @nFunc              INT,
   @cLangCode          NVARCHAR( 3),
   @nStep              INT,
   @nInputKey          INT,
   @cFacility          NVARCHAR( 5),
   @cStorerKey         NVARCHAR( 15),
   @cPickSlipNo        NVARCHAR( 20),
   @cActUCCNo          NVARCHAR( 20),
   @cTaskUCCNo         NVARCHAR( 20)  OUTPUT,
   @nErrNo             INT            OUTPUT,
   @cErrMsg            NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cActPDKey      NVARCHAR( 10)
   DECLARE @cActOrderKey   NVARCHAR( 10)
   DECLARE @cActOrderLine  NVARCHAR( 10)
   DECLARE @cActUCCSKU     NVARCHAR( 20)
   DECLARE @cActUCCLOT     NVARCHAR( 10)
   DECLARE @cActUCCLOC     NVARCHAR( 10)
   DECLARE @cActUCCID      NVARCHAR( 18)
   DECLARE @cActUCCStatus  NVARCHAR( 1)
   DECLARE @nActUCCQTY     INT

   DECLARE @cTaskPDKey     NVARCHAR( 10)
   DECLARE @cTaskOrderKey  NVARCHAR( 10)
   DECLARE @cTaskOrderLine NVARCHAR( 10)
   DECLARE @cTaskSKU       NVARCHAR( 20)
   DECLARE @cTaskLOT       NVARCHAR( 10)
   DECLARE @cTaskLOC       NVARCHAR( 10)
   DECLARE @cTaskID        NVARCHAR( 18)
   DECLARE @nTaskQTY       INT

   SELECT
      @cTaskPDKey = PickDetailKey,
      @cTaskOrderKey = OrderKey,
      @cTaskOrderLine = OrderLineNumber,
      @cTaskLOT = LOT,
      @cTaskLOC = LOC,
      @cTaskID = ID,
      @cTaskSKU = SKU,
      @nTaskQTY = QTY
   FROM dbo.PickDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerkey
      AND DropID = @cTaskUCCNo
      AND Status = '0'
      AND QTY > 0

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 243301
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad PickTask
      GOTO Fail
   END

   -- Get scanned UCC info
   SELECT
      @cActUCCSKU = SKU,
      @nActUCCQTY = QTY,
      @cActUCCLOT = LOT,
      @cActUCCLOC = LOC,
      @cActUCCID = ID,
      @cActUCCStatus = Status
   FROM dbo.UCC WITH (NOLOCK)
   WHERE UCCNo = @cActUCCNo
      AND StorerKey = @cStorerkey

   IF @cActUCCStatus <> '1'
   BEGIN
      SET @nErrNo = 243302
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC is invalid
      GOTO Fail
   END
   
  -- 1. UCC to pick, swap UCC free
   -- Don't need to swap LOT
   IF @cTaskLOT = @cActUCCLOT AND @cTaskID = @cActUCCID
   BEGIN
      BEGIN TRY
         -- Update PickDetail
         UPDATE dbo.PickDetail SET
            DropID = @cActUCCNo,
            TrafficCop = NULL,
            EditDate = GETDATE(),
            EditWho = 'rdt.' + SUSER_SNAME()
         FROM dbo.PickDetail PD
         WHERE PickDetailKey = @cTaskPDKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 243303
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PickDetail Fail
         GOTO Fail
      END CATCH
   END
   ELSE
   BEGIN
      BEGIN TRY
         -- Unallocate
         UPDATE PickDetail SET
            QTY = 0,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE PickDetailKey = @cTaskPDKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 243304
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PickDetail Fail
         GOTO Fail
      END CATCH

      BEGIN TRY
         -- Reallocate
         UPDATE PickDetail SET
            LOT = @cActUCCLOT,
            DropID = @cActUCCNo,
            Id = @cActUCCID,
            QTY = @nActUCCQTY,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE PickDetailKey = @cTaskPDKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 243305
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PickDetail Fail
            GOTO Fail
         END CATCH
   END

   BEGIN TRY
      -- Actual
      UPDATE UCC WITH (ROWLOCK) SET
         Status = '3', -- 3=Allocated
         OrderKey = @cTaskOrderKey,
         OrderLineNumber = @cTaskOrderLine,
         PickDetailKey = @cTaskPDKey,
         EditDate = GETDATE(),
         EditWho = 'rdt.' + SUSER_SNAME()
      WHERE StorerKey = @cStorerkey
         AND UCCNo = @cActUCCNo
   END TRY
   BEGIN CATCH
      SET @nErrNo = 243306
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update UCC Fail
      GOTO Fail
   END CATCH

   BEGIN TRY
      -- Task
      UPDATE UCC WITH (ROWLOCK) SET
         Status = '1', -- 1=Received
         OrderKey = '',
         OrderLineNumber = '',
         PickDetailKey = '',
         EditDate = GETDATE(),
         EditWho = 'rdt.' + SUSER_SNAME()
      WHERE StorerKey = @cStorerkey
         AND UCCNo = @cTaskUCCNo
   END TRY
   BEGIN CATCH
      SET @nErrNo = 243307
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update UCC Fail
      GOTO Fail
   END CATCH
   GOTO Quit

   Fail:
   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_957SwapUCC01 TO NSQL
GO