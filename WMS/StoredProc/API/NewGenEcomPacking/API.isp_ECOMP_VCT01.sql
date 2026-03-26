/************************************************************************/              
/* Store procedure: [API].[isp_ECOMP_VCT01]								*/              
/* Creation Date: 13-FEB-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by: Cheong													*/
/*                                                                      */
/* Purpose: Help to validate the  carton type							*/
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
/* 13-Feb-2026    Cheong   #FCR-9928									*/
/************************************************************************/ 

CREATE OR ALTER   PROC [API].[isp_ECOMP_VCT01]
   @b_Debug         INT				= 0
,  @c_CartonType	NVARCHAR(60)	   
,  @c_OrderKey		NVARCHAR(10)
,  @c_Storerkey		NVARCHAR(15)
,  @c_Facility		NVARCHAR(5)
,  @b_Success		INT				= 0   OUTPUT  
,  @n_Err			INT				= 0   OUTPUT  
,  @c_ErrMsg		NVARCHAR(255)	= ''  OUTPUT  
,  @b_IsValid		BIT				= 0	  OUTPUT
AS  
BEGIN  
   SET NOCOUNT                      ON  
   SET ANSI_NULLS                   OFF  
   SET QUOTED_IDENTIFIER            OFF  
   SET CONCAT_NULL_YIELDS_NULL      OFF  
  
   DECLARE @n_StartTCnt             INT                  = @@TRANCOUNT  
         , @n_Continue              INT                  = 1      

         , @c_CartonList			NVARCHAR(100)		 = ''
         , @c_Salesman				NVARCHAR(100)        = ''


	IF @c_OrderKey = '' OR @c_CartonType = ''
	BEGIN
		GOTO QUIT_SP
	END
	--SET @b_IsValid = 1
	--get salesman of order
	SELECT TOP 1 @c_Salesman = ISNULL(Salesman,'')
	FROM [dbo].[ORDERS] WITH (NOLOCK) WHERE OrderKey = @c_OrderKey

	IF @c_Salesman = ''
	BEGIN
		GOTO QUIT_SP
	END

	--get UDF05 as @cartonlist	
	SELECT TOP 1 @c_CartonList = ISNULL(UDF05,'')
	FROM [dbo].[Codelkup] WITH (NOLOCK) 
	WHERE ListName = 'VFCTNCFG' AND Code = @c_Salesman

	IF @c_CartonList = ''
	BEGIN
		GOTO QUIT_SP
	END


   IF @b_Debug = 1 
   BEGIN
      PRINT '@c_OrderKey = ' + @c_OrderKey
      PRINT '@c_Salesman = ' + @c_Salesman
      PRINT '@c_CartonList = ' + @c_CartonList
	  PRINT '@c_CartonType = ' + @c_CartonType
   END

   IF EXISTS(SELECT TOP 1 1 FROM [dbo].[Codelkup] WITH (NOLOCK) 
   WHERE ListName = @c_CartonList AND Code = @c_CartonType)
   BEGIN
      SET @b_IsValid = 1
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
  
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_ECOMP_VCT01'  
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