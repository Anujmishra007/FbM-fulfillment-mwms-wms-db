SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/  
/* Store procedure: rdt_1812ExtScnAU_Confirm                                  */  
/* Copyright      : MAERSK                                                    */  
/*                                                                            */  
/* Purpose: Create pallet/mbol/packinfo record after key in toloc             */  
/*                                                                            */  
/* Date       Rev  Author   Purposes                                          */  
/* 2024-09-23 1.0  James    WMS-26122 Created                                 */  
/* 2024-11-11 1.1  PXL009   FCR-1125 Merged 1.0 from v0 branch                */  
/*                            the original name is rdt_1812ExtScn01_Confirm   */  
/* 2025-05-26 1.2  SYC067   Replicate from rdt_1812ExtScn05_Confirm without   */  
/*                          Close Pallet                                      */  
/******************************************************************************/  
  
CREATE OR ALTER PROC [rdt].[rdt_1812ExtScnAU_Confirm] (  
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
    DECLARE @nPackQty    INT  
    DECLARE @cOrderKey   NVARCHAR( 10)  
    DECLARE @cSKU        NVARCHAR( 20)  
    DECLARE @cUserName   NVARCHAR( 18)  
    DECLARE @cPickSlipNo NVARCHAR( 10)  
    DECLARE @cLabelNo    NVARCHAR( 20)  
    DECLARE @cPalletLineNumber NVARCHAR( 5)  
    DECLARE @curPltD     CURSOR  
    DECLARE @curMbolD    CURSOR  
    DECLARE @cPLTUDF05   NVARCHAR( 30)  
    
    
    DECLARE @cClosePalletFlag   NVARCHAR(10) = '' 

    SET @nErrNo = 0
    SET @cErrMsg = '' 
    
    SET @cClosePalletFlag = rdt.RDTGetConfig( @nFunc, 'ClosePalletFlag', @cStorerKey)  
    IF @cClosePalletFlag = '0'  
        SET @cClosePalletFlag = ''  
    
    -- Handling transaction  
    SET @nTranCount = @@TRANCOUNT  
    BEGIN TRAN  -- Begin our own transaction  
    SAVE TRAN rdt_1812ExtScnAU_Confirm -- For rollback or commit only our own transaction  
    
    SELECT @cUserName = UserName  
    FROM rdt.RDTMOBREC WITH (NOLOCK)  
    WHERE Mobile = @nMobile  
    
    IF ISNULL(@cDropID,'') = ''  
        GOTO QUIT  
    
    -- Pallet  
    IF NOT EXISTS( SELECT 1 FROM dbo.Pallet WITH (NOLOCK) WHERE PalletKey = @cDropID)  
    BEGIN  
    
        DECLARE @nPalletLength FLOAT = 116.0  
        DECLARE @nPalletWidth  FLOAT = 116.0  
        DECLARE @nPalletHeight FLOAT = 116.0  
        DECLARE @nPalletWeight FLOAT = 45.0  
        DECLARE @cPalletType   NVARCHAR(10) = ''  
    
        SELECT TOP 1 @cPalletType = Code  
        FROM dbo.Codelkup WITH (NOLOCK)  
        WHERE ListName = 'PACKCTNTYP'  
        AND StorerKey = @cStorerKey  
        AND CHARINDEX(UDF01, @cDropID) > 0  
    
        IF ISNULL(@cPalletType,'') = ''  
        BEGIN  
    
            DECLARE @cConsigneeKey NVARCHAR( 15) = ''  
            DECLARE @cBillToKey    NVARCHAR( 20) = ''  
            DECLARE @cOrderType    NVARCHAR( 20) = ''  
    
            DECLARE @cCustomerType1     NVARCHAR( 20) = '' --PALLET / CASE  
            DECLARE @cCustomerType2     NVARCHAR( 20) = '' --SANDWICH / RAINBOW  
            DECLARE @cCustomerType3     NVARCHAR( 20) = '' --MAX SKU PER PALLET  
            DECLARE @cCustomerType4     NVARCHAR( 20) = '' --PALLET TYPE: CHEP / LOSCAM / PLAIN  
            DECLARE @cPlanningType     NVARCHAR( 20) = '' --WAVE / LOAD  
            DECLARE @cPWaveKey         NVARCHAR( 20) = ''  
            DECLARE @cPLoadkey         NVARCHAR( 20) = ''  
    
            DECLARE @cPackMethod       NVARCHAR( 20) = '' --PALLET / CASE / PIECE      
    
            SELECT  @cOrderKey = Orderkey  
                , @cStorerKey = Storerkey  
            FROM dbo.TaskDetail WITH (NOLOCK)  
            WHERE TaskDetailKey = @cTaskdetailKey  
    
            IF @cOrderKey <> ''  
                SELECT @cConsigneeKey = ConsigneeKey, @cBillToKey = BillToKey, @cOrderType = [Type]  
                    , @cPWaveKey = UserDefine09, @cPLoadkey = LoadKey  
                FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey  
    
            --Get Pack config  
    
            --Else Check Pack Type by Customer  
            --1. Check if configured by order type (UDF01 = PALLET / CASE, UDF02 = SANDWICH / RAINBOW, UDF03 = MAX SKU PER PALLET)  
            --2. If no point 1 then Check if configured by storer (storerkey = consigneekey 1st, not exist then billtokey)  
            --          (SUSR1 = PALLET / CASE, SUSR2 = SANDWICH / RAINBOW, SUSR3 = MAX SKU PER PALLET)  
            --3. If no point 1/2 then Check if configured by wave/load release (get from:  
            --            DispatchPalletPickMethod = 'PALLET' / 'CASE'  
            --            DispatchCasePickMethod   = 'SWPALLET' (SANDWICH PALLET)  
            --                                      /'SWCASE'   (SANDWICH CASE)  
            --                                      /'RBPALLET' (RAINBOW PALLET)  
            --                                      /'RBCASE'   (RAINBOW CASE)  
            --                                      /'PALLET'   (PALLET)  
            --                                      /'CASE'     (CASE)  
            --            DispatchPiecePickMethod  = 'PIECE')  
    
            --1. check if configured by order type  
            IF ISNULL(@cPackMethod,'') = ''  
            BEGIN  
                SET @cCustomerType1 = ''  
                SET @cCustomerType2 = ''  
                SET @cCustomerType3 = ''  
                SET @cCustomerType4 = ''  
                SET @cPackMethod = ''  
    
                SELECT TOP 1 @cCustomerType1 = UDF01  
                        , @cCustomerType2 = UDF02  
                        , @cCustomerType3 = UDF03  
                , @cCustomerType4 = UDF04  
                FROM dbo.CodeLKUP WITH (NOLOCK)  
                WHERE LISTNAME = 'ORDERTYPE'  
                AND STORERKEY = @cStorerKey  
                AND CODE = @cOrderType  
                AND ISNULL(UDF01,'') IN ('PALLET', 'CASE')  
    
                IF ISNULL(@cCustomerType1,'') <> ''  
                SET @cPackMethod = @cCustomerType1  
            END  
    
            --2. Check if storer configured  
            IF ISNULL(@cPackMethod,'') = ''  
            BEGIN  
                SET @cCustomerType1 = ''  
                SET @cCustomerType2 = ''  
                SET @cCustomerType3 = ''  
                SET @cCustomerType4 = ''  
                SET @cPackMethod = ''  
    
                IF ISNULL(@cConsigneeKey,'') <> ''  
                BEGIN  
                SELECT TOP 1 @cCustomerType1 = SUSR1  
                            , @cCustomerType2 = SUSR2  
                            , @cCustomerType3 = SUSR3  
                            , @cCustomerType4 = PALLET  
                FROM dbo.STORER WITH (NOLOCK)  
                WHERE CONSIGNEEFOR = @cStorerKey  
                AND STORERKEY = @cConsigneeKey  
                AND ISNULL(SUSR1,'') IN ('PALLET', 'CASE')  
                END  
    
                IF ISNULL(@cCustomerType1,'') = '' AND ISNULL(@cBillToKey,'') <> ''  
                BEGIN  
                SELECT TOP 1 @cCustomerType1 = SUSR1  
                            , @cCustomerType2 = SUSR2  
                            , @cCustomerType3 = SUSR3  
                            , @cCustomerType4 = PALLET  
                FROM dbo.STORER WITH (NOLOCK)  
                WHERE CONSIGNEEFOR = @cStorerKey  
                AND STORERKEY = @cBillToKey  
                AND ISNULL(SUSR1,'') IN ('PALLET', 'CASE')  
                END  
    
                IF ISNULL(@cCustomerType1,'') <> ''  
                SET @cPackMethod = @cCustomerType1  
            END  
    
    
            IF ISNULL(@cCustomerType4,'') LIKE '%CHEP%'  
                SET @cPalletType = 'CHEP'  
            ELSE IF ISNULL(@cCustomerType4,'') LIKE '%LOSC%'  
                SET @cPalletType = 'LOSCAM'  
            ELSE  
                SET @cPalletType = 'PALLET'  
    
        END  
    
        SELECT TOP 1 @nPalletLength = UDF01  
                    , @nPalletWidth  = UDF02  
                    --, @nPalletHeight = UDF03  
                    , @nPalletWeight = UDF04  
        FROM dbo.Codelkup WITH (NOLOCK)  
        WHERE StorerKey = @cStorerKey  
        AND ListName = 'ADIPLTDM'  
        AND CHARINDEX(Code, @cDropID) > 0  
    
        IF ISNULL(@cPalletType,'') = ''  
            SET @cPalletType = 'PALLET'  
    
        --Calculate Pallet Weight from PackInfo  
        --Calculate Pallet Height from Pallet Config (if possible)  
        DECLARE @nSumPackInfoWgt FLOAT = 0.0  
    
        SELECT @nSumPackInfoWgt = ISNULL(SUM(ISNULL(PIF.WEIGHT,0)),0)  
            , @nPalletHeight   = 12 + ISNULL(MAX(ISNULL(PACKD.ESTHEIGHT,0)),0)  
        FROM dbo.PackInfo PIF WITH (NOLOCK)  
        CROSS APPLY (  
            SELECT PICKSLIPNO,CARTONNO,  
            SUM(CEILING(PD.QTY / IIF(PACK.CASECNT>0,PACK.CASECNT,1)/ IIF(PACK.PALLETTI>0,PACK.PALLETTI,1))  
                --*PACK.PALLETHI  
                *PACK.HEIGHTUOM1) AS ESTHEIGHT  
            FROM dbo.PACKDETAIL PD WITH (NOLOCK)  
            JOIN dbo.SKU WITH (NOLOCK) ON PD.SKU = SKU.SKU AND PD.STORERKEY = SKU.StorerKey  
            JOIN dbo.PACK WITH (NOLOCK) ON SKU.PACKKEY = PACK.PACKKEY  
            WHERE PD.STORERKEY = @cStorerKey  
                AND   PD.DropID = @cDropID  
            AND   ISNULL(@cDropID,'') <> ''  
            GROUP BY PICKSLIPNO,CARTONNO  
        ) as PACKD  
        WHERE PIF.PICKSLIPNO = PACKD.PICKSLIPNO AND PIF.CARTONNO = PACKD.CARTONNO  
    
        SET @nPalletWeight = ISNULL(@nPalletWeight,45) + ISNULL(@nSumPackInfoWgt,0)  
        SET @nPalletHeight = CASE WHEN ISNULL(@nPalletHeight,116) > 140 THEN 140  
                                    WHEN ISNULL(@nPalletHeight,116) <= 13 THEN 120  
                                    ELSE ISNULL(@nPalletHeight,116) END  
    
        INSERT INTO dbo.Pallet WITH (ROWLOCK) (PalletKey, StorerKey, Status, PalletType, Length, Width, Height, GrossWgt)  
        VALUES (@cDropID, @cStorerKey, '0', @cPalletType, @nPalletLength, @nPalletWidth, @nPalletHeight, @nPalletWeight)  
        IF @@ERROR <> 0  
        BEGIN  
            SET @nErrNo = 269451  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPLTHdrFail  
            GOTO RollBackTran  
        END  
    END  
    
    SET @curPltD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
    SELECT PickSlipNo, LabelNo, CartonNo, ISNULL( SUM( Qty), 0)  
    FROM dbo.PACKDETAIL WITH (NOLOCK)  
    WHERE StorerKey = @cStorerKey  
    AND   DropID = @cDropID  
    GROUP BY PickSlipNo, LabelNo, CartonNo  
    OPEN @curPltD  
    FETCH NEXT FROM @curPltD INTO @cPickSlipNo, @cLabelNo, @nCartonNo, @nPackQty  
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
        SELECT TOP 1 @cSKU = SKU  
        FROM dbo.PACKDETAIL WITH (NOLOCK)  
        WHERE PickSlipNo = @cPickSlipNo  
        AND   LabelNo = @cLabelNo  
        ORDER BY 1  
    
        SELECT @cOrderKey = OrderKey  
        FROM dbo.PACKHEADER WITH (NOLOCK)  
        WHERE PickSlipNo = @cPickSlipNo  
    
        -- PalletDetail  
        IF NOT EXISTS( SELECT 1 FROM dbo.PalletDetail WITH (NOLOCK) WHERE PalletKey = @cDropID AND CaseId = @cLabelNo)  
        BEGIN  
            SELECT @cPalletLineNumber = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( PalletLineNumber), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)  
            FROM dbo.PalletDetail WITH (NOLOCK)  
            WHERE PalletKey = @cDropID  
    
            INSERT INTO dbo.PalletDetail WITH (ROWLOCK) (PalletKey, PalletLineNumber, CaseID, StorerKey, SKU, LOC, Qty, Status, UserDefine01, UserDefine02, UserDefine03, ArchiveCop)  
            VALUES (@cDropID, @cPalletLineNumber, @cLabelNo, @cStorerKey, @cSKU, ISNULL( @cToLOC, ''), @nPackQty, '0', @cOrderKey, @cLabelNo, @cToLane, NULL)  
            IF @@ERROR <> 0  
            BEGIN  
                SET @nErrNo = 269452  
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPLTDtlFail  
                GOTO RollBackTran  
            END  
        END  
    
        FETCH NEXT FROM @curPltD INTO @cPickSlipNo, @cLabelNo, @nCartonNo, @nPackQty  
    END  
    
    -- Close pallet  
    DECLARE @fPalletHeight FLOAT = 0.0  
    
    IF ISNULL(@cClosePalletFlag,'') = '1'  
    BEGIN  
        SET @fPalletHeight = ISNULL( CAST( @cOutField03 AS FLOAT), 0)  
    
        IF @fPalletHeight > 0 AND  
            EXISTS( SELECT 1 FROM dbo.Pallet WITH (NOLOCK) WHERE PalletKey = @cDropID AND Status = '0')  
        BEGIN  
    
            SET @cPLTUDF05 = ''  
    
            SELECT TOP 1 @cPLTUDF05 = P.PALLETKEY  
            FROM dbo.PALLET P WITH (NOLOCK)  
            JOIN dbo.PALLETDETAIL PLD WITH (NOLOCK) ON P.PALLETKEY = PLD.Palletkey  
            WHERE PLD.USERDEFINE01 = @cOrderKey  
            AND P.STATUS = '9'  
            AND ISNULL(USERDEFINE05,'') = ''  
    
            IF ISNULL(@cPLTUDF05,'') = ''  
                SELECT TOP 1 @cPLTUDF05 = PLD.USERDEFINE05  
                FROM dbo.PALLET P WITH (NOLOCK)  
                JOIN dbo.PALLETDETAIL PLD WITH (NOLOCK) ON P.PALLETKEY = PLD.Palletkey  
                WHERE PLD.USERDEFINE01 = @cOrderKey  
                AND P.STATUS = '9'  
                AND ISNULL(USERDEFINE05,'') <> ''  
    
            UPDATE dbo.PALLETDETAIL WITH (ROWLOCK) SET  
                UserDefine05 = @cPLTUDF05,  
                TrafficCop = NULL,  
                EditDate = GETDATE(),  
                EditWho = SUSER_SNAME()  
            WHERE PalletKey = @cDropID  
    
            IF @@ERROR <> 0  
            BEGIN  
                SET @nErrNo = 269453  
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PLTDL Err  
                GOTO RollBackTran  
            END  
    
            UPDATE dbo.Pallet WITH (ROWLOCK) SET  
                Status = '9',  
                Height = @fPalletHeight,  
                EditDate = GETDATE(),  
                EditWho = @cUserName  
            WHERE PalletKey = @cDropID  
        IF @@ERROR <> 0  
            BEGIN  
                SET @nErrNo = 269454  
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPLTHdrFail  
                GOTO RollBackTran  
            END  
        END  
    END  
    
    -- Get MBOL info  
    DECLARE @cMBOLKey NVARCHAR( 10) = ''  
    SELECT @cMBOLKey = MBOLKey  
    FROM dbo.MBOL WITH (NOLOCK)  
    WHERE Facility = @cFacility  
    AND   Status < '9'  
    AND   ExternMBOLKey = @cToLane  
    
    -- MBOL  
    IF @cMBOLKey = ''  
    BEGIN  
        DECLARE @nSuccess INT = 1  
        EXECUTE dbo.nspg_getkey  
            'MBOL'  
            , 10  
            , @cMBOLKey    OUTPUT  
            , @nSuccess    OUTPUT  
            , @nErrNo      OUTPUT  
            , @cErrMsg     OUTPUT  

            IF @nSuccess = 0
            BEGIN
                GOTO RollBackTran
            END
    
        INSERT INTO dbo.MBOL WITH (ROWLOCK) (  
            MBOLKey, ExternMBOLKey, Facility, Status, AddWho, AddDate, EditWho, EditDate)  
        VALUES  
            (@cMBOLKey, @cToLane, @cFacility, '0', 'rdt.' + @cUserName, GETDATE(), 'rdt.' + @cUserName, GETDATE())  
        IF @@ERROR <> 0  
        BEGIN  
            SET @nErrNo = 269455  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS MBOL Fail  
            GOTO RollBackTran  
        END  
    END  
    
    SET @curMbolD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
    SELECT DISTINCT OrderKey  
    FROM dbo.PickDetail WITH (NOLOCK)  
    WHERE Storerkey = @cStorerKey  
    AND DropID = @cDropID  
    AND ISNULL(@cDropID,'') <> ''  
    AND [STATUS] < '9'  
    --SELECT DISTINCT PH.OrderKey  
    --FROM dbo.PackDetail PD WITH (NOLOCK)  
    --JOIN dbo.PackHeader PH WITH (NOLOCK) ON ( PD.PickSlipNo = PH.PickSlipNo)  
    --WHERE PD.StorerKey = @cStorerKey  
    --AND   PD.DropID = @cDropID  
    ORDER BY 1  
    OPEN @curMbolD  
    FETCH NEXT FROM @curMbolD INTO @cOrderKey  
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
        -- MBOLDetail  
        IF NOT EXISTS( SELECT 1 FROM dbo.MBOLDetail WITH (NOLOCK) WHERE MBOLKey = @cMBOLKey AND OrderKey = @cOrderKey)  
        BEGIN  
            INSERT INTO dbo.MBOLDetail WITH (ROWLOCK)  
                (MBOLKey, MBOLLineNumber, OrderKey, LoadKey, AddWho, AddDate, EditWho, EditDate)  
            VALUES  
                (@cMBOLKey, '00000', @cOrderKey, '', 'rdt.' + @cUserName, GETDATE(), 'rdt.' + @cUserName, GETDATE())  
            IF @@ERROR <> 0  
            BEGIN  
                SET @nErrNo = 269456  
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS MBDtl Fail  
                GOTO RollBackTran  
            END  
        END  
    
        FETCH NEXT FROM @curMbolD INTO @cOrderKey  
    END  

    CLOSE @curPltD
    DEALLOCATE @curPltD
    CLOSE @curMbolD
    DEALLOCATE @curMbolD
    
    COMMIT TRAN rdt_1812ExtScnAU_Confirm -- Only commit change made here  
    GOTO Quit  
    
    RollBackTran:
    -- Cleanup cursors if open
    IF CURSOR_STATUS('variable', '@curPltD') = 1
    BEGIN
        CLOSE @curPltD
        DEALLOCATE @curPltD
    END
    ELSE IF CURSOR_STATUS('variable', '@curPltD') = -1
        DEALLOCATE @curPltD

    IF CURSOR_STATUS('variable', '@curMbolD') = 1
    BEGIN
        CLOSE @curMbolD
        DEALLOCATE @curMbolD
    END
    ELSE IF CURSOR_STATUS('variable', '@curMbolD') = -1
        DEALLOCATE @curMbolD

    ROLLBACK TRAN rdt_1812ExtScnAU_Confirm -- Only rollback change made here

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

GRANT EXECUTE ON rdt.rdt_1812ExtScnAU_Confirm TO NSQL 
GO  
