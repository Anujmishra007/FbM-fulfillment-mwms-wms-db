SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispPAKCF28                                            */
/* Creation Date: 07-Dec-2023                                              */
/* Copyright: MAERSK                                                       */
/* Written by: WLChooi                                                     */
/*                                                                         */
/* Purpose: WMS-24349 - SG - LEGOEC - Exceed Packing Module                */
/*                                                                         */
/* Called By: PostPackConfirmSP                                            */
/*                                                                         */
/* GitHub Version: 1.0                                                     */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 07-Dec-2023  WLChooi 1.0   DevOps Combine Script                        */
/* 10-Oct-2025  SSA01   1.1  UWP-42248 -Enhanced session management        */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[ispPAKCF28]
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

   DECLARE @b_Debug       INT          = 0
         , @n_Continue    INT
         , @n_StartTCnt   INT
         , @n_CartonNo    INT          = 0
         , @c_CartonType  NVARCHAR(10) = N''
         , @n_Weight      FLOAT        = 0.00
         , @n_Cube        FLOAT        = 0.00
         , @c_CartonGroup NVARCHAR(50) = N''

   SELECT @b_Success = 1
        , @n_Err = 0
        , @c_ErrMsg = ''
        , @n_Continue = 1
        , @n_StartTCnt = @@TRANCOUNT

   IF @n_Continue IN ( 1, 2 )
   BEGIN
      IF EXISTS (  SELECT 1
                   FROM PackHeader PH (NOLOCK)
                   JOIN ORDERS OH (NOLOCK) ON OH.OrderKey = PH.OrderKey
                   WHERE PH.PickSlipNo = @c_PickSlipNo
                   AND   OH.OrderGroup = 'ECOM'
                   AND   OH.DocType = 'E'
                   AND   OH.ECOM_SINGLE_Flag = 'S')
      BEGIN
         SELECT @c_CartonGroup = ISNULL(ST.CartonGroup, '')
         FROM PackHeader PH (NOLOCK)
         JOIN STORER ST (NOLOCK) ON PH.StorerKey = ST.StorerKey
         WHERE PH.PickSlipNo = @c_PickSlipNo

         --Check CartonType
         IF EXISTS (  SELECT 1
                      FROM PackInfo PIF (NOLOCK)
                      LEFT JOIN CARTONIZATION CZ (NOLOCK) ON  CZ.CartonizationGroup = @c_CartonGroup
                                                          AND CZ.CartonType = PIF.CartonType
                      WHERE PIF.PickSlipNo = @c_PickSlipNo AND CZ.CartonType IS NULL)
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 80900
            SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + ': CartonType is not valid. (ispPAKCF28)'
                            + ' ( SQLSvr MESSAGE=' + @c_ErrMsg + ' ) '
            GOTO QUIT_SP
         END

         --Check SKU
         IF EXISTS (  SELECT 1
                      FROM PackDetail PD (NOLOCK)
                      WHERE PD.PickSlipNo = @c_PickSlipNo AND (PD.SKU IS NULL OR PD.SKU = ''))
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 80905
            SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + ': SKU is empty. (ispPAKCF28)' + ' ( SQLSvr MESSAGE='
                            + @c_ErrMsg + ' ) '
            GOTO QUIT_SP
         END

         DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PD.PickSlipNo
              , PD.CartonNo
              , PIF.CartonType
              , SUM(PD.Qty * S.STDGROSSWGT) + ISNULL(CZ.CartonWeight, 0) AS [Weight]
              , ISNULL(CZ.[Cube], 0) AS [Cube]
         FROM PackDetail PD (NOLOCK)
         JOIN SKU S (NOLOCK) ON PD.StorerKey = S.StorerKey AND PD.SKU = S.Sku
         JOIN PackInfo PIF (NOLOCK) ON PD.PickSlipNo = PIF.PickSlipNo AND PD.CartonNo = PIF.CartonNo
         JOIN CARTONIZATION CZ (NOLOCK) ON CZ.CartonizationGroup = @c_CartonGroup AND CZ.CartonType = PIF.CartonType
         WHERE PD.PickSlipNo = @c_PickSlipNo
         GROUP BY PD.PickSlipNo
                , PD.CartonNo
                , PIF.CartonType
                , ISNULL(CZ.CartonWeight, 0)
                , ISNULL(CZ.[Cube], 0)

         OPEN CUR_LOOP

         FETCH NEXT FROM CUR_LOOP
         INTO @c_PickSlipNo
            , @n_CartonNo
            , @c_CartonType
            , @n_Weight
            , @n_Cube

         WHILE @@FETCH_STATUS <> -1
         BEGIN
            UPDATE PackInfo WITH (ROWLOCK)
            SET [Weight] = ISNULL(@n_Weight, 0.00)
              , [Cube] = ISNULL(@n_Cube, 0.00)
              , TrafficCop = NULL
              , EditDate = dbo.fnc_GetDate()    --(SSA01)
              , EditWho = dbo.fnc_GetUserName()                 --(SSA01)
            WHERE PickSlipNo = @c_PickSlipNo AND CartonNo = @n_CartonNo

            SELECT @n_Err = @@ERROR

            IF @n_Err <> 0
            BEGIN
               SET @n_Continue = 3
               SET @n_Err = 80910
               SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + ': Failed to update PACKINFO. (ispPAKCF28)'
                               + ' ( SQLSvr MESSAGE=' + @c_ErrMsg + ' ) '
               GOTO QUIT_SP
            END

            FETCH NEXT FROM CUR_LOOP
            INTO @c_PickSlipNo
               , @n_CartonNo
               , @c_CartonType
               , @n_Weight
               , @n_Cube
         END
         CLOSE CUR_LOOP
         DEALLOCATE CUR_LOOP
      END
   END

   QUIT_SP:

   IF CURSOR_STATUS('LOCAL', 'CUR_LOOP') IN ( 0, 1 )
   BEGIN
      CLOSE CUR_LOOP
      DEALLOCATE CUR_LOOP
   END

   IF @n_Continue = 3 -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'ispPAKCF28'
      RAISERROR(@c_ErrMsg, 16, 1) WITH SETERROR -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END
GO
GRANT EXECUTE ON [dbo].[ispPAKCF28] TO [NSQL]
GO