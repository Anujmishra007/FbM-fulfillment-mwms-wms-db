
/************************************************************************/
/* Store procedure: rdt_1641ExtUpdSP_WAG                      */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Called from: rdtfnc_Pallet_Build (ExtendedUpdateSP config)           */
/*                                                                      */
/* Purpose: Update PickDetail.ID and LotxLocxId.ID to master pallet ID  */
/*          (DropID) to enable Scan to Door (Fn1650) validation against */
/*          PICKDETAIL.ID with STATUS < '9' and maintain inventory      */
/*          consistency with LotxLocxId.                                 */
/*                                                                      */
/*          Scanned UCC = PackDetail.DropId/LabelNo                      */
/*          Resolves via PackDetail -> PackHeader -> PickDetail          */
/*                                                                      */
/*          Uses rdt.rdt_Move for LotxLocxId updates to leverage        */
/*          built-in split/merge logic, qty validation, and ITRN        */
/*          audit trail.                                                 */
/*                                                                      */
/* Required StorerConfig:                                                */
/*   ExtendedUpdateSP      = rdt_1641ExtUpdSP_WAG              */
/*   MoveQtyPick           = 1                                          */
/*   MoveQtyAlloc          = 1                                          */
/*   DefaultLoc            = <staging location>                         */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2026-05-18  1.0  JACKR   Created - PickDetail.ID + rdt_Move for      */
/*                           LotxLocxId update. Fn1650 compatibility.    */
/*                           UCC = PackDetail.LabelNo resolution path.   */
/************************************************************************/
CREATE OR ALTER   PROC [RDT].[rdt_1641ExtUpdSP_WAG] (
    @nMobile     INT
   ,@nFunc       INT
   ,@cLangCode   NVARCHAR(3)
   ,@cUserName   NVARCHAR(15)
   ,@cFacility   NVARCHAR(5)
   ,@cStorerKey  NVARCHAR(15)
   ,@cDropID     NVARCHAR(20)
   ,@cUCCNo      NVARCHAR(20)
   ,@nErrNo      INT OUTPUT
   ,@cErrMsg     NVARCHAR(20) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE @nStep        INT
           ,@nInputKey    INT
           ,@nTranCount   INT
           ,@nRowCount    INT
           ,@cLoc         NVARCHAR(10)
           ,@cLot         NVARCHAR(10)
           ,@cSKU         NVARCHAR(20)
           ,@cID          NVARCHAR(20)
           ,@cOrderKey    NVARCHAR(20)
           ,@nQty         DECIMAL(22,5)
           ,@cDefaultLoc  NVARCHAR(10)

    -- Get current step from mobile record
    SELECT @nStep     = Step
          ,@nInputKey = InputKey
    FROM   rdt.RDTMobRec WITH (NOLOCK)
    WHERE  Mobile = @nMobile

    -- Get DefaultLoc from StorerConfig (staging/pallet build location)
	SET @cDefaultLoc = rdt.RDTGetConfig( @nFunc, 'DefaultLoc', @cStorerKey)

    SET @nTranCount = @@TRANCOUNT
    SET @nErrNo = 0
    SET @cErrMsg = ''

    BEGIN TRAN
    SAVE TRAN rdt_1641ExtUpdSP__WAG

    --------------------------------------------------------------------------
    -- STEP 3: UCC Scan (InputKey 1)
    -- UCC scanned = PackDetail.LabelNo/PackDetail.DropId
    -- 1. Call rdt.rdt_Move to move inventory from current ID to master pallet
    -- 2. Update PickDetail.ID = master pallet ID
    --------------------------------------------------------------------------
    IF @nStep = 3
    BEGIN
        IF @nInputKey = 1
        BEGIN
            ------------------------------------------------------------------
            -- Validate: scanned UCC exists in PackDetail
            ------------------------------------------------------------------
            IF NOT EXISTS (
                SELECT 1
                FROM   dbo.PackDetail PKD WITH (NOLOCK)
                WHERE  PKD.DropId   = @cUCCNo
                  AND  PKD.StorerKey  = @cStorerKey
            )
            BEGIN
                SET @nErrNo  = 258276
                SET @cErrMsg = 'Invalid UCC'
                GOTO RollBackTran
            END

            ------------------------------------------------------------------
            -- 1. LotxLocxId update via rdt.rdt_Move
            --    Move from current ID/Loc to master pallet ID/DefaultLoc
            ------------------------------------------------------------------
            BEGIN TRY
                DECLARE curMove CURSOR LOCAL FAST_FORWARD FOR
                    SELECT PD.Loc
                          ,PD.Lot
                          ,PD.SKU
                          ,PD.[ID]
                          ,PD.Qty
                          ,PD.OrderKey
                    FROM   dbo.PICKDETAIL PD WITH (NOLOCK)
                    WHERE PD.StorerKey = @cStorerKey
                      AND PD.[Status]  < '9'
                      AND PD.[ID]     <> @cDropID  -- Skip if already on master pallet
					  AND PD.DropId = @cUCCNo

                OPEN curMove
                FETCH NEXT FROM curMove INTO @cLoc, @cLot, @cSKU, @cID, @nQty, @cOrderKey
				IF @cDefaultLoc = '0' --Default pallet build location not set in storerconfig
                    --No move required sop current location, just update PickDetail.ID to master pallet ID
                    SET @cDefaultLoc = @cLoc
                WHILE @@FETCH_STATUS = 0
                BEGIN
                    SET @nErrNo  = 0
                    SET @cErrMsg = ''

                    -- rdt_Move: current ID/Loc -> master pallet ID/DefaultLoc
                    EXEC rdt.rdt_Move
                         @nMobile       = @nMobile
                        ,@cLangCode     = @cLangCode
                        ,@nErrNo        = @nErrNo OUTPUT
                        ,@cErrMsg       = @cErrMsg OUTPUT
                        ,@cSourceType   = 'rdt_1641ExtUpdSP_WAG'
                        ,@cStorerKey    = @cStorerKey
                        ,@cFacility     = @cFacility
                        ,@cFromLOC      = @cLoc
                        ,@cToLOC        = @cDefaultLoc
                        ,@cFromID       = @cID
                        ,@cToID         = @cDropID
                        ,@cSKU          = @cSKU
                        ,@cFROMLot      = @cLot
                        ,@nFunc         = @nFunc
                        ,@nQty          = @nQty
                        ,@nQTYPick      = @nQty
                        ,@cOrderKey     = @cOrderKey

                    -- Check if rdt_Move failed
                    IF @nErrNo <> 0
                    BEGIN
                        CLOSE curMove
                        DEALLOCATE curMove
                        GOTO RollBackTran
                    END
                    FETCH NEXT FROM curMove INTO @cLoc, @cLot, @cSKU, @cID, @nQty, @cOrderKey
                END

                CLOSE curMove
                DEALLOCATE curMove

            END TRY
            BEGIN CATCH
                IF CURSOR_STATUS('local', 'curMove') >= 0
                BEGIN
                    CLOSE curMove
                    DEALLOCATE curMove
                END
                SET @nErrNo  = 258272
                SET @cErrMsg = 'Upd LLI.ID Fail'
                GOTO RollBackTran
            END CATCH

            ------------------------------------------------------------------
            -- 2. Update PickDetail.ID = master pallet ID
            --    Enables Fn1650: EXISTS in PICKDETAIL.ID AND STATUS < '9'
            ------------------------------------------------------------------
            BEGIN TRY
                UPDATE PD
                SET    PD.[ID] = @cDropID
                FROM   dbo.PICKDETAIL PD WITH (ROWLOCK)
                WHERE PD.StorerKey = @cStorerKey
                  AND PD.[Status]  < '9'
				  AND PD.DropID = @cUCCNo
            END TRY
            BEGIN CATCH
                SET @nErrNo  = 258270
                SET @cErrMsg = 'Upd PD.ID Fail'
                GOTO RollBackTran
            END CATCH
        END
    END

    --------------------------------------------------------------------------
    -- STEP 4: Close Pallet (Option 1)
    -- Close the DropID record to indicate pallet is complete
    --------------------------------------------------------------------------
    IF @nStep = 4
    BEGIN
        IF @nInputKey = 1
        BEGIN
            DECLARE @cOption NVARCHAR(1)

            SELECT @cOption = I_Field01
            FROM   rdt.RDTMobRec WITH (NOLOCK)
            WHERE  Mobile = @nMobile

            IF @cOption = '1'
            BEGIN
                BEGIN TRY
                    UPDATE dbo.DROPID
                    WITH  (ROWLOCK)
                    SET   [Status] = '9'
                    WHERE DropID = @cDropID
                END TRY
                BEGIN CATCH
                    SET @nErrNo  = 258271
                    SET @cErrMsg = 'Upd DROPIDFail'
                    GOTO RollBackTran
                END CATCH
            END
        END
    END

    GOTO Quit

    RollBackTran:
        ROLLBACK TRAN rdt_1641ExtUpdSP__WAG

    Quit:
        WHILE @@TRANCOUNT > @nTranCount
            COMMIT TRAN rdt_1641ExtUpdSP__WAG
END

GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
GRANT EXECUTE ON RDT.rdt_1641ExtUpdSP_WAG TO NSQL
GO
