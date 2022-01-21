IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispPKBT08]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[ispPKBT08]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: ispPKBT08                                          */
/* Creation Date: 26-Oct-2021                                           */
/* Copyright: LF Logistics                                              */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-18248 - SG - Adidas SEA - Exceed Packing UCC Label      */
/*                                                                      */
/* Called By: isp_Packing_Bartender_Print                               */
/*                                                                      */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 26-Oct-2021 WLChooi  1.0   DevOps Combine Script                     */
/************************************************************************/
CREATE PROCEDURE [dbo].[ispPKBT08]
   @c_printerid  NVARCHAR(50) = '',  
   @c_labeltype  NVARCHAR(30) = '',  
   @c_userid     NVARCHAR(18) = '',  
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
      
   DECLARE @n_continue        INT 
         , @c_Pickslipno      NVARCHAR(10) = ''
         , @c_Orderkey        NVARCHAR(10) = ''
         , @c_DocType         NVARCHAR(10) = ''
         , @c_OrderGroup      NVARCHAR(20) = ''
         , @c_UDF05           NVARCHAR(20) = ''
                                                      
   SET @n_err = 0
   SET @b_success = 1
   SET @c_errmsg = ''
   SET @n_continue = 1
   
   SET @c_Pickslipno = @c_Parm01

   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      SELECT @c_OrderKey    = ORDERS.OrderKey 
           , @c_OrderGroup  = ORDERS.OrderGroup
           , @c_DocType     = ORDERS.Doctype
      FROM PACKHEADER (NOLOCK)
      JOIN ORDERS (NOLOCK) ON PACKHEADER.Orderkey = ORDERS.Orderkey
      LEFT JOIN ORDERINFO (NOLOCK) ON OrderInfo.OrderKey = ORDERS.OrderKey
      WHERE PACKHEADER.PickSlipNo = @c_PickSlipNo 
      
      --Consider Conso
      IF ISNULL(@c_OrderKey,'') = ''
      BEGIN
         SELECT @c_OrderKey    = ORDERS.OrderKey 
              , @c_OrderGroup  = ORDERS.OrderGroup
              , @c_DocType     = ORDERS.Doctype
         FROM PACKHEADER (NOLOCK)
         JOIN LOADPLANDETAIL (NOLOCK) ON LOADPLANDETAIL.Loadkey = PACKHEADER.Loadkey
         JOIN ORDERS (NOLOCK) ON LOADPLANDETAIL.Orderkey = ORDERS.Orderkey
         LEFT JOIN ORDERINFO (NOLOCK) ON OrderInfo.OrderKey = ORDERS.OrderKey
         WHERE PACKHEADER.PickSlipNo = @c_PickSlipNo
      END
   END
   
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF @c_DocType = 'E'
      BEGIN
         SELECT @c_UDF05 = ISNULL(CL.UDF05,'') 
         FROM Orders OH (NOLOCK)
         JOIN CODELKUP CL (NOLOCK) ON CL.Listname = 'COURIERLBL'
                                  AND CL.Storerkey  = OH.Storerkey
                                  AND CL.Code = OH.Salesman
         WHERE OH.Orderkey = @c_Orderkey

         IF @c_UDF05 = 'Y'
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

            SET @b_success = 1 
         END
         ELSE   -- <> Zalora
         BEGIN
            SET @b_success = 1   --PACKUCC2PDF Should be printed before this
         END
      END
   END

QUIT_SP:
   IF @n_continue = 3
   BEGIN
      SET @b_success = 0
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'ispPKBT08'  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END   
END  
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON ispPKBT08 TO NSQL
GO