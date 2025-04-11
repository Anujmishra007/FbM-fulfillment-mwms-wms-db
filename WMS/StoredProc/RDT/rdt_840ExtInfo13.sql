SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/
/* Store procedure: rdt_840ExtInfo13                                      */
/* Copyright: MAERSK                                                      */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2025-04-10 1.0.0  NLT013     FCR-3728. Created                         */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_840ExtInfo13] (
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
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cSQL                NVARCHAR( MAX),
      @cSubQuery           NVARCHAR( MAX),
      @cExtendedMsg        NVARCHAR( 20),
      @nQty                INT

   IF @nFunc = 840 -- Pack by track no
   BEGIN
      IF @nAfterStep = 5 -- Pick & Pack Completed
      BEGIN
         SELECT TOP 1
            @cSubQuery = Notes,
            @cExtendedMsg = Description
         FROM dbo.CODELKUP WITH(NOLOCK)
         WHERE StorerKey = @cStorerkey
            AND LISTNAME = 'PACKEXTINF'

         IF ISNULL(@cSubQuery, '') <> '' AND ISNULL(@cExtendedMsg, '') <> ''
         BEGIN
            SET @cSQL = ' SELECT @nQty = COUNT(1) FROM dbo.ORDERS WITH(NOLOCK) '       +
                        ' WHERE StorerKey = @cStorerKey '                              +
                        '    AND ORDERS.OrderKey = @cOrderKey '                        +
                        + @cSubQuery
            SET @cSQLParam =  '@cStorerKey               NVARCHAR(15), '               +
                              '@cOrderKey                NVARCHAR(15), '               +
                              '@nQty                     INT OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
                     @cStorerKey = @cStorerKey,
                     @cOrderKey  = @cOrderKey,
                     @nQty = @nQty OUTPUT

            IF @nQty > 0
            BEGIN
               SET @cExtendedInfo = @cExtendedMsg
            END
            GOTO Quit
         END
      END
   END

   Quit:
GO


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_840ExtInfo13 TO NSQL
GO
