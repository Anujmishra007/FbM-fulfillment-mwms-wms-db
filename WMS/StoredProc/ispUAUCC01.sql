SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Trigger: ispUAUCC01                                                  */
/* Creation Date: 20-Apr-2015                                           */
/* Copyright: LF Logistics                                              */
/* Written by: YTWan                                                    */
/*                                                                      */
/* Purpose: SOS#337957 - ANF - CR on unallocation logic (for handling   */
/*          shared UCC in multiple orders)                              */
/* Called By: ntrPickdetaildelete Trigger when StorerConfig             */
/*            UnAllocUCCPickCode is setup                               */
/*                                                                      */
/* PVCS Version: 1.3                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 06/10/2016   TLTING    1.1 ADD NOLOCK                                */
/* 07/09/2017   Leong     1.2 IN00459369 - Add StorerKey.               */
/* 04-Dec-2025  WL01      1.3 UWP-44797 Support update by Pickdetailkey */
/* 13-Feb-2026  TK01      1.4 UWP-48857 Restructure Update using Loop   */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[ispUAUCC01]
(   @c_Storerkey  NVARCHAR(15)
  , @b_Success    INT           OUTPUT
  , @n_Err        INT           OUTPUT
  , @c_ErrMsg     NVARCHAR(255) OUTPUT
  , @c_Pickdetailkey NVARCHAR(10) = ''   --WL01
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Debug              INT
         , @n_Cnt                INT
         , @n_Continue           INT
         , @n_StartTCount        INT

   DECLARE @CUR_UCC              CURSOR      --(TK01)
         , @n_UCC_RowRef         INT         --(TK01)

   SET @b_Success       = 1
   SET @n_Err           = 0
   SET @c_ErrMsg        = ''
   SET @b_Debug         = '0'
   SET @n_Continue      = 1
   SET @n_StartTCount   = @@TRANCOUNT

   BEGIN TRAN

   --(TK01) - Start - Commented for restructure using Loop
   --WL01 S
   -- If @c_Pickdetailkey is provided (from ntrPickDetailUpdate), use PickDetailKey path
   -- If @c_Pickdetailkey is blank (from ntrPickDetailDelete), use #D_PICKDETAIL path
   --IF ISNULL(TRIM(@c_Pickdetailkey), '') <> ''
   --BEGIN
   --   UPDATE U 
   --   SET U.STATUS = '1'
   --     , U.PickdetailKey = ''
   --     , U.OrderKey = ''
   --     , U.OrderLineNumber = ''
   --     , U.WaveKey = ''
   --   FROM UCC U
   --   WHERE  U.Storerkey = @c_Storerkey
   --   AND    U.Status > '2' AND U.Status < '6'
   --   AND    EXISTS ( SELECT 1 
   --                   FROM PICKDETAIL PD (NOLOCK) 
   --                   WHERE PD.PickDetailKey = @c_Pickdetailkey
   --                   AND PD.Storerkey = @c_Storerkey
   --                   AND PD.DropID = U.UCCNo
   --                   AND PD.Status < '9' )
   --   AND NOT EXISTS ( SELECT 1 
   --                    FROM PICKDETAIL PD (NOLOCK) 
   --                    WHERE PD.Storerkey = @c_Storerkey
   --                    AND PD.DropID = U.UCCNo
   --                    AND PD.Status < '9'
   --                    AND PD.Qty > 0 )   --1 UCC Shares multiple pickdetail - ensure ALL have Qty = 0
   --END
   --ELSE IF OBJECT_ID('tempdb..#D_PICKDETAIL') IS NOT NULL
   --BEGIN   --WL01 E
   --   UPDATE UCC SET STATUS = '1'
   --      ,UCC.PickdetailKey = ''
   --      ,UCC.OrderKey = ''
   --      ,UCC.OrderLineNumber = ''
   --      ,UCC.WaveKey = ''
   --   FROM UCC U
   --   WHERE  U.Storerkey = @c_Storerkey
   --   AND    U.Status > '2' AND U.Status < '6'
   --   AND    EXISTS (SELECT 1 FROM #D_PICKDETAIL d WHERE d.DropID = U.UCCNo AND d.Storerkey = @c_Storerkey AND d.Status < '9') -- IN00459369
   --   AND    NOT EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK) WHERE PD.DropID = U.UCCNo AND PD.Storerkey = @c_Storerkey AND PD.Status < '9') -- IN00459369
   --END   --WL01   


   --WL01 S
   -- If @c_Pickdetailkey is provided (from ntrPickDetailUpdate), use PickDetailKey path
   -- If @c_Pickdetailkey is blank (from ntrPickDetailDelete), use #D_PICKDETAIL path
   IF ISNULL(TRIM(@c_Pickdetailkey), '') <> ''
   BEGIN

      SET @CUR_UCC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT U.UCC_RowRef
      FROM   UCC U (NOLOCK)
      WHERE  U.Storerkey = @c_Storerkey
      AND    U.Status > '2' AND U.Status < '6'
      AND    EXISTS ( SELECT 1 
                      FROM PICKDETAIL PD (NOLOCK) 
                      WHERE PD.PickDetailKey = @c_Pickdetailkey
                      AND PD.Storerkey = @c_Storerkey
                      AND PD.DropID = U.UCCNo
                      AND PD.Status < '9' )
      AND NOT EXISTS ( SELECT 1 
                       FROM PICKDETAIL PD (NOLOCK) 
                       WHERE PD.Storerkey = @c_Storerkey
                       AND PD.DropID = U.UCCNo
                       AND PD.Status < '9'
                       AND PD.Qty > 0 )   --1 UCC Shares multiple pickdetail - ensure ALL have Qty = 0

   END
   ELSE IF OBJECT_ID('tempdb..#D_PICKDETAIL') IS NOT NULL
   BEGIN

      SET @CUR_UCC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT U.UCC_RowRef
      FROM   UCC U (NOLOCK)
      WHERE  U.Storerkey = @c_Storerkey
      AND    U.Status > '2' AND U.Status < '6'
      AND    EXISTS (SELECT 1 FROM #D_PICKDETAIL d WHERE d.DropID = U.UCCNo AND d.Storerkey = @c_Storerkey AND d.Status < '9') -- IN00459369
      AND    NOT EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK) WHERE PD.DropID = U.UCCNo AND PD.Storerkey = @c_Storerkey AND PD.Status < '9') -- IN00459369

   END

   IF CURSOR_STATUS('variable', '@CUR_UCC') >= -1
   BEGIN

      OPEN @CUR_UCC
      FETCH NEXT FROM @CUR_UCC INTO @n_UCC_RowRef

      WHILE @@FETCH_STATUS = 0
      BEGIN

         UPDATE UCC WITH (ROWLOCK)
         SET STATUS = '1'
           , PickdetailKey = ''
           , OrderKey = ''
           , OrderLineNumber = ''
           , WaveKey = ''
         WHERE  UCC_RowRef = @n_UCC_RowRef

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 80010
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                         +': Update UCC Table Failed. (ispUAUCC01)'
                         +'(' + ERROR_MESSAGE() + ')' 
         END

         FETCH NEXT FROM @CUR_UCC INTO @n_UCC_RowRef
      END
      CLOSE @CUR_UCC
      DEALLOCATE @CUR_UCC

   END
   --(TK01) - End


   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCount
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCount
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispUAUCC01'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCount
      BEGIN
         COMMIT TRAN
      END

      RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[ispUAUCC01] TO nSQL
GO