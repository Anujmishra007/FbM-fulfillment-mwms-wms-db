SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/******************************************************************************/
/* Copyright: MaerSK                                                          */
/*                                                                            */
/* Purpose: Set Message, Clear MessageOut                                     */
/*                                                                            */
/* Updates:                                                                   */
/* Date         Author   Rev  Purposes                                        */
/* 2025-11-06   NickT    1.0  UWP-43698 Create                                */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdtUpdRDTMOBTraceID] (
   @nMobile       INT,
   @InMessage      NVARCHAR( MAX),
   @cTraceID      NVARCHAR( 100),
   @nErrNo        INT               OUTPUT,
   @cErrMsg       NVARCHAR( 1024)   OUTPUT,
   @OutMessage    NVARCHAR(MAX)     OUTPUT
)
AS
BEGIN
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

   UPDATE RDT.RDTMOBTraceID WITH (ROWLOCK) SET
      Message = @InMessage,
      InTime = GETDATE(),
      MessageOut = '',
      TraceID = @cTraceID
   WHERE Mobile = @nMobile

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdtUpdRDTMOBTraceID TO NSQL
GO
