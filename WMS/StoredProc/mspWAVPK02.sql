SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: mspWAVPK02                                         */
/* Creation Date: 15-Sep-2025                                           */
/* Copyright: Maersk                                                    */
/* Written by: AYD                                                      */
/*                                                                      */
/* Purpose:                                                             */                
/*   FCR-7762: CANADA_MWMS_MGA Entertainment_Generate pack from pick    */
/*                                                                      */
/* Called By: Wave                                                      */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 15-Sep-2025  AYD      1.0  Created procedure                         */
/* 30-Mar-2026  AYD      1.1  Rename to mspWAVPK02 (was ispWAVPK19)     */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[mspWAVPK02]
   @c_Wavekey   NVARCHAR(10),
   @b_Success   INT      OUTPUT,
   @n_Err       INT      OUTPUT,
   @c_ErrMsg    NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_Storerkey                    NVARCHAR(15),
           @c_Sku                          NVARCHAR(20),
           @n_Qty                          INT,
           @n_CaseCnt                      INT,
           @c_LottableNum                  NVARCHAR(2),
           @n_CtnQty                       INT,
           @c_PickslipNo                   NVARCHAR(10),
           @n_CartonNo                     INT,
           @c_LabelNo                      NVARCHAR(20),
           @n_LabelLineNo                  INT,
           @c_LabelLineNo                  NVARCHAR(5),
           @c_Orderkey                     NVARCHAR(10),
           @c_Loadkey                      NVARCHAR(10),
           @c_Conso                        NVARCHAR(10)

   DECLARE @n_Continue   INT,
           @n_StartTCnt  INT,
           @n_debug      INT

   IF @n_err =  1
      SET @n_debug = 1
   ELSE
      SET @n_debug = 0

   SELECT @n_Continue=1, @n_StartTCnt=@@TRANCOUNT, @n_Err = 0, @c_ErrMsg = '', @b_success = 1

   IF @@TRANCOUNT = 0
      BEGIN TRAN

   --Validation
   IF @n_continue IN(1,2)
   BEGIN
      IF EXISTS(SELECT 1 FROM PickDetail PD WITH (NOLOCK)
                JOIN  WAVEDETAIL WD WITH (NOLOCK) ON PD.Orderkey = WD.Orderkey
                WHERE PD.Status='4' AND PD.Qty > 0
                AND  WD.Wavekey = @c_WaveKey)
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38010
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Found Short Pick with Qty > 0 (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         GOTO QUIT_SP
      END

      IF EXISTS(SELECT 1 FROM WAVEDETAIL WD (NOLOCK)
                JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
                WHERE WD.Wavekey = @c_Wavekey
                AND O.Status <> '5')
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38020
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Found some orders are not picked(5). (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         GOTO QUIT_SP
      END
      IF EXISTS(SELECT 1
                FROM WAVEDETAIL WD (NOLOCK)
                JOIN LOADPLANDETAIL LPD (NOLOCK) ON WD.Orderkey = LPD.Orderkey
                JOIN PICKHEADER PH (NOLOCK) ON LPD.Loadkey = PH.ExternOrderKey AND ISNULL(PH.Orderkey,'') = '' -- ML
                WHERE WD.Wavekey = @c_Wavekey)
         SET @c_Conso = 'Y'
      ELSE
         SET @c_Conso = 'N'

      IF @c_Conso = 'Y'
      BEGIN
         IF EXISTS(SELECT 1
                   FROM WAVEDETAIL WD (NOLOCK)
                   JOIN PICKHEADER PH (NOLOCK) ON WD.Orderkey = PH.Orderkey
                   WHERE WD.Wavekey = @c_Wavekey)
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38030
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': The wave is not allowed to mix discrete and conso orders. (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
            GOTO QUIT_SP
         END
      END

      IF @c_Conso = 'N'
      BEGIN
         IF NOT EXISTS(SELECT 1
                       FROM WAVE W (NOLOCK)
                       JOIN WAVEDETAIL WD (NOLOCK) ON W.Wavekey = WD.Wavekey
                       JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
                       LEFT JOIN PACKHEADER PH (NOLOCK) ON WD.Orderkey = PH.Orderkey
                       WHERE W.Wavekey = @c_Wavekey
                       AND PH.Orderkey IS NULL)
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38040
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': No pick record found to generate pack. (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
            GOTO QUIT_SP
         END
      END

      IF @c_Conso = 'Y'
      BEGIN
         IF NOT EXISTS(SELECT 1
                       FROM WAVE W (NOLOCK)
                       JOIN WAVEDETAIL WD (NOLOCK) ON W.Wavekey = WD.Wavekey
                       JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
                       JOIN LOADPLANDETAIL LPD (NOLOCK) ON O.Orderkey = LPD.Orderkey
                       LEFT JOIN PACKHEADER PH (NOLOCK) ON LPD.Loadkey = PH.Loadkey AND (PH.Orderkey IS NULL OR PH.Orderkey = '')
                       WHERE W.Wavekey = @c_Wavekey
                       AND PH.Loadkey IS NULL)
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38050
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': No pick record found to generate pack. (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
            GOTO QUIT_SP
         END
      END

   END

   IF (@n_continue = 1 OR @n_continue = 2) AND @c_Conso = 'N'
   BEGIN
      DECLARE CUR_DISCPACK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT WD.Orderkey, O.Storerkey
         FROM WAVE W (NOLOCK)
         JOIN WAVEDETAIL WD (NOLOCK) ON W.Wavekey = WD.Wavekey
         JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
         LEFT JOIN PACKHEADER PH (NOLOCK) ON WD.Orderkey = PH.Orderkey
         WHERE W.Wavekey = @c_Wavekey
         AND PH.Orderkey IS NULL

      OPEN CUR_DISCPACK

      FETCH NEXT FROM CUR_DISCPACK INTO @c_Orderkey, @c_Storerkey

      WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)
      BEGIN
        EXEC isp_CreatePickSlip
             @c_Orderkey             = @c_Orderkey
            ,@c_Loadkey              = ''
            ,@c_Wavekey              = ''
            ,@c_PickslipType         = '8'
            ,@c_ConsolidateByLoad    = 'N'
            ,@c_Refkeylookup         = 'N'
            ,@c_LinkPickSlipToPick   = 'N'
            ,@c_AutoScanIn           = 'Y'
            ,@b_Success              = @b_Success OUTPUT
            ,@n_Err                  = @n_Err     OUTPUT
            ,@c_ErrMsg               = @c_ErrMsg  OUTPUT

         IF @b_Success <> 1
            SET @n_continue = 3

         SELECT TOP 1 @c_PickslipNo = PH.Pickheaderkey
         FROM PICKHEADER PH (NOLOCK)
         JOIN ORDERS O (NOLOCK) ON PH.Orderkey = O.Orderkey
         WHERE O.Orderkey = @c_Orderkey

         INSERT INTO PACKHEADER (OrderKey, Loadkey, StorerKey, PickSlipNo, STATUS, PackStatus)
         SELECT O.OrderKey, O.LoadKey, O.Storerkey, @c_PickSlipNo, '9', '9'
         FROM  PICKHEADER PH (NOLOCK)
         JOIN  ORDERS O (NOLOCK) ON (PH.Orderkey = O.Orderkey)
         WHERE PH.PickHeaderKey = @c_PickSlipNo

         SET @n_err = @@ERROR

         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38060
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Error On PACKHEADER Table. (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         END

         SET @c_LabelNo = ''
         SET @n_CartonNo = 0

         DECLARE CUR_PICKDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT RTRIM(X.SKU), SUM(X.Qty), X.CaseCnt
            FROM (
               SELECT P.SKU, P.Qty, PACK.CaseCnt
               FROM PICKDETAIL P (NOLOCK)
               JOIN SKU (NOLOCK) ON P.Storerkey=SKU.StorerKey and P.Sku=SKU.Sku
               JOIN PACK(NOLOCK) ON SKU.PACKKey=PACK.PackKey
               JOIN LOTATTRIBUTE LA (NOLOCK) ON P.Lot = LA.Lot
               WHERE P.OrderKey = @c_OrderKey
               AND P.Qty > 0
            ) X
            GROUP BY X.SKU, X.CaseCnt
            ORDER BY 1

         OPEN CUR_PICKDETAIL

         FETCH NEXT FROM CUR_PICKDETAIL INTO @c_SKU, @n_Qty, @n_CaseCnt

         WHILE @@FETCH_STATUS<>-1 AND @n_continue IN(1,2)
         BEGIN
            WHILE @n_Qty > 0
            BEGIN
               SET @n_CtnQty      = CASE WHEN @n_CaseCnt>0 AND @n_Qty>=@n_CaseCnt THEN @n_CaseCnt ELSE @n_Qty END
               SET @n_CartonNo    = @n_CartonNo + 1
               SET @n_LabelLineNo = @n_LabelLineNo + 1  
               SET @c_LabelLineNo = RIGHT('00000' + RTRIM(CAST(@n_LabelLineNo AS NVARCHAR)),5)  

               EXEC isp_GenUCCLabelNo_Std
                  @cPickslipNo  = @c_Pickslipno,
                  @nCartonNo    = @n_CartonNo,
                  @cLabelNo     = @c_LabelNo OUTPUT,
                  @b_success    = @b_Success OUTPUT,
                  @n_err        = @n_err OUTPUT,
                  @c_errmsg     = @c_errmsg OUTPUT

               IF @b_Success <> 1
               BEGIN
                  SET @n_continue = 3
                  BREAK
               END

               INSERT INTO PACKDETAIL
                  (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, AddWho, AddDate, EditWho, EditDate)
               VALUES
                  (@c_PickSlipNo, @n_CartonNo, @c_LabelNo, @c_LabelLineNo, @c_StorerKey, @c_SKU,
                   @n_CtnQty, sUser_sName(), GETDATE(), sUser_sName(), GETDATE())

               SET @n_err = @@ERROR

               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38070
                  SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Error On PACKDETAIL Table. (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
               END

               INSERT INTO PACKINFO 
                  (Pickslipno, CartonNo, Qty)
   	  	      VALUES 
                  (@c_PickslipNo, @n_CartonNo, @n_CtnQty)

               SET @n_err = @@ERROR

               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38071
                  SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Error On PACKINFO Table. (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
               END

               SET @n_Qty = @n_Qty - @n_CtnQty
            END

            FETCH NEXT FROM CUR_PICKDETAIL INTO @c_SKU, @n_Qty, @n_CaseCnt
         END
         CLOSE CUR_PICKDETAIL
         DEALLOCATE CUR_PICKDETAIL

         UPDATE PICKINGINFO WITH (ROWLOCK)
         SET ScanOutDate = GETDATE()
         WHERE PickslipNo = @c_PickslipNo
         AND (ScanOutDate IS NULL
             OR ScanOutDate = '1900-01-01')

         SET @n_err = @@ERROR

         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38080
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Error On PICKINGINFO Table. (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         END

         UPDATE PACKHEADER WITH (ROWLOCK)
         SET Status = '9'
         WHERE Pickslipno = @c_Pickslipno

         SET @n_err = @@ERROR

         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38090
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Error On PACKHEADER Table. (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         END

         FETCH NEXT FROM CUR_DISCPACK INTO @c_Orderkey, @c_Storerkey
      END
      CLOSE CUR_DISCPACK
      DEALLOCATE CUR_DISCPACK
   END

   IF (@n_continue = 1 OR @n_continue = 2) AND @c_Conso = 'Y'
   BEGIN
      DECLARE CUR_CONSOCPACK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT DISTINCT LPD.Loadkey, O.Storerkey
         FROM WAVE W (NOLOCK)
         JOIN WAVEDETAIL WD (NOLOCK) ON W.Wavekey = WD.Wavekey
         JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
         JOIN LOADPLANDETAIL LPD (NOLOCK) ON O.Orderkey = LPD.Orderkey
         LEFT JOIN PACKHEADER PH (NOLOCK) ON LPD.Loadkey = PH.Loadkey AND (PH.Orderkey IS NULL OR PH.Orderkey = '')
         WHERE W.Wavekey = @c_Wavekey
         AND PH.Loadkey IS NULL

      OPEN CUR_CONSOCPACK

      FETCH NEXT FROM CUR_CONSOCPACK INTO @c_Loadkey, @c_Storerkey

      WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)
      BEGIN
        EXEC isp_CreatePickSlip
             @c_Orderkey             = ''
            ,@c_Loadkey              = @c_Loadkey
            ,@c_Wavekey              = ''
            ,@c_PickslipType         = '9'
            ,@c_ConsolidateByLoad    = 'Y'
            ,@c_Refkeylookup         = 'N'
            ,@c_LinkPickSlipToPick   = 'N'
            ,@c_AutoScanIn           = 'Y'
            ,@b_Success              = @b_Success OUTPUT
            ,@n_Err                  = @n_Err     OUTPUT
            ,@c_ErrMsg               = @c_ErrMsg  OUTPUT

         IF @b_Success <> 1
            SET @n_continue = 3

         SELECT TOP 1 @c_PickslipNo = PH.Pickheaderkey
         FROM PICKHEADER PH (NOLOCK)
         JOIN LOADPLAN LP (NOLOCK) ON PH.ExternOrderkey = LP.Loadkey
         WHERE LP.Loadkey = @c_Loadkey
         AND (PH.Orderkey IS NULL OR PH.Orderkey = '')

         INSERT INTO PACKHEADER (OrderKey, Loadkey, StorerKey, PickSlipNo, STATUS, PackStatus)
         SELECT TOP 1 O.OrderKey, O.LoadKey, O.Storerkey, @c_PickSlipNo, '9', '9'
         FROM  PICKHEADER PH (NOLOCK)
         JOIN  LOADPLANDETAIL LPD (NOLOCK) ON PH.ExternOrderkey = LPD.Loadkey
         JOIN  ORDERS O (NOLOCK) ON LPD.Orderkey = O.Orderkey
         WHERE PH.PickHeaderKey = @c_PickSlipNo

         SET @n_err = @@ERROR

         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38100
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Error On PACKHEADER Table. (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         END

         SET @c_LabelNo = ''
         SET @n_CartonNo = 0

         DECLARE CUR_PICKDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT RTRIM(X.SKU), SUM(X.Qty), X.CaseCnt
            FROM (
               SELECT P.SKU, P.Qty, PACK.CaseCnt
               FROM PICKDETAIL P (NOLOCK)
               JOIN LOADPLANDETAIL LPD (NOLOCK) ON P.Orderkey = LPD.Orderkey
               JOIN SKU (NOLOCK) ON P.Storerkey=SKU.StorerKey and P.Sku=SKU.Sku
               JOIN PACK(NOLOCK) ON SKU.PACKKey=PACK.PackKey
               JOIN LOTATTRIBUTE LA (NOLOCK) ON P.Lot = LA.Lot
               WHERE LPD.Loadkey = @c_Loadkey
               AND P.Qty > 0
            ) X
            GROUP BY X.SKU, X.CaseCnt
            ORDER BY 1

         OPEN CUR_PICKDETAIL

         FETCH NEXT FROM CUR_PICKDETAIL INTO @c_SKU, @n_Qty, @n_CaseCnt

         WHILE @@FETCH_STATUS<>-1 AND @n_continue IN(1,2)
         BEGIN
            WHILE @n_Qty > 0
            BEGIN
               SET @n_CtnQty      = CASE WHEN @n_CaseCnt>0 AND @n_Qty>=@n_CaseCnt THEN @n_CaseCnt ELSE @n_Qty END
               SET @n_CartonNo    = @n_CartonNo + 1
               SET @n_LabelLineNo = @n_LabelLineNo + 1  
               SET @c_LabelLineNo = RIGHT('00000' + RTRIM(CAST(@n_LabelLineNo AS NVARCHAR)),5) 

               EXEC isp_GenUCCLabelNo_Std
                  @cPickslipNo  = @c_Pickslipno,
                  @nCartonNo    = @n_CartonNo,
                  @cLabelNo     = @c_LabelNo OUTPUT,
                  @b_success    = @b_Success OUTPUT,
                  @n_err        = @n_err OUTPUT,
                  @c_errmsg     = @c_errmsg OUTPUT

               IF @b_Success <> 1
               BEGIN
                  SET @n_continue = 3
                  BREAK
               END

               INSERT INTO PACKDETAIL
                  (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, AddWho, AddDate, EditWho, EditDate)
               VALUES
                  (@c_PickSlipNo, @n_CartonNo, @c_LabelNo, @c_LabelLineNo, @c_StorerKey, @c_SKU,
                   @n_CtnQty, sUser_sName(), GETDATE(), sUser_sName(), GETDATE())

               SET @n_err = @@ERROR

               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38110
                  SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Error On PACKDETAIL Table. (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
               END

               INSERT INTO PACKINFO 
                  (Pickslipno, CartonNo, Qty)
   	  	      VALUES 
                  (@c_PickslipNo, @n_CartonNo, @n_CtnQty)

               SET @n_err = @@ERROR

               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38111
                  SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Error On PACKINFO Table. (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
               END

               SET @n_Qty = @n_Qty - @n_CtnQty
            END

            FETCH NEXT FROM CUR_PICKDETAIL INTO @c_SKU, @n_Qty, @n_CaseCnt
         END
         CLOSE CUR_PICKDETAIL
         DEALLOCATE CUR_PICKDETAIL

         UPDATE PICKINGINFO WITH (ROWLOCK)
         SET ScanOutDate = GETDATE()
         WHERE PickslipNo = @c_PickslipNo
         AND (ScanOutDate IS NULL
             OR ScanOutDate = '1900-01-01')

         SET @n_err = @@ERROR

         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38120
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Error On PICKINGINFO Table. (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         END

         UPDATE PACKHEADER WITH (ROWLOCK)
         SET Status = '9'
         WHERE Pickslipno = @c_Pickslipno

         SET @n_err = @@ERROR

         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38130
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Error On PACKHEADER Table. (mspWAVPK02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         END

         FETCH NEXT FROM CUR_CONSOCPACK INTO @c_Orderkey, @c_Storerkey
      END
      CLOSE CUR_CONSOCPACK
      DEALLOCATE CUR_CONSOCPACK
   END

   QUIT_SP:

   IF @n_Continue=3  -- Error Occured - Process AND Return
   BEGIN
      SELECT @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'mspWAVPK02'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
      --RAISERROR @nErr @cErrmsg
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[mspWAVPK02] TO [NSQL]
GO
