SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: mspPARLJCB                                         */
/* Creation Date: 2025-08-22                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: PPA374                                                   */
/*                                                                      */
/* Purpose: UWP-32707 - FCR-3957 - JCB Putaway Using TM SCE             */
/*                                                                      */
/* Input Parameters:  @c_ReceiptKey                                     */
/*                                                                      */
/* Output Parameters:  @b_Success                                       */
/*                   , @n_err                                           */
/*                   , @c_errmsg                                        */
/*                                                                      */
/* Called By: isp_ASNReleasePATask_Wrapper                              */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2025-08-22  PPA374   1.0   UWP-32707 - FCR-3957 - JCB Putaway Using  */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[mspPARLJCB]
   @c_ReceiptKey  NVARCHAR(10) = ''
,  @b_Success     INT          = 1  OUTPUT
,  @n_Err         INT          = 0  OUTPUT
,  @c_Errmsg      NVARCHAR(250)= '' OUTPUT
,  @b_Debug       INT          = 0
AS
BEGIN
   SET NOCOUNT ON       -- SQL 2005 Standard
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Create or truncate temp table with available PND
   IF OBJECT_ID('tempdb..#tAvailPNDList') IS NULL
   BEGIN
      CREATE TABLE #tAvailPNDList
      (
         tLoc      NVARCHAR(20), 
         tLocAisle NVARCHAR(20),
         tLocFloor NVARCHAR(20),
         tPNDSpace INT,
         OK        NVARCHAR(20)
      )

	  --Creating index
      CREATE NONCLUSTERED INDEX IX_tAvailPNDList_Loc_OK
      ON #tAvailPNDList(tLoc, OK)
   END
   ELSE
   BEGIN
      TRUNCATE TABLE #tAvailPNDList
   END
   
   -- Create or truncate temp table with LPNs that are not released
   IF OBJECT_ID('tempdb..#tLPNToRelease') IS NULL
   BEGIN
      CREATE TABLE #tLPNToRelease
      (
         tLPN NVARCHAR(20) PRIMARY KEY
      )
   END
   ELSE
   BEGIN
     TRUNCATE TABLE #tLPNToRelease
   END

   -- Create or truncate temp table with Availablee Locations
   IF OBJECT_ID('tempdb..#tLocList') IS NULL
   BEGIN
      CREATE TABLE #tLocList
      (
         Loc               NVARCHAR(50),  
         PALogicalLoc      NVARCHAR(50),
         MaxPallet         INT,
         LocationFlag      NVARCHAR(20),
         LocationCategory  NVARCHAR(50),
         LocationGroup     NVARCHAR(50),
         Status            NVARCHAR(20),
         LocationRoom      NVARCHAR(50),
         LocAisle          NVARCHAR(20),
         Floor             NVARCHAR(20),
         LocLevel          INT,
         WAMidLoc          NVARCHAR(50),
         MidLocStatus      NVARCHAR(20),
         MidLocFlag        NVARCHAR(20),
         PalletsIN         NVARCHAR(20),
         LineWeight        DECIMAL(18,3),
         LocWeight         DECIMAL(18,3),
         Sku               NVARCHAR(50),
         Qty               INT,
         STDGROSSWGT       DECIMAL(18,3),
         MidLocOccupied    INT,
         PalletType        NVARCHAR(50),
         SpaceTaken        INT,
         RowID             INT,
         OK                NVARCHAR(1)
      )

      -- Creating indexes
      CREATE NONCLUSTERED INDEX IX_tLocList_Loc_OK 
      ON #tLocList(Loc, OK)

      CREATE NONCLUSTERED INDEX IX_tLocList_RowID 
      ON #tLocList(RowID)
   END
   ELSE
   BEGIN
      TRUNCATE TABLE #tLocList
   END

   --Declaring variables
   DECLARE @cLocG1            NVARCHAR( 20)
   DECLARE @cLocG2            NVARCHAR( 20)
   DECLARE @cLocG3            NVARCHAR( 20)
   DECLARE @cLocG4            NVARCHAR( 20)
   DECLARE @cLocG5            NVARCHAR( 20)
   DECLARE @nGrossWgt         INT
   DECLARE @nPalLen           INT
   DECLARE @nPalWidth         INT
   DECLARE @nPalHeight        INT
   DECLARE @cPalType          NVARCHAR( 10)
   DECLARE @nPalSpace         INT
   DECLARE @cPalSKU           NVARCHAR( 20)
   DECLARE @cPalLot           NVARCHAR( 20)
   DECLARE @cLPNToRelease     NVARCHAR( 20)
   DECLARE @cFacility         NVARCHAR( 20)
   DECLARE @cStorerKey        NVARCHAR( 20)
   DECLARE @c_TaskDetailKey   NVARCHAR( 10)
   DECLARE @nCounter          INT
   DECLARE @nLPNToRelCount    INT
   DECLARE @nPalQty           INT  
   DECLARE @cPalLoc           NVARCHAR( 20)
   DECLARE @cFinalLoc         NVARCHAR( 20)
   DECLARE @cToLoc            NVARCHAR( 20)
   DECLARE @cLocationGroup    NVARCHAR( 20)
   DECLARE @cLocationCategory NVARCHAR( 20)
   DECLARE @cPutawayZone      NVARCHAR( 20)  
   DECLARE @cAreakey          NVARCHAR( 20)
   DECLARE @nTasksReleased    INT
   DECLARE @nFirstTimeCheck   INT
   DECLARE @c_Errmsg1         NVARCHAR( 250)
   DECLARE @c_Errmsg2         NVARCHAR( 250)
   DECLARE @c_Errmsg3         NVARCHAR( 250)
   DECLARE @c_Errmsg4         NVARCHAR( 250)

   -- Set some parameters to get ready for looping and checks
   IF @nCounter IS NULL SET @nCounter = 1
   IF @nFirstTimeCheck IS NULL SET @nFirstTimeCheck = 0

   -- Setting StorerKey and Facility based on the receiptkey
   SELECT TOP 1
      @cFacility = Facility,
	  @cStorerKey = StorerKey
   FROM dbo.RECEIPT R WITH(NOLOCK)
   WHERE R.ReceiptKey = @c_Receiptkey

   -- Checking how much already released to not count it
   IF @nTasksReleased IS NULL 
   BEGIN
        SELECT 
	     @nTasksReleased = COUNT(*) 
	  FROM dbo.TaskDetail WITH(NOLOCK) 
	  WHERE SourceKey = @c_ReceiptKey 
	     AND Storerkey = @cStorerKey
   END

   -- Check if Receipt is finalised
   IF EXISTS (
      SELECT 1 
	  FROM dbo.RECEIPT R WITH(NOLOCK)
      WHERE R.ReceiptKey = @c_Receiptkey
         AND R.ASNStatus < '9'
   )
   BEGIN
      SET @n_Err = 60110
      SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)+': ASN has not closed yet. (mspPARLJCB)'
	  EXECUTE nsp_logerror @n_err, @c_errmsg, 'mspPARLJCB'
      GOTO QUIT_SP
   END

   -- Insert list of LPNs (IDs) to try to release
   INSERT INTO #tLPNToRelease
   SELECT DISTINCT RD.ToId
   FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK)
      LEFT JOIN dbo.TaskDetail TD WITH(NOLOCK)
      ON RD.ToId = TD.FromID
	     AND RD.ToLoc = TD.FromLoc
	     AND RD.StorerKey = TD.Storerkey
	     AND TD.Status <> 'X'
      INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
	  ON RD.ToId = LLI.Id
	     AND RD.ToLoc = LLI.Loc 
   WHERE ReceiptKey = @c_Receiptkey
      AND RD.ToId <> ''
      AND RD.StorerKey = @cStorerKey
      AND TaskDetailKey IS NULL
   
   -- Resetting RECEIPTDETAIL.PutawayLoc
   UPDATE RD WITH(ROWLOCK)
   SET RD.PutawayLoc = ''
   FROM dbo.RECEIPTDETAIL RD
      INNER JOIN #tLPNToRelease T
         ON RD.ToId = T.tLPN
   WHERE RD.ReceiptKey = @c_ReceiptKey
      AND RD.StorerKey = @cStorerKey;

   -- If it is first SP iteration and there is nothing to release from the beginning, give an error that there is nothing to release
   IF @nFirstTimeCheck = 0
      AND NOT EXISTS (
      SELECT 1 
	  FROM #tLPNToRelease
   ) 
   BEGIN
      SET @n_Err = 60110
      SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)+': Nothing to release. (mspPARLJCB)'
	  EXECUTE nsp_logerror @n_err, @c_errmsg, 'mspPARLJCB'
      GOTO QUIT_SP
   END

   -- Setting check off, as check is neded only in the beginning.
   SET @nFirstTimeCheck = 1

   -- Counting how much LPNs to release for looping
   SELECT 
	  @nLPNToRelCount = COUNT(*)
   FROM #tLPNToRelease

   -- Find PND locations that got facility AS EMG, flag as NONE or blank, status OK and space available
   INSERT INTO #tAvailPNDList
   SELECT 
      L.Loc,
      L.LocAisle, 
      L.Floor,
	  MaxPallet - COUNT(DISTINCT LLI.Id) AS PNDSpace,
	  '1' OK
   FROM dbo.LOC L WITH(NOLOCK)
      LEFT JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
      ON LLI.Loc = L.Loc
	     AND LLI.StorerKey = @cStorerKey
		 AND L.Facility = @cFacility
		 AND LLI.Qty + PendingMoveIN > 0
   WHERE L.Facility = @cFacility
      AND L.Status = 'OK'
	  AND L.LocationFlag IN ('','NONE')
	  AND L.LocationCategory = 'PNDIN'
   GROUP BY 
      L.Loc, 
	  L.MaxPallet, 
	  L.LocationType, 
	  L.LocationFlag, 
	  L.LocationCategory, 
	  L.LocationGroup, 
	  L.Status, 
	  L.LocationRoom, 
	  L.LocAisle, 
	  L.Floor
   HAVING MaxPallet - COUNT(DISTINCT LLI.Id) > 0

   -- Insert list of available locations
   INSERT INTO #tLocList
   SELECT 
      L.Loc, 
      L.PALogicalLoc,
      L.MaxPallet,  
      L.LocationFlag, 
      L.LocationCategory, 
      L.LocationGroup, 
      L.Status, 
      L.LocationRoom, 
      L.LocAisle, 
      L.Floor, 
      L.LocLevel,
      Calc.MidLoc AS WAMidLoc, 
      L2.Status AS MidLocStatus, 
      L2.LocationFlag AS MidLocFlag,  
      LLI.Id AS PalletsIN,
      ISNULL(LLI.Qty,0) * ISNULL(S.STDGROSSWGT,0) AS LineWeight,
      SUM(ISNULL(LLI.Qty,0) * ISNULL(S.STDGROSSWGT,0)) 
         OVER(PARTITION BY L.LOC
	  ) AS LocWeight,
      S.Sku,
      LLI.Qty,
      S.STDGROSSWGT,
      CASE 
         WHEN MidLLI.PalletsInMid > 0 
         THEN 1 
         ELSE 0 
      END AS MidLocOccupied,
      P.PalletType,
      CASE 
         WHEN C2.Short IS NULL 
            AND LLI.Id IS NOT NULL 
         THEN 1 
         ELSE ISNULL(C2.Short,0) 
      END AS SpaceTaken,
      ROW_NUMBER()OVER(
	     PARTITION BY LLI.Id, L.LOC 
		 ORDER BY LLI.ID
	  ) AS RowID,
	  '1' OK
   FROM dbo.LOC L WITH(NOLOCK)
      CROSS APPLY (
         SELECT 
		    CASE 
			   WHEN L.LocationCategory = 'WA' 
               THEN L.LocationRoom + '2' 
            END AS MidLoc
      ) AS Calc
      LEFT JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
      ON LLI.Loc = L.Loc
         AND LLI.StorerKey = @cStorerKey
         AND LLI.Qty + LLI.PendingMoveIN > 0
      LEFT JOIN dbo.LOC L2 WITH(NOLOCK)
      ON L2.Loc = Calc.MidLoc
         AND L2.Facility = @cFacility
      LEFT JOIN dbo.SKU S WITH(NOLOCK)
      ON S.SKU = LLI.Sku
         AND S.StorerKey = @cStorerKey
      LEFT JOIN dbo.PALLET P WITH(NOLOCK)
      ON LLI.Id = P.PalletKey
         AND P.StorerKey = @cStorerKey
      LEFT JOIN dbo.CODELKUP C2 WITH(NOLOCK)
      ON P.PalletType = C2.Code
         AND C2.LISTNAME = 'JCBPALTYPE'
         AND C2.Storerkey = @cStorerKey
      LEFT JOIN (
         SELECT 
		    Loc, 
			StorerKey, 
			SUM(Qty + PendingMoveIN) AS PalletsInMid
         FROM dbo.LOTxLOCxID WITH(NOLOCK)
         WHERE Qty + PendingMoveIN > 0
         GROUP BY 
		    Loc, 
			StorerKey
      ) MidLLI
      ON MidLLI.Loc = Calc.MidLoc
         AND MidLLI.StorerKey = @cStorerKey
   WHERE L.Facility = @cFacility
      AND L.Status = 'OK'
      AND L.LocationFlag IN ('','NONE')
      AND L.LocationCategory NOT IN ('PNDIN','PND_OUT','STAGE','')
      AND L.LocationGroup <> ''
      AND L.MaxPallet - 
      (CASE 
         WHEN C2.Short IS NULL 
            AND LLI.Id IS NOT NULL 
            THEN 1 
            ELSE ISNULL(C2.Short,0) 
         END) > 0

   --
   --
   -- Start looping the release
   RELEASE_LPN:

   -- Clean data
   SET @cLocG1     = '';
SET @cLocG2     = '';
SET @cLocG3     = '';
SET @cLocG4     = '';
SET @cLocG5     = '';
SET @nGrossWgt  = 0;
SET @nPalLen    = 0;
SET @nPalWidth  = 0;
SET @nPalHeight = 0;
SET @cPalType   = '';
SET @nPalSpace  = 0;
SET @cPalSKU    = '';
SET @cPalLot    = '';
SET @nPalQty    = 0;
SET @cPalLoc    = '';

   SET @cFinalLoc = ''	
   SET @cToLoc = ''
   SET @cLocationCategory = ''	
   SET @cLocationGroup = ''
   SET @cLPNToRelease = ''

   -- Select first of remaining LPNs to try to release
   SELECT TOP 1
      @cLPNToRelease = tLPN
   FROM #tLPNToRelease

   /*IF EXISTS (
      SELECT 
	     1 
	  FROM TaskDetail WITH(NOLOCK) 
	  WHERE Status NOT IN ('X','9') 
	     AND SourceKey = @c_ReceiptKey 
		 AND FromID = @cLPNToRelease 
		 AND Storerkey = @cStorerKey
   )
   BEGIN
	  DELETE FROM #tLPNToRelease
	  WHERE tLPN = @cLPNToRelease
	  GOTO RELEASE_LPN
   END*/

   -- Checking if LPN is captured and skip it if not
   IF NOT EXISTS (
      SELECT 1 
	  FROM dbo.PALLET WITH(NOLOCK)
	  WHERE PalletKey = @cLPNToRelease
   )
   BEGIN
      SET @n_Err = 60110
      SET @c_Errmsg1 = 'NSQL'+CONVERT(CHAR(5),@n_err)+': Pallet ' + @cLPNToRelease + ' not captured (PALLET table). (mspPARLJCB)'
	  EXECUTE nsp_logerror @n_err, @c_errmsg1, 'mspPARLJCB'
      GOTO SKIP_BAD_PAL
   END

   -- Check if captured LPN pallet type is valid
   IF NOT EXISTS (
      SELECT 1
      FROM dbo.PALLET P WITH(NOLOCK)
         INNER JOIN dbo.PalletTypeMaster PTM WITH(NOLOCK)
         ON P.PalletType = PTM.PalletType
            AND P.StorerKey = PTM.StorerKey
            AND PTM.Facility = @cFacility
            AND PTM.PalletTypeInUse = 'Y'
      WHERE P.StorerKey = @cStorerKey
         AND P.PalletKey = @cLPNToRelease
   )
   BEGIN
      SET @n_Err = 60110
      SET @c_Errmsg2 = 'NSQL'+CONVERT(CHAR(5),@n_err)+': Pallet ' + @cLPNToRelease + ' got bad pal type (PALLET table). (mspPARLJCB)'
	  EXECUTE nsp_logerror @n_err, @c_errmsg2, 'mspPARLJCB'
      GOTO SKIP_BAD_PAL
   END

   -- Capturing LPN data
   ;WITH LLI2Agg AS (
      SELECT 
         Id, 
         StorerKey, 
         SUM(Qty) AS LLI2SUM
      FROM dbo.LOTxLOCxID WITH (NOLOCK)
      GROUP BY Id, StorerKey
   ),
   Base AS (
      SELECT 
         C1.UDF01, 
         C1.UDF02, 
         C1.UDF03, 
         C1.UDF04, 
         C1.UDF05, 
         P.GrossWgt, 
         P.Length, 
         P.Width, 
         P.Height, 
         P.PalletType,
         ISNULL(C2.Short, 1) AS PalletSpace,
         S.SKU,
         LLI.Lot,
         C1.Long,
         S.Style,
         LLI2Agg.LLI2SUM,
         RD.ToLoc
      FROM dbo.RECEIPTDETAIL RD WITH (NOLOCK)
      INNER JOIN dbo.SKU S WITH (NOLOCK)
      ON RD.SKU = S.SKU 
         AND S.StorerKey = RD.StorerKey
      INNER JOIN dbo.LOTxLOCxID LLI WITH (NOLOCK)
      ON RD.ToId = LLI.Id
         AND RD.StorerKey = LLI.StorerKey
         AND RD.Sku = LLI.Sku
         AND LLI.Qty > 0
      INNER JOIN LLI2Agg WITH(NOLOCK)
      ON RD.ToId = LLI2Agg.Id
         AND RD.StorerKey = LLI2Agg.StorerKey
      LEFT JOIN dbo.PALLET P WITH (NOLOCK)
      ON RD.ToId = P.PalletKey
         AND RD.StorerKey = P.StorerKey
      LEFT JOIN dbo.CODELKUP C1 WITH (NOLOCK)
      ON S.Style = C1.Short 
         AND C1.ListName = 'JCBFAMILYT'
         AND C1.StorerKey = RD.StorerKey
      LEFT JOIN dbo.CODELKUP C2 WITH (NOLOCK)
      ON P.PalletType = C2.Code
         AND C2.ListName = 'JCBPALTYPE'
         AND C2.StorerKey = RD.StorerKey
   WHERE RD.ToId = @cLPNToRelease
      AND RD.StorerKey = @cStorerKey
   )
   SELECT TOP (1)
      @cLocG1     = UDF01,
      @cLocG2     = UDF02,
      @cLocG3     = UDF03,
      @cLocG4     = UDF04,
      @cLocG5     = UDF05,
      @nGrossWgt  = GrossWgt,
      @nPalLen    = Length,
      @nPalWidth  = Width,
      @nPalHeight = Height,
      @cPalType   = PalletType,
      @nPalSpace  = PalletSpace,
      @cPalSKU    = CASE WHEN MIN(SKU) OVER() = MAX(SKU) OVER() THEN SKU ELSE '' END,
      @cPalLot    = CASE WHEN MIN(Lot) OVER() = MAX(Lot) OVER() THEN Lot ELSE '' END,
      @nPalQty    = LLI2SUM,
      @cPalLoc    = ToLoc
   FROM Base
   ORDER BY Long, Style;

   -- Checking SKU style and skipping if it is bad
   IF ISNULL(@cLocG1,'') = '' 
      AND ISNULL(@cLocG2,'') = ''
	  AND ISNULL(@cLocG3,'') = ''
	  AND ISNULL(@cLocG4,'') = ''
	  AND ISNULL(@cLocG5,'') = ''
   BEGIN
      SET @n_Err = 60110
      SET @c_Errmsg3 = 'NSQL'+CONVERT(CHAR(5),@n_err)+': Pallet ' + @cLPNToRelease + ' bad SKU style. (mspPARLJCB)'
	  EXECUTE nsp_logerror @n_err, @c_errmsg3, 'mspPARLJCB'
      GOTO SKIP_BAD_PAL
   END
   
   -- Find first suitable location ordered by location group and location logical sequence
   SELECT TOP 1
      @cFinalLoc = IIF(C.CODE IS NOT NULL, C.Long, Loc),	
      @cToLoc = IIF(PNDLoc IS NULL, IIF(C.CODE IS NOT NULL, C.Long, Loc), PNDLoc),
      @cLocationCategory = LocationCategory,	
      @cLocationGroup = LocationGroup
   FROM (
      SELECT 
         T3.Loc,
         PALogicalLoc, 
         MaxPallet,
         LocationCategory,
         LocationGroup,
         LocationRoom,
         LocAisle,
         Floor,
         LocLevel,
         WAMidLoc,
         MidLocStatus,
         MidLocFlag,
         LocWeight,
         LocBeamWeight,
         MidLocOccupied,
         SpaceTaken,
         BeamSpaceLeft,
         CASE 
		    WHEN ISNULL(MidLocStatus,'OK') <> 'OK' 
               OR ISNULL(MidLocFlag,'') NOT IN ('','NONE') 
	           OR ISNULL(MidLocOccupied,0) = 1 
	           OR ISNULL(BeamSpaceLeft,0) < 2 
	           OR MaxPallet - SpaceTaken < 1
	           OR LocationCategory IN ('VNA')
	           OR (MAX(SpaceTaken)OVER(PARTITION BY LocationRoom) >= 2 
	              AND LocationCategory = 'WA')
	           OR tPNDSpace < 2
            THEN 0
            ELSE 1
         END AS DoublePalOK,
   	     tLoc PNDLoc,	
	     tLocAisle PNDAisle,
	     tLocFloor PNDSide,
	     tPNDSpace PNDSpace,
	     UDF01 MaxLen,	
	     UDF02 MaxWidth,	
	     UDF03 MaxHeight, 
	     UDF04 MaxWeight,	
	     UDF05 MaxBeamWeight
      FROM (
         SELECT 
            Loc,
            PALogicalLoc, 
            MaxPallet,
            LocationCategory,
            LocationGroup,
            LocationRoom,
            LocAisle,
            Floor,
            LocLevel,
            WAMidLoc,
            MidLocStatus,
            MidLocFlag,
            LocWeight,
            IIF(ISNULL(LocationRoom,'')<>'',SUM(LocWeight)OVER(PARTITION BY LocationRoom),LocWeight) AS LocBeamWeight,
            MidLocOccupied,
            SpaceTaken,
            IIF(ISNULL(LocationRoom,'')<>'',SUM(MaxPallet)OVER(PARTITION BY LocationRoom) - SUM(SpaceTaken)OVER(PARTITION BY LocationRoom),MaxPallet-SpaceTaken) AS BeamSpaceLeft
         FROM (
            SELECT
               Loc,
               PALogicalLoc, 
               MaxPallet,
               LocationCategory,
               LocationGroup,
               LocationRoom,
               LocAisle,
               Floor,
               LocLevel,
               WAMidLoc,
               MidLocStatus,
               MidLocFlag,
               LocWeight,
               MidLocOccupied,
               SUM(SpaceTaken) AS SpaceTaken
            FROM (
			   SELECT 
			      * 
			   FROM #tLocList 
			   WHERE OK = '1'
            ) T1
            WHERE RowID = 1
            GROUP BY 
               Loc,
               PALogicalLoc, 
               MaxPallet,
               LocationCategory,
               LocationGroup,
               LocationRoom,
               LocAisle,
               Floor,
               LocLevel,
               WAMidLoc,
               MidLocStatus,
               MidLocFlag,
               LocWeight,
               MidLocOccupied
         )T2
      )T3
         LEFT JOIN #tAvailPNDList tAPL
	        ON T3.LocAisle = tAPL.tLocAisle
               AND T3.Floor = tAPL.tLocFloor
			   AND OK = '1'
         LEFT JOIN dbo.CODELKUP C WITH(NOLOCK)
            ON C.LISTNAME = 'JCBLOCCAP'
	           AND T3.LocationCategory = C.Short
		       AND T3.LocLevel = C.Long
      WHERE MaxPallet - SpaceTaken > 0
         AND (tLoc IS NOT NULL 
		    OR LocationCategory NOT IN ('VNA','MEZZA'))
         AND UDF01 >= @nPalLen
         AND UDF02 >= @nPalWidth
         AND UDF03 >= @nPalHeight
         AND UDF04 >= LocWeight + @nGrossWgt
         AND UDF05 >= LocBeamWeight + @nGrossWgt
         AND LocationGroup IN (@cLocG1,@cLocG2,@cLocG3,@cLocG4,@cLocG5)
   )T4
      LEFT JOIN dbo.CODELKUP C WITH(NOLOCK)
      ON T4.LocationCategory = C.Short
         AND C.LISTNAME = 'JCBBKTOLOC'
   WHERE IIF(@cPalType LIKE 'D%' 
      AND DoublePalOK = 1,1,
	  IIF(MaxPallet - SpaceTaken - @nPalSpace >= 0,1,0)
   ) = 1
   ORDER BY 
      CASE 
	     WHEN @cPalType LIKE 'D%' AND LocationGroup = 'WA Dbl' THEN 1 
		 WHEN @cPalType NOT LIKE 'D%' AND LocationGroup = 'WA Dbl' THEN 99
         WHEN LocationGroup = @cLocG1 THEN 2
         WHEN LocationGroup = @cLocG2 THEN 3
	     WHEN LocationGroup = @cLocG3 THEN 4
	     WHEN LocationGroup = @cLocG4 THEN 5
	     WHEN LocationGroup = @cLocG5 THEN 6
         ELSE 999
      END,
      PALogicalLoc,
      Loc

   -- If no location was found, skip pallet
   IF ISNULL(@cToLoc,'') = ''
   BEGIN
      SET @n_Err = 60110
      SET @c_Errmsg4 = 'NSQL'+CONVERT(CHAR(5),@n_err)+': Pallet ' + @cLPNToRelease + ' no available location for LPN style, dims and weight. (mspPARLJCB)'
	  EXECUTE nsp_logerror @n_err, @c_errmsg4, 'mspPARLJCB'
      GOTO SKIP_BAD_PAL
   END

   --Updating RECEIPTDETAIL PutawayLoc for the LPN
   UPDATE dbo.RECEIPTDETAIL WITH(ROWLOCK)
   SET PutawayLoc = @cFinalLoc
   WHERE ReceiptKey = @c_ReceiptKey
      AND ToId = @cLPNToRelease
	  AND StorerKey = @cStorerKey

   -- Retrieving area and zone
   SELECT 
      @cPutawayZone = L.PutawayZone, 
	  @cAreakey = AD.AreaKey 
   FROM dbo.LOC L WITH(NOLOCK)
      INNER JOIN dbo.AreaDetail AD WITH(NOLOCK)
	  ON L.PutawayZone = AD.PutawayZone
   WHERE L.Facility = @cFacility
      AND L.LOC = @cToLoc

	/*IF EXISTS (
	   SELECT 1 FROM TaskDetail WITH(NOLOCK) WHERE Status NOT IN ('X','9') 
	      AND SourceKey = @c_ReceiptKey 
		  AND FromID = @cLPNToRelease 
		  AND Storerkey = @cStorerKey)
	BEGIN
	   GOTO SKIP_BAD_PAL
	END*/

   -- Get next task detail key
   EXECUTE nspg_GetKey
      @KeyName     = 'TaskDetailKey'
      , @fieldlength = 10
      , @keystring   = @c_TaskDetailKey OUTPUT
      , @b_Success   = @b_success       OUTPUT
      , @n_err       = @n_err           OUTPUT
      , @c_errmsg    = @c_errmsg        OUTPUT

   -- Inserting task
   INSERT INTO dbo.TASKDETAIL (    
      TaskDetailKey
      ,TaskType
      ,Storerkey
      ,Sku
      ,Lot
      ,UOM
      ,UOMQty
      ,Qty
      ,Fromloc
      ,LogicalFromLoc
      ,FromID
      ,ToLoc
      ,LogicalToLoc
      ,ToID
      ,FinalLoc
      ,FinalID
      ,PickMethod
      ,[Status]
      ,[Priority]
      ,SourcePriority
      ,SourceType
      ,SourceKey
      ,AreaKey
      ,Message01
      ,Message02
      ,Message03
      ,PendingMoveIn
   )
   VALUES (    
      @c_TaskdetailKey
      ,'PAF' 
      ,@cStorerkey
      ,@cPalSKU
      ,@cPalLot
      ,'1'
      ,@nPalQty
      ,@nPalQty
      ,@cPalLoc
      ,@cPalLoc
      ,@cLPNToRelease
      ,@cToLoc
      ,@cToLoc
      ,@cLPNToRelease
      ,@cFinalLoc
      ,@cLPNToRelease
      ,'FP'
      ,'0'
      ,'5'
      ,'9'
      ,'mspPARLJCB'
      ,@c_Receiptkey
      ,@cAreakey
      ,@cPutawayZone
      ,@cLocationGroup
      ,@cLocationCategory
      ,@nPalQty
   )

   -- If pallet got a problem, SP will jump here skipping insertion
   SKIP_BAD_PAL:
   
   -- Increasing counter to avoid endless loop
   SET @nCounter = @nCounter + 1
	
   -- Deleting LPN from the temp table to grab the next one
   DELETE FROM #tLPNToRelease
   WHERE tLPN = @cLPNToRelease

   UPDATE #tAvailPNDList
   SET OK = '0'
   WHERE tLoc IN (
      SELECT 
	     LOC 
      FROM dbo.LOC WITH(NOLOCK) 
	  WHERE Facility = @cFacility 
	     AND MaxPallet - (
		    SELECT 
			   COUNT(DISTINCT ID) 
			FROM dbo.LOTxLOCxID LLI WITH(NOLOCK) 
			WHERE StorerKey = @cStorerKey 
			   AND LLI.LOC = LOC.LOC 
			   AND LLI.Qty + LLI.PendingMoveIN > 0
         ) <= 0
      )

   IF ISNULL(@cFinalLoc,'')<>''
   BEGIN
      UPDATE #tLocList
      SET OK = '0'
      WHERE LOC = @cFinalLoc 
         AND @cFinalLoc NOT IN (
	        SELECT 
		       Long 
		    FROM dbo.CODELKUP WITH(NOLOCK) 
		    WHERE LISTNAME = 'JCBBKTOLOC'
         ) 
	     AND (
	        SELECT 
		       MaxPallet 
		    FROM dbo.LOC WITH(NOLOCK) 
		    WHERE Facility = @cFacility 
		       AND LOC = @cFinalLoc
         ) 
	     - (
	        SELECT 
		       COUNT(DISTINCT ID) 
		    FROM dbo.LOTxLOCxID WITH(NOLOCK) 
		    WHERE StorerKey = @cStorerKey 
		       AND LOC = @cFinalLoc 
			   AND Qty + PendingMoveIN > 0
            ) <= 0 
   END

   DELETE FROM #tAvailPNDList WHERE OK = '0' 
   
   DELETE FROM #tLocList WHERE OK = '0'

   -- Check if need to loop or to stop
   IF @nCounter <= @nLPNToRelCount
      AND EXISTS (
	     SELECT 1 
		 FROM #tLPNToRelease
	  )
   BEGIN
      GOTO RELEASE_LPN
   END

   -- Increasing released task for message
   SET @nTasksReleased = (
      SELECT 
	     COUNT(*) 
      FROM dbo.TaskDetail WITH(NOLOCK) 
	  WHERE SourceKey = @c_ReceiptKey 
	     AND Storerkey = @cStorerKey
   ) - @nTasksReleased

   SET @c_Errmsg = 
      CONCAT_WS ('; ',
         @c_Errmsg,
         @c_Errmsg1,
         @c_Errmsg2,
         @c_Errmsg3,
         @c_Errmsg4,
         CAST(@nTasksReleased AS NVARCHAR(10)) + ' tasks released.'
      )

   -- Quit SP on finish or error
QUIT_SP:

END
