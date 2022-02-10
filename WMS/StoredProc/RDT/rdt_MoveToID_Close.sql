if exists (select * from dbo.sysobjects where id = object_id(N'[rdt].[rdt_MoveToID_Close]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdt_MoveToID_Close]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_MoveToID_Close                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2013-01-04 1.0  Ung        SOS265198. Created                        */
/* 2018-03-07 1.1  ChewKP     WMS-4190 Add ConfirmSP Config (ChewKP01)  */
/* 2021-06-15 1.7  James      WMS-17221 Add stdevtlog (james02)         */
/************************************************************************/

CREATE PROC rdt.rdt_MoveToID_Close (
   @nMobile    INT,
   @nFunc      INT, 
   @cLangCode  NVARCHAR( 3), 
   @nStep      INT, 
   @cStorerKey NVARCHAR( 15),
   @cToID      NVARCHAR( 18),
   @cToLOC     NVARCHAR( 10),
   @nErrNo     INT       OUTPUT, 
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE @cFacility NVARCHAR( 5)
   DECLARE @cFromLOT NVARCHAR( 10)
   DECLARE @cFromID  NVARCHAR( 18)
   DECLARE @cFromLOC NVARCHAR( 10)
   DECLARE @cSKU     NVARCHAR( 20)
   DECLARE @nQTY     INT
   DECLARE @cExtendedUpdateSP NVARCHAR( 20)
           ,@cSQL          NVARCHAR(1000)
           ,@cSQLParam     NVARCHAR(1000)
           ,@cUserName     NVARCHAR( 18)
           
   SELECT @cUserName = UserName
   FROM rdt.rdtMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
           
   SET @cFacility = ''
   
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_MoveToID_Close
   
   DECLARE @cConfirmSP NVARCHAR( 20)
   SET @cConfirmSP = rdt.RDTGetConfig( @nFunc, 'ConfirmSP', @cStorerKey)
   IF @cConfirmSP = '0'
      SET @cConfirmSP = ''

         
   -- Custom receiving logic
   IF @cConfirmSP <> ''
   BEGIN
      

       SET @cSQL = 'EXEC rdt.' + RTRIM( @cConfirmSP) +
          '  @nMobile, @nFunc,  @cLangCode, @nStep, @cStorerKey, @cToID, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT '
       SET @cSQLParam =
            '@nMobile    INT,                   '+
            '@nFunc      INT,                   '+
            '@cLangCode  NVARCHAR( 3),          '+
            '@nStep      INT,                   '+
            '@cStorerKey NVARCHAR( 15),         '+
            '@cToID      NVARCHAR( 18),         '+
            '@cToLOC     NVARCHAR( 10),         '+
            '@nErrNo     INT       OUTPUT,      '+
            '@cErrMsg    NVARCHAR( 20) OUTPUT   '

       EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
           @nMobile, @nFunc,  @cLangCode, @nStep, @cStorerKey, @cToID, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT 

   END
   ELSE
   BEGIN
      -- Loop rdtMoveToIDLog
      DECLARE @curMoveToIDLog CURSOR
      SET @curMoveToIDLog = CURSOR FOR 
      SELECT FromLOT, FromLOC, FromID, SKU, QTY
      FROM rdt.rdtMoveToIDLog WITH (NOLOCK) 
      WHERE StorerKey = @cStorerKey
         AND ToID = @cToID
      OPEN @curMoveToIDLog
      FETCH NEXT FROM @curMoveToIDLog INTO @cFromLOT, @cFromLOC, @cFromID, @cSKU, @nQTY
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Get facility
         IF @cFacility = ''
            SELECT @cFacility = Facility FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cFromLOC

         -- Reduce LOTxLOCxID.QTYReplen
         UPDATE dbo.LOTxLOCxID SET 
            QTYReplen = CASE WHEN QTYReplen - @nQTY >= 0 THEN QTYReplen - @nQTY ELSE 0 END
         WHERE LOT = @cFromLOT
            AND LOC = @cFromLOC
            AND ID = @cFromID
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 78951
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD LLI Fail
            GOTO RollBackTran
         END

         -- Move
         EXECUTE rdt.rdt_Move
            @nMobile     = @nMobile,
            @cLangCode   = @cLangCode, 
            @nErrNo      = @nErrNo  OUTPUT,
            @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 char max
            @cSourceType = 'rdtfnc_Move_SKU', 
            @cStorerKey  = @cStorerKey,
            @cFacility   = @cFacility, 
            @cFromLOC    = @cFromLOC, 
            @cToLOC      = @cToLOC, 
            @cFromID     = @cFromID,     -- NULL means not filter by ID. Blank is a valid ID
            @cToID       = @cToID,       -- NULL means not changing ID. Blank consider a valid ID
            @cFromLOT    = @cFromLOT, 
            @cSKU        = @cSKU, 
            @nQTY        = @nQTY
         IF @nErrNo <> 0
            GOTO RollBackTran

         -- EventLog
         EXEC RDT.rdt_STD_EventLog
            @cActionType   = '4', -- Move
            @cUserID       = @cUserName,
            @nMobileNo     = @nMobile,
            @nFunctionID   = @nFunc,
            @cFacility     = @cFacility,
            @cStorerKey    = @cStorerkey,
            @cToID         = @cToID,
            @cToLocation   = @cToLOC,
            @nStep         = @nStep, 
            @cSKU          = @cSKU,    
            @nQTY          = @nQTY,   
            @cLocation     = @cFromLOC,
            @cID           = @cFromID
         
         FETCH NEXT FROM @curMoveToIDLog INTO @cFromLOT, @cFromLOC, @cFromID, @cSKU, @nQTY
      END

      -- Delete log
      DELETE rdt.rdtMoveToIDLog
      WHERE StorerKey = @cStorerKey
         AND ToID = @cToID
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 78952
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DEL Log Fail
         GOTO RollBackTran
      END
   END
   GOTO Quit

RollBackTran:
      ROLLBACK TRAN rdt_MoveToID_Close
Quit:         
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_MoveToID_Close TO NSQL
GO
