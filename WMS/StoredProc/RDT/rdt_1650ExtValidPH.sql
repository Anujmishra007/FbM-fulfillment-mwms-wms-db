SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: rdt_1650ExtValidPH                                  */
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
/* 2023-06-01 1.0  MBI165     PHARMA                                    */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1650ExtValidPH] (
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
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER ON
    SET ANSI_NULLS ON

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
            @cMBOL4Pallet               NVARCHAR( 10),
            @cStatus                    NVARCHAR( 10),
            @cLocationType              NVARCHAR( 10)


    SET @nErrNo = 0

    SELECT
        @cFacility = Facility,
        @cMbolKey  = V_String2
    FROM RDT.RDTMOBREC WITH (NOLOCK)
    WHERE MOBILE = @nMobile

    SELECT TOP 1 @cStatus = o.Status
    ,@cOrderKey = O.OrderKey
    FROM DBO.ORDERS O
    WHERE MBOLKey = @cMbolKey

    IF @cStatus IN ('8','9')
    BEGIN
        SET @cMbolKey = ''
    END

    IF ( ISNULL(@cMbolKey,'') = '' AND  @nStep = 3 AND @cOption = '1' )
    BEGIN
        SET @nErrNo = 273051
        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Door
        GOTO Quit
    END
    IF ( ISNULL(@cOrderKey,'') = '' AND  @nStep = 3 AND @cOption = '1' )
    BEGIN
        SET @nErrNo = 273052
        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Door
        GOTO Quit
    END
    IF  ISNULL(@cMbolKey,'') = '' 
    BEGIN
        GOTO Quit
    END


    IF @nInputKey = 1
    BEGIN
        IF @nStep = 1
        BEGIN
            SELECT TOP 1 @cOrderKey = OrderKey
            ,@cLocationType = L.LocationType
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.loc L WITH (NOLOCK) ON L.LOC = PD.LOC AND L.Facility = @cFacility
            WHERE PD.StorerKey = @cStorerKey
                AND   PD.ID = @cPalletID
                AND  PD.Status < '9'

            -- Check if OrderKey exists
            IF ISNULL(@cOrderKey, '') = ''
            BEGIN
                SET @nErrNo = 273053
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Order Found
                GOTO Quit
            END

            --Check if Pallet is in Correct Location Type
            IF @cLocationType in ('PND')
            BEGIN
                SET @nErrNo = 273054
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pallet Not in Dock Lane
                GOTO Quit
            END            

            -- Get the mbolkey for this particular dropid
            SELECT @cMBOL4Pallet = MbolKey
            FROM dbo.MBOLDetail WITH (NOLOCK)
            WHERE OrderKey = @cOrderKey

            -- Every dropid must have associated mbol created. Prompt error if mbol not created
            IF ISNULL( @cMBOL4Pallet, '') = ''
            BEGIN
                SET @nErrNo = 273055
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No mbol create
                GOTO Quit
            END

            IF rdt.RDTGetConfig( @nFunc, 'ScanToDoorCloseTruck', @cStorerkey) <> '1'
            BEGIN
                SET @nErrNo = 273056
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not allow scan
                GOTO Quit
            END

            IF EXISTS ( SELECT 1 FROM rdt.rdtScanToTruck WITH (NOLOCK)
                        WHERE MbolKey = @cMBOL4Pallet
                        AND   RefNo = @cPalletID
                        AND  [Status] = '9')
            BEGIN
                SET @nErrNo = 273057
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
                    SET @nErrNo = 273058
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
                SET @nErrNo = 273059
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Door
                GOTO Quit
            END
        END

        IF @nStep = 3
        BEGIN
            IF @cOption = '2' AND ISNULL(@cOrderKey,'') <> ''
            BEGIN
                IF NOT EXISTS ( SELECT 1
                        FROM dbo.PickDetail PD WITH (NOLOCK)
                        JOIN dbo.MBOLDetail MD WITH (NOLOCK) ON ( PD.OrderKey = MD.OrderKey)
                        ---JOIN DBO.ORDERS O ON MD.MbolKey = O.MBOLKey 
                        WHERE PD.StorerKey = @cStorerKey
                        --AND O.STATUS NOT IN (8,9)   
                        AND   ISNULL( PD.ID, '') <> ''
                        AND   MD.MBOLKey = @cMbolKey
                        AND   NOT EXISTS ( SELECT 1 FROM rdt.rdtScanToTruck ST WITH (NOLOCK)
                                            WHERE MD.MBOLKey = ST.MBOLKey
                                            AND   PD.ID = ST.RefNo
                                            AND   ST.CartonType = 'SCNPT2DOOR'))
                BEGIN 
                    SET @nErrNo = 273060
                    SET @cErrMsg1 = ''
                    SET @cErrMsg2 = rdt.rdtgetmessage( 273061, @cLangCode, 'DSP') -- ALL PALLETS LOADED
                    SET @cErrMsg3 = rdt.rdtgetmessage( 273062, @cLangCode, 'DSP') -- PLEASE CHOOSE
                    SET @cErrMsg4 = rdt.rdtgetmessage( 273063, @cLangCode, 'DSP') -- OPTION 1
                    EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3,@cErrMsg4
                END
            GOTO Quit
            END
            IF @cOption = '1'
            BEGIN
                SET @nCloseTruck = 1

        -- Check if any pallet in the mbol not yet scanned to door
                IF EXISTS ( SELECT 1
                        FROM dbo.PickDetail PD WITH (NOLOCK)
                        JOIN dbo.MBOLDetail MD WITH (NOLOCK) ON ( PD.OrderKey = MD.OrderKey)
                        WHERE PD.StorerKey = @cStorerKey
                        AND   ISNULL( PD.ID, '') <> ''
                        AND   MD.MBOLKey = @cMbolKey
                        AND   NOT EXISTS ( SELECT 1 FROM rdt.rdtScanToTruck ST WITH (NOLOCK)
                                            WHERE MD.MBOLKey = ST.MBOLKey
                                            AND   PD.ID = ST.RefNo
                                            AND   ST.CartonType = 'SCNPT2DOOR'))
                BEGIN
                    SET @nCloseTruck = 0
                END
                    

                IF @nCloseTruck = 0
                BEGIN
                    SET @nErrNo = 0
                    SET @cErrMsg1 = ''
                    SET @cErrMsg2 = rdt.rdtgetmessage( 273064, @cLangCode, 'DSP') -- There are pallets
                    SET @cErrMsg3 = rdt.rdtgetmessage( 273065, @cLangCode, 'DSP') -- not scan to doors.
                    SET @cErrMsg4 = rdt.rdtgetmessage( 273066, @cLangCode, 'DSP') -- Cannot close.
                    EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3,@cErrMsg4
                    IF @nErrNo = 1
                    BEGIN
                        SET @cErrMsg1 = ''
                        SET @cErrMsg2 = ''
                        SET @cErrMsg3 = ''
                    END
                    SET @nErrNo = 273067
                    GOTO Quit
                END
            END
        END    
    END
QUIT:
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1650ExtValidPH] TO NSQL
GO
