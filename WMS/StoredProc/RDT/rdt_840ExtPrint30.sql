SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_840ExtPrint30                                   */
/* Purpose: Print carton label                                          */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2023-11-16 1.0  James      WMS-24113. Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_840ExtPrint30] (
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
           @cShippLabel       NVARCHAR( 10),
           @cPrtInvoice       NVARCHAR( 10),
           @nExpectedQty      INT = 0,
           @nPackedQty        INT = 0,
           @nNoOfCopy         INT = 0,
           @cNoOfCopy         NVARCHAR( 2),
           @cShipperKey       NVARCHAR( 15),
           @cLabelType        NVARCHAR( 10),
           @cBTPrinterID      NVARCHAR( 10),
           @cDocType          NVARCHAR( 1),
           @cType             NVARCHAR( 10)
           
   DECLARE @tShippLabel    VariableTable
   DECLARE @tPrtInvoice    VariableTable

   SELECT @cLabelPrinter = Printer,
          @cPaperPrinter = Printer_Paper,
          @cFacility = Facility,
          @cUserName = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nInputKey = 1
   BEGIN
      IF @nStep = 4
      BEGIN
         SELECT @nExpectedQty = ISNULL(SUM(Qty), 0) FROM PickDetail WITH (NOLOCK)
         WHERE Orderkey = @cOrderkey
            AND Storerkey = @cStorerkey
            AND Status < '9'

         SELECT @nPackedQty = ISNULL(SUM(Qty), 0) FROM dbo.PackDetail WITH (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo

         IF @nExpectedQty > @nPackedQty
            GOTO Quit

         SET @cShippLabel = rdt.RDTGetConfig( @nFunc, 'SHIPPLABEL', @cStorerkey)
         IF @cShippLabel = '0'
            SET @cShippLabel = ''

         IF @cShippLabel <> ''
         BEGIN
            -- First label print(Order label)
            -- Get first LabelType 
            SET @cLabelType = ''
            SELECT @cLabelType = Notes2
            FROM dbo.CODELKUP WITH (NOLOCK)
            WHERE LISTNAME = 'RDTPACKPRT'
            AND   Code = '001'
            AND   StorerKey = @cStorerkey
            AND   Notes = @cFacility


            -- Get LabelPrinter to print out
            SELECT @cBTPrinterID = BTPrinterID
            FROM dbo.BartenderLabelCfg WITH (NOLOCK)
            WHERE StorerKey = @cStorerkey
            AND   LabelType = @cLabelType
            AND   Key02 = @cUserName
 
            -- Send first order label print
            INSERT INTO @tShippLabel (Variable, Value) VALUES ( '@cOrderkey',       @cOrderkey)
            INSERT INTO @tShippLabel (Variable, Value) VALUES ( '@nFromCartonNo',   @nCartonNo)
            INSERT INTO @tShippLabel (Variable, Value) VALUES ( '@nToCartonNo',     @nCartonNo)
            
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, @cBTPrinterID, '',
               @cShippLabel, -- Report type
               @tShippLabel, -- Report params
               'rdt_840ExtPrint30',
               @nErrNo  OUTPUT,
               @cErrMsg OUTPUT

            -- Second label print(Courier label)
            -- Get LabelType 
            SET @cLabelType = ''
            SELECT @cLabelType = Notes2
            FROM dbo.CODELKUP WITH (NOLOCK)
            WHERE LISTNAME = 'RDTPACKPRT'
            AND   Code = '002'
            AND   StorerKey = @cStorerkey
            AND   Notes = @cFacility

            -- Get ORDERS. DOCTYPE, ORDERS.SHIPPERKEY, ORDERS.TYPE from ORDERS table.
            SELECT 
               @cDocType = DocType,
               @cShipperKey = ShipperKey,
               @cType = Type
            FROM dbo.Orders WITH (NOLOCK)
            WHERE Orderkey = @cOrderkey

            -- Get label template.
            SELECT @cShippLabel = LabelType
            FROM dbo.BartenderLabelCfg WITH (NOLOCK)
            WHERE StorerKey = @cStorerkey
            AND   LabelType = @cLabelType
            AND   Key04 = @cShipperKey
            AND   Key05 = @cType

            -- Send Second Courier label print
            INSERT INTO @tShippLabel (Variable, Value) VALUES ( '@cOrderkey',       @cOrderkey)
            INSERT INTO @tShippLabel (Variable, Value) VALUES ( '@nFromCartonNo',   @nCartonNo)
            INSERT INTO @tShippLabel (Variable, Value) VALUES ( '@nToCartonNo',     @nCartonNo)

            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, @cLabelPrinter, '',
               @cShippLabel, -- Report type
               @tShippLabel, -- Report params
               'rdt_840ExtPrint16',
               @nErrNo  OUTPUT,
               @cErrMsg OUTPUT
         END
         
         SET @cPrtInvoice = rdt.RDTGetConfig( @nFunc, 'PrtInvoice', @cStorerkey)
         IF @cPrtInvoice = '0'
            SET @cPrtInvoice = ''

         IF @cPrtInvoice <> ''
         BEGIN
            INSERT INTO @tPrtInvoice (Variable, Value) VALUES ( '@cOrderkey',     @cOrderkey)

            -- Print label
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, '', @cPaperPrinter,
               @cPrtInvoice, -- Report type
               @tPrtInvoice, -- Report params
               'rdt_840ExtPrint30',
               @nErrNo  OUTPUT,
               @cErrMsg OUTPUT
         END
      END   -- IF @nStep = 4
   END   -- @nInputKey = 1

Quit:
GO
GRANT EXECUTE ON  [RDT].[rdt_840ExtPrint30] TO [NSQL]
GO
