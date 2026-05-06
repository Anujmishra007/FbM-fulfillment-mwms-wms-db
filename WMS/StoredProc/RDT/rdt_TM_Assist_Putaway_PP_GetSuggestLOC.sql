
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO  
  
/************************************************************************/  
/* Store procedure: rdt_TM_Assist_Putaway_PP_GetSuggestLOC              */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date        Rev  Author   Purposes                                   */  
/* 2021-08-30  1.0  James    WMS-17016 Created                          */  
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_TM_Assist_Putaway_PP_GetSuggestLOC] (  
   @nMobile          INT,  
   @nFunc            INT,  
   @cLangCode        NVARCHAR( 3),  
   @nStep            INT,   
   @nInputKey        INT,   
   @cStorerKey       NVARCHAR( 15),   
   @cFacility        NVARCHAR( 5),  
   @cTaskDetailKey   NVARCHAR( 10),  
   @cFromLOC         NVARCHAR( 10),  
   @cFromID          NVARCHAR( 18),  
   @cSKU             NVARCHAR( 20),  
   @nQTY             INT,   
   @cSuggLOC         NVARCHAR( 10)  OUTPUT,  
   @nPABookingKey    INT            OUTPUT,  
   @nErrNo           INT            OUTPUT,  
   @cErrMsg          NVARCHAR( 20)  OUTPUT  
) AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @nTranCount       INT  
   DECLARE @cFitCasesInAisle NVARCHAR(1)  
   DECLARE @cSQL             NVARCHAR( MAX)  
   DECLARE @cSQLParam        NVARCHAR( MAX)  
     
   SET @cSuggLOC = ''  
     
   -- Get extended putaway  
   DECLARE @cGetSuggestLOCSP NVARCHAR(20)  
   SET @cGetSuggestLOCSP = rdt.rdtGetConfig( @nFunc, 'GetSuggestLOCSP', @cStorerKey)  
   IF @cGetSuggestLOCSP = '0'  
      SET @cGetSuggestLOCSP = ''    
  
   -- Extended putaway  
   IF @cGetSuggestLOCSP <> ''  
   BEGIN  
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cGetSuggestLOCSP AND type = 'P')  
      BEGIN  
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cGetSuggestLOCSP) +  
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cTaskDetailKey, @cFromLOC, @cFromID, @cSKU, @nQTY, ' +   
            ' @cSuggLOC OUTPUT, @nPABookingKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
         SET @cSQLParam =  
            '@nMobile          INT,                  ' +  
            '@nFunc            INT,                  ' +  
            '@cLangCode        NVARCHAR( 3),         ' +  
            '@nStep            INT,                  ' +   
            '@nInputKey        INT,                  ' +   
            '@cStorerKey       NVARCHAR( 15),        ' +  
            '@cFacility        NVARCHAR( 5),         ' +   
            '@cTaskDetailKey   NVARCHAR( 10),        ' +  
            '@cFromLOC         NVARCHAR( 10),        ' +  
            '@cFromID          NVARCHAR( 18),        ' +  
            '@cSKU             NVARCHAR( 20),        ' +  
            '@nQTY             INT,                  ' +  
            '@cSuggLOC         NVARCHAR( 10) OUTPUT, ' +   
            '@nPABookingKey    INT           OUTPUT, ' +   
            '@nErrNo           INT           OUTPUT, ' +  
            '@cErrMsg          NVARCHAR( 20) OUTPUT  '  
  
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cTaskDetailKey, @cFromLOC, @cFromID, @cSKU, @nQTY,   
            @cSuggLOC OUTPUT, @nPABookingKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
         IF @nErrNo <> 0  
            GOTO Quit  
      END  
  
      ELSE IF EXISTS( SELECT 1 FROM PutawayStrategy WITH (NOLOCK) WHERE PutawayStrategyKey = @cGetSuggestLOCSP)  
      BEGIN  
         -- Suggest LOC  
         EXEC @nErrNo = [dbo].[nspRDTPASTD]  
              @c_userid          = 'RDT'  
            , @c_storerkey       = @cStorerKey  
            , @c_lot             = ''  
            , @c_sku             = @cSKU  
            , @c_id              = @cFromID  
            , @c_fromloc         = @cFromLOC  
            , @n_qty             = @nQTY  
            , @c_uom             = '' -- not used  
            , @c_packkey         = '' -- optional, if pass-in SKU  
            , @n_putawaycapacity = 0  
            , @c_final_toloc     = @cSuggLOC OUTPUT  
            , @c_PAStrategyKey   = @cGetSuggestLOCSP  
      END  
   END  
   ELSE  
   BEGIN  
      -- Suggest LOC  
      EXEC @nErrNo = [dbo].[nspRDTPASTD]  
           @c_userid          = 'RDT'  
         , @c_storerkey       = @cStorerKey  
         , @c_lot             = ''  
         , @c_sku             = @cSKU  
         , @c_id              = @cFromID  
         , @c_fromloc         = @cFromLOC  
         , @n_qty             = @nQTY  
         , @c_uom             = '' -- not used  
         , @c_packkey         = '' -- optional, if pass-in SKU  
         , @n_putawaycapacity = 0  
         , @c_final_toloc     = @cSuggLOC OUTPUT  
   END  
     
   -- Check suggest loc  
   IF @cSuggLOC = ''  
   BEGIN  
      SET @nErrNo = 261451  
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NoSuitableLOC  
  
      SET @nErrNo = -1  
      GOTO Quit  
   END  
  
   -- Suggested location  
   IF @cSuggLOC <> ''   
   BEGIN  
      -- Handling transaction  
      SET @nTranCount = @@TRANCOUNT  
      BEGIN TRAN  -- Begin our own transaction  
      SAVE TRAN rdt_PP_GetSuggestLOC -- For rollback or commit only our own transaction  
        
      -- Lock suggested location  
      EXEC rdt.rdt_Putaway_PendingMoveIn '', 'LOCK'  
         ,@cFromLOC  
         ,@cFromID  
         ,@cSuggLOC  
         ,@cStorerKey  
         ,@nErrNo  OUTPUT  
         ,@cErrMsg OUTPUT  
         ,@nPABookingKey = @nPABookingKey OUTPUT  
         ,@cSKU = @cSKU  
         ,@nPutawayQTY = @nQTY  
      IF @nErrNo <> 0  
         GOTO RollBackTran  
  
      COMMIT TRAN rdt_PP_GetSuggestLOC -- Only commit change made here  
   END  
  
   GOTO Quit  
  
RollBackTran:  
   ROLLBACK TRAN rdt_PP_GetSuggestLOC -- Only rollback change made here  
Quit:  
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      COMMIT TRAN  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_TM_Assist_Putaway_PP_GetSuggestLOC to nSQL
GO