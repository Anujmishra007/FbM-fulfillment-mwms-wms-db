SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtVal27                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2025-11-17 1.0  NickT       UWP-43907 Merge from V0 WMS-25533        */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtVal27 (
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

   DECLARE @cOrderKey NVARCHAR( 10)  
   DECLARE @cMsg      NVARCHAR( 20)
               
   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 1 -- PSNO
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Check FROM DROP ID contain multi orders
            IF EXISTS( SELECT TOP 1 1
               FROM dbo.Orders O WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (O.OrderKey = PD.OrderKey) 
                  JOIN dbo.LOC WITH (NOLOCK) ON (PD.LOC = LOC.LOC)
               WHERE O.Status < '9'
                  AND PD.StorerKey = @cStorerKey
                  AND PD.DropID = @cFromDropID
                  AND PD.Status <> '4'
                  AND PD.QTY > 0
               HAVING COUNT( DISTINCT PD.OrderKey) > 1)
            BEGIN
               SET @nErrNo = 220801
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Multi Orders
               EXEC rdt.rdtSetFocusField @nMobile, 2  -- FromDropID
               GOTO Quit
            END
            
            -- Get session info
            DECLARE @cOtherUser NVARCHAR( 128) = ''
            SELECT @cOtherUser = UserName 
            FROM rdt.rdtMobRec WITH (NOLOCK) 
            WHERE Mobile <> @nMobile
               AND Func = @nFunc 
               AND StorerKey = @cStorerKey
               AND V_String20 = @cFromDropID
               AND (Step > 1                                             -- After pickslip screen or
                OR Step = 1 AND @cFromDropID IN (I_Field02, O_Field02))  -- At pickslip screen and had key-in FROM DROP ID
               
            -- Check other user locked from drop ID
            IF @cOtherUser <> ''
            BEGIN
               SET @cMsg = rdt.rdtgetmessage( 220802, @cLangCode, 'DSP') --DROP ID LOCKED BY:
               EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', @cMsg, @cOtherUser
               EXEC rdt.rdtSetFocusField @nMobile, 2  -- FromDropID
               SET @nErrNo = -1
               GOTO Quit
            END
            
            -- Operator try to pack into a new carton
            /*
            IF @cPackDtlDropID = 'NEW'
            BEGIN
               -- Check existing any open carton
               IF EXISTS( SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonType = 'SKIP')
               BEGIN
                  SET @nErrNo = 220803
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --CartonNotClose
                  EXEC rdt.rdtSetFocusField @nMobile, 3  -- FromDropID
                  GOTO Quit
               END
            END
            */
         END
      END
      
      IF @nStep = 3 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Existing carton
            IF @nCartonNo > 0
            BEGIN
               DECLARE @cHazardousFlag NVARCHAR( 30)
               DECLARE @nML            INT = 0 -- milliliter, ml
               DECLARE @nPackingML     INT = 0
               DECLARE @nPackedML      INT = 0
               
               -- Get current SKU info
               SELECT @cHazardousFlag = ISNULL( HazardousFlag, '') 
               FROM dbo.SKU WITH (NOLOCK)
               WHERE SKU.StorerKey = @cStorerKey
                  AND SKU.SKU = @cSKU
               
               -- Current SKU is hazard 
               IF @cHazardousFlag = 'X'
               BEGIN
                  -- Get packed hazard SKU ml
                  SELECT @nPackedML = SUM( ISNULL( TRY_CAST( ExtendedField01 AS INT), 0) * PD.QTY)
                  FROM dbo.PackDetail PD WITH (NOLOCK)
                     JOIN dbo.SKU WITH (NOLOCK) ON (PD.StorerKey = SKU.StorerKey AND PD.SKU = SKU.SKU)
                     LEFT JOIN dbo.SKUInfo SI WITH (NOLOCK) ON (SKU.StorerKey = SI.StorerKey AND SKU.SKU = SI.SKU)
                  WHERE PD.PickSlipNo = @cPickSlipNo
                     AND CartonNo = @nCartonNo
                     AND SKU.HazardousFlag = 'X'

                  -- Get current SKU info
                  SELECT @nML = ISNULL( TRY_CAST( ExtendedField01 AS INT), 0)
                  FROM dbo.SKUInfo WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND SKU = @cSKU
                     
                  -- Calc packing SKU ml
                  SET @nPackingML = @nQTY * @nML
                  
                  -- Check carton over 150 ml
                  IF @nPackingML + @nPackedML > 150
                  BEGIN
                     -- Except when the item itself is already > 150ml and packed alone
                     IF NOT (@nQTY = 1 AND @nML > 150 AND @nPackedML = 0)
                     BEGIN
                        SET @cMsg = rdt.rdtgetmessage( 220807, @cLangCode, 'DSP') --OVER 150ML IN CTN
                        EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', @cMsg
                        EXEC rdt.rdtSetFocusField @nMobile, 3  -- SKU
                        SET @nErrNo = -1
                        GOTO Quit
                     END
                  END
               END
            END
         END
      END
      
      IF @nStep = 4 -- Pack info
      BEGIN
         IF @cCartonType = 'SKIP'
         BEGIN
            DECLARE @cLoadKey  NVARCHAR( 10)  
            DECLARE @cZone     NVARCHAR( 18)  
            DECLARE @nPackQTY  INT  
            DECLARE @nPickQTY  INT  
            DECLARE @cPickStatus  NVARCHAR( 20)  
            DECLARE @cPackConfirm NVARCHAR( 1)  
           
            SET @cOrderKey = ''  
            SET @cLoadKey = ''  
            SET @cZone = ''  
            
            -- Storer config  
            SET @cPickStatus = rdt.rdtGetConfig( @nFunc, 'PickStatus', @cStorerKey)  

            -- Get PickHeader info  
            SELECT TOP 1  
               @cOrderKey = OrderKey,  
               @cLoadKey = ExternOrderKey,  
               @cZone = Zone  
            FROM dbo.PickHeader WITH (NOLOCK)  
            WHERE PickHeaderKey = @cPickSlipNo  
           
            -- Calc pack QTY  
            SET @nPackQTY = 0  
            SELECT @nPackQTY = ISNULL( SUM( QTY), 0) FROM PackDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo  
           
            -- Cross dock PickSlip  
            IF @cZone IN ('XD', 'LB', 'LP')  
            BEGIN  
               -- Check outstanding PickDetail  
               IF EXISTS( SELECT TOP 1 1  
                  FROM dbo.RefKeyLookup RKL WITH (NOLOCK)  
                     JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)  
                  WHERE RKL.PickSlipNo = @cPickSlipNo  
                     AND PD.Status < '5'  
                     AND PD.QTY > 0  
                     AND (PD.Status = '4' OR CHARINDEX( PD.Status, @cPickStatus) = 0))  -- Short or not yet pick  
                  SET @cPackConfirm = 'N'  
               ELSE  
                  SET @cPackConfirm = 'Y'  
                 
               -- Check fully packed  
               IF @cPackConfirm = 'Y'  
               BEGIN  
                  SELECT @nPickQTY = SUM( QTY)   
                  FROM dbo.RefKeyLookup RKL WITH (NOLOCK)  
                     JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)  
                  WHERE RKL.PickSlipNo = @cPickSlipNo  
                    
                  IF @nPickQTY <> @nPackQTY  
                     SET @cPackConfirm = 'N'  
               END  
            END  
           
            -- Discrete PickSlip  
            ELSE IF @cOrderKey <> ''  
            BEGIN  
               -- Check outstanding PickDetail  
               IF EXISTS( SELECT TOP 1 1  
                  FROM dbo.PickDetail PD WITH (NOLOCK)  
                  WHERE PD.OrderKey = @cOrderKey  
                     AND PD.Status < '5'  
                     AND PD.QTY > 0  
                     AND (PD.Status = '4' OR CHARINDEX( PD.Status, @cPickStatus) = 0))  -- Short or not yet pick  
                  SET @cPackConfirm = 'N'  
               ELSE  
                  SET @cPackConfirm = 'Y'  
                 
               -- Check fully packed  
               IF @cPackConfirm = 'Y'  
               BEGIN  
                  SELECT @nPickQTY = SUM( PD.QTY)   
                  FROM dbo.PickDetail PD WITH (NOLOCK)   
                  WHERE PD.OrderKey = @cOrderKey  
                    
                  IF @nPickQTY <> @nPackQTY  
                     SET @cPackConfirm = 'N'  
               END  
            END  
              
            -- Conso PickSlip  
            ELSE IF @cLoadKey <> ''  
            BEGIN  
               -- Check outstanding PickDetail  
               IF EXISTS( SELECT TOP 1 1   
                  FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)   
                     JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey)  
                  WHERE LPD.LoadKey = @cLoadKey  
                     AND PD.Status < '5'  
                     AND PD.QTY > 0  
                     AND (PD.Status = '4' OR CHARINDEX( PD.Status, @cPickStatus) = 0))  -- Short or not yet pick  
                  SET @cPackConfirm = 'N'  
               ELSE  
                  SET @cPackConfirm = 'Y'  
                 
               -- Check fully packed  
               IF @cPackConfirm = 'Y'  
               BEGIN  
                  SELECT @nPickQTY = SUM( PD.QTY)   
                  FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)   
                     JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey)  
                  WHERE LPD.LoadKey = @cLoadKey  
                    
                  IF @nPickQTY <> @nPackQTY  
                     SET @cPackConfirm = 'N'  
               END  
            END  
           
            -- Custom PickSlip  
            ELSE  
            BEGIN  
               -- Check outstanding PickDetail  
               IF EXISTS( SELECT TOP 1 1   
                  FROM PickDetail PD WITH (NOLOCK)   
                  WHERE PD.PickSlipNo = @cPickSlipNo  
                     AND PD.Status < '5'  
                     AND PD.QTY > 0  
                     AND (PD.Status = '4' OR CHARINDEX( PD.Status, @cPickStatus) = 0))  -- Short or not yet pick  
                  SET @cPackConfirm = 'N'  
               ELSE  
                  SET @cPackConfirm = 'Y'  
           
               -- Check fully packed  
               IF @cPackConfirm = 'Y'  
               BEGIN  
                  SELECT @nPickQTY = SUM( PD.QTY)   
                  FROM PickDetail PD WITH (NOLOCK)   
                  WHERE PD.PickSlipNo = @cPickSlipNo  
                    
                  IF @nPickQTY <> @nPackQTY  
                     SET @cPackConfirm = 'N'  
               END  
            END 
            
            -- Pack confirm  
            IF @cPackConfirm = 'Y' 
            BEGIN
               SET @nErrNo = 220804
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Close Last CTN
               EXEC rdt.rdtSetFocusField @nMobile, 1  -- CartonType
               GOTO Quit
            END
         END
         ELSE -- IF @cCartonType <> 'SKIP'
         BEGIN
            DECLARE @cStorerCountry     NVARCHAR( 30)
            DECLARE @cOrderCountry      NVARCHAR( 30)
            DECLARE @cStorerCartonGroup NVARCHAR( 10)
            DECLARE @cSKUCartonGroup    NVARCHAR( 10)
            DECLARE @cCartonGroup       NVARCHAR( 10) = ''

            -- Get storer info
            SELECT 
               @cStorerCartonGroup = CartonGroup, 
               @cStorerCountry = ISNULL( Country, '')
            FROM dbo.Storer WITH (NOLOCK) 
            WHERE StorerKey = @cStorerKey
         
            -- Get SKU info
            SELECT @cSKUCartonGroup = CartonGroup FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU
            
            -- Get order info
            SELECT @cOrderKey = OrderKey FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo
            SELECT @cOrderCountry = C_Country FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey
            
            -- Get carton group
            IF @cOrderCountry = @cStorerCountry -- Local
            BEGIN
               -- Get local carton group
               IF EXISTS( SELECT TOP 1 1 FROM dbo.Cartonization WITH (NOLOCK) WHERE CartonizationGroup = @cStorerCartonGroup + '-' + @cSKUCartonGroup + 'L' )
                  SET @cCartonGroup = @cStorerCartonGroup + '-' + @cSKUCartonGroup + 'L'
            END
            ELSE
            BEGIN
               -- Get international carton group
               IF EXISTS( SELECT TOP 1 1 FROM dbo.Cartonization WITH (NOLOCK) WHERE CartonizationGroup = @cStorerCartonGroup + '-' + @cSKUCartonGroup + 'I' )
                  SET @cCartonGroup = @cStorerCartonGroup + '-' + @cSKUCartonGroup + 'I'
            END
            
            -- Default carton group 
            IF @cCartonGroup = ''
               SET @cCartonGroup = @cStorerCartonGroup + '-' + @cSKUCartonGroup
               
            -- Check SKU level carton type
            IF NOT EXISTS( SELECT 1 
               FROM dbo.Cartonization WITH (NOLOCK)
               WHERE CartonizationGroup = @cCartonGroup
                  AND CartonType = @cCartonType)
            BEGIN
               SET @nErrNo = 220805
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Wrong CTNType
               EXEC rdt.rdtSetFocusField @nMobile, 1  -- CartonType
               GOTO Quit
            END
            
            -- Get OrderDetail info
            DECLARE @cNotes NVARCHAR( 500)
            SELECT TOP 1 
               @cNotes = ISNULL( Notes, '')
            FROM dbo.OrderDetail WITH (NOLOCK) 
            WHERE OrderKey = @cOrderKey 
               AND SKU = @cSKU
            ORDER BY OrderLineNumber
            
            -- VAS
            IF @cNotes <> ''
            BEGIN
               -- VAS group that need carton type
               IF EXISTS( SELECT 1 
                  FROM dbo.CodeLKUP WITH (NOLOCK)
                  WHERE ListName = 'HBVASCODE'
                     AND Code IN (
                        SELECT value
                        FROM STRING_SPLIT( @cNotes, '|')
                        WHERE TRIM( value) <> '')
                     AND Long = 'PACKING'
                     AND Code2 <> '' -- had setup CartonType
                     AND StorerKey = @cStorerKey)
               BEGIN
                  -- Check carton type in that VAS group
                  IF NOT EXISTS( SELECT 1 
                     FROM dbo.CodeLKUP WITH (NOLOCK)
                     WHERE ListName = 'HBVASCODE'
                        AND Code IN (
                           SELECT value
                           FROM STRING_SPLIT( @cNotes, '|')
                           WHERE TRIM( value) <> '')
                        AND Long = 'PACKING'
                        AND Code2 = @cCartonType
                        AND StorerKey = @cStorerKey)
                  BEGIN
                     SET @nErrNo = 220806
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Wrong CTNType
                     EXEC rdt.rdtSetFocusField @nMobile, 1  -- CartonType
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

GRANT EXECUTE ON RDT.rdt_838ExtVal27 TO NSQL
GO
