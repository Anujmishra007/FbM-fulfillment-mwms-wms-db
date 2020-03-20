IF EXISTS (SELECT name FROM sysobjects WHERE name = 'ispPKINS02' AND type = 'P')
   DROP PROC ispPKINS02
GO

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
/************************************************************************/

CREATE PROCEDURE ispPKINS02
   @c_Pickslipno       NVARCHAR(10),
   @c_Storerkey        NVARCHAR(15),
   @c_Sku              NVARCHAR(50),  --if call from pack header sku no value(header instruction), if from packdetail sku have value(item instruction)
   @c_PackInstruction  NVARCHAR(20) OUTPUT,
   @b_Success          INT      OUTPUT,
   @n_ErrNo            INT      OUTPUT, 
   @c_ErrMsg           NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @c_countryname NVARCHAR(50)
                                 
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
END -- End Procedure

GO

GRANT EXECUTE ON  ispPKINS02 TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
