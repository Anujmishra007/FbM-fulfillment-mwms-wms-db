if exists (select * from dbo.sysobjects where id = object_id(N'rdt.rdtVFTBExtUpd') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure rdt.rdtVFTBExtUpd
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdtVFTBExtUpd                                       */
/* Purpose: Trolley build                                               */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2013-05-20 1.0  Ung        SOS259761. Created                        */
/************************************************************************/

CREATE PROC rdt.rdtVFTBExtUpd (
   @nMobile       INT,
   @nFunc         INT, 
   @cLangCode     NVARCHAR( 3), 
   @nStep         INT, 
   @cStorerKey    NVARCHAR( 15), 
   @cUCC          NVARCHAR( 20),
   @cPutawayZone  NVARCHAR( 10),
   @cSuggestedLOC NVARCHAR( 10),
   @cTrolleyNo    NVARCHAR( 10),
   @nErrNo        INT       OUTPUT, 
   @cErrMsg       NVARCHAR( 20) OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF

IF @nStep = 2
BEGIN
   IF LEFT( @cTrolleyNo, 3) <> 'TRO'
   BEGIN
      SET @nErrNo = 81201
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Bad TrolleyNo
   END
END

Quit:
Fail:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdtVFTBExtUpd TO NSQL
GO
