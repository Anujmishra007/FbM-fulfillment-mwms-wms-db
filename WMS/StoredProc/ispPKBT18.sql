SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: ispPKBT18                                          */
/* Creation Date: 20-Dec-2023                                           */
/* Copyright: Maersk                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-23560 - SG - LIXIL (LIXILSAP & LIXILNSAP) - Ninjavan    */
/*                      Exceed Packing Module                           */
/*                                                                      */
/* Called By: isp_Packing_Bartender_Print                               */
/*                                                                      */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 20-Dec-2023 WLChooi  1.0   DevOps Combine Script                     */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ispPKBT18]
   @c_printerid  NVARCHAR(50) = '',  
   @c_labeltype  NVARCHAR(30) = '',  
   @c_userid     NVARCHAR(100) = '',  
   @c_Parm01     NVARCHAR(60) = '', --Pickslipno         
   @c_Parm02     NVARCHAR(60) = '', --carton from         
   @c_Parm03     NVARCHAR(60) = '', --carton to         
   @c_Parm04     NVARCHAR(60) = '',          
   @c_Parm05     NVARCHAR(60) = '',          
   @c_Parm06     NVARCHAR(60) = '',          
   @c_Parm07     NVARCHAR(60) = '',          
   @c_Parm08     NVARCHAR(60) = '',          
   @c_Parm09     NVARCHAR(60) = '',          
   @c_Parm10     NVARCHAR(60) = '',    
   @c_Storerkey  NVARCHAR(15) = '',
   @c_NoOfCopy   NVARCHAR(5) = '1',
   @c_Subtype    NVARCHAR(20) = '',
   @b_Success    INT      OUTPUT,
   @n_Err        INT      OUTPUT, 
   @c_ErrMsg     NVARCHAR(250) OUTPUT   
AS  
BEGIN  
   SET NOCOUNT ON   
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
      
   DECLARE @n_continue           INT 
         , @c_Pickslipno         NVARCHAR(10) = ''
         , @c_Facility           NVARCHAR(5)  = ''
         , @c_CartonNoStart      NVARCHAR(10)
         , @c_CartonNoEnd        NVARCHAR(10)
         , @c_CheckConso         NVARCHAR(10) = 'N'
         , @c_GetOrderkey        NVARCHAR(10)
         , @c_M_Company          NVARCHAR(50) = N''
         , @c_C_Country          NVARCHAR(50) = N''
                                                      
   SET @n_err = 0
   SET @b_success = 1
   SET @c_errmsg = ''
   SET @n_continue = 1
   
   SET @c_Pickslipno    = @c_Parm01
   SET @c_CartonNoStart = @c_Parm02
   SET @c_CartonNoEnd   = @c_Parm03

   --Discrete  
   SELECT TOP 1 @c_GetOrderkey = ORDERS.OrderKey
              , @c_M_Company = ISNULL(TRIM(ORDERS.M_Company), '')
              , @c_C_Country = ISNULL(TRIM(ORDERS.C_Country), '')
   FROM PackHeader (NOLOCK)
   JOIN ORDERS (NOLOCK) ON ORDERS.OrderKey = PackHeader.OrderKey
   WHERE PackHeader.PickSlipNo = @c_Parm01

   IF ISNULL(@c_GetOrderkey, '') = ''
   BEGIN
      --Conso  
      SELECT TOP 1 @c_GetOrderkey = ORDERS.OrderKey
                 , @c_M_Company = ISNULL(TRIM(ORDERS.M_Company), '')
                 , @c_C_Country = ISNULL(TRIM(ORDERS.C_Country), '')
      FROM PackHeader (NOLOCK)
      JOIN LoadPlanDetail (NOLOCK) ON PackHeader.LoadKey = LoadPlanDetail.LoadKey
      JOIN ORDERS (NOLOCK) ON ORDERS.OrderKey = LoadPlanDetail.OrderKey
      WHERE PackHeader.PickSlipNo = @c_Parm01

      IF ISNULL(@c_GetOrderkey, '') <> ''
         SET @c_CheckConso = 'Y'
      ELSE
         GOTO QUIT_SP
   END

   IF (@n_continue = 1 OR @n_continue = 2)
   BEGIN
      IF (@c_M_Company = 'OMG')
      BEGIN
         EXEC isp_BT_GenBartenderCommand   	  
                 @cPrinterID = @c_PrinterID
              ,  @c_LabelType = @c_LabelType
              ,  @c_userid = @c_UserId
              ,  @c_Parm01 = @c_Parm01 --pickslipno
              ,  @c_Parm02 = @c_Parm02 --carton from
              ,  @c_Parm03 = @c_Parm03 --carton to
              ,  @c_Parm04 = @c_Parm04
              ,  @c_Parm05 = @c_Parm05
              ,  @c_Parm06 = @c_Parm06
              ,  @c_Parm07 = @c_Parm07
              ,  @c_Parm08 = @c_Parm08
              ,  @c_Parm09 = @c_Parm09
              ,  @c_Parm10 = @c_Parm10
              ,  @c_Storerkey = @c_Storerkey
              ,  @c_NoCopy = @c_NoOfCopy
              ,  @c_Returnresult = 'N' 
              ,  @n_err = @n_Err OUTPUT
              ,  @c_errmsg = @c_ErrMsg OUTPUT   	
                               
         IF @n_Err <> 0 
         BEGIN
            SET @n_continue = 3
         END
      END
      
      IF (@c_C_Country = 'SG' AND @c_M_Company = 'NJV')
      BEGIN
         SET @b_success = 2   --Continue PrintCartonLabelByITF
      END
   END     
   
QUIT_SP:
   IF @n_continue = 3
   BEGIN
      SET @b_success = 0
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'ispPKBT18'  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END   
END  
GO
GRANT EXECUTE ON [dbo].[ispPKBT18] TO [NSQL]
GO