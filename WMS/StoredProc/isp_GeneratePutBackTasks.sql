SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Stored Procedure: isp_GeneratePutBackTasks                              */
/* Copyright: MAERSK                                                       */
/*                                                                         */
/* Purpose: FCR-8087 - SKU Consolidation                                   */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author     Ver   Purpose                                   */
/* 18-OCT-2025  USH022     1.0   FCR-8087 SKU Consolidation                */
/* 30-DEC-2025  Michael    1.1   FCR-8087 Fine tunning                     */
/* 27-APR-2026  Michael    1.2   FCR-8087 New requirement FBR V1.8         */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[isp_GeneratePutBackTasks]
(
   @c_Zone01    NVARCHAR(10)  = NULL
 , @c_Zone02    NVARCHAR(10)  = NULL
 , @c_Zone03    NVARCHAR(10)  = NULL
 , @c_Zone04    NVARCHAR(10)  = NULL
 , @c_Zone05    NVARCHAR(10)  = NULL
 , @c_Zone06    NVARCHAR(10)  = NULL
 , @c_Zone07    NVARCHAR(10)  = NULL
 , @c_Zone08    NVARCHAR(10)  = NULL
 , @c_Zone09    NVARCHAR(10)  = NULL
 , @c_Zone10    NVARCHAR(10)  = NULL
 , @c_Zone11    NVARCHAR(10)  = NULL
 , @c_Zone12    NVARCHAR(10)  = NULL
 , @c_ReplGrp   NVARCHAR(10)  = 'ALL'
 , @c_Storerkey NVARCHAR(15)
 , @c_ReplenType NVARCHAR(10) = 'T' -- R=Replenishment, T=TaskManager
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_starttcnt      INT = @@TRANCOUNT

   DECLARE
        @c_Facility          NVARCHAR(10)  = ISNULL(@c_Zone01,'')
      , @c_SourceType        NVARCHAR(30)  = 'isp_GeneratePutBackTasks'
      , @c_TaskType          NVARCHAR(10)  = ''
      , @c_Clear_SourceType  NVARCHAR(250) = ''
      , @c_Clear_TaskType    NVARCHAR(250) = ''
      , @c_PickMethod        NVARCHAR(10)  = ''
      , @c_UOM               NVARCHAR(5)   = ''
      , @c_Priority          NVARCHAR(10)  = ''
      , @c_GroupKey          NVARCHAR(10)  = ''
      , @c_SelectFlag        NVARCHAR(1)   = ''
      , @c_CartonType        NVARCHAR(10)  = ''
      , @c_NoCommingleSku    NVARCHAR(10)  = ''
      , @c_MoveAllocQty      NVARCHAR(10)  = ''
      , @c_MovePickedQty     NVARCHAR(10)  = ''
      , @c_TaskFilterZone    NVARCHAR(10)  = ''
      , @c_DynPick_LocType   NVARCHAR(10)  = ''
      , @n_DftCartonCube     FLOAT         = 0
      , @n_DftSkuStdCube     FLOAT         = 0
      , @n_LocTolerance      FLOAT         = 0
      , @n_CtnCubeFactor     FLOAT         = 1
      , @c_ToPKLoc_Cond_Exp  NVARCHAR(MAX) = ''
      , @c_ToDPLoc_Cond_Exp  NVARCHAR(MAX) = ''
      , @c_ToPKLoc_Sort_Exp  NVARCHAR(MAX) = ''
      , @c_ToDPLoc_Sort_Exp  NVARCHAR(MAX) = ''
      , @c_TaskDetailKey     NVARCHAR(10)  = ''
      , @n_debug             INT           = 0
      , @n_continue          INT           = 1
      , @b_success           INT           = 0
      , @n_err               INT           = 0
      , @c_errmsg            NVARCHAR(255) = ''
      , @c_SQL               NVARCHAR(MAX) = ''
      , @c_SQL_Zones         NVARCHAR(MAX) = ''
      , @c_SQL_Rule1         NVARCHAR(MAX) = ''
      , @c_SQL_Rule2         NVARCHAR(MAX) = ''
      , @c_Params_FindToLoc  NVARCHAR(MAX) = ''
      , @n_CartonCube        BIGINT        = ''
      , @c_Sku               NVARCHAR(20)  = ''
      , @c_FromLoc           NVARCHAR(10)  = ''
      , @c_ToLoc             NVARCHAR(10)  = ''
      , @c_Lot               NVARCHAR(10)  = ''
      , @n_Qty               INT           = 0
      , @c_FromLogicalLoc    NVARCHAR(10)  = ''
      , @c_ToLogicalLoc      NVARCHAR(10)  = ''
      , @c_FromID            NVARCHAR(20)  = ''
      , @c_ToID              NVARCHAR(20)  = ''
      , @c_FromLocType       NVARCHAR(10)  = ''
      , @c_FromAisle         NVARCHAR(10)  = ''
      , @c_FromBay           NVARCHAR(10)  = ''
      , @c_FromPAZone        NVARCHAR(10)  = ''
      , @c_PickAisle         NVARCHAR(10)  = ''
      , @c_PickBay           NVARCHAR(10)  = ''
      , @c_PickLoc           NVARCHAR(10)  = ''
      , @c_PickLogicalLoc    NVARCHAR(10)  = ''
      , @c_SkuClass          NVARCHAR(10)  = ''
      , @c_SkuStyle          NVARCHAR(20)  = ''
      , @c_StylePickAisle    NVARCHAR(10)  = ''
      , @c_StylePickLoc      NVARCHAR(10)  = ''
      , @c_StylePickLgLoc    NVARCHAR(10)  = ''
      , @n_SkuStdCube        FLOAT         = 0
      , @c_PrevStorerkey     NVARCHAR(15)  = ''
      , @c_ReplenishmentKey  NVARCHAR(10)  = ''
      , @c_Packkey           NVARCHAR(10)  = ''
      , @n_SeqNo             INT           = 0


   ----------------------------------------------------------------
   -- Step 1: Prepare temp tables
   ----------------------------------------------------------------
   IF OBJECT_ID('tempdb..#TEMP_UsedFromLoc') IS NOT NULL
      DROP TABLE #TEMP_UsedFromLoc
   IF OBJECT_ID('tempdb..#TEMP_UsedToLoc') IS NOT NULL
      DROP TABLE #TEMP_UsedToLoc
   IF OBJECT_ID('tempdb..#TEMP_CandidateSKUs') IS NOT NULL
      DROP TABLE #TEMP_CandidateSKUs
   IF OBJECT_ID('tempdb..#TEMP_DPLOC') IS NOT NULL
      DROP TABLE #TEMP_DPLOC
   IF OBJECT_ID('tempdb..#TEMP_FROMLOC') IS NOT NULL
      DROP TABLE #TEMP_FROMLOC
   IF OBJECT_ID('tempdb..#TEMP_TASK') IS NOT NULL
      DROP TABLE #TEMP_TASK

   CREATE TABLE #TEMP_UsedFromLoc (
      Loc NVARCHAR(10) PRIMARY KEY
   )
   CREATE TABLE #TEMP_UsedToLoc (
      Loc NVARCHAR(10) PRIMARY KEY
   )
   CREATE TABLE #TEMP_CandidateSKUs (
      Storerkey      NVARCHAR(15)
    , SKU            NVARCHAR(20)
   )
   CREATE TABLE #TEMP_DPLOC (
      Loc             NVARCHAR(10) PRIMARY KEY
   )
   CREATE TABLE #TEMP_FROMLOC (
      SeqNo          INT IDENTITY(1,1) PRIMARY KEY
    , FromLoc        NVARCHAR(10) NULL
    , Qty            INT          NULL
    , FromLogicalLoc NVARCHAR(10) NULL
    , Lot            NVARCHAR(10) NULL
    , FromID         NVARCHAR(20) NULL
    , FromLocType    NVARCHAR(10) NULL
    , FromAisle      NVARCHAR(10) NULL
    , FromBay        NVARCHAR(10) NULL
    , FromPAZone     NVARCHAR(10) NULL
   )
   CREATE TABLE #TEMP_TASK (
      RowNo          INT IDENTITY(1,1) PRIMARY KEY
    , TaskType       NVARCHAR(10) NULL
    , Storerkey      NVARCHAR(15) NULL
    , Sku            NVARCHAR(20) NULL
    , Lot            NVARCHAR(10) NULL
    , Qty            INT          NULL
    , FromLoc        NVARCHAR(10) NULL
    , FromLogicalLoc NVARCHAR(10) NULL
    , FromID         NVARCHAR(20) NULL
    , ToLoc          NVARCHAR(10) NULL
    , ToLogicalLoc   NVARCHAR(10) NULL
    , ToID           NVARCHAR(20) NULL
    , UOM            NVARCHAR(10) NULL
    , PackKey        NVARCHAR(10) NULL
    , Priority       NVARCHAR(10) NULL
    , PickMethod     NVARCHAR(10) NULL
    , SourceType     NVARCHAR(30) NULL
    , GroupKey       NVARCHAR(10) NULL
    , AddDate        DATETIME DEFAULT (GETDATE())
    , SelectFlag     NVARCHAR(1)  NULL
   )

   -- Optional zone filters if provided (these are appended to the WHERE clause)
   SET @c_SQL_Zones = ''
   IF ISNULL(@c_Zone02,'') <> 'ALL'
      SET @c_SQL_Zones += N' AND LOC.PutawayZone IN ('
                  + '''' + ISNULL(REPLACE(RTRIM(@c_Zone02),'''',''''''),'') + ''','
                  + '''' + ISNULL(REPLACE(RTRIM(@c_Zone03),'''',''''''),'') + ''','
                  + '''' + ISNULL(REPLACE(RTRIM(@c_Zone04),'''',''''''),'') + ''','
                  + '''' + ISNULL(REPLACE(RTRIM(@c_Zone05),'''',''''''),'') + ''','
                  + '''' + ISNULL(REPLACE(RTRIM(@c_Zone06),'''',''''''),'') + ''','
                  + '''' + ISNULL(REPLACE(RTRIM(@c_Zone07),'''',''''''),'') + ''','
                  + '''' + ISNULL(REPLACE(RTRIM(@c_Zone08),'''',''''''),'') + ''','
                  + '''' + ISNULL(REPLACE(RTRIM(@c_Zone09),'''',''''''),'') + ''')'

   IF ISNULL(@c_Zone10,'') NOT IN ('', 'ALL')
      SET @c_SQL_Zones += N' AND LOC.LocAisle = ''' + ISNULL(REPLACE(@c_Zone10,'''',''''''),'') + ''''

   IF ISNULL(@c_Zone11,'') NOT IN ('', 'ALL')
      SET @c_SQL_Zones += N' AND LOC.LocBay = ''' + ISNULL(REPLACE(@c_Zone11,'''',''''''),'') + ''''

   IF ISNULL(@c_Zone12,'') <> '' AND TRY_PARSE(ISNULL(@c_Zone12,'') AS INT) IS NOT NULL
      SET @c_SQL_Zones += N' AND LOC.LocLevel = ' + CONVERT(NVARCHAR(10), ISNULL(TRY_PARSE(ISNULL(@c_Zone12,'''') AS INT),0))

   ----------------------------------------------------------------
   -- Step 2: Build list of SKUs that exist in more than one location
   ----------------------------------------------------------------
   SET @c_SQL = N'INSERT INTO #TEMP_CandidateSKUs (Storerkey, Sku)'
     +' SELECT SL2.Storerkey, SL2.Sku'
     +' FROM dbo.SKUxLOC SL2 WITH(NOLOCK)'
     +' JOIN dbo.LOC LOC2 WITH (NOLOCK) ON SL2.Loc = LOC2.Loc'
     +' JOIN ('
     +   ' SELECT DISTINCT SL.StorerKey, SL.Sku'
     +     ' FROM dbo.SKUxLOC SL WITH (NOLOCK)'
     +     ' JOIN dbo.LOC LOC WITH (NOLOCK) ON SL.Loc = LOC.Loc'
     +    ' WHERE LOC.Facility = ''' + ISNULL(REPLACE(@c_Facility,'''',''''''),'') + ''''

   IF ISNULL(@c_Storerkey,'') <> 'ALL'
      SET @c_SQL += ' AND SL.StorerKey = ''' + ISNULL(REPLACE(@c_Storerkey,'''',''''''),'') + ''''

   IF ISNULL(@c_SQL_Zones,'') <> ''
      SET @c_SQL = @c_SQL + @c_SQL_Zones

   SET @c_SQL = @c_SQL
     + ') X ON SL2.Storerkey = X.Storerkey AND SL2.Sku = X.Sku'
     +' OUTER APPLY (SELECT TOP 1 LocType = RTRIM(Long) FROM CODELKUP a(NOLOCK)'
     +    ' WHERE a.Listname=''REPLENCFG'' AND a.Code=''DynPick_LocType'' AND a.Code2=''isp_GeneratePutBackTasks'' AND a.Storerkey=SL2.Storerkey'
     +' ) DP'
     +' WHERE (SL2.LocationType = ''PICK'''
     +    ' OR (SL2.Qty > 0 AND LOC2.LocationType = ISNULL(NULLIF(DP.LocType,''''),''DYNPPICK'')))'
     + ' GROUP BY SL2.StorerKey, SL2.SKU'
     +' HAVING COUNT(DISTINCT SL2.LOC) > 1'

   EXEC (@c_SQL)

   SET @c_Params_FindToLoc
     = N'@c_Facility       NVARCHAR(5)'
     + ',@c_Storerkey      NVARCHAR(15)'
     + ',@c_Sku            NVARCHAR(20)'
     + ',@c_FromLoc        NVARCHAR(10)'
     + ',@c_FromLogicalLoc NVARCHAR(10)'
     + ',@c_FromLocType    NVARCHAR(10)'
     + ',@c_FromAisle      NVARCHAR(10)'
     + ',@c_FromBay        NVARCHAR(10)'
     + ',@c_FromPAZone     NVARCHAR(10)'
     + ',@c_FromID         NVARCHAR(20)'
     + ',@c_Lot            NVARCHAR(10)'
     + ',@n_Qty            INT'
     + ',@c_ReplenType     NVARCHAR(10)'
     + ',@n_CartonCube     FLOAT'
     + ',@n_SkuStdCube     FLOAT'
     + ',@n_LocTolerance   FLOAT'
     + ',@c_NoCommingleSku NVARCHAR(10)'
     + ',@c_PickAisle      NVARCHAR(10)'
     + ',@c_PickBay        NVARCHAR(10)'
     + ',@c_PickLoc        NVARCHAR(10)'
     + ',@c_PickLogicalLoc NVARCHAR(10)'
     + ',@c_SkuClass       NVARCHAR(10)'
     + ',@c_SkuStyle       NVARCHAR(20)'
     + ',@c_StylePickAisle NVARCHAR(10)'
     + ',@c_StylePickLoc   NVARCHAR(10)'
     + ',@c_StylePickLgLoc NVARCHAR(10)'
     + ',@c_ToLoc          NVARCHAR(10) OUTPUT'
     + ',@c_ToLogicalLoc   NVARCHAR(10) OUTPUT'

   ----------------------------------------------------------------
   -- Step 3: Process SKUs
   ----------------------------------------------------------------
   DECLARE CUR_SKU CURSOR LOCAL FAST_FORWARD FOR
   SELECT Storerkey, SKU
     FROM #TEMP_CandidateSKUs
    ORDER BY 1,2

   OPEN CUR_SKU

   SET @c_PrevStorerkey = NULL

   WHILE @n_continue IN (1,2)
   BEGIN
      FETCH NEXT FROM CUR_SKU INTO @c_Storerkey, @c_Sku

      IF @@FETCH_STATUS <> 0
         BREAK

      IF ISNULL(@c_Storerkey,'') <> ISNULL(@c_PrevStorerkey,'') OR @c_PrevStorerkey IS NULL
      BEGIN
         SET @c_PrevStorerkey = ISNULL(@c_Storerkey,'')

         SELECT @c_TaskType           = ISNULL(RTRIM(MAX(CASE WHEN Code='TaskType'           THEN Long END)), 'PUTBACK')
              , @c_Clear_SourceType   = ISNULL(RTRIM(MAX(CASE WHEN Code='Clear_SourceType'   THEN Long END)), ''       )   -- allow multi value seperated by comma
              , @c_Clear_TaskType     = ISNULL(RTRIM(MAX(CASE WHEN Code='Clear_TaskType'     THEN Long END)), ''       )   -- allow multi value seperated by comma
              , @c_PickMethod         = ISNULL(RTRIM(MAX(CASE WHEN Code='PickMethod'         THEN Long END)), 'PP'     )
              , @c_UOM                = ISNULL(RTRIM(MAX(CASE WHEN Code='UOM'                THEN Long END)), '6'      )
              , @c_Priority           = ISNULL(RTRIM(MAX(CASE WHEN Code='Priority'           THEN Long END)), '5'      )
              , @c_GroupKey           = ISNULL(RTRIM(MAX(CASE WHEN Code='GroupKey'           THEN Long END)), ''       )
              , @c_CartonType         = ISNULL(RTRIM(MAX(CASE WHEN Code='CartonType'         THEN Long END)), 'RS8'    )
              , @c_NoCommingleSku     = ISNULL(RTRIM(MAX(CASE WHEN Code='NoCommingleSku'     THEN Long END)), '1'      )
              , @c_MoveAllocQty       = ISNULL(RTRIM(MAX(CASE WHEN Code='MoveAllocQty'       THEN Long END)), '0'      )
              , @c_MovePickedQty      = ISNULL(RTRIM(MAX(CASE WHEN Code='MovePickedQty'      THEN Long END)), '0'      )
              , @c_TaskFilterZone     = ISNULL(RTRIM(MAX(CASE WHEN Code='TaskFilterZone'     THEN Long END)), ''       )
              , @c_DynPick_LocType    = ISNULL(NULLIF(RTRIM(MAX(CASE WHEN Code='DynPick_LocType'    THEN Long END)),''), 'DYNPPICK')
              , @n_DftCartonCube      = ISNULL(TRY_PARSE(ISNULL(MAX(CASE WHEN Code='DftCartonCube' THEN Long END),'') AS FLOAT), 50020)
              , @n_DftSkuStdCube      = ISNULL(TRY_PARSE(ISNULL(MAX(CASE WHEN Code='DftSkuStdCube' THEN Long END),'') AS FLOAT), 1000 )
              , @n_LocTolerance       = ISNULL(TRY_PARSE(ISNULL(MAX(CASE WHEN Code='LocTolerance'  THEN Long END),'') AS FLOAT), 1.2  )
              , @n_CtnCubeFactor      = ISNULL(TRY_PARSE(ISNULL(MAX(CASE WHEN Code='CtnCubeFactor' THEN Long END),'') AS FLOAT), 1)
              , @c_ToPKLoc_Cond_Exp   = ISNULL(TRIM(MAX(CASE WHEN Code='ToPickLoc_Condition' THEN Notes END)), '')
              , @c_ToPKLoc_Sort_Exp   = ISNULL(TRIM(MAX(CASE WHEN Code='ToPickLoc_Sort'      THEN Notes END)), '')
              , @c_ToDPLoc_Cond_Exp   = ISNULL(TRIM(MAX(CASE WHEN Code='ToDPLoc_Condition'   THEN Notes END)), '')
              , @c_ToDPLoc_Sort_Exp   = ISNULL(TRIM(MAX(CASE WHEN Code='ToDPLoc_Sort'        THEN Notes END)), '')
           FROM dbo.CODELKUP WITH(NOLOCK)
          WHERE ListName = 'REPLENCFG'
            AND Code2 = 'isp_GeneratePutBackTasks'
            AND Storerkey = @c_Storerkey

         IF LEFT(@c_ToPKLoc_Cond_Exp,4) = 'AND '
            SET @c_ToPKLoc_Cond_Exp = TRIM(SUBSTRING(@c_ToPKLoc_Cond_Exp,5,LEN(@c_ToPKLoc_Cond_Exp)))

         IF LEFT(@c_ToDPLoc_Cond_Exp,4) = 'AND '
            SET @c_ToDPLoc_Cond_Exp = TRIM(SUBSTRING(@c_ToDPLoc_Cond_Exp,5,LEN(@c_ToDPLoc_Cond_Exp)))

         -- Prepare Dynamic Pick Loc
         TRUNCATE TABLE #TEMP_DPLOC

         INSERT INTO #TEMP_DPLOC(Loc)
         SELECT Loc
           FROM dbo.LOC WITH (NOLOCK)
          WHERE Facility = @c_Facility
            AND LocationType = @c_DynPick_LocType

         -- Prepare Carton Cube
         SET @n_CartonCube = @n_DftCartonCube

         IF ISNULL(@n_CtnCubeFactor,0) = 0
            SET @n_CtnCubeFactor = 1

         SELECT TOP 1 @n_CartonCube = ISNULL(NULLIF(C.CUBE,0), @n_CartonCube)
           FROM dbo.Cartonization C WITH (NOLOCK)
           LEFT JOIN dbo.STORER   S WITH (NOLOCK) ON C.CartonizationGroup = S.CartonGroup AND S.Storerkey  = @c_Storerkey
          WHERE C.CartonType = @c_CartonType
          ORDER BY CASE WHEN S.Storerkey IS NOT NULL THEN 1 ELSE 2 END
                 , C.UseSequence

         SET @n_CartonCube = @n_CartonCube * @n_CtnCubeFactor

         -- Clear incomplete/pending putback tasks
         IF @c_ReplenType = 'R'
         BEGIN
            DECLARE CUR_REPLEN CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT R.ReplenishmentKey
              FROM dbo.REPLENISHMENT R
              JOIN dbo.LOC           LOC WITH(NOLOCK) ON R.FromLoc = LOC.Loc
             WHERE R.Confirmed = 'N'
               AND R.ReplenishmentGroup = 'PUTBACK'
               AND R.Storerkey = @c_Storerkey
               AND LOC.Facility = @c_Facility

            OPEN CUR_REPLEN

            WHILE 1=1
            BEGIN
               FETCH NEXT FROM CUR_REPLEN INTO @c_ReplenishmentKey

               IF @@FETCH_STATUS <> 0
                  BREAK

               DELETE dbo.REPLENISHMENT WITH (ROWLOCK)
               WHERE ReplenishmentKey = @c_ReplenishmentKey
                 AND Confirmed = 'N'
            END
            CLOSE CUR_REPLEN
            DEALLOCATE CUR_REPLEN
         END

         IF @c_ReplenType = 'T' OR
           (@c_ReplenType = 'R' AND ISNULL(@c_Clear_SourceType,'')<>'' AND ISNULL(@c_Clear_TaskType,'')<>'')
         BEGIN
            DECLARE CUR_TASK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT TD.TaskDetailKey
            FROM dbo.TASKDETAIL TD  WITH (NOLOCK)
            JOIN dbo.LOC        LOC WITH (NOLOCK) ON TD.FromLoc = LOC.Loc
            WHERE TD.Status IN ('0', '3')
              AND TD.StorerKey  = @c_Storerkey
              AND LOC.Facility  = @c_Facility
              AND CASE WHEN @c_ReplenType = 'R'
                       THEN IIF(EXISTS(SELECT TOP 1 1 FROM STRING_SPLIT(@c_Clear_SourceType,',') WHERE value<>'' AND value=TD.SourceType) AND
                                EXISTS(SELECT TOP 1 1 FROM STRING_SPLIT(@c_Clear_TaskType  ,',') WHERE value<>'' AND value=TD.TaskType), 1, 0)
                       ELSE IIF(TD.SourceType=@c_SourceType AND TD.TaskType=@c_TaskType, 1, 0)
                  END = 1

            OPEN CUR_TASK

            WHILE 1=1
            BEGIN
               FETCH NEXT FROM CUR_TASK INTO @c_TaskDetailKey

               IF @@FETCH_STATUS <> 0
                  BREAK

               DELETE FROM dbo.TASKDETAIL WITH (ROWLOCK)
               WHERE TaskDetailKey = @c_TaskDetailKey
                 AND Status IN ('0', '3')
            END
            CLOSE CUR_TASK
            DEALLOCATE CUR_TASK
         END

         -- Build SQL for Rule 1 (Fixed Pickface)
         SET @c_SQL_Rule1 = N'SELECT TOP 1'
           +    ' @c_ToLoc        = SL.Loc'
           +   ', @c_ToLogicalLoc = LOC.LogicalLocation'
           + ' FROM dbo.SKUxLOC         SL  WITH (NOLOCK)'
           + ' JOIN dbo.LOC             LOC WITH (NOLOCK) ON SL.Loc = LOC.Loc'
           + ' OUTER APPLY ('
           +    ' SELECT Qty          = SUM(Qty)'
           +          ', QtyAllocated = SUM(QtyAllocated)'
           +          ', QtyPicked    = SUM(QtyPicked)'
           +      ' FROM dbo.LOTxLOCxID a WITH(NOLOCK)'
           +     ' WHERE a.Storerkey = @c_Storerkey AND a.Sku = @c_Sku AND a.Loc = LOC.Loc'
           +  ') LLI'
           + ' OUTER APPLY ('
           +    ' SELECT PendingQty = SUM(Qty)'
           +      ' FROM #TEMP_TASK a'
           +     ' WHERE a.Storerkey = @c_Storerkey AND a.Sku = @c_Sku AND a.ToLoc = LOC.Loc'
           +  ') TS'
           +' WHERE LOC.Facility = @c_Facility'
           +  ' AND SL.StorerKey = @c_Storerkey'
           +  ' AND SL.Sku = @c_Sku'
           +  ' AND SL.LocationType = ''PICK'''
           +  ' AND SL.Loc NOT IN (SELECT Loc FROM #TEMP_UsedFromLoc)'
           +  ' AND SL.Loc <> @c_FromLoc'
           +  ' AND NOT EXISTS(SELECT TOP 1 1 FROM dbo.LOTxLOCxID a WITH (NOLOCK)'
           +         ' OUTER APPLY ('
           +            ' SELECT PendingQty = SUM(Qty)'
           +               ' FROM #TEMP_TASK c'
           +               ' WHERE c.Storerkey = a.Storerkey AND c.Sku = a.Sku AND c.Lot = a.Lot AND c.ToLoc = a.Loc AND c.ToID  = a.ID'
           +          ') d'
           +         ' WHERE a.Storerkey = SL.Storerkey AND a.Sku = SL.Sku AND a.Loc = SL.Loc'
           +         ' HAVING SUM(a.Qty - a.QtyPicked + ISNULL(d.PendingQty,0)) + @n_Qty > SL.QtyLocationLimit * @n_LocTolerance)'
           +  ' AND ((LOC.CommingleSku = ''1'' AND ISNULL(@c_NoCommingleSku,'''')<>''1'')'
           +    ' OR (NOT EXISTS(SELECT TOP 1 1 FROM LOTxLOCxID a WITH (NOLOCK)'
           +          ' OUTER APPLY ('
           +             ' SELECT PendingQty = SUM(Qty)'
           +                ' FROM #TEMP_TASK c'
           +                ' WHERE c.Storerkey = a.Storerkey AND c.Sku = a.Sku AND c.Lot = a.Lot AND c.ToLoc = a.Loc AND c.ToID  = a.ID'
           +           ') d'
           +          ' WHERE a.Loc = SL.Loc AND a.Qty - a.QtyPicked + ISNULL(d.PendingQty,0) > 0 AND a.Sku <> @c_Sku)'

         IF @c_ReplenType = 'R'
            SET @c_SQL_Rule1 = @c_SQL_Rule1
           +   ' AND NOT EXISTS(SELECT TOP 1 1 FROM dbo.Replenishment WITH (NOLOCK) WHERE ToLoc = LOC.Loc AND FromLoc<>'''' AND Sku <> @c_Sku AND ISNULL(Confirmed,'''')<>''Y'')'
         ELSE IF @c_ReplenType = 'T'
            SET @c_SQL_Rule1 = @c_SQL_Rule1
           +   ' AND NOT EXISTS(SELECT TOP 1 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE ToLoc = LOC.Loc AND FromLoc<>'''' AND Sku <> @c_Sku AND Status IN (''0'',''3''))'

         SET @c_SQL_Rule1 = @c_SQL_Rule1 + '))'

         IF ISNULL(@c_ToPKLoc_Cond_Exp,'')<>''
            SET @c_SQL_Rule1 = @c_SQL_Rule1 + ' AND (' + @c_ToPKLoc_Cond_Exp + ')'
         ELSE
            SET @c_SQL_Rule1 = @c_SQL_Rule1 + ' AND LOC.PutawayZone = @c_FromPAZone'

         IF ISNULL(@c_ToPKLoc_Sort_Exp,'')<>''
            SET @c_SQL_Rule1 = @c_SQL_Rule1 + ' ORDER BY ' + @c_ToPKLoc_Sort_Exp
         ELSE
            SET @c_SQL_Rule1 = @c_SQL_Rule1
              +' ORDER BY CASE WHEN SL.Loc = @c_PickLoc THEN 10 ELSE 20 END'
              +        ', CASE WHEN ISNULL(LLI.Qty,0)-ISNULL(LLI.QtyPicked,0)+ISNULL(TS.PendingQty,0)>0 THEN 10 ELSE 20 END'
              +        ', CASE WHEN LOC.LocAisle=@c_PickAisle THEN 10 ELSE 20 END'
              +        ', LOC.LogicalLocation'
              +        ', SL.Loc'

         -- Build SQL for Rule 2 (Dynamic Pick)
         SET @c_SQL_Rule2 = N'SELECT TOP 1'
           +    ' @c_ToLoc        = LOC.Loc'
           +   ', @c_ToLogicalLoc = LOC.LogicalLocation'
           + ' FROM #TEMP_DPLOC DPLOC'
           + ' JOIN dbo.LOC             LOC WITH (NOLOCK) ON DPLOC.Loc = LOC.Loc'
           + ' OUTER APPLY ('
           +    ' SELECT Qty          = SUM(a.Qty)'
           +          ', QtyAllocated = SUM(a.QtyAllocated)'
           +          ', QtyPicked    = SUM(a.QtyPicked)'
           +      ' FROM dbo.LOTxLOCxID a WITH(NOLOCK)'
           +     ' WHERE a.Storerkey = @c_Storerkey AND a.Sku = @c_Sku AND a.Loc = LOC.Loc'
           +  ') LLI'
           + ' OUTER APPLY ('
           +    ' SELECT PendingQty = SUM(a.Qty)'
           +      ' FROM #TEMP_TASK a'
           +     ' WHERE a.Storerkey = @c_Storerkey AND a.Sku = @c_Sku AND a.ToLoc = LOC.Loc'
           +  ') TS'
           +' WHERE LOC.Loc <> @c_FromLoc'
           +  ' AND LOC.Loc NOT IN (SELECT Loc FROM #TEMP_UsedFromLoc)'
           +  ' AND NOT EXISTS(SELECT TOP 1 1'
           +         ' FROM dbo.LOTxLOCxID a WITH (NOLOCK)'
           +         ' JOIN dbo.SKU        b WITH (NOLOCK) ON a.Storerkey = b.Storerkey AND a.Sku = b.Sku'
           +         ' OUTER APPLY ('
           +            ' SELECT PendingQty = SUM(Qty)'
           +               ' FROM #TEMP_TASK c'
           +               ' WHERE c.Storerkey = a.Storerkey AND c.Sku = a.Sku AND c.Lot = a.Lot AND c.ToLoc = a.Loc AND c.ToID  = a.ID'
           +          ') d'
           +         ' WHERE a.Loc = LOC.Loc'
           +           ' AND a.Qty - a.QtyPicked + ISNULL(d.PendingQty,0) > 0'
           +         ' HAVING SUM((a.Qty - a.QtyPicked + ISNULL(d.PendingQty,0)) * ISNULL(NULLIF(b.StdCube,0),@n_SkuStdCube)) + @n_Qty * @n_SkuStdCube'
           +              ' > @n_CartonCube * ISNULL(TRY_PARSE(ISNULL(LOC.LocationRoom,'''') AS FLOAT),1) * @n_LocTolerance'
           +       ')'
           +  ' AND ((LOC.CommingleSku = ''1'' AND ISNULL(@c_NoCommingleSku,'''')<>''1'')'
           +   ' OR (NOT EXISTS(SELECT TOP 1 1 FROM dbo.LOTxLOCxID a WITH (NOLOCK)'
           +         ' OUTER APPLY ('
           +            ' SELECT PendingQty = SUM(Qty)'
           +               ' FROM #TEMP_TASK c'
           +               ' WHERE c.Storerkey = a.Storerkey AND c.Sku = a.Sku AND c.Lot = a.Lot AND c.ToLoc = a.Loc AND c.ToID  = a.ID'
           +          ') d'
           +         ' WHERE a.Loc = LOC.Loc AND a.Qty - a.QtyPicked + ISNULL(d.PendingQty,0) > 0 AND Sku <> @c_Sku)'

         IF @c_ReplenType = 'R'
            SET @c_SQL_Rule2 = @c_SQL_Rule2
              +   ' AND NOT EXISTS(SELECT TOP 1 1 FROM dbo.Replenishment WITH (NOLOCK) WHERE ToLoc = LOC.Loc AND FromLoc<>'''' AND Sku <> @c_Sku AND ISNULL(Confirmed,'''')<>''Y'')'
         ELSE IF @c_ReplenType = 'T'
            SET @c_SQL_Rule2 = @c_SQL_Rule2
              +   ' AND NOT EXISTS(SELECT TOP 1 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE ToLoc = LOC.Loc AND FromLoc<>'''' AND Sku <> @c_Sku AND Status IN (''0'',''3''))'

         SET @c_SQL_Rule2 = @c_SQL_Rule2 + '))'

         IF ISNULL(@c_ToDPLoc_Cond_Exp,'')<>''
            SET @c_SQL_Rule2 = @c_SQL_Rule2 + ' AND (' + @c_ToDPLoc_Cond_Exp + ')'
         ELSE
            SET @c_SQL_Rule2 = @c_SQL_Rule2
              +  ' AND ((ISNULL(@c_PickLoc,'''')<>'''' AND LOC.LocAisle=@c_PickAisle)'
              +    ' OR (ISNULL(@c_StylePickLoc,'''')<>'''' AND LOC.LocAisle=@c_StylePickAisle)'
              +    ' OR (ISNULL(LLI.Qty,0)-ISNULL(LLI.QtyPicked,0)+ISNULL(TS.PendingQty,0)>0))'
              +  ' AND LOC.PutawayZone = @c_FromPAZone'
              +  ' AND CASE WHEN @c_SkuClass=''Bigger'' THEN IIF(ISNULL(TRY_PARSE(ISNULL(LOC.LocationRoom,'''') AS FLOAT),1)>=2,1,0) ELSE 1 END=1'

         IF ISNULL(@c_ToDPLoc_Sort_Exp,'')<>''
            SET @c_SQL_Rule2 = @c_SQL_Rule2 + ' ORDER BY ' + @c_ToDPLoc_Sort_Exp
         ELSE
            SET @c_SQL_Rule2 = @c_SQL_Rule2
              +' ORDER BY CASE WHEN ISNULL(LLI.Qty,0)-ISNULL(LLI.QtyPicked,0)+ISNULL(TS.PendingQty,0)>0 THEN 10 ELSE 20 END'
              +        ', CASE WHEN ISNULL(@c_PickLoc,'''')<>'''' AND LOC.LocAisle=@c_PickAisle THEN 10'
              +              ' WHEN ISNULL(@c_StylePickLoc,'''')<>'''' AND LOC.LocAisle=@c_StylePickAisle THEN 20'
              +         ' ELSE 30 END'
              +        ', ABS(ISNULL(TRY_PARSE(ISNULL(IIF(ISNULL(@c_PickLoc,'''')<>'''',@c_PickLogicalLoc,@c_StylePickLgLoc),'''') AS FLOAT),0)'
              +           ' - ISNULL(TRY_PARSE(ISNULL(LOC.LogicalLocation,'''') AS FLOAT),0))'
              +        ', LOC.LogicalLocation'
              +        ', LOC.Loc'
      END

      SET @b_success        = 0
      SET @c_PickAisle      = ''
      SET @c_PickBay        = ''
      SET @c_PickLoc        = ''
      SET @c_PickLogicalLoc = ''
      SET @c_SkuClass       = ''
      SET @c_SkuStyle       = ''
      SET @c_StylePickAisle = ''
      SET @c_StylePickLoc   = ''
      SET @c_StylePickLgLoc = ''
      SET @n_SkuStdCube     = @n_DftSkuStdCube

      SELECT TOP 1 @n_SkuStdCube = ISNULL(NULLIF(STDCUBE,0),@n_SkuStdCube)
      FROM dbo.SKU S (NOLOCK)
      WHERE S.Sku = @c_Sku AND S.StorerKey = @c_Storerkey

      -- get pickface
      SELECT TOP 1
             @c_PickAisle      = ISNULL(RTRIM(LOC.LocAisle),'')
           , @c_PickBay        = ISNULL(RTRIM(LOC.LocBay),'')
           , @c_PickLoc        = ISNULL(RTRIM(LOC.Loc),'')
           , @c_PickLogicalLoc = ISNULL(RTRIM(LOC.LogicalLocation),'')
           , @c_SkuClass       = ISNULL(RTRIM(SKU.[Class]),'')
           , @c_SkuStyle       = ISNULL(RTRIM(SKU.Style),'')
        FROM dbo.SKUxLOC SL  WITH (NOLOCK)
        JOIN dbo.LOC     LOC WITH (NOLOCK) ON SL.Loc = LOC.Loc
        JOIN dbo.SKU     SKU WITH (NOLOCK) ON SL.Storerkey = SKU.Storerkey AND SL.Sku = SKU.Sku
       WHERE LOC.Facility = @c_Facility
         AND SL.StorerKey = @c_Storerkey
         AND SL.Sku = @c_Sku
         AND SL.LocationType = 'PICK'
       ORDER BY ISNULL(TRY_PARSE(ISNULL(LOC.LogicalLocation,'') AS FLOAT),0)
              , LOC.LogicalLocation
              , SL.Loc

      -- get same Style pickface
      IF ISNULL(@c_SkuStyle,'')<>''
      BEGIN
         SELECT TOP 1
                @c_StylePickAisle = ISNULL(RTRIM(LOC.LocAisle),'')
              , @c_StylePickLoc   = ISNULL(RTRIM(LOC.Loc),'')
              , @c_StylePickLgLoc = ISNULL(RTRIM(LOC.LogicalLocation),'')
           FROM dbo.SKUxLOC SL  WITH (NOLOCK)
           JOIN dbo.LOC     LOC WITH (NOLOCK) ON SL.Loc = LOC.Loc
           JOIN dbo.SKU     SKU WITH (NOLOCK) ON SL.Storerkey = SKU.Storerkey AND SL.Sku = SKU.Sku
          WHERE LOC.Facility = @c_Facility
            AND SL.StorerKey = @c_Storerkey
            AND SL.LocationType = 'PICK'
            AND SKU.Style = @c_SkuStyle
          ORDER BY ISNULL(TRY_PARSE(ISNULL(LOC.LogicalLocation,'') AS FLOAT),0)
                 , LOC.LogicalLocation
                 , SL.Loc
      END

      IF @n_debug = 1
      BEGIN
         SELECT 'Pickface', PickAisle=@c_PickAisle, PickBay=@c_PickBay, PickLoc=@c_PickLoc, PickLogicalLoc=@c_PickLogicalLoc
              , SkuClass=@c_SkuClass, SkuStyle=@c_SkuStyle, StylePickAisle=@c_StylePickAisle, StylePickLoc=@c_StylePickLoc, StylePickLgLoc=@c_StylePickLgLoc
      END

      TRUNCATE TABLE #TEMP_FROMLOC

      INSERT INTO #TEMP_FROMLOC (FromLoc, Qty, FromLogicalLoc, Lot, FromID, FromLocType, FromAisle, FromBay, FromPAZone)
      SELECT LLI.Loc
           , LLI.Qty - CASE WHEN @c_MoveAllocQty ='1' THEN 0 ELSE LLI.QtyAllocated END
                     - CASE WHEN @c_MovePickedQty='1' THEN 0 ELSE LLI.QtyPicked    END
           , LOC.LogicalLocation
           , LLI.Lot
           , LLI.Id
           , SL.LocationType
           , LOC.LocAisle
           , LOC.LocBay
           , LOC.PutawayZone
        FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
        JOIN dbo.LOC        LOC WITH (NOLOCK) ON LOC.Loc = LLI.Loc
        JOIN dbo.SKUxLOC    SL  WITH (NOLOCK) ON LLI.Storerkey = SL.Storerkey AND LLI.Sku = SL.Sku AND LLI.Loc = SL.Loc
       WHERE LLI.StorerKey = @c_Storerkey
         AND LLI.SKU = @c_Sku
         AND LOC.Facility = @c_Facility
         AND ( LOC.LocationType = @c_DynPick_LocType
           OR SL.LocationType = 'PICK' AND SL.Loc <> @c_PickLoc)
         AND LLI.Qty - CASE WHEN @c_MoveAllocQty ='1' THEN 0 ELSE LLI.QtyAllocated END
                     - CASE WHEN @c_MovePickedQty='1' THEN 0 ELSE LLI.QtyPicked    END > 0
         AND LLI.Loc NOT IN (SELECT Loc FROM #TEMP_UsedToLoc)
         AND LLI.Loc NOT IN (SELECT Loc FROM #TEMP_UsedFromLoc)
       ORDER BY CASE WHEN ISNULL(LOC.LocAisle,'') <> ISNULL(@c_PickAisle,'') THEN 10   -- FROM Priority 1: dynamic locations where aisle != pickface aisle (qty asc)
                     WHEN ISNULL(LOC.LocAisle,'') =  ISNULL(@c_PickAisle,'')
                      AND ISNULL(LOC.LocBay  ,'') <> ISNULL(@c_PickBay  ,'') THEN 20   -- FROM Priority 2: same aisle but different bay
                     ELSE                                                         30   -- FROM Priority 3: same bay or any dynamic (qty asc)
                END
              , LLI.Qty - CASE WHEN @c_MoveAllocQty ='1' THEN 0 ELSE LLI.QtyAllocated END
                        - CASE WHEN @c_MovePickedQty='1' THEN 0 ELSE LLI.QtyPicked    END
              , ISNULL(TRY_PARSE(ISNULL(LOC.LogicalLocation,'') AS FLOAT),0)
              , LOC.LogicalLocation
              , LLI.Loc

      IF @@ROWCOUNT = 0
         CONTINUE

      DECLARE CUR_FROMLOC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT SeqNo, FromLoc, Qty, FromLogicalLoc, Lot, FromID, FromLocType, FromAisle, FromBay, FromPAZone
        FROM #TEMP_FROMLOC
       ORDER BY SeqNo

      OPEN CUR_FROMLOC

      WHILE @n_continue IN (1,2)
      BEGIN
         FETCH NEXT FROM CUR_FROMLOC INTO @n_SeqNo, @c_FromLoc, @n_Qty, @c_FromLogicalLoc, @c_Lot, @c_FromID, @c_FromLocType, @c_FromAisle, @c_FromBay, @c_FromPAZone

         IF @@FETCH_STATUS <> 0
            BREAK

         IF EXISTS(SELECT TOP 1 1 FROM #TEMP_UsedToLoc WHERE Loc = @c_FromLoc)
            CONTINUE

         IF @n_debug = 1
            SELECT FromLoc = @c_FromLoc, Qty = @n_Qty

         SET @c_ToLoc        = ''
         SET @c_ToLogicalLoc = ''

         ----------------------------------------------------------------
         -- TO Rule 1: Fixed Pickface (Cubic Measurement Capacity Check)
         ----------------------------------------------------------------
         IF @n_continue IN (1,2) AND ISNULL(@c_FromLoc,'')<>'' AND ISNULL(@c_PickLoc,'')<>''
         BEGIN
            EXEC sp_executesql
                 @c_SQL_Rule1
               , @c_Params_FindToLoc
               , @c_Facility
               , @c_Storerkey
               , @c_Sku
               , @c_FromLoc
               , @c_FromLogicalLoc
               , @c_FromLocType
               , @c_FromAisle
               , @c_FromBay
               , @c_FromPAZone
               , @c_FromID
               , @c_Lot
               , @n_Qty
               , @c_ReplenType
               , @n_CartonCube
               , @n_SkuStdCube
               , @n_LocTolerance
               , @c_NoCommingleSku
               , @c_PickAisle
               , @c_PickBay
               , @c_PickLoc
               , @c_PickLogicalLoc
               , @c_SkuClass
               , @c_SkuStyle
               , @c_StylePickAisle
               , @c_StylePickLoc
               , @c_StylePickLgLoc
               , @c_ToLoc          OUTPUT
               , @c_ToLogicalLoc   OUTPUT
         END

         ----------------------------------------------------------------
         -- TO Rule 2: dynamic loc by cubic measurement and proximity (logical location)
         ----------------------------------------------------------------
         IF @n_continue IN (1,2) AND ISNULL(@c_ToLoc,'')='' AND ISNULL(@c_FromLoc,'')<>'' AND ISNULL(@c_FromLocType,'')<>'PICK'
         BEGIN
            EXEC sp_executesql
                 @c_SQL_Rule2
               , @c_Params_FindToLoc
               , @c_Facility
               , @c_Storerkey
               , @c_Sku
               , @c_FromLoc
               , @c_FromLogicalLoc
               , @c_FromLocType
               , @c_FromAisle
               , @c_FromBay
               , @c_FromPAZone
               , @c_FromID
               , @c_Lot
               , @n_Qty
               , @c_ReplenType
               , @n_CartonCube
               , @n_SkuStdCube
               , @n_LocTolerance
               , @c_NoCommingleSku
               , @c_PickAisle
               , @c_PickBay
               , @c_PickLoc
               , @c_PickLogicalLoc
               , @c_SkuClass
               , @c_SkuStyle
               , @c_StylePickAisle
               , @c_StylePickLoc
               , @c_StylePickLgLoc
               , @c_ToLoc          OUTPUT
               , @c_ToLogicalLoc   OUTPUT
         END

         ----------------------------------------------------------------
         -- Insert PUTBACK Task using provided proc
         ----------------------------------------------------------------
         IF @n_continue IN (1,2) AND ISNULL(@c_FromLoc,'')<>'' AND ISNULL(@c_ToLoc,'')<>''
         BEGIN
            IF NOT EXISTS(SELECT TOP 1 1 FROM #TEMP_UsedFromLoc WHERE Loc=@c_FromLoc)
               INSERT INTO #TEMP_UsedFromLoc (Loc) VALUES(@c_FromLoc)
            IF NOT EXISTS(SELECT TOP 1 1 FROM #TEMP_UsedToLoc   WHERE Loc=@c_ToLoc)
               INSERT INTO #TEMP_UsedToLoc   (Loc) VALUES(@c_ToLoc)

            SET @c_Packkey = ''
            SET @c_UOM     = ''
            SET @c_SelectFlag = CASE WHEN @c_TaskFilterZone IN ('1','Y') THEN '' ELSE 'Y' END

            IF @c_ReplenType = 'R'
            BEGIN
               SELECT @c_Packkey = S.Packkey
                    , @c_UOM     = P.PackUOM3
                 FROM dbo.SKU  S WITH (NOLOCK)
                 JOIN dbo.PACK P WITH (NOLOCK) ON S.Packkey = P.Packkey
                WHERE S.Storerkey = @c_Storerkey
                  AND S.SKu = @c_Sku
            END

            INSERT INTO #TEMP_TASK (TaskType, Storerkey, Sku, Lot, Qty, FromLoc, FromLogicalLoc, FromID, ToLoc, ToLogicalLoc, ToID,
                                    UOM, PackKey, Priority, PickMethod, SourceType, GroupKey, SelectFlag)
            VALUES(@c_TaskType, @c_Storerkey, @c_Sku, @c_Lot, @n_Qty, @c_FromLoc, @c_FromLogicalLoc, @c_FromID, @c_ToLoc, @c_ToLogicalLoc, @c_FromID,
                   @c_UOM, @c_PackKey, @c_Priority, @c_PickMethod, @c_SourceType, @c_GroupKey, @c_SelectFlag)
         END
      END
      CLOSE CUR_FROMLOC
      DEALLOCATE CUR_FROMLOC
   END
   CLOSE CUR_SKU
   DEALLOCATE CUR_SKU

   IF EXISTS(SELECT TOP 1 1 FROM #TEMP_TASK)
   BEGIN
      IF EXISTS(SELECT TOP 1 1 FROM #TEMP_TASK WHERE ISNULL(SelectFlag,'')<>'Y')
      BEGIN
         IF ISNULL(@c_SQL_Zones,'') <> ''
         BEGIN
            SET @c_SQL = 'UPDATE T SET SelectFlag = ''Y'''
              + ' FROM #TEMP_TASK T'
              + ' JOIN LOC WITH(NOLOCK) ON T.FromLoc = LOC.Loc'
              + ' WHERE ISNULL(T.SelectFlag,'''')<>''Y'''
              + ISNULL(@c_SQL_Zones,'')
            EXEC (@c_SQL)
         
            SET @c_SQL = 'UPDATE T SET SelectFlag = ''Y'''
              + ' FROM #TEMP_TASK T'
              + ' JOIN LOC WITH(NOLOCK) ON T.ToLoc = LOC.Loc'
              + ' WHERE ISNULL(T.SelectFlag,'''')<>''Y'''
              + ISNULL(@c_SQL_Zones,'')
            EXEC (@c_SQL)
         END
         ELSE
         BEGIN
            UPDATE #TEMP_TASK SET SelectFlag = 'Y'
         END
      END

      DECLARE CUR_TASK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT TaskType, Storerkey, Sku, Lot, Qty, FromLoc, FromLogicalLoc, FromID, ToLoc, ToLogicalLoc, ToID,
             UOM, PackKey, Priority, PickMethod, SourceType, GroupKey
      FROM #TEMP_TASK
      WHERE SelectFlag = 'Y'
      ORDER BY RowNo

      OPEN CUR_TASK

      WHILE @n_continue IN (1,2)
      BEGIN
         FETCH NEXT FROM CUR_TASK
          INTO @c_TaskType, @c_Storerkey, @c_Sku, @c_Lot, @n_Qty, @c_FromLoc, @c_FromLogicalLoc, @c_FromID, @c_ToLoc, @c_ToLogicalLoc, @c_ToID,
               @c_UOM, @c_PackKey, @c_Priority, @c_PickMethod, @c_SourceType, @c_GroupKey

         IF @@FETCH_STATUS <> 0
            BREAK

         IF @c_ReplenType = 'R'
         BEGIN
            EXECUTE nspg_GetKey 'REPLENISHKEY', 10, @c_ReplenishmentKey OUTPUT,
               @b_success OUTPUT, @n_err OUTPUT, @c_errmsg OUTPUT

            IF NOT @b_success = 1
            BEGIN
               SELECT @n_continue = 3
               SELECT @n_err = 81140
               SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err) + ': Get REPLENISHKEY failed. (isp_GenReplenishmentTask_01)'
               BREAK
            END

            INSERT INTO dbo.REPLENISHMENT WITH(ROWLOCK)
                  ( Replenishmentgroup, ReplenishmentKey, StorerKey, Sku, FromLoc, ToLoc, Lot, Id, Qty, UOM,
                    PackKey, Confirmed, Priority, PendingMoveIn)
            VALUES( N'PUTBACK', @c_ReplenishmentKey, @c_Storerkey, @c_Sku, @c_FromLoc, @c_ToLoc, @c_Lot, @c_FromID, @n_Qty, @c_UOM,
                    @c_PackKey, N'N', LEFT(@c_Priority,5), @n_Qty)

            SELECT @n_err = @@ERROR
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250), @n_err), @n_err = 81141
               SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err)
                    + ': Insert REPLENISHMENT table failed. (isp_GenReplenishmentTask_01) ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
               BREAK
            END
         END
         ELSE IF @c_ReplenType = 'T'
         BEGIN
            EXEC isp_InsertTaskDetail
                 @c_TaskType              = @c_TaskType
               , @c_Storerkey             = @c_Storerkey
               , @c_Sku                   = @c_Sku
               , @c_Lot                   = @c_Lot
               , @c_UOM                   = @c_UOM
               , @n_UOMQty                = @n_Qty
               , @n_Qty                   = @n_Qty
               , @c_FromLoc               = @c_FromLoc
               , @c_LogicalFromLoc        = @c_FromLogicalLoc
               , @c_FromID                = @c_FromID
               , @c_ToLoc                 = @c_ToLoc
               , @c_LogicalToLoc          = @c_ToLogicalLoc
               , @c_ToID                  = @c_ToID
               , @c_PickMethod            = @c_PickMethod
               , @c_Priority              = @c_Priority
               , @c_SourcePriority        = @c_Priority
               , @c_SourceType            = @c_SourceType
               , @c_GroupKey              = @c_GroupKey
               , @c_AreaKey               = '?F'  -- ?F=Get from location areakey
               , @c_SplitTaskByCase       = 'N'
               , @c_ReservePendingMoveIn  = 'Y'
               , @b_Success               = @b_Success OUTPUT
               , @n_Err                   = @n_err OUTPUT
               , @c_ErrMsg                = @c_errmsg OUTPUT

            IF @b_Success <> 1
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 81142
               SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                    + ': Insert Taskdetail Failed. (ispRLWAV05)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
               BREAK
            END
         END
      END
      CLOSE CUR_TASK
      DEALLOCATE CUR_TASK
   END

   ----------------------------------------------------------------
   -- Commit/rollback handling
   ----------------------------------------------------------------
   IF @n_continue = 3
   BEGIN
      SELECT @b_success = 0
      ROLLBACK TRANSACTION
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_GeneratePutBackTasks'
      RAISERROR(@c_errmsg, 16, 1) WITH SETERROR
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRANSACTION
      END
   END
END
GO
GRANT EXECUTE ON [dbo].[isp_GeneratePutBackTasks] TO [nSQL]
GO
