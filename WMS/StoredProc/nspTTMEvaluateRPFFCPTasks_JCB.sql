SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************************************/
/* Stored Procedure: nspTTMEvaluateRPFFCPTasks_JCB                                              */
/* Copyright: Maersk                                                                            */
/* Customer : JCB                                                                               */
/* Purpose:                                                                                     */
/*                                                                                              */
/* Modification log:                                                                            */
/* Date        Ver.   Author   Purposes                                                         */
/* 2025-06-09  1.0.0  NickT    FCR-5727. Created, copied from                                   */
/*                              nspTTMEvaluateRPFTasks                                          */
/* 2025-06-26  1.0.1  Jackc    FCR-5727 1. Not get task from aisle in use.                      */
/*                               2. Fix @tFCPRPFTaskDeliveryDate join condition                 */
/*                               3. Fix Qty, weight calculation for task with SKU=''(UWP36863)  */
/*                               4. Use Picking task reftaskkey to link RPF (UWP36799)          */
/* 2025-07-03  1.0.2  Jackc    FCR-5727 Get task order by task priority                         */
/* 2025-09-01  1.0.3  Dennis   FCR-3959 if toloc(ML or Kit) onhold then look for other lanes    */
/* 2025-11-11  2.0.0  PPA374   Updating aisle in use logic                                      */
/* 2025-12-16  2.0.1  PPA374   Adding fix to avoid blocking replen tasks without orderkey       */
/* 2026-01-05  2.0.2  PPA374   Changing aisle in use to C_String28                              */
/* 2026-02-12  2.0.3  PPA374   Adding INLOCKED flag as a valid location flag to pick from or to */
/* 2026-02-12  2.0.4  PPA374   Not checking aisle in use for PND_OUT unless task is back to VNA */
/************************************************************************************************/

CREATE OR ALTER PROC [dbo].[nspTTMEvaluateRPFFCPTasks_JCB]
    @c_sendDelimiter    NVARCHAR(1)
   ,@c_UserID           NVARCHAR(18)
   ,@c_StrategyKey      NVARCHAR(10)
   ,@c_TTMStrategyKey   NVARCHAR(10)
   ,@c_TTMPickCode      NVARCHAR(10)
   ,@c_TTMOverride      NVARCHAR(10)
   ,@c_AreaKey01        NVARCHAR(10)
   ,@c_AreaKey02        NVARCHAR(10)
   ,@c_AreaKey03        NVARCHAR(10)
   ,@c_AreaKey04        NVARCHAR(10)
   ,@c_AreaKey05        NVARCHAR(10)
   ,@c_LastLoc          NVARCHAR(10)
   ,@c_OutString        NVARCHAR(255)  OUTPUT
   ,@b_Success          INT            OUTPUT
   ,@n_err              INT            OUTPUT
   ,@c_errmsg           NVARCHAR(250)  OUTPUT
   ,@c_ptcid            NVARCHAR(5)
   ,@c_FromLOC          NVARCHAR(10)   OUTPUT
   ,@c_TaskDetailKey    NVARCHAR(10)   OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @nTranCount             INT,
      @nContinue              INT,
      @cLangCode              NVARCHAR( 3),
      @bSkipTheTask           INT,
      @bDebug                 INT,
      @cEquipmentProfileKey   NVARCHAR( 10),
      @cStorerKey             NVARCHAR(15),
      @cTaskDetailKey         NVARCHAR(10),
      @cPutawayZone           NVARCHAR(10),
      @cFromLoc               NVARCHAR(10),
      @cToLOC                 NVARCHAR(10),
      @cFinalLOC              NVARCHAR(10),
      @cTaskType              NVARCHAR( 10),
      @cFromLocationCategory  NVARCHAR( 10),
      @cToLocationCategory    NVARCHAR( 10),
      @cLOCAisle              NVARCHAR( 10),
      @cFacility              NVARCHAR( 5),
      @cWaveKey               NVARCHAR( 10),
      @cLoadKey               NVARCHAR( 10),
      @cPickMethod            NVARCHAR( 10),
      @cSKU                   NVARCHAR(20),
      @cFromID                NVARCHAR(18),
      @cTaskDetailOrderKey    NVARCHAR(10),
      @cOrderKey              NVARCHAR(10),
      @nQty                   INT,
      @nLoopIndex             INT,
      @nToLocMaxPallet        INT,
      @nTempMaxPallet         INT,
      @nRowCount              INT,
      @nExistingPallets       INT,
      @nRowCountTemp1         INT = 0,
      @nRowCountTemp2         INT = 0,
      @fMaximumWeight         FLOAT,
      @fPalletWeight          FLOAT,
      @fSKUGrossWeight        FLOAT,
      @cSQL                   NVARCHAR( MAX),
      @cSQLParam              NVARCHAR( MAX),
      @cLogMsg                NVARCHAR(1000),
      @cCurTaskDetail         NVARCHAR(10),
      @cTempToLoc             NVARCHAR(10),
      @b_SkipTheTask          INT,
	  @nWaitSecondsS          INT,
	  @nWaitSecondsL          INT,
	  

      @cCandidateTaskDetailKey            NVARCHAR(10),
      @cCandidateTaskType                 NVARCHAR(10),
      @cCandidateToLoc                    NVARCHAR(10),
      @cCandidateFinalLoc                 NVARCHAR(10),
      @cCandidateFromLocationCategory     NVARCHAR(10),
      @cCandidateToLocationCategory       NVARCHAR(10),
      @cCandidateOrderKey                 NVARCHAR(10),
      @cCandidatePutawayZone              NVARCHAR(10)

   DECLARE @tFCPRPFTaskCandidate TABLE
   (
      RowIndex                INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
      TaskDetailKey           NVARCHAR(10) NOT NULL,
      TaskType                NVARCHAR(10),
      PickMethod              NVARCHAR(10),
      Priority                NVARCHAR(10) NOT NULL DEFAULT '9',-- V1.0.2 Priority of the task 
      OrderKey                NVARCHAR(10) NULL, -- Order key of the task
      OrderType               NVARCHAR(10) NULL, -- Order type of the task
      OrderPriority           NVARCHAR(10) NULL, -- Order priority of the task
      OrderGroup              NVARCHAR(20) NULL, -- Order group key of the task
      OrderDeliveryDate       DATETIME NULL -- Order delivery date of the task
   )

   DECLARE @tFCPRPFTaskDeliveryDate TABLE
   (
      RowIndex                INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
      TaskDetailKey           NVARCHAR(10) NOT NULL,
      OrderKey                NVARCHAR(10) NULL, -- Order key of the task
      DeliveryDate            DATETIME NOT NULL -- Delivery date of the task
   )

   DECLARE @tSkippedTaskDetail TABLE
   (
      RowIndex                INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
      TaskDetailKey           NVARCHAR(10) NOT NULL
   )

   DECLARE @tTaskCandidate TABLE
   (
      RowIndex                INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
      TaskDetailKey           NVARCHAR(10) NOT NULL,
      TaskType                NVARCHAR(10) NOT NULL,
      Priority                NVARCHAR(10) NOT NULL DEFAULT '9', -- V1.0.2 change default to 9 
      FromLoc                 NVARCHAR(10) NOT NULL,
      FromLocationCategory    NVARCHAR(10) NOT NULL,
      PutawayZone             NVARCHAR(10) NOT NULL, -- Putaway zone of the task
      ToLoc                   NVARCHAR(10) NOT NULL,
      ToLocationCategory      NVARCHAR(10) NOT NULL,
      ToLocMaxPallet          INT NOT NULL DEFAULT 99999,
      FinalLoc                NVARCHAR(10) NULL, -- Final location of the task
      FromID                  NVARCHAR(18) NULL, -- ID of the task
      SKU                     NVARCHAR(20) NULL, -- SKU of the task
      SKUGrossWeight          FLOAT NOT NULL, -- Gross weight of the SKU
      Qty                     INT NOT NULL, -- Quantity of SKU in the task
      PickMethod              NVARCHAR(10) NOT NULL DEFAULT 'FP',
      Status                  NVARCHAR(10) NOT NULL DEFAULT '0', -- Status of the task
      ListKey                 NVARCHAR(10) NOT NULL DEFAULT '',-- List key for the task
      OrderKey                NVARCHAR(10) NOT NULL DEFAULT ''
   )

   DECLARE @tAisle_InUsed TABLE
   ( 
      Rowref INT identity(1,1) Primary Key,
      LocAIsle NVARCHAR(10) ,
      UserKey NVARCHAR(18)
   )

   DECLARE @nIsRDT INT

   EXECUTE RDT.rdtIsRDT @nIsRDT OUTPUT

   SELECT 
      @nTranCount = @@TRANCOUNT,
      @b_Success = 0,
      @n_err = 0,
      @c_errmsg = '',
      @bDebug = IIF(@nIsRDT = 1, 0, 1),
      @cCandidateTaskDetailKey = '',
      @cCandidateTaskType = '',
      @cCandidateToLoc = '',
      @cCandidateToLocationCategory = ''

   SELECT
      @cLangCode = Lang_Code, 
      @cFacility = Facility,
      @cCurTaskDetail = V_TaskDetailKey,
      @c_LastLoc = V_LOC, -- From Loc
      @cStorerKey = StorerKey
   FROM rdt.rdtMobRec WITH (NOLOCK) 
   WHERE UserName = @c_UserID

   SELECT @cEquipmentProfileKey = EquipmentProfileKey
   FROM dbo.TaskManagerUser WITH (NOLOCK) 
   WHERE UserKey = @c_UserID

   SELECT @fMaximumWeight = MaximumWeight 
   FROM dbo.EquipmentProfile EP WITH(NOLOCK) 
   WHERE EquipmentProfileKey = @cEquipmentProfileKey

   SELECT TOP 1 @nWaitSecondsS = Short, @nWaitSecondsL = Long FROM CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'JCBVNAWAIT'

   IF @bDebug = 1
   BEGIN
      SET @cLogMsg = CONCAT_WS(',', 'EquipmentProfile: ' + ISNULL(@cEquipmentProfileKey, ''),
                                 'EquipMaxWeight: ' + FORMAT(ISNULL(@fMaximumWeight, 0), '0.##########')
                              )
      PRINT @cLogMsg
   END

   -- Candidate task selection
   -- 1. Task status must be in status 0 or 3 if assigned to the same user.   Y
   -- 2. Task must be in the provided area (TaskDetail.AreaKey).              Y
   -- 3. Task should be for the JCB storer and EMG03 facility.                Y
   -- 4. Task must be for replenishment or picking be it first, second or third step task. (RPF, RP1, FCP, FCP1)           Y
   -- 5. MHE must not be excluded from the source zone (TaskDetail.Message01)                   Y
   -- 6. MHE must not be excluded from the target (To Loc) zone.                                Y

   --V1.0.1(1) start
   -- Get all VNA aisles in user by other users
   INSERT INTO @tAisle_InUsed
   (
      LocAisle, UserKey
   )
   -- TaskDetail aisles
   SELECT 
      L.LocAisle,
      IIF(TD.UserKey = '', TD.UserKeyOverRide, TD.UserKey) AS UserKey
   FROM dbo.TaskDetail TD WITH(NOLOCK)
      CROSS APPLY (VALUES
         (TD.FromLoc),
         (TD.ToLoc)
      ) AS loc(L)
      LEFT JOIN dbo.LOC L WITH(NOLOCK) ON loc.L = L.Loc AND L.LocationCategory = 'VNA' AND L.Facility = @cFacility
   WHERE LocAisle IS NOT NULL
      AND (TD.UserKey <> '' OR TD.UserKeyOverRide <> '')
      AND TD.Status IN ('0','3')
      AND IIF(TD.UserKey = '', TD.UserKeyOverRide, TD.UserKey) <> @c_UserID
	  AND TD.Storerkey = @cStorerKey

   UNION ALL

   -- RDTMOBREC aisles
   SELECT 
      IIF(ISNULL(L1.LocAisle,'')='',L2.LocAisle,L1.LocAisle) AS LocAisle,
      R.UserName AS UserKey
   FROM RDT.RDTMOBREC R WITH(NOLOCK)
      LEFT JOIN dbo.LOC L1 WITH(NOLOCK) ON R.V_LOC = L1.Loc AND L1.Facility = @cFacility AND L1.LocationCategory = 'VNA'
      LEFT JOIN dbo.LOC L2 WITH(NOLOCK) ON R.C_String28 = L2.Loc AND L2.Facility = @cFacility AND L2.LocationCategory = 'VNA'
   WHERE R.StorerKey = @cStorerKey
      AND ((R.Func IN (1756,1764,1812,1871) AND DATEADD(SECOND, @nWaitSecondsL, R.EditDate) >= GETDATE()) OR (R.Func NOT IN (1756,1764,1812,1871) AND DATEADD(SECOND, @nWaitSecondsS, ISNULL(R.C_DateTime1,0)) >= GETDATE()))
      AND R.UserName <> @c_UserID
      AND IIF(ISNULL(L1.LocAisle,'')='',L2.LocAisle,L1.LocAisle) <> ''

      /*SELECT DISTINCT v.LocAisle, Td.UserKey
      FROM TaskDetail TD WITH (NOLOCK)
      LEFT JOIN LOC FromLoc WITH (NOLOCK) 
         ON TD.FromLOC = FromLoc.Loc 
         AND FromLoc.LocationCategory = 'VNA' 
         AND FromLOC.Facility = @cFacility
      LEFT JOIN LOC ToLoc WITH (NOLOCK) 
         ON TD.ToLOC = ToLoc.Loc 
         AND ToLoc.LocationCategory = 'VNA'
         AND ToLoc.Facility = @cFacility
      CROSS APPLY (
         SELECT FromLoc.LocAisle WHERE ISNULL(FromLoc.LocAisle,'') <> ''
         UNION ALL
         SELECT ToLoc.LocAisle WHERE ISNULL(ToLoc.LocAisle,'') <> ''
      ) v(LocAisle)
      WHERE TD.UserKey <> @c_UserID
      AND TD.Status = '3'
      AND (FromLoc.Loc IS NOT NULL OR ToLoc.Loc IS NOT NULL)*/

   IF @bDebug = 1
   BEGIN
      SELECT 'In used VNA Aisle'
      SELECT * FROM @tAisle_InUsed
   END
   --V1.0.1(1) end

   IF ISNULL(RTRIM(@c_AreaKey01), '') IN ('', 'ALL' )
   BEGIN
      BEGIN TRY 
         INSERT INTO @tFCPRPFTaskCandidate (TaskDetailKey, TaskType, PickMethod, Priority, OrderKey, OrderType, OrderPriority, OrderGroup, OrderDeliveryDate)
         SELECT DISTINCT TD.TaskDetailKey, TD.TaskType, TD.PickMethod, TD.Priority, PD.OrderKey, ORM.Type, ORM.Priority, ORM.OrderGroup, ORM.DeliveryDate
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON TD.StorerKey = PD.StorerKey AND TD.TaskDetailKey = PD.TaskDetailKey
         INNER JOIN dbo.ORDERS ORM WITH (NOLOCK) ON PD.StorerKey = ORM.StorerKey AND PD.OrderKey = ORM.OrderKey
         INNER JOIN dbo.LOC LOC WITH(NOLOCK) ON TD.FromLoc = LOC.Loc AND LOC.Facility = @cFacility
         INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON TD.ToLoc = LOC1.Loc AND LOC1.Facility = @cFacility
         INNER JOIN dbo.TaskManagerUserDetail TMU WITH (NOLOCK) ON TMU.PermissionType = TD.TASKTYPE AND TD.AreaKey = TMU.AreaKey
         WHERE TD.StorerKey = @cStorerKey
            AND
            (
               (TD.Status = '0' AND (TD.UserKey = '' AND TD.UserKeyOverRide IN ('', @c_UserID) ) )
               OR
               (TD.Status = '3' AND TD.UserKey = @c_UserID )
            )
            AND TD.TaskType IN ('FCP', 'FCP1')
            AND TD.PickMethod IN ('PP', 'FP')
            --AND TD.AreaKey = @c_AreaKey01
            AND TMU.UserKey = @c_UserID
            AND TMU.Permission = '1'
         AND (LOC.Status = 'OK' AND LOC.LocationFlag IN ('','NONE','INLOCKED'))
            AND (LOC1.Status = 'OK' AND LOC1.LocationFlag IN ('','NONE','INLOCKED'))
            AND NOT EXISTS (SELECT 1 
                        FROM dbo.PAZoneEquipmentExcludeDetail PAE WITH(NOLOCK)
                        WHERE PAE.EquipmentProfileKey = @cEquipmentProfileKey
                           AND (PAE.PutawayZone = LOC.PutawayZone OR PAE.PutawayZone = LOC1.PutawayZone)
                     )
            AND NOT EXISTS (SELECT 1
                        FROM @tAisle_InUsed Aisle
                        WHERE (Aisle.LocAisle = LOC.LocAisle OR Aisle.LocAisle = LOC1.LocAisle)
	                       AND (LOC.LocationCategory <> 'PND_OUT' OR LOC1.LocationCategory = 'VNA')
                     ) --V1.0.1(1)
         END TRY
         BEGIN CATCH
            SET @nContinue = 3
            SET @n_err = 239802
            SET @c_errmsg = rdt.rdtgetmessage( @n_err, @cLangCode, 'DSP') --Populate @tFCPRPFTaskCandidate Fail
            GOTO Fail
         END CATCH

      BEGIN TRY
         INSERT INTO @tFCPRPFTaskCandidate (TaskDetailKey, TaskType, PickMethod, Priority, OrderKey, OrderType, OrderPriority, OrderGroup, OrderDeliveryDate)
         SELECT DISTINCT TD.TaskDetailKey, TD.TaskType, TD.PickMethod, TD.Priority, PD.OrderKey, ORM.Type, ORM.Priority, ORM.OrderGroup, ORM.DeliveryDate
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         --INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON TD.StorerKey = PD.StorerKey AND TD.FromID = PD.CaseID
         --INNER JOIN dbo.TaskDetail TD1 WITH (NOLOCK) ON PD.StorerKey = TD1.StorerKey AND PD.TaskDetailKey = TD1.TaskDetailKey AND TD1.TaskType IN ('FCP', 'FCP1') AND TD1.Status = '0'
         INNER JOIN dbo.TaskDetail TD1 WITH (NOLOCK) 
            ON TD.StorerKey = TD1.StorerKey 
            AND TD.TaskDetailKey = TD1.RefTaskKey 
            AND TD1.TaskType IN ('FCP', 'FCP1') 
            AND TD1.Status IN ('0', 'S') --V1.0.1(4)
         INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON TD1.TaskDetailKey = PD.TaskDetailKey --V1.0.1(4)
         INNER JOIN dbo.ORDERS ORM WITH (NOLOCK) ON PD.StorerKey = ORM.StorerKey AND PD.OrderKey = ORM.OrderKey
         INNER JOIN dbo.LOC LOC WITH(NOLOCK) ON TD.FromLoc = LOC.Loc AND LOC.Facility = @cFacility
         INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON TD.ToLoc = LOC1.Loc AND LOC1.Facility = @cFacility
		 INNER JOIN dbo.LOC LOC2 WITH(NOLOCK) ON TD.FinalLOC = LOC2.Loc AND LOC2.Facility = @cFacility
         INNER JOIN dbo.TaskManagerUserDetail TMU WITH (NOLOCK) ON TMU.PermissionType = TD.TASKTYPE AND TD.AreaKey = TMU.AreaKey
         WHERE TD.StorerKey = @cStorerKey
            AND
            (
               (TD.Status = '0' AND (TD.UserKey = '' AND TD.UserKeyOverRide IN ('', @c_UserID) ) )
               OR
               (TD.Status = '3' AND TD.UserKey = @c_UserID )
            )
            AND TD.TaskType IN ('RPF', 'RP1')
            AND TD.PickMethod IN ('PP', 'FP')
            AND (LOC.Status = 'OK' AND LOC.LocationFlag IN ('','NONE','INLOCKED'))
            AND (LOC1.Status = 'OK' AND LOC1.LocationFlag IN ('','NONE','INLOCKED'))
            AND (LOC2.Status = 'OK' AND LOC2.LocationFlag IN ('','NONE','INLOCKED'))
            --AND TD.AreaKey = @c_AreaKey01
            AND TMU.UserKey = @c_UserID
            AND TMU.Permission = '1'
            AND NOT EXISTS(SELECT 1 
                        FROM dbo.PAZoneEquipmentExcludeDetail PAE WITH(NOLOCK)
                        WHERE PAE.EquipmentProfileKey = @cEquipmentProfileKey
                           AND (PAE.PutawayZone = LOC.PutawayZone OR PAE.PutawayZone = LOC1.PutawayZone)
                     )
            AND NOT EXISTS (SELECT 1
                        FROM @tAisle_InUsed Aisle
                        WHERE (Aisle.LocAisle = LOC.LocAisle OR Aisle.LocAisle = LOC1.LocAisle)
	                       AND (LOC.LocationCategory <> 'PND_OUT' OR LOC1.LocationCategory = 'VNA')
                     ) --V1.0.1(1)
      END TRY
      BEGIN CATCH
         SET @nContinue = 3
         SET @n_err = 239803
         SET @c_errmsg = rdt.rdtgetmessage( @n_err, @cLangCode, 'DSP') --Populate @tFCPRPFTaskCandidate Fail
         GOTO Fail
      END CATCH
   END --areakey is empty
   ELSE
   BEGIN
      BEGIN TRY
         INSERT INTO @tFCPRPFTaskCandidate (TaskDetailKey, TaskType, PickMethod, Priority, OrderKey, OrderType, OrderPriority, OrderGroup, OrderDeliveryDate)
         SELECT DISTINCT TD.TaskDetailKey, TD.TaskType, TD.PickMethod, TD.Priority, PD.OrderKey, ORM.Type, ORM.Priority, ORM.OrderGroup, ORM.DeliveryDate
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON TD.StorerKey = PD.StorerKey AND TD.TaskDetailKey = PD.TaskDetailKey
         INNER JOIN dbo.ORDERS ORM WITH (NOLOCK) ON PD.StorerKey = ORM.StorerKey AND PD.OrderKey = ORM.OrderKey
         INNER JOIN dbo.LOC LOC WITH(NOLOCK) ON TD.FromLoc = LOC.Loc AND LOC.Facility = @cFacility
         INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON TD.ToLoc = LOC1.Loc AND LOC1.Facility = @cFacility
         INNER JOIN dbo.LOC FinalLoc WITH(NOLOCK) ON TD.FinalLoc = FinalLoc.Loc AND FinalLoc.Facility = @cFacility
         INNER JOIN dbo.TaskManagerUserDetail TMU WITH (NOLOCK) ON TMU.PermissionType = TD.TASKTYPE AND TD.AreaKey = TMU.AreaKey
         WHERE TD.StorerKey = @cStorerKey
            AND
            (
               (TD.Status = '0' AND (TD.UserKey = '' AND TD.UserKeyOverRide IN ('', @c_UserID) ) )
               OR
               (TD.Status = '3' AND TD.UserKey = @c_UserID )
            )
            AND TD.TaskType IN ('FCP', 'FCP1')
            AND (LOC.Status = 'OK' AND LOC.LocationFlag IN ('','NONE','INLOCKED'))
            AND TD.PickMethod IN ('PP', 'FP')
            AND (TD.PickMethod = 'FP' 
               OR (TD.PickMethod = 'PP' AND NOT EXISTS (
               SELECT 1 FROM TaskDetail (NOLOCK) TD2 
               LEFT JOIN dbo.PickDetail PD1 WITH (NOLOCK) ON TD2.StorerKey = PD1.StorerKey AND TD2.TaskDetailKey = PD1.TaskDetailKey AND PD1.OrderKey = PD.OrderKey
               JOIN dbo.LOC LOC2 WITH(NOLOCK) ON TD2.FromLoc = LOC2.Loc AND LOC2.Facility = @cFacility
               LEFT JOIN dbo.SKU S WITH(NOLOCK) ON TD2.Sku = S.Sku AND S.StorerKey = TD2.Storerkey
			   WHERE TD2.OrderKey = PD.OrderKey
               AND (
			      TD2.Status IN ('S','H')
			      OR (LOC2.Status <> 'OK' OR LOC2.LocationFlag NOT IN ('','NONE','INLOCKED'))
			      OR (TD2.Status = '3' AND TD2.UserKey <> @c_UserID)
				  OR TD2.Qty * ISNULL(S.STDGROSSWGT,0) > @fMaximumWeight
				  OR (PD1.TaskDetailKey IS NULL AND TD2.Status IN ('0','3') AND TD2.AreaKey = @c_AreaKey01) --PPA 20/11/2025 fixing to not provide orders with pickdetail is missing
			   )
               AND TD2.TaskType IN ('FCP', 'FCP1')
               AND TD2.PickMethod = 'PP'
               AND LOC2.PutawayZone = LOC.PutawayZone
               AND TD2.AreaKey = TD.AreaKey
               )))
            AND ((LOC1.Status = 'OK' AND LOC1.LocationFlag IN ('','NONE','INLOCKED'))
            --OR It is Marshalling lane
             OR (EXISTS (SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK)
                  WHERE LISTNAME = 'JCBCOMPML'
                  AND SHORT = TD.ToLOC
                  AND Storerkey = @cStorerKey)
               AND EXISTS ( SELECT 1 FROM dbo.CODELKUP CL WITH (NOLOCK)
                        JOIN dbo.LOC L WITH (NOLOCK) ON CL.SHORT = L.LOC
                        WHERE CL.LISTNAME = 'JCBCOMPML'
                          AND CL.LONG = ORM.c_company
                          AND CL.Storerkey = @cStorerKey
                          AND (L.Status = 'OK' AND (L.LocationFlag = '' OR L.LocationFlag = 'NONE' OR L.LocationFlag = 'INLOCKED'))
                     )
               )
            --OR its kitting loc
               OR (EXISTS (SELECT 1
                     FROM dbo.CodeLKUP CL WITH (NOLOCK )
                     JOIN dbo.LOC L WITH (NOLOCK)
                        ON CL.LONG = L.LocationCategory
                     WHERE CL.LISTNAME = 'JCBKITORDT'
                        AND CL.Storerkey = @cStorerKey
                        AND CL.Short = 'Y'
                        AND L.LOC = TD.ToLOC
                        AND CL.Code = ORM.Type)
               AND EXISTS ( SELECT 1 FROM dbo.CodeLKUP CL WITH (NOLOCK)
                        JOIN dbo.LOC L WITH (NOLOCK) ON CL.LONG = L.LocationCategory
                        WHERE CL.Short = 'Y'
                           AND CL.LISTNAME = 'JCBKITORDT'
                           AND CL.Code = ORM.Type
                           AND CL.Storerkey = @cStorerKey
                           AND L.Status = 'OK'
                           AND (L.LocationFlag = '' OR L.LocationFlag = 'NONE' OR L.LocationFlag = 'INLOCKED')
                     )
               )
            )
            AND TD.AreaKey = @c_AreaKey01
            AND TMU.UserKey = @c_UserID
            AND TMU.Permission = '1'
            AND NOT EXISTS(SELECT 1 
                        FROM dbo.PAZoneEquipmentExcludeDetail PAE WITH(NOLOCK)
                        WHERE PAE.EquipmentProfileKey = @cEquipmentProfileKey
                           AND (PAE.PutawayZone = LOC.PutawayZone OR PAE.PutawayZone = LOC1.PutawayZone)
                     )
            AND NOT EXISTS (SELECT 1
                        FROM @tAisle_InUsed Aisle
                        WHERE (Aisle.LocAisle = LOC.LocAisle OR Aisle.LocAisle = LOC1.LocAisle)
	                       AND (LOC.LocationCategory <> 'PND_OUT' OR LOC1.LocationCategory = 'VNA')
                     ) --V1.0.1(1)
            AND ((EXISTS (SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK)
                  WHERE LISTNAME = 'JCBCOMPML'
                  AND SHORT = TD.FinalLoc
                  AND Storerkey = @cStorerKey)
               AND EXISTS ( SELECT 1 FROM dbo.CODELKUP CL WITH (NOLOCK)
                        JOIN dbo.LOC L WITH (NOLOCK) ON CL.SHORT = L.LOC
                        WHERE CL.LISTNAME = 'JCBCOMPML'
                          AND CL.LONG = ORM.c_company
                          AND CL.Storerkey = @cStorerKey
                          AND (L.Status = 'OK' AND (L.LocationFlag = '' OR L.LocationFlag = 'NONE' OR L.LocationFlag = 'INLOCKED'))
                     ))
               OR (EXISTS (SELECT 1
                     FROM dbo.CodeLKUP CL WITH (NOLOCK )
                     JOIN dbo.LOC L WITH (NOLOCK)
                        ON CL.LONG = L.LocationCategory
                     WHERE CL.LISTNAME = 'JCBKITORDT'
                        AND CL.Storerkey = @cStorerKey
                        AND CL.Short = 'Y'
                        AND L.LOC = TD.FinalLoc
                        AND CL.Code = ORM.Type)
               AND EXISTS ( SELECT 1 FROM dbo.CodeLKUP CL WITH (NOLOCK)
                        JOIN dbo.LOC L WITH (NOLOCK) ON CL.LONG = L.LocationCategory
                        WHERE CL.Short = 'Y'
                           AND CL.LISTNAME = 'JCBKITORDT'
                           AND CL.Code = ORM.Type
                           AND CL.Storerkey = @cStorerKey
                           AND L.Status = 'OK'
                           AND (L.LocationFlag = '' OR L.LocationFlag = 'NONE' OR L.LocationFlag = 'INLOCKED')
                     )
               )
            )
      END TRY
      BEGIN CATCH
         SET @nContinue = 3
         SET @n_err = 239804
         SET @c_errmsg = rdt.rdtgetmessage( @n_err, @cLangCode, 'DSP') --Populate @tFCPRPFTaskCandidate Fail
         GOTO Fail
      END CATCH

      BEGIN TRY
         INSERT INTO @tFCPRPFTaskCandidate (TaskDetailKey, TaskType, PickMethod, Priority, OrderKey, OrderType, OrderPriority, OrderGroup, OrderDeliveryDate)
         SELECT DISTINCT TD.TaskDetailKey, TD.TaskType, TD.PickMethod, TD.Priority, PD.OrderKey, ORM.Type, ORM.Priority, ORM.OrderGroup, ORM.DeliveryDate
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         --INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON TD.StorerKey = PD.StorerKey AND TD.FromID = PD.CaseID
         --INNER JOIN dbo.TaskDetail TD1 WITH (NOLOCK) ON PD.StorerKey = TD1.StorerKey AND PD.TaskDetailKey = TD1.TaskDetailKey AND TD1.TaskType IN ('FCP', 'FCP1') AND TD1.Status = '0'
         INNER JOIN dbo.TaskDetail TD1 WITH (NOLOCK) 
            ON TD.StorerKey = TD1.StorerKey 
            AND TD.TaskDetailKey = TD1.RefTaskKey 
            AND TD1.TaskType IN ('FCP', 'FCP1') 
            AND TD1.Status IN ('0', 'S') --V1.0.1(4)
         INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON TD1.TaskDetailKey = PD.TaskDetailKey --V1.0.1(4)
         INNER JOIN dbo.ORDERS ORM WITH (NOLOCK) ON PD.StorerKey = ORM.StorerKey AND PD.OrderKey = ORM.OrderKey
         INNER JOIN dbo.LOC LOC WITH(NOLOCK) ON TD.FromLoc = LOC.Loc AND LOC.Facility = @cFacility
         INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON TD.ToLoc = LOC1.Loc AND LOC1.Facility = @cFacility
		 INNER JOIN dbo.LOC LOC2 WITH(NOLOCK) ON TD.FinalLOC = LOC2.Loc AND LOC2.Facility = @cFacility
         INNER JOIN dbo.TaskManagerUserDetail TMU WITH (NOLOCK) ON TMU.PermissionType = TD.TASKTYPE AND TD.AreaKey = TMU.AreaKey
         WHERE TD.StorerKey = @cStorerKey
            AND
            (
               (TD.Status = '0' AND (TD.UserKey = '' AND TD.UserKeyOverRide IN ('', @c_UserID) ) )
               OR
               (TD.Status = '3' AND TD.UserKey = @c_UserID )
            )
            AND TD.TaskType IN ('RPF', 'RP1')
            AND TD.PickMethod IN ('PP', 'FP')
            AND (LOC.Status = 'OK' AND LOC.LocationFlag IN ('','NONE', 'INLOCKED'))
			AND (LOC2.Status = 'OK' AND LOC2.LocationFlag IN ('','NONE', 'INLOCKED'))
            AND ((LOC1.Status = 'OK' AND LOC1.LocationFlag IN ('','NONE', 'INLOCKED'))
            --OR It is Marshalling lane
             OR (EXISTS (SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK)
                  WHERE LISTNAME = 'JCBCOMPML'
                  AND SHORT = TD.ToLOC
                  AND Storerkey = @cStorerKey)
               AND EXISTS ( SELECT 1 FROM dbo.CODELKUP CL WITH (NOLOCK)
                        JOIN dbo.LOC L WITH (NOLOCK) ON CL.SHORT = L.LOC
                        WHERE CL.LISTNAME = 'JCBCOMPML'
                          AND CL.LONG = ORM.c_company
                          AND CL.Storerkey = @cStorerKey
                          AND (L.Status = 'OK' AND (L.LocationFlag = '' OR L.LocationFlag = 'NONE' OR L.LocationFlag = 'INLOCKED'))
                     )
               )
            --OR its kitting loc
               OR (EXISTS (SELECT 1
                     FROM dbo.CodeLKUP CL WITH (NOLOCK )
                     JOIN dbo.LOC L WITH (NOLOCK)
                        ON CL.LONG = L.LocationCategory
                     WHERE CL.LISTNAME = 'JCBKITORDT'
                        AND CL.Short = 'Y'
                        AND CL.Storerkey = @cStorerKey
                        AND L.LOC = TD.ToLOC
                        AND CL.Code = ORM.Type)
               AND EXISTS ( SELECT 1 FROM dbo.CodeLKUP CL WITH (NOLOCK)
                        JOIN dbo.LOC L WITH (NOLOCK) ON CL.LONG = L.LocationCategory
                        WHERE CL.Short = 'Y'
                           AND CL.LISTNAME = 'JCBKITORDT'
                           AND CL.Storerkey = @cStorerKey
                           AND CL.Code = ORM.Type
                           AND L.Status = 'OK'
                           AND (L.LocationFlag = '' OR L.LocationFlag = 'NONE' OR L.LocationFlag = 'INLOCKED')
                     )
               )
            )
            AND TD.AreaKey = @c_AreaKey01
            AND TMU.UserKey = @c_UserID
            AND TMU.Permission = '1'
            AND NOT EXISTS(SELECT 1 
                        FROM dbo.PAZoneEquipmentExcludeDetail PAE WITH(NOLOCK)
                        WHERE PAE.EquipmentProfileKey = @cEquipmentProfileKey
                           AND (PAE.PutawayZone = LOC.PutawayZone OR PAE.PutawayZone = LOC1.PutawayZone)
                     )
            AND NOT EXISTS (SELECT 1
                        FROM @tAisle_InUsed Aisle
                        WHERE (Aisle.LocAisle = LOC.LocAisle OR Aisle.LocAisle = LOC1.LocAisle)
	                       AND (LOC.LocationCategory <> 'PND_OUT' OR LOC1.LocationCategory = 'VNA')
                     ) --V1.0.1(1)
      END TRY
      BEGIN CATCH
         SET @nContinue = 3
         SET @n_err = 239805
         SET @c_errmsg = rdt.rdtgetmessage( @n_err, @cLangCode, 'DSP') --Populate @tFCPRPFTaskCandidate Fail
         GOTO Fail
      END CATCH

      --PPA374 Adding General Replen Tasks
      BEGIN TRY
         INSERT INTO @tFCPRPFTaskCandidate (TaskDetailKey, TaskType, PickMethod, Priority, OrderKey, OrderType, OrderPriority, OrderGroup, OrderDeliveryDate)
         SELECT TaskDetailKey, TaskType, TD.PickMethod, Priority, ROW_NUMBER()OVER(ORDER BY (SELECT 1)) OrderKey, '999' OrderType, Priority OrderPriority, 'Replen' OrderGroup, CAST(0 AS DATETIME) OrderDeliveryDate
       FROM dbo.TaskDetail TD WITH(NOLOCK)
         INNER JOIN dbo.TaskManagerUserDetail TMU WITH (NOLOCK) ON TMU.PermissionType = TD.TASKTYPE AND TD.AreaKey = TMU.AreaKey
         INNER JOIN dbo.LOC LOC WITH(NOLOCK) ON TD.FromLoc = LOC.Loc AND LOC.Facility = @cFacility
         INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON TD.ToLoc = LOC1.Loc AND LOC1.Facility = @cFacility
		 INNER JOIN dbo.LOC LOC2 WITH(NOLOCK) ON TD.FinalLOC = LOC2.Loc AND LOC2.Facility = @cFacility
       WHERE TD.AreaKey = @c_AreaKey01
         AND (LOC.Status = 'OK' AND LOC.LocationFlag IN ('','NONE', 'INLOCKED'))
         AND TD.TaskType IN ('RPF','RPF1','RP1')
            AND TMU.UserKey = @c_UserID
            AND TMU.Permission = '1'
         AND (LOC1.Status = 'OK' AND LOC1.LocationFlag IN ('','NONE', 'INLOCKED'))
		 AND (LOC2.Status = 'OK' AND LOC2.LocationFlag IN ('','NONE', 'INLOCKED'))
         AND TD.PickMethod IN ('PP', 'FP')
         AND TD.StorerKey = @cStorerKey
         AND (
            (TD.Status = '0' AND (TD.UserKey = '' AND TD.UserKeyOverRide IN ('', @c_UserID)))
            OR
            (TD.Status = '3' AND TD.UserKey = @c_UserID)
         )
         AND NOT EXISTS (
            SELECT 1 
               FROM dbo.PAZoneEquipmentExcludeDetail PAE WITH(NOLOCK)
               WHERE PAE.EquipmentProfileKey = @cEquipmentProfileKey
                  AND (PAE.PutawayZone = LOC.PutawayZone 
                  OR PAE.PutawayZone = LOC1.PutawayZone)
            )
         AND NOT EXISTS (
            SELECT 1 FROM TASKDETAIL TD2 WITH (NOLOCK)
               WHERE TD2.StorerKey = TD.StorerKey
                  AND TD2.OrderKey = TD.OrderKey
                  AND TD2.AreaKey = TD.AreaKey
                  AND TD2.TaskType IN ('RPF','RPF1','RP1')
                  AND TD2.Status = 'S'
				  AND TD.TaskType IN ('FCP','FCP1')
				  AND TD2.OrderKey <> ''
         )
		 AND NOT EXISTS (SELECT 1
                        FROM @tAisle_InUsed Aisle
                        WHERE (Aisle.LocAisle = LOC.LocAisle OR Aisle.LocAisle = LOC1.LocAisle)
	                       AND (LOC.LocationCategory <> 'PND_OUT' OR LOC1.LocationCategory = 'VNA')
                     ) --V1.0.1(1)
      END TRY
      BEGIN CATCH
         SET @nContinue = 3
         SET @n_err = 239805
         SET @c_errmsg = rdt.rdtgetmessage( @n_err, @cLangCode, 'DSP') --Populate @tFCPRPFTaskCandidate Fail
         GOTO Fail
      END CATCH
      ---------------------------------------

      IF @bDebug = 1
         SELECT '@tFCPRPFTaskCandidate', * FROM @tFCPRPFTaskCandidate
   END--areakey is not empty

   IF @bDebug = 1
   BEGIN
      SELECT 'After inserting into @tFCPRPFTaskCandidate'
      SELECT * FROM @tFCPRPFTaskCandidate
   END

   IF NOT EXISTS (SELECT 1 FROM @tFCPRPFTaskCandidate)
   BEGIN
      IF @bDebug = 1
         PRINT '@tFCPRPFTaskCandidate is empty, return'
      SET @c_TaskDetailKey = ''
      RETURN
   END

   BEGIN TRY
      INSERT INTO @tFCPRPFTaskDeliveryDate (TaskDetailKey, OrderKey, DeliveryDate)
      SELECT TaskDetailKey, OrderKey, DATEADD( hh, ISNULL(CAST(Long AS INT), 0), OrderDeliveryDate)
      FROM 
         (SELECT FCPRRPF.TaskDetailKey, 
            FCPRRPF.OrderKey,
            FCPRRPF.OrderDeliveryDate,
            CLK.Long,
            ROW_NUMBER() OVER (
                  PARTITION BY FCPRRPF.OrderKey, FCPRRPF.TaskType, FCPRRPF.PickMethod
                  ORDER BY 
                     CASE 
                        WHEN CLK.UDF02 = FCPRRPF.OrderPriority THEN 1
                        WHEN CLK.UDF03 = FCPRRPF.OrderGroup THEN 2
                        ELSE 3
                     END
            ) AS RowIndex
         FROM @tFCPRPFTaskCandidate AS FCPRRPF
         INNER JOIN dbo.CODELKUP CLK WITH(NOLOCK) ON FCPRRPF.OrderType = CLK.code2 
            AND (CLK.UDF02 = '' OR CLK.UDF02 = FCPRRPF.OrderPriority) 
            AND (CLK.UDF03 = '' OR CLK.UDF03 = FCPRRPF.OrderGroup)
            AND CLK.LISTNAME = 'JCBORDPR'
         WHERE CLK.StorerKey = @cStorerKey) AS T1
      WHERE T1.RowIndex = 1
   END TRY
   BEGIN CATCH
      SET @nContinue = 3
      SET @n_err = 239806
      SET @c_errmsg = rdt.rdtgetmessage( @n_err, @cLangCode, 'DSP') --Populate @tFCPRPFTaskDeliveryDate Fail
      GOTO Fail
   END CATCH

   IF @bDebug = 1
   BEGIN
      SELECT '@tFCPRPFTaskDeliveryDate'
      SELECT * FROM @tFCPRPFTaskDeliveryDate
   END

   IF NOT EXISTS (SELECT 1 FROM @tFCPRPFTaskDeliveryDate)
   BEGIN
      IF @bDebug = 1
         PRINT '@tFCPRPFTaskDeliveryDate is empty'
      SET @nContinue = 3
      SET @n_err = 239812
      SET @c_errmsg = rdt.rdtgetmessage( @n_err, @cLangCode, 'DSP') --@tFCPRPFTaskDeliveryDate is empty
      GOTO Fail
   END

   BEGIN TRY
      INSERT INTO @tTaskCandidate (TaskDetailKey, TaskType, Priority, PutawayZone, FromLoc, FromLocationCategory,
         ToLoc, ToLocationCategory, ToLocMaxPallet, FinalLoc, FromID, SKU, SKUGrossWeight, Qty,
         PickMethod, OrderKey)
      SELECT TaskDetailKey, TaskType, Priority, T.PutawayZone, FromLoc, FromLocationCategory,
             ToLoc, ToLocationCategory, ToLocMaxPallet, FinalLoc, FromID, SKU, ISNULL(SKUGrossWeight,0), ISNULL(Qty,0),
             T.PickMethod, OrderKey
      FROM (
         SELECT 
           TD.TaskDetailKey, 
           TD.TaskType, 
           LOC.PutawayZone, 
           TD.FromLoc, 
           LOC.LocationCategory AS FromLocationCategory,
           LOC.Floor AS FromLocFloor,
           LOC.LocAisle AS FromLocAisle,
           LOC.LogicalLocation AS FromLogicalLoc,
           TD.ToLoc,
           LOC1.LocationCategory AS ToLocationCategory, 
           ISNULL(LOC1.MaxPallet, 99999) AS ToLocMaxPallet, 
           TD.FinalLoc, 
           TD.FromID, 
           ISNULL(TD.SKU,'') AS SKU, 
           -- Calculate SKUGrossWeight of a task
           CASE 
             WHEN TD.SKU IS NULL OR TD.SKU = '' THEN 
               -- IF SKU is empty then get all SKU and Qty from lotxlocxid to get gross weight
               (
                  SELECT SUM(ISNULL(LLI.Qty,0) * ISNULL(SKU2.STDGROSSWGT,0))
                  FROM dbo.LOTXLOCXID LLI WITH(NOLOCK)
                  INNER JOIN dbo.SKU SKU2 WITH(NOLOCK) ON LLI.StorerKey = SKU2.StorerKey AND LLI.SKU = SKU2.SKU
                  WHERE LLI.LOC = TD.FromLoc AND LLI.ID = TD.FromID AND LLI.StorerKey = TD.StorerKey
               )
             ELSE -- IF SKU is not empty then get the gross weight via task and SKU table
               ISNULL(SKU.STDGROSSWGT,0) * ISNULL(TD.QTY,0)
           END AS SKUGrossWeight, --V1.0.1(3)
           CASE 
             WHEN TD.SKU IS NULL OR TD.SKU = '' THEN 
               --IF SKU is empty then get qty from lotxlocxid 
               (
                  SELECT SUM(ISNULL(LLI.Qty,0))
                  FROM dbo.LOTXLOCXID LLI WITH(NOLOCK)
                  WHERE LLI.LOC = TD.FromLoc AND LLI.ID = TD.FromID AND LLI.StorerKey = TD.StorerKey
               )
             ELSE 
               TD.QTY
           END AS Qty, --V1.0.1(3)
           TD.PickMethod,
           ROW_NUMBER() OVER (PARTITION BY TD.TaskDetailKey ORDER BY TD.TaskDetailKey ) AS RowIndex,
           TD.Status, TD.UserKey, TD.UserKeyOverRide, TD.ListKey, TD.Priority, FCPRRPFDD.DeliveryDate, FCPRRPFDD.OrderKey
         FROM dbo.TaskDetail TD WITH (NOLOCK) 
         INNER JOIN @tFCPRPFTaskCandidate AS FCPRRPF ON TD.TaskDetailKey = FCPRRPF.TaskDetailKey
         --INNER JOIN @tFCPRPFTaskDeliveryDate AS FCPRRPFDD ON TD.TaskDetailKey = FCPRRPFDD.TaskDetailKey
         INNER JOIN @tFCPRPFTaskDeliveryDate AS FCPRRPFDD ON FCPRRPF.OrderKey = FCPRRPFDD.OrderKey --v1.0.1(2)
         INNER JOIN dbo.LOC LOC WITH(NOLOCK) ON TD.FromLoc = LOC.Loc AND LOC.Facility = @cFacility
         INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON TD.ToLoc = LOC1.Loc AND LOC1.Facility = @cFacility
         LEFT JOIN dbo.SKU WITH(NOLOCK) ON TD.StorerKey = SKU.StorerKey AND TD.SKU = SKU.SKU
         WHERE EXISTS (SELECT 1 FROM LOTXLOCXID LL WITH(NOLOCK) WHERE LL.Loc = TD.FromLoc AND LL.ID = TD.FromID AND LL.StorerKey = TD.StorerKey)
      ) AS T
      LEFT JOIN LOC LASTLOC WITH(NOLOCK) ON LASTLOC.Loc = ISNULL(@c_LastLoc,'') AND LASTLOC.Facility = @cFacility AND LASTLOC.LocationCategory = 'VNA'
      WHERE T.RowIndex = 1
      ORDER BY 
         IIF(ISNULL(LASTLOC.LOC,'') <> '' AND LASTLOC.LocAisle = T.FromLocAisle, 1, 99),
         IIF(ISNULL(LASTLOC.LOC,'') <> '' AND LASTLOC.LocAisle = T.FromLocAisle AND LASTLOC.Floor = T.FromLocFloor, 1, 99),
         IIF (T.Status = '3' AND UserKey = @c_UserID, 1, 2), 
         IIF (UserKeyOverRide = @c_UserID AND UserKey IN ('',@c_UserID) AND T.Status = '3', 1, 2),
         IIF (UserKeyOverRide = @c_UserID AND T.Status = '0', 1, 2),
         --IIF(ListKey <> '', 1, 2), --V1.0.2
         Priority, 
         DeliveryDate,
         ABS(RANK()OVER(ORDER BY T.FromLogicalLoc) - RANK()OVER(ORDER BY LASTLOC.LogicalLocation)),
         IIF(ListKey <> '', 1, 2), --V1.0.2 Adjust the sequence. Consider business priority first.
         TaskDetailKey
   END TRY
   BEGIN CATCH
      SET @nContinue = 3
      SET @n_err = 239807
      SET @c_errmsg = rdt.rdtgetmessage( @n_err, @cLangCode, 'DSP') --Populate @tTaskCandidate Fail
      GOTO Fail
   END CATCH

   IF @bDebug = 1
   BEGIN
      SELECT 'Ordered tasks in @tTaskCandidate'
      SELECT * FROM @tTaskCandidate
   END

   -- Check if any task candidate were found
   -- 1. Weight of the pallet: sum of (LOTxLOCxID.Qty * SKU.STDGROSSWGT) must be <= max weight of the MHE provided (EquipmentProfile.MaximumWeight).
   -- 2. If "To Loc" is PNDOUT, pallet capacity minus existing inventory must be >= 0.
   -- 3.   If the task is picking, ToLoc can be either marshalling lane or kitting location, need check if ToLoc's Status = 'OK', also need check the LocationFlag NOT IN ('','NONE')

   SET @nLoopIndex = -1
   WHILE 1 = 1
   BEGIN
      SELECT TOP 1
         @cTaskDetailKey = TaskDetailKey,
         @cTaskType = TaskType,
         @cPutawayZone = PutawayZone,
         @cFromLoc = FromLoc,
         @cToLOC = ToLoc,
         @cFinalLOC = FinalLoc,
         @cFromLocationCategory = FromLocationCategory,
         @cToLocationCategory = ToLocationCategory,
         @cFromID = FromID,
         @cSKU = SKU,
         @cPickMethod = PickMethod,
         @fSKUGrossWeight = SKUGrossWeight,
         @nQty = Qty,
         @nToLocMaxPallet = IIF(ToLocMaxPallet = 0, 99999, ToLocMaxPallet), -- Default to 99999 if MaxPallet is 0
         @cTaskDetailOrderKey = OrderKey,
         @nLoopIndex = RowIndex
      FROM @tTaskCandidate AS TC
      WHERE RowIndex > @nLoopIndex
         AND NOT EXISTS(SELECT 1 FROM @tSkippedTaskDetail SKD WHERE TC.TaskDetailKey = SKD.TaskDetailKey)
      ORDER BY RowIndex

      SELECT @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
      BEGIN
         SET @cLogMsg = CONCAT_WS(',','No more task candidates found, exiting loop','')
         PRINT @cLogMsg
         BREAK -- No more task candidates
      END

      IF @bDebug = 1
      BEGIN
         SET @cLogMsg = CONCAT_WS(',', 'Loop @tTaskCandidate - 1',
                                    '@cTaskDetailKey: ' + ISNULL(@cTaskDetailKey, ''),
                                    '@cTaskType: ' + ISNULL(@cTaskType, ''),
                                    '@cPutawayZone: ' + ISNULL(@cPutawayZone, ''),
                                    '@cFromLoc: ' + ISNULL(@cFromLoc, ''),
                                    '@cToLOC: ' + ISNULL(@cToLOC, ''),
                                    '@cFinalLOC: ' + ISNULL(@cFinalLOC, ''),
                                    '@cFromLocationCategory: ' + ISNULL(@cFromLocationCategory, ''),
                                    '@cToLocationCategory: ' + ISNULL(@cToLocationCategory, ''),
                                    '@cFromID: ' + ISNULL(@cFromID, ''),
                                    '@cSKU: ' + ISNULL(@cSKU, ''),
                                    '@fSKUGrossWeight: ' + CAST(ISNULL(@fSKUGrossWeight, 0) AS NVARCHAR(10)),
                                    '@nQty: ' + CAST(ISNULL(@nQty, 0) AS NVARCHAR(10)),
                                    '@nToLocMaxPallet: ' + CAST(ISNULL(@nToLocMaxPallet, 0) AS NVARCHAR(10)),
                                    '@cTaskDetailOrderKey: ' + ISNULL(@cTaskDetailOrderKey, ''),
                                    '@nLoopIndex: ' + CAST(ISNULL(@nLoopIndex, 0) AS NVARCHAR(10))
                                 )
         PRINT @cLogMsg
      END

      -- Check skip task
      SET @b_success = 0
      SET @b_SkipTheTask = 0
      EXECUTE nspCheckSkipTasks
           @c_UserID
         , @cTaskDetailKey
         , @cTaskType
         , ''
         , ''
         , ''
         , ''
         , ''
         , ''
         , @b_SkipTheTask  OUTPUT
         , @b_Success      OUTPUT
         , @n_err          OUTPUT
         , @c_errmsg       OUTPUT
      IF @b_success <> 1
         GOTO Fail

      IF @bDebug = 1
      BEGIN
         SET @cLogMsg = CONCAT_WS(',', 'Loop @tTaskCandidate - 1',
                                    '@b_SkipTheTask: ' + CAST(ISNULL(@b_SkipTheTask, 0) AS NVARCHAR(10))
                                 )
         PRINT @cLogMsg
      END

      IF @b_SkipTheTask = 1
      BEGIN
         DELETE FROM @tTaskCandidate WHERE TaskDetailKey = @cTaskDetailKey
         CONTINUE
      END

      -- 1. Check the weight, make sure Inventory Weight <= MaxWeight of MHE           Y
      IF @cPickMethod = 'FP'
      BEGIN
         SELECT @fPalletWeight = SUM((LLI.Qty - LLI.QtyPicked) * SKU.STDGROSSWGT)
         FROM dbo.LOTXLOCXID LLI WITH (NOLOCK)
         INNER JOIN dbo.SKU WITH(NOLOCK) ON LLI.StorerKey = SKU.StorerKey AND LLI.SKU = SKU.SKU
         WHERE LLI.LOC = @cFromLoc
         AND LLI.ID = @cFromID
         AND LLI.StorerKey = @cStorerKey
         AND LLI.Qty - LLI.QtyPicked > 0
      END
      ELSE
      BEGIN
	     SELECT @fPalletWeight = SUM(@nQty * SKU.STDGROSSWGT)
		 FROM TaskDetail TD WITH (NOLOCK)
		 INNER JOIN dbo.SKU WITH(NOLOCK) ON TD.StorerKey = SKU.StorerKey AND TD.SKU = SKU.SKU
		 WHERE TD.FromLoc = @cFromLoc
		 AND TD.FromID = @cFromID
		 AND TD.SKU = @cSKU
		 AND TD.Storerkey = @cStorerKey
		 AND TD.TaskDetailKey = @cTaskDetailKey

         /*SELECT @fPalletWeight = SUM(@nQty * SKU.STDGROSSWGT)
         FROM dbo.LOTXLOCXID LLI WITH (NOLOCK)
         INNER JOIN dbo.SKU WITH(NOLOCK) ON LLI.StorerKey = SKU.StorerKey AND LLI.SKU = SKU.SKU
         WHERE LLI.LOC = @cFromLoc
         AND LLI.ID = @cFromID
         AND LLI.SKU = @cSKU
         AND LLI.StorerKey = @cStorerKey
         AND LLI.Qty - LLI.QtyPicked > 0*/
      END

      IF @bDebug = 1
      BEGIN
         SET @cLogMsg = CONCAT_WS(',', 'Loop @tTaskCandidate - 1',
                                    '@fPalletWeight: ' + CAST(ISNULL(@fPalletWeight, 0) AS NVARCHAR(10)),
                                    '@fMaximumWeight: ' + FORMAT(ISNULL(@fMaximumWeight, 0), '0.##########')
                                 )
         PRINT @cLogMsg
      END

      -- Pallet weight exceeds the maximum weight of the MHE
      IF @fPalletWeight > @fMaximumWeight
      BEGIN
         IF @bDebug = 1
         BEGIN
            SET @cLogMsg = CONCAT_WS(',', 'Loop @tTaskCandidate - 1',
                                       'Over weight, skip the task'
                                    )
            PRINT @cLogMsg
         END
         CONTINUE
      END

      -- 2. If ToLoc is PND location, check if there are enough space available     Y
      --IF @cToLocationCategory IN ('PND', 'PND_OUT')
      IF @cToLocationCategory IN ('PND', 'PND_OUT') AND @cCandidateTaskDetailKey=''-- V1.0.1
      -- Only check capacity when find the candidate task. If candidate task is found, no need to check capacity for PP tasks to lock. They are in one pallet.
      BEGIN
         SET @nExistingPallets = 0
         SELECT @nExistingPallets = COUNT(DISTINCT ID)
         FROM dbo.LOTXLOCXID WITH(NOLOCK)
         WHERE LOC = @cToLOC
           AND StorerKey = @cStorerKey
           AND Qty > 0

         SET @nTempMaxPallet = 0
         SELECT @nTempMaxPallet = COUNT(1) FROM TaskDetail TD (NOLOCK)
         JOIN dbo.LOC LOC WITH(NOLOCK) ON TD.ToLoc = LOC.Loc AND LOC.Facility = @cFacility
         WHERE TD.Status = '3' AND TD.TaskType IN ('FCP','FCP1')
         AND LOC.LOC = @cToLOC

         IF @bDebug = 1
         BEGIN
            SET @cLogMsg = CONCAT_WS(',', 'Loop @tTaskCandidate - 1',
                                       'ToLoc is PND, checking capacity',
                                       '@nExistingPallets: ' + CAST(ISNULL(@nExistingPallets, 0) AS NVARCHAR(10)),
                                       '@nTempMaxPallet: ' + CAST(ISNULL(@nTempMaxPallet, 0) AS NVARCHAR(10)),
                                       '@nToLocMaxPallet: ' + CAST(ISNULL(@nToLocMaxPallet, 0) AS NVARCHAR(10))
                                    )
            PRINT @cLogMsg
         END

         -- Not enough space available in the destination location
         IF @nToLocMaxPallet <= ISNULL(@nExistingPallets, 0) + ISNULL(@nTempMaxPallet, 0)
         BEGIN
            SET @cTempToLoc = ''
            SELECT TOP 1 @cTempToLoc = LOC1.LOC FROM dbo.LOC LOC1 WITH(NOLOCK)
            JOIN dbo.LOC LOC2 WITH(NOLOCK) ON LOC2.Loc = @cToLoc AND LOC2.Facility = @cFacility AND LOC1.LocAisle = LOC2.LocAisle AND LOC1.Floor = LOC2.Floor
            LEFT JOIN dbo.LOTXLOCXID LLI WITH(NOLOCK) ON LOC1.LOC = LLI.LOC AND LLI.StorerKey = @cStorerKey AND LLI.Qty > 0 
            LEFT JOIN TASKDETAIL TD WITH(NOLOCK) ON LOC1.Loc = TD.ToLoc AND TD.Status = '3' AND TD.TaskType IN ('FCP','FCP1')
            WHERE LOC1.Facility = @cFacility
            AND LOC1.LOC <> @cToLoc
            AND LOC1.LocationCategory = 'PND_OUT'
            AND (LOC1.Status = 'OK' AND LOC1.LocationFlag IN ('','NONE', 'INLOCKED'))
            GROUP BY LOC1.Loc
            HAVING COUNT(DISTINCT LLI.ID) + COUNT(DISTINCT TD.TaskDetailKey) < MAX(ISNULL(LOC1.MaxPallet, 99999))

            IF ISNULL(@cTempToLoc, '') <> ''
            BEGIN
               SET @cToLoc = @cTempToLoc
               UPDATE @tTaskCandidate SET ToLoc = @cToLoc WHERE TaskDetailKey = @cTaskDetailKey
               UPDATE TASKDETAIL SET TOLOC = @cToLoc WHERE TASKDETAILKEY = @cTaskDetailKey

               IF @bDebug = 1
               BEGIN
                  SET @cLogMsg = CONCAT_WS(',', 'Loop @tTaskCandidate - 1',
                                             'Switch ToLoc to another PND_OUT location: ', @cToLoc
                                          )
                  PRINT @cLogMsg
               END
            END
            ELSE
            BEGIN
               IF @bDebug = 1
               BEGIN
                  SET @cLogMsg = CONCAT_WS(',', 'Loop @tTaskCandidate - 1',
                                             'No enough space, skip the task'
                                          )
                  PRINT @cLogMsg
               END
               CONTINUE
            END
         END
      END

      -- 3. If the task is picking, check if ToLoc is valid,
      -- ToLoc is either a kitting location or a marshalling lane, or PND location        Y
      IF @cTaskType IN ('FCP', 'FCP1')
      BEGIN
         SET @nRowCount = 0
         -- a. Check if ToLoc is a valid kitting location
         SELECT @nRowCount = COUNT(1) 
         FROM dbo.CODELKUP CLK WITH(NOLOCK)
         INNER JOIN dbo.LOC WITH(NOLOCK) ON ISNULL(CLK.Long, '') = LOC.LocationCategory AND LOC.Loc = @cToLoc
         WHERE CLK.LISTNAME = 'JCBKITORDT'
            AND CLK.Storerkey = @cStorerKey
            AND LOC.Facility =  @cFacility
            --AND (LOC.Status = 'OK' AND LOC.LocationFlag IN ('','NONE', 'INLOCKED'))

         -- b. Check if ToLoc is a valid marshalling lane            Y
         IF ISNULL(@nRowCount, 0) = 0
         BEGIN
            IF @bDebug = 1
            BEGIN
               SET @cLogMsg = CONCAT_WS(',', 'Loop @tTaskCandidate - 1',
                                          'ToLoc is not a valid kitting location: ', @cToLoc
                                       )
               PRINT @cLogMsg
            END

            SELECT @nRowCountTemp1 = COUNT(1) 
            FROM dbo.CODELKUP CLK WITH(NOLOCK)
            INNER JOIN dbo.LOC WITH(NOLOCK) ON CLK.Short = LOC.Loc
            WHERE CLK.LISTNAME = 'JCBCOMPML' 
               AND CLK.Short = @cToLoc
               AND LOC.Facility = @cFacility
               AND CLK.Storerkey = @cStorerKey
               --AND (LOC.Status = 'OK' AND LOC.LocationFlag IN ('','NONE', 'INLOCKED'))

            SELECT @cOrderKey = PD.OrderKey
            FROM dbo.PickDetail PD WITH(NOLOCK)
            INNER JOIN dbo.TaskDetail TD WITH(NOLOCK) ON PD.StorerKey = TD.StorerKey AND PD.TaskDetailKey = TD.TaskDetailKey
            WHERE TD.TaskDetailKey = @cTaskDetailKey
            AND PD.StorerKey = @cStorerKey

            SELECT @nRowCountTemp2 = COUNT(1)
            FROM dbo.MBOL WITH(NOLOCK)
            INNER JOIN dbo.ORDERS ORM WITH(NOLOCK) ON MBOL.MbolKey = ORM.MbolKey
            WHERE ORM.OrderKey = @cOrderKey
               AND MBOL.OtherReference <> ''

            -- Exists in 'JCBCOMPML', but not exists in MBOL with OtherReference <> ''
            IF ISNULL(@nRowCountTemp1, 0) > 0 AND ISNULL(@nRowCountTemp2, 0) < 1
            BEGIN
               SET @nRowCount = 1 --Valid marshalling lane
            END
            ELSE
               SET @nRowCount = 0 --Invalid marshalling lane
         END

         -- c. Check if ToLoc is a valid PND location          Y
         IF ISNULL(@nRowCount, 0) = 0
         BEGIN
            IF @bDebug = 1
            BEGIN
               SET @cLogMsg = CONCAT_WS(',', 'Loop @tTaskCandidate - 1',
                                          'ToLoc is not a valid marshalling lane: ', @cToLoc
                                       )
               PRINT @cLogMsg
            END

            SELECT @nRowCount = COUNT(1)
            FROM dbo.LOC WITH(NOLOCK)
            WHERE Loc = @cToLoc
               AND Facility = @cFacility
               AND LocationCategory IN ('PND', 'PND_OUT')
               --AND (Status = 'OK' AND LocationFlag IN ('','NONE', 'INLOCKED'))
         END

         -- If ToLoc is not valid, skip the task               Y
         IF ISNULL(@nRowCount, 0) = 0
         BEGIN
            IF @bDebug = 1
            BEGIN
               SET @cLogMsg = CONCAT_WS(',', 'Loop @tTaskCandidate - 1',
                                          'ToLoc is not valid, skip the task: ', @cToLoc
                                       )
               PRINT @cLogMsg
            END
            CONTINUE
         END
      END --END while

      -- 3. If the first task is from PND OUT. Tasks having "From Loc" category as PND OUT must be sorted not only by priority, delivery date, logical loc and loc, 
      --    but also by number of unique users already having tasks assigned to that location. 
      --    need select a best task in the PND OUT location where minimum user is working on it 

      --@cCandidateTaskDetailKey is empty means no task found yet, still try to find a valid task to return
      IF @cCandidateTaskDetailKey = '' AND @cFromLocationCategory IN ('PND', 'PND_OUT') AND @cPickMethod = 'FP'
      BEGIN
         IF @bDebug = 1
         BEGIN
            SET @cLogMsg = CONCAT_WS(',', 'First Task PND OUT',
                                       'First task is from PND OUT, FromLoc is PND OUT, PickMethod is FP'
                                    )
            PRINT @cLogMsg
         END
         
         DECLARE @cTaskDetailKey1   NVARCHAR(10) = ''
         DECLARE @tFPTaskCandidate TABLE
         (
            RowIndex                INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            TaskDetailKey           NVARCHAR(10) NOT NULL,
            TaskType                NVARCHAR(10) NOT NULL,
            FromLoc                 NVARCHAR(10) NOT NULL,
            FromLocationCategory    NVARCHAR(10) NOT NULL,
            PutawayZone             NVARCHAR(10) NOT NULL, -- Putaway zone of the task
            ToLoc                   NVARCHAR(10) NOT NULL,
            ToLocationCategory      NVARCHAR(10) NOT NULL,
            ToLocMaxPallet          INT NOT NULL,
            FinalLoc                NVARCHAR(10) NULL DEFAULT '', -- Final location of the task
            FromID                  NVARCHAR(18) NULL DEFAULT '', -- ID of the task
            SKU                     NVARCHAR(20) NULL DEFAULT '', -- SKU of the task
            SKUGrossWeight          FLOAT NULL DEFAULT 0, -- Gross weight of the SKU
            Qty                     INT NOT NULL, -- Quantity of SKU in the task
            UserCount               INT
         )
         
         BEGIN TRY
            INSERT INTO @tFPTaskCandidate (TaskDetailKey, TaskType, PutawayZone, FromLoc, FromLocationCategory,
               ToLoc, ToLocationCategory, ToLocMaxPallet, FinalLoc, FromID, SKU, SKUGrossWeight, Qty, UserCount)
            SELECT
               TC.TaskDetailKey,
               TC.TaskType,
               TC.PutawayZone,
               TC.FromLoc,
               TC.FromLocationCategory,
               TC.ToLoc,
               TC.ToLocationCategory,
               IIF(TC.ToLocMaxPallet = 0, 99999, TC.ToLocMaxPallet),
               TC.FinalLoc,
               TC.FromID,
               TC.SKU,
               TC.SKUGrossWeight,
               TC.Qty,
               TD1.UserCount
            FROM @tTaskCandidate AS TC
            LEFT JOIN (SELECT  T1.FromLoc, COUNT(DISTINCT TD1.UserKey) AS UserCount
                        FROM
                           (SELECT TD.TaskDetailKey, TD.FromLoc
                              FROM dbo.TaskDetail TD WITH(NOLOCK) 
                              INNER JOIN dbo.LOC WITH(NOLOCK) ON TD.FromLoc = LOC.Loc
                              WHERE TD.StorerKey = @cStorerKey
                              AND TD.TaskType IN ('RPF', 'RP1', 'FCP', 'FCP1')
                              AND LOC.LocationCategory IN ('PND', 'PND_OUT')
                              AND TD.Status IN ('0', '3')
                              AND TD.PickMethod = 'FP'
                              AND LOC.PutawayZone = @cPutawayZone) T1
                           LEFT JOIN dbo.TaskDetail TD1 WITH(NOLOCK)
                           ON T1.TaskDetailKey = TD1.TaskDetailKey AND TD1.UserKey <> ''
                        GROUP BY  T1.FromLoc
                        ) AS TD1
            ON TC.FromLoc = TD1.FromLoc
            ORDER BY ISNULL(TD1.UserCount, 0), TC.RowIndex, TC.FromLoc
         END TRY
         BEGIN CATCH
            SET @nContinue = 3
            SET @n_err = 239808
            SET @c_errmsg = rdt.rdtgetmessage( @n_err, @cLangCode, 'DSP') --Populate @tFPTaskCandidate Fail

            IF @bDebug = 1
            BEGIN
               SET @cLogMsg = CONCAT_WS(',', 'Exception happens while insert into @tFPTaskCandidate: ', Error_message() )
               PRINT @cLogMsg
            END
            
            GOTO Fail
         END CATCH

         IF @bDebug = 1
         BEGIN
            SELECT '@tFPTaskCandidate', * FROM @tFPTaskCandidate
         END

         DECLARE @nLoopIndex1 INT = -1
         DELETE FROM @tSkippedTaskDetail

         WHILE 1 = 1
         BEGIN
            SELECT TOP 1
               @cTaskDetailKey1 = TC.TaskDetailKey,
               @cTaskType = TC.TaskType,
               @cPutawayZone = TC.PutawayZone,
               @cFromLoc = TC.FromLoc,
               @cToLOC = TC.ToLoc,
               @cFinalLOC = TC.FinalLoc,
               @cFromLocationCategory = TC.FromLocationCategory,
               @cToLocationCategory = TC.ToLocationCategory,
               @cFromID = TC.FromID,
               @cSKU = TC.SKU,
               @fSKUGrossWeight = TC.SKUGrossWeight,
               @nQty = TC.Qty,
               @nToLocMaxPallet = ToLocMaxPallet,
               @nLoopIndex1 = TC.RowIndex
            FROM @tFPTaskCandidate AS TC
            WHERE TC.RowIndex > @nLoopIndex1
            ORDER BY TC.RowIndex

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount = 0
            BEGIN
               SET @cTaskDetailKey1 = ''
               BREAK -- No more task candidates
            END

            IF @bDebug = 1
            BEGIN
               SET @cLogMsg = CONCAT_WS(',', 'Loop @tFPTaskCandidate - 1',
                                          '@cTaskDetailKey1: ' + ISNULL(@cTaskDetailKey1, ''),
                                          '@cTaskType: ' + ISNULL(@cTaskType, ''),
                                          '@cPutawayZone: ' + ISNULL(@cPutawayZone, ''),
                                          '@cFromLoc: ' + ISNULL(@cFromLoc, ''),
                                          '@cToLOC: ' + ISNULL(@cToLOC, ''),
                                          '@cFinalLOC: ' + ISNULL(@cFinalLOC, ''),
                                          '@cFromLocationCategory: ' + ISNULL(@cFromLocationCategory, ''),
                                          '@cToLocationCategory: ' + ISNULL(@cToLocationCategory, ''),
                                          '@cFromID: ' + ISNULL(@cFromID, ''),
                                          '@cSKU: ' + ISNULL(@cSKU, ''),
                                          '@fSKUGrossWeight: ' + CAST(ISNULL(@fSKUGrossWeight, 0) AS NVARCHAR(10)),
                                          '@nQty: ' + CAST(ISNULL(@nQty, 0) AS NVARCHAR(10)),
                                          '@nToLocMaxPallet: ' + CAST(ISNULL(@nToLocMaxPallet, 0) AS NVARCHAR(10)),
                                          '@nLoopIndex1: ' + CAST(ISNULL(@nLoopIndex1, 0) AS NVARCHAR(10))
                                       )
               PRINT @cLogMsg
            END

            -- No need to check itself, becuase the validation is passed
            IF @cTaskDetailKey1 = @cTaskDetailKey
            BEGIN
               SET @cCandidateTaskDetailKey = IIF(ISNULL(@cTaskDetailKey1, '') <> '', @cTaskDetailKey1, @cTaskDetailKey)

               IF @bDebug = 1
               BEGIN
                  SET @cLogMsg = CONCAT_WS(',', 'Loop @tFPTaskCandidate - 1',
                                             'Task is found - 1 ', @cCandidateTaskDetailKey, @cTaskDetailKey1
                                          )
                  PRINT @cLogMsg
               END

               BREAK
            END

            -- 1. Check the weight, make sure Inventory Weight <= MaxWeight of MHE
            SELECT @fPalletWeight = SUM((LLI.Qty - LLI.QtyPicked) * SKU.STDGROSSWGT)
            FROM dbo.LOTXLOCXID LLI WITH (NOLOCK)
            INNER JOIN dbo.SKU WITH(NOLOCK) ON LLI.StorerKey = SKU.StorerKey AND LLI.SKU = SKU.SKU
            WHERE LLI.LOC = @cFromLoc
            AND LLI.ID = @cFromID
            AND LLI.StorerKey = @cStorerKey
            AND LLI.Qty - LLI.QtyPicked > 0

            IF @bDebug = 1
            BEGIN
               SET @cLogMsg = CONCAT_WS(',', 'Loop @tFPTaskCandidate - 1',
                                          '@fPalletWeight: ' + CAST(ISNULL(@fPalletWeight, 0) AS NVARCHAR(10)),
                                          '@fMaximumWeight: ' + CAST(ISNULL(@fMaximumWeight, 0) AS NVARCHAR(10))
                                       )
               PRINT @cLogMsg
            END

            -- Pallet weight exceeds the maximum weight of the MHE
            IF @fPalletWeight > @fMaximumWeight
            BEGIN
               INSERT INTO @tSkippedTaskDetail (TaskDetailKey)
               VALUES (@cTaskDetailKey1)

               IF @bDebug = 1
               BEGIN
                  SET @cLogMsg = CONCAT_WS(',', 'Loop @tFPTaskCandidate - 1',
                                             'Over weight, skip the task'
                                          )
                  PRINT @cLogMsg
               END
               CONTINUE
            END

            -- 2. If ToLoc is PND location, check if there are enough space available
            IF @cToLocationCategory IN ('PND', 'PND_OUT')
            BEGIN
               SET @nExistingPallets = 0

               SELECT @nExistingPallets = COUNT(DISTINCT ID)
               FROM dbo.LOTXLOCXID WITH(NOLOCK)
               WHERE LOC = @cToLOC
                 AND StorerKey = @cStorerKey
                 AND Qty - QtyPicked > 0

               SET @nTempMaxPallet = 0
               SELECT @nTempMaxPallet = COUNT(1) FROM TaskDetail TD (NOLOCK)
               JOIN dbo.LOC LOC WITH(NOLOCK) ON TD.ToLoc = LOC.Loc AND LOC.Facility = @cFacility
               WHERE TD.Status = '3' AND TD.TaskType IN ('FCP','FCP1')
               AND LOC.LOC = @cToLOC

               IF @bDebug = 1
               BEGIN
                  SET @cLogMsg = CONCAT_WS(',', 'Loop @tFPTaskCandidate - 1',
                                             '@nExistingPallets: ' + CAST(ISNULL(@nExistingPallets, 0) AS NVARCHAR(10)),
                                             '@nTempMaxPallet: ' + CAST(ISNULL(@nTempMaxPallet, 0) AS NVARCHAR(10)),
                                             '@nToLocMaxPallet: ' + CAST(ISNULL(@nToLocMaxPallet, 0) AS NVARCHAR(10))
                                          )
                  PRINT @cLogMsg
               END

               -- Not enough space available in the destination location
               IF @nToLocMaxPallet <= ISNULL(@nExistingPallets, 0) 
               BEGIN
                  IF @cToLocationCategory = 'PND_OUT' 
                  BEGIN
                     SET @cTempToLoc = ''
                     SELECT TOP 1 @cTempToLoc = LOC1.LOC FROM dbo.LOC LOC1 WITH(NOLOCK)
                     JOIN dbo.LOC LOC2 WITH(NOLOCK) ON LOC2.Loc = @cToLoc AND LOC2.Facility = @cFacility AND LOC1.LocAisle = LOC2.LocAisle AND LOC1.Floor = LOC2.Floor
                     LEFT JOIN dbo.LOTXLOCXID LLI WITH(NOLOCK) ON LOC1.LOC = LLI.LOC AND LLI.StorerKey = @cStorerKey AND LLI.Qty - LLI.QtyPicked > 0 
                     LEFT JOIN TASKDETAIL TD WITH(NOLOCK) ON LOC1.Loc = TD.ToLoc AND TD.Status = '3' AND TD.TaskType IN ('FCP','FCP1')
                     WHERE LOC1.Facility = @cFacility
                     AND LOC1.LOC <> @cToLoc
                     AND LOC1.LocationCategory = 'PND_OUT'
                     AND (LOC1.Status = 'OK' AND LOC1.LocationFlag IN ('','NONE', 'INLOCKED'))
                     GROUP BY LOC1.Loc
                     HAVING COUNT(DISTINCT LLI.ID) + COUNT(DISTINCT TD.TaskDetailKey) < MAX(ISNULL(LOC1.MaxPallet, 99999))

                     IF ISNULL(@cTempToLoc, '') <> ''
                     BEGIN
                        SET @cToLoc = @cTempToLoc
                        UPDATE @tTaskCandidate SET ToLoc = @cToLoc WHERE TaskDetailKey = @cTaskDetailKey
                        UPDATE TASKDETAIL SET TOLOC = @cToLoc WHERE TASKDETAILKEY = @cTaskDetailKey

                        IF @bDebug = 1
                        BEGIN
                           SET @cLogMsg = CONCAT_WS(',', 'Loop @tTaskCandidate - 1',
                                                      'Switch ToLoc to another PND_OUT location: ', @cToLoc
                                                   )
                           PRINT @cLogMsg
                        END
                     END
                     ELSE
                     BEGIN
                        INSERT INTO @tSkippedTaskDetail (TaskDetailKey)
                        VALUES (@cTaskDetailKey1)

                        IF @bDebug = 1
                        BEGIN
                           SET @cLogMsg = CONCAT_WS(',', 'Loop @tFPTaskCandidate - 1',
                                                      'No enough space, skip the task'
                                                   )
                           PRINT @cLogMsg
                        END
                        CONTINUE
                     END
                  END
                  ELSE
                  BEGIN
                     INSERT INTO @tSkippedTaskDetail (TaskDetailKey)
                     VALUES (@cTaskDetailKey1)

                     IF @bDebug = 1
                     BEGIN
                        SET @cLogMsg = CONCAT_WS(',', 'Loop @tFPTaskCandidate - 1',
                                                   'No enough space, skip the task'
                                                )
                        PRINT @cLogMsg
                     END
                     CONTINUE
                  END
               END
            END

            -- 3. If the task is picking, check if ToLoc is valid,
            -- ToLoc is either a kitting location or a marshalling lane
            IF @cTaskType IN ('FCP', 'FCP1')
            BEGIN
               SET @nRowCount = 0
               -- a. Check if ToLoc is a valid kitting location
               SELECT @nRowCount = COUNT(1) 
               FROM dbo.CODELKUP CLK WITH(NOLOCK)
               INNER JOIN dbo.LOC WITH(NOLOCK) ON ISNULL(CLK.Long, '') = LOC.LocationCategory AND LOC.Loc = @cToLoc
               WHERE CLK.LISTNAME = 'JCBKITORDT'
                  AND CLK.Storerkey = @cStorerKey
                  AND LOC.Facility =  @cFacility
                  --AND (LOC.Status = 'OK' AND LOC.LocationFlag IN ('','NONE', 'INLOCKED'))

               -- b. Check if ToLoc is a valid marshalling lane
               IF ISNULL(@nRowCount, 0) = 0
               BEGIN

                  SELECT @nRowCountTemp1 = COUNT(1) 
                  FROM dbo.CODELKUP CLK WITH(NOLOCK)
                  INNER JOIN dbo.LOC WITH(NOLOCK) ON CLK.Short = LOC.Loc
                  WHERE CLK.LISTNAME = 'JCBCOMPML' 
                     AND CLK.Short = @cToLoc
                     AND LOC.Facility = @cFacility
                     AND CLK.Storerkey = @cStorerKey
                     --AND (LOC.Status = 'OK' AND LOC.LocationFlag IN ('','NONE', 'INLOCKED'))

                  SELECT @cOrderKey = PD.OrderKey
                  FROM dbo.PickDetail PD WITH(NOLOCK)
                  INNER JOIN dbo.TaskDetail TD WITH(NOLOCK) ON PD.StorerKey = TD.StorerKey AND PD.TaskDetailKey = TD.TaskDetailKey
                  WHERE TD.TaskDetailKey = @cTaskDetailKey1
                  AND PD.StorerKey = @cStorerKey

                  SELECT @nRowCountTemp2 = COUNT(1)
                  FROM dbo.MBOL WITH(NOLOCK)
                  INNER JOIN dbo.ORDERS ORM WITH(NOLOCK) ON MBOL.MbolKey = ORM.MbolKey
                  WHERE ORM.OrderKey = @cOrderKey
                     AND MBOL.OtherReference <> ''

                  -- Exists in 'JCBCOMPML', but not exists in MBOL with OtherReference <> ''
                  IF ISNULL(@nRowCountTemp1, 0) > 0 AND ISNULL(@nRowCountTemp2, 0) < 1
                  BEGIN
                     SET @nRowCount = 1 --Valid marshalling lane
                  END
                  ELSE
                     SET @nRowCount = 0 --Invalid marshalling lane
               END

               -- c. Check if ToLoc is a valid location
               IF ISNULL(@nRowCount, 0) = 0
               BEGIN
                  SELECT @nRowCount = COUNT(1)
                  FROM dbo.LOC WITH(NOLOCK)
                  WHERE Loc = @cToLoc
                     AND Facility = @cFacility
                     AND LocationCategory IN ('PND', 'PND_OUT')
                     --AND (Status = 'OK' AND LocationFlag IN ('','NONE', 'INLOCKED'))
               END

               -- If ToLoc is not valid, skip the task
               IF ISNULL(@nRowCount, 0) = 0
               BEGIN
                  INSERT INTO @tSkippedTaskDetail (TaskDetailKey)
                  VALUES (@cTaskDetailKey1)

                  IF @bDebug = 1
                  BEGIN
                     SET @cLogMsg = CONCAT_WS(',', 'Loop @tFPTaskCandidate - 1',
                                                'ToLoc is not valid, skip the task'
                                             )
                     PRINT @cLogMsg
                  END
                  CONTINUE
               END
            END

            -- The task is found, it is the best one
            SET @cCandidateTaskDetailKey = IIF(ISNULL(@cTaskDetailKey1, '') <> '', @cTaskDetailKey1, @cTaskDetailKey)

            IF @bDebug = 1
            BEGIN
               SET @cLogMsg = CONCAT_WS(',', 'Loop @tFPTaskCandidate - 1',
                                          'Task is found - 0 ', @cCandidateTaskDetailKey, @cTaskDetailKey1
                                       )
               PRINT @cLogMsg
            END
            
            BREAK -- Break PND location searching loop
         END --FP task list while end

         IF @cCandidateTaskDetailKey = ''
         BEGIN
            IF @bDebug = 1
            BEGIN
               SET @cLogMsg = CONCAT_WS(',', 'Loop @tFPTaskCandidate - 1',
                                          'No task is found, continue to next iteration'
                                       )
               PRINT @cLogMsg
            END
            -- No valid task is found, continue to the next iteration
            CONTINUE
         END
         ELSE 
         BEGIN
            -- A valid task is found, break the loop
            BEGIN TRY
               UPDATE @tTaskCandidate SET Status = '3' WHERE TaskDetailKey = @cCandidateTaskDetailKey
            END TRY
            BEGIN CATCH
               SET @nContinue = 3
               SET @n_err = 239809
               SET @c_errmsg = rdt.rdtgetmessage( @n_err, @cLangCode, 'DSP') --Populate @tTaskCandidate Fail
               GOTO Fail
            END CATCH

            IF @bDebug = 1
            BEGIN
               SET @cLogMsg = CONCAT_WS(',', 'Loop @tFPTaskCandidate - 1',
                                          'Task is found - 0, mark is as 3'
                                       )
               PRINT @cLogMsg
            END

            BREAK -- Break entire task loop
         END
      END -- Current task from PND and PickMethod = FP

      -- The first task is found, populate the candidate task variables
      IF @cCandidateTaskDetailKey = ''
      BEGIN
         SELECT 
            @cCandidateTaskDetailKey = @cTaskDetailKey,
            @cCandidateTaskType = @cTaskType,
            @cCandidateToLoc = @cToLOC,
            @cCandidateFinalLoc = @cFinalLoc,
            @cCandidateFromLocationCategory = @cFromLocationCategory,
            @cCandidateToLocationCategory = @cToLocationCategory,
            @cCandidatePutawayZone = @cPutawayZone

         BEGIN TRY
            UPDATE @tTaskCandidate SET Status = '3' WHERE TaskDetailKey = @cCandidateTaskDetailKey
         END TRY
         BEGIN CATCH
            SET @nContinue = 3
            SET @n_err = 239810
            SET @c_errmsg = rdt.rdtgetmessage( @n_err, @cLangCode, 'DSP') --Populate @tTaskCandidate Fail
            GOTO Fail
         END CATCH

         IF @bDebug = 1
         BEGIN
            SET @cLogMsg = CONCAT_WS(',', 'Loop @tTaskCandidate - 1',
                                       'Task found, marked as 3:' + @cCandidateTaskDetailKey,
                                       '@cCandidateTaskType: ' + ISNULL(@cCandidateTaskType, ''),
                                       '@cCandidateToLoc: ' + ISNULL(@cCandidateToLoc, ''),
                                       '@cCandidateFinalLoc: ' + ISNULL(@cCandidateFinalLoc, ''),
                                       '@cCandidateFromLocationCategory: ' + ISNULL(@cCandidateFromLocationCategory, ''),
                                       '@cCandidateToLocationCategory: ' + ISNULL(@cCandidateToLocationCategory, ''),
                                       '@cCandidatePutawayZone: ' + ISNULL(@cCandidatePutawayZone, '')
                                    )
            PRINT @cLogMsg
         END

         --Remove tasks that are not in the same putaway zone as the candidate task
         DELETE FROM @tTaskCandidate
         WHERE PutawayZone <> @cCandidatePutawayZone

         IF @bDebug = 1
         BEGIN
            SET @cLogMsg = CONCAT_WS(',', 'Remove tasks that are not in the same putaway zone as the candidate task',
                                       '@cCandidatePutawayZone: ' + ISNULL(@cCandidatePutawayZone, '')
                                    )
            PRINT @cLogMsg
         END

         -- If task is "FP", stop searching for other tasks
         IF @cPickMethod = 'FP'
         BEGIN
            IF @bDebug = 1
            BEGIN
               SET @cLogMsg = CONCAT_WS(',', 'Stop searching other task',
                                          'Pickmethod is FP'
                                       )
               PRINT @cLogMsg
            END
            BREAK
         END

         IF ISNULL(@cTaskDetailOrderKey, '') = ''
         BEGIN
            IF @bDebug = 1
            BEGIN
               SET @cLogMsg = CONCAT_WS(',', 'Orderkey is not retrieved from @tTaskCandidate, try to get it from PickDetail', '')
               PRINT @cLogMsg
            END
            -- If task is "PP", then search other tasks for the same order in the same putaway zone must be having status 0 (or 3 if assigned to the same user) to be suggested
            IF @cTaskType IN ('FCP', 'FCP1')
            BEGIN
               SELECT @cCandidateOrderKey = PD.OrderKey
               FROM dbo.PickDetail PD WITH(NOLOCK)
               INNER JOIN dbo.TaskDetail TD WITH(NOLOCK) ON PD.StorerKey = TD.StorerKey AND PD.TaskDetailKey = TD.TaskDetailKey
               WHERE TD.TaskDetailKey = @cTaskDetailKey
                  AND PD.StorerKey = @cStorerKey

               IF @bDebug = 1
               BEGIN
                  SET @cLogMsg = CONCAT_WS(',', 'Found task type is ', @cTaskType,
                                             'find @cCandidateOrderKey', @cCandidateOrderKey
                                          )
                  PRINT @cLogMsg
               END
            END
            ELSE IF @cTaskType IN ('RPF', 'RP1')
            BEGIN
               SELECT TOP 1 
                  @cCandidateOrderKey = OrderKey
               FROM (
                  SELECT PD.OrderKey, TD.Priority, ORM.DeliveryDate, TD.TaskDetailKey, CLK.Long,
                     ROW_NUMBER() OVER ( PARTITION BY ORM.OrderKey ORDER BY 
                              CASE 
                                 WHEN CLK.UDF02 = ORM.Priority THEN 1
                                 WHEN CLK.UDF03 = ORM.OrderGroup THEN 2
                                 ELSE 3
                              END
                     ) AS ROW_INDEX
                  FROM dbo.TaskDetail TD WITH(NOLOCK)
                  INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON PD.StorerKey = TD.StorerKey AND PD.TaskDetailKey = TD.TaskDetailKey
                  INNER JOIN dbo.ORDERS ORM WITH(NOLOCK) ON PD.StorerKey = ORM.StorerKey AND PD.OrderKey = ORM.OrderKey
                  INNER JOIN dbo.CODELKUP CLK WITH(NOLOCK) ON ORM.Type = CLK.code2 AND (CLK.UDF02 = '' OR CLK.UDF02 = ORM.Priority) AND (CLK.UDF03 = '' OR CLK.UDF03 = ORM.OrderGroup)
                  WHERE TD.StorerKey = @cStorerKey
                     AND TD.TaskType IN ('FCP', 'FCP1')
                     --AND TD.FromLoc = @cCandidateFinalLoc
                     --AND TD.Status = '0'
                     AND TD.RefTaskKey = @cCandidateTaskDetailKey --V1.0.1(4)
                     AND TD.Status IN ('0','S') --V1.0.1(4)
                     AND CLK.LISTNAME = 'JCBORDPR'
                  ) AS T1
               WHERE T1.ROW_INDEX = 1
               ORDER BY Priority, DATEADD( hh, ISNULL(CAST(Long AS INT), 0), DeliveryDate), TaskDetailKey

               IF @bDebug = 1
               BEGIN
                  SET @cLogMsg = CONCAT_WS(',', 'Found task type is ', @cTaskType,
                                             'find @cCandidateOrderKey', @cCandidateOrderKey,
                                             '@cCandidateFinalLoc', @cCandidateFinalLoc
                                          )
                  PRINT @cLogMsg
               END
            END
         END
         ELSE
         BEGIN
            IF @bDebug = 1
            BEGIN
               SET @cLogMsg = CONCAT_WS(',', 'Orderkey is retrieved from @tTaskCandidate, no need to search it again', @cTaskDetailOrderKey
                                       )
               PRINT @cLogMsg
            END
            SET @cCandidateOrderKey = @cTaskDetailOrderKey
         END
      END --Candidate taks is empty
      ELSE
      BEGIN
         --CandidateTaskDetailKey empty means a task is found, now continue to loop list to make the qualified tasks will be locked for the same user
         -- If task is "PP", then all other tasks for the same order in the same putaway zone must be having status 0 (or 3 if assigned to the same user) to be suggested
         IF @cPickMethod = 'PP' AND ISNULL(@cCandidateOrderKey, '') <> ''
         BEGIN
            IF @cTaskType IN ('FCP', 'FCP1') 
            BEGIN
               SELECT @cOrderKey = PD.OrderKey
               FROM dbo.PickDetail PD WITH(NOLOCK)
               INNER JOIN dbo.TaskDetail TD WITH(NOLOCK) ON PD.StorerKey = TD.StorerKey AND PD.TaskDetailKey = TD.TaskDetailKey
               WHERE TD.TaskDetailKey = @cTaskDetailKey
               AND PD.StorerKey = @cStorerKey

               IF @bDebug = 1
               BEGIN
                  SET @cLogMsg = CONCAT_WS(',', 'Try to lock current task',
                                             '@cTaskType', @cTaskType,
                                             '@cCandidateOrderKey', @cCandidateOrderKey,
                                             'Current order key', @cOrderKey
                                          )
                  PRINT @cLogMsg
               END

               -- If the order key or PutawayZone is not the same as the candidate order key, PutawayZone, skip the task
               IF @cOrderKey <> @cCandidateOrderKey OR @cCandidatePutawayZone <> @cPutawayZone
               BEGIN
                  IF @bDebug = 1
                  BEGIN
                     SET @cLogMsg = CONCAT_WS(',', 'OrderKey or PutawayZone does not match, so do not lock this task',
                                                '@cCandidateOrderKey', @cCandidateOrderKey,
                                                'Current order key', @cOrderKey,
                                                '@cCandidatePutawayZone', @cCandidatePutawayZone,
                                                'Current PutawayZone', @cPutawayZone
                                             )
                     PRINT @cLogMsg
                  END
                  
                  CONTINUE
               END
            END
            ELSE IF @cTaskType IN ('RPF', 'RP1')
            BEGIN
               -- Check if any pick task is associated with the candidate order key
               SELECT @nRowCount = COUNT(1)
               FROM dbo.TaskDetail TD WITH(NOLOCK)
               INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON TD.StorerKey = PD.StorerKey AND TD.TaskDetailKey = PD.TaskDetailKey
               WHERE TD.StorerKey = @cStorerKey
                 AND TD.TaskType IN ('FCP', 'FCP1')
                 --AND TD.FromLoc = @cFinalLOC
                 AND TD.RefTaskKey = @cTaskDetailKey --V1.0.1(4)
                 AND TD.Status = '0'
                 AND PD.OrderKey = @cCandidateOrderKey

               IF @bDebug = 1
               BEGIN
                  SET @cLogMsg = CONCAT_WS(',', 'Try to lock current task',
                                             '@cTaskType', @cTaskType,
                                             '@cCandidateOrderKey', @cCandidateOrderKey
                                          )
                  PRINT @cLogMsg
               END

               IF @nRowCount = 0 OR @cCandidatePutawayZone <> @cPutawayZone
               BEGIN
                  IF @bDebug = 1
                  BEGIN
                     SET @cLogMsg = CONCAT_WS(',', 'OrderKey or PutawayZone does not match, so do not lock this task',
                                                '@cCandidatePutawayZone', @cCandidatePutawayZone,
                                                'Current PutawayZone', @cPutawayZone
                                             )
                     PRINT @cLogMsg
                  END
                  CONTINUE
               END
            END

            -- Update the task as assigned to the user
            UPDATE @tTaskCandidate SET Status = '3' WHERE TaskDetailKey = @cTaskDetailKey

            IF @bDebug = 1
            BEGIN
               SET @cLogMsg = CONCAT_WS(',', 'Lock this task, same putawayzone and orderky as candidate order', ''
                                       )
               PRINT @cLogMsg
            END
         END
      END --Candidate task is found
   END --END while

   -- Update ListKey for the tasks that are RPF, RP1, FCP or FCP1
   DECLARE @cTaskDetailKeyTemp   NVARCHAR(10)
   SET @cTaskDetailKeyTemp = ''

   BEGIN TRY
      UPDATE @tTaskCandidate
      SET ListKey = ''
      FROM @tTaskCandidate

      SET @cTaskDetailKeyTemp = ''
      -- Get the first task detail key for RPF tasks
      SELECT TOP 1 @cTaskDetailKeyTemp = TaskDetailKey 
      FROM @tTaskCandidate 
      WHERE TaskType = 'RPF' AND Status = '3'
      ORDER BY RowIndex

      UPDATE @tTaskCandidate
      SET ListKey = TaskDetailKey
      FROM @tTaskCandidate
      WHERE TaskDetailKey = ISNULL(@cTaskDetailKeyTemp, '')

      SET @cTaskDetailKeyTemp = ''
       -- Get the first task detail key for RPF1 tasks
      SELECT TOP 1 @cTaskDetailKeyTemp = TaskDetailKey 
      FROM @tTaskCandidate 
      WHERE TaskType = 'RP1' AND Status = '3'
      ORDER BY RowIndex

      UPDATE @tTaskCandidate
      SET ListKey = TaskDetailKey
      FROM @tTaskCandidate
      WHERE TaskDetailKey = ISNULL(@cTaskDetailKeyTemp, '')

      SET @cTaskDetailKeyTemp = ''
      -- Get the first task detail key for FCP tasks
      SELECT TOP 1 @cTaskDetailKeyTemp = TaskDetailKey 
      FROM @tTaskCandidate 
      WHERE TaskType = 'FCP' AND Status = '3'
      ORDER BY RowIndex

      UPDATE @tTaskCandidate
      SET ListKey = TaskDetailKey
      FROM @tTaskCandidate
      WHERE TaskDetailKey = ISNULL(@cTaskDetailKeyTemp, '')

      SET @cTaskDetailKeyTemp = ''
      -- Get the first task detail key for FCP1 tasks
      SELECT TOP 1 @cTaskDetailKeyTemp = TaskDetailKey 
      FROM @tTaskCandidate 
      WHERE TaskType = 'FCP1' AND Status = '3'
      ORDER BY RowIndex

      UPDATE @tTaskCandidate
      SET ListKey = TaskDetailKey
      FROM @tTaskCandidate
      WHERE TaskDetailKey = ISNULL(@cTaskDetailKeyTemp, '')
   END TRY
   BEGIN CATCH
      SET @nContinue = 3
      SET @n_err = 239811
      SET @c_errmsg = rdt.rdtgetmessage( @n_err, @cLangCode, 'DSP') --Update @tTaskCandidate Fail
      GOTO Fail
   END CATCH

   IF @bDebug = 1
   BEGIN
      SELECT 'Locked candidate tasks in @tTaskCandidate', * FROM @tTaskCandidate
   END

   BEGIN TRY
      UPDATE TD WITH(ROWLOCK)
      SET 
         TD.UserKey = @c_UserID,
         TD.Status = '3',
         TD.ListKey = TC.ListKey,
         TD.StartTime  = CURRENT_TIMESTAMP,
         TD.EditDate = CURRENT_TIMESTAMP,
         TD.EditWho = @c_UserID,
         TD.Groupkey = FORMAT(GETDATE(), 'ddMMyyHHmm'),
         TD.TrafficCop = NULL,
		 TD.StatusMsg = ''
      FROM dbo.TaskDetail TD
      INNER JOIN @tTaskCandidate TC ON TD.TaskDetailKey = TC.TaskDetailKey
      WHERE TD.StorerKey = @cStorerKey
      AND TD.TaskType IN ('RPF', 'RP1', 'FCP', 'FCP1')
      AND TC.Status = '3'
      AND TD.Status IN ('0', '3')
   END TRY
   BEGIN CATCH
      SET @nContinue = 3
      SET @n_err = 239801
      SET @c_errmsg = rdt.rdtgetmessage( @n_err, @cLangCode, 'DSP') --Update TaskDetail Fail
      GOTO Fail
   END CATCH

   IF @bDebug = 1
   BEGIN
      SELECT 'Locked candidate tasks in TaskDetail', * 
      FROM dbo.TaskDetail WITH(NOLOCK) 
      WHERE StorerKey = @cStorerKey
         AND TaskType IN ('RPF', 'RP1', 'FCP', 'FCP1')
         AND Status = '3'
         AND UserKey = @c_UserID
   END

   SET @c_TaskDetailKey = ISNULL(@cCandidateTaskDetailKey, '')

   IF @bDebug = 1
   BEGIN
      SET @cLogMsg = CONCAT_WS(',', 'Return candidate task detail key', @cCandidateTaskDetailKey
                                       )
               PRINT @cLogMsg
   END

   GOTO Quit

Fail:
   SET @nContinue = 3

Quit:
   IF @nContinue=3 -- Error Occured - Process And Return
   BEGIN
      SELECT @b_Success = 0
      RAISERROR (@n_err ,10 ,1) WITH SETERROR
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
GRANT EXECUTE ON nspTTMEvaluateRPFFCPTasks_JCB TO nSQL
GO
