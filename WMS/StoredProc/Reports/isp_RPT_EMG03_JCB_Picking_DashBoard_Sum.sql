USE [GBRWMS]
GO
/****** Object:  StoredProcedure [BI].[isp_RPT_EMG03_JCB_Picking_DashBoard_Sum]    Script Date: 5/25/2026 4:53:02 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_EMG03_JCB_Picking_DashBoard_Sum               */
/* Optimized rewrite candidate - TEST version                              */
/* Date         Author  Ver   Purposes                                     */
/* 23/01/2026   AGM046  1.0                                                */
/* 22/05/2026   SKE140  2.0   Optimized summary dashboard query            */
/*                                                                         */
/* Main performance changes:                                               */
/* 1. Materialise reusable CTEs into indexed #temp tables.                  */
/* 2. Read PICKDETAIL once for the parent/split-order family.               */
/* 3. Precompute GroupingKey and JCBCOMPML flag once.                       */
/* 4. Restrict TaskDetail and JCB_TD to #baseOrders only.                   */
/* 5. Compute st6/st7 exclusion flags once instead of repeated EXISTS.      */
/***************************************************************************/

CREATE OR ALTER   PROC [BI].[isp_RPT_EMG03_JCB_Picking_DashBoard_Sum]
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
    IF OBJECT_ID('tempdb..#taskAgg')        IS NOT NULL DROP TABLE #taskAgg;

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
        , o.Type
        , o.OrderGroup
        , o.ecom_platform
        , o.UserDefine09
    INTO #baseOrders
    FROM dbo.ORDERS o WITH (NOLOCK)
    WHERE o.StorerKey = 'JCB'
      AND ISNULL(o.Rdd, '') <> 'SplitOrder'
      AND o.Status IN ('2','3','5')
      AND o.ecom_platform <> '3RDParty'
      AND o.ecom_platform <> '3RDPartyQty'
      AND o.OrderGroup <> 'XDOCK'
      AND o.DeliveryDate <= @delivery_date_limit;

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
        ON #familyPick (StorerKey, ParentOrderKey, GroupingKey);

    CREATE INDEX IX_familyPick_TruckScan
        ON #familyPick (OrderKey, DropID)
        INCLUDE (StorerKey, ParentOrderKey, ParentFacility, Status);

    -------------------------------------------------------------------------
    -- 5) Pallet aggregation.
    --    Each GroupingKey = one logical business counting unit.
    -------------------------------------------------------------------------
    ;WITH g AS
    (
        SELECT
              fp.StorerKey
            , fp.ParentOrderKey AS OrderKey
            , fp.GroupingKey
        FROM #familyPick fp
        GROUP BY
              fp.StorerKey
            , fp.ParentOrderKey
            , fp.GroupingKey
    )
    SELECT
          StorerKey
        , OrderKey
        , COUNT(*) AS Pallets
    INTO #pdAgg
    FROM g
    GROUP BY
          StorerKey
        , OrderKey;

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
    -- 7) Fully done FCP task exclusion, restricted to current dashboard orders.
    -------------------------------------------------------------------------
    SELECT
          t.OrderKey
        , t.StorerKey
        , SUM(CASE WHEN t.Status = '9' THEN 1 ELSE 0 END) AS Status9Cnt
        , SUM(CASE WHEN t.Status <> '9' THEN 1 ELSE 0 END) AS StatusNot9Cnt
    INTO #taskAgg
    FROM
    (
        SELECT
              td.OrderKey
            , td.StorerKey
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

    -------------------------------------------------------------------------
    -- 8) Final summary output. Column names kept as current dashboard expects.
    -------------------------------------------------------------------------
    ;WITH base AS
    (
        SELECT
              CAST(od.DeliveryDate AS date) AS [Date]
            , CASE
                  WHEN od.Status = '2' THEN 'Allocated'
                  WHEN od.Status = '3' THEN 'In Progress'
                  WHEN od.Status = '5' THEN 'Picked'
              END AS [Status]
            , CONCAT_WS(' - ', od.Type, COALESCE(ck.Description, 'No description')) AS [Order Type]
            , od.OrderKey
            , CASE WHEN @Now > od.DeliveryDate THEN 1 ELSE 0 END AS IsLate
            , CASE WHEN @Now <= od.DeliveryDate THEN 1 ELSE 0 END AS IsOnTime
            , COALESCE(p.Pallets, 0) AS Pallets
        FROM #baseOrders od
        LEFT JOIN dbo.CODELKUP ck WITH (NOLOCK)
          ON ck.StorerKey = od.StorerKey
         AND ck.Short     = od.Type
         AND ck.LISTNAME  = 'ORDERTYPE'
        LEFT JOIN #pdAgg p
          ON p.StorerKey = od.StorerKey
         AND p.OrderKey  = od.OrderKey
        LEFT JOIN #nonFinalAgg nfa
          ON nfa.StorerKey = od.StorerKey
         AND nfa.OrderKey  = od.OrderKey
         AND nfa.Facility  = od.Facility
        LEFT JOIN #scanAgg scn
          ON scn.StorerKey = od.StorerKey
         AND scn.OrderKey  = od.OrderKey
         AND scn.Facility  = od.Facility
        LEFT JOIN #taskAgg ta
          ON ta.StorerKey = od.StorerKey
         AND ta.OrderKey  = od.OrderKey
        WHERE COALESCE(p.Pallets, 0) > 0
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
    )
    SELECT
          CONVERT(varchar(10), [Date], 103) AS [Date]
        , [Status]
        , [Order Type]
        , COUNT(*) AS [Total Orders]
        , SUM(IsLate) AS [Total Late]
        , SUM(IsOnTime) AS [Total On Time]
        , SUM(Pallets) AS [Pallets]
    FROM base
    GROUP BY
          [Date]
        , [Status]
        , [Order Type]
    ORDER BY
          [Date]
        , [Status]
        , [Order Type];
END
