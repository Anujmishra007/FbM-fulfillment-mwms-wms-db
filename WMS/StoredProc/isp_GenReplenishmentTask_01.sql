SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Stored Procedure: isp_GenReplenishmentTask_01                           */
/* Creation Date:                                                          */
/* Copyright: MAERSK                                                       */
/* Written by: Michael Lam                                                 */
/*                                                                         */
/* Purpose:                                                                */
/*                                                                         */
/* Called By: FCR-8042 - Copy from isp_GenReplenishment                    */
/*            @c_ReplenFlag --  N = Normal                                 */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author     Ver   Purposes                                  */
/* 2025-10-24   Michael    1.0   DevOps Combine Script                     */
/* 2025-12-08   Michael    1.1   FCR-8536 ONBR-Replen per PND (ML01)       */
/* 2026-01-20   Michael    1.2   FCR-9971 UK-Columbia-Replenishment (ML02) */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_GenReplenishmentTask_01]
     @c_Zone01     NVARCHAR(10)
   , @c_Zone02     NVARCHAR(10)
   , @c_Zone03     NVARCHAR(10)
   , @c_Zone04     NVARCHAR(10)
   , @c_Zone05     NVARCHAR(10)
   , @c_Zone06     NVARCHAR(10)
   , @c_Zone07     NVARCHAR(10)
   , @c_Zone08     NVARCHAR(10)
   , @c_Zone09     NVARCHAR(10)
   , @c_Zone10     NVARCHAR(10)
   , @c_Zone11     NVARCHAR(10)
   , @c_Zone12     NVARCHAR(10)
   , @c_ReplenFlag NVARCHAR(10) = 'N' -- N = Normal
   , @c_Storerkey  NVARCHAR(15)
   , @c_ReplenType NVARCHAR(10) = 'R' -- R=Replenishment, T=TaskManager
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_starttcnt INT = @@TRANCOUNT

   DECLARE @b_debug                  INT = 0
         , @n_continue               INT = 1
         , @c_SP_Name                NVARCHAR(128) = 'isp_GenReplenishmentTask_01'
         , @c_Packkey                NVARCHAR(10)
         , @c_UOM                    NVARCHAR(10)
         , @n_Pallet                 INT
         , @n_FullPackQty            INT
         , @c_LocationType           NVARCHAR(10)
         , @c_Facility               NVARCHAR(5)
         , @n_Qty                    INT
         , @n_QtyLocationLimit       INT
         , @n_QtyPicked              INT
         , @n_QtyAllocated           INT
         , @n_QtyLocationMinimum     INT
         , @n_CaseCnt                INT
         , @n_ReplenQty              INT
         , @c_PickCode               NVARCHAR(10)
         , @c_LogicalLocation        NVARCHAR(20)
         , @c_SortColumn             NVARCHAR(60)
         , @n_Cnt                    INT
         , @n_QtyAvailable           INT
         , @c_Priority               NVARCHAR(10)
         , @c_ReplenishmentGroup     NVARCHAR(10) = ''
         , @c_ReplExclProdNearExpiry NVARCHAR(10)
         , @n_NearExpiryDay          INT
         , @c_UCCNo                  NVARCHAR(20)
         , @c_SQL                    NVARCHAR(MAX)= ''
         , @c_SQLStatement           NVARCHAR(MAX)= ''
         , @c_SQLParms1              NVARCHAR(MAX)= ''
         , @c_SQLParms2              NVARCHAR(MAX)= ''   --ML02
         , @c_SQLParms3              NVARCHAR(MAX)= ''   --ML02
         , @c_SQLCondition           NVARCHAR(MAX)= ''
         , @c_ReplCond_Exp           NVARCHAR(MAX)= ''
         , @c_ReplJoin_Exp           NVARCHAR(MAX)= ''
         , @c_Sorting_Exp            NVARCHAR(MAX)= ''   --ML02
         , @c_PendingTaskQty_Exp     NVARCHAR(MAX)= ''
         , @c_ReplCond_LOT_Exp       NVARCHAR(MAX)= ''
         , @c_ReplJoin_LOT_Exp       NVARCHAR(MAX)= ''   --ML02
         , @c_LotSortColumn_Exp      NVARCHAR(MAX)= ''
         , @c_ReplCond_LLI_Exp       NVARCHAR(MAX)= ''
         , @c_ReplJoin_LLI_Exp       NVARCHAR(MAX)= ''   --ML02
         , @c_Sorting_LLI_Exp        NVARCHAR(MAX)= ''
         , @c_TransitLOC_Exp         NVARCHAR(MAX)= ''
         , @c_TaskGrouping_Exp       NVARCHAR(MAX)= ''
         , @c_TaskPriority_Exp       NVARCHAR(MAX)= ''
         , @c_TaskType_Exp           NVARCHAR(MAX)= ''
         , @c_PickMethod_Exp         NVARCHAR(MAX)= ''
         , @c_ReplenQty_Exp          NVARCHAR(MAX)= ''   --ML02
         , @c_TaskType_Val           NVARCHAR(10) = ''
         , @c_PickMethod_Val         NVARCHAR(10) = ''
         , @c_TaskPriority_Val       NVARCHAR(10) = ''
         , @c_DelPendingTask         NVARCHAR(10) = ''
         , @c_B2CChannelReplen       NVARCHAR(10) = ''
         , @c_NoUCC                  NVARCHAR(10) = ''   --ML02
         , @n_LocTolerance           FLOAT        = 1    --ML02
         , @n_CartonTolerance        FLOAT        = 1    --ML02
         , @n_PalletTolerance        FLOAT        = 1    --ML02
         , @b_CleanUpReplen          INT          = 0    --ML02
         , @n_PendingMoveIn          INT
         , @n_ChannelInvQty          INT
         , @n_Temp                   INT

   DECLARE @c_CurrentSKU             NVARCHAR(20) = ''
         , @c_CurrentStorer          NVARCHAR(15) = ''
         , @c_CurrentLOC             NVARCHAR(10) = ''
         , @c_CurrentLogicalLocation NVARCHAR(10) = ''
         , @c_CurrentPriority        NVARCHAR(5)  = ''
         , @c_FromLOC                NVARCHAR(10) = ''
         , @c_FromLogicalLocation    NVARCHAR(10) = ''
         , @c_FromLot                NVARCHAR(10) = ''
         , @c_FromId                 NVARCHAR(20) = ''
         , @n_FromQty                INT          = 0
         , @n_RemainingQty           INT          = 0
         , @n_PossibleCases          INT          = 0
         , @n_OnHandQty              INT          = 0
         , @c_ReplenishmentKey       NVARCHAR(10) = ''
         , @n_LotSKUQTY              INT          = 0
         , @c_TransitLOC             NVARCHAR(10) = ''
         , @c_ToLOC                  NVARCHAR(10) = ''
         , @c_FinalLOC               NVARCHAR(10) = ''
         , @c_GroupKey               NVARCHAR(10) = ''
         , @c_TaskGrouping           NVARCHAR(100)= ''
         , @c_TaskGrouping_Prev      NVARCHAR(100)= ''
         , @n_PendingTaskQty         INT          = 0
         , @c_TaskType               NVARCHAR(10) = ''
         , @c_PickMethod             NVARCHAR(10) = ''
         , @c_CommingleSku           NVARCHAR(1)  = ''   --ML02
         , @c_ValidateMsg            NVARCHAR(250)= ''   --ML02
         , @c_ValidateMsg_Exp        NVARCHAR(MAX)= ''   --ML02
         , @c_ValidateExp            NVARCHAR(MAX)= ''   --ML02
         , @c_ValidateAction         NVARCHAR(60) = ''   --ML02
         , @c_ValidateStep           NVARCHAR(30) = ''   --ML02
         , @c_WarningMsg             NVARCHAR(250)= ''   --ML02

   DECLARE @b_success INT,
           @n_err INT,
           @c_errmsg NVARCHAR(255)

   SET @c_Facility = @c_Zone01

   IF @c_Zone12 = '1'
   BEGIN
      SET @b_debug = ISNULL(TRY_PARSE(ISNULL(@c_Zone12,'') AS INT),0)
      SET @c_Zone12 = ''
   END

   SELECT @c_ReplCond_Exp       = ISNULL(TRIM(MAX(CASE WHEN Code = 'Condition'         THEN Notes END)),'')
        , @c_ReplJoin_Exp       = ISNULL(TRIM(MAX(CASE WHEN Code = 'SQL_JOIN'          THEN Notes END)),'')   --ML01
        , @c_Sorting_Exp        = ISNULL(TRIM(MAX(CASE WHEN Code = 'Sorting'           THEN Notes END)),'')   --ML02
        , @c_PendingTaskQty_Exp = ISNULL(TRIM(MAX(CASE WHEN Code = 'PendingTaskQty'    THEN Notes END)),'')   --ML01
        , @c_ReplCond_LOT_Exp   = ISNULL(TRIM(MAX(CASE WHEN Code = 'Condition_LOT'     THEN Notes END)),'')   --ML01
        , @c_ReplJoin_LOT_Exp   = ISNULL(TRIM(MAX(CASE WHEN Code = 'SQL_JOIN_LOT'      THEN Notes END)),'')   --ML02
        , @c_LotSortColumn_Exp  = ISNULL(TRIM(MAX(CASE WHEN Code = 'LotSortColumn'     THEN Notes END)),'')
        , @c_ReplCond_LLI_Exp   = ISNULL(TRIM(MAX(CASE WHEN Code = 'Condition_LLI'     THEN Notes END)),'')
        , @c_ReplJoin_LLI_Exp   = ISNULL(TRIM(MAX(CASE WHEN Code = 'SQL_JOIN_LLI'      THEN Notes END)),'')   --ML02
        , @c_Sorting_LLI_Exp    = ISNULL(TRIM(MAX(CASE WHEN Code = 'Sorting_LLI'       THEN Notes END)),'')
        , @c_TransitLOC_Exp     = ISNULL(TRIM(MAX(CASE WHEN Code = 'TransitLOC'        THEN Notes END)),'')   --ML01
        , @c_TaskGrouping_Exp   = ISNULL(TRIM(MAX(CASE WHEN Code = 'TaskGrouping'      THEN Notes END)),'')   --ML01
        , @c_TaskType_Exp       = ISNULL(TRIM(MAX(CASE WHEN Code = 'TaskType'          THEN Notes END)),'')   --ML01
        , @c_TaskPriority_Exp   = ISNULL(TRIM(MAX(CASE WHEN Code = 'TaskPriority'      THEN Notes END)),'')   --ML01
        , @c_PickMethod_Exp     = ISNULL(TRIM(MAX(CASE WHEN Code = 'PickMethod'        THEN Notes END)),'')   --ML01
        , @c_ReplenQty_Exp      = ISNULL(TRIM(MAX(CASE WHEN Code = 'ReplenQty'         THEN Notes END)),'')   --ML02
        , @c_TaskType_Val       = ISNULL(TRIM(MAX(CASE WHEN Code = 'TaskType'          THEN Long  END)),'')   --ML01
        , @c_PickMethod_Val     = ISNULL(TRIM(MAX(CASE WHEN Code = 'PickMethod'        THEN Long  END)),'')   --ML01
        , @c_TaskPriority_Val   = ISNULL(TRIM(MAX(CASE WHEN Code = 'TaskPriority'      THEN Long  END)),'')
        , @c_DelPendingTask     = ISNULL(TRIM(MAX(CASE WHEN Code = 'DeletePendingTask' THEN Long  END)),'1')
        , @c_B2CChannelReplen   = ISNULL(TRIM(MAX(CASE WHEN Code = 'B2CChannelReplen'  THEN Long  END)),'')
        , @c_NoUCC              = ISNULL(TRIM(MAX(CASE WHEN Code = 'NoUCC'             THEN Long  END)),'')   --ML02
        , @n_LocTolerance       = ISNULL(TRY_PARSE(ISNULL(MAX(CASE WHEN Code='LocTolerance'    THEN Long END),'') AS FLOAT), 1)   --ML02
        , @n_CartonTolerance    = ISNULL(TRY_PARSE(ISNULL(MAX(CASE WHEN Code='CartonTolerance' THEN Long END),'') AS FLOAT), 0.9) --ML02
        , @n_PalletTolerance    = ISNULL(TRY_PARSE(ISNULL(MAX(CASE WHEN Code='PalletTolerance' THEN Long END),'') AS FLOAT), 1)   --ML02
     FROM dbo.CODELKUP WITH(NOLOCK)
    WHERE ListName = 'REPLENCFG'
      AND Code2 = @c_SP_Name
      AND Storerkey = @c_Storerkey

   IF @c_ReplCond_Exp LIKE 'AND %'
      SET @c_ReplCond_Exp = SUBSTRING(@c_ReplCond_Exp, 5, LEN(@c_ReplCond_Exp))

   IF @c_ReplCond_LOT_Exp LIKE 'AND %'
      SET @c_ReplCond_LOT_Exp = SUBSTRING(@c_ReplCond_LOT_Exp, 5, LEN(@c_ReplCond_LOT_Exp))

   IF @c_ReplCond_LLI_Exp LIKE 'AND %'
      SET @c_ReplCond_LLI_Exp = SUBSTRING(@c_ReplCond_LLI_Exp, 5, LEN(@c_ReplCond_LLI_Exp))

   IF ISNULL(@n_LocTolerance,0) = 0    --ML02
      SET @n_LocTolerance = 1          --ML02
   IF ISNULL(@n_CartonTolerance,0) = 0 --ML02
      SET @n_CartonTolerance = 1
   IF ISNULL(@n_PalletTolerance,0) = 0 --ML02
      SET @n_PalletTolerance = 1

   CREATE TABLE #TEMP_REPLENISHMENT
   (
      StorerKey    NVARCHAR(15) NULL DEFAULT ('')
    , SKU          NVARCHAR(20) NULL DEFAULT ('')
    , FromLOC      NVARCHAR(10) NULL DEFAULT ('')
    , ToLOC        NVARCHAR(10) NULL DEFAULT ('')
    , Lot          NVARCHAR(10) NULL DEFAULT ('')
    , Id           NVARCHAR(18) NULL DEFAULT ('')
    , Qty          INT          NULL DEFAULT (0)
    , QtyMoved     INT          NULL DEFAULT (0)
    , QtyInPickLOC INT          NULL DEFAULT (0)
    , Priority     NVARCHAR(10) NULL DEFAULT ('')
    , UOM          NVARCHAR(10) NULL DEFAULT ('')
    , PackKey      NVARCHAR(10) NULL DEFAULT ('')
    , UCCNo        NVARCHAR(20) NULL DEFAULT ('')
    , TransitLOC   NVARCHAR(10) NULL DEFAULT ('')
   )

   CREATE TABLE #TEMP_LOT_SORT
   (
      LOT        NVARCHAR(10) NULL DEFAULT ('')
    , SortColumn NVARCHAR(60) NULL DEFAULT ('')
   )

   IF @n_continue NOT IN (1,2)
      GOTO EXIT_SP

   IF @c_Zone02 <> 'ALL' AND ISNULL(@c_ReplCond_Exp,'') = ''
   BEGIN
      SELECT @c_SQLCondition = @c_SQLCondition + ' AND LOC.PutawayZone IN ( '''
           + RTRIM(ISNULL(@c_Zone02,'')) +''','''
           + RTRIM(ISNULL(@c_Zone03,'')) +''','''
           + RTRIM(ISNULL(@c_Zone04,'')) +''','''
           + RTRIM(ISNULL(@c_Zone05,'')) +''','''
           + RTRIM(ISNULL(@c_Zone06,'')) +''','''
           + RTRIM(ISNULL(@c_Zone07,'')) +''','''
           + RTRIM(ISNULL(@c_Zone08,'')) +''','''
           + RTRIM(ISNULL(@c_Zone09,'')) +''','''
           + RTRIM(ISNULL(@c_Zone10,'')) +''','''
           + RTRIM(ISNULL(@c_Zone11,'')) +''','''
           + RTRIM(ISNULL(@c_Zone12,'')) +''')'
   END

   SET @c_SQLStatement = 'DECLARE CUR_ReplenSkuLoc CURSOR FAST_FORWARD READ_ONLY FOR'
     + ' SELECT SKUxLOC.ReplenishmentPriority'
     +       ', SKUxLOC.StorerKey'
     +       ', SKUxLOC.SKU'
     +       ', SKUxLOC.LOC'
     +       ', SKUxLOC.Qty'
     +       ', SKUxLOC.QtyPicked'
     +       ', SKUxLOC.QtyAllocated'
     +       ', SKUxLOC.QtyLocationLimit'
     +       ', SKUxLOC.QtyLocationMinimum'
     +       ', PACK.CaseCnt'
     +       ', PACK.Pallet'
     +       ', SKU.PickCode'
     +       ', SKUxLOC.LocationType'
     +       ', SC2.Authority'
     +       ', PendingTaskQty=ISNULL(' + CASE WHEN ISNULL(@c_PendingTaskQty_Exp,'') <> '' THEN @c_PendingTaskQty_Exp ELSE '0' END + ',0)'   --ML01
     +       ', LOC.CommingleSku'   --ML02
     +   ' FROM dbo.SKUxLOC WITH(NOLOCK)'
     +   ' JOIN dbo.LOC     WITH(NOLOCK) ON SKUxLOC.Loc = LOC.Loc'
     +   ' JOIN dbo.SKU     WITH(NOLOCK) ON SKU.StorerKey = SKUxLOC.StorerKey AND SKU.SKU = SKUxLOC.SKU'
     +   ' JOIN dbo.PACK    WITH(NOLOCK) ON PACK.PackKey = SKU.PACKKey'
     +  ' OUTER APPLY dbo.fnc_GetRight2(LOC.Facility, SKUxLOC.Storerkey, '''', ''REPLEXCLPRODNEAREXPIRY_DAY'') SC2'

   IF ISNULL(@c_ReplJoin_Exp,'') <> ''                                --ML01
      SET @c_SQLStatement = @c_SQLStatement + ' ' + @c_ReplJoin_Exp   --ML01

   SET @c_SQLStatement = @c_SQLStatement
     +  ' WHERE LOC.Facility = ''' + ISNULL(REPLACE(@c_Facility,'''',''''''),'') +''''
     +    ' AND SKUxLOC.StorerKey = ''' + ISNULL(REPLACE(@c_Storerkey,'''',''''''),'') + ''''
     +    ' AND SKUxLOC.LocationType IN ( ''PICK'', ''CASE'' )'
     +    ' AND LOC.LocationFlag NOT IN ( ''DAMAGE'', ''HOLD'' )'
     +    ' ' + RTRIM(ISNULL(@c_SQLCondition,''))

   IF ISNULL(@c_ReplCond_Exp,'') <> ''
      SET @c_SQLStatement = @c_SQLStatement
        +    ' AND (' + @c_ReplCond_Exp + ')'

   --ML02-S
   IF ISNULL(@c_Sorting_Exp,'') <> ''
      SET @c_SQLStatement = @c_SQLStatement
        +  ' ORDER BY ' + @c_Sorting_Exp
   ELSE
   --ML02-E
      SET @c_SQLStatement = @c_SQLStatement
        +  ' ORDER BY SKUxLOC.Storerkey, SKUxLOC.ReplenishmentPriority, SKUxLOC.Loc'

   IF @b_debug = 1
   BEGIN
      SET @c_SQL = 'SELECT SKUxLOC_SQL = ''' + ISNULL(REPLACE(@c_SQLStatement,'''',''''''),'') + ''''
      EXEC(@c_SQL)
   END

   SET @c_SQLParms1 = N'@c_Zone01     NVARCHAR(10)'
                    +', @c_Zone02     NVARCHAR(10)'
                    +', @c_Zone03     NVARCHAR(10)'
                    +', @c_Zone04     NVARCHAR(10)'
                    +', @c_Zone05     NVARCHAR(10)'
                    +', @c_Zone06     NVARCHAR(10)'
                    +', @c_Zone07     NVARCHAR(10)'
                    +', @c_Zone08     NVARCHAR(10)'
                    +', @c_Zone09     NVARCHAR(10)'
                    +', @c_Zone10     NVARCHAR(10)'
                    +', @c_Zone11     NVARCHAR(10)'
                    +', @c_Zone12     NVARCHAR(10)'
                    +', @c_ReplenFlag NVARCHAR(10)'
                    +', @c_Storerkey  NVARCHAR(15)'
                    +', @c_Facility   NVARCHAR(10)'
                    +', @c_ReplenType NVARCHAR(5)'
                    +', @c_DelPendingTask   NVARCHAR(10)'
                    +', @c_B2CChannelReplen NVARCHAR(10)'
                    +', @c_NoUCC            NVARCHAR(10)'   --ML02
                    +', @n_LocTolerance     FLOAT'          --ML02
                    +', @n_CartonTolerance  FLOAT'          --ML02
                    +', @n_PalletTolerance  FLOAT'          --ML02
                    +', @c_CurrentStorer    NVARCHAR(15)='''''
                    +', @c_CurrentSKU       NVARCHAR(20)='''''
                    +', @c_CurrentLOC       NVARCHAR(10)='''''
                    +', @c_LocationType     NVARCHAR(10)='''''

   --ML02-S
   SET @c_SQLParms2 = @c_SQLParms1
                    +', @c_CurrentPriority NVARCHAR(5)'
                    +', @n_Qty INT'
                    +', @n_QtyPicked INT'
                    +', @n_QtyAllocated INT'
                    +', @n_QtyLocationLimit INT'
                    +', @n_QtyLocationMinimum INT'
                    +', @n_CaseCnt INT'
                    +', @n_Pallet INT'
                    +', @c_PickCode NVARCHAR(10)'
                    +', @c_ReplExclProdNearExpiry NVARCHAR(10)'
                    +', @n_PendingTaskQty INT'
                    +', @n_ReplenQty INT OUTPUT'

   SET @c_SQLParms3 = @c_SQLParms2
                    +', @c_FromLot NVARCHAR(10)'
                    +', @c_FromLoc NVARCHAR(10)'
                    +', @c_FromID NVARCHAR(20)'
                    +', @n_OnHandQty INT'
                    +', @c_LogicalLocation NVARCHAR(20)'
                    +', @c_UCCNo NVARCHAR(20)'
                    +', @n_FullPackQty INT'
                    +', @n_PossibleCases INT'
                    +', @n_RemainingQty INT'
                    +', @n_FromQty INT'
                    +', @b_Success INT OUTPUT'
                    +', @c_ValidateMsg NVARCHAR(250)='''' OUTPUT'
   --ML02-E

   EXEC sp_ExecuteSQL @c_SQLStatement, @c_SQLParms1
      , @c_Zone01, @c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06, @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10
      , @c_Zone11, @c_Zone12, @c_ReplenFlag, @c_Storerkey, @c_Facility, @c_ReplenType, @c_DelPendingTask, @c_B2CChannelReplen
      , @c_NoUCC, @n_LocTolerance, @n_CartonTolerance, @n_PalletTolerance   --ML02

   OPEN CUR_ReplenSkuLoc

   WHILE @n_continue IN (1,2)
   BEGIN
      FETCH NEXT FROM CUR_ReplenSkuLoc INTO @c_CurrentPriority, @c_CurrentStorer, @c_CurrentSKU, @c_CurrentLOC, @n_Qty
                                          , @n_QtyPicked, @n_QtyAllocated, @n_QtyLocationLimit, @n_QtyLocationMinimum
                                          , @n_CaseCnt, @n_Pallet, @c_PickCode, @c_LocationType, @c_ReplExclProdNearExpiry
                                          , @n_PendingTaskQty   --ML01
                                          , @c_CommingleSku     --ML02

      IF @@FETCH_STATUS <> 0
         BREAK

      --ML02-S
      IF ISNULL(@c_CommingleSku,'') = '0' AND
         EXISTS(SELECT TOP 1 1 FROM LOTxLOCxID WITH (NOLOCK) WHERE Loc = @c_CurrentLOC AND Qty - QtyPicked > 0 AND Sku <> @c_CurrentSku)
      BEGIN
         CONTINUE
      END
      --ML02-E

      SET @n_ReplenQty = @n_QtyLocationLimit * @n_LocTolerance - ( @n_Qty - @n_QtyPicked ) - ISNULL(@n_PendingTaskQty,0)   --ML02

      SET @n_QtyAvailable = ( @n_Qty - @n_QtyPicked )

      --ML02-S
      IF ISNULL(@c_ReplenQty_Exp,'') <> ''
      BEGIN
          SET @c_SQLStatement = N'SET @n_ReplenQty = (' + @c_ReplenQty_Exp + ')'

          EXEC sp_ExecuteSQL @c_SQLStatement, @c_SQLParms2
             , @c_Zone01, @c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06, @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10
             , @c_Zone11, @c_Zone12, @c_ReplenFlag, @c_Storerkey, @c_Facility, @c_ReplenType, @c_DelPendingTask, @c_B2CChannelReplen
             , @c_NoUCC, @n_LocTolerance, @n_CartonTolerance, @n_PalletTolerance   --ML02
             , @c_CurrentStorer, @c_CurrentSKU, @c_CurrentLOC, @c_LocationType
             , @c_CurrentPriority, @n_Qty, @n_QtyPicked, @n_QtyAllocated, @n_QtyLocationLimit, @n_QtyLocationMinimum, @n_CaseCnt, @n_Pallet, @c_PickCode
             , @c_ReplExclProdNearExpiry, @n_PendingTaskQty
             , @n_ReplenQty OUTPUT
      END
      --ML02-E

      IF @b_debug = 1
      BEGIN
         SELECT [Storer]               = @c_CurrentStorer
              , [SKU]                  = @c_CurrentSKU
              , [Loc]                  = @c_CurrentLOC
              , [Qty Replen]           = @n_ReplenQty
              , [Qty Available]        = @n_QtyAvailable
              , [Qty Location Minimum] = @n_QtyLocationMinimum
              , [Location Limit]       = @n_QtyLocationLimit
              , [Case Qty]             = @n_CaseCnt
              , [Pallet Qty]           = @n_Pallet
              , [Location Type]        = @c_LocationType
      END

      IF @n_QtyAvailable > @n_QtyLocationMinimum
         CONTINUE

      IF @c_B2CChannelReplen = '1' AND @c_LocationType = 'PICK'
      BEGIN
         SET @n_PendingMoveIn = 0
         SET @n_ChannelInvQty = 0

         SELECT @n_PendingMoveIn = SUM(Qty)
           FROM #TEMP_REPLENISHMENT RP
          WHERE Storerkey = @c_CurrentStorer
            AND Sku = @c_CurrentSKU
            AND ToLoc = @c_CurrentLOC

         SELECT @n_ChannelInvQty = SUM(Qty)
           FROM CHANNELINV WITH(NOLOCK)
          WHERE Facility = @c_Facility
            AND Storerkey = @c_CurrentStorer
            AND Sku = @c_CurrentSKU
            AND Channel = 'B2C'

         SET @n_Temp = @n_ChannelInvQty - @n_QtyAvailable - @n_PendingMoveIn
         IF @n_Temp > 0 AND @n_ReplenQty < @n_Temp
            SET @n_ReplenQty = @n_Temp
      END

      IF ISNULL(@n_ReplenQty,0) <= 0
         CONTINUE

      -- Clean up pending Replenishment Tasks
      IF @c_DelPendingTask = '1' AND @b_CleanUpReplen = 0
      BEGIN
         SET @b_CleanUpReplen = 1
         IF @c_ReplenType = 'R'
         BEGIN
            DELETE R WITH(ROWLOCK)
              FROM dbo.REPLENISHMENT R
              JOIN dbo.SKUxLOC       SL  WITH(NOLOCK) ON SL.StorerKey = R.Storerkey AND SL.Sku = R.Sku AND SL.Loc = R.ToLoc
              JOIN dbo.LOC           LOC WITH(NOLOCK) ON SL.Loc = LOC.Loc
             WHERE R.Storerkey = @c_Storerkey
               AND R.Confirmed = 'N'
               AND R.ReplenishmentGroup NOT IN('DYNAMIC')
               AND SL.LocationType IN ('CASE', 'PICK')
               AND LOC.Facility = @c_Facility
         END
         ELSE IF @c_ReplenType = 'T'
         BEGIN
            DELETE T WITH(ROWLOCK)
              FROM TASKDETAIL T
              JOIN dbo.LOC    LOC WITH(NOLOCK) ON T.ToLoc = LOC.Loc
             WHERE T.Status = '0'
               AND T.SourceType = @c_SP_Name
               AND T.Storerkey = @c_Storerkey
               AND LOC.Facility = @c_Facility
         END
      END

      TRUNCATE TABLE #TEMP_LOT_SORT

      INSERT INTO #TEMP_LOT_SORT (LOT, SortColumn)
      SELECT DISTINCT LOT, ''
        FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
       WHERE LLI.StorerKey = @c_CurrentStorer
         AND LLI.SKU = @c_CurrentSKU
         AND LLI.LOC = @c_CurrentLOC
         AND LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked < 0

      IF @b_debug = 1
      BEGIN
         SELECT [CurrentLOC] = @c_CurrentLOC
      END

      IF ISNULL(@c_LotSortColumn_Exp,'')='' AND
         ISNULL(@c_ReplCond_LOT_Exp ,'')='' AND
         ISNULL(@c_ReplJoin_LOT_Exp ,'')='' AND   --ML02
         LEFT(@c_PickCode,5) = 'nspRP'      AND
         EXISTS(SELECT TOP 1 1 FROM dbo.sysobjects WHERE name = RTRIM(@c_PickCode) AND type = 'P')
      BEGIN
         SET @c_SQLStatement = @c_PickCode + ' ''' + ISNULL(REPLACE(@c_CurrentStorer,'''',''''''),'') + ''''
                             + ',''' + ISNULL(REPLACE(@c_CurrentSKU,'''',''''''),'') + ''''
                             + ',''' + ISNULL(REPLACE(@c_CurrentLOC,'''',''''''),'') + ''''
                             + ',''' + ISNULL(REPLACE(@c_Facility,'''',''''''),'') + ''''
                             + ','''''
         INSERT INTO #TEMP_LOT_SORT (LOT, SortColumn)
         EXEC(@c_SQLStatement)
      END
      ELSE
      BEGIN
         SET @c_SQLStatement = N'INSERT INTO #TEMP_LOT_SORT (LOT, SortColumn)'
           +' SELECT LLI.LOT'
           +      ', SortColumn = MIN('
           +            CASE WHEN ISNULL(@c_LotSortColumn_Exp,'')<>'' THEN ISNULL(@c_LotSortColumn_Exp,'')
                             ELSE 'ISNULL(CONVERT(NVARCHAR(8),LA.LOTTABLE04,112),''00000000'') + ISNULL(CONVERT(NVARCHAR(8),LA.LOTTABLE05,112),''00000000'')'
                        END + ')'
           +  ' FROM dbo.LOTxLOCxID   LLI WITH(NOLOCK)'
           +  ' JOIN dbo.LOC          LOC WITH(NOLOCK) ON LLI.LOC=LOC.LOC'
           +  ' JOIN dbo.ID           ID  WITH(NOLOCK) ON LLI.ID=ID.ID'
           +  ' JOIN dbo.LOT          LOT WITH(NOLOCK) ON LLI.LOT=LOT.LOT'
           +  ' JOIN dbo.LOTATTRIBUTE LA  WITH(NOLOCK) ON LLI.LOT=LA.LOT'
           +  ' JOIN dbo.SKU          SKU WITH(NOLOCK) ON LLI.StorerKey=SKU.StorerKey AND LLI.SKU=SKU.SKU'
           +  ' JOIN dbo.SKUxLOC      SL  WITH(NOLOCK) ON LLI.StorerKey=SL.StorerKey AND LLI.SKU=SL.SKU AND LLI.LOC=SL.LOC'

         IF ISNULL(@c_ReplJoin_LOT_Exp,'') <> ''                                --ML02
            SET @c_SQLStatement = @c_SQLStatement + ' ' + @c_ReplJoin_LOT_Exp   --ML02

         SET @c_SQLStatement = @c_SQLStatement
           + ' WHERE LLI.StorerKey = ''' + ISNULL(REPLACE(@c_CurrentStorer,'''',''''''),'') + ''''
           +   ' AND LLI.SKU = '''       + ISNULL(REPLACE(@c_CurrentSKU   ,'''',''''''),'') + ''''
           +   ' AND LOC.Facility = '''  + ISNULL(REPLACE(@c_Facility     ,'''',''''''),'') + ''''
           +   ' AND LLI.LOC <> '''      + ISNULL(REPLACE(@c_CurrentLOC   ,'''',''''''),'') + ''''
           +   ' AND LOC.LocationFlag NOT IN (''DAMAGE'',''HOLD'')'
           +   ' AND LOC.Status = ''OK'''
           +   ' AND LOT.Status = ''OK'''
           +   ' AND ID.Status = ''OK'''
           +   ' AND (LLI.Qty - LLI.QtyPicked - LLI.QtyAllocated) > 0'
           +   ' AND NOT EXISTS(SELECT 1 FROM #TEMP_LOT_SORT L WHERE L.LOT = LLI.LOT)'

         IF ISNULL(@c_ReplCond_LOT_Exp,'') <> ''
            SET @c_SQLStatement = @c_SQLStatement
              +' AND (' + @c_ReplCond_LOT_Exp + ')'
         ELSE
            SET @c_SQLStatement = @c_SQLStatement
              +' AND LOC.Locationtype NOT IN (''CASE'',''PICK'')'
              +' AND SL.Locationtype  NOT IN (''CASE'',''PICK'')'

         SET @c_SQLStatement = @c_SQLStatement
           +' GROUP BY LLI.Lot'
           +' ORDER BY SortColumn'

         IF @b_debug = 1
         BEGIN
            SET @c_SQL = 'SELECT LotSortColumn_SQL = ''' + ISNULL(REPLACE(@c_SQLStatement,'''',''''''),'') + ''''
            EXEC(@c_SQL)
         END

         EXEC sp_ExecuteSQL @c_SQLStatement, @c_SQLParms1
            , @c_Zone01, @c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06, @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10
            , @c_Zone11, @c_Zone12, @c_ReplenFlag, @c_Storerkey, @c_Facility, @c_ReplenType, @c_DelPendingTask, @c_B2CChannelReplen
            , @c_NoUCC, @n_LocTolerance, @n_CartonTolerance, @n_PalletTolerance   --ML02
            , @c_CurrentStorer, @c_CurrentSKU, @c_CurrentLOC, @c_LocationType
      END

      SET @n_NearExpiryDay = 0
      IF ISNULL(@c_ReplExclProdNearExpiry,'0') <> '0' AND ISNUMERIC(@c_ReplExclProdNearExpiry) = 1
      BEGIN
         SET @n_NearExpiryDay = TRY_PARSE(ISNULL(@c_ReplExclProdNearExpiry,'') AS INT)

         DELETE #TEMP_LOT_SORT
           FROM #TEMP_LOT_SORT
           JOIN LOTATTRIBUTE LA(NOLOCK) ON #TEMP_LOT_SORT.Lot = LA.Lot
          WHERE ISNULL(#TEMP_LOT_SORT.SortColumn,'') <> ''  --Exclude overallocation lot
            AND DATEDIFF(DAY, GETDATE(), LA.Lottable04) <= @n_NearExpiryDay
      END

      SELECT @n_Cnt = COUNT(1) FROM #TEMP_LOT_SORT

      IF @b_debug = 1
      BEGIN
         IF @n_Cnt = 0
           SELECT '**** No Stock Available'
      END

      IF @n_Cnt = 0
         CONTINUE

      DECLARE CUR_LOT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT LOT, SortColumn
      FROM #TEMP_LOT_SORT
      ORDER BY SortColumn, LOT

      OPEN CUR_LOT

      SET @n_RemainingQty = @n_ReplenQty

      WHILE @n_RemainingQty > 0 AND @n_continue IN (1,2)
      BEGIN
         FETCH NEXT FROM CUR_LOT INTO @c_FromLot, @c_SortColumn

         IF @@FETCH_STATUS <> 0
            BREAK

         IF @b_debug = 1
         BEGIN
            SELECT [LOT] = @c_FromLOT
         END

         SET @c_SQLStatement = N'DECLARE CUR_LOTxLOCxID_REPLEN CURSOR FAST_FORWARD READ_ONLY FOR'
           +' SELECT FromLoc = LLI.LOC'
           +      ', FromID = LLI.ID'
           +      ', OnHandQty = CASE WHEN ISNULL(UCC.UCCNo,'''')<>'''' THEN UCC.Qty ELSE (LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED) END'
           +      ', FromLogicalLOC = LOC.LogicalLocation'
           +      ', UCCNo = ISNULL(UCC.UCCNo,'''')'
           +  ' FROM dbo.LOTxLOCxID   LLI WITH(NOLOCK)'
           +  ' JOIN dbo.LOC          LOC WITH(NOLOCK) ON LLI.LOC=LOC.LOC'
           +  ' JOIN dbo.ID           ID  WITH(NOLOCK) ON LLI.ID=ID.ID'
           +  ' JOIN dbo.LOT          LOT WITH(NOLOCK) ON LLI.LOT=LOT.LOT'
           +  ' JOIN dbo.LOTATTRIBUTE LA  WITH(NOLOCK) ON LLI.LOT=LA.LOT'
           +  ' JOIN dbo.SKU          SKU WITH(NOLOCK) ON LLI.StorerKey=SKU.StorerKey AND LLI.SKU=SKU.SKU'
           +  ' JOIN dbo.SKUxLOC      SL  WITH(NOLOCK) ON LLI.StorerKey=SL.StorerKey AND LLI.SKU=SL.SKU AND LLI.LOC=SL.LOC'
           +  ' LEFT JOIN dbo.UCC     UCC WITH(NOLOCK) ON LLI.Storerkey=UCC.Storerkey AND LLI.Sku=UCC.Sku AND LLI.Lot=UCC.Lot AND LLI.Loc=UCC.Loc AND LLI.ID=UCC.ID'
           +                                      ' AND UCC.Status=''1'' AND LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED>=UCC.Qty AND UCC.Qty>0'
           +                                      CASE WHEN @c_LocationType='PICK' AND ISNULL(@c_NoUCC,'')<>'1' THEN '' ELSE ' AND 1=2' END   --ML02

         IF ISNULL(@c_ReplJoin_LLI_Exp,'') <> ''                                --ML02
            SET @c_SQLStatement = @c_SQLStatement + ' ' + @c_ReplJoin_LLI_Exp   --ML02

         SET @c_SQLStatement = @c_SQLStatement
           + ' WHERE LLI.LOT='''      + ISNULL(REPLACE(@c_FromLot ,'''',''''''),'') + ''''
           +   ' AND LOC.Facility=''' + ISNULL(REPLACE(@c_Facility,'''',''''''),'') + ''''
           +   ' AND LOC.LocationFlag NOT IN (''DAMAGE'', ''HOLD'')'
           +   ' AND LOC.Status=''OK'''
           +   ' AND LOT.Status=''OK'''
           +   ' AND ID.Status=''OK'''
           +   ' AND (LLI.QTY-LLI.QTYPICKED-LLI.QTYALLOCATED)>0'

         IF ISNULL(@c_ReplCond_LOT_Exp,'') <> ''
            SET @c_SQLStatement = @c_SQLStatement
              +' AND (' + @c_ReplCond_LOT_Exp + ')'
         ELSE
            SET @c_SQLStatement = @c_SQLStatement
              +' AND LOC.Locationtype NOT IN (''CASE'',''PICK'')'
              +' AND SL.Locationtype  NOT IN (''CASE'',''PICK'')'

         IF ISNULL(@c_ReplCond_LLI_Exp,'') <> ''
            SET @c_SQLStatement = @c_SQLStatement
              +' AND (' + @c_ReplCond_LLI_Exp + ')'

         IF ISNULL(@c_Sorting_LLI_Exp,'') <> ''
            SET @c_SQLStatement = @c_SQLStatement
              + ' ORDER BY ' + @c_Sorting_LLI_Exp
         ELSE
            SET @c_SQLStatement = @c_SQLStatement
              + ' ORDER BY OnHandQty, FromLogicalLOC, FromLoc, UCCNo'

         IF @b_debug = 1
         BEGIN
            SET @c_SQL = 'SELECT LLI_SQL = ''' + ISNULL(REPLACE(@c_SQLStatement,'''',''''''),'') + ''''
            EXEC(@c_SQL)
         END

         EXEC sp_ExecuteSQL @c_SQLStatement, @c_SQLParms1
            , @c_Zone01, @c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06, @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10
            , @c_Zone11, @c_Zone12, @c_ReplenFlag, @c_Storerkey, @c_Facility, @c_ReplenType, @c_DelPendingTask, @c_B2CChannelReplen
            , @c_NoUCC, @n_LocTolerance, @n_CartonTolerance, @n_PalletTolerance   --ML02
            , @c_CurrentStorer, @c_CurrentSKU, @c_CurrentLOC, @c_LocationType

         OPEN CUR_LOTxLOCxID_REPLEN

         WHILE @n_RemainingQty > 0 AND @n_continue IN (1,2)
         BEGIN
            FETCH NEXT FROM CUR_LOTxLOCxID_REPLEN INTO @c_FromLoc, @c_FromID, @n_OnHandQty, @c_LogicalLocation, @c_UCCNo

            IF @@FETCH_STATUS <> 0
               BREAK

            -- **** Update OnHandQTY to avoid getting the same OnHandQTY when loop into 2nd Pick Location with same SKU *** --
            SET @n_LotSKUQTY = 0

            IF ISNULL(@c_UCCNo,'')=''
            BEGIN
               SELECT @n_LotSKUQTY = SUM(QTY)
               FROM #TEMP_REPLENISHMENT RP
               WHERE Lot = @c_FromLot
                 AND FromLOC = @c_FromLoc
                 AND ID = @c_FromId
            END

            IF @b_debug = 1
            BEGIN
               SELECT [Original Lot QTY]   = @n_OnHandQty
                    , [Located Replen QTY] = @n_LotSKUQTY
            END

            SET @n_OnHandQty = @n_OnHandQty - ISNULL(@n_LotSKUQTY,0)

            IF @n_OnHandQTy <= 0
               CONTINUE

            IF @b_debug = 1
            BEGIN
               SELECT [From Loc]     = @c_FromLOC
                    , [From lot]     = @c_FromLot
                    , [From ID]      = @c_FromId
                    , [@n_OnHandQty] = @n_OnHandQty
                    , [UCCNo]        = @c_UCCNo
            END

            IF @n_CaseCnt IS NULL OR @n_CaseCnt = 0
               SET @n_CaseCnt = 1

            --ML02-S
            IF @c_LocationType = 'PICK'
            BEGIN
               SET @n_FullPackQty = CASE WHEN ISNULL(@c_UCCNo,'')<>''  THEN @n_OnHandQty
                                         WHEN ISNULL(@n_CaseCnt,0) > 1 THEN @n_CaseCnt
                                         ELSE 1
                                    END
            END
            ELSE IF @c_LocationType = 'CASE'
            BEGIN
               SET @n_FullPackQty = CASE WHEN ISNULL(@c_FromID,'')<>'' THEN @n_OnHandQty
                                         WHEN ISNULL(@n_Pallet,0) > 1  THEN @n_Pallet
                                         ELSE 1
                                    END
            END
            ELSE
               SET @n_FullPackQty = 0

            SET @n_PossibleCases = 0
            IF @n_FullPackQty > 0
            BEGIN
               -- If residual qty >= Tolerance, round up to full Carton/Pallet
               IF @n_FullPackQty > 1
                     AND @n_RemainingQty % @n_FullPackQty > 0
                     AND @n_RemainingQty % @n_FullPackQty >= @n_FullPackQty * IIF(@c_LocationType = 'CASE', @n_PalletTolerance, @n_CartonTolerance)
                  SET @n_PossibleCases = CEILING(CAST(@n_RemainingQty AS FLOAT) / @n_FullPackQty)
               ELSE
                  SET @n_PossibleCases = FLOOR(CAST(@n_RemainingQty AS FLOAT) / @n_FullPackQty)
            END

            IF @n_OnHandQty <= @n_PossibleCases * @n_FullPackQty
               SET @n_FromQty = @n_OnHandQty
            ELSE
               SET @n_FromQty = @n_PossibleCases * @n_FullPackQty
            --ML02-E

            IF @b_debug = 1
            BEGIN
               SELECT [On Hand Qty]    = @n_OnHandQty
                    , [Case Cnt]       = @n_CaseCnt
                    , [Possible Cases] = @n_PossibleCases
                    , [Full Pack Qty]  = @n_FullPackQty
                    , [Remaining Qty]  = @n_RemainingQty
                    , [From Qty]       = @n_FromQty
                    , [From ID]        = @c_FromID
                    , [UCCNo]          = @c_UCCNo
            END

            SET @n_RemainingQty = @n_RemainingQty - @n_FromQty

            IF @n_FromQty > 0
               AND @n_continue IN (1,2)
            BEGIN
               SELECT @c_Packkey = PACK.PackKey
                    , @c_UOM = PACK.PackUOM3
                 FROM SKU  WITH(NOLOCK)
                 JOIN PACK WITH(NOLOCK) ON SKU.PackKey = PACK.Packkey
                WHERE SKU.StorerKey = @c_CurrentStorer AND
                      SKU.SKU = @c_CurrentSKU

               --ML02-S
               IF EXISTS(SELECT TOP 1 1 FROM dbo.CODELKUP WITH(NOLOCK)
                   WHERE ListName = 'REPLENCFG' AND Code2 = @c_SP_Name AND Storerkey = @c_Storerkey AND Code LIKE 'Validation%')
               BEGIN
                  DECLARE CUR_Validation CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT ValidateMsg      = ISNULL(TRIM(Long), '')
                       , ValidateMsg_Exp  = ISNULL(TRIM(Notes2), '')
                       , ValidateExp      = ISNULL(TRIM(Notes), '')
                       , ValidateAction   = ISNULL(TRIM(UDF01), '')
                       , ValidateStep     = ISNULL(TRIM(SUBSTRING(Code,11,LEN(Code))), '')
                    FROM dbo.CODELKUP WITH(NOLOCK)
                   WHERE ListName = 'REPLENCFG' AND Code2 = @c_SP_Name AND Storerkey = @c_Storerkey AND Code LIKE 'Validation%'
                     AND ISNULL(Notes,'')<>''
                   ORDER BY Code

                  OPEN CUR_Validation

                  WHILE @n_continue IN (1,2)
                  BEGIN
                     FETCH NEXT FROM CUR_Validation
                      INTO @c_ValidateMsg, @c_ValidateMsg_Exp, @c_ValidateExp, @c_ValidateAction, @c_ValidateStep

                     IF @@FETCH_STATUS<>0
                        BREAK

                     SELECT @b_success = 0

                     IF @c_ValidateAction='DECODE'
                        SET @c_SQLStatement = 'SET @b_success=1 BEGIN ' +CHAR(10)+ @c_ValidateExp +CHAR(10)+ 'END'
                     ELSE
                        SET @c_SQLStatement = 'IF (' + @c_ValidateExp + ') SET @b_success=1'

                     BEGIN TRY
                        EXEC sp_ExecuteSQL @c_SQLStatement, @c_SQLParms3
                           , @c_Zone01, @c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06, @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10
                           , @c_Zone11, @c_Zone12, @c_ReplenFlag, @c_Storerkey, @c_Facility, @c_ReplenType, @c_DelPendingTask, @c_B2CChannelReplen
                           , @c_NoUCC, @n_LocTolerance, @n_CartonTolerance, @n_PalletTolerance
                           , @c_CurrentStorer, @c_CurrentSKU, @c_CurrentLOC, @c_LocationType
                           , @c_CurrentPriority, @n_Qty, @n_QtyPicked, @n_QtyAllocated, @n_QtyLocationLimit, @n_QtyLocationMinimum, @n_CaseCnt, @n_Pallet, @c_PickCode
                           , @c_ReplExclProdNearExpiry, @n_PendingTaskQty, @n_ReplenQty
                           , @c_FromLot, @c_FromLoc, @c_FromID, @n_OnHandQty, @c_LogicalLocation, @c_UCCNo, @n_FullPackQty, @n_PossibleCases, @n_RemainingQty, @n_FromQty
                           , @b_Success OUTPUT
                     END TRY
                     BEGIN CATCH
                        SET @n_continue = 3
                        SELECT @c_errmsg = ISNULL(ERROR_MESSAGE(),'')
                             , @n_err = 63521
                        SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err) +
                              ': Validation Error - Step ' + ISNULL(@c_ValidateStep,'') + ' (' + ISNULL(@c_SP_Name,'') + ') (SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
                        BREAK
                     END CATCH

                     IF ISNULL(@b_success,0)<>1
                     BEGIN
                        IF ISNULL(@c_ValidateMsg_Exp,'') <> ''
                        BEGIN
                           SET @c_SQLStatement = 'SET @c_ValidateMsg = (' + @c_ValidateMsg_Exp +')'
                           EXEC sp_ExecuteSQL @c_SQLStatement, @c_SQLParms3
                              , @c_Zone01, @c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06, @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10
                              , @c_Zone11, @c_Zone12, @c_ReplenFlag, @c_Storerkey, @c_Facility, @c_ReplenType, @c_DelPendingTask, @c_B2CChannelReplen
                              , @c_NoUCC, @n_LocTolerance, @n_CartonTolerance, @n_PalletTolerance
                              , @c_CurrentStorer, @c_CurrentSKU, @c_CurrentLOC, @c_LocationType
                              , @c_CurrentPriority, @n_Qty, @n_QtyPicked, @n_QtyAllocated, @n_QtyLocationLimit, @n_QtyLocationMinimum, @n_CaseCnt, @n_Pallet, @c_PickCode
                              , @c_ReplExclProdNearExpiry, @n_PendingTaskQty, @n_ReplenQty
                              , @c_FromLot, @c_FromLoc, @c_FromID, @n_OnHandQty, @c_LogicalLocation, @c_UCCNo, @n_FullPackQty, @n_PossibleCases, @n_RemainingQty, @n_FromQty
                              , @b_Success, @c_ValidateMsg OUTPUT
                        END

                        SET @n_err = 63522
                        SET @c_errmsg = ISNULL(@c_ValidateMsg,'')

                        IF ISNULL(@c_ValidateAction,'')<>'WARNING'
                        BEGIN
                           SET @n_continue = 3
                           BREAK
                        END
                        ELSE IF ISNULL(@c_WarningMsg,'')=''
                        BEGIN
                           SET @c_WarningMsg = ISNULL(@c_ValidateMsg,'')
                        END
                     END
                  END
                  CLOSE CUR_Validation
                  DEALLOCATE CUR_Validation

                  IF @n_continue NOT IN (1,2)
                     BREAK
               END
               --ML02-E

               INSERT #TEMP_REPLENISHMENT
                     ( StorerKey
                     , SKU
                     , FromLOC
                     , ToLOC
                     , Lot
                     , Id
                     , Qty
                     , UOM
                     , PackKey
                     , Priority
                     , QtyMoved
                     , QtyInPickLOC
                     , UCCNo
                     )
               VALUES( @c_CurrentStorer
                     , @c_CurrentSKU
                     , @c_FromLOC
                     , @c_CurrentLOC
                     , @c_FromLot
                     , @c_FromId
                     , @n_FromQty
                     , @c_UOM
                     , @c_Packkey
                     , @c_CurrentPriority
                     , 0
                     , 0
                     , @c_UCCNo
                     )
            END -- if from qty > 0
         END -- while CUR_LOTxLOCxID_REPLEN

         CLOSE CUR_LOTxLOCxID_REPLEN
         DEALLOCATE CUR_LOTxLOCxID_REPLEN
      END --while CUR_LOT

      CLOSE CUR_LOT
      DEALLOCATE CUR_LOT
   END -- while CUR_ReplenSkuLoc

   CLOSE CUR_ReplenSkuLoc
   DEALLOCATE CUR_ReplenSkuLoc

   IF @n_continue NOT IN (1,2)   --ML02
      GOTO EXIT_SP               --ML02

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      /* Update the column QtyInPickLOC in the Replenishment Table */
      UPDATE RP
         SET QtyInPickLOC = SKUxLOC.Qty - SKUxLOC.QtyPicked
        FROM #TEMP_REPLENISHMENT RP, SKUxLOC(NOLOCK)
       WHERE RP.StorerKey = SKUxLOC.StorerKey
         AND RP.SKU = SKUxLOC.SKU
         AND RP.toLOC = SKUxLOC.LOC
   END --continue end

   --ML01-S
   -- Update TransitLOC
   IF ISNULL(@c_TransitLOC_Exp,'')<>'' AND EXISTS(SELECT TOP 1 1 FROM #TEMP_REPLENISHMENT)
   BEGIN
      SET @c_SQLStatement = 'UPDATE RPL SET TransitLOC = ' + @c_TransitLOC_Exp
        + ' FROM #TEMP_REPLENISHMENT RPL'
        + ' LEFT JOIN dbo.LOC FRLOC WITH(NOLOCK) ON RPL.FromLoc=FRLOC.Loc'
        + ' LEFT JOIN dbo.LOC TOLOC WITH(NOLOCK) ON RPL.ToLoc=TOLOC.Loc'
        + ' LEFT JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON RPL.Lot=LA.Lot'
        + ' LEFT JOIN dbo.SKU SKU WITH(NOLOCK) ON RPL.StorerKey=SKU.Storerkey AND RPL.Sku=SKU.Sku'

      EXEC sp_ExecuteSQL @c_SQLStatement, @c_SQLParms1
         , @c_Zone01, @c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06, @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10
         , @c_Zone11, @c_Zone12, @c_ReplenFlag, @c_Storerkey, @c_Facility, @c_ReplenType, @c_DelPendingTask, @c_B2CChannelReplen
         , @c_NoUCC, @n_LocTolerance, @n_CartonTolerance, @n_PalletTolerance   --ML02

      IF @b_debug = 1
      BEGIN
         SET @c_SQL = 'SELECT Update_TransitLOC_SQL = ''' + ISNULL(REPLACE(@c_SQLStatement,'''',''''''),'') + ''''
         EXEC(@c_SQL)
      END
   END
   --ML01-E


   /* Insert Into Replenishment Table Now */
   SET @c_SQLStatement = 'DECLARE CUR1 CURSOR FAST_FORWARD READ_ONLY FOR'
     + ' SELECT RPL.FromLoc'
     +       ', RPL.Id'
     +       ', RPL.ToLoc'
     +       ', RPL.Sku'
     +       ', RPL.Qty'
     +       ', RPL.StorerKey'
     +       ', RPL.Lot'
     +       ', RPL.PackKey'
     +       ', Priority='     + CASE WHEN ISNULL(@c_TaskPriority_Exp,'')<>'' THEN @c_TaskPriority_Exp
                                      WHEN ISNULL(@c_TaskPriority_Val,'')<>'' THEN ''''+REPLACE(@c_TaskPriority_Val,'''','''''')+''''
                                      ELSE 'RPL.Priority' END

   SET @c_SQLStatement = @c_SQLStatement
     +       ', RPL.UOM'
     +       ', RPL.UCCNo'
     +       ', FRLOC.LogicalLocation'
     +       ', TOLOC.LogicalLocation'
     +       ', RPL.TransitLOC'
     +       ', TaskGrouping=' + CASE WHEN ISNULL(@c_TaskGrouping_Exp,'')<>'' THEN @c_TaskGrouping_Exp ELSE '''''' END

   --ML01-S
   SET @c_SQLStatement = @c_SQLStatement
     +       ', TaskType='     + CASE WHEN ISNULL(@c_TaskType_Exp    ,'')<>'' THEN @c_TaskType_Exp
                                      WHEN ISNULL(@c_TaskType_Val    ,'')<>'' THEN '''' + REPLACE(RTRIM(@c_TaskType_Val),'''','''''') + ''''
                                      ELSE '''RPF'''
                                 END

   SET @c_SQLStatement = @c_SQLStatement
     +       ', PickMethod='   + CASE WHEN ISNULL(@c_PickMethod_Exp  ,'')<>'' THEN @c_PickMethod_Exp
                                      WHEN ISNULL(@c_PickMethod_Val  ,'')<>'' THEN '''' + REPLACE(RTRIM(@c_PickMethod_Val),'''','''''') + ''''
                                      ELSE '''PP'''
                                 END
   --ML01-E

   SET @c_SQLStatement = @c_SQLStatement
     + ' FROM #TEMP_REPLENISHMENT RPL'
     + ' LEFT JOIN dbo.LOC FRLOC WITH(NOLOCK) ON RPL.FromLoc=FRLOC.Loc'
     + ' LEFT JOIN dbo.LOC TOLOC WITH(NOLOCK) ON RPL.ToLoc=TOLOC.Loc'
     + ' LEFT JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON RPL.Lot=LA.Lot'
     + ' LEFT JOIN dbo.SKU SKU WITH(NOLOCK) ON RPL.StorerKey=SKU.Storerkey AND RPL.Sku=SKU.Sku'
     + ' ORDER BY TaskGrouping, FRLOC.LogicalLocation, RPL.FromLoc'

   IF @b_debug = 1
   BEGIN
      SET @c_SQL = 'SELECT Replenishment_SQL = ''' + ISNULL(REPLACE(@c_SQLStatement,'''',''''''),'') + ''''
      EXEC(@c_SQL)
   END

   EXEC sp_ExecuteSQL @c_SQLStatement, @c_SQLParms1
      , @c_Zone01, @c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06, @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10
      , @c_Zone11, @c_Zone12, @c_ReplenFlag, @c_Storerkey, @c_Facility, @c_ReplenType, @c_DelPendingTask, @c_B2CChannelReplen
      , @c_NoUCC, @n_LocTolerance, @n_CartonTolerance, @n_PalletTolerance   --ML02

   OPEN CUR1

   SET @c_TaskGrouping_Prev = ''
   SET @c_GroupKey = ''

   WHILE @n_continue IN (1,2)
   BEGIN
      FETCH NEXT FROM CUR1 INTO @c_FromLoc, @c_FromId, @c_CurrentLOC,
            @c_CurrentSKU, @n_FromQty, @c_CurrentStorer, @c_FromLot, @c_PackKey,
            @c_Priority, @c_UOM, @c_UCCNo, @c_FromLogicalLocation, @c_CurrentLogicalLocation,
            @c_TransitLOC, @c_TaskGrouping, @c_TaskType, @c_PickMethod   --ML01

      IF @@FETCH_STATUS <> 0
         BREAK

      --ML01-S
      IF ISNULL(@c_TaskGrouping,'') <> '' AND ISNULL(@c_TaskGrouping,'') <> ISNULL(@c_TaskGrouping_Prev,'')
         OR (@c_ReplenType = 'R' AND ISNULL(@c_GroupKey,'') = '')
      BEGIN
         EXECUTE nspg_GetKey
                 @keyname       = 'REPLENISHGROUP'
               , @fieldlength   = 10
               , @keystring     = @c_ReplenishmentGroup OUTPUT
               , @b_success     = @b_success   OUTPUT
               , @n_err         = @n_err       OUTPUT
               , @c_errmsg      = @c_errmsg    OUTPUT

         IF NOT @b_success = 1
         BEGIN
            SET @n_continue = 3
            BREAK
         END

         SET @c_GroupKey = @c_ReplenishmentGroup
         SET @c_TaskGrouping_Prev = @c_TaskGrouping
      END

      IF ISNULL(@c_TransitLOC,'') <> ''
      BEGIN
         SET @c_ToLOC    = @c_TransitLOC
         SET @c_FinalLOC = @c_CurrentLOC
         SET @c_CurrentLogicalLocation = @c_ToLOC

         SELECT @c_CurrentLogicalLocation = LogicalLocation
           FROM LOC(NOLOCK)
          WHERE Loc = @c_ToLOC
      END
      ELSE
      BEGIN
         SET @c_ToLOC    = @c_CurrentLOC
         SET @c_FinalLOC = ''
      END
      --ML01-E


      IF @c_ReplenType = 'R'
      BEGIN
         EXECUTE nspg_GetKey 'REPLENISHKEY', 10, @c_ReplenishmentKey OUTPUT,
            @b_success OUTPUT, @n_err OUTPUT, @c_errmsg OUTPUT

         IF NOT @b_success = 1
            BREAK

         IF @b_success = 1
         BEGIN
            INSERT REPLENISHMENT
                  ( replenishmentgroup
                  , ReplenishmentKey
                  , StorerKey
                  , Sku
                  , FromLoc
                  , ToLoc
                  , Lot
                  , Id
                  , Qty
                  , UOM
                  , PackKey
                  , Confirmed
                  , RefNo
                  , OriginalFromLoc   --ML01
                  , Priority          --ML01
                  )
            VALUES( @c_GroupKey
                  , @c_ReplenishmentKey
                  , @c_CurrentStorer
                  , @c_CurrentSku
                  , @c_FromLoc
                  , @c_CurrentLOC
                  , @c_FromLot
                  , @c_FromId
                  , @n_FromQty
                  , @c_UOM
                  , @c_PackKey
                  , 'N'
                  , @c_UCCNo
                  , @c_TransitLOC   --ML01
                  , LEFT(@c_Priority,5) --ML01
                  )

            SELECT @n_err = @@ERROR
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250), @n_err)
                    , @n_err = 63524
               SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err) +
                     ': Insert REPLENISHMENT table failed. (' + ISNULL(@c_SP_Name,'') + ') ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
            END
         END -- IF @b_success = 1
      END
      ELSE IF @c_ReplenType = 'T'
      BEGIN
         SET @c_UOM = CASE WHEN ISNULL(@c_UCCNo,'')<>'' THEN '2' ELSE '6' END   --ML01

         EXEC isp_InsertTaskDetail
              @c_TaskType              = @c_TaskType    --ML01
            , @c_Storerkey             = @c_CurrentStorer
            , @c_Sku                   = @c_CurrentSku
            , @c_Lot                   = @c_FromLot
            , @c_UOM                   = @c_UOM
            , @n_UOMQty                = @n_FromQty
            , @n_Qty                   = @n_FromQty
            , @c_FromLoc               = @c_FromLoc
            , @c_LogicalFromLoc        = @c_FromLogicalLocation
            , @c_FromID                = @c_FromId
            , @c_ToLoc                 = @c_ToLOC
            , @c_LogicalToLoc          = @c_CurrentLogicalLocation
            , @c_ToID                  = @c_FromId
            , @c_CaseID                = @c_UCCNo
            , @c_DropID                = @c_UCCNo
            , @c_PickMethod            = @c_PickMethod  --ML01
            , @c_Priority              = @c_Priority
            , @c_SourcePriority        = @c_Priority
            , @c_SourceType            = @c_SP_Name
            , @c_OrderKey              = ''
            , @c_GroupKey              = @c_GroupKey   --ML01
            , @c_Loadkey               = ''
            , @c_AreaKey               = '?F'  -- ?F=Get from location areakey
            , @c_FinalLOC              = @c_FinalLOC   --ML01
            , @c_Message03             = ''
            , @c_SplitTaskByCase       = 'N'
            , @c_ReservePendingMoveIn  = 'Y'
            , @n_SystemQty             = @n_FromQty
            , @b_Success               = @b_Success OUTPUT
            , @n_Err                   = @n_err OUTPUT
            , @c_ErrMsg                = @c_errmsg OUTPUT

         IF @b_Success <> 1
            SELECT @n_continue = 3
      END
   END -- While CUR1

   CLOSE CUR1
   DEALLOCATE CUR1
   -- End Insert Replenishment

EXIT_SP:
   IF ISNULL(@c_WarningMsg,'')<>''   --ML02
      SET @n_continue = 3            --ML02

   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_starttcnt
            COMMIT TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, @c_SP_Name
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT   @b_success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
   END
END --SP end
GO
GRANT EXECUTE ON  [dbo].[isp_GenReplenishmentTask_01] TO [NSQL]
GO
