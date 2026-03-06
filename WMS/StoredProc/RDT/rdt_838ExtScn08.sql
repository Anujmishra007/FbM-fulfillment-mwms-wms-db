SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtScn08                                     */
/* Copyright      : Maersk WMS                                          */
/* Customer       : LEVIS UAE                                           */
/*                                                                      */
/* Date       Rev    Author      Purposes                               */
/* 2026-02-18 1.0    SSR259      FCR-10629 Full UCC Pack Modification   */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ExtScn08] (
    @nMobile                     INT,
    @nFunc                       INT,
    @cLangCode                   NVARCHAR(3),
    @nStep                       INT,
    @nScn                        INT,
    @nInputKey                   INT,
    @cFacility                   NVARCHAR(5),
    @cStorerKey                  NVARCHAR(15),
    @tExtScnData VariableTable   READONLY,

    @cInField01 NVARCHAR(60) OUTPUT, @cOutField01 NVARCHAR(60) OUTPUT, @cFieldAttr01 NVARCHAR(1) OUTPUT, @cLottable01 NVARCHAR(18) OUTPUT,
    @cInField02 NVARCHAR(60) OUTPUT, @cOutField02 NVARCHAR(60) OUTPUT, @cFieldAttr02 NVARCHAR(1) OUTPUT, @cLottable02 NVARCHAR(18) OUTPUT,
    @cInField03 NVARCHAR(60) OUTPUT, @cOutField03 NVARCHAR(60) OUTPUT, @cFieldAttr03 NVARCHAR(1) OUTPUT, @cLottable03 NVARCHAR(18) OUTPUT,
    @cInField04 NVARCHAR(60) OUTPUT, @cOutField04 NVARCHAR(60) OUTPUT, @cFieldAttr04 NVARCHAR(1) OUTPUT, @dLottable04 DATETIME OUTPUT,
    @cInField05 NVARCHAR(60) OUTPUT, @cOutField05 NVARCHAR(60) OUTPUT, @cFieldAttr05 NVARCHAR(1) OUTPUT, @dLottable05 DATETIME OUTPUT,
    @cInField06 NVARCHAR(60) OUTPUT, @cOutField06 NVARCHAR(60) OUTPUT, @cFieldAttr06 NVARCHAR(1) OUTPUT, @cLottable06 NVARCHAR(30) OUTPUT,
    @cInField07 NVARCHAR(60) OUTPUT, @cOutField07 NVARCHAR(60) OUTPUT, @cFieldAttr07 NVARCHAR(1) OUTPUT, @cLottable07 NVARCHAR(30) OUTPUT,
    @cInField08 NVARCHAR(60) OUTPUT, @cOutField08 NVARCHAR(60) OUTPUT, @cFieldAttr08 NVARCHAR(1) OUTPUT, @cLottable08 NVARCHAR(30) OUTPUT,
    @cInField09 NVARCHAR(60) OUTPUT, @cOutField09 NVARCHAR(60) OUTPUT, @cFieldAttr09 NVARCHAR(1) OUTPUT, @cLottable09 NVARCHAR(30) OUTPUT,
    @cInField10 NVARCHAR(60) OUTPUT, @cOutField10 NVARCHAR(60) OUTPUT, @cFieldAttr10 NVARCHAR(1) OUTPUT, @cLottable10 NVARCHAR(30) OUTPUT,
    @cInField11 NVARCHAR(60) OUTPUT, @cOutField11 NVARCHAR(60) OUTPUT, @cFieldAttr11 NVARCHAR(1) OUTPUT, @cLottable11 NVARCHAR(30) OUTPUT,
    @cInField12 NVARCHAR(60) OUTPUT, @cOutField12 NVARCHAR(60) OUTPUT, @cFieldAttr12 NVARCHAR(1) OUTPUT, @cLottable12 NVARCHAR(30) OUTPUT,
    @cInField13 NVARCHAR(60) OUTPUT, @cOutField13 NVARCHAR(60) OUTPUT, @cFieldAttr13 NVARCHAR(1) OUTPUT, @dLottable13 DATETIME OUTPUT,
    @cInField14 NVARCHAR(60) OUTPUT, @cOutField14 NVARCHAR(60) OUTPUT, @cFieldAttr14 NVARCHAR(1) OUTPUT, @dLottable14 DATETIME OUTPUT,
    @cInField15 NVARCHAR(60) OUTPUT, @cOutField15 NVARCHAR(60) OUTPUT, @cFieldAttr15 NVARCHAR(1) OUTPUT, @dLottable15 DATETIME OUTPUT,

    @nAction INT,
    @nAfterScn INT OUTPUT, @nAfterStep INT OUTPUT,
    @nErrNo INT OUTPUT,
    @cErrMsg NVARCHAR(20) OUTPUT,
    @cUDF01 NVARCHAR(250) OUTPUT, @cUDF02 NVARCHAR(250) OUTPUT, @cUDF03 NVARCHAR(250) OUTPUT,
    @cUDF04 NVARCHAR(250) OUTPUT, @cUDF05 NVARCHAR(250) OUTPUT, @cUDF06 NVARCHAR(250) OUTPUT,
    @cUDF07 NVARCHAR(250) OUTPUT, @cUDF08 NVARCHAR(250) OUTPUT, @cUDF09 NVARCHAR(250) OUTPUT,
    @cUDF10 NVARCHAR(250) OUTPUT, @cUDF11 NVARCHAR(250) OUTPUT, @cUDF12 NVARCHAR(250) OUTPUT,
    @cUDF13 NVARCHAR(250) OUTPUT, @cUDF14 NVARCHAR(250) OUTPUT, @cUDF15 NVARCHAR(250) OUTPUT,
    @cUDF16 NVARCHAR(250) OUTPUT, @cUDF17 NVARCHAR(250) OUTPUT, @cUDF18 NVARCHAR(250) OUTPUT,
    @cUDF19 NVARCHAR(250) OUTPUT, @cUDF20 NVARCHAR(250) OUTPUT, @cUDF21 NVARCHAR(250) OUTPUT,
    @cUDF22 NVARCHAR(250) OUTPUT, @cUDF23 NVARCHAR(250) OUTPUT, @cUDF24 NVARCHAR(250) OUTPUT,
    @cUDF25 NVARCHAR(250) OUTPUT, @cUDF26 NVARCHAR(250) OUTPUT, @cUDF27 NVARCHAR(250) OUTPUT,
    @cUDF28 NVARCHAR(250) OUTPUT, @cUDF29 NVARCHAR(250) OUTPUT, @cUDF30 NVARCHAR(250) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    -- defaults
    SET @nAfterScn  = @nScn
    SET @nAfterStep = @nStep
    SET @nErrNo     = 0
    SET @cErrMsg    = ''
    SET @cUDF01     = ''
    SET @cUDF02     = '' 

    -- Local variables from rdtMobRec
    DECLARE @cPickSlipNo           NVARCHAR(10)  = ''
    DECLARE @cUCCNo                NVARCHAR(20)  = ''
    DECLARE @cUCCCounter           NVARCHAR(5)   = '0'
    DECLARE @cCapturePackInfoSP    NVARCHAR(20)  = ''
    DECLARE @nCartonNo             INT           = 0
    DECLARE @cShipLabel            NVARCHAR(20)  = ''
    DECLARE @cPackInfo             NVARCHAR(20)  = ''
    DECLARE @cCartonManifest       NVARCHAR(20)  = ''
    DECLARE @cOption               NVARCHAR(5)   = ''
    DECLARE @cShowPickSlipNo       NVARCHAR(5)   = ''
    DECLARE @cDisableQTYField      NVARCHAR(5)   = ''
    -- We must populate them with existing data if available, or empty
    DECLARE @cExCartonType NVARCHAR(10) = ''
    DECLARE @cExWeight     NVARCHAR(10) = ''
    DECLARE @cExCube       NVARCHAR(10) = ''
    DECLARE @cExRefNo      NVARCHAR(20) = ''
    DECLARE @cExLength     NVARCHAR(10) = ''
    DECLARE @cExWidth      NVARCHAR(10) = ''
    DECLARE @cExHeight     NVARCHAR(10) = ''


    -- Read option from @tExtScnData (passed from main SP)
    SELECT @cOption = ISNULL(Value, '')
    FROM @tExtScnData
    WHERE Variable = '@cOption'

    SELECT
        @cPickSlipNo        = ISNULL(V_PickSlipNo, ''),
        @cUCCNo             = ISNULL(V_String19, ''),
        @cUCCCounter        = ISNULL(V_String10, '0'),
        @cCapturePackInfoSP = ISNULL(V_String27, ''),
        @nCartonNo          = ISNULL(V_CartonNo, 0),
        @cShipLabel         = ISNULL(V_String36, ''),
        @cPackInfo          = ISNULL(V_String28, ''),
        @cCartonManifest    = ISNULL(V_String37, ''),
        @cShowPickSlipNo    = ISNULL(V_String15, ''),
        @cDisableQTYField   = ISNULL(V_String13, '')
    FROM rdt.rdtMobRec WITH (NOLOCK)
    WHERE Mobile = @nMobile

    -- Override with fresh config values (ExtScn08 is called as a hook via Step_99,
    -- rdtMobRec may contain stale values from previous sessions)
    SET @cCapturePackInfoSP = rdt.RDTGetConfig(@nFunc, 'CapturePackInfoSP', @cStorerKey)
    IF @cCapturePackInfoSP = '0'
        SET @cCapturePackInfoSP = ''

    SET @cPackInfo = rdt.RDTGetConfig(@nFunc, 'PackInfo', @cStorerKey)
    IF @cPackInfo = '0'
        SET @cPackInfo = ''

    SET @cShipLabel = rdt.RDTGetConfig(@nFunc, 'ShipLabel', @cStorerKey)
    IF @cShipLabel = '0'
        SET @cShipLabel = ''

    SET @cCartonManifest = rdt.RDTGetConfig(@nFunc, 'CartonManifest', @cStorerKey)
    IF @cCartonManifest = '0'
        SET @cCartonManifest = ''


    -- Compare packed vs picked (Status = '5')
    -- SUM(PACKDETAIL.QTY) = SUM(PICKDETAIL.QTY) for the same PickSlipNo
    DECLARE @nPickedQty INT = 0
    DECLARE @nPackedQty INT = 0
    DECLARE @bComplete BIT = 0

    SELECT @nPickedQty = ISNULL(SUM(QTY), 0)
    FROM dbo.PickDetail WITH (NOLOCK)
    WHERE PickSlipNo = @cPickSlipNo
      AND Status = '5'

    SELECT @nPackedQty = ISNULL(SUM(QTY), 0)
    FROM dbo.PackDetail WITH (NOLOCK)
    WHERE PickSlipNo = @cPickSlipNo

    IF (@nPickedQty > 0 AND @nPackedQty = @nPickedQty)
        SET @bComplete = 1

    -- SCREEN 3 (SKU/QTY) - Only handle completion when Screen 4 NOT configured
    IF (@nScn = 4652 AND @nStep = 3 AND @nInputKey = 1 AND @nAction = 0)
    BEGIN
        -- When COMPLETE -> go to Screen 1 with message (regardless of Screen 4 config)
        IF (@bComplete = 0)
            RETURN

        IF (@cCapturePackInfoSP <> '')
        BEGIN
            -- Jump to Step 4 (Pack Info)
            SET @cUDF01     = 'JumpTo_Step_4' 
            SET @nAfterScn  = 4653
            SET @nAfterStep = 4

            SELECT DISTINCT -- Using TOP 1 or DISTINCT in case multiple details, though CartonNo should be unique
                @cExCartonType = ISNULL(CartonType, ''),
                @cExWeight     = rdt.rdtFormatFloat(Weight),
                @cExCube       = rdt.rdtFormatFloat([Cube]),
                @cExRefNo      = ISNULL(RefNo, ''),
                @cExLength     = rdt.rdtFormatFloat([Length]),
                @cExWidth      = rdt.rdtFormatFloat([Width]),
                @cExHeight     = rdt.rdtFormatFloat([Height])
            FROM dbo.PackInfo WITH (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
              AND CartonNo   = @nCartonNo

            SET @cOutField01 = ''
            SET @cOutField02 = ''
            SET @cOutField03 = ''
            SET @cOutField04 = ''
            SET @cOutField05 = ''
            SET @cOutField06 = ''
            SET @cOutField07 = ''

            -- Set field attributes based on CapturePackInfoSP config
            -- 'O' = Output only (disabled), '' = Editable
            SET @cFieldAttr01 = CASE WHEN CHARINDEX('T', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- CartonType
            SET @cFieldAttr02 = CASE WHEN CHARINDEX('W', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- Weight
            SET @cFieldAttr03 = CASE WHEN CHARINDEX('C', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- Cube
            SET @cFieldAttr04 = CASE WHEN CHARINDEX('R', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- RefNo
            SET @cFieldAttr05 = CASE WHEN CHARINDEX('L', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- Length
            SET @cFieldAttr06 = CASE WHEN CHARINDEX('D', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- Width
            SET @cFieldAttr07 = CASE WHEN CHARINDEX('H', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- Height

            -- Pre-populate input fields with existing valus to avoid "Required" errors if user accepts defaults
            SET @cInField01  = ''
            SET @cInField02  = ''
            SET @cInField03  = ''
            SET @cInField04  = ''
            SET @cInField05  = ''
            SET @cInField06  = ''
            SET @cInField07  = ''

            GOTO Quit
        END
        -- Screen 4 NOT configured -> check Screen 5
        IF (@cShipLabel <> '' OR @cCartonManifest <> '')
        BEGIN
            SET @cUDF01     = 'JumpTo_Step_5'
            SET @nAfterScn  = 4654
            SET @nAfterStep = 5
            GOTO Quit
        END

        -- Nothing configured -> completion message -> Screen 1
        SET @nErrNo     = 259252
        SET @cErrMsg    = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
        SET @cUDF01     = 'JumpTo_Step_1'
        SET @nAfterScn  = 4650
        SET @nAfterStep = 1
        SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END
        SET @cOutField02 = ''
        SET @cOutField03 = ''
        GOTO Quit
    END

    -- Screen 4 completion via Step_99 (FCR-10629)
    -- When coming from Screen 4 Enter and going to Screen 2
    DECLARE @cFromStep NVARCHAR(10)
    SELECT @cFromStep = Value FROM @tExtScnData WHERE Variable = '@cFromStep'

    IF @nAction = 0 AND @cFromStep = '4' AND @nInputKey = 1
    BEGIN
        -- Coming from Screen 4 Enter, redirect to Screen 1 with completion message
        SET @nErrNo     = 259252
        SET @cErrMsg    = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
        SET @cUDF01     = 'JumpTo_Step_1'
        SET @nAfterScn  = 4650
        SET @nAfterStep = 1

        -- Clear Screen 1 fields
        SET @cOutField01 = ''  -- PickSlipNo
        SET @cOutField02 = ''  -- FromDropID
        SET @cOutField03 = ''  -- ToDropID
        SET @cOutField04 = ''
        SET @cOutField05 = ''
        SET @cOutField06 = ''
        SET @cOutField07 = ''
        SET @cOutField08 = ''
        SET @cOutField09 = ''

        GOTO Quit
    END

    -- SCREEN 4 (Capture Pack Info) - Handle completion
    IF (@nScn = 4653 AND @nStep = 4 AND @nInputKey = 1)   
    BEGIN
        IF (@bComplete = 0)
            RETURN  -- Let main SP handle normal Screen 4 flow

        IF (@cInField01 = '')
            RETURN 

        -- If ShipLabel or CartonManifest configured -> show Screen 5
        IF (@cShipLabel <> '' OR @cCartonManifest <> '')
        BEGIN
            SET @cUDF01     = 'JumpTo_Step_5'
            SET @nAfterScn  = 4654
            SET @nAfterStep = 5
            GOTO Quit
        END

        -- No ShipLabel -> completion message and go to Screen 1
        SET @nErrNo     = 259252
        SET @cErrMsg    = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
        SET @cUDF01     = 'JumpTo_Step_1'
        SET @nAfterScn  = 4650
        SET @nAfterStep = 1
        SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END 
        SET @cOutField02 = '' -- FromDropID
        SET @cOutField03 = '' -- ToDropID
        GOTO Quit
    END

    -- After ShipLabel or CartonManifest, go to Screen 1 with completion message
    IF (@nScn = 4654 AND @nStep = 5 AND @nInputKey = 1)
    BEGIN
        SET @nErrNo     = 259252
        SET @cErrMsg    = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
        SET @cUDF01     = 'JumpTo_Step_1'
        SET @nAfterScn  = 4650
        SET @nAfterStep = 1
        SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END 
        SET @cOutField02 = '' -- FromDropID
        SET @cOutField03 = '' -- ToDropID
        GOTO Quit

    END

    -- SCREEN 8 (UCC Scan) - Handle completion and skip Screen 4 when CapturePackInfoSP = 'R'
    IF (@nScn = 4657 AND @nStep = 8 AND @nInputKey = 1)
    BEGIN
        
        -- Pack < Pick -> stay on Screen 8
        IF (@bComplete = 0)
        BEGIN
            RETURN
        END

        -- Check if Pack Info (RefNo) has been captured (meaning Screen 4 was completed)
        DECLARE @cHasPackInfo BIT = 0
        IF EXISTS (SELECT 1 FROM PackInfo WITH (NOLOCK) 
                    WHERE PickSlipNo = @cPickSlipNo 
                        AND CartonNo = @nCartonNo 
                        AND RefNo <> '' AND RefNo IS NOT NULL)
            SET @cHasPackInfo = 1

        -- If Pack Info captured AND Pack==Pick -> go to Screen 1 (completion)
        IF (@cHasPackInfo = 1 AND @bComplete = 1)
        BEGIN
            SET @nErrNo     = 259252
            SET @cErrMsg    = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            SET @cUDF01     = 'JumpTo_Step_1'
            SET @nAfterScn  = 4650
            SET @nAfterStep = 1
            SET @cOutField01 = ''
            SET @cOutField02 = ''
            SET @cOutField03 = ''
            GOTO Quit
        END

        -- Pack == Pick -> check Screen 4
        IF (@cCapturePackInfoSP <> '' AND @cCapturePackInfoSP <> 'R' AND @bComplete = 1)
        BEGIN

            -- Jump to Step 4 (Pack Info)
            SET @cUDF01     = 'JumpTo_Step_4' 
            SET @nAfterScn  = 4653
            SET @nAfterStep = 4

            SELECT DISTINCT -- Using TOP 1 or DISTINCT in case multiple details, though CartonNo should be unique
                @cExCartonType = ISNULL(C.Barcode, P.CartonType), -- Pre-fill Barcode for validation
                @cExWeight     = rdt.rdtFormatFloat(P.Weight),
                @cExCube       = rdt.rdtFormatFloat(P.[Cube]),
                @cExRefNo      = ISNULL(P.RefNo, ''),
                @cExLength     = rdt.rdtFormatFloat(P.[Length]),
                @cExWidth      = rdt.rdtFormatFloat(P.[Width]),
                @cExHeight     = rdt.rdtFormatFloat(P.[Height])
            FROM dbo.PackInfo P WITH (NOLOCK)
            LEFT JOIN dbo.Cartonization C WITH (NOLOCK) ON P.CartonType = C.CartonType 
               AND C.CartonizationGroup = (SELECT CartonGroup FROM Storer WHERE StorerKey = @cStorerKey)
            WHERE P.PickSlipNo = @cPickSlipNo
              AND P.CartonNo   = @nCartonNo

            SET @cOutField01 = ''
            SET @cOutField02 = ''
            SET @cOutField03 = ''
            SET @cOutField04 = ''
            SET @cOutField05 = ''
            SET @cOutField06 = ''
            SET @cOutField07 = ''

            -- Set field attributes based on CapturePackInfoSP config
            -- 'O' = Output only (disabled), '' = Editable
            SET @cFieldAttr01 = CASE WHEN CHARINDEX('T', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- CartonType
            SET @cFieldAttr02 = CASE WHEN CHARINDEX('W', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- Weight
            SET @cFieldAttr03 = CASE WHEN CHARINDEX('C', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- Cube
            SET @cFieldAttr04 = CASE WHEN CHARINDEX('R', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- RefNo
            SET @cFieldAttr05 = CASE WHEN CHARINDEX('L', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- Length
            SET @cFieldAttr06 = CASE WHEN CHARINDEX('D', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- Width
            SET @cFieldAttr07 = CASE WHEN CHARINDEX('H', @cPackInfo) = 0 THEN 'O' ELSE '' END  -- Height

            -- Pre-populate input fields with existing valus to avoid "Required" errors if user accepts defaults
            SET @cInField01  = @cExCartonType
            SET @cInField02  = @cExWeight
            SET @cInField03  = @cExCube
            SET @cInField04  = @cExRefNo
            SET @cInField05  = @cExLength
            SET @cInField06  = @cExWidth
            SET @cInField07  = @cExHeight

            GOTO Quit
        END

        -- Screen 5 configured -> go to Screen 5
        IF ((@cShipLabel <> '' OR @cCartonManifest <> '') AND @bComplete = 1)
        BEGIN
            SET @cUDF01     = 'JumpTo_Step_5'
            SET @nAfterScn  = 4654
            SET @nAfterStep = 5
            GOTO Quit
        END

        -- Nothing configured -> completion message -> Screen 1
        SET @nErrNo     = 259252
        SET @cErrMsg    = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
        SET @cUDF01     = 'JumpTo_Step_1'
        SET @nAfterScn  = 4650
        SET @nAfterStep = 1
        SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END
        SET @cOutField02 = ''
        SET @cOutField03 = ''
        GOTO Quit
    END
    RETURN

Quit:
    /* Update RDTMOBREC since main SP does RETURN without updating */
    UPDATE rdt.RDTMOBREC WITH (ROWLOCK) SET
        EditDate    = GETDATE(),
        ErrMsg      = @cErrMsg,
        Step        = @nAfterStep,
        Scn         = @nAfterScn,
        I_Field01 = @cInField01,  O_Field01 = @cOutField01,  FieldAttr01 = @cFieldAttr01,
        I_Field02 = @cInField02,  O_Field02 = @cOutField02,  FieldAttr02 = @cFieldAttr02,
        I_Field03 = @cInField03,  O_Field03 = @cOutField03,  FieldAttr03 = @cFieldAttr03,
        I_Field04 = @cInField04,  O_Field04 = @cOutField04,  FieldAttr04 = @cFieldAttr04,
        I_Field05 = @cInField05,  O_Field05 = @cOutField05,  FieldAttr05 = @cFieldAttr05,
        I_Field06 = @cInField06,  O_Field06 = @cOutField06,  FieldAttr06 = @cFieldAttr06,
        I_Field07 = @cInField07,  O_Field07 = @cOutField07,  FieldAttr07 = @cFieldAttr07,
        I_Field08 = @cInField08,  O_Field08 = @cOutField08,  FieldAttr08 = @cFieldAttr08
    WHERE Mobile = @nMobile
END
GO


GRANT EXECUTE ON [RDT].[rdt_838ExtScn08] TO NSQL
GO