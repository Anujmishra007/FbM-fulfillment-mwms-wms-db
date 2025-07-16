SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1766ExtUpd05                                    */
/* Purpose: For PAGE                                                    */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author    Purposes                                 */
/* 2025-07-15 1..00  NickT     FCR-4885. Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1766ExtUpd05] (
   @nMobile     INT,
   @nFunc       INT, 
   @cLangCode   NVARCHAR( 3), 
   @nStep       INT, 
   @nInputKey   INT, 
   @cFacility       NVARCHAR( 15), 
   @cStorerKey      NVARCHAR( 15), 
   @cTaskdetailkey  NVARCHAR( 20), 
   @cFromLoc        NVARCHAR( 20), 
   @cID             NVARCHAR( 20), 
   @cPickMethod     NVARCHAR( 20), 
   @nErrNo          INT           OUTPUT, 
   @cErrMsg         NVARCHAR( 20) OUTPUT  
)
AS
BEGIN

   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF 

   DECLARE
      @cUserName       NVARCHAR( 18),
      @cOptions        NVARCHAR( 60),
      @cLoc            NVARCHAR( 10),
      @cHoldType       NVARCHAR( 60),
      @nRowCount      INT

   SELECT 
      @cUserName = UserName,
      @cOptions = I_Field02
   FROM rdt.RDTMOBREC (NOLOCK) WHERE Mobile = @nMobile

   IF @nFunc IN (1766,1794,1795) -- Handle CC & CCSUP
   BEGIN
      IF @nStep = 4
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF ISNULL(@cOptions, '') = '1'
            BEGIN
               SELECT @cLoc = FromLoc,
                  @cHoldType = Message01
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE TaskDetailKey = @cTaskdetailkey
                  AND Status = '9'
                  AND SourceType = 'rdt_ActionByReason'
                  AND Holdkey = 'UNHOLD'

               SELECT @nRowCount = @@RowCount

               IF ISNULL(@nRowCount, 0) = 1
               BEGIN
                  UPDATE dbo.LOC WITH(ROWLOCK)
                  SET 
               END
            END
         END
      END
   END --Func

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1766ExtUpd05 TO NSQL
GO