SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Stored Procedure: ispPKINS05                                            */
/* Creation Date: 06-Nov-2023                                              */
/* Copyright: MAERSK                                                       */
/* Written by: WLChooi                                                     */
/*                                                                         */
/* Purpose: WMS-24075 - LEGOEC - ECOM Packing                              */
/*                                                                         */
/* Called By: isp_PackGetInstruction_Wrapper                               */
/*            Storerconfig: PackGetInstruction_SP                          */
/*                                                                         */
/* GitHub Version: 1.0                                                     */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 06-Nov-2023  WLChooi 1.0   DevOps Combine Script                        */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ispPKINS05]
   @c_Pickslipno      NVARCHAR(10)
 , @c_Storerkey       NVARCHAR(15)
 , @c_Sku             NVARCHAR(50) --if call from pack header sku no value(header instruction), if from packdetail sku have value(item instruction)
 , @c_PackInstruction NVARCHAR(500) OUTPUT
 , @b_Success         INT           OUTPUT
 , @n_ErrNo           INT           OUTPUT
 , @c_ErrMsg          NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_Country     NVARCHAR(100) = N''
         , @c_CountryCode NVARCHAR(250) = N''

   SELECT @b_Success = 1
        , @n_ErrNo = 0
        , @c_ErrMsg = ''
        , @c_PackInstruction = ''

   IF ISNULL(@c_Sku, '') = '' --only get header instruction
   BEGIN
      SELECT @c_Country = O.C_Country
      FROM PICKHEADER PH (NOLOCK)
      JOIN ORDERS O (NOLOCK) ON PH.OrderKey = O.OrderKey
      WHERE PH.PickHeaderKey = @c_Pickslipno

      SELECT @c_CountryCode = ISNULL(CL.Code, '')
      FROM CODELKUP CL (NOLOCK)
      WHERE CL.LISTNAME = 'ISOCOUNTRY' AND CL.Code = @c_Country

      IF ISNULL(@c_CountryCode, '') <> ''
      BEGIN
         SET @c_PackInstruction = 'Country Code: ' + TRIM(@c_CountryCode)
      END
   END
END -- End Procedure
GO
GRANT EXECUTE ON [dbo].[ispPKINS05] TO [NSQL]
GO