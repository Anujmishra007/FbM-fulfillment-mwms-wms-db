SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1768ExtCfm05                                    */
/* Copyright      : MAERSK                                              */
/*                                                                      */
/* Purpose: Comfirm CC Task. Decode lottable01. Offset qty from same    */
/*          loc + sku.                                                  */
/*                                                                      */
/* Called from: rdtfnc_TM_CycleCount_SKU                                */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2025-07-07  1.0  James    FCR-6059. Created                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1768ExtCfm05] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cStorerKey      NVARCHAR( 15),
   @cTaskDetailKey  NVARCHAR( 10),
   @cCCKey          NVARCHAR( 10),
   @cCCDetailKey    NVARCHAR( 10),
   @cPickMethod     NVARCHAR( 10),
   @cLoc            NVARCHAR( 10),
   @cID             NVARCHAR( 18),
   @cSKU            NVARCHAR( 20),
   @nQTY            INT,
   @cLottable01     NVARCHAR( 18),
   @cLottable02     NVARCHAR( 18),
   @cLottable03     NVARCHAR( 18),
   @dLottable04     DATETIME,
   @dLottable05     DATETIME,
   @cLottable06     NVARCHAR( 30),
   @cLottable07     NVARCHAR( 30),
   @cLottable08     NVARCHAR( 30),
   @cLottable09     NVARCHAR( 30),
   @cLottable10     NVARCHAR( 30),
   @cLottable11     NVARCHAR( 30),
   @cLottable12     NVARCHAR( 30),
   @dLottable13     DATETIME,
   @dLottable14     DATETIME,
   @dLottable15     DATETIME,
   @nErrNo          INT            OUTPUT,
   @cErrMsg         NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_success             INT
         , @n_err                 INT
         , @c_errmsg              NVARCHAR(250)
         , @nTranCount            INT
         , @bDebug                INT
         , @nSystemQty            INT
         , @nCCQty                INT
         , @cCCSheetNo            NVARCHAR(10)
         , @cNewCCDetailKey       NVARCHAR(10)
         , @nCountedQty           INT
         , @nTotalQty             INT
         , @nTotalRecord          INT
         , @nCounter              INT
         , @cLot                  NVARCHAR(10)
         , @dNewLottable05        DATETIME
         , @cUserName             NVARCHAR(18)    --KY01
         , @cFacility             NVARCHAR( 5)
         , @nTMCCQty              INT
         , @cErrMsg1              NVARCHAR(20)
         , @cInField12            NVARCHAR(60)
         , @curConfirmCC          CURSOR
         , @nCCDetailExitFlag     INT = 0

   SET @nTotalRecord = 0
   SET @bDebug = 0
   SET @nCounter = 1
   SET @cLot = ''
   SET @nTMCCQty = @nQTY

   SET @nTranCount = @@TRANCOUNT

   IF @dLottable04 = 0     SET @dLottable04 = NULL
   IF @dLottable05 = 0     SET @dLottable05 = NULL

   -- Truncate the time portion
   IF @dLottable04 IS NOT NULL
      SET @dLottable04 = CONVERT( DATETIME, CONVERT( NVARCHAR( 10), @dLottable04, 120), 120)
   IF @dLottable05 IS NOT NULL
      SET @dLottable05 = CONVERT( DATETIME, CONVERT( NVARCHAR( 10), @dLottable05, 120), 120)

   SET @dNewLottable05 = CONVERT( DATETIME, CONVERT( NVARCHAR( 10), GETDATE(), 120), 120)

   SELECT @cUserName = UserName,
          @cFacility = Facility,
          @cInField12 = I_Field12
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   BEGIN TRAN
   SAVE TRAN rdt_1768ExtCfm05

   IF EXISTS ( SELECT 1 FROM dbo.CCDetail WITH (NOLOCK)
               WHERE CCKey    = @cCCKey
               AND StorerKey  = @cStorerKey
               AND Loc        = @cLoc
               AND ID         = @cID
               AND SKU        = @cSKU
               AND CCSheetNo  = @cTaskDetailKey)  
   BEGIN
         SET @nCCDetailExitFlag = 1
         SET @curConfirmCC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT CCD.CCDetailKey, CCD.SystemQty, CCD.Qty, CCD.Lot
         FROM dbo.CCDetail CCD WITH (NOLOCK)
         JOIN dbo.LOTxLOCxID LLI WITH (NOLOCK) ON ( CCD.Lot = LLI.Lot AND CCD.Loc = LLI.Loc AND CCD.Id = LLI.Id)
         JOIN dbo.LOC LOC WITH (NOLOCK) ON ( LLI.Loc = LOC.Loc)
         WHERE CCD.CCKey = @cCCKey
         AND   CCD.[Status] = '0'
         AND   CCD.SKU = @cSKU
         AND   CCD.StorerKEy = @cStorerKey
         AND   CCD.Loc = @cLoc
         AND   CCD.ID = @cID
         AND   CCD.CCSheetNo = @cTaskDetailKey
         AND   LLI.StorerKey = @cStorerKey
         AND   LOC.Facility = @cFacility
         ORDER BY 
             CASE 
                 WHEN LLI.QtyAllocated > 0 THEN 0 
                 ELSE 1 
             END,                         -- Prioritize rows with AllocQty > 0
             CASE 
                 WHEN LLI.QtyAllocated > 0 THEN LLI.QtyAllocated 
                 ELSE NULL 
             END,                         -- Then sort by AllocQty if > 0
             LLI.Lot,                     -- Then always sort by Lot
             CCD.CCDetailKey
   END
   ELSE
   BEGIN
      -- Add New CCDetail
      GOTO STEP_ADD_CCDETAIL
   END

   OPEN @curConfirmCC
   FETCH NEXT FROM @curConfirmCC INTO @cCCDetailKEy, @nSystemQty, @nCCQty, @cLot
   WHILE @@FETCH_STATUS <> -1
   BEGIN
      IF @nQTY = 0
      BEGIN
         UPDATE dbo.CCDetail SET
            Qty = 0,
            Status = CASE WHEN Status = '4' THEN Status ELSE '2' END,
            EditWho = @cUserName,
            EditDate = GETDATE()
         WHERE CCDetailKey   = @cCCDetailKEy

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 241451
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'Upd CCDetFail'
            GOTO RollBackTran
         END
      END
      ELSE
      IF @nSystemQty = ( @nCCQty + @nQTY)
      BEGIN
         UPDATE dbo.CCDetail SET
            Qty = SystemQty,
            Status = CASE WHEN Status = '4' THEN Status ELSE '2' END,
            EditWho = @cUserName,
            EditDate = GETDATE()
         WHERE CCDetailKey   = @cCCDetailKEy

        IF @@ERROR <> 0
        BEGIN
           SET @nErrNo = 241452
           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'Upd CCDetFail'
           GOTO RollBackTran
        END

        SET @nQTY = 0
      END
      ELSE IF @nSystemQty < ( @nCCQty + @nQTY)
      BEGIN
         UPDATE dbo.CCDetail SET
            Qty = @nSystemQty, --Qty + @nQTY,
            Status = CASE WHEN Status = '4' THEN Status ELSE '2' END,
            EditWho = @cUserName,
            EditDate = GETDATE()
         WHERE CCDetailKey   = @cCCDetailKEy

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 241453
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'Upd CCDetFail'
            GOTO RollBackTran
         END

         SET @nQTY = @nQTY - @nSystemQty + @nCCQty
      END
      ELSE IF @nSystemQty > ( @nCCQty + @nQTY)
      BEGIN
         UPDATE dbo.CCDetail SET
            Qty = Qty + @nQTY,
            Status = CASE WHEN Status = '4' THEN Status ELSE '2' END,
            EditWho = @cUserName,
            EditDate = GETDATE()
         WHERE CCDetailKey   = @cCCDetailKEy

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 241454
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'Upd CCDetFail'
            GOTO RollBackTran
         END

         SET @nQTY = 0
      END

      FETCH NEXT FROM @curConfirmCC INTO @cCCDetailKEy, @nSystemQty, @nCCQty, @cLot
   END
   CLOSE @curConfirmCC
   DEALLOCATE @curConfirmCC

   STEP_ADD_CCDETAIL:
   IF @nQTY > 0
   BEGIN
      SET @nErrNo = 0
      EXECUTE nspg_getkey
          'CCDetailKey'
          , 10
          , @cNewCCDetailKey OUTPUT
          , @b_success OUTPUT
          , @nErrNo OUTPUT
          , @cErrMsg OUTPUT

      IF @nErrNo <> 0
      BEGIN
         SET @nErrNo = 241455
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'GetKey Fail'
         GOTO RollBackTran
      END

      --Add CCDetail for Additional qty
      IF @nCCDetailExitFlag = 1
      BEGIN
         INSERT INTO dbo.CCDetail (
                  CCKey, CCDetailKey, StorerKey, Sku, Lot, Loc, Id, Qty, CCSheetNo, 
                  Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
                  SystemQty, RefNo, Status)
         SELECT CCKey, @cNewCCDetailKey, StorerKey, Sku, Lot, Loc, Id, @nQTY + Qty, CCSheetNo, 
                  Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
                  SystemQty, RefNo, '4'
         FROM dbo.CCDetail CCD WITH (NOLOCK)
         WHERE CCDetailKey = @cCCDetailKEy

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 241456
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'InsCCDetFail'
            GOTO RollBackTran
         END
      END
      ELSE
      BEGIN
         INSERT INTO dbo.CCDetail (
                  CCKey, CCDetailKey, StorerKey, Sku, Lot, Loc, Id, Qty, CCSheetNo, 
                  Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
                  SystemQty, RefNo, Status)
         VALUES ( @cCCKey, @cNewCCDetailKey, @cStorerKey, @cSKU, '', @cLoc, @cID, @nQTY, @cTaskDetailKey, 
                  '', '', '', NULL, NULL, 
                  0, '', '4' )
         
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 241460
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'InsCCDetFail'
            GOTO RollBackTran
         END
      END

      

      SET @nQTY = 0
   END

   -- EventLog - QTY
   EXEC RDT.rdt_STD_EventLog
         @cActionType   = '8', -- Cycle Count
         @cUserID       = @cUserName,
         @nMobileNo     = @nMobile,
         @nFunctionID   = @nFunc,
         @cFacility     = @cFacility,
         @cStorerKey    = @cStorerKey,
         @cLocation     = @cLoc,
         @cToLocation   = '',
         @cID           = @cID,
         @cToID         = '',
         @cSKU          = @cSKU,
         @nQTY          = @nTMCCQty,
         @cRefNo1       = @cCCKey,
         @cRefNo2       = @cTaskDetailKey,
         @cRefNo3       = '',
         @cRefNo4       = ''

   IF @cPickMethod = 'SKU'
   BEGIN
      UPDATE dbo.SKU WITH (ROWLOCK) SET
         LastCycleCount = GETDATE()
      WHERE StorerKey = @cStorerKey
      AND SKU = @cSKU

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 241457
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'Upd CCDateFail'
         GOTO RollBackTran
      END
   END
   ELSE IF @cPickMethod = 'LOC'
   BEGIN
      UPDATE dbo.LOC WITH (ROWLOCK) SET
         LastCycleCount = GETDATE()
      WHERE Loc = @cLoc

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 241458
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'Upd CCDateFail'
         GOTO RollBackTran
      END

       -- count by loc update sku.lastcyclecount too
      UPDATE dbo.SKU WITH (ROWLOCK) SET
         LastCycleCount = GETDATE()
      WHERE StorerKey = @cStorerKey
      AND SKU = @cSKU

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 241459
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'Upd CCDateFail'
         GOTO RollBackTran
      END
   END

   GOTO QUIT

   RollBackTran:
      ROLLBACK TRAN rdt_1768ExtCfm05

   Quit:
   WHILE @@TRANCOUNT>@nTranCount -- Commit until the level we started
      COMMIT TRAN rdt_1768ExtCfm05
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON  [RDT].[rdt_1768ExtCfm05] TO [NSQL]
GO
