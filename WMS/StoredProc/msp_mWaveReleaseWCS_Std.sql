SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: msp_mWaveReleaseWCS_Std                             */  
/* Creation Date: 2024-01-14                                             */  
/* Copyright: mWMS                                                       */  
/* Written by: Wan                                                       */  
/*                                                                       */  
/* Purpose: Release to WCS                                               */  
/*                                                                       */  
/* Called By: mWMS Wave Release WCS                                      */  
/*                                                                       */  
/* Version: Maserk V2                                                    */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date         Author  Ver   Purposes                                   */ 
/* 2024-01-14   Wan01   1.1   Initiase Created.                          */
/*                            UWP-13590-WMS to send the Order Include    */
/*                            message to WCS upon Wave release           */ 
/*                            UWP-13591-WMS to send the PTWWaveCheck     */
/*                            message to WCS upon Wave release           */ 
/* 2024-02-22   Wan02   1.2   UWP-13590-Fixed issue                      */
/*************************************************************************/   
CREATE OR ALTER PROCEDURE [dbo].[msp_mWaveReleaseWCS_Std]      
  @c_Wavekey      NVARCHAR(10)  
 ,@b_Success      int        OUTPUT  
 ,@n_Err          int        OUTPUT  
 ,@c_Errmsg       NVARCHAR(250)  OUTPUT  
 AS  
 BEGIN  
    SET NOCOUNT ON   
    SET QUOTED_IDENTIFIER OFF   
    SET ANSI_NULLS OFF   
    SET CONCAT_NULL_YIELDS_NULL OFF  
    
    DECLARE @n_Continue       INT          = 1    
          , @n_StartTCnt      INT          = @@TRANCOUNT       -- Holds the current transaction count  
          , @n_Debug          INT          = 0
          
          , @c_Facility       NVARCHAR(5)  = ''          
          , @c_Storerkey      NVARCHAR(15) = ''
          , @c_OrderKey       NVARCHAR(10) = ''
          
          , @c_TableName      NVARCHAR(30) = ''
          , @c_Key1           NVARCHAR(10) = ''
          , @c_Key2           NVARCHAR(30) = ''
          , @c_Key3           NVARCHAR(20) = ''
          , @c_TransmitBatch  NVARCHAR(30) = ''
      
          , @c_CfgWCS         NVARCHAR(10) = ''
          
          , @cur_OPENORD      CURSOR

   SELECT TOP 1 
           @c_Facility  = o.Facility
         , @c_Storerkey = o.StorerKey
   FROM dbo.ORDERS AS o (NOLOCK)
   WHERE o.UserDefine09 = @c_Wavekey
   ORDER BY o.OrderKey DESC

   SELECT @c_CfgWCS = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'WCS')
    
   IF @c_CfgWCS = '1'
   BEGIN
      SET @cur_OPENORD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT w.OrderKey
      FROM dbo.WAVEDETAIL AS w (NOLOCK)
      JOIN ORDERS AS o (NOLOCK) ON o.OrderKey = w.OrderKey
      WHERE w.WaveKey = @c_Wavekey
      AND o.[Status] = '0'
      ORDER BY w.WaveDetailKey
      
      OPEN @cur_OPENORD
      
      FETCH NEXT FROM @cur_OPENORD INTO @c_OrderKey
      
      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         SET @c_TableName = 'WSORDCFM'                                              --(Wan02)
         SET @c_Key1 = @c_OrderKey
         SET @c_Key2 = @c_Wavekey
         SET @c_Key3 = @c_Storerkey                                                 --(wan02)
         
         EXEC dbo.ispGenTransmitLog2
               @c_TableName   = @c_TableName
            ,  @c_Key1        = @c_Key1
            ,  @c_Key2        = @c_Key2
            ,  @c_Key3        = @c_Key3
            ,  @c_TransmitBatch = @c_TransmitBatch 
            ,  @b_Success     = @b_Success
            ,  @n_err         = @n_err
            ,  @c_errmsg      = @c_errmsg
         
         IF @b_Success = 0
         BEGIN
            SET @n_Continue = 3
         END
         
         FETCH NEXT FROM @cur_OPENORD INTO @c_OrderKey   
      END
      CLOSE @cur_OPENORD
      DEALLOCATE @cur_OPENORD
      
      IF @n_Continue = 1 
      BEGIN
         SET @c_TableName = 'WSWVCHKPTW'                                            --(wan02)
         SET @c_Key1 = @c_Wavekey
         SET @c_Key2 = ''
         SET @c_Key3 = @c_Storerkey                                                 --(wan02)

         EXEC dbo.ispGenTransmitLog2
               @c_TableName   = @c_TableName
            ,  @c_Key1        = @c_Key1
            ,  @c_Key2        = @c_Key2
            ,  @c_Key3        = @c_Key3
            ,  @c_TransmitBatch = @c_TransmitBatch 
            ,  @b_Success     = @b_Success
            ,  @n_err         = @n_err
            ,  @c_errmsg      = @c_errmsg
         
         IF @b_Success = 0
         BEGIN
            SET @n_Continue = 3
         END
      END
   END    
EXIT_SP:
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "msp_mWaveReleaseWCS_Std"  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    
      RETURN  
   END  
   ELSE  
   BEGIN  
      SET @b_Success = 1  
      WHILE @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
         COMMIT TRAN  
      END  
      RETURN  
   END
END --sp end
GO
GRANT EXECUTE ON [dbo].msp_mWaveReleaseWCS_Std TO nSQL 
GO
