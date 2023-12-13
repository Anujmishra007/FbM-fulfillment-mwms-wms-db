SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/    
/* Stored Procedure: ispPOA25                                           */    
/* Creation Date: 04-AUG-2023                                           */    
/* Copyright: LFL                                                       */    
/* Written by:                                                          */    
/*                                                                      */    
/* Purpose: WMS-23310 - TW - Identify order with single or multiple     */  
/*          pickzone and update to order userdefine                     */
/*                                                                      */
/*                                                                      */    
/* Called By: StorerConfig.ConfigKey = PostAllocationSP                 */    
/*                                                                      */    
/* GitLab Version: 1.0                                                  */    
/*                                                                      */    
/* Version: 7.0                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author  Rev   Purposes                                  */ 
/* 04-AUG-2023  NJOW    1.0   Devops Combine Script                     */
/* 30-NOV-2023  NJOW01  1.1   WMS-22310 Update Loc to userdefine05      */
/************************************************************************/    
CREATE OR ALTER PROC [dbo].[ispPOA25]      
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
            @c_PickZone              NVARCHAR(10),
            @c_GetOrderkey           NVARCHAR(10),
            @c_Storerkey             NVARCHAR(15),
            @c_Facility              NVARCHAR(5),
            @c_Authority             NVARCHAR(30)='',
            @c_LocZoneUpdToField     NVARCHAR(50)='',
            @c_LocZoneUpdToField_Opt5 NVARCHAR(1000)='',
            @c_SQL                   NVARCHAR(MAX)='',
            @n_RowRef                BIGINT,
            @c_Status                NVARCHAR(10),
            @n_AllocatedSKU          INT,
            @c_LocUpdToField         NVARCHAR(30), --NJOW01
            @c_Loc                   NVARCHAR(10)  --NJOW01
                                              
   SELECT @n_StartTCnt = @@TRANCOUNT , @n_Continue = 1, @b_Success = 1, @n_Err = 0, @c_ErrMsg = ''    
      
   IF @@TRANCOUNT = 0
      BEGIN TRAN

   --Copy from ispPOA15
   SELECT TOP 1 @n_RowRef = RowRef
   FROM dbo.AutoAllocBatchDetail (NOLOCK)
   WHERE OrderKey = @c_OrderKey
   AND Status in ('0', '1')
   ORDER BY RowRef DESC

   IF @n_continue IN (1,2)
   BEGIN
      SET @c_Status = '0'

      SELECT @c_Status = [Status]
      FROM dbo.ORDERS WITH (NOLOCK)
      WHERE OrderKey = @c_OrderKey

      SET @n_AllocatedSKU = 0
      SELECT @n_AllocatedSKU = COUNT(DISTINCT SKU)  
      FROM dbo.ORDERDETAIL AS OD WITH (NOLOCK)  
      WHERE OD.OrderKey = @c_OrderKey    
      AND (OD.QtyAllocated + OD.QtyPicked) > 0

      UPDATE dbo.AutoAllocBatchDetail WITH (ROWLOCK)  
         SET SKUAllocated = @n_AllocatedSKU, 
             NoStockFound = CASE WHEN @n_AllocatedSKU = 0 THEN 1 ELSE 0 END,
             EditDate = GETDATE()
      WHERE RowRef = @n_RowRef  

      IF @c_Status IN ('1','2')
      BEGIN
         EXEC [dbo].[isp_UpdateAutoAllocBatchDetail_Status]
           @n_AABD_RowRef = @n_RowRef,
           @c_Status = '9',
           @n_Err    = @n_Err    OUTPUT,
           @c_ErrMsg = @c_ErrMsg OUTPUT
      END
   END
   
   IF @n_continue IN(1,2)   
   BEGIN      	
      IF ISNULL(RTRIM(@c_OrderKey), '') <> ''  
      BEGIN  
         DECLARE cur_ORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
            SELECT DISTINCT O.Orderkey, O.Storerkey, O.Facility
            FROM ORDERS O (NOLOCK)
            WHERE O.Orderkey = @c_OrderKey
      END
      ELSE IF ISNULL(RTRIM(@c_Loadkey), '') <> ''  
      BEGIN
         DECLARE cur_ORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
            SELECT DISTINCT O.Orderkey, O.Storerkey, O.Facility
            FROM LoadPlanDetail LPD (NOLOCK)  
            JOIN ORDERS O (NOLOCK) ON LPD.OrderKey = O.OrderKey 
            WHERE LPD.LoadKey = @c_Loadkey
      END 
      ELSE IF ISNULL(RTRIM(@c_Wavekey), '') <> ''  
      BEGIN
         DECLARE cur_ORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
            SELECT DISTINCT O.Orderkey, O.Storerkey, O.Facility
            FROM WaveDetail WD (NOLOCK)  
            JOIN ORDERS O (NOLOCK) ON WD.OrderKey = O.OrderKey
            WHERE WD.Wavekey = @c_Wavekey
      END 
      ELSE 
      BEGIN      
         SELECT @n_Continue = 3      
         SELECT @n_Err = 67060      
         SELECT @c_ErrMsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': Loadkey, Wave and Orderkey are Blank (ispPOA25)'  
         GOTO EXIT_SP      
      END    
   	        
      OPEN cur_ORD    
            
      FETCH NEXT FROM cur_ORD INTO @c_GetOrderkey, @c_Storerkey, @c_Facility     
        
      WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)  
      BEGIN
         --Copy from ispPOA15 S
         SET @n_RowRef = 0
         SET @c_Status = '0'
         SET @n_AllocatedSKU = 0

         SELECT TOP 1 @n_RowRef = RowRef
         FROM dbo.AutoAllocBatchDetail (NOLOCK)
         WHERE OrderKey = @c_GetOrderKey
         AND Status in ('0', '1')
         ORDER BY RowRef DESC
         
         IF @n_RowRef > 0
         BEGIN      
            SELECT @c_Status = [Status]
            FROM dbo.ORDERS WITH (NOLOCK)
            WHERE OrderKey = @c_GetOrderKey
            
            SELECT @n_AllocatedSKU = COUNT(DISTINCT SKU)  
            FROM dbo.ORDERDETAIL AS OD WITH (NOLOCK)  
            WHERE OD.OrderKey = @c_GetOrderKey    
            AND (OD.QtyAllocated + OD.QtyPicked) > 0
            
            UPDATE dbo.AutoAllocBatchDetail WITH (ROWLOCK)  
               SET SKUAllocated = @n_AllocatedSKU, 
                   NoStockFound = CASE WHEN @n_AllocatedSKU = 0 THEN 1 ELSE 0 END,
                   EditDate = GETDATE()
            WHERE RowRef = @n_RowRef  
            
            IF @c_Status IN ('1','2')
            BEGIN
               EXEC [dbo].[isp_UpdateAutoAllocBatchDetail_Status]
                 @n_AABD_RowRef = @n_RowRef,
                 @c_Status = '9',
                 @n_Err    = @n_Err    OUTPUT,
                 @c_ErrMsg = @c_ErrMsg OUTPUT
            END
         END
      	 --Copy from ispPOA15 E
      	
         SET @c_PickZone = ''
         SET @c_Loc = '' --NJOW01
         SET @c_LocZoneUpdToField = 'ORDERS.UserDefine10'
         SET @c_LocUpdToField = 'ORDERS.Userdefine05' --NJOW01

 	       SELECT @c_Authority = SC.Authority,
                @c_LocZoneUpdToField_Opt5 = SC.Option5
         FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey,'','PostAllocationSP') AS SC
      
         SELECT @c_LocZoneUpdToField = dbo.fnc_GetParamValueFromString('@c_LocZoneUpdToField', @c_LocZoneUpdToField_Opt5, @c_LocZoneUpdToField)      
         SELECT @c_LocUpdToField = dbo.fnc_GetParamValueFromString('@c_LocUpdToField', @c_LocZoneUpdToField_Opt5, @c_LocUpdToField)  --NJOW01    
                   
         SELECT @c_PickZone = CASE WHEN COUNT(DISTINCT LOC.PickZone) > 1 THEN 'MIXLZONE' ELSE CAST(MAX(LOC.PickZone) AS NVARCHAR) END,
                @c_Loc = MIN(PD.Loc)  --NJOW01
         FROM ORDERS O (NOLOCK)
         JOIN PICKDETAIL PD (NOLOCK) ON O.Orderkey = PD.Orderkey
         JOIN LOC (NOLOCK) ON PD.Loc = LOC.Loc
         WHERE O.Orderkey = @c_Orderkey
         GROUP BY O.Orderkey         
                                                   
         SET @c_SQL = N'UPDATE ORDERS WITH (ROWLOCK)
                        SET ' + ISNULL(@c_LocZoneUpdToField,'') + ' = @c_PickZone ' +
                         ',' + ISNULL(@c_LocUpdToField,'') + ' = @c_Loc ' +  --NJOW01
                         ', ORDERS.TrafficCop   = NULL
                          , ORDERS.EditDate     = GETDATE()
                          , ORDERS.EditWho      = SUSER_SNAME()
                        WHERE ORDERS.OrderKey   = @c_GetOrderkey'
                                          
         EXEC sp_executesql @c_SQL,
               N'@c_PickZone NVARCHAR(10), @c_GetOrderkey NVARCHAR(10), @c_Loc NVARCHAR(10)', 
               @c_PickZone,
               @c_GetOrderkey,
               @c_Loc --NJOW01
                                 
         SELECT @n_err = @@ERROR
         
         IF @n_err <> 0                                                                                                                                                               
         BEGIN                                                                                                                                                                                  
            SELECT @n_Continue = 3                                                                                                                                                              
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 67010   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                            
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update ORDERS Failed. (ispPOA25)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '             
         END
                        
         FETCH NEXT FROM cur_ORD INTO @c_GetOrderkey, @c_Storerkey, @c_Facility     
      END  
      CLOSE cur_ORD
      DEALLOCATE cur_ORD    
   END  

EXIT_SP:        

   IF CURSOR_STATUS('LOCAL', 'cur_ORD') IN (0 , 1)
   BEGIN
      CLOSE cur_ORD
      DEALLOCATE cur_ORD   
   END 
   
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
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'ispPOA25'      
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
GRANT EXECUTE ON [dbo].[ispPOA25] TO nSQL 
GO