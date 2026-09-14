/************************************************************************/              
/* Store procedure: [API].[isp_ECOMP_SYSSCT02]                          */              
/* Creation Date: 06-AUG-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by: CSC166	                                                */
/*                                                                      */
/* Purpose: Help to recommend the reasonable carton type                */
/*          for saving courier cost.                                    */
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
/* Date           Author   Purposes	                                    */
/* 06-AUG-2026    CSC166   #FCR-14711: Initial version                  */
/************************************************************************/ 

CREATE OR ALTER PROC [API].[isp_ECOMP_SYSSCT02]
   @b_Debug          INT            = 0
,  @c_PickSlipNo     NVARCHAR(10)      
,  @c_OrderKey       NVARCHAR(10)
,  @c_Storerkey      NVARCHAR(15) 
,  @c_Facility       NVARCHAR(5)
,  @b_Success        INT            = 0   OUTPUT  
,  @n_Err            INT            = 0   OUTPUT  
,  @c_ErrMsg         NVARCHAR(255)  = ''  OUTPUT  
,  @c_CTS_Response   NVARCHAR(500)  = ''  OUTPUT
AS  
BEGIN  
   SET NOCOUNT                      ON  
   SET ANSI_NULLS                   OFF  
   SET QUOTED_IDENTIFIER            OFF  
   SET CONCAT_NULL_YIELDS_NULL      OFF  
  
   DECLARE @n_StartTCnt             INT                  = @@TRANCOUNT  
         , @n_Continue              INT                  = 1      

         , @c_Priority_CartonType   NVARCHAR(30)         = ''
         , @c_CartonGroup			NVARCHAR(30)         = ''

		 , @c_DefaultCartonType      NVARCHAR(10)         = ''
         
         , @c_CartonType            NVARCHAR(10)         = ''
         , @f_CartonWeight          FLOAT                = 0

   SET @n_Err                       = 0  
   SET @c_ErrMsg                    = ''  
   SET @c_CTS_Response              = '[]'

   --get Cartongroup from storer
   SELECT TOP 1 @c_CartonGroup = CartonGroup FROM Storer(NOLOCK) WHERE StorerKey = @c_StorerKey

   --Get the Carton Type from Orders.Priority if Order is S-9
   SELECT TOP 1 @c_Priority_CartonType = A.Priority 
   FROM ORDERS(NOLOCK) A
   INNER JOIN PACKTASK(NOLOCK) B ON A.OrderKey = B.OrderKey AND B.OrderMode = 'S-9'
   WHERE A.OrderKey = @c_OrderKey AND A.StorerKey = @c_StorerKey

   IF @b_Debug = 1 
   BEGIN
      PRINT '@c_Priority_CartonType = ' + @c_Priority_CartonType
	  PRINT '@c_CartonGroup = ' + @c_CartonGroup
   END

   IF @c_Priority_CartonType = ''
   BEGIN
      GOTO QUIT_SP
   END

   --Find existing Carton Type from Cartonization where CartonizationGroup = Storer. CartonGroup and CartonType = Orders.Priority
   SELECT TOP 1 @c_CartonType = CartonType, @f_CartonWeight = CartonWeight
   FROM CARTONIZATION(NOLOCK) 
   WHERE CartonizationGroup = @c_CartonGroup AND CartonType = @c_Priority_CartonType

   IF @b_Debug = 1 
   BEGIN
      PRINT '@c_CartonType = ' + @c_CartonType
	  PRINT '@f_CartonWeight = ' + @f_CartonWeight
   END

   IF ISNULL(@c_CartonType, '') <> ''
   BEGIN
      SET @c_CTS_Response = ISNULL(( 
                              SELECT @c_CartonType       As 'CartonType'
                                    ,@f_CartonWeight     As 'CartonWeight'
                              FOR JSON PATH
                            ), '')
   END

QUIT_SP:  
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
  
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_ECOMP_SYSSCT02'  
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