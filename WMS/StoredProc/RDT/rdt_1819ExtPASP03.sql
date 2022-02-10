IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[rdt].[rdt_1819ExtPASP03]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [rdt].[rdt_1819ExtPASP03]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1819ExtPASP03                                   */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 08-12-2015  1.0  Ung      SOS355261. Created                         */
/************************************************************************/

CREATE PROC [rdt].[rdt_1819ExtPASP03] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cUserName        NVARCHAR( 18),
   @cStorerKey       NVARCHAR( 15), 
   @cFacility        NVARCHAR( 5), 
   @cFromLOC         NVARCHAR( 10),
   @cID              NVARCHAR( 18),
   @cSuggLOC         NVARCHAR( 10)  OUTPUT,
   @cPickAndDropLOC  NVARCHAR( 10)  OUTPUT,
   @cFitCasesInAisle NVARCHAR( 1)   OUTPUT,
   @nPABookingKey    INT            OUTPUT, 
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   SET @cSuggLOC = ''
   SET @cPickAndDropLOC = ''
   
   -- Get TaskDetail info
   SELECT 
      @cSuggLOC = ToLOC 
   FROM TaskDetail TD WITH (NOLOCK) 
      JOIN LOC WITH (NOLOCK) ON (TD.FromLOC = LOC.LOC)
   WHERE LOC.Facility = @cFacility
      AND TD.TaskType = 'ASTMV'
      AND TD.Status = '0'
      AND TD.FromID = @cID

   -- Check duplicate task, due to ID reuse. 
   IF @@ROWCOUNT > 1
   BEGIN
      SET @cSuggLOC = ''
      SET @nErrNo = 59101
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Dup ASTMV task
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1819ExtPASP03] TO NSQL
GO
