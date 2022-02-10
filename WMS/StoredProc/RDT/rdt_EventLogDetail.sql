IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdt_EventLogDetail]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [RDT].[rdt_EventLogDetail]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_EventLogDetail                                  */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Insert into event log into RDT.RDTEventLogDetail table      */
/*                                                                      */
/* Called from:                                                         */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2008-Nov-10 1.0  James       Created                                 */
/************************************************************************/

CREATE PROC [RDT].[rdt_EventLogDetail] (
   @nRowRef     INT,
   @cFacility   NVARCHAR( 20), 
   @cStorerKey  NVARCHAR( 15), 
   @cSKU        NVARCHAR( 20), 
   @cUOM        NVARCHAR( 10), 
   @nQTY        INT, 
   @cDocRefNo   NVARCHAR( 20)
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   
   INSERT INTO RDT.RDTEventLogDetail (RowRef, Facility, StorerKey, SKU, UOM, QTY, DocRefNo, AddDate)
   VALUES
   (@nRowRef, @cFacility, @cStorerKey, @cSKU, @cUOM, @nQTY, @cDocRefNo, GETDATE())

   IF @@ERROR <> 0
   GOTO Quit
      
Quit:

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE on [RDT].[rdt_EventLogDetail] to nSQL
GO  
