SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Stored Procedure: rdt_1770ExtValARLA                                       */
/* Creation Date: 01-07-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: KMS043                                                        */
/*                                                                           */
/* Purpose : 1770 Pallet Pick Validation of Checking 18 Digit SSCC Code UWP-59502   */
/*                                                                           */
/* Called By:  rdt_830ExtValARLA                                             */
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purpose                                        */
/* 01-04-2026   KMS043  1.0  Initial version created  UWP-61885               */
/*****************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_1770ExtValARLA]
    @nMobile         INT 
   ,@nFunc           INT 
   ,@cLangCode       NVARCHAR( 3) 
   ,@nStep           INT 
   ,@nInputKey       INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@nQTY            INT
   ,@cToLOC          NVARCHAR( 10)
   ,@cDropID         NVARCHAR( 20)
   ,@nErrNo          INT           OUTPUT 
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
   
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
    DECLARE @cFromID         NVARCHAR( 20)
   -- TM Pallet Pick
   IF @nFunc = 1770
   BEGIN
      IF @nStep = 4 -- ToLOC, DropID
      BEGIN
         IF @nInputKey = 1 -- ENTER

		 SELECT @cFromID=FROMID FROM TASKDETAIL WHERE TASKDETAILKEY=@cTaskDetailKey
         BEGIN
            -- Check DropID
            IF @cDropID = '' OR @cDropID<>@cFromID
            BEGIN
               SET @nErrNo = 271201
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropIDNeeded
               EXEC rdt.rdtSetFocusField @nMobile, 4 -- DropID
               GOTO Quit
            END
         END
      END
   END
   GOTO Quit

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [RDT].[rdt_1770ExtValARLA] TO NSQL 
GO   
