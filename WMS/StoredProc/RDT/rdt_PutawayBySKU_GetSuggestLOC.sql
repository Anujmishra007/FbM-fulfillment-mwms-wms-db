IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[rdt].[rdt_PutawayBySKU_GetSuggestLOC]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [rdt].[rdt_PutawayBySKU_GetSuggestLOC]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_PutawayBySKU_GetSuggestLOC                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 07-12-2016  1.0  Ung      WMS-751 Created                            */
/************************************************************************/

CREATE PROC [rdt].[rdt_PutawayBySKU_GetSuggestLOC] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cUserName        NVARCHAR( 18), 
   @cStorerKey       NVARCHAR( 15), 
   @cFacility        NVARCHAR( 5),
   @cLOC             NVARCHAR( 10),
   @cID              NVARCHAR( 18),
   @cLOT             NVARCHAR( 10),
   @cUCC             NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),
   @nQTY             INT,
   @cSuggestedLOC    NVARCHAR( 10)  OUTPUT,
   @nPABookingKey    INT            OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @nTranCount  INT
   DECLARE @cSQL        NVARCHAR( MAX)
   DECLARE @cSQLParam   NVARCHAR( MAX)
   
   SET @cSuggestedLOC = ''
   
   -- Get extended putaway
   DECLARE @cExtendedPutawaySP NVARCHAR(20)
   SET @cExtendedPutawaySP = rdt.rdtGetConfig( @nFunc, 'ExtendedPutawaySP', @cStorerKey)
   IF @cExtendedPutawaySP = '0'
      SET @cExtendedPutawaySP = ''  

   -- Extended putaway
   IF @cExtendedPutawaySP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedPutawaySP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedPutawaySP) +
            ' @nMobile, @nFunc, @cLangCode, @cUserName, @cStorerKey, @cFacility, @cLOC, @cID, @cLOT, @cUCC, @cSKU, @nQTY, ' + 
            ' @cSuggestedLOC OUTPUT, @nPABookingKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile          INT,                  ' +
            '@nFunc            INT,                  ' +
            '@cLangCode        NVARCHAR( 3),         ' +
            '@cUserName        NVARCHAR( 18),        ' +
            '@cStorerKey       NVARCHAR( 15),        ' +
            '@cFacility        NVARCHAR( 5),         ' + 
            '@cLOC         NVARCHAR( 10),        ' +
            '@cID              NVARCHAR( 18),        ' +
            '@cLOT             NVARCHAR( 10),        ' +
            '@cUCC             NVARCHAR( 20),        ' + 
            '@cSKU             NVARCHAR( 20),        ' +
            '@nQTY             INT,                  ' +
            '@cSuggestedLOC    NVARCHAR( 10) OUTPUT, ' + 
            '@nPABookingKey    INT           OUTPUT, ' + 
            '@nErrNo           INT           OUTPUT, ' +
            '@cErrMsg          NVARCHAR( 20) OUTPUT  '

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @cUserName, @cStorerKey, @cFacility, @cLOC, @cID, @cLOT, @cUCC, @cSKU, @nQTY, 
            @cSuggestedLOC OUTPUT, @nPABookingKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

         IF @nErrNo <> 0
            GOTO Quit
      END
   END
   ELSE
   BEGIN
      -- Suggest LOC
      EXEC @nErrNo = [dbo].[nspRDTPASTD]
           @c_userid          = 'RDT'
         , @c_storerkey       = @cStorerKey
         , @c_lot             = @cLOT
         , @c_sku             = @cSKU
         , @c_id              = @cID
         , @c_fromloc         = @cLOC
         , @n_qty             = @nQTY
         , @c_uom             = '' -- not used
         , @c_packkey         = '' -- optional, if pass-in SKU
         , @n_putawaycapacity = 0
         , @c_final_toloc     = @cSuggestedLOC OUTPUT

      -- Check suggest loc
      IF @cSuggestedLOC = ''
      BEGIN
         SET @nErrNo = -1
         GOTO Quit
      END
      
      -- Lock suggested location
      IF @cSuggestedLOC <> '' 
      BEGIN
         -- Handling transaction
         SET @nTranCount = @@TRANCOUNT
         BEGIN TRAN  -- Begin our own transaction
         SAVE TRAN rdt_PutawayBySKU_GetSuggestLOC -- For rollback or commit only our own transaction
         
         EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
            ,@cLOC
            ,@cID
            ,@cSuggestedLOC
            ,@cStorerKey
            ,@nErrNo  OUTPUT
            ,@cErrMsg OUTPUT
            ,@cSKU          = @cSKU
            ,@nPutawayQTY   = @nQTY
            ,@cFromLOT      = @cLOT
            ,@cUCCNo        = @cUCC
            ,@nPABookingKey = @nPABookingKey OUTPUT
         
         IF @nErrNo <> 0
            GOTO RollBackTran

         COMMIT TRAN rdt_PutawayBySKU_GetSuggestLOC -- Only commit change made here
      END
   END
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_PutawayBySKU_GetSuggestLOC -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_PutawayBySKU_GetSuggestLOC] TO NSQL
GO
