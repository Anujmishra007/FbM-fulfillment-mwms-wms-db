SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_VIVORPL01                                         */
/* Creation Date:  10-Feb-2026                                             */
/* Copyright: Maersk                                                       */
/* Written by:Supriya S                                                    */
/*                                                                         */
/* Purpose: This Stored procedure include Replenishment logic and          */
/*        : Task creation as well as Replenishment record generation       */
/*                                                                         */
/* Called By:  msp_BEJ_AutoInventoryReplenishment (Scheduler Job)          */
/*                                                                         */
/* PVCS Version:                                                           */
/*                                                                         */
/* Version: MWMS V2                                                        */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date        Author   Ver   Purposes                                     */
/* 10-Feb-2026 SSA01    1.0   Create UWP-47046                             */
/***************************************************************************/
CREATE OR ALTER   PROC [dbo].[isp_VIVORPL01]
   @c_Facility   NVARCHAR(5)    = '',
   @c_Storerkey  NVARCHAR(15)   = '',
   @c_SKU        NVARCHAR(20)   = '',
   @c_LOC        NVARCHAR(10)   = '',
   @c_ReplenishmentGroup NVARCHAR(10)   = '',
   @n_QtyReplen   INT            = 0,
   @c_TaskPriority  NVARCHAR(10)  = '5',
   @b_Success    INT OUTPUT,
   @n_Err        INT OUTPUT,
   @c_ErrMsg     NVARCHAR(255) OUTPUT,
   @b_Debug      INT = 0
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt          INT            = @@TRANCOUNT
      , @n_Continue              INT            = 1
      , @c_ReplenishmentKey      NVARCHAR(10)   = ''
      , @c_FromLOC                    NVARCHAR(10)
      , @c_FromLot                    NVARCHAR(10)
      , @c_FromId                     NVARCHAR(18)
      , @n_FromQty                    INT
      , @c_Packkey            NVARCHAR(10)
      , @c_UOM                NVARCHAR(10)

   WHILE @@TRANCOUNT > 0
   BEGIN
     COMMIT TRAN
   END

   BEGIN TRAN

   IF ISNULL(RTRIM(@c_LOC), '') = ''
   BEGIN
      IF @b_debug = 1
      PRINT '<<< Location Paramater Blank! '

      GOTO QUIT_SP
   END

   SELECT TOP 1
      @c_Facility  = LOC.Facility
   FROM LOC WITH (NOLOCK)
   WHERE LOC.LOC = @c_LOC

   IF @n_continue = 1
   BEGIN
      -- Do not execute it Replenishment Task not done yet

        IF EXISTS(SELECT 1
                  FROM Replenishment RP WITH (NOLOCK)
                  WHERE (RP.Storerkey = @c_Storerkey
                  AND RP.Sku = @c_SKU
                  AND RP.ToLoc = @c_LOC)
                  AND (RP.Confirmed = 'N') )
        BEGIN
            PRINT '>>>>>> Replenishment Exists, Do nothing'
            GOTO QUIT_SP
        END

        IF EXISTS(SELECT 1
                  FROM TaskDetail TD WITH (NOLOCK)
                  WHERE (TD.Storerkey = @c_Storerkey
                  AND TD.Sku = @c_SKU
                  AND TD.ToLoc = @c_LOC)
                  AND (TD.Status IN ('Q', '0','1', '3'))
                  AND TD.TaskType = 'RPF')
        BEGIN
            PRINT '>>>>>> Replenishment Task Exists, Do nothing'
            GOTO QUIT_SP
        END
         SELECT   @c_Packkey = PACK.PackKey,
                            @c_UOM = PACK.PackUOM3
                   FROM     SKU (NOLOCK),
                            PACK (NOLOCK)
                   WHERE    SKU.PackKey = PACK.Packkey AND
                            SKU.StorerKey = @c_Storerkey AND
                            SKU.SKU = @c_SKU

    /* Insert Into Replenishment Table Now */

    WHILE @n_QtyReplen > 0
    BEGIN

     SELECT Top 1 @c_FromLOC = LLI.LOC,
                            @c_FromID = LLI.ID,
                            @n_FromQty = (LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED),
                            @c_FromLot = LLI.Lot
                   FROM     dbo.LOTxLOCxID LLI (NOLOCK)
                   JOIN dbo.LOC LOC WITH (NOLOCK) ON LLI.LOC = LOC.Loc
                   JOIN dbo.ID ID WITH (NOLOCK) ON LLI.ID = ID.Id
                   JOIN dbo.SKUxLOC SL WITH (nolock) ON SL.StorerKey = LLI.StorerKey AND
                      SL.SKU = LLI.SKU AND SL.LOC = LLI.LOC
                   WHERE LOC.LocationFlag NOT IN ('DAMAGE', 'HOLD') AND
                            LOC.Facility = @c_Facility AND
                            LOC.Status = 'OK' AND
                            ID.Status = 'OK' AND
                            LOC.LocationCategory <> 'shelving' AND
                            LOC.Locationtype = 'BULK' AND
                            (LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED) > 0
                   ORDER BY
                    CASE WHEN LOC.LocationCategory <> 'shelving' THEN 0 ELSE 1 END,
                    CASE WHEN LOC.LocationType IN ('BULK') THEN 0 ELSE 1 END,
                   LLI.QTY - LLI.QTYPICKED - LLI.QTYALLOCATED

            IF @n_FromQty > @n_QtyReplen
            BEGIN
            EXECUTE nspg_GetKey
                  'REPLENISHKEY'
               ,  10
               ,  @c_ReplenishmentKey OUTPUT
               ,  @b_success          OUTPUT
               ,  @n_err              OUTPUT
               ,  @c_errmsg           OUTPUT

           IF NOT @b_success = 1
           BEGIN
               BREAK
           END

           IF @b_success = 1
           BEGIN

               INSERT INTO REPLENISHMENT
                   (
                     Replenishmentgroup
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
                   )
               VALUES
                   (     @c_ReplenishmentGroup,
                          @c_ReplenishmentKey,
                          @c_StorerKey,
                          @c_Sku,
                          @c_FromLoc,
                          @c_LOC,
                          @c_FromLot,
                          @c_FromId,
                          @n_QtyReplen,
                          @c_UOM,
                          @c_PackKey,
                          'N'
                        )
                  SELECT @n_err = @@ERROR
                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @c_ErrMsg = CONVERT(CHAR(250) ,@n_err),@n_err = 62081
                     SELECT @c_ErrMsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+
                              ': Insert Into Replenishment Failed (isp_VIVORPL01)'
                           +' ( '+' SQLSvr MESSAGE='+ TRIM(@c_ErrMsg) +' ) '
            END
            END -- IF @b_success = 1

            SELECT @b_success = 1

             EXEC isp_InsertTaskDetail
              @c_TaskType              = 'RPF'
             ,@c_Storerkey             = @c_Storerkey
             ,@c_Sku                   = @c_Sku
             ,@c_Lot                   = @c_FromLot
             ,@c_UOM                   = @c_UOM
             ,@n_UOMQty                = @n_QtyReplen
             ,@n_Qty                   = @n_QtyReplen
             ,@c_FromLoc               = @c_Fromloc
             ,@c_FromID                = @c_FromId
             ,@c_ToLoc                 = @c_Loc
             ,@c_ToID                  = @c_FromId
             ,@c_PickMethod            = '?TASKQTY' --?TASKQTY=(Qty available - taskqty)
             ,@c_Priority              = @c_TaskPriority
             ,@c_SourcePriority        = @c_TaskPriority
             ,@c_SourceType            = 'isp_VIVORPL01'
             ,@c_SourceKey             = @c_Replenishmentkey
             ,@c_AreaKey               = '?F'  -- ?F=Get from location areakey
             ,@c_Groupkey              = @c_ReplenishmentGroup
             ,@c_CallSource            = 'REPLENISHMENT'
             ,@n_QtyReplen             = @n_QtyReplen
             ,@n_PendingMoveIn         = @n_QtyReplen
             ,@c_LinkTaskToReplen      = 'Y'
			       ,@c_ZeroSystemQty         = 'Y'
             ,@b_Success               = @b_Success OUTPUT
             ,@n_Err                   = @n_err OUTPUT
             ,@c_ErrMsg                = @c_errmsg OUTPUT

          IF @b_Success <> 1
          BEGIN
               SELECT @n_continue = 3
               SELECT @c_ErrMsg = CONVERT(CHAR(250) ,@n_err),@n_err = 62082
               SELECT @c_ErrMsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+
                        ': Insert Into TaskDetail Failed (isp_VIVORPL01)'
                     +' ( '+' SQLSvr MESSAGE='+ TRIM(@c_ErrMsg) +' ) '
          END
          SET @n_QtyReplen =  @n_QtyReplen - @n_FromQty
       END
    END
-- End Insert Replenishment
END

QUIT_SP:

   IF @n_continue = 3
   BEGIN
    IF @@TRANCOUNT > 0
      BEGIN
        ROLLBACK TRAN
    END
    RAISERROR (@c_errmsg, 16, 1) WITH SETERROR
   END
   ELSE
   BEGIN
    WHILE @@TRANCOUNT > 0
      BEGIN
        COMMIT TRAN
    END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END
GO

GRANT EXECUTE ON [dbo].[isp_ODMRPL01] TO [NSQL]
GO
