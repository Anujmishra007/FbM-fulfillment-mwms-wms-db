if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_803CloseCtnSP01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_803CloseCtnSP01]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_803CloseCtnSP01                                 */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: Close station                                               */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 01-03-2021 1.0  YeeKung     WMS-16066 Created                        */  
/************************************************************************/

CREATE PROC rdt.rdt_803CloseCtnSP01 (
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

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_803CloseCtnSP01 -- For rollback or commit only our own transaction

   UPDATE RDT.rdtPTLPieceLog WITH (ROWLOCK)
   set cartonid=@cCartonID,
       sku=''
   where loc=@cloc

   IF @@ERROR<>0
   BEGIN
      SET @nErrNo = 165051  
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd 
      GOTO RollBackTran
   END

   COMMIT TRAN rdt_803CloseCtnSP01
   GOTO Quit
   
RollBackTran:
   ROLLBACK TRAN rdt_803CloseCtnSP01 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_803CloseCtnSP01 TO NSQL
GO
