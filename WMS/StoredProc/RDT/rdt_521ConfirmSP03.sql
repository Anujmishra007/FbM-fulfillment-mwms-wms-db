SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_521ConfirmSP03                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev    Author   Purposes                                 */
/* 2025-03-14  1.0.0  Dennis   FCR-3449 Created                         */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_521ConfirmSP03] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT, 
   @nInputKey        INT,
   @cStorerKey       NVARCHAR( 15),
   @cFacility        NVARCHAR( 5),
   @cFromLOC         NVARCHAR( 10),
   @cID              NVARCHAR( 18),
   @cLOT             NVARCHAR( 10),
   @cUCCNo           NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),
   @nQTY             INT,
   @cToLOC           NVARCHAR( 10),
   @cSuggestedLOC    NVARCHAR( 10),
   @cPickAndDropLoc  NVARCHAR( 10),
   @nPABookingKey    INT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @cSwapLOT    NVARCHAR( 1)
   DECLARE @cChkQuality NVARCHAR( 10)
   DECLARE @cITrnKey    NVARCHAR( 10)
   DECLARE @cUCC_SKU    NVARCHAR( 20)
   DECLARE @cUCC_LOT    NVARCHAR( 10)
   DECLARE @nUCC_QTY    INT
   DECLARE @nUCC_RowRef INT
   DECLARE @cAllowAllocatedUCCPutaway NVARCHAR( 1)
   DECLARE @cUserName NVARCHAR( 10) = SUSER_SNAME()
   DECLARE @nTranCount  INT
   DECLARE @cSQL        NVARCHAR( MAX)
   DECLARE @cSQLParam   NVARCHAR( MAX)
   
   SET @nTranCount = @@TRANCOUNT
   SELECT 
      @cAllowAllocatedUCCPutaway = C_STRING1
   FROM rdt.rdtMobRec WITH (NOLOCK)  
   WHERE Mobile = @nMobile  

   -- Get UCC info
   DECLARE @nSKUCnt INT
   SELECT @nSKUCnt = COUNT( DISTINCT SKU)
   FROM dbo.UCC WITH (NOLOCK) 
   WHERE StorerKey = @cStorerKey
      AND UCCNo = @cUCCNo
      AND (Status = '1' OR Status = '3')

   -- Handling transaction
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_UCCPutaway_Confirm -- For rollback or commit only our own transaction 

   -- Single SKU UCC
   IF @nSKUCnt = 1
   BEGIN
      IF @cAllowAllocatedUCCPutaway = '1'
      BEGIN
         -- Execute putaway process  
         EXEC rdt.rdt_PutawayUCC_Allocated @nMobile, @nFunc, @cLangCode, @cUserName, @cFacility,  
            @cLOT,  
            @cFromLOC,  
            @cID,  
            @cStorerKey,  
            @cSKU,  
            @nQTY,  
            @cToLOC,  
            '',      --@cLabelType OUTPUT, -- optional  
            @cUCCNo, -- optional  --(cc01- for event log)
            @nErrNo     OUTPUT,  
            @cErrMsg    OUTPUT 
      END
      ELSE 
      BEGIN
         EXEC rdt.rdt_Putaway @nMobile, @nFunc, @cLangCode, @cUserName, @cFacility,  
            @cLOT, 
            @cFromLOC,  
            @cID,  
            @cStorerKey,  
            @cSKU,  
            @nQTY,  
            @cToLOC,  
            '',      --@cLabelType OUTPUT, -- optional  
            @cUCCNo, -- optional  --(cc01- for event log)
            @nErrNo     OUTPUT,  
            @cErrMsg    OUTPUT 
      END
      IF @nErrNo <> 0
         GOTO RollBackTran
   END
   
   -- Multi SKU UCC
   ELSE
   BEGIN
      DECLARE @curUCC   CURSOR

      SET @curUCC = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR 
         SELECT SKU, QTY, LOT
         FROM dbo.UCC WITH (NOLOCK) 
         WHERE StorerKey = @cStorerKey
            AND UCCNo = @cUCCNo
            AND (Status = '1' OR Status = '3')
      OPEN @curUCC
      FETCH NEXT FROM @curUCC INTO @cUCC_SKU, @nUCC_QTY, @cUCC_LOT
      WHILE @@FETCH_STATUS = 0
      BEGIN

         IF @cAllowAllocatedUCCPutaway = '1'
         BEGIN
            -- Execute putaway process  
            EXEC rdt.rdt_PutawayUCC_Allocated @nMobile, @nFunc, @cLangCode, @cUserName, @cFacility,  
               @cUCC_LOT,  
               @cFromLOC,  
               @cID,  
               @cStorerKey,  
               @cUCC_SKU,  
               @nUCC_QTY,  
               @cToLOC,  
               '',      --@cLabelType OUTPUT, -- optional  
               @cUCCNo, -- optional  --(cc01--for Eventlog)
               @nErrNo     OUTPUT,  
               @cErrMsg    OUTPUT   
         END
         ELSE 
         BEGIN
            EXEC rdt.rdt_Putaway @nMobile, @nFunc, @cLangCode, @cUserName, @cFacility,  
               @cUCC_LOT,  
               @cFromLOC,  
               @cID,  
               @cStorerKey,  
               @cUCC_SKU,  
               @nUCC_QTY,  
               @cToLOC,  
               '',      --@cLabelType OUTPUT, -- optional  
               @cUCCNo, -- optional  --(cc01--for Eventlog)
               @nErrNo     OUTPUT,  
               @cErrMsg    OUTPUT  
         END

         IF @nErrNo <> 0
            GOTO RollBackTran
         
         FETCH NEXT FROM @curUCC INTO @cUCC_SKU, @nUCC_QTY, @cUCC_LOT
      END
   END

   -- Get LOC info  
   DECLARE @cLoseID  NVARCHAR( 1)
   DECLARE @cLoseUCC NVARCHAR( 1)
   SELECT   
      @cLoseID = LoseID,   
      @cLoseUCC = LoseUCC  
   FROM LOC WITH (NOLOCK)   
   WHERE LOC = @cToLOC  

   -- Update UCC
   UPDATE dbo.UCC WITH (ROWLOCK) SET 
      ID = CASE WHEN @cLoseID = '1' THEN '' ELSE ID END,   
      LOC = @cToLOC,   
      EditWho  = SUSER_SNAME(),    
      EditDate = GETDATE(),   
      [Status] = CASE WHEN @cLoseUCC = '1' THEN '6' ELSE [Status] END  
   WHERE UCCNo = @cUCCNo   
      AND StorerKey = @cStorerKey  
      AND (Status = '1' OR Status = '3')
   IF @@ERROR <> 0
   BEGIN    
      SET @nErrNo = 50020 
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'UPD UCC FAIL 
      GOTO RollBackTran    
   END    

   -- Unlock current session suggested LOC
   IF @nPABookingKey <> 0
   BEGIN
      EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
         ,'' --FromLOC
         ,'' --FromID
         ,'' --SuggLOC
         ,'' --Storer
         ,@nErrNo  OUTPUT
         ,@cErrMsg OUTPUT
         ,@nPABookingKey = @nPABookingKey OUTPUT
      IF @nErrNo <> 0  
         GOTO RollBackTran
   
      SET @nPABookingKey = 0
   END

   COMMIT TRAN rdt_UCCPutaway_Confirm

   IF EXISTS (SELECT 1 FROM dbo.PickDetail (NOLOCK) WHERE DropID = @cUCCNo AND Status < '4' AND StorerKey = @cStorerKey) AND @cAllowAllocatedUCCPutaway = '1'
   BEGIN
      UPDATE dbo.PickDetail WITH(ROWLOCK) SET LOC = @cToLOC,TrafficCop = NULL WHERE DropID = @cUCCNo AND Status < '4' AND StorerKey = @cStorerKey
   END

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_UCCPutaway_Confirm
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_521ConfirmSP03] TO NSQL
GO
