if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_Create_Order_PI_Encrypted]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_Create_Order_PI_Encrypted]
GO
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: isp_Create_Order_PI_Encrypted                      */
/* Creation Date: 31-Mar-2020                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Shong                                                    */
/*                                                                      */
/* Purpose: Encrypt Personal Information for Order                      */
/*                                                                      */
/* Called By: Interface                                                 */
/*                                                                      */
/* Version: 8.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 02-Mar-2021  Shong         Update EditWho and EditDate               */
/************************************************************************/

CREATE PROC [dbo].[isp_Create_Order_PI_Encrypted]
            @c_OrderKey       NVARCHAR(10)
          , @c_C_Contact1     NVARCHAR(200) = ''
          , @c_C_Contact2     NVARCHAR(200) = ''
          , @c_C_Company      NVARCHAR(45)  = ''
          , @c_C_Address1     NVARCHAR(45)  = ''
          , @c_C_Address2     NVARCHAR(45)  = ''
          , @c_C_Address3     NVARCHAR(45)  = ''
          , @c_C_Address4     NVARCHAR(45)  = ''
          , @c_C_City         NVARCHAR(45)  = ''
          , @c_C_State        NVARCHAR(45)  = ''
          , @c_C_Country      NVARCHAR(30)  = ''
          , @c_C_Phone1       NVARCHAR(18)  = ''
          , @c_C_Phone2       NVARCHAR(18)  = ''
          , @c_C_Zip          NVARCHAR(18)  = ''
          , @c_C_Fax1         NVARCHAR(18)  = ''
          , @c_C_Fax2         NVARCHAR(18)  = ''
          , @c_B_Contact1     NVARCHAR(30)  = ''
          , @c_B_Contact2     NVARCHAR(30)  = ''
          , @c_B_Company      NVARCHAR(45)  = ''
          , @c_B_Address1     NVARCHAR(45)  = ''
          , @c_B_Address2     NVARCHAR(45)  = ''
          , @c_B_Address3     NVARCHAR(45)  = ''
          , @c_B_Address4     NVARCHAR(45)  = ''
          , @c_B_City         NVARCHAR(45)  = ''
          , @c_B_Zip          NVARCHAR(18)  = ''
          , @c_B_Country      NVARCHAR(30)  = ''
          , @c_B_Phone1       NVARCHAR(18)  = ''
          , @c_B_Phone2       NVARCHAR(18)  = ''
          , @c_B_Fax1         NVARCHAR(18)  = ''
          , @c_B_Fax2         NVARCHAR(18)  = ''
          , @c_B_State        NVARCHAR(45)  = ''
          , @c_M_Contact1     NVARCHAR(45)  = ''
          , @c_M_Contact2     NVARCHAR(45)  = ''
          , @c_M_Company      NVARCHAR(45)  = ''
          , @c_M_Address1     NVARCHAR(45)  = ''
          , @c_M_Address2     NVARCHAR(45)  = ''
          , @c_M_Address3     NVARCHAR(45)  = ''
          , @c_M_Address4     NVARCHAR(45)  = ''
          , @c_M_City         NVARCHAR(45)  = ''
          , @c_M_Zip          NVARCHAR(45)  = ''
          , @c_M_Country      NVARCHAR(45)  = ''
          , @c_M_Phone1       NVARCHAR(45)  = ''
          , @c_M_Phone2       NVARCHAR(45)  = ''
          , @c_M_Fax1         NVARCHAR(18)  = ''
          , @c_M_Fax2         NVARCHAR(18)  = ''
          , @c_M_State        NVARCHAR(45)  = ''
          , @c_NoUpdateC      NVARCHAR(45)  = 'N'
          , @b_success        INT           = 1  OUTPUT
          , @n_ErrNo          INT           = 0  OUTPUT
          , @c_ErrMsg         NVARCHAR(250) = '' OUTPUT
AS
BEGIN
   SET @b_success = 1

   BEGIN TRY
      OPEN SYMMETRIC KEY Smt_Key_Orders_PI
      DECRYPTION BY CERTIFICATE Cert_Orders_PI;
   END TRY

   BEGIN CATCH
      SET @n_ErrNo   = ERROR_NUMBER()
      SET @c_ErrMsg  = ERROR_MESSAGE()
      SET @b_success = 0

       GOTO QUICK_SP
   END CATCH

   IF NOT EXISTS (SELECT 1 FROM Orders_PI_Encrypted WITH (NOLOCK) WHERE Orderkey = @c_OrderKey )
   BEGIN
      INSERT INTO Orders_PI_Encrypted (
        Orderkey
      , C_Contact1
      , C_Contact2
      , C_Company
      , C_Address1
      , C_Address2
      , C_Address3
      , C_Address4
      , C_City
      , C_State
      , C_Country
      , C_Phone1
      , C_Phone2
      , C_Zip
      , C_Fax1
      , C_Fax2
      , B_Contact1
      , B_Contact2
      , B_Company
      , B_Address1
      , B_Address2
      , B_Address3
      , B_Address4
      , B_City
      , B_Zip
      , B_Country
      , B_Phone1
      , B_Phone2
      , B_Fax1
      , B_Fax2
      , B_State
      , M_Contact1
      , M_Contact2
      , M_Company
      , M_Address1
      , M_Address2
      , M_Address3
      , M_Address4
      , M_City
      , M_Zip
      , M_Country
      , M_Phone1
      , M_Phone2
      , M_Fax1
      , M_Fax2
      , M_State
      , AddDate
      , AddWho
      , EditDate
      , EditWho
      ) VALUES (
        @c_Orderkey
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_Contact1, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_Contact2, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_Company , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_Address1, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_Address2, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_Address3, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_Address4, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_City    , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_State   , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_Country , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_Phone1  , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_Phone2  , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_Zip     , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_Fax1    , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_C_Fax2    , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_Contact1, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_Contact2, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_Company , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_Address1, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_Address2, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_Address3, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_Address4, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_City    , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_Zip     , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_Country , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_Phone1  , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_Phone2  , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_Fax1    , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_Fax2    , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_B_State   , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_Contact1, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_Contact2, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_Company , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_Address1, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_Address2, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_Address3, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_Address4, ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_City    , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_Zip     , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_Country , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_Phone1  , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_Phone2  , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_Fax1    , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_Fax2    , ''))
      , EncryptByKey(Key_GUID('Smt_Key_Orders_PI'),ISNULL(@c_M_State   , ''))
      , GETDATE()
      , SUSER_SNAME()
      , GETDATE()
      , SUSER_SNAME()
      )

   END
   ELSE
   BEGIN
      UPDATE Orders_PI_Encrypted WITH (ROWLOCK)
      SET C_Contact1 = CASE WHEN @c_NoUpdateC = 'Y' THEN C_Contact1 ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_Contact1, '')) END
        , C_Contact2 = CASE WHEN @c_NoUpdateC = 'Y' THEN C_Contact2 ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_Contact2, '')) END
        , C_Company  = CASE WHEN @c_NoUpdateC = 'Y' THEN C_Company  ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_Company , '')) END
        , C_Address1 = CASE WHEN @c_NoUpdateC = 'Y' THEN C_Address1 ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_Address1, '')) END
        , C_Address2 = CASE WHEN @c_NoUpdateC = 'Y' THEN C_Address2 ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_Address2, '')) END
        , C_Address3 = CASE WHEN @c_NoUpdateC = 'Y' THEN C_Address3 ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_Address3, '')) END
        , C_Address4 = CASE WHEN @c_NoUpdateC = 'Y' THEN C_Address4 ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_Address4, '')) END
        , C_City     = CASE WHEN @c_NoUpdateC = 'Y' THEN C_City     ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_City    , '')) END
        , C_State    = CASE WHEN @c_NoUpdateC = 'Y' THEN C_State    ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_State   , '')) END
        , C_Phone1   = CASE WHEN @c_NoUpdateC = 'Y' THEN C_Phone1   ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_Phone1  , '')) END
        , C_Phone2   = CASE WHEN @c_NoUpdateC = 'Y' THEN C_Phone2   ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_Phone2  , '')) END
        , C_Zip      = CASE WHEN @c_NoUpdateC = 'Y' THEN C_Zip      ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_Zip     , '')) END
        , C_Fax1     = CASE WHEN @c_NoUpdateC = 'Y' THEN C_Fax1     ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_Fax1    , '')) END
        , C_Fax2     = CASE WHEN @c_NoUpdateC = 'Y' THEN C_Fax2     ELSE EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_C_Fax2    , '')) END
        , B_Contact1 = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_Contact1, ''))
        , B_Contact2 = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_Contact2, ''))
        , B_Company  = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_Company , ''))
        , B_Address1 = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_Address1, ''))
        , B_Address2 = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_Address2, ''))
        , B_Address3 = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_Address3, ''))
        , B_Address4 = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_Address4, ''))
        , B_City     = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_City    , ''))
        , B_Zip      = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_Zip     , ''))
        , B_Country  = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_Country , ''))
        , B_Phone1   = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_Phone1  , ''))
        , B_Phone2   = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_Phone2  , ''))
        , B_Fax1     = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_Fax1    , ''))
        , B_Fax2     = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_Fax2    , ''))
        , B_State    = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_B_State   , ''))
        , M_Contact1 = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_Contact1, ''))
        , M_Contact2 = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_Contact2, ''))
        , M_Company  = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_Company , ''))
        , M_Address1 = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_Address1, ''))
        , M_Address2 = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_Address2, ''))
        , M_Address3 = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_Address3, ''))
        , M_Address4 = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_Address4, ''))
        , M_City     = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_City    , ''))
        , M_Zip      = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_Zip     , ''))
        , M_Country  = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_Country , ''))
        , M_Phone1   = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_Phone1  , ''))
        , M_Phone2   = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_Phone2  , ''))
        , M_Fax1     = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_Fax1    , ''))
        , M_Fax2     = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_Fax2    , ''))
        , M_State    = EncryptByKey(Key_GUID('Smt_Key_Orders_PI'), ISNULL(@c_M_State   , ''))
        , EditDate = GETDATE()
        , EditWho = SUSER_SNAME()
      WHERE Orderkey = @c_Orderkey
   END

   QUICK_SP:

END -- procedure

GO


GRANT EXECUTE ON isp_Get_Order_PI_Encrypted to nSQL
GO