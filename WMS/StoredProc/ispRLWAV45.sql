SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Stored Proc: ispRLWAV45                                              */  
/* Creation Date: 03-AUG-2021                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by: CSCHONG                                                  */  
/*                                                                      */  
/* Purpose:  WMS-17585 - Adidas AU SCE trigger SO Export by wave release*/  
/*        :                                                             */  
/* Called By: ReleaseWave_SP                                            */  
/*          :                                                           */  
/* PVCS Version: 1.8                                                    */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author  Ver   Purposes                                  */  
/* 17-JAN-2022  CSCHONG 1.0   Devops Scripts Combine                    */
/************************************************************************/  
CREATE OR ALTER PROC ispRLWAV45  
        @c_wavekey      NVARCHAR(10)    
       ,@b_Success      INT            OUTPUT    
       ,@n_err          INT            OUTPUT    
       ,@c_errmsg       NVARCHAR(250)  OUTPUT    
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE    
           @n_StartTCnt       INT  
         , @n_Continue        INT 
         , @n_RowRef          INT
         , @c_Orderkey        NVARCHAR(10)  
         , @c_Storerkey       NVARCHAR(15)                                   
         , @c_Status          NVARCHAR(10)             
     
   SET @n_StartTCnt = @@TRANCOUNT  
   SET @n_Continue = 1  
   SET @n_err      = 0  
   SET @c_errmsg   = '' 
   SET @c_Storerkey = ''                     
  
   --DECLARE CUR_ORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
   --   SELECT O.Orderkey, O.Storerkey  
   --   FROM ORDERS O WITH (NOLOCK)  
   --   JOIN WAVEDETAIL WD WITH (NOLOCK) ON O.Orderkey = WD.Orderkey  
   --   WHERE WD.Wavekey = @c_Wavekey        
   --   ORDER BY O.Orderkey  
  
   --OPEN CUR_ORD        
  
   --FETCH NEXT FROM CUR_ORD INTO @c_Orderkey, @c_Storerkey 
  
   --WHILE @@FETCH_STATUS <> -1  
   --BEGIN    

       SELECT TOP 1 @c_Storerkey = O.storerkey
       FROM ORDERS O WITH (NOLOCK)  
       JOIN WAVEDETAIL WD WITH (NOLOCK) ON O.Orderkey = WD.Orderkey  
       WHERE WD.Wavekey = @c_Wavekey        
  
      EXEC ispGenTransmitlog2  
         @c_TableName = 'WSSOALCLOGAVB'    
        ,@c_Key1 = @c_Wavekey           
        ,@c_Key2 = ''  
        ,@c_Key3 = @c_Storerkey              
        ,@c_TransmitBatch = ''    
        ,@b_Success = @b_success OUTPUT             
        ,@n_err = @n_err OUTPUT                 
        ,@c_errmsg = @c_errmsg OUTPUT                
        
      IF @b_Success <> 1    
      BEGIN  
         SET @n_continue = 3    
         GOTO QUIT_SP  
      END   
 
        
   --FETCH NEXT FROM CUR_ORD INTO @c_Orderkey, @c_Storerkey
   --END       
   --CLOSE CUR_ORD  
   --DEALLOCATE CUR_ORD  
  
 
QUIT_SP:  
      
   IF CURSOR_STATUS( 'LOCAL', 'CUR_ORD') in (0 , 1)    
   BEGIN  
      CLOSE CUR_ORD  
      DEALLOCATE CUR_ORD  
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
  
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ispRLWAV45'  
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
GRANT EXECUTE ON [dbo].[ispRLWAV45] TO nSQL 
GO
