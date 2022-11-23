SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* SP: isp_Ecom_GetPackTaskOrders_PackStatus                            */
/* Creation Date: 18-Oct-2022                                           */
/* Copyright: LF Logistics                                              */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-20953 - MY - Add screen to view pending order           */
/*        :                                                             */
/* Called By: ECOM Packing - Single Order                               */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 18-Oct-2022 WLChooi  1.0   DevOps Combine Script                     */  
/************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_Ecom_GetPackTaskOrders_PackStatus] 
         @c_TaskBatchNo NVARCHAR(10)
      ,  @c_PickSlipNo  NVARCHAR(10)  = ''  
      ,  @c_Orderkey    NVARCHAR(10)  = ''  
      ,  @c_Type        NVARCHAR(10) = 'PENDING'
AS         
BEGIN 
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Cnt             INT   = 0
         , @n_StartTCnt       INT
         , @c_SQL             NVARCHAR(MAX)
         , @c_ExecArguments   NVARCHAR(MAX)
         , @c_SQLCondition    NVARCHAR(MAX)

   SET @n_StartTCnt = @@TRANCOUNT

   WHILE @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END

   IF RTRIM(@c_TaskBatchNo) = '' OR @c_TaskBatchNo IS NULL
   BEGIN
      SELECT NULL, NULL, NULL, NULL, NULL, NULL
      GOTO QUIT_SP
   END

   SELECT TOP 1 @n_Cnt = 1
   FROM PACKTASKDETAIL WITH (NOLOCK)
   WHERE TaskBatchNo = @c_TaskBatchNo
   ORDER BY ADDDate 

   IF @n_Cnt > 0
   BEGIN
      IF @c_Type = 'ALL'
      BEGIN
         SET @c_SQLCondition = ''
      END
      ELSE IF @c_Type = 'PACKED'
      BEGIN
         --SET @c_SQLCondition = ' AND ISNULL(PD.QtyPacked,0) = PTD.QtyAllocated'
         SET @c_SQLCondition = ' AND PTD.[Status] = ''9'' '
      END
      ELSE IF @c_Type = 'PENDING'
      BEGIN
         --SET @c_SQLCondition = ' AND ISNULL(PD.QtyPacked,0) < PTD.QtyAllocated'
         SET @c_SQLCondition = ' AND PTD.[Status] < ''9'' '
      END

      SET @c_SQL = N' SELECT PTD.TaskBatchNo ' + CHAR(13)
                 + N'      , OH.Orderkey ' + CHAR(13)
                 + N'      , OH.LoadKey ' + CHAR(13)
                 + N'      , PTD.Sku ' + CHAR(13)
                 + N'      , PTD.QtyAllocated ' + CHAR(13)
                 + N'      , ISNULL(PD.QtyPacked,0) AS QtyPacked ' + CHAR(13)
                 + N'      , OH.[Status] ' + CHAR(13)
                 + N'      , OH.SOStatus ' + CHAR(13)
                 + N' FROM PACKTASKDETAIL PTD WITH (NOLOCK) ' + CHAR(13)
                 + N' JOIN ORDERS OH WITH (NOLOCK) ON OH.OrderKey = PTD.Orderkey ' + CHAR(13)
                 + N' OUTER APPLY (SELECT SUM(Qty) AS QtyPacked ' + CHAR(13)
                 + N'              FROM PACKDETAIL WITH (NOLOCK) ' + CHAR(13)
                 + N'              WHERE PickSlipNo = PTD.PickSlipNo) AS PD  ' + CHAR(13)
                 + N' WHERE PTD.TaskBatchNo = @c_TaskBatchNo ' + CHAR(13)
                 + @c_SQLCondition
                 + N' GROUP BY PTD.TaskBatchNo ' + CHAR(13)
                 + N'        , OH.Orderkey ' + CHAR(13)
                 + N'        , OH.LoadKey ' + CHAR(13)
                 + N'        , PTD.Sku ' + CHAR(13)
                 + N'        , PTD.QtyAllocated ' + CHAR(13)
                 + N'        , ISNULL(PD.QtyPacked,0) ' + CHAR(13)
                 + N'        , OH.[Status] ' + CHAR(13)
                 + N'        , OH.SOStatus '

      SET @c_ExecArguments = N'  @c_TaskBatchNo   NVARCHAR(10)'
                           + N', @c_Pickslipno    NVARCHAR(10)'
                           + N', @c_Orderkey      NVARCHAR(10)'
                           
      EXEC sp_ExecuteSql   @c_SQL     
                         , @c_ExecArguments    
                         , @c_TaskBatchNo
                         , @c_PickSlipNo
                         , @c_Orderkey      
   END

   QUIT_SP:
   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END
GO
GRANT EXECUTE ON [dbo].[isp_Ecom_GetPackTaskOrders_PackStatus] TO nSQL 
GO