SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_593ShipLabel20                                        */
/* Copyright      : Maersk WMS                                                */
/*                                                                            */
/* Purpose: Extended print label                                              */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2024-03-13 1.0  Vikas      UWP-15734 Created                               */
/******************************************************************************/



CREATE OR ALTER PROC [RDT].[rdt_593ShipLabel20] (
   @nMobile    INT,
   @nFunc      INT='',
   @nStep      INT='',
   @cLangCode  NVARCHAR( 3)='ENG',
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 1)='',
   @cParam1    NVARCHAR(20),  -- Label No
   @cParam2    NVARCHAR(20)='',
   @cParam3    NVARCHAR(20)='',
   @cParam4    NVARCHAR(20)='',
   @cParam5    NVARCHAR(20)='',
   @nErrNo     INT OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cFacility        NVARCHAR(  5),
      @cLabelPrinter    NVARCHAR( 10),
      @cPaperPrinter    NVARCHAR( 10),
      @cOrderKey        NVARCHAR( 20),
      @cCustomer        NVARCHAR( 20),
      @cAddress         NVARCHAR( 20),
      @cCity            NVARCHAR( 20),
      @cLoc             NVARCHAR( 20),
      @cSku             NVARCHAR( 20),
      @cQty             NVARCHAR( 10),
      @cPalletID        NVARCHAR( 20),
      @cShipment        NVARCHAR( 20),
      @nWight           NVARCHAR( 10),
      @cShipLabel       NVARCHAR(10)

   -- Parameter mapping
   SET @cPalletID = @cParam1

   -- Check blank
   IF @cPalletID = ''
   BEGIN
      SET @nErrNo = 121651
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Need DropID
      GOTO Quit
   END

   -- Get login info
   SELECT
         @cFacility = Facility,
         @cLabelPrinter = Printer,
         @cPaperPrinter = Printer_Paper
   FROM rdt.rdtMobrec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Storer configure
   SET @cShipLabel = rdt.rdtGetConfig( @nFunc, 'ShipLabel', @cStorerKey)

   DECLARE cursor_product CURSOR LOCAL FOR

   SELECT
      O.ORDERKEY,
      TD.FinalLOC,
      ORD.SKU,
      SUM(PKD.QTY),
      CASE WHEN MAX(S.STDGROSSWGT)>0 THEN (SUM(PKD.QTY)*MAX(S.STDGROSSWGT)/1000) ELSE SUM(PKD.QTY) END ,
      MD.MbolKey
   FROM ORDERS O WITH (NOLOCK) JOIN ORDERDETAIL ORD WITH (NOLOCK)
      ON ORD.OrderKey=O.OrderKey AND ORD.StorerKey=O.StorerKey
   JOIN PICKDETAIL PKD WITH (NOLOCK)
      ON PKD.OrderKey=ORD.OrderKey AND PKD.OrderLineNumber=ORD.OrderLineNumber
   JOIN MBOLDETAIL MD WITH (NOLOCK)
      ON MD.OrderKey=PKD.OrderKey
   JOIN TASKDETAIL TD WITH (NOLOCK)
      ON TD.TaskDetailKey=PKD.TaskDetailKey
   JOIN SKU S WITH (NOLOCK)
      ON S.SKU=ORD.SKU AND S.StorerKey=ORD.StorerKey
   WHERE ((PKD.ID=@cPalletID AND TD.PICKMETHOD='FP') OR ( PKD.DropID= @cPalletID  AND TD.PICKMETHOD='PP'))
     AND PKD.Storerkey= @cStorerKey AND PKD.Status IN (5,9)
   GROUP BY
      O.ORDERKEY,
      ORD.SKU,
      PKD.ID,
      TD.FinalLOC,
      MD.MbolKey

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 121652
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Invalid DropID
      GOTO Quit
   END

   OPEN cursor_product;

   FETCH NEXT FROM cursor_product INTO
      @cOrderKey,
      @cLoc,
      @cSku,
      @cQty,
      @nWight,
      @cShipment;

   WHILE @@FETCH_STATUS = 0
   BEGIN
      DECLARE @tShipLabel AS VariableTable
      INSERT INTO @tShipLabel (Variable, Value) VALUES
      ('@cOrderKey',@cOrderKey),
      ('@cLoc'     ,@cLoc     ),
      ('@cSku'     ,@cSku     ),
      ('@cQty'     ,@cQty     ),
      ('@nWight'   ,@nWight   ),
      ('@cShipment',@cShipment),
      ('@cPalletID',@cPalletID),
      ('@cStorerKey',@cStorerKey)

      -- Print label
      EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
           @cShipLabel, -- Report type
           @tShipLabel, -- Report params
           'rdt_593ShipLabel20',
           @nErrNo  OUTPUT,
           @cErrMsg OUTPUT
      DELETE from @tShipLabel
      IF @nErrNo <> 0
         GOTO Quit
      FETCH NEXT FROM cursor_product INTO
         @cOrderKey,
         @cLoc,
         @cSku,
         @cQty,
         @nWight,
         @cShipment;
   END;

   CLOSE cursor_product;

   DEALLOCATE cursor_product;


   Quit:
END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_600ExtScnEntry TO NSQL
GO
