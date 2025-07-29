SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Procedure: msp_GetBOLbyConsigneeKey                                  */
/* Creation Date: 22-Jul-2025                                           */
/* Copyright: Maersk                                                    */
/* Written by: WLC015                                                   */
/*                                                                      */
/* Purpose: FCR-6612 - LVSUSA - Get BOLByConsigneekey for PARCEL Orders */
/*        :                                                             */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 22-Jul-2025 WLC015   1.0   Initial Version                           */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[msp_GetBOLbyConsigneeKey]
(
   @c_Wavekey           NVARCHAR(10) = ''
,  @c_Orderkey          NVARCHAR(10) = ''
 , @c_Consigneekey      NVARCHAR(15)
 , @c_BOLByConsigneekey NVARCHAR(50)         OUTPUT
 , @c_OtherParams       NVARCHAR(MAX) = ''   OUTPUT   --Usage: Optional - Pass in other params such as keyname, fieldlength, min, max - in JSON format
 , @b_Success           INT           = 1    OUTPUT   --Example: [{"Keyname":"BOLbyCons","MinSeq":1,"MaxSeq":69999999,"FieldLength":8}]
 , @n_Err               INT           = 0    OUTPUT
 , @c_ErrMsg            NVARCHAR(255) = ''   OUTPUT
 , @b_debug             INT           = 0
)
AS
BEGIN
   DECLARE @n_Continue     INT = 1
         , @c_StorerKey    NVARCHAR(15) = ''
         , @c_Facility     NVARCHAR(5)  = ''
         , @c_Keyname      NVARCHAR(18) = 'BOLbyCons'
         , @n_FieldLength  INT = 8
         , @n_MinSeq       BIGINT = 1
         , @n_MaxSeq       BIGINT = 69999999
         , @c_Susr5Prefix  NVARCHAR(60) = ''
         , @c_CheckDigit   NVARCHAR(1) = ''
         , @n_RowCount     INT = 0

   SET @b_Debug = @n_Err
   SET @b_Debug = ISNULL(@b_Debug, 0)
   SET @b_Success = 1
   SET @n_Err = 0
   SET @c_Errmsg = ''
   SET @c_BOLByConsigneekey = ''

   IF ISNULL(@c_Wavekey, '') <> ''   --By Wave
   BEGIN
      SELECT @c_StorerKey = MAX(OH.StorerKey)
           , @c_Facility = MAX(OH.Facility)
           , @c_BOLByConsigneekey = MAX(ISNULL(OI.ReferenceId,''))
           , @n_RowCount = COUNT(1)
      FROM dbo.WAVEDETAIL WD WITH (NOLOCK)
      JOIN dbo.ORDERS OH WITH (NOLOCK) ON WD.OrderKey = OH.OrderKey
      JOIN dbo.OrderInfo OI WITH (NOLOCK) ON OH.OrderKey = OI.OrderKey 
      WHERE WD.WaveKey = @c_Wavekey
      AND OH.ConsigneeKey = @c_Consigneekey
   END
   ELSE IF ISNULL(@c_Orderkey, '') <> ''   --By Order
   BEGIN
      SELECT @c_StorerKey = MAX(OH.StorerKey)
           , @c_Facility = MAX(OH.Facility)
           , @c_BOLByConsigneekey = MAX(ISNULL(OI.ReferenceId,''))
           , @n_RowCount = COUNT(1)
      FROM dbo.ORDERS OH WITH (NOLOCK)
      JOIN dbo.OrderInfo OI WITH (NOLOCK) ON OH.OrderKey = OI.OrderKey 
      WHERE OH.OrderKey = @c_Orderkey
      AND OH.ConsigneeKey = @c_Consigneekey
   END
   ELSE
   BEGIN
      GOTO QUIT_SP
   END

   --If no result, return
   IF @n_RowCount = 0
   BEGIN
      GOTO QUIT_SP
   END

   --Check if @c_OtherParams is JSON format
   IF ISJSON(@c_OtherParams) = 1
   BEGIN
      SELECT @c_Keyname = ISNULL(Keyname, 'BOLbyCons')
           , @n_MinSeq  = ISNULL(MinSeq, 1)
           , @n_MaxSeq  = ISNULL(MaxSeq, 69999999)
           , @n_FieldLength = ISNULL(FieldLength, 8)
      FROM
         OPENJSON(@c_OtherParams)
         WITH (
         Keyname     NVARCHAR(18) '$.Keyname'
       , MinSeq      BIGINT '$.MinSeq'
       , MaxSeq      BIGINT '$.MaxSeq'
       , FieldLength INT '$.FieldLength'
      )
   END

   IF TRIM(ISNULL(@c_BOLbyConsigneeKey, '')) = '' AND @n_Continue IN (1, 2)
   BEGIN
      SELECT @c_Susr5Prefix = ISNULL(TRIM(Storer.SUSR5),'0')
      FROM dbo.STORER Storer (NOLOCK)
      WHERE Storer.StorerKey = @c_Storerkey
      AND Storer.Facility = @c_Facility

      EXEC dbo.nspg_GetKeyMinMax @keyname = @c_Keyname -- nvarchar(18)
                               , @fieldlength = @n_FieldLength -- int
                               , @Min = @n_MinSeq -- bigint
                               , @Max = @n_MaxSeq -- bigint
                               , @keystring = @c_BOLbyConsigneeKey OUTPUT -- nvarchar(25)
                               , @b_Success = @b_Success OUTPUT -- int
                               , @n_err = @n_err OUTPUT -- int
                               , @c_errmsg = @c_errmsg OUTPUT -- nvarchar(250)

      IF NOT @b_success = 1
      BEGIN
         SELECT @n_Continue = 3
      END
      ELSE
      BEGIN
         SET @c_BOLbyConsigneeKey = @c_Susr5Prefix + @c_BOLbyConsigneeKey
         SELECT @c_CheckDigit = dbo.fnc_CalcGS1CheckDigit(TRIM(@c_BOLbyConsigneeKey))
         SET @c_BOLbyConsigneeKey = RIGHT(@c_BOLbyConsigneeKey + @c_CheckDigit, 17)
      END
   END

   QUIT_SP:
END
GO