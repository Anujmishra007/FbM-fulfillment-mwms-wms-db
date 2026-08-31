SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_803Unassign01                                   */
/* Copyright      : Maersk                                              */
/* Customer       : AEOMX                                               */
/* Purpose        : PTW/PTL Unassign - only delete COMPLETE records,    */
/*                  preserve INPROGRESS records with SortTote info      */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2026-07-15  1.0  Cuize       FCR-13139 Created                       */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_803Unassign01] (
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

   -- FCR-13139: Do NOT delete rdtPTLPieceLog records
   -- SortTote (CartonID) and DropID info must be preserved for PTW sorting
   SET @nErrNo = 0
   SET @cErrMsg = ''

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_803Unassign01 TO NSQL
GO
