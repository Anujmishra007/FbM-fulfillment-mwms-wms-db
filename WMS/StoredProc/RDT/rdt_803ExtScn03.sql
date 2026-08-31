
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/
/* Store procedure: rdt_803ExtScn03                                       */
/* Copyright      : Maersk                                                */
/* Customer       : ONBR                                                  */
/*                                                                        */
/* Date       Rev    Author   Purposes                                    */
/* 2025-11-27 1.0.0  Cuize    FCR-9003 Created                            */
/* 2026-08-21 1.1.0  NickT    FCR-14204 Add Unassign Station and Reason   */
/*                            Code screens                                */
/**************************************************************************/
  
CREATE OR ALTER PROC [RDT].[rdt_803ExtScn03] (
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
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
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
      @nCurrentScn                  INT,
      @nCurrentStep                 INT,
      @cOption                      NVARCHAR( 10),
      @cStation                     NVARCHAR( 10),
      @cCartID                      NVARCHAR( 10),
      @cMethod                      NVARCHAR( 1),
      @cDeviceID                    NVARCHAR( 20),
      @cWaveKey                     NVARCHAR( 10),
      @cHSBKKSeqKey                 NVARCHAR( 10),
      @nMenu                        INT,
      @bSuccess                     INT,
      @cReasonCode                  NVARCHAR( 10),
      @cAllowedReasonCode           NVARCHAR( 500),
      @cUserName                    NVARCHAR(128),
      @cHospLocIdentifier           NVARCHAR( 10),
      @cBulkHospLocPrefix           NVARCHAR( 10),
      @cHospLoc                     NVARCHAR( 10),
      @cHospDropID                  NVARCHAR( 18),
      @cOrderKey                    NVARCHAR( 10),
      @cCurrentOrderKey             NVARCHAR( 10),
      @cPickDetailKey               NVARCHAR( 18),
      @cFromDropID                  NVARCHAR( 20),
      @cFromLoc                     NVARCHAR( 10),
      @cLockID                      NVARCHAR( 18),
      @cPaperPrinter                NVARCHAR( 10),
      @cLabelPrinter                NVARCHAR( 10),
      @nTranCount                   INT,
      @nOrderLoopIndex              INT,
      @nPickDetailKeyLoopIndex      INT,
      @nPABookingKey                INT,
      @nGenerateKeyCounter          INT,
      @nHSBKKSeqKey                 INT,
      @nNewKey                      INT,
      @Attempt                      INT

   DECLARE @tUsedKey TABLE
   (
      UsedKey INT NOT NULL PRIMARY KEY
   )

   SELECT
      @nCurrentScn      = Scn,
      @nCurrentStep     = Step,
      @cDeviceID        = DeviceID,
      @cStation         = V_String1,
      @cMethod          = V_String2,
      @cCartID          = V_String42,
      @nMenu            = Menu,
      @cUserName        = UserName,
      @cPaperPrinter    = Printer_Paper,
      @cLabelPrinter    = Printer

   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile


   IF @nFunc = 803
   BEGIN
      IF @nCurrentStep = 1 -- If Next Step is Confirm Unassign
      BEGIN

         SET @cStation = @cInField01

         -- If station is HOSPITAL, go to step 2 DropID screeen
         IF @cStation = 'HOSPITAL'
         BEGIN
            SET @nAfterScn = 4602
            SET @nAfterStep = 2
            GOTO Quit
         END

         SET @nAfterScn = 6706
         SET @nAfterStep = 99
         GOTO Quit
      END
   
      IF @nCurrentStep = 99 -- Customize Step Screen
      BEGIN
         IF @nCurrentScn = 6706 -- scn 1A
         BEGIN
            IF @nInputKey = 0
            BEGIN

               SET @cOutfield01 = @cStation
               SET @cOutfield02 = @cMethod

               SET @nAfterStep = 1
               SET @nAfterScn = 4590

            END

            IF @nInputKey = 1
            BEGIN
               SET @cCartID = @cInField01

               -- Check station valid
               IF NOT EXISTS( SELECT 1 FROM dbo.DeviceProfile WITH (NOLOCK) WHERE DeviceType = 'CART' AND DeviceID <> '' AND DeviceID = @cCartID)
               BEGIN
                  SET @nErrNo = 252851
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidCartID
                  SET @cOutField01 = ''
                  GOTO Quit
               END

               IF EXISTS(
                  SELECT 1 FROM rdt.RDTPTLPIECELOG WITH (NOLOCK)
                           WHERE station = @cStation
                             AND UserDefine01 <> @cCartID
               )
               BEGIN
                  SET @nErrNo = 252853
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Station assigned with different cart
                  SET @cOutField01 = ''
                  GOTO Quit
               END

               IF NOT EXISTS(
                  SELECT 1 FROM rdt.RDTPTLPIECELOG WITH (NOLOCK)
                  WHERE station = @cStation
                    AND UserDefine01 <> @cCartID
               ) -- cart already Unassinged
               AND EXISTS(
                  SELECT 1 FROM LOTxLOCxID
                     WHERE ID LIKE @cCartID + '%'
                     AND QTY > 0
               ) --CART has inventory
               BEGIN
                  SET @nErrNo = 252860
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cart is not empty
                  SET @cOutField01 = ''
                  GOTO Quit
               END


               IF EXISTS(
                  SELECT 1
                  FROM rdt.RDTPTLPIECELOG WITH (NOLOCK)
                  WHERE  UserDefine01 = @cCartID
                  AND Station <> @cStation)
               BEGIN
                  SET @nErrNo = 252854
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cart assigned to another station
                  SET @cOutField01 = ''
                  GOTO Quit
               END

               -- Dynamic assign
               EXEC rdt.rdt_PTLPiece_Assign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
                    @cStation, @cMethod, 'POPULATE-IN',
                    @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,
                    @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,
                    @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,
                    @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,
                    @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,
                    @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,
                    @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,
                    @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,
                    @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,
                    @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,
                    @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,
                    @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,
                    @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,
                    @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,
                    @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,
                    @nAfterScn        OUTPUT,
                    @nErrNo      OUTPUT,
                    @cErrMsg     OUTPUT
               IF @nErrNo <> 0
                  GOTO Quit


               SET @nAfterStep = 2
            END
         END

         /********************************************************************************
         Step 99. Scn = 6925. Unassign cart screen
            Unassign cart?
            1 = YES
            9 = NO
            Option   (field01, input)
         ********************************************************************************/
         ELSE IF @nCurrentScn = 6925 
         BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN
               -- Screen mapping
               SET @cOption = @cInField01

               -- Check blank
               IF @cOption = ''
               BEGIN
                  SET @nErrNo = 252871
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --252871 Need Option
                  GOTO Quit
               END

               -- Check valid option
               IF @cOption <> '1' AND @cOption <> '9'
               BEGIN
                  SET @nErrNo = 252872
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --252872 Invalid Option
                  GOTO Quit
               END
               
               IF @cOption = '1' -- Yes
               BEGIN
                  SET @cWaveKey = ''
                  SELECT TOP 1
                     @cWaveKey = WaveKey
                  FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
                  WHERE Station = @cStation
                  AND   Method = @cMethod
                  AND   SourceKey <> ''

                  --Check if there are pickdetails not yet moved to cart slot
                  IF ISNULL(@cWaveKey,'') <> ''
                  BEGIN
                     IF @cStation <> 'HOSPITAL' 
                        AND EXISTS( SELECT 1
                                 FROM dbo.PICKDETAIL AS PD WITH (NOLOCK)
                                 INNER JOIN dbo.ORDERS ORM WITH (NOLOCK) ON PD.StorerKey = ORM.StorerKey AND ORM.orderkey = PD.orderkey
                                 WHERE PD.wavekey = @cwavekey
                                    AND PD.StorerKey = @cStorerKey
                                    AND PD.DropID IS NOT NULL
                                    AND PD.DropID NOT LIKE 'CART%'
                                    AND ORM.UserDefine04 IS NOT NULL
                                    AND ORM.UserDefine04 = @cStation
                     )
                     BEGIN
                        SET @cOutField01 = ''
                        SET @nAfterScn = 6926
                        SET @nAfterStep = 99
                        GOTO Quit
                     END
                  END
                     
                  -- Dynamic assign
                  EXEC rdt.rdt_PTLPiece_Assign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
                     @cStation, @cMethod, 'POPULATE-OUT',
                     @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,
                     @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,
                     @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,
                     @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,
                     @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,
                     @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,
                     @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,
                     @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,
                     @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,
                     @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,
                     @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,
                     @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,
                     @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,
                     @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,
                     @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,
                     @nCurrentScn        OUTPUT,
                     @nErrNo      OUTPUT,
                     @cErrMsg     OUTPUT
                  IF @nErrNo <> 0
                     GOTO Quit

                  -- Close station
                  EXEC rdt.rdt_PTLPiece_Unassign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
                     ,@cStation
                     ,@cMethod
                     ,@nErrNo     OUTPUT
                     ,@cErrMsg    OUTPUT
                  IF @nErrNo <> 0
                     GOTO Quit

                  -- Prep next screen var
                  SET @cOutField01 = @cStation
                  SET @cOutField02 = @cMethod
            
                  EXEC rdt.rdtSetFocusField @nMobile, 1 -- Station
            
                  -- Go to station screen
                  SET @nAfterScn = 4590
                  SET @nAfterStep = 1
               END
               
               IF @cOption = '9' -- No
               BEGIN
                  -- Prepare next screen var
                  SET @cOutField01 = @cStation
                  SET @cOutField02 = @cMethod
            
                  -- Go to station screen
                  SET @nAfterScn = 4590
                  SET @nAfterStep = 1
               END
            END

            IF @nInputKey = 0 -- ESC
            BEGIN
               -- Dynamic assign
               EXEC rdt.rdt_PTLPiece_Assign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
                  @cStation, @cMethod, 'POPULATE-IN',
                  @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,
                  @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,
                  @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,
                  @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,
                  @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,
                  @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,
                  @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,
                  @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,
                  @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,
                  @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,
                  @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,
                  @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,
                  @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,
                  @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,
                  @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,
                  @nAfterScn        OUTPUT,
                  @nErrNo      OUTPUT,
                  @cErrMsg     OUTPUT
               IF @nErrNo <> 0
                  GOTO Quit
            
               -- Go to assign screen
               SET @nAfterStep = 2
               SET @nAfterScn = 4602
            END
         END

         /********************************************************************************
         Step 99. Scn = 6926. Unassign cart screen
            UNASSIGN STATION?
            WAVE NOT COMPLETE
            REASON CODE
            ReasonCode      (Field11, input)
         ********************************************************************************/
         ELSE IF @nCurrentScn = 6926
         BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN
               SET @cReasonCode = @cInField01

               -- Blank check
               IF @cReasonCode = ''
               BEGIN
                  SET @nErrNo = 252873
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --252873 Need Reason Code
                  GOTO Quit
               END

               -- Validate reason code against PTLINCOMPRSN config
               -- Svalue stores comma-separated valid reason codes, e.g. '6477' or '6477,6478'
               SET @cAllowedReasonCode = rdt.rdtGetConfig(@nFunc, 'PTLINCOMPRSN', @cStorerKey)
               IF ISNULL(@cAllowedReasonCode, '') = '' OR @cAllowedReasonCode = '0'
               BEGIN
                  SET @nErrNo = 252874
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- No reason code configured
                  SET @cOutField01 = ''
                  GOTO Quit
               END
                  
               IF NOT EXISTS (
                     SELECT 1 FROM STRING_SPLIT(@cAllowedReasonCode, ',')
                     WHERE LTRIM(RTRIM(value)) = @cReasonCode
                  )
               BEGIN
                  SET @nErrNo = 252862
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Incorrect reason code
                  SET @cOutField01 = ''
                  GOTO Quit
               END

               -- Get WaveKey for the current station
               SET @cWaveKey = ''
               SELECT TOP 1
                  @cWaveKey = WaveKey
               FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
               WHERE Station = @cStation
               AND   Method  = @cMethod
               AND   SourceKey <> ''

               -- === Hospital Move Logic ===
               DECLARE @tOrderHospital TABLE
               (
                  RowRef        INT IDENTITY(1,1) NOT NULL,
                  OrderKey      NVARCHAR( 10) NOT NULL,
                  Loc           NVARCHAR( 10) NOT NULL,
                  DropID        NVARCHAR( 20) NOT NULL
               )

               DECLARE @tOrderLoc TABLE
               (
                  RowRef         INT IDENTITY(1,1) NOT NULL,
                  OrderKey       NVARCHAR( 10) NOT NULL,
                  HospLoc        NVARCHAR( 10) NOT NULL,
                  FromDropID     NVARCHAR( 20) NOT NULL,
                  ToID           NVARCHAR( 18) NOT NULL
               )

               DECLARE @tPickDetail TABLE
               (
                  RowRef         INT IDENTITY(1,1) NOT NULL,
                  PickDetailKey  NVARCHAR( 18) NOT NULL PRIMARY KEY
               )

               DECLARE @tHospDropID AS VariableTable
               DECLARE @cHospDropIDLabel AS NVARCHAR( 10) = 'HOSPLABEL'

               SET @cHospLocIdentifier = rdt.rdtGetConfig(@nFunc, 'HOSPLOCIDENTIFIER', @cStorerKey)
               IF ISNULL(@cHospLocIdentifier, '') = '' OR @cHospLocIdentifier = '0'
                  SET @cHospLocIdentifier = 'HS'

               SET @cBulkHospLocPrefix = rdt.rdtGetConfig(@nFunc, 'BulkHospLoc', @cStorerKey)
               IF ISNULL(@cBulkHospLocPrefix, '') = '' OR @cBulkHospLocPrefix = '0'
                  SET @cBulkHospLocPrefix = 'ONBR_HSP'

               -- Collect incomplete PickDetails , sorted by OrderKey
               INSERT INTO @tOrderHospital (OrderKey, Loc, DropID)
               SELECT DISTINCT PD.OrderKey, PD.Loc, PD.DropID
               FROM dbo.PICKDETAIL PD WITH (NOLOCK)
               INNER JOIN dbo.ORDERS ORM WITH (NOLOCK)
                  ON PD.StorerKey = ORM.StorerKey
                  AND ORM.OrderKey = PD.OrderKey
               WHERE PD.WaveKey    = @cWaveKey
                  AND PD.StorerKey = @cStorerKey
                  AND PD.DropID IS NOT NULL
                  AND PD.DropID <> ''
                  --AND PD.DropID LIKE 'CART%'
                  AND ORM.UserDefine04 IS NOT NULL
                  AND ORM.UserDefine04 = @cStation
               ORDER BY PD.OrderKey, PD.DropID

               IF NOT EXISTS (SELECT 1 FROM @tOrderHospital)
               BEGIN
                  SET @nErrNo = 252863
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- NoItemsToHospitalize
                  SET @cOutField01 = ''
                  GOTO Quit
               END

               -- Begin transaction — all moves succeed or all roll back
               SET @nTranCount     = @@TRANCOUNT
               SET @cHospLoc       = ''
               SET @cHospDropID    = ''
               SET @cLockID        = ''

               BEGIN TRAN
               SAVE TRAN rdt_803_HospMove

               SET @nOrderLoopIndex = 0
               WHILE 1 = 1
               BEGIN
                  SET @cOrderKey      = ''
                  SET @cFromLoc       = ''
                  SET @cFromDropID    = ''
                  SET @nPABookingKey  = -1

                  SELECT TOP 1
                     @cOrderKey       = OrderKey,
                     @cFromLoc        = Loc,
                     @cFromDropID     = DropID,
                     @nOrderLoopIndex = RowRef
                  FROM @tOrderHospital
                  WHERE RowRef > @nOrderLoopIndex
                  ORDER BY RowRef

                  IF @@ROWCOUNT = 0 BREAK

                  IF EXISTS (SELECT 1 FROM @tOrderLoc WHERE FromDropID = @cFromDropID AND ToID <> '')
                     CONTINUE -- Already moved this PickDetail's inventory

                  SET @cHospLoc = ''
                  SELECT TOP 1 
                     @cHospLoc = HospLoc
                  FROM @tOrderLoc
                  WHERE OrderKey = @cOrderKey
                  ORDER BY HospLoc DESC

                  -- Find 1 empty hospital location; already-LOCKed locs excluded via RFPutaway check
                  IF ISNULL(@cHospLoc, '') = ''
                  BEGIN
                     SELECT TOP 1 @cHospLoc = Loc
                     FROM dbo.LOC WITH (NOLOCK)
                     WHERE LEFT(Loc, LEN(@cHospLocIdentifier)) = @cHospLocIdentifier
                        AND LocationType = 'HOSPITAL'
                        AND Facility = @cFacility
                        AND NOT EXISTS (
                           SELECT 1 FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                           WHERE LLI.Loc = LOC.Loc AND LLI.Qty - LLI.QtyPicked > 0
                        )
                        AND NOT EXISTS (
                           SELECT 1 FROM dbo.RFPutaway RP WITH (NOLOCK)
                           WHERE RP.SuggestedLoc = LOC.Loc
                        )
                     ORDER BY LOC.LogicalLocation, LOC.Loc

                     IF @cHospLoc <> ''
                     BEGIN
                        -- Individual hospital location: use loc name as DropID/ID
                        INSERT INTO @tOrderLoc (OrderKey, HospLoc, FromDropID, ToID)
                        VALUES (@cOrderKey, @cHospLoc, @cFromDropID, '')
                     END
                     ELSE
                     BEGIN
                        -- No individual loc: use bulk location with HSBKK##### sequence ID
                        IF NOT EXISTS (SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE LEFT(Loc, LEN(@cBulkHospLocPrefix)) = @cBulkHospLocPrefix AND Facility = @cFacility)
                        BEGIN
                           SET @nErrNo = 252864
                           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- BulkLocNotFound
                           GOTO HospMove_Fail
                        END

                        SELECT TOP 1 @cHospLoc = LOC.Loc
                        FROM dbo.LOC WITH (NOLOCK)
                        WHERE LEFT(LOC.Loc, LEN(@cBulkHospLocPrefix)) = @cBulkHospLocPrefix
                           AND LOC.Facility = @cFacility
                        ORDER BY (
                              SELECT COUNT(DISTINCT ID) FROM dbo.LOTxLOCxID WITH (NOLOCK) WHERE Loc = LOC.Loc
                           ), LOC.LogicalLocation, LOC.Loc


                        INSERT INTO @tOrderLoc (OrderKey, HospLoc, FromDropID, ToID)
                        VALUES (@cOrderKey, @cHospLoc, @cFromDropID, '')
                     END
                  END

                  -- Still no hospital location found, error out
                  IF ISNULL(@cHospLoc, '') = ''
                  BEGIN
                     SET @nErrNo = 252870
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- No hospital location found
                     GOTO HospMove_Fail
                  END

                  -- Generate hospital DropID for this PickDetail's inventory
                  -- 1. If individual hospital location, use loc name as DropID/ID
                  -- 2. If bulk hospital location, generate unique HSBKK##### sequence ID as DropID/ID
                  SET @nGenerateKeyCounter = 0
                  IF LEFT(@cHospLoc, LEN(@cBulkHospLocPrefix)) = @cBulkHospLocPrefix
                  BEGIN
                     GENE_KEY:
                     IF @nGenerateKeyCounter > 10
                     BEGIN
                        INSERT INTO @tUsedKey (UsedKey)
                        SELECT DISTINCT RIGHT(DropID, 6)
                        FROM dbo.PickDetail WITH(NOLOCK)
                        WHERE StorerKey = @cStorerKey
                           AND LEFT(DropID, 4) = 'HSBK'
                           AND TRY_CAST( RIGHT (DropID, 6) AS INT) IS NOT NULL

                        SET @Attempt = 0
                        WHILE @Attempt < 10
                        BEGIN
                           SET @nNewKey = FLOOR(RAND() * 99999) + 1

                           IF NOT EXISTS (
                              SELECT 1 FROM @tUsedKey WHERE UsedKey = @nNewKey
                           )
                           BEGIN
                              BREAK -- Find the key
                           END

                           SET @Attempt = @Attempt + 1
                        END

                        IF @Attempt >= 10
                        BEGIN
                           SET @nErrNo = 252869
                           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --  Generate HSBK key failed
                           GOTO HospMove_Fail
                        END

                        SET @cHSBKKSeqKey = 'HSBK' + RIGHT('000000' + CAST(@nNewKey AS NVARCHAR(6)), 6)
                        SET @cHospDropID = @cHSBKKSeqKey
                        GOTO HAND_PKD
                     END

                     SET @bSuccess = 1
                     EXECUTE nspg_getkey
                        'HSBKKSeqKey'
                        , 6
                        , @cHSBKKSeqKey OUTPUT
                        , @bSuccess     OUTPUT
                        , @nErrNo       OUTPUT
                        , @cErrMsg      OUTPUT
                     IF @bSuccess <> 1
                     BEGIN
                        SET @nErrNo = 252865
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- SeqKeyFailed
                        GOTO HospMove_Fail
                     END

                     SET @cHospDropID = 'HSBK' + @cHSBKKSeqKey
                     SET @nGenerateKeyCounter = @nGenerateKeyCounter + 1

                     IF EXISTS(SELECT 1 FROM dbo.PickDetail WITH(NOLOCK)
                              WHERE StorerKey = @cStorerKey
                                 AND DropID = @cHospDropID)
                     BEGIN
                        GOTO GENE_KEY
                     END
                  END
                  ELSE
                  BEGIN
                     SET @cHospDropID = @cHospLoc
                  END

                  HAND_PKD:
                  DELETE FROM @tPickDetail
                  BEGIN TRY
                     INSERT INTO @tPickDetail (PickDetailKey)
                     SELECT PickDetailKey
                     FROM dbo.PickDetail WITH(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND WaveKey = @cWaveKey
                        AND DropID = @cFromDropID
                        AND Loc = @cFromLoc
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 252866
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- InsPickDetailFailed
                     GOTO HospMove_Fail
                  END CATCH

                  -- Lock hospital location using first PickDetail's ID as the lock token
                  SET @cLockID = @cFromDropID

                  IF NOT EXISTS(
                     SELECT 1 FROM dbo.RFPutaway WITH (NOLOCK)
                     WHERE SuggestedLoc = @cHospLoc AND ID = @cLockID
                  )
                  BEGIN
                     SET @nPABookingKey = 0
                     IF LEFT(@cLockID, 4) = 'CART'
                     BEGIN
                        EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
                           ,@cFromLoc
                           ,@cLockID
                           ,@cHospLoc
                           ,@cStorerKey
                           ,@nErrNo  OUTPUT
                           ,@cErrMsg OUTPUT
                           ,@cMoveQTYAlloc = '1'
                           ,@cToID = @cHospDropID 
                           ,@nPABookingKey = @nPABookingKey OUTPUT
                        IF @nErrNo <> 0
                           GOTO HospMove_Fail
                     END
                     ELSE
                     BEGIN
                        BEGIN TRY
                           INSERT INTO dbo.RFPutaway (Storerkey, SKU, LOT, FromLOC, FromID, SuggestedLOC, ID, ptcid, QTY, CaseID, TaskDetailKey, Func, PABookingKey, QTYPrinted)  
                           VALUES (@cStorerKey, '', '', @cFromLoc, @cLockID, @cHospLoc, @cHospDropID, @cUserName, 1, '', '', @nFunc, @nPABookingKey, 1)  
                           
                           SET @nPABookingKey = SCOPE_IDENTITY()

                           UPDATE dbo.RFPutaway WITH(ROWLOCK) SET  
                              PABookingKey = @nPABookingKey  
                           WHERE RowRef = @nPABookingKey  
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 252875
                           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Add RFPutaway failed
                           GOTO HospMove_Fail
                        END CATCH
                     END
                  END

                  BEGIN TRY
                     UPDATE @tOrderLoc
                     SET ToID = @cHospDropID
                     WHERE OrderKey = @cOrderKey 
                        AND HospLoc = @cHospLoc 
                        AND FromDropID = @cFromDropID
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 252867
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- UpdOrderLocFailed
                     GOTO HospMove_Fail
                  END CATCH

                  IF LEFT(@cLockID, 4) <> 'CART' -- If not a cart, no need to move  inventory, no need to update PickDetail, only print label
                     GOTO PRINT_LABEL

                  -- Move this PickDetail's inventory (Loc + ID identifies the LOTxLOCxID record)
                  EXECUTE rdt.rdt_Move
                     @nMobile     = @nMobile,
                     @cLangCode   = @cLangCode,
                     @nErrNo      = @nErrNo  OUTPUT,
                     @cErrMsg     = @cErrMsg OUTPUT,
                     @cSourceType = 'rdt_803ExtScn03_HospMove',
                     @cStorerKey  = @cStorerKey,
                     @cFacility   = @cFacility,
                     @cFromLOC    = @cFromLoc,
                     @cToLOC      = @cHospLoc,
                     @cFromID     = @cFromDropID,
                     @cToID       = @cHospDropID,
                     @nFunc       = @nFunc
                  IF @nErrNo <> 0
                     GOTO HospMove_Fail

                  -- Unlock hospital location
                  IF ISNULL(@nPABookingKey, -1) > 0
                  BEGIN
                     EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                        ,'' --FromLOC
                        ,'' --FromID
                        ,'' --cSuggLOC
                        ,'' --Storer
                        ,@nErrNo  OUTPUT
                        ,@cErrMsg OUTPUT
                        ,@nPABookingKey = @nPABookingKey OUTPUT    
                     IF @nErrNo <> 0
                        GOTO HospMove_Fail
                  END
                  ELSE
                  BEGIN
                     EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                        ,'' --@cSuggFromLOC
                        ,@cFromDropID
                        ,'' --@cSuggToLOC
                        ,@cStorerKey
                        ,@nErrNo  OUTPUT
                        ,@cErrMsg OUTPUT
                     IF @nErrNo <> 0
                        GOTO HospMove_Fail
                  END

                  -- Update PICKDETAIL to reflect new location/ID
                  SET @nPickDetailKeyLoopIndex = -1
                  WHILE 1 = 1
                  BEGIN
                     SET @cPickDetailKey = ''
                     SELECT TOP 1
                        @cPickDetailKey = PickDetailKey,
                        @nPickDetailKeyLoopIndex = RowRef
                     FROM @tPickDetail
                     WHERE RowRef > @nPickDetailKeyLoopIndex
                     ORDER BY RowRef

                     IF @@ROWCOUNT = 0 BREAK

                     BEGIN TRY
                        UPDATE dbo.PICKDETAIL WITH(ROWLOCK)
                        SET Loc     = @cHospLoc,
                           DropID   = @cHospDropID,
                           ID       = @cHospDropID,
                           EditDate = GETDATE(),
                           EditWho  = @cUserName
                        WHERE PickDetailKey = @cPickDetailKey
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 252868
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- UpdPickDetailFailed
                        GOTO HospMove_Fail
                     END CATCH
                  END

                  -- Print DropID label for hospital location
                  PRINT_LABEL:
                  DELETE FROM @tHospDropID
                  INSERT INTO @tHospDropID (Variable, Value) VALUES
                     ( '@cWaveKey',       @cWaveKey),
                     ( '@cOrderKey',      @cOrderKey),
                     ( '@cFromLoc',       @cFromLoc),
                     ( '@cFromDropID',    @cFromDropID),
                     ( '@cHospLoc',       @cHospLoc),
                     ( '@cHospDropID',    @cHospDropID)

                  -- Print label
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                     @cHospDropIDLabel, -- Report type
                     @tHospDropID, -- Report params
                     'rdt_803ExtScn03',
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT
                  IF @nErrNo <> 0
                     GOTO HospMove_Fail
               END

               -- POPULATE-OUT to clear PTL slot assignments
               EXEC rdt.rdt_PTLPiece_Assign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
                  @cStation, @cMethod, 'POPULATE-OUT',
                  @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,
                  @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,
                  @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,
                  @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,
                  @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,
                  @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,
                  @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,
                  @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,
                  @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,
                  @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,
                  @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,
                  @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,
                  @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,
                  @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,
                  @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,
                  @nCurrentScn        OUTPUT,
                  @nErrNo      OUTPUT,
                  @cErrMsg     OUTPUT
               IF @nErrNo <> 0
                  GOTO HospMove_Fail

               -- Unassign station
               EXEC rdt.rdt_PTLPiece_Unassign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
                  ,@cStation
                  ,@cMethod
                  ,@nErrNo  OUTPUT
                  ,@cErrMsg OUTPUT
               IF @nErrNo <> 0
                  GOTO HospMove_Fail

               -- All moves successful — commit
               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN

               SET @cOutField01 = @cStation
               SET @cOutField02 = @cMethod
               EXEC rdt.rdtSetFocusField @nMobile, 1
               SET @nAfterScn  = 4590
               SET @nAfterStep = 1
               GOTO Quit

               HospMove_Fail:
               ROLLBACK TRAN rdt_803_HospMove
               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN
               SET @cOutField01 = ''
               GOTO Quit

            END
            ELSE IF @nInputKey = 0 -- ESC
            BEGIN
               SET @nAfterStep = 99
               SET @nAfterScn = 6925
            END
         END

      END

      IF @nAfterStep = 4 AND @nAfterScn = 4593
      BEGIN
         SET @nAfterStep = 99
         SET @nAfterScn = 6925
      END


   END

   IF @nFunc = @nMenu
   BEGIN
      SET @cStation = ''
   END

   
   GOTO Quit

Quit:

   SET @cUDF07 = @cCartID
   SET @cUDF08 = @cStation

END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_803ExtScn03 TO NSQL
GO
