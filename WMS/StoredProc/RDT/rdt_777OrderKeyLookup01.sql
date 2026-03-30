
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_777OrderKeyLookup01                                   */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: FromDropID, lookup PickSlipNo                                     */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2025-11-19   1.0  Ung        FCR-9200  created                             */
/******************************************************************************/
CREATE OR ALTER PROC rdt.rdt_777OrderKeyLookup01(
    @nMobile      INT
   ,@nFunc        INT
   ,@cLangCode    NVARCHAR( 3)
   ,@nStep        INT
   ,@nInputKey    INT
   ,@cFacility    NVARCHAR( 5)
   ,@cStorerKey   NVARCHAR( 15)
   ,@cSKU         NVARCHAR( 20)
   ,@nQty         INT
   ,@cOrderKey    NVARCHAR( 20)
   ,@cPickSlipNo  NVARCHAR( 10)  OUTPUT
   ,@nMPOCFlag    INT            OUTPUT
   ,@nErrNo       INT            OUTPUT
   ,@cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 777
   BEGIN
      IF @nStep = 1
      BEGIN
         IF @nInputKey = 1
         BEGIN
            EXEC dbo.msp_GetMPOCRequired 
               @c_OrderKey = @cOrderKey,
               @n_MPOCFlag = @nMPOCFlag OUTPUT,
               @b_Success = 1,
               @n_Err = @nErrNo OUTPUT,
               @c_ErrMsg = @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Quit
               
            -- Auto retrieve PickSlipNo
            IF @cPickSlipNo = ''
            BEGIN
               -- Get PickSlipNo
               SELECT @cPickSlipNo = PickSlipNo FROM PackHeader WITH (NOLOCK) WHERE OrderKey = @cOrderKey
               IF @cPickSlipNo = ''
                  SELECT @cPickSlipNo = PickHeaderKey FROM PickHeader WITH (NOLOCK) WHERE OrderKey = @cOrderKey
                  
               -- New PickSlipNo  
               IF @cPickSlipNo = '' 
               BEGIN
                  DECLARE @bSuccess INT
                  EXECUTE dbo.nspg_GetKey  
                     'PICKSLIP',  
                     9,  
                     @cPickSlipNo   OUTPUT,  
                     @bSuccess      OUTPUT,  
                     @nErrNo        OUTPUT,  
                     @cErrMsg       OUTPUT    
                  IF @nErrNo <> 0  
                     GOTO Quit  
            
                  SET @cPickSlipNo = 'P' + @cPickSlipNo  
               END
               
               -- Create PickHeader
               IF NOT EXISTS( SELECT 1 FROM dbo.PickHeader WITH (NOLOCK) WHERE PickHeaderKey = @cPickSlipNo)
               BEGIN
                  INSERT INTO dbo.PickHeader (PickHeaderKey, StorerKey, OrderKey, ExternOrderKey, Priority, Type, Zone, LoadKey)
                  VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, '', '5', '5', '3', '')
                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 251502
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPHdrFail
                     GOTO Quit
                  END
               END
               
               -- Create PackHeader
               IF NOT EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE Pickslipno = @cPickSlipNo)
                  AND @nMPOCFlag = 0
               BEGIN
                  DECLARE @cConsigneeKey NVARCHAR( 15)
                  DECLARE @cLoadKey NVARCHAR( 10)
                  SELECT 
                     @cConsigneeKey = ConsigneeKey, 
                     @cLoadKey = LoadKey
                  FROM Orders WITH (NOLOCK) 
                  WHERE OrderKey = @cOrderKey     

                  INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, ConsigneeKey, LoadKey)
                  VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, @cConsigneeKey, @cLoadKey)
                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 251503
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPHdrFail
                     GOTO Quit
                  END
               END
            END
         END
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_777OrderKeyLookup01] TO NSQL
GO