SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO    
/*************************************************************************/    
/* Stored Procedure: mspWaveReleaseWCS03                                 */  
/* Creation Date: 2026-06-10                                             */  
/* Copyright: Maersk Logistics                                           */    
/* Written by: Wan                                                       */  
/*                                                                       */    
/* Purpose: FCR-13434 - AEOMX Release PIECE PICK To WCS                  */    
/*                                                                       */    
/* Called By: WMS Wave Release To WCS                                    */  
/*                                                                       */    
/* Version: 1.0                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date         Author  Ver   Purposes                                   */ 
/*************************************************************************/     
CREATE OR ALTER PROCEDURE [dbo].[mspWaveReleaseWCS03]  
   @c_Wavekey      NVARCHAR(10)    
,  @b_Success      INT           = 1   OUTPUT    
,  @n_Err          INT           = 0   OUTPUT    
,  @c_Errmsg       NVARCHAR(250) = ''  OUTPUT    
AS    
BEGIN    
    SET NOCOUNT ON     
    SET QUOTED_IDENTIFIER OFF     
    SET ANSI_NULLS OFF     
    SET CONCAT_NULL_YIELDS_NULL OFF    
      
    DECLARE @n_Continue          INT          = 1      
         ,  @n_StartTCnt         INT          = @@TRANCOUNT       -- Holds the current transaction count  
         ,  @n_Debug             INT          = 0            
         ,  @c_Facility          NVARCHAR(5)  = ''            
         ,  @c_Storerkey         NVARCHAR(15) = ''  
         ,  @c_TableName         NVARCHAR(30) = 'WSWCSNEWTM'  
         ,  @c_Key1              NVARCHAR(10) = ''  
         ,  @c_Key2              NVARCHAR(30) = ''  
         ,  @c_Key3              NVARCHAR(20) = ''  
         ,  @c_TransmitBatch     NVARCHAR(30) = '0' 
         ,  @c_TaskDetailKey     NVARCHAR(10) = ''  
         ,  @c_Groupkey          NVARCHAR(10) = ''  
    
         ,  @Cur_PICK            CURSOR

   SET @b_success = 0
   SET @n_err     = 0
   SET @c_errmsg  = ''  
  

   IF OBJECT_ID('tempdb..#TMP_WAVETASK') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_WAVETASK
   END

   CREATE TABLE #TMP_WAVETASK
   (  [Wavekey]      [NVARCHAR](10)    NOT NULL    DEFAULT('')
   ,  [TaskDetailkey][NVARCHAR](10)    NOT NULL    DEFAULT('') PRIMARY KEY
   ,  [Tasktype]     [NVARCHAR](10)    NOT NULL    DEFAULT('')
   ,  [UOM]          [NVARCHAR](10)    NOT NULL    DEFAULT('')
   ,  [Groupkey]     [NVARCHAR](10)    NOT NULL    DEFAULT('')
   ,  [Status]       [NVARCHAR](10)    NOT NULL    DEFAULT(0) 
   ) 

   CREATE INDEX IDX_GroupKey ON #TMP_WAVETASK ( GroupKey, [Status] )

   SELECT TOP 1  
               @c_Facility  = O.Facility  
            ,  @c_Storerkey = O.StorerKey  
   FROM dbo.WAVEDETAIL WD (NOLOCK) 
   JOIN dbo.ORDERS O (NOLOCK) ON O.OrderKey = WD.OrderKey  
   WHERE wd.WaveKey = @c_Wavekey 
 

   INSERT INTO #TMP_WAVETASK (Wavekey, TaskDetailkey, Tasktype, UOM, GroupKey, [Status])
   SELECT td.Wavekey
         ,td.TaskDetailKey
         ,td.Tasktype
         ,td.UOM
         ,td.GroupKey
         ,td.[Status]
   FROM TaskDetail td (NOLOCK)     
   WHERE td.WaveKey = @c_WaveKey 

   SET @Cur_PICK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR     
   SELECT DISTINCT
          wt.GroupKey
   FROM #TMP_WAVETASK wt     
   WHERE wt.TaskType= 'FCP'
   AND   wt.UOM     = '6'
   AND   EXISTS ( SELECT 1
                  FROM #TMP_WAVETASK twt
                  WHERE twt.Groupkey = wt.GroupKey
                  GROUP BY twt.GroupKey
                  HAVING COUNT(DISTINCT twt.Status) = 1
                  AND    MIN(twt.Status) = '0'
                )
   ORDER BY wt.GroupKey
    
   OPEN @Cur_PICK  
      
   FETCH NEXT FROM @Cur_PICK INTO @c_GroupKey   

   WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1   
   BEGIN 
      SET @c_Key1 = @c_GroupKey
      SET @c_Key2 = @c_Wavekey
      SET @c_Key3 = @c_Storerkey

      EXEC ispGenTransmitLog2
         @c_TableName      = @c_TableName
      ,  @c_Key1           = @c_Key1
      ,  @c_Key2           = @c_Key2
      ,  @c_Key3           = @c_Key3
      ,  @c_TransmitBatch  = @c_TransmitBatch
      ,  @b_Success        = @b_Success   OUTPUT  
      ,  @n_err            = @n_err       OUTPUT  
      ,  @c_errmsg         = @c_errmsg    OUTPUT  

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3        
         SET @n_err      = 70010        
         SET @c_errmsg   = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)
                           + ': Error Executing ispGenTransmitLog2'
                           + '. (mspWaveReleaseWCS03)'        
      END

      FETCH NEXT FROM @Cur_PICK INTO  @c_GroupKey  
   END    
   CLOSE @Cur_PICK     
   DEALLOCATE @Cur_PICK  

EXIT_SP:  

   IF OBJECT_ID('tempdb..#TMP_WAVETASK') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_WAVETASK
   END

   IF @n_Continue=3  -- Error Occured - Process And Return    
   BEGIN    
      SET @b_Success = 0    
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTCnt    
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "mspWaveReleaseWCS03"  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR
   END    
   ELSE    
   BEGIN    
      SET @b_Success = 1    
      WHILE @@TRANCOUNT > @n_StartTCnt    
      BEGIN    
         COMMIT TRAN    
      END    
   END  
END  
GO
GRANT EXECUTE ON [dbo].[mspWaveReleaseWCS03] TO [NSQL]
GO
