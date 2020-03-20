IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[isp_r_hk_picking_control_list_06]') AND OBJECTPROPERTY(Id, N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[isp_r_hk_picking_control_list_06]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*************************************************************************/
/* Stored Procedure: isp_r_hk_picking_control_list_06                    */
/* Creation Date: 30-Apr-2019                                            */
/* Copyright: LFL                                                        */
/* Written by: Michael Lam (HK LIT)                                      */
/*                                                                       */
/* Purpose: Picking Control List                                         */
/*                                                                       */
/* Called By: RCM - Popup Discrete Pickslip FPA                          */
/*                  Popup Combine Pickslip FPA                           */
/*            Datawidnow r_hk_picking_control_list_06_1                  */
/*                       r_hk_picking_control_list_06_2                  */
/*                                                                       */
/* PVCS Version: 1.0                                                     */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author   Ver  Purposes                                   */
/* 2019-09-16   ML       1.1  Split subtasks by Pickdetail.PickslipNo    */
/*                            Add keywords SplitLine, ReSplitLine,       */
/*                            AssignPicker, ReAssignPicker               */
/*************************************************************************/

CREATE PROCEDURE [dbo].[isp_r_hk_picking_control_list_06] (
       @as_Key_Type  NVARCHAR(13)
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_DataWindow        NVARCHAR(40)
         , @c_Key               NVARCHAR(10)
         , @c_Type              NVARCHAR(2)
         , @b_FirstPrint        INT
         , @b_Success           INT
         , @n_Err               INT
         , @c_ErrMsg            NVARCHAR(250)
         , @n_AssignPicker      INT
         , @n_SplitLine         INT
         , @b_ReAssign          INT
         , @c_PickdetailKey     NVARCHAR(10)
         , @c_LogicalLocation   NVARCHAR(10)
         , @c_Loc               NVARCHAR(10)
         , @c_Storerkey         NVARCHAR(15)
         , @c_Sku               NVARCHAR(20)
         , @n_Qty               INT
         , @n_TotalTasks        INT
         , @n_AvgTasks          FLOAT
         , @n_Picker            INT
         , @n_PrevPicker        INT
         , @c_PickslipNo        NVARCHAR(20)
         , @c_PickslipNoTemp    NVARCHAR(20)
         , @c_PH_PickslipNo     NVARCHAR(20)
         , @c_PrevPH_PickslipNo NVARCHAR(20)
         , @c_OrderStatus       NVARCHAR(10)
         , @c_PickStatus        NVARCHAR(10)


   SELECT @c_DataWindow = 'r_hk_picking_control_list_06'
        , @c_Key  = LEFT(@as_Key_Type, 10)
        , @c_Type = RIGHT(@as_Key_Type, 2)
        , @b_FirstPrint   = 1
        , @n_AssignPicker = 0
        , @n_SplitLine    = 0
        , @b_ReAssign     = 0

   IF OBJECT_ID('tempdb..#TEMP_PICKHEADER') IS NOT NULL
      DROP TABLE #TEMP_PICKHEADER
   IF OBJECT_ID('tempdb..#TEMP_PICKDETAIL') IS NOT NULL
      DROP TABLE #TEMP_PICKDETAIL
   IF OBJECT_ID('tempdb..#TEMP_PICKTASK') IS NOT NULL
      DROP TABLE #TEMP_PICKTASK
   IF OBJECT_ID('tempdb..#TEMP_PICKTASK2') IS NOT NULL
      DROP TABLE #TEMP_PICKTASK2
   IF OBJECT_ID('tempdb..#TEMP_PICKSLIPNO') IS NOT NULL
      DROP TABLE #TEMP_PICKSLIPNO

   CREATE TABLE #TEMP_PICKDETAIL (
        PickdetailKey   NVARCHAR(20) NULL
      , OrderKey        NVARCHAR(10) NULL
      , LogicalLocation NVARCHAR(10) NULL
      , Loc             NVARCHAR(10) NULL
      , Storerkey       NVARCHAR(15) NULL
      , Sku             NVARCHAR(20) NULL
      , Qty             INT          NULL
      , PickslipNo      NVARCHAR(20) NULL
      , PH_PickslipNo   NVARCHAR(20) NULL
   )


   IF @c_Type = 'WP'
   BEGIN
      IF EXISTS(SELECT TOP 1 1
                FROM dbo.WAVE     WAVE(NOLOCK)
                JOIN dbo.ORDERS     OH(NOLOCK) ON WAVE.Wavekey=OH.Userdefine09
                JOIN dbo.PICKDETAIL PD(NOLOCK) ON OH.Orderkey=PD.Orderkey
                JOIN dbo.SKU       SKU(NOLOCK) ON PD.Storerkey=SKU.Storerkey AND PD.Sku=SKU.Sku
                LEFT JOIN dbo.CODELKUP BRD(NOLOCK) ON BRD.LISTNAME='LORBRAND' AND BRD.Storerkey=SKU.Storerkey AND BRD.Description=SKU.Class
                LEFT JOIN (
                 SELECT Storerkey, ShowFields = LTRIM(RTRIM(UDF01)) + LOWER(LTRIM(RTRIM(Notes))) + LTRIM(RTRIM(UDF01))
                      , SeqNo=ROW_NUMBER() OVER(PARTITION BY Storerkey ORDER BY Code2)
                   FROM dbo.CodeLkup (NOLOCK) WHERE Listname='REPORTCFG' AND Code='SHOWFIELD' AND Long=@c_DataWindow AND Short='Y'
                ) RptCfg
                ON RptCfg.Storerkey=OH.Storerkey AND RptCfg.SeqNo=1
                WHERE OH.Status < '5' AND PD.Qty > 0 AND WAVE.Wavekey = @c_Key
                HAVING (ISNULL(MAX(RptCfg.ShowFields),'') LIKE '%,AllowUserChangePickMethod,%' AND ISNULL(MAX(WAVE.Userdefine03),'')='RDT')
                    OR (ISNULL(MAX(RptCfg.ShowFields),'') LIKE '%,DefaultRDTPick,%'
                        AND NOT (ISNULL(MAX(RptCfg.ShowFields),'') LIKE '%,AllowUserChangePickMethod,%' AND ISNULL(MAX(WAVE.Userdefine03),'')='PICKSLIP'))
                    OR MAX(IIF(BRD.UDF01='RDT',1,0)) = 1
      )
      BEGIN
         IF EXISTS(SELECT TOP 1 1
                   FROM dbo.ORDERS     OH(NOLOCK)
                   JOIN dbo.PICKHEADER PH(NOLOCK) ON OH.Orderkey=PH.Orderkey
                   WHERE OH.Userdefine09=@c_Key
            )
         BEGIN
            SET @b_FirstPrint = 0
         END

         EXEC isp_CreatePickSlip
              @c_Orderkey           = ''
            , @c_Loadkey            = ''
            , @c_Wavekey            = @c_Key
            , @c_PickslipType       = '8'
            , @c_ConsolidateByLoad  = 'N'
            , @c_Refkeylookup       = 'N'
            , @c_LinkPickSlipToPick = 'N'
            , @c_AutoScanIn         = 'N'
            , @b_Success            = @b_Success OUTPUT
            , @n_Err                = @n_Err     OUTPUT
            , @c_ErrMsg             = @c_ErrMsg  OUTPUT

         IF @b_FirstPrint = 0 AND
            EXISTS(SELECT TOP 1 1
                   FROM dbo.ORDERS     OH(NOLOCK)
                   JOIN dbo.PICKHEADER PH(NOLOCK) ON OH.Orderkey=PH.Orderkey
                   WHERE OH.Userdefine09=@c_Key AND PH.Zone='8' AND PH.PickType='0'
            )
         BEGIN
            UPDATE PH WITH(ROWLOCK)
               SET PickType = '1'
                 , TrafficCop = NULL
              FROM dbo.ORDERS     OH(NOLOCK)
              JOIN dbo.PICKHEADER PH ON OH.Orderkey=PH.Orderkey
             WHERE OH.Userdefine09=@c_Key AND PH.Zone='8' AND PH.PickType='0'
         END
      END

      SELECT @n_AssignPicker = TRY_PARSE(REPLACE(REPLACE(UserDefine04,'ReAssignPicker=',''),'AssignPicker=','') AS FLOAT)
           , @n_SplitLine    = TRY_PARSE(REPLACE(REPLACE(UserDefine04,'ReSplitLine=',''),'SplitLine=','') AS FLOAT)
           , @b_ReAssign     = IIF(LTRIM(UserDefine04) LIKE 'ReAssignPicker=%' OR LTRIM(UserDefine04) LIKE 'ReSplitLine=%', 1, 0)
        FROM dbo.WAVE (NOLOCK)
      WHERE Wavekey = @c_Key
        AND (LTRIM(UserDefine04) LIKE 'ReAssignPicker=%' OR LTRIM(UserDefine04) LIKE 'AssignPicker=%'
          OR LTRIM(UserDefine04) LIKE 'ReSplitLine=%'    OR LTRIM(UserDefine04) LIKE 'SplitLine=%')

      SELECT @c_OrderStatus = MAX(OH.Status)
           , @c_PickStatus  = MAX(PD.Status)
           , @c_PickslipNo  = MIN(ISNULL(PD.PickslipNo,''))
        FROM dbo.ORDERS OH(NOLOCK)
        JOIN dbo.PICKDETAIL PD(NOLOCK) ON OH.Orderkey=PD.Orderkey
       WHERE OH.Userdefine09 = @c_Key AND @c_Key<>''

      IF (@n_AssignPicker > 0 OR @n_SplitLine > 0) AND (@c_PickslipNo='' OR @b_ReAssign=1) AND @c_OrderStatus<'3' AND @c_PickStatus='0'
      BEGIN
         INSERT INTO #TEMP_PICKDETAIL (PickdetailKey, OrderKey, LogicalLocation, Loc, Storerkey, Sku, Qty, PickslipNo)
         SELECT PickdetailKey   = PD.PickdetailKey
              , OrderKey        = PD.OrderKey
              , LogicalLocation = IIF(PD.ToLoc<>'', LOC2.LogicalLocation, LOC1.LogicalLocation)
              , Loc             = IIF(PD.ToLoc<>'', LOC2.Loc, LOC1.Loc)
              , Storerkey       = PD.Storerkey
              , Sku             = PD.Sku
              , Qty             = PD.Qty
              , PickslipNo      = PD.PickslipNo
           FROM dbo.ORDERS OH(NOLOCK)
           JOIN dbo.PICKDETAIL PD(NOLOCK) ON OH.Orderkey=PD.Orderkey
           LEFT JOIN dbo.LOC LOC1(NOLOCK) ON PD.Loc=LOC1.Loc
           LEFT JOIN dbo.LOC LOC2(NOLOCK) ON PD.ToLoc=LOC2.Loc AND PD.ToLoc<>''
          WHERE OH.Userdefine09 = @c_Key AND @c_Key<>'' AND PD.Status = '0'
      END
   END
   ELSE IF @c_Type = 'LP'
   BEGIN
      IF EXISTS(SELECT TOP 1 1
                FROM dbo.LOADPLAN   LP(NOLOCK)
                JOIN dbo.ORDERS     OH(NOLOCK) ON LP.Loadkey=OH.Loadkey
                JOIN dbo.PICKDETAIL PD(NOLOCK) ON OH.Orderkey=PD.Orderkey
                JOIN dbo.SKU       SKU(NOLOCK) ON PD.Storerkey=SKU.Storerkey AND PD.Sku=SKU.Sku
                LEFT JOIN dbo.CODELKUP BRD(NOLOCK) ON BRD.LISTNAME='LORBRAND' AND BRD.Storerkey=SKU.Storerkey AND BRD.Description=SKU.Class
                LEFT JOIN (
                 SELECT Storerkey, ShowFields = LTRIM(RTRIM(UDF01)) + LOWER(LTRIM(RTRIM(Notes))) + LTRIM(RTRIM(UDF01))
                      , SeqNo=ROW_NUMBER() OVER(PARTITION BY Storerkey ORDER BY Code2)
                   FROM dbo.CodeLkup (NOLOCK) WHERE Listname='REPORTCFG' AND Code='SHOWFIELD' AND Long=@c_DataWindow AND Short='Y'
                ) RptCfg
                ON RptCfg.Storerkey=OH.Storerkey AND RptCfg.SeqNo=1
                WHERE OH.Status < '5' AND PD.Qty > 0 AND LP.Loadkey = @c_Key
                HAVING (ISNULL(MAX(RptCfg.ShowFields),'') LIKE '%,AllowUserChangePickMethod,%' AND ISNULL(MAX(LP.Userdefine03),'')='RDT')
                    OR (ISNULL(MAX(RptCfg.ShowFields),'') LIKE '%,DefaultRDTPick,%'
                        AND NOT (ISNULL(MAX(RptCfg.ShowFields),'') LIKE '%,AllowUserChangePickMethod,%' AND ISNULL(MAX(LP.Userdefine03),'')='PICKSLIP'))
                    OR MAX(IIF(BRD.UDF01='RDT',1,0)) = 1
      )
      BEGIN
         IF EXISTS(SELECT TOP 1 1
                   FROM dbo.ORDERS     OH(NOLOCK)
                   JOIN dbo.PICKHEADER PH(NOLOCK) ON OH.Loadkey=PH.ExternOrderkey AND PH.Orderkey='' AND OH.Loadkey<>''
                   WHERE OH.Loadkey=@c_Key
            )
         BEGIN
            SET @b_FirstPrint = 0
         END

         IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.ORDERS(NOLOCK) WHERE Loadkey=@c_Key AND ISNULL(Userdefine08,'')<>'N')
         BEGIN
            EXEC isp_CreatePickSlip
                 @c_Orderkey           = ''
               , @c_Loadkey            = @c_Key
               , @c_Wavekey            = ''
               , @c_PickslipType       = '9'
               , @c_ConsolidateByLoad  = 'Y'
               , @c_Refkeylookup       = 'N'
               , @c_LinkPickSlipToPick = 'N'
               , @c_AutoScanIn         = 'N'
               , @b_Success            = @b_Success OUTPUT
               , @n_Err                = @n_Err     OUTPUT
               , @c_ErrMsg             = @c_ErrMsg  OUTPUT
         END

         IF @b_FirstPrint = 0 AND
            EXISTS(SELECT TOP 1 1
                   FROM dbo.ORDERS     OH(NOLOCK)
                   JOIN dbo.PICKHEADER PH(NOLOCK) ON OH.Loadkey=PH.ExternOrderkey AND PH.Orderkey='' AND OH.Loadkey<>''
                   WHERE OH.Loadkey=@c_Key AND PH.Zone='9' AND PH.PickType='0'
            )
         BEGIN
            UPDATE PH WITH(ROWLOCK)
               SET PickType = '1'
                 , TrafficCop = NULL
              FROM dbo.ORDERS     OH(NOLOCK)
              JOIN dbo.PICKHEADER PH ON OH.Loadkey=PH.ExternOrderkey AND PH.Orderkey='' AND OH.Loadkey<>''
             WHERE OH.Loadkey=@c_Key AND PH.Zone='9' AND PH.PickType='0'
         END
      END


      SELECT @n_AssignPicker = TRY_PARSE(REPLACE(REPLACE(UserDefine04,'ReAssignPicker=',''),'AssignPicker=','') AS FLOAT)
           , @n_SplitLine    = TRY_PARSE(REPLACE(REPLACE(UserDefine04,'ReSplitLine=',''),'SplitLine=','') AS FLOAT)
           , @b_ReAssign     = IIF(LTRIM(UserDefine04) LIKE 'ReAssignPicker=%' OR LTRIM(UserDefine04) LIKE 'ReSplitLine=%', 1, 0)
        FROM dbo.LOADPLAN (NOLOCK)
      WHERE Loadkey = @c_Key
        AND (LTRIM(UserDefine04) LIKE 'ReAssignPicker=%' OR LTRIM(UserDefine04) LIKE 'AssignPicker=%'
          OR LTRIM(UserDefine04) LIKE 'ReSplitLine=%'    OR LTRIM(UserDefine04) LIKE 'SplitLine=%')


      SELECT @c_OrderStatus = MAX(OH.Status)
           , @c_PickStatus  = MAX(PD.Status)
           , @c_PickslipNo  = MIN(ISNULL(PD.PickslipNo,''))
        FROM dbo.ORDERS OH(NOLOCK)
        JOIN dbo.PICKDETAIL PD(NOLOCK) ON OH.Orderkey=PD.Orderkey
       WHERE OH.Loadkey = @c_Key AND @c_Key<>''

      IF (@n_AssignPicker > 0 OR @n_SplitLine > 0) AND (@c_PickslipNo='' OR @b_ReAssign=1) AND @c_OrderStatus<'3' AND @c_PickStatus='0'
      BEGIN
         INSERT INTO #TEMP_PICKDETAIL (PickdetailKey, OrderKey, LogicalLocation, Loc, Storerkey, Sku, Qty, PickslipNo)
         SELECT PickdetailKey   = PD.PickdetailKey
              , OrderKey        = PD.OrderKey
              , LogicalLocation = IIF(PD.ToLoc<>'', LOC2.LogicalLocation, LOC1.LogicalLocation)
              , Loc             = IIF(PD.ToLoc<>'', LOC2.Loc, LOC1.Loc)
              , Storerkey       = PD.Storerkey
              , Sku             = PD.Sku
              , Qty             = PD.Qty
              , PickslipNo      = PD.PickslipNo
           FROM dbo.ORDERS OH(NOLOCK)
           JOIN dbo.PICKDETAIL PD(NOLOCK) ON OH.Orderkey=PD.Orderkey
           LEFT JOIN dbo.LOC LOC1(NOLOCK) ON PD.Loc=LOC1.Loc
           LEFT JOIN dbo.LOC LOC2(NOLOCK) ON PD.ToLoc=LOC2.Loc AND PD.ToLoc<>''
          WHERE OH.Loadkey = @c_Key AND @c_Key<>'' AND PD.Status = '0'
      END
   END


   -- #TEMP_PICKHEADER
   SELECT Orderkey     = OH.Orderkey
        , PickslipNo   = MAX(ISNULL(PH1.PickHeaderKey,PH2.PickHeaderKey))
        , IsConsol     = MAX(IIF(PH2.PickHeaderKey IS NOT NULL, 'Y', 'N'))
        , Userdefine03 = MAX(IIF(PH2.PickHeaderKey IS NOT NULL, LP.Userdefine03, WAVE.Userdefine03))
        , PrintedFlag  = MAX(IIF(PH2.PickHeaderKey IS NOT NULL, PH2.PickType, PH1.PickType))
        , FOK          = MIN(OH.Orderkey) OVER(PARTITION BY MAX(ISNULL(PH1.PickHeaderKey,PH2.PickHeaderKey)))
        , Storerkey    = MAX(OH.Storerkey)

   INTO #TEMP_PICKHEADER

   FROM dbo.ORDERS OH(NOLOCK)
   LEFT JOIN dbo.PICKHEADER PH1(NOLOCK) ON OH.Orderkey = PH1.Orderkey AND ISNULL(OH.Orderkey,'')<>''
   LEFT JOIN dbo.PICKHEADER PH2(NOLOCK) ON OH.Loadkey = PH2.ExternOrderkey AND ISNULL(OH.Loadkey,'')<>'' AND ISNULL(PH2.Orderkey,'')=''
   LEFT JOIN dbo.WAVE      WAVE(NOLOCK) ON OH.Userdefine09=WAVE.Wavekey AND ISNULL(OH.Userdefine09,'')<>'' AND PH1.PickheaderKey IS NOT NULL
   LEFT JOIN dbo.LOADPLAN    LP(NOLOCK) ON OH.Loadkey=LP.Loadkey AND ISNULL(OH.Loadkey,'')<>''  AND PH2.PickheaderKey IS NOT NULL

   WHERE OH.Status >= '1' AND OH.Status <= '9'
     AND (PH1.PickheaderKey IS NOT NULL OR PH2.PickheaderKey IS NOT NULL)
     AND ( @c_Type = 'WP' OR @c_Type = 'LP' )
     AND ((@c_Type = 'WP' AND OH.Userdefine09 = @c_Key)
       OR (@c_Type = 'LP' AND OH.Loadkey      = @c_Key)
         )
   GROUP BY OH.Orderkey


   -- Assign Picker
   UPDATE a SET PH_PickslipNo = b.PickslipNo
     FROM #TEMP_PICKDETAIL a
     JOIN #TEMP_PICKHEADER b ON a.OrderKey = b.OrderKey

   SELECT DISTINCT PH_PickslipNo, LogicalLocation, Loc, Storerkey, Sku
     INTO #TEMP_PICKTASK
     FROM #TEMP_PICKDETAIL
    WHERE Qty>0
    ORDER BY 1,2,3,4,5

   SET @n_TotalTasks = 0
   SELECT @n_TotalTasks = COUNT(1) FROM #TEMP_PICKTASK

   IF @n_SplitLine > 0
   BEGIN
      SET @n_AssignPicker = FLOOR( CAST(@n_TotalTasks AS FLOAT) / @n_SplitLine + (1 - 5.1 / @n_SplitLine) )    -- max 5 more lines
      IF ISNULL(@n_AssignPicker,0)<=0
         SET @n_AssignPicker = 1
   END
   SET @n_AvgTasks = CAST(@n_TotalTasks AS FLOAT) / @n_AssignPicker


   IF ISNULL(@n_AssignPicker,0) <= 0 AND ISNULL(@n_SplitLine,0) <= 0
   BEGIN
      UPDATE PD WITH(ROWLOCK)
         SET PickslipNo = RTRIM(a.PickslipNo)
           , AltSku     = ''
           , Trafficcop = NULL
      FROM #TEMP_PICKHEADER a
      JOIN PICKDETAIL PD ON a.Orderkey = PD.Orderkey
      WHERE PD.Status = '0' AND ISNULL(PD.PickslipNo,'')<>ISNULL(a.PickslipNo,'')
   END
   ELSE IF EXISTS(SELECT TOP 1 1 FROM #TEMP_PICKTASK) AND ISNULL(@n_AvgTasks,0)>0
   BEGIN
      SELECT DISTINCT PickslipNo
        INTO #TEMP_PICKSLIPNO
        FROM #TEMP_PICKDETAIL
       WHERE PickslipNo LIKE 'T%'
       ORDER BY 1

      SELECT @n_PrevPicker = 0
           , @c_PrevPH_PickslipNo = ''
           , @c_PickslipNo = ''

      UPDATE PD WITH (ROWLOCK)
         SET PickslipNo = NULL
           , AltSku     = ''
           , Trafficcop = NULL
        FROM #TEMP_PICKDETAIL a
        JOIN dbo.PICKDETAIL PD ON a.PickdetailKey=PD.PickdetailKey
       WHERE PD.Status='0'

      SELECT PH_PickslipNo, LogicalLocation, Loc, Storerkey, Sku
           , Picker=FLOOR((ROW_NUMBER() OVER(ORDER BY PH_PickslipNo, LogicalLocation, Loc, Storerkey, Sku)-1) / @n_AvgTasks) + 1
           , PH_PickslipNo_Used = 0
        INTO #TEMP_PICKTASK2
        FROM #TEMP_PICKTASK

      DECLARE C_PICKTASK CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT PH_PickslipNo, LogicalLocation, Loc, Storerkey, Sku, Picker
        FROM #TEMP_PICKTASK2
       ORDER BY 1,2,3,4,5

      OPEN C_PICKTASK

      WHILE 1=1
      BEGIN
         FETCH NEXT FROM C_PICKTASK
          INTO @c_PH_PickslipNo, @c_LogicalLocation, @c_Loc, @c_Storerkey, @c_Sku, @n_Picker

         IF @@FETCH_STATUS<>0
            BREAK

         IF @n_Picker<>@n_PrevPicker OR
            ISNULL(@c_PH_PickslipNo,'')<>ISNULL(@c_PrevPH_PickslipNo,'') OR
            ISNULL(@c_PickslipNo,'') = ''
         BEGIN
            SELECT @n_PrevPicker        = @n_Picker
                 , @c_PrevPH_PickslipNo = @c_PH_PickslipNo
                 , @c_PickslipNoTemp    = ''

            IF (SELECT COUNT(DISTINCT Picker) FROM #TEMP_PICKTASK2 WHERE PH_PickslipNo=@c_PH_PickslipNo)=1 AND
               EXISTS(SELECT TOP 1 1 FROM #TEMP_PICKTASK2 WHERE PH_PickslipNo=@c_PH_PickslipNo AND PH_PickslipNo_Used=0)
            BEGIN
               SET @c_PickslipNoTemp = @c_PH_PickslipNo
               UPDATE #TEMP_PICKTASK2 SET PH_PickslipNo_Used=1 WHERE PH_PickslipNo=@c_PH_PickslipNo AND PH_PickslipNo_Used=0
            END
            ELSE IF EXISTS(SELECT TOP 1 1 FROM #TEMP_PICKSLIPNO)
            BEGIN
               SELECT @c_PickslipNoTemp = MIN(PickslipNo) FROM #TEMP_PICKSLIPNO
               IF ISNULL(@c_PickslipNoTemp,'')<>''
                  DELETE FROM #TEMP_PICKSLIPNO WHERE PickslipNo = @c_PickslipNoTemp
            END

            IF ISNULL(@c_PickslipNoTemp,'')=''
            BEGIN
               EXECUTE nspg_GetKey 'PICKSLIP', 9, @c_PickslipNoTemp OUTPUT, 0, 0, ''
               SET @c_PickslipNoTemp = 'T' + @c_PickslipNoTemp
            END

            IF ISNULL(@c_PickslipNoTemp,'')<>''
            BEGIN
               SET @c_PickslipNo = @c_PickslipNoTemp
            END
         END

         UPDATE PD WITH (ROWLOCK)
            SET PickslipNo = RTRIM(@c_PickslipNo)
              , AltSku     = 'Picker-' + RIGHT(SPACE(10)+ISNULL(CONVERT(VARCHAR(10),@n_Picker),''),2) +'/'+ ISNULL(CONVERT(VARCHAR(10),@n_AssignPicker),'')
              , Trafficcop = NULL
           FROM #TEMP_PICKDETAIL a
           JOIN dbo.PICKDETAIL PD ON a.PickdetailKey=PD.PickdetailKey
          WHERE a.PH_PickslipNo = @c_PH_PickslipNo AND a.LogicalLocation=@c_LogicalLocation
            AND a.Loc=@c_Loc AND a.Storerkey=@c_Storerkey AND a.Sku=@c_Sku
            AND PD.Status='0'
      END

      CLOSE C_PICKTASK
      DEALLOCATE C_PICKTASK
   END


   IF EXISTS(SELECT TOP 1 1
               FROM #TEMP_PICKHEADER a
               JOIN dbo.PICKDETAIL b(NOLOCK) ON a.Orderkey=b.Orderkey
              WHERE ISNULL(b.PickslipNo,'')='')
   BEGIN
      UPDATE PD WITH(ROWLOCK)
         SET PickslipNo = X.PickslipNo
           , AltSku     = X.AltSku
      FROM dbo.PICKDETAIL PD
      JOIN (
         SELECT *
         FROM (
            SELECT Orderkey
                 , AltSku
                 , PickslipNo
                 , SeqNo = ROW_NUMBER() OVER(PARTITION BY Orderkey ORDER BY PickslipNo DESC, AltSku DESC)
            FROM dbo.PICKDETAIL (NOLOCK)
            WHERE ISNULL(PickslipNo,'')<>''
              AND Orderkey IN (
                     SELECT DISTINCT b.Orderkey
                       FROM #TEMP_PICKHEADER a
                       JOIN dbo.PICKDETAIL b(NOLOCK) ON a.Orderkey=b.Orderkey
                      WHERE ISNULL(b.PickslipNo,'')=''
                  )
         ) X
         WHERE X.SeqNo=1
      ) X ON PD.Orderkey = X.Orderkey
      WHERE ISNULL(PD.PickslipNo,'')=''
   END


   TRUNCATE TABLE #TEMP_PICKDETAIL
   IF @c_Type = 'WP'
   BEGIN
      IF EXISTS(SELECT TOP 1 1 FROM dbo.WAVE (NOLOCK) WHERE Wavekey = @c_Key
                AND (LTRIM(UserDefine04) LIKE 'ReAssignPicker=%' OR LTRIM(UserDefine04) LIKE 'ReSplitLine=%'))
      BEGIN
         UPDATE dbo.WAVE WITH(ROWLOCK)
            SET UserDefine04 = RTRIM(REPLACE(REPLACE(UserDefine04, 'ReAssignPicker=', 'AssignPicker='), 'ReSplitLine=', 'SplitLine='))
          WHERE Wavekey = @c_Key
            AND (LTRIM(UserDefine04) LIKE 'ReAssignPicker=%' OR LTRIM(UserDefine04) LIKE 'ReSplitLine=%')
      END

      INSERT INTO #TEMP_PICKDETAIL (PickdetailKey, PickslipNo)
      SELECT PickdetailKey   = PD.PickdetailKey
           , PickslipNo      = PD.PickslipNo
        FROM dbo.ORDERS OH(NOLOCK)
        JOIN dbo.PICKDETAIL PD(NOLOCK) ON OH.Orderkey=PD.Orderkey
       WHERE OH.Userdefine09 = @c_Key AND @c_Key<>'' AND PD.PickslipNo<>''
   END
   ELSE IF @c_Type = 'LP'
   BEGIN
      IF EXISTS(SELECT TOP 1 1 FROM dbo.LOADPLAN (NOLOCK) WHERE Loadkey = @c_Key
                AND (LTRIM(UserDefine04) LIKE 'ReAssignPicker=%' OR LTRIM(UserDefine04) LIKE 'ReSplitLine=%'))
      BEGIN
         UPDATE dbo.LOADPLAN WITH(ROWLOCK)
            SET UserDefine04 = RTRIM(REPLACE(REPLACE(UserDefine04, 'ReAssignPicker=', 'AssignPicker='), 'ReSplitLine=', 'SplitLine='))
          WHERE Loadkey = @c_Key
            AND (LTRIM(UserDefine04) LIKE 'ReAssignPicker=%' OR LTRIM(UserDefine04) LIKE 'ReSplitLine=%')
      END

      INSERT INTO #TEMP_PICKDETAIL (PickdetailKey, PickslipNo)
      SELECT PickdetailKey   = PD.PickdetailKey
           , PickslipNo      = PD.PickslipNo
        FROM dbo.ORDERS OH(NOLOCK)
        JOIN dbo.PICKDETAIL PD(NOLOCK) ON OH.Orderkey=PD.Orderkey
       WHERE OH.Loadkey = @c_Key AND @c_Key<>'' AND PD.PickslipNo<>''
   END



   -- Final Result
   SELECT PickslipNo        = RTRIM( PH.PickslipNo )
        , CustomerGroupCode = RTRIM( MAX( ST.CustomerGroupCode ) )
        , Orderkey          = RTRIM( MAX( IIF(PH.IsConsol='Y', '', FOH.Orderkey) ) )
        , ExternOrderkey    = RTRIM( MAX( IIF(PH.IsConsol='Y', '', FOH.ExternOrderkey) ) )
        , Status            = RTRIM( MIN( FOH.Status ) )
        , Loadkey           = RTRIM( MAX( IIF(PH.IsConsol='Y', FOH.Loadkey, '') ) )
        , Wavekey           = RTRIM( MAX( IIF(PH.IsConsol='Y', '', FOH.Userdefine09) ) )
        , DeliveryDate      = MAX( CONVERT(DATETIME, CONVERT(VARCHAR(10),FOH.DeliveryDate,120)) )
        , Type              = RTRIM( ISNULL( MAX( FOH.Type ), '') )
        , Notes             = RTRIM( ISNULL( MAX( FOH.Notes ), '') )
        , Notes2            = RTRIM( ISNULL( MAX( FOH.Notes2 ), '') )
        , Userdefine05      = RTRIM( ISNULL( MAX( FOH.Userdefine05 ), '') )
        , C_Company         = RTRIM( ISNULL( MAX( FOH.C_Company ), '') )
        , C_Address1        = RTRIM( ISNULL( MAX( FOH.C_Address1 ), '') )
        , C_Address2        = RTRIM( ISNULL( MAX( FOH.C_Address2 ), '') )
        , C_Address3        = RTRIM( ISNULL( MAX( FOH.C_Address3 ), '') )
        , C_Address4        = RTRIM( ISNULL( MAX( FOH.C_Address4 ), '') )
        , Route             = RTRIM( ISNULL( MAX( FOH.Route ), '') )
        , AllocQty          = SUM( PD.Qty )
        , CBM               = SUM( PD.Qty * SKU.StdCube )
        , SkuCount          = COUNT( DISTINCT PD.Sku )
        , LocCount          = COUNT( DISTINCT IIF(PD.ToLoc<>'', PD.ToLoc, PD.Loc) )
        , PickDetailCount   = COUNT( DISTINCT IIF(PH.IsConsol='Y', RTRIM(PD.Lot)+'|'+RTRIM(PD.Loc)+'|'+RTRIM(PD.ID), PD.PickdetailKey ) )
        , NoOfTotes         = CASE WHEN ISNULL(TRY_PARSE(ISNULL(MAX(CBM.Long),'') AS FLOAT),0.0)=0.0
                                     OR ISNULL(TRY_PARSE(ISNULL(MAX(RTO.Long),'') AS FLOAT),0.0)=0.0
                                   THEN 0.0
                                   ELSE CEILING(ISNULL(SUM(PD.Qty * SKU.StdCube),0.0) /
                                        ISNULL(TRY_PARSE(ISNULL(MAX(CBM.Long),'') AS FLOAT),0.0) * ISNULL(TRY_PARSE(ISNULL(MAX(RTO.Long),'') AS FLOAT),0.0))
                                   END
        , IsConsol          = MAX( PH.IsConsol )
        , HasReplen         = IIF(ISNULL(MAX(LOC.LocationCategory),'')='SELECTIVE','Y','N')
        , KeyType           = @c_Type
        , datawindow        = @c_DataWindow
        , Div               = RTRIM( MAX( BRD.Long ) )
        , Brand             = RTRIM( MAX( BRD.Notes ) )
        , PrintedFlag       = RTRIM( MAX( PH.PrintedFlag ) )
        , PickZones         = CAST( CASE MAX( PH.IsConsol )
                              WHEN 'N' THEN
                                 STUFF((SELECT ', ', RTRIM(ISNULL(X.PickZone,'')), RTRIM(X.Replen)
                                 FROM (
                                    SELECT PickZone=IIF(c.ToLoc<>'',e.PickZone,d.PickZone), Replen=IIF(ISNULL(MAX(c.ToLoc),'')<>'', IIF(ISNULL(MIN(c.ToLoc),'')=ISNULL(MAX(c.ToLoc),''), N'■',N'▼'),'')
                                    FROM PICKHEADER      a(NOLOCK)
                                    LEFT JOIN PICKDETAIL c(NOLOCK) ON a.Orderkey=c.Orderkey
                                    LEFT JOIN LOC        d(NOLOCK) ON c.Loc=d.Loc
                                    LEFT JOIN LOC        e(NOLOCK) ON c.ToLoc=e.Loc AND c.ToLoc<>''
                                    WHERE c.PickslipNo = ISNULL(ISNULL(TPD.PickslipNo, PH.PickslipNo), '') AND c.Qty>0
                                 GROUP BY IIF(c.ToLoc<>'',e.PickZone,d.PickZone)
                                 ) X
                                 ORDER BY IIF(X.Replen=N'■',3,IIF(X.Replen=N'▼',2,1)), 2
                                 FOR XML PATH('')), 1, 2, '')

                              WHEN 'Y' THEN
                                 STUFF((SELECT ', ', RTRIM(ISNULL(X.PickZone,'')), RTRIM(X.Replen)
                                 FROM (
                                    SELECT PickZone=IIF(c.ToLoc<>'',e.PickZone,d.PickZone), Replen=IIF(ISNULL(MAX(c.ToLoc),'')<>'', IIF(ISNULL(MIN(c.ToLoc),'')=ISNULL(MAX(c.ToLoc),''), N'■',N'▼'),'')
                                    FROM PICKHEADER      a(NOLOCK)
                                    LEFT JOIN ORDERS     b(NOLOCK) ON a.ExternOrderkey=b.Loadkey AND ISNULL(a.Orderkey,'')=''
                                    LEFT JOIN PICKDETAIL c(NOLOCK) ON b.Orderkey=c.Orderkey
                                    LEFT JOIN LOC        d(NOLOCK) ON c.Loc=d.Loc
                                    LEFT JOIN LOC        e(NOLOCK) ON c.ToLoc=e.Loc AND c.ToLoc<>''
                                    WHERE c.PickslipNo = ISNULL(ISNULL(TPD.PickslipNo, PH.PickslipNo), '') AND c.Qty>0
                                 GROUP BY IIF(c.ToLoc<>'',e.PickZone,d.PickZone)
                                 ) X
                                 ORDER BY IIF(X.Replen=N'■',3,IIF(X.Replen=N'▼',2,1)), 2
                                 FOR XML PATH('')), 1, 2, '')
                              END AS NVARCHAR(4000))
        , ReplenCount       = COUNT(DISTINCT CASE WHEN LOC.LocationCategory='SELECTIVE' THEN DropID END)
        , PD_PickslipNo     = RTRIM( ISNULL(ISNULL(TPD.PickslipNo, PH.PickslipNo), '') )
        , Picker            = RTRIM( IIF( PD.AltSku LIKE 'Picker-%', PD.AltSku, '') )
        , PTL_TaskCount     = COUNT( DISTINCT RTRIM(PD.Loc)+'|'+RTRIM(PD.Sku) )
        , PickSlip_SeqNo    = ROW_NUMBER() OVER(PARTITION BY PH.PickslipNo ORDER BY ISNULL(ISNULL(TPD.PickslipNo, PH.PickslipNo), '') )
        , PickSlip_Count    = COUNT(1) OVER(PARTITION BY PH.PickslipNo)

   FROM #TEMP_PICKHEADER PH
   JOIN dbo.ORDERS        FOH(NOLOCK) ON PH.FOK=FOH.Orderkey
   JOIN dbo.STORER         ST(NOLOCK) ON PH.Storerkey=ST.Storerkey
   JOIN dbo.PICKDETAIL     PD(NOLOCK) ON PH.Orderkey=PD.Orderkey
   JOIN dbo.LOC           LOC(NOLOCK) ON PD.Loc=LOC.Loc
   JOIN dbo.SKU           SKU(NOLOCK) ON PD.Storerkey=SKU.Storerkey AND PD.Sku=SKU.Sku
   LEFT JOIN #TEMP_PICKDETAIL TPD     ON PD.PickDetailKey=TPD.PickdetailKey
   LEFT JOIN dbo.CODELKUP BRD(NOLOCK) ON BRD.LISTNAME='LORBRAND' AND BRD.Storerkey=SKU.Storerkey AND BRD.Description=SKU.Class
   LEFT JOIN dbo.CODELKUP CBM(NOLOCK) ON CBM.LISTNAME='ToteCBM' AND CBM.Storerkey=PH.Storerkey
   LEFT JOIN dbo.CODELKUP RTO(NOLOCK) ON RTO.LISTNAME='Ratio' AND RTO.Storerkey=PH.Storerkey
   LEFT JOIN (
      SELECT Storerkey, ShowFields = LTRIM(RTRIM(UDF01)) + LOWER(LTRIM(RTRIM(Notes))) + LTRIM(RTRIM(UDF01))
           , SeqNo=ROW_NUMBER() OVER(PARTITION BY Storerkey ORDER BY Code2)
        FROM dbo.CodeLkup (NOLOCK) WHERE Listname='REPORTCFG' AND Code='SHOWFIELD' AND Long=@c_DataWindow AND Short='Y'
   ) RptCfg
   ON RptCfg.Storerkey=PH.Storerkey AND RptCfg.SeqNo=1

   WHERE PD.Qty > 0

   GROUP BY PH.PickslipNo
          , ISNULL(ISNULL(TPD.PickslipNo, PH.PickslipNo), '')
          , IIF( PD.AltSku LIKE 'Picker-%', PD.AltSku, '')

   HAVING (ISNULL(MAX(RptCfg.ShowFields),'') LIKE '%,AllowUserChangePickMethod,%' AND ISNULL(MAX(PH.Userdefine03),'')='RDT')
       OR (ISNULL(MAX(RptCfg.ShowFields),'') LIKE '%,DefaultRDTPick,%'
           AND NOT (ISNULL(MAX(RptCfg.ShowFields),'') LIKE '%,AllowUserChangePickMethod,%' AND ISNULL(MAX(PH.Userdefine03),'')='PICKSLIP'))
       OR MAX(IIF(BRD.UDF01='RDT',1,0)) = 1

   ORDER BY CustomerGroupCode, PickslipNo, PickSlip_SeqNo
END
GO
GRANT EXECUTE ON isp_r_hk_picking_control_list_06 TO NSQL
GO