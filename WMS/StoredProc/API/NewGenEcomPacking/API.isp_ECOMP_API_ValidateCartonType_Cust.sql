/*********************************************************************************/              
/* Store procedure: [API].[isp_ECOMP_API_ValidateCartonType_Cust]                */              
/* Creation Date: 13-FEB-2026                                                    */
/* Copyright: Maersk                                                             */
/* Written by: Cheong			                                                 */
/*                                                                               */
/* Purpose:                                                                      */
/*                                                                               */
/* Called By: SCEAPI                                                             */
/*                                                                               */
/* PVCS Version: 1.0                                                             */
/*                                                                               */
/* Version: 1.0                                                                  */
/*                                                                               */
/* Data Modifications:                                                           */
/*                                                                               */
/* Updates:                                                                      */
/* Date           Author   Purposes                                              */
/* 09-FEB-2026    Cheong   #FCR-9928 - Initial                                   */
/*********************************************************************************/

CREATE OR ALTER     PROC [API].[isp_ECOMP_API_ValidateCartonType_Cust](
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
         , @c_SQLQuery                    NVARCHAR(500)  = ''
         , @c_Facility                    NVARCHAR(10)   = ''
         , @c_StorerKey                   NVARCHAR(15)   = ''
         , @c_CartonType                  NVARCHAR(60)   = ''
		 , @c_OrderKey					  NVARCHAR(100)  = ''

         , @c_PickSlipNo                  NVARCHAR(10)   = ''
         , @n_CartonNo                    INT            = 0
         , @b_IsValid                     BIT            = 0
         , @c_Authority                   NVARCHAR(1)    = ''
         , @c_AlertMsg                    NVARCHAR(255)  = ''
         
         , @c_EPACKValidateCustCTNType    NVARCHAR(1)    = ''
         , @c_EPACKValidateCustCTNTypeSP  NVARCHAR(200)  = ''

         , @n_sc_Success                  INT            = 0
         , @n_sc_err                      INT            = 0
         , @c_sc_errmsg                   NVARCHAR(250)  = ''

         , @c_IsValidateRequired		  NVARCHAR(1)    = '0'

   SET @b_Success                         = 0
   SET @n_ErrNo                           = 0
   SET @c_ErrMsg                          = ''
   SET @c_ResponseString                  = ''
   
   SELECT @c_Facility       = ISNULL(RTRIM(Facility     ), '')
         ,@c_StorerKey      = ISNULL(RTRIM(Storer       ), '')
         ,@c_PickSlipNo     = ISNULL(RTRIM(PickSlipNo   ), '')
		 ,@c_OrderKey       = ISNULL(Orderkey            , '')
		 ,@c_CartonType     = ISNULL(RTRIM(CartonType   ), '')
   FROM OPENJSON (@c_RequestString)
   WITH ( 
      Facility          NVARCHAR(10)         '$.Facility',
      Storer            NVARCHAR(15)         '$.Storer',
      PickSlipNo        NVARCHAR(10)         '$.PickSlipNo',
      OrderKey	        NVARCHAR(10)         '$.OrderKey',
	  CartonType		NVARCHAR(60)		 '$.CartonType'
   )
   

   SET @c_IsValidateRequired = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'EPACKValidateCustCTNType')

   IF @b_Debug = 1 
   BEGIN
      PRINT '@c_OrderKey = ' + @c_OrderKey
      PRINT '@c_IsValidateRequired = ' + @c_IsValidateRequired
   END

   IF @c_OrderKey = '' OR NOT @c_IsValidateRequired = '1'
   BEGIN
      GOTO GEN_RESPONSE
   END

   EXEC [dbo].[nspGetRight]
         @c_Facility          = @c_Facility
      ,  @c_StorerKey         = @c_StorerKey
      ,  @c_sku               = ''
      ,  @c_ConfigKey         = 'EPACKValidateCustCTNType'
      ,  @b_Success           = @n_sc_Success					OUTPUT     
      ,  @c_authority         = @c_EPACKValidateCustCTNType		OUTPUT    
      ,  @n_err               = @n_sc_err						OUTPUT    
      ,  @c_errmsg            = @c_sc_errmsg					OUTPUT  
      ,  @c_Option1           = @c_EPACKValidateCustCTNTypeSP	OUTPUT 

   IF @c_OrderKey = '' 
      OR  @c_EPACKValidateCustCTNType <> '1' OR ISNULL(RTRIM(@c_EPACKValidateCustCTNTypeSP), '') = '' 
   BEGIN
      GOTO GEN_RESPONSE
   END

   IF NOT EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = RTRIM(@c_EPACKValidateCustCTNTypeSP) AND type = 'P')  
   BEGIN  
       SET @n_continue = 3    
       SET @n_ErrNo = 51601
       SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_ErrNo) +   
              ': Storerconfig EPACKValidateCustCTNType - Stored Proc name invalid ('+RTRIM(ISNULL(@c_EPACKValidateCustCTNTypeSP,''))+') (isp_ECOMP_API_ValidateCartonType_Cust)'    
       GOTO QUIT  
   END 

    SET @c_SQLQuery = 'EXEC [API].[' + @c_EPACKValidateCustCTNTypeSP + '] '
                   + '   @b_Debug          = @b_Debug		      '
                   + ',  @c_CartonType     = @c_CartonType	      '
                   + ',  @c_OrderKey       = @c_OrderKey	      '
                   + ',  @c_Storerkey      = @c_Storerkey	      '
                   + ',  @c_Facility       = @c_Facility		  '
                   + ',  @b_Success        = @b_Success		OUTPUT' 
                   + ',  @n_Err            = @n_ErrNo		OUTPUT' 
                   + ',  @c_ErrMsg         = @c_ErrMsg		OUTPUT'
                   + ',  @b_IsValid		   = @b_IsValid		OUTPUT'
   
   EXEC sp_executesql 
      @c_SQLQuery  
    , N'@b_Debug INT, @c_CartonType NVARCHAR(60), @c_OrderKey NVARCHAR(10), @c_Storerkey NVARCHAR(15), @c_Facility NVARCHAR(5), @b_Success INT OUTPUT, @n_ErrNo INT OUTPUT, @c_ErrMsg NVARCHAR(255) OUTPUT, @b_IsValid BIT OUTPUT'
    , @b_Debug             
    , @c_CartonType           
    , @c_OrderKey          
    , @c_Storerkey         
    , @c_Facility                                                   
    , @b_Success        OUTPUT
    , @n_ErrNo          OUTPUT
    , @c_ErrMsg         OUTPUT     
    , @b_IsValid		OUTPUT
     

   GEN_RESPONSE:
   SET @c_ResponseString = ISNULL(( 
                              SELECT @b_IsValid As 'IsValid'
                              FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
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
