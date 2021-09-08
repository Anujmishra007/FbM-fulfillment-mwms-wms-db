IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispPAKCF14]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[ispPAKCF14]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO 
/***************************************************************************/  
/* Stored Procedure: ispPAKCF14                                            */  
/* Creation Date: 12-NOV-2020                                              */  
/* Copyright: LFL                                                          */  
/* Written by: Wan                                                         */  
/*                                                                         */  
/* Purpose: ADIDAS MALAYSIA-Create to Solve Production Issue Without JIRA  */  
/*                                                                         */  
/* Called By: PostPackConfirmSP                                            */  
/*                                                                         */  
/*                                                                         */  
/* PVCS Version: 1.1                                                       */  
/*                                                                         */  
/* Version: 5.4                                                            */  
/*                                                                         */  
/* Data Modifications:                                                     */  
/*                                                                         */  
/* Updates:                                                                */  
/* Date        Author   Ver   Purposes                                     */ 
/* 2020-11-12  Wan      1.0   Creation                                     */ 
/* 2021-08-17  WLChooi  1.1   WMS-17206 - Trigger Interface (WL01)         */ 
/***************************************************************************/    
CREATE PROC [dbo].[ispPAKCF14]    
(     @c_PickSlipNo  NVARCHAR(10)     
  ,   @c_Storerkey   NVARCHAR(15)  
  ,   @b_Success     INT           OUTPUT  
  ,   @n_Err         INT           OUTPUT  
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT     
)    
AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
    
   DECLARE @b_Debug           INT  
         , @n_Continue        INT   
         , @n_StartTCnt       INT   
   
   DECLARE @c_Orderkey        NVARCHAR(10) = ''
         , @c_Key2            NVARCHAR(11) = ''
         , @c_OrderGroup      NVARCHAR(50) = ''   --WL01
         , @n_MaxCarton       INT = 0   --WL01
              
   SET @b_Success= 1   
   SET @n_Err    = 0    
   SET @c_ErrMsg = ''  
   SET @b_Debug  = 0   
   SET @n_Continue = 1    
   SET @n_StartTCnt = @@TRANCOUNT    
    
   IF @@TRANCOUNT = 0  
      BEGIN TRAN  

   SELECT @c_Orderkey = PH.Orderkey
   FROM PACKHEADER PH WITH (NOLOCK)
   WHERE PH.PickSlipNo = @c_PickSlipNo

   SET @c_Key2 = 'O' + @c_Orderkey 
   EXEC ispGenTransmitLog2 'WOLSHPLABLELOG', @c_PickSlipNo, @c_Key2, @c_StorerKey, ''    
         , @b_success OUTPUT    
         , @n_err OUTPUT    
         , @c_errmsg OUTPUT    
                         
   IF @b_success <> 1    
   BEGIN    
      SET @n_continue = 3    
      SET @n_err = 68010    
      SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) +     
                        ': Insert into TRANSMITLOG2 Failed. (ispPAKCF14) ( SQLSvr MESSAGE = ' +     
                        ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '    
      GOTO QUIT_SP  
   END 
   
   --WL01 S
   SELECT @c_OrderGroup = OH.OrderGroup
   FROM PACKHEADER PH WITH (NOLOCK)
   JOIN ORDERS OH WITH (NOLOCK) ON OH.Orderkey = PH.Orderkey
   WHERE PH.PickSlipNo = @c_PickSlipNo

   IF @c_OrderGroup = 'aCommerce' AND @c_Storerkey = 'ADIDAS'
   BEGIN
      SELECT @n_MaxCarton = MAX(CartonNo)
      FROM PACKDETAIL WITH (NOLOCK)
      WHERE Pickslipno = @c_PickSlipNo

      EXEC ispGenTransmitLog2 'WSPACFMLOGAC', @c_PickSlipNo, 1, @c_StorerKey, ''    
            , @b_success OUTPUT    
            , @n_err OUTPUT    
            , @c_errmsg OUTPUT    
                            
      IF @b_success <> 1    
      BEGIN    
         SET @n_continue = 3    
         SET @n_err = 68015    
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) +     
                           ': Insert into TRANSMITLOG2 Failed. (ispPAKCF14) ( SQLSvr MESSAGE = ' +     
                           ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '    
         GOTO QUIT_SP  
      END 
   END
   --WL01 E    
                                                                                                                                
   QUIT_SP:  
  
   IF @n_continue = 3  -- Error Occured - Process And Return  
   BEGIN  
      SET @b_success = 0  
  
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
         ROLLBACK TRAN  
      END  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispPAKCF14'  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
      RETURN  
   END  
   ELSE  
   BEGIN  
      SET @b_success = 1  
      WHILE @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
        COMMIT TRAN  
      END   
      RETURN  
   END   
END  
GO

GRANT EXECUTE ON [dbo].[ispPAKCF14] TO nSQL 
GO