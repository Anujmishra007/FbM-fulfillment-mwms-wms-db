if exists (select * from dbo.sysobjects where id = object_id(N'rdt.rdt_1650ExtValid01') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure rdt.rdt_1650ExtValid01
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1650ExtValid01                                  */
/* Purpose: If rdt config AllowPartialScanToDoor is turned on and       */
/*          orders is partially picked, return true else false          */
/*          If rdt config ScanToDoorCloseTruck is turned on then check  */
/*          whether all pallet for this mbol has been scanned to door   */
/*                                                                      */
/* Called from: rdtfnc_Scan_Pallet_To_Door                              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2015-02-09 1.0  James      SOS316783 - Created                       */
/* 2016-02-05 1.1  James      Check pallet must PA to stage (james01)   */
/************************************************************************/

CREATE PROC rdt.rdt_1650ExtValid01 (
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

   SELECT @cFacility = Facility 
   FROM RDT.RDTMOBREC WITH (NOLOCK) 
   WHERE MOBILE = @nMobile

   IF @nInputKey = 1 
   BEGIN
      SELECT TOP 1 @cOrderKey = OrderKey 
      FROM dbo.PickDetail WITH (NOLOCK) 
      WHERE StorerKey = @cStorerKey
      AND   ID = @cPalletID
      AND  [Status] < '9'

      IF ISNULL(@cOrderKey, '') = ''
      BEGIN
         SET @nErrNo = 92901   
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Order Found
         GOTO Quit
      END

      -- Get the mbolkey for this particular dropid
      SELECT @cMBOL4Pallet = MbolKey 
      FROM dbo.MBOLDetail WITH (NOLOCK) 
      WHERE OrderKey = @cOrderKey

      IF @nStep = 1
      BEGIN
         -- Every dropid must have assocaited mbol created. Prompt error if mbol not created
         IF ISNULL( @cMBOL4Pallet, '') = ''
         BEGIN
            SET @nErrNo = 92902   
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No mbol create 
            GOTO Quit
         END

         IF rdt.RDTGetConfig( @nFunc, 'ScanToDoorCloseTruck', @cStorerkey) <> '1'
         BEGIN
            SET @nErrNo = 92910   
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not allow scan 
            GOTO Quit
         END

         IF EXISTS ( SELECT 1 FROM rdt.rdtScanToTruck WITH (NOLOCK) 
                     WHERE MbolKey = @cMBOL4Pallet
                     AND   RefNo = @cPalletID
                     AND  [Status] = '9')
         BEGIN
            SET @nErrNo = 92911   
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
               SET @nErrNo = 92903   
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Partial Picked
               GOTO Quit
            END

            -- Check if all pallet already putaway to staging area (james01)
            IF OBJECT_ID('tempdb..#TMP_ORDERS') IS NOT NULL   
               DROP TABLE #TMP_ORDERS

            CREATE TABLE #TMP_ORDERS ( OrderKey NVARCHAR(10) NULL DEFAULT (''))  

            INSERT INTO #TMP_ORDERS ( OrderKey)
            SELECT DISTINCT OrderKey
            FROM dbo.PickDetail WITH (NOLOCK) 
            WHERE StorerKey = @cStorerKey
            AND   ID = @cPalletID
            AND  [Status] < '9'

            IF EXISTS ( SELECT 1 FROM dbo.PickDetail PD WITH (NOLOCK) 
                        JOIN #TMP_ORDERS O WITH (NOLOCK) ON ( PD.OrderKey = O.OrderKey)
                        JOIN dbo.LOC LOC WITH (NOLOCK) ON ( PD.LOC = LOC.LOC)
                        WHERE PD.StorerKey = @cStorerKey
                        AND   PD.Status < '9'
                        AND   LOC.LocationCategory <> 'STAGING')
            BEGIN
               SET @nErrNo = 92904   
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PLT NOT ALL PA
               GOTO Quit
            END
         END

         IF EXISTS ( SELECT 1 FROM dbo.PickDetail PD WITH (NOLOCK) 
                     JOIN dbo.LOC LOC WITH (NOLOCK) ON ( PD.LOC = LOC.LOC)
                     WHERE PD.StorerKey = @cStorerKey
                     AND   PD.Status < '9'
                     AND   PD.ID = @cPalletID
                     AND   LOC.LocationCategory <> 'STAGING')
         BEGIN
            SET @nErrNo = 92912   
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PLT NOT AT STG
            GOTO Quit
         END

         -- Check if DropID (pallet for merlion) has any qty not picked on pallet
         -- Return error if something not picked and cannot scan to door
         IF EXISTS ( SELECT 1 
                     FROM dbo.LOTxLOCxID LLI WITH (NOLOCK) 
                     JOIN dbo.LOC LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)
                     WHERE LOC.Facility = @cFacility
                     AND   LLI.ID = @cPalletID
                     GROUP BY LLI.ID
                     HAVING ISNULL( SUM( LLI.QTY - LLI.QTYAllocated - LLI.QTYPicked), 0) > 0)
         BEGIN
            SET @nErrNo = 92905   
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pl has avl qty
            GOTO Quit
         END
      END

      IF @nStep = 2
      BEGIN
         -- Make sure the door scanned is the same with mbol.placeofloading that dropid belong
         IF NOT EXISTS ( SELECT 1 from dbo.MBOL WITH (NOLOCK) 
                         WHERE MbolKey = @cMBOL4Pallet 
                         AND PlaceOfLoading = @cDoor)
         BEGIN
            SET @nErrNo = 92909   
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Door
            GOTO Quit
         END
      END

      IF @nStep = 3
      BEGIN
         IF @cOption = '2'
            GOTO Quit

         SET @nCloseTruck = 1

         -- Check if any pallet in the mbol not yet scanned to door
         IF EXISTS ( SELECT 1 
                     FROM dbo.PickDetail PD WITH (NOLOCK) 
                     JOIN dbo.MBOLDetail MD WITH (NOLOCK) ON ( PD.OrderKey = MD.OrderKey)
                     WHERE PD.StorerKey = @cStorerKey
                     AND   ISNULL( PD.ID, '') <> ''
                     AND   MD.MBOLKey = @cMbolKey
                     AND   EXISTS ( SELECT 1 FROM rdt.rdtScanToTruck ST WITH (NOLOCK) 
                                    WHERE MD.MBOLKey = ST.MBOLKey 
                                    AND   ST.CartonType = 'SCNPT2DOOR'))
         BEGIN
            SET @nCloseTruck = 0
         END

         IF @nCloseTruck = 0
         BEGIN
            INSERT INTO TRACEINFO (TRACENAME, TIMEIN, COL1, COL2, COL3) VALUES ('SCNPT2DOOR', GETDATE(), @cPalletID, @cMbolKey, '92906')
            SET @nErrNo = 92906
            SET @cErrMsg1 = SUBSTRING( rdt.rdtgetmessage( 92906, @cLangCode, 'DSP'), 7, 20) -- There are pallets
            SET @cErrMsg2 = SUBSTRING( rdt.rdtgetmessage( 92907, @cLangCode, 'DSP'), 7, 20) -- not scan to doors.
            SET @cErrMsg3 = SUBSTRING( rdt.rdtgetmessage( 92908, @cLangCode, 'DSP'), 7, 20) -- Cannot close.
            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
            GOTO Quit
         END

      END
   END


QUIT:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1650ExtValid01 TO NSQL
GO
