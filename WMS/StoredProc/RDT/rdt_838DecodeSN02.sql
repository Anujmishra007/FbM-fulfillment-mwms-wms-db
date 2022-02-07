if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_838DecodeSN02]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_838DecodeSN02]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Store procedure: rdt_838DecodeSN02                                   */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: Decode semi-colon separated delimeted serial no             */
/*                                                                      */
/* Date        Rev  Author       Purposes                               */
/* 2020-02-27  1.0  James        WMS-12052. Created                     */
/************************************************************************/

CREATE PROCEDURE [RDT].[rdt_838DecodeSN02]
   @nMobile     INT,           
   @nFunc       INT,           
   @cLangCode   NVARCHAR( 3),  
   @nStep       INT,           
   @nInputKey   INT,           
   @cStorerKey  NVARCHAR( 15), 
   @cFacility   NVARCHAR( 5),  
   @cSKU        NVARCHAR( 20),  
   @cBarcode    NVARCHAR( MAX),
   @cSerialNo   NVARCHAR( 30)  OUTPUT,
   @nSerialQTY  INT            OUTPUT,
   @nBulkSNO    INT            OUTPUT,
   @nErrNo      INT            OUTPUT,
   @cErrMsg     NVARCHAR( 20)  OUTPUT 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nReceiveSerialNoLogKey INT
   DECLARE @nSerialNo_Cnt          INT
   DECLARE @nPickQTY               INT
   DECLARE @nPackQTY               INT
   DECLARE @nBalQTY                INT
   DECLARE @nQTY                   INT
   DECLARE @cPickSlipNo            NVARCHAR( 10)

   SELECT @cPickSlipNo = V_PickSlipNo, 
          @nQTY = V_QTY
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   DECLARE @cOrderKey      NVARCHAR( 10) = ''
          ,@cLoadKey       NVARCHAR( 10) = '' 
          ,@cZone          NVARCHAR( 10) = ''
          ,@cPSType        NVARCHAR( 10) = ''
  

   SELECT @cZone = Zone, 
          @cLoadKey = ExternOrderKey,
          @cOrderKey = OrderKey
   FROM dbo.PickHeader WITH (NOLOCK)     
   WHERE PickHeaderKey = @cPickSlipNo

   -- Get PickSlip type      
   IF @@ROWCOUNT = 0
      SET @cPSType = 'CUSTOM'
   ELSE
   BEGIN
      IF @cZone = 'XD' OR @cZone = 'LB' OR @cZone = 'LP'
         SET @cPSType = 'XD'
      ELSE IF @cOrderKey = ''
         SET @cPSType = 'CONSO'
      ELSE 
         SET @cPSType = 'DISCRETE'
   END  

   SELECT @nPackQTY = ISNULL( SUM( Qty), 0)
   FROM dbo.PACKDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND   PickSlipNo = @cPickSlipNo
   AND   SKU = @cSKU
   
   IF @cPSType = 'CUSTOM'
      SELECT @nPickQTY = ISNULL( SUM( Qty), 0)
      FROM dbo.PICKDETAIL WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   PickSlipNo = @cPickSlipNo
      AND   SKU = @cSKU
      AND   [Status] <> 4
   ELSE IF @cPSType = 'XD'
      SELECT @nPickQTY = ISNULL( SUM( Qty), 0)
      FROM dbo.PICKDETAIL PD WITH (NOLOCK)
      JOIN dbo.RefKeyLookup RKL WITH (NOLOCK) ON PD.PickDetailKey = RKL.PickDetailkey
      WHERE PD.StorerKey = @cStorerKey
      AND   RKL.PickSlipNo = @cPickSlipNo
      AND   PD.SKU = @cSKU
      AND   PD.Status <> 4
   ELSE IF @cPSType = 'CONSO'
      SELECT @nPickQTY = ISNULL( SUM( Qty), 0)
      FROM dbo.PICKDETAIL PD WITH (NOLOCK)
      JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK) ON PD.OrderKey = LPD.OrderKey
      WHERE PD.StorerKey = @cStorerKey
      AND   LPD.LoadKey = @cLoadKey
      AND   PD.SKU = @cSKU
      AND   PD.Status <> 4
   ELSE
      SELECT @nPickQTY = ISNULL( SUM( Qty), 0)
      FROM dbo.PICKDETAIL WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   OrderKey = @cOrderKey
      AND   SKU = @cSKU
      AND   [Status] <> 4
   
   SET @nBalQTY = @nPickQTY - @nPackQTY
   
   IF @nBalQTY = 1 OR @nQTY = 1
   BEGIN
      IF CHARINDEX( ';', @cBarCode) > 0 
      BEGIN
         SET @nErrNo = 148801
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'SrCnt NotMatch'
         GOTO Quit
      END

      SET @cSerialNo = LEFT( @cBarCode, 30)
      SET @nSerialQTY = 1
      
      SET @nBulkSNO = 0 -- No
   END
   -- Bulk serial no
   ELSE
   BEGIN
      -- Check serial no scanned match qty to pack (james01)
      SELECT @nSerialNo_Cnt = SUM( LEN( RTRIM( @cBarcode)) - LEN( REPLACE( RTRIM( @cBarcode), ';', '')) + 1)

      IF @nBalQTY < @nSerialNo_Cnt
      BEGIN
         SET @nErrNo = 148802
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'SrCnt NotMatch'
         GOTO Quit
      END

      -- Delete serial no temp table
      WHILE (1=1)
      BEGIN
         SELECT TOP 1 
            @nReceiveSerialNoLogKey = ReceiveSerialNoLogKey 
         FROM rdt.rdtReceiveSerialNoLog WITH (NOLOCK)
         WHERE Mobile = @nMobile
            AND Func = @nFunc

         IF @@ROWCOUNT > 0
            DELETE rdt.rdtReceiveSerialNoLog 
            WHERE ReceiveSerialNoLogKey = @nReceiveSerialNoLogKey
         ELSE
            BREAK      
      END
   
      -- Decode base on delimeter
      INSERT INTO rdt.rdtReceiveSerialNoLog (Mobile, Func, StorerKey, SKU, SerialNo, QTY)
      SELECT @nMobile, @nFunc, @cStorerKey, @cSKU, ColValue, 1
      FROM dbo.fnc_DelimSplit (';', @cBarcode)
      WHERE ColValue <> ''
   
      SET @nBulkSNO = 1 -- Yes
   END
   
Quit:

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON rdt.rdt_838DecodeSN02 TO NSQL 
GO   