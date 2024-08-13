
/******************************************************************************/  
/* Store procedure: rdt_838ExtSNUpdVLT                                        */    
/*                                                                            */  
/* Date         Author   Purposes                                             */  
/* 22/05/2024   PPA374   Insert SN data in the Serial Number table            */  
/* 08/08/2024   PPA374   Amended as per review comments                       */
/******************************************************************************/  
  
CREATE OR ALTER PROCEDURE [RDT].[rdt_838ExtSNUpdVLT]  
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 3),
   @cStorerKey   NVARCHAR( 15),
   @cSKU         NVARCHAR( 20),
   @nQTY         INT,
   @cSerialNo    NVARCHAR( 30),
   @cType        NVARCHAR( 15), --CHECK/INSERT
   @cDocType     NVARCHAR( 10),
   @cDocNo       NVARCHAR( 20),
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR( 20) OUTPUT
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @nRowCount  INT  
   DECLARE @cChkStatus NVARCHAR(10)  
   DECLARE @cChkExternStatus NVARCHAR(10)  
  
   IF @nFunc = 838 and @nStep = 9 and @nInputKey = 1 --Pack, Serial number screen
   BEGIN  
      IF exists (select 1 from SerialNo (NOLOCK) where StorerKey = @cStorerKey and SerialNo = @cSerialNo)
      BEGIN
         SET @nErrNo = 218003
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') -- 'SN is already used' 
         GOTO quit
      END
      
      DECLARE 
      @cSerialNoKey NVARCHAR(20),
      @cOrderLineNumber NVARCHAR(5),
      @bsuccess INT =0,
      @cOrderkey NVARCHAR(20)

      -- Get serial no info  
      SELECT TOP 1  
      @cChkStatus = Status,   
      @cChkExternStatus = ExternStatus  
      FROM SerialNo WITH (NOLOCK)  
      WHERE StorerKey = @cStorerKey  
      AND SKU = @cSKU  
      AND SerialNo = @cSerialNo  
      SET @nRowCount = @@ROWCOUNT  
  
      -- Check SNO in ASN  
      IF @nRowCount = 0  
      BEGIN  
         
         EXECUTE dbo.nspg_GetKey  
         'SerialNo',  
         10 ,  
         @cSerialNoKey      OUTPUT,  
         @bsuccess          OUTPUT,  
         @nErrNo            OUTPUT,  
         @cErrMsg           OUTPUT  
                 
         IF @bsuccess <> 1  
         BEGIN  
            SET @nErrNo = 151351   
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') -- 'GetKeyFail'  
            GOTO Quit
         END  

      select top 1 @cOrderkey = PD.Orderkey 
      FROM dbo.PickDetail PD WITH (NOLOCK)  
         JOIN PICKHEADER PH (NOLOCK)
      ON PH.OrderKey = PD.OrderKey
         WHERE PD.StorerKey = @cStorerKey  
         AND PH.PickHeaderKey = @cDocNo  
         AND PD.SKU = @cSKU  

      select top 1 @cOrderLineNumber = OrderLineNumber
      from PICKDETAIL PD (NOLOCK)
      where orderkey = @cOrderkey
      and storerkey = @cStorerKey
      and sku = @cSKU
      and (select sum(qty) from PICKDETAIL (NOLOCK) where orderkey = @cOrderkey and storerkey = @cStorerKey and sku = @cSKU) 
      - (select isnull(sum(qty),0) from SerialNo SN (NOLOCK) where SN.OrderKey = PD.OrderKey and SN.OrderLineNumber = PD.OrderLineNumber and Storerkey = @cStorerKey) > 0
      order by OrderLineNumber
            
         INSERT INTO SerialNo (SerialNoKey, OrderKey, OrderLineNumber, StorerKey, SKU, SerialNo, Qty)   
         VALUES (@cSerialNoKey, @cOrderkey,@cOrderLineNumber, @cStorerKey, @cSKU , @cSerialNo , 1)
              
         IF @@ERROR <> 0   
         BEGIN   
            SET @nErrNo = 151352  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsSerialNoFail  
            GOTO Quit    
         END
      END  
   END

Quit:  
  
END  

GRANT EXECUTE ON [RDT].[rdt_838ExtSNUpdVLT] TO [NSQL]
