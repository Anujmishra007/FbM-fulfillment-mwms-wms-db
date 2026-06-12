SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/  
/* Store procedure: rdt_1764SuggToLocAU                                       */  
/* Copyright      : LF Logistics                                              */  
/*                                                                            */  
/* Date        Rev  Author    Purposes                                        */  
/* 2025-06-12  1.0  SYC067    Created                                         */  
/******************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_1764SuggToLocAU] (  
   @nMobile            INT,  
   @nFunc              INT,  
   @cLangCode          NVARCHAR( 3),  
   @cUserName          NVARCHAR( 18),  
   @cTaskDetailKey     NVARCHAR( 10),  
   @cSuggToLOC         NVARCHAR( 10),  
   @cNewSuggToLOC      NVARCHAR( 10) OUTPUT,  
   @nErrNo             INT           OUTPUT,  
   @cErrMsg            NVARCHAR( 20) OUTPUT  
) AS  
BEGIN  
    SET NOCOUNT ON  
    SET QUOTED_IDENTIFIER OFF  
    SET ANSI_NULLS OFF  
    SET CONCAT_NULL_YIELDS_NULL OFF  
    
    DECLARE @cFacility      NVARCHAR( 5)  
    DECLARE @cStorerKey     NVARCHAR( 15)  
    DECLARE @cLocAisle      NVARCHAR( 10)  
    DECLARE @cToLoc         NVARCHAR( 10)  
    DECLARE @cFromLoc       NVARCHAR( 10)  
    DECLARE @cFromID        NVARCHAR( 18)  
    DECLARE @cToID          NVARCHAR( 18)  
    DECLARE @cFromLot       NVARCHAR( 10)  
    DECLARE @cSKU           NVARCHAR( 30)  
    DECLARE @cLocationType  NVARCHAR( 10)  
    DECLARE @cLocationCat   NVARCHAR( 10)  
    DECLARE @cLocBay        NVARCHAR( 10)  
    DECLARE @cTasktype      NVARCHAR( 10)  
    DECLARE @nQty           INT  
    DECLARE @bSuccess       INT = 1  
    
    SELECT @cStorerKey = StorerKey,  
            @cFacility = Facility  
    FROM RDT.RDTMOBREC WITH (NOLOCK)  
    WHERE Mobile = @nMobile 

    SET @cNewSuggToLOC = ''
    SET @nErrNo = 0
    SET @cErrMsg = '' 
    
    SELECT @cToLoc = ToLoc  
            , @cFromLoc = FromLoc  
            , @cFromID = FromID  
            , @cToID = ToID  
            , @cFromLot = Lot  
            , @cSKU = SKU  
            , @ctasktype = TASKTYPE  
            , @nQty = Qty  
    FROM dbo.TaskDetail WITH (NOLOCK)  
    WHERE TaskDetailKey = @cTaskDetailKey  
    
    SELECT @cLocAisle      = LOCAISLE  
         , @cLocationType  = LOCATIONTYPE  
         , @cLocationCat   = LOCATIONCATEGORY  
    FROM dbo.LOC WITH (NOLOCK)  
    WHERE Loc = @cToLoc  
    AND   Facility = @cFacility  
    
    IF EXISTS (  
        SELECT TOP 1 1 FROM dbo.LOTXLOCXID WITH (NOLOCK)  
        WHERE STORERKEY = @cStorerKey  
        AND QTY - QTYPICKED > 0  
        AND LOC = @cToLoc  
        AND LOT <> CASE WHEN @cLocationType <> 'PICK' THEN 'XXXX' ELSE @cFromLot END)  
    BEGIN  
        SELECT TOP 1 @cNewSuggToLOC = NEWLOC.LOC  
        FROM dbo.LOC NEWLOC WITH (NOLOCK)  
        OUTER APPLY (  
            SELECT TOP 1 LOC  
            FROM dbo.LOTXLOCXID WITH (NOLOCK)  
            WHERE LOC = NEWLOC.LOC  
            AND STORERKEY = @cStorerKey  
            AND QTY - QTYPICKED + PENDINGMOVEIN > 0  
        ) LLI  
        WHERE NEWLOC.Facility = @cFacility  
        AND ISNULL(LLI.LOC,'') = ''  
        AND NEWLOC.LOCATIONCATEGORY = @cLocationCat  
        AND NEWLOC.LOCATIONTYPE = @cLocationType  
        ORDER BY CASE WHEN NEWLOC.LOCAISLE = @cLocAisle THEN 1 ELSE 2 END  
                , NEWLOC.LOGICALLOCATION  
    END  
    ELSE  
    BEGIN  
        SET @cNewSuggToLOC = @cToLoc  
    END  
    
    IF ISNULL(@cNewSuggToLOC,'') <> @cToLoc
    BEGIN
        DECLARE @nTranCount INT = @@TRANCOUNT;
        BEGIN TRY
            IF @nTranCount = 0
                BEGIN TRAN;
            ELSE
                SAVE TRAN rdt_1764SuggToLocAU;

            UPDATE dbo.TASKDETAIL WITH (ROWLOCK)
            SET TOLOC = @cNewSuggToLOC--, LOGICALTOLOC = @cNewSuggToLOC
            WHERE TASKDETAILKEY = @cTaskDetailKey

            UPDATE dbo.RFPUTAWAY WITH (ROWLOCK)
            SET SUGGESTEDLOC = @cNewSuggToLOC
            WHERE TASKDETAILKEY = @cTaskDetailKey

            IF NOT EXISTS (SELECT 1 FROM dbo.LOTxLOCxID WITH (UPDLOCK, HOLDLOCK) WHERE LOT = @cFromLot AND LOC = @cNewSuggToLOC AND ID = @cToID)
                INSERT INTO dbo.LOTxLOCxID WITH (ROWLOCK)
                (Lot,Loc,ID,Storerkey,Sku)
                VALUES (@cFromLot, @cNewSuggToLOC, @cToID, @cStorerKey, @cSKU)

            -- Remove pending move-in for old location
            EXECUTE dbo.nspPendingMoveInUpdate
                    @c_storerkey    = ''
                    , @c_sku          = ''
                    , @c_lot          = ''
                    , @c_Loc          = @cToLoc
                    , @c_ID           = @cToID
                    , @c_fromloc      = @cFromLoc
                    , @c_fromid       = @cFromID
                    , @n_qty          = @nQty
                    , @c_action       = 'R'
                    , @b_Success      = @bSuccess OUTPUT
                    , @n_err          = @nErrNo OUTPUT
                    , @c_errmsg       = @cErrMsg OUTPUT
                    , @c_tasktype     = @cTasktype

            IF @bSuccess = 0
            BEGIN
                SET @nErrNo = 269251  -- 'cant suggest loc'
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                ;THROW 50001, 'PendingMoveIn Remove failed', 1;
            END

            -- Insert pending move-in for new location
            EXECUTE dbo.nspPendingMoveInUpdate
                    @c_storerkey    = ''
                    , @c_sku          = ''
                    , @c_lot          = ''
                    , @c_Loc          = @cNewSuggToLOC
                    , @c_ID           = @cToID
                    , @c_fromloc      = @cFromLoc
                    , @c_fromid       = @cFromID
                    , @n_qty          = @nQty
                    , @c_action       = 'I'
                    , @b_Success      = @bSuccess OUTPUT
                    , @n_err          = @nErrNo OUTPUT
                    , @c_errmsg       = @cErrMsg OUTPUT
                    , @c_tasktype     = @cTasktype

            IF @bSuccess = 0
            BEGIN
                SET @nErrNo = 269252  -- 'cant suggest loc'
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                ;THROW 50001, 'PendingMoveIn Insert failed', 1;
            END

            IF @nTranCount = 0
                COMMIT TRAN;
        END TRY
                END TRY
        BEGIN CATCH
            IF XACT_STATE() = -1
                ROLLBACK TRAN; -- uncommittable transaction, must rollback fully
            ELSE IF XACT_STATE() = 1
            BEGIN
                IF @nTranCount = 0
                    ROLLBACK TRAN;
                ELSE
                    ROLLBACK TRAN rdt_1764SuggToLocAU;
            END
            SET @nErrNo = 269253
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'cant suggest loc'
            RETURN
        END CATCH
    END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1764SuggToLocAU] TO NSQL
GO