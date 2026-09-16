SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_ECOMP_PAKCF01                                     */
/* Creation Date: 15-JUN-2026                                              */
/* Copyright: IDS                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: FCR-13430 HK -On Running SCE Ecom Packing Decode Logic         */
/*                                                                         */
/* Called By: PostPackConfirmSP                                            */
/*                                                                         */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 15-Jun-2026  CSC166  1.0   FCR-13430 - Initial						         */
/* 16-Sep-2026  SRD041  1.1   FCR-13430 - fix duplicate name					*/
/***************************************************************************/
CREATE OR ALTER   PROC [dbo].[isp_ECOMP_PAKCF01]
(     @c_PickSlipNo  NVARCHAR(10)
  ,   @c_Storerkey   NVARCHAR(15)
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Debug           INT
         , @n_Continue        INT
         , @n_StartTCnt       INT

   SET @b_Success= 1
   SET @n_Err    = 0
   SET @c_ErrMsg = ''
   SET @b_Debug  = 0
   SET @n_Continue = 1
   SET @n_StartTCnt = @@TRANCOUNT

   DECLARE @c_LabelNo  NVARCHAR(20),
           @c_Orderkey NVARCHAR(10),
           @n_RowRef   BIGINT

   UPDATE PACKSERIALNO
	SET PACKSERIALNO.PickDetailKey = PDI.PickDetailKey,
		Trafficcop = NULL
	FROM PACKSERIALNO PSN
	INNER JOIN PackDetail PD
		ON PD.PickSlipNo = PSN.PickSlipNo
	   AND PD.LabelNo  = PSN.LabelNo
	   AND PD.Sku    = PSN.Sku
	   AND PD.StorerKey  = PSN.StorerKey
	INNER JOIN PickDetail PDI
		ON PDI.CaseID = PD.LabelNo
	   AND PDI.SKU = PD.Sku
	   AND PDI.StorerKey = PD.StorerKey
	WHERE PD.PickSlipNo = @c_PickSlipNo AND PD.StorerKey = @c_Storerkey

   SET @n_Err = @@ERROR

	IF @n_Err <> 0
	BEGIN
		SELECT @n_Continue = 3
		SELECT @n_Err = 38020
		SELECT @c_Errmsg='NSQL'+CONVERT(varchar(5),@n_Err)+': Update PACKDETAIL Failed. (isp_ECOMP_PAKCF01)'
		GOTO QUIT_SP
	END

   QUIT_SP:

   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_ECOMP_PAKCF01'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
        COMMIT TRAN
      END
      RETURN
   END
END
