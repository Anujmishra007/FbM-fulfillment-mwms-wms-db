SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/  
/* Store procedure: rdt_1812ExtScnAU_PackCtn_Confirm                          */  
/* Copyright      : MAERSK                                                    */  
/*                                                                            */  
/* Purpose: Create pallet/mbol/packinfo record after key in toloc             */  
/*                                                                            */  
/* Date       Rev  Author   Purposes                                          */  
/* 2025-06-19 1.0  SYC067   Created                                           */  
/******************************************************************************/  
  
CREATE OR ALTER PROC [rdt].[rdt_1812ExtScnAU_PackCtn_Confirm] (  
   @nMobile          INT,  
   @nFunc            INT,  
   @cLangCode        NVARCHAR( 3),  
   @nStep            INT OUTPUT,  
   @nScn             INT OUTPUT,  
   @nInputKey        INT,  
   @cFacility        NVARCHAR( 5),  
   @cStorerKey       NVARCHAR( 15),  
   @cTaskdetailKey   NVARCHAR( 10),  
   @cDropID          NVARCHAR( 20),  
   @nQTY             INT,  
   @cToLOC           NVARCHAR( 10),  
   @cToLane          NVARCHAR( 20),  
   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  
   @nErrNo           INT           OUTPUT,  
   @cErrMsg          NVARCHAR( 20) OUTPUT  
)  
AS  
BEGIN  
    SET NOCOUNT ON  
    SET QUOTED_IDENTIFIER OFF  
    SET ANSI_NULLS OFF  
    SET CONCAT_NULL_YIELDS_NULL OFF  
    
    DECLARE @nTranCount  INT  
    DECLARE @nCartonNo   INT  
    DECLARE @cOrderKey   NVARCHAR( 10)  
    DECLARE @cSKU        NVARCHAR( 20)  
    DECLARE @cUserName   NVARCHAR( 18)  
    DECLARE @cLabelNo    NVARCHAR( 20)  
    
    
    --DECLARE @cStorerKey     NVARCHAR(15)  
    --DECLARE @cSKU           NVARCHAR(20)  
    --DECLARE @nQTY           INT  
    --DECLARE @cDropID        NVARCHAR(20)  
    DECLARE @cFromLOC       NVARCHAR(10)  
    --DECLARE @cOrderKey      NVARCHAR(10)  
    DECLARE @cPickSlipNo    NVARCHAR(10) = ''  
    DECLARE @cLot           NVARCHAR(10)  
    DECLARE @cID            NVARCHAR(18) = ''  
    DECLARE @cGroupKey      NVARCHAR( 10)  
    DECLARE @cTaskPickMethod NVARCHAR(10) = ''  
    DECLARE @c_PickDetailKey NVARCHAR(10) = ''  
    
    DECLARE @cClosePalletFlag   NVARCHAR(10) = ''  
    
    --DECLARE @nCartonNo   INT = 0  
    DECLARE @cLabelLine  NVARCHAR(5) = ''  
    DECLARE @cNewLine    NVARCHAR(1) = 'N'  
    
    DECLARE @cConsigneeKey NVARCHAR( 15) = ''  
    DECLARE @cBillToKey    NVARCHAR( 20) = ''  
    DECLARE @cOrderType    NVARCHAR( 20) = ''  
    
    DECLARE @cCustomerType1     NVARCHAR( 20) = '' --PALLET / CASE  
    DECLARE @cCustomerType2     NVARCHAR( 20) = '' --SANDWICH / RAINBOW  
    DECLARE @cCustomerType3     NVARCHAR( 20) = '' --MAX SKU PER PALLET  
    DECLARE @cCustomerType4     NVARCHAR( 20) = '' --PALLET TYPE: CHEP / LOSCAM / PLAIN  
    DECLARE @cCustomerType5     NVARCHAR( 20) = '' --CASE CONVERT QTY  
    DECLARE @cPrintCopy         NVARCHAR(  1) = '' --Print Copy  
    DECLARE @nNoOfCopy         INT = 1  
    
    DECLARE @cPackMethod       NVARCHAR( 20) = '' --PALLET / CASE / PIECE  
    DECLARE @cPackCaseType     NVARCHAR( 20) = '' --SANDWICH / RAINBOW  
    DECLARE @cPalletType       NVARCHAR( 20) = '' --CHEP / LOSCAM / PLAIN,  
    
    DECLARE @fCube               FLOAT = 0  
    DECLARE @fLength             FLOAT = 0  
    DECLARE @fWidth              FLOAT = 0  
    DECLARE @fHeight             FLOAT = 0  
    DECLARE @fWeight             FLOAT = 0  
    DECLARE @fCartonWeight       FLOAT = 0  
    DECLARE @fSKUWeight          FLOAT = 0  
    DECLARE @cCartonType         NVARCHAR( 10)  
    DECLARE @cCube               NVARCHAR( 10)  
    DECLARE @cWeight             NVARCHAR( 10)  
    DECLARE @cDefaultcartontype  NVARCHAR( 10)  
    DECLARE @cDefaultpallettype  NVARCHAR( 10)  
    DECLARE @cUpdatePackDetailInfo  NVARCHAR(  1)  
    DECLARE @nPackDetailInfoKey BIGINT  
    DECLARE @cPackData1      NVARCHAR( 30)  
    DECLARE @cPackData2      NVARCHAR( 30)  
    DECLARE @cPackData3      NVARCHAR( 30)  
    DECLARE @cLottable01     NVARCHAR( 18)  
    
    DECLARE @cShipLabel          NVARCHAR( 10),  
            @cCartonManifest     NVARCHAR( 10),  
            @cCstLabelSP         NVARCHAR(30) ,  
            @cLabelPrinter    NVARCHAR( 10),  
            @cPaperPrinter    NVARCHAR( 10),  
            @cUCCNo           NVARCHAR( 20)  
    
    DECLARE @tShipLabel AS VariableTable  
    DECLARE @tCartonManifest AS VariableTable  
    
    DECLARE @cDefaultWeight    NVARCHAR( 1)  
    DECLARE @cGenPackLabelNoSP NVARCHAR(20)  
    --DECLARE @cLabelNo          NVARCHAR(20)  
    DECLARE @cSQL              NVARCHAR( MAX)  
    DECLARE @cSQLParam         NVARCHAR( MAX)  
    DECLARE @cCheckMaxByBatch  NVARCHAR(  1)  
    DECLARE @bSuccess          INT  
    
    SELECT @cPaperPrinter    = Printer_Paper,  
            @cLabelPrinter    = Printer  
    FROM RDT.RDTMOBREC WITH (NOLOCK)  
    WHERE MOBILE = @nMobile  

    SET @nErrNo = 0
    SET @cErrMsg = ''   
    
    SET @cPackData1 = ''  
    SET @cPackData2 = ''  
    SET @cPackData3 = ''

    SET @cUpdatePackDetailInfo = rdt.RDTGetConfig( @nFunc, 'UpdatePackDetailInfo', @cStorerKey)  
    
    SET @cCheckMaxByBatch = rdt.RDTGetConfig( @nFunc, 'CheckMaxByBatch', @cStorerKey)  
    IF @cCheckMaxByBatch = '0'  
        SET @cCheckMaxByBatch = ''  
    
    SET @cGenPackLabelNoSP = rdt.RDTGetConfig( @nFunc, 'GenPackLabelNoSP', @cStorerKey)  
    IF @cGenPackLabelNoSP = '0'  
        SET @cGenPackLabelNoSP = ''  
    
    SET @cShipLabel = rdt.RDTGetConfig( @nFunc, 'ShipLabel', @cStorerKey)  
    IF @cShipLabel = '0'  
        SET @cShipLabel = ''  
    
    SET @cCartonManifest = rdt.RDTGetConfig( @nFunc, 'CartonManifest', @cStorerKey)  
    IF @cCartonManifest = '0'  
        SET @cCartonManifest = ''  
    
    SET @cDefaultcartontype=rdt.RDTGetConfig( @nFunc, 'DefaultCartonType', @cStorerKey)  --(cc01)  
    IF @cDefaultcartontype = '0'  
        SET @cDefaultcartontype = ''  
    
    SET @cDefaultpallettype=rdt.RDTGetConfig( @nFunc, 'DefaultPalletType', @cStorerKey)  --(cc01)  
    IF @cDefaultpallettype = '0'  
        SET @cDefaultpallettype = ''  
    
    SET @cDefaultWeight = rdt.RDTGetConfig( @nFunc, 'DefaultWeight', @cStorerKey)  
    
    SELECT @cUserName = UserName  
    FROM rdt.RDTMOBREC WITH (NOLOCK)  
    WHERE Mobile = @nMobile  
    
    -- Get task info  
    SELECT  
        @cStorerKey = StorerKey,  
        @cSKU = SKU,  
        --@nQTY = QTY,  
        --@cDropID = DropID,  
        @cFromLOC = FromLOC,  
        @cOrderKey = OrderKey,  
        @cLot = Lot,  
        @cGroupKey = GroupKey,  
        @cTaskPickMethod = PickMethod,  
        @cID  = FromID  
    FROM dbo.TaskDetail WITH (NOLOCK)  
    WHERE TaskDetailKey = @cTaskdetailKey  
    
    
    SET @cLottable01 = ''  
    SELECT @cLottable01 = LA.LOTTABLE01  
    FROM dbo.LOTATTRIBUTE LA WITH (NOLOCK)  
    WHERE LA.LOT = @cLot  
    AND LA.STORERKEY = @cStorerkey  
    AND LA.SKU = @cSKU  
    
    IF ISNULL(@cTaskPickMethod,'') = 'FP'  
        SET @cDropID = @cID  

    -- Handling transaction  
    SET @nTranCount = @@TRANCOUNT  
    BEGIN TRAN  -- Begin our own transaction  
    SAVE TRAN rdt_1812ExtScnAU_PackCtn_Confirm -- For rollback or commit only our own transaction  
    
    IF ISNULL(@cTaskPickMethod,'') = 'FP'  
    BEGIN  
        BEGIN TRY
            UPDATE dbo.TaskDetail WITH (ROWLOCK)  
            SET DropID = @cDropID  
            WHERE TaskDetailKey = @cTaskdetailKey  
        END TRY
        BEGIN CATCH
            SET @nErrNo = 269510
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDTaskDtlFail
            GOTO RollBackTran
        END CATCH
    
        DECLARE CUR_PICK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
        SELECT PICKDETAILKEY  
        FROM dbo.PICKDETAIL WITH (NOLOCK)  
        WHERE STORERKEY = @cStorerKey  
        AND TASKDETAILKEY = @cTaskdetailKey  
        --AND STATUS = '5'  
    
        OPEN CUR_PICK  
    
        FETCH NEXT FROM CUR_PICK INTO @c_PickDetailKey  
    
        WHILE @@FETCH_STATUS <> -1  
        BEGIN  
            BEGIN TRY
                UPDATE dbo.PICKDETAIL WITH (ROWLOCK)  
                SET DROPID = @cDropID  
                WHERE PICKDETAILKEY = @c_PickDetailKey
            END TRY
            BEGIN CATCH
                SET @nErrNo = 269511
                SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --UPDPickDtlFail
                GOTO RollBackTran
            END CATCH
            FETCH NEXT FROM CUR_PICK INTO @c_PickDetailKey  
        END  
        CLOSE CUR_PICK  
        DEALLOCATE CUR_PICK  
    END  
    
    -- Get PackHeader  
    SELECT @cPickSlipNo = PickSlipNo  
    FROM dbo.PackHeader WITH (NOLOCK)  
    WHERE OrderKey = @cOrderKey  
    
    /***********************************************************************************************  
                                                PackHeader  
    ***********************************************************************************************/  
    IF NOT EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE Pickslipno = @cPickSlipNo)  
    BEGIN  
        -- Get PickSlipNo  
        IF @cPickSlipNo = ''  
        BEGIN  
            SELECT TOP 1 @cPickSlipNo = PickHeaderKey  
            FROM dbo.PICKHEADER WITH (NOLOCK)  
            WHERE OrderKey = @cOrderKey  
        END  
    
        IF @cPickSlipNo = ''  
        BEGIN  
            EXECUTE dbo.nspg_GetKey  
                'PICKSLIP',  
                9,  
                @cPickSlipNo   OUTPUT,  
                @bSuccess      OUTPUT,  
                @nErrNo        OUTPUT,  
                @cErrMsg       OUTPUT  
            IF @nErrNo <> 0  
                GOTO RollBackTran  
    
            SET @cPickSlipNo = 'P' + @cPickSlipNo  
        END  
    
        DECLARE @cLoadKey NVARCHAR( 10) = ''  
        SELECT @cLoadKey = LoadKey FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey  
    
        BEGIN TRY
            INSERT INTO dbo.PackHeader WITH (ROWLOCK) (PickSlipNo, StorerKey, OrderKey, ConsigneeKey, LoadKey)  
            VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, '', @cLoadKey) 
        END TRY
        BEGIN CATCH 
            SET @nErrNo = 269501  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPHdrFail  
            GOTO RollBackTran  
        END CATCH
    END  
    
    SET @cLabelLine = ''  
    SET @nCartonNo = 0  
    SET @cLabelNo = ''  
    IF ISNULL(@cInField04,'') = ''  
    BEGIN  
        SET @cNewLine = 'Y'  
        SET @nCartonNo = 0  
        SET @cLabelLine = '00001'  
        SET @cLabelNo = ''  
    END  
    ELSE  
    BEGIN  
        SELECT  
            @nCartonNo = CartonNo,  
            @cLabelLine = LabelLine,  
            @cLabelNo   = LabelNo  
        FROM dbo.PackDetail WITH (NOLOCK)  
        WHERE PickSlipNo = @cPickSlipNo  
            AND LabelNo = ISNULL(@cInField04,'')  
            AND SKU = @cSKU  
            AND DropID = @cDropID  
            AND ISNULL(@cInField04,'') <> ''  
    
        IF @cLabelLine = ''  
        BEGIN  
            SELECT @nCartonNo = CartonNo,  
                    @cLabelNo   = LabelNo  
            FROM dbo.PackDetail WITH (NOLOCK)  
            WHERE PickSlipNo = @cPickSlipNo  
            --AND DropID = @cDropID  
            AND LabelNo = ISNULL(@cInField04,'')  
            AND ISNULL(@cInField04,'') <> ''  
    
            IF @nCartonNo = 0  
                SET @cLabelLine = '00001'  
            ELSE  
                SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)  
                FROM dbo.PackDetail WITH (NOLOCK)  
                WHERE Pickslipno = @cPickSlipNo  
                AND LabelNo = ISNULL(@cInField04,'')  
                AND ISNULL(@cInField04,'') <> ''  
    
            SET @cNewLine = 'Y'  
        END  
    END  
    
    -- PackDetail  
    IF @cNewLine = 'Y'  
    BEGIN  
        -- Insert PackDetail  
        IF ISNULL(@nCartonNo,0) = 0  
        BEGIN  
            SET @cLabelNo = ''  
            IF @cGenPackLabelNoSP <> ''  
            BEGIN  
                IF @cGenPackLabelNoSP = '1'  
                BEGIN  
                EXEC dbo.isp_GenUCCLabelNo  
                    @cStorerKey,  
                    @cLabelNo      OUTPUT,  
                    @bSuccess      OUTPUT,  
                    @nErrNo        OUTPUT,  
                    @cErrMsg       OUTPUT  
                IF @nErrNo <> 0  
                BEGIN  
                    SET @nErrNo = 269502  
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail  
                    GOTO RollBackTran  
                END  
                END  
                ELSE IF @cGenPackLabelNoSP = 'DropIDWithZero'  
                BEGIN  
                SET @cLabelNo = '00'+@cDropID  
    
                IF EXISTS (SELECT TOP 1 1 FROM dbo.PACKDETAIL WITH (NOLOCK) WHERE  
                            STORERKEY = @cStorerkey AND LABELNO = @cLabelNo)  
                BEGIN  
                    SET @cLabelNo = ''  
                    EXEC dbo.isp_GenUCCLabelNo  
                        @cStorerKey,  
                        @cLabelNo      OUTPUT,  
                        @bSuccess      OUTPUT,  
                        @nErrNo        OUTPUT,  
                        @cErrMsg       OUTPUT  
                    IF @nErrNo <> 0  
                    BEGIN  
                        SET @nErrNo = 269503  
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail  
                        GOTO RollBackTran  
                    END  
                END  
                END  
                ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cGenPackLabelNoSP AND type = 'P')  
                BEGIN  
                SET @cSQL = 'EXEC dbo.' + RTRIM( @cGenPackLabelNoSP) +  
                    ' @cPickslipNo, ' +  
                    ' @nCartonNo,   ' +  
                    ' @cLabelNo     OUTPUT '  
                SET @cSQLParam =  
                    ' @cPickslipNo  NVARCHAR(10),       ' +  
                    ' @nCartonNo    INT,                ' +  
                    ' @cLabelNo     NVARCHAR(20) OUTPUT '  
                EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
                    @cPickslipNo,  
                @nCartonNo,  
                    @cLabelNo OUTPUT  
                END  
    
                IF ISNULL(@cLabelNo,'') = ''  
                BEGIN  
                SET @cLabelNo = @cDropID  
    
                IF EXISTS (SELECT TOP 1 1 FROM dbo.PACKDETAIL WITH (NOLOCK) WHERE  
                            STORERKEY = @cStorerkey AND LABELNO = @cLabelNo)  
                    GOTO Quit  
                END  
            END  
            ELSE  
                GOTO Quit  
        END  

        BEGIN TRY
            INSERT INTO dbo.PackDetail WITH (ROWLOCK)
            (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, DropID,  
                AddWho, AddDate, EditWho, EditDate, REFNO)  
            VALUES  
                (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nQTY, @cDropID,  
                'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE(), 'PIECEPICK')  
        END TRY
        BEGIN CATCH
            SET @nErrNo = 269504  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackDtlFail  
            GOTO RollBackTran  
        END CATCH
    
        SELECT TOP 1  
            @nCartonNo = CartonNo  
            ,@cLabelLine = LabelLine  
        FROM dbo.PackDetail WITH (NOLOCK)  
        WHERE PickSlipNo = @cPickSlipNo  
            AND SKU = @cSKU  
            AND LabelNo = @cLabelNo  
            AND AddWho = 'rdt.' + SUSER_SNAME()  
        ORDER BY CartonNo DESC -- max cartonno  
    END  
    ELSE  
    BEGIN  
        BEGIN TRY
            -- Update Packdetail  
            UPDATE dbo.PackDetail WITH (ROWLOCK) SET  
                SKU = @cSKU,  
                QTY = QTY + @nQTY,  
                EditWho = 'rdt.' + SUSER_SNAME(),  
                EditDate = GETDATE(),  
                ArchiveCop = NULL  
            WHERE PickSlipNo = @cPickSlipNo  
                AND CartonNo = @nCartonNo  
                AND LabelNo = @cLabelNo  
                AND LabelLine = @cLabelLine 
        END TRY
        BEGIN CATCH
            SET @nErrNo = 269505  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPackDtlFail  
            GOTO RollBackTran  
        END CATCH
    END  
    
    --PackDetailInfo  
    IF @cUpdatePackDetailInfo = '1'  
    BEGIN  
        SET @cPackData1 = @cLottable01  
        SET @cPackData2 = ''  
        SET @cPackData3 = ''  
    
        -- Pack data  
        IF @cPackData1 <> '' OR  
            @cPackData2 <> '' OR  
            @cPackData3 <> ''  
        BEGIN  
    
            -- Get PackDetailInfo  
            SET @nPackDetailInfoKey = 0  
            SELECT @nPackDetailInfoKey = PackDetailInfoKey  
            FROM dbo.PackDetailInfo WITH (NOLOCK)  
            WHERE PickSlipNo = @cPickSlipNo  
                AND CartonNo = @nCartonNo  
                AND LabelNo = @cLabelNo  
                AND SKU = @cSKU  
                AND UserDefine01 = @cPackData1  
                AND UserDefine02 = @cPackData2  
                AND UserDefine03 = @cPackData3  
    
            IF @nPackDetailInfoKey = 0  
            BEGIN  
                BEGIN TRY
                    -- Insert PackDetailInfo  
                    INSERT INTO dbo.PackDetailInfo WITH (ROWLOCK) (  
                    PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, UserDefine01, UserDefine02, UserDefine03,  
                    AddWho, AddDate, EditWho, EditDate)  
                    VALUES (  
                    @cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nQTY, @cPackData1, @cPackData2, @cPackData3,  
                    'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE())  
                END TRY
                BEGIN CATCH
                    SET @nErrNo = 269506  
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PDInfoFail  
                    GOTO RollBackTran  
                END CATCH
            END  
            ELSE  
            BEGIN  
                BEGIN TRY
                    -- Update PackDetailInfo  
                    UPDATE dbo.PackDetailInfo WITH(ROWLOCK)  
                    SET  
                    QTY = QTY + @nQTY,  
                    EditWho = 'rdt.' + SUSER_SNAME(),  
                    EditDate = GETDATE(),  
                    ArchiveCop = NULL  
                    WHERE PackDetailInfoKey = @nPackDetailInfoKey  
                END TRY
    
                BEGIN CATCH
                    SET @nErrNo = 269507  
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PDInfoFail  
                    GOTO RollBackTran  
                END CATCH
            END  
    END  
    END  
    
    -- PackInfo  
    SET @cCartonType = ''  
    SET @cPackMethod = 'PIECE'  
    
    SELECT @cCartonType   = C.CartonType  
            , @fLength  = CartonLength  
            , @fWidth        = CartonWidth  
            , @fHeight       = CartonHeight  
            , @fCube         = CartonLength * CartonWidth * CartonHeight  
            , @fCartonWeight = CartonWeight  
    FROM dbo.Cartonization C WITH (NOLOCK)  
    JOIN dbo.Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)  
    WHERE S.StorerKey = @cStorerKey  
    AND C.CartonType = CASE WHEN ISNULL(@cPackMethod,'') = 'PALLET' THEN @cPalletType ELSE 'CARTON' END  
    
    SET @fSKUWeight = 0  
    
    IF @cDefaultWeight IN ('2', '3')  
    BEGIN  
    -- Weight (SKU only)  
        SELECT @fSKUWeight = ISNULL( SKU.STDGrossWGT * @nQty, 0)  
        FROM dbo.SKU SKU WITH (NOLOCK)  
        WHERE SKU.STORERKEY = @cStorerKey  
        AND SKU.SKU = @cSKU  
    
        -- Weight (SKU + carton)  
        --IF @cDefaultWeight = '3'  
        --BEGIN  
        --   -- Get carton type info  
        --   SELECT @nCartonWeight = CartonWeight  
        --   FROM dbo.Cartonization C WITH (NOLOCK)  
        --      JOIN dbo.Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)  
        --   WHERE S.StorerKey = @cStorerKey  
        --      AND C.CartonType = @cCartonType  
        --  
        --   SET @nWeight = @nWeight + @nCartonWeight  
        --END  
    END  
    
    --SET @cWeight = rdt.rdtFormatFloat( @fSKUWeight)  
    SET @fWeight = 0  
    
    IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)  
    BEGIN  
    
        IF @cDefaultWeight = '3'
            BEGIN
                SET @fWeight = @fSKUWeight + @fCartonWeight
            END
            ELSE IF @cDefaultWeight = '2'
            BEGIN
                SET @fWeight = @fSKUWeight
            END
            SET @cWeight = rdt.rdtFormatFloat(@fWeight)
            SET @fWeight = ISNULL(TRY_CAST(@cWeight AS FLOAT), 0)
        
        BEGIN TRY
            INSERT INTO dbo.PackInfo WITH (ROWLOCK)(PickslipNo, CartonNo, Qty, Weight, Cube, CartonType, Length, Width, Height)  
            VALUES (@cPickSlipNo, @nCartonNo, @nQTY, @fWeight, @fCube, @cCartonType, @fLength, @fWidth, @fHeight)  
            --INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, QTY)  
            --VALUES (@cPickSlipNo, @nCartonNo, @nQTY)  
        END TRY
        BEGIN CATCH
            SET @nErrNo = 269508  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackInfFail  
            GOTO RollBackTran  
        END CATCH
    END  
    ELSE  
    BEGIN  
        SET @cWeight = rdt.rdtFormatFloat( @fSKUWeight)  
        SET @fSKUWeight = ISNULL(TRY_CAST(@cWeight AS FLOAT), 0)  
        SET @fWeight = @fSKUWeight
        
        BEGIN TRY
            UPDATE dbo.PackInfo WITH (ROWLOCK) SET  
                QTY = QTY + @nQTY,  
                EditDate = GETDATE(),  
                EditWho = SUSER_SNAME(),  
                Weight = Weight + @fWeight,  
                TrafficCop = NULL  
            WHERE PickSlipNo = @cPickSlipNo  
                AND CartonNo = @nCartonNo
        END TRY
        BEGIN CATCH
            SET @nErrNo = 269509  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPackInfFail  
            GOTO RollBackTran  
        END CATCH
    END  
    
    --SUBMIT PRINT JOB IF SANDWICH  
    --IF @cPackCaseType = 'SANDWICH' AND ISNULL(@cLabelPrinter,'') <> ''  
    IF ISNULL(@cLabelPrinter,'') <> ''  
    BEGIN  
        IF @cShipLabel <> ''  
        BEGIN  
            IF @cShipLabel = 'CstLabelSP'  
            BEGIN  
                SET @cCstLabelSP = rdt.RDTGetConfig( @nFunc, 'CstLabelSP', @cStorerKey)  
                IF @cCstLabelSP = '0'  
                SET @cCstLabelSP = ''  
                IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cCstLabelSP AND type = 'P')  --Customize Print Label  
                BEGIN  
                SET @cSQL = 'EXEC rdt.' + RTRIM( @cCstLabelSP) +  
                    ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, ' +  
                    ' @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption, ' +  
                    ' @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3, ' +  
                    ' @nErrNo OUTPUT, @cErrMsg OUTPUT '  
                SET @cSQLParam =  
                    '@nMobile         INT,           ' +  
                    '@nFunc           INT,           ' +  
                    '@cLangCode       NVARCHAR( 3),  ' +  
                    '@nStep           INT,           ' +  
                    '@nInputKey       INT,           ' +  
                    '@cFacility       NVARCHAR( 5),  ' +  
                    '@cStorerKey      NVARCHAR( 15), ' +  
                    '@cPickSlipNo     NVARCHAR( 10), ' +  
                    '@cFromDropID     NVARCHAR( 20), ' +  
                    '@nCartonNo       INT,           ' +  
                    '@cLabelNo        NVARCHAR( 20), ' +  
                    '@cSKU            NVARCHAR( 20), ' +  
                    '@nQTY            INT,           ' +  
                    '@cUCCNo          NVARCHAR( 20), ' +  
                    '@cCartonType     NVARCHAR( 10), ' +  
                    '@cCube           NVARCHAR( 10), ' +  
                    '@cWeight         NVARCHAR( 10), ' +  
                    '@cRefNo          NVARCHAR( 20), ' +  
                    '@cSerialNo       NVARCHAR( 30), ' +  
                    '@nSerialQTY      INT,       ' +  
                    '@cOption         NVARCHAR( 1),  ' +  
                    '@cPackDtlRefNo   NVARCHAR( 20), ' +  
                    '@cPackDtlRefNo2  NVARCHAR( 20), ' +  
                    '@cPackDtlUPC     NVARCHAR( 30), ' +  
                    '@cPackDtlDropID  NVARCHAR( 20), ' +  
                    '@cPackData1      NVARCHAR( 30), ' +  
                    '@cPackData2      NVARCHAR( 30), ' +  
                    '@cPackData3      NVARCHAR( 30), ' +  
                    '@nErrNo          INT            OUTPUT, ' +  
                    '@cErrMsg        NVARCHAR( 20)  OUTPUT'  
    
                EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
                    @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cDropID,  
                    @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, '', '', '', '1',  
                    '', '', '', @cDropID, @cPackData1, @cPackData2, @cPackData3,  
                    @nErrNo OUTPUT, @cErrMsg OUTPUT  
    
                --IF @nErrNo <> 0  
                --   GOTO Quit  
                END  
            END  
            ELSE BEGIN  --Standard Print  
                -- Common params  
                DELETE FROM @tShipLabel  
    
                IF ISNULL(@cPrintCopy,'') <> '' AND TRY_CAST(@cPrintCopy AS INT) IS NOT NULL 
                    SET @nNoOfCopy = CAST(@cPrintCopy AS INT)  
                ELSE  
                    SET @nNoOfCopy = 1  
    
                INSERT INTO @tShipLabel (Variable, Value) VALUES  
                ( '@cStorerKey',     @cStorerKey),  
                ( '@cPickSlipNo',    @cPickSlipNo),  
                ( '@cFromDropID',    @cDropID),  
                ( '@cPackDtlDropID', @cDropID),  
                ( '@cLabelNo',       @cLabelNo),  
                ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))  
    
                -- Print label  
                EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,  
                @cShipLabel, -- Report type  
                @tShipLabel, -- Report params  
                'rdt_1812ExtScnAU_PackCtn',  
                @nErrNo  OUTPUT,  
                @cErrMsg OUTPUT,  
                @nNoOfCopy  
                --IF @nErrNo <> 0  
                --   GOTO Quit  
            END  
        END  
    
        -- Carton manifest  
        IF @cCartonManifest <> ''  
        BEGIN  
            -- Common params  
            DELETE FROM @tCartonManifest  
    
            INSERT INTO @tCartonManifest (Variable, Value) VALUES  
                ( '@cStorerKey',     @cStorerKey),  
                ( '@cPickSlipNo',    @cPickSlipNo),  
                ( '@cFromDropID',    @cDropID),  
            ( '@cPackDtlDropID', @cDropID),  
                ( '@cLabelNo',       @cLabelNo),  
                ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))  
    
            -- Print label  
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,  
                @cCartonManifest, -- Report type  
                @tCartonManifest, -- Report params  
                'rdt_1812ExtScnAU_PackCtn',  
                @nErrNo  OUTPUT,  
                @cErrMsg OUTPUT  
            --IF @nErrNo <> 0  
            --   GOTO Quit  
        END  
    END  
    
    COMMIT TRAN rdt_1812ExtScnAU_PackCtn_Confirm -- Only commit change made here  
    GOTO Quit  
    
    RollBackTran:
    -- Cleanup CUR_PICK cursor if open
    IF CURSOR_STATUS('local', 'CUR_PICK') = 1
    BEGIN
        CLOSE CUR_PICK
        DEALLOCATE CUR_PICK
    END
    ELSE IF CURSOR_STATUS('local', 'CUR_PICK') = -1
        DEALLOCATE CUR_PICK

    IF XACT_STATE() <> 0 AND @@TRANCOUNT > @nTranCount
         ROLLBACK TRAN rdt_1812ExtScnAU_PackCtn_Confirm -- Rollback only change made here
 
    Fail:  
    Quit:  
        WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
            COMMIT TRAN  
END    
GO
  
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_1812ExtScnAU_PackCtn_Confirm TO NSQL 
GO  