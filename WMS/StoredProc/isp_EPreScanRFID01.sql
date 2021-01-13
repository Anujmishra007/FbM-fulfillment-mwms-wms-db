IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_EPreScanRFID01]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_EPreScanRFID01]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
    
/************************************************************************/        
/* Trigger: isp_EPreScanRFID01                                          */        
/* Creation Date: 13-OCT-2020                                           */        
/* Copyright: LF Logistics                                              */        
/* Written by: Wan                                                      */        
/*                                                                      */        
/* Purpose: WMS-15244 - [CN] NIKE_O2_Ecom_packing_RFID_CR               */        
/*        :                                                             */        
/* Called By: n_cst_packcarton_ecom                                     */        
/*          : of_getprescanrfidsp                                       */        
/*        :                                                             */        
/* PVCS Version: 1.0                                                    */        
/*                                                                      */        
/* Version: 7.0                                                         */        
/*                                                                      */        
/* Data Modifications:                                                  */        
/*                                                                      */        
/* Updates:                                                             */        
/* Date        Author   Ver   Purposes                                  */        
/* 13-OCT-2020 Wan      1.0   Created                                   */         
/************************************************************************/        
CREATE PROC [dbo].[isp_EPreScanRFID01]        
         @c_TaskBatchNo NVARCHAR(10)         
      ,  @c_PickSlipNo  NVARCHAR(10)       
      ,  @c_Storerkey   NVARCHAR(15) = ''        
      ,  @c_Sku         NVARCHAR(20) = ''    
      ,  @b_Success     INT = 0              OUTPUT          
      ,  @n_err         INT = 0              OUTPUT         
      ,  @c_errmsg      NVARCHAR(255) = ''   OUTPUT         
AS        
BEGIN        
   SET NOCOUNT ON        
   SET ANSI_NULLS OFF        
   SET QUOTED_IDENTIFIER OFF        
   SET CONCAT_NULL_YIELDS_NULL OFF        
        
   DECLARE @n_StartTCnt          INT         = @@TRANCOUNT         
         , @n_Continue           INT         = 1   

         , @c_ExtendedField03    NVARCHAR(30)= ''       
          
   SET @b_Success  = 0        
   SET @n_err      = 0        
   SET @c_errmsg   = ''        
        
   SET @c_ExtendedField03 = ''        
   SELECT @c_ExtendedField03 = SIF.ExtendedField03        
   FROM SKUINFO SIF WITH (NOLOCK)        
   WHERE SIF.Storerkey = @c_Storerkey  
   AND   SIF.Sku = @c_Sku          
        
   IF @c_ExtendedField03 = 'rfid'       
   BEGIN          
     SET @b_Success = 1        
   END           
        
   QUIT_SP:        
         
END -- procedure 
GO
GRANT EXECUTE ON [dbo].[isp_EPreScanRFID01] TO nSQL 
GO
