SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: rdt_1767ExtCfm01                                    */
/* Copyright      : MAERSK                                              */
/*                                                                      */
/* Purpose: Comfirm UCC count                                           */
/*                                                                      */
/* Called from: rdtfnc_TM_CycleCount_UCC                                */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2025-07-07 1.0  James    FCR-6060. Created                           */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1767ExtCfm01] (
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
   @cUCC            NVARCHAR( 20),
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
   @tExtCfmSP       VARIABLETABLE READONLY,
   @nErrNo          INT            OUTPUT,
   @cErrMsg         NVARCHAR( 20)  OUTPUT
 )
AS
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
          , @cCCSheetNo            NVARCHAR(10)
          , @cNewCCDetailKey       NVARCHAR(10)
          , @cWdLottable01         NVARCHAR( 18)
          , @cWdLottable02         NVARCHAR( 18)
          , @cWdLottable03         NVARCHAR( 18)
          , @dWdLottable04         DATETIME
          , @dWdLottable05         DATETIME
          , @cWdLoc                NVARCHAR( 10)
          , @cWdId                 NVARCHAR( 18)
          , @cWdLot                NVARCHAR( 10)

   DECLARE @curCfmUCC      CURSOR
   DECLARE @cUserName      NVARCHAR( 18)

   SET @bDebug = 0

   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_1767ExtCfm01

   SELECT @cUserName = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @dLottable04 = 0     SET @dLottable04 = NULL
   IF @dLottable05 = 0     SET @dLottable05 = NULL

   -- Truncate the time portion
   IF @dLottable04 IS NOT NULL
      SET @dLottable04 = rdt.rdtconverttodate(@dLottable04)
   IF @dLottable05 IS NOT NULL
      SET @dLottable05 = rdt.rdtconverttodate(@dLottable05)

   IF EXISTS (SELECT 1 FROM dbo.CCDetail WITH (NOLOCK)
              WHERE CCSheetNo = @cTaskDetailKey
              AND   Storerkey = @cStorerKey
              AND   RefNo = @cUCC
              AND   [Status] = '0'
              AND   Loc = @cLoc
              AND   ID = @cID)
   BEGIN
      SET @curCfmUCC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT CCDetailKey, CCSheetNo, SystemQty
      FROM dbo.CCDetail WITH (NOLOCK)
      WHERE CCSheetNo = @cTaskDetailKey
      AND   Storerkey = @cStorerKey
      AND   RefNo = @cUCC
      AND   [Status] = '0'
      AND   Loc = @cLoc
      AND   ID = @cID
      OPEN @curCfmUCC
      FETCH NEXT FROM @curCfmUCC INTO @cCCDetailKey, @cCCSheetNo, @nSystemQty
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- FOR UCC Split CCDetail When Receive Different UCC
         IF @nSystemQty = @nQty
         BEGIN
            UPDATE dbo.CCDetail SET
               RefNo = @cUCC,
               Qty  = @nQty,
               [Status] = '2',
               EditWho = @cUserName,
               EditDate = GETDATE()
            WHERE CCDetailKey  = @cCCDetailKey

            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 241701
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'UpdCCDetFail'
               GOTO RollBackTran
            END

            SET @nQty = 0
         END
         ELSE IF @nSystemQty > @nQty
         BEGIN
            EXECUTE nspg_getkey
               'CCDetailKey'
               , 10
               , @cNewCCDetailKey OUTPUT
               , @b_success OUTPUT
               , @nErrNo OUTPUT
               , @cErrMsg OUTPUT

            INSERT INTO dbo.CCDetail (
                     CCKey, CCDetailKey, StorerKey, Sku, Lot, Loc, Id, Qty, CCSheetNo, 
                     Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
                     SystemQty, RefNo, STATUS, AddWho, AddDate)
            SELECT CCKey, @cNewCCDetailKey, @cStorerKey, @cSKU, Lot, @cLoc, @cID, 0, CCSheetNo, 
                   @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, 
                   SystemQty - @nQty, '', '0', @cUserName, GETDATE()
            FROM dbo.CCDetail WITH (NOLOCK)
            WHERE CCDetailKey  = @cCCDetailKey

            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 241702
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'InsCCDetFail'
               GOTO RollBackTran
            END

            UPDATE dbo.CCDetail SET
               RefNo = @cUCC,
               Qty  = @nQty,
               [Status] = '2',
               SystemQty = @nQty,
               EditWho = @cUserName,
               EditDate = GETDATE()
            WHERE CCDetailKey  = @cCCDetailKey

            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 241703
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'UpdCCDetFail'
               GOTO RollBackTran
            END

            SET @nQTy = 0
         END
         ELSE IF @nSystemQty  < @nQty
         BEGIN
            UPDATE dbo.CCDetail SET
               RefNo = @cUCC,
               Qty  = SystemQty,
               [Status] = '2',
               EditWho = @cUserName,
               EditDate = GETDATE()
            WHERE CCDetailKey  = @cCCDetailKey

            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 241704
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'UpdCCDetFail'
               GOTO RollBackTran
            END

            SET @nQTy = @nQty - @nSystemQty
         END

         IF @nQty = 0
            BREAK

         FETCH NEXT FROM @curCfmUCC INTO @cCCDetailKey, @cCCSheetNo, @nSystemQty

      END
      CLOSE @curCfmUCC
      DEALLOCATE @curCfmUCC
    END

    --IF  There is still remaining of @nQty
    --Create New CCTask to Store this Qty
   IF @nQty > 0
   BEGIN
      EXECUTE nspg_getkey
         'CCDetailKey'
         , 10
         , @cNewCCDetailKey OUTPUT
         , @b_success OUTPUT
         , @nErrNo OUTPUT
         , @cErrMsg OUTPUT

      IF @nErrNo <> 0
      BEGIN
         SET @nErrNo = 241705
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'GetKey Fail'
         GOTO RollBackTran
      END

      INSERT INTO dbo.CCDetail (
         CCKey, CCDetailKey, CCSheetNo, StorerKey, Sku, Lot, Loc, Id, SystemQty, Qty, [Status], RefNo,
         Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, AddWho, AddDate)
      VALUES (@cCCKey, @cNewCCDetailKey, @cTaskDetailKey, @cStorerKey, @cSKU, '', @cLoc, @cID, 0, @nQty , '4', @cUCC,
         @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, @cUserName, GETDATE())

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 241706
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'InsCCDetFail'
         GOTO RollBackTran
      END
   END

   IF @cPickMethod = 'SKU'
   BEGIN
      UPDATE dbo.SKU SET
         LastCycleCount = GETDATE(),
         EditWho = @cUserName,
         EditDate = GETDATE()
      WHERE StorerKey = @cStorerKey
      AND   SKU = @cSKU

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 241707
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'UpdSKUFail'
         GOTO RollBackTran
      END
   END
   ELSE IF @cPickMethod = 'LOC'
   BEGIN
      UPDATE dbo.LOC SET
         LastCycleCount = GETDATE(),
         EditWho = @cUserName,
         EditDate = GETDATE()
       WHERE Loc = @cLoc

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 241708
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'UpdLocFail'
         GOTO RollBackTran
      END

       -- count by loc update sku.lastcyclecount too (james02)
      UPDATE dbo.SKU SET
         LastCycleCount = GETDATE(),
         EditWho = @cUserName,
         EditDate = GETDATE()
      WHERE StorerKey = @cStorerKey
      AND SKU = @cSKU

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 241709
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'UpdSKUFail'
         GOTO RollBackTran
      END
    END
    GOTO Quit

    -- If ucc exists in another loc then create a ccdetail with 0 qty
    -- to let system withdraw it from the that loc
    IF EXISTS ( SELECT 1
                FROM dbo.UCC WITH (NOLOCK)
                WHERE Storerkey = @cStorerKey
                AND   UCCNo = @cUCC
                AND   Loc <> @cLOC)
    BEGIN
       SELECT
         @cWdLot = Lot,
         @cWdLoc = Loc,
         @cWdId = Id
       FROM dbo.UCC WITH (NOLOCK)
       WHERE Storerkey = @cStorerKey
       AND   UCCNo = @cUCC

       SELECT
         @cWdLottable01 = Lottable01,
         @cWdLottable02 = Lottable02,
         @cWdLottable03 = Lottable03,
         @dWdLottable04 = Lottable04,
         @dWdLottable05 = Lottable05
       FROM dbo.LOTATTRIBUTE WITH (NOLOCK)
       WHERE Lot = @cWdLot

       EXECUTE nspg_getkey
          'CCDetailKey'
          , 10
          , @cNewCCDetailKey OUTPUT
          , @b_success OUTPUT
          , @nErrNo OUTPUT
          , @cErrMsg OUTPUT

      IF @nErrNo <> 0
      BEGIN
         SET @nErrNo = 241710
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'GetKey Fail'
         GOTO RollBackTran
      END

      INSERT INTO dbo.CCDetail (
         CCKey, CCDetailKey, CCSheetNo, StorerKey, Sku, Lot, Loc, Id, SystemQty, Qty, [Status], RefNo,
         Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, AddWho, AddDate)
      VALUES (@cCCKey, @cNewCCDetailKey, @cTaskDetailKey, @cStorerKey, @cSKU, @cWdLot, @cWdLoc, @cWdId, 0, 0 , '4', @cUCC,
         @cWdLottable01, @cWdLottable02, @cWdLottable03, @dWdLottable04, @dWdLottable05, @cUserName, GETDATE())

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 241711
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'InsCCDetFail'
         GOTO RollBackTran
      END
   END

   RollBackTran:
     ROLLBACK TRAN rdt_1767ExtCfm01

   Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN rdt_1767ExtCfm01
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON  [RDT].[rdt_1767ExtCfm01] TO [NSQL]
GO