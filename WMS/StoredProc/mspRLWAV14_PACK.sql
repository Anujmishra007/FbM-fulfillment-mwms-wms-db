SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*************************************************************************/
/* Stored Procedure: mspRLWAV14_PACK                                     */
/* Creation Date: 2026-07-16                                             */
/* Copyright: Maersk Logistics                                           */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: FCR-14547 CANADA MGACA Wave Release                          */
/*                                                                       */
/* Called By: Wave                                                       */
/*                                                                       */
/* Version: 1.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 16-Jul-2026 WLChooi  1.0   Initial Version                            */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV14_PACK]       
   @c_Wavekey     NVARCHAR(10)
,  @b_Success     INT            = 1   OUTPUT
,  @n_Err         INT            = 0   OUTPUT
,  @c_ErrMsg      NVARCHAR(255)  = ''  OUTPUT
,  @n_debug       INT            = 0
AS    
BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    

   DECLARE
           @n_StartTCnt             INT   = @@TRANCOUNT
         , @n_Continue              INT   = 1
         , @n_RowCount              INT   = 0

         , @c_SourceType            NVARCHAR(30)   = 'mspRLWAV14'
         , @c_UserName              NVARCHAR(128)  = ''
         , @c_Facility              NVARCHAR(5)    = ''
         , @c_Storerkey             NVARCHAR(15)   = ''
         , @c_CartonGroup           NVARCHAR(10)   = ''
         , @c_Orderkey              NVARCHAR(10)   = ''
         , @c_PickSlipNo            NVARCHAR(10)   = ''
         , @c_PickDetailKey         NVARCHAR(18)   = ''
         , @c_NewPickDetailKey      NVARCHAR(18)   = ''
         , @c_Sku                   NVARCHAR(20)   = ''
         , @c_LabelNo               NVARCHAR(20)   = ''
         , @c_CartonType            NVARCHAR(10)   = ''
         , @c_RefPickKey            NVARCHAR(18)   = ''
         , @c_RefPickMode           NVARCHAR(1)    = ''
         , @c_Notes                 NVARCHAR(100)  = ''

         , @n_Qty                   INT            = 0
         , @n_QtyLeft               INT            = 0
         , @n_Qty_pd                INT            = 0
         , @n_QtyToPack             INT            = 0
         , @n_QtyToPack_cd          INT            = 0
         , @n_QtyToPack_ins         INT            = 0
         , @n_MaxQtyPerCtn          INT            = 0
         , @n_QtyPacked             INT            = 0
         , @n_CartonSeqNo           INT            = 0
         , @n_CartonNo_Last         INT            = 0
         , @n_RowID_cd              INT            = 0

         , @n_Length                FLOAT          = 0.00
         , @n_Width                 FLOAT          = 0.00
         , @n_Height                FLOAT          = 0.00
         , @n_Weight                FLOAT          = 0.00
         , @n_Cube                  FLOAT          = 0.00
         , @n_CubeUOM3              FLOAT          = 0.00
         , @n_NetWgt                FLOAT          = 0.00
         , @n_LineCBM               FLOAT          = 0.00
         , @n_CartonWeight          FLOAT          = 0.00

         , @cur_ORD                 CURSOR
         , @cur_UOM6                CURSOR
         , @cur_LBL                 CURSOR
         , @cur_SPLPD               CURSOR
         , @cur_PDSKU               CURSOR

   DECLARE @t_CZ                 TABLE
         (  [CartonizationKey]   [nvarchar](10)    PRIMARY KEY                   
         ,  [CartonizationGroup] [nvarchar](10)    NOT NULL     
         ,  [CartonType]         [nvarchar](30)    NOT NULL  
         ,  [Cube]               [float]           NOT NULL  
         ,  [MaxWeight]          [float]           NOT NULL  
         ,  [CartonWeight]       [float]           NULL  
         ,  [CartonLength]       [float]           NULL  
         ,  [CartonWidth]        [float]           NULL  
         ,  [CartonHeight]       [float]           NULL  
         ) 

   SET @b_Success = 1
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''
   SET @c_UserName= dbo.fnc_GetUserName()

   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NULL
   BEGIN
      CREATE TABLE #PickDetail_WIP(
         [PickDetailKey]   [nvarchar](18) NOT NULL PRIMARY KEY
      ,  [CaseID]          [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [PickHeaderKey]   [nvarchar](18) NOT NULL
      ,  [OrderKey]        [nvarchar](10) NOT NULL
      ,  [OrderLineNumber] [nvarchar](5)  NOT NULL
      ,  [Lot]             [nvarchar](10) NOT NULL
      ,  [Storerkey]       [nvarchar](15) NOT NULL
      ,  [Sku]             [nvarchar](20) NOT NULL
      ,  [AltSku]          [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [UOM]             [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [UOMQty]          [int]          NOT NULL DEFAULT (0)
      ,  [Qty]             [int]          NOT NULL DEFAULT (0)
      ,  [QtyMoved]        [int]          NOT NULL DEFAULT (0)
      ,  [Status]          [nvarchar](10) NOT NULL DEFAULT ('0')
      ,  [DropID]          [nvarchar](20) NOT NULL DEFAULT ('')
      ,  [Loc]             [nvarchar](10) NOT NULL DEFAULT ('UNKNOWN')
      ,  [ID]              [nvarchar](18) NOT NULL DEFAULT (' ')
      ,  [PackKey]         [nvarchar](10) NULL     DEFAULT (' ')
      ,  [UpdateSource]    [nvarchar](10) NULL     DEFAULT ('0')
      ,  [CartonGroup]     [nvarchar](10) NULL
      ,  [CartonType]      [nvarchar](10) NULL
      ,  [ToLoc]           [nvarchar](10) NULL     DEFAULT (' ')
      ,  [DoReplenish]     [nvarchar](1)  NULL     DEFAULT ('N')
      ,  [ReplenishZone]   [nvarchar](10) NULL     DEFAULT (' ')
      ,  [DoCartonize]     [nvarchar](1)  NULL     DEFAULT ('N')
      ,  [PickMethod]      [nvarchar](1)  NOT NULL DEFAULT (' ')
      ,  [WaveKey]         [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [LoadKey]         [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [EffectiveDate]   [datetime]     NOT NULL DEFAULT (getdate())
      ,  [AddDate]         [datetime]     NOT NULL DEFAULT (getdate())
      ,  [AddWho]          [nvarchar](128)NOT NULL DEFAULT (suser_sname())
      ,  [EditDate]        [datetime]     NOT NULL DEFAULT (getdate())
      ,  [EditWho]         [nvarchar](128)NOT NULL DEFAULT (suser_sname())
      ,  [TrafficCop]      [nvarchar](1)  NULL
      ,  [ArchiveCop]      [nvarchar](1)  NULL
      ,  [OptimizeCop]     [nvarchar](1)  NULL
      ,  [ShipFlag]        [nvarchar](1)  NULL     DEFAULT ('0')
      ,  [PickSlipNo]      [nvarchar](10) NULL
      ,  [TaskDetailKey]   [nvarchar](10) NULL
      ,  [TaskManagerReasonKey] [nvarchar](10) NULL
      ,  [Notes]           [nvarchar](4000)NULL
      ,  [MoveRefKey]      [nvarchar](10) NULL     DEFAULT ('')
      ,  [WIP_Refno]       [nvarchar](30) NULL     DEFAULT ('')
      ,  [Channel_ID]      [bigint]       NULL     DEFAULT (0)
      )
      CREATE INDEX IDX_Case ON #PickDetail_WIP (Orderkey, CaseID, Lot, Loc, ID)

      EXEC [dbo].[mspRLWAV14_DATA]
         @c_Wavekey     = @c_Wavekey
      ,  @b_Success     = @b_Success   OUTPUT
      ,  @n_Err         = @n_Err       OUTPUT
      ,  @c_ErrMsg      = @c_ErrMsg    OUTPUT
      ,  @n_debug       = @n_debug

      SET @n_Continue = CASE WHEN @b_Success = 0 THEN 3 ELSE 1 END
   END

   IF @n_Continue = 1
   BEGIN
      IF OBJECT_ID('tempdb..#CartonDetail') IS NOT NULL
         DROP TABLE #CartonDetail

      CREATE TABLE #CartonDetail
      (  [RowID]           [int]          NOT NULL IDENTITY(1,1) PRIMARY KEY
      ,  [PickDetailKey]   [nvarchar](18) NOT NULL DEFAULT ('')
      ,  [OrderKey]        [nvarchar](10) NOT NULL DEFAULT ('')
      ,  [CartonGroup]     [nvarchar](10) NOT NULL DEFAULT ('')
      ,  [CartonType]      [nvarchar](10) NOT NULL DEFAULT ('')
      ,  [CartonSeqNo]     [int]          NOT NULL DEFAULT (0)
      ,  [CartonCube]      [float]        NOT NULL DEFAULT (0.00)
      ,  [CartonWeight]    [float]        NOT NULL DEFAULT (0.00)
      ,  [LabelNo]         [nvarchar](20) NOT NULL DEFAULT ('')
      ,  [Storerkey]       [nvarchar](15) NOT NULL DEFAULT ('')
      ,  [Sku]             [nvarchar](20) NOT NULL DEFAULT ('')
      ,  [Length]          [float]        NOT NULL DEFAULT (0.00)
      ,  [Width]           [float]        NOT NULL DEFAULT (0.00)
      ,  [Height]          [float]        NOT NULL DEFAULT (0.00)
      ,  [Weight]          [float]        NOT NULL DEFAULT (0.00)
      ,  [UOM]             [nvarchar](10) NOT NULL DEFAULT ('')
      ,  [Qty]             [int]          NOT NULL DEFAULT (0)
      ,  [DropID]          [nvarchar](20) NOT NULL DEFAULT ('')
      ,  [RefPickKey]      [nvarchar](18) NOT NULL DEFAULT ('')
      ,  [RefPickMode]     [nvarchar](1)  NOT NULL DEFAULT ('')  -- blank / S:Split / N:New
      ,  [Notes]           [nvarchar](500)NOT NULL DEFAULT ('')
      ,  [Status]          [nvarchar](1)  NOT NULL DEFAULT ('9')
      )
      CREATE INDEX IDX_CartonSeqNo ON #CartonDetail (Orderkey, CartonSeqNo, RefPickKey)
   END

   IF @n_Continue = 1
   BEGIN
      SELECT TOP 1 @c_Facility  = o.Facility
                ,  @c_Storerkey = p.Storerkey
      FROM #PickDetail_WIP p
      JOIN ORDERS o (NOLOCK) ON o.Orderkey = p.OrderKey

      SELECT @c_CartonGroup = st.CartonGroup
      FROM STORER st (NOLOCK)
      WHERE st.StorerKey = @c_Storerkey
   END
   
   IF @n_Continue = 1
   BEGIN
      INSERT INTO @t_CZ
            (  CartonizationKey, CartonizationGroup, CartonType, [Cube], MaxWeight
            ,  CartonWeight, CartonLength, CartonWidth, CartonHeight )
      SELECT   cz.CartonizationKey, cz.CartonizationGroup, cz.CartonType, cz.[Cube], cz.MaxWeight
            ,  0.00   --ISNULL(cz.CartonWeight,0.00)
            ,  ISNULL(cz.CartonLength,0.00)
            ,  ISNULL(cz.CartonWidth,0.00), ISNULL(cz.CartonHeight,0.00)
      FROM CARTONIZATION cz (NOLOCK)
      WHERE cz.CartonizationGroup = @c_CartonGroup
      ORDER BY cz.[Cube]

      IF NOT EXISTS (SELECT 1 FROM @t_CZ)
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 64010
         SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                        + ': Cartonization Group ' + TRIM(@c_CartonGroup) + ' not found. (mspRLWAV14_PACK)'
      END
   END

   IF @n_Continue = 1
   BEGIN
      SET @cur_ORD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT pw.Orderkey
      FROM #PICKDETAIL_WIP AS pw
      JOIN ORDERS o (NOLOCK) ON o.Orderkey = pw.Orderkey
      WHERE pw.WaveKey = @c_Wavekey
      AND ISNULL(pw.CaseID,'') = ''
      AND pw.Qty > 0
      AND o.UserDefine10 IN ('Y','N')
      ORDER BY pw.Orderkey

      OPEN @cur_ORD
      FETCH NEXT FROM @cur_ORD INTO @c_Orderkey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         -------------------------------------------------------
         -- UOM = '2'
         -------------------------------------------------------
         INSERT INTO #CartonDetail
            (  PickDetailKey
            ,  OrderKey
            ,  CartonGroup
            ,  CartonType
            ,  CartonSeqNo
            ,  CartonCube
            ,  CartonWeight
            ,  LabelNo
            ,  Storerkey
            ,  Sku
            ,  [Length]
            ,  [Width]
            ,  [Height]
            ,  [Weight]
            ,  UOM
            ,  Qty
            ,  DropID
            ,  RefPickKey
            ,  RefPickMode
            ,  Notes
            ,  [Status]
            )
         SELECT
               pw.PickDetailKey
            ,  pw.OrderKey
            ,  CartonGroup = @c_CartonGroup
            ,  CartonType  = 'BOX'
            ,  CartonSeqNo = DENSE_RANK() OVER ( ORDER BY pw.DropID )
            ,  CartonCube  = 0
            ,  CartonWeight= 0
            ,  LabelNo     = ''
            ,  Storerkey   = @c_Storerkey
            ,  pw.Sku
            ,  [Length]    = ISNULL(p.LengthUOM1,0)
            ,  [Width]     = ISNULL(p.WidthUOM1,0)
            ,  [Height]    = ISNULL(p.HeightUOM1,0)
            ,  [Weight]    = ISNULL(s.NetWgt,0) * pw.Qty
            ,  pw.UOM
            ,  pw.Qty
            ,  DropID      = pw.DropID
            ,  RefPickKey  = pw.PickDetailKey
            ,  RefPickMode = ''
            ,  Notes       = ''
            ,  [Status]    = '9'
         FROM #PICKDETAIL_WIP AS pw
         JOIN SKU s (NOLOCK) ON s.Storerkey = pw.Storerkey
                             AND s.Sku = pw.Sku
         JOIN PACK p (NOLOCK) ON p.PackKey = s.PackKey
         WHERE pw.Orderkey = @c_Orderkey
         AND ISNULL(pw.CaseID,'') = ''
         AND pw.Qty > 0
         AND pw.UOM = '2'
         ORDER BY pw.PickDetailKey

         -------------------------------------------------------
         -- UOM = '6': GROUP BY SKU, SUM(Qty), cartonize by volume
         -- Split across cartons + RefPickMode S/N
         -------------------------------------------------------
         SET @n_CartonSeqNo = 0
         SELECT TOP 1 @n_CartonSeqNo = cd.CartonSeqNo
         FROM #CartonDetail AS cd
         WHERE cd.OrderKey = @c_Orderkey
         ORDER BY cd.CartonSeqNo DESC

         SET @cur_UOM6 = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT pw.Sku
              , Qty      = SUM(pw.Qty)
              , CubeUOM3 = ISNULL(MAX(p.CubeUOM3),0)
              , NetWgt   = ISNULL(MAX(s.NetWgt),0)
         FROM #PICKDETAIL_WIP AS pw
         JOIN SKU s (NOLOCK) ON s.Storerkey = @c_Storerkey
                             AND s.Sku = pw.Sku
         JOIN PACK p (NOLOCK) ON p.PackKey = s.PackKey
         WHERE pw.OrderKey = @c_Orderkey
         AND ISNULL(pw.CaseID,'') = ''
         AND pw.Qty > 0
         AND pw.UOM = '6'
         GROUP BY pw.Sku
         ORDER BY pw.Sku

         OPEN @cur_UOM6
         FETCH NEXT FROM @cur_UOM6 INTO @c_Sku, @n_Qty, @n_CubeUOM3, @n_NetWgt

         WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
         BEGIN
            SET @n_QtyLeft = @n_Qty
            SET @n_LineCBM = @n_CubeUOM3 * @n_QtyLeft
            SET @c_CartonType = ''
            SET @n_Length = 0
            SET @n_Width  = 0
            SET @n_Height = 0
            SET @n_Cube   = 0
            SET @n_CartonWeight = 0
            SET @c_PickDetailKey = ''
            SET @n_Qty_pd = 0
            SET @c_RefPickKey = ''
            SET @c_RefPickMode = ''
            
            -- Prefer smallest carton that fits total SKU volume
            SELECT TOP 1
                   @c_CartonType   = cz.CartonType
                 , @n_Cube         = cz.[Cube]
                 , @n_Length       = cz.CartonLength
                 , @n_Width        = cz.CartonWidth
                 , @n_Height       = cz.CartonHeight
                 , @n_CartonWeight = ISNULL(cz.CartonWeight,0)
            FROM @t_CZ AS cz
            WHERE cz.[Cube] >= @n_LineCBM
            ORDER BY cz.[Cube]

            -- Else use largest and split across cartons
            IF ISNULL(@c_CartonType,'') = ''
            BEGIN
               SELECT TOP 1
                      @c_CartonType   = cz.CartonType
                    , @n_Cube         = cz.[Cube]
                    , @n_Length       = cz.CartonLength
                    , @n_Width        = cz.CartonWidth
                    , @n_Height       = cz.CartonHeight
                    , @n_CartonWeight = ISNULL(cz.CartonWeight,0)
               FROM @t_CZ AS cz
               ORDER BY cz.[Cube] DESC
            END

            IF ISNULL(@c_CartonType,'') = ''
            BEGIN
               SET @n_Continue = 3
               SET @n_Err = 64040
               SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                              + ': Carton Type not found for OrderKey=' + TRIM(@c_Orderkey)
                              + ' SKU=' + TRIM(@c_Sku)
                              + ' (mspRLWAV14_PACK)'
               BREAK
            END
            
            IF @n_CubeUOM3 > 0 AND @n_Cube > 0
               SET @n_MaxQtyPerCtn = FLOOR(@n_Cube / @n_CubeUOM3)
            ELSE
               SET @n_MaxQtyPerCtn = @n_QtyLeft

            IF @n_MaxQtyPerCtn <= 0
               SET @n_MaxQtyPerCtn = @n_QtyLeft

            -- Keep @n_Qty_pd / @c_RefPickKey / @c_RefPickMode across cartons
            -- so remaining qty on the same pickdetail continues into the next carton
            WHILE @n_QtyLeft > 0 AND @n_Continue = 1
            BEGIN
               SET @n_QtyToPack = CASE WHEN @n_QtyLeft > @n_MaxQtyPerCtn
                                       THEN @n_MaxQtyPerCtn
                                       ELSE @n_QtyLeft END
               SET @n_CartonSeqNo = @n_CartonSeqNo + 1
               SET @n_QtyToPack_cd = @n_QtyToPack
               SET @n_QtyPacked = 0

               -- Do not get next record if pickdetail still have remainqty
               WHILE @n_QtyToPack_cd > 0 AND @n_Continue = 1
               BEGIN
                  IF @n_Qty_pd = 0
                  BEGIN
                     SET @c_RefPickMode = ''
                     SET @c_RefPickKey  = ''
                     SET @c_Notes       = ''

                     SELECT TOP 1
                            @c_RefPickKey = pw.PickDetailKey
                          , @n_Qty_pd     = pw.Qty
                     FROM #PICKDETAIL_WIP AS pw
                     WHERE pw.OrderKey = @c_Orderkey
                     AND pw.Sku = @c_Sku
                     AND pw.UOM = '6'
                     AND ISNULL(pw.CaseID,'') = ''
                     AND pw.Qty > 0
                     AND pw.PickDetailKey > @c_PickDetailKey
                     ORDER BY pw.PickDetailKey

                     SET @n_RowCount = @@ROWCOUNT
                     IF @n_RowCount = 0
                        BREAK

                     SET @c_PickDetailKey = @c_RefPickKey

                     SET @c_Notes = 'RefPickKey: ' + TRIM(@c_RefPickKey)
                                  + ' Qty: ' + CONVERT(NVARCHAR(10), @n_Qty_pd)
                  END

                  SET @n_QtyToPack_ins = @n_QtyToPack_cd
                  IF @n_Qty_pd <= @n_QtyToPack_cd
                     SET @n_QtyToPack_ins = @n_Qty_pd

                  -- blank -> S (first portion of this pickdetail)
                  -- S -> N (subsequent cartons from same pickdetail)
                  IF @c_RefPickMode = ''
                     SET @c_RefPickMode = 'S'
                  ELSE IF @c_RefPickMode = 'S'
                     SET @c_RefPickMode = 'N'

                  SET @n_Qty_pd = @n_Qty_pd - @n_QtyToPack_ins
                  SET @n_QtyToPack_cd = @n_QtyToPack_cd - @n_QtyToPack_ins
                  SET @n_QtyPacked = @n_QtyPacked + @n_QtyToPack_ins

                  SET @n_Weight = @n_NetWgt * @n_QtyToPack_ins

                  INSERT INTO #CartonDetail
                     (  PickDetailKey, OrderKey, CartonGroup, CartonType, CartonSeqNo
                     ,  CartonCube, CartonWeight, LabelNo, Storerkey, Sku
                     ,  [Length], [Width], [Height], [Weight], UOM, Qty
                     ,  DropID, RefPickKey, RefPickMode, Notes, [Status] )
                  SELECT
                        pw.PickDetailKey
                     ,  pw.OrderKey
                     ,  @c_CartonGroup
                     ,  @c_CartonType
                     ,  @n_CartonSeqNo
                     ,  @n_Cube
                     ,  @n_CartonWeight
                     ,  ''
                     ,  @c_Storerkey
                     ,  pw.Sku
                     ,  @n_Length
                     ,  @n_Width
                     ,  @n_Height
                     ,  @n_Weight
                     ,  '6'
                     ,  @n_QtyToPack_ins
                     ,  ''
                     ,  @c_RefPickKey
                     ,  @c_RefPickMode
                     ,  @c_Notes
                     ,  '9'
                  FROM #PICKDETAIL_WIP AS pw
                  WHERE pw.PickDetailKey = @c_RefPickKey
               END  -- consume pickdetails for this carton

               -- Only deduct qty actually packed (avoid phantom drain if no pickdetail found)
               SET @n_QtyLeft = @n_QtyLeft - @n_QtyPacked
               IF @n_QtyPacked <= 0
                  BREAK
            END  -- WHILE SKU qty left

            FETCH NEXT FROM @cur_UOM6 INTO @c_Sku, @n_Qty, @n_CubeUOM3, @n_NetWgt
         END
         CLOSE @cur_UOM6
         DEALLOCATE @cur_UOM6

         IF @n_debug = 1
         BEGIN
            SELECT '#CartonDetail', * FROM #CartonDetail
            WHERE OrderKey = @c_Orderkey
            ORDER BY CartonSeqNo, RowID
         END

         -------------------------------------------------------
         -- BUILD_PACK from #CartonDetail
         -------------------------------------------------------
         IF @n_Continue = 1
            AND EXISTS (SELECT 1 FROM #CartonDetail
                        WHERE OrderKey = @c_Orderkey
                        AND CartonType > ''
                        AND [Status] = '9')
         BEGIN
            EXEC [dbo].[isp_CreatePickSlip]
               @c_Orderkey              = @c_Orderkey
            ,  @c_Loadkey               = ''
            ,  @c_Wavekey               = @c_Wavekey
            ,  @c_PickslipType          = '3'
            ,  @c_ConsolidateByLoad     = 'N'
            ,  @c_Refkeylookup          = 'N'
            ,  @c_LinkPickSlipToPick    = 'N'
            ,  @c_AutoScanIn            = 'N'
            ,  @b_Success               = @b_Success  OUTPUT
            ,  @n_Err                   = @n_Err      OUTPUT
            ,  @c_ErrMsg                = @c_ErrMsg   OUTPUT
            ,  @c_PickSlipWithWavekey   = 'Y'

            IF @b_Success = 0
            BEGIN
               SET @n_Continue = 3
               GOTO ORD_NEXT
            END

            SET @c_PickSlipNo = ''
            SELECT @c_PickSlipNo = ph.PickHeaderKey
            FROM PICKHEADER ph (NOLOCK)
            WHERE ph.Orderkey = @c_Orderkey
            AND   ph.[Zone] = '3'

            IF ISNULL(@c_PickSlipNo,'') = ''
            BEGIN
               SET @n_Continue = 3
               SET @n_Err = 64020
               SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                              + ': PickSlipNo not found. OrderKey=' + TRIM(@c_Orderkey)
                              + ' (mspRLWAV14_PACK)'
               GOTO ORD_NEXT
            END

            IF NOT EXISTS (SELECT 1 FROM PACKHEADER ph (NOLOCK)
                           WHERE ph.PickSlipNo = @c_PickSlipNo)
            BEGIN
               BEGIN TRY
                  INSERT INTO PACKHEADER
                     (  PickSlipNo, Storerkey, Orderkey, Loadkey
                     ,  Consigneekey, [Route], OrderRefNo
                     ,  [Status], CartonGroup, PackStatus )
                  SELECT @c_PickSlipNo, @c_Storerkey, o.Orderkey, ISNULL(o.LoadKey,'')
                        , o.Consigneekey, o.[Route], o.ExternOrderkey
                        , '0', @c_CartonGroup, '0'
                  FROM ORDERS o (NOLOCK)
                  WHERE o.Orderkey = @c_Orderkey
               END TRY
               BEGIN CATCH
                  SET @n_Continue = 3
                  SET @n_Err = ERROR_NUMBER()
                  SET @c_ErrMsg = ERROR_MESSAGE()
                  GOTO ORD_NEXT
               END CATCH
            END

            -------------------------------------------------------
            -- Gen LabelNo + Split/Update PickDetail
            -------------------------------------------------------
            SET @cur_LBL = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT DISTINCT cd.CartonSeqNo
            FROM #CartonDetail AS cd
            WHERE cd.OrderKey = @c_Orderkey
            AND cd.CartonType > ''
            AND cd.[Status] = '9'
            AND cd.LabelNo = ''
            ORDER BY cd.CartonSeqNo

            OPEN @cur_LBL
            FETCH NEXT FROM @cur_LBL INTO @n_CartonSeqNo

            WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
            BEGIN
               SET @c_LabelNo = ''

               EXEC isp_GenUCCLabelNo_Std
                  @cPickslipNo   = @c_PickSlipNo
               ,  @nCartonNo     = 0
               ,  @cLabelNo      = @c_LabelNo   OUTPUT
               ,  @b_success     = @b_Success   OUTPUT
               ,  @n_err         = @n_Err       OUTPUT
               ,  @c_errmsg      = @c_ErrMsg    OUTPUT

               IF @b_Success <> 1
               BEGIN
                  SET @n_Continue = 3
                  SET @n_Err = 64050
                  SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                                 + ': Error Executing isp_GenUCCLabelNo_Std. (mspRLWAV14_PACK)'
                                 + ' ( ' + ISNULL(@c_ErrMsg,'') + ' ) '
                  BREAK
               END

               SET @cur_SPLPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT cd.RowID
                    , cd.Qty
                    , cd.RefPickKey
                    , cd.RefPickMode
               FROM #CartonDetail AS cd
               WHERE cd.OrderKey = @c_Orderkey
               AND cd.CartonSeqNo = @n_CartonSeqNo
               AND cd.CartonType > ''
               AND cd.[Status] = '9'
               ORDER BY cd.RowID

               OPEN @cur_SPLPD
               FETCH NEXT FROM @cur_SPLPD INTO @n_RowID_cd, @n_Qty, @c_RefPickKey, @c_RefPickMode

               WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
               BEGIN
                  IF @c_RefPickMode = 'N'
                  BEGIN
                     -- New pickdetail for remaining carton portion
                     SET @b_Success = 1
                     EXECUTE nspg_getkey
                        @KeyName     = 'Pickdetailkey'
                     ,  @fieldlength = 10
                     ,  @keystring   = @c_NewPickDetailKey OUTPUT
                     ,  @b_success   = @b_Success          OUTPUT
                     ,  @n_err       = @n_Err              OUTPUT
                     ,  @c_errmsg    = @c_ErrMsg           OUTPUT

                     IF @b_Success = 0
                     BEGIN
                        SET @n_Continue = 3
                        BREAK
                     END

                     BEGIN TRY
                        INSERT INTO PickDetail
                           (  PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber
                           ,  Lot, Storerkey, Sku, AltSku, UOM, UOMQty, Qty, QtyMoved, [Status]
                           ,  DropID, Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType
                           ,  ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod
                           ,  WaveKey, EffectiveDate, OptimizeCop, ShipFlag, PickSlipNo
                           ,  Taskdetailkey, TaskManagerReasonkey, Notes, Channel_ID )
                        SELECT @c_NewPickDetailKey, @c_LabelNo, pd.PickHeaderKey, pd.OrderKey, pd.OrderLineNumber
                             , pd.Lot, pd.Storerkey, pd.Sku, pd.AltSku, pd.UOM, cd.Qty, cd.Qty, pd.QtyMoved, pd.[Status]
                             , pd.DropID
                             , pd.Loc, pd.ID, pd.PackKey, pd.UpdateSource, cd.CartonGroup, cd.CartonType
                             , pd.ToLoc, pd.DoReplenish, pd.ReplenishZone, pd.DoCartonize, pd.PickMethod
                             , pd.WaveKey, pd.EffectiveDate, '9', pd.ShipFlag, @c_PickSlipNo
                             , pd.Taskdetailkey, pd.TaskManagerReasonkey, cd.Notes, pd.Channel_ID
                        FROM #CartonDetail AS cd
                        JOIN PickDetail AS pd (NOLOCK) ON pd.PickDetailKey = cd.RefPickKey
                        WHERE cd.RowID = @n_RowID_cd
                     END TRY
                     BEGIN CATCH
                        SET @n_Continue = 3
                        SET @n_Err = ERROR_NUMBER()
                        SET @c_ErrMsg = ERROR_MESSAGE()
                        BREAK
                     END CATCH

                     UPDATE cd
                        SET cd.PickDetailKey = @c_NewPickDetailKey
                          , cd.LabelNo = @c_LabelNo
                     FROM #CartonDetail AS cd
                     WHERE cd.RowID = @n_RowID_cd

                     -- Keep WIP in sync
                     INSERT INTO #PickDetail_WIP
                        (  PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber
                        ,  Lot, Storerkey, Sku, AltSku, UOM, UOMQty, Qty, QtyMoved, [Status]
                        ,  DropID, Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType
                        ,  ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod
                        ,  WaveKey, LoadKey, PickSlipNo, Notes, Channel_ID )
                     SELECT @c_NewPickDetailKey, @c_LabelNo, pw.PickHeaderKey, pw.OrderKey, pw.OrderLineNumber
                          , pw.Lot, pw.Storerkey, pw.Sku, pw.AltSku, pw.UOM, @n_Qty, @n_Qty, pw.QtyMoved, pw.[Status]
                          , pw.DropID
                          , pw.Loc, pw.ID, pw.PackKey, pw.UpdateSource, @c_CartonGroup
                          , cd.CartonType
                          , pw.ToLoc, pw.DoReplenish, pw.ReplenishZone, pw.DoCartonize, pw.PickMethod
                          , pw.WaveKey, pw.LoadKey, @c_PickSlipNo
                          , cd.Notes
                          , pw.Channel_ID
                     FROM #CartonDetail AS cd
                     JOIN #PickDetail_WIP AS pw ON pw.PickDetailKey = cd.RefPickKey
                     WHERE cd.RowID = @n_RowID_cd
                     AND NOT EXISTS (SELECT 1 FROM #PickDetail_WIP x WHERE x.PickDetailKey = @c_NewPickDetailKey)
                  END
                  ELSE
                  BEGIN
                     -- '' or 'S': update existing pickdetail
                     BEGIN TRY
                        UPDATE pd WITH (ROWLOCK)
                           SET pd.CaseID      = @c_LabelNo
                             , pd.Qty         = CASE WHEN @c_RefPickMode = 'S' THEN @n_Qty ELSE pd.Qty END
                             , pd.UOMQty      = CASE WHEN @c_RefPickMode = 'S' THEN @n_Qty ELSE pd.UOMQty END
                             , pd.CartonType  = cd.CartonType
                             , pd.CartonGroup = cd.CartonGroup
                             , pd.PickSlipNo  = @c_PickSlipNo
                             , pd.TrafficCop  = NULL
                             , pd.EditWho     = @c_UserName
                             , pd.EditDate    = GETDATE()
                        FROM #CartonDetail AS cd
                        JOIN PickDetail AS pd ON pd.PickDetailKey = cd.RefPickKey
                        WHERE cd.RowID = @n_RowID_cd
                        AND cd.[Status] = '9'
                     END TRY
                     BEGIN CATCH
                        SET @n_Continue = 3
                        SET @n_Err = ERROR_NUMBER()
                        SET @c_ErrMsg = ERROR_MESSAGE()
                        BREAK
                     END CATCH

                     -- Keep WIP in sync
                     UPDATE pw
                        SET pw.CaseID      = @c_LabelNo
                          , pw.Qty         = CASE WHEN @c_RefPickMode = 'S' THEN @n_Qty ELSE pw.Qty END
                          , pw.UOMQty      = CASE WHEN @c_RefPickMode = 'S' THEN @n_Qty ELSE pw.UOMQty END
                          , pw.CartonType  = cd.CartonType
                          , pw.CartonGroup = @c_CartonGroup
                          , pw.PickSlipNo  = @c_PickSlipNo
                          , pw.EditWho     = @c_UserName
                          , pw.EditDate    = GETDATE()
                     FROM #CartonDetail AS cd
                     JOIN #PickDetail_WIP AS pw ON pw.PickDetailKey = cd.RefPickKey
                     WHERE cd.RowID = @n_RowID_cd
                  END

                  FETCH NEXT FROM @cur_SPLPD INTO @n_RowID_cd, @n_Qty, @c_RefPickKey, @c_RefPickMode
               END
               CLOSE @cur_SPLPD
               DEALLOCATE @cur_SPLPD

               UPDATE cd
                  SET cd.LabelNo = @c_LabelNo
               FROM #CartonDetail AS cd
               WHERE cd.OrderKey = @c_Orderkey
               AND cd.CartonSeqNo = @n_CartonSeqNo
               AND cd.LabelNo = ''
               AND cd.[Status] = '9'

               FETCH NEXT FROM @cur_LBL INTO @n_CartonSeqNo
            END
            CLOSE @cur_LBL
            DEALLOCATE @cur_LBL

            IF @n_Continue = 1
            BEGIN
               SET @n_CartonNo_Last = 0
               SELECT TOP 1 @n_CartonNo_Last = ISNULL(pd.CartonNo,0)
               FROM dbo.PackDetail pd (NOLOCK)
               WHERE pd.PickSlipNo = @c_PickSlipNo
               ORDER BY pd.CartonNo DESC

               BEGIN TRY
                  INSERT INTO dbo.PackDetail
                     (  PickSlipNo, CartonNo, LabelNo, LabelLine
                     ,  Storerkey, Sku, Qty, RefNo )
                  SELECT PickSlipNo = @c_PickSlipNo
                        ,CartonNo   = cd.CartonSeqNo + @n_CartonNo_Last
                        ,cd.LabelNo
                        ,LabelLine  = RIGHT('00000' + CONVERT(NVARCHAR(5),
                                             ROW_NUMBER() OVER (PARTITION BY cd.LabelNo
                                                                ORDER BY cd.CartonSeqNo, cd.Sku)), 5)
                        ,cd.Storerkey
                        ,cd.Sku
                        ,Qty = SUM(cd.Qty)
                        ,RefNo = ''
                  FROM #CartonDetail AS cd
                  WHERE cd.OrderKey = @c_Orderkey
                  AND cd.CartonType > ''
                  AND cd.[Status] = '9'
                  GROUP BY cd.CartonSeqNo, cd.LabelNo, cd.Storerkey, cd.Sku
                  ORDER BY cd.CartonSeqNo, cd.Sku
               END TRY
               BEGIN CATCH
                  SET @n_Continue = 3
                  SET @n_Err = ERROR_NUMBER()
                  SET @c_ErrMsg = ERROR_MESSAGE()
                  GOTO ORD_NEXT
               END CATCH
            END

            IF @n_Continue = 1
            BEGIN
               BEGIN TRY
                  INSERT INTO dbo.PackInfo
                     (  PickSlipNo, CartonNo, [Weight], [Cube], Qty, CartonType
                     ,  [Length], [Width], [Height], RefNo, TrackingNo, UCCNo )
                  SELECT PickSlipNo = @c_PickSlipNo
                        ,CartonNo   = cd.CartonSeqNo + @n_CartonNo_Last
                        ,[Weight]   = SUM(cd.[Weight]) + MAX(cd.CartonWeight)
                        ,[Cube]     = MAX(cd.CartonCube)
                        ,Qty        = SUM(cd.Qty)
                        ,CartonType = MAX(cd.CartonType)
                        ,[Length]   = MAX(cd.[Length])
                        ,[Width]    = MAX(cd.[Width])
                        ,[Height]   = MAX(cd.[Height])
                        ,RefNo      = ''
                        ,TrackingNo = ''
                        ,UCCNo      = ''
                  FROM #CartonDetail AS cd
                  WHERE cd.OrderKey = @c_Orderkey
                  AND cd.CartonType > ''
                  AND cd.[Status] = '9'
                  GROUP BY cd.CartonSeqNo
                  ORDER BY cd.CartonSeqNo
               END TRY
               BEGIN CATCH
                  SET @n_Continue = 3
                  SET @n_Err = ERROR_NUMBER()
                  SET @c_ErrMsg = ERROR_MESSAGE()
                  GOTO ORD_NEXT
               END CATCH
            END

            -- Stamp remaining UOM2 WIP (RefPickMode blank; may not have been touched if CaseID already set)
            IF @n_Continue = 1
            BEGIN
               UPDATE pw
                  SET pw.PickSlipNo  = @c_PickSlipNo
                    , pw.CartonGroup = @c_CartonGroup
                    , pw.CartonType  = cd.CartonType
                    , pw.CaseID      = cd.LabelNo 
                    , pw.EditWho     = @c_UserName
                    , pw.EditDate    = GETDATE()
               FROM #PICKDETAIL_WIP AS pw
               JOIN #CartonDetail cd ON cd.RefPickKey = pw.PickDetailKey
               WHERE pw.Orderkey = @c_Orderkey
               AND pw.UOM = '2'
            END

            IF @n_debug = 2
            BEGIN
               SELECT 'PACKHEADER', * FROM PACKHEADER (NOLOCK) WHERE PickSlipNo = @c_PickSlipNo
               SELECT 'PACKDETAIL', * FROM PACKDETAIL (NOLOCK) WHERE PickSlipNo = @c_PickSlipNo
               SELECT 'PACKINFO',   * FROM PACKINFO   (NOLOCK) WHERE PickSlipNo = @c_PickSlipNo
            END
         END

         ORD_NEXT:
         FETCH NEXT FROM @cur_ORD INTO @c_Orderkey
      END
      CLOSE @cur_ORD
      DEALLOCATE @cur_ORD
   END

   QUIT_SP:
   IF CURSOR_STATUS('LOCAL', '@cur_UOM6') IN (0, 1)
   BEGIN
      CLOSE @cur_UOM6
      DEALLOCATE @cur_UOM6
   END

   IF CURSOR_STATUS('LOCAL', '@cur_LBL') IN (0, 1)
   BEGIN
      CLOSE @cur_LBL
      DEALLOCATE @cur_LBL
   END

   IF CURSOR_STATUS('LOCAL', '@cur_SPLPD') IN (0, 1)
   BEGIN
      CLOSE @cur_SPLPD
      DEALLOCATE @cur_SPLPD
   END

   IF CURSOR_STATUS('LOCAL', '@cur_ORD') IN (0, 1)
   BEGIN
      CLOSE @cur_ORD
      DEALLOCATE @cur_ORD
   END

   IF OBJECT_ID('tempdb..#CartonDetail') IS NOT NULL
      DROP TABLE #CartonDetail

   IF @n_Continue = 3  -- Error Occured - Process And Return
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV14_PACK'
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
END 
GO
GRANT EXECUTE ON [dbo].[mspRLWAV14_PACK] TO [NSQL]
GO
