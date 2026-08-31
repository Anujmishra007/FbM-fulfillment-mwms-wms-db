
/******************************************************************************/
/* Store procedure: rdt_838PntLblCSC                                          */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose:  Print correct content label after recartonize                    */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 27-03-2026 1.0  AGA399     Create                                          */
/*                                                                            */
/******************************************************************************/

CREATE           PROC [RDT].[rdt_838PntLblCSC] (
 @nMobile          INT,
 @nFunc            INT,
 @cLangCode        NVARCHAR( 3),
 @nStep            INT,  
 @nInputKey        INT,
 @cFacility        NVARCHAR( 5),
 @cStorerKey       NVARCHAR( 15),
 @cPickSlipNo      NVARCHAR( 10),
 @cFromDropID      NVARCHAR( 20),
 @nCartonNo        INT,
 @cLabelNo         NVARCHAR( 20),
 @cSKU             NVARCHAR( 20),
 @nQTY             INT,
 @cUCCNo           NVARCHAR( 20),
 @cCartonType      NVARCHAR( 10),
 @cCube            NVARCHAR( 10),
 @cWeight          NVARCHAR( 10),
 @cRefNo           NVARCHAR( 20),
 @cSerialNo        NVARCHAR( 30),
 @nSerialQTY       INT,
 @cOption          NVARCHAR( 1),
 @cPackDtlRefNo    NVARCHAR( 20),
 @cPackDtlRefNo2   NVARCHAR( 20),
 @cPackDtlUPC      NVARCHAR( 30),
 @cPackDtlDropID   NVARCHAR( 20),
 @cPackData1       NVARCHAR( 30),
 @cPackData2       NVARCHAR( 30),
 @cPackData3       NVARCHAR( 30),
 @nErrNo           INT            OUTPUT,
 @cErrMsg          NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
 SET NOCOUNT ON
 SET QUOTED_IDENTIFIER OFF
 SET ANSI_NULLS OFF
 SET CONCAT_NULL_YIELDS_NULL OFF

 IF @nStep = 5 -- Print label
 BEGIN
 IF @nInputKey = 1 -- ENTER
    BEGIN
       IF @cOption = 1 -- Yes
       BEGIN
          -- Get storer config
          DECLARE @cOrderKey         NVARCHAR( 20)
          DECLARE @cShort            NVARCHAR( 10)
          DECLARE @cLabelPrinter     NVARCHAR( 10)
          DECLARE @cPaperPrinter     NVARCHAR( 10)
          DECLARE @cUserDefine02     NVARCHAR(100)
          DECLARE @tCARTONLBL AS VariableTable

          -- Get session info
          SELECT
             @cLabelPrinter = Printer,
             @cPaperPrinter = Printer_Paper
          FROM rdt.rdtMobRec WITH (NOLOCK)
          WHERE Mobile = @nMobile
          --Recovery Order
          SELECT top 1 @cOrderKey = ph.OrderKey
             FROM PackHeader ph WITH (NOLOCK)
             JOIN PackDetail pd WITH (NOLOCK)
             ON ph.StorerKey = pd.StorerKey
             AND pd.PickSlipNo = ph.PickSlipNo
          WHERE ph.StorerKey = @cStorerKey
             --AND pd.LabelNo = @cLabelNo
      AND ph.PickSlipNo = @cPickSlipNo

          --Get label type
          SELECT @cUserDefine02 = O.USERDEFINE02,@cShort = CL.Short
          FROM ORDERS O WITH(NOLOCK)
          JOIN CODELKUP CL WITH(NOLOCK) ON CL.ListName = 'CSCLBLPRT' AND CL.CODE = O.USERDEFINE02 AND CL.StorerKey = O.StorerKey
          WHERE O.Storerkey = @cStorerKey
          AND O.OrderKey = @cOrderKey
          AND O.doctype <> 'E' AND O.ordergroup <> 'Ecom' AND O.USERDEFINE02 <> 'C9'

          /*SELECT @nCartonNo = CartonNo
          FROM PACKDETAIL WITH(NOLOCK)
          WHERE LabelNo = @cFromDropID*/
 SELECT @cLabelNo = LabelNo
          FROM PACKDETAIL WITH(NOLOCK)
          WHERE PickSlipNo = @cPickSlipNo
 AND CartonNo = @nCartonNo

          IF ISNULL(@cOrderKey, '') <> '' AND ISNULL(@cUserDefine02, '') <> '' AND ISNULL(@cShort, '') <> ''
          BEGIN
             DELETE FROM @tCARTONLBL
             INSERT INTO @tCARTONLBL (Variable, Value) VALUES ( '@cLabelNo', @cLabelNo)
             INSERT INTO @tCARTONLBL (Variable, Value) VALUES ( '@cCartonNo',  @nCartonNo)

             EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                @cShort, -- Report type
                @tCARTONLBL, -- Report params
                'rdt_838PntLblCSC',
                @nErrNo  OUTPUT,
                @cErrMsg OUTPUT
             IF @nErrNo <> 0
                GOTO Quit
          END
       END
    END
 END
Quit:
END
