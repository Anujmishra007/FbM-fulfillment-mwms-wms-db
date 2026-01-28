SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO    
/*************************************************************************/    
/* Stored Procedure: mspWaveReleaseWCS02                                 */  
/* Creation Date: 2025-12-02                                             */  
/* Copyright: Maersk                                                     */    
/* Written by: JihHaur                                                   */  
/*                                                                       */    
/* Purpose: FCR-9002 Release to WCS  */    
/*                                                                       */    
/* Called By: WMS Wave Release To WCS                                    */  
/*                                                                       */    
/* Version: Maserk V2                                                    */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date         Author  Ver   Purposes                                   */   
/* 2025-12-02   JihHaur 1.0  DevOps Combine Script                       */    
/*                           *Actually just update deviceProfile or some */  
/*                           table, no sending WCS. User just want to    */  
/*                           click the Release to WCS button only        */  
/* 2026-01-22   JihHaur 1.1  Change OrderType (JH01)                     */  
/* 2026-01-28   JihHaur 1.2  Hotfix (JH02)                               */ 
/*************************************************************************/     
CREATE OR ALTER PROCEDURE [dbo].[mspWaveReleaseWCS02]  
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
      
    DECLARE @n_continue          INT          = 1      
          , @n_StartTCnt         INT          = @@TRANCOUNT       -- Holds the current transaction count  
          , @n_Debug             INT          = 0            
          , @c_Facility          NVARCHAR(5)  = ''            
          , @c_Storerkey         NVARCHAR(15) = ''  
          , @c_TableName         NVARCHAR(30) = ''  
          , @c_Key1              NVARCHAR(10) = ''  
          , @c_Key2              NVARCHAR(30) = ''  
          , @c_Key3              NVARCHAR(20) = ''  
          , @c_TransmitBatch     NVARCHAR(30) = ''  
          , @c_OrderKey          NVARCHAR(10)    
          , @c_LoadKey           NVARCHAR(10)    
          , @c_PreviousLoadKey   NVARCHAR(10)  = ''  
          , @n_CBMperOrder       Float                   
          , @n_AvailableStation  INT = 0         
          , @n_LoadKey_Cnt       INT = 0  
          , @n_OrderKey_Cnt      INT = 0  
          , @n_MaxLoadPerWave    INT = 0  
          , @n_MaxOrderPerLoad   INT = 0           
          , @n_Rowref            INT  
          , @c_LOC               NVARCHAR(10)   
          , @c_DeviceID          NVARCHAR(20)    --Means Station  
          --, @c_DevicePosition    NVARCHAR(10)                
          , @n_CubicCapacity     Float          
          , @b_OrderAssigned     INT = 0             
          , @c_OrderNotAssigned  NVARCHAR(500) = ''    
          , @c_WaveStatus        NVARCHAR(10) = ''  
    
   SELECT @n_starttcnt = @@TRANCOUNT , @n_continue = 1, @b_success = 0, @n_err = 0, @c_errmsg = ''  
   SELECT @n_debug = 0  
  
   SELECT TOP 1  
               @c_Facility  = O.Facility  
            ,  @c_Storerkey = O.StorerKey  
            ,  @c_WaveStatus = W.Status  
   FROM dbo.WAVE W (NOLOCK)  
   JOIN dbo.WAVEDETAIL WD (NOLOCK) ON WD.WaveKey = W.WaveKey  
   JOIN dbo.ORDERS O (NOLOCK) ON O.OrderKey = WD.OrderKey  
   WHERE W.WaveKey = @c_Wavekey  
  
   --Get MaxLoadKey and MaxOrderKey  
   SELECT @n_MaxLoadPerWave = Option1, @n_MaxOrderPerLoad = Option2  
   FROM  StorerConfig WITH (NOLOCK)    
   WHERE StorerKey = @c_Storerkey    
   AND ConfigKey = 'MaxLoadnOrderKey'   
   AND SValue = '1'  
  
   IF @c_WaveStatus <> 2       
   BEGIN        
      SELECT @n_continue = 3        
      SELECT @n_err = 90019        
      SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Wave Status must be 2-Fully Allocated (mspWaveReleaseWCS02)'        
   END  
    
   IF @n_MaxLoadPerWave = 0       
   BEGIN        
      SELECT @n_continue = 3        
      SELECT @n_err = 90020        
      SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Kindly setup Max LoadKey in Option1 in StorerConfig MaxLoadnOrderKey(mspWaveReleaseWCS02)'        
   END  
     
   IF @n_MaxOrderPerLoad = 0       
   BEGIN        
      SELECT @n_continue = 3        
      SELECT @n_err = 90021        
      SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Kindly setup Max OrderKey in Option2 in StorerConfig MaxLoadnOrderKey(mspWaveReleaseWCS02)'        
   END  
  
   --Check Order Type and Ecom_SINGLE_Flag  
   IF @n_continue = 1 OR @n_continue = 2      
   BEGIN  
      IF EXISTS(SELECT 1   
                  FROM WAVEDETAIL (NOLOCK)      
                  JOIN ORDERS (NOLOCK) ON WAVEDETAIL.Orderkey = ORDERS.Orderkey              
                  WHERE WAVEDETAIL.Wavekey = @c_WaveKey      
                  AND ISNULL(ORDERS.DocType,'') <> 'E' AND ISNULL(ORDERS.Ecom_SINGLE_Flag,'') <> 'M')   /*JH01*/
      BEGIN   
         SELECT @n_continue = 3        
         SELECT @n_err = 90022        
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': DocType or Ecom_SINGLE_Flag not correct(mspWaveReleaseWCS02)'       
      END  
   END   
  
   --Check missing Loadkey    
   IF @n_continue = 1 OR @n_continue = 2      
   BEGIN  
      SELECT TOP 1 @c_OrderKey = ORDERS.OrderKey  
      FROM WAVEDETAIL (NOLOCK)      
      JOIN ORDERS (NOLOCK) ON WAVEDETAIL.Orderkey = ORDERS.Orderkey              
      WHERE WAVEDETAIL.Wavekey = @c_WaveKey      
      AND ISNULL(ORDERS.LoadKey,'') = ''  
  
      IF ISNULL(@c_OrderKey,'') <> ''       
      BEGIN        
         SELECT @n_continue = 3        
         SELECT @n_err = 90023        
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Missing LoadKey for ' + @c_OrderKey +  '.(mspWaveReleaseWCS02)'        
      END     
   END   
     
   -- Check numbers of OrderKey in 1 LoadKey  
   IF @n_continue = 1 OR @n_continue = 2      
   BEGIN  
      DECLARE Cur_CountOrder CURSOR LOCAL FAST_FORWARD READ_ONLY FOR     
      SELECT ORDERS.LoadKey, COUNT(ORDERS.OrderKey)  
      FROM WAVEDETAIL (NOLOCK)     
      JOIN ORDERS (NOLOCK) ON WAVEDETAIL.Orderkey = ORDERS.OrderKey    
      JOIN LOADPLANDETAIL (NOLOCK) ON LOADPLANDETAIL.OrderKey = ORDERS.Orderkey   
      WHERE WAVEDETAIL.WaveKey = @c_WaveKey        
      GROUP BY ORDERS.loadkey     
    
      OPEN Cur_CountOrder     
      FETCH NEXT FROM Cur_CountOrder INTO @c_LoadKey, @n_OrderKey_Cnt    
      WHILE @@FETCH_STATUS = 0     
      BEGIN    
         IF @n_OrderKey_Cnt > @n_MaxOrderPerLoad  
         BEGIN    
            CLOSE Cur_CountOrder     
            DEALLOCATE Cur_CountOrder                      
            SELECT @n_continue = 3        
            SELECT @n_err = 90024        
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': LoadKey ' + @c_LoadKey + ' have more than ' + @n_MaxOrderPerLoad + ' orders.(mspWaveReleaseWCS02)'        
         END    
         FETCH NEXT FROM Cur_CountOrder INTO @c_LoadKey, @n_OrderKey_Cnt    
      END    
      CLOSE Cur_CountOrder     
      DEALLOCATE Cur_CountOrder    
   END        
     
   ----Check if WCS already sent  
   --IF @n_continue = 1 OR @n_continue = 2      
   --BEGIN  
   --   SET @c_TableName = 'WSWAVELOG'  
   --         SET @c_Key1 = @c_Wavekey  
   --         SET @c_Key2 = ''  
   --         SET @c_Key3 = @c_Storerkey  
  
   --   IF EXISTS ( SELECT 1 FROM TransmitLog2 (NOLOCK) WHERE TableName = @c_TableName  
   --               AND Key1 = @c_Key1 AND Key2 = @c_Key2 AND Key3 = @c_Key3)  
   --   BEGIN  
   -- SET @n_continue = 3  
   --      SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)  
   --      SET @n_err = 90025  
   --      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Wave already released to WCS. (mspWaveReleaseWCS02) '  
   --   END  
   --END  
  
   --Create Temporary Tables      
   IF @n_continue = 1 OR @n_continue = 2      
   BEGIN    
      CREATE TABLE #AvailableLoc  
      (       
         Rowref          INT          NOT NULL IDENTITY(1, 1) PRIMARY KEY  
       , LOC             NVARCHAR(10) NULL  
       , DeviceID        NVARCHAR(20) NULL     
       , DevicePosition  NVARCHAR(10) NULL     
       , DeviceStatus    NVARCHAR(10) NULL     
       , CubicCapacity   Float        NULL  
       , LoadKey         NVARCHAR(10) NULL  
       , OrderKey        NVARCHAR(10) NULL  
      )  
      CREATE INDEX IDX_LOC ON #AvailableLoc (LOC)  
  
      INSERT INTO #AvailableLoc (LOC, DeviceID, DevicePosition, DeviceStatus, CubicCapacity)  
      SELECT DP.LOC, DP.DeviceID, DP.DevicePosition, DP.Status, L.CubicCapacity   
      FROM DeviceProfile DP (NOLOCK)  
      JOIN LOC L (NOLOCK) ON L.LOC = DP.LOC --AND L.Facility = DP.Facility   
      WHERE DP.StorerKey = @c_Storerkey   
        AND L.Facility = @c_Facility  
        AND L.Status = 'OK'  
        AND DP.DeviceType = 'STATION'  
        AND DP.Status = 'IDLE'  
        AND DP.DeviceID NOT IN (SELECT DISTINCT DeviceID FROM DeviceProfile (NOLOCK)                 
                                    WHERE StorerKey = @c_Storerkey                                         
                                      --AND L.Facility = @c_Facility  (JH02)
                                      --AND L.Status = 'OK'          (JH02)
                                      AND DeviceType = 'STATION'  
                                      AND Status IN ('BUSY','OFF'))    
      ORDER BY DP.DeviceID, CubicCapacity DESC        
   END  
  
   --Check Station available  
   IF @n_continue = 1 OR @n_continue = 2      
   BEGIN            
      SELECT @n_AvailableStation = COUNT(DISTINCT DeviceID)  
      FROM #AvailableLoc (NOLOCK)                 
            
      IF @n_AvailableStation = 0        
      BEGIN        
         SELECT @n_continue = 3        
         SELECT @n_err = 90026        
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': not enough carts available (mspWaveReleaseWCS02)'        
      END          
   END  
  
   -- Check numbers of Loadkey in 1 wave  
   IF @n_continue = 1 OR @n_continue = 2      
   BEGIN            
      SELECT @n_LoadKey_Cnt = COUNT(DISTINCT ORDERS.LoadKey)  
      FROM WAVEDETAIL (NOLOCK)   
      JOIN ORDERS (NOLOCK) ON WAVEDETAIL.Orderkey = ORDERS.Orderkey              
      WHERE WAVEDETAIL.Wavekey = @c_WaveKey      
        
      IF @n_LoadKey_Cnt = 0        
      BEGIN        
         SELECT @n_continue = 3        
         SELECT @n_err = 90027        
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': At least 1 LoadKey needed (mspWaveReleaseWCS02)'        
      END   
          
      IF @n_LoadKey_Cnt > @n_MaxLoadPerWave        
      BEGIN        
         SELECT @n_continue = 3        
         SELECT @n_err = 90028        
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Maximum LoadKey allowed is ' + @n_MaxLoadPerWave + ' (mspWaveReleaseWCS02)'        
      END    
  
      IF @n_LoadKey_Cnt > @n_AvailableStation        
      BEGIN        
         SELECT @n_continue = 3        
         SELECT @n_err = 90029        
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': not enough carts available (mspWaveReleaseWCS02)'        
      END   
   END     
     
   --Check StdCube  
   IF @n_continue = 1 OR @n_continue = 2      
   BEGIN    
      IF EXISTS (SELECT 1  
            FROM PICKDETAIL (NOLOCK) PD        
            JOIN WAVEDETAIL(NOLOCK) WD ON WD.OrderKey = PD.OrderKey  
            JOIN SKU (NOLOCK) S ON S.SKU = PD.SKU AND S.StorerKey = PD.StorerKey        
            WHERE WD.WaveKey = @c_Wavekey  
            AND PD.Storerkey = @c_Storerkey      
            AND ISNULL(S.STDCUBE,0) = 0  
            GROUP BY PD.OrderKey)          
      BEGIN  
         SELECT @n_continue = 3        
         SELECT @n_err = 90030        
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Sku.Std cannot be null or 0 (mspWaveReleaseWCS02)'        
      END     
   END  
  
   IF @n_continue = 1 OR @n_continue = 2   
   BEGIN  
      DECLARE CUR_ORDERS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT O.LoadKey, PD.OrderKey, SUM(PD.Qty * S.STDCUBE)  
         FROM PICKDETAIL (NOLOCK) PD        
         JOIN WAVEDETAIL(NOLOCK) WD ON WD.OrderKey = PD.OrderKey  
         JOIN ORDERS (NOLOCK) O ON WD.Orderkey = O.OrderKey             
         JOIN SKU (NOLOCK) S ON S.SKU = PD.SKU AND S.StorerKey = PD.StorerKey        
         WHERE WD.WaveKey = @c_Wavekey  
         AND PD.Storerkey = @c_Storerkey                                                      
         GROUP BY O.LoadKey, PD.OrderKey  
         ORDER BY O.LoadKey, SUM(PD.Qty * S.STDCUBE) DESC  
      OPEN CUR_ORDERS     
      FETCH NEXT FROM CUR_ORDERS INTO @c_LoadKey, @c_OrderKey, @n_CBMperOrder    
      WHILE @@FETCH_STATUS = 0     
      BEGIN    
         SET @b_OrderAssigned = 0    
           
         IF(@c_PreviousLoadKey <> @c_LoadKey)  
         BEGIN              
            SET @c_PreviousLoadKey = @c_LoadKey  
            SET @c_DeviceID = ''  
            SELECT TOP 1 @c_DeviceID = DeviceID  
            FROM #AvailableLoc (NOLOCK)  
            WHERE DeviceStatus = 'IDLE'  
            AND ISNULL(LoadKey,'') = ''  
            --AND DeviceID NOT IN (SELECT DISTINCT DeviceID  
            --                     FROM #AvailableLoc (NOLOCK)  
            --                      WHERE DeviceStatus = 'BUSY')  
            GROUP BY DeviceID  
            ORDER BY DeviceID   
  
            Update #AvailableLoc SET LoadKey = @c_LoadKey   
            WHERE DeviceID = @c_DeviceID  
         END  
  
         DECLARE CUR_AssignToLoc CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
            SELECT Rowref, CubicCapacity  
            FROM #AvailableLoc (NOLOCK) AL                 
            WHERE DeviceID = @c_DeviceID   
            AND DeviceStatus = 'IDLE'  
            ORDER BY CubicCapacity DESC, DevicePosition  
           
         OPEN CUR_AssignToLoc     
         FETCH NEXT FROM CUR_AssignToLoc INTO @n_Rowref, @n_CubicCapacity  
         WHILE @@FETCH_STATUS = 0     
         BEGIN    
            IF @n_CBMperOrder <= @n_CubicCapacity  
            BEGIN  
               Update #AvailableLoc SET OrderKey = @c_OrderKey, DeviceStatus = 'BUSY'  
               WHERE Rowref = @n_Rowref  
  
               SET @b_OrderAssigned = 1  
               BREAK  
            END               
            FETCH NEXT FROM CUR_AssignToLoc INTO @n_Rowref, @n_CubicCapacity  
         END    
         CLOSE CUR_AssignToLoc     
         DEALLOCATE CUR_AssignToLoc    
          
         IF @b_OrderAssigned = 0           
         BEGIN  
            SET @c_OrderNotAssigned = @c_OrderNotAssigned + @c_OrderKey + ','   
         END          
  
         FETCH NEXT FROM CUR_ORDERS INTO @c_LoadKey, @c_OrderKey, @n_CBMperOrder    
      END    
      CLOSE CUR_ORDERS     
      DEALLOCATE CUR_ORDERS    
  
   END  
  
   IF @c_OrderNotAssigned <> ''           
   BEGIN  
      SET @c_OrderNotAssigned = LEFT(@c_OrderNotAssigned, LEN(@c_OrderNotAssigned)-1)  
      SELECT @n_continue = 3        
      SELECT @n_err = 90031        
      SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+'Order ' + @c_OrderNotAssigned + ' not fit in PTW. It must be removed from wave (mspWaveReleaseWCS02)'                 
   END  
  
   IF @n_continue = 1 OR @n_continue = 2   
   BEGIN  
      SET @c_PreviousLoadKey = ''  
      DECLARE CUR_Update CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT LoadKey, OrderKey, DeviceID, LOC  
         FROM #AvailableLoc (NOLOCK)           
         WHERE ISNULL(LoadKey,'') <> ''  
         AND ISNULL(OrderKey,'') <> ''   
         ORDER BY LoadKey, Rowref  
      OPEN CUR_Update     
      FETCH NEXT FROM CUR_Update INTO @c_LoadKey, @c_OrderKey, @c_DeviceID, @c_Loc  
      WHILE @@FETCH_STATUS = 0     
      BEGIN   
         IF @c_PreviousLoadKey <> @c_LoadKey  
         BEGIN  
            SET @c_PreviousLoadKey = @c_LoadKey  
              
            UPDATE LoadPlan SET UserDefine01 = @c_DeviceID  
            WHERE LoadKey = @c_LoadKey  
              
            SELECT @n_err = @@ERROR    
            IF @n_err <> 0     
            BEGIN    
               SELECT @n_continue = 3    
               SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 90032       
               SELECT @c_errmsg = 'NSQL' +CONVERT(NVARCHAR(5),@n_err)+': Update LoadPlan Table Failed. (mspWaveReleaseWCS02)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '    
               BREAK    
            END     
  
            IF @n_continue = 1 OR @n_continue = 2   
            BEGIN  
               UPDATE DeviceProfile SET Status = 'BUSY'  
               WHERE DeviceID = @c_DeviceID  
  
               SELECT @n_err = @@ERROR    
               IF @n_err <> 0     
               BEGIN    
                  SELECT @n_continue = 3    
                  SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 90033       
                  SELECT @c_errmsg = 'NSQL' +CONVERT(NVARCHAR(5),@n_err)+': Update DeviceProfile Table Failed. (mspWaveReleaseWCS02)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '    
                  BREAK    
               END    
            END              
         END  
           
         IF @n_continue = 1 OR @n_continue = 2   
         BEGIN  
            UPDATE Orders SET UserDefine04 = @c_DeviceID  
                          ,UserDefine05 = @c_Loc  
                          ,UserDefine10 = @c_LoadKey  
            WHERE OrderKey = @c_OrderKey  
  
            SELECT @n_err = @@ERROR    
            IF @n_err <> 0     
            BEGIN    
               SELECT @n_continue = 3    
               SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 90034       
               SELECT @c_errmsg = 'NSQL' +CONVERT(NVARCHAR(5),@n_err)+': Update Orders Table Failed. (mspWaveReleaseWCS02)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '    
               BREAK    
            END    
         END  
          
      FETCH NEXT FROM CUR_Update INTO @c_LoadKey, @c_OrderKey, @c_DeviceID, @c_Loc    
      END    
      CLOSE CUR_Update     
      DEALLOCATE CUR_Update    
   END  
     
   --IF @n_continue = 1 OR @n_continue = 2   
   --BEGIN     
   --   SET @b_Success = 1  
   --   EXEC dbo.ispGenTransmitLog2  
   --         @c_TableName   = @c_TableName  
   --      ,  @c_Key1        = @c_Key1  
   --      ,  @c_Key2        = @c_Key2  
   --      ,  @c_Key3        = @c_Key3  
   --      ,  @c_TransmitBatch = @c_TransmitBatch  
   --      ,  @b_Success     = @b_Success OUTPUT  
   --      ,  @n_err         = @n_err OUTPUT  
   --      ,  @c_errmsg      = @c_errmsg OUTPUT  
  
   --   IF @b_Success = 0  
   --   BEGIN  
   --      SET @n_Continue = 3  
   --   END  
   --END  
     
EXIT_SP:  
   IF OBJECT_ID('tempdb..#AvailableLoc') IS NOT NULL  
      DROP TABLE #AvailableLoc  
  
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "mspWaveReleaseWCS02"  
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
GRANT EXECUTE ON [dbo].[mspWaveReleaseWCS02] TO [NSQL]
GO




