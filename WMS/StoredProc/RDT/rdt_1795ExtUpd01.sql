SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1795ExtUpd01                                    */
/* Purpose: Close Alert                                                 */
/* Customer: USA Levis                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author    Purposes                                 */
/* 2025-07-15 1.0.0  NickT     UWP-52220. Created                       */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1795ExtUpd01] (
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
      @nRowCount           INT,
      @cAlertKey           NVARCHAR(18)

   IF @nFunc IN ( 1766, 1795 ) -- Handle CC & CCSUP
   BEGIN
      IF @nStep IN (4, 7)
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SELECT @cAlertKey = Message03
            FROM dbo.TaskDetail WITH(NOLOCK) 
            WHERE StorerKey = @cStorerKey 
               AND TaskDetailKey = @cTaskDetailKey
               AND Status = '9'
               AND TaskType = 'CCSUP'

            SELECT @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0 AND ISNULL(@cAlertKey, '') <> ''
            BEGIN
               BEGIN TRY
                  UPDATE dbo.ALERT WITH (ROWLOCK) 
                  SET
                     [Status] = '9'
                  WHERE AlertKey = @cAlertKey
                     AND [Status] = '0'
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 260501
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Close alert failed
                  GOTO Quit
               END CATCH
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
GRANT EXECUTE ON RDT.rdt_1795ExtUpd01 TO NSQL
GO