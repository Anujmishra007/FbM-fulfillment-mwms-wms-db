SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/***************************************************************************/
/* Store Procedure: isp_Batching_AssignCart_Wrapper                        */
/* Creation Date: 29-NOV-2023                                              */
/* Copyright: MAERSK                                                       */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: WMS-24313 Allow custom SP for batching assign cart             */
/*          storerconfig Batching_Assign_Cart_SP = ispBATCHASGCART??       */
/*                                                                         */
/* Called By: isp_Batching_AssignCart                                      */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author    Ver.  Purposes                                   */
/* 29-NOV-2023  NJOW      1.0   DEVOPS Combine Script                      */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_Batching_AssignCart_Wrapper] 
    @c_TaskBatchNo   NVARCHAR(10)   
  , @b_Success       INT           OUTPUT
  , @n_Err           INT           OUTPUT
  , @c_ErrMsg        NVARCHAR(255) OUTPUT   
AS 
BEGIN
   SET NOCOUNT ON                                                                                                                                                                                                                        	
   SET QUOTED_IDENTIFIER OFF                                                                                                                                                                                                            	
   SET ANSI_NULLS OFF                                                                                                                                                                                                                     
   SET CONCAT_NULL_YIELDS_NULL OFF                                                                                                                                                                                                        
                                                                                                                                                                                                                                          
   DECLARE @n_continue      INT,                                                                                                                                                                                                          
           @c_SPCode        NVARCHAR(30),                                                                                                                                                                                                 
           @c_SQL           NVARCHAR(MAX),
           @n_StartTCnt     INT,
           @c_Storerkey     NVARCHAR(15),
           @c_Facility      NVARCHAR(5)                                                                                                                                                                         
                                                                                                                                                                                                                                          
   SELECT @c_SPCode='', @n_err=0, @b_success=1, @c_errmsg='', @n_StartTCnt=@@TRANCOUNT
   
   SELECT @c_Storerkey = MAX(O.Storerkey),
          @c_Facility = MAX(O.Facility)
   FROM ORDERS O (NOLOCK)
   JOIN PICKDETAIL PD (NOLOCK) ON O.Orderkey = PD.Orderkey
   JOIN PACKTASK PT (NOLOCK) ON O.Orderkey = PT.Orderkey
   WHERE PT.TaskBatchNo = @c_TaskBatchNo
   AND RIGHT(RTRIM(ISNULL(PD.Notes,'')),1) IN ('1','4') --1=Multi-S 4=Multi-M   
                                                                                                                                                                                                                                          
   SELECT @c_SPCode = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'Batching_AssignCart_SP')                                                                                                                                         
                                                                                                                                                                                                                                          
   IF ISNULL(RTRIM(@c_SPCode),'') IN( '','0')                                                                                                                                                                                             
   BEGIN                                                                                                                                                                                                                                  
      GOTO QUIT_SP                                                                                                                                                                                                                       
   END                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                          
   IF NOT EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = RTRIM(@c_SPCode) AND type = 'P')                                                                                                                                              
   BEGIN                                                                                                                                                                                                                                  
       SELECT @n_continue = 3                                                                                                                                                                                                             
       SELECT @c_ErrMsg = CONVERT(CHAR(250), @n_Err),                                                                                                                                                                                     
              @n_Err = 31012 -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                                                                                                                        
       SELECT @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) +                                                                                                                                                                             
              ': Storerconfig Batching_AssignCart_SP - Stored Proc name invalid ('+RTRIM(ISNULL(@c_SPCode,''))+') (isp_Batching_AssignCart_Wrapper)'                                                                                  
       GOTO QUIT_SP                                                                                                                                                                                                                       
   END                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                          
   SET @c_SQL = 'EXEC ' + @c_SPCode + ' @c_TaskBatchNo=@c_TaskBatchNoP, @b_Success=@b_SuccessP OUTPUT, @n_Err=@n_ErrP OUTPUT, @c_ErrMsg=@c_ErrMsgP OUTPUT '                                                                                                                                     
                                                                                                                                                                                                                                          
   EXEC sp_executesql @c_SQL,                                                                                                                                                                                                             
        N'@c_TaskBatchNoP NVARCHAR(10), @b_SuccessP INT OUTPUT, @n_ErrP INT OUTPUT, @c_ErrMsgP NVARCHAR(250) OUTPUT',  
        @c_TaskBatchNo,                                                                                                                                                                                                                    
        @b_Success OUTPUT,                                                                                                             
        @n_Err OUTPUT,                                                                                                                                                                                                                    
        @c_ErrMsg OUTPUT                                                                                                                                                                                                                  
                                                                                                                                                                                                                                          
   IF @b_Success <> 1                                                                                                                                                                                                                     
   BEGIN                                                                                                                                                                                                                                  
      SELECT @n_continue = 3                                                                                                                                                                                                             
      GOTO QUIT_SP                                                                                                                                                                                                                       
   END                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
   QUIT_SP:

   IF @n_Continue=3  -- Error Occured - Process And Return  
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
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_Batching_AssignCart_Wrapper'  
  		--RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012 
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
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

GRANT EXECUTE ON isp_Batching_AssignCart_Wrapper to nSQL
GO
