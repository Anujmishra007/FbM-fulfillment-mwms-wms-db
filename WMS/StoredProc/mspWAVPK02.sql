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
/* 15-Sep-2025  AYD      1.0  Created procedure - ispWAVPK19            */
/* 30-Mar-2026  AYD      1.1  Rename to mspWAVPK02 (was ispWAVPK19)     */
/* 26-Nov-2025  API      1.2  Generate custom SSCCC as customer request */
/* 29-Apr-2026  TKLIM    1.3  FCR-12721 - Generate TL2 by LabelNo (TK01)*/
/* 05-Jun-2026  TKLIM    1.4  UWP-58334 - GenSSCC based on config (TK02)*/
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

   DECLARE @c_Storerkey          NVARCHAR(15)
         , @c_Sku                NVARCHAR(20)
         , @n_Qty                INT
         , @n_CaseCnt            INT
         , @c_LottableNum        NVARCHAR(2)
         , @n_CtnQty             INT
         , @c_PickslipNo         NVARCHAR(10)
         , @n_CartonNo           INT
         , @c_LabelNo            NVARCHAR(20)
         , @n_LabelLineNo        INT
         , @c_LabelLineNo        NVARCHAR(5)
         , @c_Orderkey           NVARCHAR(10)
         , @c_Loadkey            NVARCHAR(10)
         , @c_Conso              NVARCHAR(10)
         , @c_CustomSSCC         NVARCHAR(30) --API178
         , @c_CustomSSCCPrefix   NVARCHAR(30)   = ''           --(TK02)
     
   DECLARE @c_Facility           NVARCHAR(5)    = ''           --(TK01)
         , @c_WAVGENPACK_Opt5    NVARCHAR(1000) = ''           --(TK01)
         , @c_GenTL2ByLabelNo    NVARCHAR(MAX)  = ''           --(TK01)
         , @c_Transmitlogkey     NVARCHAR(10)   = ''           --(TK01)
         , @c_TableName          NVARCHAR(30)   = 'WSSOMAAC'   --(TK01)
         , @c_TLOrderKey         NVARCHAR(10)   = ''           --(TK01)
         , @c_TLLabelNo          NVARCHAR(20)   = ''           --(TK01)
         , @c_TLStorerkey        NVARCHAR(15)   = ''           --(TK01)

   DECLARE @n_Continue   INT
         , @n_StartTCnt  INT
         , @b_Debug      INT

   SET @b_Debug = @n_Err

   SELECT @n_Continue=1, @n_StartTCnt=@@TRANCOUNT, @n_Err = 0, @c_ErrMsg = '', @b_success = 1

   IF @@TRANCOUNT = 0
      BEGIN TRAN

   --(TK01)
   CREATE TABLE #TEMP_TLOG2
   (
        RowID      INT IDENTITY(1, 1) PRIMARY KEY
      , Orderkey   NVARCHAR(10)
      , LabelNo    NVARCHAR(20)
      , Storerkey  NVARCHAR(15)
   )


   --Validation
   IF @n_continue IN(1,2)
   BEGIN

      --(TK01)
      SELECT TOP 1 @c_Facility = OH.Facility, @c_Storerkey = OH.Storerkey
      FROM WAVEDETAIL WD (NOLOCK)
      JOIN ORDERS OH (NOLOCK) ON OH.OrderKey = WD.OrderKey
      WHERE WD.Wavekey = @c_WaveKey
      
      --(TK01)
      SELECT @c_WAVGENPACK_Opt5 = SC.Option5
      FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey,'','WAVGENPACKFROMPICKED_SP') AS SC

      SET @c_GenTL2ByLabelNo = dbo.fnc_GetParamValueFromString('@c_GenTL2ByLabelNo', @c_WAVGENPACK_Opt5, @c_GenTL2ByLabelNo)     --(TK01)
      SET @c_CustomSSCCPrefix = dbo.fnc_GetParamValueFromString('@c_CustomSSCCPrefix', @c_WAVGENPACK_Opt5, @c_CustomSSCCPrefix)  --(TK02)

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

      IF @b_Debug > 0
      BEGIN
         SELECT '==> Initial'
         , @c_Conso  [@c_Conso]
         , @c_WAVGENPACK_Opt5  [@c_WAVGENPACK_Opt5]
         , @c_GenTL2ByLabelNo  [@c_GenTL2ByLabelNo]

      END


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
         SET @c_CustomSSCC  = '' --API178

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

               --(TK02) - Remove Hardcoded SSCC Prefix, Generate SSCC based on config
               IF @c_CustomSSCCPrefix <> ''
               BEGIN
                  --SET @c_CustomSSCC = '0000035051' + @c_LabelNo --API178
                  SET @c_CustomSSCC = @c_CustomSSCCPrefix + @c_LabelNo --API178
               END
           
               INSERT INTO PACKDETAIL
                  (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, AddWho, AddDate, EditWho, EditDate, RefNo2)  --API178
               VALUES
                  (@c_PickSlipNo, @n_CartonNo, @c_LabelNo, @c_LabelLineNo, @c_StorerKey, @c_SKU,
                   @n_CtnQty, sUser_sName(), GETDATE(), sUser_sName(), GETDATE(), @c_CustomSSCC) --API178

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

         --(TK01)
         IF @b_Debug > 2
         BEGIN
            SELECT '==> PACKHEADER',* FROM PACKHEADER WHERE PickSlipNo = @c_PickSlipNo
            SELECT '==> PACKDETAIL',* FROM PACKDETAIL WHERE PickSlipNo = @c_PickSlipNo
            SELECT '==> PACKINFO  ',* FROM PACKINFO WHERE PickSlipNo = @c_PickSlipNo
         END

         --(TK01)
         IF @c_GenTL2ByLabelNo = 'Y'
         BEGIN 

            INSERT INTO #TEMP_TLOG2 (Orderkey, LabelNo, Storerkey)
            SELECT PH.Orderkey, PD.LabelNo, PH.Storerkey
            FROM PACKHEADER PH (NOLOCK)
            JOIN PACKDETAIL PD (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
            WHERE PH.PickSlipNo = @c_Pickslipno

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
         SET @c_CustomSSCC = '' --API178

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

               --(TK02) - Remove Hardcoded SSCC Prefix, Generate SSCC based on config
               IF @c_CustomSSCCPrefix <> ''
               BEGIN
                  --SET @c_CustomSSCC = '0000035051' + @c_LabelNo --API178
                  SET @c_CustomSSCC = @c_CustomSSCCPrefix + @c_LabelNo --API178
               END

               INSERT INTO PACKDETAIL
                  (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, AddWho, AddDate, EditWho, EditDate, RefNo2) --API178
               VALUES
                  (@c_PickSlipNo, @n_CartonNo, @c_LabelNo, @c_LabelLineNo, @c_StorerKey, @c_SKU,
                   @n_CtnQty, sUser_sName(), GETDATE(), sUser_sName(), GETDATE(), @c_CustomSSCC) --API178

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

         --(TK01)
         IF @b_Debug > 2
         BEGIN
            SELECT '==> PACKHEADER',* FROM PACKHEADER WHERE PickSlipNo = @c_PickSlipNo
            SELECT '==> PACKDETAIL',* FROM PACKDETAIL WHERE PickSlipNo = @c_PickSlipNo
            SELECT '==> PACKINFO  ',* FROM PACKINFO WHERE PickSlipNo = @c_PickSlipNo
         END

         --(TK01)
         IF @c_GenTL2ByLabelNo = 'Y'
         BEGIN 

            INSERT INTO #TEMP_TLOG2 (Orderkey, LabelNo, Storerkey)
            SELECT PH.Orderkey, PD.LabelNo, PH.Storerkey
            FROM PACKHEADER PH (NOLOCK)
            JOIN PACKDETAIL PD (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
            WHERE PH.PickSlipNo = @c_Pickslipno

         END

         FETCH NEXT FROM CUR_CONSOCPACK INTO @c_Loadkey, @c_Storerkey
      END
      CLOSE CUR_CONSOCPACK
      DEALLOCATE CUR_CONSOCPACK
   END

   --(TK01) - Start
   IF @c_GenTL2ByLabelNo = 'Y' AND @n_continue IN (1,2)
   BEGIN
      SET @b_success = 1  

      DECLARE CUR_TLOG2 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Orderkey, LabelNo, Storerkey
      FROM #TEMP_TLOG2
      ORDER BY RowID ASC

      OPEN CUR_TLOG2
      FETCH NEXT FROM CUR_TLOG2 INTO @c_TLOrderkey, @c_TLLabelNo, @c_TLStorerkey

      WHILE @@FETCH_STATUS <> -1 AND @n_continue IN (1,2)
      BEGIN

         EXECUTE nspg_getkey  
            @KeyName     = 'TransmitlogKey2'  
         ,  @fieldlength = 10  
         ,  @keystring   = @c_Transmitlogkey OUTPUT  
         ,  @b_success   = @b_success        OUTPUT  
         ,  @n_err       = @n_err            OUTPUT  
         ,  @c_errmsg    = @c_errmsg         OUTPUT
                 
         IF @b_success = 0
         BEGIN  
            SET @n_Continue = 3
         END 
         
         IF @n_Continue = 1
         BEGIN
            IF NOT EXISTS (SELECT 1 FROM TransmitLog2 (NOLOCK) 
                           WHERE TableName = @c_Tablename 
                           AND Key1 = @c_TLOrderKey 
                           AND Key2 = @c_TLLabelNo 
                           AND Key3 = @c_TLStorerkey
                           )  
            BEGIN  

               IF @b_Debug > 0
               BEGIN
                  SELECT '==> INSERT TL2'
                        , @c_Transmitlogkey  [@c_Transmitlogkey]
                        , @c_Tablename       [@c_Tablename]
                        , @c_TLOrderKey      [@c_TLOrderKey]
                        , @c_TLLabelNo       [@c_TLLabelNo]
                        , @c_TLStorerkey     [@c_TLStorerkey]
               END

               INSERT INTO Transmitlog2 (transmitlogkey, tablename, key1, key2, key3, transmitflag)  
               VALUES (@c_Transmitlogkey, @c_Tablename, @c_TLOrderKey, @c_TLLabelNo, @c_TLStorerkey, '0')  

               SET @n_Err = @@ERROR

               IF @n_Err > 0
               BEGIN
                  SET @n_Continue = 3
               END

               IF @n_Continue = 1
               BEGIN
                  EXEC [dbo].[isp_QCmd_WSTransmitLogInsertAlert]   
                        @c_QCmdClass        = ''      
                     , @c_FrmTransmitlogKey= @c_Transmitlogkey 
                     , @c_ToTransmitlogKey = @c_Transmitlogkey                  
                     , @b_Debug            = 0              
                     , @b_Success          = @b_Success  OUTPUT                        
                     , @n_Err              = @n_Err      OUTPUT    
                     , @c_ErrMsg           = @c_ErrMsg   OUTPUT    
                     , @n_PortLimit        = 0   

                  IF @n_Err <> 0  
                  BEGIN
                     SET @n_Continue = 3
                  END
               END
            END   --IF not exist in TransmitLog2
            ELSE
            BEGIN
               IF @b_Debug > 0
               BEGIN
                  SELECT '==> TL2 Exist', @c_TLOrderKey [@c_TLOrderKey], @c_TLLabelNo [@c_TLLabelNo], @c_TLStorerkey [@c_TLStorerkey]
               END
            END
         END



         FETCH NEXT FROM CUR_TLOG2 INTO @c_TLOrderkey, @c_TLLabelNo, @c_TLStorerkey
      END
      CLOSE CUR_TLOG2
      DEALLOCATE CUR_TLOG2

   END   --IF (@n_continue = 1 OR @n_continue = 2)
   --(TK01) - End
   
   QUIT_SP:

   IF CURSOR_STATUS('LOCAL', 'CUR_DISCPACK') IN (0 , 1)
   BEGIN
      CLOSE CUR_DISCPACK
      DEALLOCATE CUR_DISCPACK
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_CONSOCPACK') IN (0 , 1)
   BEGIN
      CLOSE CUR_CONSOCPACK
      DEALLOCATE CUR_CONSOCPACK
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_TLOG2') IN (0 , 1)
   BEGIN
      CLOSE CUR_TLOG2
      DEALLOCATE CUR_TLOG2
   END

   IF OBJECT_ID('tempdb..#TEMP_TLOG2') IS NOT NULL
      DROP TABLE #TEMP_TLOG2


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
