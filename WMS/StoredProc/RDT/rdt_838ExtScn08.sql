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

    -- Initialize output variables (only error and UDF, NOT @nAfterScn/@nAfterStep)
    -- @nAfterScn and @nAfterStep are set ONLY when step logic determines a redirect
    SET @nErrNo     = 0
    SET @cErrMsg    = ''
    SET @cUDF01     = ''
    SET @cUDF02     = ''

    -- Read variables from @tExtScnData
    DECLARE @cJumpType      NVARCHAR(10) = ''
    SELECT  @cJumpType = ISNULL(Value, '') FROM @tExtScnData WHERE Variable = '@cJumpType'

    -- Read from rdtMobRec
    DECLARE @cPickSlipNo         NVARCHAR(10) = ''
    DECLARE @cShowPickSlipNo     NVARCHAR(5)  = ''
    DECLARE @cCapturePackInfoSP  NVARCHAR(20) = ''
    DECLARE @cShipLabel          NVARCHAR(20) = ''
    DECLARE @cCartonManifest     NVARCHAR(20) = ''
    DECLARE @cCompletionMsg      NVARCHAR(200) = ''
    DECLARE @cPackList           NVARCHAR(20) = ''

    -- Completion check variables
    DECLARE @nPickedQty INT = 0
    DECLARE @nPackedQty INT = 0
    DECLARE @bComplete  BIT = 0
    DECLARE @cOrderKey  NVARCHAR(10) = ''
    DECLARE @cLoadKey   NVARCHAR(10) = ''
    DECLARE @cZone      NVARCHAR(18) = ''

    SELECT
        @cPickSlipNo        = ISNULL(V_PickSlipNo, ''),
        @cShowPickSlipNo    = ISNULL(V_String15, '')
    FROM rdt.rdtMobRec WITH (NOLOCK)
    WHERE Mobile = @nMobile

    SET @cCapturePackInfoSP = rdt.RDTGetConfig(@nFunc, 'CapturePackInfoSP', @cStorerKey)
    IF @cCapturePackInfoSP = '0'
        SET @cCapturePackInfoSP = ''

    SET @cShipLabel = rdt.RDTGetConfig(@nFunc, 'ShipLabel', @cStorerKey)
    IF @cShipLabel = '0'
        SET @cShipLabel = ''

    SET @cCartonManifest = rdt.RDTGetConfig(@nFunc, 'CartonManifest', @cStorerKey)
    IF @cCartonManifest = '0'
        SET @cCartonManifest = ''

    SET @cPackList = rdt.RDTGetConfig(@nFunc, 'PackList', @cStorerKey)
    IF @cPackList = '0'
        SET @cPackList = ''

    IF @nStep IN (2, 3, 4, 6, 8)
    BEGIN
        -- Get PickHeader info
        SELECT TOP 1
            @cOrderKey = ISNULL(OrderKey, ''),
            @cLoadKey  = ISNULL(ExternOrderKey, ''),
            @cZone     = ISNULL(Zone, '')
        FROM dbo.PickHeader WITH (NOLOCK)
        WHERE PickHeaderKey = @cPickSlipNo

        -- Get PackDetail total (always by PickSlipNo)
        SELECT @nPackedQty = ISNULL(SUM(QTY), 0)
        FROM dbo.PackDetail WITH (NOLOCK)
        WHERE PickSlipNo = @cPickSlipNo

        -- Get PickDetail total based on PickHeader type
        -- Cross dock PickSlip
        IF @cZone IN ('XD', 'LB', 'LP')
        BEGIN
            SELECT @nPickedQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            WHERE RKL.PickSlipNo = @cPickSlipNo
                AND PD.Status <= '5'
                AND PD.Status <> '4'
        END
        -- Discrete PickSlip (has OrderKey)
        ELSE IF @cOrderKey <> ''
        BEGIN
            SELECT @nPickedQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            WHERE PD.OrderKey = @cOrderKey
                AND PD.Status <= '5'
                AND PD.Status <> '4'
        END
        -- Conso PickSlip (has LoadKey)
        ELSE IF @cLoadKey <> ''
        BEGIN
            SELECT @nPickedQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
            WHERE LPD.LoadKey = @cLoadKey
                AND PD.Status <= '5'
                AND PD.Status <> '4'
        END
        -- Custom PickSlip (default)
        ELSE
        BEGIN
            SELECT @nPickedQty = ISNULL(SUM(PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
                AND PD.Status <= '5'
                AND PD.Status <> '4'
        END

        -- Check completion
        IF (@nPickedQty > 0 AND @nPackedQty = @nPickedQty)
            SET @bComplete = 1
    END

    IF @nFunc = 838
    BEGIN

        /*********************************************************************
        STEP 2 - Statistics Screen (Scn = 4651)
        Coming FROM Screen 4 after ENTER
        *********************************************************************/
        IF @nStep = 2
        BEGIN
            IF @nScn = 4651
            BEGIN
                IF @nInputKey = 1
                BEGIN
                    IF @bComplete = 1
                    BEGIN
                        -- Check if ShipLabel/CartonManifest configured
                        IF (@cShipLabel <> '' OR @cCartonManifest <> '')
                        BEGIN
                            SET @cOutField01 = ''
                            SET @nAfterScn  = 4654
                            SET @nAfterStep = 5
                            GOTO Quit
                        END

                        -- No print label -> completion message -> Screen 1
                        SET @cCompletionMsg = 'PSNO: ' + ISNULL(@cPickSlipNo, '')
                        EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', 'PACKING COMPLETED', @cCompletionMsg, 'Please press ESC to continue'
    
                        SET @cErrMsg    = ''
                        SET @nAfterScn  = 4650
                        SET @nAfterStep = 1
                        SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END
                        SET @cOutField02 = ''
                        SET @cOutField03 = ''
                        GOTO Quit
                    END
                    -- NOT Complete: continue to Screen 2
                    RETURN
                END
            END
        END

        /*********************************************************************
        STEP 3 - SKU QTY Screen (Scn = 4652)
        *********************************************************************/
        IF @nStep = 3
        BEGIN
            IF @nScn = 4652
            BEGIN
                IF @nInputKey = 1
                BEGIN
                    IF @bComplete = 1
                    BEGIN
                        -- If CapturePackInfoSP configured, go to Screen 4 first
                        IF @cCapturePackInfoSP <> ''
                        BEGIN
                            -- Set output field values to EMPTY (user should enter fresh values)
                            SET @cOutField01 = ''
                            SET @cOutField02 = ''
                            SET @cOutField03 = ''
                            SET @cOutField04 = ''
                            SET @cOutField05 = ''
                            SET @cOutField06 = ''
                            SET @cOutField07 = ''

                            -- Set field attributes based on @cCapturePackInfoSP
                            SET @cFieldAttr01 = CASE WHEN CHARINDEX('T', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                            SET @cFieldAttr02 = CASE WHEN CHARINDEX('C', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                            SET @cFieldAttr03 = CASE WHEN CHARINDEX('W', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                            SET @cFieldAttr04 = CASE WHEN CHARINDEX('R', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                            SET @cFieldAttr05 = CASE WHEN CHARINDEX('L', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                            SET @cFieldAttr06 = CASE WHEN CHARINDEX('D', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                            SET @cFieldAttr07 = CASE WHEN CHARINDEX('H', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END

                            SET @nAfterScn  = 4653
                            SET @nAfterStep = 4
                            GOTO Quit
                        END

                        -- If ShipLabel configured, go to Screen 5
                        IF (@cShipLabel <> '' OR @cCartonManifest <> '')
                        BEGIN
                            SET @cOutField01 = ''
                            SET @nAfterScn  = 4654
                            SET @nAfterStep = 5
                            GOTO Quit
                        END

                        -- Nothing configured -> completion message -> Screen 1
                        SET @cCompletionMsg = 'PSNO: ' + ISNULL(@cPickSlipNo, '')
                        EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', 'PACKING COMPLETED', @cCompletionMsg, 'Please press ESC to continue'
    
                        SET @cErrMsg    = ''
                        SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END
                        SET @cOutField02 = ''
                        SET @cOutField03 = ''
                        SET @nAfterScn  = 4650
                        SET @nAfterStep = 1
                        GOTO Quit
                    END
                END
            END
        END

        /*********************************************************************
        STEP 4 - Pack Info Screen (Scn = 4653)
        Going TO Screen 4 from Screen 8
        *********************************************************************/
        IF @nStep = 4
        BEGIN
            IF @nScn = 4653
            BEGIN
                IF @nInputKey = 1
                BEGIN
                    -- If CapturePackInfoSP = 'R' ONLY and complete, SKIP Screen 4
                    IF (@bComplete = 1 AND @cCapturePackInfoSP = 'R')
                    BEGIN
                        -- Check if ShipLabel/CartonManifest configured
                        IF (@cShipLabel <> '' OR @cCartonManifest <> '')
                        BEGIN
                            SET @cOutField01 = ''                      
                            SET @nAfterScn  = 4654
                            SET @nAfterStep = 5
                            GOTO Quit
                        END

                        -- No print label -> completion message -> Screen 1
                        SET @cCompletionMsg = 'PSNO: ' + ISNULL(@cPickSlipNo, '')
                        EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', 'PACKING COMPLETED', @cCompletionMsg, 'Please press ESC to continue'
                        
                        -- Enable input fields for Screen 1
                        SET @cFieldAttr01 = ''  -- PSNO - enabled
                        SET @cFieldAttr02 = ''  -- FromDropID - enabled
                        SET @cFieldAttr03 = ''  -- ToDropID - enabled
                        
                        SET @cErrMsg    = ''
                        SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END
                        SET @cOutField02 = ''
                        SET @cOutField03 = ''
                        SET @nAfterScn  = 4650
                        SET @nAfterStep = 1
                        GOTO Quit
                    END

                    -- Set field attributes using fresh config value (not stale @cPackInfo)
                    SET @cFieldAttr01 = CASE WHEN CHARINDEX('T', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                    SET @cFieldAttr02 = CASE WHEN CHARINDEX('C', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                    SET @cFieldAttr03 = CASE WHEN CHARINDEX('W', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                    SET @cFieldAttr04 = CASE WHEN CHARINDEX('R', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                    SET @cFieldAttr05 = CASE WHEN CHARINDEX('L', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                    SET @cFieldAttr06 = CASE WHEN CHARINDEX('D', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                    SET @cFieldAttr07 = CASE WHEN CHARINDEX('H', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END

                    RETURN
                END
            END
        END

        /*********************************************************************
        STEP 6 - Print Packing List Screen (Scn = 4655)
        *********************************************************************/
        IF @nStep = 6
        BEGIN
            IF @nScn = 4655
            BEGIN
                IF @nInputKey = 1
                BEGIN
                    IF @bComplete = 1
                        -- After print packing list, show completion
                        SET @cCompletionMsg = 'PSNO: ' + ISNULL(@cPickSlipNo, '')
                        EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', 'PACKING COMPLETED', @cCompletionMsg, 'Please press ESC to continue'
    
                        SET @cErrMsg    = ''
                        SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END
                        SET @cOutField02 = ''
                        SET @cOutField03 = ''
                        SET @nAfterScn  = 4650
                        SET @nAfterStep = 1
                        GOTO Quit
                    END
                END
            END
        END

        /*********************************************************************
        STEP 8 - UCC Scan Screen (Scn = 4657)
        *********************************************************************/
        IF @nStep = 8
        BEGIN
            IF @nScn = 4657
            BEGIN
                IF @nInputKey = 1
                BEGIN
                    IF @bComplete = 1
                    BEGIN
                        IF (@cCapturePackInfoSP <> '' AND @cCapturePackInfoSP <> 'R' AND @cJumpType <> 'Back')
                        BEGIN
                            SET @cOutField01 = ''
                            SET @cOutField02 = ''
                            SET @cOutField03 = ''
                            SET @cOutField04 = ''
                            SET @cOutField05 = ''
                            SET @cOutField06 = ''
                            SET @cOutField07 = ''

                            SET @cFieldAttr01 = CASE WHEN CHARINDEX('T', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                            SET @cFieldAttr02 = CASE WHEN CHARINDEX('C', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                            SET @cFieldAttr03 = CASE WHEN CHARINDEX('W', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                            SET @cFieldAttr04 = CASE WHEN CHARINDEX('R', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                            SET @cFieldAttr05 = CASE WHEN CHARINDEX('L', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                            SET @cFieldAttr06 = CASE WHEN CHARINDEX('D', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END
                            SET @cFieldAttr07 = CASE WHEN CHARINDEX('H', @cCapturePackInfoSP) = 0 THEN 'O' ELSE '' END

                            SET @nAfterScn  = 4653
                            SET @nAfterStep = 4
                            GOTO Quit
                        END

                        -- Check if ShipLabel/CartonManifest configured
                        IF (@cShipLabel <> '' OR @cCartonManifest <> '')
                        BEGIN
                            SET @cOutField01 = ''
                            SET @nAfterScn  = 4654
                            SET @nAfterStep = 5
                            GOTO Quit
                        END

                        -- No print label -> completion message -> Screen 1
                        SET @cCompletionMsg = 'PSNO: ' + ISNULL(@cPickSlipNo, '')
                        EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', 'PACKING COMPLETED', @cCompletionMsg, 'Please press ESC to continue'
    
                        SET @cErrMsg    = ''
                        SET @cOutField01 = CASE WHEN @cShowPickSlipNo = '1' THEN @cPickSlipNo ELSE '' END
                        SET @cOutField02 = ''
                        SET @cOutField03 = ''
                        SET @nAfterScn  = 4650
                        SET @nAfterStep = 1
                        GOTO Quit
                    END
                    -- NOT Complete: continue to Screen 8
                    RETURN
                END
            END
        END

    END -- IF @nFunc = 838
    RETURN

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_838ExtScn08] TO NSQL
GO
