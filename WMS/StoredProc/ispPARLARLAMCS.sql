SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: ispPARLARLAMCS                                     */
/* Creation Date: 17-MAR-2026                                           */
/* Written by: SYO054                                                   */
/*  FCR: UWP-59481                                                      */
/* Purpose: Denmark Arla Putaway - Release / Update PA Tasks per Pallet */
/*          - If pallet exists in TASKDETAIL: update ToLoc/LogicalToLoc */
/*          - Else: insert new TASKDETAIL (only when Message01 = 'AGV') */
/*          - Suggest smallest LOC that fits pallet dimensions          */
/*          - Ensure chosen LOC empty & no pending putaways             */
/*          - Restrict LOC to SKU.PutawayZone                           */
/*          - Restrict LOC to same LocationGroup as RECEIPTDETAIL.ToLoc */
/*                                                                      */
/* Input Parameters:  @cPalletId                                        */
/*                   @bDebug (optional)                                 */
/*                                                                      */
/* Output Parameters: @cTaskDetailKey                                   */
/*                    @bSuccess                                         */
/*                    @nErrNo                                           */
/*                    @cErrMsg                                          */
/*                                                                      */
/* Version: 1.14                                                        */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purpose                                   */
/* 17-MAR-2026  SYO054_01   1.1  Dim-based @c_SuggestLoc enhancement       */
/* 17-MAR-2026  SYO054_02   1.2  Exclude filled & pending-putaway locs     */
/* 17-MAR-2026  SYO054_03   1.3  Update-if-exists, else insert             */
/* 17-MAR-2026  SYO054_04   1.4  Join SKU.PutawayZone = LOC.PutawayZone    */
/* 15-APR-2026  SYO054_05   1.5  Corrected the SKU.ItemClass & added       */
/*                             weight validation. Disabled              */
/*                             rdt_1819ExtPASP12 as it's already done   */
/*                             during Release PA Tasks                  */
/* 16-APR-2026  SYO054_06   1.6  Added a check to set @bSuccess = 0        */
/*                             If PalletId is NULL                      */
/* 20-APR-2026  SYO054_07   1.7  Enhanced the code to consider             */
/*                            TaskDetail.Status = 'X' (Hold)            */
/* 20-APR-2026  SYO054_08   1.8  Enhanced pallet dimensions to use         */
/*                            PalletTypeMaster and PACK if NULL         */
/* 20-APR-2026  SYO054_09   1.9  Added additional update to correct        */
/*                            SuggestedLoc in RFPUTAWAY & LOTXLOCXID    */
/* 20-APR-2026  SYO054_10   1.10 Added logic to putaway pallet to INSP     */
/*                            LocationCatergory if no suggestedloc      */
/* 20-APR-2026  SYO054_11   1.11 Added @bDebug flag to enable debug prints */
/* 19-MAY-2026  SYO054_12   1.12 Added new parameter @cScanLocation        */
/* 27-MAY-2026  SYO054_13   1.13 Restricted TASKDETAIL insert to only      */
/*                            occur when @c_Message01 = 'AGV'.          */
/*                            MANUAL pallets are skipped (no insert,    */
/*                            no new key consumed).                     */
/* 27-MAY-2026  SYO054_14   1.14 Look up LocationGroup of                  */
/*                            RECEIPTDETAIL.ToLoc from LOC table and    */
/*                            restrict SuggestedLoc candidates to       */
/*                            the same LocationGroup.                   */
/************************************************************************/
CREATE OR ALTER  PROC [dbo].[ispPARLARLAMCS]
      @cPalletId       NVARCHAR(20),
      @bDebug          BIT = 0,              -- Debug flag: 1 = print debug statements
      @cScanLocation   NVARCHAR(20), 
      @cTaskDetailKey  NVARCHAR(10)   OUTPUT,
      @bSuccess        INT            OUTPUT,
      @nErrNo          INT            OUTPUT,
      @cErrMsg         NVARCHAR(250)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON;
   SET QUOTED_IDENTIFIER OFF;
   SET ANSI_NULLS OFF;
   SET CONCAT_NULL_YIELDS_NULL OFF;

   ----------------------------------------------------------------
   -- Debug helper (prints only when @bDebug = 1)
   ----------------------------------------------------------------
   DECLARE @dbgPrefix NVARCHAR(50) = N'[ispPARLARLAMCS DEBUG] ';
   -- Note: PRINT truncates long messages; keep debug messages short.

   DECLARE @n_continue              INT,
           @n_StartTCnt             INT,
           @n_NoOfTasks             INT,
           @c_Storerkey             NVARCHAR(15),
           @c_SourceKey             NVARCHAR(30),
           @c_PickMethod            NVARCHAR(10),
           @c_ToID                  NVARCHAR(20),
           @c_ToLoc                 NVARCHAR(10),
           @c_ToLogicalLoc          NVARCHAR(18),
           @c_SuggestLoc            NVARCHAR(10),
           @c_UserId                NVARCHAR(30),
           @c_PickAndDropLOC        NVARCHAR(10),
           @c_FitCasesInAisle       NVARCHAR(1),
           @n_PABookingKey          INT,
           @c_Facility              NVARCHAR(5),
           @c_Sku                   NVARCHAR(50),
           @n_ReceiptLineNumber     INT,
           @c_Message01             NVARCHAR(10),
           @c_ItemClass             NVARCHAR(20),
           @c_UserDefine01          NVARCHAR(50), -- This is from RECEIPTDETAIL
           @c_RdUserDefine01        NVARCHAR(50), -- RECEIPTDETAIL.UserDefine01
           @n_UserDefine02          DECIMAL(18,4),
           @c_ExistingTaskDetailKey NVARCHAR(10),
           @c_SkuPutawayZone        NVARCHAR(20),
           @n_DefaultHeight         DECIMAL(18,4), -- default height
           @c_LocationGroup         NVARCHAR(20);  -- v1.14: LocationGroup of RECEIPTDETAIL.ToLoc

   SET @n_StartTCnt    = @@TRANCOUNT;
   SET @n_continue     = 1;
   SET @n_NoOfTasks    = 0;
   SET @cTaskDetailKey = '';
   SET @c_Storerkey    = '';
   SET @c_SourceKey    = '';
   SET @c_PickMethod   = '';
   SET @c_ToID         = '';
   SET @c_ToLoc        = '';
   SET @c_ToLogicalLoc = '';
   SELECT @c_UserId = SUSER_NAME();

   IF @bDebug = 1
      PRINT @dbgPrefix + 'Start. PalletId=' + ISNULL(@cPalletId,'<NULL>') + ', User=' + ISNULL(@c_UserId,'<NULL>');

   -- Quick stub to simulate Stored procedure returns success but TaskId not found in TASKDETAIL
   --IF @cPalletId = 'AOT202604131000404'
   --BEGIN
     --IF @bDebug = 1
        --PRINT @dbgPrefix + 'Stub pallet hit. Returning TaskDetailKey=404404';
     --SET @bSuccess = 1;
     --SET @cTaskDetailKey = '404404';
     --RETURN;
   --END;

   ----------------------------------------------------------------
   -- Validate pallet id
   ----------------------------------------------------------------
   IF @cPalletId IS NULL OR @cPalletId = ''
   BEGIN
      SET @bSuccess = 0;
      SET @nErrNo   = 164261;
      SET @cErrMsg  = 'NSQL' + CONVERT(CHAR(5), @nErrNo)
                      + ': Pallet ID (@cPalletId) is required. (ispPARLARLAMCS)';

      IF @bDebug = 1
         PRINT @dbgPrefix + 'Validation failed: PalletId is NULL/empty. ErrNo=' + CONVERT(NVARCHAR(20),@nErrNo);

      EXECUTE nsp_logerror @nErrNo, @cErrMsg, 'ispPARLARLAMCS';
      RETURN;
   END;

   ----------------------------------------------------------------
   -- Validate pallet exists in RECEIPTDETAIL table
   ----------------------------------------------------------------
   IF NOT EXISTS (SELECT 1 FROM RECEIPTDETAIL RD WHERE RD.ToId = @cPalletId)
   BEGIN
      SET @bSuccess = 0;
      SET @nErrNo   = 164262;
      SET @cErrMsg  = 'NSQL' + CONVERT(CHAR(5), @nErrNo)
                      + ': Pallet ID (' + ISNULL(@cPalletId,'')
                      + ') does not exist in RECEIPTDETAIL table. (ispPARLARLAMCS)';

      IF @bDebug = 1
         PRINT @dbgPrefix + 'Validation failed: PalletId not in RECEIPTDETAIL. ErrNo=' + CONVERT(NVARCHAR(20),@nErrNo);

      EXECUTE nsp_logerror @nErrNo, @cErrMsg, 'ispPARLARLAMCS';
      RETURN;
   END;

   IF @n_StartTCnt = 0
   BEGIN
      IF @bDebug = 1 PRINT @dbgPrefix + 'Beginning transaction (outermost).';
      BEGIN TRAN;
   END
   ELSE
   BEGIN
      IF @bDebug = 1 PRINT @dbgPrefix + 'Running inside existing transaction. TranCount=' + CONVERT(NVARCHAR(20),@n_StartTCnt);
   END;

   ----------------------------------------------------------------
   -- Get default height from CODELKUP once
   ----------------------------------------------------------------
   SELECT @n_DefaultHeight = TRY_CONVERT(DECIMAL(18,4), C.code)
   FROM   CODELKUP C WITH (NOLOCK)
   WHERE  C.listname = 'ARLAPALHGT';

   IF @n_DefaultHeight IS NULL
      SET @n_DefaultHeight = 0;

   IF @bDebug = 1
      PRINT @dbgPrefix + 'DefaultHeight=' + CONVERT(NVARCHAR(50),@n_DefaultHeight);

   --------------------------------------------------------------------
   -- Cursor over ReceiptDetail records for a single Pallet (ToID)
   --------------------------------------------------------------------
   DECLARE CursorPalletDetail CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT RD.Storerkey,
          RD.ReceiptKey,
          'FP' AS PickMethod,
          RD.ToID,
          RD.ToLoc,
          ISNULL(LOC.LogicalLocation,LOC.loc) AS LogicalLocation,
          LOC.Facility,
          RD.Sku,
          RD.ReceiptLineNumber,
          RD.UserDefine01
   FROM   ReceiptDetail RD WITH (NOLOCK)
          JOIN LOC LOC WITH (NOLOCK)
            ON RD.Toloc = LOC.Loc
   WHERE  RD.ToID         = @cPalletId
     AND  RD.FinalizeFlag = 'Y'
     AND  RD.QtyReceived  > 0
     AND  ISNULL(RD.ToID,'') <> ''
   GROUP BY RD.Storerkey,
            RD.ReceiptKey,
            RD.ToID,
            RD.ToLoc,
            ISNULL(LOC.LogicalLocation,LOC.loc),
            LOC.Facility,
            RD.Sku,
            RD.ReceiptLineNumber,
            RD.UserDefine01;

   OPEN CursorPalletDetail;

   FETCH NEXT FROM CursorPalletDetail
      INTO @c_Storerkey,
           @c_SourceKey,
           @c_PickMethod,
           @c_ToID,
           @c_ToLoc,
           @c_ToLogicalLoc,
           @c_Facility,
           @c_Sku,
           @n_ReceiptLineNumber,
           @c_RdUserDefine01;

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      IF @bDebug = 1
         PRINT @dbgPrefix + 'Cursor row: Storer=' + ISNULL(@c_Storerkey,'') +
               ', ReceiptKey=' + ISNULL(@c_SourceKey,'') +
               ', ToID=' + ISNULL(@c_ToID,'') +
               ', ToLoc=' + ISNULL(@c_ToLoc,'') +
               ', SKU=' + ISNULL(@c_Sku,'') +
               ', RLN=' + CONVERT(NVARCHAR(20),@n_ReceiptLineNumber);

      SET @c_SuggestLoc             = '';
      SET @n_PABookingKey           = 0;
      SET @c_Message01              = NULL;
      SET @c_ItemClass              = NULL;
      SET @c_UserDefine01           = NULL;
      SET @n_UserDefine02           = NULL;
      SET @c_ExistingTaskDetailKey  = NULL;
      SET @c_SkuPutawayZone         = NULL;
      SET @c_LocationGroup          = NULL;   -- v1.14: reset each iteration

      ----------------------------------------------------------------
      -- Get SKU.ItemClass & PutawayZone
      ----------------------------------------------------------------
      SELECT @c_ItemClass      = S.ItemClass,
             @c_SkuPutawayZone = S.PutawayZone
      FROM   SKU S WITH (NOLOCK)
      WHERE  S.StorerKey = @c_Storerkey
        AND  S.Sku       = @c_Sku;

      IF @bDebug = 1
         PRINT @dbgPrefix + 'SKU attributes: ItemClass=' + ISNULL(@c_ItemClass,'<NULL>') +
               ', PutawayZone=' + ISNULL(@c_SkuPutawayZone,'<NULL>');

      ----------------------------------------------------------------
      -- v1.14: Get LocationGroup of RECEIPTDETAIL.ToLoc from LOC
      ----------------------------------------------------------------
      SELECT @c_LocationGroup = L.LocationGroup
      FROM   LOC L WITH (NOLOCK)
      WHERE  L.Loc = @c_ToLoc;

      IF @bDebug = 1
         PRINT @dbgPrefix + 'v1.14 ToLoc=' + ISNULL(@c_ToLoc,'<NULL>') +
               ' LocationGroup=' + ISNULL(@c_LocationGroup,'<NULL>');

      ----------------------------------------------------------------
      -- Get RECEIPTDETAIL.UserDefine01, UserDefine02
      ----------------------------------------------------------------
      SELECT @c_UserDefine01 = P.UserDefine01,
             @n_UserDefine02 = TRY_CONVERT(DECIMAL(18,4), P.UserDefine02)
      FROM   RECEIPTDETAIL P WITH (NOLOCK)
      WHERE  P.StorerKey    = @c_Storerkey
        AND  P.ReceiptKey        = @c_SourceKey
        AND  P.ReceiptLineNumber = @n_ReceiptLineNumber;

      IF @bDebug = 1
         PRINT @dbgPrefix + 'RECEIPTDETAIL: UD01=' + ISNULL(@c_UserDefine01,'<NULL>') +
               ', UD02=' + ISNULL(CONVERT(NVARCHAR(50),@n_UserDefine02),'<NULL>');

      ----------------------------------------------------------------
      -- Message01 decision logic
      ----------------------------------------------------------------
      IF UPPER(ISNULL(@c_ItemClass,'')) = 'EXTRA CHIL'
      BEGIN
         SET @c_Message01 = 'MANUAL';
      END
      ELSE
      BEGIN
		 IF UPPER(ISNULL(@c_ItemClass,'')) = 'CHILLED'
              AND ISNULL(@c_UserDefine01,'') IN (SELECT DISTINCT CODE FROM CODELKUP WITH (NOLOCK) WHERE Storerkey = 'ARLA' AND LISTNAME = 'ARLAPALTYP' AND SHORT = 'AGV')
              AND ISNULL(@n_UserDefine02,0) <= 1500
         BEGIN
            SET @c_Message01 = 'AGV';
         END
         ELSE IF  UPPER(ISNULL(@c_ItemClass,'')) = 'CHILLED'
             OR ISNULL(@c_UserDefine01,'') NOT IN (SELECT DISTINCT CODE FROM CODELKUP WITH (NOLOCK) WHERE Storerkey = 'ARLA' AND LISTNAME = 'ARLAPALTYP' AND SHORT = 'AGV')
             OR ISNULL(@n_UserDefine02,0) > 1500
         BEGIN
            SET @c_Message01 = 'MANUAL';
         END
         
      END;

      IF @c_Message01 IS NULL
         SET @c_Message01 = 'MANUAL';

      IF @bDebug = 1
         PRINT @dbgPrefix + 'Message01 decided=' + ISNULL(@c_Message01,'<NULL>');

      ----------------------------------------------------------------
      -- Check if TASKDETAIL already exists for this pallet (FromID)
      ----------------------------------------------------------------
      SELECT TOP 1
             @c_ExistingTaskDetailKey = TD.TaskDetailKey
      FROM   TASKDETAIL TD WITH (NOLOCK)
      WHERE  TD.FromID    = @c_ToID
        AND  TD.StorerKey = @c_Storerkey
        AND  TD.TaskType  = 'PAF'
        AND  ISNUMERIC(TD.Status) = 1
        AND  TRY_CONVERT(INT, TD.Status) < 9
        AND  TD.Status <> 'X'
      ORDER BY TD.TaskDetailKey DESC;

      IF @bDebug = 1
         PRINT @dbgPrefix + 'ExistingTaskDetailKey=' + ISNULL(@c_ExistingTaskDetailKey,'<NONE>');

      ----------------------------------------------------------------
      -- Override @c_SuggestLoc using pallet vs. LOC dimensions
      -- v1.14: restricted to same LocationGroup as RECEIPTDETAIL.ToLoc
      ----------------------------------------------------------------
      DECLARE @nPalLen  DECIMAL(18,4),
              @nPalWid  DECIMAL(18,4),
              @nPalHgt  DECIMAL(18,4),
              @nPalWgt  DECIMAL(18,4),
              @cBestLoc NVARCHAR(10);

      SELECT
          @nPalLen = COALESCE(P.Length, PTM.Length),
          @nPalWid = COALESCE(P.Width,  PTM.Width),
          @nPalHgt = COALESCE(
                      (SELECT MAX(v.val)
                       FROM (VALUES (PK.HeightUOM1),
                                    (PK.HeightUOM2),
                                    (PK.HeightUOM3),
                                    (PK.HeightUOM4),
                                    (PK.HeightUOM8),
                                    (PK.HeightUOM9)
                            ) AS v(val)),
                      @n_DefaultHeight
                    ),
          @nPalWgt = P.grosswgt
      FROM    PALLET P WITH (NOLOCK)
      LEFT JOIN PalletTypeMaster PTM WITH (NOLOCK)
             ON PTM.PalletTypeMasterKey = @c_RdUserDefine01
            AND PTM.StorerKey = @c_Storerkey
      LEFT JOIN SKU S_DIM WITH (NOLOCK)
             ON S_DIM.StorerKey = P.StorerKey AND S_DIM.Sku = @c_Sku
      LEFT JOIN PACK PK WITH (NOLOCK)
             ON PK.PackKey = S_DIM.PackKey
      WHERE   P.PalletKey = @c_ToID
        AND   P.StorerKey = @c_Storerkey;

      IF @bDebug = 1
         PRINT @dbgPrefix + 'Pallet dims: L=' + ISNULL(CONVERT(NVARCHAR(50),@nPalLen),'<NULL>') +
               ', W=' + ISNULL(CONVERT(NVARCHAR(50),@nPalWid),'<NULL>') +
               ', H=' + ISNULL(CONVERT(NVARCHAR(50),@nPalHgt),'<NULL>') +
               ', Wgt=' + ISNULL(CONVERT(NVARCHAR(50),@nPalWgt),'<NULL>');

      IF @nPalLen IS NOT NULL
      BEGIN
         ;WITH PalletDims AS
         (
            SELECT @nPalLen AS PalLength,
                   @nPalWid AS PalWidth,
                   @nPalHgt AS PalHeight,
                   @nPalWgt AS PalWeight
         )
         SELECT TOP 1
                @cBestLoc = L.Loc
         FROM   PalletDims PD
                JOIN LOC L WITH (NOLOCK)
                  ON L.Facility = @c_Facility
                 AND PD.PalLength <= L.Length
                 AND PD.PalWidth  <= L.Width
                 AND PD.PalHeight <= L.Height
                 AND PD.PalWeight <= L.weightcapacity
         WHERE
             ( @c_SkuPutawayZone IS NULL
               OR @c_SkuPutawayZone = ''
               OR L.PutawayZone = @c_SkuPutawayZone
             )
           -- v1.14: restrict to same LocationGroup as the pallet's current ToLoc
           AND ( @c_LocationGroup IS NULL
                 OR @c_LocationGroup = ''
                 OR L.LocationGroup = @c_LocationGroup
               )
           AND NOT EXISTS (
                SELECT 1
                FROM   LOTXLOCXID LL WITH (NOLOCK)
                WHERE  LL.StorerKey = @c_Storerkey
                  AND  LL.Loc       = L.Loc
           )
           AND NOT EXISTS (
                SELECT 1
                FROM   TASKDETAIL TD2 WITH (NOLOCK)
                WHERE  TD2.StorerKey = @c_Storerkey
                  AND  TD2.TaskType  = 'PAF'
                  AND  ISNUMERIC(TD2.Status) = 1
                  AND  TRY_CONVERT(INT, TD2.Status) < 9
                  AND  TD2.Status <> 'X'
                  AND  TD2.ToLoc = L.Loc
           )
         ORDER BY L.Length ASC,
                  L.Width  ASC,
                  L.Height ASC,
                  L.weightcapacity ASC,
                  L.PALogicalLoc ASC;

		 -- Quick stub to support SIT - added by VMA237 08.06.2026 - start
		 --IF @cPalletId = 'VMA202606101000001'
		 --BEGIN 
			--SET @cBestLoc = 'W3A21810B3'
		 --END
		 -- Quick stub to support SIT - added by VMA237 08.06.2026 - end

         IF @cBestLoc IS NULL OR @cBestLoc = '' OR LEN(@cBestLoc) = 0
         BEGIN
            SELECT TOP 1
                   @cBestLoc = L.Loc
            FROM   LOC L WITH (NOLOCK)
            WHERE  L.Facility = @c_Facility
              AND  L.LocationCategory = 'INSP'
              AND NOT EXISTS (
                    SELECT 1
                    FROM   LOTXLOCXID LL WITH (NOLOCK)
                    WHERE  LL.StorerKey = @c_Storerkey
                      AND  LL.Loc       = L.Loc
              )
              AND NOT EXISTS (
                    SELECT 1
                    FROM   TASKDETAIL TD2 WITH (NOLOCK)
                    WHERE  TD2.StorerKey = @c_Storerkey
                      AND  TD2.TaskType  = 'PAF'
                      AND  ISNUMERIC(TD2.Status) = 1
                      AND  TRY_CONVERT(INT, TD2.Status) < 9
                      AND  TD2.Status <> 'X'
                      AND  TD2.ToLoc = L.Loc
              )
            ORDER BY L.Loc;
         END;

         SET @c_SuggestLoc = @cBestLoc;
      END;

      IF @bDebug = 1
         PRINT @dbgPrefix + 'SuggestedLoc=' + ISNULL(@c_SuggestLoc,'<NULL>');

      -- Fallback if still no suggestion
      IF ISNULL(@c_SuggestLoc,'') = ''
      BEGIN
         SET @c_SuggestLoc   = @c_ToLoc;
         SET @c_ToLogicalLoc = @c_ToLogicalLoc;
         IF @bDebug = 1
            PRINT @dbgPrefix + 'No suggestion found; fallback to ToLoc=' + ISNULL(@c_ToLoc,'<NULL>');
      END;

      ----------------------------------------------------------------
      -- Upsert TASKDETAIL
      --   * UPDATE: always run if an existing PAF task exists for the
      --            pallet (existing behaviour preserved).
      --   * INSERT: only when @c_Message01 = 'AGV'. MANUAL pallets are
      --            intentionally skipped (no insert, no key consumed).
      ----------------------------------------------------------------
      IF @c_ExistingTaskDetailKey IS NOT NULL
      BEGIN
         SET @cTaskDetailKey = @c_ExistingTaskDetailKey;

         IF @bDebug = 1
            PRINT @dbgPrefix + 'Updating TASKDETAIL key=' + @cTaskDetailKey + ' ToLoc=' + ISNULL(@c_SuggestLoc,'<NULL>');

         UPDATE TD
            SET TD.FromLoc        = @c_ToLoc,
                TD.LogicalFromLoc = @c_ToLogicalLoc,
                TD.ToLoc          = @c_SuggestLoc,
                TD.LogicalToLoc   = @c_SuggestLoc,
                TD.PickMethod     = @c_PickMethod,
                TD.SourceKey      = @c_SourceKey,
                TD.Message01      = @c_Message01,
                TD.SourceType     = 'ispPARLARLAMCS'
         FROM TASKDETAIL TD
         WHERE TD.TaskDetailKey = @c_ExistingTaskDetailKey

         IF @bDebug = 1
            PRINT @dbgPrefix + 'Updating LOTXLOCXID Id=' + @c_ToID + ' Loc=' + @c_ToLoc;

         -- UPDATE LOTXLOCXID
         UPDATE LLI
            SET LLI.Loc = @c_SuggestLoc
         FROM LOTXLOCXID LLI
         WHERE LLI.Id = @c_ToID
           AND LLI.StorerKey = @c_Storerkey
           AND LLI.PendingMoveIN > 0
           AND LLI.Qty = 0
           AND LLI.Loc <> @c_ToLoc

         -- UPDATE RFPUTAWAY
         UPDATE RFP
            SET RFP.SuggestedLoc = @c_ToLoc
         FROM RFPUTAWAY RFP
         WHERE RFP.Id = @c_ToID
           AND RFP.StorerKey = @c_Storerkey
           AND RFP.SuggestedLoc <> @c_ToLoc

         SET @n_NoOfTasks = @n_NoOfTasks + 1;
      END
      ELSE
      BEGIN
         ----------------------------------------------------------------
         -- INSERT branch: only proceed if Message01 = 'AGV'
         ----------------------------------------------------------------
         IF ISNULL(@c_Message01,'') = 'AGV'
         BEGIN
            IF @bDebug = 1
               PRINT @dbgPrefix + 'Inserting new TASKDETAIL (Message01=AGV). Getting new key.';

            EXECUTE nspg_GetKey
                    'TaskDetailKey',
                    10,
                    @cTaskDetailKey OUTPUT,
                    @bSuccess       OUTPUT,
                    @nErrNo         OUTPUT,
                    @cErrMsg        OUTPUT;

            IF @bSuccess <> 1
            BEGIN
               IF @bDebug = 1
                  PRINT @dbgPrefix + 'nspg_GetKey failed. ErrNo=' + ISNULL(CONVERT(NVARCHAR(20),@nErrNo),'<NULL>');

               SET @n_continue = 3;
               SET @nErrNo     = 30101;
               SET @cErrMsg    = 'NSQL' + CONVERT(CHAR(5),@nErrNo)
                                 + ': Error Getting New TaskDetailKey. (ispPARLARLAMCS)';
               GOTO QUIT_SP;
            END;

            IF @bDebug = 1
               PRINT @dbgPrefix + 'New TaskDetailKey=' + ISNULL(@cTaskDetailKey,'<NULL>') +
                     ' Insert ToLoc=' + ISNULL(@c_SuggestLoc,'<NULL>');

            INSERT INTO TASKDETAIL
                   ( TaskDetailKey,
                     Storerkey,
                     TaskType,
                     Fromloc,
                     LogicalFromLoc,
                     FromID,
                     PickMethod,
                     ToLoc,
                     LogicalToLoc,
                     Status,
                     Priority,
                     SourcePriority,
                     SourceType,
                     SourceKey,
                     Message01 )
            VALUES ( @cTaskDetailKey,
                     @c_Storerkey,
                     'PAF',
                     @c_Toloc,
                     @c_ToLogicalLoc,
                     @c_ToID,
                     @c_PickMethod,
                     @c_SuggestLoc,
                     @c_SuggestLoc,
                     0,
                     9,
                     9,
                     'ispPARLARLAMCS',
                     @c_Sourcekey,
                     @c_Message01 );

            SET @n_NoOfTasks = @n_NoOfTasks + 1;
         END
         ELSE
         BEGIN
            ----------------------------------------------------------------
            -- Not AGV - skip the insert by design (e.g. MANUAL pallets)
            ----------------------------------------------------------------
            IF @bDebug = 1
               PRINT @dbgPrefix + 'Skipping TASKDETAIL insert: Message01=' +
                     ISNULL(@c_Message01,'<NULL>') + ' (only AGV pallets are inserted).';
         END;
      END;

      FETCH NEXT FROM CursorPalletDetail
        INTO @c_Storerkey,
             @c_SourceKey,
             @c_PickMethod,
             @c_ToID,
             @c_ToLoc,
             @c_ToLogicalLoc,
             @c_Facility,
             @c_Sku,
             @n_ReceiptLineNumber,
             @c_RdUserDefine01;
   END;  -- WHILE

QUIT_SP:
   CLOSE CursorPalletDetail;
   DEALLOCATE CursorPalletDetail;

   IF @n_continue = 3
   BEGIN
      SET @bSuccess = 0;

      IF @bDebug = 1
         PRINT @dbgPrefix + 'Error path. Rolling back/ending transaction handling. ErrNo=' + ISNULL(CONVERT(NVARCHAR(20),@nErrNo),'<NULL>');

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN;
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN;
         END;
      END;

      EXECUTE nsp_logerror @nErrNo, @cErrMsg, 'ispPARLARLAMCS';
      RETURN;
   END
   ELSE
   BEGIN
      IF @n_NoOfTasks > 0
      BEGIN
         SET @cErrMsg = 'Total '
                        + CONVERT(NVARCHAR(5), @n_NoOfTasks)
                        + ' Putaway From tasks released/updated successfully for pallet '
                        + ISNULL(@cPalletId,'') + '.';
      END
      ELSE
      BEGIN
         SET @cErrMsg = 'No Putaway From tasks released/updated for pallet '
                        + ISNULL(@cPalletId,'') + '.';
      END;

      SET @bSuccess = 1;

      IF @bDebug = 1
         PRINT @dbgPrefix + 'Success path. Tasks=' + CONVERT(NVARCHAR(20),@n_NoOfTasks);

      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN;
      END;

      RETURN;
   END;
END;
GO
