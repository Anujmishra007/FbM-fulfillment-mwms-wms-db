SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store procedure: rdt_1812ExtScnAU                                    */  
/* Copyright      : MAERSK                                              */  
/*                                                                      */  
/* Purpose: Validate To Lane (MBOL.ExternMBOLKey)                       */  
/*                                                                      */  
/* Date       Rev  Author   Purposes                                    */  
/* 2025-05-31 1.0  SYC067   Created                                     */  
/************************************************************************/  
  
CREATE OR ALTER PROC [rdt].[rdt_1812ExtScnAU] (  
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
    @nAction          INT, --0 Jump Screen, 1 Prepare output fields .....  
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
    @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT,  
    @cUDF30 NVARCHAR( MAX)  OUTPUT   --to support max length parameter output  
    )  
AS  
BEGIN  
    SET NOCOUNT ON  
    SET QUOTED_IDENTIFIER OFF  
    SET ANSI_NULLS OFF  
    SET CONCAT_NULL_YIELDS_NULL OFF  
    
    DECLARE  
    @nMOBRECStep      INT,  
    @nMOBRECScn       INT,  
    @cTaskdetailKey   NVARCHAR( 10),  
    @cDropID          NVARCHAR( 20),  
    @cQTY             NVARCHAR( 20),  
    @nQTY             INT,  
    @cToLOC           NVARCHAR( 10),  
    @cSQLParam        NVARCHAR(MAX),  
    @cExtendedInfo1   NVARCHAR(20),  
    @cExtendedInfoSP  NVARCHAR(20)  
    
    -- Screen constant  
    DECLARE @nScn_ToLane     INT = 6520  
    DECLARE @nScn_Message    INT = 4026  
    DECLARE @nStep_Message   INT = 7  
    DECLARE @nScn_Carton     INT = 1645  
    DECLARE @nScn_ContTask   INT = 4024  
    DECLARE @nStep_ContTask  INT = 5  
    DECLARE @nScn_ShortTask  INT = 4027  
    DECLARE @nStep_ShortTask INT = 8  
    
    -- Session var  
    DECLARE @cToLane        NVARCHAR( 20)  
    DECLARE @cSuggToLane    NVARCHAR( 20)  
    DECLARE @cExtMbolKey    NVARCHAR( 15)  
    DECLARE @cMbolKey       NVARCHAR( 10)  
    DECLARE @cPickMethod    NVARCHAR( 10)  
    DECLARE @cSuggFromLOC   NVARCHAR( 10)  
    DECLARE @cSuggID        NVARCHAR( 18)  
    DECLARE @cWaveKey       NVARCHAR( 10)  
    DECLARE @cOrderKey      NVARCHAR( 10)  
    DECLARE @nShipperCnt INT = 0  
    DECLARE @nFromStep   INT  
    DECLARE @nFromScn    INT  
    
    DECLARE @cMsg1    NVARCHAR( 20),  
            @cMsg2    NVARCHAR( 20),  
            @cMsg3    NVARCHAR( 20),  
            @cMsg4    NVARCHAR( 20),  
            @cMsg5    NVARCHAR( 20)  
    
    DECLARE @cConsigneeKey  NVARCHAR( 15)  
    DECLARE @cBillToKey     NVARCHAR( 15)  
    DECLARE @cPreGenDropID  NVARCHAR( 15)  
    DECLARE @cLabelPrinter  NVARCHAR( 10)  
    DECLARE @cManiLaneLBL   NVARCHAR( 10)  
    DECLARE @tManiLaneLBL AS VariableTable  
    DECLARE @cManiLanePrinted   NVARCHAR( 10)  ='N'  
    DECLARE @cExternOrderkey   NVARCHAR( 30)   =''  
    DECLARE @cTaskPickMethod NVARCHAR(10) = ''  
    DECLARE @cTaskFromID     NVARCHAR(18) = ''  
    DECLARE @nPDSumQty       INT = 0  
    DECLARE @cPalletHeight   NVARCHAR(10) = ''  
    DECLARE @fPalletHeight   FLOAT = 0.0  
    DECLARE @cClosePalletFlag   NVARCHAR(10) = ''  
    DECLARE @cOrderType        NVARCHAR( 10)  
    DECLARE @nFilterOrdType    INT = 0  
    DECLARE @nLaneNoMixWave    INT = 0  
    DECLARE @cLaneWaveKey      NVARCHAR( 10)  
    DECLARE @cOrdWaveKey       NVARCHAR( 10)  
    DECLARE @cPalletLabel      NVARCHAR( 10)  
    DECLARE @cSKU              NVARCHAR( 30)  
    DECLARE @fCASECNT          FLOAT = 0.0  
    DECLARE @cSuggLabelNo      NVARCHAR( 20)  
    DECLARE @nSuggCartonNo     INT = 0  
    DECLARE @nCartonNo         INT = 0  
    DECLARE @cPickSlipNo       NVARCHAR( 10)  
    DECLARE @cPieceOpenCarton  NVARCHAR( 10)  
    DECLARE @cUserName         NVARCHAR( 20)  
    DECLARE @cLabelNo          NVARCHAR( 20)  
    
    DECLARE @tPalletLabel  AS VariableTable  
    DECLARE @cSQL NVARCHAR(MAX)
    
    SET @cPalletLabel = rdt.RDTGetConfig( @nFunc, 'PalletLabel', @cStorerKey)  
    IF @cPalletLabel = '0'  
        SET @cPalletLabel = ''  
    
    SET @cClosePalletFlag = rdt.RDTGetConfig( @nFunc, 'ClosePalletFlag', @cStorerKey)  
    IF @cClosePalletFlag = '0'  
        SET @cClosePalletFlag = ''  
    
    --1 = CONFIRM IN EXTSCN, 2 = CONFIRM IN ConfirmExtUpdSP  
    SET @cPieceOpenCarton = rdt.RDTGetConfig( @nFunc, 'PieceOpenCarton', @cStorerKey)  
    IF @cPieceOpenCarton = '0'  
        SET @cPieceOpenCarton = ''  
    
    -- Get session info  
    SELECT @nMOBRECStep      = [Step]  
        ,@nMOBRECScn         = [Scn]  
        ,@nFromScn           = [V_FromScn]  
        ,@nFromStep          = [V_FromStep]  
        ,@cExtendedInfoSP    = [V_String27]  
        ,@cLabelPrinter      = [Printer]  
        ,@cUserName          = [UserName]  
    FROM rdt.rdtMobRec WITH (NOLOCK)  
    WHERE Mobile = @nMobile  
    
    SET @cManiLaneLBL = rdt.RDTGetConfig( @nFunc, 'ManiLaneLBL', @cStorerKey)  
    IF @cManiLaneLBL = '0'  
        SET @cManiLaneLBL = ''  
    
    SELECT @cTaskDetailKey = Value FROM @tExtScnData WHERE Variable = '@cTaskDetailKey'  
    SELECT @cDropID        = Value FROM @tExtScnData WHERE Variable = '@cDropID'  
    SELECT @cToLOC         = Value FROM @tExtScnData WHERE Variable = '@cToLOC'  
    SELECT @cQTY           = Value FROM @tExtScnData WHERE Variable = '@cQTY'  
    SELECT @nQTY           = ISNULL(TRY_CONVERT(INT, @cQTY), 0) 
  
    IF @nFunc = 1812 -- TM Case Pick  
    BEGIN  
        SET @cTaskPickMethod = 'PP'  
    
        SELECT @cTaskPickMethod = PICKMETHOD  
            , @cTaskFromID     = FromID  
            , @cSKU            = SKU  
        FROM dbo.TASKDETAIL WITH (NOLOCK)  
        WHERE STORERKEY = @cStorerkey  
        AND TASKDETAILKEY = @cTaskDetailKey  
    
        IF ISNULL(@cTaskPickMethod,'') = 'FP'  
            SET @cDropID = @cTaskFromID  
    
        IF (@nMOBRECStep = 4 AND ISNULL(@cPieceOpenCarton,'') IN ('1','2')) -- SKU QTY STEP  
        BEGIN  
            IF @nInputKey = 1 -- ENTER  
            BEGIN  
                IF ISNULL(@cSKU,'') <> '' AND ISNULL(@nQTY,0) > 0  
                BEGIN  
                    SET @cOrderKey = ''  
                    SELECT @cOrderKey = Orderkey  
                    FROM TASKDETAIL WITH (NOLOCK)  
                    WHERE STORERKEY = @cStorerKey  
                    AND TASKDETAILKEY = @cTaskdetailKey  
    
                    SET @fCASECNT = 0.0  
                    SELECT @fCASECNT = PACK.CASECNT  
                    FROM SKU WITH (NOLOCK)  
                    JOIN PACK WITH (NOLOCK) ON SKU.PACKKEY = PACK.PACKKEY  
                    WHERE SKU.SKU = @cSKU  
                    AND SKU.STORERKEY = @cStorerkey  
    
                    IF NOT EXISTS (  
                        SELECT TOP 1 1  
                        FROM ORDERS O WITH (NOLOCK)  
                        JOIN CODELKUP C WITH (NOLOCK) ON O.[TYPE] = C.CODE AND O.STORERKEY = C.STORERKEY  
                        WHERE ORDERKEY = @cOrderKey  
                        AND C.LISTNAME = 'PCSCTN1812'  
                        AND C.SHORT = '1')  
                        GOTO Quit  
    
                    IF ISNULL(@fCASECNT,0) > 0 AND @nQTY < @fCASECNT  
                    BEGIN  
                        SET @cPickslipNo = ''  
                        SELECT @cPickslipNo = PickSlipNo  
                        FROM PACKHEADER WITH (NOLOCK)  
                        WHERE ORDERKEY = @cOrderKey  
    
                        IF ISNULL(@cPickslipNo,'') = ''  
                        BEGIN  
                            SELECT TOP 1 @cPickSlipNo = PickHeaderKey  
                            FROM PICKHEADER WITH (NOLOCK)  
                            WHERE OrderKey = @cOrderKey  
                        END  
    
                    --IF @cPickSlipNo = ''  
                    --BEGIN  
                    --   EXECUTE dbo.nspg_GetKey  
                    --      'PICKSLIP',  
                    --      9,  
                    --      @cPickSlipNo   OUTPUT,  
                    --      @bSuccess      OUTPUT,  
                    --      @nErrNo        OUTPUT,  
                    --      @cErrMsg       OUTPUT  
                    --  
                    --   SET @cPickSlipNo = 'P' + @cPickSlipNo  
                    --END  
                        --GET SUGGESTED LABELNO  
                        SET @cSuggLabelNo = ''  
    
                        SELECT TOP 1 @cSuggLabelNo  = PD.LabelNo  
                                    , @nSuggCartonNo = PD.CartonNo  
                                    --, @cPickslipNo = PD.PickSlipNo  
                        FROM PACKDETAIL PD WITH (NOLOCK)  
                        JOIN PACKHEADER PH WITH (NOLOCK) ON PD.PICKSLIPNO = PH.PICKSLIPNO  
                        WHERE PH.ORDERKEY = @cOrderKey  
                        AND PH.STORERKEY = @cStorerkey  
                        AND PD.AddWho = 'rdt.' + SUSER_SNAME()  
                        AND REFNO = 'PIECEPICK'  
                        AND PD.DROPID = @cDropID  
                        ORDER BY PD.CARTONNO DESC  
    
                        SET @cOutField01 = ISNULL(@cPickSlipNo,'')  
                        SET @cOutField02 = ISNULL(@nSuggCartonNo,0)  
                        SET @cOutField03 = ISNULL(@cSuggLabelNo,'')  
    
                        SET @cOutField04 = ''  
                        SET @cOutField05 = ''  
    
                        SET @nAfterScn = @nScn_Carton  
                        SET @nAfterStep = 99  
                    END  
                END  
            END  
        END  
    
        IF @nMOBRECStep = 6 -- To LOC  
        BEGIN  
            IF @nInputKey = 1 -- ENTER  
            BEGIN  
                SET @nPDSumQty = 0  
    
                SELECT @nPDSumQty = SUM(QTY)  
                FROM PICKDETAIL WITH (NOLOCK)  
                WHERE STORERKEY = @cStorerkey  
                AND STATUS = '5'  
                AND DROPID = @cDropID  
                AND ISNULL(@cDropID,'') <> ''  
    
                --SKIP SCREEN IF FULL SHORT FOR DROPID  
                IF ISNULL(@nPDSumQty,0) = 0  
                GOTO QUIT  
    
                --DECLARE @cMBOLKey NVARCHAR(10) = ''  
    
                SET @cMBOLKey = ''  
                SET @cOrderKey = ''  
                SELECT @cOrderKey = Orderkey  
                FROM TASKDETAIL WITH (NOLOCK)  
                WHERE STORERKEY = @cStorerKey  
                AND TASKDETAILKEY = @cTaskdetailKey  
    
                SET @cSuggToLane = ''  
    
                SELECT TOP 1 @cSuggToLane = MB.EXTERNMBOLKEY, @cMBOLKey = MB.MBOLKey  
                FROM dbo.ORDERS O WITH (NOLOCK)  
                JOIN dbo.MBOL MB WITH (NOLOCK) ON O.MBOLKEY = MB.MBOLKEY  
                WHERE O.StorerKey = @cStorerKey  
                AND   O.ORDERKEY = @cOrderKey  
                ORDER BY 1  
    
                --IF MBOLKEY FOUND BUT EXTERNMBOLKEY IS BLANK  
                --IF ISNULL(@cMBOLKey,'') <> '' AND @cSuggToLane = ''  
                --   GOTO Quit  
    
                /*  
                SELECT TOP 1 @cSuggToLane = UserDefine03  
                FROM dbo.PalletDetail PD WITH (NOLOCK)  
                WHERE PD.StorerKey = @cStorerKey  
                --AND   PD.PalletKey = @cDropID  
                --AND   PD.Status = '9'  
                AND   PD.UserDefine01 = @cOrderKey  
                AND   EXISTS ( SELECT 1 -- Look for to lane that scanned before  
                            FROM dbo.MBOL M WITH (NOLOCK)  
                            WHERE M.ExternMBOLKey = PD.UserDefine03  
                            AND   M.Status < '9')  
                ORDER BY 1  
                */  
    
                SET @cConsigneeKey = ''  
                SET @cBillToKey    = ''  
    
                SELECT TOP 1  
                @cConsigneeKey = ISNULL( O.ConsigneeKey, ''),  
                @cBillToKey = ISNULL(O.BillToKey,'')  
                FROM dbo.Orders O WITH (NOLOCK)  
                WHERE O.ORDERKEY = @cOrderKey  
    
                -- Order not yet have lane (first pallet)  
                IF @cSuggToLane = '' AND ISNULL(@cMBOLKey,'') = ''  
                BEGIN
                    -- Suggest lane as abbreviated company name  
                    SELECT @cSuggToLane = LEFT( Long, 12)+ CONVERT(NVARCHAR(8),GETDATE(),112)  
                    FROM dbo.CodeLKUP WITH (NOLOCK)  
                    WHERE ListName = 'RDTCSTCODE'  
                        AND Code = @cConsigneeKey  
                        AND StorerKey = @cStorerKey 
                END 
    
                -- Order not yet have lane (first pallet)  
                IF @cSuggToLane = '' AND ISNULL(@cMBOLKey,'') = '' 
                BEGIN 
                    -- Suggest lane as abbreviated company name  
                    SELECT @cSuggToLane = LEFT( Long, 12)+ CONVERT(NVARCHAR(8),GETDATE(),112)  
                    FROM dbo.CodeLKUP WITH (NOLOCK)  
                    WHERE ListName = 'RDTCSTCODE'  
                        AND Code = @cBillToKey  
                        AND StorerKey = @cStorerKey  
                END
    
                -- To Lane screen  
                SET @cOutField01 = CASE WHEN ISNULL( @cSuggToLane, '') <> '' THEN @cSuggToLane ELSE '' END -- To Lane  
                SET @cOutField02 = ''  
    
                IF ISNULL(@cSuggToLane,'') <> '' AND ISNULL(@cLabelPrinter,'') <> ''  
                BEGIN  
                    IF ISNULL(@cManiLaneLBL,'') <> ''  
                    BEGIN  
    
                        SELECT @cExternOrderkey = EXTERNORDERKEY  
                        FROM ORDERS WITH (NOLOCK)  
                        WHERE ORDERKEY = @cOrderKey  
    
                        INSERT INTO @tManiLaneLBL (Variable, Value) VALUES  
                            ( '@cStorerKey',      @cStorerKey),  
                            ( '@cManifestLane',   @cSuggToLane),  
                            ( '@cExternOrderkey', @cExternOrderkey),  
                            ( '@cDropID',         @cDropID)  
    
                        -- Print label  
                        EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, '1', @cFacility, @cStorerKey, @cLabelPrinter, '',  
                            @cManiLaneLBL,    -- Report type  
                            @tManiLaneLBL,    -- Report params  
                            'rdt_1812ExtScnAU',  
                            @nErrNo  OUTPUT,  
                            @cErrMsg OUTPUT  
    
                        IF @nErrNo = 0  
                            SET @cManiLanePrinted = 'Y'  
                    END  
                END  
    
                SET @nAfterScn = @nScn_ToLane  
                SET @nAfterStep = 99  
    
                GOTO Quit  
            END  
        END  
    
        IF @nMOBRECStep = 99 -- Customize screens  
        BEGIN  
            IF @nScn = @nScn_Carton -- Create Carton screen  
            BEGIN  
                IF @nInputKey = 1  
                BEGIN  
                    DECLARE @cActLabelNo NVARCHAR(20)  
                    DECLARE @cOption     NVARCHAR(1)  
    
                    SET @cPickSlipNo  = @cOutField01  
                    SET @nCartonNo    = @cOutField02  
                    SET @cSuggLabelNo = @cOutField03  
                    SET @cActLabelNo  = @cInField04  
                    SET @cOption      = @cInField05  
    
                    IF @cOption NOT IN ('', '1')  
                    BEGIN  
                        SET @nErrNo = 267601  
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid option  
                        GOTO Quit  
                    END  
    
                    IF ISNULL(@cPickSlipNo,'') = '' AND @cOption <> '1'  
                    BEGIN  
                        SET @nErrNo = 267602  
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid option  
                        GOTO Quit  
                    END  
    
                    IF @cOption = '1'  
                    BEGIN  
                        -- Create New Label No  
                        SET @cActLabelNo = ''  
                    END  
                    ELSE  
                        BEGIN  
                        IF @cActLabelNo = '' OR @cActLabelNo IS NULL  
                        BEGIN  
                            SET @nErrNo = 267603  
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LabelNo needed  
                            GOTO Quit  
                        END  
    
                        IF @cActLabelNo <> @cSuggLabelNo  
                        BEGIN  
                            -- Check if labelno used in other pickslip  
                            IF EXISTS( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)  
                                WHERE StorerKey = @cStorerKey  
                                AND LabelNo = @cActLabelNo  
                                AND PickSlipNo <> @cPickSlipNo  
                                AND ISNULL(@cPickSlipNo,'') <> '')  
                            BEGIN  
                                SET @nErrNo = 267604  
                                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LabelNo Used  
                                GOTO Quit  
                            END  
                            -- Check if labelno is non Piece Pick type  
                            IF NOT EXISTS( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)  
                                WHERE StorerKey = @cStorerKey  
                                AND LabelNo = @cActLabelNo  
                                AND PickSlipNo = @cPickSlipNo  
                                AND ISNULL(REFNO,'') = 'PIECEPICK'  
                                AND ISNULL(@cPickSlipNo,'') <> ''  
                                AND DROPID = @cDropID)  
                            BEGIN  
                                SET @nErrNo = 267605  
                                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid LabelNo  
                                GOTO Quit  
                            END  
                        END  
                    END  
    
                    IF @cPieceOpenCarton = '1'  
                    BEGIN  
                        -- Confirm  
                        EXEC rdt.rdt_1812ExtScnAU_PackCtn_Confirm  
                            @nMobile, @nFunc, @cLangCode, @nStep OUTPUT, @nScn OUTPUT, @nInputKey, @cFacility, @cStorerkey,  
                            @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @cToLane,  
                            @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  
                            @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  
                            @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  
                            @cActLabelNo OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  
                            @cOption    OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  
                            @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  
                            @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  
                            @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  
                            @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  
                            @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  
                            @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  
                            @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  
                            @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  
                            @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  
                            @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  
                            @nErrNo     OUTPUT,  
                            @cErrMsg    OUTPUT  
                        IF @nErrNo <> 0  
                            GOTO Quit  
                    END  
                    ELSE IF @cPieceOpenCarton = '2'
                    BEGIN
                        BEGIN TRY
                            BEGIN TRAN rdt_1812ExtScnAU
                            
                            UPDATE TASKDETAIL WITH (ROWLOCK)
                            SET CASEID = ISNULL(@cActLabelNo,'')
                            WHERE TASKDETAILKEY = @cTaskdetailKey
                            
                            COMMIT TRAN rdt_1812ExtScnAU
                        END TRY
                        BEGIN CATCH
                            IF @@TRANCOUNT > 0
                                ROLLBACK TRAN rdt_1812ExtScnAU
                            SET @nErrNo = 267614
                            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                            GOTO Quit
                        END CATCH
                    END
    
                    -- Prepare next screen var  
                    SET @cOutField01 = ''  
                    SET @cOutField02 = ''  
                    SET @cOutField03 = ''  
                    SET @cOutField04 = ''  
                    SET @cOutField05 = ''  
    
                    DECLARE @nTaskQty INT = 0  
    
                    SELECT @nTaskQty = QTY  
                    FROM TASKDETAIL WITH (NOLOCK)  
                    WHERE TASKDETAILKEY = @cTaskdetailKey  
                    AND STORERKEY = @cStorerKey
    
                    IF ISNULL(@nTaskQty,0) > @nQTY  
                    BEGIN  
                        SET @nAfterScn = @nScn_ShortTask  
                        SET @nAfterStep = @nStep_ShortTask  
                    END  
                    ELSE  
                    BEGIN  
                        SET @nAfterScn = @nScn_ContTask  
                        SET @nAfterStep = @nStep_ContTask  
                    END  
    
                END  
            END  
    
            IF @nScn = @nScn_ToLane -- To Loc screen  
            BEGIN  
                IF ISNULL(@cOutField01,'') = '' --If no suggested, REGRAB SUGGESTED LANE  
                BEGIN  
                    SET @cMBOLKey = ''  
                    SET @cOrderKey = ''  
                    SELECT @cOrderKey = Orderkey  
                    FROM TASKDETAIL WITH (NOLOCK)  
                    WHERE STORERKEY = @cStorerKey  
                    AND TASKDETAILKEY = @cTaskdetailKey  
    
                    SET @cSuggToLane = ''  
    
                    SELECT TOP 1 @cSuggToLane = MB.EXTERNMBOLKEY, @cMBOLKey = MB.MBOLKey  
                    FROM dbo.ORDERS O WITH (NOLOCK)  
                    JOIN dbo.MBOL MB WITH (NOLOCK) ON O.MBOLKEY = MB.MBOLKEY  
                    WHERE O.StorerKey = @cStorerKey  
                    AND   O.ORDERKEY = @cOrderKey  
                    ORDER BY 1  
    
                    --IF MBOLKEY FOUND BUT EXTERNMBOLKEY IS BLANK  
                    --IF ISNULL(@cMBOLKey,'') <> '' AND @cSuggToLane = ''  
                    --   GOTO Quit  
    
                    /*  
                    SELECT TOP 1 @cSuggToLane = UserDefine03  
                    FROM dbo.PalletDetail PD WITH (NOLOCK)  
                    WHERE PD.StorerKey = @cStorerKey  
                    --AND   PD.PalletKey = @cDropID  
                    --AND   PD.Status = '9'  
                    AND   PD.UserDefine01 = @cOrderKey  
                    AND   EXISTS ( SELECT 1 -- Look for to lane that scanned before  
                                    FROM dbo.MBOL M WITH (NOLOCK)  
                                    WHERE M.ExternMBOLKey = PD.UserDefine03  
                                    AND   M.Status < '9')  
                    ORDER BY 1  
                    */  
    
                    SET @cConsigneeKey = ''  
                    SET @cBillToKey    = ''  
    
                    SELECT TOP 1  
                        @cConsigneeKey = ISNULL( O.ConsigneeKey, ''),  
                        @cBillToKey = ISNULL(O.BillToKey,'')  
                    FROM dbo.Orders O WITH (NOLOCK)  
                    WHERE O.ORDERKEY = @cOrderKey  
    
                    -- Order not yet have lane (first pallet)  
                    IF @cSuggToLane = '' AND ISNULL(@cMBOLKey,'') = ''  
                    BEGIN
                        -- Suggest lane as abbreviated company name  
                        SELECT @cSuggToLane = LEFT( Long, 12)+ CONVERT(NVARCHAR(8),GETDATE(),112)  
                        FROM dbo.CodeLKUP WITH (NOLOCK)  
                        WHERE ListName = 'RDTCSTCODE'  
                            AND Code = @cConsigneeKey  
                            AND StorerKey = @cStorerKey  
                    END
    
                    -- Order not yet have lane (first pallet)  
                    IF @cSuggToLane = '' AND ISNULL(@cMBOLKey,'') = ''  
                    BEGIN
                        -- Suggest lane as abbreviated company name  
                        SELECT @cSuggToLane = LEFT( Long, 12)+ CONVERT(NVARCHAR(8),GETDATE(),112)  
                        FROM dbo.CodeLKUP WITH (NOLOCK)  
                        WHERE ListName = 'RDTCSTCODE'  
                            AND Code = @cBillToKey  
                            AND StorerKey = @cStorerKey  
                    END
    
                    -- To Lane screen  
                    SET @cOutField01 = CASE WHEN ISNULL( @cSuggToLane, '') <> '' THEN @cSuggToLane ELSE '' END -- To Lane  
    
                    IF ISNULL(@cSuggToLane,'') <> '' AND ISNULL(@cLabelPrinter,'') <> ''  
                    BEGIN  
                        IF ISNULL(@cManiLaneLBL,'') <> ''  
                        BEGIN  
    
                            SELECT @cExternOrderkey = EXTERNORDERKEY  
                            FROM ORDERS WITH (NOLOCK)  
                            WHERE ORDERKEY = @cOrderKey  
    
                            INSERT INTO @tManiLaneLBL (Variable, Value) VALUES  
                                ( '@cStorerKey',      @cStorerKey),  
                                ( '@cManifestLane',   @cSuggToLane),  
                                ( '@cExternOrderkey', @cExternOrderkey),  
                                ( '@cDropID',         @cDropID)  
    
                            -- Print label  
                            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, '1', @cFacility, @cStorerKey, @cLabelPrinter, '',  
                                @cManiLaneLBL,    -- Report type  
                                @tManiLaneLBL,    -- Report params  
                                'rdt_1812ExtScnAU',  
                                @nErrNo  OUTPUT,  
                                @cErrMsg OUTPUT  
    
                            IF @nErrNo = 0  
                                SET @cManiLanePrinted = 'Y'  
                        END  
                    END  
                END  
    
                IF @nInputKey = 1 -- ENTER  
                BEGIN  
                    -- Screen mapping  
                    SET @cToLane = @cInField02  
                    SET @cOutField02 = @cInField02  
                    SET @cSuggToLane = @cOutField01  
    
                    IF ISNULL(@cClosePalletFlag,'') = '1'  
                    BEGIN  
                        SET @cPalletHeight = @cInField03  
    
                        IF ISNULL(@cPalletHeight,'') = ''  
                        BEGIN  
                            SET @nErrNo = 267606  
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Height  
                            EXEC rdt.rdtSetFocusField @nMobile, 3  
                            GOTO Quit  
                        END  
    
                        SET @nErrNo = rdt.rdtIsValidQty( @cPalletHeight, 21)  
                        IF @nErrNo = 0  
                        BEGIN  
                            SET @nErrNo = 267607  
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Height  
                            EXEC rdt.rdtSetFocusField @nMobile, 3  
                            SET @cOutField05 = ''  
                            GOTO QUIT  
                        END  
                        SET @nErrNo = 0  
                        SET @cOutField03 = @cPalletHeight  
                    END  
    
                    --SET @fPalletHeight = ISNULL( CAST( @cPalletHeight AS FLOAT), 0)  
    
                    -- Check To Lane  
                    IF @cToLane = ''  
                    BEGIN  
                        SET @nErrNo = 267608  
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need Lane  
                        GOTO Quit  
                    END  
    
                    SET @nShipperCnt = 0  
                    SELECT @nShipperCnt = COUNT( DISTINCT O.ShipperKey)  
                    FROM dbo.ORDERS O WITH (NOLOCK)  
                    WHERE O.StorerKey = @cStorerKey  
                    AND   EXISTS ( SELECT 1  
                                    FROM dbo.MBOLDETAIL MD WITH (NOLOCK)  
                                    JOIN dbo.MBOL M WITH (NOLOCK) ON ( MD.MbolKey = M.MbolKey)  
                                    WHERE O.OrderKey = MD.OrderKey  
                                    AND   M.ExternMbolKey = @cToLane  
                                    AND   M.Status < '9')  
    
                    IF @nShipperCnt > 1  
                    BEGIN  
                        SET @nErrNo = 267609  
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Mix Shipper  
                        GOTO Quit  
                    END  
    
                    SET @nShipperCnt = 0  
                    SELECT @nShipperCnt = COUNT( DISTINCT O.ShipperKey)  
                    FROM dbo.ORDERS O WITH (NOLOCK)  
                    WHERE O.StorerKey = @cStorerKey  
                    AND   EXISTS ( SELECT 1  
                                    FROM dbo.PICKDETAIL PD WITH (NOLOCK)  
                                    JOIN dbo.TaskDetail TD WITH (NOLOCK) ON ( PD.TaskDetailKey = TD.TaskDetailKey)  
                                    WHERE O.OrderKey = PD.OrderKey  
                                    AND   TD.DropID = @cDropID  
                                    AND   TD.Status<'9')  --ALT028  
    
                    IF @nShipperCnt > 1  
                    BEGIN  
                        SET @nErrNo = 267610  
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Mix Shipper  
                        GOTO Quit  
                    END  
    
                    SET @cOrderKey = ''  
                    SELECT @cOrderKey = Orderkey  
                    FROM TASKDETAIL WITH (NOLOCK)  
                    WHERE STORERKEY = @cStorerKey  
                    AND TASKDETAILKEY = @cTaskdetailKey  
    
                    SET @cOrderType = ''  
                    SELECT @cOrderType = [TYPE]  
                    FROM ORDERS WITH (NOLOCK)  
                    WHERE STORERKEY = @cStorerKey  
                    AND ORDERKEY = @cOrderKey  
    
                    IF NOT EXISTS( SELECT 1  
                                    FROM dbo.MBOL M WITH (NOLOCK)  
                                    JOIN dbo.ORDERS O WITH (NOLOCK) ON ( M.MbolKey = O.MBOLKey)  
                                    WHERE O.StorerKey = @cStorerKey  
                                    AND   O.Orderkey = @cOrderkey  
                                    AND   M.Status < '9')  
                    BEGIN  
    
                        IF EXISTS ( SELECT 1  
                                    FROM dbo.Codelkup WITH (NOLOCK)  
                                    WHERE ListName = 'LANECONFIG'  
                                    AND   Code = 'NOMIXWAVE'  
                                    AND   StorerKey = @cStorerKey  
                                    AND   code2 = @cOrderType)  
                            SET @nFilterOrdType = 1  
                        ELSE  
                            SET @nFilterOrdType = 0  
    
                        SELECT @nLaneNoMixWave = Short FROM dbo.Codelkup WITH (NOLOCK)  
                        WHERE ListName = 'LANECONFIG'  
                        AND   Code = 'NOMIXWAVE'  
                        AND   StorerKey = @cStorerKey  
                        AND  (( @nFilterOrdType = 0 AND code2 = '') OR ( @nFilterOrdType = 1 AND code2 = @cOrderType))  
    
                        SELECT TOP 1 @cLaneWaveKey = O.UserDefine09  
                        FROM dbo.MBOL M WITH (NOLOCK)  
                        JOIN dbo.MBOLDetail MD WITH (NOLOCK) ON MD.MBOLKey = M.MBOLKey  
                        JOIN dbo.Orders O WITH (NOLOCK) ON O.OrderKey = MD.OrderKey AND O.MBOLKey = M.MBOLKey  
                        WHERE O.StorerKey = @cStorerKey  
                        AND M.ExternMBOLKey = @cToLane  
    
                        SELECT @cOrdWaveKey = UserDefine09 FROM dbo.Orders WITH (NOLOCK)  
                        WHERE OrderKey = @cOrderKey     -- To-be scanned order  
    
                        IF @nLaneNoMixWave = 1  
                        AND (ISNULL(@cLaneWaveKey, '') <> '' AND @cOrdWaveKey <> @cLaneWaveKey)  
                        BEGIN  
                            SET @nErrNo = 267611  
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lane Mix Wave  
                            GOTO Quit  
                        END  
    
                    END  
    
                    SELECT TOP 1  
                        @cMbolKey = O.MBOLKey,  
                        @cWaveKey = O.UserDefine09  
                    FROM dbo.PICKDETAIL PD WITH (NOLOCK)  
                    JOIN dbo.ORDERS O WITH (NOLOCK) ON ( PD.OrderKey = O.OrderKey)  
                    WHERE PD.TaskDetailKey = @cTaskdetailKey  
                    ORDER BY 1  
    
                    IF ISNULL( @cMbolKey, '') <> ''  
                    BEGIN  
                        SELECT @cExtMbolKey = ExternMBOLKey  
                        FROM dbo.MBOL WITH (NOLOCK)  
                        WHERE MbolKey = @cMbolKey  
    
                        IF ISNULL( @cExtMbolKey, '') <> '' AND ( @cExtMbolKey <> @cToLane)  
                        BEGIN  
                            SET @nErrNo = 267612  
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Diff Lane  
                            GOTO Quit  
                        END  
    
                        IF ISNULL( @cExtMbolKey, '') = ''  
                        BEGIN  
                            SET @nErrNo = 267613  
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NoLaneAssign  
                            GOTO Quit  
                        END  
                    END  
    
                /*  
                IF EXISTS( SELECT 1  
                            FROM dbo.MBOL M WITH (NOLOCK)  
                            JOIN dbo.ORDERS O WITH (NOLOCK) ON ( M.MbolKey = O.MBOLKey)  
                            WHERE O.StorerKey = @cStorerKey  
                            AND   O.UserDefine09 = @cWaveKey  
                            AND   M.ExternMBOLKey <> @cToLane  
                            AND   M.Status < '9')  
                BEGIN  
                    SET @nErrNo = 228955  
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No Split Lane  
                    GOTO Quit  
                END  
                */  
    
                -- Confirm  
                EXEC rdt.rdt_1812ExtScnAU_Confirm  
                    @nMobile, @nFunc, @cLangCode, @nStep OUTPUT, @nScn OUTPUT, @nInputKey, @cFacility, @cStorerkey,  
                    @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @cToLane,  
                    @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  
                    @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  
                    @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  
                    @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  
                    @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  
                    @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  
                    @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  
                    @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  
                    @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  
                    @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  
                    @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  
                    @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  
                    @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  
                    @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  
                    @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  
                    @nErrNo     OUTPUT,  
                    @cErrMsg    OUTPUT  
                IF @nErrNo <> 0  
                    GOTO Quit  
                ELSE  
                BEGIN  
                    IF ISNULL(@cManiLanePrinted,'') <> 'Y' AND ISNULL(@cSuggToLane,'') = ''  
                    BEGIN  
                        IF ISNULL(@cManiLaneLBL,'') <> ''  
                        BEGIN  
    
                        SELECT @cExternOrderkey = EXTERNORDERKEY  
                        FROM ORDERS WITH (NOLOCK)  
                        WHERE ORDERKEY = @cOrderKey  
    
                        INSERT INTO @tManiLaneLBL (Variable, Value) VALUES  
                            ( '@cStorerKey',      @cStorerKey),  
                            ( '@cManifestLane',   @cToLane),  
                            ( '@cExternOrderkey', @cExternOrderkey),  
                            ( '@cDropID',         @cDropID)  
    
                        -- Print label  
                        EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, '1', @cFacility, @cStorerKey, @cLabelPrinter, '',  
                            @cManiLaneLBL,    -- Report type  
                            @tManiLaneLBL,    -- Report params  
                            'rdt_1812ExtScnAU',  
                            @nErrNo  OUTPUT,  
                            @cErrMsg OUTPUT  
    
                        IF @nErrNo = 0  
                            SET @cManiLanePrinted = 'Y'  
    
                        SET @nErrNo = 0  
                        SET @cErrMsg = ''  
                    END  
                    END  
    
                    IF EXISTS (SELECT TOP 1 1 FROM PALLET WITH (NOLOCK) WHERE PALLETKEY = @cDropID)  
                    BEGIN  
    
                        IF ISNULL(@cPalletLabel,'') <> '' AND ISNULL(@cLabelPrinter,'') <> ''  
                        BEGIN  
    
                            INSERT INTO @tPalletLabel (Variable, Value) VALUES  
                                ( '@cStorerKey', @cStorerKey),  
                                ( '@cPalletKey', @cDropID)  
    
                            -- Print label  
                            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, '',  
                                @cPalletLabel,    -- Report type  
                                @tPalletLabel,    -- Report params  
                                'rdt_1812ExtScnAU',  
                                @nErrNo  OUTPUT,  
                                @cErrMsg OUTPUT  
    
                            SET @nErrNo = 0  
                            SET @cErrMsg = ''  
                        END  
                    END  
                END  
    
                -- Prepare next screen var  
                SET @cOutField01 = @cToLOC  
                SET @cOutField02 = ''  
                SET @cOutField03 = ''  
    
                SET @nAfterScn = @nScn_Message  
                SET @nAfterStep = @nStep_Message  
    
                --IF EXISTS ( SELECT 1  
                --FROM dbo.TaskDetail TD WITH (NOLOCK)  
                --CROSS APPLY (SELECT SUM(QTY) QTY FROM dbo.PICKDETAIL WITH (NOLOCK)  
                --             WHERE TaskDetailKey = TD.TaskDetailKey AND ORDERKEY = TD.ORDERKEY  
                -- AND DROPID = TD.DROPID AND STATUS = '5') AS PD  
                --OUTER APPLY (SELECT SUM(QTY) QTY FROM dbo.PACKDETAIL PD WITH (NOLOCK)                --             JOIN dbo.PACKHEADER PH WITH (NOLOCK) ON PD.PICKSLIPNO = PH.PICKSLIPNO  
                --             WHERE PH.ORDERKEY = TD.ORDERKEY AND DROPID = TD.DROPID) AS PAD  
                --WHERE TD.DropID = @cDropID  
                --AND   TD.STORERKEY = @cStorerkey  
                --AND   TD.Status<'9'  
                --AND ISNULL(PD.QTY,0) <> ISNULL(PAD.QTY,0))  --ALT028  
                --BEGIN  
                --   SET @cMsg1 = 'Please Pack'  
                --   SET @cMsg2 = 'Remaining Loose'  
                --   SET @cMsg3 = 'Units using'  
                --   SET @cMsg4 = @cDropID  
                --   SET @cMsg5 = ''  
            --  
                --   EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT,  
                --      @cMsg1, @cMsg2, @cMsg3, @cMsg4, @cMsg5  
                --END  
    
                GOTO Quit  
            END  
    
                IF @nInputKey = 0 -- ESC  
                BEGIN  
                    --REMAIN CURRENT SCREEN TO PREVENT OVER PACK  
                    SET @nAfterScn = @nScn_ToLane  
                    SET @nAfterStep = 99  
                    /*  
                -- Back to FromID screen (full pallet)  
                IF @nFromStep = 3  
                BEGIN  
                    -- Get session info  
                    SELECT  
                        @nFromScn      = V_FromScn,  
                        @nFromStep     = V_FromStep,  
                        @cPickMethod   = V_String4,  
                        @cSuggFromLOC  = V_LOC,  
                        @cSuggID       = V_ID  
                    FROM rdt.rdtMobRec WITH (NOLOCK)  
                    WHERE Mobile = @nMobile  
    
                    -- Prepare next screen variable  
                    SET @cOutField01 = @cPickMethod  
                    SET @cOutField02 = @cDropID  
                    SET @cOutField03 = @cSuggFromLOC  
                    SET @cOutField04 = @cSuggID  
                    SET @cOutField05 = '' -- FromID  
                END  
    
                -- Back to close pallet screen  
                IF @nFromStep = 5  
                BEGIN  
                    -- Prepare next screen variable  
                    SET @cOutField01 = '' -- Option  
                END  
    
                -- Back to short pick screen  
                IF @nFromStep = 8  
                BEGIN  
                    -- Prepare next screen variable  
                    SET @cOutField01 = '' -- Option  
                END  
    
                    -- Back to prev screen  
                    SET @nAfterScn = @nFromScn  
                    SET @nAfterStep = @nFromStep  
                    */  
                END  
    
            GOTO Quit  
        END  
        END  
    END  
  
Quit:  
    -- Extended info  
    IF @cExtendedInfoSP <> ''  
    BEGIN  
        IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')  
        BEGIN  
            SET @cExtendedInfo1 = ''  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +  
                ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep'  
            SET @cSQLParam =  
                '@nMobile         INT,           ' +  
                '@nFunc           INT,           ' +  
                '@cLangCode       NVARCHAR( 3),  ' +  
                '@nStep           INT,           ' +  
                '@cTaskdetailKey  NVARCHAR( 10), ' +  
                '@cExtendedInfo1  NVARCHAR( 20) OUTPUT, ' +  
                '@nErrNo          INT           OUTPUT, ' +  
                '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +  
                '@nAfterStep      INT '  
    
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
                @nMobile, @nFunc, @cLangCode, 99, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep  
    
            SET @cOutField10 = @cExtendedInfo1  
        END  
    END  
    
END  
  
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_1812ExtScnAU TO NSQL 
GO  