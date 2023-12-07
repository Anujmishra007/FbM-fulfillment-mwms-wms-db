SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Stored Procedure: ispBATCHASGCART01                                     */
/* Creation Date: 29-NOV-2023                                              */
/* Copyright: MAERSK                                                       */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: WMS-24313 - CN UA batching assign cart logic                   */
/*                                                                         */
/* Called By: isp_Batching_AssignCart_Wrapper                              */
/*            Storerconfig: Batching_AssignCart_SP                         */
/*                                                                         */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */                 
/* 29-NOV-2023  NJOW    1.0   DEVOPS Combine Script                        */
/***************************************************************************/  
CREATE OR ALTER PROC [dbo].[ispBATCHASGCART01]  
(     @c_TaskBatchNo   NVARCHAR(10)   
  ,   @b_Success       INT           OUTPUT
  ,   @n_Err           INT           OUTPUT
  ,   @c_ErrMsg        NVARCHAR(255) OUTPUT   
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
      
   DECLARE @n_Continue INT,
           @n_StartTranCount INT,
           @c_Orderkey NVARCHAR(10),
           @c_Storerkey NVARCHAR(15),
           @c_DevicePosition NVARCHAR(10),
           @c_LogicalName NVARCHAR(10),
           @n_ordcnt INT,
           @c_Facility NVARCHAR(5)
          
   CREATE TABLE #TMP_CartPosition (RowID INT IDENTITY(1,1) PRIMARY KEY,
                                   DeviceID    NVARCHAR(20),
                                   DevicePosition NVARCHAR(10),
                                   Status      INT,
                                   LogicalName NVARCHAR(10) NULL,
                                   RowSeq      INT,
                                   ColSeq      INT)       

   SELECT @b_Success = 1, @n_Err = 0, @c_ErrMsg = '', @n_Continue = 1, @n_StartTranCount = @@TRANCOUNT              

   SELECT @c_Storerkey = MAX(O.Storerkey),
          @c_Facility = MAX(O.Facility), 
  	      @n_ordcnt = COUNT(DISTINCT O.orderkey)
   FROM ORDERS O (NOLOCK)
   JOIN PICKDETAIL PD (NOLOCK) ON O.Orderkey = PD.Orderkey
   JOIN PACKTASK PT (NOLOCK) ON O.Orderkey = PT.Orderkey
   WHERE PT.TaskBatchNo = @c_TaskBatchNo
   AND RIGHT(RTRIM(ISNULL(PD.Notes,'')),1) IN ('1','4') --1=Multi-S 4=Multi-M
              
   IF @n_continue IN (1,2) 
   BEGIN
   	  INSERT INTO #TMP_CartPosition (DeviceID, DevicePosition, STATUS, LogicalName, RowSeq, ColSeq)
      SELECT DeviceID, DevicePosition, 0 AS Status, LogicalName,
             CASE WHEN Row = 3 THEN 1 
                  WHEN Row = 4 THEN 2
                  WHEN Row = 5 THEN 3
                  WHEN Row = 2 THEN 4
             ELSE 5 END AS RowSeq,
             ROW_NUMBER() OVER(PARTITION BY DeviceID, Row 
                ORDER BY CASE WHEN Row = 3 THEN 1 
                              WHEN Row = 4 THEN 2
                              WHEN Row = 5 THEN 3
                              WHEN Row = 2 THEN 4
                         ELSE 5 END, LogicalName, DevicePosition) AS ColSeq
      FROM DEVICEPROFILE (NOLOCK)
      WHERE Devicetype = 'CART' 
      AND Priority = 'M' 
      AND Storerkey = @c_Storerkey      
      ORDER BY DeviceID, 5, LogicalName, DevicePosition          
   
      IF (SELECT COUNT(DISTINCT DevicePosition) FROM #TMP_CartPosition) < @n_ordcnt
      BEGIN
         SET @n_continue = 3      
         SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)    
         SET @n_err = 81010  -- Should Be Set To The SQL Errmessage but I don't know how to do so.      
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insuffice Cart Device Position (ispBATCHASGCART01)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '      
      END   
   END
   	     
   IF @n_continue IN (1,2)
   BEGIN   	     	     	     	  
   	  DECLARE CUR_ORDERS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   	     SELECT O.Orderkey
   	     FROM ORDERS O (NOLOCK)
   	     JOIN PICKDETAIL PD (NOLOCK) ON O.Orderkey = PD.Orderkey
         JOIN PACKTASK PT (NOLOCK) ON O.Orderkey = PT.Orderkey
   	     WHERE PT.TaskBatchNo = @c_TaskBatchNo 
   	     AND RIGHT(RTRIM(ISNULL(PD.Notes,'')),1) IN ('1','4')
   	     GROUP BY O.Orderkey
   	     ORDER BY SUM(PD.Qty) DESC, O.Orderkey

      OPEN CUR_ORDERS
      
      FETCH NEXT FROM CUR_ORDERS INTO @c_Orderkey

      WHILE @@FETCH_STATUS <> -1 AND (@n_continue = 1 OR @n_continue = 2)
      BEGIN      	     
         SELECT TOP 1 @c_DevicePosition = DevicePosition,
                      @c_LogicalName = LogicalName
         FROM #TMP_CartPosition
         WHERE Status = 0
         AND RowID <= @n_ordcnt
         ORDER BY RowSeq, ColSeq, DeviceID, LogicalName, DevicePosition  
         
         UPDATE #TMP_CartPosition
         SET Status = Status + 1
         WHERE DevicePosition = @c_DevicePosition
         
         UPDATE PACKTASK 
         SET DevicePosition = @c_DevicePosition,
             LogicalName = @c_LogicalName
         WHERE Orderkey = @c_Orderkey
         AND TaskBatchNo = @c_TaskBatchNo     

         SET @n_err = @@ERROR      
         
         IF @n_err <> 0      
         BEGIN      
            SET @n_continue = 3      
            SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)    
            SET @n_err = 81020  -- Should Be Set To The SQL Errmessage but I don't know how to do so.      
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update PACKHEADER Failed (ispBATCHASGCART01)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '      
         END              	   
            
         FETCH NEXT FROM CUR_ORDERS INTO @c_Orderkey
      END	
      CLOSE CUR_ORDERS
      DEALLOCATE CUR_ORDERS        	    	       	     
   END
      
   QUIT_SP:
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTranCount
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispBATCHASGCART01'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTranCount  
      BEGIN  
         COMMIT TRAN  
      END  
      RETURN
   END 
END
GO
GRANT EXECUTE ON [dbo].[ispBATCHASGCART01] TO nSQL 
GO
