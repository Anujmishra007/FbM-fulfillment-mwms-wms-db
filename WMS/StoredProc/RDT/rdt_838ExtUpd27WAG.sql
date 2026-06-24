
/*********************************************************************************/
/* Store procedure: rdt_838ExtUpd27WAG                                              */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose: Extended Upd for Whiteaway                                             */
/*                                                                               */
/* Date       Rev  Author      Purposes                                          */
/* 2025-11-13 1.0  Jackc       FCR-8974 Created                                  */
/* 2026-02-03 1.1  Dennis      FCR-8931                                          */
/* 2026-05-20 1.2  JackR       Copy rdt_838ExtUpd27 for WAG implementation        */
/*********************************************************************************/

CREATE OR ALTER     PROC [RDT].[rdt_838ExtUpd27WAG] (
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

   DECLARE  @cOrderKey     NVARCHAR(10),
			@cDelServiceList NVARCHAR(10) = 'DELSERVICE',
			@cDelService	NVARCHAR(30),
			@cShipLabel        NVARCHAR(10),
			@tReportParam AS VariableTable,
            @cLabelPrinter     NVARCHAR(10),
            @cPaperPrinter     NVARCHAR(10),            
			@nRowCount     INT,
      @nCartonLength				FLOAT,		
	  @nCartonWidth				FLOAT,	
	  @nCartonHeight				FLOAT

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 4 -- Carton Type
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            --IF @cOption = 1 -- Yes
            BEGIN
               DECLARE @bSuccess             INT

               SELECT TOP 1
               @nCartonLength = CartonLength
               ,@nCartonWidth = CartonWidth
               ,@nCartonHeight = CartonHeight
               FROM dbo.Cartonization (NOLOCK) 
               WHERE CartonizationGroup = @cStorerKey
               AND CartonType = @cCartonType

               UPDATE dbo.PackInfo
               SET Length = @nCartonLength
               ,Width = @nCartonWidth
               ,Height = @nCartonHeight
               WHERE PickSlipNo = @cPickSlipNo
               AND CartonNo = @nCartonNo
               AND CartonType = @cCartonType

               SELECT TOP 1 @cOrderKey = PH.OrderKey,
			      @cDelService = O.UserDefine02
               FROM PickHeader PH WITH (NOLOCK)
			      JOIN dbo.Orders O (NOLOCK) ON O.StorerKey = PH.StorerKey AND O.OrderKey = PH.OrderKey
               WHERE PH.StorerKey = @cStorerKey
			      AND PH.PickHeaderKey = @cPickSlipNo

               SET @nRowCount = @@ROWCOUNT
			      IF @nRowCount = 0
               BEGIN
                  SET @nErrNo = 250501
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Order not Found
                  GOTO Quit
               END

               IF @nRowCount <> 0 AND ISNULL(@cOrderKey, '') <> '' AND ISNULL(@cDelService,'') <> ''
               BEGIN
				      IF EXISTS(SELECT 1 FROM dbo.Codelkup WITH (NOLOCK)
							WHERE Storerkey = @cStorerKey
							AND ListName = @cDelServiceList
							AND Code = @cDelService 
							AND UDF02 = 'TMS_ENABLED')
				      BEGIN 					
                     --Create new Transmitlog2 record
                     EXECUTE ispGenTransmitLog2 
                     @c_TableName      = 'WSPACKCFMLOG', 
                     @c_Key1           = @cOrderKey, 
                     @c_Key2           = @cLabelNo, 
                     @c_Key3           = @cStorerkey, 
                     @c_TransmitBatch  = '', 
                     @b_Success        = @bSuccess   OUTPUT,    
                     @n_err            = @nErrNo     OUTPUT,    
                     @c_errmsg         = @cErrMsg    OUTPUT

                     IF @nErrNo <> 0 OR @bSuccess <> 1
                        GOTO Quit
			         END
               END
               GOTO Quit
            END -- option=1
         END -- key=1
      END -- step5
   END -- 838

   GOTO Quit

   Quit:  

END--sp

GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
GRANT EXECUTE ON RDT.rdt_838ExtUpd27WAG TO NSQL
GO
