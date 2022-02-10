if exists (select * from dbo.sysobjects where id = object_id(N'rdt.rdt_840ExtInfo01') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure rdt.rdt_840ExtInfo01
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_840ExtInfo01                                    */
/* Copyright: LF Logistics                                              */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2014-09-17 1.0  Ung        SOS320585. Created                        */
/************************************************************************/

CREATE PROC rdt.rdt_840ExtInfo01 (
   @nMobile       INT,
   @nFunc         INT, 
   @cLangCode     NVARCHAR( 3), 
   @nStep         INT, 
   @nAfterStep    INT, 
   @nInputKey     INT, 
   @cStorerkey    NVARCHAR( 15), 
   @cOrderKey     NVARCHAR( 10), 
   @cPickSlipNo   NVARCHAR( 10), 
   @cTrackNo      NVARCHAR( 20), 
   @cSKU          NVARCHAR( 20), 
   @nCartonNo     INT,
   @cExtendedInfo NVARCHAR( 20) OUTPUT,
   @nErrNo        INT           OUTPUT, 
   @cErrMsg       NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   IF @nFunc = 840 -- Pack by track no
   BEGIN
      IF @nAfterStep = 3 -- SKU
      BEGIN
         -- Get Order Info
         DECLARE @cDoor NVARCHAR( 10)
         SELECT @cDoor = Door FROM Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey
         
         IF @cDoor = 'TMALL'
            SET @cExtendedInfo = '*** TMALL ***'
         ELSE
            SET @cExtendedInfo = ''
      END
   END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_840ExtInfo01 TO NSQL
GO
