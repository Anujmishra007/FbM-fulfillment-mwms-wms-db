IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdt_EventLog]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [RDT].[rdt_EventLog]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_EventLog                                        */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Insert into event log into RDT.RDTEventLog table            */
/*                                                                      */
/* Called from:                                                         */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 19-Jun-2008 1.0  James       Created                                 */
/************************************************************************/

CREATE PROC [RDT].[rdt_EventLog] (
   @nRowRef     INT OUTPUT,
   @cUserID     NVARCHAR( 15), 
   @cActivity   NVARCHAR( 20), 
   @nFucntionID INT 
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   
   INSERT INTO RDT.RDTEventLog (StartDate, UserID, Activity, FunctionID)
   VALUES
   (GETDATE(), @cUserID, @cActivity, @nFucntionID)

   SELECT @nRowRef = @@IDENTITY 
   
   IF @@ERROR <> 0 GOTO Quit
      
Quit:

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE on [RDT].[rdt_EventLog] to nSQL
GO  
