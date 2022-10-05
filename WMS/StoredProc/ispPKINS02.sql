SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Store procedure: ispPKINS02                                          */
/* Copyright      : LF                                                  */
/*                                                                      */
/* Purpose: WMS-4405 - SG NikeSG- get header pack instruction           */
/*                                                                      */
/* Called from: isp_PackGetInstruction_Wrapper                          */
/*              storerconfig: PackGetInstruction_SP                     */
/*                                                                      */
/* Exceed version: 7.0                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 01-Jul-2021 1.0  NJOW01     WMS-17290 Sku pack instruction for single*/
/*                             order pack                               */
/* 19-Sep-2022 1.1  NJOW02     WMS-20807 prompt alert for DG product    */
/* 19-Sep-2022 1.1  NJOW02     DEVOPS Combine Script                    */
/************************************************************************/

CREATE OR ALTER PROCEDURE ispPKINS02
   @c_Pickslipno       NVARCHAR(10),
   @c_Storerkey        NVARCHAR(15),
   @c_Sku              NVARCHAR(50),  --if call from pack header sku no value(header instruction), if from packdetail sku have value(item instruction)
   @c_PackInstruction  NVARCHAR(500) OUTPUT,  --NJOW01
   @b_Success          INT      OUTPUT,
   @n_ErrNo            INT      OUTPUT, 
   @c_ErrMsg           NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @c_countryname  NVARCHAR(50),
           @c_ProductModel NVARCHAR(30),
           @c_OrderGroup   NVARCHAR(20)
                                 
   SELECT @b_Success = 1, @n_ErrNo = 0, @c_ErrMsg = '', @c_PackInstruction = ''
        
   IF ISNULL(@c_Sku,'') = ''  --only get header instruction
   BEGIN   	
   	  SELECT @c_countryname = CASE WHEN ISNULL(CL.Long,'') <> '' THEN CL.Long ELSE O.c_isocntrycode END
   	  FROM PICKHEADER PH (NOLOCK)
   	  JOIN ORDERS O (NOLOCK) ON PH.Orderkey = O.Orderkey
   	  LEFT JOIN CODELKUP CL (NOLOCK) ON  O.c_isocntrycode = CL.Code AND CL.Listname = 'ISOCOUNTRY'
   	  WHERE PH.Pickheaderkey = @c_Pickslipno   	  
   	  
   	  IF ISNULL(@c_countryname,'') <> ''
   	     SET @c_PackInstruction = 'Country: ' + @c_countryname
   	  
   END
   
   --NJOW01
   IF ISNULL(@c_Sku,'') <> ''  --only get detail instruction for single order pack
   BEGIN   	                                    
   	  --NJOW02 S                              
   	  SELECT TOP 1 @c_OrderGroup = O.OrderGroup,
   	               @c_ProductModel = SKU.ProductModel
   	  FROM PICKHEADER PH (NOLOCK)
      JOIN ORDERS O (NOLOCK) ON PH.Orderkey = O.Orderkey
      JOIN ORDERDETAIL OD (NOLOCK) ON O.Orderkey = OD.Orderkey
      JOIN SKU (NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku
      WHERE PH.Pickheaderkey = @c_Pickslipno
      AND OD.Sku = @c_Sku
                      
      IF @c_OrderGroup = 'SINGLE' AND @c_ProductModel = '1BOX'
      BEGIN
         SET @c_PackInstruction = '1 BOX SKU. No Shipping Box Required!' 
      END          
      ELSE IF @c_OrderGroup IN('SINGLE','MULTI') AND @c_ProductModel = 'DG'
      BEGIN
         SET @c_PackInstruction = 'Paste DG Label' 
      END         
      --NJOW02 E

      /*
   	  IF EXISTS(SELECT 1
                FROM PICKHEADER PH (NOLOCK)
                JOIN ORDERS O (NOLOCK) ON PH.Orderkey = O.Orderkey
                JOIN ORDERDETAIL OD (NOLOCK) ON O.Orderkey = OD.Orderkey
                JOIN SKU (NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku
                WHERE PH.Pickheaderkey = @c_Pickslipno
                AND OD.Sku = @c_Sku
                AND SKU.ProductModel = '1BOX'
                AND O.OrderGroup = 'SINGLE'         
                )
      BEGIN
         SET @c_PackInstruction = '1 BOX SKU. No Shipping Box Required!'
      END    
      */ 
   END
END -- End Procedure

GO

GRANT EXECUTE ON  ispPKINS02 TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
