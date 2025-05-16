  
/************************************************************************/                
/* Store procedure: [API].[isp_ECOMP_API_GetTestData]                   */                
/* Creation Date: 13-FEB-2023                                           */  
/* Copyright: Maersk                                                    */  
/* Written by: AlexKeoh                                                 */  
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Called By: SCEAPI                                                    */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 1.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date           Author   Purposes                                     */  
/* 16-June-2023    Alex     Initial                                     */  
/************************************************************************/      
CREATE OR ALTER  PROC [API].[isp_ECOMP_API_GetTestData](  
     @b_Debug           INT            = 0  
   , @c_Format          VARCHAR(10)    = ''  
   , @c_UserID          NVARCHAR(256)  = ''  
   , @c_OperationType   NVARCHAR(60)   = ''  
   , @c_RequestString   NVARCHAR(MAX)  = ''  
   , @b_Success         INT            = 0   OUTPUT  
   , @n_ErrNo           INT            = 0   OUTPUT  
   , @c_ErrMsg          NVARCHAR(250)  = ''  OUTPUT  
   , @c_ResponseString  NVARCHAR(MAX)  = ''  OUTPUT  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @n_Continue                    INT            = 1  
         , @n_StartCnt                    INT            = @@TRANCOUNT  
  
         , @c_ComputerName                NVARCHAR(30)   = ''  
         , @c_TaskBatchNo                 NVARCHAR(10)   = ''  
         , @c_StorerKey                   NVARCHAR(15)  
         , @c_Facility                    NVARCHAR(10)  
  
   DECLARE @t_Temp AS TABLE (  
      RowRef         BIGINT  
   ,  TaskBatchNo    NVARCHAR(10)   NULL     
   ,  StorerKey      NVARCHAR(15)   NULL     
   ,  Facility       NVARCHAR(10)   NULL     
   )  
   SET @b_Success                         = 0  
   SET @n_ErrNo                           = 0  
   SET @c_ErrMsg                          = ''  
   SET @c_ResponseString                  = ''  
  
   SELECT @c_ComputerName  = ISNULL(RTRIM(ComputerName), '')  
   FROM OPENJSON (@c_RequestString)  
   WITH (   
      ComputerName  NVARCHAR(30)   '$.ComputerName'    
   )  
  
   INSERT INTO @t_Temp (RowRef, TaskBatchNo)  
   SELECT TOP 200 RowRef, TaskBatchNo  
   FROM [dbo].[EPACKPFTDATA] WITH (NOLOCK)   
   WHERE AppType = 'NewGen'  
   AND ComputerName = @c_ComputerName  
   AND [Status] = '0'  
  
   DECLARE C_LOOP_BATCH CURSOR FAST_FORWARD READ_ONLY FOR  
   SELECT DISTINCT TaskBatchNo  
   FROM @t_Temp  
  
   OPEN C_LOOP_BATCH  
   FETCH NEXT FROM C_LOOP_BATCH INTO @c_TaskBatchNo  
   WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1  
   BEGIN  
      SET @c_StorerKey     = ''  
      SET @c_Facility      = ''  
  
      IF EXISTS ( SELECT 1 FROM dbo.PackTaskDetail (NOLOCK) WHERE TaskBatchNo = @c_TaskBatchNo )
      BEGIN
         SELECT @c_StorerKey = StorerKey  
               ,@c_Facility = Facility  
         FROM [dbo].[Orders] WITH (NOLOCK)   
         WHERE OrderKey IN ( SELECT TOP 1 OrderKey FROM dbo.PackTaskDetail (NOLOCK) WHERE TaskBatchNo = @c_TaskBatchNo )  
      END
      ELSE
      BEGIN
         SELECT @c_StorerKey = StorerKey  
               ,@c_Facility = Facility  
         FROM [dbo].[Orders] WITH (NOLOCK)   
         WHERE OrderKey IN ( SELECT TOP 1 OrderKey FROM dbo.PICKDETAIL (NOLOCK) WHERE PickSlipNo = @c_TaskBatchNo )  
      END
  
      UPDATE @t_Temp  
      SET Facility = @c_Facility  
         ,StorerKey = @c_StorerKey  
      WHERE TaskBatchNo = @c_TaskBatchNo  
      FETCH NEXT FROM C_LOOP_BATCH INTO @c_TaskBatchNo  
   END   
   CLOSE C_LOOP_BATCH;  
   DEALLOCATE C_LOOP_BATCH;  
  
   UPDATE [dbo].[EPACKPFTDATA]  
   SET [Status] = '9'  
   WHERE RowRef IN ( SELECT RowRef   
      FROM @t_Temp )  
  
   SET @c_ResponseString = ISNULL((   
                              SELECT  
                                EPD.RowRef,   
                                EPD.TaskBatchNo,   
                                EPD.OrderKey,   
                                CASE WHEN (ISNULL(EPD.OrderMode, '') <> '' AND LEN(EPD.OrderMode) > 1) THEN SUBSTRING(EPD.OrderMode, 1,1) ELSE EPD.OrderMode END As [OrderMode],   
                                EPD.Cartonno As [CartonNo],  
                                EPD.[CartonType],  
                                EPD.[Weight],  
                                CASE   
                                   WHEN T.[StorerKey] = 'DOTERRA' THEN EPD.QRCode  
                                   ELSE EPD.SKU END As [SKU],  
                                EPD.SerialNo,  
                                EPD.QRCode,   
                                T.StorerKey,  
                                T.Facility  
                              FROM [dbo].[EPACKPFTDATA] EPD WITH (NOLOCK)   
                              --LEFT JOIN [dbo].[ORDERS] ORD WITH (NOLOCK) ON (EPD.OrderKey = ORD.OrderKey)  
                              JOIN  @t_Temp T ON ( EPD.RowRef = T.RowRef )  
                              --WHERE RowRef IN ( SELECT RowRef FROM @t_Temp )  
                              FOR JSON PATH, INCLUDE_NULL_VALUES   
                           ), '')  
  
   QUIT:  
   IF @n_Continue= 3  -- Error Occured - Process And Return        
   BEGIN        
      SET @b_Success = 0        
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1   
      BEGIN                 
         ROLLBACK TRAN        
      END        
      ELSE        
      BEGIN        
         WHILE @@TRANCOUNT > @n_StartCnt        
         BEGIN        
            COMMIT TRAN        
         END        
      END     
      RETURN        
   END        
   ELSE        
   BEGIN        
      SELECT @b_Success = 1        
      WHILE @@TRANCOUNT > @n_StartCnt        
      BEGIN        
         COMMIT TRAN        
      END        
      RETURN        
   END  
END -- Procedure    