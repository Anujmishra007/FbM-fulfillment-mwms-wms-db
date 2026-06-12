
/************************************************************************/
/* Store procedure: rdt_1650ExtValCSC                                   */
/* Purpose: If rdt config AllowPartialScanToDoor is turned on and       */
/*          orders is partially picked, return true else false          */
/*          If rdt config ScanToDoorCloseTruck is turned on then check  */
/*          whether all pallet for this mbol has been scanned to door   */
/*                                                                      */
/*          check if PackSlipReport was printed  for CSCUK01            */
/*                                                                      */
/* Called from: rdtfnc_Scan_Pallet_To_Door                              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-03-24 1.0  AGA399      Created                                  */
/************************************************************************/

CREATE       PROC [RDT].[rdt_1650ExtValCSC] (
 @nMobile          INT,
 @nFunc            INT,
 @cLangCode        NVARCHAR( 3),
 @nStep            INT,
 @nInputKey        INT,
 @cStorerKey       NVARCHAR( 15),
 @cPalletID        NVARCHAR( 18),
 @cMbolKey         NVARCHAR( 10),
 @cDoor            NVARCHAR( 20),
 @cOption          NVARCHAR( 1),
 @nAfterStep       INT,
 @nErrNo           INT           OUTPUT,
 @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF

 DECLARE @cAllowPartialScanToDoor    NVARCHAR( 1),
         @nCloseTruck                INT,
         @cOrderKey                  NVARCHAR( 10),
         @cErrMsg1                   NVARCHAR( 20),
         @cErrMsg2                   NVARCHAR( 20),
         @cErrMsg3                   NVARCHAR( 20),
         @cErrMsg4                   NVARCHAR( 20),
         @cErrMsg5                   NVARCHAR( 20),
         @cFacility                  NVARCHAR( 5),
         @cID                        NVARCHAR( 18),
         @cMBOL4Pallet               NVARCHAR( 10)


 SET @nErrNo = 0

 SELECT
    @cFacility = Facility,
    @cMbolKey  = V_String2
 FROM RDT.RDTMOBREC WITH (NOLOCK)
 WHERE MOBILE = @nMobile

 IF @nInputKey = 1
 BEGIN
    IF @nStep = 1
    BEGIN
       SELECT TOP 1 @cOrderKey = OrderKey
       FROM dbo.PickDetail WITH (NOLOCK)
       WHERE StorerKey = @cStorerKey
       AND   ID = @cPalletID
       AND  [Status] < '9'

       IF ISNULL(@cOrderKey, '') = ''
       BEGIN
          SET @nErrNo = 202001
          SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Order Found
          GOTO Quit
       END

       -- Get the mbolkey for this particular dropid
       SELECT @cMBOL4Pallet = MbolKey
       FROM dbo.MBOLDetail WITH (NOLOCK)
       WHERE OrderKey = @cOrderKey

       -- Every dropid must have assocaited mbol created. Prompt error if mbol not created
       IF ISNULL( @cMBOL4Pallet, '') = ''
       BEGIN
          SET @nErrNo = 202002
          SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No mbol create
          GOTO Quit
       END

       /*AGA399 24/03/26 CSCUK01 check if PackDetail was printed*/
       IF EXISTS ( SELECT 1 FROM dbo.PickDetail PD WITH (NOLOCK)
          JOIN ORDERS O (NOLOCK) ON PD.StorerKey = O.StorerKey AND PD.OrderKey = O.OrderKey AND O.UserDefine03 <> '001'
          JOIN PACKHEADER PH WITH (NOLOCK) ON PD.StorerKey = PH.StorerKey AND PD.OrderKey = PH.OrderKey
          JOIN CODELKUP CL (NOLOCK) ON O.UserDefine03 = CL.Code AND CL.ListName = 'CSPACKSLIP' AND CL.StorerKey = @cStorerKey
          WHERE PD.StorerKey = @cStorerKey
             AND PD.ID = @cPalletID
             AND PH.ManifestPrinted = '0'
       )
       BEGIN
          SET @nErrNo = 180021
          SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') -- Please Print PackSlip (Manifest) report to continue
          GOTO Quit
       END
       /*AGA399 24/03/26 CSCUK01 check if PackDetail was printed*/


       IF rdt.RDTGetConfig( @nFunc, 'ScanToDoorCloseTruck', @cStorerkey) <> '1'
       BEGIN
          SET @nErrNo = 202003
          SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not allow scan
          GOTO Quit
       END

       IF EXISTS ( SELECT 1 FROM rdt.rdtScanToTruck WITH (NOLOCK)
                   WHERE MbolKey = @cMBOL4Pallet
                   AND   RefNo = @cPalletID
                   AND  [Status] = '9')
       BEGIN
          SET @nErrNo = 202004
          SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IDLoaded2Door
          GOTO Quit
       END

       SET @cAllowPartialScanToDoor = rdt.RDTGetConfig( @nFunc, 'AllowPartialScanToDoor', @cStorerKey)
       IF ISNULL( @cAllowPartialScanToDoor, '') IN ('', '0')
          SET @cAllowPartialScanToDoor = 0

       IF @cAllowPartialScanToDoor = 0
       BEGIN
          -- Check if any this pallet has something not picked
          IF EXISTS ( SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)
                      WHERE StorerKey = @cStorerKey
                      AND   ID = @cPalletID
                      AND  [Status] < '5')
          BEGIN
             SET @nErrNo = 202005
             SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Partial Picked
             GOTO Quit
          END
       END
    END

    IF @nStep = 2
    BEGIN
       -- Make sure the door scanned is the same with mbol.placeofloading that dropid belong
       IF NOT EXISTS ( SELECT 1 from dbo.MBOL WITH (NOLOCK)
                       WHERE MbolKey = @cMbolKey
                       AND PlaceOfLoading = @cDoor)
       BEGIN
          SET @nErrNo = 202006
          SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Door
          GOTO Quit
       END
    END
 END


QUIT:
