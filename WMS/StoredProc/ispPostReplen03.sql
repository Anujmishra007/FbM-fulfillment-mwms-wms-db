SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: ispPostReplen03                                         */
/* Creation Date: 08-SEP-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by: Michael Lam                                              */
/*                                                                      */
/* Purpose: FCR-7044 - ZAF_PMI Replen based on Min Max (FEFO) set up    */
/*                                                                      */
/* Called By: isp_PostReplenishment_Wrapper                             */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2025-09-08  Michael  1.0   DevOps Combined                           */
/* 2025-11-12  Michael  1.1   UWP-43723 Fix UCC Loc Not updated (ML01)  */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[ispPostReplen03]
           @c_Replenishmentkey   NVARCHAR(10)
         , @b_Success            INT            OUTPUT
         , @n_Err                INT            OUTPUT
         , @c_ErrMsg             NVARCHAR(255)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt       INT
         , @n_Continue        INT
         , @c_Storerkey       NVARCHAR(15) = ''
         , @c_Sku             NVARCHAR(20) = ''
         , @c_FromLoc         NVARCHAR(10) = ''
         , @c_ToLoc           NVARCHAR(10) = ''
         , @c_Lot             NVARCHAR(10) = ''
         , @c_FromID          NVARCHAR(18) = ''
         , @c_ToID            NVARCHAR(18) = ''
         , @c_UCCNo           NVARCHAR(20) = ''
         , @c_LoseUCC         NVARCHAR(10) = ''
         , @c_ToLocType       NVARCHAR(10) = ''
         , @n_Qty             INT          = 0
         , @n_UCC_RowRef      INT          = 0
         , @CUR_UCC           CURSOR

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1
   SET @n_err      = 0
   SET @c_errmsg   = ''

   SELECT @c_Storerkey = ISNULL(ITR.Storerkey,'')
        , @c_Sku       = ISNULL(ITR.Sku,'')
        , @c_FromLoc   = ISNULL(ITR.FromLoc,'')
        , @c_ToLoc     = ISNULL(ITR.ToLoc,'')
        , @c_Lot       = ISNULL(ITR.Lot,'')
        , @c_FromID    = ISNULL(ITR.FromID,'')
        , @c_ToID      = ISNULL(ITR.ToID,'')
        , @c_UCCNo     = ISNULL(RP.RefNo,'')
        , @n_Qty       = ISNULL(ITR.Qty,0)
        , @c_LoseUCC   = ISNULL(LOC.LoseUCC,'')
        , @c_ToLocType = ISNULL(SL.LocationType,'')
     FROM dbo.REPLENISHMENT RP WITH(NOLOCK)
     JOIN dbo.ITRN         ITR WITH(NOLOCK) ON RP.Replenishmentkey = ITR.Sourcekey AND ITR.SourceType = 'ntrReplenishmentUpdate' AND ITR.TranType = 'MV'
                                           AND RP.Lot = ITR.Lot AND RP.FromLoc = ITR.FromLoc AND RP.ToLoc = ITR.ToLoc AND RP.ID = ITR.FromID
--ML01                                       AND RP.ToID = ITR.ToID
     JOIN dbo.LOC          LOC WITH(NOLOCK) ON ITR.ToLoc = LOC.Loc
     LEFT JOIN dbo.SKUxLOC  SL WITH(NOLOCK) ON ITR.Storerkey = SL.Storerkey AND ITR.Sku = SL.Sku AND ITR.ToLoc = SL.Loc
     CROSS APPLY dbo.fnc_SelectGetRight(LOC.Facility, ITR.Storerkey, '', 'UCC') CFG
    WHERE RP.Replenishmentkey = @c_Replenishmentkey
      AND RP.Confirmed = 'Y'
      AND CFG.Authority = '1'


   IF @@ROWCOUNT <= 0
      GOTO QUIT_SP

   BEGIN TRAN

   IF ISNULL(@c_FromID,'') <> '' AND ISNULL(@c_UCCNo,'')='' 
      SET @CUR_UCC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT UCC_RowRef
      FROM (
         SELECT UCCNo
              , UCC_RowRef
              , Qty
              , CumQty = SUM(Qty) OVER(ORDER BY UCCNo, UCC_RowRef)
           FROM dbo.UCC WITH(NOLOCK)
          WHERE Storerkey = @c_Storerkey
            AND Sku = @c_Sku
            AND Lot = @c_Lot
            AND Loc = @c_FromLoc
            AND ID  = @c_FromID
      ) X
      WHERE X.CumQty - X.Qty + 1 <= @n_Qty
      ORDER BY UCCNo, UCC_RowRef
   ELSE
      SET @CUR_UCC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT UCC_RowRef
        FROM dbo.UCC WITH(NOLOCK)
       WHERE Storerkey = @c_Storerkey
         AND Sku = @c_Sku
         AND Lot = @c_Lot
         AND Loc = @c_FromLoc
         AND ID  = @c_FromID
         AND UCCNo = @c_UCCNo
         AND ISNULL(@c_UCCNo,'')<>''
       ORDER BY UCCNo, UCC_RowRef

   OPEN @CUR_UCC
   FETCH NEXT FROM @CUR_UCC INTO @n_UCC_RowRef

   WHILE @@FETCH_STATUS = 0 AND @n_continue IN (1,2)
   BEGIN
      IF @n_UCC_RowRef > 0
      BEGIN
         UPDATE UCC
         SET Loc = @c_ToLoc
           , ID  = @c_ToID
           , Status = CASE WHEN @c_LoseUCC = '1' THEN '6'
                           ELSE Status END
         WHERE UCC_RowRef = @n_UCC_RowRef

         SELECT @n_err = @@ERROR
         IF @n_err <> 0
         BEGIN
            SET @n_continue = 3
            SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
            SET @n_err = 81010   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update UCC Table Failed. (ispPostReplen03)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         END
      END

      FETCH NEXT FROM @CUR_UCC INTO @n_UCC_RowRef
   END
   CLOSE @CUR_UCC
   DEALLOCATE @CUR_UCC

QUIT_SP:

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ispPostReplen03'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
GRANT EXECUTE ON  [dbo].[ispPostReplen03] TO [NSQL]
GO
