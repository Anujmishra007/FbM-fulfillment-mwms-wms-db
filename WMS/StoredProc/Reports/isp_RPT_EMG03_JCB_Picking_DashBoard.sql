USE [GBRWMS]
GO
/****** Object:  StoredProcedure [BI].[isp_RPT_EMG03_JCB_Picking_DashBoard]    Script Date: 5/25/2026 4:51:43 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_EMG03_JCB_Picking_DashBoard                   */
/* Optimized rewrite candidate                                             */
/* Date         Author  Ver   Purposes                                     */
/* 23/01/2026   AGM046  1.0                                                 */
/* 17/05/2026   SKE140  2.0                                                 */
/* Updates:                                                                  */     
/* Main performance changes:                                               */
/* 1. Materialise reusable CTEs into indexed #temp tables.                  */
/* 2. Read PICKDETAIL once for the parent/split-order family.               */
/* 3. Precompute GroupingKey, AreaKey and JCBCOMPML flag once.              */
/* 4. Restrict ORDERDETAIL, TaskDetail and JCB_TD to #baseOrders only.      */
/* 5. Compute st6/st7 exclusion flags once instead of repeated EXISTS.      */
/*                                                                         */
/****************************************************************************/

CREATE OR ALTER   PROC [BI].[isp_RPT_EMG03_JCB_Picking_DashBoard]
    @delivery_date_limit DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    SET ANSI_NULLS OFF;
    SET QUOTED_IDENTIFIER OFF;
    SET CONCAT_NULL_YIELDS_NULL OFF;

    DECLARE @Now DATETIME = GETDATE();

    -------------------------------------------------------------------------
    -- Cleanup, useful if the proc is rerun in same session after failure
    -------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#baseOrders')     IS NOT NULL DROP TABLE #baseOrders;
    IF OBJECT_ID('tempdb..#orderFamily')    IS NOT NULL DROP TABLE #orderFamily;
    IF OBJECT_ID('tempdb..#CompML')         IS NOT NULL DROP TABLE #CompML;
    IF OBJECT_ID('tempdb..#familyPick')     IS NOT NULL DROP TABLE #familyPick;
    IF OBJECT_ID('tempdb..#pdAgg')          IS NOT NULL DROP TABLE #pdAgg;
    IF OBJECT_ID('tempdb..#nonFinalAgg')    IS NOT NULL DROP TABLE #nonFinalAgg;
    IF OBJECT_ID('tempdb..#scanAgg')        IS NOT NULL DROP TABLE #scanAgg;
    IF OBJECT_ID('tempdb..#odSum')          IS NOT NULL DROP TABLE #odSum;
    IF OBJECT_ID('tempdb..#taskAgg')        IS NOT NULL DROP TABLE #taskAgg;
    IF OBJECT_ID('tempdb..#taskRelease')    IS NOT NULL DROP TABLE #taskRelease;

    -------------------------------------------------------------------------
    -- 1) Visible parent orders only
    -------------------------------------------------------------------------
    SELECT
          o.OrderKey
        , o.StorerKey
        , o.Facility
        , o.LoadKey
        , o.Status
        , o.DeliveryDate
        , o.OrderGroup
        , o.ecom_platform
        , o.UserDefine09
        , o.ExternOrderKey
        , o.Type
        , o.C_Company
        , o.Notes
        , o.Rdd
    INTO #baseOrders
    FROM dbo.ORDERS o WITH (NOLOCK)
    WHERE o.StorerKey = 'JCB'
      AND ISNULL(o.Rdd, '') <> 'SplitOrder'
      AND o.Status IN ('2','3','5')
      AND o.DeliveryDate <= @delivery_date_limit
      AND o.OrderGroup <> 'XDOCK'
      AND o.ecom_platform <> '3RDParty'
      AND o.ecom_platform <> '3RDPartyQty';

    CREATE CLUSTERED INDEX CIX_baseOrders
        ON #baseOrders (StorerKey, OrderKey);

    CREATE INDEX IX_baseOrders_LoadKey
        ON #baseOrders (StorerKey, LoadKey)
        INCLUDE (Facility, UserDefine09, Status, DeliveryDate, Type);

    -------------------------------------------------------------------------
    -- 2) Parent + child split-order family
    -------------------------------------------------------------------------
    SELECT DISTINCT
          x.StorerKey
        , x.ParentOrderKey
        , x.ParentFacility
        , x.FamilyOrderKey
    INTO #orderFamily
    FROM
    (
        SELECT
              b.StorerKey
            , b.OrderKey AS ParentOrderKey
            , b.Facility AS ParentFacility
            , b.OrderKey AS FamilyOrderKey
        FROM #baseOrders b

        UNION ALL

        SELECT
              b.StorerKey
            , b.OrderKey AS ParentOrderKey
            , b.Facility AS ParentFacility
            , c.OrderKey AS FamilyOrderKey
        FROM #baseOrders b
        JOIN dbo.ORDERS c WITH (NOLOCK)
          ON c.StorerKey = b.StorerKey
         AND c.Rdd       = 'SplitOrder'
         AND c.LoadKey   = b.LoadKey
        WHERE NULLIF(LTRIM(RTRIM(b.UserDefine09)), '') IS NOT NULL
    ) x;

    CREATE CLUSTERED INDEX CIX_orderFamily
        ON #orderFamily (StorerKey, FamilyOrderKey, ParentOrderKey);

    CREATE INDEX IX_orderFamily_Parent
        ON #orderFamily (StorerKey, ParentOrderKey, ParentFacility);

    -------------------------------------------------------------------------
    -- 3) Marshalled / complete-location lookup list
    -------------------------------------------------------------------------
    SELECT DISTINCT
          ck.StorerKey
        , ck.Short AS Loc
    INTO #CompML
    FROM dbo.CODELKUP ck WITH (NOLOCK)
    WHERE ck.ListName  = 'JCBCOMPML'
      AND ck.StorerKey = 'JCB'
      AND ck.Short IS NOT NULL;

    CREATE CLUSTERED INDEX CIX_CompML
        ON #CompML (StorerKey, Loc);

    -------------------------------------------------------------------------
    -- 4) Family-level PICKDETAIL read.
    --    This is the expensive section; keep it to one pass.
    -------------------------------------------------------------------------
    ;WITH fp_raw AS
    (
        SELECT
              ofm.StorerKey
            , ofm.ParentOrderKey
            , ofm.ParentFacility
            , pd.OrderKey
            , pd.ID
            , pd.DropID
            , pd.Loc
            , pd.Lot
            , pd.Status
            , la.Lottable11
            , ad.AreaKey
            , CASE WHEN cm.Loc IS NOT NULL THEN 1 ELSE 0 END AS InComplLoc
            , NULLIF(LTRIM(RTRIM(pd.ID)), '') AS IDKey
            , NULLIF(LTRIM(RTRIM(pd.DropID)), '') AS DropIDKey
            , NULLIF(LTRIM(RTRIM(la.Lottable11)), '') AS Lot11Key
            , ROW_NUMBER() OVER
              (
                  PARTITION BY ofm.StorerKey, ofm.ParentOrderKey
                  ORDER BY pd.OrderKey, pd.Loc, pd.Lot, pd.ID, pd.DropID
              ) AS PickRowNum
        FROM #orderFamily ofm
        JOIN dbo.PICKDETAIL pd WITH (NOLOCK)
          ON pd.StorerKey = ofm.StorerKey
         AND pd.OrderKey  = ofm.FamilyOrderKey
        LEFT JOIN dbo.LOTATTRIBUTE la WITH (NOLOCK)
          ON la.StorerKey = pd.StorerKey
         AND la.Lot       = pd.Lot
        LEFT JOIN dbo.LOC l WITH (NOLOCK)
          ON l.Loc      = pd.Loc
         AND l.Facility = 'EMG03'
        LEFT JOIN dbo.AreaDetail ad WITH (NOLOCK)
          ON ad.PutawayZone = l.PutawayZone
        LEFT JOIN #CompML cm
          ON cm.StorerKey = pd.StorerKey
         AND cm.Loc       = pd.Loc
        WHERE NULLIF(LTRIM(RTRIM(pd.OrderKey)), '') IS NOT NULL
    )
    SELECT
          StorerKey
        , ParentOrderKey
        , ParentFacility
        , OrderKey
        , ID
        , DropID
        , Loc
        , Lot
        , Status
        , Lottable11
        , AreaKey
        , InComplLoc
        , CASE
              WHEN IDKey IS NOT NULL AND DropIDKey IS NOT NULL AND Lot11Key IS NOT NULL
                  THEN 'ID|' + IDKey
              WHEN IDKey IS NOT NULL AND Lot11Key IS NOT NULL
                  THEN 'LOT11|' + Lot11Key
              WHEN IDKey IS NOT NULL
                  THEN 'ID|' + IDKey
              WHEN IDKey IS NULL AND DropIDKey IS NULL AND Lot11Key IS NOT NULL
                  THEN 'LOT11|' + Lot11Key
              ELSE 'ROW|' + ParentOrderKey + '|' + CAST(PickRowNum AS varchar(30))
          END AS GroupingKey
    INTO #familyPick
    FROM fp_raw;

    CREATE CLUSTERED INDEX CIX_familyPick
        ON #familyPick (StorerKey, ParentOrderKey, OrderKey);

    CREATE INDEX IX_familyPick_Status
        ON #familyPick (StorerKey, ParentOrderKey, Status)
        INCLUDE (OrderKey, DropID, Loc, InComplLoc);

    CREATE INDEX IX_familyPick_Grouping
        ON #familyPick (StorerKey, ParentOrderKey, GroupingKey)
        INCLUDE (Status, AreaKey);

    CREATE INDEX IX_familyPick_TruckScan
        ON #familyPick (OrderKey, DropID)
        INCLUDE (StorerKey, ParentOrderKey, ParentFacility, Status);

    -------------------------------------------------------------------------
    -- 5) Pallet / case-pallet aggregation and area counts.
    --    Each GroupingKey = one logical business counting unit.
    -------------------------------------------------------------------------
    ;WITH g AS
    (
        SELECT
              fp.StorerKey
            , fp.ParentOrderKey AS OrderKey
            , fp.GroupingKey
            , MAX(CASE WHEN fp.Status IN ('0','1','2','3','4') THEN 1 ELSE 0 END) AS IsRemaining
            , MAX(CASE WHEN fp.AreaKey = 'EMGWA' THEN 1 ELSE 0 END) AS [WIDE]
            , MAX(CASE WHEN fp.AreaKey = 'EMGVNA1' THEN 1 ELSE 0 END) AS [VNA1]
            , MAX(CASE WHEN fp.AreaKey = 'EMGVNA2' THEN 1 ELSE 0 END) AS [VNA2]
            , MAX(CASE WHEN fp.AreaKey = 'EMGVNA3' THEN 1 ELSE 0 END) AS [VNA3]
            , MAX(CASE WHEN fp.AreaKey = 'EMGVNA4' THEN 1 ELSE 0 END) AS [VNA4]
            , MAX(CASE WHEN fp.AreaKey = 'EMGVNA5' THEN 1 ELSE 0 END) AS [VNA5]
            , MAX(CASE WHEN fp.AreaKey = 'EMGBULKINT' THEN 1 ELSE 0 END) AS [BULK-INT]
            , MAX(CASE WHEN fp.AreaKey = 'EMGBULKEXT' THEN 1 ELSE 0 END) AS [BULK-EXT]
            , MAX(CASE WHEN fp.AreaKey IN ('EMGMEZZ','EMGMEZZRAC') THEN 1 ELSE 0 END) AS [MEZZ]
            , MAX(CASE WHEN fp.AreaKey = 'EMGPDOUT' THEN 1 ELSE 0 END) AS [P&D]
            , MAX(CASE WHEN fp.AreaKey = 'EMGCABSKIT' THEN 1 ELSE 0 END) AS [CABSKIT]
            , MAX(CASE WHEN fp.AreaKey = 'EMGLPKIT' THEN 1 ELSE 0 END) AS [LPKIT]
            , MAX(CASE WHEN fp.AreaKey = 'EMGT4KIT' THEN 1 ELSE 0 END) AS [T4]
            , MAX(CASE WHEN fp.AreaKey = 'MOTHERSONS' THEN 1 ELSE 0 END) AS [MOTHERSONS]
        FROM #familyPick fp
        GROUP BY
              fp.StorerKey
            , fp.ParentOrderKey
            , fp.GroupingKey
    )
    SELECT
          StorerKey
        , OrderKey
        , COUNT(*) AS pkdsh_Total_CasPall
        , SUM(IsRemaining) AS pkdsh_Remain_CasPall
        , SUM([WIDE]) AS [WIDE]
        , SUM([VNA1]) AS [VNA1]
        , SUM([VNA2]) AS [VNA2]
        , SUM([VNA3]) AS [VNA3]
        , SUM([VNA4]) AS [VNA4]
        , SUM([VNA5]) AS [VNA5]
        , SUM([BULK-INT]) AS [BULK-INT]
        , SUM([BULK-EXT]) AS [BULK-EXT]
        , SUM([MEZZ]) AS [MEZZ]
        , SUM([P&D]) AS [P&D]
        , SUM([CABSKIT]) AS [CABSKIT]
        , SUM([LPKIT]) AS [LPKIT]
        , SUM([T4]) AS [T4]
        , SUM([MOTHERSONS]) AS [MOTHERSONS]
    INTO #pdAgg
    FROM g
    GROUP BY StorerKey, OrderKey;

    CREATE CLUSTERED INDEX CIX_pdAgg
        ON #pdAgg (StorerKey, OrderKey);

    -------------------------------------------------------------------------
    -- 6) st6/st7 exclusion data.
    --    Kept separate to avoid duplicate rdtScanToTruck rows multiplying counts.
    -------------------------------------------------------------------------
    SELECT
          fp.StorerKey
        , fp.ParentOrderKey AS OrderKey
        , fp.ParentFacility AS Facility
        , SUM(CASE WHEN fp.Status <> '9' THEN 1 ELSE 0 END) AS NonFinalRows
        , SUM(CASE WHEN fp.Status <> '9' AND fp.InComplLoc = 0 THEN 1 ELSE 0 END) AS NonFinalRowsNotInCompML
    INTO #nonFinalAgg
    FROM #familyPick fp
    GROUP BY
          fp.StorerKey
        , fp.ParentOrderKey
        , fp.ParentFacility;

    CREATE CLUSTERED INDEX CIX_nonFinalAgg
        ON #nonFinalAgg (StorerKey, OrderKey, Facility);

    SELECT DISTINCT
          fp.StorerKey
        , fp.ParentOrderKey AS OrderKey
        , fp.ParentFacility AS Facility
    INTO #scanAgg
    FROM #familyPick fp
    JOIN rdt.rdtScanToTruck stt WITH (NOLOCK)
      ON stt.OrderKey = fp.OrderKey
     AND stt.URNNo    = fp.DropID
     AND stt.Status   = '9'
    WHERE fp.Status <> '9';

    CREATE CLUSTERED INDEX CIX_scanAgg
        ON #scanAgg (StorerKey, OrderKey, Facility);

    -------------------------------------------------------------------------
    -- 7) Task release calculation, restricted to current dashboard orders.
    -------------------------------------------------------------------------
    SELECT
          od.OrderKey
        , od.StorerKey
        , od.Facility
        , SUM(od.OpenQty) AS OpenQtySum
    INTO #odSum
    FROM dbo.ORDERDETAIL od WITH (NOLOCK)
    JOIN #baseOrders b
      ON b.StorerKey = od.StorerKey
     AND b.OrderKey  = od.OrderKey
     AND b.Facility  = od.Facility
    GROUP BY
          od.OrderKey
        , od.StorerKey
        , od.Facility;

    CREATE CLUSTERED INDEX CIX_odSum
        ON #odSum (StorerKey, OrderKey, Facility);

    SELECT
          t.OrderKey
        , t.StorerKey
        , SUM(t.Qty) AS TaskQtySum
        , SUM(CASE WHEN t.Status = '9' THEN 1 ELSE 0 END) AS Status9Cnt
        , SUM(CASE WHEN t.Status <> '9' THEN 1 ELSE 0 END) AS StatusNot9Cnt
    INTO #taskAgg
    FROM
    (
        SELECT
              td.OrderKey
            , td.StorerKey
            , td.Qty
            , td.Status
        FROM dbo.TaskDetail td WITH (NOLOCK)
        JOIN #baseOrders b
          ON b.StorerKey = td.StorerKey
         AND b.OrderKey  = td.OrderKey
        WHERE td.StorerKey = 'JCB'
          AND td.TaskType  = 'FCP'
          AND td.Status   <> '9'

        UNION ALL

        SELECT
              jtd.OrderKey
            , jtd.StorerKey
            , jtd.Qty
            , jtd.Status
        FROM dbo.JCB_TD jtd WITH (NOLOCK)
        JOIN #baseOrders b
          ON b.StorerKey = jtd.StorerKey
         AND b.OrderKey  = jtd.OrderKey
        WHERE jtd.StorerKey = 'JCB'
          AND jtd.TaskType  = 'FCP'
          AND jtd.Status    = '9'
    ) t
    GROUP BY
          t.OrderKey
        , t.StorerKey;

    CREATE CLUSTERED INDEX CIX_taskAgg
        ON #taskAgg (StorerKey, OrderKey);

    SELECT
          b.OrderKey
        , b.StorerKey
        , b.Facility
        , CASE
              WHEN COALESCE(t.TaskQtySum, 0) = 0 THEN 'Not Released'
              WHEN COALESCE(t.TaskQtySum, 0) < COALESCE(o.OpenQtySum, 0) THEN 'Part Released'
              ELSE 'Released'
          END AS Task_Release
    INTO #taskRelease
    FROM #baseOrders b
    LEFT JOIN #odSum o
      ON o.StorerKey = b.StorerKey
     AND o.OrderKey  = b.OrderKey
     AND o.Facility  = b.Facility
    LEFT JOIN #taskAgg t
      ON t.StorerKey = b.StorerKey
     AND t.OrderKey  = b.OrderKey;

    CREATE CLUSTERED INDEX CIX_taskRelease
        ON #taskRelease (StorerKey, OrderKey, Facility);

    -------------------------------------------------------------------------
    -- 8) Final output. Column names kept as current dashboard expects.
    -------------------------------------------------------------------------
    SELECT
          'DelDate: ' + CONVERT(varchar(10), od.DeliveryDate, 103) AS pkdsh_Hd_DeliveryDate
        , CONVERT(varchar(10), od.DeliveryDate, 103) + ' ' + LEFT(CONVERT(varchar(8), od.DeliveryDate, 108), 5) AS pkdsh_DeliveryDate
        , od.OrderKey AS pkdsh_OrderID
        , od.UserDefine09 AS pkdsh_WaveID
        , od.ExternOrderKey AS pkdsh_SellerOrderID
        , od.Type AS pkdsh_otINT
        , CONCAT_WS(' - ', od.Type, COALESCE(ck.Description, 'No description')) AS pkdsh_OrderType
        , od.C_Company AS pkdsh_C_Company
        , CASE
              WHEN od.Status = '2' THEN 'Allocated'
              WHEN od.Status = '3' THEN 'In Progress'
              WHEN od.Status = '5' THEN 'Picked'
              ELSE od.Status
          END AS pkdsh_Status
        , od.Notes AS pkdsh_Comments
        , CONCAT(
              CASE WHEN a.DaysAbs = 0 THEN '' ELSE CONCAT(a.DaysAbs, ' days, ') END,
              a.HoursAbs, ' h, ',
              a.MinAbs,  ' min ',
              CASE WHEN d.DeltaSec < 0 THEN 'late' ELSE 'left' END
          ) AS pkdsh_LATE
        , CASE
              WHEN d.DeltaSec < 0 THEN 'DELAYED'
              WHEN d.DeltaSec <= 14400 THEN '1H_TO_DDATE'
              WHEN d.DeltaSec <= 21600 THEN '2H_1H_TO_DDATE'
              ELSE 'ON-TIME'
          END AS pkdsh_LateStatus
        , COALESCE(p.pkdsh_Total_CasPall, 0) AS pkdsh_Total_CasPall
        , COALESCE(p.pkdsh_Remain_CasPall, 0) AS pkdsh_Remain_CasPall
        , CAST(
              CASE
                  WHEN COALESCE(p.pkdsh_Total_CasPall, 0) = 0 THEN 0
                  ELSE ROUND(
                      100.0 * (COALESCE(p.pkdsh_Total_CasPall, 0) - COALESCE(p.pkdsh_Remain_CasPall, 0))
                      / COALESCE(p.pkdsh_Total_CasPall, 0),
                      0
                  )
              END AS int
          ) AS pkdsh_PercentPicked_n
        , CONCAT(
              CAST(
                  CASE
                      WHEN COALESCE(p.pkdsh_Total_CasPall, 0) = 0 THEN 0
                      ELSE ROUND(
                          100.0 * (COALESCE(p.pkdsh_Total_CasPall, 0) - COALESCE(p.pkdsh_Remain_CasPall, 0))
                          / COALESCE(p.pkdsh_Total_CasPall, 0),
                          0
                      )
                  END AS int
              ),
              ' %'
          ) AS pkdsh_PercentPicked
        , COALESCE(tr.Task_Release, 'Not Released') AS [pkdsh_Task_Release]
        , NULLIF(p.[WIDE], 0) AS [pkdsh_WIDE]
        , NULLIF(p.[VNA1], 0) AS [pkdsh_VNA1]
        , NULLIF(p.[VNA2], 0) AS [pkdsh_VNA2]
        , NULLIF(p.[VNA3], 0) AS [pkdsh_VNA3]
        , NULLIF(p.[VNA4], 0) AS [pkdsh_VNA4]
        , NULLIF(p.[VNA5], 0) AS [pkdsh_VNA5]
        , NULLIF(p.[BULK-INT], 0) AS [pkdsh_BULK-INT]
        , NULLIF(p.[BULK-EXT], 0) AS [pkdsh_BULK-EXT]
        , NULLIF(p.[MEZZ], 0) AS [pkdsh_MEZZ]
        , NULLIF(p.[P&D], 0) AS [pkdsh_P&D]
        , NULLIF(p.[CABSKIT], 0) AS [pkdsh_CABSKIT]
        , NULLIF(p.[LPKIT], 0) AS [pkdsh_LPKIT]
        , NULLIF(p.[T4], 0) AS [pkdsh_T4]
        , NULLIF(p.[MOTHERSONS], 0) AS [pkdsh_MOTHERSONS]
    FROM #baseOrders od
    LEFT JOIN dbo.CODELKUP ck WITH (NOLOCK)
      ON ck.StorerKey = od.StorerKey
     AND ck.Short     = od.Type
     AND ck.LISTNAME  = 'ORDERTYPE'
    LEFT JOIN #pdAgg p
      ON p.StorerKey = od.StorerKey
     AND p.OrderKey  = od.OrderKey
    LEFT JOIN #taskRelease tr
      ON tr.StorerKey = od.StorerKey
     AND tr.OrderKey  = od.OrderKey
     AND tr.Facility  = od.Facility
    LEFT JOIN #taskAgg ta
      ON ta.StorerKey = od.StorerKey
     AND ta.OrderKey  = od.OrderKey
    LEFT JOIN #nonFinalAgg nfa
      ON nfa.StorerKey = od.StorerKey
     AND nfa.OrderKey  = od.OrderKey
     AND nfa.Facility  = od.Facility
    LEFT JOIN #scanAgg scn
      ON scn.StorerKey = od.StorerKey
     AND scn.OrderKey  = od.OrderKey
     AND scn.Facility  = od.Facility
    CROSS APPLY
    (
        SELECT DATEDIFF(SECOND, @Now, od.DeliveryDate) AS DeltaSec
    ) d
    CROSS APPLY
    (
        SELECT
              ABS(d.DeltaSec) / 86400 AS DaysAbs
            , (ABS(d.DeltaSec) % 86400) / 3600 AS HoursAbs
            , ((ABS(d.DeltaSec) % 86400) % 3600) / 60 AS MinAbs
    ) a
    WHERE COALESCE(p.pkdsh_Total_CasPall, 0) > 0
      -- Exclude derived loaded orders, equivalent to old st7 CTE.
      AND NOT
      (
          od.Status = '5'
          AND scn.OrderKey IS NOT NULL
      )
      -- Exclude derived marshalled/ready orders, equivalent to old st6 CTE.
      AND NOT
      (
          od.Status = '5'
          AND scn.OrderKey IS NULL
          AND COALESCE(nfa.NonFinalRows, 0) > 0
          AND COALESCE(nfa.NonFinalRowsNotInCompML, 0) = 0
      )
      -- Exclude orders whose FCP tasks are fully done, equivalent to old fully_done_tasks CTE.
      AND NOT
      (
          COALESCE(ta.Status9Cnt, 0) > 0
          AND COALESCE(ta.StatusNot9Cnt, 0) = 0
      )
    ORDER BY od.DeliveryDate ASC;
END

