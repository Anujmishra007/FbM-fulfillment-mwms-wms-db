SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****************************************************************************/
/* Store procedure: rdt_869ExtScn01                                         */
/* Copyright      :  Maersk                                                 */
/* Customer       :  USA Levis                                              */
/*                                                                          */
/*                                                                          */
/* Date       Rev      Author   Purposes                                    */
/* 2025-08-27 1.0.0    NickT    FCR-6730 Create                             */
/* 2025-09-03 1.0.1    Jackc    FCR-6730 Fix bugs                           */
/* 2025-09-09 1.0.2    NickT    FCR-6730 Fix issue:UWP-40880                */
/****************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_869ExtScn01] (
   @nMobile          INT,           
   @nFunc            INT,           
   @cLangCode        NVARCHAR( 3),  
   @nStep            INT,           
   @nScn             INT,           
   @nInputKey        INT,           
   @cFacility        NVARCHAR( 5),  
   @cStorerKey       NVARCHAR( 15), 
   @tExtScnData      VariableTable READONLY,
   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,  
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,  
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,  
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,  
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,  
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT, 
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT, 
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT, 
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT, 
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT, 
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction          INT, 
   @nAfterScn        INT OUTPUT, @nAfterStep    INT OUTPUT, 
   @nErrNo           INT            OUTPUT, 
   @cErrMsg          NVARCHAR( 1024)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nDebugFlag             INT = 0,
      @nCurrentScn            INT,
      @nCurrentStep           INT,
      @nMenu                  INT,
      @nFocusField            INT,
      @nRowCout               INT,
      @cWaveKey               NVARCHAR( 10),
      @cLoadKey               NVARCHAR( 10),
      @cOrderKey              NVARCHAR( 10),
      @cShipRef               NVARCHAR( 10),
      @cOrderCount            NVARCHAR( 5),
      @cShort                 NVARCHAR( 10),
      @cPick                  NVARCHAR( 10),
      @cExtendedUpdateSP      NVARCHAR( 20),
      @cExtendedScnSP         NVARCHAR( 20)

   SET @cUDF30 = '0' -- 1 update rdtMobRec in current extendedScreenSP, 0 update rdtMobRec in main function SP

   SELECT 
      @nCurrentScn         = Scn, 
      @nCurrentStep        = Step,
      @nMenu               = Menu,
      @cLoadKey            = V_LoadKey,--V1.0.1
      @cOrderKey           = V_OrderKey,--V1.0.1
      @cShort              = V_String1,
      @cPick               = V_String2,
      @nFocusField         = CASE WHEN rdt.rdtIsValidQTY( LEFT( V_String3,  5), 0) = 1 THEN LEFT( V_String3,  5) ELSE 0 END,
      @cWaveKey            = V_String4, --V.0.1
      @cOrderCount         = V_String5,
      @cExtendedUpdateSP   = V_String10,
      @cExtendedScnSP      = V_String11,
      @cShipRef            = C_String1
   FROM rdt.rdtMobRec (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 869
   BEGIN
      SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
      IF @cExtendedUpdateSP = '0'
         SET @cExtendedUpdateSP = ''

      SET @cExtendedScnSP = rdt.RDTGetConfig( @nFunc, 'ExtScnSP', @cStorerKey)
      IF @cExtendedScnSP = '0'
         SET @cExtendedScnSP = ''

      -- If next step is 1, go to custom screen 6673
      IF @nScn = 3050 AND @nStep = 1
      BEGIN
         SET @cOutField04 = ''
         SET @nAfterScn = 6673
         SET @nAfterStep = 99
         RETURN
      END

      --If next step is 2, then go to new screen 6674 if ShipRef <> ''
      IF @nScn = 3051 AND @nStep = 2 --V1.0.1
      BEGIN
         IF ISNULL(@cShipRef, '') <> ''
         BEGIN
            SET @cOutField07 = @cShipRef
            SET @nAfterScn = 6674
            SET @nAfterStep = 99
            RETURN
         END
      END

      IF @nCurrentStep = 99
      BEGIN
         /********************************************************************************
         Scn = 6673. WaveKey / LoadKey / OrderKey, Ship Ref
            WaveKey  (field01, input)
            LoadKey  (field02, input)
            OrderKey (field03, input)
            Ship Ref (field03, input)
         ********************************************************************************/
         IF @nCurrentScn = 6673
         BEGIN
            SET @nErrNo = 0
            SET @cUDF30 = '1'

            IF @nInputKey = 1
            BEGIN
               -- Screen mapping
               SET @cWaveKey = @cInField01
               SET @cLoadKey = @cInField02
               SET @cOrderKey = @cInField03
               SET @cShipRef = @cInField04

               -- If Ship Ref is entered, WaveKey must be entered
               IF @cShipRef <> '' AND @cWaveKey = ''
               BEGIN
                  SET @nErrNo = 245559
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Wavekey
                  EXEC rdt.rdtSetFocusField @nMobile, 1
                  GOTO Quit
               END
               
               -- Check if blank
               IF @cWaveKey = '' AND @cLoadKey = '' AND @cOrderKey = ''
               BEGIN
                  SET @nErrNo = 245551
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need value
                  EXEC rdt.rdtSetFocusField @nMobile, 01
                  GOTO Quit
               END

               -- Check if key-in more then 1
               DECLARE @i INT
               SET @i = 0
               IF @cWaveKey <> '' SET @i = @i + 1
               IF @cLoadKey <> '' SET @i = @i + 1 
               IF @cOrderKey <> '' SET @i = @i + 1
               IF @i <> 1
               BEGIN
                  SET @nErrNo = 245552
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Key-in OneOnly
                  EXEC rdt.rdtSetFocusField @nMobile, 01
                  GOTO Quit
               END

               DECLARE @nOrderCount INT
               DECLARE @nShort      INT
               DECLARE @nPick       INT

               IF @cWaveKey <> ''
               BEGIN
                  -- Check valid WaveKey
                  IF NOT EXISTS (SELECT 1 FROM dbo.Wave WITH (NOLOCK) WHERE WaveKey = @cWaveKey)
                  BEGIN
                     SET @nErrNo = 245553
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid WaveKey
                     EXEC rdt.rdtSetFocusField @nMobile, 01
                     GOTO Quit
                  END
                  
                  IF ISNULL(@cShipRef, '') = ''
                  BEGIN 
                     -- Check not yet pick
                     IF EXISTS (SELECT 1
                        FROM PickDetail PD WITH (NOLOCK)
                           INNER JOIN OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
                           INNER JOIN WaveDetail WD  WITH (NOLOCK) ON (OD.OrderKey = WD.OrderKey)
                        WHERE WD.WaveKey = @cWaveKey
                           AND PD.Status < '3'
                           AND PD.QTY > 0)
                     BEGIN
                        SET @nErrNo = 245554
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pick is not finished
                        EXEC rdt.rdtSetFocusField @nMobile, 01
                        GOTO Quit
                     END
                     
                     -- Get stat
                     SELECT 
                        @nOrderCount = COUNT( DISTINCT OD.OrderKey), 
                        @nShort = SUM( CASE WHEN PD.Status = 4 THEN PD.QTY ELSE 0 END), 
                        @nPick  = SUM( CASE WHEN PD.Status = 5 THEN PD.QTY ELSE 0 END)
                     FROM dbo.PickDetail PD WITH (NOLOCK)
                     INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
                     INNER JOIN dbo.WaveDetail WD  WITH (NOLOCK) ON (OD.OrderKey = WD.OrderKey)
                     WHERE WD.WaveKey = @cWaveKey

                     --set field focus on field no. 1
                     SET @nFocusField = 1
                  END -- Shipref = ''
                  ELSE -- wave <> '' and shipref <> '' -- V1.0.0
                  BEGIN
                     IF NOT EXISTS (SELECT 1 FROM dbo.MBOL WITH(NOLOCK) WHERE MbolKey = @cShipRef)
                     BEGIN
                        SET @nErrNo = 245560
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Ship Ref
                        EXEC rdt.rdtSetFocusField @nMobile, 1
                        GOTO Quit
                     END

                     IF NOT EXISTS (SELECT 1
                     FROM dbo.PickDetail PD (NOLOCK)
                     INNER JOIN dbo.MBOLDetail MD WITH(NOLOCK) ON PD.OrderKey = MD.OrderKey
                     WHERE PD.StorerKey = @cStorerKey
                        AND PD.WaveKey = @cWaveKey
                        AND MD.MbolKey = @cShipRef
                        AND PD.QTY > 0)
                     BEGIN
                        SET @nErrNo = 245561
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No pick data found
                        EXEC rdt.rdtSetFocusField @nMobile, 1
                        GOTO Quit
                     END

                     IF EXISTS ( SELECT 1
                        FROM dbo.PickDetail PD (NOLOCK)
                        INNER JOIN dbo.MBOLDetail MD WITH(NOLOCK) ON PD.OrderKey = MD.OrderKey
                        WHERE PD.StorerKey = @cStorerKey
                           AND PD.WaveKey = @cWaveKey
                           AND MD.MbolKey = @cShipRef
                           AND PD.Status <= '3'
                           AND PD.QTY > 0)
                     BEGIN
                        SET @nErrNo = 245562
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pick is not finished
                        EXEC rdt.rdtSetFocusField @nMobile, 1
                        GOTO Quit
                     END

                     SELECT 
                        @nOrderCount = COUNT( DISTINCT PD.OrderKey), 
                        @nShort = SUM( CASE WHEN PD.Status = 4 THEN PD.QTY ELSE 0 END),
                        @nPick  = SUM( CASE WHEN PD.Status = 5 THEN PD.QTY ELSE 0 END)
                     FROM dbo.PickDetail PD WITH (NOLOCK)
                     INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
                     INNER JOIN dbo.ORDERS ORM WITH (NOLOCK) ON (ORM.OrderKey = OD.OrderKey AND ORM.StorerKey = OD.StorerKey)
                     INNER JOIN dbo.WaveDetail WD WITH (NOLOCK) ON (ORM.OrderKey = WD.OrderKey)
                     WHERE WD.WaveKey = @cWaveKey
                        AND ORM.MBOLKey IS NOT NULL
                        AND ORM.MBOLKey = @cShipRef
                  END-- wave <> '' and shipref <> ''
               END --Wavekey <> ''

               IF @cLoadKey <> ''
               BEGIN
                  -- Check valid LoadKey
                  IF NOT EXISTS (SELECT 1 FROM dbo.LoadPlan (NOLOCK) WHERE LoadKey = @cLoadKey)
                  BEGIN
                     SET @nErrNo = 245555
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid LoadKey
                     EXEC rdt.rdtSetFocusField @nMobile, 02
                     GOTO Quit
                  END

                  -- Check not yet pick
                  IF EXISTS (SELECT 1
                     FROM dbo.PickDetail PD WITH (NOLOCK)
                     INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
                     WHERE OD.LoadKey = @cLoadKey
                        AND PD.Status < '3'
                        AND PD.QTY > 0)
                  BEGIN
                     SET @nErrNo = 245556
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pick is not finished
                     EXEC rdt.rdtSetFocusField @nMobile, 02
                     GOTO Quit
                  END

                  -- Get stat
                  SELECT 
                     @nOrderCount = COUNT( DISTINCT OD.OrderKey), 
                     @nShort = SUM( CASE WHEN PD.Status = 4 THEN PD.QTY ELSE 0 END), 
                     @nPick  = SUM( CASE WHEN PD.Status = 5 THEN PD.QTY ELSE 0 END)
                  FROM dbo.PickDetail PD WITH (NOLOCK)
                  INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
                  WHERE OD.LoadKey = @cLoadKey

                  --set field focus on field no. 2
                  SET @nFocusField = 2
               END

               IF @cOrderKey <> ''
               BEGIN
                  -- Check valid OrderKey
                  IF NOT EXISTS (SELECT 1 FROM dbo.Orders (NOLOCK) WHERE OrderKey = @cOrderKey)
                  BEGIN
                     SET @nErrNo = 245557
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Order Key
                     EXEC rdt.rdtSetFocusField @nMobile, 03
                     GOTO Quit
                  END

                  -- Check not yet pick
                  IF EXISTS (SELECT 1 
                     FROM dbo.PickDetail PD WITH (NOLOCK) 
                     WHERE PD.OrderKey = @cOrderKey 
                        AND PD.Status < '3' 
                        AND PD.QTY > 0)
                  BEGIN
                     SET @nErrNo = 245558
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pick is not finished
                     EXEC rdt.rdtSetFocusField @nMobile, 03
                     GOTO Quit
                  END

                  -- Get stat
                  SELECT 
                     @nOrderCount = 1, 
                     @nShort = SUM( CASE WHEN PD.Status = 4 THEN PD.QTY ELSE 0 END), 
                     @nPick  = SUM( CASE WHEN PD.Status = 5 THEN PD.QTY ELSE 0 END)
                  FROM dbo.PickDetail PD WITH (NOLOCK)
                  WHERE PD.OrderKey = @cOrderKey

                  --set field focus on field no. 3
                  SET @nFocusField = 3
               END

               SET @cOrderCount = CAST( ISNULL( @nOrderCount, 0) AS NVARCHAR( 5))
               SET @cShort = CAST( ISNULL( @nShort, 0) AS NVARCHAR( 10))
               SET @cPick = CAST( ISNULL( @nPick, 0) AS NVARCHAR( 10))

               -- Prepare next screen var
               SET @cOutField01 = @cWaveKey
               SET @cOutField02 = @cLoadKey
               SET @cOutField03 = @cOrderKey
               SET @cOutField04 = @cOrderCount
               SET @cOutField05 = @cPick
               SET @cOutField06 = @cShort
               

               -- Go to next screen
               IF @cShipRef <> '' AND @cWaveKey <> ''
               BEGIN
                  SET @nAfterScn = 6674
                  SET @nAfterStep = 99
                  SET @cOutField07 = @cShipRef
               END
               ELSE
               BEGIN
                  SET @nAfterScn = 3051
                  SET @nAfterStep = 2
                  SET @cOutField07 = ''
               END
               GOTO Quit
            END

            IF @nInputKey = 0 -- ESC
            BEGIN
               -- Back to menu
               SET @nFunc = @nMenu
               SET @nAfterScn  = @nMenu
               SET @nAfterStep = 0
               SET @cOutField01 = '' -- Option
            END
            GOTO Quit
         END

         /********************************************************************************
         Scn = 6674. Info screen
            WaveKey    (field01)
            SHIP REF   (field07)
            LoadKey    (field02)
            OrderKey   (field03)
            OrderCount (field04)
            Short      (field05)
            Pick       (field06)
         ********************************************************************************/
         IF @nCurrentScn = 6674
         BEGIN
            SET @cUDF30 = '1'
            IF @nInputKey = 1 -- ENTER
            BEGIN
               -- Check any short
               IF @cShort = '0'
               BEGIN
                  SET @nErrNo = 245563
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No short pick
                  GOTO Quit
               END

               -- Prepare next screen var
               SET @cOutField01 = '' -- Option

               -- Go to next screen
               SET @nAfterScn = 3052
               SET @nAfterStep = 3
            END

            IF @nInputKey = 0
            BEGIN
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''
               SET @cOutField04 = ''

               SET @nAfterScn = 6673
               SET @nAfterStep = 99
               GOTO Quit
            END
         END
      END
   
   END

Quit:
   UPDATE rdt.RDTMOBREC WITH (ROWLOCK) SET
      EditDate = GETDATE(), 
      ErrMsg = @cErrMsg,
      Func   = @nFunc,
      Step   = @nAfterStep,
      Scn    = @nAfterScn,
      
      V_LoadKey    = @cLoadKey, 
      V_OrderKey   = @cOrderKey,

      V_String1    = @cShort,
      V_String2    = @cPick,
      V_String3    = @nFocusField,
      V_String4    = @cWaveKey, 
      V_String5    = @cOrderCount, 
      V_String10   = @cExtendedUpdateSP, 
      V_String11   = @cExtendedScnSP, --V1.0.1 --@cExtendedScnSP
      C_String1    = @cShipRef,

      I_Field01 = @cInField01,  O_Field01 = @cOutField01,  FieldAttr01  = @cFieldAttr01,
      I_Field02 = @cInField02,  O_Field02 = @cOutField02,  FieldAttr02  = @cFieldAttr02,
      I_Field03 = @cInField03,  O_Field03 = @cOutField03,  FieldAttr03  = @cFieldAttr03,
      I_Field04 = @cInField04,  O_Field04 = @cOutField04,  FieldAttr04  = @cFieldAttr04,
      I_Field05 = @cInField05,  O_Field05 = @cOutField05,  FieldAttr05  = @cFieldAttr05,
      I_Field06 = @cInField06,  O_Field06 = @cOutField06,  FieldAttr06  = @cFieldAttr06,
      I_Field07 = @cInField07,  O_Field07 = @cOutField07,  FieldAttr07  = @cFieldAttr07,
      I_Field08 = @cInField08,  O_Field08 = @cOutField08,  FieldAttr08  = @cFieldAttr08,
      I_Field09 = @cInField09,  O_Field09 = @cOutField09,  FieldAttr09  = @cFieldAttr09,
      I_Field10 = @cInField10,  O_Field10 = @cOutField10,  FieldAttr10  = @cFieldAttr10,
      I_Field11 = @cInField11,  O_Field11 = @cOutField11,  FieldAttr11  = @cFieldAttr11,
      I_Field12 = @cInField12,  O_Field12 = @cOutField12,  FieldAttr12  = @cFieldAttr12,
      I_Field13 = @cInField13,  O_Field13 = @cOutField13,  FieldAttr13  = @cFieldAttr13,
      I_Field14 = @cInField14,  O_Field14 = @cOutField14,  FieldAttr14  = @cFieldAttr14,
      I_Field15 = @cInField15,  O_Field15 = @cOutField15,  FieldAttr15  = @cFieldAttr15 
      
   WHERE Mobile = @nMobile
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_869ExtScn01 TO NSQL
GO
