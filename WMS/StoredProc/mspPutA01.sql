SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: mspPutA01                                          */
/* Creation Date: 2026-03-09                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: AYD                                                      */
/*                                                                      */
/* Purpose:  FCR-10206 - SAU DAMMAM Putaway Strategy                    */
/*                                                                      */
/* Return Status:  None                                                 */
/*                                                                      */
/* Usage: Release Putaway Code                                          */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: Putaway Release Task                                      */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2026-03-09  Wan      1.0   Created                                   */
/************************************************************************/
CREATE OR ALTER PROC dbo.mspPutA01 
   @c_UserID            NVARCHAR(128)  = ''
,  @c_Storerkey         NVARCHAR(15)   
,  @c_Lot               NVARCHAR(10)   = ''
,  @c_Sku               NVARCHAR(20)   = ''
,  @c_ID                NVARCHAR(18) 
,  @c_FromLoc           NVARCHAR(10) 
,  @n_Qty               INT            = 0
,  @c_UOM               NVARCHAR(10)   = ''   
,  @c_Packkey           NVARCHAR(10)   = ''
,  @n_PutawayCapacity   INT            = 0
,  @c_Final_ToLoc       NVARCHAR(10)   = ''  OUTPUT 
,  @n_AvailablePASlot   INT            = 0   OUTPUT 
,  @n_LPNLeftToFulfill  INT            = 0   OUTPUT
,  @c_ReceiptKey        NVARCHAR(10)   = ''
,  @c_ReceiptLineNumber NVARCHAR(5)    = ''
,  @c_Lottable01        NVARCHAR(18)   = ''
,  @c_Lottable02        NVARCHAR(18)   = ''
,  @c_Lottable03        NVARCHAR(18)   = ''
,  @dt_Lottable04       DATETIME       = NULL
,  @dt_Lottable05       DATETIME       = NULL
,  @c_Lottable06        NVARCHAR(30)   = ''
,  @c_Lottable07        NVARCHAR(30)   = ''
,  @c_Lottable08        NVARCHAR(30)   = ''
,  @c_Lottable09        NVARCHAR(30)   = ''
,  @c_Lottable10        NVARCHAR(30)   = ''
,  @c_Lottable11        NVARCHAR(30)   = ''
,  @c_Lottable12        NVARCHAR(30)   = ''
,  @dt_Lottable13       DATETIME       = NULL
,  @dt_Lottable14       DATETIME       = NULL
,  @dt_Lottable15       DATETIME       = NULL
,  @b_Success           INT            = 1  OUTPUT
,  @n_Err               INT            = 0  OUTPUT
,  @c_Errmsg            NVARCHAR(250)  = '' OUTPUT
,  @b_Debug             INT            = 0
AS
BEGIN
   SET NOCOUNT ON       -- SQL 2005 Standard
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue                       INT            = 1
         , @n_StartTCnt                      INT            = @@TRANCOUNT
         , @n_RowCount                       INT            = 0

         , @c_Facility                       NVARCHAR(5)    = ''
         , @c_ToLoc                          NVARCHAR(10)   = ''
         , @n_Pallet                         INT            = 0
         , @c_ItemClass                      NVARCHAR(10)   = ''

         , @c_ListName                       NVARCHAR(10)   = 'mspPutA01'
         , @b_Proceed                        BIT            = 0
         , @cpa_StrategyKey                  NVARCHAR(10)   = ''
         , @cpa_StrategyLineNo               NVARCHAR(5)    = '' 
         , @cpa_AreaKey                      NVARCHAR(10)   = '' 
         , @cpa_LocationTypeExclude01        NVARCHAR(10)   = '' 
         , @cpa_LocationTypeExclude02        NVARCHAR(10)   = '' 
         , @cpa_LocationTypeExclude03        NVARCHAR(10)   = '' 
         , @cpa_LocationTypeExclude04        NVARCHAR(10)   = '' 
         , @cpa_LocationTypeExclude05        NVARCHAR(10)   = '' 
         , @cpa_LocationCategoryExclude01    NVARCHAR(10)   = '' 
         , @cpa_LocationCategoryExclude02    NVARCHAR(10)   = '' 
         , @cpa_LocationCategoryExclude03    NVARCHAR(10)   = '' 
         , @cpa_LocationHandlingExclude01    NVARCHAR(10)   = '' 
         , @cpa_LocationHandlingExclude02    NVARCHAR(10)   = '' 
         , @cpa_LocationHandlingExclude03    NVARCHAR(10)   = '' 
         , @cpa_LocationFlagExclude01        NVARCHAR(10)   = '' 
         , @cpa_LocationFlagExclude02        NVARCHAR(10)   = '' 
         , @cpa_LocationFlagExclude03        NVARCHAR(10)   = '' 
         , @cpa_LocationFlagInclude01        NVARCHAR(10)   = '' 
         , @cpa_LocationFlagInclude02        NVARCHAR(10)   = '' 
         , @cpa_LocationFlagInclude03        NVARCHAR(10)   = '' 
         , @cpa_LocationCategoryInclude01    NVARCHAR(10)   = '' 
         , @cpa_LocationCategoryInclude02    NVARCHAR(10)   = '' 
         , @cpa_LocationCategoryInclude03    NVARCHAR(10)   = '' 
         , @cpa_LocationHandlingInclude01    NVARCHAR(10)   = '' 
         , @cpa_LocationHandlingInclude02    NVARCHAR(10)   = '' 
         , @cpa_LocationHandlingInclude03    NVARCHAR(10)   = '' 
         , @cpa_AreaTypeExclude01            NVARCHAR(10)   = '' 
         , @cpa_AreaTypeExclude02            NVARCHAR(10)   = '' 
         , @cpa_AreaTypeExclude03            NVARCHAR(10)   = '' 
         , @cpa_LocationTypeRestriction01    NVARCHAR(10)   = '' 
         , @cpa_LocationTypeRestriction02    NVARCHAR(10)   = '' 
         , @cpa_LocationTypeRestriction03    NVARCHAR(10)   = '' 
         , @npa_LocLevelInclude01            INT            = ''
         , @npa_LocLevelInclude02            INT            = ''
         , @npa_LocLevelInclude03            INT            = ''
         , @npa_LocLevelInclude04            INT            = ''
         , @npa_LocLevelInclude05            INT            = ''
         , @npa_LocLevelInclude06            INT            = '' 
         , @npa_LocLevelExclude01            INT            = ''
         , @npa_LocLevelExclude02            INT            = ''
         , @npa_LocLevelExclude03            INT            = ''
         , @npa_LocLevelExclude04            INT            = ''
         , @npa_LocLevelExclude05            INT            = ''
         , @npa_LocLevelExclude06            INT            = ''
         , @cpa_LocAisleInclude01            NVARCHAR(10)   = '' 
         , @cpa_LocAisleInclude02            NVARCHAR(10)   = '' 
         , @cpa_LocAisleInclude03            NVARCHAR(10)   = '' 
         , @cpa_LocAisleInclude04            NVARCHAR(10)   = '' 
         , @cpa_LocAisleInclude05            NVARCHAR(10)   = '' 
         , @cpa_LocAisleInclude06            NVARCHAR(10)   = '' 
         , @cpa_LocAisleExclude01            NVARCHAR(10)   = '' 
         , @cpa_LocAisleExclude02            NVARCHAR(10)   = '' 
         , @cpa_LocAisleExclude03            NVARCHAR(10)   = '' 
         , @cpa_LocAisleExclude04            NVARCHAR(10)   = '' 
         , @cpa_LocAisleExclude05            NVARCHAR(10)   = '' 
         , @cpa_LocAisleExclude06            NVARCHAR(10)   = '' 
         , @cpa_PutawayZone01                NVARCHAR(10)   = ''   
         , @cpa_PutawayZone02                NVARCHAR(10)   = ''   
         , @cpa_PutawayZone03                NVARCHAR(10)   = ''   
         , @cpa_PutawayZone04                NVARCHAR(10)   = ''   
         , @cpa_PutawayZone05                NVARCHAR(10)   = ''           
         , @c_PAType                         NVARCHAR(30)   = ''
         , @c_Criteria                       NVARCHAR(30)   = ''
         , @c_SQLSkipPAType                  NVARCHAR(2000) = ''
         , @c_Condition                      NVARCHAR(MAX)  = ''
         , @c_SortBy                         NVARCHAR(3000) = ''
         , @c_ForceMatchLA                   NVARCHAR(30)   = ''
 
         , @c_SQL                            NVARCHAR(MAX)  = ''
         , @c_SQLCond                        NVARCHAR(MAX)  = ''
         , @c_SQLCond_PA                     NVARCHAR(2000) = ''
         , @c_SQLCond_Sku                    NVARCHAR(200)  = ''
         , @c_SQLCond_Loc                    NVARCHAR(MAX)  = ''   
         , @c_SQLSortBy                      NVARCHAR(2000) = ''
         , @c_SQLSelect_LA                   NVARCHAR(2000) = ''
         , @c_SQLParms                       NVARCHAR(MAX) = ''
        
         , @CUR_PAS                          CURSOR
  
   SET @b_Success    = 1
   SET @n_Err        = 0
   SET @c_Errmsg     = ''
   SET @c_Final_ToLoc= ''

   IF OBJECT_ID('tempdb..#TMP_PALOC') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_PALOC
   END

   CREATE TABLE #TMP_PALOC
   (  [Loc]                         [nvarchar](10)    NOT NULL PRIMARY KEY      
   )

   IF OBJECT_ID('tempdb..#TMP_CL') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_CL
   END

   CREATE TABLE #TMP_CL
   (  [RowID]                       INT               IDENTITY(1,1) PRIMARY KEY                   
   ,  [LISTNAME]                    [nvarchar](10)    NULL     
   ,  [Code]                        [nvarchar](30)    NULL  
   ,  [Description]                 [nvarchar](250)   NULL  
   ,  [Short]                       [nvarchar](10)    NULL  
   ,  [Long]                        [nvarchar](250)   NULL  
   ,  [Notes]                       [nvarchar](4000)  NULL  
   ,  [Notes2]                      [nvarchar](4000)  NULL  
   ,  [Storerkey]                   [nvarchar](50)    NOT NULL  
   ,  [UDF01]                       [nvarchar](60)    NOT NULL  
   ,  [UDF02]                       [nvarchar](60)    NOT NULL  
   ,  [UDF03]                       [nvarchar](60)    NOT NULL  
   ,  [UDF04]                       [nvarchar](60)    NOT NULL  
   ,  [UDF05]                       [nvarchar](60)    NOT NULL  
   ,  [code2]                       [nvarchar](30)    NOT NULL 
   )     

   INSERT INTO #TMP_CL( Listname, Code, Description, Short, Long                
                     ,  Notes, Notes2, Storerkey
                     ,  UDF01, UDF02, UDF03, UDF04, UDF05, Code2
                     )  
   SELECT CL.Listname   
         , CL.Code   
         , [Description] = ISNULL(CL.[Description],'')   
         , Short = ISNULL(CL.Short,'')      
         , Long  = ISNULL(CL.Long ,'')     
         , Notes = ISNULL(CL.Notes,'')      
         , Notes2= ISNULL(CL.Notes2,'')           
         , CL.Storerkey  
         , CL.UDF01   
         , CL.UDF02   
         , CL.UDF03   
         , CL.UDF04   
         , CL.UDF05   
         , CL.Code2  
   FROM CODELKUP CL (NOLOCK)  
   WHERE CL.Listname = @c_ListName
   AND   CL.Storerkey= @c_Storerkey
   ORDER BY  CL.Listname, CL.Code 

   IF @c_UserID = ''
   BEGIN
      SET @c_UserID = dbo.Fnc_GetUserName()
   END
  
   --SET @c_ReceiptLineNumber  = ''

   IF @c_Sku > '' 
   BEGIN
      SET @c_SQLCond_Sku = @c_SQLCond_Sku + ' AND LotxLocxId.Sku = @c_Sku'
      SET @c_SQLCond_PA  = @c_SQLCond_PA  + ' AND LocxId.nSku = 1'
      SET @c_SQLSelect_LA = @c_SQLSelect_LA + ', nSku = COUNT(DISTINCT lli.Sku)'
   END

   IF @c_Sku = ''
   BEGIN
      SELECT TOP 1 @c_Sku = s.Sku
                  ,@c_Packkey = s.Packkey
      FROM SKU s (NOLOCK)
      WHERE s.Storerkey = @c_Storerkey
   END

   SELECT @cpa_StrategyKey = stg.PutawayStrategyKey
         ,@c_ItemClass     = ISNULL(s.itemclass,'')
   FROM SKU s (NOLOCK)
   JOIN Strategy stg (NOLOCK) ON stg.StrategyKey = s.StrategyKey
   WHERE s.Storerkey = @c_Storerkey
   AND   s.Sku = @c_Sku

   SELECT @n_Pallet = p.Pallet
   FROM PACK p(NOLOCK)
   WHERE p.Packkey = @c_Packkey

   SELECT @c_Facility = LOC.Facility
   FROM LOC (NOLOCK) 
   WHERE Loc = @c_FromLoc

   SET @CUR_PAS = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
   SELECT pasd.PutawayStrategyLineNumber
         ,pasd.LocationTypeExclude01    
         ,pasd.LocationTypeExclude02    
         ,pasd.LocationTypeExclude03    
         ,pasd.LocationTypeExclude04    
         ,pasd.LocationTypeExclude05    
         ,pasd.LocationCategoryExclude01    
         ,pasd.LocationCategoryExclude02    
         ,pasd.LocationCategoryExclude03    
         ,pasd.LocationHandlingExclude01    
         ,pasd.LocationHandlingExclude02    
         ,pasd.LocationHandlingExclude03   
         ,pasd.LocationFlagExclude01    
         ,pasd.LocationFlagExclude02    
         ,pasd.LocationFlagExclude03           
         ,pasd.LocationFlagInclude01    
         ,pasd.LocationFlagInclude02    
         ,pasd.LocationFlagInclude03    
         ,pasd.LocationCategoryInclude01    
         ,pasd.LocationCategoryInclude02    
         ,pasd.LocationCategoryInclude03    
         ,pasd.LocationHandlingInclude01    
         ,pasd.LocationHandlingInclude02    
         ,pasd.LocationHandlingInclude03    
         ,pasd.AreaTypeExclude01    
         ,pasd.AreaTypeExclude02    
         ,pasd.AreaTypeExclude03    
         ,pasd.LocationTypeRestriction01    
         ,pasd.LocationTypeRestriction02    
         ,pasd.LocationTypeRestriction03  
         ,pasd.LocLevelInclude01    
         ,pasd.LocLevelInclude02    
         ,pasd.LocLevelInclude03    
         ,pasd.LocLevelInclude04    
         ,pasd.LocLevelInclude05    
         ,pasd.LocLevelInclude06    
         ,pasd.LocLevelExclude01    
         ,pasd.LocLevelExclude02    
         ,pasd.LocLevelExclude03    
         ,pasd.LocLevelExclude04    
         ,pasd.LocLevelExclude05    
         ,pasd.LocLevelExclude06    
         ,pasd.LocAisleInclude01    
         ,pasd.LocAisleInclude02    
         ,pasd.LocAisleInclude03    
         ,pasd.LocAisleInclude04    
         ,pasd.LocAisleInclude05    
         ,pasd.LocAisleInclude06    
         ,pasd.LocAisleExclude01    
         ,pasd.LocAisleExclude02    
         ,pasd.LocAisleExclude03    
         ,pasd.LocAisleExclude04    
         ,pasd.LocAisleExclude05    
         ,pasd.LocAisleExclude06    
         ,pasd.PutawayZone01    
         ,pasd.PutawayZone02    
         ,pasd.PutawayZone03    
         ,pasd.PutawayZone04    
         ,pasd.PutawayZone05  
   FROM PutawayStrategyDetail pasd (NOLOCK)
   WHERE pasd.PutawayStrategyKey = @cpa_StrategyKey
   AND   Pasd.PAType = ''
   ORDER BY pasd.PutawayStrategyLineNumber
   
   OPEN @CUR_PAS

   FETCH NEXT FROM @CUR_PAS INTO @cpa_StrategyLineNo
                              ,  @cpa_LocationTypeExclude01       
                              ,  @cpa_LocationTypeExclude02       
                              ,  @cpa_LocationTypeExclude03       
                              ,  @cpa_LocationTypeExclude04       
                              ,  @cpa_LocationTypeExclude05       
                              ,  @cpa_LocationCategoryExclude01   
                              ,  @cpa_LocationCategoryExclude02   
                              ,  @cpa_LocationCategoryExclude03   
                              ,  @cpa_LocationHandlingExclude01   
                              ,  @cpa_LocationHandlingExclude02   
                              ,  @cpa_LocationHandlingExclude03 
                              ,  @cpa_LocationFlagExclude01       
                              ,  @cpa_LocationFlagExclude02       
                              ,  @cpa_LocationFlagExclude03                               
                              ,  @cpa_LocationFlagInclude01       
                              ,  @cpa_LocationFlagInclude02       
                              ,  @cpa_LocationFlagInclude03 
                              ,  @cpa_LocationCategoryInclude01   
                              ,  @cpa_LocationCategoryInclude02   
                              ,  @cpa_LocationCategoryInclude03   
                              ,  @cpa_LocationHandlingInclude01   
                              ,  @cpa_LocationHandlingInclude02   
                              ,  @cpa_LocationHandlingInclude03   
                              ,  @cpa_AreaTypeExclude01           
                              ,  @cpa_AreaTypeExclude02           
                              ,  @cpa_AreaTypeExclude03           
                              ,  @cpa_LocationTypeRestriction01   
                              ,  @cpa_LocationTypeRestriction02   
                              ,  @cpa_LocationTypeRestriction03   
                              ,  @npa_LocLevelInclude01           
                              ,  @npa_LocLevelInclude02           
                              ,  @npa_LocLevelInclude03           
                              ,  @npa_LocLevelInclude04           
                              ,  @npa_LocLevelInclude05           
                              ,  @npa_LocLevelInclude06           
                              ,  @npa_LocLevelExclude01           
                              ,  @npa_LocLevelExclude02           
                              ,  @npa_LocLevelExclude03           
                              ,  @npa_LocLevelExclude04           
                              ,  @npa_LocLevelExclude05           
                              ,  @npa_LocLevelExclude06           
                              ,  @cpa_LocAisleInclude01           
                              ,  @cpa_LocAisleInclude02           
                              ,  @cpa_LocAisleInclude03           
                              ,  @cpa_LocAisleInclude04           
                              ,  @cpa_LocAisleInclude05           
                              ,  @cpa_LocAisleInclude06           
                              ,  @cpa_LocAisleExclude01           
                              ,  @cpa_LocAisleExclude02           
                              ,  @cpa_LocAisleExclude03           
                              ,  @cpa_LocAisleExclude04           
                              ,  @cpa_LocAisleExclude05           
                              ,  @cpa_LocAisleExclude06           
                              ,  @cpa_PutawayZone01               
                              ,  @cpa_PutawayZone02               
                              ,  @cpa_PutawayZone03               
                              ,  @cpa_PutawayZone04               
                              ,  @cpa_PutawayZone05               

   WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
   BEGIN
      TRUNCATE TABLE #TMP_PALOC;
      SET @c_SQLCond_Loc = ''
      SELECT @c_SQLCond_Loc = dbo.Fnc_PARestriction (@cpa_StrategyKey
                                                   , @cpa_StrategyLineNo)
 
      SET @c_SQL = N'SELECT DISTINCT LOC.LOC'
                 + ' FROM LOC (NOLOCK)'
                 + ' LEFT OUTER JOIN AREADETAIL (NOLOCK)'
                 +                 ' ON AREADETAIL.PutawayZone = LOC.PutawayZone'
                 + ' WHERE LOC.Facility = @c_Facility'
                 + ''
                 + @c_SQLCond_Loc
 
      SET @c_SQLParms = N'@c_Facility                       NVARCHAR(5)' 
                      +', @cpa_AreaKey                      NVARCHAR(10)' 
                      +', @cpa_LocationTypeExclude01        NVARCHAR(10)' 
                      +', @cpa_LocationTypeExclude02        NVARCHAR(10)' 
                      +', @cpa_LocationTypeExclude03        NVARCHAR(10)' 
                      +', @cpa_LocationTypeExclude04        NVARCHAR(10)' 
                      +', @cpa_LocationTypeExclude05        NVARCHAR(10)' 
                      +', @cpa_LocationCategoryExclude01    NVARCHAR(10)' 
                      +', @cpa_LocationCategoryExclude02    NVARCHAR(10)'  
                      +', @cpa_LocationCategoryExclude03    NVARCHAR(10)'
                      +', @cpa_LocationHandlingExclude01    NVARCHAR(10)'
                      +', @cpa_LocationHandlingExclude02    NVARCHAR(10)'
                      +', @cpa_LocationHandlingExclude03    NVARCHAR(10)'
                      +', @cpa_LocationFlagExclude01        NVARCHAR(10)' 
                      +', @cpa_LocationFlagExclude02        NVARCHAR(10)' 
                      +', @cpa_LocationFlagExclude03        NVARCHAR(10)' 
                      +', @cpa_LocationFlagInclude01        NVARCHAR(10)'
                      +', @cpa_LocationFlagInclude02        NVARCHAR(10)'
                      +', @cpa_LocationFlagInclude03        NVARCHAR(10)'
                      +', @cpa_LocationCategoryInclude01    NVARCHAR(10)'
                      +', @cpa_LocationCategoryInclude02    NVARCHAR(10)'
                      +', @cpa_LocationCategoryInclude03    NVARCHAR(10)'
                      +', @cpa_LocationHandlingInclude01    NVARCHAR(10)'
                      +', @cpa_LocationHandlingInclude02    NVARCHAR(10)'
                      +', @cpa_LocationHandlingInclude03    NVARCHAR(10)'
                      +', @cpa_AreaTypeExclude01            NVARCHAR(10)'
                      +', @cpa_AreaTypeExclude02            NVARCHAR(10)'
                      +', @cpa_AreaTypeExclude03            NVARCHAR(10)'
                      +', @cpa_LocationTypeRestriction01    NVARCHAR(10)'
                      +', @cpa_LocationTypeRestriction02    NVARCHAR(10)'
                      +', @cpa_LocationTypeRestriction03    NVARCHAR(10)'
                      +', @npa_LocLevelInclude01            INT'         
                      +', @npa_LocLevelInclude02            INT'         
                      +', @npa_LocLevelInclude03            INT'         
                      +', @npa_LocLevelInclude04            INT'         
                      +', @npa_LocLevelInclude05            INT'         
                      +', @npa_LocLevelInclude06            INT'             
                      +', @npa_LocLevelExclude01            INT'            
                      +', @npa_LocLevelExclude02            INT'            
                      +', @npa_LocLevelExclude03            INT'            
                      +', @npa_LocLevelExclude04            INT'            
                      +', @npa_LocLevelExclude05            INT'            
                      +', @npa_LocLevelExclude06            INT'            
                      +', @cpa_LocAisleInclude01            NVARCHAR(10)'    
                      +', @cpa_LocAisleInclude02            NVARCHAR(10)'    
                      +', @cpa_LocAisleInclude03            NVARCHAR(10)'    
                      +', @cpa_LocAisleInclude04            NVARCHAR(10)'    
                      +', @cpa_LocAisleInclude05            NVARCHAR(10)'    
                      +', @cpa_LocAisleInclude06            NVARCHAR(10)'    
                      +', @cpa_LocAisleExclude01            NVARCHAR(10)'    
                      +', @cpa_LocAisleExclude02            NVARCHAR(10)'    
                      +', @cpa_LocAisleExclude03            NVARCHAR(10)'    
                      +', @cpa_LocAisleExclude04            NVARCHAR(10)'
                      +', @cpa_LocAisleExclude05            NVARCHAR(10)'
                      +', @cpa_LocAisleExclude06            NVARCHAR(10)'
                      +', @cpa_PutawayZone01                NVARCHAR(10)' 
                      +', @cpa_PutawayZone02                NVARCHAR(10)' 
                      +', @cpa_PutawayZone03                NVARCHAR(10)' 
                      +', @cpa_PutawayZone04                NVARCHAR(10)' 
                      +', @cpa_PutawayZone05                NVARCHAR(10)'

      INSERT INTO #TMP_PALOC
      EXEC sp_ExecuteSQL @c_SQL
                        ,@c_SQLParms
                        ,@c_Facility
                        ,@cpa_AreaKey
                        ,@cpa_LocationTypeExclude01       
                        ,@cpa_LocationTypeExclude02       
                        ,@cpa_LocationTypeExclude03       
                        ,@cpa_LocationTypeExclude04       
                        ,@cpa_LocationTypeExclude05       
                        ,@cpa_LocationCategoryExclude01   
                        ,@cpa_LocationCategoryExclude02   
                        ,@cpa_LocationCategoryExclude03   
                        ,@cpa_LocationHandlingExclude01   
                        ,@cpa_LocationHandlingExclude02   
                        ,@cpa_LocationHandlingExclude03 
                        ,@cpa_LocationFlagExclude01       
                        ,@cpa_LocationFlagExclude02       
                        ,@cpa_LocationFlagExclude03                         
                        ,@cpa_LocationFlagInclude01       
                        ,@cpa_LocationFlagInclude02       
                        ,@cpa_LocationFlagInclude03  
                        ,@cpa_LocationCategoryInclude01   
                        ,@cpa_LocationCategoryInclude02   
                        ,@cpa_LocationCategoryInclude03   
                        ,@cpa_LocationHandlingInclude01   
                        ,@cpa_LocationHandlingInclude02   
                        ,@cpa_LocationHandlingInclude03   
                        ,@cpa_AreaTypeExclude01           
                        ,@cpa_AreaTypeExclude02           
                        ,@cpa_AreaTypeExclude03           
                        ,@cpa_LocationTypeRestriction01   
                        ,@cpa_LocationTypeRestriction02   
                        ,@cpa_LocationTypeRestriction03 
                        ,@npa_LocLevelInclude01           
                        ,@npa_LocLevelInclude02           
                        ,@npa_LocLevelInclude03           
                        ,@npa_LocLevelInclude04           
                        ,@npa_LocLevelInclude05           
                        ,@npa_LocLevelInclude06           
                        ,@npa_LocLevelExclude01           
                        ,@npa_LocLevelExclude02           
                        ,@npa_LocLevelExclude03           
                        ,@npa_LocLevelExclude04           
                        ,@npa_LocLevelExclude05           
                        ,@npa_LocLevelExclude06           
                        ,@cpa_LocAisleInclude01           
                        ,@cpa_LocAisleInclude02           
                        ,@cpa_LocAisleInclude03           
                        ,@cpa_LocAisleInclude04           
                        ,@cpa_LocAisleInclude05           
                        ,@cpa_LocAisleInclude06           
                        ,@cpa_LocAisleExclude01           
                        ,@cpa_LocAisleExclude02           
                        ,@cpa_LocAisleExclude03           
                        ,@cpa_LocAisleExclude04           
                        ,@cpa_LocAisleExclude05           
                        ,@cpa_LocAisleExclude06           
                        ,@cpa_PutawayZone01               
                        ,@cpa_PutawayZone02               
                        ,@cpa_PutawayZone03               
                        ,@cpa_PutawayZone04               
                        ,@cpa_PutawayZone05    

      SET @n_RowCount = @@ROWCOUNT
      IF @n_RowCount = 0
      BEGIN
         GOTO NEXT_STRATEGY
      END
 
      SET @c_PAType = ''
      SET @c_Criteria = ''
      SET @c_SQLSkipPAType = ''
      SET @c_Condition= ''
      SET @c_SortBy = ''
      SET @c_SQLCond_PA = ''                                                        --2026-03-24
      SET @c_SQLSelect_LA = ''                                                      --2026-03-24
      SET @c_SQLCond= ''

      SELECT TOP 1
            @c_PAType      = cl.UDF01
      FROM #TMP_CL cl (NOLOCK)
      WHERE cl.ListName = @c_ListName
      AND   cl.Code = 'PAType'
      AND   cl.Storerkey = @c_Storerkey
      AND   cl.Code2 IN (@cpa_StrategyLineNo, '')
      ORDER BY cl.Code2 DESC
      
      SELECT TOP 1
            @c_SQLSkipPAType = cl.Notes
      FROM #TMP_CL cl (NOLOCK)
      WHERE cl.ListName = @c_ListName
      AND   cl.Code = 'SkipPAType'
      AND   cl.Storerkey = @c_Storerkey
      AND   cl.Code2 IN (@cpa_StrategyLineNo, '')
      ORDER BY cl.Code2 DESC

      SELECT TOP 1
            @c_Condition = cl.Notes
      FROM #TMP_CL cl (NOLOCK)
      WHERE cl.ListName = @c_ListName
      AND   cl.Code = 'Condition'
      AND   cl.Storerkey = @c_Storerkey
      AND   cl.Code2 IN (@cpa_StrategyLineNo, '')
      ORDER BY cl.Code2 DESC

      SELECT TOP 1
            @c_SortBy = cl.Notes
      FROM #TMP_CL cl (NOLOCK)
      WHERE cl.ListName = @c_ListName
      AND   cl.Code = 'Sorting'
      AND   cl.Storerkey = @c_Storerkey
      AND   cl.Code2 IN (@cpa_StrategyLineNo, '')
      ORDER BY cl.Code2 DESC

      SELECT TOP 1
            @c_ForceMatchLA = cl.UDF01
      FROM #TMP_CL cl (NOLOCK)
      WHERE cl.ListName = @c_ListName
      AND   cl.Code = 'ForceMatchLA'
      AND   cl.Storerkey = @c_Storerkey
      AND   cl.Code2 IN (@cpa_StrategyLineNo, '')
      ORDER BY cl.Code2 DESC

      IF @c_Lottable01 > '' OR CHARINDEX('01',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable01 = @c_Lottable01'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot01 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA + ', nLot01 = COUNT(DISTINCT la.Lottable01)'
      END

      IF @c_Lottable02 > '' OR CHARINDEX('02',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable02 = @c_Lottable02'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot02 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA + ', nLot02 = COUNT(DISTINCT la.Lottable02)'
      END

      IF @c_Lottable03 > '' OR CHARINDEX('03',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable03 = @c_Lottable03'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot03 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA + ', nLot03 = COUNT(DISTINCT la.Lottable03)'
      END

      IF @dt_Lottable04 NOT IN (NULL, '1900-01-01') OR CHARINDEX('04',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable04 = @dt_Lottable04'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot04 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA + ', nLot04 = COUNT(DISTINCT ISNULL(la.Lottable04,''1900-01-01''))'
      END

      IF @dt_Lottable05 NOT IN (NULL, '1900-01-01') OR CHARINDEX('05',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable05 = @dt_Lottable05'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot05 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA + ', nLot05 = COUNT(DISTINCT ISNULL(la.Lottable05,''1900-01-01''))'
      END

      IF @c_Lottable06 > '' OR CHARINDEX('06',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable06 = @c_Lottable06'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot06 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA + ', nLot06 = COUNT(DISTINCT la.Lottable06)'
      END

      IF @c_Lottable07 > '' OR CHARINDEX('07',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable07 = @c_Lottable07'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot07 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA + ', nLot07 = COUNT(DISTINCT la.Lottable07)'
      END

      IF @c_Lottable08 > '' OR CHARINDEX('08',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable08 = @c_Lottable08'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot08 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA + ', nLot08 = COUNT(DISTINCT la.Lottable08)'
      END

      IF @c_Lottable09 > '' OR CHARINDEX('09',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable09 = @c_Lottable09'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot09 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA + ', nLot09 = COUNT(DISTINCT la.Lottable09)'
      END

      IF @c_Lottable10 > '' OR CHARINDEX('10',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable10 = @c_Lottable10'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot10 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA + ', nLot10 = COUNT(DISTINCT la.Lottable10)'
      END

      IF @c_Lottable11 > '' OR CHARINDEX('11',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable11 = @c_Lottable11'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot11 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA + ', nLot11 = COUNT(DISTINCT la.Lottable11)'
      END

      IF @c_Lottable12 > '' OR CHARINDEX('12',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable12 = @c_Lottable12'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot12 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA 
                             + ', nLot12 = COUNT(DISTINCT la.Lottable12)'
      END

      IF @dt_Lottable13 NOT IN (NULL, '1900-01-01') OR CHARINDEX('13',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable13 = @dt_Lottable13'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot13 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA 
                             + ', nLot13 = COUNT(DISTINCT ISNULL(la.Lottable13,''1900-01-01''))'
      END

      IF @dt_Lottable14 NOT IN (NULL, '1900-01-01') OR CHARINDEX('14',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable14 = @dt_Lottable14'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot14 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA 
                             + ', nLot14 = COUNT(DISTINCT ISNULL(la.Lottable14,''1900-01-01''))'
      END

      IF @dt_Lottable15 NOT IN (NULL, '1900-01-01') OR CHARINDEX('15',@c_ForceMatchLA) > 1
      BEGIN
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LotAttribute.Lottable15 = @dt_Lottable15'
         SET @c_SQLCond_PA = @c_SQLCond_PA + ' AND LocxId.nLot15 = 1'
         SET @c_SQLSelect_LA = @c_SQLSelect_LA 
                           + ', nLot15 = COUNT(DISTINCT ISNULL(la.Lottable15,''1900-01-01''))'
      END
      
      IF @c_PAType = '' 
      BEGIN
         SET @c_PAType = 'EmptyLoc'
      END

      IF @c_PAType = 'MatchLPNAttrib' 
      BEGIN
         SET @c_SQLCond = @c_SQLCond + ' AND LotxLocxId.ID > '''''
         IF CHARINDEX('LOC.MaxPallet', @c_SQLCond_Loc) > 0
         BEGIN
            SET @c_SQLCond = @c_SQLCond + ' AND LOC.MaxPallet > LocxId.nID'
         END
      END

      IF @c_SQLSkipPAType > ''
      BEGIN
         SET @b_Proceed = 1
         SET @c_SQLParms = N'@c_Storerkey NVARCHAR(15)'
                         + ',@c_Sku NVARCHAR(20)'
                         + ',@c_ItemClass NVARCHAR(10)'
                         + ',@n_Qty INT '
                         + ',@n_LPNLeftToFulfill INT '
                         + ',@n_Pallet INT'
                         + ',@c_Receiptkey NVARCHAR(10)'                            --2026-04-16
                         + ',@c_ReceiptlineNumber NVARCHAR(5)'                      --2026-04-16
                         + ',@c_FromLoc NVARCHAR(10)'                               --2026-04-16
                         + ',@c_ID NVARCHAR(18)'                                    --2026-04-16
                         + ',@b_Proceed BIT OUTPUT'

         EXEC sp_ExecuteSQL @c_SQLSkipPAType
                           ,@c_SQLParms
                           ,@c_Storerkey
                           ,@c_Sku
                           ,@c_ItemClass
                           ,@n_Qty
                           ,@n_LPNLeftToFulfill
                           ,@n_Pallet
                           ,@c_Receiptkey                                           --2026-04-16
                           ,@c_ReceiptlineNumber                                    --2026-04-16
                           ,@c_FromLoc                                              --2026-04-16
                           ,@c_ID                                                   --2026-04-16
                           ,@b_Proceed OUTPUT

         IF @b_Debug = 1
         BEGIN
            PRINT '@b_Proceed: ' + @c_SQLSkipPAType
            PRINT '@c_Receiptkey: ' + @c_Receiptkey + 
                  ',@c_ReceiptlineNumber: ' + @c_ReceiptlineNumber +
                  ',@c_ID: ' + @c_ID
            PRINT @b_Proceed
         END

         IF @b_Proceed = 0
         BEGIN
            GOTO NEXT_STRATEGY
         END
      END
 
      IF @b_Debug = 1
      BEGIN
         PRINT '@cpa_StrategyLineNo: ' + @cpa_StrategyLineNo 
            + ', @n_Qty: ' + CAST(@n_Qty as nvarchar)
            + ', @n_Pallet: ' + CAST(@n_Pallet as nvarchar)
            + ', @c_PAType: ' + @c_PAType
      END

      IF @c_PAType NOT IN ('EmptyLoc','PADefaultLoc')                                 --2026-04-16
      BEGIN
         SET @c_SQLCond = @c_SQLCond_Sku + @c_SQLCond_PA + @c_SQLCond
      END
      
      IF @c_Condition > ''
      BEGIN
         SET @c_SQLCond = @c_SQLCond + ' ' + @c_Condition
      END
 
      IF @c_SortBy = ''
      BEGIN
         SET @c_SortBy = ' ORDER BY LOC.PALogicalLoc'
      END
      ELSE
      BEGIN
         SET @c_SortBy = ' ORDER BY ' + @c_SortBy 
      END
 
      SET @c_ToLoc = ''
      SET @n_AvailablePASlot = 0
      IF @c_PAType = 'PADefaultLoc'                                                 --2026-04-16
      BEGIN
         IF @c_SQLCond = ''
         BEGIN
            SET @c_SQLCond = ' AND 1 = 2'
         END

         SET @c_SQL = 
         + N'SELECT TOP 1 @c_ToLoc = LOC.Loc'
         +              ',@n_AvailablePASlot = LOC.MaxPallet' 
         + ' FROM  #TMP_PALOC as tpa'
         + ' JOIN LOC (NOLOCK) ON LOC.Loc = tpa.LOC'
         + ' WHERE 1 = 1' 
         + @c_SQLCond
      END
      IF @c_PAType = 'MatchLPNAttrib' 
      BEGIN
         --Find Same Friend
         SET @c_SQL = 
               + N'SELECT TOP 1 @c_ToLoc = LOC.Loc'
               +              ',@n_AvailablePASlot = LOC.MaxPallet - LocxId.nID'
               + ' FROM  #TMP_PALOC as tpa'
               + ' JOIN LOC (NOLOCK) ON LOC.Loc = tpa.LOC'
               + ' JOIN LotxLocxId (NOLOCK) ON LotxLocxId.Loc = LOC.Loc'
               + ' JOIN LotAttribute (NOLOCK) ON LotAttribute.Lot = LotxLocxId.Lot'
               + ' JOIN ID (NOLOCK) ON ID.Id = LotxLocxId.Id'
               + ' JOIN Sku (NOLOCK) ON Sku.Storerkey = LotxLocxId.Storerkey'
               +                   ' AND Sku.Sku = LotxLocxId.Sku'
               + ' CROSS APPLY(SELECT nID = COUNT(DISTINCT lli.ID)'
               +             @c_SQLSelect_LA 
               +             ' FROM LotxLocxId lli  (NOLOCK)'
               +             ' JOIN LotAttribute la (NOLOCK) ON la.Lot = lli.Lot'
               +             ' WHERE lli.Loc = LOC.Loc'
               +             ' AND lli.Qty - lli.QtyPicked + lli.PendingMoveIN > 0'
               +             ') LocxId'
               + ' WHERE LotxLocxId.Storerkey = @c_Storerkey'
               + @c_SQLCond
               + @c_SortBy
      END
      ELSE IF @c_PAType = 'EmptyLoc' 
      BEGIN
         --Find Empty
         SET @c_SQL = 
               + N'SELECT TOP 1 @c_ToLoc = LOC.Loc'
               +              ',@n_AvailablePASlot = LOC.MaxPallet' 
               + ' FROM  #TMP_PALOC as tpa'
               + ' JOIN LOC (NOLOCK) ON LOC.Loc = tpa.LOC'
               + ' WHERE NOT EXISTS(SELECT 1' 
               +                  ' FROM LotxLocxId lli (NOLOCK)'
               +                  ' WHERE lli.Loc = LOC.Loc'
               +                  ' AND   lli.Qty - lli.QtyPicked + lli.PendingMoveIN > 0'
               +                  ')'
               + @c_SQLCond
               + @c_SortBy
      END

      SET @c_SQLParms = N'@c_Storerkey    NVARCHAR(15)'
                      +', @c_Sku          NVARCHAR(20)'
                      +', @c_Lottable01   NVARCHAR(18)'
                      +', @c_Lottable02   NVARCHAR(18)'
                      +', @c_Lottable03   NVARCHAR(18)'
                      +', @dt_Lottable04  DATETIME'
                      +', @dt_Lottable05  DATETIME'
                      +', @c_Lottable06   NVARCHAR(36)'
                      +', @c_Lottable07   NVARCHAR(36)'
                      +', @c_Lottable08   NVARCHAR(36)'
                      +', @c_Lottable09   NVARCHAR(36)'
                      +', @c_Lottable10   NVARCHAR(36)'
                      +', @c_Lottable11   NVARCHAR(36)'
                      +', @c_Lottable12   NVARCHAR(36)'
                      +', @dt_Lottable13  DATETIME'   
                      +', @dt_Lottable14  DATETIME'   
                      +', @dt_Lottable15  DATETIME'
                      +', @n_Qty          INT'
                      +', @n_LPNLeftToFulfill   INT'
                      +', @c_Facility     NVARCHAR(5)'                              --2026-04-16
                      +', @c_Receiptkey   NVARCHAR(10)'                             --2026-04-16
                      +', @c_ReceiptLineNumber  NVARCHAR(5)'                        --2026-04-16
                      +', @c_ToLoc        NVARCHAR(10)   OUTPUT' 
                      +', @n_AvailablePASlot INT         OUTPUT'
                        
      EXEC sp_ExecuteSQL @c_SQL
                        ,@c_SQLParms
                        ,@c_Storerkey
                        ,@c_Sku     
                        ,@c_Lottable01  
                        ,@c_Lottable02  
                        ,@c_Lottable03  
                        ,@dt_Lottable04 
                        ,@dt_Lottable05 
                        ,@c_Lottable06  
                        ,@c_Lottable07        
                        ,@c_Lottable08        
                        ,@c_Lottable09        
                        ,@c_Lottable10        
                        ,@c_Lottable11        
                        ,@c_Lottable12        
                        ,@dt_Lottable13       
                        ,@dt_Lottable14       
                        ,@dt_Lottable15 
                        ,@n_Qty
                        ,@n_LPNLeftToFulfill
                        ,@c_Facility                                                --2026-04-16
                        ,@c_Receiptkey                                              --2026-04-16
                        ,@c_ReceiptLineNumber                                       --2026-04-16
                        ,@c_ToLoc            OUTPUT
                        ,@n_AvailablePASlot  OUTPUT

      IF @b_Debug = 1
      BEGIN
         PRINT '@c_PAType: ' + @c_PAType
             + ',@c_SQL: ' + @c_SQL
      END

      IF @c_PAType = 'PADefaultLoc' AND @c_ToLoc = ''                               --2026-04-16
      BEGIN
         SET @n_Continue = 4
      END
 
      IF @c_ToLoc > ''
      BEGIN
         SET @n_Continue = 4
      END

      IF @n_AvailablePASlot < 0 
      BEGIN
         SET @n_AvailablePASlot = 0
      END

      NEXT_STRATEGY:

      FETCH NEXT FROM @CUR_PAS INTO @cpa_StrategyLineNo
                                 ,  @cpa_LocationTypeExclude01       
                                 ,  @cpa_LocationTypeExclude02       
                                 ,  @cpa_LocationTypeExclude03       
                                 ,  @cpa_LocationTypeExclude04       
                                 ,  @cpa_LocationTypeExclude05       
                                 ,  @cpa_LocationCategoryExclude01   
                                 ,  @cpa_LocationCategoryExclude02   
                                 ,  @cpa_LocationCategoryExclude03   
                                 ,  @cpa_LocationHandlingExclude01   
                                 ,  @cpa_LocationHandlingExclude02   
                                 ,  @cpa_LocationHandlingExclude03  
                                 ,  @cpa_LocationFlagExclude01       
                                 ,  @cpa_LocationFlagExclude02       
                                 ,  @cpa_LocationFlagExclude03                                    
                                 ,  @cpa_LocationFlagInclude01       
                                 ,  @cpa_LocationFlagInclude02       
                                 ,  @cpa_LocationFlagInclude03 
                                 ,  @cpa_LocationCategoryInclude01   
                                 ,  @cpa_LocationCategoryInclude02   
                                 ,  @cpa_LocationCategoryInclude03   
                                 ,  @cpa_LocationHandlingInclude01   
                                 ,  @cpa_LocationHandlingInclude02   
                                 ,  @cpa_LocationHandlingInclude03   
                                 ,  @cpa_AreaTypeExclude01           
                                 ,  @cpa_AreaTypeExclude02           
                                 ,  @cpa_AreaTypeExclude03           
                                 ,  @cpa_LocationTypeRestriction01   
                                 ,  @cpa_LocationTypeRestriction02   
                                 ,  @cpa_LocationTypeRestriction03   
                                 ,  @npa_LocLevelInclude01           
                                 ,  @npa_LocLevelInclude02           
                                 ,  @npa_LocLevelInclude03           
                                 ,  @npa_LocLevelInclude04           
                                 ,  @npa_LocLevelInclude05           
                                 ,  @npa_LocLevelInclude06           
                                 ,  @npa_LocLevelExclude01           
                                 ,  @npa_LocLevelExclude02           
                                 ,  @npa_LocLevelExclude03           
                                 ,  @npa_LocLevelExclude04           
                                 ,  @npa_LocLevelExclude05           
                                 ,  @npa_LocLevelExclude06           
                                 ,  @cpa_LocAisleInclude01           
                                 ,  @cpa_LocAisleInclude02           
                                 ,  @cpa_LocAisleInclude03           
                                 ,  @cpa_LocAisleInclude04           
                                 ,  @cpa_LocAisleInclude05           
                                 ,  @cpa_LocAisleInclude06           
                                 ,  @cpa_LocAisleExclude01           
                                 ,  @cpa_LocAisleExclude02           
                                 ,  @cpa_LocAisleExclude03           
                                 ,  @cpa_LocAisleExclude04           
                                 ,  @cpa_LocAisleExclude05           
                                 ,  @cpa_LocAisleExclude06           
                                 ,  @cpa_PutawayZone01               
                                 ,  @cpa_PutawayZone02               
                                 ,  @cpa_PutawayZone03               
                                 ,  @cpa_PutawayZone04               
                                 ,  @cpa_PutawayZone05
   END
   CLOSE @CUR_PAS
   DEALLOCATE @CUR_PAS

QUIT_SP:
   SET @c_Final_ToLoc = @c_ToLoc

   IF OBJECT_ID('tempdb..#TMP_PALOC') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_PALOC
   END

   IF OBJECT_ID('tempdb..#TMP_CL') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_CL
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0
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
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END