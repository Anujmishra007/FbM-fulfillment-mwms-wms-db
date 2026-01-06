SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Stored Procedure: mspPARL01                                          */
/* Creation Date: 2025-04-15                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: UWP-32707 - FCR-3957 - JCB Putaway Using TM SCE             */
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
/* 2025-05-20  Wan      1.0   UWP-32707 - FCR-3957 - JCB Putaway Using  */
/* 2025-07-16                 TM SCE                                    */
/* 2025-07-25  Wan01    1.1   UWP-38325 - GBRProd-ASN Release-Putaway   */
/*                            issue                                     */
/*                            PerformanceTune to reduce blocking        */
/*                            Remove WIP update                         */
/* 2025-10-10  SSA01    1.2   UWP-42248 -Enhanced session management    */
/************************************************************************/

CREATE OR ALTER PROC dbo.mspPARL01
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
         , @n_NoOfTasks          INT            = 0
         , @n_RowID              INT            = 0         
         , @b_True               BIT            = 1

         , @c_UDF01              NVARCHAR(60)   = ''
         , @c_UDF02              NVARCHAR(60)   = ''
         , @c_UDF03              NVARCHAR(60)   = ''
         , @c_UDF04              NVARCHAR(60)   = ''
         , @c_UDF05              NVARCHAR(60)   = ''
         , @c_LocationGroups     NVARCHAR(200)  = ''

         , @c_Facility           NVARCHAR(5)    = ''
         , @c_Storerkey          NVARCHAR(15)   = ''
         , @c_ReceiptLineNumber  NVARCHAR(5)    = ''
         , @c_Sku                NVARCHAR(20)   = ''
         , @c_Lot                NVARCHAR(10)   = ''
         , @n_Qty_ID             INT            = 0
         , @c_PalletKey          NVARCHAR(10)   = ''
         , @c_PalletType         NVARCHAR(10)   = ''
         , @c_Style              NVARCHAR(10)   = ''
         , @n_Length_P           FLOAT          = 0.00
         , @n_Width_P            FLOAT          = 0.00
         , @n_height_P           FLOAT          = 0.00
         , @n_GrossWgt_P         FLOAT          = 0.00
         , @n_WeightLimit        FLOAT          = 0.00
         , @n_NoOfLoc            INT            = 0
         , @n_MaxPallet          INT            = 0
         , @n_LocLevel           INT            = 0
         , @c_Areakey            NVARCHAR(10)   = ''
         , @c_Putawayzone        NVARCHAR(10)   = ''
         , @c_LocationGroup      NVARCHAR(10)   = ''
         , @c_LocationCategory   NVARCHAR(10)   = ''
         , @c_LocationCategory_F NVARCHAR(10)   = ''
         , @c_LocAisle           NVARCHAR(10)   = ''
         , @c_Floor              NVARCHAR(6)    = ''
         , @c_LocationRoom       NVARCHAR(10)   = ''
         , @c_TaskDetailKey      NVARCHAR(10)   = ''
         , @c_TaskType           NVARCHAR(10)   = 'PAF'
         , @c_UOM                NVARCHAR(10)   = '1'
         , @c_SourceType         NVARCHAR(30)   = ''

         , @c_PickMethod         NVARCHAR(10)   = 'FP'
         , @c_Loc_PND            NVARCHAR(10)   = ''
         , @c_Loc_PNDIN          NVARCHAR(10)   = ''
         , @c_FromID             NVARCHAR(18)   = ''
         , @c_FromLoc            NVARCHAR(10)   = ''
         , @c_ToLoc              NVARCHAR(10)   = ''
         , @c_FinalLoc           NVARCHAR(10)   = ''
         
         , @c_FromLogicalLoc     NVARCHAR(10)   = ''
         , @c_ToLogicalLoc       NVARCHAR(10)   = ''

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

   IF OBJECT_ID('tempdb..#TMP_GRP') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_GRP;
   END

   CREATE TABLE #TMP_GRP                                                      
   (  Loc                  NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LogicalLocation      NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  Facility             NVARCHAR(5)    NOT NULL DEFAULT('') 
   ,  LocationGroup        NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LocationCategory     NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LocLevel             INT            NOT NULL DEFAULT(0)
   ,  LocAisle             NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LocationRoom         NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  MaxPallet            INT            NOT NULL DEFAULT(0)
   ,  [Floor]              NVARCHAR(6)    NOT NULL DEFAULT('')
   )

   IF OBJECT_ID('tempdb..#TMP_GRP_STYLE') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_GRP_STYLE;
   END

   CREATE TABLE #TMP_GRP_STYLE                                                       
   (  RowID                INT            IDENTITY(1,1) PRIMARY KEY
   ,  Loc                  NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LogicalLocation      NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  Facility             NVARCHAR(5)    NOT NULL DEFAULT('') 
   ,  LocationGroup        NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LocationCategory     NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LocLevel             INT            NOT NULL DEFAULT(0)
   ,  LocAisle             NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LocationRoom         NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  [Floor]              NVARCHAR(6)    NOT NULL DEFAULT('')
   ,  MaxPallet            INT            NOT NULL DEFAULT(0)
   ,  WeightLimit          FLOAT          NOT NULL DEFAULT(0.00)
   )

   IF OBJECT_ID('tempdb..#TMP_OCPGRP_STYLE') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_OCPGRP_STYLE;
   END

   CREATE TABLE #TMP_OCPGRP_STYLE                                                      
   (  RowID                INT            IDENTITY(1,1)  
   ,  Loc                  NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LogicalLocation      NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  Facility             NVARCHAR(5)    NOT NULL DEFAULT('') 
   ,  LocationGroup        NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LocationCategory     NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LocLevel             INT            NOT NULL DEFAULT(0)
   ,  LocAisle             NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LocationRoom         NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  [Floor]              NVARCHAR(6)    NOT NULL DEFAULT('')
   )
   CREATE NONCLUSTERED INDEX ix_tmpOCPGRP ON #TMP_OCPGRP_STYLE 
   (LocationGroup, LocationCategory, LocLevel, Loc, LocAisle, LocationRoom, [Floor]);

   IF OBJECT_ID('tempdb..#TMP_PND') IS NOT NULL                                     --(Wan01) - START
   BEGIN
      DROP TABLE #TMP_PND;
   END

   CREATE TABLE #TMP_PND                                                      
   (  Loc                  NVARCHAR(10)   NOT NULL PRIMARY KEY
   ,  Facility             NVARCHAR(5)    NOT NULL DEFAULT ('')
   ,  LogicalLocation      NVARCHAR(10)   NOT NULL DEFAULT ('')      
   ,  LocationType         NVARCHAR(10)   NOT NULL DEFAULT ('')
   ,  LocationFlag         NVARCHAR(10)   NOT NULL DEFAULT ('')
   ,  LocationGroup        NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LocationCategory     NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LocLevel             INT            NOT NULL DEFAULT(0)
   ,  LocAisle             NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  LocationRoom         NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  MaxPallet            INT            NOT NULL DEFAULT(0)
   ,  [Floor]              NVARCHAR(6)    NOT NULL DEFAULT('')
   )

   CREATE NONCLUSTERED INDEX ix_TMP_PND_1 ON #TMP_PND 
   (Facility, LocationCategory, LocAisle, [Floor]);

   IF OBJECT_ID('tempdb..#TMP_BEAMLOC') IS NOT NULL                                 
   BEGIN
      DROP TABLE #TMP_BEAMLOC;
   END

   CREATE TABLE #TMP_BEAMLOC                                                      
   (  LocationGroup        NVARCHAR(10)   DEFAULT ('')
   ,  LocationCategory     NVARCHAR(10)   DEFAULT ('')
   ,  LocAisle             NVARCHAR(10)   DEFAULT ('')
   ,  LocationRoom         NVARCHAR(10)   DEFAULT ('')
   ,  LocLevel             INT            DEFAULT (0)
   ,  [Status]             NVARCHAR(10)   DEFAULT ('')
   ,  StartLoc             NVARCHAR(10)   DEFAULT ('')
   ,  EndLoc               NVARCHAR(10)   DEFAULT ('')
   ,  EmptyLocCount        INT            DEFAULT (1)
   ,  EmptyLPNCount        INT            DEFAULT (1)
   ,  LocCount             INT            DEFAULT (1)
   ,  TotalPalletWeights   FLOAT          DEFAULT (0.00)
   )                                                                                --(Wan01) - END
   
   IF EXISTS ( SELECT 1 FROM RECEIPT r (NOLOCK)
               WHERE r.ReceiptKey = @c_ReceiptKey
               AND   r.ASNStatus < '9'
              )
   BEGIN
      SET @n_Continue = 3
      SET @n_Err = 60110
      SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)+': ASN has not closed yet. (mspPARL01)'
      GOTO QUIT_SP
   END
  
   --IF EXISTS ( SELECT 1 FROM RECEIPTDETAIL rd (NOLOCK)                            --(Wan01) --2025-06-11  
   --            WHERE rd.ReceiptKey = @c_ReceiptKey  
   --            AND   rd.PutawayLoc = 'WIP'
   --           )  
   --BEGIN  
   --    GOTO QUIT_SP 
   --END
   
   WHILE @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END

   SET @CUR_PAID = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT rd.ReceiptKey
         ,rd.ReceiptLineNumber
   FROM dbo.RECEIPTDETAIL rd (NOLOCK)
   JOIN LOTxLOCxID lli (NOLOCK) ON lli.StorerKey = rd.StorerKey
                                AND lli.Loc = rd.ToLoc
                                AND lli.ID  = rd.ToID
   LEFT OUTER JOIN TaskDetail td (NOLOCK) ON  td.FromLoc = rd.ToLoc
                                          AND td.FromID  = rd.ToID
                                          AND td.FinalLoc= rd.PutawayLoc
                                          AND td.Storerkey = rd.Storerkey
                                          AND td.TaskType  = @c_TaskType 
                                          AND td.Sourcekey = rd.ReceiptKey
   WHERE rd.ReceiptKey = @c_ReceiptKey
   AND   rd.ToID > ''
   AND   rd.PutawayLoc > ''
   AND   rd.FinalizeFlag = 'Y'
   AND   lli.Qty > 0
   GROUP BY rd.ReceiptKey
         ,  rd.ReceiptLineNumber
   HAVING COUNT(1) = SUM(CASE WHEN ISNULL(td.[Status],'X') = 'X' THEN 1 ELSE 0 END)
   ORDER BY rd.ReceiptKey
         ,  rd.ReceiptLineNumber

   OPEN @CUR_PAID

   FETCH NEXT FROM @CUR_PAID INTO @c_ReceiptKey, @c_ReceiptLineNumber

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      UPDATE RECEIPTDETAIL WITH (ROWLOCK)
         SET PutawayLoc = ''
            ,TrafficCop = NULL
            ,EditDate = dbo.fnc_GetDate()   --(SSA01)
            ,EditWho  = dbo.fnc_GetUserName()          --(SSA01)
      WHERE ReceiptKey = @c_ReceiptKey
      AND   ReceiptLineNumber = @c_ReceiptLineNumber

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 60120
         SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)+': Reset PutawayLoc ON Receiptdetail table fail. (mspPARL01)'
         GOTO QUIT_SP
      END

      FETCH NEXT FROM @CUR_PAID INTO @c_ReceiptKey, @c_ReceiptLineNumber
   END
   CLOSE @CUR_PAID
   DEALLOCATE @CUR_PAID

   WHILE @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END

   SELECT @c_Facility = r.Facility
         ,@c_Storerkey= r.StorerKey
   FROM Receipt r (NOLOCK)
   WHERE r.ReceiptKey = @c_ReceiptKey
   
   INSERT INTO #TMP_GRP ( Loc, LogicalLocation, Facility          
                        , LocationGroup, LocationCategory, LocLevel, LocAisle          
                        , LocationRoom, [Floor], MaxPallet
                        )
   SELECT loc = MIN(CASE WHEN ISNULL(l.LocationRoom,'') = '' THEN l.Loc ELSE '' END)
         ,LogicalLocation = ISNULL(MIN(l.LogicalLocation),'') 
         ,l.Facility
         ,LocationGroup = ISNULL(l.LocationGroup,'')
         ,l.LocationCategory
         ,l.LocLevel
         ,LocAisle = ISNULL(l.LocAisle,'')
         ,LocationRoom = ISNULL(l.LocationRoom,'')
         ,[Floor] = ISNULL(l.[Floor],'')
         ,MaxPallet = ISNULL(SUM(l.MaxPallet),0)
   FROM LOC l (NOLOCK)
   WHERE l.Facility = @c_Facility
   AND   l.LocationFlag IN ('', 'NONE')
   AND   l.[Status] = 'OK'
   AND   l.MaxPallet > 0
   GROUP BY CASE WHEN ISNULL(l.LocationRoom,'') = '' THEN l.Loc ELSE '' END
         ,  l.Facility
         ,  ISNULL(l.LocationGroup,'')
         ,  l.LocationCategory
         ,  ISNULL(l.LocAisle,'')
         ,  ISNULL(l.[Floor],'')
         ,  l.LocLevel
         ,  ISNULL(l.LocationRoom,'')

   INSERT INTO #TMP_PND ( Loc, LogicalLocation, Facility, LocationType, LocationFlag   --(Wan01)     
                        , LocationGroup, LocationCategory, LocLevel, LocAisle          
                        , LocationRoom, [Floor], MaxPallet
                        )
   SELECT l.loc  
         ,l.LogicalLocation 
         ,l.Facility
         ,l.LocationType
         ,l.LocationFlag
         ,LocationGroup = ISNULL(l.LocationGroup,'')
         ,l.LocationCategory
         ,l.LocLevel
         ,LocAisle = ISNULL(l.LocAisle,'')
         ,LocationRoom = ISNULL(l.LocationRoom,'')
         ,[Floor] = ISNULL(l.[Floor],'')
         ,MaxPallet = ISNULL(l.MaxPallet,0)
   FROM LOC l (NOLOCK)
   WHERE l.Facility = @c_Facility
   AND   l.LocationCategory = 'PNDIN'

   INSERT INTO @TMP_PA_CL (Listname, Code, Description, Short, Long, Notes, Notes2, Storerkey, UDF01, UDF02, UDF03, UDF04, UDF05, Code2)  
   SELECT CODELKUP.Listname   
        , CODELKUP.Code   
        , [Description] = ISNULL(CODELKUP.[Description],'')   
        , Short = ISNULL(CODELKUP.Short,'')      
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
   WHERE CODELKUP.Listname = 'JCBFAMILYT'  
   AND   CODELKUP.Storerkey = @c_Storerkey
   ORDER BY CODELKUP.Code 

   INSERT INTO @TMP_PA_CL (Listname, Code, Description, Short, Long, Notes, Notes2, Storerkey, UDF01, UDF02, UDF03, UDF04, UDF05, Code2)  
   SELECT CODELKUP.Listname   
        , CODELKUP.Code   
        , [Description] = ISNULL(CODELKUP.[Description],'')   
        , Short = ISNULL(CODELKUP.Short,'')      
        , Long  = ISNULL(CODELKUP.Long ,'')     
        , Notes = ISNULL(CODELKUP.Notes,'')      
        , Notes2= ISNULL(CODELKUP.Notes2,'')          
        , CODELKUP.Storerkey  
        , UDF01 = CASE WHEN ISNUMERIC(CODELKUP.UDF01) = 1 THEN CODELKUP.UDF01 ELSE '0.00' END 
        , UDF02 = CASE WHEN ISNUMERIC(CODELKUP.UDF02) = 1 THEN CODELKUP.UDF02 ELSE '0.00' END 
        , UDF03 = CASE WHEN ISNUMERIC(CODELKUP.UDF03) = 1 THEN CODELKUP.UDF03 ELSE '0.00' END 
        , UDF04 = CASE WHEN ISNUMERIC(CODELKUP.UDF04) = 1 THEN CODELKUP.UDF04 ELSE '0.00' END 
        , UDF05 = CASE WHEN ISNUMERIC(CODELKUP.UDF05) = 1 THEN CODELKUP.UDF05 ELSE '0.00' END 
        , CODELKUP.Code2  
   FROM CODELKUP (NOLOCK)  
   WHERE CODELKUP.Listname = 'JCBLOCCAP'  
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

   INSERT INTO @TMP_PA_CL (Listname, Code, Description, Short, Long, Notes, Notes2, Storerkey, UDF01, UDF02, UDF03, UDF04, UDF05, Code2)  
   SELECT CODELKUP.Listname   
        , CODELKUP.Code   
        , [Description] = ISNULL(CODELKUP.[Description],'')   
        , Short = ISNULL(CODELKUP.Short,'')      
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
   WHERE CODELKUP.Listname = 'JCBBKTOLOC' 
   AND CODELKUP.Storerkey = @c_Storerkey
   ORDER BY CODELKUP.Code

   SET @CUR_PAID = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT rd.ReceiptKey
         ,rd.Storerkey
         ,Sku = CASE WHEN COUNT(DISTINCT rd.Sku) = 1 THEN MIN(rd.Sku) ELSE '' END
         ,rd.ToLoc
         ,rd.ToID
         ,PalletKey  = ISNULL(pm.PalletKey,'')
         ,PalletType = ISNULL(pm.PalletType,'')
         ,Qty_ID   = SUM(rd.QtyReceived)
         ,[Length] = ISNULL(pm.[Length],0.00)
         ,Width    = ISNULL(pm.[Width] ,0.00)
         ,Height   = ISNULL(pm.[Height],0.00)
         ,GrossWgt = ISNULL(pm.GrossWgt,0.00)
   FROM dbo.RECEIPTDETAIL rd (NOLOCK)
   LEFT OUTER JOIN Pallet pm (NOLOCK) ON pm.Palletkey = rd.ToID
   WHERE rd.ReceiptKey = @c_ReceiptKey
   AND   rd.ToID > ''
   AND   rd.PutawayLoc = ''
   AND   rd.FinalizeFlag = 'Y'
   GROUP BY rd.ReceiptKey
         ,  rd.Storerkey
         ,  rd.ToLoc
         ,  rd.ToID
         ,  ISNULL(pm.PalletKey,'')
         ,  ISNULL(pm.PalletType,'')
         ,  pm.[Length]
         ,  pm.[Width]
         ,  pm.[Height]
         ,  pm.GrossWgt
   ORDER BY rd.ReceiptKey
         ,  rd.ToID

   OPEN @CUR_PAID 

   FETCH NEXT FROM @CUR_PAID INTO @c_ReceiptKey, @c_Storerkey, @c_Sku 
                                 ,@c_FromLoc, @c_FromID, @c_PalletKey, @c_PalletType, @n_Qty_ID
                                 ,@n_Length_P, @n_Width_P, @n_Height_P, @n_GrossWgt_P

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      SET @b_True = 1
      SET @n_Continue   = 1
      SET @n_Err        = 0
      SET @c_ErrMsg     = ''      
      SET @n_MaxPallet  = 0
      SET @n_NoOfLoc    = 0
      SET @c_Loc_PND    = ''
      SET @c_ToLoc = ''
      SET @c_FinalLoc = ''
      SET @c_LocationCategory_F = ''
      
      --BEGIN TRAN                                                                  --(Wan01)  --2025-06-11
      --UPDATE RECEIPTDETAIL WITH (ROWLOCK)
      --SET PutawayLoc = 'WIP'
      --   ,TrafficCop = NULL
      --WHERE Receiptkey = @c_Receiptkey
      --AND ToLoc = @c_FromLoc 
      --AND ToID  = @c_FromID

      IF @@ERROR <> 0  
      BEGIN  
         SET @n_Continue = 3  
         SET @n_Err = 60122 
         SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)+': Set PutawayLoc to ''WIP''. (mspPARL01)'  
      END  
      
      IF @b_Debug = 1
      BEGIN
         PRINT ' @c_FromLoc: '+ @c_FromLoc
              +',@c_FromID: '+ @c_FromID
      END
      
      IF @n_Continue = 1
      BEGIN
         IF @c_PalletKey = ''
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 60130
            SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                          + ': Pallet Key not Found. LPN: ' + @c_FromID
                          + ' (mspPARL01)'
            IF @n_Err_rv = 0 
            BEGIN
               SET @n_Err_rv = @n_Err
               SET @c_Errmsg_rv = @c_Errmsg
            END
         END
      END
      
      IF @n_Continue = 1
      BEGIN
         IF @n_Length_P = 0.00 OR @n_Width_P = 0.00 OR @n_Height_P = 0.00 OR  
            @n_GrossWgt_P = 0.00
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 60140
            SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                          + ': Bad Pallet key dimension setup. LPN: ' + @c_FromID
                          + ' (mspPARL01)'
            IF @n_Err_rv = 0 
            BEGIN
               SET @n_Err_rv = @n_Err
               SET @c_Errmsg_rv = @c_Errmsg
            END
         END
      END

      IF @n_Continue = 1
      BEGIN
         SELECT TOP 1 @n_NoOfLoc = cl.Short 
         FROM @TMP_PA_CL cl  
         WHERE cl.ListName = 'JCBPALTYPE'
         AND   cl.Code = @c_PalletType

         IF @n_NoOfLoc = 0
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 60150
            SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                          + ': Bad setup IN JCBPalType. LPN: ' + @c_FromID
                          + ' (mspPARL01)'
            IF @n_Err_rv = 0 
            BEGIN
               SET @n_Err_rv = @n_Err
               SET @c_Errmsg_rv = @c_Errmsg
            END
         END
      END

      IF @n_Continue = 1  
      BEGIN
         SET @c_UDF01 = ''
         SET @c_UDF02 = ''
         SET @c_UDF03 = ''
         SET @c_UDF04 = ''
         SET @c_UDF05 = ''
         SET @c_LocationGroups = ''

         SELECT TOP 1
                @c_Style = CASE WHEN MIN(s.Style) = '' OR lg.Code IS NULL 
                                THEN '' ELSE MIN(s.Style) END
               ,@c_UDF01 = lg.UDF01
               ,@c_UDF02 = lg.UDF02
               ,@c_UDF03 = lg.UDF03
               ,@c_UDF04 = lg.UDF04
               ,@c_UDF05 = lg.UDF05
         FROM RECEIPTDETAIL rd (NOLOCK)
         JOIN SKU s (NOLOCK) ON  s.Storerkey  = rd.Storerkey
                             AND s.Sku = rd.Sku
         LEFT OUTER JOIN @TMP_PA_CL lg ON  lg.ListName = 'JCBFAMILYT'
                                       AND lg.Code = s.Style
         WHERE rd.ToLoc = @c_FromLoc
         AND   rd.ToID  = @c_FromID
         AND   rd.ReceiptKey = @c_ReceiptKey                                        --(Wan01)
         GROUP BY lg.Code
               ,  lg.Long 
               ,  lg.UDF01
               ,  lg.UDF02
               ,  lg.UDF03
               ,  lg.UDF04
               ,  lg.UDF05
         ORDER BY lg.Long 

         IF @c_Style =  ''
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 60160
            SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                          + ': Bad Sku Style or no setup in JCBFamilyT. LPN: ' + @c_FromID
                          + ' (mspPARL01)'
            IF @n_Err_rv = 0 
            BEGIN
               SET @n_Err_rv = @n_Err
               SET @c_Errmsg_rv = @c_Errmsg
            END
         END

         IF @n_Continue = 1
         BEGIN
            IF @c_UDF01 > '' SET @c_LocationGroups = @c_LocationGroups + @c_UDF01 + ','
            IF @c_UDF02 > '' SET @c_LocationGroups = @c_LocationGroups + @c_UDF02 + ','
            IF @c_UDF03 > '' SET @c_LocationGroups = @c_LocationGroups + @c_UDF03 + ','
            IF @c_UDF04 > '' SET @c_LocationGroups = @c_LocationGroups + @c_UDF04 + ','
            IF @c_UDF05 > '' SET @c_LocationGroups = @c_LocationGroups + @c_UDF05 + ','

            IF RIGHT(@c_LocationGroups,1) = ','
            BEGIN
               SET @c_LocationGroups = SUBSTRING(@c_LocationGroups,1, LEN(@c_LocationGroups)-1)
            END

            IF @c_LocationGroups =  ''
            BEGIN
               SET @n_Continue = 3
               SET @n_Err = 60170
               SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                              + ': Bad LocationGroup Setup in JCBFamilyT. LPN: ' + @c_FromID
                             + ' (mspPARL01)'
               IF @n_Err_rv = 0 
               BEGIN
                  SET @n_Err_rv = @n_Err
                  SET @c_Errmsg_rv = @c_Errmsg
               END
            END
         END

         IF @n_Continue = 1 AND NOT EXISTS ( SELECT 1
                                             FROM LOC l (NOLOCK)
                                             JOIN STRING_SPLIT(@c_LocationGroups, ',') ss 
                                                      ON ss.[value] = l.LocationGroup
                                             WHERE l.Facility = @c_Facility 
                                           )
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 60180
            SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)
                          + ': Invalid Location Group. ' + @c_FromID
                          + ' (mspPARL01)'
            IF @n_Err_rv = 0 
            BEGIN
               SET @n_Err_rv = @n_Err
               SET @c_Errmsg_rv = @c_Errmsg
            END                        
         END
      END

      IF @n_Continue = 1 
      BEGIN
         TRUNCATE TABLE #TMP_GRP_STYLE;

         ;with lg AS                                                                --2025-06-03
         (  SELECT RowID = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
                  ,locationGroup = ss.[value]
            FROM STRING_SPLIT(@c_LocationGroups, ',') ss 
         )
         INSERT INTO #TMP_GRP_STYLE ( Loc, LogicalLocation, Facility          
                                    , LocationGroup, LocationCategory, LocLevel, LocAisle          
                                    , LocationRoom, [Floor], MaxPallet, WeightLimit
                                    )
         SELECT l.loc               
               ,l.LogicalLocation  
               ,l.Facility
               ,l.LocationGroup
               ,l.LocationCategory
               ,l.LocLevel
               ,l.LocAisle
               ,l.LocationRoom
               ,l.[Floor]
               ,l.MaxPallet  
               ,ca.UDF05
         FROM #TMP_GRP l (NOLOCK)
         JOIN lg ON lg.LocationGroup = l.LocationGroup                              --2025-06-03
         JOIN @TMP_PA_CL ca ON  ca.LISTNAME = 'JCBLOCCAP'
                            AND ca.Short = l.LocationCategory
                            AND ca.Long  = l.LocLevel
         WHERE ca.UDF01 >= @n_Length_P
         AND   ca.UDF02 >= @n_Width_P
         AND   ca.UDF03 >= @n_height_P
         AND   ca.UDF04 >= @n_GrossWgt_P
         ORDER BY lg.RowID, l.LogicalLocation                                       --2025-06-03

         SET @CUR_PALOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT l.RowID 
               ,l.Loc
               ,l.LocationCategory
               ,l.LocLevel
               ,l.LocAisle
               ,l.LocationRoom
               ,l.[Floor]
               ,l.MaxPallet 
               ,l.WeightLimit
               ,Loc_PND = ISNULL(pnd.Loc,'')
         FROM #TMP_GRP_STYLE l  
         LEFT OUTER JOIN #TMP_OCPGRP_STYLE og ON  og.LocationGroup = l.LocationGroup
                                        AND og.LocationCategory = l.LocationCategory
                                        AND og.LocLevel = l.LocLevel
                                        AND og.LocAisle = l.LocAisle
                                        AND og.LocationRoom = l.LocationRoom
                                        AND og.[Floor]  = l.[Floor]
                                        AND og.Loc      = l.Loc 
         LEFT OUTER JOIN #TMP_PND pnd ON  pnd.Facility = l.Facility
                                      AND pnd.LocationCategory = 'PNDIN'
                                      AND pnd.LocAisle = l.LocAisle
                                      AND pnd.[Floor]  = l.[Floor]
         WHERE og.RowID IS NULL
         AND   NOT EXISTS (SELECT 1 FROM LotxLocxID lli (NOLOCK)
                           WHERE lli.Storerkey =  @c_Storerkey
                           AND   lli.Loc = pnd.Loc
                           AND   lli.Loc > ''
                           AND   lli.ID  > ''
                           AND   lli.Qty + lli.PendingMoveIn > 0                    --2025-06-11
                           GROUP BY lli.Loc
                           HAVING COUNT(DISTINCT lli.ID) >= pnd.MaxPallet           --2025-06-03
                           )
         ORDER BY l.RowID, l.LogicalLocation 

         OPEN @CUR_PALOC 

         FETCH NEXT FROM @CUR_PALOC INTO @n_RowId, @c_ToLoc, @c_LocationCategory, @n_LocLevel
                                       , @c_LocAisle, @c_LocationRoom, @c_Floor
                                       , @n_MaxPallet, @n_WeightLimit
                                       , @c_Loc_PNDIN

         WHILE @@FETCH_STATUS <> -1 AND @b_True = 1
         BEGIN
            SET @c_FinalLoc = @c_ToLoc
            SET @c_LocationCategory_F = ''

            IF @b_Debug = 1
            BEGIN
               PRINT   '@c_FromID : '+ @c_FromID
                     + ', @c_LocationGroups: '+ @c_LocationGroups                 
                     + ', @c_LocationCategory: '+ @c_LocationCategory
                     + ', @c_LocationRoom: ' + @c_LocationRoom 
                     + ', @c_LocAisle:' + @c_LocAisle 
                     + ', @n_LocLevel: ' + CAST(@n_LocLevel AS NVARCHAR)
                     + ', @c_ToLoc: ' + @c_ToLoc
                     + ', @c_Loc_PNDIN: ' + @c_Loc_PNDIN
               PRINT   '  @n_WeightLimit: ' + CAST(@n_WeightLimit AS NVARCHAR) 
                     + ', @n_NoOfLoc: ' + CAST (@n_NoOfLoc AS NVARCHAR)
                     + ', @n_GrossWgt_P : ' + CAST (@n_GrossWgt_P  AS NVARCHAR)
            END

            IF @c_LocationRoom > ''  
            BEGIN
               TRUNCATE TABLE #TMP_BEAMLOC;

               INSERT INTO #TMP_BEAMLOC  
                  (  LocationGroup         
                  ,  LocationCategory      
                  ,  LocAisle              
                  ,  LocationRoom          
                  ,  LocLevel              
                  ,  [Status]              
                  ,  StartLoc              
                  ,  EndLoc                
                  ,  EmptyLocCount         
                  ,  EmptyLPNCount         
                  ,  LocCount              
                  ,  TotalPalletWeights
                  )
               SELECT 
                     bl.LocationGroup         
                  ,  bl.LocationCategory      
                  ,  bl.LocAisle              
                  ,  bl.LocationRoom          
                  ,  bl.LocLevel              
                  ,  bl.[Status]              
                  ,  bl.StartLoc              
                  ,  bl.EndLoc                
                  ,  bl.EmptyLocCount         
                  ,  bl.EmptyLPNCount         
                  ,  bl.LocCount              
                  ,  bl.TotalPalletWeights
               FROM dbo.fnc_GetBeamLoc(@c_Storerkey, @c_Facility
                                    ,  @c_LocationGroups, @c_LocationCategory, @c_LocAisle
                                    ,  @c_LocationRoom,  @n_LocLevel) bl 
                                       
               IF @b_Debug = 2
               BEGIN
                  SELECT TOP 5 l.Loc, bl.EmptyLPNCount, bl.LocCount, bl.Status
                  FROM #TMP_BEAMLOC bl 
                  JOIN LOC l (NOLOCK) ON l.Loc = bl.StartLoc
                  WHERE bl.TotalPalletWeights + @n_GrossWgt_P <= @n_WeightLimit
                  ORDER BY l.LogicalLocation
               END
               
               SELECT TOP 1 @c_FinalLoc = l.Loc
               FROM #TMP_BEAMLOC bl 
               JOIN LOC l (NOLOCK) ON l.Loc = bl.StartLoc
               WHERE bl.TotalPalletWeights + @n_GrossWgt_P <= @n_WeightLimit
               AND   bl.LocCount >= @n_NoOfLoc
               AND   bl.EmptyLPNCount >= @n_NoOfLoc
               ORDER BY l.LogicalLocation
            END
            
            IF @c_LocationRoom = '' AND @c_FinalLoc > ''  
            BEGIN   
               IF EXISTS ( SELECT 1  
                           FROM LotxLocxid lli (NOLOCK)    
                           LEFT OUTER JOIN Pallet pm (NOLOCK) ON pm.PalletKey = lli.ID  
                           WHERE lli.Storerkey = @c_Storerkey  
                           AND   lli.loc = @c_FinalLoc                              --2025-06-11 - (Start)
                           AND   lli.id > ''  
                           AND   lli.Qty + lli.PendingMoveIn > 0                    
                           GROUP BY lli.Loc  
                           HAVING SUM(ISNULL(pm.GrossWgt,0.00)) + @n_GrossWgt_P > @n_WeightLimit  
                           OR  COUNT(DISTINCT lli.id) >= @n_MaxPallet               --2025-06-11 - (END)   
                           )  
               BEGIN  
                  SET @c_FinalLoc = ''  
               END  
            END 
            
            IF @c_FinalLoc = '' 
            BEGIN
               INSERT INTO #TMP_OCPGRP_STYLE ( Loc, LogicalLocation, Facility          
                                       , LocationGroup, LocationCategory, LocLevel, LocAisle          
                                       , LocationRoom, [Floor] 
                                       )
               SELECT  Loc, LogicalLocation, Facility          
                     , LocationGroup, LocationCategory, LocLevel, LocAisle          
                     , LocationRoom, [Floor]
               FROM #TMP_GRP_STYLE
               WHERE RowID = @n_RowID
            END
            ELSE IF @c_FinalLoc > '' 
            BEGIN
               SET @b_True = 0
               SET @c_LocationCategory_F = @c_LocationCategory
               SET @c_Loc_PND = @c_Loc_PNDIN
            END

            FETCH NEXT FROM @CUR_PALOC INTO @n_RowId, @c_ToLoc, @c_LocationCategory, @n_LocLevel
                                          , @c_LocAisle, @c_LocationRoom, @c_Floor
                                          , @n_MaxPallet, @n_WeightLimit
                                          , @c_Loc_PNDIN
         END
         CLOSE @CUR_PALOC
         DEALLOCATE @CUR_PALOC
      END

      IF @b_Debug = 1
      BEGIN
         PRINT   '  @c_FinalLoc: '+ @c_FinalLoc
               + ', @c_Loc_PND: ' + @c_Loc_PND
               + ', @c_LocationCategory_F: ' + @c_LocationCategory_F
      END

      IF @n_Continue = '1' AND @c_FinalLoc > ''
      BEGIN
         SELECT @c_FinalLoc = ISNULL(cl.Long,'')
         FROM @TMP_PA_CL cl
         WHERE cl.LISTNAME = 'JCBBKTOLOC'
         AND   cl.Code = @c_LocationCategory_F
      END

      IF @n_Continue = '1' AND @c_FinalLoc = ''
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 60190
         SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)+': Suggested loc not found. LPN: ' + @c_FromID
                       + ' (mspPARL01)'
         IF @n_Err_rv = 0 
         BEGIN
            SET @n_Err_rv = @n_Err
            SET @c_Errmsg_rv = @c_Errmsg
         END
      END

      BEGIN TRAN                                                                    --(Wan01) 
      IF @n_Continue = 1
      BEGIN
         EXECUTE nspg_GetKey
           @KeyName     = 'TaskDetailKey'
         , @fieldlength = 10
         , @keystring   = @c_TaskDetailKey OUTPUT
         , @b_Success   = @b_success       OUTPUT
         , @n_err       = @n_err           OUTPUT
         , @c_errmsg    = @c_errmsg        OUTPUT

         IF NOT @b_success = 1
         BEGIN
            SET @n_Continue = 3

            IF @n_Err_rv = 0 
            BEGIN
               SET @n_Err_rv = @n_Err
               SET @c_Errmsg_rv = @c_Errmsg
            END
            GOTO QUIT_SP
         END

         IF @n_Continue = 1
         BEGIN
            SET @c_ToLoc = @c_FinalLoc
            IF @c_Loc_PND > ''
            BEGIN
               SET @c_ToLoc = @c_Loc_PND
            END

            SET @c_Putawayzone  = ''
            SET @c_LocationGroup= ''
            SET @c_LocationCategory =  ''
            
            SELECT TOP 1 
                   @c_Putawayzone   = l.PutawayZone
                  ,@c_LocationGroup = ISNULL(l.LocationGroup,'')                    --2025-07-16
                  ,@c_LocationCategory = l.LocationCategory
            FROM dbo.LOC l (NOLOCK)
            WHERE Loc = @c_ToLoc

            SELECT TOP 1                                                            --2025-06-03
                   @c_Areakey = a.AreaKey
            FROM dbo.LOC l (NOLOCK)
            JOIN AreaDetail a (NOLOCK) ON a.PutawayZone = l.PutawayZone
            WHERE Loc = @c_FromLoc
            ORDER BY a.AreaKey

            SET @c_Lot = ''
            SELECT @c_Lot = CASE WHEN COUNT(DISTINCT lli.Lot) > 1 THEN '' ELSE MIN (lli.Lot) END
            FROM LOTxLOCxID lli (NOLOCK)
            WHERE lli.Storerkey = @c_Storerkey
            AND   lli.Loc = @c_FromLoc
            AND   lli.ID  = @c_FromID
            GROUP BY lli.Storerkey
                  ,  lli.Loc
                  ,  lli.ID

            BEGIN TRY                                                               --2025-06-03
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
                        ,  'mspPARL01'
                        ,  @c_Receiptkey
                        ,  @c_Areakey
                        ,  @c_PutawayZone
                        ,  @c_LocationGroup
                        ,  @c_LocationCategory
                        ,  @n_Qty_ID
                      )

               IF @@ERROR <> 0
               BEGIN 
                  SET @n_Continue = 3
                  SET @c_ErrMsg   =  ERROR_MESSAGE()

                  IF @n_Err_rv = 0 
                  BEGIN
                     SET @n_Err_rv = @n_Err
                     SET @c_Errmsg_rv = @c_Errmsg
                  END
               END

               IF @n_Continue = 1
               BEGIN
                  SET @CUR_UPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT rd.ReceiptKey
                        ,rd.ReceiptLineNumber
                  FROM dbo.RECEIPTDETAIL rd (NOLOCK)
                  WHERE rd.ReceiptKey = @c_ReceiptKey
                  AND   rd.ToLoc= @c_FromLoc
                  AND   rd.ToID = @c_FromID
                  AND   rd.PutawayLoc = ''                                          --(Wan01)
                  ORDER BY rd.ReceiptKey
                        ,  rd.ReceiptLineNumber

                  OPEN @CUR_UPD 

                  FETCH NEXT FROM @CUR_UPD INTO @c_ReceiptKey, @c_ReceiptLineNumber 

                  WHILE @@FETCH_STATUS <> -1
                  BEGIN
                     UPDATE RECEIPTDETAIL WITH (ROWLOCK)
                        SET PutawayLoc = @c_FinalLoc
                           ,TrafficCop = NULL
                           ,EditDate = dbo.fnc_GetDate()   --(SSA01)
                           ,EditWho  = dbo.fnc_GetUserName()         --(SSA01)
                     WHERE ReceiptKey = @c_ReceiptKey
                     AND   ReceiptLineNumber = @c_ReceiptLineNumber

                     IF @@ERROR <> 0
                     BEGIN
                        SET @n_Continue = 3
                        SET @n_Err = 60200
                        SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)+': Reset PutawayLoc ON Receiptdetail table fail.'
                                      + ' (mspPARL01)'

                        IF @n_Err_rv = 0 
                        BEGIN
                           SET @n_Err_rv = @n_Err
                           SET @c_Errmsg_rv = @c_Errmsg
                        END
                        GOTO QUIT_SP
                     END 
                     FETCH NEXT FROM @CUR_UPD INTO @c_ReceiptKey, @c_ReceiptLineNumber 
                  END
                  CLOSE @CUR_UPD
                  DEALLOCATE @CUR_UPD
               END
            END TRY
            BEGIN CATCH
               SET @n_Continue = 3
               SET @n_Err = 60210
               SET @c_Errmsg = ERROR_MESSAGE()

               IF @n_Err_rv = 0 
               BEGIN
                  SET @n_Err_rv = @n_Err
                  SET @c_Errmsg_rv = @c_Errmsg
               END
               
               IF (XACT_STATE()) = -1                                                             
               BEGIN
                  ROLLBACK TRAN
               END                 
            END CATCH                                                                
         END
      END

      IF @n_Continue = 3                                                      --2025-06-11
      BEGIN
         IF @@TRANCOUNT > 0                                                   
         BEGIN
            ROLLBACK TRAN
         END
      END
      ELSE IF @n_Continue = 1 
      BEGIN
         SET @n_NoOfTasks = @n_NoOfTasks + 1                                  --2025-06-03
         WHILE @@TRANCOUNT > 0                                                --(Wan01)                                     
         BEGIN
            COMMIT TRAN
         END
      END                                                                     --2025-06-11
            
      FETCH NEXT FROM @CUR_PAID INTO @c_ReceiptKey, @c_Storerkey, @c_Sku 
                                    ,@c_FromLoc, @c_FromID, @c_PalletKey, @c_PalletType, @n_Qty_ID
                                    ,@n_Length_P, @n_Width_P, @n_Height_P, @n_GrossWgt_P
   END
   CLOSE @CUR_PAID
   DEALLOCATE @CUR_PAID

   SET @n_Continue = 1
   QUIT_SP:
   
   IF OBJECT_ID('tempdb..#TMP_GRP') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_GRP;
   END

   IF OBJECT_ID('tempdb..#TMP_LOCGRP') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_LOCGRP;
   END

   IF OBJECT_ID('tempdb..#TMP_GRP_STYLE') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_GRP_STYLE;
   END

   IF OBJECT_ID('tempdb..#TMP_OCPGRP_STYLE') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_OCPGRP_STYLE;
   END

   IF OBJECT_ID('tempdb..#TMP_PND') IS NOT NULL                                     --(Wan01) - START
   BEGIN
      DROP TABLE #TMP_PND;
   END
   
   IF OBJECT_ID('tempdb..#TMP_BEAMLOC') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_BEAMLOC;
   END                                                                              --(Wan01) - END

   IF @n_Err_rv > 0
   BEGIN
      SET @n_Err = @n_Err_rv
      SET @c_Errmsg = @c_Errmsg_rv
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
      execute nsp_logerror @n_err, @c_errmsg, 'mspPARL01'
   END
   ELSE
   BEGIN
      IF @n_NoOfTasks > 0 AND @n_Err_rv = 0
      BEGIN
         SET @c_errmsg = 'Total PAF Task: ' +CONVERT(NVARCHAR(5), @n_NoOfTasks)+ ' released sucessfully.'
      END
      ELSE IF @n_NoOfTasks = 0 AND @n_Err_rv = 0
      BEGIN
         SET @c_errmsg = 'No PAF Task released.'
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