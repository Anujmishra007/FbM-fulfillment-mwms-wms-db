if exists (select * from dbo.sysobjects where id = object_id(N'rdt.rdt_870ExtInfoSP01') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure rdt.rdt_870ExtInfoSP01
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_870ExtInfoSP01                                  */
/* Purpose: Serial No Capture extended info                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2014-07-16 1.0  James      SOS#315487. Created                       */
/************************************************************************/

CREATE PROC rdt.rdt_870ExtInfoSP01 (
   @nMobile     INT,
   @nFunc       INT, 
   @cLangCode   NVARCHAR( 3), 
   @nStep       INT, 
   @nInputKey   INT, 
   @cSerialNo   NVARCHAR( 30) OUTPUT, 
   @nErrNo      INT           OUTPUT, 
   @cErrMsg     NVARCHAR( 20) OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF

   SET @cSerialNo = @cSerialNo
   
QUIT:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_870ExtInfoSP01 TO NSQL
GO
