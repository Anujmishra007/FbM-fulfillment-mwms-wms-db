
/*************************************************************************/
/* Stored Procedure: mspRLWAV04WAG                                          */
/* Creation Date: 19-Oct-2024                                            */
/* Copyright: MAERSK                                                     */
/* Written by: USH022                                                    */
/*                                                                       */
/* Purpose:  [WAG] TM wave release rules & Logic    				     */
/*                                                                       */
/* Called By: Wave                                                       */
/*                                                                       */
/* GitHub Version: 2.0                                                   */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date           Author    Ver   Purposes                               */
/* 19-Oct-2024    USH022    1.0   UWP-24680                              */
/* 16-Nov-2024    SHONG     1.1   Revise coding logic for multiple issues*/
/* 18-Nov-2024    SHONG     1.2   Revise Task Message                    */
/* 19-Nov-2024    SHONG     1.3   Missing torelance for non-parcel       */
/* 04-Dec-2024    SHONG     1.4   Set Task Status Priority by OrderGroup */
/* 10-Dec-2024    SHONG01   1.5   Revise VAS Flag logic                  */
/* 27-Jan-2025    USH022-01 1.6   Exclude LOT for ASTCPK tasktype        */
/*                                Ticket-UWP-28865                       */
/* 10-Oct-2025    SSA01     1.7  UWP-42248 -Enhanced session management  */
/* 11-May-2026    JRA432    1.8   UWP-59279: Copied From mspRLWAV04 for WAG (JRA01)*/
/* 11-May-2026    JRA432    1.8   UWP-59279: Set valid TaskDetail.ToLoc   */
/*                                from Wave.UDF01 (JRA02)                  */
/*************************************************************************/

CREATE OR ALTER     PROC [dbo].[mspRLWAV04WAG]
   @c_WaveKey NVARCHAR(10)
 , @b_Success INT           OUTPUT
 , @n_Err     INT           OUTPUT
 , @c_ErrMsg  NVARCHAR(250) OUTPUT
 , @b_debug   INT = 0
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
           @n_StartTCnt          INT   = @@TRANCOUNT
         , @n_Continue           INT   = 1

         , @c_Facility           NVARCHAR(5)  = ''
         , @c_Loadkey            NVARCHAR(10) = ''
         , @c_Consigneekey       NVARCHAR(15) = ''
         , @c_C_Zip              NVARCHAR(18) = ''
         , @c_OrderKey_Last      NVARCHAR(10) = ''
         , @c_ParcelType         NVARCHAR(30) = ''
         , @c_ParcelType_Last    NVARCHAR(30) = ''
         , @c_OtherReference     NVARCHAR(10) = ''

         , @c_PickDetailkey      NVARCHAR(10) = ''
         , @c_OrderKey           NVARCHAR(10) = ''
         , @c_OrderLineNumber    NVARCHAR(5)  = ''
         , @c_Storerkey          NVARCHAR(15) = ''
         , @c_Sku                NVARCHAR(20) = ''
         , @c_Sku_Last           NVARCHAR(20) = ''
         , @c_SkuClass           NVARCHAR(10) = ''
         , @c_SkuClass_Last      NVARCHAR(10) = ''
         , @c_SerialNoCapture    NVARCHAR(1)  = ''
         , @n_StdGrossWgt        FLOAT        = 0.00
         , @n_PackCube           FLOAT        = 0.00
         , @c_UOM                NVARCHAR(10) = ''
         , @c_Lot                NVARCHAR(10) = ''
         , @c_FromLoc            NVARCHAR(10) = ''
         , @c_FromLogicalLoc     NVARCHAR(10) = ''
         , @c_ID                 NVARCHAR(18) = ''
         , @c_LocAisle           NVARCHAR(10) = ''
         , @n_Qty                INT          = 0
         , @n_UOMQty             INT          = 0

         , @c_PickSlipNo         NVARCHAR(10) = ''
         , @c_PickHeaderKey      NVARCHAR(10) = ''

         , @c_TaskDetailKey      NVARCHAR(10) = ''
         , @c_TaskType           NVARCHAR(10) = ''
         , @c_TaskType_Last      NVARCHAR(10) = ''
         , @c_ToLoc              NVARCHAR(10) = ''
         , @c_ToLogicalLoc       NVARCHAR(10) = ''
         , @c_PickMethod         NVARCHAR(10) = ''
         , @c_Message01          NVARCHAR(20) = ''
         , @c_Message02          NVARCHAR(20) = ''
         , @c_Message03          NVARCHAR(20) = ''
         , @c_GroupKey           NVARCHAR(10) = ''
         , @c_GroupKey_Last      NVARCHAR(10) = ''
         , @c_SourceType         NVARCHAR(10) = 'mspRLWAV04'
         , @c_Priority           NVARCHAR(10) = '9'
         , @c_TaskStatus         NVARCHAR(10) = '0'
         , @c_TaskStatus_FPK     NVARCHAR(10) = '0'
         , @c_LinkTaskToPick_SQL NVARCHAR(MAX)= ''

         , @n_NoOfPallet_df      INT          = 0
         , @n_MaxCube_df         FLOAT        = 0.00
         , @n_MaxHeight_df       FLOAT        = 0.00
         , @n_MaxWeight_df       FLOAT        = 0.00
         , @c_OneBrand_df        NVARCHAR(10) = ''
         , @c_PalletType_df      NVARCHAR(10) = ''

         , @n_NoOfPallet         INT          = 0
         , @n_MaxCube            FLOAT        = 0.00
         , @n_MaxHeight          FLOAT        = 0.00
         , @n_MaxWeight          FLOAT        = 0.00
         , @c_OneBrand           NVARCHAR(10) = ''
         , @c_PalletType         NVARCHAR(10) = ''

         , @b_NonParcel          BIT          = 0
         , @n_OrderCnt           INT          = 0
         , @n_MaxOrderPerGroup   INT          = 5
         , @n_NoOfOrderPerGrp    INT          = 0
         , @c_BoxType            NVARCHAR(50) = ''
         , @c_ParcelSize         NVARCHAR(50) = ''
         , @c_ParcelSize_Last    NVARCHAR(50) = ''
         , @n_Cube_ORD           FLOAT        = 0.00
         , @n_Cube               FLOAT        = 0.00
         , @n_Height             FLOAT        = 0.00
         , @n_Weight             FLOAT        = 0.00
         , @n_Tolerance          FLOAT        = 0.00
         , @n_Tolerance_T        FLOAT        = 0.00
         , @n_TotalCube          FLOAT        = 0.00
         , @n_TotalWeight        FLOAT        = 0.00
         , @n_TrolleyCube        FLOAT        = 0.00

         , @n_MaxOrdPerBld       INT          = 0
         , @n_MaxOrdPerBld01     INT          = 0
         , @n_MaxOrdPerBld02     INT          = 0
         , @n_MaxOrdPerBld03     INT          = 0
         , @n_MaxOrdPerBld04     INT          = 0
         , @n_MaxOrdPerBld05     INT          = 0
         , @c_FirstOrderKey      NVARCHAR(10) = ''
         , @b_InsertTask         BIT          = 0            --USH022-01
         , @c_ID_Last            NVARCHAR(18) = ''
         , @c_Loc                NVARCHAR(10) = ''
         , @c_Loc_Last           NVARCHAR(10) = ''           --USH022-01

      DECLARE @n_Capacity INT = 0,
              @n_MaxSKU   INT = 0,
              @n_RowID    INT = 0,
              @n_TotalSKU INT = 0

   DECLARE @CUR_PCK        CURSOR
         , @CUR_TSK        CURSOR

   SET @b_success = 0
   SET @n_err = 0
   SET @c_errmsg = ''

   IF @@TRANCOUNT = 0
      BEGIN TRAN

   IF EXISTS ( SELECT 1 FROM TaskDetail td (NOLOCK)
               WHERE td.Wavekey = @c_Wavekey
               AND   td.Sourcetype = @c_SourceType
               AND   td.Tasktype IN ('FPK','ASTCPK')
               AND   td.[Status] NOT IN ('X')
             )
   BEGIN
      SET @n_Continue = 3
      SET @n_Err = 85010
      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err) + ': Task has been released.(mspRLWAV04WAG)'
      GOTO RETURN_SP;
   END

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      SELECT TOP 1
              @c_Storerkey  = OH.Storerkey
            , @c_Facility   = OH.Facility
            , @c_OrderKey   = OH.OrderKey
			, @c_ToLoc = W.UserDefine01
            --, @c_ParcelType = ISNULL(OH.UserDefine10,'')
      FROM WAVEDETAIL WD (NOLOCK)
	  JOIN WAVE W (NOLOCK) ON W.WaveKey = WD.WaveKey
      JOIN ORDERS OH (NOLOCK) ON OH.OrderKey = WD.OrderKey
      WHERE WD.Wavekey = @c_Wavekey
      ORDER BY ISNULL(OH.UserDefine10,'')
      
	  --JRA432 V1.8 (JRA01) - UWP-59279: Validate To Location is on wave and is valid
	  IF ISNULL(@c_ToLoc, '') = ''
	  OR NOT EXISTS(SELECT 1 FROM dbo.Loc (NOLOCK)
					WHERE Facility = @c_Facility
					AND Loc = @c_ToLoc)
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 83010
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Valid ToLoc (Wave.Userdefine01) not assigned. (mspRLWAV04WAG)'
         GOTO RETURN_SP
      END 
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      -- Order count validation for WaveKey
      DECLARE @c_Buildparmkey NVARCHAR(10);
      select top 1 @c_Buildparmkey = bwl.Buildparmkey
      FROM BuildWaveLog bwl(NOLOCK)
      JOIN BuildWaveDetailLog bwdl (NOLOCK) ON bwdl.BatchNo = bwl.BatchNo
      JOIN BuildParm bp (NOLOCK) ON bp.Buildparmkey = bwl.Buildparmkey
      where bwdl.Wavekey = @c_WaveKey;

      SELECT @n_MaxOrdPerBld01= CASE WHEN BP.Restriction01 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue01  ELSE 0 END
      ,@n_MaxOrdPerBld02= CASE WHEN BP.Restriction02 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue02  ELSE 0 END
      ,@n_MaxOrdPerBld03= CASE WHEN BP.Restriction03 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue03  ELSE 0 END
      ,@n_MaxOrdPerBld04= CASE WHEN BP.Restriction04 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue04  ELSE 0 END
      ,@n_MaxOrdPerBld05= CASE WHEN BP.Restriction05 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue05  ELSE 0 END
      FROM BUILDPARM BP WITH (NOLOCK)
      WHERE BP.BuildParmKey = @c_BuildParmKey

      SET @n_MaxOrdPerBld= @n_MaxOrdPerBld01
      IF @n_MaxOrdPerBld = 0 SET @n_MaxOrdPerBld = @n_MaxOrdPerBld02
      IF @n_MaxOrdPerBld = 0 SET @n_MaxOrdPerBld = @n_MaxOrdPerBld03
      IF @n_MaxOrdPerBld = 0 SET @n_MaxOrdPerBld = @n_MaxOrdPerBld04
      IF @n_MaxOrdPerBld = 0 SET @n_MaxOrdPerBld = @n_MaxOrdPerBld05

/*JRA432 1.8   UWP-59279(JRA01)
      --DECLARE @n_OrderTypeCount INT
      --DECLARE @n_OrderKeyCount INT

      SELECT --@n_OrderTypeCount = COUNT(DISTINCT ISNULL(cl.UDF01,''))
            @n_OrderKeyCount  = COUNT(O.OrderKey)
           --, @n_InvalidParcelType = MAX(CASE WHEN cl.ListName IS NULL THEN 1 ELSE 0 END)
           --, @n_UDF10_AS_UNKNOWN =	MAX(CASE WHEN O.UserDefine10 = 'UNKNOWN' THEN 1 ELSE 0 END)
      FROM Orders O (NOLOCK)
      JOIN WAVEDETAIL WD (NOLOCK) ON WD.OrderKey = O.OrderKey AND WD.WaveKey = @c_WaveKey
*/
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF EXISTS(SELECT 1 FROM WAVEDETAIL WD (NOLOCK)
            LEFT OUTER JOIN MBOLDETAIL MD (NOLOCK) ON WD.OrderKey = MD.OrderKey
            LEFT OUTER JOIN MBOL M (NOLOCK) ON MD.MBOlKey =  M.MbolKey
            WHERE WD.WaveKey = @c_WaveKey
            AND M.MbolKey IS NULL)
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 85090
         SET @c_errmsg='NSQL'+LTRIM(RTRIM(CONVERT(NVARCHAR(5),@n_err))) +
         ':Shipping Reference not being generated, You are not allow to Release Wave: '+
         @c_Wavekey +'. (mspRLWAV04)'
         GOTO RETURN_SP;
      END
   END
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF EXISTS(SELECT 1 FROM WAVEDETAIL WD (NOLOCK)
            LEFT OUTER JOIN LoadPlanDetail LD (NOLOCK) ON WD.OrderKey = LD.OrderKey
            WHERE WD.WaveKey = @c_WaveKey
            AND LD.LoadKey IS NULL)
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 85100
         SET @c_errmsg='NSQL'+LTRIM(RTRIM(CONVERT(NVARCHAR(5),@n_err))) +
         ':Load not being generated, You are not allow to Release Wave: '+
         @c_Wavekey +'. (mspRLWAV04)'
         GOTO RETURN_SP;
      END
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
         DROP TABLE #PICKDETAIL_WIP

      CREATE TABLE #PickDetail_WIP(
         [PickDetailKey] [nvarchar](18) NOT NULL PRIMARY KEY,
         [CaseID] [nvarchar](20) NOT NULL DEFAULT (' '),
         [PickHeaderKey] [nvarchar](18) NOT NULL,
         [OrderKey] [nvarchar](10) NOT NULL,
         [OrderLineNumber] [nvarchar](5) NOT NULL,
         [Lot] [nvarchar](10) NOT NULL,
         [Storerkey] [nvarchar](15) NOT NULL,
         [Sku] [nvarchar](20) NOT NULL,
         [AltSku] [nvarchar](20) NOT NULL DEFAULT (' '),
         [UOM] [nvarchar](10) NOT NULL DEFAULT (' '),
         [UOMQty] [int] NOT NULL DEFAULT ((0)),
         [Qty] [int] NOT NULL DEFAULT ((0)),
         [QtyMoved] [int] NOT NULL DEFAULT ((0)),
         [Status] [nvarchar](10) NOT NULL DEFAULT ('0'),
         [DropID] [nvarchar](20) NOT NULL DEFAULT (''),
         [Loc] [nvarchar](10) NOT NULL DEFAULT ('UNKNOWN'),
         [ID] [nvarchar](18) NOT NULL DEFAULT (' '),
         [PackKey] [nvarchar](10) NULL DEFAULT (' '),
         [UpdateSource] [nvarchar](10) NULL DEFAULT ('0'),
         [CartonGroup] [nvarchar](10) NULL,
         [CartonType] [nvarchar](10) NULL,
         [ToLoc] [nvarchar](10) NULL  DEFAULT (' '),
         [DoReplenish] [nvarchar](1) NULL DEFAULT ('N'),
         [ReplenishZone] [nvarchar](10) NULL DEFAULT (' '),
         [DoCartonize] [nvarchar](1) NULL DEFAULT ('N'),
         [PickMethod] [nvarchar](1) NOT NULL DEFAULT (' '),
         [WaveKey] [nvarchar](10) NOT NULL DEFAULT (' '),
         [EffectiveDate] [datetime] NOT NULL DEFAULT (getdate()),
         [AddDate] [datetime] NOT NULL DEFAULT (getdate()),                  --(SSA01)
         [AddWho] [nvarchar](128) NOT NULL DEFAULT (suser_sname()),          --(SSA01)
         [EditDate] [datetime] NOT NULL DEFAULT (getdate()),                 --(SSA01)
         [EditWho] [nvarchar](128) NOT NULL DEFAULT (suser_sname()),         --(SSA01)
         [TrafficCop] [nvarchar](1) NULL,
         [ArchiveCop] [nvarchar](1) NULL,
         [OptimizeCop] [nvarchar](1) NULL,
         [ShipFlag] [nvarchar](1) NULL DEFAULT ('0'),
         [PickSlipNo] [nvarchar](10) NULL,
         [TaskDetailKey] [nvarchar](10) NULL,
         [TaskManagerReasonKey] [nvarchar](10) NULL,
         [Notes] [nvarchar](4000) NULL,
         [MoveRefKey] [nvarchar](10) NULL DEFAULT (''),
         [WIP_Refno] [nvarchar](30) NULL DEFAULT (''),
         [Channel_ID] [bigint] NULL DEFAULT ((0)))
   END

   --Initialize Pickdetail work in progress staging table
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      EXEC isp_CreatePickdetail_WIP
            @c_Loadkey               = ''
         ,  @c_Wavekey               = @c_wavekey
         ,  @c_WIP_RefNo             = @c_SourceType
         ,  @c_PickCondition_SQL     = ''
         ,  @c_Action                = 'I'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
         ,  @c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
         ,  @b_Success               = @b_Success OUTPUT
         ,  @n_Err                   = @n_Err     OUTPUT
         ,  @c_ErrMsg                = @c_ErrMsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_continue = 3
      END
      ELSE
      BEGIN
         UPDATE #PICKDETAIL_WIP
         SET #PICKDETAIL_WIP.Taskdetailkey = ''
         FROM #PICKDETAIL_WIP
         LEFT JOIN TASKDETAIL TD (NOLOCK) ON  TD.Taskdetailkey = #PICKDETAIL_WIP.Taskdetailkey
                                          AND TD.Sourcetype = @c_SourceType
                                          AND TD.Tasktype IN ('FPK','ASTCPK')
                                          AND TD.PickDetailKey = #PICKDETAIL_WIP.PickDetailKey
                                          AND TD.Status <> 'X'
         WHERE TD.Taskdetailkey IS NULL
      END
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SET @CUR_PCK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PD.PickdetailKey
            ,PD.OrderKey
            ,PD.OrderLineNumber
            ,PD.Storerkey
            ,PD.Sku
            ,PD.Lot
            ,PD.Loc
            ,PD.ID
            ,PD.UOM
            ,PD.Qty
            ,S.Class
            ,S.SerialNoCapture
            ,S.StdGrossWgt
            ,PackCube = P.WidthUOM3 * P.LengthUOM3 * P.HeightUOM3
            ,L.LogicalLocation
            ,L.LocAisle
            ,LoadKey = ISNULL(OH.Loadkey,'')
            ,OH.Consigneekey
            ,OH.C_Zip
            ,OH.Userdefine10
      FROM #PickDetail_WIP PD (NOLOCK)
      JOIN ORDERS     OH (NOLOCK) ON OH.OrderKey = PD.OrderKey
      JOIN WAVEDETAIL WD (NOLOCK) ON WD.OrderKey = OH.OrderKey
      JOIN SKU        S  (NOLOCK) ON  S.Storerkey = PD.Storerkey
                                  AND S.Sku = PD.Sku
      JOIN PACK       P  (NOLOCK) ON  P.Packkey = S.Packkey
      JOIN LOC        L  (NOLOCK) ON PD.Loc = L.Loc
      WHERE WD.Wavekey  = @c_WaveKey
      AND   PD.[Status] < '5'
      AND   PD.TaskDetailKey = ''
      AND   PD.UOM IN ('1','6')
      ORDER BY CASE WHEN ISNULL(OH.OrderGroup,'') = '' THEN '999999' ELSE OH.OrderGroup END
             , OH.DeliveryDate
             , PD.OrderKey
             , PD.UOM
             , CASE WHEN PD.UOM = '6' THEN PD.Loc ELSE '' END             --USH022-01
             , L.LogicalLocation
             , CASE WHEN PD.UOM = '6' THEN PD.ID ELSE '' END              --USH022-01
             , S.Class
             , S.Sku
             , PD.PickDetailKey

      OPEN @CUR_PCK

      FETCH NEXT FROM @CUR_PCK INTO @c_PickdetailKey
                                 ,  @c_OrderKey
                                 ,  @c_OrderLineNumber
                                 ,  @c_Storerkey
                                 ,  @c_Sku
                                 ,  @c_Lot
                                 ,  @c_FromLoc
                                 ,  @c_ID
                                 ,  @c_UOM
                                 ,  @n_Qty
                                 ,  @c_SkuClass
                                 ,  @c_SerialNoCapture
                                 ,  @n_StdGrossWgt
                                 ,  @n_PackCube
                                 ,  @c_FromLogicalLoc
                                 ,  @c_LocAisle
                                 ,  @c_Loadkey
                                 ,  @c_Consigneekey
                                 ,  @c_C_Zip
                                 ,  @c_ParcelType
      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         IF @c_FirstOrderKey = '' 
		 --AND @c_ParcelType='Non-Parcel'
         BEGIN
            SET @c_FirstOrderKey = @c_OrderKey
         END

         SET @c_TaskStatus_FPK = 'S'
         SET @c_TaskStatus = 'S'

         IF @c_FirstOrderKey = @c_OrderKey
         BEGIN
            SET @c_TaskStatus_FPK = '0'
            SET @c_TaskStatus = '0'
         END

         IF @c_OrderKey <> @c_OrderKey_Last
         BEGIN
            SET @c_PickSlipNo = ''

            SELECT @c_PickSlipNo = ISNULL(ph.PickHeaderKey,'')
            FROM PICKHEADER ph (NOLOCK)
            WHERE ph.OrderKey = @c_OrderKey
            AND ph.[Zone] = 'LP'

            IF @c_PickSlipNo = ''
            BEGIN
               SET @b_success = 1
               EXECUTE nspg_getkey
                       @KeyName   = 'PICKSLIP'
                     , @fieldlength = 9
                     , @KeyString   = @c_PickSlipNo      OUTPUT
                     , @b_success   = @b_success         OUTPUT
                     , @n_err       = @n_err             OUTPUT
                     , @c_errmsg    = @c_errmsg          OUTPUT

               IF @b_success = 0
               BEGIN
                  SET @n_Continue = 3
               END

               IF @n_Continue = 1
               BEGIN
                  SET @c_PickSlipNo = N'P' + @c_PickSlipNo

                  INSERT INTO PICKHEADER (PickHeaderKey, OrderKey, ExternOrderKey, Loadkey, [Zone], Wavekey, StorerKey)
                  VALUES (@c_PickSlipNo, @c_OrderKey, @c_Loadkey, @c_Loadkey, 'LP', @c_Wavekey, @c_Storerkey)

                  IF @@ERROR <> 0
                  BEGIN
                     SET @n_Continue = 3
                  END
               END
            END
         END

         IF @n_Continue = 1
         BEGIN
            SET @n_UOMQty = @n_Qty
            --SET @c_ToLoc = ''
            SET @c_Message01 = ''
            SET @c_Message02 = ''
            SET @c_Message03 = ''
            SET @c_Loc = @c_FromLoc;                    --USH022-01
            SET @b_InsertTask = 0

            IF @c_UOM = '1'
            BEGIN
               SET @b_InsertTask = 1;
               SET @c_TaskType  = 'FPK'
               SET @c_PickMethod= 'FP'
               --SET @c_ToLoc = @c_OtherReference
               SET @c_LinkTaskToPick_SQL = 'PICKDETAIL.OrderKey = @c_OrderKey AND PICKDETAIL.UOM = @c_UOM' --USH022-01

               SET @c_TaskStatus = '0' --@c_TaskStatus_FPK
            END
            ELSE IF @c_UOM = '6' AND
              (@c_ORderkey <> @c_Orderkey_Last OR @c_Loc <> @c_Loc_Last OR @c_ID <> @c_ID_Last --USH022-01
              OR (@c_Sku <> @c_Sku_last OR @c_Skuclass <> @c_SkuClass_last)           --USH022-01
              )
            BEGIN
               IF @b_debug=1
               BEGIN
                  PRINT '@c_ParcelType:' + @c_ParcelType + ', @c_TaskType=' + @c_TaskType
                  PRINT '>>> ' + @c_OrderKey
               END

               SET @c_BoxType   = ''
               SET @c_ParcelSize= ''
               SET @b_NonParcel = 0
               SET @c_GroupKey  = ''
               SET @c_Lot = ''                                                      --USH022-01
               SET @c_LinkTaskToPick_SQL = 'PICKDETAIL.OrderKey = @c_OrderKey
                              AND PICKDETAIL.UOM = @c_UOM AND PICKDETAIL.Loc = @c_Fromloc
                              AND PICKDETAIL.ID = @c_FromID'
               SET @b_InsertTask = 1                                                --USH022-01

               SET @c_TaskType  = 'ASTCPK'
               SET @c_PickMethod= 'PP'

               SELECT @n_Qty = SUM(QTY) FROM #PickDetail_WIP PDW (NOLOCK)  --USH022-01
               WHERE PDW.WaveKey = @c_WaveKey
               AND PDW.Sku = @c_Sku
               AND PDW.ID = @c_ID
               AND PDW.Loc = @c_Loc
               AND PDW.Orderkey = @c_Orderkey
               AND PDW.[Status] < '5'
               GROUP BY PDW.Sku, PDW.ID, PDW.Loc;                          --USH022-01

               IF @b_debug=1
               BEGIN
                  PRINT '@b_NonParcel:' + CAST(@b_NonParcel as varchar(10))
                  SELECT @c_GroupKey '@c_GroupKey', @n_NoOfPallet '@n_NoOfPallet', @c_Sku '@c_Sku' ,@c_Sku_Last '@c_Sku_Last', @c_SkuClass '@c_SkuClass'
               END

            END
         END

         IF @n_Continue = 1
         BEGIN
            SET @c_ToLogicalLoc = ''
            SELECT @c_ToLogicalLoc = l.LogicalLocation
            FROM LOC l (NOLOCK)
            WHERE l.Loc = @c_ToLoc

            --Insert Taskdetail
            IF @b_NonParcel = 0
            SET @c_TaskStatus = '0'

            IF @b_InsertTask = 1                                  --USH022-01
            BEGIN
                SET @c_TaskDetailKey = ''

                EXEC isp_InsertTaskDetail
                @c_TaskDetailKey         = @c_TaskDetailKey OUTPUT
                ,  @c_TaskType              = @c_TaskType
                ,  @c_Storerkey             = @c_Storerkey
                ,  @c_Sku                   = @c_Sku
                ,  @c_Lot                   = @c_Lot
                ,  @c_UOM                   = @c_UOM
                ,  @n_UOMQty                = @n_UOMQty
                ,  @n_Qty                   = @n_Qty
                ,  @c_FromLoc               = @c_Fromloc
                ,  @c_LogicalFromLoc        = @c_FromLogicalLoc
                ,  @c_FromID                = @c_ID
                ,  @c_ToLoc                 = @c_ToLoc
                ,  @c_LogicalToLoc          = @c_ToLogicalLoc
                ,  @c_ToID                  = @c_ID
                ,  @c_PickMethod            = @c_PickMethod
                ,  @c_Priority              = @c_Priority
                ,  @c_SourcePriority        = '9'
                ,  @c_SourceType            = @c_SourceType
                ,  @c_SourceKey             = @c_Wavekey
                ,  @c_PickDetailkey         = @c_PickDetailkey
                ,  @c_OrderKey              = @c_OrderKey
                ,  @c_Groupkey              = @c_Groupkey
                ,  @c_WaveKey               = @c_Wavekey
                ,  @c_AreaKey               = '?F'  -- ?F=Get from location areakey
                ,  @c_Message01             = @c_Message01
                ,  @c_Message02             = @c_Message02
                ,  @c_Message03             = @c_Message03
                ,  @c_LinkTaskToPick        = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip
                ,  @c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL
                ,  @c_SplitTaskByCase       ='N'   -- N=No slip Y=Split TASK by carton. Only apply if @n_casecnt > 0. include last partial carton.
                ,  @c_WIP_RefNo             = @c_SourceType
                ,  @b_Success               = @b_Success     OUTPUT
                ,  @n_Err                   = @n_err         OUTPUT
                ,  @c_ErrMsg                = @c_errmsg      OUTPUT
                ,  @c_Status                = @c_TaskStatus
                ,  @c_Loadkey               = @c_Loadkey  -- 16/11 WS: added to allows me testig RDT FCR's but Please validate this

            END
         END

         --JRA432 V1.8 (JRA01)
         IF ISNULL(@c_TaskDetailKey,'') <> ''
         BEGIN
            UPDATE TaskDetail  WITH(ROWLOCK)
            SET CaseId = Orderkey 
            WHERE storerkey = @c_StorerKey
            AND WaveKey = @c_wavekey
            AND TaskDetailKey = @c_TaskDetailKey
            --JRA432 V1.8 (JRA01)    
            UPDATE PickDetail  WITH(ROWLOCK)
            SET CaseId = Orderkey 
            WHERE storerkey = @c_StorerKey
            AND WaveKey = @c_wavekey
            AND PickDetailKey = @c_PickDetailkey
         END

         IF @n_Continue = 1
         BEGIN
            UPDATE PICKDETAIL WITH (ROWLOCK)
               SET PickSlipNo = CASE WHEN ISNULL(PickSlipNo,'') = '' THEN @c_PickSlipNo ELSE PickSlipNo END
                  , EditDate = dbo.fnc_GetDate()   --(SSA01)
                  , TrafficCop = NULL
                  , TaskDetailKey = @c_TaskDetailKey
                  , Notes = CASE WHEN ISNULL(Notes,'') = '' THEN LOC ELSE Notes END
            WHERE PickDetailKey = @c_PickDetailkey

            IF @@ERROR <> 0
            BEGIN
               SET @n_Continue = 3
            END
         END

         IF @n_Continue = 1
         BEGIN
            IF EXISTS (SELECT 1 FROM RefKeyLookup (NOLOCK) WHERE PickDetailkey = @c_PickDetailkey)
            BEGIN
               UPDATE RefKeyLookup WITH (ROWLOCK)
                     SET Pickslipno = @c_PickSlipNo
                        ,OrderKey = @c_OrderKey
                        ,OrderLineNumber = @c_OrderLineNumber
                        ,Loadkey = @c_Loadkey
                        ,ArchiveCop = NULL
               WHERE PickDetailkey = @c_PickDetailkey
            END
            ELSE
            BEGIN
               INSERT INTO RefKeyLookup (PickDetailkey, Pickslipno, OrderKey, OrderLineNumber, Loadkey)
               VALUES (@c_PickDetailkey, @c_PickSlipNo, @c_OrderKey, @c_OrderLineNumber, @c_Loadkey)
            END

            IF @@ERROR <> 0
            BEGIN
               SET @n_Continue = 3
            END
         END

         SET @c_OrderKey_Last = @c_OrderKey
         SET @c_ParcelType_Last = @c_ParcelType
         SET @c_Sku_Last      = @c_Sku
         SET @c_SkuClass_Last = @c_SkuClass
         SET @c_GroupKey_Last = @c_GroupKey
         SET @c_TaskType_Last = @c_TaskType
         SET @c_ParcelSize_Last = @c_ParcelSize
         SET @c_Loc_Last        = @c_Loc                    --USH022-01
         SET @c_ID_Last         = @c_ID                     --USH022-01
         FETCH NEXT FROM @CUR_PCK INTO @c_PickdetailKey
                                    ,  @c_OrderKey
                                    ,  @c_OrderLineNumber
                                    ,  @c_Storerkey
                                    ,  @c_Sku
                                    ,  @c_Lot
                                    ,  @c_FromLoc
                                    ,  @c_ID
                                    ,  @c_UOM
                                    ,  @n_Qty
                                    ,  @c_SkuClass
                                    ,  @c_SerialNoCapture
                                    ,  @n_StdGrossWgt
                                    ,  @n_PackCube
                                    ,  @c_FromLogicalLoc
                                    ,  @c_LocAisle
                                    ,  @c_Loadkey
                                    ,  @c_Consigneekey
                                    ,  @c_C_Zip
                                    ,  @c_ParcelType
      END
      CLOSE @CUR_PCK
      DEALLOCATE @CUR_PCK
   END

   IF @b_debug=1
   BEGIN
       SELECT TD.Storerkey
       , TD.TaskDetailKey
       , LOC.LogicalLocation
       , OH.OrderKey
       , S.Sku
       , S.Class
       , TD.Qty * (P.WidthUOM3 * P.LengthUOM3 * P.HeightUOM3) AS TaskCube
       , TD.Qty * S.StdGrossWgt AS [TaskWeight]
       , CL.UDF01
       , GroupKey
       , TD.TaskType
       , CL.Code2
      FROM dbo.TaskDetail TD WITH (NOLOCK)
      JOIN dbo.LOC LOC WITH (NOLOCK) ON LOC.Loc = TD.FromLoc
      JOIN SKU S (NOLOCK) ON  S.Storerkey = TD.Storerkey AND S.Sku = TD.Sku
      JOIN dbo.ORDERS OH WITH (NOLOCK) ON OH.OrderKey = TD.OrderKey
      JOIN PACK P  (NOLOCK) ON  P.Packkey = S.Packkey
      JOIN dbo.CODELKUP cl ON  cl.listName = 'HUSQPKTYPE'
                           AND cl.StorerKey = OH.Storerkey
                           AND cl.Short = OH.Userdefine10
      WHERE  TD.TaskType = 'ASTCPK'
      AND TD.WaveKey = @c_Wavekey
   END

   /**************************************/
   /* Additional sorting order for task  */
   /**************************************/
   /* declare variables */
   DECLARE @c_OrderGroup      NVARCHAR(20)=''
          ,@c_FirstOrderGroup NVARCHAR(20)=''

   DECLARE CUR_OrderGroup CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT CASE WHEN ISNULL(O.OrderGroup,'') = '' THEN '999999' ELSE O.OrderGroup END AS OrderGroup, O.OrderKey
   FROM dbo.ORDERS O WITH (NOLOCK)
   JOIN dbo.WAVEDETAIL WD WITH (NOLOCK) ON WD.OrderKey = O.OrderKey
   WHERE WD.WaveKey = @c_WaveKey
   ORDER BY CASE WHEN ISNULL(O.OrderGroup,'') = '' THEN '999999' ELSE O.OrderGroup END

   OPEN CUR_OrderGroup

   FETCH NEXT FROM CUR_OrderGroup INTO @c_OrderGroup, @c_OrderKey

   WHILE @@FETCH_STATUS = 0
   BEGIN
       IF @c_FirstOrderGroup=''
          SET @c_FirstOrderGroup = @c_OrderGroup

       IF @c_FirstOrderGroup = '999999'
       BEGIN
          -- system should generate task as per current process as all Orders.OrderGroup = ''
          --WAG exits here
          BREAK
       END

       ELSE
       BEGIN
          IF @c_FirstOrderGroup =  @c_OrderGroup
            SET @c_TaskStatus='0'
          ELSE
            SET @c_TaskStatus = 'S'

          DECLARE CUR_TASKDETAIL_REC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
          SELECT TD.TaskDetailKey
          FROM dbo.TaskDetail TD WITH (NOLOCK)
          WHERE TD.WaveKey = @c_WaveKey
          AND TD.OrderKey = @c_OrderKey
          AND TD.Status IN ('0','S')


          OPEN CUR_TASKDETAIL_REC

          FETCH NEXT FROM CUR_TASKDETAIL_REC INTO @c_TaskDetailKey

          WHILE @@FETCH_STATUS = 0
          BEGIN
              UPDATE dbo.TaskDetail WITH (ROWLOCK)
               SET Status=@c_TaskStatus, TrafficCop=NULL
              WHERE TaskDetailKey=@c_TaskDetailKey

              FETCH NEXT FROM CUR_TASKDETAIL_REC INTO @c_TaskDetailKey
          END

          CLOSE CUR_TASKDETAIL_REC
          DEALLOCATE CUR_TASKDETAIL_REC
       END

       FETCH NEXT FROM CUR_OrderGroup INTO @c_OrderGroup, @c_OrderKey
   END

   CLOSE CUR_OrderGroup
   DEALLOCATE CUR_OrderGroup

RETURN_SP:
 -----Delete pickdetail_WIP work in progress staging table
   IF @n_continue IN (1,2)
   BEGIN
      EXEC isp_CreatePickdetail_WIP
            @c_Loadkey               = ''
         ,  @c_Wavekey               = @c_wavekey
         ,  @c_WIP_RefNo             = @c_SourceType
         ,  @c_PickCondition_SQL     = ''
         ,  @c_Action                = 'D'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
         ,  @c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
         ,  @b_Success               = @b_Success OUTPUT
         ,  @n_Err                   = @n_Err     OUTPUT
         ,  @c_ErrMsg                = @c_ErrMsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_continue = 3
      END
   END

   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
      DROP TABLE #PICKDETAIL_WIP

   --JRA432 1.8   UWP-59279(JRA01)
   IF CURSOR_STATUS('LOCAL', 'CUR_OrderGroup') IN (0 , 1)
   BEGIN
   CLOSE CUR_OrderGroup
   DEALLOCATE CUR_OrderGroup
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_TASKDETAIL_REC') IN (0 , 1)
   BEGIN
   CLOSE CUR_TASKDETAIL_REC
   DEALLOCATE CUR_TASKDETAIL_REC
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV04WAG'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

END -- procedure


