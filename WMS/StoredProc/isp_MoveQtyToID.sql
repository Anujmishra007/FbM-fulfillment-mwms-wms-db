SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Stored Procedure: isp_MoveQtyToID                                       */
/* Creation Date: 2026-01-27                                               */
/* Copyright: MAERSK                                                       */
/* Written by: Michael Lam                                                 */
/*                                                                         */
/* Purpose: Move Qty of LOTxLOCxID to New ID                               */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author     Ver   Purposes                                  */
/* 2026-01-27   Michael    1.0   Devops Combines                           */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[isp_MoveQtyToID] (
   @c_Lot        NVARCHAR(10)
 , @c_Loc        NVARCHAR(10)
 , @c_ID         NVARCHAR(20)
 , @c_ToID       NVARCHAR(20)
 , @n_Qty        INT
 , @b_Success    INT           OUTPUT
 , @n_Err        INT           OUTPUT
 , @c_ErrMsg     NVARCHAR(250) OUTPUT
 , @c_SourceKey  NVARCHAR(20) = NULL
 , @c_SourceType NVARCHAR(30) = NULL
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue      INT = 1
         , @n_starttcnt     INT = @@TRANCOUNT
         , @c_Storerkey     NVARCHAR(15)
         , @c_Sku           NVARCHAR(20)
         , @c_MoveRefKey    NVARCHAR(10)
         , @c_LoseID        NVARCHAR(1)
         , @c_LoseID2       NVARCHAR(1)
         , @c_CommingleSku  NVARCHAR(1)
         , @b_UpdLoc        INT
         , @c_PackKey       NVARCHAR(10)
         , @c_PackUOM3      NVARCHAR(10)
         , @c_PickDetailKey NVARCHAR(10)
         , @n_QtyOnHand     INT

   SELECT @b_Success = 1
        , @n_Err     = 0
        , @c_ErrMsg  = ''

   IF ISNULL(@n_Qty,0) <=0
      GOTO EXIT_SP

   CREATE TABLE #TEMP_PICKDETAIL (
      PickDetailKey NVARCHAR(10) NOT NULL PRIMARY KEY
   )
   
   INSERT INTO #TEMP_PICKDETAIL (PickDetailKey)
   SELECT PickDetailKey
     FROM dbo.PICKDETAIL (NOLOCK)
    WHERE Status < '9'
      AND Qty > 0
      AND ISNULL(ShipFlag,'') <> 'Y'
      AND Lot = @c_Lot
      AND Loc = @c_Loc
      AND ID  = @c_ID

   IF EXISTS(SELECT TOP 1 1 FROM #TEMP_PICKDETAIL)
   BEGIN
      EXECUTE dbo.nspg_GetKey
         'MOVEREFKEY',
         10 ,
         @c_MoveRefKey OUTPUT,
         @b_Success    OUTPUT,
         @n_Err        OUTPUT,
         @c_ErrMsg     OUTPUT
      
      IF @b_success=0
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_Err = 60023
         SELECT @c_Errmsg = 'Unable to obtain MoveRefKey [nspInventoryHoldWrapper]'
         GOTO EXIT_SP
      END
      
      DECLARE CUR_PICKDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PickDetailKey
        FROM #TEMP_PICKDETAIL
       ORDER BY 1
      
      OPEN CUR_PICKDETAIL
      
      WHILE @n_continue IN (1,2)
      BEGIN
         FETCH NEXT FROM CUR_PICKDETAIL INTO @c_PickDetailKey
      
         IF @@FETCH_STATUS <> 0
            BREAK
      
         UPDATE dbo.PICKDETAIL WITH (ROWLOCK)
            SET MoveRefKey = @c_MoveRefKey
              , TrafficCop = NULL
          WHERE PickDetailKey = @c_PickDetailKey
            AND Status < '9'
            AND Qty > 0
            AND ISNULL(ShipFlag,'') <> 'Y'
            AND Lot = @c_Lot
            AND Loc = @c_Loc
            AND ID  = @c_ID
      
         IF @@ERROR <> 0
         BEGIN
            SET @n_continue = 3
            SELECT @c_errmsg = ISNULL(ERROR_MESSAGE(),'')
                 , @n_err = 60024
            SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5), @n_err) +
                  ': Update PickDetail MoveRefKey Fail [nspInventoryHoldWrapper] (SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
            BREAK
         END
      END
      CLOSE CUR_PICKDETAIL
      DEALLOCATE CUR_PICKDETAIL
   END
   
   IF @n_continue IN (1,2)
   BEGIN
      SELECT @c_Storerkey = ''
           , @c_Sku = ''
           , @c_LoseID = ''
           , @c_LoseID2 = CASE WHEN @c_ToID<>'' THEN '0' ELSE '1' END
           , @c_CommingleSku = ''
           , @b_UpdLoc = 0
           , @c_PackKey = ''
           , @c_PackUOM3 = ''
           , @n_QtyOnHand = 0

      SELECT @c_LoseID = LoseID
           , @c_CommingleSku = CommingleSku
        FROM dbo.LOC WITH(NOLOCK)
       WHERE Loc = @c_Loc
      
      SELECT @c_Storerkey = SKU.Storerkey
           , @c_Sku       = SKU.Sku
           , @c_PackKey   = PACK.PackKey
           , @c_PackUOM3  = PACK.PackUOM3
           , @n_QtyOnHand = LLI.Qty
        FROM dbo.LOTxLOCxID LLI  WITH(NOLOCK)
        LEFT JOIN dbo.SKU   SKU  WITH(NOLOCK) ON LLI.Storerkey = SKU.Storerkey AND LLI.Sku = SKU.Sku
        LEFT JOIN dbo.PACK  PACK WITH(NOLOCK) ON SKU.Packkey = PACK.Packkey
       WHERE LLI.Lot = @c_Lot
         AND LLI.Loc = @c_Loc
         AND LLI.ID  = @c_ID
      
      IF ISNULL(@c_LoseID,'') <> @c_LoseID2
      BEGIN
         SET @b_UpdLoc = 1
         UPDATE dbo.LOC WITH(ROWLOCK)
            SET LoseID = @c_LoseID2
              , TrafficCop = NULL
          WHERE Loc = @c_Loc
      END
      
      IF ISNULL(@c_CommingleSku,'') NOT IN ('1','Y') AND
         EXISTS(SELECT TOP 1 1 FROM LOTxLOCxID WITH(NOLOCK)
                WHERE Loc = @c_Loc AND Qty > QtyPicked
                AND NOT (Storerkey = @c_Storerkey AND Sku = @c_Sku) )
      BEGIN
         SET @b_UpdLoc = 1

         UPDATE dbo.LOC WITH(ROWLOCK)
            SET CommingleSku = '1'
              , TrafficCop = NULL
          WHERE Loc = @c_Loc
      END

      SELECT @n_QtyOnHand = @n_QtyOnHand - ISNULL(SUM(Qty),0)
        FROM dbo.PICKDETAIL WITH(NOLOCK)
       WHERE Status < '9'
         AND ISNULL(ShipFlag,'') = 'Y'
         AND Qty > 0
         AND Lot = @c_Lot
         AND Loc = @c_Loc
         AND ID  = @c_ID

      IF @n_Qty > @n_QtyOnHand
         SET @n_Qty = @n_QtyOnHand

      IF @c_SourceKey  IS NULL
         SET @c_SourceKey  = ''
      IF @c_SourceType IS NULL
         SET @c_SourceType = 'isp_MoveQtyToID'

      EXECUTE nspItrnAddMove
           @n_ItrnSysId  = NULL
         , @c_StorerKey  = @c_Storerkey
         , @c_SKU        = @c_Sku
         , @c_LOT        = @c_Lot
         , @c_FromLoc    = @c_Loc
         , @c_FromID     = @c_ID
         , @c_ToLoc      = @c_Loc
         , @c_ToID       = @c_ToID
         , @c_Status     = ''
         , @c_LOTtable01 = ''
         , @c_LOTtable02 = ''
         , @c_LOTtable03 = ''
         , @d_lottable04 = NULL
         , @d_lottable05 = NULL
         , @c_LOTtable06 = ''
         , @c_LOTtable07 = ''
         , @c_LOTtable08 = ''
         , @c_LOTtable09 = ''
         , @c_LOTtable10 = ''
         , @c_LOTtable11 = ''
         , @c_LOTtable12 = ''
         , @d_lottable13 = NULL
         , @d_lottable14 = NULL
         , @d_lottable15 = NULL
         , @n_casecnt    = 0
         , @n_innerpack  = 0
         , @n_Qty        = @n_Qty
         , @n_pallet     = 0
         , @f_cube       = 0
         , @f_grosswgt   = 0
         , @f_netwgt     = 0
         , @f_otherunit1 = 0
         , @f_otherunit2 = 0
         , @c_SourceKey  = @c_SourceKey
         , @c_SourceType = @c_SourceType
         , @c_PackKey    = @c_PackKey
         , @c_UOM        = @c_PackUOM3
         , @b_UOMCalc    = 1
         , @d_EffectiveDate = NULL
         , @c_itrnkey    = ''
         , @b_Success    = @b_Success OUTPUT
         , @n_Err        = @n_Err OUTPUT
         , @c_ErrMsg     = @c_ErrMsg OUTPUT
         , @c_MoveRefKey = @c_MoveRefKey
      
      IF @b_UpdLoc = 1
      BEGIN
         UPDATE dbo.LOC WITH(ROWLOCK)
            SET LoseID       = @c_LoseID
              , CommingleSku = @c_CommingleSku
              , TrafficCop   = NULL
          WHERE Loc = @c_Loc
      END
   END

EXIT_SP:
   IF @n_continue=3
   BEGIN
      SET @b_Success = 0
      IF @@TRANCOUNT = 1 AND (@@TRANCOUNT>@n_starttcnt)
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT>@n_starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      RETURN
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT>@n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[isp_MoveQtyToID] TO NSQL
GO
