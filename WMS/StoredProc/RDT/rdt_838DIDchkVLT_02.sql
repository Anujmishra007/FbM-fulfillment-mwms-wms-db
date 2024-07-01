SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838DIDchkVLT_02                                 */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 5/17/2024  1.0  PPA374   Packing validations - DROP ID number AND    */
/*                     usage of options.                                */
/* 6/20/2024  1.1  WSE016   Packing validations - Client Pack Matrix    */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_838DIDchkVLT_02] (
   @nMobile         INT,            
   @nFunc           INT,            
   @cLangCode       NVARCHAR( 3),   
   @nStep           INT,            
   @nInputKey       INT,            
   @cFacility       NVARCHAR( 5),   
   @cStorerKey      NVARCHAR( 15),  
   @cPickSlipNo     NVARCHAR( 10),  
   @cFromDropID     NVARCHAR( 20),  
   @nCartonNo       INT,            
   @cLabelNo        NVARCHAR( 20),  
   @cSKU            NVARCHAR( 20),  
   @nQTY            INT,            
   @cUCCNo          NVARCHAR( 20),  
   @cCartonType     NVARCHAR( 10),  
   @cCube           NVARCHAR( 10),  
   @cWeight         NVARCHAR( 10),  
   @cRefNo          NVARCHAR( 20),  
   @cSerialNo       NVARCHAR( 30),  
   @nSerialQTY      INT,            
   @cOption         NVARCHAR( 1),   
   @cPackDtlRefNo   NVARCHAR( 20),  
   @cPackDtlRefNo2  NVARCHAR( 20),  
   @cPackDtlUPC     NVARCHAR( 30),  
   @cPackDtlDropID  NVARCHAR( 20),  
   @cPackData1      NVARCHAR( 30),  
   @cPackData2      NVARCHAR( 30),  
   @cPackData3      NVARCHAR( 30),  
   @nErrNo          INT            OUTPUT,  
   @cErrMsg         NVARCHAR( 20)  OUTPUT
) AS
BEGIN  
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @NeedSerial       INT,
      @OrderKey         NVARCHAR(20),
      @ClientID         NVARCHAR (30),
      @LabelCode        NVARCHAR (30),
      @SkuLimit         INT,
      @SKU              NVARCHAR (30),
      @SKU1             NVARCHAR (30)

   SELECT TOP 1 @NeedSerial = SerialNoCapture FROM SKU (NOLOCK) WHERE sku = @cSKU
   SELECT TOP 1 @OrderKey = OrderKey FROM PICKDETAIL (NOLOCK) WHERE DropID = @cFromDropID

   -- get ConsigneeKey for Client Print Matrix
   SELECT TOP 1 @ClientID = ConsigneeKey FROM ORDERS (NOLOCK) WHERE storerkey = @cStorerKey AND OrderKey = @OrderKey


   -- get Client Pack Matrix
   SELECT 
      @ClientID = code, 
      @LabelCode = Short,
      @SkuLimit = udf01
   FROM CODELKUP WITH (NOLOCK) 
   WHERE LISTNAME ='PackMatrix'
      AND Code = @ClientID

   -- get SKU for Client Pack Matrix
   SELECT @SKU = sku  FROM PicKDetail (NOLOCK) WHERE  DropID = @cFromDropID
   SELECT @SKU1= sku FROM PackDetail (NOLOCK) WHERE CartonNo = @nCartonNo AND DropID = @cPackDtlDropID

   -- WS_20062024 END

   IF @nFunc = 838
   BEGIN
      IF @nStep = 1 
      BEGIN
         IF @cFromDropID = '' OR @cPackDtlDropID = ''
         BEGIN
            SET @nErrNo = 217937
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BothDropIDNeeded
         END

         ELSE IF EXISTS (SELECT 1 FROM PackDetail (NOLOCK) WHERE Dropid = @cPackDtlDropID AND PickSlipNo <> @cPickSlipNo) 
         BEGIN
            SET @nErrNo = 217938
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToDropIDISUsed
         END

         ELSE IF EXISTS (SELECT 1 FROM PickDetail (NOLOCK) WHERE Dropid = @cPackDtlDropID AND @OrderKey <> OrderKey) 
         BEGIN
            SET @nErrNo = 217939
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --OtherOrderDropID
         END

         ELSE IF CHARINDEX(' ',@cPackDtlDropID)>0 OR LEN(@cPackDtlDropID)<>18 OR CONVERT(NVARCHAR(30),substring(@cPackDtlDropID,1,3)) <> '050'
         BEGIN
            SET @nErrNo = 217940
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --WrongFormat
         END

         ELSE IF (1 IN (SELECT short FROM CODELKUP (NOLOCK) WHERE LISTNAME = 'HUSQPICCHK' AND storerkey = @cStorerKey) 
            AND 0 NOT IN (SELECT short FROM CODELKUP (NOLOCK) WHERE LISTNAME = 'HUSQPICCHK' AND storerkey = @cStorerKey)) AND
            EXISTS 
            (SELECT Loc FROM PICKDETAIL PD (NOLOCK)
            WHERE orderkey = @OrderKey
            AND (loc NOT IN
            (SELECT OtherReference FROM MBOL (NOLOCK)
            WHERE mbolkey = 
            (SELECT top 1 mbolkey FROM orders (NOLOCK) WHERE orderkey = @OrderKey))
            AND loc NOT IN (SELECT loc FROM loc (NOLOCK) WHERE locationtype = (SELECT code FROM CODELKUP (NOLOCK) WHERE LISTNAME = 'HUSQPACCHK'))))
         BEGIN
            SET @nErrNo = 217941
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --OrderNotStaged
         END
      END

      -- WS_20062024 Client Pack Validation Matrix
      IF @nStep = 1 AND @LabelCode = 'SINGLE' AND @SKU <> @SKU1 AND @SkuLimit <= (SELECT isnull(COUNT(DISTINCT(sku)),0) FROM PackDetail (NOLOCK) WHERE CartonNo = @nCartonNo AND DropID = @cPackDtlDropID AND PickSlipNo = @cPickSlipNo)
      BEGIN
         SET @nErrNo = 217942
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SingleSKULimit
      END

      IF @nStep = 1 AND @LabelCode = 'MULTI' AND @SkuLimit <= (SELECT isnull(COUNT(DISTINCT(sku)),0) FROM PackDetail (NOLOCK) WHERE CartonNo = @nCartonNo AND DropID = @cPackDtlDropID AND PickSlipNo = @cPickSlipNo)
      BEGIN
         SET @nErrNo = 217943
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultSKULimit
      END

      -- WS_20062024 
      IF @nStep = 3 AND @NeedSerial IN ('1','3') AND @nQTY > 1
      BEGIN
         SET @nErrNo = 217944
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pack 1 EA
      END

      IF @nStep = 2 AND @cOption IN (2,3) AND NOT EXISTS (SELECT 1 FROM PackDetail (NOLOCK) WHERE CartonNo = @nCartonNo AND DropID = @cPackDtlDropID AND PickSlipNo = @cPickSlipNo)
      BEGIN
         SET @nErrNo = 217945
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvCon/DropID
      END

      IF @nStep = 2 AND @cOption = 1 AND EXISTS (SELECT 1 FROM PackDetail (NOLOCK) WHERE CartonNo = @nCartonNo AND DropID = @cPackDtlDropID AND PickSlipNo = @cPickSlipNo)
      BEGIN
         SET @nErrNo = 217946
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Exists,UseEdit
      END
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_838DIDchkVLT_02] TO NSQL
GO  

