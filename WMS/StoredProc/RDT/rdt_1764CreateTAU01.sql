SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/  
/* Store procedure: rdt_1764CreateTAU01                                       */  
/* Copyright      : Maersk                                                    */  
/*                                                                            */  
/* Date        Rev  Author    Purposes                                        */  
/* 2025-05-09  1.0  SYC067    Create task if less than casecnt                */  
/*                            allocated for an order in ToLoc                 */  
/******************************************************************************/  
  
CREATE PROC [RDT].[rdt_1764CreateTAU01] (  
   @nMobile        INT,  
   @nFunc          INT,  
   @cLangCode      NVARCHAR( 3),  
   @cUserName      NVARCHAR( 15),  
   @cListKey       NVARCHAR( 10),  
   @nErrNo         INT           OUTPUT,  
   @cErrMsg        NVARCHAR( 20) OUTPUT  
) AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @nTranCount  INT  
   DECLARE @nSuccess    INT  
   DECLARE @cTaskDetailKey    NVARCHAR( 10)  
   DECLARE @cNewTaskDetailKey NVARCHAR( 10)  
   DECLARE @cStatus     NVARCHAR( 10)  
   DECLARE @cWaveKey    NVARCHAR( 10)  
   DECLARE @cLoadKey    NVARCHAR( 10)  
   DECLARE @cStorerKey  NVARCHAR( 15)  
   DECLARE @cSKU        NVARCHAR( 20)  
   DECLARE @cLOT        NVARCHAR( 10)  
   DECLARE @nQTY        INT  
   DECLARE @cFromLOC    NVARCHAR( 10)  
   DECLARE @cToLOC      NVARCHAR( 10)  
   DECLARE @cToID       NVARCHAR( 18)  
   DECLARE @cCaseID     NVARCHAR( 20)  
   DECLARE @cFinalLOC   NVARCHAR( 10)  
   DECLARE @cFinalID    NVARCHAR( 18)  
   DECLARE @cTransitLOC NVARCHAR( 10)  
   DECLARE @nTransitCount   INT  
   DECLARE @cPriority       NVARCHAR( 10)  
   DECLARE @cSourcePriority NVARCHAR( 10)  
   DECLARE @cSourceType     NVARCHAR( 30)  
   DECLARE @cOrgTaskKey     NVARCHAR( 30)  
   DECLARE @nUOMQty         INT  
   DECLARE @cPickMethod     NVARCHAR( 10)  
   DECLARE @cFacility       NVARCHAR( 10)  
   DECLARE @n_LessThanCaseQty INT  
   DECLARE @n_LessThanInnerQty INT  
   DECLARE @nToQTY        INT  
   DECLARE @n_CaseCnt     INT  
   DECLARE @n_InnerPack    INT  
   DECLARE @cFinalLOCCat    NVARCHAR( 10)  
   DECLARE @cFinalLOCType   NVARCHAR( 10)  
   DECLARE @c_PickDetailKey   NVARCHAR(10)= ''  
   DECLARE @n_PDQty           INT  
   DECLARE @n_SystemQty       INT  
   DECLARE @c_CurrPickdetailKey NVARCHAR(10)= ''  
   DECLARE @n_CurrPDQty       INT  
   DECLARE @n_SplitQty        INT  
   DECLARE @c_NewPickdetailKey NVARCHAR(10) = ''  
   DECLARE @nLLITTLQty        INT  
  
   DECLARE @tTask TABLE  
   (  
      TaskDetailKey NVARCHAR(10),  
      StorerKey     NVARCHAR(15),  
      SKU           NVARCHAR(20),  
      QTY           INT,  
      ToLOC         NVARCHAR(10),  
      ToID          NVARCHAR(18),  
      FinalLOC      NVARCHAR(10),  
      FinalID       NVARCHAR(18),  
      TransitLOC    NVARCHAR(10),  
      LOT           NVARCHAR(10),  
      FromLoc       NVARCHAR(10)  
   )  
  
   DECLARE @cSkipInnerTask NVARCHAR(10) = ''  
  
   -- Init var  
   SET @nErrNo = 0  
   SET @cErrMsg = ''  
  
   -- Get ToLOC from latest transit task  
   SELECT TOP 1  
      @cWaveKey        = WaveKey,  
      @cLoadKey        = LoadKey,  
      @cStorerKey      = StorerKey,  
      @cStatus         = Status,  
      @cToLOC          = ToLOC,  
      @cToID           = ToID,  
      @nQTY            = QTY,  
      @nTransitCount   = TransitCount,  
      @cPriority       = Priority,  
      @cSourcePriority = SourcePriority,  
      @cSourceType     = 'rdt_1764CreateTAU01',  
      @cFinalLOC       = FinalLOC,  
      @cSKU            = SKU,  
      @nQty            = QTY,  
      @cTaskDetailKey  = TaskDetailKey,  
      @cStorerkey      = Storerkey,  
      @cFinalID        = FinalID,  
      @cLOT            = LOT,  
      @cFromLOC        = FromLoc,  
      @n_SystemQty     = SystemQty  
   FROM dbo.TaskDetail WITH (NOLOCK)  
   WHERE ListKey = @cListKey  
   ORDER BY  
      TransitCount DESC, -- Get initial task  
      CASE WHEN Status = '9' THEN 1 ELSE 2 END -- RefTask that fetch to perform together, still Status=3  
  
   -- Task not completed/SKIP/CANCEL  
   IF @cStatus <> '9'  
      RETURN  
  
   IF ISNULL(@cFinalLOC,'') <> ''  --Transit Required  
   BEGIN  
      EXEC [RDT].[rdt_1764CreateTask03]  
           @nMobile  
         , @nFunc  
         , @cLangCode  
         , @cUserName  
         , @cListKey  
         , @nErrNo            OUTPUT  
         , @cErrMsg           OUTPUT  
  
      GOTO Quit  
   END  
  
   SET @cSkipInnerTask = rdt.RDTGetConfig( @nFunc, 'SkipInnerTask', @cStorerKey)  
   IF @cSkipInnerTask = '0'  
      SET @cSkipInnerTask = ''  
  
   -- Get initial task info  
   INSERT INTO @tTask (TaskDetailKey, StorerKey, SKU, QTY, ToLOC, ToID, FinalLOC, FinalID, LOT, FromLoc)  
   SELECT @cTaskDetailKey, @cStorerkey, @cSKU, @nQty, @cToLOC, @cToID, @cFinalLOC, @cFinalID, @cLOT, @cFromLOC  
   --SELECT TaskDetailKey, StorerKey, SKU, QTY, @cToLOC, @cToID, FinalLOC, FinalID, LOT --NOTE: ToLOC, ToID are from lastest task  
   --FROM dbo.TaskDetail WITH (NOLOCK)  
   --WHERE ListKey = @cListKey  
   --AND TransitCount = 0  
  
   -- Not generate next task if:  
   -- 1) QtyAllocated is not less than casecnt  
   -- 2) ToLOC is not in Case Location (only replen from case to piece)  
   IF NOT EXISTS ( SELECT 1 FROM @tTask Task  
                   JOIN dbo.SKU WITH (NOLOCK) ON SKU.SKU = Task.SKU AND SKU.STORERKEY = Task.StorerKey  
                   JOIN dbo.PACK WITH (NOLOCK) ON SKU.PACKKEY = PACK.PACKKEY  
                   OUTER APPLY (  
                   SELECT SKU, SUM(QTY) as Qty  
                   FROM dbo.PICKDETAIL WITH (NOLOCK) WHERE LOC = Task.ToLoc  
                   AND SKU = Task.SKU AND STATUS = '0'  
                   GROUP BY ORDERKEY, SKU) AS PD  
                   WHERE PACK.CASECNT > 0  
                   AND PD.QTY % CAST(PACK.CASECNT AS INT) > 0 )--means need to breakdown single case to fulfill single order  
   RETURN  
  
   IF EXISTS( SELECT 1 FROM @tTask Task JOIN dbo.LOC WITH (NOLOCK) ON (Task.ToLOC = LOC.LOC)  
              WHERE LOC.LocationType NOT IN ('CASE','PICK'))  
      RETURN  
  
   IF EXISTS( SELECT 1 FROM @tTask Task JOIN dbo.LOC WITH (NOLOCK) ON (Task.ToLOC = LOC.LOC)  
              WHERE LOC.LocationType = 'PICK' AND LOC.LocationCategory <> 'CLS')  
      RETURN  
  
  
   -- Get LOC info  
   DECLARE @cToLOCPAZone NVARCHAR(10)  
   DECLARE @cToLOCAreaKey NVARCHAR(10)  
   DECLARE @cToLocAisle    NVARCHAR(10)  
   DECLARE @cToLocType    NVARCHAR(10)  
   DECLARE @cToLocCat    NVARCHAR(10)  
   SET @cToLOCPAZone = ''  
   SET @cToLOCAreaKey = ''  
   SET @cToLocAisle = ''  
   SET @cToLocType = ''  
   SET @cToLocCat  = ''  
   SELECT @cToLOCPAZone = PutawayZone  
        , @cToLocAisle = LocAisle  
        , @cToLocType = LocationType  
        , @cToLocCat  = LocationCategory  
        , @cFacility = Facility FROM LOC WITH (NOLOCK) WHERE LOC = @cToLOC  
   SELECT @cToLOCAreaKey = AreaKey FROM AreaDetail WITH (NOLOCK) WHERE PutawayZone = @cToLOCPAZone  
  
   --Get ToLoc as PICK Location based on:  
   --1. SKU+Lot exists in PICK Location  
   --2. else then empty PICK location with no tasks  
  
  
   -- Generate task  
   SET @cFinalLOC = ''  
  
   --GET SKU+LOT EXISTS RECORDS  
   SELECT TOP 1 @cFinalLOC = LOC.LOC  
   FROM @tTask task  
   JOIN LOTATTRIBUTE TASKLA WITH (NOLOCK) ON TASKLA.LOT = TASK.LOT AND TASKLA.STORERKEY = TASK.STORERKEY  
   JOIN LOTXLOCXID LLI WITH (NOLOCK) ON Task.Storerkey = LLI.Storerkey AND TASK.SKU = LLI.SKU  
   JOIN LOC WITH (NOLOCK) ON LLI.LOC = LOC.LOC AND LOC.LOC <> task.ToLoc AND LOC.LOC <> TASK.FROMLOC  
   JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON LLI.LOT = LA.LOT AND LLI.STORERKEY = LA.STORERKEY  
   WHERE LLI.STORERKEY = @cStorerKey  
   AND LOC.LOCATIONTYPE = 'PICK'  
   AND LOC.LOCATIONCATEGORY = CASE WHEN @cToLocType = 'PICK' AND ISNULL(@cSkipInnerTask,'') <> '1' THEN 'PICK'  
                                   WHEN @cToLocType = 'CASE' THEN 'CLS'  
                                   ELSE LOC.LOCATIONCATEGORY END  
   AND LOC.STATUS = 'OK'  
   AND LOC.LOCATIONFLAG = 'NONE'  
   AND LOC.FACILITY = @cFacility  
   AND LLI.QTY - LLI.QTYPICKED + LLI.PENDINGMOVEIN > 0  
   ORDER BY CASE WHEN LOC.LOCAISLE = @cToLocAisle THEN 1 ELSE 2 END  
   , LOC.PUTAWAYZONE  
  
   --CHECK PENDING TASKS THAT HAS THE SAME SKU+LOT  
   IF ISNULL(@cFinalLOC,'') = ''  
   BEGIN  
      SELECT TOP 1 @cFinalLOC = LOC.LOC  
      FROM @tTask task  
      JOIN LOTATTRIBUTE TASKLA WITH (NOLOCK) ON TASKLA.LOT = TASK.LOT AND TASKLA.STORERKEY = TASK.STORERKEY  
      JOIN TASKDETAIL TD WITH (NOLOCK) ON Task.Storerkey = TD.Storerkey AND TASK.SKU = TD.SKU  
                                          AND TD.TASKDETAILKEY <> TASK.TASKDETAILKEY  
      JOIN LOC WITH (NOLOCK) ON TD.TOLOC = LOC.LOC AND LOC.LOC <> task.ToLoc AND LOC.LOC <> TASK.FROMLOC  
      JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON TD.LOT = LA.LOT AND TD.STORERKEY = LA.STORERKEY  
      WHERE TD.STORERKEY = @cStorerKey  
      AND LOC.LOCATIONTYPE = 'PICK'  
      AND LOC.LOCATIONCATEGORY = CASE WHEN @cToLocType = 'PICK' AND ISNULL(@cSkipInnerTask,'') <> '1' THEN 'PICK'  
                                      WHEN @cToLocType = 'CASE' THEN 'CLS'  
                                      ELSE LOC.LOCATIONCATEGORY END  
      AND LOC.STATUS = 'OK'  
      AND LOC.LOCATIONFLAG = 'NONE'  
      AND LOC.FACILITY = @cFacility  
      AND TD.QTY > 0  
      AND TD.STATUS NOT IN ('9','X','R')  
   END  
  
   --IF FINALLOC STILL NOT FOUND, GRAB AN EMPTY LOCATION  
   IF ISNULL(@cFinalLOC,'') = ''  
   BEGIN  
      SELECT TOP 1 @cFinalLOC = LOC.LOC  
      FROM @tTask task  
      LEFT JOIN SKUXLOC SL WITH (NOLOCK) ON TASK.SKU = SL.SKU AND TASK.STORERKEY = SL.STORERKEY  
                                         AND SL.LOCATIONTYPE = 'PICK'  
      JOIN LOTATTRIBUTE TASKLA WITH (NOLOCK) ON TASKLA.LOT = TASK.LOT AND TASKLA.STORERKEY = TASK.STORERKEY  
      JOIN LOC WITH (NOLOCK) ON LOC.LOC <> task.ToLoc AND LOC.LOC <> TASK.FROMLOC  
      WHERE TASK.STORERKEY = @cStorerKey  
      AND LOC.LOCATIONTYPE = 'PICK'  
      AND LOC.LOCATIONCATEGORY = CASE WHEN @cToLocType = 'PICK' AND ISNULL(@cSkipInnerTask,'') <> '1' THEN 'PICK'  
                                      WHEN @cToLocType = 'CASE' THEN 'CLS'  
                                      ELSE LOC.LOCATIONCATEGORY END  
      AND LOC.STATUS = 'OK'  
      AND LOC.LOCATIONFLAG = 'NONE'  
      AND LOC.FACILITY = @cFacility  
      AND LOC.LOC = CASE WHEN ISNULL(SL.LOC,'') <> '' THEN SL.LOC ELSE LOC.LOC END  
      AND NOT EXISTS (SELECT TOP 1 1 FROM LOTXLOCXID WITH (NOLOCK) WHERE LOC = LOC.LOC AND QTY-QTYPICKED+PENDINGMOVEIN > 0)  
      AND NOT EXISTS (SELECT TOP 1 1 FROM TASKDETAIL WITH (NOLOCK) WHERE TOLOC = LOC.LOC AND STATUS NOT IN ('9','X','R'))  
      AND NOT EXISTS (SELECT TOP 1 1 FROM REPLENISHMENT WITH (NOLOCK) WHERE TOLOC = LOC.LOC AND CONFIRMED NOT IN ('Y'))  
      ORDER BY CASE WHEN LOC.LOCAISLE = @cToLocAisle THEN 1 ELSE 2 END  
             , CASE WHEN TRY_CONVERT(INT, LOC.LOCAISLE) IS NOT NULL AND TRY_CONVERT(INT, @cToLocAisle) IS NOT NULL --GET CLOSEST LOCAISLE
                    THEN ABS(TRY_CONVERT(INT, LOC.LOCAISLE) - TRY_CONVERT(INT, @cToLocAisle)) ELSE 999999 END
             , LOC.PUTAWAYZONE  
   END  
  
   --IF STILL NOT FOUND, DONT GENERATE TASK  
   IF ISNULL(@cFinalLoc,'') = ''  
      RETURN  
  
   --ELSE, PROCEED  
   -- Get new TaskDetailKeys  
   SET @nSuccess = 1  
   EXECUTE dbo.nspg_getkey  
      'TASKDETAILKEY'  
      , 10  
      , @cNewTaskDetailKey OUTPUT  
      , @nSuccess          OUTPUT  
      , @nErrNo            OUTPUT  
      , @cErrMsg           OUTPUT  
   IF @nSuccess <> 1  
   BEGIN  
      SET @nErrNo = 268851  
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey  
      GOTO Fail  
   END  
  
   -- Handling transaction  
   SET @nTranCount = @@TRANCOUNT  
   BEGIN TRAN  -- Begin our own transaction  
   SAVE TRAN rdt_1764CreateTAU01 -- For rollback or commit only our own transaction  
  
   SET @nTransitCount = @nTransitCount + 1  
  
   IF ISNULL(@cFinalLOC,'') <> '' AND '1' = CASE WHEN ISNULL(@cSkipInnerTask,'') = '1' AND ISNULL(@cToLocType,'') = 'PICK' THEN 'SKIP' ELSE '1' END  
   BEGIN  
      --CHECK REQUIRED QTY FOR ALLOCATION  
      --CEILING(CAST(@n_FromLessThanCase AS FLOAT)/@n_CaseCnt) * @n_CaseCnt  
      SET @n_LessThanCaseQty = 0  
      SET @n_LessThanInnerQty = 0  
      SELECT @n_LessThanCaseQty = SUM(ALLOC.LESSTHANCASE)  
           , @n_CaseCnt = ALLOC.CASECNT  
           , @n_LessThanInnerQty = SUM(ALLOC.LESSTHANINNER)  
           , @n_InnerPack = ALLOC.INNERPACK  
      FROM @tTask TASK  
      CROSS APPLY (  
          SELECT SUM(CASE WHEN P.CASECNT>0 THEN  
                     CASE WHEN (PD.QTY % CAST(P.CASECNT AS INT)) > 0 THEN PD.QTY % CAST(P.CASECNT AS INT) ELSE 0 END  
                     ELSE 0 END) AS LESSTHANCASE  
               , P.CASECNT AS CASECNT  
               , SUM(CASE WHEN P.InnerPack > 0 THEN  
                     CASE WHEN (PD.QTY % CAST(P.InnerPack AS INT)) > 0 THEN PD.QTY % CAST(P.InnerPack AS INT) ELSE 0 END  
                     ELSE 0 END) AS LESSTHANINNER  
               , P.INNERPACK  
           FROM PICKDETAIL PD  WITH (NOLOCK)  
           JOIN ORDERS O WITH (NOLOCK) ON PD.ORDERKEY = O.ORDERKEY  
           JOIN SKU S WITH (NOLOCK) ON PD.SKU = S.SKU AND PD.STORERKEY = S.STORERKEY  
           JOIN PACK P WITH (NOLOCK) ON S.PACKKEY = P.PACKKEY  
           LEFT JOIN LOADPLAN LP WITH (NOLOCK) ON O.LOADKEY = LP.LOADKEY  
           WHERE PD.STORERKEY = @cStorerKey  
           AND PD.LOC = TASK.TOLOC  
           AND PD.STATUS IN ('0')  
           AND PD.SKU = TASK.SKU  
           AND PD.TASKDETAILKEY = TASK.TASKDETAILKEY  
           GROUP BY PD.ORDERKEY,P.CASECNT, P.INNERPACK) AS ALLOC  
      GROUP BY TASK.TASKDETAILKEY, TASK.SKU, ALLOC.CASECNT, ALLOC.INNERPACK  
  
      --CHECK REPLENISH TO WHICH LOCATION TYPE  
      SET @cFinalLOCCat  = ''  
      SET @cFinalLOCType = ''  
  
      SELECT @cFinalLOCCat = LOCATIONCATEGORY  
           , @cFinalLocType = LOCATIONTYPE  
      FROM LOC WITH (NOLOCK) WHERE  
      LOC = @cFinalLOC  
  
      IF ISNULL(@n_LessThanCaseQty,0) > 0 AND @cFinalLOCCat = 'CLS'  
      BEGIN  
         --if casecnt > 0, convert qty to number of required case  
         --SET @nTransitCount = 0 --FOR PALLET REPLEN  
         IF @n_CaseCnt > 0  
            SET @nToQTY = CEILING(CAST(@n_LessThanCaseQty AS FLOAT)/@n_CaseCnt) * @n_CaseCnt  
         ELSE  
            SET @nToQTY = @n_LessThanCaseQty  
  
  
         --GRAB ALL PICKDETAIL AND UPDATE TaskDetailKey  
         --ONLY FOR PICKDETAILS THAT HAS LESS THAN CASE ALLOCATED  
         SET @n_SystemQty = 0  
         SET @c_CurrPickdetailKey = ''  
         SET @n_CurrPDQty = 0  
         SET @n_SplitQty = 0  
  
         DECLARE CUR1_DET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT PD.PickdetailKey, PD.QTY  
         FROM PICKDETAIL PD WITH (NOLOCK)  
         WHERE PD.STORERKEY = @cStorerKey  
         AND PD.TASKDETAILKEY = @cTaskDetailKey  
         --AND PD.QTY <  @n_CaseCnt  
         AND PD.QTY < CASE WHEN @n_CaseCnt > 0 THEN @n_CaseCnt* CEILING(CAST(PD.QTY AS FLOAT)/@n_CaseCnt)  
                           ELSE PD.QTY END  
         ORDER BY 1  
  
         OPEN CUR1_DET  
         FETCH FROM CUR1_DET INTO @c_PickDetailKey, @n_PDQty  
         WHILE @@FETCH_STATUS = 0  
         BEGIN  
  
            SET @n_SplitQty = 0  
            IF @n_PDQty < @n_CaseCnt  
            BEGIN  
               UPDATE PICKDETAIL WITH (ROWLOCK)  
               SET TaskDetailKey = @cNewTaskDetailKey, TRAFFICCOP = NULL, Editdate = getdate()  
               WHERE PickdetailKey = @c_PickDetailKey  
  
               SET @n_SystemQty = @n_SystemQty + @n_PDQty  
            END  
            ELSE IF @n_CaseCnt > 0  
               SET @n_SplitQty = @n_PDQty - (@n_CaseCnt * FLOOR(CAST(@n_PDQty AS FLOAT)/@n_CaseCnt))  
  
            IF @n_SplitQty > 0 AND @n_SplitQty < @n_PDQty  
            BEGIN  
               SET @c_NewPickdetailKey = ''  
  
               EXECUTE nspg_GetKey  
                  'PICKDETAILKEY',  
                  10,  
                  @c_NewPickdetailKey OUTPUT,  
                  @nSuccess OUTPUT,  
                  @nErrNo   OUTPUT,  
                  @cErrMsg  OUTPUT  
  
               IF ISNULL(@c_NewPickdetailKey,'') <> ''  
               BEGIN  
                  INSERT INTO PICKDETAIL  (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot,  
                     Storerkey, Sku, AltSku, UOM, UOMQty, Qty, QtyMoved, [Status],  
                     DropID, Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,  
                     ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod,  
                     WaveKey, EffectiveDate, OptimizeCop, ShipFlag, PickSlipNo,  
                     TaskDetailKey, TaskManagerReasonKey, Notes, MoveRefKey )  
                  SELECT @c_NewpickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot,  
                         Storerkey, Sku, AltSku, UOM, CASE UOM WHEN '6' THEN @n_SplitQty ELSE UOMQty END , @n_SplitQty, QtyMoved, Status,  
                         '', Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,  
                         ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod,  
                         WaveKey, EffectiveDate, '9', ShipFlag, PickSlipNo,  
                         @cNewTaskDetailKey, TaskManagerReasonKey, Notes, MoveRefKey  
                  FROM PICKDETAIL WITH (NOLOCK)  
                  WHERE PickdetailKey = @c_PickDetailKey  
  
                  UPDATE PICKDETAIL WITH (ROWLOCK)  
                  SET QTY = QTY - @n_SplitQty, TRAFFICCOP = NULL, Editdate = getdate()  
                  WHERE PickdetailKey = @c_PickDetailKey  
  
                  SET @n_SystemQty = @n_SystemQty + @n_SplitQty  
  
               END  
            END  
  
         FETCH FROM CUR1_DET INTO @c_PickDetailKey, @n_PDQty  
         END  
         CLOSE CUR1_DET  
         DEALLOCATE CUR1_DET  
  
         SET @nLLITTLQty = 0  
         SELECT @nLLITTLQty = SUM(QTY-QTYALLOCATED-QTYPICKED) FROM  
         LOTXLOCXID WITH (NOLOCK) WHERE LOC = @cToLOC  
         AND SKU = @cSKU AND LOT = @cLOT  
         AND ID = @cToID  
  
         IF @n_SystemQty > 0 AND @n_SystemQty < @nToQTY AND @nLLITTLQty = 0  
            SET @nToQTY = @n_SystemQty  
  
         -- Insert final task  
         INSERT INTO TaskDetail (  
            TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, AreaKey, TransitLOC, SystemQty,  
            PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, WaveKey, LoadKey, Priority, SourcePriority, SourceKey, TrafficCop)  
         VALUES (  
            @cNewTaskDetailKey, 'RP1', '0', '', @cToLOC, @cToID, @cFinalLOC, '', @nToQTY, @cToLOCAreaKey, @cFinalLOC, @n_SystemQty,  
            'PP', @cStorerKey, @cSKU, @cLOT, '', @nTransitCount, @cSourceType, @cWaveKey, @cLoadKey, @cPriority, @cSourcePriority, @cTaskDetailKey, NULL)  
         IF @@ERROR <> 0  
         BEGIN  
            SET @nErrNo = 268852  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsTaskDetFail  
            GOTO RollBackTran  
         END  
  
  
      END  
      ELSE IF ISNULL(@n_LessThanInnerQty,0) > 0 AND @cFinalLOCCat = 'PICK'  
      BEGIN  
         --if casecnt > 0, convert qty to number of required case  
         --SET @nTransitCount = 0 --FOR PALLET REPLEN  
         IF @n_InnerPack > 0  
            SET @nToQTY = CEILING(CAST(@n_LessThanInnerQty AS FLOAT)/@n_InnerPack) * @n_InnerPack  
         ELSE  
            SET @nToQTY = @n_LessThanInnerQty  
  
         --GRAB ALL PICKDETAIL AND UPDATE TaskDetailKey  
         --ONLY FOR PICKDETAILS THAT HAS LESS THAN CASE ALLOCATED  
         SET @n_SystemQty = 0  
         SET @c_CurrPickdetailKey = ''  
         SET @n_CurrPDQty = 0  
         SET @n_SplitQty = 0  
  
         DECLARE CUR1_DET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT PD.PickdetailKey, PD.QTY  
         FROM PICKDETAIL PD WITH (NOLOCK)  
         WHERE PD.STORERKEY = @cStorerKey  
         AND PD.TASKDETAILKEY = @cTaskDetailKey  
         --AND PD.QTY <  @n_InnerPack  
         AND PD.QTY < CASE WHEN @n_InnerPack > 0 THEN @n_InnerPack* CEILING(CAST(PD.QTY AS FLOAT)/@n_InnerPack)  
                           ELSE PD.QTY END  
         ORDER BY 1  
  
         OPEN CUR1_DET  
         FETCH FROM CUR1_DET INTO @c_PickDetailKey, @n_PDQty  
         WHILE @@FETCH_STATUS = 0  
         BEGIN  
  
            SET @n_SplitQty = 0  
            IF @n_PDQty < @n_InnerPack  
            BEGIN  
               UPDATE PICKDETAIL WITH (ROWLOCK)  
               SET TaskDetailKey = @cNewTaskDetailKey, TRAFFICCOP = NULL, Editdate = getdate()  
               WHERE PickdetailKey = @c_PickDetailKey  
  
               SET @n_SystemQty = @n_SystemQty + @n_PDQty  
            END  
            ELSE IF @n_InnerPack > 0  
               SET @n_SplitQty = @n_PDQty - (@n_InnerPack * FLOOR(CAST(@n_PDQty AS FLOAT)/@n_InnerPack))  
  
            IF @n_SplitQty > 0 AND @n_SplitQty < @n_PDQty  
            BEGIN  
               SET @c_NewPickdetailKey = ''  
  
               EXECUTE nspg_GetKey  
                  'PICKDETAILKEY',  
                  10,  
                  @c_NewPickdetailKey OUTPUT,  
                  @nSuccess OUTPUT,  
                  @nErrNo   OUTPUT,  
                  @cErrMsg  OUTPUT  
  
               IF ISNULL(@c_NewPickdetailKey,'') <> ''  
               BEGIN  
                  INSERT INTO PICKDETAIL  (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot,  
                     Storerkey, Sku, AltSku, UOM, UOMQty, Qty, QtyMoved, [Status],  
                     DropID, Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,  
                     ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod,  
                     WaveKey, EffectiveDate, OptimizeCop, ShipFlag, PickSlipNo,  
                     TaskDetailKey, TaskManagerReasonKey, Notes, MoveRefKey )  
                  SELECT @c_NewpickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot,  
                         Storerkey, Sku, AltSku, UOM, CASE UOM WHEN '6' THEN @n_SplitQty ELSE UOMQty END , @n_SplitQty, QtyMoved, Status,  
                         '', Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,  
                         ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod,  
                         WaveKey, EffectiveDate, '9', ShipFlag, PickSlipNo,  
                         @cNewTaskDetailKey, TaskManagerReasonKey, Notes, MoveRefKey  
                  FROM PICKDETAIL WITH (NOLOCK)  
                  WHERE PickdetailKey = @c_PickDetailKey  
  
                  UPDATE PICKDETAIL WITH (ROWLOCK)  
                  SET QTY = QTY - @n_SplitQty, TRAFFICCOP = NULL, Editdate = getdate()  
                  WHERE PickdetailKey = @c_PickDetailKey  
  
                  SET @n_SystemQty = @n_SystemQty + @n_SplitQty  
  
               END  
            END  
  
         FETCH FROM CUR1_DET INTO @c_PickDetailKey, @n_PDQty  
         END  
         CLOSE CUR1_DET  
         DEALLOCATE CUR1_DET  
  
         SET @nLLITTLQty = 0  
         SELECT @nLLITTLQty = SUM(QTY-QTYALLOCATED-QTYPICKED) FROM  
         LOTXLOCXID WITH (NOLOCK) WHERE LOC = @cToLOC  
         AND SKU = @cSKU AND LOT = @cLOT  
         AND ID = @cToID  
  
         IF @n_SystemQty > 0 AND @n_SystemQty < @nToQTY AND @nLLITTLQty = 0  
            SET @nToQTY = @n_SystemQty  
  
         -- Insert final task  
         INSERT INTO TaskDetail (  
            TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, AreaKey, TransitLOC, SystemQty,  
            PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, WaveKey, LoadKey, Priority, SourcePriority, SourceKey, TrafficCop)  
         VALUES (  
            @cNewTaskDetailKey, 'RP1', '0', '', @cToLOC, @cToID, @cFinalLOC, '', @nToQTY, @cToLOCAreaKey, @cFinalLOC, @n_SystemQty,  
            'PP', @cStorerKey, @cSKU, @cLOT, '', @nTransitCount, @cSourceType, @cWaveKey, @cLoadKey, @cPriority, @cSourcePriority, @cTaskDetailKey, NULL)  
         IF @@ERROR <> 0  
         BEGIN  
            SET @nErrNo = 268853  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsTaskDetFail  
            GOTO RollBackTran  
         END  
      END  
   END  
  
  
   COMMIT TRAN rdt_1764CreateTAU01 -- Only commit change made here  
   GOTO Quit  
  
RollBackTran:  
   ROLLBACK TRAN rdt_1764CreateTAU01 -- Only rollback change made here  
Fail:  
Quit:  
  
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      COMMIT TRAN  
END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1764CreateTAU01] TO NSQL
GO
