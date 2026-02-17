/****** Object:  StoredProcedure [dbo].[isp_GetVicsMbol]    Script Date: 7/30/2025 2:21:24 PM ******/
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
/* Purpose: UWP-20706 - Granite | MWMS | BOL Report (FCR-234)           */
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
/* 25-Jul-2025 CSCHONG  1.1   FCR-6331 revised externmbolkey logic (CS01)*/
/************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[isp_GetVicsMbol]
(
   @c_Mbolkey NVARCHAR(10)
 , @c_Vics_MBOL NVARCHAR(60) OUTPUT
)
AS
BEGIN
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   DECLARE @c_ExternMBOLKey NVARCHAR(60)
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
         , @c_Keyname                 NVARCHAR(50) = 'LVSUSABOLNONPARCEL'
         , @c_Keystring               NVARCHAR(50)
         , @n_Startnumber             INT          = 0
         , @n_Endnumber               INT          = 0
         , @n_Runnolen                INT          = 0
         , @n_SumAll                  INT          = 0
   DECLARE @b_Success   INT
         , @c_authority NVARCHAR(30) = N''
         , @n_err       INT
         , @c_errmsg    NVARCHAR(250)

   --CS01 S
   DECLARE @n_Continue             INT = 1    
         , @n_FieldLength          INT = 8  
         , @n_MinSeq               BIGINT = 70000001  
         , @n_MaxSeq               BIGINT = 99999999   
         , @c_CheckDigit           NVARCHAR(1) = ''
		 , @c_Susr5Prefix          NVARCHAR(60) = ''
		 , @c_skipGenExtMbolkey    NVARCHAR(1) ='Y'
		 , @c_Vics_MBOL1           NVARCHAR(60) 
		 , @c_Vics_MBOL2           NVARCHAR(60) 


   SELECT @c_ExternMBOLKey = ExternMbolKey
        , @c_Facility = Facility
   FROM MBOL WITH (NOLOCK)
   WHERE MbolKey = @c_Mbolkey

   IF ISNULL(@c_ExternMBOLKey, '') = ''
      SET @c_ExternMBOLKey = N''

   --CS01 S
     --move up
     SELECT @c_UCC = MAX(STORER.SUSR5)
           , @c_Storerkey = MAX(STORER.StorerKey)
      FROM MBOLDETAIL WITH (NOLOCK)
      JOIN ORDERS WITH (NOLOCK) ON (ORDERS.OrderKey = MBOLDETAIL.OrderKey)
      JOIN STORER WITH (NOLOCK) ON (STORER.StorerKey = ORDERS.StorerKey)
      WHERE MBOLDETAIL.MbolKey = @c_Mbolkey
	  
   IF NOT EXISTS (
			SELECT 1
			FROM MBOL MB (NOLOCK)
			INNER JOIN MBOLDETAIL MBD (NOLOCK) ON MB.MbolKey = MBD.MbolKey
			INNER JOIN ORDERS O (NOLOCK) ON O.OrderKey = MBD.OrderKey 
			LEFT JOIN CODELKUP CLK (NOLOCK) ON MB.CarrierKey = CLK.Short AND CLK.LISTNAME = 'WSCOURIER' AND CLK.Code LIKE 'ECL%'
			WHERE MB.MBOLKey = @c_Mbolkey 
			AND (MB.ExternMbolKey <> ''
			OR (MB.ExternMbolKey = '' AND MB.CarrierKey = ''
			OR CLK.Short IS NOT NULL 
			OR MB.CarrierKey <> O.ShipperKey))
			) 
   BEGIN
      --CS01 
      --SELECT @c_UCC = MAX(STORER.SUSR5)
      --     , @c_Storerkey = MAX(STORER.StorerKey)
      --FROM MBOLDETAIL WITH (NOLOCK)
      --JOIN ORDERS WITH (NOLOCK) ON (ORDERS.OrderKey = MBOLDETAIL.OrderKey)
      --JOIN STORER WITH (NOLOCK) ON (STORER.StorerKey = ORDERS.StorerKey)
      --WHERE MBOLDETAIL.MbolKey = @c_Mbolkey

      IF ISNULL(@c_UCC, '') = '' OR LEN(TRIM(@c_UCC)) = 0
      BEGIN
         SET @c_Vics_MBOL = ''
         GOTO QUIT_SP
      END
      IF ISNUMERIC(@c_UCC) = 0
      BEGIN
         SET @c_Vics_MBOL = ''
         GOTO QUIT_SP
      END
      --SET @c_Vics_MBOL = TRIM(@c_UCC) + RIGHT(TRIM(@c_Mbolkey), 8)  --CS01
	  SET @c_Vics_MBOL = RIGHT(TRIM(@c_Mbolkey), 8)                   --CS01

	  
      EXEC dbo.nspg_GetKeyMinMax @keyname = @c_Keyname -- nvarchar(18)  
                               , @fieldlength = @n_FieldLength -- int  
                               , @Min = @n_MinSeq -- bigint  
                               , @Max = @n_MaxSeq -- bigint  
                               , @keystring = @c_Vics_MBOL OUTPUT -- nvarchar(25)  
                               , @b_Success = @b_Success OUTPUT -- int  
                               , @n_err = @n_err OUTPUT -- int  
                               , @c_errmsg = @c_errmsg OUTPUT -- nvarchar(250)  

	  --CS01 start disable
      --SET @n_length = LEN(@c_Vics_MBOL)
      --IF @n_length > 0
      --BEGIN
      --   SET @n_count = 1
      --   WHILE (@n_count <= @n_length)
      --   BEGIN
      --      IF @n_count % 2 > 0
      --         SET @n_odd = @n_odd + CAST(SUBSTRING(@c_Vics_MBOL, @n_count, 1) AS INT) --ADD all digit in Odd Placement
      --      ELSE
      --         SET @n_even = @n_even + CAST(SUBSTRING(@c_Vics_MBOL, @n_count, 1) AS INT) --ADD all digit in Even Placement
      --      SET @n_count = @n_count + 1
      --   END
      --END
        --   SET @n_SumAll = (@n_odd * 3) + @n_even
   --   SET @n_check_digit = CONVERT(NVARCHAR(1),(1000 - @n_SumAll) % 10)
   --   SET @c_Vics_MBOL = @c_Vics_MBOL + CAST(@n_check_digit AS NVARCHAR)
   --   SET @c_Vics_MBOL = RIGHT(TRIM(@c_Vics_MBOL), 17)
    
	  SET @c_Vics_MBOL = TRIM(@c_UCC) + @c_Vics_MBOL
      SET @c_CheckDigit = dbo.fnc_CalcGS1CheckDigit(TRIM(@c_Vics_MBOL))
      SET @c_Vics_MBOL = (@c_Vics_MBOL + @c_CheckDigit)
      SET @c_Vics_MBOL = RIGHT(TRIM(@c_Vics_MBOL), 17)
	  --CS01 End
   END
   ELSE
   BEGIN
      SET @c_Vics_MBOL = @c_ExternMBOLKey
   END

QUIT_SP:
END -- procedure

GO
GRANT EXECUTE ON [dbo].[isp_GetVicsMbol] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_GetVicsMbol] TO LogiReportRoleWM
GO
