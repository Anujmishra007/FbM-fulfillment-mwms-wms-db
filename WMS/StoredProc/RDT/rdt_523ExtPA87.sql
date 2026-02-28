SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_523ExtPA87                                            */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Customer: DAIMLER TRUCK AG                                                 */
/*                                                                            */
/* Date        Rev  Author    Purposes                                        */
/* 2026-01-29  1.0  Jackc     FCR-9756. Created                               */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_523ExtPA87] (
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

   DECLARE @nDebugFlag     INT = 0

   DECLARE @nTranCount     INT
   DECLARE @nPreAlloQty    INT
   DECLARE @cSuggToLOC     NVARCHAR( 10) = ''

   IF @nDebugFlag = 1
      SELECT 'Running rdt_523ExtPA87'

   SET @nTranCount = @@TRANCOUNT

   SELECT @nPreAlloQty = C_Integer1 
   FROM rdt.RDTMOBREC WITH (NOLOCK)
      WHERE Mobile = @nMobile

   IF @nPreAlloQty > 0
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Customized loc suggestion'

      -- Find a friend
      SELECT TOP 1
         @cSuggestedLOC = LOC.LOC
      FROM dbo.LOC WITH (NOLOCK)
      JOIN dbo.CODELKUP CL WITH (NOLOCK)
         ON CL.LISTNAME = 'VORZONE' 
         AND CL.Code =LOC.PUTAWAYZONE
      WHERE LOC.Facility = @cFacility

      IF @@ROWCOUNT = 0
         SET @cSuggestedLOC = ''
   END
   ELSE
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'base loc suggestion'

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
   END

   IF @nDebugFlag = 1
      SELECT @cSuggestedLOC

   /*-------------------------------------------------------------------------------
                                 Book suggested location
   -------------------------------------------------------------------------------*/
   -- Handling transaction
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_523ExtPA87 -- For rollback or commit only our own transaction

   IF ISNULL(@cSuggestedLOC,'') <> ''
   BEGIN
      SET @nErrNo = 0
      EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
         ,@cLOC
         ,@cID
         ,@cSuggestedLOC
         ,@cStorerKey
         ,@nErrNo  OUTPUT
         ,@cErrMsg OUTPUT
         ,@cSKU          = @cSKU
         ,@nPutawayQTY   = @nQTY
         ,@nPABookingKey = @nPABookingKey OUTPUT
      IF @nErrNo <> 0
         GOTO RollBackTran

      COMMIT TRAN rdt_523ExtPA87 -- Only commit change made here
   END
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_523ExtPA87 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO
GRANT EXECUTE ON  [RDT].[rdt_523ExtPA87] TO [NSQL]
GO
