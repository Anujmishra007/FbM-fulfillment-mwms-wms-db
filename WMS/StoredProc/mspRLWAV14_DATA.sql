SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*************************************************************************/
/* Stored Procedure: mspRLWAV14_DATA                                     */
/* Creation Date: 21-Jul-2026                                            */
/* Copyright: Maersk Logistics                                           */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: FCR-14547 CANADA MGACA Wave Release                          */
/*                                                                       */
/* Called By: Wave                                                       */
/*                                                                       */
/* Version: 1.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 21-Jul-2026 WLChooi  1.0   Initial Version                            */
/*************************************************************************/    
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV14_DATA]        
   @c_Wavekey     NVARCHAR(10)
,  @b_Success     INT            = 1   OUTPUT
,  @n_Err         INT            = 0   OUTPUT
,  @c_ErrMsg      NVARCHAR(255)  = ''  OUTPUT 
,  @n_debug       INT            = 0                     
AS    
BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
     
   DECLARE
           @n_StartTCnt          INT   = @@TRANCOUNT
         , @n_Continue           INT   = 1
         , @n_RowCount           INT   = 0

         , @c_SourceType         NVARCHAR(30)= 'mspRLWAV14'
         , @c_PickCondition_SQL  NVARCHAR(MAX)= ''
  
   SET @b_Success = 1
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''

   --@n_Err Start 63010
   SET @c_PickCondition_SQL = 'PICKDETAIL.Status = ''0'' AND PICKDETAIL.Qty > 0'

   IF @n_debug = 5
   BEGIN
      SET @c_PickCondition_SQL = 'PICKDETAIL.Qty > 0'
   END
 
   EXEC isp_CreatePickdetail_WIP 
      @c_Loadkey = ''                                 
   ,  @c_Wavekey   = @c_Wavekey
   ,  @c_WIP_RefNo = @c_SourceType
   ,  @c_PickCondition_SQL = @c_PickCondition_SQL  
   ,  @c_Action  = 'I' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records    
   ,  @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization    
   ,  @b_Success = @b_Success OUTPUT
   ,  @n_Err     = @n_err     OUTPUT
   ,  @c_ErrMsg  = @c_errmsg  OUTPUT
 
   IF @b_Success <> 1
   BEGIN
      SET @n_continue = 3
   END

   QUIT_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV14_DATA'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      IF @n_Continue = 4 SET @b_Success = 4

      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END 
GO
GRANT EXECUTE ON [dbo].[mspRLWAV14_DATA] TO [NSQL]
GO
