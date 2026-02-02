SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispPAKCF26                                            */
/* Creation Date: 06-Sep-2023                                              */
/* Copyright: MAERSK                                                       */
/* Written by: WLChooi                                                     */
/*                                                                         */
/* Purpose: WMS-23560 - SG - LIXIL (LIXILSAP & LIXILNSAP) Pack confirm     */
/*                      update packdetail and orders                       */
/*                                                                         */
/* Called By: PostPackConfirmSP                                            */
/*                                                                         */
/* GitLab Version: 1.0                                                     */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 06-Sep-2023  WLChooi 1.0   DevOps Combine Script                        */
/* 10-Oct-2025  SSA01   1.1  UWP-42248 -Enhanced session management        */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[ispPAKCF26]
(
   @c_PickSlipNo NVARCHAR(10)
 , @c_Storerkey  NVARCHAR(15)
 , @b_Success    INT           OUTPUT
 , @n_Err        INT           OUTPUT
 , @c_ErrMsg     NVARCHAR(255) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Debug         INT = 0
         , @n_Continue      INT
         , @n_StartTCnt     INT
         , @c_Refno2        NVARCHAR(30)
         , @c_Orderkey      NVARCHAR(10)
         , @n_CartonNo      INT
         , @c_C_Country     NVARCHAR(100) = ''
         , @c_M_Company     NVARCHAR(100) = ''
         , @c_UpdTrackingNo NVARCHAR(1) = 'N'

   SELECT @b_Success = 1
        , @n_Err = 0
        , @c_ErrMsg = ''
        , @n_Continue = 1
        , @n_StartTCnt = @@TRANCOUNT

   IF @@TRANCOUNT = 0
      BEGIN TRAN

   IF  @n_Continue IN ( 1, 2 )
   AND EXISTS (  SELECT 1
                 FROM PackHeader PH (NOLOCK)
                 JOIN ORDERS O (NOLOCK) ON PH.OrderKey = O.OrderKey
                 JOIN CODELKUP CL (NOLOCK) ON O.StorerKey = CL.Storerkey AND O.M_Company = CL.UDF01
                 WHERE CL.LISTNAME = 'CUSTPARAM' AND CL.Code = 'AUTOGENTRACKINGID' AND PH.PickSlipNo = @c_PickSlipNo)
   BEGIN
      SELECT @c_Orderkey = O.OrderKey
           , @c_Refno2 = RTRIM(ISNULL(O.C_Country, '')) + LTRIM(ISNULL(O.M_Company, ''))
           , @c_C_Country = ISNULL(O.C_Country, '')
           , @c_M_Company = ISNULL(O.M_Company, '')
      FROM PackHeader PH (NOLOCK)
      JOIN ORDERS O (NOLOCK) ON PH.OrderKey = O.OrderKey
      WHERE PH.PickSlipNo = @c_PickSlipNo

      IF (@c_C_Country = 'SG' AND @c_M_Company = 'NJV')
         SET @c_UpdTrackingNo = 'Y'

      DECLARE CUR_UPD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PD.CartonNo
      FROM PACKDETAIL PD (NOLOCK)
      WHERE PD.PickSlipNo = @c_PickSlipNo
      ORDER BY PD.CartonNo

      OPEN CUR_UPD

      FETCH NEXT FROM CUR_UPD INTO @n_CartonNo

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         UPDATE PackDetail WITH (ROWLOCK)
         SET RefNo = IIF(@c_UpdTrackingNo = 'Y', 'MSLIX' + SUBSTRING(PickSlipNo,2,9) + CONVERT(NVARCHAR,CartonNo), LabelNo)
           , RefNo2 = @c_Refno2
           , ArchiveCop = NULL
           , EditDate = dbo.fnc_GetDate()    --(SSA01)
           , EditWho = dbo.fnc_GetUserName()            --(SSA01)
         WHERE PickSlipNo = @c_PickSlipNo
         AND CartonNo = @n_CartonNo

         SET @n_Err = @@ERROR

         IF @n_Err <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 64300 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
            SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err)
                            + ': Update Packdetail Table Failed. (ispPAKCF26) ( SQLSvr MESSAGE=' + @c_ErrMsg + ' ) '
            GOTO QUIT_SP
         END

         IF @c_UpdTrackingNo = 'Y'
         BEGIN
            UPDATE PackInfo WITH (ROWLOCK)
            SET TrackingNo = 'MSLIX' + SUBSTRING(PickSlipNo,2,9) + CONVERT(NVARCHAR,CartonNo)
              , ArchiveCop = NULL
              , EditDate = dbo.fnc_GetDate()    --(SSA01)
              , EditWho = dbo.fnc_GetUserName()           --(SSA01)
            WHERE PickSlipNo = @c_PickSlipNo
            AND CartonNo = @n_CartonNo

            SET @n_Err = @@ERROR

            IF @n_Err <> 0
            BEGIN
               SET @n_Continue = 3
               SET @n_Err = 64305 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
               SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err)
                               + ': Update PackInfo Table Failed. (ispPAKCF26) ( SQLSvr MESSAGE=' + @c_ErrMsg + ' ) '
               GOTO QUIT_SP
            END
         END

         FETCH NEXT FROM CUR_UPD INTO @n_CartonNo
      END
      CLOSE CUR_UPD
      DEALLOCATE CUR_UPD

      UPDATE ORDERS WITH (ROWLOCK)
      SET SOStatus = '5'
      WHERE OrderKey = @c_Orderkey

      SET @n_Err = @@ERROR

      IF @n_Err <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 64310 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err)
                         + ': Update Order Table Failed. (ispPAKCF26) ( SQLSvr MESSAGE=' + @c_ErrMsg + ' ) '
         GOTO QUIT_SP
      END
   END

   QUIT_SP:

   IF CURSOR_STATUS('LOCAL', 'CUR_UPD') IN (0 , 1)
   BEGIN
      CLOSE CUR_UPD
      DEALLOCATE CUR_UPD   
   END

   IF @n_Continue = 3 -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'ispPAKCF26'
      RAISERROR(@c_ErrMsg, 16, 1) WITH SETERROR -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[ispPAKCF26] TO NSQL
GO