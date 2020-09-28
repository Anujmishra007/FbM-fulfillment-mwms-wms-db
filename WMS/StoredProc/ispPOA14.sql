IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispPOA14]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[ispPOA14]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: ispPOA14                                           */  
/* Creation Date: 26-Aug-2020                                           */  
/* Copyright: LFL                                                       */  
/* Written by: WLChooi                                                  */  
/*                                                                      */  
/* Purpose: WMS-14894 - CN NIKE ECOM PostAlloc Order Mark               */
/*                                                                      */  
/* Called By: StorerConfig.ConfigKey = PostAllocationSP                 */  
/*                                                                      */  
/* GitLab Version: 1.0                                                  */  
/*                                                                      */  
/* Version: 1.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author  Rev   Purposes                                  */  
/************************************************************************/  
CREATE PROC [dbo].[ispPOA14]    
     @c_OrderKey    NVARCHAR(10) = '' 
   , @c_LoadKey     NVARCHAR(10) = ''
   , @c_Wavekey     NVARCHAR(10) = ''
   , @b_Success     INT           OUTPUT    
   , @n_Err         INT           OUTPUT    
   , @c_ErrMsg      NVARCHAR(250) OUTPUT    
   , @b_debug       INT = 0    
AS    
BEGIN    
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF         
    
   DECLARE  @n_Continue              INT,    
            @n_StartTCnt             INT, -- Holds the current transaction count
            @c_Pickdetailkey         NVARCHAR(10),
            @c_Orderkey2             NVARCHAR(10),
            @c_Putawayzone           NVARCHAR(4000)
                                                                          
   SELECT @n_StartTCnt=@@TRANCOUNT , @n_Continue=1, @b_Success=1, @n_Err=0, @c_ErrMsg=''  
   
   CREATE TABLE #TMP_ORD (
      Orderkey      NVARCHAR(10) NULL,
      Putawayzone   NVARCHAR(10) NULL
   )

   CREATE TABLE #TMP_ORD_Final (
      Orderkey      NVARCHAR(10) NULL,
      Putawayzone   NVARCHAR(4000) NULL
   )

   IF @n_continue IN(1,2) 
   BEGIN
      INSERT INTO #TMP_ORD (Orderkey, Putawayzone)
      SELECT O.Orderkey, LOC.Putawayzone
      FROM PICKDETAIL PD (NOLOCK)
      JOIN LOC LOC (NOLOCK) ON LOC.LOC = PD.LOC
      LEFT JOIN LOADPLANDETAIL LPD (NOLOCK) ON LPD.Orderkey = PD.Orderkey
      LEFT JOIN WAVEDETAIL WD (NOLOCK) ON WD.Orderkey = LPD.Orderkey
      JOIN ORDERS O (NOLOCK) ON O.Orderkey = PD.Orderkey
      JOIN CODELKUP CL (NOLOCK) ON CL.Listname = 'NKEEXWH' AND CL.Storerkey = PD.Storerkey
                              AND CL.Code = LOC.Putawayzone
      WHERE (LPD.Loadkey = @c_Loadkey OR ISNULL(@c_Loadkey,'') = '')
      AND (WD.Wavekey = @c_Wavekey OR ISNULL(@c_Wavekey,'') = '')
      AND (O.Orderkey = @c_Orderkey OR ISNULL(@c_Orderkey,'') = '')
      AND O.DocType = 'E'
      GROUP BY O.Orderkey, LOC.Putawayzone
      ORDER BY O.Orderkey

      INSERT INTO #TMP_ORD_Final
      SELECT DISTINCT t2.Orderkey, 
             STUFF((SELECT RTRIM(t1.Putawayzone) FROM #TMP_ORD t1
                    WHERE t1.Orderkey = t2.Orderkey
                    ORDER BY t1.Putawayzone FOR XML PATH('')),1,0,'' )
      FROM #TMP_ORD t2
      ORDER BY t2.Orderkey
   END

   IF @n_continue IN(1,2) 
   BEGIN   	         
      DECLARE cur_ORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT Orderkey, Putawayzone
         FROM #TMP_ORD_Final 
         ORDER BY Orderkey
      
      OPEN cur_ORD  
          
      FETCH NEXT FROM cur_ORD INTO @c_Orderkey2, @c_Putawayzone
          
      WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)
      BEGIN     
         --SELECT @c_Orderkey2, @c_Putawayzone

         UPDATE ORDERS WITH (ROWLOCK)
         SET B_Address4 = SUBSTRING(@c_Putawayzone, 1, 45),
             EditDate = GETDATE(),
             EditWho = SUSER_SNAME(),
             TrafficCop = NULL
         WHERE Orderkey = @c_Orderkey2

         SET @n_err = @@ERROR
         
         IF @n_err <> 0                                                                                                                                                             
         BEGIN                                                                                                                                                                                
            SELECT @n_Continue = 3                                                                                                                                                            
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 35010   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                          
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update ORDERS table failed. (ispPOA13)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '           
         END

         FETCH NEXT FROM cur_ORD INTO @c_Orderkey2, @c_Putawayzone
      END
      CLOSE cur_ORD
      DEALLOCATE cur_ORD      
   END
         
EXIT_SP:
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
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'ispPOA14'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
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
    
END -- Procedure  
GO
GRANT EXECUTE ON [dbo].[ispPOA14] TO nSQL 
GO
                                                                                                                                                                                                                                                                                                                                 