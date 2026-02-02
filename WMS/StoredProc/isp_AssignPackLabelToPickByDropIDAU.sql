SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc : isp_AssignPackLabelToPickByDropIDAU                    */
/* Creation Date: 2025-07-30                                            */
/* Copyright: Maersk                                                    */
/* Written by: SYC067                                                   */
/*                                                                      */
/* Purpose: Assign pack label# to picketail by DropID                   */
/*                                                                      */
/* Called By: Confirm pick                                              */
/*                                                                      */
/* Version: 7.0                                                        */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver.  Purposes                                  */
/* 2025-07-30  SYC067   1.0   FCR-7074 Copy from                        */
/*                            isp_AssignPackLabelToOrderByLoad, adding  */
/*                            DropID to only assign by DropID           */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_AssignPackLabelToPickByDropIDAU]
(@c_Pickslipno NVARCHAR(10),   --NJOW03
 @c_DropID     NVARCHAR(20),   --SYC067
 @b_Success      INT       OUTPUT,
 @n_err          INT       OUTPUT,
 @c_errmsg       NVARCHAR(250) OUTPUT
)
AS
BEGIN

SET NOCOUNT ON       -- SQL 2005 Standard
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE @n_continue          INT,
        @c_debug             NVARCHAR(1),
        @n_starttcnt         INT,
        @n_cnt               INT

SELECT @c_debug = '0'

SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT, @b_success=0, @n_err=0

DECLARE @c_sku                    NVARCHAR(20),
        @n_packqty                INT,
        @n_pickqty                INT,
        @n_splitqty               INT,
        @c_labelno                NVARCHAR(20),
        @c_pickdetailkey          NVARCHAR(10),
        @c_newpickdetailkey       NVARCHAR(10),
        @c_orderkey               NVARCHAR(10), --NJOW02
        @c_loadkey                NVARCHAR(10),  --NJOW03
        @n_TotPickQty             INT,
        @n_TotPackQty             INT,
        @c_AssignByPackDetailInfo NVARCHAR(30), --NJOW10
        @c_UserDefine01           NVARCHAR(30), --NJOW10
        @c_UserDefine02           NVARCHAR(30), --NJOW10
        @c_UserDefine03           NVARCHAR(30), --NJOW10
        @c_PackDetailInfoKey      BIGINT        --NJOW10

--NJOW08
DECLARE @c_RefNo            NVARCHAR(20),
        @c_RefNo2           NVARCHAR(30),
        @c_UPC              NVARCHAR(30),
        --@c_DropID           NVARCHAR(20),
        @c_LottableValue    NVARCHAR(60),
        @c_GetPickdetCondition NVARCHAR(4000) = ''

--NJOW05
DECLARE @c_AssignPackLabelToOrdCfg NVARCHAR(30),
        @c_storerkey NVARCHAR(15),
        @c_facility NVARCHAR(5),
        @c_option1 NVARCHAR(50),
        @c_option2 NVARCHAR(50),
        @c_option3 NVARCHAR(50),
        @c_option4 NVARCHAR(50),
        @c_option5 NVARCHAR(4000),
        @c_SQL NVARCHAR(2000)

DECLARE  @c_SQLArgument  NVARCHAR(4000)         -- (Wan01)

SET @c_pickdetailkey = ''

IF ISNULL(@c_DropID,'') = '' --SYC067
   SET @n_continue = 3 --SYC067

-- IN00289179
IF @n_continue = 1 OR @n_continue = 2
BEGIN
   SELECT @c_loadkey = Loadkey,
          @c_orderkey = Orderkey
   FROM PACKHEADER WITH (NOLOCK)
   WHERE Pickslipno = @c_Pickslipno

   SET @n_TotPackQty = 0
   SELECT @n_TotPackQty = SUM(PACKDETAIL.Qty)
   FROM PACKDETAIL WITH (NOLOCK)
   WHERE PickSlipNo = @c_PickSlipNo
   AND DropID = @c_DropID --SYC067

   IF ISNULL(RTRIM(@c_orderkey),'') = ''
   BEGIN
      SET @n_TotPickQty = 0
      SELECT @n_TotPickQty = SUM(PICKDETAIL.Qty)
      FROM LOADPLANDETAIL WITH (NOLOCK)
      JOIN PICKDETAIL WITH (NOLOCK) ON LOADPLANDETAIL.Orderkey = PICKDETAIL.Orderkey
      WHERE LOADPLANDETAIL.Loadkey = @c_loadkey
      AND DropID = @c_DropID --SYC067
   END
   ELSE
   BEGIN
      SET @n_TotPickQty = 0
      SELECT @n_TotPickQty = SUM(PICKDETAIL.Qty)
      FROM  PICKDETAIL WITH (NOLOCK)
      WHERE PICKDETAIL.Orderkey = @c_orderkey
      AND DropID = @c_DropID --SYC067
   END

   IF ISNULL(@n_TotPackQty, 0) <> ISNULL(@n_TotPickQty, 0)
   BEGIN
      SELECT @n_continue = 3
      SELECT @n_err = 63334
      SELECT @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Total PackQty ('+ CAST(@n_TotPackQty AS VARCHAR) +
                         ') vs PickQty ('+ CAST(@n_TotPickQty AS VARCHAR) +') Not Tally. (isp_AssignPackLabelToPickByDropIDAU)'
   END
END

--NJOW05
IF @n_continue = 1 OR @n_continue = 2
BEGIN
   IF ISNULL(@c_Orderkey,'') <> ''
   BEGIN
     SELECT @c_Storerkey = Storerkey,
            @c_Facility = Facility
     FROM ORDERS (NOLOCK)
     WHERE Orderkey = @c_Orderkey
   END
   ELSE
   BEGIN
     SELECT TOP 1 @c_Storerkey = Storerkey,
                  @c_Facility = Facility
     FROM ORDERS (NOLOCK)
     WHERE Loadkey = @c_Loadkey
   END

   EXECUTE nspGetRight
      @c_facility,
      @c_StorerKey,
      '',
      'AssignPackLabelToOrdCfg', -- Configkey
      @b_success    OUTPUT,
      @c_AssignPackLabelToOrdCfg OUTPUT,
      @n_err        OUTPUT,
      @c_errmsg     OUTPUT,
      @c_option1 OUTPUT, --ispPKLBLToOrd??
      @c_option2 OUTPUT, --CaseID => Update Pickdetail.CaseID
      @c_option3 OUTPUT, --FullLabelNo
      @c_option4 OUTPUT, --skipstamped
      @c_option5 OUTPUT  --used for multiple settings like @c_var1=test1 @c_var2=test2

   --NJOW08 S
   SELECT @c_GetPickdetCondition = LTRIM(RTRIM(dbo.fnc_GetParamValueFromString('@c_GetPickDetCondition', @c_option5, @c_GetPickdetCondition)))

   IF @c_GetPickdetCondition <> '' AND LEFT(@c_GetPickdetCondition,4) <> 'AND '
      SET @c_GetPickdetCondition = 'AND ' + @c_GetPickdetCondition
   --NJOW08 E

   --NJOW10
   SELECT @c_AssignByPackDetailInfo = LTRIM(RTRIM(dbo.fnc_GetParamValueFromString('@c_AssignByPackDetailInfo', @c_option5, @c_AssignByPackDetailInfo)))

   IF @b_success = 1 AND ISNULL(@c_AssignPackLabelToOrdCfg,'') =  '1' AND ISNULL(@c_Option1,'') <> ''
   BEGIN
      IF EXISTS(SELECT 1 FROM sys.Objects WHERE NAME = @c_Option1 AND TYPE = 'P')
      BEGIN
         SET @c_SQL = 'EXEC ' + @c_Option1 + ' @c_PickSlipno '
                    + ',@b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT '

         EXEC sp_executesql @c_SQL
            , N'@c_Pickslipno NVARCHAR(10)
               , @b_Success INT OUTPUT, @n_Err INT OUTPUT, @c_ErrMsg NVARCHAR(250) OUTPUT'
            , @c_Pickslipno
            , @b_Success         OUTPUT
            , @n_Err             OUTPUT
            , @c_ErrMsg          OUTPUT

         IF @b_Success <> 1
            SELECT @n_Continue = 3
         ELSE
            SELECT @n_Continue = 4 -- run custom sp successful and skip std logic
      END
   END
END

--NJOW03
-- TLTING01
IF (@n_continue = 1 OR @n_continue = 2) AND ISNULL(@c_Option4,'') <> 'SKIPSTAMPED'  --NJOW06
BEGIN
   -- Clear all the dropid(labelno) for re-assign in case of pack status reversal by manual and confirm pack again in future
   IF ISNULL(@c_orderkey,'')='' --NJOW04
   BEGIN
      DECLARE PickDet_cur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PICKDETAIL.Pickdetailkey
            FROM LOADPLANDETAIL WITH (NOLOCK) INNER JOIN PICKDETAIL WITH (NOLOCK) ON LOADPLANDETAIL.Orderkey = PICKDETAIL.Orderkey
        WHERE LOADPLANDETAIL.Loadkey = @c_loadkey
        AND PICKDETAIL.DropID = @c_DropID --SYC067
   END
   ELSE
   BEGIN
      DECLARE PickDet_cur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PICKDETAIL.Pickdetailkey
            FROM  PICKDETAIL WITH (NOLOCK)
        WHERE PICKDETAIL.Orderkey = @c_orderkey
        AND PICKDETAIL.DropID = @c_DropID --SYC067
   END

   OPEN PickDet_cur
   FETCH NEXT FROM PickDet_cur INTO @c_pickdetailkey
   WHILE @@FETCH_STATUS = 0 AND ( @n_continue = 1 OR @n_continue = 2 )
   BEGIN
      UPDATE PICKDETAIL WITH (ROWLOCK)
      SET PICKDETAIL.DropId = CASE WHEN @c_Option2 = 'CaseID' THEN PICKDETAIL.DropId ELSE '' END   --(Wan01)
         ,PICKDETAIL.CaseID = CASE WHEN @c_Option2 = 'CaseID' THEN '' ELSE PICKDETAIL.CaseID END   --(Wan01)
         ,TrafficCop = NULL
      WHERE PICKDETAIL.Pickdetailkey = @c_pickdetailkey
        
      SELECT @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
           SELECT @n_continue = 3
           SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 63330
           SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Pickdetail Table Failed. (isp_AssignPackLabelToPickByDropIDAU)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
      END

      FETCH NEXT FROM PickDet_cur INTO @c_pickdetailkey
   END
   CLOSE PickDet_cur
   DEALLOCATE PickDet_cur
   SET @c_pickdetailkey = ''
END

IF @n_continue = 1 OR @n_continue = 2
BEGIN
  IF ISNULL(@c_Option4,'') = 'SKIPSTAMPED' --NJOW06
  BEGIN
     IF @c_AssignByPackDetailInfo = 'Y'
     BEGIN
       --NJOW10
         DECLARE CUR_PACKDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT PACKDETAIL.Sku,
                   CASE WHEN PACKDETAILINFO.Qty IS NOT NULL THEN PACKDETAILINFO.Qty ELSE PACKDETAIL.Qty END,
                   PACKDETAIL.Labelno,
                   PACKHEADER.Orderkey, --NJOW02
                   PACKDETAIL.RefNo, PACKDETAIL.RefNo2, PACKDETAIL.UPC, PACKDETAIL.DropId, PACKDETAIL.LottableValue,  --NJOW08
                   PACKDETAILINFO.PackDetailInfoKey, PACKDETAILINFO.Userdefine01, PACKDETAILINFO.Userdefine02, PACKDETAILINFO.Userdefine03
            FROM   PACKHEADER (NOLOCK) INNER JOIN PACKDETAIL (NOLOCK) ON PACKHEADER.Pickslipno = PACKDETAIL.Pickslipno
            LEFT JOIN PACKDETAILINFO (NOLOCK) ON PACKHEADER.Pickslipno = PACKDETAILINFO.Pickslipno  AND PACKDETAIL.CartonNo = PACKDETAILINFO.CartonNo
                                              AND PACKDETAIL.LabelLine = PACKDETAILINFO.LabelLine
            WHERE  PACKHEADER.Pickslipno = @c_Pickslipno --NJOW03
            AND    PACKDETAIL.DropID = @c_DropID --SYC067
            AND NOT EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK)
                            WHERE PD.Orderkey = PACKHEADER.Orderkey
                            AND PD.Sku = PACKDETAIL.Sku
                            AND PD.CaseID = CASE WHEN @c_Option2 = 'CaseID' THEN PACKDETAIL.LabelNo ELSE PD.CaseID END
                            AND PD.DropID = CASE WHEN @c_Option2 = 'CaseID' THEN PD.DropID ELSE PACKDETAIL.LabelNo END
                            )
            AND PACKHEADER.Orderkey <> ''
            AND PACKHEADER.Orderkey IS NOT NULL
            UNION ALL   --NJOW07
            SELECT PACKDETAIL.Sku, PACKDETAIL.Qty, PACKDETAIL.Labelno,
                   PACKHEADER.Orderkey, --NJOW02
                   PACKDETAIL.RefNo, PACKDETAIL.RefNo2, PACKDETAIL.UPC, PACKDETAIL.DropId, PACKDETAIL.LottableValue,  --NJOW08
                   PACKDETAILINFO.PackDetailInfoKey, PACKDETAILINFO.Userdefine01, PACKDETAILINFO.Userdefine02, PACKDETAILINFO.Userdefine03
            FROM   PACKHEADER (NOLOCK) INNER JOIN PACKDETAIL (NOLOCK) ON PACKHEADER.Pickslipno = PACKDETAIL.Pickslipno
            LEFT JOIN PACKDETAILINFO (NOLOCK) ON PACKHEADER.Pickslipno = PACKDETAILINFO.Pickslipno  AND PACKDETAIL.CartonNo = PACKDETAILINFO.CartonNo
                                              AND PACKDETAIL.LabelLine = PACKDETAILINFO.LabelLine
            WHERE  PACKHEADER.Pickslipno = @c_Pickslipno --NJOW03
            AND    PACKDETAIL.DropID = @c_DropID --SYC067
            AND NOT EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK)
                            JOIN LOADPLANDETAIL LPD (NOLOCK) ON PD.Orderkey = LPD.Orderkey
                            WHERE LPD.Loadkey = PACKHEADER.Loadkey
                            AND PD.Sku = PACKDETAIL.Sku
                            AND PD.CaseID = CASE WHEN @c_Option2 = 'CaseID' THEN PACKDETAIL.LabelNo ELSE PD.CaseID END
                            AND PD.DropID = CASE WHEN @c_Option2 = 'CaseID' THEN PD.DropID ELSE PACKDETAIL.LabelNo END
                            )
            AND (PACKHEADER.Orderkey = '' OR PACKHEADER.Orderkey IS NULL)
            ORDER BY 1, 3
     END
     ELSE
     BEGIN
         DECLARE CUR_PACKDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT PACKDETAIL.Sku, PACKDETAIL.Qty, PACKDETAIL.Labelno,
                   PACKHEADER.Orderkey, --NJOW02
                   PACKDETAIL.RefNo, PACKDETAIL.RefNo2, PACKDETAIL.UPC, PACKDETAIL.DropId, PACKDETAIL.LottableValue,  --NJOW08
                   NULL, NULL, NULL, NULL --NJOW10
            FROM   PACKHEADER (NOLOCK) INNER JOIN PACKDETAIL (NOLOCK) ON PACKHEADER.Pickslipno = PACKDETAIL.Pickslipno
            WHERE  PACKHEADER.Pickslipno = @c_Pickslipno --NJOW03
            AND    PACKDETAIL.DropID = @c_DropID --SYC067
            AND NOT EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK)
                            WHERE PD.Orderkey = PACKHEADER.Orderkey
                            AND PD.Sku = PACKDETAIL.Sku
                            AND PD.CaseID = CASE WHEN @c_Option2 = 'CaseID' THEN PACKDETAIL.LabelNo ELSE PD.CaseID END
                            AND PD.DropID = CASE WHEN @c_Option2 = 'CaseID' THEN PD.DropID ELSE PACKDETAIL.LabelNo END
                            )
            AND PACKHEADER.Orderkey <> ''
            AND PACKHEADER.Orderkey IS NOT NULL
            UNION ALL   --NJOW07
            SELECT PACKDETAIL.Sku, PACKDETAIL.Qty, PACKDETAIL.Labelno,
                   PACKHEADER.Orderkey, --NJOW02
                   PACKDETAIL.RefNo, PACKDETAIL.RefNo2, PACKDETAIL.UPC, PACKDETAIL.DropId, PACKDETAIL.LottableValue,  --NJOW08
                   NULL, NULL, NULL, NULL --NJOW10
            FROM   PACKHEADER (NOLOCK) INNER JOIN PACKDETAIL (NOLOCK) ON PACKHEADER.Pickslipno = PACKDETAIL.Pickslipno
            WHERE  PACKHEADER.Pickslipno = @c_Pickslipno --NJOW03
            AND    PACKDETAIL.DropID = @c_DropID --SYC067
            AND NOT EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK)
                            JOIN LOADPLANDETAIL LPD (NOLOCK) ON PD.Orderkey = LPD.Orderkey
                            WHERE LPD.Loadkey = PACKHEADER.Loadkey
                 AND PD.Sku = PACKDETAIL.Sku
                            AND PD.CaseID = CASE WHEN @c_Option2 = 'CaseID' THEN PACKDETAIL.LabelNo ELSE PD.CaseID END
                            AND PD.DropID = CASE WHEN @c_Option2 = 'CaseID' THEN PD.DropID ELSE PACKDETAIL.LabelNo END
                            )
            AND (PACKHEADER.Orderkey = '' OR PACKHEADER.Orderkey IS NULL)
            ORDER BY 1, 3
      END
  END
  ELSE
  BEGIN
     IF @c_AssignByPackDetailInfo = 'Y'
     BEGIN
       --NJOW10
         DECLARE CUR_PACKDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PACKDETAIL.Sku,
                CASE WHEN PACKDETAILINFO.Qty IS NOT NULL THEN PACKDETAILINFO.Qty ELSE PACKDETAIL.Qty END,
                PACKDETAIL.Labelno,
                PACKHEADER.Orderkey, --NJOW02
                PACKDETAIL.RefNo, PACKDETAIL.RefNo2, PACKDETAIL.UPC, PACKDETAIL.DropId, PACKDETAIL.LottableValue,  --NJOW08
                PACKDETAILINFO.PackDetailInfoKey, PACKDETAILINFO.Userdefine01, PACKDETAILINFO.Userdefine02, PACKDETAILINFO.Userdefine03
         FROM   PACKHEADER (NOLOCK) INNER JOIN PACKDETAIL (NOLOCK) ON PACKHEADER.Pickslipno = PACKDETAIL.Pickslipno
         LEFT JOIN PACKDETAILINFO (NOLOCK) ON PACKHEADER.Pickslipno = PACKDETAILINFO.Pickslipno  AND PACKDETAIL.CartonNo = PACKDETAILINFO.CartonNo
                                           AND PACKDETAIL.LabelLine = PACKDETAILINFO.LabelLine
         WHERE  PACKHEADER.Pickslipno = @c_Pickslipno --NJOW03
         AND    PACKDETAIL.DropID = @c_DropID --SYC067
         ORDER BY PACKDETAIL.Sku, PACKDETAIL.Labelno, PACKDETAIL.LabelLine
     END
     ELSE
     BEGIN
         DECLARE CUR_PACKDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PACKDETAIL.Sku, PACKDETAIL.Qty, PACKDETAIL.Labelno,
                PACKHEADER.Orderkey, --NJOW02
                PACKDETAIL.RefNo, PACKDETAIL.RefNo2, PACKDETAIL.UPC, PACKDETAIL.DropId, PACKDETAIL.LottableValue,  --NJOW08
                NULL, NULL, NULL, NULL --NJOW10
         FROM   PACKHEADER (NOLOCK) INNER JOIN PACKDETAIL (NOLOCK) ON PACKHEADER.Pickslipno = PACKDETAIL.Pickslipno
         WHERE  PACKHEADER.Pickslipno = @c_Pickslipno --NJOW03
         AND    PACKDETAIL.DropID = @c_DropID --SYC067
         ORDER BY PACKDETAIL.Sku, PACKDETAIL.Labelno
      END
   END

   OPEN CUR_PACKDET

   FETCH NEXT FROM CUR_PACKDET INTO @c_sku, @n_packqty, @c_labelno, @c_orderkey, --NJOW02
                                    @c_RefNo, @c_RefNo2, @c_UPC, @c_DropID, @c_LottableValue,  --NJOW08
                                    @c_PackDetailInfoKey, @c_UserDefine01,  @c_UserDefine02, @c_UserDefine03  --NJOW10

   WHILE @@FETCH_STATUS <> -1
   BEGIN
     SELECT @c_pickdetailkey = ''
      WHILE @n_packqty > 0
      BEGIN
         --(Wan01) - START
         IF @c_OPtion3 <> 'FullLabelNo'
         BEGIN
            --NJOW01
            IF LEN(LTRIM(RTRIM(@c_labelno))) > 18
            BEGIN
               IF LEFT(LTRIM(@c_labelno),2) = '00'
               BEGIN
                  SET @c_labelno = RIGHT(LTRIM(RTRIM(@c_labelno)),18)
               END
               --ELSE                                                      --SOS319000
               --SET @c_labelno = LEFT(LTRIM(RTRIM(@c_labelno)),18)  --SOS319000
            END
         END

         SET @n_cnt = 0
         SET @c_SQL = N'SELECT TOP 1 @n_cnt = 1'
                    + ',@n_pickqty = PICKDETAIL.Qty'
                    + ',@c_pickdetailkey = PICKDETAIL.Pickdetailkey'
                    + ' FROM PICKDETAIL WITH (NOLOCK)'
                    + CASE WHEN @c_GetPickdetCondition <> ''
                           THEN ' JOIN ORDERS WITH (NOLOCK) ON PICKDETAIL.Orderkey = ORDERS.Orderkey
                                  JOIN LOTATTRIBUTE WITH (NOLOCK) ON PICKDETAIL.Lot = LOTATTRIBUTE.Lot'
                           ELSE ''
                           END  --NJOW08
                    + CASE WHEN ISNULL(@c_orderkey,'')=''
                           THEN ' JOIN LOADPLANDETAIL WITH (NOLOCK) ON LOADPLANDETAIL.Orderkey = PICKDETAIL.Orderkey'
                           ELSE ''
                           END
                    + CASE WHEN ISNULL(@c_orderkey,'')=''
                           THEN ' WHERE LOADPLANDETAIL.Loadkey = @c_loadkey'
                           ELSE ' WHERE PICKDETAIL.Orderkey = @c_orderkey'
                           END
                    + ' AND PICKDETAIL.Sku = @c_sku'
                    + ' AND PICKDETAIL.storerkey = @c_storerkey'  -- (james01)
                    + ' AND PICKDETAIL.DropID = @c_DropID'
                    + CASE WHEN @c_Option2 = 'CaseID'
                           THEN ' AND (PICKDETAIL.CaseID = '''' OR PICKDETAIL.CaseID IS NULL)'
                           ELSE ' AND (PICKDETAIL.Dropid = '''' OR PICKDETAIL.Dropid IS NULL)'
                           END
                    + ' AND PICKDETAIL.Pickdetailkey > @c_pickdetailkey '
                    + @c_GetPickdetCondition  --NJOW08
                    + ' ORDER BY PICKDETAIL.Pickdetailkey'

         SET @c_SQLArgument = N'@n_cnt               INT            OUTPUT'
                            + ',@n_pickqty           INT            OUTPUT'
                            + ',@c_PickDetailKey     NVARCHAR(10)   OUTPUT'
                            + ',@c_loadkey           NVARCHAR(10)'
                            + ',@c_orderkey          NVARCHAR(10)'
                            + ',@c_sku               NVARCHAR(20)'
                            + ',@c_StorerKey         NVARCHAR(15)'
                            + ',@c_RefNo             NVARCHAR(20)'  --NJOW08
                            + ',@c_RefNo2            NVARCHAR(30)'
                            + ',@c_UPC               NVARCHAR(30)'
                            + ',@c_DropID            NVARCHAR(20)'
                            + ',@c_LottableValue     NVARCHAR(60)'
                            + ',@c_LabelNo           NVARCHAR(20)' --NJOW09
                            + ',@c_PackDetailInfoKey BIGINT' --NJOW10
                            + ',@c_Userdefine01      NVARCHAR(30)' --NJOW10
                            + ',@c_Userdefine02      NVARCHAR(30)' --NJOW10
                            + ',@c_Userdefine03      NVARCHAR(30)' --NJOW10

         EXEC sp_executesql @c_SQL
               ,  @c_SQLArgument
               ,  @n_Cnt            OUTPUT
               ,  @n_pickqty        OUTPUT
               ,  @c_PickDetailKey  OUTPUT
               ,  @c_loadkey
               ,  @c_orderkey
               ,  @c_sku
               ,  @c_StorerKey
               ,  @c_RefNo  --NJOW08
               ,  @c_RefNo2
               ,  @c_UPC
               ,  @c_DropID
               ,  @c_LottableValue
               ,  @c_labelno  --NJOW09
               ,  @c_PackDetailInfoKey --NJOW10
               ,  @c_UserDefine01 --NJOW10
               ,  @c_UserDefine02  --NJOW10
               ,  @c_UserDefine03  --NJOW10


         IF @n_cnt = 0
            BREAK

         IF @n_pickqty <= @n_packqty
         BEGIN
            UPDATE PICKDETAIL WITH (ROWLOCK)
            SET PICKDETAIL.DropId = CASE WHEN @c_Option2 = 'CaseID' THEN PICKDETAIL.DropId ELSE @c_labelno END   --(Wan01)
               ,PICKDETAIL.CaseID = CASE WHEN @c_Option2 = 'CaseID' THEN @c_labelno ELSE PICKDETAIL.CaseID END   --(Wan01)
               ,TrafficCop = NULL
            WHERE Pickdetailkey = @c_pickdetailkey
            SELECT @n_err = @@ERROR
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 63331
               SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Pickdetail Table Failed. (isp_AssignPackLabelToPickByDropIDAU)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
               BREAK
            END
            SELECT @n_packqty = @n_packqty - @n_pickqty
         END
         ELSE
         BEGIN  -- pickqty > packqty
             SELECT @n_splitqty = @n_pickqty - @n_packqty
             EXECUTE nspg_GetKey
            'PICKDETAILKEY',
            10,
            @c_newpickdetailkey OUTPUT,
            @b_success OUTPUT,
            @n_err OUTPUT,
            @c_errmsg OUTPUT
            IF NOT @b_success = 1
            BEGIN
               SELECT @n_continue = 3
               BREAK
            END

             INSERT PICKDETAIL
                   (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot,
                    Storerkey, Sku, AltSku, UOM, UOMQty, Qty, QtyMoved, Status,
                    DropID, Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                    ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod,
                    WaveKey, EffectiveDate, OptimizeCop, ShipFlag, PickSlipNo, Channel_ID    -- ZG01
                  , TaskDetailKey                                                --(Wan02)
                   )
            SELECT @c_newpickdetailkey
                 , CASE WHEN @c_Option2 = 'CaseID' THEN '' ELSE PICKDETAIL.CaseID END                             --(Wan01)
                 , PickHeaderKey, OrderKey, OrderLineNumber, Lot,
                   Storerkey, Sku, AltSku, UOM, CASE UOM WHEN '6' THEN @n_splitqty ELSE UOMQty END , @n_splitqty, QtyMoved, Status,
                   CASE WHEN @c_Option2 = 'CaseID' THEN PICKDETAIL.DropId ELSE '' END                             --(Wan01)
                 , Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                   ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod,
                   WaveKey, EffectiveDate, '9', ShipFlag, PickSlipNo, Channel_ID             -- ZG01
                 , TaskDetailKey                                                --(Wan02)
            FROM PICKDETAIL (NOLOCK)
            WHERE PickdetailKey = @c_pickdetailkey

            SELECT @n_err = @@ERROR
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
              SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 63332
                SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Pickdetail Table Failed. (isp_AssignPackLabelToPickByDropIDAU)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
               BREAK
            END

            UPDATE PICKDETAIL WITH (ROWLOCK)
            SET PICKDETAIL.DropId = CASE WHEN @c_Option2 = 'CaseID' THEN PICKDETAIL.DropId ELSE @c_labelno END   --(Wan01)
               ,PICKDETAIL.CaseID = CASE WHEN @c_Option2 = 'CaseID' THEN @c_labelno ELSE PICKDETAIL.CaseID END   --(Wan01)
               ,Qty = @n_packqty
               ,UOMQTY = CASE UOM WHEN '6' THEN @n_packqty ELSE UOMQty END
               ,TrafficCop = NULL
             WHERE Pickdetailkey = @c_pickdetailkey
             SELECT @n_err = @@ERROR
             IF @n_err <> 0
             BEGIN
                SELECT @n_continue = 3
                SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 63333
                SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Pickdetail Table Failed. (isp_AssignPackLabelToPickByDropIDAU)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
                BREAK
             END

            SELECT @n_packqty = 0
         END
      END -- While packqty > 0
     FETCH NEXT FROM CUR_PACKDET INTO @c_sku, @n_packqty, @c_labelno, @c_orderkey, --NJOW02
                                      @c_RefNo, @c_RefNo2, @c_UPC, @c_DropID, @c_LottableValue,  --NJOW08
                                      @c_PackDetailInfoKey, @c_UserDefine01,  @c_UserDefine02, @c_UserDefine03  --NJOW10
   END -- Cursor While
   DEALLOCATE CUR_PACKDET
END
IF @n_continue = 3  -- Error Occured - Process And Return
BEGIN
   SELECT @b_success = 0
   IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt
   BEGIN
      ROLLBACK TRAN
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
   END
   EXECUTE nsp_logerror @n_err, @c_errmsg, "isp_AssignPackLabelToPickByDropIDAU"
   RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   RETURN
END
ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[isp_AssignPackLabelToPickByDropIDAU] TO nSQL 
GO


