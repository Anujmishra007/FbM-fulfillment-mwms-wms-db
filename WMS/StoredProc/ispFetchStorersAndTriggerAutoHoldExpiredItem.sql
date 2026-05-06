SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Stored Procedure: ispFetchStorersAndTriggerAutoHoldExpiredItem          */
/* Creation Date: 30-June-2025                                             */
/* Copyright: Maersk                                                       */
/* Purpose: FCR-4993                                                       */
/* Written by: Bruce                                                       */
/* Purpose: Fetch StorerKeys and Trigger Auto Hold ExpiredItem             */
/* Called By: DB Scheduler                                                 */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author     Ver   Purposes                                  */
/* 02-Sep-2025  MICHAEL    1.1   UWP-40390 - Change Hold Status (ML01)     */
/* 12-Nov-2025  MICHAEL    1.2   FCR-8872 - Add @c_ExpiredThreshold (ML02) */
/* 15-Apr-2026  MICHAEL    1.3   FCR-12446-Add @c_SQLJoin,@c_SQLWhere(ML03)*/
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[ispFetchStorersAndTriggerAutoHoldExpiredItem](
   @b_Success        INT          = 1   OUTPUT
,  @n_Err            INT          = 0   OUTPUT
,  @c_ErrMsg         NVARCHAR(250)= ''  OUTPUT

)
AS
BEGIN
   /*
   StorerConfig.Configkey = AutoHoldExpiredItem
   OPTION5: (if value contains @ char, use @@ instead)
      @c_HoldStatus       = XXXXX      default @c_HoldStatus = Auto-Block
      @c_ExpiredThreshold = 999        default @c_ExpiredThreshold = 0
      @c_Lottable04Label  = XXXXX      default @c_Lottable04Label = EXP_DATE
      @c_IgnoreLottable04 = Y/N        default @c_IgnoreLottable04 = N  (effective only when @c_SQLWhere<>'')
      @c_SQLJoin          = XXXXX      e.g. @c_SQLJoin = INNER JOIN LOC WITH(NOLOCK) ON LLI.Loc=LOC.Loc
      @c_SQLWhere         = XXXXX      e.g. @c_SQLWhere = ISNULL(LOC.LocationGroup,'')<>'EXP_DMG'
   */
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_StorerKey        NVARCHAR(80)
         , @n_Continue         INT
         , @c_AlertMessage     NVARCHAR(255) = ''
         , @b_SuccessLog       INT= 1
         , @c_Lot              NVARCHAR(10)
         , @c_OPTION5          NVARCHAR(MAX) = ''   --ML01
         , @c_HoldStatus       NVARCHAR(10)  = ''   --ML01
         , @c_ExpiredThreshold NVARCHAR(10)     --ML02
         , @c_Facility         NVARCHAR(5)   = ''   --ML03
         , @c_Lottable04Label  NVARCHAR(20)  = ''   --ML03
         , @c_IgnoreLottable04 NVARCHAR(10)  = ''   --ML03
         , @c_SQL              NVARCHAR(MAX)        --ML03
         , @c_SQLJoin          NVARCHAR(MAX)        --ML03
         , @c_SQLWhere         NVARCHAR(MAX)        --ML03

   IF OBJECT_ID('tempdb..#TEMP_LOT') IS NOT NULL
      DROP TABLE #TEMP_LOT

   CREATE TABLE #TEMP_LOT
   (
      LOT   NVARCHAR(10) NOT NULL PRIMARY KEY
   )

   DECLARE CUR_TEMP CURSOR LOCAL FORWARD_ONLY STATIC FOR
--ML01   SELECT StorerKey FROM [dbo].[StorerConfig] WITH (NOLOCK) WHERE ConfigKey = 'AutoHoldExpiredItem' AND SValue = '1'
   --ML01-S
   SELECT DISTINCT StorerKey, OPTION5
        , Facility   --ML03
   FROM [dbo].[StorerConfig] WITH (NOLOCK)
   WHERE ConfigKey = 'AutoHoldExpiredItem' AND SValue = '1'
   --ML01-E

   OPEN CUR_TEMP
   FETCH NEXT FROM CUR_TEMP INTO @c_StorerKey
       , @c_OPTION5   --ML01
       , @c_Facility  --ML03

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      --ML01-S
      SET @c_HoldStatus = ''
      SET @c_HoldStatus = dbo.fnc_GetParamValueFromString('@c_HoldStatus', @c_OPTION5, @c_HoldStatus)
      IF ISNULL(@c_HoldStatus,'')=''
          SET @c_HoldStatus = 'Auto-Block'
      --ML01-E

      --ML02-S
      SET @c_ExpiredThreshold = ''
      SET @c_ExpiredThreshold = dbo.fnc_GetParamValueFromString('@c_ExpiredThreshold', @c_OPTION5, @c_ExpiredThreshold)
      --ML02-E

/* ML03-S
      SET @c_Lot = SPACE(10)
      WHILE(1=1)
      BEGIN
         SELECT TOP 1
                @c_Lot = LOT.Lot
           FROM LOTxLOCxID STO WITH(NOLOCK)
          INNER JOIN LOT WITH(NOLOCK) ON STO.Lot = LOT.Lot
          INNER JOIN LOTATTRIBUTE ATTR WITH(NOLOCK) ON LOT.Lot = ATTR.Lot
          INNER JOIN SKU WITH(NOLOCK) ON STO.Storerkey = SKU.Storerkey AND STO.Sku = SKU.Sku
          WHERE LOT.StorerKey = @c_StorerKey
            AND LOT.Status = 'OK'
--ML01         AND STO.Qty > STO.QtyAllocated
            AND STO.Qty > 0                        --ML01
            AND SKU.Lottable04Label = 'EXP_DATE'   --ML01
--ML02         AND ATTR.Lottable04 <= GETDATE()
            AND DATEDIFF(DAY, GETDATE(), ATTR.Lottable04) <= ISNULL(TRY_PARSE(ISNULL(@c_ExpiredThreshold,'') AS INT),0)   --ML02
            AND LOT.Lot > @c_Lot
           ORDER BY LOT.Lot

         IF @@ROWCOUNT = 0
         BEGIN
            BREAK
         END
ML03-E */

      --ML03-S
      SET @c_Lottable04Label = 'EXP_DATE'
      SET @c_Lottable04Label = dbo.fnc_GetParamValueFromString('@c_Lottable04Label', @c_OPTION5, @c_Lottable04Label)

      SET @c_IgnoreLottable04 = 'N'
      SET @c_IgnoreLottable04 = dbo.fnc_GetParamValueFromString('@c_IgnoreLottable04', @c_OPTION5, @c_IgnoreLottable04)

      SET @c_SQLJoin  = ISNULL(TRIM(dbo.fnc_GetParamValueFromString('@c_SQLJoin' , @c_OPTION5, '')),'')
      SET @c_SQLWhere = ISNULL(TRIM(dbo.fnc_GetParamValueFromString('@c_SQLWhere', @c_OPTION5, '')),'')

      IF @c_SQLWhere LIKE 'AND %'
         SET @c_SQLWhere = TRIM(SUBSTRING(@c_SQLWhere, 5, LEN(@c_SQLWhere)))

      SET @c_SQL = N'INSERT INTO #TEMP_LOT (Lot)'
        + ' SELECT DISTINCT LOT.Lot'
        + ' FROM dbo.LOTxLOCxID   LLI WITH(NOLOCK)'
        + ' JOIN dbo.LOT          LOT WITH(NOLOCK) ON LLI.Lot = LOT.Lot'
        + ' JOIN dbo.LOTATTRIBUTE LA  WITH(NOLOCK) ON LOT.Lot = LA.Lot'
        + ' JOIN dbo.SKU          SKU WITH(NOLOCK) ON LLI.Storerkey = SKU.Storerkey AND LLI.Sku = SKU.Sku'
        + ' JOIN dbo.LOC          LOC WITH(NOLOCK) ON LLI.Loc = LOC.Loc'

      IF ISNULL(@c_SQLJoin,'')<>''
         SET @c_SQL = @c_SQL
           + ' ' + @c_SQLJoin

      SET @c_SQL = @c_SQL
        + ' WHERE LOT.Status = ''OK'''
        +   ' AND LLI.Qty > 0'
        +   ' AND LLI.StorerKey = ''' + REPLACE(ISNULL(@c_StorerKey,''),'''','''''') + ''''

      IF ISNULL(@c_Facility,'')<>''
         SET @c_SQL = @c_SQL
           + ' AND LOC.Facility = ''' + REPLACE(ISNULL(@c_Facility,''),'''','''''') + ''''

      IF ISNULL(@c_Lottable04Label,'')<>''
         SET @c_SQL = @c_SQL
           + ' AND SKU.Lottable04Label = ''' + REPLACE(ISNULL(@c_Lottable04Label,''),'''','''''') + ''''

      IF NOT (ISNULL(@c_IgnoreLottable04,'')='Y' AND ISNULL(@c_SQLWhere,'')<>'')
         SET @c_SQL = @c_SQL
           + ' AND DATEDIFF(DAY, GETDATE(), LA.Lottable04) <= ' + CONVERT(NVARCHAR(10),ISNULL(TRY_PARSE(ISNULL(@c_ExpiredThreshold,'') AS INT),0))

      IF ISNULL(@c_SQLWhere,'')<>''
         SET @c_SQL = @c_SQL
           + ' AND (' + @c_SQLWhere + ')'

      SET @c_SQL = @c_SQL
        +  ' ORDER BY LOT.Lot'

      TRUNCATE TABLE #TEMP_LOT
      EXEC (@c_SQL)

      DECLARE CUR_LOT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Lot FROM #TEMP_LOT ORDER BY 1

      OPEN CUR_LOT
      FETCH NEXT FROM CUR_LOT INTO @c_Lot

      WHILE @@FETCH_STATUS = 0
      BEGIN
      --ML03-E

         EXEC nspInventoryHold
             @c_Lot,               --lot
             '',                   --loc
             '',                   --id
--ML01             'non NIF',            --status
             @c_HoldStatus,   --ML01
             '1',                  --hold
             @b_Success OUTPUT,
             @n_Err     OUTPUT,
             @c_ErrMsg  OUTPUT,
             'Job'
         IF @n_Err <> 0
         BEGIN
            BREAK
         END

         FETCH NEXT FROM CUR_LOT INTO @c_Lot   --ML03
      END

      CLOSE CUR_LOT        --ML03
      DEALLOCATE CUR_LOT   --ML03

      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
         SET @n_err = 81182
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': The AutoHoldExpiredItem processing has an error . The flow is Scheduler->ispFetchStorersAndTriggerAutoHoldExpiredItem'
             + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         GOTO ERROR_HANDLE
      END

ERROR_HANDLE:

      IF @n_continue = 3  -- Error Occured
      BEGIN
         --- Error Handling ----
         SET @c_AlertMessage = 'The AutoHoldExpiredItem processing triggered by scheduler has an error.' +' - ' + @c_ErrMsg
         BEGIN TRAN
         EXEC nspLogAlert
               @c_modulename       = 'ispFetchStorersAndTriggerAutoHoldExpiredItem'
             , @c_AlertMessage     = @c_AlertMessage
             , @n_Severity         = '5'
             , @b_success          = @b_SuccessLog OUTPUT
             , @n_err              = @n_Err        OUTPUT
             , @c_errmsg           = @c_ErrMsg     OUTPUT
             , @c_Activity         = 'Scheduled Task'
             , @c_Storerkey        = @c_StorerKey
             , @c_SKU              = ''
             , @c_UOM              = ''
             , @c_UOMQty           = ''
             , @c_Qty              = 0
             , @c_Lot              = @c_Lot
             , @c_Loc              = ''
             , @c_ID               = ''
             , @c_TaskDetailKey    = ''

         WHILE @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END
      END

      FETCH NEXT FROM CUR_TEMP INTO @c_StorerKey
          , @c_OPTION5   --ML01
          , @c_Facility  --ML03
   END
   CLOSE CUR_TEMP
   DEALLOCATE CUR_TEMP
END
GO
