IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispPOReplenCfm01]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[ispPOReplenCfm01]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: ispPOReplenCfm01                                        */
/* Creation Date: 13-JUN-2018                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: WMS-5218 - [CN] UA Relocation Phase II - Exceed Generate    */
/*          and Confirm Replenishment(B2C)                              */ 
/*                                                                      */ 
/* Called By: ispPostGenEOrderReplenWrapper                             */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/************************************************************************/
CREATE PROC ispPOReplenCfm01
           @c_ReplenishmentGroup NVARCHAR(10) 
         , @c_ReplenishmentKey   NVARCHAR(10) 
         , @b_Success            INT            OUTPUT
         , @n_Err                INT            OUTPUT
         , @c_ErrMsg             NVARCHAR(255)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt          INT
         , @n_Continue           INT 

         , @n_UCC_RowRef         BIGINT    

         , @cur_UCC              CURSOR

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1
   SET @n_err      = 0
   SET @c_errmsg   = ''

   IF NOT EXISTS (SELECT 1
                  FROM PACKTASK PT WITH (NOLOCK) 
                  WHERE PT.ReplenishmentGroup = @c_ReplenishmentGroup
                  )
   BEGIN
      GOTO QUIT_SP
   END

   BEGIN TRAN

   SET @cur_UCC = CURSOR FAST_FORWARD READ_ONLY FOR
   SELECT UCC.UCC_RowRef  
   FROM   UCC WITH (NOLOCK)
   WHERE  UCC.Status < '6'
   AND    EXISTS( SELECT 1
                  FROM PICKDETAIL PD WITH (NOLOCK)
                  JOIN   PACKTASK   PT WITH (NOLOCK) ON (PD.PickSlipNo = PT.TaskBatchNo)
                                                     AND(PD.Orderkey   = PT.Orderkey)
                  WHERE  PT.ReplenishmentGroup = @c_ReplenishmentGroup
                  AND    PD.UOM = '2'
                  AND    PD.Status < '5'
                  AND    PD.ShipFlag NOT IN ('P','Y') 
                  AND    PD.DropID = UCC.UCCNo
                )
   UNION
   SELECT UCC.UCC_RowRef
   FROM   UCC WITH (NOLOCK)
   JOIN   REPLENISHMENT RP WITH (NOLOCK) ON (UCC.UserDefined10 = RP.ReplenishmentKey)
   WHERE  RP.ReplenishmentKey   = @c_ReplenishmentKey
   AND    RP.ReplenishmentGroup = @c_ReplenishmentGroup
   AND    UCC.Status < '6'
   ORDER BY UCC_RowRef

   OPEN @cur_UCC
   
   FETCH NEXT FROM @cur_UCC INTO @n_UCC_RowRef
   WHILE @@FETCH_STATUS <> -1
   BEGIN
      UPDATE UCC WITH (ROWLOCK)
      SET Status = '6'
         ,EditWho  = SUSER_SNAME()
         ,EditDate = GETDATE()
      WHERE UCC_RowRef = @n_UCC_RowRef

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 62310
         SET @c_ErrMsg = 'NSQL' +CONVERT(CHAR(5), @n_Err) + ': Update UCC Table Fail. (ispPOReplenCfm01)'
         GOTO QUIT_SP
      END

      FETCH NEXT FROM @cur_UCC INTO @n_UCC_RowRef 
   END
   CLOSE @cur_UCC
   DEALLOCATE @cur_UCC 
    
QUIT_SP:

   IF CURSOR_STATUS( 'VARIABLE', '@cur_UCC') in (0 , 1)  
   BEGIN
      CLOSE @cur_UCC
      DEALLOCATE @cur_UCC
   END

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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ispPOReplenCfm01'
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

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
   RETURN
END -- procedure
GO
GRANT EXECUTE ON [dbo].[ispPOReplenCfm01] TO nSQL 
GO
