if exists (select * from sys.sysobjects where id = object_id(N'rdt.rdt_LOCLookUp') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure rdt.rdt_LOCLookUp
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_LOCLookUp                                       */
/* Purpose: Return loc with prefix or custom method                     */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2019-02-19 1.0  James      WMS-7796. Created                         */
/************************************************************************/

CREATE PROC rdt.rdt_LOCLookUp (
   @nMobile     INT,
   @nFunc       INT, 
   @cLangCode   NVARCHAR( 3), 
   @nStep       INT, 
   @nInputKey   INT, 
   @cStorerkey  NVARCHAR( 15), 
   @cFacility   NVARCHAR( 5), 
   @cLOC        NVARCHAR( 10) OUTPUT, 
   @nErrNo      INT           OUTPUT, 
   @cErrMsg     NVARCHAR( 20) OUTPUT
)
AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cPrefix  NVARCHAR( 10)
   
   SELECT @cPrefix = Userdefine03
   FROM dbo.Facility WITH (NOLOCK)
   WHERE Facility = @cFacility

   SET @cLOC = LEFT( RTRIM( ISNULL( @cPrefix, '')) + @cLOC, 10)
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_LOCLookUp TO NSQL
GO
