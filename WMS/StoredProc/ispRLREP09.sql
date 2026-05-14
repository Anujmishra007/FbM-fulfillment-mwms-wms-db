SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: ispRLREP09                                         */
/* Creation Date: 2025-12-12                                            */
/* Copyright: MAERSK                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-8536 - Brazil-Cajamar-ONBR-Consolidate RPL per PND      */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 2025-12-12   Michael  1.0  DevOps Combine Script                     */
/* 2026-04-30   Michael  1.1  FCR-8087 New REPLENCFG SQL_JOIN_TASK,ToID,*/
/*                            NoQtyReplen,SetTransitLoc (ML01)          */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[ispRLREP09]
   @c_Facility  NVARCHAR(10) = ''
 , @c_zone02    NVARCHAR(10) = ''
 , @c_zone03    NVARCHAR(10) = ''
 , @c_zone04    NVARCHAR(10) = ''
 , @c_zone05    NVARCHAR(10) = ''
 , @c_zone06    NVARCHAR(10) = ''
 , @c_zone07    NVARCHAR(10) = ''
 , @c_zone08    NVARCHAR(10) = ''
 , @c_zone09    NVARCHAR(10) = ''
 , @c_zone10    NVARCHAR(10) = ''
 , @c_zone11    NVARCHAR(10) = ''
 , @c_zone12    NVARCHAR(10) = ''
 , @c_Storerkey NVARCHAR(15) = ''
 , @n_err       INT           OUTPUT
 , @c_ErrMsg    NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue               INT = 1
         , @n_starttcnt              INT = @@TRANCOUNT
         , @b_Success                INT = 0
         , @c_Replenishmentkey       NVARCHAR(10) = ''
         , @c_Storer                 NVARCHAR(15) = ''
         , @c_Sku                    NVARCHAR(20) = ''
         , @c_Lot                    NVARCHAR(10) = ''
         , @n_Qty                    INT          = 0
         , @n_QtyReplen              INT          = 0    --ML01
         , @c_FromLOC                NVARCHAR(10) = ''
         , @c_FromLogicalLoc         NVARCHAR(10) = ''
         , @c_ID                     NVARCHAR(18) = ''
         , @c_ToLOC                  NVARCHAR(10) = ''
         , @c_ToLogicalLoc           NVARCHAR(10) = ''
         , @c_ToID                   NVARCHAR(18) = ''   --ML01
         , @c_FinalLOC               NVARCHAR(10) = ''
         , @c_Priority               NVARCHAR(5)  = ''
         , @c_UCCNo                  NVARCHAR(20) = ''
         , @c_TransitLOC             NVARCHAR(10) = ''
         , @c_TaskGrouping           NVARCHAR(100)= ''
         , @c_GroupKey               NVARCHAR(10) = ''
         , @c_TaskGrouping_Prev      NVARCHAR(100)= ''
         , @c_UOM                    NVARCHAR(10) = ''
         , @c_SQLStatement           NVARCHAR(MAX)= ''
         , @c_SQLParms               NVARCHAR(MAX)= ''
         , @c_ReplCond_Exp           NVARCHAR(MAX)= ''
         , @c_ReplJoin_Exp           NVARCHAR(MAX)= ''
         , @c_TaskJoin_Exp           NVARCHAR(MAX)= ''   --ML01
         , @c_TransitLOC_Exp         NVARCHAR(MAX)= ''
         , @c_TaskGrouping_Exp       NVARCHAR(MAX)= ''
         , @c_TaskPriority_Exp       NVARCHAR(MAX)= ''
         , @c_TaskType_Exp           NVARCHAR(MAX)= ''
         , @c_PickMethod_Exp         NVARCHAR(MAX)= ''
         , @c_ToID_Exp               NVARCHAR(MAX)= ''   --ML01
         , @c_NoQtyReplen_Exp        NVARCHAR(MAX)= ''   --ML01
         , @c_TaskType_Val           NVARCHAR(10) = ''
         , @c_PickMethod_Val         NVARCHAR(10) = ''
         , @c_TaskPriority_Val       NVARCHAR(10) = ''
         , @c_NoQtyReplen_Val        NVARCHAR(10) = ''   --ML01
         , @c_NoQtyReplen_SC         NVARCHAR(10) = ''   --ML01
         , @c_NoQtyReplen            NVARCHAR(10) = ''   --ML01
         , @c_SetTransitLoc          NVARCHAR(10) = ''   --ML01
         , @c_TaskType               NVARCHAR(10) = ''
         , @c_PickMethod             NVARCHAR(10) = ''
         , @c_OPTION5                NVARCHAR(MAX)= ''   --ML01

   CREATE TABLE #TEMP_REPLENISHMENT
   (
      Replenishmentkey   NVARCHAR(10)  NULL DEFAULT ('')
    , StorerKey          NVARCHAR(15)  NULL DEFAULT ('')
    , Sku                NVARCHAR(20)  NULL DEFAULT ('')
    , Lot                NVARCHAR(10)  NULL DEFAULT ('')
    , Qty                INT           NULL DEFAULT (0)
    , FromLOC            NVARCHAR(10)  NULL DEFAULT ('')
    , ID                 NVARCHAR(18)  NULL DEFAULT ('')
    , ToLOC              NVARCHAR(10)  NULL DEFAULT ('')
    , UCCNo              NVARCHAR(20)  NULL DEFAULT ('')
    , Priority           NVARCHAR(10)  NULL DEFAULT ('')
    , TransitLOC         NVARCHAR(10)  NULL DEFAULT ('')
    --ML01-S
    , ReplenishmentGroup NVARCHAR(10)  NULL DEFAULT ('')
    , ToID               NVARCHAR(18)  NULL DEFAULT ('')
    , QtyMoved           INT           NULL DEFAULT (0)
    , QtyInPickLoc       INT           NULL DEFAULT (0)
    , UOM                NVARCHAR(10)  NULL DEFAULT ('')
    , PackKey            NVARCHAR(10)  NULL DEFAULT ('')
    , Confirmed          NVARCHAR(1)   NULL DEFAULT ('')
    , ReplenNo           NVARCHAR(10)  NULL DEFAULT ('')
    , Remark             NVARCHAR(255) NULL DEFAULT ('')
    , AddDate            DATETIME      NULL
    , AddWho             NVARCHAR(128) NULL DEFAULT ('')
    , EditDate           DATETIME      NULL
    , EditWho            NVARCHAR(128) NULL DEFAULT ('')
    , RefNo              NVARCHAR(20)  NULL DEFAULT ('')
    , DropID             NVARCHAR(20)  NULL DEFAULT ('')
    , LoadKey            NVARCHAR(10)  NULL DEFAULT ('')
    , Wavekey            NVARCHAR(10)  NULL DEFAULT ('')
    , OriginalFromLoc    NVARCHAR(10)  NULL DEFAULT ('')
    , OriginalQty        INT           NULL DEFAULT (0)
    , MoveRefKey         NVARCHAR(10)  NULL DEFAULT ('')
    , PendingMoveIn      INT           NULL DEFAULT (0)
    , QtyReplen          INT           NULL DEFAULT (0)
    --ML01-E
   )

   SELECT @n_err=0, @c_errmsg=''

   SELECT @c_OPTION5 = ISNULL(OPTION5,'') FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '', 'ReleaseReplenTaskCode')   --ML01
   SELECT @c_NoQtyReplen_SC = dbo.fnc_GetParamValueFromString('@c_NoQtyReplen', @c_OPTION5, '')                            --ML01

   SELECT @c_ReplCond_Exp       = ISNULL(TRIM(MAX(CASE WHEN Code = 'Condition'         THEN Notes END)),'')
        , @c_ReplJoin_Exp       = ISNULL(TRIM(MAX(CASE WHEN Code = 'SQL_JOIN'          THEN Notes END)),'')
        , @c_TaskJoin_Exp       = ISNULL(TRIM(MAX(CASE WHEN Code = 'SQL_JOIN_TASK'     THEN Notes END)),'')   --ML01
        , @c_TransitLOC_Exp     = ISNULL(TRIM(MAX(CASE WHEN Code = 'TransitLOC'        THEN Notes END)),'')
        , @c_TaskGrouping_Exp   = ISNULL(TRIM(MAX(CASE WHEN Code = 'TaskGrouping'      THEN Notes END)),'')
        , @c_TaskType_Exp       = ISNULL(TRIM(MAX(CASE WHEN Code = 'TaskType'          THEN Notes END)),'')
        , @c_TaskPriority_Exp   = ISNULL(TRIM(MAX(CASE WHEN Code = 'TaskPriority'      THEN Notes END)),'')
        , @c_PickMethod_Exp     = ISNULL(TRIM(MAX(CASE WHEN Code = 'PickMethod'        THEN Notes END)),'')
        , @c_ToID_Exp           = ISNULL(TRIM(MAX(CASE WHEN Code = 'ToID'              THEN Notes END)),'')   --ML01
        , @c_NoQtyReplen_Exp    = ISNULL(TRIM(MAX(CASE WHEN Code = 'NoQtyReplen'       THEN Notes END)),'')   --ML01
        , @c_TaskType_Val       = ISNULL(TRIM(MAX(CASE WHEN Code = 'TaskType'          THEN Short END)),'')
        , @c_PickMethod_Val     = ISNULL(TRIM(MAX(CASE WHEN Code = 'PickMethod'        THEN Short END)),'')
        , @c_TaskPriority_Val   = ISNULL(TRIM(MAX(CASE WHEN Code = 'TaskPriority'      THEN Short END)),'')
        , @c_NoQtyReplen_Val    = ISNULL(TRIM(MAX(CASE WHEN Code = 'NoQtyReplen'       THEN Short END)),'')   --ML01
        , @c_SetTransitLoc      = ISNULL(TRIM(MAX(CASE WHEN Code = 'SetTransitLoc'     THEN Short END)),'')   --ML01
     FROM dbo.CODELKUP WITH(NOLOCK)
    WHERE ListName = 'REPLENCFG'
      AND Code2 = 'ispRLREP09'
      AND Storerkey = @c_Storerkey

   IF @c_ReplCond_Exp LIKE 'AND %'
      SET @c_ReplCond_Exp = SUBSTRING(@c_ReplCond_Exp, 5, LEN(@c_ReplCond_Exp))

   IF @c_Zone02 <> 'ALL' AND ISNULL(@c_ReplCond_Exp,'') = ''
   BEGIN
      SELECT @c_ReplCond_Exp = @c_ReplCond_Exp + ' AND LOC.PutawayZone IN ( '''
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

   SET @c_SQLStatement = 'INSERT INTO #TEMP_REPLENISHMENT(Replenishmentkey, StorerKey, Sku, Lot, Qty, FromLOC, ID, ToLOC, UCCNo, Priority, TransitLOC'
     + ', ReplenishmentGroup, ToID, QtyMoved, QtyInPickLoc, UOM, PackKey, Confirmed, ReplenNo, Remark, AddDate, AddWho'              --ML01
     + ', EditDate, EditWho, RefNo, DropID, LoadKey, Wavekey, OriginalFromLoc, OriginalQty, MoveRefKey, PendingMoveIn, QtyReplen)'   --ML01
     + ' SELECT RPL.Replenishmentkey'
     +       ', RPL.StorerKey'
     +       ', RPL.Sku'
     +       ', RPL.Lot'
     +       ', RPL.Qty'
     +       ', RPL.FromLoc'
     +       ', RPL.ID'
     +       ', RPL.ToLoc'
     +       ', RPL.RefNo'
     +       ', RPL.Priority'
     +       ', TransitLOC=' + CASE WHEN ISNULL(@c_TransitLOC_Exp  ,'')<>'' THEN @c_TransitLOC_Exp   ELSE 'ISNULL(PA.InLoc,'''')' END
     --ML01-S
   SET @c_SQLStatement = @c_SQLStatement
     +       ', RPL.ReplenishmentGroup'
     +       ', RPL.ToID'
     +       ', RPL.QtyMoved'
     +       ', RPL.QtyInPickLoc'
     +       ', RPL.UOM'
     +       ', RPL.PackKey'
     +       ', RPL.Confirmed'
     +       ', RPL.ReplenNo'
     +       ', RPL.Remark'
     +       ', RPL.AddDate'
     +       ', RPL.AddWho'
     +       ', RPL.EditDate'
     +       ', RPL.EditWho'
     +       ', RPL.RefNo'
     +       ', RPL.DropID'
     +       ', RPL.LoadKey'
     +       ', RPL.Wavekey'
     +       ', RPL.OriginalFromLoc'
     +       ', RPL.OriginalQty'
     +       ', RPL.MoveRefKey'
     +       ', RPL.PendingMoveIn'
     +       ', RPL.QtyReplen'
     --ML01-E
     +   ' FROM dbo.REPLENISHMENT RPL WITH(NOLOCK)'
     +   ' JOIN dbo.LOC LOC WITH(NOLOCK) ON RPL.ToLoc=LOC.Loc'

   IF ISNULL(@c_ReplJoin_Exp,'') <> ''
      SET @c_SQLStatement = @c_SQLStatement + ' ' + @c_ReplJoin_Exp

   SET @c_SQLStatement = @c_SQLStatement
     +   ' LEFT JOIN dbo.PUTAWAYZONE PA WITH(NOLOCK) ON LOC.PutawayZone=PA.PutawayZone'
     +   ' LEFT JOIN dbo.LOC FRLOC WITH(NOLOCK) ON RPL.FromLoc=FRLOC.Loc'
     +   ' LEFT JOIN dbo.LOC TOLOC WITH(NOLOCK) ON RPL.ToLoc=TOLOC.Loc'
     +   ' LEFT JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON RPL.Lot=LA.Lot'
     +   ' LEFT JOIN dbo.SKU SKU WITH(NOLOCK) ON RPL.StorerKey=SKU.Storerkey AND RPL.Sku=SKU.Sku'
     +  ' WHERE LOC.Facility = ''' + ISNULL(REPLACE(@c_Facility,'''',''''''),'') +''''
     +    ' AND RPL.StorerKey = ''' + ISNULL(REPLACE(@c_Storerkey,'''',''''''),'') + ''''
     +    ' AND RPL.Confirmed = ''N'''

   IF ISNULL(@c_ReplCond_Exp,'') <> ''
      SET @c_SQLStatement = @c_SQLStatement
      +   ' AND (' + @c_ReplCond_Exp + ')'

   SET @c_SQLParms = N'@c_Facility NVARCHAR(10)'
                   +', @c_Zone02 NVARCHAR(10)'
                   +', @c_Zone03 NVARCHAR(10)'
                   +', @c_Zone04 NVARCHAR(10)'
                   +', @c_Zone05 NVARCHAR(10)'
                   +', @c_Zone06 NVARCHAR(10)'
                   +', @c_Zone07 NVARCHAR(10)'
                   +', @c_Zone08 NVARCHAR(10)'
                   +', @c_Zone09 NVARCHAR(10)'
                   +', @c_Zone10 NVARCHAR(10)'
                   +', @c_Zone11 NVARCHAR(10)'
                   +', @c_Zone12 NVARCHAR(10)'
                   +', @c_Storerkey NVARCHAR(15)'

   EXEC sp_ExecuteSQL @c_SQLStatement, @c_SQLParms
      , @c_Facility, @c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06, @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10
      , @c_Zone11, @c_Zone12, @c_Storerkey


   -- Loop #TEMP_REPLENISHMENT
   SET @c_SQLStatement = 'DECLARE CUR_REPLEN CURSOR FAST_FORWARD READ_ONLY FOR'
     + ' SELECT RPL.Replenishmentkey'
     +       ', RPL.StorerKey'
     +       ', RPL.Sku'
     +       ', RPL.Lot'
     +       ', RPL.Qty'
     +       ', RPL.FromLoc'
     +       ', FRLOC.LogicalLocation'
     +       ', RPL.ID'
     +       ', RPL.ToLoc'
     +       ', TOLOC.LogicalLocation'
     +       ', RPL.UCCNo'
     +       ', RPL.TransitLOC'
     +       ', TaskGrouping=' + CASE WHEN ISNULL(@c_TaskGrouping_Exp,'')<>'' THEN @c_TaskGrouping_Exp ELSE '''''' END

   SET @c_SQLStatement = @c_SQLStatement
     +       ', Priority='     + CASE WHEN ISNULL(@c_TaskPriority_Exp,'')<>'' THEN @c_TaskPriority_Exp
                                      WHEN ISNULL(@c_TaskPriority_Val,'')<>'' THEN '''' + REPLACE(@c_TaskPriority_Val,'''','''''') + ''''
                                      ELSE 'RPL.Priority' END

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

   --ML01-S
   SET @c_SQLStatement = @c_SQLStatement
     +       ', ToID='         + CASE WHEN ISNULL(@c_ToID_Exp        ,'')<>'' THEN @c_ToID_Exp
                                      ELSE 'RPL.ID'
                                 END

   SET @c_SQLStatement = @c_SQLStatement
     +       ', NoQtyReplen='  + CASE WHEN ISNULL(@c_NoQtyReplen_Exp ,'')<>'' THEN @c_NoQtyReplen_Exp
                                      WHEN ISNULL(@c_NoQtyReplen_Val ,'')<>'' THEN '''' + REPLACE(RTRIM(@c_NoQtyReplen_Val),'''','''''') + ''''
                                      WHEN ISNULL(@c_NoQtyReplen_SC  ,'')<>'' THEN '''' + REPLACE(RTRIM(@c_NoQtyReplen_SC),'''','''''') + ''''
                                      ELSE 'Y'
                                 END
   --ML01-E

   SET @c_SQLStatement = @c_SQLStatement
     + ' FROM #TEMP_REPLENISHMENT RPL'

   IF ISNULL(@c_TaskJoin_Exp,'') <> ''                                --ML01
      SET @c_SQLStatement = @c_SQLStatement + ' ' + @c_TaskJoin_Exp   --ML01

   SET @c_SQLStatement = @c_SQLStatement
     + ' LEFT JOIN dbo.LOC FRLOC WITH(NOLOCK) ON RPL.FromLoc=FRLOC.Loc'
     + ' LEFT JOIN dbo.LOC TOLOC WITH(NOLOCK) ON RPL.ToLoc=TOLOC.Loc'
     + ' LEFT JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON RPL.Lot=LA.Lot'
     + ' LEFT JOIN dbo.SKU SKU WITH(NOLOCK) ON RPL.StorerKey=SKU.Storerkey AND RPL.Sku=SKU.Sku'
     + ' ORDER BY TaskGrouping, RPL.Replenishmentkey'

   EXEC sp_ExecuteSQL @c_SQLStatement, @c_SQLParms
      , @c_Facility, @c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06, @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10
      , @c_Zone11, @c_Zone12, @c_Storerkey

   OPEN CUR_REPLEN

   SET @c_TaskGrouping_Prev = ''
   SET @c_GroupKey = ''

   WHILE @n_continue IN (1,2)
   BEGIN
      FETCH NEXT FROM CUR_REPLEN
      INTO @c_Replenishmentkey, @c_Storer, @c_Sku, @c_Lot, @n_Qty, @c_FromLOC, @c_FromLogicalLoc, @c_ID, @c_ToLOC, @c_ToLogicalLoc
         , @c_UCCNo, @c_TransitLOC, @c_TaskGrouping, @c_Priority, @c_TaskType, @c_PickMethod
         , @c_ToID, @c_NoQtyReplen   --ML01

      IF @@FETCH_STATUS <> 0
         BREAK

      IF ISNULL(@c_TaskGrouping,'') <> '' AND ISNULL(@c_TaskGrouping,'') <> ISNULL(@c_TaskGrouping_Prev,'')
      BEGIN
         EXECUTE nspg_GetKey
                 @keyname     = 'REPLENISHGROUP'
               , @fieldlength = 10
               , @keystring   = @c_GroupKey  OUTPUT
               , @b_success   = @b_success   OUTPUT
               , @n_err       = @n_err       OUTPUT
               , @c_errmsg    = @c_errmsg    OUTPUT

         IF NOT @b_success = 1
         BEGIN
            SET @n_continue = 3
            BREAK
         END

         SET @c_TaskGrouping_Prev = @c_TaskGrouping
      END

      IF ISNULL(@c_TransitLOC,'') <> ''
      BEGIN
         SET @c_FinalLOC = @c_ToLOC

         IF ISNULL(@c_SetTransitLoc,'') NOT IN ('1','Y')   --ML01
         BEGIN                                             --ML01
            SET @c_ToLOC    = @c_TransitLOC
            SET @c_ToLogicalLoc = @c_ToLOC
            SET @c_TransitLOC = ''                         --ML01

            SELECT @c_ToLogicalLoc = LogicalLocation
            FROM LOC(NOLOCK)
            WHERE Loc = @c_ToLOC
         END                                               --ML01
      END
      ELSE
      BEGIN
         SET @c_FinalLOC = ''
      END

      SET @c_UOM = CASE WHEN ISNULL(@c_UCCNo,'')<>'' THEN '2' ELSE '6' END
      SET @n_QtyReplen = CASE WHEN ISNULL(@c_NoQtyReplen,'') IN ('1','Y') THEN 0 ELSE @n_Qty END   --ML01

      EXEC isp_InsertTaskDetail
           @c_TaskType              = @c_TaskType
         , @c_Storerkey             = @c_Storer
         , @c_Sku                   = @c_Sku
         , @c_Lot                   = @c_Lot
         , @c_UOM                   = @c_UOM
         , @n_UOMQty                = @n_Qty
         , @n_Qty                   = @n_Qty
         , @c_FromLoc               = @c_FromLoc
         , @c_LogicalFromLoc        = @c_FromLogicalLoc
         , @c_FromID                = @c_ID
         , @c_ToLoc                 = @c_ToLOC
         , @c_LogicalToLoc          = @c_ToLogicalLoc
         , @c_ToID                  = @c_ToID   --ML01
         , @c_CaseID                = @c_UCCNo
         , @c_DropID                = @c_UCCNo
         , @c_PickMethod            = @c_PickMethod
         , @c_Priority              = @c_Priority
         , @c_SourcePriority        = @c_Priority
         , @c_SourceType            = 'ispRLREP09'
         , @c_SourceKey             = @c_Replenishmentkey
         , @c_OrderKey              = ''
         , @c_GroupKey              = @c_GroupKey
         , @c_CallSource            = 'REPLENISHMENT'
         , @n_QtyReplen             = @n_QtyReplen   --ML01
         , @n_PendingMoveIn         = @n_Qty
         , @c_Loadkey               = ''
         , @c_AreaKey               = '?F'  -- ?F=Get from location areakey
         , @c_LinkTaskToReplen      = 'Y'
         , @c_ZeroSystemQty         = 'Y'
         , @c_TransitLOC            = @c_TransitLOC  --ML01
         , @c_FinalLOC              = @c_FinalLOC
         , @c_Message03             = ''
         , @c_SplitTaskByCase       = 'N'
         , @c_ReservePendingMoveIn  = 'Y'
         , @n_SystemQty             = @n_Qty
         , @b_Success               = @b_Success OUTPUT
         , @n_Err                   = @n_err OUTPUT
         , @c_ErrMsg                = @c_errmsg OUTPUT

      IF @b_Success <> 1
         SELECT @n_continue = 3
   END
   CLOSE CUR_REPLEN
   DEALLOCATE CUR_REPLEN

EXIT_SP:
   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      execute nsp_logerror @n_err, @c_errmsg, "ispRLREP09"
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON ispRLREP09 to nSQL
GO
