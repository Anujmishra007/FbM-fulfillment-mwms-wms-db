SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/
/* Store procedure: rdt_840ExtInfo13                                      */
/* Copyright: MAERSK                                                      */
/* Customer : Kayali                                                      */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2025-04-10 1.0.0  NLT013     FCR-3728. Created                         */
/* 2025-04-16 1.0.1  NLT013     FCR-3728 Add Catch section                */
/* 2025-04-16 1.0.2  NLT013     FCR-3728 CODELKUP join ORDERS             */
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
      @cSQLParam           NVARCHAR( MAX),
      @cExtendedMsg        NVARCHAR( 20),
      @nQty                INT

   IF @nFunc = 840 -- Pack by track no
   BEGIN
      IF @nAfterStep = 5 -- Pick & Pack Completed
      BEGIN
         SELECT TOP 1
            @cSubQuery = CL.Notes,
            @cExtendedMsg = CL.Description
         FROM dbo.CODELKUP CL WITH(NOLOCK)
         INNER JOIN dbo.ORDERS ORM WITH(NOLOCK) ON CL.StorerKey = ORM.StorerKey AND CL.Code = ORM.UserDefine04
         WHERE CL.StorerKey = @cStorerkey
            AND CL.LISTNAME = 'PACKEXTINF'
            AND ORM.OrderKey = @cOrderKey

         IF ISNULL(@cSubQuery, '') <> '' AND ISNULL(@cExtendedMsg, '') <> ''
         BEGIN
            SET @cSQL = ' SELECT @nQty = COUNT(1) FROM dbo.ORDERS WITH(NOLOCK) '       +
                        ' WHERE StorerKey = @cStorerKey '                              +
                        '    AND ORDERS.OrderKey = @cOrderKey '                        +
                        '    AND '                        +
                        + @cSubQuery
            SET @cSQLParam =  '@cStorerKey               NVARCHAR(15), '               +
                              '@cOrderKey                NVARCHAR(15), '               +
                              '@nQty                     INT OUTPUT'

            BEGIN TRY
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
                     @cStorerKey = @cStorerKey,
                     @cOrderKey  = @cOrderKey,
                     @nQty = @nQty OUTPUT
            END TRY
            BEGIN CATCH
               SET @cExtendedInfo = 'SQL Error Happens'
               GOTO Quit
            END CATCH

            IF @nQty > 0
            BEGIN
               SET @cExtendedInfo = @cExtendedMsg
            END
            ELSE
               SET @cExtendedInfo = ''
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
