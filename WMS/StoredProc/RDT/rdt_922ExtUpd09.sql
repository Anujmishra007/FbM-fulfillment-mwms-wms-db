
/************************************************************************/
/* Store procedure: rdt_922ExtUpd09                                     */
/* Customer: LAQUILA Brazil                                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-02-24 1.0  Jackc      FCR-10830.                                */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_922ExtUpd09 (
   @nMobile     INT,
   @nFunc       INT, 
   @cLangCode   NVARCHAR( 3), 
   @nStep       INT, 
   @nInputKey   INT, 
   @cStorerKey  NVARCHAR( 15), 
   @cType       NVARCHAR( 1),
   @cMBOLKey    NVARCHAR( 10),
   @cLoadKey    NVARCHAR( 10),
   @cOrderKey   NVARCHAR( 10), 
   @cLabelNo    NVARCHAR( 20),
   @cPackInfo   NVARCHAR( 3), 
   @cWeight     NVARCHAR( 10),
   @cCube       NVARCHAR( 10),
   @cCartonType NVARCHAR( 10),
   @cDoor       NVARCHAR( 10),
   @cRefNo      NVARCHAR( 40),
   @nErrNo      INT           OUTPUT, 
   @cErrMsg     NVARCHAR( 20) OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF

DECLARE @nDebugFlag  INT = 0

IF @nDebugFlag = 1
   SELECT '922ExtUpd09'

IF @nFunc = 922
BEGIN
   IF @nStep = 2 -- LabelNo/DropID
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'St2, Enter', @cOrderKey AS OrderKey

         DECLARE @cCheckPickDetailDropID  NVARCHAR(1)
         DECLARE @cCheckPackDetailDropID  NVARCHAR(1)
         DECLARE @cExtOrderKey            NVARCHAR(50)
         DECLARE @bSuccess                INT
         DECLARE @nTotalCarton            INT
         DECLARE @nScanCarton             INT
         DECLARE @cMsg1                   NVARCHAR(60),
                 @cMsg2                   NVARCHAR(60),
                 @cMsg3                   NVARCHAR(60)

         SET @cCheckPickDetailDropID = rdt.RDTGetConfig( @nFunc, 'CheckPickDetailDropID', @cStorerKey)
         SET @cCheckPackDetailDropID = rdt.RDTGetConfig( @nFunc, 'CheckPackDetailDropID', @cStorerKey) 
         -- PickDetail
         IF @cCheckPickDetailDropID = '1'
         BEGIN
            SELECT @nTotalCarton = COUNT( DISTINCT PD.DropID)  
            FROM dbo.PickDetail PD WITH (NOLOCK)
            WHERE PD.OrderKey = @cOrderKey        
         END
         ELSE 
         BEGIN
            -- PackDetail
            IF @cCheckPackDetailDropID = '1'
               SELECT @nTotalCarton = COUNT( DISTINCT PD.DropID)  
               FROM dbo.PackHeader PH WITH (NOLOCK)
                  JOIN dbo.PackDetail PD WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)
               WHERE PH.OrderKey = @cOrderKey 
            ELSE
               SELECT @nTotalCarton = COUNT( DISTINCT PD.LabelNo)
               FROM dbo.PackHeader PH WITH (NOLOCK)
                  JOIN dbo.PackDetail PD WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)
               WHERE PH.OrderKey = @cOrderKey 
         END
         SELECT @nScanCarton = COUNT( 1) FROM rdt.rdtScanToTruck WITH (NOLOCK) WHERE OrderKey = @cOrderKey

         IF @nDebugFlag = 1
            SELECT @nTotalCarton AS TotalCarton, @nScanCarton AS ScanCarton

         IF @nTotalCarton = @nScanCarton
         BEGIN
            SELECT @cExtOrderKey = ExternOrderKey FROM dbo.ORDERS WITH (NOLOCK) WHERE OrderKey = @cOrderKey

            SET @cExtOrderKey = ISNULL(@cExtOrderKey, '')

            -- Insert transmitlog2 here  
            EXEC ispGenTransmitLog2   
               @c_TableName        = 'WSScanToTKLOG'  
               ,@c_Key1             = @cOrderkey  
               ,@c_Key2             = @cExtOrderKey  
               ,@c_Key3             = @cStorerkey  
               ,@c_TransmitBatch    = ''  
               ,@b_Success          = @bSuccess    OUTPUT  
               ,@n_err              = @nErrNo      OUTPUT  
               ,@c_errmsg           = @cErrMsg     OUTPUT        

            -- Insert TL2 here only, the web service will do the printing  
            -- quit after excute        
            IF @nErrNo <> 0 OR @bSuccess <> 1
            BEGIN
               IF @nErrNo <> 0
               BEGIN
                  SET @cMsg1 = TRY_CAST(@nErrNo AS NVARCHAR(10))
                  SET @cMsg2 = @cErrMsg
                  SET @cMsg3 = 'Gen WSScanToTKLOG Fail'
                  EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', @cMsg1, @cMsg2, @cMsg3

                  SET @nErrNo = 0 -- do not block process
               END
               GOTO Quit
            END  
         END 
      END
   END
END

Fail:

Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_922ExtUpd09 TO NSQL
GO
