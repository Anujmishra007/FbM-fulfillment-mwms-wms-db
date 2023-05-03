SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_840ExtPrint15                                   */
/* Purpose: Print carton label                                          */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2021-01-04 1.0  James      WMS-15988. Created                        */
/* 2023-02-15 1.1  YeeKung    WMS-21751 Add shiplabel logic (yeekung01) */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_840ExtPrint15] (
   @nMobile     INT,
   @nFunc       INT,
   @cLangCode   NVARCHAR( 3),
   @nStep       INT,
   @nInputKey   INT,
   @cStorerkey  NVARCHAR( 15),
   @cOrderKey   NVARCHAR( 10),
   @cPickSlipNo NVARCHAR( 10),
   @cTrackNo    NVARCHAR( 20),
   @cSKU        NVARCHAR( 20),
   @nCartonNo   INT,
   @nErrNo      INT           OUTPUT,
   @cErrMsg     NVARCHAR( 20) OUTPUT
)
AS

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cPaperPrinter     NVARCHAR( 10),
           @cLabelPrinter     NVARCHAR( 10),
           @cUserName         NVARCHAR( 18),
           @cFacility         NVARCHAR( 5),
           @cDocType          NVARCHAR( 1),
           @cShippLabel       NVARCHAR( 10),
           @cShipperKey       NVARCHAR( 15)

   DECLARE @tShippLabel    VariableTable

   SELECT @cLabelPrinter = Printer,
          @cFacility = Facility,
          @cUserName = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nInputKey = 1
   BEGIN
      IF @nStep = 4
      BEGIN
         SELECT @cDocType = DocType,
                @cShipperKey = ShipperKey
         FROM dbo.Orders WITH (NOLOCK)
         WHERE Orderkey = @cOrderkey

         IF @cDocType = 'E' AND EXISTS (
            SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK)
            WHERE LISTNAME = 'CartnTrack'
            AND   Code = @cShipperKey
            AND   Storerkey = @cStorerkey)
         BEGIN
            --(yeekung01)
            SELECT @cShippLabel=notes2
            FROM codelkup (nolock)
            where listname='AsgnTNo'
            AND storerkey=@cStorerkey
            AND short =@cShipperKey
            AND notes = @cfacility

            IF ISNULL(@cShippLabel,'') =''
            BEGIN
               SET @cShippLabel = rdt.RDTGetConfig( @nFunc, 'SHIPPLABEL', @cStorerKey)
               IF @cShippLabel = '0'
                  SET @cShippLabel = ''
            END

            IF @cShippLabel <> ''
            BEGIN
              INSERT INTO @tShippLabel (Variable, Value) VALUES ( '@cOrderkey',     @cOrderkey)
              INSERT INTO @tShippLabel (Variable, Value) VALUES ( '@nFromCartonNo',   @nCartonNo)
              INSERT INTO @tShippLabel (Variable, Value) VALUES ( '@nToCartonNo',     @nCartonNo)

              -- Print label
              EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, @cLabelPrinter, '',
                 @cShippLabel, -- Report type
                 @tShippLabel, -- Report params
                 'rdt_840ExtPrint15',
                 @nErrNo  OUTPUT,
                 @cErrMsg OUTPUT
            END
         END
      END   -- IF @nStep = 4
   END   -- @nInputKey = 1

Quit:
GO
GRANT EXECUTE ON  [RDT].[rdt_840ExtPrint15] TO [NSQL]
GO
