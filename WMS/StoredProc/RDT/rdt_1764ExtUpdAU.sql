SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/  
/* Store procedure: rdt_1764ExtUpdAU                                          */  
/* Purpose: TM Replen From, Extended Update for AU SWISSE                     */  
/*                                                                            */  
/* Modifications log:                                                         */  
/*                                                                            */  
/* Date         Author    Ver.  Purposes                                      */  
/* 2025-06-13   SYC067    1.0   Created                                       */  
/* 2025-09-12   SYC067    1.1   Enhance Query (SY02)                          */  
/******************************************************************************/  
  
CREATE OR ALTER PROCEDURE [RDT].[rdt_1764ExtUpdAU]  
    @nMobile         INT  
   ,@nFunc           INT  
   ,@cLangCode       NVARCHAR( 3)  
   ,@nStep           INT  
   ,@cTaskdetailKey  NVARCHAR( 10)  
   ,@nErrNo          INT           OUTPUT  
   ,@cErrMsg         NVARCHAR( 20) OUTPUT  
   ,@nAfterStep      INT = 0  
   ,@cDropID         NVARCHAR( 20) = ''  
AS  
BEGIN  
    SET NOCOUNT ON  
    SET QUOTED_IDENTIFIER OFF  
    SET ANSI_NULLS OFF  
    SET CONCAT_NULL_YIELDS_NULL OFF  
    
    DECLARE @nTranCount  INT  

    DECLARE @cStorerkey            NVARCHAR(15)  
            ,@cTaskType            NVARCHAR(10)  
            ,@cSourceType          NVARCHAR(30)  
            ,@cSku                 NVARCHAR(20)  
            ,@cLot                 NVARCHAR(10)  
            ,@cFromLoc             NVARCHAR(10)  
            ,@cFromID              NVARCHAR(18)  
            ,@cID                  NVARCHAR(18)  
            ,@cToID                NVARCHAR(18)  
            ,@cStatus              NVARCHAR(10)  
            ,@nQty                 INT  
            ,@cUOM                 NVARCHAR(10)  
            ,@nUOMQty              INT  
            ,@cOrderkey            NVARCHAR(10)  
            ,@cGroupkey            NVARCHAR(10)  
            ,@cToloc               NVARCHAR(10)  
            ,@cPriority            NVARCHAR(10)  
            ,@cPickMethod          NVARCHAR(10)  
            ,@cMessage03           NVARCHAR(20)  
            ,@cMessage02           NVARCHAR(20)  
            ,@cExternOrderKey      NVARCHAR(20)  
            ,@CZip                 NVARCHAR(18)  
            ,@cLinkTaskToPick_SQL  NVARCHAR(4000)  
            ,@cRoute               NVARCHAR(10)  
            ,@cTaskdetailkeyNew    NVARCHAR(10)  
            ,@cDefaultLoc          NVARCHAR(10)  
            ,@cLoadkey             NVARCHAR(10)  
            ,@dtdeliveryDate       DATETIME  
            ,@nLastPartial_Ctn     INT  
            ,@nCaseCNT             INT  
            ,@cSTBMAXSKU           NVARCHAR(10)  
            ,@cSTCMAXSKU           NVARCHAR(10)  
            ,@cSKUBUSR2            NVARCHAR(10)  
            ,@nPackMaxSKU          INT  
            ,@cwavekey             NVARCHAR(10)  
            ,@cUserKeyOverride     NVARCHAR(18)  
    
    DECLARE  @bSuccess      int = 0  
            ,@nErr          int = 0  
            ,@cInsertErrMsg NVARCHAR(250) = ''  
    
    
    SET @nTranCount = @@TRANCOUNT  
    
    -- TM Replen From  
    IF @nFunc = 1764  
    BEGIN  
        IF @nStep = 6 -- ToLOC  
        BEGIN  
            -- Get task info  
            SELECT  
                @cSKU = SKU,  
                @cPickMethod = PickMethod,  
                @cStorerKey = StorerKey,  
                @cFromID = FromID,  
                @cToID = ToID,  
                @cToLOC = ToLOC,  
                @cStatus = Status  
            FROM dbo.TaskDetail WITH (NOLOCK)  
            WHERE TaskdetailKey = @cTaskdetailKey  
    
            -- Completed task  
            IF @cStatus = '9'  
            BEGIN  
                SELECT @cDefaultLoc = CL.Long  
                FROM dbo.CODELKUP CL WITH (NOLOCK)  
                JOIN dbo.LOC LOC WITH (NOLOCK) ON CL.Long = LOC.Loc  
                WHERE CL.Listname = 'TM_TOLOC'  
                AND CL.Storerkey = @cStorerKey  
                AND CL.Code = 'DEFAULT'  
    
                SET @cSourceType = 'ispRLWVAU1'  
    
                BEGIN TRAN  
                SAVE TRAN rdt_1764ExtUpdAU  
    
                DECLARE cur_pick CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
                SELECT PD.Storerkey, PD.Sku, PD.Lot, PD.Loc, PD.ID, SUM(PD.Qty) AS Qty,  
                    PD.UOM, SUM(PD.UOMQty) AS UOMQty,  
                    O.Route,  
                    O.Orderkey,  
                    O.ExternOrderkey,  
                    ISNULL(O.Loadkey,''),  
                    W.WAVEKEY,  
                    TOLOC.Loc AS ToLoc,  
                    ISNULL(CL.Code,'9') AS Priority,  
                    ISNULL(STB.SUSR3,'') AS STBMAXSKU,  
                    ISNULL(STC.SUSR3,'') AS STCMAXSKU,  
                    ISNULL(TTMTYPE.SHORT,''),  
                    ISNULL(TTMTYPE.LONG,''),  
                    O.DeliveryDate  
                FROM dbo.WAVEDETAIL WD WITH (NOLOCK)  
                JOIN dbo.WAVE W WITH (NOLOCK) ON WD.Wavekey = W.Wavekey  
                JOIN dbo.ORDERS O WITH (NOLOCK) ON WD.Orderkey = O.Orderkey  
                JOIN dbo.PICKDETAIL PD WITH (NOLOCK) ON O.Orderkey = PD.Orderkey  
                JOIN dbo.LOC LOC WITH (NOLOCK) ON PD.Loc = LOC.Loc  
                LEFT JOIN dbo.TASKDETAIL TD WITH (NOLOCK) ON PD.Taskdetailkey = TD.Taskdetailkey AND TD.Sourcetype = @cSourceType AND TD.Tasktype IN ('FPK','FCP','FPP') AND TD.Status <> 'X'  
                AND PD.STORERKEY = TD.STORERKEY --SY02  
                LEFT JOIN dbo.STORERSODEFAULT SSO WITH (NOLOCK) ON SSO.Storerkey = O.Consigneekey  
                LEFT JOIN dbo.STORERSODEFAULT SSOB WITH (NOLOCK) ON SSOB.Storerkey = O.Billtokey   --SY02  
                LEFT JOIN dbo.LOADPLAN LP WITH (NOLOCK) ON LP.LOADKEY = O.LOADKEY  
                LEFT JOIN dbo.STORER STC WITH (NOLOCK) ON STC.STORERKEY = O.CONSIGNEEKEY AND STC.CONSIGNEEFOR = O.STORERKEY  
                LEFT JOIN dbo.STORER STB WITH (NOLOCK) ON STB.STORERKEY = O.BILLTOKEY AND STB.CONSIGNEEFOR = O.STORERKEY  
                LEFT JOIN dbo.TASKDETAIL TDRPL WITH (NOLOCK) ON PD.Taskdetailkey = TDRPL.Taskdetailkey AND PD.STORERKEY = TDRPL.STORERKEY --SY01  
                    AND TDRPL.Tasktype IN ('RPF','RPT','RP1') AND TDRPL.STATUS NOT IN ('9','X')  
                LEFT JOIN dbo.REPLENISHMENT RP WITH (NOLOCK) ON PD.MoveRefKey = RP.MoveRefKey AND PD.STORERKEY = RP.STORERKEY --SY01  
                    AND PD.Storerkey = RP.Storerkey AND RP.CONFIRMED <> 'Y'  
                LEFT JOIN dbo.CODELKUP TTMTYPE WITH (NOLOCK) ON TTMTYPE.LISTNAME = 'PKUOM2TTM' AND TTMTYPE.STORERKEY = O.STORERKEY AND TTMTYPE.CODE = PD.UOM  
                LEFT JOIN dbo.CODELKUP CL WITH (NOLOCK) ON O.Storerkey = CL.Storerkey AND CL.Listname = 'TMPRIORITY' AND O.PRIORITY = CL.Short  
                OUTER APPLY (SELECT TOP 1 TL.Loc FROM dbo.LOC TL WITH (NOLOCK) WHERE TL.Putawayzone <> '' AND (TL.Putawayzone = SSO.Route OR TL.Putawayzone = SSOB.Route OR TL.Putawayzone = LP.Route)  
                            ORDER BY CASE WHEN ISNULL(LP.Route,'') <> '' THEN 1 WHEN ISNULL(SSO.Route,'') <> '' THEN 2 ELSE 3 END) AS TOLOC  
                WHERE PD.Status = '0'  
                AND W.TMRELEASEFLAG = 'Y'  
                AND TD.Taskdetailkey IS NULL  
                AND PD.Taskdetailkey = @cTaskdetailKey  
                AND PD.PickDetailKey = CASE WHEN PD.UOM <> '1' AND LOC.LOCATIONTYPE = 'BULK' THEN 'SKIP' ELSE PD.PickDetailKey END  
                AND ISNULL(TDRPL.TASKDETAILKEY,'') = ''  
                AND ISNULL(RP.REPLENISHMENTKEY,'') = ''  
                GROUP BY PD.Storerkey, PD.Sku, PD.Lot, PD.Loc, PD.ID, PD.UOM, O.Route, LOC.LogicalLocation, O.Orderkey,  
                    O.ExternOrderkey, O.Consigneekey, TOLOC.Loc, ISNULL(CL.Code,'9'),  
                        O.DeliveryDate,  O.Loadkey  
                        ,ISNULL(STB.SUSR3,'')  
                        ,ISNULL(STC.SUSR3,'')  
                        ,ISNULL(TTMTYPE.SHORT,'')  
                        ,ISNULL(TTMTYPE.LONG,'')  
                        ,W.WAVEKEY  
                ORDER BY O.Route, PD.UOM, Loc.LogicalLocation, PD.Loc, PD.Sku, O.Orderkey  
    
                OPEN cur_pick  
    
                FETCH NEXT FROM cur_pick INTO @cStorerkey, @cSku, @cLot, @cFromLoc, @cID, @nQty, @cUOM, @nUOMQty, @cRoute, @cOrderkey, @cExternOrderKey, @cLoadkey, @cWavekey  
                                            , @cToLoc, @cPriority, @cSTBMAXSKU, @cSTCMAXSKU, @cTaskType, @cPickMethod, @dtDeliveryDate  
                WHILE @@FETCH_STATUS = 0  
                BEGIN  
    
                BEGIN TRY
                    UPDATE dbo.PICKDETAIL WITH (ROWLOCK)  
                    SET TASKDETAILKEY = ''  
                    WHERE TASKDETAILKEY = @cTaskdetailKey  
                    AND ORDERKEY = @cOrderkey  
                    AND STORERKEY = @cStorerkey  
                    AND LOC = @cFromloc  
                    AND LOT = @cLot  
                    AND ID = @cID  
                    AND SKU = @cSku  
                    AND UOM = @cUOM  
                END TRY
                BEGIN CATCH
                    SET @nErrNo = 267555    -- UpdPickDtlFail
                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                    GOTO RollBackTran
                END CATCH  
    
                SET @cLinkTaskToPick_SQL = ''  
                    --SET @n_UOMQty = 0  
                SET @cGroupkey = ''  
                SET @cTaskdetailkeyNew = ''  
    
                SET @nPackMaxSKU = ISNULL(TRY_CAST(@cSTCMAXSKU AS INT), 0)

                IF @nPackMaxSKU = 0
                    SET @nPackMaxSKU = ISNULL(TRY_CAST(@cSTBMAXSKU AS INT), 0) 
    
                IF ISNULL(@cDefaultLoc,'') <> '' AND ISNULL(@cToLoc,'') = ''  
                    SET @cToLoc = @cDefaultLoc  
    
                IF @cUOM = '1'  
                BEGIN  
                    IF ISNULL(@cTaskType,'') = ''  
                        SET @cTaskType = 'FPK'  
                    IF ISNULL(@cPickMethod,'') = ''  
                        SET @cPickMethod = 'FP'  
                    SET @cGroupKey = @cOrderkey  
                    SET @cLinkTaskToPick_SQL = 'PICKDETAIL.UOM = @cUOM AND ORDERS.Orderkey = @cOrderkey'  
                    SET @cTaskdetailkeyNew = ''  
    
                    EXEC dbo.isp_InsertTaskDetail  
                        @cTaskdetailkey         = @cTaskdetailkeyNew OUTPUT  
                        ,@cTaskType              = @cTaskType  
                        ,@cStorerkey             = @cStorerkey  
                        ,@cSku                   = @cSku  
                        ,@cLot                   = @cLot  
                        ,@cUOM                   = @cUOM  
                        ,@nUOMQty                = @nUOMQty  
                        ,@nQty                   = @nQty  
                        ,@cFromLoc               = @cFromLoc  
                        ,@cLogicalFromLoc        = @cFromLoc  
                        ,@cFromID                = @cFromID  
                        ,@cToLoc                 = @cToLoc  
                        ,@cLogicalToLoc          = @cToLoc  
                        ,@cToID                  = @cToID  
                        ,@cPickMethod            = @cPickMethod  
                        ,@cPriority              = @cPriority  
                        ,@cSourcePriority        = '9'  
                        ,@cSourceType            = @cSourceType  
                        ,@cSourceKey             = @cWavekey  
                        ,@cOrderKey              = @cOrderkey  
                        ,@cGroupkey              = @cGroupkey  
                        ,@cWaveKey               = @cWavekey  
                        ,@cLoadkey               = @cLoadkey  
                        ,@cAreaKey               = '?F'  -- ?F=Get from location areakey  
                        ,@cMessage03             = ''  
                        ,@cMessage02             = @cExternOrderKey  
                        ,@cLinkTaskToPick        = 'Y' -- WIP=Update taskdetailkey to pickdetail_wip  
                        ,@cLinkTaskToPick_SQL    = @cLinkTaskToPick_SQL  
                        ,@cWIP_RefNo             = @cSourceType  
                        ,@bSuccess               = @bSuccess OUTPUT  
                        ,@nErr                   = @nErr OUTPUT  
                        ,@cErrMsg                = @cInsertErrMsg OUTPUT  
    
                    IF @bSuccess <> 1  
                    BEGIN  
                        SET @nErrNo = 267551  
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDTaskDtlFail  
                        GOTO RollBackTran  
                    END  
                    ELSE  
                    BEGIN  
                        SET @cUserKeyOverride = ''  
                        SELECT TOP 1 @cUserKeyOverride = UserKeyOverride  
                        FROM dbo.TASKDETAIL WITH (NOLOCK)  
                        WHERE GROUPKEY = @cGroupkey  
                        AND ORDERKEY = @cOrderkey  
                        AND STORERKEY = @cStorerkey  
                        AND TASKTYPE = @cTaskType  
                        AND UOM = @cUOM  
                        AND TASKDETAILKEY <> @cTaskdetailkeyNew 
                        AND [STATUS] IN ('3','5')  
    
                        IF ISNULL(@cUserKeyOverride,'') <> ''  
                        BEGIN
                            BEGIN TRY
                                UPDATE dbo.TASKDETAIL WITH (ROWLOCK)  
                                --SET Groupkey = @cTaskdetailkeyNew  
                                SET UserKeyOverride = @cUserKeyOverride  
                                WHERE TaskDetailKey = @cTaskdetailkeyNew 
                            END TRY
                            BEGIN CATCH
                                SET @nErrNo = 267556  -- UpdTaskDtlFail
                                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                                GOTO RollBackTran
                            END CATCH 
                        END
                    END  
                END  
                ELSE IF @cUOM = '2'  
                BEGIN  
                    IF ISNULL(@cTaskType,'') = ''  
                        SET @cTaskType = 'FCP'  
                    IF ISNULL(@cPickMethod,'') = ''  
                        SET @cPickMethod = 'PP'  
    
                    --IF @dt_deliverydate IS NOT NULL  
                    --  SET @c_Groupkey = RTRIM(@c_Route) + SUBSTRING(CONVERT(NVARCHAR(8), @dt_deliverydate, 112),5,4)   --NJOW01  
                    --ELSE  
                    --  SET @c_GroupKey = @c_Route  
    
                    SET @cGroupKey = @cOrderkey  
    
                    IF @nPackMaxSKU > 0  
                    BEGIN  
                        SET @cSKUBUSR2 = ''  
    
                        SELECT @cSKUBUSR2 = ISNULL(BUSR2,'')  
                        FROM dbo.SKU WITH (NOLOCK)  
                        WHERE STORERKEY = @cStorerkey  
                        AND SKU = @cSku  
    
                        IF ISNULL(@cSKUBUSR2,'') <> ''  
                            SET @cGroupKey = LEFT( LEFT(@cSKUBUSR2,LEN(@cSKUBUSR2)) + RIGHT(@cOrderkey,10-IIF(LEN(@cSKUBUSR2)>=10,10,LEN(@cSKUBUSR2))), 10)  
                        ELSE  
                            SET @cGroupKey = LEFT( (@cSku + @cOrderkey) , 10)  
                    END  
    
                    SET @cLinkTaskToPick_SQL = 'PICKDETAIL.UOM = @cUOM AND ORDERS.Orderkey = @cOrderkey'  
    
                    SELECT @nCaseCNT = PACK.CASECNT  
                    FROM dbo.SKU WITH (NOLOCK)  
                    JOIN dbo.PACK WITH (NOLOCK) ON SKU.PACKKEY = PACK.PACKKEY  
                    WHERE SKU.STORERKEY = @cStorerkey  
                    AND SKU.SKU = @cSku  
    
                    SET @nLastPartial_Ctn = 0  
    
                    IF @nCaseCNT > 0  
                        SET @nLastPartial_Ctn = @nQty % @nCaseCNT  
    
                    IF @nLastPartial_Ctn > 0  
                        SET @nQty = @nQty - @nLastPartial_Ctn  
    
                    SET @cTaskdetailkeyNew = ''  
    
                    EXEC dbo.isp_InsertTaskDetail  
                        @cTaskdetailkey         = @cTaskdetailkeyNew OUTPUT  
                        ,@cTaskType              = @cTaskType  
                        ,@cStorerkey             = @cStorerkey  
                        ,@cSku                   = @cSku  
                        ,@cLot                   = @cLot  
                        ,@cUOM                   = @cUOM  
                        ,@nUOMQty                = @nUOMQty  
                        ,@nQty                   = @nQty  
                        ,@cFromLoc               = @cFromloc  
                        ,@cLogicalFromLoc        = @cFromLoc  
                        ,@cFromID                = @cID  
                        ,@cToLoc                 = @cToLoc  
                        ,@cLogicalToLoc          = @cToLoc  
                        ,@cToID                  = @cID  
                        ,@cPickMethod            = @cPickMethod  
                        ,@cPriority              = @cPriority  
                        ,@cSourcePriority        = '9'  
                        ,@cSourceType            = @cSourceType  
                        ,@cSourceKey             = @cWavekey  
                        ,@cOrderKey              = @cOrderkey  
                        ,@cGroupkey              = @cGroupkey  
                        ,@cWaveKey               = @cWavekey  
                        ,@cLoadkey               = @cLoadkey  
                        ,@cAreaKey               = '?F'  -- ?F=Get from location areakey  
                        ,@cMessage03             = ''  
                        ,@cMessage02             = @cExternOrderKey  
                        ,@cLinkTaskToPick        = 'Y' -- WIP=Update taskdetailkey to pickdetail_wip  
                        ,@cLinkTaskToPick_SQL    = @cLinkTaskToPick_SQL  
                        ,@cSplitTaskByCase       ='N'   -- N=No slip Y=Split TASK by carton. Only apply if @n_casecnt > 0. include last partial carton.  
                        ,@cWIP_RefNo             = @cSourceType  
                        ,@bSuccess               = @bSuccess OUTPUT  
                        ,@nErr                   = @nErr OUTPUT  
                        ,@cErrMsg                = @cInsertErrMsg OUTPUT  
    
                    IF @bSuccess <> 1  
                    BEGIN  
                        SET @nErrNo = 267552  
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDTaskDtlFail  
                        GOTO RollBackTran  
                    END  
                    ELSE  
                    BEGIN  
                        SET @cUserKeyOverride = ''  
                        SELECT TOP 1 @cUserKeyOverride = UserKeyOverride  
                        FROM dbo.TASKDETAIL WITH (NOLOCK)  
                        WHERE GROUPKEY = @cGroupkey  
                        AND ORDERKEY = @cOrderkey  
                        AND STORERKEY = @cStorerkey  
                        AND TASKTYPE = @cTaskType  
                        AND UOM = @cUOM  
                        AND TASKDETAILKEY <> @cTaskdetailkeyNew  
                        AND [STATUS] IN ('3','5')  
    
                        IF ISNULL(@cUserKeyOverride,'') <> ''  
                        BEGIN
                            BEGIN TRY
                                UPDATE dbo.TASKDETAIL WITH (ROWLOCK)  
                                --SET Groupkey = @cTaskdetailkeyNew  
                                SET UserKeyOverride = @cUserKeyOverride  
                                WHERE TaskDetailKey = @cTaskdetailkeyNew  
                            END TRY
                            BEGIN CATCH
                                SET @nErrNo = 267557  -- UpdTaskDtlFail
                                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                                GOTO RollBackTran
                            END CATCH
    
                        IF @nLastPartial_Ctn > 0  
                        BEGIN  
                            --If found last partial carton, split to different task.  
                            --SET @c_TaskType = 'FPP'  
                            SELECT TOP 1 @cTaskType = SHORT, @cPickMethod = LONG  
                            FROM dbo.CODELKUP WITH (NOLOCK)  
                            WHERE LISTNAME = 'PKUOM2TTM'  
                            AND CODE = '6'  
    
                            IF ISNULL(@cTaskType,'') = ''  
                                SET @cTaskType = 'FCP'  
    
                            IF ISNULL(@cPickMethod,'') = ''  
                                SET @cPickMethod = 'PP'  
    
                            --SET @c_GroupKey = @c_Wavekey  
                            SET @cGroupKey = @cOrderkey  
    
                            IF @nPackMaxSKU > 0  
                            BEGIN  
                                SET @cSKUBUSR2 = ''  

                                SELECT @cSKUBUSR2 = ISNULL(BUSR2,'')  
                                FROM dbo.SKU WITH (NOLOCK)  
                                WHERE STORERKEY = @cStorerkey  
                                  AND SKU = @cSku  

                                IF ISNULL(@cSKUBUSR2,'') <> ''  
                                    SET @cGroupKey = LEFT(@cSKUBUSR2,10)  
                                ELSE  
                                    SET @cGroupKey = LEFT(@cSku,10)  
                            END  
    
                            SET @cTaskdetailkeyNew = ''  
    
                            EXEC dbo.isp_InsertTaskDetail  
                                @cTaskdetailkey         = @cTaskdetailkeyNew OUTPUT  
                               ,@cTaskType              = @cTaskType  
                               ,@cStorerkey             = @cStorerkey  
                               ,@cSku                   = @cSku  
                               ,@cLot                   = ''  
                               ,@cUOM                   = @cUOM  
                               ,@nUOMQty                = @nLastPartial_Ctn  
                               ,@nQty                   = @nLastPartial_Ctn  
                               ,@cFromLoc               = @cFromloc  
                               ,@cLogicalFromLoc        = @cFromLoc  
                               ,@cFromID                = @cID  
                               ,@cToLoc                 = @cToLoc  
                               ,@cLogicalToLoc          = @cToLoc  
                               ,@cToID                  = @cID  
                               ,@cPickMethod            = @cPickMethod  
                               ,@cPriority              = @cPriority  
                               ,@cSourcePriority        = '9'  
                               ,@cSourceType            = @cSourceType  
                               ,@cSourceKey             = @cWavekey  
                               ,@cOrderKey              = @cOrderkey  
                               ,@cGroupkey              = @cGroupkey  
                               ,@cWaveKey               = @cWavekey  
                               ,@cLoadkey               = @cLoadkey  
                               ,@cAreaKey               = '?F'  -- ?F=Get from location areakey  
                               ,@cMessage01             = 'Last Partial Carton'  
                               ,@cMessage02             = @cExternOrderKey  
                               ,@cLinkTaskToPick        = 'Y' -- WIP=Update taskdetailkey to pickdetail_wip  
                               ,@cLinkTaskToPick_SQL    = @cLinkTaskToPick_SQL  
                               ,@cSplitTaskByCase       = 'N'   -- N=No slip Y=Split TASK by carton. Only apply if @n_casecnt > 0. include last partial carton.  
                               ,@cWIP_RefNo             = @cSourceType  
                               ,@bSuccess               = @bSuccess OUTPUT  
                               ,@nErr                   = @nErr OUTPUT  
                               ,@cErrMsg                = @cInsertErrMsg OUTPUT  
    
                            IF @bSuccess <> 1  
                            BEGIN  
                                SET @nErrNo = 267553  
                                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDTaskDtlFail  
                                GOTO RollBackTran  
                            END  
                            ELSE  
                            BEGIN  
                                SET @cUserKeyOverride = ''  
                                SELECT TOP 1 @cUserKeyOverride = UserKeyOverride  
                                FROM dbo.TASKDETAIL WITH (NOLOCK)  
                                WHERE GROUPKEY = @cGroupkey  
                                  AND ORDERKEY = @cOrderkey  
                                  AND STORERKEY = @cStorerkey  
                                  AND TASKTYPE = @cTaskType  
                                  AND UOM = @cUOM  
                                  AND TASKDETAILKEY <> @cTaskdetailkeyNew  
                                  AND [STATUS] IN ('3','5')  

                                IF ISNULL(@cUserKeyOverride,'') <> ''  
                                BEGIN
                                    BEGIN TRY
                                        UPDATE dbo.TASKDETAIL WITH (ROWLOCK)  
                                        --SET Groupkey = @cTaskdetailkeyNew  
                                        SET UserKeyOverride = @cUserKeyOverride  
                                        WHERE TaskDetailKey = @cTaskdetailkeyNew
                                    END TRY
                                    BEGIN CATCH
                                        SET @nErrNo = 267557  -- UpdTaskDtlFail
                                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                                        GOTO RollBackTran
                                    END CATCH
                                END  
                            END  
                        END  
                    END  
                END  
                ELSE  
                BEGIN  --UOM 6/7  
                    --SET @c_TaskType = 'FPP'  
                    IF ISNULL(@cTaskType,'') = ''  
                        SET @cTaskType = 'FCP'  
    
                    IF ISNULL(@cPickMethod,'') = ''  
                        SET @cPickMethod = 'PP'  
    
                    --SET @c_GroupKey = @c_Wavekey  
                    SET @cGroupKey = @cOrderkey  
                    SET @cLinkTaskToPick_SQL = 'PICKDETAIL.UOM = @cUOM AND ORDERS.Orderkey = @cOrderkey'  
    
                    IF @nPackMaxSKU > 0  
                    BEGIN  
                        SET @cSKUBUSR2 = ''  
    
                        SELECT @cSKUBUSR2 = ISNULL(BUSR2,'')  
                        FROM dbo.SKU WITH (NOLOCK)  
                        WHERE STORERKEY = @cStorerkey  
                        AND SKU = @cSku  
    
                        IF ISNULL(@cSKUBUSR2,'') <> ''  
                            SET @cGroupKey = LEFT(@cSKUBUSR2,10)  
                        ELSE  
                            SET @cGroupKey = LEFT(@cSku,10)  
                    END  
    
                    SET @cTaskdetailkeyNew = ''  
    
                    EXEC dbo.isp_InsertTaskDetail  
                        @cTaskdetailkey         = @cTaskdetailkeyNew OUTPUT  
                        ,@cTaskType              = @cTaskType  
                        ,@cStorerkey             = @cStorerkey  
                        ,@cSku                   = @cSku  
                        ,@cLot                   = @cLot  
                        ,@cUOM                   = @cUOM  
                        ,@nUOMQty                = @nUOMQty  
                        ,@nQty                   = @nQty  
                        ,@cFromLoc               = @cFromloc  
                        ,@cLogicalFromLoc        = @cFromLoc  
                        ,@cFromID                = @cID  
                        ,@cToLoc                 = @cToLoc  
                        ,@cLogicalToLoc          = @cToLoc  
                        ,@cToID                  = @cID  
                        ,@cPickMethod            = @cPickMethod  
                        ,@cPriority              = @cPriority  
                        ,@cSourcePriority        = '9'  
                        ,@cSourceType            = @cSourceType  
                        ,@cSourceKey             = @cWavekey  
                        ,@cOrderKey              = @cOrderkey  
                        ,@cGroupkey              = @cGroupkey  
                        ,@cWaveKey               = @cWavekey  
                        ,@cLoadkey               = @cLoadkey  
                        ,@cAreaKey               = '?F'  -- ?F=Get from location areakey  
                        ,@cMessage03             = ''  
                        ,@cMessage02             = @cExternOrderKey  
                        ,@cLinkTaskToPick        = 'Y' -- WIP=Update taskdetailkey to pickdetail_wip  
                        ,@cLinkTaskToPick_SQL    = @cLinkTaskToPick_SQL  
                        ,@cWIP_RefNo             = @cSourceType  
                        ,@bSuccess               = @bSuccess OUTPUT  
                        ,@nErr                   = @nErr OUTPUT  
                        ,@cErrMsg                = @cInsertErrMsg OUTPUT  
    
                    IF @bSuccess <> 1  
                    BEGIN  
                        SET @nErrNo = 267554  
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDTaskDtlFail  
                        GOTO RollBackTran  
                    END  
                    ELSE  
                    BEGIN  
                        SET @cUserKeyOverride = ''  
                        SELECT TOP 1 @cUserKeyOverride = UserKeyOverride  
                        FROM dbo.TASKDETAIL WITH (NOLOCK)  
                        WHERE GROUPKEY = @cGroupkey  
                        AND ORDERKEY = @cOrderkey  
                        AND STORERKEY = @cStorerkey  
                        AND TASKTYPE = @cTaskType  
                        AND UOM = @cUOM  
                        AND TASKDETAILKEY <> @cTaskdetailkeyNew  
                        AND [STATUS] IN ('3','5')  
    
                        IF ISNULL(@cUserKeyOverride,'') <> '' 
                        BEGIN
                            BEGIN TRY 
                                UPDATE dbo.TASKDETAIL WITH (ROWLOCK)  
                                --SET Groupkey = @cTaskdetailkeyNew  
                                SET UserKeyOverride = @cUserKeyOverride  
                                WHERE TaskDetailKey = @cTaskdetailkeyNew 
                            END TRY
                            BEGIN CATCH
                                SET @nErrNo = 267558  -- UpdTaskDtlFail
                                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                                GOTO RollBackTran
                            END CATCH
                        END
                    END  
                END  
    
                FETCH NEXT FROM cur_pick INTO @cStorerkey, @cSku, @cLot, @cFromLoc, @cID, @nQty, @cUOM, @nUOMQty, @cRoute, @cOrderkey, @cExternOrderKey, @cLoadkey, @cWavekey  
                                            , @cToLoc, @cPriority, @cSTBMAXSKU, @cSTCMAXSKU, @cTaskType, @cPickMethod, @dtDeliveryDate  
                END  
                CLOSE cur_pick  
                DEALLOCATE cur_pick  
    
                COMMIT TRAN rdt_1764ExtUpdAU -- Only commit change made here  
            END  
        END  
    END  
  
    GOTO Quit  
    RollBackTran: 
        IF CURSOR_STATUS('local','cur_pick') = 1
        BEGIN
            CLOSE cur_pick
            DEALLOCATE cur_pick
        END
        ELSE IF CURSOR_STATUS('local','cur_pick') = -1
        BEGIN
            DEALLOCATE cur_pick
        END

        IF (XACT_STATE()) = -1
        BEGIN
            IF @nTranCount = 0
                ROLLBACK TRANSACTION
        END
        IF (XACT_STATE()) = 1
        BEGIN
            IF @nTranCount > 0
                ROLLBACK TRANSACTION rdt_1764ExtUpdAU
            ELSE
                ROLLBACK TRANSACTION
        END
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
GRANT EXECUTE ON [RDT].[rdt_1764ExtUpdAU] TO NSQL
GO
