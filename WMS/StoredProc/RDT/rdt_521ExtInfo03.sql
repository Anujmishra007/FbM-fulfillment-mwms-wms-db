IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'rdt.rdt_521ExtInfo03') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE rdt.rdt_521ExtInfo03
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_521ExtInfo03                                    */
/* Purpose: Display custom info                                         */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2021-09-03   James     1.0   WMS-17795 Created                       */
/************************************************************************/

CREATE PROCEDURE rdt.rdt_521ExtInfo03
   @nMobile         INT,       
   @nFunc           INT,       
   @cLangCode       NVARCHAR( 3),  
   @nStep           INT,       
   @nInputKey       INT,       
   @cStorerKey      NVARCHAR( 15), 
   @cUCCNo          NVARCHAR( 20), 
   @cSuggestedLOC   NVARCHAR( 10), 
   @cToLOC          NVARCHAR( 10), 
   @cExtendedInfo1  NVARCHAR( 20) OUTPUT, 
   @nErrNo          INT OUTPUT,    
   @cErrMsg         NVARCHAR( 20) OUTPUT 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cPAZone     NVARCHAR( 10)
   DECLARE @cFacility   NVARCHAR( 5)
   
   SELECT @cFacility = Facility
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   IF @nInputKey = 1
   BEGIN
      IF @nStep = 1
      BEGIN
         SELECT @cPAZone = PutawayZone
         FROM dbo.LOC WITH (NOLOCK) 
         WHERE Facility = @cFacility
         AND   LOC = @cSuggestedLOC

         SET @cExtendedInfo1 = 'PA ZONE: ' + @cPAZone
      END
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_521ExtInfo03 TO NSQL
GO
