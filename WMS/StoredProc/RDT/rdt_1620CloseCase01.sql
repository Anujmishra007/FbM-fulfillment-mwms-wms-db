if exists (select * from dbo.sysobjects where id = object_id(N'rdt.rdt_1620CloseCase01') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure rdt.rdt_1620CloseCase01
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1620CloseCase01                                 */
/* Purpose: Cluster Pick Extended Close Case SP                         */
/*          If the drop id having prefix "ID" then turn off the config  */
/*                                                                      */
/* Called from: rdtfnc_Cluster_Pick                                     */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 15-Dec-2015 1.0  James      SOS356971 - Created                      */
/************************************************************************/

CREATE PROC rdt.rdt_1620CloseCase01 (
   @nMobile          INT,
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerkey       NVARCHAR( 15), 
   @cWaveKey         NVARCHAR( 10), 
   @cLoadKey         NVARCHAR( 10), 
   @cOrderKey        NVARCHAR( 10), 
   @cLoc             NVARCHAR( 10), 
   @cDropID          NVARCHAR( 20), 
   @cSKU             NVARCHAR( 20), 
   @nQty             INT, 
   @cPromptCloseCase NVARCHAR( 1)  OUTPUT,
   @nErrNo           INT           OUTPUT, 
   @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   IF SUBSTRING( @cDropID, 1, 2) = 'ID'
      SET @cPromptCloseCase = '0'
   ELSE
      SET @cPromptCloseCase = '1'

QUIT:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1620CloseCase01 TO NSQL
GO
