SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* SP: isp_GetVicsMbol                                                  */
/* Creation Date: 18-Jun-2024                                           */
/* Copyright: Maersk                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: UWP-20706 - Granite | MWMS | BOL Report                     */
/*        :                                                             */
/* Called By: Ported from PB function - f_get_vics_mbol                 */
/*          :                                                           */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 18-Jun-2024 WLChooi  1.0   DevOps Combine Script                     */
/************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[isp_GetVicsMbol]
(
   @c_Mbolkey NVARCHAR(10)
 , @c_Vics_MBOL NVARCHAR(50) OUTPUT
)
AS
BEGIN
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF

   DECLARE @c_ExternMBOLKey NVARCHAR(50)
         , @c_UCC           NVARCHAR(50)
         , @n_length        INT = 0
         , @n_count         INT = 0
         , @n_odd           INT = 0
         , @n_even          INT = 0
         , @n_check_digit   INT = 0
         , @n_len           INT = 0

   DECLARE @c_Facility                NVARCHAR(5)
         , @c_Storerkey               NVARCHAR(15)
         , @c_vicbillnumber_authority NVARCHAR(50) = N''
         , @c_Startnumber             NVARCHAR(50)
         , @c_Endnumber               NVARCHAR(50)
         , @c_Keyname                 NVARCHAR(50)
         , @c_Keystring               NVARCHAR(50)
         , @n_Startnumber             INT          = 0
         , @n_Endnumber               INT          = 0
         , @n_Runnolen                INT          = 0

   DECLARE @b_Success   INT
         , @c_authority NVARCHAR(30) = N''
         , @n_err       INT
         , @c_errmsg    NVARCHAR(250)

   SELECT @c_ExternMBOLKey = ExternMbolKey
        , @c_Facility = Facility
   FROM MBOL WITH (NOLOCK)
   WHERE MbolKey = @c_Mbolkey

   IF ISNULL(@c_ExternMBOLKey, '') = ''
      SET @c_ExternMBOLKey = N''

   IF @c_ExternMBOLKey = ''
   BEGIN
      SELECT @c_UCC = MAX(STORER.SUSR1)
           , @c_Storerkey = MAX(STORER.StorerKey)
      FROM MBOLDETAIL WITH (NOLOCK)
      JOIN ORDERS WITH (NOLOCK) ON (ORDERS.OrderKey = MBOLDETAIL.OrderKey)
      JOIN STORER WITH (NOLOCK) ON (STORER.StorerKey = ORDERS.StorerKey)
      WHERE MBOLDETAIL.MbolKey = @c_Mbolkey

      IF ISNULL(@c_UCC, '') = '' OR LEN(TRIM(@c_UCC)) = 0
      BEGIN
         SET @c_UCC = N'0400000'
      END
      ELSE
      BEGIN
         SET @c_UCC = RIGHT(REPLICATE('0', 7) + TRIM(@c_UCC), 7)
      END

      IF ISNUMERIC(@c_UCC) = 0
         SET @c_UCC = N'0400000'

      SET @c_Vics_MBOL = TRIM(@c_UCC) + N'000' + RIGHT(@c_Mbolkey, 6)

      EXEC dbo.nspGetRight @c_Facility = @c_Facility
                         , @c_StorerKey = @c_Storerkey
                         , @c_sku = N''
                         , @c_ConfigKey = N'VicBillNumber'
                         , @b_Success = @b_Success OUTPUT
                         , @c_authority = @c_vicbillnumber_authority OUTPUT
                         , @n_err = @n_err OUTPUT
                         , @c_errmsg = @c_errmsg OUTPUT

      IF @c_vicbillnumber_authority = '0'
         SET @c_vicbillnumber_authority = N''

      IF ISNULL(TRIM(@c_vicbillnumber_authority), '') <> ''
      BEGIN
         SELECT TOP 1 @c_Keyname = Code
                    , @c_Startnumber = ISNULL(UDF01, '0')
                    , @c_Endnumber = ISNULL(UDF02, '0')
         FROM CODELKUP (NOLOCK)
         WHERE LISTNAME = @c_vicbillnumber_authority

         IF ISNULL(TRIM(@c_Keyname), '') <> ''
         BEGIN
            IF ISNUMERIC(@c_Startnumber) = 1
               SET @n_Startnumber = CAST(@c_Startnumber AS INT)

            IF ISNUMERIC(@c_Endnumber) = 1
               SET @n_Endnumber = CAST(@c_Endnumber AS INT)

            EXEC dbo.nspg_GetKeyMinMax @keyname = @c_Keyname
                                     , @fieldlength = 17
                                     , @Min = @n_Startnumber
                                     , @Max = @n_Endnumber
                                     , @keystring = @c_Keystring OUTPUT
                                     , @b_Success = @b_Success OUTPUT
                                     , @n_err = @n_err OUTPUT
                                     , @c_errmsg = @c_errmsg OUTPUT

            IF @b_Success = 1 AND ISNULL(TRIM(@c_Keystring), '') <> ''
            BEGIN
               SET @n_Runnolen = 17 - LEN(TRIM(@c_UCC)) - 1
               SET @c_Vics_MBOL = TRIM(@c_UCC) + RIGHT(TRIM(@c_Keystring), @n_Runnolen)
            END
         END
      END

      SET @n_length = LEN(@c_Vics_MBOL)

      IF @n_length > 0
      BEGIN
         SET @n_count = 1

         WHILE (@n_count <= @n_length)
         BEGIN
            IF @n_count % 2 > 0
               SET @n_odd = @n_odd + CAST(SUBSTRING(@c_Vics_MBOL, @n_count, 1) AS INT) --ADD all digit in Add Placement
            ELSE
               SET @n_even = @n_even + CAST(SUBSTRING(@c_Vics_MBOL, @n_count, 1) AS INT) --ADD all digit in Even Placement

            SET @n_count = @n_count + 1
         END
      END

      SET @n_check_digit = 10 - ((@n_odd + (@n_even * 3)) % 10)

      IF @n_check_digit = 10
         SET @n_check_digit = 0

      SET @c_Vics_MBOL = @c_Vics_MBOL + CAST(@n_check_digit AS NVARCHAR)
   END
   ELSE
   BEGIN
      SET @c_Vics_MBOL = @c_ExternMBOLKey
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_GetVicsMbol] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_GetVicsMbol] TO [LogiReportRoleWM]
GO