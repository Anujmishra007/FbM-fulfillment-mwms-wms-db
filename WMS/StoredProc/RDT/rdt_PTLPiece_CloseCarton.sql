if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_PTLPiece_CloseCarton]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_PTLPiece_CloseCarton]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_PTLPiece_CloseCarton                            */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: Close station                                               */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 01-03-2021 1.0  YeeKung     WMS-16066 Created                        */  
/************************************************************************/

CREATE PROC rdt.rdt_PTLPiece_CloseCarton (
    @nMobile    INT
   ,@nFunc      INT
   ,@cLangCode  NVARCHAR( 3)
   ,@nStep      INT
   ,@nInputKey  INT
   ,@cFacility  NVARCHAR(5)
   ,@cStorerKey NVARCHAR( 15)
   ,@cStation   NVARCHAR( 10)
   ,@cPosition  NVARCHAR( 20)
   ,@cLOC       NVARCHAR( 20)
   ,@cCartonID  NVARCHAR( 20)
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

                 
   DECLARE @cSQL      NVARCHAR( MAX)  
   DECLARE @cSQLParam NVARCHAR( MAX)  
   DECLARE @cCloseCartonSP NVARCHAR(30)
     
   SET @cCloseCartonSP = rdt.rdtGetConfig( @nFunc, 'PtlPieceCloseCartonSP', @cStorerKey)
  
   -- Chec closecarton SP valid  
   IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cCloseCartonSP AND type = 'P')  
   BEGIN 
  
      -- Confirm SP  
      SET @cSQL = 'EXEC rdt.' + RTRIM( @cCloseCartonSP) +  
         ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +  
         ' @cStation, @cPosition,@cLOC,@cCartonID, @nErrNo OUTPUT, @cErrMsg OUTPUT' 

      SET @cSQLParam =  
         '   @nMobile    INT                 '+
         '  ,@nFunc      INT                 '+
         '  ,@cLangCode  NVARCHAR( 3)        '+
         '  ,@nStep      INT                 '+
         '  ,@nInputKey  INT                 '+
         '  ,@cFacility  NVARCHAR(5)         '+
         '  ,@cStorerKey NVARCHAR( 15)       '+
         '  ,@cStation   NVARCHAR( 10)       '+
         '  ,@cPosition  NVARCHAR( 20)       '+
         '  ,@cLOC       NVARCHAR( 20)       '+
         '  ,@cCartonID  NVARCHAR( 20)       '+
         '  ,@nErrNo     INT           OUTPUT'+  
         '  ,@cErrMsg    NVARCHAR(250) OUTPUT'

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
      @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
      @cStation, @cPosition,@cLOC,@cCartonID, @nErrNo OUTPUT, @cErrMsg OUTPUT

      GOTO QUIT
   END
  
  /**********************************************************************************************/
  /*       standard close carton                                                                */
  /**********************************************************************************************/


   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_PTLPiece_CloseCarton -- For rollback or commit only our own transaction

   UPDATE RDT.rdtPTLPieceLog WITH (ROWLOCK)
   set cartonid=@cCartonID
   where position=@cPosition 
   and station=@cStation
   and loc=@cloc

   IF @@ERROR<>0
   BEGIN
      SET @nErrNo = 164951 
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd 
      GOTO RollBackTran
   END

   COMMIT TRAN rdt_PTLPiece_CloseCarton
   GOTO Quit
   
RollBackTran:
   ROLLBACK TRAN rdt_PTLPiece_CloseCarton -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_PTLPiece_CloseCarton TO NSQL
GO
