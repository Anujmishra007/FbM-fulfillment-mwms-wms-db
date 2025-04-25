/****** Object:  StoredProcedure [dbo].[mspPCKD01]    Script Date: 3/24/2025 8:11:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/************************************************************************/
/* Stored Procedure: mspPCKD01                                         */
/* Creation Date: 21-Mar-2025                                           */
/* Copyright: Maersk                                                    */
/* Written by: YWA059                                                   */
/*                                                                      */
/* Purpose: Clear CaseId from PICKDETAIL When unpack by LabelNo,SKU     */
/*                                                                      */
/* Called By: isp_PackdetailTrigger_Wrapper from PackDetail Trigger     */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1                                                           */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2025-03-21  YWA059   1.0   Clear CaseId from PICKDETAIL for hillsAU  */
/*                            When unpack by lableNo,SKU for FCR-3752   */
/************************************************************************/
CREATE OR ALTER          PROC [dbo].[mspPCKD01]     
   @c_Action        NVARCHAR(10),
   @c_Storerkey     NVARCHAR(15),  
   @b_Success       INT      OUTPUT,
   @n_Err           INT      OUTPUT, 
   @c_ErrMsg        NVARCHAR(250) OUTPUT
AS   
BEGIN  
   SET NOCOUNT ON   
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @n_Continue        INT,
           @n_StartTCnt       INT

   SELECT @n_Continue = 1, @n_StartTCnt = @@TRANCOUNT, @n_Err = 0, @c_ErrMsg = '', @b_Success = 1

   IF @c_Action <> 'DELETE'
      GOTO QUIT_SP

   IF OBJECT_ID('tempdb..#DELETED') IS NULL
   BEGIN
      GOTO QUIT_SP
   END

   IF (@c_Action = 'DELETE') 
   BEGIN
		IF EXISTS(SELECT 1 FROM #DELETED D
			      INNER JOIN PICKDETAIL pkd (NOLOCK) 
				          ON D.StorerKey = pkd.Storerkey
						 AND D.PickSlipNo = pkd.PickSlipNo 
						 AND (D.Sku = pkd.Sku OR ISNULL(D.Sku,'')='')
						 AND D.LabelNo = pkd.CaseId )
	   BEGIN
		  DECLARE @n_PickDetailKey NVARCHAR(18)
		  DECLARE CUR_PICKDETAILKEY_DELETE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
			 SELECT pkd.PickDetailKey
			 FROM #DELETED D
			 INNER JOIN PickDetail pkd (NOLOCK) 
			         ON D.StorerKey = pkd.Storerkey
					AND D.PickSlipNo = pkd.PickSlipNo 
				    AND (D.Sku = pkd.Sku OR ISNULL(D.Sku,'')='')
					AND D.LabelNo = pkd.CaseId
			 ORDER BY pkd.PickDetailKey
		  OPEN CUR_PICKDETAILKEY_DELETE      
		  FETCH NEXT FROM CUR_PICKDETAILKEY_DELETE INTO @n_PickDetailKey
		  WHILE @@FETCH_STATUS = 0 
		  BEGIN
			 UPDATE PICKDETAIL WITH (ROWLOCK) 
			 SET CaseID = ''
			 ,TrafficCop = NULL
			 WHERE PickDetailKey = @n_PickDetailKey
			 SELECT @n_err = @@ERROR      
			 IF @n_err <> 0      
			 BEGIN      
				SELECT @n_continue = 3      
				SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 219955
				SELECT @c_errmsg='NSQL'+CONVERT(CHAR(6), @n_err)+': UPDATE Failed On Table PICKDETAIL. (mspPCKD01)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '      
				BREAK
			 END  
			 FETCH NEXT FROM CUR_PICKDETAILKEY_DELETE INTO @n_PickDetailKey
		  END
		  CLOSE CUR_PICKDETAILKEY_DELETE
	      DEALLOCATE CUR_PICKDETAILKEY_DELETE
	   END
   END
  
   QUIT_SP:
   
   IF @n_Continue=3  -- Error Occured - Process AND Return
   BEGIN
      SELECT @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'mspPCKD01'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END  
END  

GRANT EXECUTE ON [dbo].[mspPCKD01] TO NSQL