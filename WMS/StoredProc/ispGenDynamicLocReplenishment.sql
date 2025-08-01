SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/      
/* Stored Procedure: ispGenDynamicLocReplenishment                      */      
/* Creation Date: 30-Jun-2009                                           */      
/* Copyright: IDS                                                       */      
/* Written by: Shong                                                    */      
/*                                                                      */      
/* Purpose: SOS140686                                                   */      
/*          Replenishment and Dynamic Pick location assignment          */      
/*                                                                      */      
/* Called By: RCM Option From Wave maintenance Screen                   */      
/*                                                                      */      
/* PVCS Version: 1.0                                                    */      
/*                                                                      */      
/* Version: 6.0                                                         */      
/*                                                                      */      
/* Data Modifications:                                                  */      
/*                                                                      */      
/* Updates:                                                             */      
/* Date         Author   Ver  Purposes                                  */      
/* 01-Feb-2010  Shong    1.0  Added new storer config control to force  */    
/*                            grouping by SKU instead of Style          */    
/* 27-May-2011  NJOW01   1.1  216932-Empty id for dynamic pick loc      */    
/* 21-Jun-2011  TLTING   1.2  Performance Tune, SQL std, TraceInfo      */    
/* 23-Jun-2011  TLTING   1.3  Commit by line                            */    
/* 09-Nov-2011  SHONG    1.4  Assign Dny Loc by SKU, Lottable02         */    
/*                            (SHONG001) SkipJack Project               */    
/* 13-Dec-2011  SHONG    1.5  Do not allow more then 1 Storer Config    */    
/*                            Replenishment Grouping Set in system      */    
/* 20-Dec-2011  SHONG    1.6  Include Qty Allocated > 0 As Non-Empty Loc*/    
/* 30-Dec-2011  ChewKP   1.7  Do Not Loose ID when Generate Replen      */  
/*                            (ChewKP01)                                */  
/* 31-Dec-2011  James    1.8  Use config to control whether reuse last  */  
/*                            DP LOC if no more empty DP LOC (james01)  */ 
/* 09-Jan-2012  James    1.9  Check facility between orders.facility and*/  
/*                            start dynamic loc (james02)               */
/* 2012-01-12   ChewKP   2.0  Insert PICKRESLOG to TransmitLog3         */
/*                            (ChewKP02)                                */
/* 2012-02-21   Shong    2.1  Bug Fixing - Wrong Zone                   */
/* 2012-04-02   SHONG    2.2  Exclude HOLD Location when search DPP Loc */
/*                            SOS#240525                                */
/* 2012-04-07   SHONG    2.3  Validate Tot PickDet Qty vs Replen Qty    */
/* 2025-02-03   Wan01    2.4  UWP-29796 - Error on Gen Replenishment for*/
/*                            multiple pickdetail record for same lot,  */
/*                            loc and id                                */
/* 2025-02-24                 - fixed incorrect pendingmovein           */
/* 2025-03-07                 - fixed to ID                             */
/* 2025-02-26   Wan02    2.5  UWP-30442[FCR-2635][UL-Riyadh] Automating */
/*                            base on Bulk Zone to find toloc           */
/************************************************************************/      
CREATE OR ALTER PROC [dbo].[ispGenDynamicLocReplenishment]     
   @cWaveKey NVARCHAR(10),    
   @bSuccess INT OUTPUT,    
   @nErrNo   INT OUTPUT,    
   @cErrMsg  NVARCHAR(215) OUTPUT    
AS
BEGIN    
   SET NOCOUNT ON    
   SET ANSI_NULLS OFF       
   SET QUOTED_IDENTIFIER OFF       
   SET CONCAT_NULL_YIELDS_NULL OFF         
    
        
   DECLARE @cStartDynamicP_PalletLoc   NVARCHAR(20) = ''   
         , @cStartDynamicP_RackLoc     NVARCHAR(20) = ''   
         , @cDynamicP_PalletZone       NVARCHAR(10) = ''   
         , @cDynamicP_RackZone         NVARCHAR(10) = ''   
         , @nDynPalletCBM              FLOAT    
         , @nContinue                  INT    
         , @nStartTranCount            INT    
         , @cFacility                  NVARCHAR(5)    
         , @cDynGroup                  NVARCHAR(50)                                     
         , @cStorerKey                 NVARCHAR(15)    
         , @cSKU                       NVARCHAR(20)    
         , @cLOT                       NVARCHAR(10)    
         , @cLOC                       NVARCHAR(10)    
         , @cID                        NVARCHAR(18)    
         , @cNextDynPickLoc            NVARCHAR(10)    
         , @bDebug                     INT    
         , @nRowID                     INT    
         , @cReplenishmentKey          NVARCHAR(10)    
         , @cPickDetailKey             NVARCHAR(10)    
         , @nErr                       INT    
         , @nQty                       INT    
         , @cDynamicPickLoc            NVARCHAR(10)    
         , @cPackKey                   NVARCHAR(10)    
         , @cUOM                       NVARCHAR(10)    
         , @cGenDynLocReplenBySKUBatch NVARCHAR(10)    
         , @cDynLocReplenNotGetLastLoc NVARCHAR(1)  -- (james01)  
         , @cOrders_Facility           NVARCHAR(5)   -- (james02)
         , @c_authority_pickreslog     NVARCHAR(1)   -- Generic Pick Release Interface -- (ChewKP02)
         , @c_OrderKey                 NVARCHAR(10)  -- (ChewKP02)
         , @b_success                  INT  -- (CheWKP02)
         , @nPDT_TotReplenQty          INT 
         , @nRPL_TotReplenQty          INT 
         , @c_ToID                     NVARCHAR(18) = ''                            --(Wan01) 
         
         , @b_UserDefineStartDP        BIT   = 1                                    --(Wan02)
         , @b_UserDefineStartDR        BIT   = 1                                    --(Wan02)
         , @b_ReplByAvailZone          BIT   = 0                                    --(Wan02)
         , @n_LoopTrue                 INT   = 0                                    --(Wan02)
         , @n_RowID_FB                 INT   = 0                                    --(Wan02)
         , @n_RowID_DynPK              INT   = 0                                    --(Wan02)
         , @n_RowID_RZ                 INT   = 0                                    --(Wan02)
         , @c_Fromloc                  NVARCHAR(10)   = ''                          --(Wan02) 
         , @c_LocType                  NVARCHAR(10)   = ''                          --(Wan02)
         , @c_LocType1                 NVARCHAR(10)   = ''                          --(Wan02)
         , @c_LocType2                 NVARCHAR(10)   = ''                          --(Wan02)
         , @c_PAFrZone                 NVARCHAR(10)   = ''                          --(Wan02)           
         , @c_PAToZone                 NVARCHAR(10)   = ''                          --(Wan02) 
         , @c_DynGroup_P               NVARCHAR(50)   = ''                          --(Wan02)  
                                       
         , @c_DYNPICKP_Zone_P          NVARCHAR(10)   = ''                          --(Wan02)
         , @c_DYNPICKR_Zone_P          NVARCHAR(10)   = ''                          --(Wan02)         
         , @c_GenDynLocReplenBySKU     NVARCHAR(10)   = ''                          --(Wan02)           
         , @c_IdenticalToBulk          NVARCHAR(500)  = ''                          --(Wan02)
         , @c_IdenticalRepl            NVARCHAR(10)   = ''                          --(Wan02)
         , @c_IdenticalRepl01          NVARCHAR(30)   = ''                          --(Wan02)
         , @c_FindSimilarDP            NVARCHAR(10)   = ''                          --(Wan02)
         , @c_FindSimilarDR            NVARCHAR(10)   = ''                          --(Wan02)
         , @c_NextSeqType              NVARCHAR(10) = ''                            --(Wan02)
         , @c_ReplenByGroup            NVARCHAR(500)= ''                            --(Wan02)   
         , @c_SeqType                  NVARCHAR(10) = ''                            --(Wan02)           
         , @c_GroupBy                  NVARCHAR(4000) = ''                          --(Wan02) 
         , @c_OrderBy                  NVARCHAR(4000) = ''                          --(Wan02)
                                       
         , @c_SQL                      NVARCHAR(MAX)  = ''                          --(Wan02)
         , @c_SQLParms                 NVARCHAR(4000) = ''                          --(Wan02)
                                       
         , @CUR_ZONE                   CURSOR                                       --(Wan02)
         , @CUR_IDTC                   CURSOR                                       --(Wan02) 
         
   DECLARE  @TMP_CODELKUP TABLE                                                     --(Wan02)
      (                           
       [LISTNAME]    [nvarchar](10)    NULL,  
       [Code]        [nvarchar](30)    NULL,  
       [Description] [nvarchar](250)   NULL,  
       [Short]       [nvarchar](10)    NULL,  
       [Long]        [nvarchar](250)   NULL,  
       [Notes]       [nvarchar](4000)  NULL,  
       [Notes2]      [nvarchar](4000)  NULL,  
       [Storerkey]   [nvarchar](50)    NOT NULL,  
       [UDF01]       [nvarchar](60)    NOT NULL,  
       [UDF02]       [nvarchar](60)    NOT NULL,  
       [UDF03]       [nvarchar](60)    NOT NULL,  
       [UDF04]       [nvarchar](60)    NOT NULL,  
       [UDF05]       [nvarchar](60)    NOT NULL,  
       [code2]       [nvarchar](30)    NOT NULL  
       )  
        
   SET @nContinue = 0    
   SET @nErrNo = 0    
   SET @cErrMsg = ''    
   SET @nStartTranCount = @@TRANCOUNT     
   SET @nErrNo = 70500    
        
   SET @bDebug = 0    
   IF @bSuccess=9    
      SET @bDebug = 1    
        
   BEGIN TRAN   
        
   SELECT @cStartDynamicP_PalletLoc = WAVE.UserDefine02    
         ,@cStartDynamicP_RackLoc = WAVE.UserDefine03    
   FROM   WAVE WITH (NOLOCK)
   WHERE  Wavekey = @cWaveKey
    
   --(Wan02) - START
   SELECT TOP 1
              @cOrders_Facility = o.Facility
            , @cStorerkey = o.Storerkey
   FROM dbo.WaveDetail wd (NOLOCK)
   JOIN dbo.ORDERs o (NOLOCK) ON o.Orderkey = wd.Orderkey
   WHERE wd.Wavekey = @cWavekey
   ORDER BY wd.Wavedetailkey

   SET @cGenDynLocReplenBySKUBatch = '0'                                          
   SELECT @cGenDynLocReplenBySKUBatch = dbo.Fnc_GetRight (@cOrders_Facility, @cStorerkey, '', 'GenDynLocReplenBySKUBatch')
   SET @c_GenDynLocReplenBySKU = '0'
   SELECT @c_GenDynLocReplenBySKU = dbo.Fnc_GetRight (@cOrders_Facility, @cStorerkey, '', 'GenDynLocReplenBySKU')

   INSERT INTO @TMP_CODELKUP (Listname, Code, Description, Short, Long, Notes, Notes2, Storerkey, UDF01, UDF02, UDF03, UDF04, UDF05, Code2)  
   SELECT CODELKUP.Listname   
        , CODELKUP.Code   
        , ISNULL(CODELKUP.Description,'')   
        , ISNULL(CODELKUP.Short,'')      
        , ISNULL(CODELKUP.Long ,'')     
        , ISNULL(CODELKUP.Notes,'')      
        , ISNULL(CODELKUP.Notes2,'')      
        , CODELKUP.Storerkey  
        , CODELKUP.UDF01   
        , CODELKUP.UDF02   
        , CODELKUP.UDF03   
        , CODELKUP.UDF04   
        , CODELKUP.UDF05   
        , CODELKUP.Code2  
   FROM CODELKUP (NOLOCK)  
   WHERE CODELKUP.Listname = 'WAVEDYNRPL'  
   AND   CODELKUP.Storerkey IN ( '', @cStorerkey)
   ORDER BY Storerkey DESC
   
   SELECT TOP 1
          @c_IdenticalRepl   = cl.UDF01
         ,@c_IdenticalToBulk = cl.UDF02
   FROM @TMP_CODELKUP cl
   WHERE cl.Code = 'IdenticalRepl'
   ORDER BY cl.Storerkey DESC

   SELECT TOP 1 @c_NextSeqType = cl.UDF01
   FROM @TMP_CODELKUP cl
   WHERE cl.Code = 'NextSeqType'
   ORDER BY cl.Storerkey DESC

   SELECT TOP 1 
          @c_FindSimilarDP = cl.UDF01
         ,@c_FindSimilarDR = cl.UDF02
   FROM @TMP_CODELKUP cl
   WHERE cl.Code = 'FindSimilarLoc'
   ORDER BY cl.Storerkey DESC

   SELECT TOP 1 @c_ReplenByGroup = cl.Notes
   FROM @TMP_CODELKUP cl
   WHERE cl.Code = 'ReplenByGroup'
   ORDER BY cl.Storerkey DESC

   IF @c_IdenticalRepl = '' SET @c_IdenticalRepl = 'N'
   IF @c_FindSimilarDP = '' SET @c_FindSimilarDP = 'Y'
   IF @c_FindSimilarDR = '' SET @c_FindSimilarDR = 'Y'
   
   IF @c_IdenticalRepl = 'Y' AND @c_IdenticalToBulk = ''
   BEGIN
      SET @c_IdenticalToBulk = 'LOC.PUTAWAYZONE'
   END

   IF @c_NextSeqType > '' AND @c_IdenticalToBulk = ''
   BEGIN
      SET @c_IdenticalToBulk = 'LOC.PUTAWAYZONE' 
   END
 
   IF @c_IdenticalToBulk > ''
   BEGIN 
      IF EXISTS (SELECT 1 FROM string_split (@c_IdenticalToBulk,',') ss HAVING COUNT(1) > 1) 
      BEGIN    
         SET @nErrNo = @nErrNo+1    
         SET @cErrMsg = 'Allow 1 to setup 1 identicaltoBulk Column '    
         SET @nContinue = 3     
         GOTO ErrorHandling    
      END  
   END

   IF @c_IdenticalRepl = 'N'
   BEGIN
      IF ISNULL(RTRIM(@cStartDynamicP_PalletLoc) ,'')='' 
      BEGIN    
         SET @nErrNo = @nErrNo+1    
         SET @cErrMsg = 'Start Dynamic Pick Pallet Location Cannot Be Blank!'    
         SET @nContinue = 3     
         GOTO ErrorHandling    
      END     
      --Block Move Up - START   
      -- (james02)
      --SET @cOrders_Facility = ''                                                 --(Wan02)
      --SELECT DISTINCT TOP 1 @cOrders_Facility = ORDERS.Facility                  --(Wan02)
      --FROM ORDERS WITH (NOLOCK)                                                  --(Wan02)
      --JOIN WAVEDETAIL WITH (NOLOCK) ON  WAVEDETAIL.OrderKey = ORDERS.OrderKey    --(Wan02)
      --WHERE  WAVEDETAIL.WaveKey = @cWaveKey                                      --(Wan02)
     
      SELECT @cDynamicP_PalletZone = ISNULL(LOC.PutawayZone ,'')    
            ,@cFacility = LOC.Facility    
      FROM   LOC WITH (NOLOCK)    
      WHERE  LOC = @cStartDynamicP_PalletLoc    

      -- If Orders.Facility <> facility for start dynamic pallet loc (james02)
      IF @cOrders_Facility <> @cFacility
      BEGIN    
         SET @nErrNo = @nErrNo+1    
         SET @cErrMsg = 'Facility different between Pallet Start location '+RTRIM(@cStartDynamicP_PalletLoc)
            +' and ORDERS Facility'    
         SET @nContinue = 3     
         GOTO ErrorHandling    
      END     
    
      IF ISNULL(RTRIM(@cDynamicP_PalletZone) ,'')=''    
      BEGIN    
         SET @nErrNo = @nErrNo+1    
         SET @cErrMsg = 'Putaway Zone for Pallet Start location: '+@cStartDynamicP_PalletLoc     
            +' is BLANK.'    
            
         SET @nContinue = 3     
         GOTO ErrorHandling    
      END     
 
      SELECT @cDynamicP_RackZone = LOC.PutawayZone    
      FROM   LOC WITH (NOLOCK)    
      WHERE  LOC = @cStartDynamicP_RackLoc    
        
      --IF ISNULL(RTRIM(@cDynamicP_PalletZone) ,'')=''    
      --BEGIN    
      --   SET @nErrNo = @nErrNo+1    
      --   SET @cErrMsg = 'Putaway Zone for Rack Start location: '+@cStartDynamicP_PalletLoc     
      --      +' is BLANK.'    
        
      --   SET @nContinue = 3     
      --   GOTO ErrorHandling    
      --END     
      --Block Move Up - END
   END
   SET @cFacility = @cOrders_Facility
   --(Wan02) - END
   
   IF EXISTS(SELECT ORDERS.STORERKEY FROM ORDERS WITH (NOLOCK)    
            JOIN WAVEDETAIL WITH (NOLOCK)    
                  ON  WAVEDETAIL.OrderKey = ORDERS.OrderKey    
            JOIN STORERCONFIG SCFG WITH (NOLOCK) ON SCFG.StorerKey = ORDERS.StorerKey AND     
                     SCFG.ConfigKey IN ('GenDynLocReplenBySKU', 'GenDynLocReplenBySKUBatch') AND SCfg.sValue = '1'    
            WHERE  WAVEDETAIL.WaveKey = @cWaveKey     
            GROUP BY ORDERS.STORERKEY     
            HAVING COUNT(DISTINCT SCFG.ConfigKey) > 1 )     
   BEGIN    
      SET @nErrNo = @nErrNo+1    
      SET @cErrMsg = 'More Than One Replenishment Grouping Found in Storer Configuration. '    
      SET @nContinue = 3     
      GOTO ErrorHandling    
   END     
    
   --SET @cGenDynLocReplenBySKUBatch = '0'                                          --(Wan02) - START 
   --SELECT TOP 1 @cGenDynLocReplenBySKUBatch = ISNULL(RTRIM(SCfg.sValue),'0')     
   --FROM ORDERS WITH (NOLOCK)    
   --JOIN WAVEDETAIL WITH (NOLOCK) ON  WAVEDETAIL.OrderKey = ORDERS.OrderKey    
   --JOIN STORERCONFIG SCFG WITH (NOLOCK) ON SCFG.StorerKey = ORDERS.StorerKey AND     
   --                  SCFG.ConfigKey = 'GenDynLocReplenBySKUBatch'    
   --WHERE  WAVEDETAIL.WaveKey = @cWaveKey                                          --(Wan02) - END
  
   -- (james01)  
   SET @cDynLocReplenNotGetLastLoc = '0'    
   SELECT TOP 1 @cDynLocReplenNotGetLastLoc = ISNULL(RTRIM(SCfg.sValue),'0')     
   FROM ORDERS WITH (NOLOCK)    
   JOIN WAVEDETAIL WITH (NOLOCK) ON  WAVEDETAIL.OrderKey = ORDERS.OrderKey    
   JOIN STORERCONFIG SCFG WITH (NOLOCK) ON SCFG.StorerKey = ORDERS.StorerKey AND     
                     SCFG.ConfigKey = 'DynLocReplenNotGetLastLoc'    
   WHERE  WAVEDETAIL.WaveKey = @cWaveKey   

    -- Added By Shong on 07-Apr-2012                                                --(Wan02) - START 
    --DECLARE @nStorerConfigCount INT
    --SET @nStorerConfigCount = 0
  
    --SELECT @nStorerConfigCount = COUNT(DISTINCT SCFG.ConfigKey) 
    --FROM  ORDERS WITH (NOLOCK)    
    --JOIN WAVEDETAIL WITH (NOLOCK) ON  WAVEDETAIL.OrderKey = ORDERS.OrderKey  
    --JOIN STORERCONFIG SCFG WITH (NOLOCK) ON SCFG.StorerKey = ORDERS.StorerKey AND
    --     SCFG.ConfigKey IN ('GenDynLocReplenBySKU', 'GenDynLocReplenBySKUBatch') 
    --AND SCfg.sValue = '1' 
    --AND WAVEDETAIL.WaveKey = @cWaveKey
    --IF @nStorerConfigCount > 1 
    --BEGIN
    --    SET @nErrNo = @nErrNo+1    
    --    SET @cErrMsg = 'Found More then 1 Dynamic Replen Configuration Setup'    
    --    SET @nContinue = 3     
    --    GOTO ErrorHandling          
    --END                                                                           --(Wan02) - END 
                        
    CREATE TABLE #DynPick    
    (    
        RowID           INT IDENTITY(1 ,1)  Primary Key    
       ,PickDetailKey  NVARCHAR(10)    
       ,DynGroup       NVARCHAR(50)    
       ,StorerKey      NVARCHAR(15)    
       ,SKU            NVARCHAR(20)    
       ,LOT            NVARCHAR(10)    
       ,LOC            NVARCHAR(10)    
       ,ID             NVARCHAR(18)    
       ,Qty            INT    
       ,D_Pick_LOC     NVARCHAR(10)    
       ,StdCube        FLOAT    
    )    
        
   SET @c_SQL = N'SELECT PICKDETAIL.PickDetailKey'                                  --(Wan02) - START 
              + CASE WHEN @c_ReplenByGroup > ''
                     THEN ', ' + @c_ReplenByGroup  
                     WHEN @c_GenDynLocReplenBySKU = '1' 
                     THEN ', RTRIM(SKU.SKU)'
                     WHEN @cGenDynLocReplenBySKUBatch = '1' 
                     THEN ', RTRIM(SKU.SKU) + RTRIM(ISNULL(LOTATTRIBUTE.Lottable02,''''))'
                     ELSE ', ISNULL(SKU.Style ,'''')'  
                     END + ' AS DYNGROUP'
              + ',SKU.StorerKey'    
              + ',SKU.SKU'    
              + ',PICKDETAIL.LOT'    
              + ',PICKDETAIL.LOC'    
              + ',PICKDETAIL.ID'    
              + ',PICKDETAIL.Qty'    
              + ','''' AS D_Pick_Loc'    
              + ',SKU.StdCube'    
              + ' FROM PICKDETAIL WITH (NOLOCK)'    
              + ' JOIN WAVEDETAIL WITH (NOLOCK) ON WAVEDETAIL.OrderKey = PICKDETAIL.OrderKey'   
              + ' JOIN SKU WITH (NOLOCK) ON  SKU.StorerKey = PICKDETAIL.StorerKey'    
              +                        ' AND SKU.SKU = PICKDETAIL.SKU'    
              + ' JOIN LOC WITH (NOLOCK) ON  LOC.LOC = PICKDETAIL.LOC'    
              +                        ' AND LOC.LocationType NOT IN (''DYNPICKP'',''DYNPICKR'')'    
              + ' JOIN SKUxLOC WITH (NOLOCK) ON  SKUxLOC.StorerKey = PICKDETAIL.StorerKey'    
              +                            ' AND SKUxLOC.SKU = PICKDETAIL.SKU'    
              +                            ' AND SKUxLOC.LOC = PICKDETAIL.LOC'    
              +                            ' AND LOC.LocationType NOT IN (''PICK'' ,''CASE'')'    
              + ' JOIN LOTATTRIBUTE  WITH (NOLOCK) ON LOTATTRIBUTE.LOT = PICKDETAIL.LOT'  
              + ' WHERE WAVEDETAIL.WaveKey = @cWaveKey'
              + ' ORDER BY DYNGROUP, PICKDETAIL.PickDetailKey'

   SET @c_SQLParms = N'@cWaveKey NVARCHAR(10)'
        
   INSERT INTO #DynPick    
   (    
      PickDetailKey, DynGroup, StorerKey, SKU, LOT, LOC, ID, Qty, D_Pick_LOC,     
      StdCube    
   ) 
   EXEC sp_ExecuteSQL @c_SQL
                     ,@c_SQLParms
                     ,@cWaveKey                                                     --(Wan02) - END 
        
    IF EXISTS(SELECT 1 
              FROM #DynPick DP 
              JOIN PICKDETAIL p WITH (NOLOCK) ON DP.PickDetailKey = P.PickDetailKey 
              JOIN REPLENISHMENT r WITH (NOLOCK) ON R.ReplenishmentKey = P.PickHeaderKey 
                           AND r.Confirmed IN ('S', 'N')
              WHERE R.Wavekey = @cWaveKey )
    BEGIN
        SET @nErrNo = @nErrNo+1    
        SET @cErrMsg = 'Not Allow to Regenerate Modified PickDetail while Replenishment Already Generated'    
        SET @nContinue = 3     
        GOTO ErrorHandling                
   END
   
   IF EXISTS (SELECT TOP 1 1 FROM #DynPick WHERE DynGroup > '')                     --(Wan02) - START 
   BEGIN
      SET @c_LocType1 = 'DYNPICKP'
   END

   IF EXISTS (SELECT TOP 1 1 FROM #DynPick WHERE DynGroup = '')
   BEGIN
      SET @c_LocType2 = 'DYNPICKR'

      SELECT @nDynPalletCBM = ISNULL(SHORT ,'0')                                    --Move Down - START  
      FROM   CodeLkUp WITH (NOLOCK)    
      WHERE  ListName = 'DYNPICK' AND    
            CODE = 'DynPalletCBM'    
        
      IF ISNULL(RTRIM(@nDynPalletCBM) ,'0')='0'    
      BEGIN    
         SET @nErrNo = @nErrNo+1    
         SET @cErrMsg =     
            'Dynamic Pallet Location CBM Not Found in Code Lookup Table '    
            
         SET @nContinue = 3     
         GOTO ErrorHandling    
      END    
        
      IF ISNUMERIC(@nDynPalletCBM)<>1    
      BEGIN    
         SET @nErrNo = @nErrNo+1    
         SET @cErrMsg = 'Dynamic Pallet Location CBM Is not Numeric '    
         SET @nContinue = 3     
         GOTO ErrorHandling    
      END                                                                           --Move Down - END
   END

   IF @c_LocType1 = '' AND @c_LocType2 > ''
   BEGIN
      SET @c_LocType1 = @c_LocType2
   END

   IF @c_LocType2 = '' AND @c_LocType1 > ''
   BEGIN
      SET @c_LocType2 = @c_LocType1
   END

   IF OBJECT_ID('tempdb..#ReplTo','u') IS NOT NULL                                                          
   BEGIN
      DROP TABLE #ReplTo;
   END

   CREATE TABLE #ReplTo
      (  RowID             INT                        IDENTITY(1,1) PRIMARY KEY
      ,  Facility          NVARCHAR(5)    DEFAULT('')
      ,  FromLoc           NVARCHAR(10)   DEFAULT('')
      ,  [Zone]            NVARCHAR(10)   DEFAULT('')
      ,  IdenticalRepl01   NVARCHAR(30)   DEFAULT('')
      ,  ToLocType         NVARCHAR(10)   DEFAULT('')
      ,  SeqType           NVARCHAR(10)   DEFAULT('')
      ,  Used              INT            DEFAULT(0)
      )

   IF @c_IdenticalRepl= 'N'
   BEGIN
      SET @b_UserDefineStartDP = 1 
      SET @b_UserDefineStartDR = 1  
  
      IF @cDynamicP_PalletZone <> '' AND @c_LocType1 = 'DYNPICKP'
      BEGIN
         INSERT INTO #ReplTo ( Facility, FromLoc, [Zone], IdenticalRepl01, ToLocType )
         VALUES ( @cFacility, '', @cDynamicP_PalletZone, @cDynamicP_PalletZone, 'DYNPICKP')
      END

      IF @cDynamicP_RackZone <> '' AND @c_LocType2 = 'DYNPICKR'
      BEGIN
         INSERT INTO #ReplTo ( Facility, FromLoc, [Zone], IdenticalRepl01, ToLocType )
         VALUES ( @cFacility, '', @cDynamicP_RackZone, @cDynamicP_RackZone, 'DYNPICKR' )
      END
      ELSE IF @c_LocType2 = 'DYNPICKR' AND @cDynamicP_RackZone = ''
      BEGIN
         IF ISNULL(RTRIM(@cDynamicP_RackZone) ,'')=''                                  
         BEGIN    
            SET @nErrNo = @nErrNo+1    
            SET @cErrMsg = 'Putaway Zone for Rack Start location: '+ @cDynamicP_RackZone       
               +' is BLANK.'    
            
            SET @nContinue = 3     
            GOTO ErrorHandling    
         END
      END
   END
   ELSE 
   BEGIN
      SET @b_UserDefineStartDP = 0 
      SET @b_UserDefineStartDR = 0        
      SET @c_GroupBy = 'GROUP BY LOC.Facility, LOC.PutawayZone, floc.loc, LOC.LocationType'
      SET @c_OrderBy = 'ORDER BY LOC.Facility, LOC.PutawayZone, floc.Loc, LOC.LocationType'

      IF @c_IdenticalToBulk > ''
      BEGIN
         IF @c_IdenticalToBulk Not Like '%LOC.PutawayZone%'
         BEGIN
            SET @c_GroupBy = @c_GroupBy + ',' + @c_IdenticalToBulk
            SET @c_OrderBy = @c_OrderBy + ',' + @c_IdenticalToBulk
         END
      END

      SET @c_SQL = N'SELECT LOC.Facility, floc.Loc, LOC.PutawayZone, ToLocType = LOC.LocationType' 
                 + CASE WHEN @c_IdenticalToBulk = ''
                        THEN ', '''''  
                        ELSE ', ' + @c_IdenticalToBulk   
                        END 
                 + ' FROM LOC (NOLOCK)'
                 + ' JOIN LOC floc (NOLOCK) ON floc.Facility = LOC.Facility'
                 +                       ' AND floc.PutawayZone = LOC.PutawayZone'
                 +                       ' AND floc.LocationType NOT IN (''PICK'',''CASE'')' 
                 +           CASE WHEN @c_IdenticalToBulk = '' 
                                  THEN ''
                                  WHEN @c_IdenticalToBulk Like '%LOC.Putawayzone%' 
                                  THEN ''
                                  ELSE ' AND ' +REPLACE(@c_IdenticalToBulk,'LOC.','floc.') + ' = ' + @c_IdenticalToBulk
                                  END
                 + ' JOIN #DynPick dp ON dp.Loc = floc.Loc'     
                 + ' WHERE LOC.Facility = @c_Facility'
                 + ' AND LOC.[Status] = ''OK'''
                 + ' AND LOC.[LocationFlag] NOT IN (''HOLD'', ''DAMAGE'') '
                 + ' AND LOC.LocationType IN (@c_LocType1,@c_LocType2) '
                 + ' ' + @c_GroupBy
                 + ' ' + @c_OrderBy

      SET @c_SQLParms = N'@c_Facility   NVARCHAR(5)'
                      + ',@c_LocType1   NVARCHAR(10)'
                      + ',@c_LocType2   NVARCHAR(10)'
 
      INSERT INTO #ReplTo ( Facility, FromLoc, [Zone], ToLocType, IdenticalRepl01 )
      EXEC sp_ExecuteSQL @c_SQL
                        ,@c_SQLParms
                        ,@cFacility
                        ,@c_LocType1
                        ,@c_LocType2
   END                                                                                 

   IF @c_NextSeqType > ''       
   BEGIN 
      SET @c_SQL = N'SET @CUR_ZONE = CURSOR FAST_FORWARD READ_ONLY FOR' 

      IF @c_IdenticalToBulk > '' AND @c_IdenticalToBulk NOT Like '%LOC.PUTAWAYZONE%'
      BEGIN
         SET @c_SQL = @c_SQL + ' SELECT rt.FromLoc, rt.Zone, RowID = 0'
                              + ',rt.SeqType, rt.Zone, rt.ToLocType'
                              + ' FROM #ReplTo rt'
                              + ' GROUP BY rt.FromLoc, rt.Zone, rt.SeqType, rt.ToLocType'
                              + ' UNION'
      END

      IF @c_NextSeqType IN ('FWDBWD', 'FWD')
      BEGIN
         SET @c_SQL = @c_SQL  
                     + ' SELECT rt.FromLoc, LOC.PutawayZone'
                     + ',RowID = ((ROW_NUMBER() OVER (ORDER BY LOC.PutawayZone ASC)) * 2 ) - 1'
                     + ',SeqType = ''FWD'', rt.Zone, rt.ToLocType'
                     + ' FROM LOC (NOLOCK)'
                     + ' JOIN #ReplTo rt ON rt.Facility = LOC.Facility'
                     +                ' AND rt.ToLocType= LOC.LocationType'
                     + ' WHERE LOC.Facility = @c_Facility'
                     + ' AND LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'')'
                     + ' AND LOC.[Status] = ''OK'''
                     + ' AND LOC.PutawayZone >  rt.[Zone]'
                     + ' GROUP BY LOC.PutawayZone, rt.FromLoc, rt.Zone, rt.ToLocType'
      END

      IF @c_NextSeqType IN ('FWDBWD') 
      BEGIN
         SET @c_SQL = @c_SQL + ' UNION'
      END

      IF @c_NextSeqType IN ('FWDBWD', 'BWD')
      BEGIN
            SET @c_SQL = @c_SQL  
                     + ' SELECT rt.FromLoc, LOC.PutawayZone'
                     + ',RowID = (ROW_NUMBER() OVER (ORDER BY LOC.PutawayZone DESC)) * 2'
                     + ',SeqType = ''BWD'', rt.Zone, rt.ToLocType'
                     + ' FROM LOC (NOLOCK)'
                     + ' JOIN #ReplTo rt ON rt.Facility = LOC.Facility'
                     +                ' AND rt.ToLocType= LOC.LocationType'
                     + ' WHERE LOC.Facility = @c_Facility'
                     + ' AND LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'')'
                     + ' AND LOC.[Status] = ''OK'''
                     + ' AND LOC.PutawayZone <  rt.[Zone]'
                     + ' GROUP BY LOC.PutawayZone, rt.FromLoc, rt.Zone, rt.ToLocType'
      END

      SET @c_SQL = @c_SQL + ' ORDER BY FromLoc, RowID;'
         
      SET @c_SQL = @c_SQL + ' OPEN @CUR_ZONE;'

      SET @c_SQLParms = N'@c_Facility     NVARCHAR(5)'
                      + ',@CUR_ZONE       CURSOR       OUTPUT'
 
      EXEC sp_ExecuteSQL @c_SQL
                        ,@c_SQLParms
                        ,@cFacility
                        ,@CUR_ZONE        OUTPUT
 
      FETCH NEXT FROM @CUR_ZONE INTO @c_FromLoc, @c_PAToZone, @n_RowID_FB, @c_SeqType, @c_PAFrZone, @c_LocType
 
      WHILE @@FETCH_STATUS <> -1 
      BEGIN
         IF @c_IdenticalToBulk > '' AND  @c_IdenticalToBulk NOT Like '%LOC.PutAwayZone%'
         BEGIN
            SET @c_SQL = N'SET @CUR_IDTC = CURSOR FAST_FORWARD READ_ONLY FOR' 

            IF (@c_PAFrZone = @c_PAToZone AND @c_NextSeqType IN ('FWDBWD','FWD')) OR
                  @c_SeqType = 'FWD'
            BEGIN
               SET @c_SQL = @c_SQL  
                           + ' SELECT ' + @c_IdenticalToBulk
                           + ',RowID = ((ROW_NUMBER() OVER (ORDER BY ' + @c_IdenticalToBulk  + ' ASC)) * 2 ) - 1'
                           + ',SeqType = ''FWD'''
                           + ' FROM LOC (NOLOCK)'
                           + ' JOIN #ReplTo rt ON rt.Facility = LOC.Facility'
                           +                ' AND rt.ToLocType= LOC.LocationType'
                           + ' WHERE LOC.Facility = @c_Facility'
                           + ' AND LOC.PutawayZone = @c_PAToZone'
                           + ' AND LOC.LocationType = @c_LocType'
                           + ' AND LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'')'
                           + ' AND LOC.[Status] = ''OK'''
                           + ' AND rt.FromLoc = @c_FromLoc'
                           + CASE WHEN @c_PAFrZone = @c_PAToZone
                                 THEN ' AND ' + @c_IdenticalToBulk + ' > rt.IdenticalRepl01'  
                                 ELSE ' '
                                 END
                           + ' GROUP BY ' + @c_IdenticalToBulk
            END

            IF @c_PAFrZone = @c_PAToZone AND @c_NextSeqType IN ('FWDBWD')
            BEGIN
               SET @c_SQL = @c_SQL + ' UNION'
            END
  
            IF (@c_PAFrZone = @c_PAToZone AND @c_NextSeqType IN ('FWDBWD','BWD')) OR
                  @c_SeqType = 'BWD'
            BEGIN
               SET @c_SQL = @c_SQL  
                           + ' SELECT ' + @c_IdenticalToBulk
                           + ',RowID = ((ROW_NUMBER() OVER (ORDER BY ' + @c_IdenticalToBulk  + ' DESC)) * 2 )'
                           + ',SeqType = ''BWD'''
                           + ' FROM LOC (NOLOCK)'
                           + ' JOIN #ReplTo rt ON rt.Facility = LOC.Facility'
                           +                ' AND rt.ToLocType= LOC.LocationType'
                           + ' WHERE LOC.Facility = @c_Facility'
                           + ' AND LOC.PutawayZone = @c_PAToZone'
                           + ' AND LOC.LocationType = @c_LocType'
                           + ' AND LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'')'
                           + ' AND LOC.[Status] = ''OK'''
                           + ' AND rt.FromLoc = @c_FromLoc'
                           + CASE WHEN @c_PAFrZone = @c_PAToZone
                                 THEN ' AND ' + @c_IdenticalToBulk + ' < rt.IdenticalRepl01'  
                                 ELSE ' '
                                 END
                           + ' GROUP BY ' + @c_IdenticalToBulk
            END
         
            SET @c_SQL = @c_SQL + ' ORDER BY RowID;'
         
            SET @c_SQL = @c_SQL + ' OPEN @CUR_IDTC;'

            SET @c_SQLParms = N'@c_Facility     NVARCHAR(5)'
                              + ',@c_FromLoc      NVARCHAR(10)'
                              + ',@c_PAToZone     NVARCHAR(10)'
                              + ',@c_LocType      NVARCHAR(10)'
                              + ',@CUR_IDTC       CURSOR       OUTPUT'
 
            EXEC sp_ExecuteSQL @c_SQL
                              ,@c_SQLParms
                              ,@cFacility
                              ,@c_FromLoc
                              ,@c_PAToZone
                              ,@c_LocType
                              ,@CUR_IDTC        OUTPUT

            FETCH NEXT FROM @CUR_IDTC INTO @c_IdenticalRepl01, @n_RowID_FB, @c_SeqType 
 
            WHILE @@FETCH_STATUS <> -1 
            BEGIN
               INSERT INTO #ReplTo ( Facility, FromLoc, [Zone], IdenticalRepl01, ToLocType, SeqType )
               VALUES (@cFacility, @c_FromLoc, @c_PAToZone, @c_IdenticalRepl01, @c_LocType, @c_SeqType  )

               FETCH NEXT FROM @CUR_IDTC INTO @c_IdenticalRepl01, @n_RowID_FB, @c_SeqType 
            END
            CLOSE @CUR_IDTC
            DEALLOCATE @CUR_IDTC
         END
         ELSE IF @c_IdenticalToBulk > ''
         BEGIN
            INSERT INTO #ReplTo ( Facility, FromLoc, [Zone], IdenticalRepl01, ToLocType, SeqType )
            VALUES (@cFacility, @c_FromLoc, @c_PAToZone, @c_PAToZone, @c_LocType, @c_SeqType )
         END

         FETCH NEXT FROM @CUR_ZONE INTO @c_FromLoc, @c_PAToZone, @n_RowID_FB, @c_SeqType, @c_PAFrZone, @c_LocType
      END
      CLOSE @CUR_ZONE
      DEALLOCATE @CUR_ZONE
   END                                                                              --(Wan02) - END  
              
--    CREATE UNIQUE CLUSTERED INDEX IX_DynPick_RowID ON #DynPick(RowID)    
   CREATE INDEX IX_DynPick_RowID ON #DynPick(StorerKey, DynGroup)    
        
   CREATE TABLE #DYNPICK_PALLET ( TOLOC NVARCHAR(10) )    
   --
   SET @c_SQL = N'SELECT R.TOLOC'                                                   --(Wan02) - START
              + ' FROM   REPLENISHMENT R WITH (NOLOCK) '   
              + '        JOIN LOC WITH (NOLOCK) ON  R.TOLOC = LOC.LOC' 
              + '        JOIN #ReplTo rz ON rz.[Zone] = LOC.PutawayZone'                        
              + '                       AND rz.ToLocType = LOC.LocationType'
              + CASE WHEN @c_IdenticalToBulk = '' THEN '' 
                     ELSE ' AND rz.IdenticalRepl01 = ' + @c_IdenticalToBulk 
                     END
              + ' WHERE  LOC.LocationType IN (''DYNPICKP'') AND'                   
              + '        LOC.Facility = @c_Facility AND'    
              + '        LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'')  AND'  
              + '        LOC.[Status]     <> ''HOLD'' AND' 
              + '        R.Confirmed<>''Y'''    
              + ' GROUP BY R.TOLOC'   
              + ' HAVING SUM(R.Qty)>0'

   SET @c_SQLParms = N'@c_Facility  NVARCHAR(5)'                                       
   INSERT INTO #DYNPICK_PALLET ( TOLOC )    
   EXEC sp_ExecuteSQL @c_SQL
                     ,@c_SQLParms
                     ,@cFacility                                                    --(Wan02) - END
 
        
    CREATE TABLE #DYNPICK_RACK ( TOLOC NVARCHAR(10))    
    SET @c_SQL = N'SELECT R.TOLOC'                                                  --(Wan02) - START
              + ' FROM   REPLENISHMENT R WITH (NOLOCK) '   
              + '        JOIN LOC WITH (NOLOCK) ON  R.TOLOC = LOC.LOC' 
              + '        JOIN #ReplTo rz ON rz.[Zone] = LOC.PutawayZone'                        
              + '                       AND rz.ToLocType = LOC.LocationType'
              + CASE WHEN @c_IdenticalToBulk = '' THEN '' 
                     ELSE ' AND rz.IdenticalRepl01 = ' + @c_IdenticalToBulk 
                     END
              + ' WHERE  LOC.LocationType IN (''DYNPICKR'') AND'                   
              + '        LOC.Facility = @c_Facility AND'    
              + '        LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'')  AND'  
              + '        LOC.[Status]     <> ''HOLD'' AND' 
              + '        R.Confirmed<>''Y'''    
              + ' GROUP BY R.TOLOC'   
              + ' HAVING SUM(R.Qty)>0'

   SET @c_SQLParms = N'@c_Facility  NVARCHAR(5)'
   
   INSERT INTO #DYNPICK_RACK( TOLOC )  
   EXEC sp_ExecuteSQL @c_SQL
               ,@c_SQLParms
               ,@cFacility                                                          --(Wan02) - END
             
   CREATE TABLE #DP_RACK_NON_EMPTY ( LOC NVARCHAR(10) )
   SET @c_SQL = N'SELECT SKUxLOC.LOC'                                               --(Wan02) - START
              + ' FROM SKUxLOC WITH (NOLOCK)'    
              + ' JOIN LOC WITH (NOLOCK) ON  SKUxLOC.LOC = LOC.LOC' 
              + ' JOIN #ReplTo rz ON rz.[Zone] = LOC.PutawayZone'                        
              + '                AND rz.ToLocType = LOC.LocationType'
              + CASE WHEN @c_IdenticalToBulk = '' THEN '' 
                     ELSE ' AND rz.IdenticalRepl01 = ' + @c_IdenticalToBulk 
                     END
              + ' WHERE  LOC.LocationType IN (''DYNPICKR'')'                   
              + ' AND    LOC.Facility = @c_Facility'    
              + ' AND    LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'')'  
              + ' AND    LOC.[Status] <> ''HOLD'' ' 
              + ' GROUP BY SKUxLOC.LOC '   
              + ' HAVING SUM((Qty - QtyPicked) + QtyAllocated)>0'
     
   SET @c_SQLParms = N'@c_Facility  NVARCHAR(5)'
   
   INSERT INTO #DP_RACK_NON_EMPTY ( LOC )  
   EXEC sp_ExecuteSQL @c_SQL
                     ,@c_SQLParms
                     ,@cFacility                                                    --(Wan02) - END
        
    CREATE TABLE #DP_PALLET_NON_EMPTY ( LOC NVARCHAR(10) ) 
    SET @c_SQL = N'SELECT SKUxLOC.LOC'                                              --(Wan02) - START
              + ' FROM SKUxLOC WITH (NOLOCK)'    
              + ' JOIN LOC WITH (NOLOCK) ON  SKUxLOC.LOC = LOC.LOC' 
              + ' JOIN #ReplTo rz ON rz.[Zone] = LOC.PutawayZone'                        
              + '                AND rz.ToLocType = LOC.LocationType'
              + CASE WHEN @c_IdenticalToBulk = '' THEN '' 
                     ELSE ' AND rz.IdenticalRepl01 = ' + @c_IdenticalToBulk 
                     END
              + ' WHERE  LOC.LocationType IN (''DYNPICKP'')'                   
              + ' AND    LOC.Facility = @c_Facility'    
              + ' AND    LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'')'  
              + ' AND    LOC.[Status] <> ''HOLD'' ' 
              + ' GROUP BY SKUxLOC.LOC '   
              + ' HAVING SUM((Qty - QtyPicked) + QtyAllocated)>0'
     
   SET @c_SQLParms = N'@c_Facility  NVARCHAR(5)'

   INSERT INTO #DP_PALLET_NON_EMPTY ( LOC )    
   EXEC sp_ExecuteSQL @c_SQL
                     ,@c_SQLParms
                     ,@cFacility                                                    --(Wan02) - END
        
    CREATE TABLE #SKUDynGroup    
    (    
        StorerKey  NVARCHAR(15)    
       ,SKU        NVARCHAR(20)    
       ,DynGroup   NVARCHAR(50)    
    )    
    
    INSERT INTO #SKUDynGroup    
      (    
        StorerKey, SKU, DynGroup    
      )    
    SELECT DISTINCT StorerKey    
          ,SKU    
          ,DynGroup    
    FROM #DynPick DynPick    
        
    -- Assign Pallet Dynamic Pick Location for Total Cube > DynPalletCBM    
    -- Initial the Value    
   SELECT @cNextDynPickLoc = ''     
  
   IF @bDebug = 1  
   BEGIN  
      SELECT * FROM #SKUDynGroup   
   END         
  
  IF @b_UserDefineStartDP = 1
   BEGIN
      DECLARE CUR_DynPallet_DynGroup  CURSOR LOCAL FAST_FORWARD READ_ONLY     
      FOR   SELECT StorerKey    
                  ,DynGroup
                  ,Loc = ''
                  ,ID  = ''
                  ,RowID_DynPK = 0
            FROM   #DynPick    
            WHERE  DynGroup>''    
            GROUP BY    
                   StorerKey    
                  ,DynGroup                 
                  --   HAVING SUM(Qty * StdCube) >= @nDynPalletCBM    
            ORDER BY    
                   StorerKey    
                  ,DynGroup   
   END
   ELSE IF @b_UserDefineStartDP = 0
   BEGIN
      DECLARE CUR_DynPallet_DynGroup  CURSOR LOCAL FAST_FORWARD READ_ONLY     
      FOR   SELECT t.StorerKey    
                  ,t.DynGroup 
                  ,t.Loc
                  ,t.ID
                  ,t.RowID
            FROM   #DynPick t   
            WHERE  t.DynGroup > ''    
            ORDER BY t.DynGroup   
                  ,  t.RowID
   END                                                                              --(Wan02) - END
        
   OPEN CUR_DynPallet_DynGroup     
        
   FETCH NEXT FROM CUR_DynPallet_DynGroup INTO @cStorerKey, @cDynGroup
                                             , @cLOC, @cID, @n_RowID_DynPK          --(Wan02)                                     
   WHILE @@FETCH_STATUS<>-1    
   BEGIN    
      GetNextDynamicPickPalletLocation:  
       SET @cNextDynPickLoc      = ''                                               --(Wan02) - START   
      SET @cDynamicP_PalletZone = ''
      SET @c_IdenticalRepl01    = '' 
      
      IF @cDynGroup = @c_DynGroup_P                                                            
      BEGIN
         SELECT TOP 1 @cNextDynPickLoc = D_Pick_Loc    
         FROM   #DynPick    
         WHERE  DynGroup = @cDynGroup 
      END 
                                    
      IF @cNextDynPickLoc = ''                                                                                                             
      BEGIN
         SET @n_RowID_RZ = 0
         SELECT TOP 1 
                 @n_RowID_RZ = rz.RowID
               , @cDynamicP_PalletZone = rz.[Zone]
               , @c_IdenticalRepl01 = rz.IdenticalRepl01
         FROM #ReplTo rz
         WHERE rz.ToLocType = 'DYNPICKP'
         AND   rz.FromLoc = @cLOC
         AND   rz.Used < 2
         ORDER BY rz.Used DESC, rz.RowID
      END                                                                               
      
      SET @n_LoopTrue = 1  
      WHILE @n_LoopTrue = 1 AND @cNextDynPickLoc = '' AND @cDynamicP_PalletZone > '' 
      BEGIN   
         IF ISNULL(RTRIM(@cNextDynPickLoc) ,'')='' AND @bDebug = 1 
            PRINT 'AAA- @cNextDynPickLoc: ' + @cNextDynPickLoc + ' @cDynGroup: ' +   @cDynGroup  
            
         IF ISNULL(RTRIM(@cNextDynPickLoc) ,'')='' AND @c_FindSimilarDP = 'Y'       
         BEGIN
            SET @c_SQL = N'SELECT TOP 1 @cNextDynPickLoc = LOC.LOC' 
                       + ' FROM   LotxLocxID LLI WITH (NOLOCK)'    
                       + ' JOIN #SKUDynGroup SKUDynGroup ON SKUDynGroup.StorerKey = LLI.StorerKey'    
                       +                              ' AND SKUDynGroup.SKU = LLI.SKU'    
                       + ' JOIN LOC WITH (NOLOCK) ON  LLI.LOC = LOC.LOC'  
                       + CASE WHEN @cGenDynLocReplenBySKUBatch = '1' 
                              THEN ' JOIN LOTATTRIBUTE WITH (NOLOCK) '
                       +           ' ON  SKUDynGroup.StorerKey = LA.StorerKey'    
                       +           ' AND SKUDynGroup.SKU = LA.SKU'  
                              ELSE '' END
                       + ' WHERE  SKUDynGroup.DynGroup = @cDynGroup'  
                       + CASE WHEN @cGenDynLocReplenBySKUBatch = '1' 
                              THEN ' AND (RTRIM(LOTATTRIBUTE.SKU) + RTRIM(LOTATTRIBUTE.Lottable02)) = @cDynGroup' 
                              ELSE '' END
                       + ' AND LOC.Facility = @c_Facility'
                       + ' AND LOC.LocationType IN (''DYNPICKP'')' 
                       + ' AND LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'')'  
                       + ' AND LOC.[Status] <> ''HOLD''' 
                       + CASE WHEN @c_IdenticalToBulk > '' 
                              THEN ' AND ' + @c_IdenticalToBulk + ' = @c_IdenticalRepl01' 
                              ELSE '' END
                       + ' AND LOC.PutawayZone = @cDynamicP_PalletZone'     
                       + ' AND (LLI.Qty-LLI.QtyPicked+LLI.QtyAllocated)<>0'

            SET @c_SQLParms = N'@c_Facility           NVARCHAR(5)'
                            + ',@cDynGroup            NVARCHAR(30)'
                            + ',@cDynamicP_PalletZone NVARCHAR(10)'
                            + ',@c_IdenticalRepl01    NVARCHAR(30)'
                            + ',@cNextDynPickLoc      NVARCHAR(10) OUTPUT'

            EXEC sp_ExecuteSQL @c_SQL
                              ,@c_SQLParms
                              ,@cFacility
                              ,@cDynGroup
                              ,@cDynamicP_PalletZone
                              ,@c_IdenticalRepl01
                              ,@cNextDynPickLoc      OUTPUT
 
            IF ISNULL(RTRIM(@cNextDynPickLoc) ,'')<>'' AND @bDebug = 1 
               PRINT 'BBB- @cNextDynPickLoc: ' + @cNextDynPickLoc + ' @cDynGroup: ' +   @cDynGroup  
         END                                                                        --(Wan02) - END
            
         -- If no location with same DynGroup found, then assign the empty location    
         IF ISNULL(RTRIM(@cNextDynPickLoc) ,'')=''    
         BEGIN  
            SET @c_SQL = N'SELECT TOP 1 @cNextDynPickLoc = LOC.LOC'                 --(Wan02) - START    
                       + ' FROM  LOC WITH (NOLOCK)'     
                       + ' WHERE LOC.Facility = @c_Facility'      
                       + ' AND  LOC.LocationType IN (''DYNPICKP'')'   
                       + ' AND  LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'')'     
                       + ' AND  LOC.[Status]     <> ''HOLD'''                          
                       + ' AND  LOC.PutawayZone = @cDynamicP_PalletZone' 
                       + CASE WHEN @c_IdenticalToBulk > ''  
                              THEN ' AND ' + @c_IdenticalToBulk + ' = @c_IdenticalRepl01' 
                              ELSE '' END                       
                       + ' AND  LOC.LOC>= @cStartDynamicP_PalletLoc'      
                       + ' AND  NOT EXISTS( '   
                       +                 ' SELECT 1'    
                       +                 ' FROM   #DP_PALLET_NON_EMPTY E'    
                       +                 ' WHERE  E.LOC = LOC.LOC'    
                       +                 ')'    
                       + ' AND  NOT EXISTS('    
                       +                 ' SELECT 1'    
                       +                 ' FROM   #DYNPICK_PALLET AS ReplenLoc'    
                       +                 ' WHERE  ReplenLoc.TOLOC = LOC.LOC '   
                       +                 ')'      
                       + ' AND  NOT EXISTS('    
                       +                 ' SELECT 1'    
                       +                 ' FROM   #DynPick AS DynPick'    
                       +                 ' WHERE  DynPick.D_Pick_Loc = LOC.LOC '   
                       +                 ' )'    
                       + ' ORDER BY LOC.LOC'  

            SET @c_SQLParms = N'@c_Facility                 NVARCHAR(5)'
                            + ',@cDynGroup                  NVARCHAR(30)'
                            + ',@cDynamicP_PalletZone       NVARCHAR(10)'
                            + ',@cStartDynamicP_PalletLoc   NVARCHAR(10)'
                            + ',@c_IdenticalRepl01          NVARCHAR(30)'
                            + ',@cNextDynPickLoc            NVARCHAR(10) OUTPUT'

            EXEC sp_ExecuteSQL @c_SQL
                              ,@c_SQLParms
                              ,@cFacility
                              ,@cDynGroup
                              ,@cDynamicP_PalletZone
                              ,@cStartDynamicP_PalletLoc
                              ,@c_IdenticalRepl01
                              ,@cNextDynPickLoc      OUTPUT
                              
            IF ISNULL(RTRIM(@cNextDynPickLoc) ,'')<>'' AND @bDebug = 1 
               PRINT 'DDD- @cNextDynPickLoc: ' + @cNextDynPickLoc + ' @cDynGroup: ' +   @cDynGroup
              
            SET @n_LoopTrue = 0   
            IF @cNextDynPickLoc = ''                     
            BEGIN
               UPDATE #ReplTo SET Used = 2
               WHERE RowID = @n_RowID_RZ

               SET @cDynamicP_PalletZone = ''
               SELECT TOP 1 
                    @n_RowID_RZ = rz.RowID
                  , @cDynamicP_PalletZone = rz.[Zone]
                  , @c_IdenticalRepl01 = rz.IdenticalRepl01
               FROM #ReplTo rz
               WHERE rz.RowID > @n_RowID_RZ
               AND   rz.ToLocType = 'DYNPICKP'
               AND   rz.FromLoc   = @cLoc
               AND   rz.Used      = 0
               ORDER BY rz.RowID 
            
               IF @@ROWCOUNT = 0 OR @cDynamicP_PalletZone = ''
               BEGIN
                  SET @cDynamicP_PalletZone = @c_DYNPICKP_Zone_P  
               END
               ELSE 
               BEGIN 
                  SET @n_LoopTrue = 1
                  SET @c_DYNPICKP_Zone_P = @cDynamicP_PalletZone
               END
            END  
            
            IF @cNextDynPickLoc > ''
            BEGIN
               UPDATE #ReplTo SET Used = 1
               WHERE RowID = @n_RowID_RZ
               AND   Used  = 0
            END
         END                                                                        --(Wan02) - END                                                        
      END                                                                           
       
      IF @cDynLocReplenNotGetLastLoc = 1 AND ISNULL(RTRIM(@cNextDynPickLoc) ,'')='' -- (james01)  
      BEGIN  
         SET @nErrNo = @nErrNo+1    
         SET @cErrMsg =     
               'Dynamic Pallet Location Not Setup / Not enough Dynamic Pallet Location.'    
                
         SET @nContinue = 3     
         GOTO ErrorHandling    
      END     
          
      -- If no more DP loc then goto to last DP loc    
      IF ISNULL(RTRIM(@cNextDynPickLoc) ,'')=''    
      BEGIN    
         SELECT TOP 1 @cNextDynPickLoc = LOC.LOC    
         FROM   LOC WITH (NOLOCK)    
         WHERE  LOC.LocationType IN ('DYNPICKP') AND 
                  LOC.LocationFlag NOT IN ('HOLD','DAMAGE')  AND  
                  LOC.[Status]     <> 'HOLD' AND     
                  LOC.PutawayZone = @cDynamicP_PalletZone AND    
                  LOC.Facility = @cFacility    
         ORDER BY LOC.LOC DESC  
  
         IF ISNULL(RTRIM(@cNextDynPickLoc) ,'')<>'' AND @bDebug = 1 
            PRINT 'EEE- @cNextDynPickLoc: ' + @cNextDynPickLoc + ' @cDynGroup: ' +   @cDynGroup    
      END    
          
      IF ISNULL(RTRIM(@cNextDynPickLoc) ,'')=''    
      BEGIN    
         SET @nErrNo = @nErrNo+1    
         SET @cErrMsg =     
               'Dynamic Pallet Location Not Setup / Not enough Dynamic Pallet Location.'    
                
         SET @nContinue = 3     
         GOTO ErrorHandling    
      END     
            
      IF @n_RowID_DynPK = 0                                                         --(Wan02) - START  
      BEGIN      
         UPDATE #DynPick    
         SET    D_Pick_Loc = @cNextDynPickLoc    
         WHERE  StorerKey = @cStorerKey AND    
                DynGroup = @cDynGroup     
      END
      ELSE IF @n_RowID_DynPK > 0
      BEGIN
         UPDATE #DynPick    
         SET    D_Pick_Loc = @cNextDynPickLoc    
         WHERE  RowID = @n_RowID_DynPK   
      END                                                                           --(Wan02) - END 
      
      SET @c_DynGroup_P = @cDynGroup                                                --(Wan02)      
      FETCH NEXT FROM CUR_DynPallet_DynGroup INTO @cStorerKey, @cDynGroup
                                                , @cLOC, @cID, @n_RowID_DynPK       --(Wan02) 
   END     
   CLOSE CUR_DynPallet_DynGroup     
   DEALLOCATE CUR_DynPallet_DynGroup     
   --------------------------------------------------------------------------------------------    
   -- Assign the Dynamic Rack Location for total CBM < DynPalletCBM    
   IF @bDebug=1    
   BEGIN    
      PRINT 'Assign the Dynamic Rack Location for total CBM < DynPalletCBM'    
      SELECT StorerKey    
            ,DynGroup    
      FROM   #DynPick    
      WHERE  D_Pick_Loc = ''    
      GROUP BY    
            StorerKey    
            ,DynGroup    
      HAVING SUM(Qty * ISNULL(StdCube,0))<@nDynPalletCBM    
      ORDER BY    
            StorerKey    
            ,DynGroup    
   END   
   
   DECLARE CUR_DynRack_DynGroup  CURSOR LOCAL FAST_FORWARD READ_ONLY     
   FOR 
      SELECT StorerKey    
            ,DynGroup               
      FROM   #DynPick    
      WHERE  D_Pick_Loc = ''    
      GROUP BY    
            StorerKey    
            ,DynGroup               
      HAVING SUM(Qty * ISNULL(StdCube,0))<@nDynPalletCBM    
      ORDER BY    
            StorerKey    
            ,DynGroup               

   OPEN CUR_DynRack_DynGroup     
        
   FETCH NEXT FROM CUR_DynRack_DynGroup INTO @cStorerKey, @cDynGroup 

   WHILE @@FETCH_STATUS<>-1    
   BEGIN  
      IF @b_UserDefineStartDR = 1                                                   --(Wan02) - START
      BEGIN
         DECLARE CUR_DynGroup_PickDetail CURSOR LOCAL FAST_FORWARD READ_ONLY     
         FOR    
            SELECT DISTINCT Storerkey, SKU 
                  ,Loc      = ''
                  ,ID       = ''
                  ,RowID    = 0
            FROM   #DynPick
            WHERE  StorerKey = @cStorerKey AND    
                   DynGroup = @cDynGroup
            ORDER BY StorerKey    
                  ,  Sku                   
      END
      ELSE IF @b_UserDefineStartDR = 0 
      BEGIN
         DECLARE CUR_DynGroup_PickDetail  CURSOR LOCAL FAST_FORWARD READ_ONLY     
         FOR   SELECT t.StorerKey    
                     ,t.Sku 
                     ,t.Loc
                     ,t.ID
                     ,t.RowID
               FROM   #DynPick t   
               WHERE t.StorerKey = @cStorerKey      
               AND   t.DynGroup = @cDynGroup       
               ORDER BY t.DynGroup
                     ,  t.StorerKey    
                     ,  t.Sku
                     ,  t.RowID  
      END                                                                           --(Wan02) - END
      
      OPEN CUR_DynGroup_PickDetail            
      FETCH NEXT FROM CUR_DynGroup_PickDetail INTO @cStorerkey, @cSKU               --(Wan02)
                                                 , @cLOC, @cID, @n_RowID_DynPK      --(Wan02) 
      WHILE @@FETCH_STATUS<>-1    
      BEGIN  
        SET @cNextDynPickLoc = ''                                                   --(Wan02) - START
         SET @cDynamicP_RackZone = ''
         SET @c_IdenticalRepl01 = ''

         IF @cDynGroup + RTRIM(@cStorerkey) + RTRIM(@cSKU) = @c_DynGroup_P           
         BEGIN
            SELECT TOP 1 @cNextDynPickLoc = dp.D_Pick_Loc    
            FROM #DynPick dp 
            JOIN LOC l (NOLOCK) ON l.loc = dp.D_Pick_Loc 
            WHERE  dp.DynGroup = @cDynGroup 
            AND    dp.Storerkey= @cStorerKey
            AND    dp.SKU = @cSKU
            AND    l.LocationType = 'DYNPICKR'
         END
         
         IF @cNextDynPickLoc = ''                                                                          
         BEGIN
            SET @n_RowID_RZ = 0
            SELECT TOP 1 @n_RowID_RZ = rz.RowID 
                  ,@cDynamicP_RackZone = rz.[Zone]
                  ,@c_IdenticalRepl01 = rz.IdenticalRepl01
            FROM #ReplTo rz 
            WHERE rz.ToLocType = 'DYNPICKR'
            AND   rz.FromLoc = @cLOC
            AND   rz.RowID < 2
            ORDER BY Used DESC, rz.RowID
         END                                                                                                                                                    
          
         SET @n_LoopTrue = 1                                                                                                        
         WHILE @n_LoopTrue = 1 AND @cNextDynPickLoc = '' AND @cDynamicP_RackZone > ''   
         BEGIN   
            IF ISNULL(RTRIM(@cNextDynPickLoc) ,'')='' AND @c_FindSimilarDR = 'Y'         
            BEGIN
               SET @c_SQL  = N'SELECT TOP 1 @cNextDynPickLoc = LOC.LOC'             
                           + ' FROM LotxLocxID LLI WITH (NOLOCK)'
                           + ' JOIN LOC WITH (NOLOCK) ON LOC.LOC = LLI.LOC'     
                           + ' WHERE LOC.Facility = @c_Facility' 
                           + ' AND  LLI.StorerKey = @cStorerKey'
                           + ' AND  LLI.Sku = @cSKU'
                           + ' AND  LLI.Qty- LLI.QtyPicked+LLI.QtyAllocated <> 0' 
                           + ' AND  LOC.LocationType IN (''DYNPICKR'')'   
                           + ' AND  LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'')'     
                           + ' AND  LOC.[Status]     = ''OK'''                          
                           + ' AND  LOC.PutawayZone = @cDynamicP_RackZone' 
                           + CASE WHEN @c_IdenticalToBulk > '' 
                                  THEN ' AND ' + @c_IdenticalToBulk + ' = @c_IdenticalRepl01' 
                                  ELSE '' END  
                                  
              SET @c_SQLParms = N'@c_Facility         NVARCHAR(5)'
                              + ',@cStorerKey         NVARCHAR(15)'
                              + ',@cSKU               NVARCHAR(10)'
                              + ',@cDynamicP_RackZone NVARCHAR(10)'
                              + ',@c_IdenticalRepl01  NVARCHAR(30)'
                              + ',@cNextDynPickLoc    NVARCHAR(10) OUTPUT'
 
              EXEC sp_ExecuteSQL @c_SQL
                              ,@c_SQLParms
                              ,@cFacility
                              ,@cStorerKey
                              ,@cSKU
                              ,@cDynamicP_RackZone
                              ,@c_IdenticalRepl01
                              ,@cNextDynPickLoc      OUTPUT                         --(Wan02) - END
            END    
                
            -- If no location with same DynGroup found, then assign the empty location    
            IF ISNULL(RTRIM(@cNextDynPickLoc) ,'')=''    
            BEGIN    
               SET @c_SQL = N'SELECT TOP 1 @cNextDynPickLoc = LOC.LOC'              --(Wan02) - START
                          + ' FROM  LOC WITH (NOLOCK)'    
                          + ' WHERE LOC.Facility = @c_Facility'      
                          + ' AND LOC.LocationType = (''DYNPICKR'')'      
                          + ' AND LOC.PutawayZone = @cDynamicP_RackZone'      
                          + ' AND LOC.LOC>= @cStartDynamicP_RackLoc'      
                          + ' AND NOT EXISTS('    
                          +               ' SELECT 1'    
                          +               ' FROM   #DP_RACK_NON_EMPTY E'    
                          +               ' WHERE  E.LOC = LOC.LOC '   
                          +               ')'
                          + ' AND NOT EXISTS('    
                          +               ' SELECT 1'    
                          +               ' FROM   #DYNPICK_RACK AS ReplenLoc'    
                          +               ' WHERE  ReplenLoc.TOLOC = LOC.LOC'    
                          +               ')'    
                          + ' AND NOT EXISTS('    
                          +               ' SELECT 1'    
                          +               ' FROM   #DynPick AS DynPick'    
                          +               ' WHERE  DynPick.D_Pick_Loc = LOC.LOC'    
                          +               ')'                          
                          + ' ORDER BY LOC.LOC' 
                          
               SET @c_SQLParms = N'@c_Facility              NVARCHAR(5)'
                               + ',@cDynGroup               NVARCHAR(30)'
                               + ',@cDynamicP_RackZone      NVARCHAR(10)'
                               + ',@cStartDynamicP_RackLoc  NVARCHAR(10)'
                               + ',@c_IdenticalRepl01       NVARCHAR(30)'
                               + ',@cNextDynPickLoc         NVARCHAR(10) OUTPUT'

               EXEC sp_ExecuteSQL @c_SQL
                                 ,@c_SQLParms
                                 ,@cFacility
                                 ,@cDynGroup
                                 ,@cDynamicP_RackZone
                                 ,@cStartDynamicP_RackLoc
                                 ,@c_IdenticalRepl01
                                 ,@cNextDynPickLoc      OUTPUT
        
               SET @n_LoopTrue = 0                                                        
               IF @cNextDynPickLoc = ''                                              
               BEGIN
                  UPDATE #ReplTo SET Used = 2
                  WHERE RowID = @n_RowID_RZ
                  

                  SET @cDynamicP_RackZone = ''
                  SELECT TOP 1 
                       @n_RowID_RZ = rz.RowID
                     , @cDynamicP_RackZone = rz.[Zone]
                     , @c_IdenticalRepl01 = rz.IdenticalRepl01
                  FROM #ReplTo rz
                  WHERE rz.RowID > @n_RowID_RZ
                  AND   rz.ToLocType = 'DYNPICKR'
                  AND   rz.FromLoc = @cLOC
                  AND   rz.Used = 0
                  ORDER BY rz.RowID 
               
                  IF @@ROWCOUNT = 0 OR @cDynamicP_RackZone = ''
                  BEGIN
                     SET @cDynamicP_RackZone = @c_DYNPICKR_Zone_P 
                  END
                  ELSE
                  BEGIN
                     SET @n_LoopTrue = 1
                     SET @c_DYNPICKR_Zone_P = @cDynamicP_RackZone
                  END
               END 
               IF @cNextDynPickLoc > ''                                              
               BEGIN
                  UPDATE #ReplTo SET Used = 1
                  WHERE RowID = @n_RowID_RZ
                  AND   Used = 0
               END
            END
         END                                                                        --(Wan02) - END                                                                      
                              
         IF @cDynLocReplenNotGetLastLoc = 1 AND ISNULL(RTRIM(@cNextDynPickLoc) ,'')='' -- (james01)  
         BEGIN  
            SET @nErrNo = @nErrNo+1    
            SET @cErrMsg =     
                  'Dynamic Pallet Location Not Setup / Not enough Dynamic Pallet Location.'    
                   
            SET @nContinue = 3     
            GOTO ErrorHandling    
         END     
          
         -- If no more DP loc then goto last DP loc    
         IF ISNULL(RTRIM(@cNextDynPickLoc) ,'')=''    
         BEGIN    
            SELECT TOP 1 @cNextDynPickLoc = LOC.LOC    
            FROM   LOC WITH (NOLOCK)    
            WHERE  LOC.LocationType = ('DYNPICKR') AND    
                  LOC.PutawayZone = @cStartDynamicP_RackLoc AND    
                  LOC.Facility = @cFacility    
            ORDER BY LOC.LOC DESC    
         END    
                
         IF ISNULL(RTRIM(@cNextDynPickLoc) ,'')=''    
         BEGIN    
            SET @nErrNo = @nErrNo+1    
            SET @cErrMsg =     
               'Dynamic Rack Location Not Setup / Not enough Dynamic Rack Location.'    
                    
            SET @nContinue = 3     
            GOTO ErrorHandling    
         END 
         
        IF @n_RowID_DynPK = 0                                                      --(Wan02) - START
         BEGIN        
            UPDATE #DynPick    
            SET    D_Pick_Loc = @cNextDynPickLoc    
            WHERE  StorerKey = @cStorerKey AND    
            SKU = @cSKU AND    
            DynGroup = @cDynGroup
         END   
         ELSE IF @n_RowID_DynPK > 0  
         BEGIN
            UPDATE #DynPick    
            SET    D_Pick_Loc = @cNextDynPickLoc    
            WHERE  RowID = @n_RowID_DynPK   
         END                                                                        --(Wan02) - END  
             
         SET @c_DynGroup_P = @cDynGroup + RTRIM(@cStorerkey) + RTRIM(@cSKU)         --(Wan02) 
         FETCH NEXT FROM CUR_DynGroup_PickDetail INTO @cStorerkey, @cSKU            --(Wan02)
                                                    , @cLOC, @cID, @n_RowID_DynPK   --(Wan02) 
      END     
      CLOSE CUR_DynGroup_PickDetail    
      DEALLOCATE CUR_DynGroup_PickDetail                                             
            
      FETCH NEXT FROM CUR_DynRack_DynGroup INTO @cStorerKey, @cDynGroup

   END     
   CLOSE CUR_DynRack_DynGroup     
   DEALLOCATE CUR_DynRack_DynGroup     
    
   WHILE @@TRANCOUNT>0    
         COMMIT TRAN    
                  
   IF @bDebug=1    
   BEGIN    
      SELECT D_Pick_Loc    
            ,DynGroup    
            ,SKU    
            ,SUM(Qty*StdCube)    
      FROM   #DynPick    
      GROUP BY    
            D_Pick_Loc    
            ,DynGroup    
            ,SKU    
   END     
        
   IF EXISTS(    
         SELECT 1    
         FROM   #DynPick    
         WHERE  D_Pick_Loc = ''    
      )    
   BEGIN    
      SET @nErrNo = @nErrNo+1    
      SET @cErrMsg = 'Fail to assign Dynamic Pick Location (Pallet/Rack)'    
      SET @nContinue = 3     
      GOTO ErrorHandling    
   END     
        
   DECLARE CUR_GEN_REPLEN    CURSOR LOCAL FAST_FORWARD READ_ONLY     
   FOR    
      SELECT RowID    
      FROM   #DynPick    
      ORDER BY RowID    
        
   OPEN CUR_GEN_REPLEN    
        
   FETCH NEXT FROM CUR_GEN_REPLEN INTO @nRowID                           
        
   WHILE @@FETCH_STATUS<>-1    
   BEGIN    
      BEGIN TRAN -- tlting commit by line    
             
      SET @cPickDetailKey = ''    
      SET @cStorerKey = ''    
      SET @cSKU = ''    
      SET @cLOT = ''    
      SET @cLOC = ''    
      SET @cID  = ''    
      SET @nQty = 0    
      SET @cDynamicPickLoc = ''    
          
      SELECT  @cPickDetailKey = PickDetailKey    
            ,@cStorerKey = StorerKey    
            ,@cSKU = SKU    
            ,@cLOT = LOT    
            ,@cLOC = LOC    
            ,@cID  = ID    
            ,@nQty = Qty    
            ,@cDynamicPickLoc = D_Pick_LOC    
      FROM   #DynPick    
      WHERE RowID = @nRowID    

      SET @c_ToID = @cID                                                   --(Wan01) - START

      SELECT @c_ToID = ''
      FROM LOC (NOLOCK)
      WHERE Loc = @cDynamicPickLoc
      AND Loseid IN ('1')                                                  --(Wan01) - END     
                                        
      SET @cReplenishmentKey = ''    
            
      SELECT TOP 1     
            @cReplenishmentKey = ReplenishmentKey    
      FROM   REPLENISHMENT WITH (NOLOCK)    
      WHERE  WaveKey = @cWaveKey AND    
            LOT = @cLOT AND    
            FromLOC = @cLOC AND    
            ID = @cID AND    
            ToLOC = @cDynamicPickLoc AND 
            Confirmed = 'N'
            
      IF ISNULL(RTRIM(@cReplenishmentKey) ,'')=''    
      BEGIN    
         EXECUTE nspg_GetKey     
         @keyname='REPLENISHMENT',     
         @fieldlength=10,     
         @keystring=@cReplenishmentKey OUTPUT,     
         @b_success=@bSuccess OUTPUT,     
         @n_err=@nErr OUTPUT,     
         @c_errmsg=@cErrMsg OUTPUT      
                
         IF NOT @bSuccess=1    
         BEGIN    
            SELECT @nContinue = 3    
         END    
         ELSE    
         BEGIN    
            SELECT @cPackKey = PACK.PackKey    
                  ,@cUOM = PACK.PackUOM3    
            FROM   SKU WITH (NOLOCK)    
                  JOIN PACK WITH (NOLOCK)    
                        ON  PACK.PackKey = SKU.PackKey    
            WHERE  SKU.StorerKey = @cStorerKey AND    
                  SKU.SKU = @cSKU     
                 
            IF @bDebug=1    
            BEGIN    
               PRINT 'Insert Replenishment....'    
               SELECT @cReplenishmentKey '@cReplenishmentKey'    
                     ,@cSKU '@cSKU'    
                     ,@cLOT '@cLOT'    
                     ,@cLOC '@cLOC'    
                     ,@cID '@cID'    
                     ,@cDynamicPickLoc '@cDynamicPickLoc'    
                     ,@cPickDetailKey '@cPickDetailKey'    
            END     
                 
            INSERT INTO Replenishment    
            (    
               ReplenishmentKey, ReplenishmentGroup, StorerKey, SKU,     
               FromLOC, ToLOC, Lot, Id, Qty, UOM, PackKey, Priority,     
               QtyMoved, QtyInPickLOC, RefNo, Confirmed, WaveKey, Remark,     
               OriginalFromLoc, OriginalQty, ToID                                --(Wan01) 
            )    
            VALUES    
            (    
               @cReplenishmentKey, 'DYNAMIC', @cStorerKey, @cSKU, @cLOC, @cDynamicPickLoc,     
               @cLOT, @cID, @nQty, @cUOM, @cPackkey, '1', 0, 0, @cPickDetailKey,     
               'N', @cWaveKey, '', @cLOC, @nQty, @c_ToID                         --(Wan01)
            )     
                 
            SET @nErr = @@ERROR    
         END    
      END-- If Not Exists in Replen    
      ELSE    
      BEGIN    
         IF @bDebug=1    
         BEGIN    
               PRINT 'Update Replenishment....'    
               SELECT @cReplenishmentKey '@cReplenishmentKey'    
                     ,@cSKU '@cSKU'    
                     ,@cLOT '@cLOT'    
                     ,@cLOC '@cLOC'    
                     ,@cID '@cID'    
                     ,@cDynamicPickLoc '@cDynamicPickLoc'    
                     ,@cPickDetailKey '@cPickDetailKey'    
         END     
                
         UPDATE Replenishment WITH (ROWLOCK)    
         SET    Qty = Qty+@nQty    
               ,OriginalQty = OriginalQty+@nQty
               ,ArchiveCop  = NULL                                                  --Wan01
         WHERE  ReplenishmentKey = @cReplenishmentKey     
                
         SET @nErr = @@ERROR    
      END     
            
      IF @nErr=0    
      BEGIN    
         UPDATE LOTxLOCxID WITH (ROWLOCK)    
         SET    QtyReplen = ISNULL(QtyReplen ,0)+@nQty    
         WHERE  LOT = @cLOT AND    
                  LOC = @cLOC AND    
                  ID = @cID    
                
         IF @@ERROR=0    
         BEGIN    
                IF NOT EXISTS(    
                       SELECT 1    
                       FROM   LOTxLOCxID WITH (NOLOCK)    
                       WHERE  LOT = @cLOT AND    
                              LOC = @cDynamicPickLoc AND    
                              --ID = '' --NJOW01    
                              ID = @c_ToID --(ChewKP01)                             --(Wan01)  
                   )    
                BEGIN    
                    INSERT INTO LOTxLOCxID    
                      (    
                        StorerKey, SKU, LOT, LOC, ID, Qty, PendingMoveIN                     --(Wan01)    
                      )    
                    VALUES    
                      (    
                        --@cStorerKey, @cSKU, @cLOT, @cDynamicPickLoc, '', 0   --NJOW01    
                        --@cStorerKey, @cSKU, @cLOT, @cDynamicPickLoc, @cID, 0   --(ChewKP01) 
                        @cStorerKey, @cSKU, @cLOT, @cDynamicPickLoc, @c_ToID, 0, @nQty       --(Wan01)  
                      )      
                  IF @@ERROR<>0    
                  BEGIN    
                     SET @nErrNo = @nErrNo+1    
                     SET @cErrMsg = 'Fail to Insert LOTxLOCxID'    
                     SET @nContinue = 3     
                     GOTO ErrorHandling    
                  END-- Update PickDetail Failed    
               END    
               ELSE     
               BEGIN                     
                  --NJOW01    
                  UPDATE LOTxLOCxID WITH (ROWLOCK)    
                  SET    PendingMoveIN = ISNULL(PendingMoveIN ,0)+@nQty                       
                  WHERE  LOT = @cLOT AND    
                        LOC = @cDynamicPickLoc AND    
                        --ID = ''   
                        ID = @c_ToID --(ChewKP01)                                --(Wan01)  
    
                  IF @@ERROR<>0    
                  BEGIN    
                     SET @nErrNo = @nErrNo+1    
                     SET @cErrMsg = 'Fail to Insert LOTxLOCxID'    
                     SET @nContinue = 3     
                     GOTO ErrorHandling    
                  END-- Update PickDetail Failed    
               END    
                    
               IF NOT EXISTS(    
                     SELECT 1    
                     FROM   SKUxLOC WITH (NOLOCK)    
                     WHERE  StorerKey = @cStorerKey AND    
                           SKU = @cSKU AND    
                           LOC = @cDynamicPickLoc    
                  )    
               BEGIN    
                  INSERT INTO SKUxLOC    
                     (    
                     StorerKey, SKU, LOC, Qty    
                     )    
                  VALUES    
                     (    
                     @cStorerKey, @cSKU, @cDynamicPickLoc, 0    
                     )    
                  IF @@ERROR<>0    
                  BEGIN    
                     SET @nErrNo = @nErrNo+1    
                     SET @cErrMsg = 'Fail to Insert LOTxLOCxID'    
                     SET @nContinue = 3     
                     GOTO ErrorHandling    
                  END-- Update PickDetail Failed    
               END     
                    
               UPDATE PickDetail WITH (ROWLOCK)    
               SET    LOC = @cDynamicPickLoc    
                     ,PickHeaderKey = @cReplenishmentKey    
                     ,ID = @c_ToID                      --NJOW01  -- (ChewKP01)     --(Wan01)  
               WHERE  PickDetailKey = @cPickDetailKey    
                    
               IF @@ERROR<>0    
               BEGIN    
                  SET @nErrNo = @nErrNo+1    
                  SET @cErrMsg = 'Fail to update Pickdetail'    
                  SET @nContinue = 3     
                  GOTO ErrorHandling    
               END-- Update PickDetail Failed    
                
               SET @nPDT_TotReplenQty = 0 
               SET @nRPL_TotReplenQty = 0 
                
               SELECT  @nPDT_TotReplenQty = ISNULL(SUM(Qty),0)
               FROM    PICKDETAIL p WITH (NOLOCK) 
               JOIN    WAVEDETAIL w WITH (NOLOCK) ON w.OrderKey = p.OrderKey  
               WHERE   p.PickHeaderKey = @cReplenishmentKey 
               AND   w.WaveKey = @cWaveKey
                 
               SELECT @nRPL_TotReplenQty = r.OriginalQty 
               FROM REPLENISHMENT r WITH (NOLOCK) 
               WHERE r.Wavekey = @cWaveKey 
               AND   r.ReplenishmentKey = @cReplenishmentKey 
                
               IF @nPDT_TotReplenQty <> @nRPL_TotReplenQty
               BEGIN
                  SET @nErrNo = @nErrNo+1    
                  SET @cErrMsg = 'PickDetail Qty <> Replenishment Qty'    
                  SET @nContinue = 3     
                  GOTO ErrorHandling                   
               END
                               
         END-- Update LOTxLOCxID Succeed    
      END -- Insert Replen Succeed     
    
      WHILE @@TRANCOUNT > 0    
      BEGIN    
         COMMIT TRAN    
      END    
              
      FETCH NEXT FROM CUR_GEN_REPLEN INTO @nRowID    
   END     
   CLOSE CUR_GEN_REPLEN    
   DEALLOCATE CUR_GEN_REPLEN   
    
   -- Start (ChewKP02)
      
   SELECT @b_success = 0          
        
   EXECUTE dbo.nspGetRight  NULL,          
            @cStorerKey,        -- Storer          
            '',                  -- Sku          
            'PICKRESLOG',        -- ConfigKey          
            @b_success              OUTPUT,          
            @c_authority_pickreslog OUTPUT,          
            @nErrNo                 OUTPUT,          
            @cErrMsg                OUTPUT          
        
   IF @b_success <> 1          
   BEGIN          
      SELECT @nContinue = 3          
      SELECT @nErrNo = @nErrNo + 1
      SELECT @cErrMsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@nErrNo,0))           
                     + ': Retrieve of Right (PICKRESLOG) Failed ( '           
                     + ' (ispGenDynamicLocReplenishment)'                        --Put correct SP name   
   END
    
   IF @c_authority_pickreslog = '1'
   BEGIN
        
      DECLARE CursorWaveDetail CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
        
      SELECT OrderKey FROM WaveDetail WITH (NOLOCK)
      WHERE WaveKey = @cWaveKey 
        
      OPEN CursorWaveDetail   
   
      FETCH NEXT FROM CursorWaveDetail INTO @c_OrderKey
        
      WHILE @@FETCH_STATUS <> -1               
      BEGIN
          
         EXEC dbo.ispGenTransmitLog3 'PICKRESLOG', @c_OrderKey, '', @cStorerKey, ''          
                              , @b_success OUTPUT          
                              , @nErrNo OUTPUT          
                              , @cErrMsg OUTPUT   
                                                         
         IF @b_success <> 1          
         BEGIN          
            SELECT @nContinue = 3 
            GOTO ErrorHandling          
         END    
        
         FETCH NEXT FROM CursorWaveDetail INTO @c_OrderKey
      END
      CLOSE CursorWaveDetail            
      DEALLOCATE CursorWaveDetail  
   END
    
    
   -- End (ChewKP02) 
        
   WHILE @@TRANCOUNT>@nStartTranCount     
         COMMIT TRAN     
   
   --RETURN                                                                         --(Wan02) 
   ErrorHandling:    
   IF OBJECT_ID('tempdb..#ReplTo','u') IS NOT NULL                                  --(Wan02) - START
   BEGIN
      DROP TABLE #ReplTo;
   END                                                                              --(Wan02) - END

   IF @nContinue=3    
   BEGIN    
      IF @@TRANCOUNT>@nStartTranCount    
         ROLLBACK TRAN    
            
      EXECUTE nsp_Logerror @nErrNo, @cErrMsg, 'ispGenDynamicLocReplenishment'    
      RAISERROR (@cErrMsg, 16, 1) WITH SETERROR    -- SQL2012  
      --RETURN                                                                      --(Wan02) 
   END    

   RETURN                                                                           --(Wan02) 
END -- Procedure
GO
GRANT EXECUTE ON [dbo].[ispGenDynamicLocReplenishment] TO nSQL 
GO
