SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Stored Procedure: mspPARL03                                          */
/* Creation Date: 2026-07-13                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: FCR-14639 - USA JCB Putaway                                 */
/*                                                                      */
/* Input Parameters:  @c_ReceiptKey                                     */
/*                                                                      */
/* Output Parameters:  @b_Success                                       */
/*                   , @n_err                                           */
/*                   , @c_errmsg                                        */
/* Return Status:  None                                                 */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: isp_ASNReleasePATask_Wrapper                              */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/************************************************************************/

CREATE OR ALTER PROC dbo.mspPARL03
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

   DECLARE @n_Continue           INT            = 1
         , @n_StartTCnt          INT            = @@TRANCOUNT
         , @n_Cnt                INT            = 0 
         , @n_RowCount           INT            = 0 
         , @n_NoOfTasks          INT            = 0
         , @n_RowID              INT            = 0         

         , @c_SourceType         NVARCHAR(30)   = 'mspPARL03'

         , @c_UDF01              NVARCHAR(60)   = ''
         , @c_UDF02              NVARCHAR(60)   = ''
         , @c_UDF03              NVARCHAR(60)   = ''
         , @c_UDF04              NVARCHAR(60)   = ''
         , @c_UDF05              NVARCHAR(60)   = ''

         , @c_Facility           NVARCHAR(5)    = ''
         , @c_Storerkey          NVARCHAR(15)   = ''
         , @c_ReceiptLineNumber  NVARCHAR(5)    = ''
         , @c_Sku                NVARCHAR(20)   = ''
         , @c_Lot                NVARCHAR(10)   = ''
         , @n_Qty_ID             INT            = 0
         , @c_PalletKey          NVARCHAR(10)   = ''
         , @c_PalletType         NVARCHAR(10)   = ''
         , @c_Style              NVARCHAR(10)   = ''
         , @c_SeqNo              NVARCHAR(10)   = ''
         , @n_Length_P           FLOAT          = 0.00
         , @n_Width_P            FLOAT          = 0.00
         , @n_height_P           FLOAT          = 0.00
         , @n_GrossWgt_P         FLOAT          = 0.00
         , @n_WeightLimit        FLOAT          = 0.00
         , @n_NoOfLoc            INT            = 0
         --, @n_MaxPallet          INT            = 0
         --, @n_LocLevel           INT            = 0
         , @c_Areakey            NVARCHAR(10)   = ''
         , @c_Putawayzone        NVARCHAR(10)   = ''
         , @c_LocationGroup      NVARCHAR(10)   = ''
         , @c_LocationCategory   NVARCHAR(10)   = ''
         --, @c_LocationCategory_F NVARCHAR(10)   = ''
         --, @c_LocAisle           NVARCHAR(10)   = ''
         --, @c_Floor              NVARCHAR(6)    = ''
         --, @c_LocationRoom       NVARCHAR(10)   = ''
         , @c_TaskDetailKey      NVARCHAR(10)   = ''
         , @c_TaskType           NVARCHAR(10)   = 'PAF'
         , @c_UOM                NVARCHAR(10)   = '1'

         , @c_PickMethod         NVARCHAR(10)   = 'FP'
         , @c_FromID             NVARCHAR(18)   = ''
         , @c_FromLoc            NVARCHAR(10)   = ''
         , @c_ToLoc              NVARCHAR(10)   = ''
         , @c_FinalLoc           NVARCHAR(10)   = ''
         
         , @c_FromLogicalLoc     NVARCHAR(10)   = ''
         , @c_ToLogicalLoc       NVARCHAR(10)   = ''
         , @c_Message01          NVARCHAR(20)   = ''
         , @c_Message02          NVARCHAR(20)   = ''
         , @c_Message03          NVARCHAR(20)   = ''

         , @n_Err_rv             INT = 0
         , @c_ErrMsg_rv          NVARCHAR(255)  = ''

         , @CUR_PAID             CURSOR
         , @CUR_PALOC            CURSOR
         , @CUR_UPD              CURSOR

   DECLARE @TMP_PA_CL            TABLE                                                     
      ( [RowID]            INT               IDENTITY(1,1) PRIMARY KEY                             
      , [LISTNAME]         [nvarchar](10)    NULL     
      , [Code]             [nvarchar](30)    NULL  
      , [Description]      [nvarchar](250)   NULL  
      , [Short]            [nvarchar](10)    NULL  
      , [Long]             [nvarchar](250)   NULL  
      , [Notes]            [nvarchar](4000)  NULL  
      , [Notes2]           [nvarchar](4000)  NULL  
      , [Storerkey]        [nvarchar](50)    NOT NULL  
      , [UDF01]            [nvarchar](60)    NOT NULL  
      , [UDF02]            [nvarchar](60)    NOT NULL  
      , [UDF03]            [nvarchar](60)    NOT NULL  
      , [UDF04]            [nvarchar](60)    NOT NULL  
      , [UDF05]            [nvarchar](60)    NOT NULL  
      , [code2]            [nvarchar](30)    NOT NULL 
      )

   IF OBJECT_ID('tempdb..#ReceiptDetail_WIP') IS NOT NULL
   BEGIN
      DROP TABLE #ReceiptDetail_WIP;
   END

   CREATE TABLE #ReceiptDetail_WIP                                                      
   (  RowID                INT            IDENTITY(1,1)  PRIMARY KEY
   ,  Receiptkey           NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  ReceiptLineNumber    NVARCHAR(5)    NOT NULL DEFAULT('')
   ,  Storerkey            NVARCHAR(15)   NOT NULL DEFAULT('') 
   ,  Sku                  NVARCHAR(20)   NOT NULL DEFAULT('')
   ,  Packkey              NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  UOM                  NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  Lot                  NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  ToLoc                NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  ToID                 NVARCHAR(18)   NOT NULL DEFAULT('')
   ,  QtyReceived          INT            NOT NULL DEFAULT(0)
   ,  FinalizeFlag         NVARCHAR(10)   NOT NULL DEFAULT('N')
   ,  PutawayLoc           NVARCHAR(10)   NOT NULL DEFAULT('')
   )
   CREATE  NONCLUSTERED INDEX IDX_ReceiptDetail_WIP_ToID ON #ReceiptDetail_WIP (ToID)

   IF OBJECT_ID('tempdb..#TMP_GRP') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_GRP;
   END

   CREATE TABLE #TMP_GRP                                                      
   (  RowID                INT            IDENTITY(1,1)        PRIMARY KEY
   ,  LocationGroup        NVARCHAR(10)   NOT NULL DEFAULT('')  
   ,  Facility             NVARCHAR(5)    NOT NULL DEFAULT('')
   ,  LocationFlag         NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  HostWHCode           NVARCHAR(10)   NULL 
   ,  [Status]             NVARCHAR(10)   NOT NULL DEFAULT('')
   )
   CREATE  NONCLUSTERED INDEX IDX_TMP_GRP_LocationGroup ON #TMP_GRP (LocationGroup)

   IF OBJECT_ID('tempdb..#TMP_GRP_LPN') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_GRP_LPN;
   END

   CREATE TABLE #TMP_GRP_LPN                                                      
   (  LocationGroup        NVARCHAR(10)   NOT NULL DEFAULT('') PRIMARY KEY
   ,  SortIdx              INT            NOT NULL DEFAULT(99)
   )
   CREATE  NONCLUSTERED INDEX IDX_TMP_GRP_LPN_ToID ON #TMP_GRP_LPN (SortIdx)
   
   IF OBJECT_ID('tempdb..#TMP_ID_STYLE') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_ID_STYLE;
   END
   
   CREATE TABLE #TMP_ID_STYLE                                                      
   (  RowID                INT            IDENTITY(1,1)        PRIMARY KEY
   ,  Style                NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  SeqNo                INT            NOT NULL DEFAULT(0)      
   ,  LocationGroup        NVARCHAR(10)   NOT NULL DEFAULT('')  
   ,  SortIdx              INT            NOT NULL DEFAULT(99)
   )
   
   CREATE  NONCLUSTERED INDEX IDX_TMP_ID_STYLE_LocGrp ON #TMP_ID_STYLE (LocationGroup)
   
   IF EXISTS ( SELECT 1 FROM RECEIPT r (NOLOCK)
               WHERE r.ReceiptKey = @c_ReceiptKey
               AND   r.ASNStatus < '9'
              )
   BEGIN
      SET @n_Continue = 3
      SET @n_Err = 60110
      SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)+': ASN has not closed yet. (mspPARL03)'
      GOTO QUIT_SP
   END
  
   INSERT INTO #ReceiptDetail_WIP( Receiptkey, ReceiptLineNumber    
                                 , Storerkey, Sku, Packkey, UOM                   
                                 , Lot, ToLoc, ToID, QtyReceived, FinalizeFlag
                                 , PutawayLoc
                                 )
   SELECT rd.ReceiptKey
         ,rd.ReceiptLineNumber
         ,rd.Storerkey
         ,rd.Sku
         ,rd.Packkey
         ,rd.UOM                   
         ,Lot = ''
         ,rd.ToLoc
         ,rd.ToID
         ,rd.QtyReceived
         ,rd.FinalizeFlag 
         ,PutawayLoc = ''
   FROM dbo.RECEIPTDETAIL rd (NOLOCK)
   JOIN dbo.Loc rl (NOLOCK) ON rl.Loc = rd.ToLoc
   WHERE rd.ReceiptKey = @c_ReceiptKey
   AND   rd.ToID > ''
   AND   rd.FinalizeFlag = 'Y'
   AND   EXISTS ( SELECT 1 
                  FROM LOTxLOCxID lli (NOLOCK) 
                  JOIN LOC l (NOLOCK) ON l.Loc = lli.Loc
                  WHERE lli.ID  = rd.ToID
                  AND   lli.Qty > 0
                  AND   l.LocationCategory = rl.LocationCategory
                )
   AND   NOT EXISTS (SELECT 1
                     FROM TaskDetail td (NOLOCK) 
                     WHERE td.CaseID = ''
                     AND td.TaskType = @c_TaskType
                     AND td.Storerkey= rd.Storerkey
                     AND td.[Status] < '9'
                     AND td.FromID   = rd.ToID
                     )
   ORDER BY rd.ToID

   SELECT @c_Facility = r.Facility
         ,@c_Storerkey= r.StorerKey
   FROM Receipt r (NOLOCK)
   WHERE r.ReceiptKey = @c_ReceiptKey
   
   INSERT INTO #TMP_GRP ( LocationGroup
                        , Facility, LocationFlag, [Status], HostWhCode          
                        )
   SELECT l.LocationGroup 
         ,l.Facility
         ,l.LocationFlag
         ,l.[Status] 
         ,l.HostWhCode 
   FROM LOC l (NOLOCK)
   WHERE l.Facility = @c_Facility
   AND   l.LocationFlag IN ('', 'NONE')
   AND   l.[Status] = 'OK'
   AND   l.MaxPallet > 0
   AND   l.LocationGroup > ''
   AND   l.LocationGroup IS NOT NULL
   GROUP BY l.LocationGroup 
         ,  l.Facility
         ,  l.LocationFlag
         ,  l.[Status] 
         ,  l.HostWhCode 

   INSERT INTO @TMP_PA_CL (Listname, Code, Description, Short, Long, Notes, Notes2, Storerkey, UDF01, UDF02, UDF03, UDF04, UDF05, Code2)  
   SELECT CODELKUP.Listname   
        , CODELKUP.Code   
        , [Description] = ISNULL(CODELKUP.[Description],'')   
        , Short = ISNULL(CODELKUP.Short,'')      
        , Long  = CASE WHEN ISNUMERIC(CODELKUP.Long) = 1 THEN CODELKUP.Long ELSE '0' END     
        , Notes = ISNULL(CODELKUP.Notes,'')      
        , Notes2= ISNULL(CODELKUP.Notes2,'')           
        , CODELKUP.Storerkey  
        , CODELKUP.UDF01   
        , CODELKUP.UDF02   
        , CODELKUP.UDF03   
        , CODELKUP.UDF04   
        , CODELKUP.UDF05   
        , CODELKUP.Code2  
   FROM CODELKUP (NOLOCK)  
   WHERE CODELKUP.Listname = 'JCBFAMILYT'  
   AND   CODELKUP.Storerkey = @c_Storerkey
   ORDER BY CODELKUP.Code 

   INSERT INTO @TMP_PA_CL (Listname, Code, Description, Short, Long, Notes, Notes2, Storerkey, UDF01, UDF02, UDF03, UDF04, UDF05, Code2)  
   SELECT CODELKUP.Listname   
        , CODELKUP.Code   
        , [Description] = ISNULL(CODELKUP.[Description],'')   
        , Short = CASE WHEN ISNUMERIC(CODELKUP.Short) = 1 THEN CODELKUP.Short ELSE '0' END   
        , Long  = ISNULL(CODELKUP.Long ,'')     
        , Notes = ISNULL(CODELKUP.Notes,'')      
        , Notes2= ISNULL(CODELKUP.Notes2,'')      
        , CODELKUP.Storerkey  
        , CODELKUP.UDF01
        , CODELKUP.UDF02   
        , CODELKUP.UDF03   
        , CODELKUP.UDF04   
        , CODELKUP.UDF05   
        , CODELKUP.Code2  
   FROM CODELKUP (NOLOCK)  
   WHERE CODELKUP.Listname = 'JCBPALTYPE' 
   AND CODELKUP.Storerkey = @c_Storerkey
   ORDER BY CODELKUP.Code

   WHILE @n_Continue <> 0
   BEGIN
      SET @n_Continue   = 1
      SET @n_Err        = 0
      SET @c_ErrMsg     = '' 
      
      SET @c_FromLoc    = ''
      SET @c_PalletKey  = ''
      SET @c_PalletType = ''
      SET @n_Qty_ID     = 0
      SET @n_Length_P   = 0.00
      SET @n_Width_P    = 0.00
      SET @n_Height_P   = 0.00
      SET @n_Height_P   = 0.00
      SET @n_GrossWgt_P = 0.00

      --SET @n_MaxPallet  = 0
      --SET @n_NoOfLoc    = 0
      SET @c_ToLoc = ''
      SET @c_FinalLoc = ''
      --SET @c_LocationCategory_F = ''

      SELECT TOP 1
             @c_Storerkey = rd.Storerkey
            ,@c_FromLoc = rd.ToLoc
            ,@c_FromID  = rd.ToID
            ,@n_Qty_ID  = SUM(rd.QtyReceived)
      FROM #ReceiptDetail_WIP as rd
      WHERE rd.ToID > @c_FromID
      GROUP BY rd.Storerkey
            ,  rd.ToLoc 
            ,  rd.ToID
      ORDER BY rd.ToID
      
      SET @n_RowCount = @@ROWCOUNT

      IF @n_RowCount = 0
      BEGIN
         BREAK
      END

      IF @b_Debug = 1
      BEGIN
         PRINT ' @c_FromLoc: '+ @c_FromLoc
              +',@c_FromID: '+ @c_FromID
      END
      
      IF @n_Continue = 1
      BEGIN
         SELECT 
           @c_PalletKey  = ISNULL(pm.PalletKey,'')
         , @c_PalletType = ISNULL(pm.PalletType,'')
         , @n_Length_P   = ISNULL(pm.[Length],0.00)
         , @n_Width_P    = ISNULL(pm.[Width] ,0.00)
         , @n_Height_P   = ISNULL(pm.[Height],0.00)
         , @n_GrossWgt_P = ISNULL(pm.GrossWgt,0.00)
         FROM Pallet pm (NOLOCK) 
         WHERE pm.Palletkey = @c_FromID

         IF @c_PalletKey = ''
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 60120
            SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                          + ': Pallet Key not Found. LPN: ' + @c_FromID
                          + ' (mspPARL03)'
         END
      
         IF @n_Continue = 1
         BEGIN
            IF @n_Length_P = 0.00 OR @n_Width_P = 0.00 OR @n_Height_P = 0.00 OR  
               @n_GrossWgt_P = 0.00
            BEGIN
               SET @n_Continue = 3
               SET @n_Err = 60130
               SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                             + ': Bad Pallet key dimension setup. LPN: ' + @c_FromID
                             + ' (mspPARL03)'
            END
         END
      END

      IF @n_Continue = 1
      BEGIN
         SET @n_Cnt = 0

         SELECT @n_Cnt   = 1
         FROM @TMP_PA_CL cl  
         WHERE cl.ListName = 'JCBPALTYPE'
         AND   cl.Code = @c_PalletType

         IF @n_Cnt = 0
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 60140
            SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                          + ': Bad setup IN JCBPalType. LPN: ' + @c_FromID
                          + ' (mspPARL03)'
         END

         IF @n_Continue = 1  
         BEGIN
            TRUNCATE TABLE #TMP_GRP_LPN;

            INSERT INTO #TMP_GRP_LPN (LocationGroup)
            SELECT V.ColValue
            FROM @TMP_PA_CL AS cl 
            CROSS APPLY (
                            VALUES
                                ('UDF01', cl.UDF01) 
                               ,('UDF02', cl.UDF02) 
                               ,('UDF03', cl.UDF03) 
                               ,('UDF04', cl.UDF04) 
                               ,('UDF05', cl.UDF05)                                  
                        ) V (ColName, ColValue)
            WHERE cl.ListName = 'JCBPALTYPE'
            AND   cl.Code = @c_PalletType
            AND   V.ColValue > ''

            SET @n_RowCount  = @@ROWCOUNT
            
            IF @n_RowCount = 0
            BEGIN
               INSERT INTO #TMP_GRP_LPN (LocationGroup)
               SELECT DISTINCT g.LocationGroup
               FROM #TMP_GRP g
            END
            ELSE IF @n_RowCount > 0
            BEGIN
               SET @n_Cnt = 0
               SELECT @n_Cnt = 1
                     ,@c_LocationGroup = lpn.LocationGroup
               FROM #TMP_GRP_LPN AS lpn  
               WHERE NOT EXISTS
                  (
                      SELECT 1
                      FROM #TMP_GRP g (NOLOCK)
                      WHERE g.LocationGroup = lpn.LocationGroup
                  );

               IF @n_Cnt > 0
               BEGIN
                  SET @n_Continue = 3
                  SET @n_Err = 60150
                  SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                                + ': Invalid Location Group: ' + @c_LocationGroup
                                + ', LPN: ' + @c_FromID
                                + ' (mspPARL03)'

               END
            END
         END
      END

      IF @n_Continue = 1  
      BEGIN
         SET @n_Cnt   = 0
         SELECT TOP 1
                @n_Cnt = 1
         FROM #ReceiptDetail_WIP rd (NOLOCK)
         JOIN SKU s (NOLOCK) ON  s.Storerkey  = rd.Storerkey
                             AND s.Sku = rd.Sku
         WHERE rd.ToID  = @c_FromID
         AND   rd.ReceiptKey = @c_ReceiptKey
         AND   s.Style = ''         
         ORDER BY s.Style

         IF @n_Cnt = 1
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 60160
            SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                          + ': Bad Sku Style. LPN: ' + @c_FromID
                          + ' (mspPARL03)'
         END

         IF @n_Continue = 1
         BEGIN 
            TRUNCATE TABLE #TMP_ID_STYLE;
            
            INSERT INTO #TMP_ID_STYLE (Style, SeqNo, LocationGroup, SortIDX)
            SELECT lg.Code, SeqNo = CAST(lg.Long AS INT), v.ColValue, v.ColIdx
            FROM #ReceiptDetail_WIP rd (NOLOCK)
            JOIN SKU s (NOLOCK) ON  s.Storerkey  = rd.Storerkey
                                AND s.Sku = rd.Sku
            JOIN @TMP_PA_CL lg ON lg.ListName = 'JCBFAMILYT'
                              AND lg.Code = s.Style   
            CROSS APPLY (  
                           VALUES  ('UDF01', lg.UDF01, 1) 
                                  ,('UDF02', lg.UDF02, 2) 
                                  ,('UDF03', lg.UDF03, 3) 
                                  ,('UDF04', lg.UDF04, 4) 
                                  ,('UDF05', lg.UDF05, 5)                                  
                              ) v (ColName, ColValue, ColIdx)                           
            WHERE rd.ToID  = @c_FromID
            AND   rd.ReceiptKey = @c_ReceiptKey

            SET @n_RowCount = @@ROWCOUNT

            IF @n_RowCount = 0
            BEGIN
               SET @n_Continue = 3
               SET @n_Err = 60170
               SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                             + ': Sku Stype does not setup in JCBFamilyT. LPN: ' + @c_FromID
                             + ' (mspPARL03)'
            END 
         END
         
         IF @n_Continue = 1
         BEGIN            
            SET @n_Cnt = 0
            SELECT TOP 1
                   @n_Cnt = 1
            FROM @TMP_PA_CL lg 
            WHERE lg.ListName = 'JCBFAMILYT'
            AND   lg.UDF01 = '' AND lg.UDF02 = '' AND lg.UDF03 = '' 
            AND   lg.UDF04 = '' AND lg.UDF05 = ''
            AND   EXISTS (SELECT 1 FROM #TMP_ID_STYLE AS s WHERE s.Style = lg.Code)
         
            IF @n_Cnt = 1
            BEGIN
               SET @n_Continue = 3
               SET @n_Err = 60180
               SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                             + ': Bad LocationGroup Setup in JCBFamilyT. LPN: ' + @c_FromID
                             + ' (mspPARL03)'
            END
         END
         
         IF @n_Continue = 1
         BEGIN
            SET @n_Cnt = 0
            SET @c_LocationGroup = ''

            SELECT 
                  @n_Cnt = 1
               ,  @c_LocationGroup = s.LocationGroup
            FROM #TMP_ID_STYLE AS s
            WHERE s.LocationGroup > ''
            AND   NOT EXISTS  (
                                  SELECT 1
                                  FROM #TMP_GRP g (NOLOCK)
                                  WHERE g.LocationGroup = s.LocationGroup
                              );

            IF @n_Cnt = 1
            BEGIN
               SET @n_Continue = 3
               SET @n_Err = 60190
               SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                             + ': Invalid Location Group: ' + @c_LocationGroup
                             + ', Style: ' + @c_Style
                             + ' (mspPARL03)'
            END
         END

         IF @n_Continue = 1
         BEGIN
            ;  WITH cte AS 
            (
               SELECT TOP 1 WITH TIES 
                     s.LocationGroup, s.SortIdx
               FROM #TMP_ID_STYLE AS s
               WHERE s.LocationGroup > ''
               ORDER BY s.SeqNo
            )
            MERGE #TMP_GRP_LPN AS t
            USING cte AS s
               ON t.LocationGroup = s.LocationGroup
            WHEN MATCHED THEN
               UPDATE
                  SET t.SortIdx = s.SortIdx
            WHEN NOT MATCHED BY SOURCE THEN
               DELETE;
         END
      END
      
      IF @n_Continue = 1
      BEGIN
         IF NOT EXISTS (SELECT 1 FROM #TMP_GRP_LPN AS lpn)
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 60200
            SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                          + ': Sort Location Group does not match with Pallet Location Group.'
                          + '. LPN: ' + @c_FromID
                          + ' (mspPARL03)'
         END
      END

      IF @n_Continue = 1 
      BEGIN
         SET @c_FinalLoc = ''
         SELECT TOP 1 @c_FinalLoc = l.loc               
         FROM #TMP_GRP_LPN AS lpn 
         JOIN #TMP_GRP AS g ON g.LocationGroup = lpn.LocationGroup
         JOIN LOC l (NOLOCK) ON  l.LocationFlag = g.LocationFlag
                             AND l.[Status] = g.[Status]
                             AND l.HOSTWHCODE IN (g.HostWHCode)
                             AND l.LocationGroup = lpn.LocationGroup
         CROSS APPLY (  SELECT NoOfLPN = COUNT(DISTINCT inv.ID)
                              ,[Length]= ISNULL(SUM(inv.[Length]),0.00)
                              ,Width   = ISNULL(SUM(inv.Width),0.00)
                              ,Height  = ISNULL(SUM(inv.Height),0.00)
                              ,GrossWgt= ISNULL(SUM(inv.GrossWgt),0.00)
                        FROM
                        (
                        SELECT lli.ID 
                              ,pm.[Length]
                              ,pm.Width
                              ,pm.Height
                              ,pm.GrossWgt
                        FROM LOTxLOCxID lli (NOLOCK)
                        JOIN Pallet pm (NOLOCK) ON pm.PalletKey = lli.ID 
                        WHERE lli.Loc = l.Loc
                        AND   lli.ID  > ''
                        AND   lli.Qty + lli.PendingMoveIn > 0
                        GROUP BY lli.ID
                              ,  pm.[Length]
                              ,  pm.Width
                              ,  pm.Height
                              ,  pm.GrossWgt
                       ) inv
                     ) pl
         WHERE l.Facility = @c_Facility
         AND   l.[Length] >= @n_Length_P
         AND   l.Width  >= @n_Width_P
         AND   l.Height >= @n_height_P
         AND   l.WeightCapacity >= @n_GrossWgt_P
         AND   l.MaxPallet >= 1
         AND   l.[Length] >= pl.[Length] + @n_Length_P
         AND   l.Width  >= pl.Width + @n_Width_P
         AND   l.Height >= pl.Height+ @n_height_P
         AND   l.WeightCapacity >= pl.GrossWgt + @n_GrossWgt_P
         AND   l.MaxPallet >= pl.NoOfLPN + 1
         ORDER BY lpn.SortIdx
               ,  l.PALogicalLoc  

         IF @b_Debug = 1
         BEGIN
            PRINT   '@c_FromID : '+ @c_FromID
                  + ', @c_LocationCategory: '+ @c_LocationCategory
                  --+ ', @c_LocationRoom: ' + @c_LocationRoom 
                  --+ ', @c_LocAisle:' + @c_LocAisle 
                  --+ ', @n_LocLevel: ' + CAST(@n_LocLevel AS NVARCHAR)
                  + ', @c_ToLoc: ' + @c_ToLoc
            PRINT   '  @n_WeightLimit: ' + CAST(@n_WeightLimit AS NVARCHAR) 
                  + ', @n_NoOfLoc: ' + CAST (@n_NoOfLoc AS NVARCHAR)
                  + ', @n_GrossWgt_P : ' + CAST (@n_GrossWgt_P  AS NVARCHAR)

            PRINT   '  @c_FinalLoc: '+ @c_FinalLoc
                  --+ ', @c_LocationCategory_F: ' + @c_LocationCategory_F
         END
      END
 
      IF @n_Continue = '1' AND @c_FinalLoc = ''
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 60210
         SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)+': Suggested loc not found. LPN: ' + @c_FromID
                       + ' (mspPARL03)'
      END
      
      IF @n_Continue = 1
      BEGIN
         BEGIN TRAN  
         EXECUTE nspg_GetKey
           @KeyName     = 'TaskDetailKey'
         , @fieldlength = 10
         , @keystring   = @c_TaskDetailKey OUTPUT
         , @b_Success   = @b_success       OUTPUT
         , @n_err       = @n_err           OUTPUT
         , @c_errmsg    = @c_errmsg        OUTPUT

         IF NOT @b_success = 1
         BEGIN
            SET @n_Continue = 0
         END

         IF @n_Continue = 1
         BEGIN
            SET @c_ToLoc = @c_FinalLoc

            --SET @c_Putawayzone  = ''
            --SET @c_LocationGroup= ''
            --SET @c_LocationCategory =  ''
            
            --SELECT TOP 1 
            --       @c_Putawayzone   = l.PutawayZone
            --      ,@c_LocationGroup = ISNULL(l.LocationGroup,'')                    
            --      ,@c_LocationCategory = l.LocationCategory
            --FROM dbo.LOC l (NOLOCK)
            --WHERE Loc = @c_ToLoc

            SET @c_Lot = ''
            SELECT @c_Lot = CASE WHEN COUNT(DISTINCT lli.Lot) > 1 THEN '' ELSE MIN (lli.Lot) END
                  ,@c_Sku = CASE WHEN COUNT(DISTINCT lli.Sku) > 1 THEN '' ELSE MIN (lli.Sku) END
                  ,@c_FromLoc = lli.Loc
            FROM LOTxLOCxID lli (NOLOCK)
            WHERE lli.Storerkey = @c_Storerkey
            AND   lli.ID  = @c_FromID
            AND   lli.Qty > 0
            GROUP BY lli.Storerkey
                  ,  lli.Loc
                  ,  lli.ID
            
            SELECT TOP 1                                                            
                   @c_Areakey = a.AreaKey
            FROM dbo.LOC l (NOLOCK)
            JOIN AreaDetail a (NOLOCK) ON a.PutawayZone = l.PutawayZone
            WHERE Loc = @c_FromLoc
            ORDER BY a.AreaKey

            SELECT @n_Continue = 4
            FROM taskdetail td (NOLOCK)
            WHERE td.Caseid = ''
            AND   td.TaskType  = @c_TaskType
            AND   td.[Status]  = '0'
            AND   td.Storerkey = @c_Storerkey
            AND   td.[FromId]  = @c_FromID
         END

         IF @n_Continue = 1
         BEGIN                     
            BEGIN TRY                                                                
               INSERT INTO dbo.TASKDETAIL
                      (    TaskDetailKey
                        ,  TaskType
                        ,  Storerkey
                        ,  Sku
                        ,  Lot
                        ,  UOM
                        ,  UOMQty
                        ,  Qty
                        ,  Fromloc
                        ,  LogicalFromLoc
                        ,  FromID
                        ,  ToLoc
                        ,  LogicalToLoc
                        ,  ToID
                        ,  FinalLoc
                        ,  FinalID
                        ,  PickMethod
                        ,  [Status]
                        ,  [Priority]
                        ,  SourcePriority
                        ,  SourceType
                        ,  SourceKey
                        ,  AreaKey
                        ,  Message01
                        ,  Message02
                        ,  Message03
                        ,  PendingMoveIn
                      )
               VALUES (    @c_TaskdetailKey
                        ,  @c_TaskType 
                        ,  @c_Storerkey
                        ,  @c_Sku
                        ,  @c_Lot
                        ,  @c_UOM
                        ,  @n_Qty_ID
                        ,  @n_Qty_ID
                        ,  @c_FromLoc
                        ,  @c_FromLoc
                        ,  @c_FromID
                        ,  @c_ToLoc
                        ,  @c_ToLoc
                        ,  @c_FromID
                        ,  @c_FinalLoc
                        ,  @c_FromID
                        ,  @c_PickMethod
                        ,  '0'
                        ,  '5'
                        ,  '9'
                        ,  @c_SourceType 
                        ,  @c_Receiptkey
                        ,  @c_Areakey
                        ,  @c_Message01
                        ,  @c_Message02
                        ,  @c_Message03
                        ,  @n_Qty_ID
                      )

               IF @@ERROR <> 0
               BEGIN 
                  SET @n_Continue = 3
                  SET @c_ErrMsg   =  ERROR_MESSAGE()
               END

               IF @n_Continue = 1
               BEGIN
                  SET @CUR_UPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT rd.ReceiptKey
                        ,rd.ReceiptLineNumber
                  FROM #RECEIPTDETAIL_WIP rd (NOLOCK)
                  WHERE rd.ReceiptKey = @c_ReceiptKey
                  AND   rd.ToID = @c_FromID
                  ORDER BY rd.ReceiptKey
                        ,  rd.ReceiptLineNumber

                  OPEN @CUR_UPD 

                  FETCH NEXT FROM @CUR_UPD INTO @c_ReceiptKey, @c_ReceiptLineNumber 

                  WHILE @@FETCH_STATUS <> -1
                  BEGIN
                     UPDATE RECEIPTDETAIL WITH (ROWLOCK)
                        SET PutawayLoc = @c_FinalLoc
                           ,TrafficCop = NULL
                           ,EditDate = GETDATE()
                           ,EditWho  = SUSER_SNAME()
                     WHERE ReceiptKey = @c_ReceiptKey
                     AND   ReceiptLineNumber = @c_ReceiptLineNumber

                     IF @@ERROR <> 0
                     BEGIN
                        SET @n_Continue = 3
                        SET @n_Err = 60220
                        SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                                      +': Reset PutawayLoc ON Receiptdetail table fail.'
                                      + ' (mspPARL03)'
                        BREAK
                     END 
                     FETCH NEXT FROM @CUR_UPD INTO @c_ReceiptKey, @c_ReceiptLineNumber 
                  END
                  CLOSE @CUR_UPD
                  DEALLOCATE @CUR_UPD
               END
            END TRY
            BEGIN CATCH
               SET @n_Continue = 3
               SET @n_Err = 60230
               SET @c_Errmsg = ERROR_MESSAGE()
               
               IF (XACT_STATE()) = -1                                                             
               BEGIN
                  ROLLBACK TRAN
               END                 
            END CATCH                                                                
         END

         IF @n_Continue IN (3,0)                                                      
         BEGIN
            IF @n_Err_rv = 0 
            BEGIN
               SET @n_Err_rv = @n_Err
               SET @c_Errmsg_rv = @c_Errmsg
            END

            IF @@TRANCOUNT > 0                                                   
            BEGIN
               ROLLBACK TRAN
            END
         END
         ELSE IF @n_Continue = 1 
         BEGIN
            SET @n_NoOfTasks = @n_NoOfTasks + 1                                 
            WHILE @@TRANCOUNT > 0                                                                                 
            BEGIN
               COMMIT TRAN
            END
         END
      END
      
      IF @n_Continue IN (3,0)                                                      
      BEGIN
         IF @n_Err_rv = 0 
         BEGIN
            SET @n_Err_rv = @n_Err
            SET @c_Errmsg_rv = @c_Errmsg
         END
      END
   END -- WHILE @n_Continue <> 0

   SET @n_Continue = 1
   QUIT_SP:
   
   IF OBJECT_ID('tempdb..#TMP_GRP') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_GRP;
   END

   IF OBJECT_ID('tempdb..#TMP_GRP_LPN') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_GRP_LPN;
   END
   
   IF OBJECT_ID('tempdb..#TMP_ID_STYLE') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_ID_STYLE;
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTCnt
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
      execute nsp_logerror @n_err, @c_errmsg, 'mspPARL03'
   END
   ELSE
   BEGIN
      IF @n_NoOfTasks > 0  
      BEGIN
         SET @c_errmsg = 'Total PAF Task: ' +CONVERT(NVARCHAR(5), @n_NoOfTasks)+ ' released sucessfully.'
                       + CASE WHEN @n_Err_rv > 0 THEN ' With Error: ' + @c_Errmsg_rv ELSE '' END
      END
      ELSE IF @n_NoOfTasks = 0  
      BEGIN
         SET @c_errmsg = 'No PAF Task released.'
                       + CASE WHEN @n_Err_rv > 0 THEN ' With Error: ' + @c_Errmsg_rv ELSE '' END
                       
      END
 
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END