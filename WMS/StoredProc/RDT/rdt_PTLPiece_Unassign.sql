if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_PTLPiece_Unassign]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_PTLPiece_Unassign]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_PTLPiece_Unassign                               */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: Close station                                               */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 25-04-2016  1.0  Ung         SOS368861 Created                       */
/* 2026-07-15  1.1  Cuize       FCR-13139 Add UnassignSP config         */
/************************************************************************/

CREATE PROC rdt.rdt_PTLPiece_Unassign (
    @nMobile    INT
   ,@nFunc      INT
   ,@cLangCode  NVARCHAR( 3)
   ,@nStep      INT
   ,@nInputKey  INT
   ,@cFacility  NVARCHAR(5)
   ,@cStorerKey NVARCHAR( 15)
   ,@cStation   NVARCHAR( 10)
   ,@cMethod    NVARCHAR( 10)
   ,@nErrNo     INT           OUTPUT
   ,@cErrMsg    NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nRowRef INT
   DECLARE @nPTLKey INT
   DECLARE @cIPAddress NVARCHAR(40)
   DECLARE @cPosition  NVARCHAR(10)
   DECLARE @cSQL       NVARCHAR(MAX)
   DECLARE @cSQLParam  NVARCHAR(MAX)

   /***********************************************************************************************
                                         Custom Unassign SP
   ***********************************************************************************************/
   DECLARE @cUnassignSP SYSNAME
   SET @cUnassignSP = rdt.RDTGetConfig(@nFunc, 'UnassignSP', @cStorerKey)
   IF @cUnassignSP = '0'
      SET @cUnassignSP = ''

   -- Custom unassign SP
   IF @cUnassignSP <> ''
   BEGIN
      IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = @cUnassignSP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM(@cUnassignSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +
            ' @cStation, @cMethod, @nErrNo OUTPUT, @cErrMsg OUTPUT '
         SET @cSQLParam =
            ' @nMobile    INT,           ' +
            ' @nFunc      INT,           ' +
            ' @cLangCode  NVARCHAR( 3),  ' +
            ' @nStep      INT,           ' +
            ' @nInputKey  INT,           ' +
            ' @cFacility  NVARCHAR( 5),  ' +
            ' @cStorerKey NVARCHAR( 15), ' +
            ' @cStation   NVARCHAR( 10), ' +
            ' @cMethod    NVARCHAR( 10), ' +
            ' @nErrNo     INT            OUTPUT, ' +
            ' @cErrMsg    NVARCHAR( 250) OUTPUT  '
         EXEC sp_executesql @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
            @cStation, @cMethod, @nErrNo OUTPUT, @cErrMsg OUTPUT
         RETURN
      END
   END

   /***********************************************************************************************
                                         Standard Unassign
   ***********************************************************************************************/
   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_PTLPiece_Unassign -- For rollback or commit only our own transaction

   -- rdtPTLPieceLog
   DECLARE @curDPL CURSOR
   SET @curDPL = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT RowRef
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
      WHERE Station = @cStation
   OPEN @curDPL
   FETCH NEXT FROM @curDPL INTO @nRowRef
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Update rdtPTLPieceLog
      DELETE rdt.rdtPTLPieceLog WHERE RowRef = @nRowRef
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 99651
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DEL LOG Fail
         GOTO RollBackTran
      END
      FETCH NEXT FROM @curDPL INTO @nRowRef
   END

   COMMIT TRAN rdt_PTLPiece_Unassign
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_PTLPiece_Unassign -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_PTLPiece_Unassign TO NSQL
GO
