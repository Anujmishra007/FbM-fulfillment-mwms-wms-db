SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Function:  fnc_PARestriction                                         */
/* Creation Date: 2026-03-16                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: WAN                                                      */
/*                                                                      */
/* Purpose: Return Loc Restriction SQL. Based on nspRDTPASTD logic      */
/*        : FCR-10206 - SAU DAMMAM Putaway Strategy                     */
/*                                                                      */
/* Called By:  ispPutA01                                                */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver.  Purposes                                  */
/* 2026-03-10  Wan      1.0   Created.                                  */
/************************************************************************/
CREATE OR ALTER FUNCTION [dbo].[fnc_PARestriction] ( 
   @c_paStrategyKey        NVARCHAR(10)
,  @c_paStrategyLineNumber NVARCHAR(5)
) RETURNS NVARCHAR(MAX)
AS
BEGIN
   SET QUOTED_IDENTIFIER OFF

   DECLARE @cpa_PAType                       NVARCHAR(5)    = '' 
         , @cpa_FromLoc                      NVARCHAR(10)   = '' 
         , @cpa_ToLoc                        NVARCHAR(10)   = '' 
         , @cpa_AreaKey                      NVARCHAR(10)   = '' 
         , @cpa_Zone                         NVARCHAR(10)   = '' 
         , @cpa_LocType                      NVARCHAR(10)   = '' 
         , @cpa_LocSearchType                NVARCHAR(10)   = '' 
         , @cpa_DimensionRestriction01       NVARCHAR(5)    = ''
         , @cpa_DimensionRestriction02       NVARCHAR(5)    = ''
         , @cpa_DimensionRestriction03       NVARCHAR(5)    = ''
         , @cpa_DimensionRestriction04       NVARCHAR(5)    = ''
         , @cpa_DimensionRestriction05       NVARCHAR(5)    = ''
         , @cpa_DimensionRestriction06       NVARCHAR(5)    = ''
         , @cpa_LocationTypeExclude01        NVARCHAR(10)   = '' 
         , @cpa_LocationTypeExclude02        NVARCHAR(10)   = '' 
         , @cpa_LocationTypeExclude03        NVARCHAR(10)   = '' 
         , @cpa_LocationTypeExclude04        NVARCHAR(10)   = '' 
         , @cpa_LocationTypeExclude05        NVARCHAR(10)   = '' 
         , @cpa_LocationFlagExclude01        NVARCHAR(10)   = '' 
         , @cpa_LocationFlagExclude02        NVARCHAR(10)   = '' 
         , @cpa_LocationFlagExclude03        NVARCHAR(10)   = '' 
         , @cpa_LocationCategoryExclude01    NVARCHAR(10)   = '' 
         , @cpa_LocationCategoryExclude02    NVARCHAR(10)   = '' 
         , @cpa_LocationCategoryExclude03    NVARCHAR(10)   = '' 
         , @cpa_LocationHandlingExclude01    NVARCHAR(10)   = '' 
         , @cpa_LocationHandlingExclude02    NVARCHAR(10)   = '' 
         , @cpa_LocationHandlingExclude03    NVARCHAR(10)   = '' 
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
         --, @cpa_LocationTypeRestriction04  NVARCHAR(10)   = '' 
         --, @cpa_LocationTypeRestriction05  NVARCHAR(10)   = '' 
         --, @cpa_LocationTypeRestriction06  NVARCHAR(10)   = '' 
         , @cpa_FitFullReceipt               NVARCHAR(5)    = ''
         , @cpa_OrderType                    NVARCHAR(10)   = '' 
         , @npa_NumberofDaysOffSet           INT            = 0
         , @cpa_LocationStateRestriction01   NVARCHAR(5)    = ''
         , @cpa_LocationStateRestriction02   NVARCHAR(5)    = ''
         , @cpa_LocationStateRestriction03   NVARCHAR(5)    = ''
         , @cpa_AllowFullPallets             NVARCHAR(5)    = ''
         , @cpa_AllowFullCases               NVARCHAR(5)    = ''
         , @cpa_AllowPieces                  NVARCHAR(5)    = ''
         , @cpa_CheckEquipmentProfileKey     NVARCHAR(5)    = ''
         , @cpa_CheckRestrictions            NVARCHAR(5)    = ''
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

   DECLARE @c_SQL                            NVARCHAR(MAX)  = ''
         ,  @c_SQL_Areakey                   NVARCHAR(1000) = ''
         ,  @c_SQL_LocationTypeExclude       NVARCHAR(1000) = ''    
         ,  @c_SQL_LocationCategoryInclude   NVARCHAR(1000) = ''    
         ,  @c_SQL_LocationCategoryExclude   NVARCHAR(1000) = ''    
         ,  @c_SQL_LocationHandlingInclude   NVARCHAR(1000) = ''    
         ,  @c_SQL_LocationHandlingExclude   NVARCHAR(1000) = ''    
         ,  @c_SQL_LocationFlagInclude       NVARCHAR(1000) = ''    
         ,  @c_SQL_LocationFlagExclude       NVARCHAR(1000) = ''    
         ,  @c_SQL_LocLevelInclude           NVARCHAR(1000) = ''    
         ,  @c_SQL_LocLevelExclude           NVARCHAR(1000) = ''    
         ,  @c_SQL_LocAisleInclude           NVARCHAR(1000) = ''    
         ,  @c_SQL_LocAisleExclude           NVARCHAR(1000) = ''     
         ,  @c_SQL_LocTypeRestriction        NVARCHAR(1000) = ''    
         ,  @c_SQL_LocStateRestriction       NVARCHAR(1000) = ''  
         ,  @c_SQL_AreaTypeExclude           NVARCHAR(1000) = ''  
         ,  @c_SQL_Putawayzone               NVARCHAR(1000) = ''
         ,  @c_SQL_DimensionRestriction      NVARCHAR(1000) = ''
         ,  @c_SQL_MaxPallet                 NVARCHAR(1000) = ''
         ,  @c_SQL_ABC                       NVARCHAR(1000) = ''
         ,  @c_SQL_HostWHCode                NVARCHAR(1000) = ''

   SELECT TOP 1 
            @cpa_FromLoc                     = FROMLOC    
         ,  @cpa_ToLoc                       = ISNULL(TOLOC, '')    
         ,  @cpa_AreaKey                     = AreaKey    
         ,  @cpa_Zone                        = Zone    
         ,  @cpa_DimensionRestriction01      = DimensionRestriction01    
         ,  @cpa_DimensionRestriction02      = DimensionRestriction02    
         ,  @cpa_DimensionRestriction03      = DimensionRestriction03    
         ,  @cpa_DimensionRestriction04      = DimensionRestriction04    
         ,  @cpa_DimensionRestriction05      = DimensionRestriction05    
         ,  @cpa_DimensionRestriction06      = DimensionRestriction06    
         ,  @cpa_LocationTypeExclude01       = LocationTypeExclude01    
         ,  @cpa_LocationTypeExclude02       = LocationTypeExclude02    
         ,  @cpa_LocationTypeExclude03       = LocationTypeExclude03    
         ,  @cpa_LocationTypeExclude04       = LocationTypeExclude04    
         ,  @cpa_LocationTypeExclude05       = LocationTypeExclude05    
         ,  @cpa_LocationCategoryExclude01   = LocationCategoryExclude01    
         ,  @cpa_LocationCategoryExclude02   = LocationCategoryExclude02    
         ,  @cpa_LocationCategoryExclude03   = LocationCategoryExclude03    
         ,  @cpa_LocationHandlingExclude01   = LocationHandlingExclude01    
         ,  @cpa_LocationHandlingExclude02   = LocationHandlingExclude02    
         ,  @cpa_LocationHandlingExclude03   = LocationHandlingExclude03    
         ,  @cpa_LocationFlagInclude01       = LocationFlagInclude01    
         ,  @cpa_LocationFlagInclude02       = LocationFlagInclude02    
         ,  @cpa_LocationFlagInclude03       = LocationFlagInclude03    
         ,  @cpa_LocationFlagExclude01       = LocationFlagExclude01    
         ,  @cpa_LocationFlagExclude02       = LocationFlagExclude02    
         ,  @cpa_LocationFlagExclude03       = LocationFlagExclude03                 
         ,  @cpa_LocationCategoryInclude01   = LocationCategoryInclude01    
         ,  @cpa_LocationCategoryInclude02   = LocationCategoryInclude02    
         ,  @cpa_LocationCategoryInclude03   = LocationCategoryInclude03    
         ,  @cpa_LocationHandlingInclude01   = LocationHandlingInclude01    
         ,  @cpa_LocationHandlingInclude02   = LocationHandlingInclude02    
         ,  @cpa_LocationHandlingInclude03   = LocationHandlingInclude03    
         ,  @cpa_AreaTypeExclude01           = AreaTypeExclude01    
         ,  @cpa_AreaTypeExclude02           = AreaTypeExclude02    
         ,  @cpa_AreaTypeExclude03           = AreaTypeExclude03    
         ,  @cpa_LocationTypeRestriction01   = LocationTypeRestriction01    
         ,  @cpa_LocationTypeRestriction02   = LocationTypeRestriction02    
         ,  @cpa_LocationTypeRestriction03   = LocationTypeRestriction03    
         ,  @cpa_FitFullReceipt              = FitFullReceipt    
         ,  @cpa_OrderType                   = OrderType    
         ,  @npa_NumberofDaysOffSet          = NumberofDaysOffSet    
         ,  @cpa_LocationStateRestriction01  = LocationStateRestriction01    
         ,  @cpa_LocationStateRestriction02  = LocationStateRestriction02    
         ,  @cpa_LocationStateRestriction03  = LocationStateRestriction03    
         ,  @cpa_AllowFullPallets            = AllowFullPallets    
         ,  @cpa_AllowFullCases              = AllowFullCases    
         ,  @cpa_AllowPieces                 = AllowPieces    
         ,  @cpa_CheckEquipmentProfileKey    = CheckEquipmentProfileKey    
         ,  @cpa_CheckRestrictions           = CheckRestrictions    
         ,  @npa_LocLevelInclude01           = LocLevelInclude01    
         ,  @npa_LocLevelInclude02           = LocLevelInclude02    
         ,  @npa_LocLevelInclude03           = LocLevelInclude03    
         ,  @npa_LocLevelInclude04           = LocLevelInclude04    
         ,  @npa_LocLevelInclude05           = LocLevelInclude05    
         ,  @npa_LocLevelInclude06           = LocLevelInclude06    
         ,  @npa_LocLevelExclude01           = LocLevelExclude01    
         ,  @npa_LocLevelExclude02           = LocLevelExclude02    
         ,  @npa_LocLevelExclude03           = LocLevelExclude03    
         ,  @npa_LocLevelExclude04           = LocLevelExclude04    
         ,  @npa_LocLevelExclude05           = LocLevelExclude05    
         ,  @npa_LocLevelExclude06           = LocLevelExclude06    
         ,  @cpa_LocAisleInclude01           = LocAisleInclude01    
         ,  @cpa_LocAisleInclude02           = LocAisleInclude02    
         ,  @cpa_LocAisleInclude03           = LocAisleInclude03    
         ,  @cpa_LocAisleInclude04           = LocAisleInclude04    
         ,  @cpa_LocAisleInclude05           = LocAisleInclude05    
         ,  @cpa_LocAisleInclude06           = LocAisleInclude06    
         ,  @cpa_LocAisleExclude01           = LocAisleExclude01    
         ,  @cpa_LocAisleExclude02           = LocAisleExclude02    
         ,  @cpa_LocAisleExclude03           = LocAisleExclude03    
         ,  @cpa_LocAisleExclude04           = LocAisleExclude04    
         ,  @cpa_LocAisleExclude05           = LocAisleExclude05    
         ,  @cpa_LocAisleExclude06           = LocAisleExclude06    
         ,  @cpa_PutawayZone01               = PutawayZone01    
         ,  @cpa_PutawayZone02               = PutawayZone02    
         ,  @cpa_PutawayZone03               = PutawayZone03    
         ,  @cpa_PutawayZone04               = PutawayZone04    
         ,  @cpa_PutawayZone05               = PutawayZone05    
   FROM  PUTAWAYSTRATEGYDETAIL WITH (NOLOCK)    
   WHERE PutAwayStrategyKey = @c_paStrategyKey 
   AND   PutawayStrategyLineNumber = @c_paStrategyLineNumber 

   IF @cpa_CheckRestrictions = 'N'
   BEGIN 
      GOTO QUIT_FUNC
   END

     
   SET @c_SQL_LocationTypeExclude  = [dbo].[fnc_BuildVariableString](@cpa_LocationTypeExclude01
                                    , '@cpa_LocationTypeExclude01', @c_SQL_LocationTypeExclude)    
   SET @c_SQL_LocationTypeExclude  = [dbo].[fnc_BuildVariableString](@cpa_LocationTypeExclude02
                                    , '@cpa_LocationTypeExclude02', @c_SQL_LocationTypeExclude)    
   SET @c_SQL_LocationTypeExclude  = [dbo].[fnc_BuildVariableString](@cpa_LocationTypeExclude03
                                    , '@cpa_LocationTypeExclude03', @c_SQL_LocationTypeExclude)    
   SET @c_SQL_LocationTypeExclude  = [dbo].[fnc_BuildVariableString](@cpa_LocationTypeExclude04
                                    , '@cpa_LocationTypeExclude04', @c_SQL_LocationTypeExclude)    
   SET @c_SQL_LocationTypeExclude  = [dbo].[fnc_BuildVariableString](@cpa_LocationTypeExclude05
                                    , '@cpa_LocationTypeExclude05', @c_SQL_LocationTypeExclude)    
   IF @c_SQL_LocationTypeExclude > ''    
   BEGIN    
      IF CHARINDEX(',', @c_SQL_LocationTypeExclude) > 0     
      BEGIN    
         SET @c_SQL_LocationTypeExclude  = ' AND LOC.LocationType NOT IN ('+ @c_SQL_LocationTypeExclude + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_LocationTypeExclude  = ' AND LOC.LocationType <> ' + @c_SQL_LocationTypeExclude     
      END             
   END    
          
   SET @c_SQL_LocationCategoryExclude = [dbo].[fnc_BuildVariableString](@cpa_LocationCategoryExclude01
                                       , '@cpa_LocationCategoryExclude01', @c_SQL_LocationCategoryExclude)    
   SET @c_SQL_LocationCategoryExclude = [dbo].[fnc_BuildVariableString](@cpa_LocationCategoryExclude02
                                       , '@cpa_LocationCategoryExclude02', @c_SQL_LocationCategoryExclude)    
   SET @c_SQL_LocationCategoryExclude = [dbo].[fnc_BuildVariableString](@cpa_LocationCategoryExclude03
                                       , '@cpa_LocationCategoryExclude03', @c_SQL_LocationCategoryExclude)    
   IF @c_SQL_LocationCategoryExclude > ''    
   BEGIN    
      IF CHARINDEX(',', @c_SQL_LocationCategoryExclude) > 0     
      BEGIN    
         SET @c_SQL_LocationCategoryExclude = ' AND LOC.LocationCategory NOT IN ('+ @c_SQL_LocationCategoryExclude + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_LocationCategoryExclude = ' AND LOC.LocationCategory <> ' + @c_SQL_LocationCategoryExclude     
      END                   
   END     
          
   SET @c_SQL_LocationCategoryInclude = [dbo].[fnc_BuildVariableString](@cpa_LocationCategoryInclude01
                                       , '@cpa_LocationCategoryInclude01', @c_SQL_LocationCategoryInclude)    
   SET @c_SQL_LocationCategoryInclude = [dbo].[fnc_BuildVariableString](@cpa_LocationCategoryInclude02
                                       , '@cpa_LocationCategoryInclude02', @c_SQL_LocationCategoryInclude)    
   SET @c_SQL_LocationCategoryInclude = [dbo].[fnc_BuildVariableString](@cpa_LocationCategoryInclude03
                                       , '@cpa_LocationCategoryInclude03', @c_SQL_LocationCategoryInclude)    
   IF ISNULL(RTRIM(@c_SQL_LocationCategoryInclude),'') <> ''    
   BEGIN    
      IF CHARINDEX(',', @c_SQL_LocationCategoryInclude) > 0     
      BEGIN    
         SET @c_SQL_LocationCategoryInclude = ' AND LOC.LocationCategory IN ('+ @c_SQL_LocationCategoryInclude + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_LocationCategoryInclude = ' AND LOC.LocationCategory = ' + @c_SQL_LocationCategoryInclude     
      END                     
   END    
          
   SET @c_SQL_LocationHandlingInclude = [dbo].[fnc_BuildVariableString](@cpa_LocationHandlingInclude01
                                       , '@cpa_LocationHandlingInclude01', @c_SQL_LocationHandlingInclude)         
   SET @c_SQL_LocationHandlingInclude = [dbo].[fnc_BuildVariableString](@cpa_LocationHandlingInclude02
                                       , '@cpa_LocationHandlingInclude02', @c_SQL_LocationHandlingInclude)    
   SET @c_SQL_LocationHandlingInclude = [dbo].[fnc_BuildVariableString](@cpa_LocationHandlingInclude03
                                       , '@cpa_LocationHandlingInclude03', @c_SQL_LocationHandlingInclude)    
   IF @c_SQL_LocationHandlingInclude > ''    
   BEGIN    
      IF CHARINDEX(',', @c_SQL_LocationHandlingInclude) > 0     
      BEGIN    
         SET @c_SQL_LocationHandlingInclude = ' AND LOC.LocationHandling IN ('+ @c_SQL_LocationHandlingInclude + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_LocationHandlingInclude = ' AND LOC.LocationHandling = ' + @c_SQL_LocationHandlingInclude     
      END                    
   END    
      
    
   SET @c_SQL_LocationHandlingExclude = [dbo].[fnc_BuildVariableString](@cpa_LocationHandlingExclude01
                                       , '@cpa_LocationHandlingExclude01', @c_SQL_LocationHandlingExclude)         
   SET @c_SQL_LocationHandlingExclude = [dbo].[fnc_BuildVariableString](@cpa_LocationHandlingExclude02
                                       , '@cpa_LocationHandlingExclude02', @c_SQL_LocationHandlingExclude)    
   SET @c_SQL_LocationHandlingExclude = [dbo].[fnc_BuildVariableString](@cpa_LocationHandlingExclude03
                                       , '@cpa_LocationHandlingExclude03', @c_SQL_LocationHandlingExclude)    
   IF @c_SQL_LocationHandlingExclude > ''    
   BEGIN    
      IF CHARINDEX(',', @c_SQL_LocationHandlingExclude) > 0     
      BEGIN    
         SET @c_SQL_LocationHandlingExclude = ' AND LOC.LocationHandling NOT IN ('+ @c_SQL_LocationHandlingExclude + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_LocationHandlingExclude = ' AND LOC.LocationHandling <> ' + @c_SQL_LocationHandlingExclude     
      END               
   END    

   SET @c_SQL_LocationFlagInclude = [dbo].[fnc_BuildVariableString](@cpa_LocationFlagInclude01
                                    , '@cpa_LocationFlagInclude01', @c_SQL_LocationFlagInclude)         
   SET @c_SQL_LocationFlagInclude = [dbo].[fnc_BuildVariableString](@cpa_LocationFlagInclude02
                                    , '@cpa_LocationFlagInclude02', @c_SQL_LocationFlagInclude)    
   SET @c_SQL_LocationFlagInclude = [dbo].[fnc_BuildVariableString](@cpa_LocationFlagInclude03
                                    , '@cpa_LocationFlagInclude03', @c_SQL_LocationFlagInclude)    
   IF @c_SQL_LocationFlagInclude > ''    
   BEGIN    
      IF CHARINDEX(',', @c_SQL_LocationFlagInclude) > 0     
      BEGIN    
         SET @c_SQL_LocationFlagInclude = ' AND LOC.LocationFlag IN ('+ @c_SQL_LocationFlagInclude + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_LocationFlagInclude = ' AND LOC.LocationFlag = ' + @c_SQL_LocationFlagInclude     
      END                   
   END    
          
   SET @c_SQL_LocationFlagExclude = [dbo].[fnc_BuildVariableString](@cpa_LocationFlagExclude01
                                    , '@cpa_LocationFlagExclude01', @c_SQL_LocationFlagExclude)         
   SET @c_SQL_LocationFlagExclude = [dbo].[fnc_BuildVariableString](@cpa_LocationFlagExclude02
                                    , '@cpa_LocationFlagExclude02', @c_SQL_LocationFlagExclude)    
   SET @c_SQL_LocationFlagExclude = [dbo].[fnc_BuildVariableString](@cpa_LocationFlagExclude03
                                    , '@cpa_LocationFlagExclude03', @c_SQL_LocationFlagExclude)    
   IF @c_SQL_LocationFlagExclude > ''    
   BEGIN    
      IF CHARINDEX(',', @c_SQL_LocationFlagExclude) > 0     
      BEGIN    
         SET @c_SQL_LocationFlagExclude = ' AND LOC.LocationFlag NOT IN ('+ @c_SQL_LocationFlagExclude + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_LocationFlagExclude = ' AND LOC.LocationFlag <> ' + @c_SQL_LocationFlagExclude     
      END               
   END    
                                      
   SET @c_SQL_LocLevelInclude = [dbo].[fnc_BuildVariableString](@npa_LocLevelInclude01
                              , '@npa_LocLevelInclude01', @c_SQL_LocLevelInclude)       
   SET @c_SQL_LocLevelInclude = [dbo].[fnc_BuildVariableString](@npa_LocLevelInclude02
                              , '@npa_LocLevelInclude02', @c_SQL_LocLevelInclude)    
   SET @c_SQL_LocLevelInclude = [dbo].[fnc_BuildVariableString](@npa_LocLevelInclude03
                              , '@npa_LocLevelInclude03', @c_SQL_LocLevelInclude)    
   SET @c_SQL_LocLevelInclude = [dbo].[fnc_BuildVariableString](@npa_LocLevelInclude04
                              , '@npa_LocLevelInclude04', @c_SQL_LocLevelInclude)    
   SET @c_SQL_LocLevelInclude = [dbo].[fnc_BuildVariableString](@npa_LocLevelInclude05
                              , '@npa_LocLevelInclude05', @c_SQL_LocLevelInclude)    
   SET @c_SQL_LocLevelInclude = [dbo].[fnc_BuildVariableString](@npa_LocLevelInclude06
                              , '@npa_LocLevelInclude06', @c_SQL_LocLevelInclude)    
   IF @c_SQL_LocLevelInclude > ''    
   BEGIN    
      IF CHARINDEX(',', @c_SQL_LocLevelInclude) > 0     
      BEGIN    
         SET @c_SQL_LocLevelInclude = ' AND LOC.LocLevel IN ('+ @c_SQL_LocLevelInclude + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_LocLevelInclude = ' AND LOC.LocLevel = ' + @c_SQL_LocLevelInclude     
      END                  
   END    
    
   SET @c_SQL_LocLevelExclude = [dbo].[fnc_BuildVariableString](@npa_LocLevelExclude01
                              , '@npa_LocLevelExclude01', @c_SQL_LocLevelExclude)       
   SET @c_SQL_LocLevelExclude = [dbo].[fnc_BuildVariableString](@npa_LocLevelExclude02
                              , '@npa_LocLevelExclude02', @c_SQL_LocLevelExclude)    
   SET @c_SQL_LocLevelExclude = [dbo].[fnc_BuildVariableString](@npa_LocLevelExclude03
                              , '@npa_LocLevelExclude03', @c_SQL_LocLevelExclude)    
   SET @c_SQL_LocLevelExclude = [dbo].[fnc_BuildVariableString](@npa_LocLevelExclude04
                              , '@npa_LocLevelExclude04', @c_SQL_LocLevelExclude)    
   SET @c_SQL_LocLevelExclude = [dbo].[fnc_BuildVariableString](@npa_LocLevelExclude05
                              , '@npa_LocLevelExclude05', @c_SQL_LocLevelExclude)    
   SET @c_SQL_LocLevelExclude = [dbo].[fnc_BuildVariableString](@npa_LocLevelExclude06
                              , '@npa_LocLevelExclude06', @c_SQL_LocLevelExclude)    
   IF @c_SQL_LocLevelExclude > ''    
   BEGIN    
      IF CHARINDEX(',', @c_SQL_LocLevelExclude) > 0     
      BEGIN    
         SET @c_SQL_LocLevelExclude = ' AND LOC.LocLevel NOT IN ('+ @c_SQL_LocLevelExclude + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_LocLevelExclude = ' AND LOC.LocLevel <> ' + @c_SQL_LocLevelExclude     
      END              
   END   
    
   SET @c_SQL_LocAisleInclude = [dbo].[fnc_BuildVariableString](@cpa_LocAisleInclude01
                              , '@cpa_LocAisleInclude01', @c_SQL_LocAisleInclude)       
   SET @c_SQL_LocAisleInclude = [dbo].[fnc_BuildVariableString](@cpa_LocAisleInclude02
                              , '@cpa_LocAisleInclude02', @c_SQL_LocAisleInclude)    
   SET @c_SQL_LocAisleInclude = [dbo].[fnc_BuildVariableString](@cpa_LocAisleInclude03
                              , '@cpa_LocAisleInclude03', @c_SQL_LocAisleInclude)    
   SET @c_SQL_LocAisleInclude = [dbo].[fnc_BuildVariableString](@cpa_LocAisleInclude04
                              , '@cpa_LocAisleInclude04', @c_SQL_LocAisleInclude)    
   SET @c_SQL_LocAisleInclude = [dbo].[fnc_BuildVariableString](@cpa_LocAisleInclude05
                              , '@cpa_LocAisleInclude05', @c_SQL_LocAisleInclude)    
   SET @c_SQL_LocAisleInclude = [dbo].[fnc_BuildVariableString](@cpa_LocAisleInclude06
                              , '@cpa_LocAisleInclude06', @c_SQL_LocAisleInclude)    
   IF @c_SQL_LocAisleInclude > ''    
   BEGIN    
      IF CHARINDEX(',', @c_SQL_LocAisleInclude) > 0     
      BEGIN    
         SET @c_SQL_LocAisleInclude = ' AND LOC.LocAisle IN ('+ @c_SQL_LocAisleInclude + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_LocAisleInclude = ' AND LOC.LocAisle = ' + @c_SQL_LocAisleInclude     
      END                  
   END 
    
   SET @c_SQL_LocAisleExclude = [dbo].[fnc_BuildVariableString](@cpa_LocAisleExclude01
                              , '@cpa_LocAisleExclude01', @c_SQL_LocAisleExclude)       
   SET @c_SQL_LocAisleExclude = [dbo].[fnc_BuildVariableString](@cpa_LocAisleExclude02
                              , '@cpa_LocAisleExclude02', @c_SQL_LocAisleExclude)    
   SET @c_SQL_LocAisleExclude = [dbo].[fnc_BuildVariableString](@cpa_LocAisleExclude03
                              , '@cpa_LocAisleExclude03', @c_SQL_LocAisleExclude)    
   SET @c_SQL_LocAisleExclude = [dbo].[fnc_BuildVariableString](@cpa_LocAisleExclude04
                              , '@cpa_LocAisleExclude04', @c_SQL_LocAisleExclude)    
   SET @c_SQL_LocAisleExclude = [dbo].[fnc_BuildVariableString](@cpa_LocAisleExclude05
                              , '@cpa_LocAisleExclude05', @c_SQL_LocAisleExclude)    
   SET @c_SQL_LocAisleExclude = [dbo].[fnc_BuildVariableString](@cpa_LocAisleExclude06
                              , '@cpa_LocAisleExclude06', @c_SQL_LocAisleExclude)    
   IF @c_SQL_LocAisleExclude > ''    
   BEGIN    
      IF CHARINDEX(',', @c_SQL_LocAisleExclude) > 0     
      BEGIN    
         SET @c_SQL_LocAisleExclude = ' AND LOC.LocAisle NOT IN ('+ @c_SQL_LocAisleExclude + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_LocAisleExclude = ' AND LOC.LocAisle <> ' + @c_SQL_LocAisleExclude     
      END              
   END    
                               
   SET @c_SQL_LocTypeRestriction = [dbo].[fnc_BuildVariableString](@cpa_LocationTypeRestriction01
                                 , '@cpa_LocationTypeRestriction01', @c_SQL_LocTypeRestriction)         
   SET @c_SQL_LocTypeRestriction = [dbo].[fnc_BuildVariableString](@cpa_LocationTypeRestriction02
                                 , '@cpa_LocationTypeRestriction02', @c_SQL_LocTypeRestriction)    
   SET @c_SQL_LocTypeRestriction = [dbo].[fnc_BuildVariableString](@cpa_LocationTypeRestriction03
                                 , '@cpa_LocationTypeRestriction03', @c_SQL_LocTypeRestriction)    
   IF @c_SQL_LocTypeRestriction > ''    
   BEGIN             
      IF CHARINDEX(',', @c_SQL_LocTypeRestriction) > 0     
      BEGIN    
         SET @c_SQL_LocTypeRestriction = ' AND LOC.LocationType IN ('+ @c_SQL_LocTypeRestriction + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_LocTypeRestriction = ' AND LOC.LocationType = ' + @c_SQL_LocTypeRestriction     
      END               
   END   

   SET @c_SQL_AreaKey = [dbo].[fnc_BuildVariableString](@cpa_AreaKey
                              , '@cpa_AreaKey', @c_SQL_AreaKey)    

   IF @cpa_AreaKey > ''
   BEGIN
      SET @c_SQL_Areakey = ' AND AREADETAIL.Areakey = ' + @c_SQL_Areakey
   END

   SET @c_SQL_AreaTypeExclude = [dbo].[fnc_BuildVariableString](@cpa_AreaTypeExclude01
                              , '@cpa_AreaTypeExclude01', @c_SQL_AreaTypeExclude)         
   SET @c_SQL_AreaTypeExclude = [dbo].[fnc_BuildVariableString](@cpa_AreaTypeExclude02
                              , '@cpa_AreaTypeExclude02', @c_SQL_AreaTypeExclude)    
   SET @c_SQL_AreaTypeExclude = [dbo].[fnc_BuildVariableString](@cpa_AreaTypeExclude03
                              , '@cpa_AreaTypeExclude03', @c_SQL_AreaTypeExclude)    
   IF @c_SQL_AreaTypeExclude > ''    
   BEGIN    
      IF CHARINDEX(',', @c_SQL_AreaTypeExclude) > 0     
      BEGIN    
         SET @c_SQL_AreaTypeExclude = ' AND AREADETAIL.AreaKey NOT IN ('+ @c_SQL_AreaTypeExclude + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_AreaTypeExclude = ' AND AREADETAIL.AreaKey = ' + @c_SQL_AreaTypeExclude     
      END                    
   END  

   SET @c_SQL_PutawayZone  = [dbo].[fnc_BuildVariableString](@cpa_PutawayZone01, '@cpa_PutawayZone01', @c_SQL_PutawayZone)    
   SET @c_SQL_PutawayZone  = [dbo].[fnc_BuildVariableString](@cpa_PutawayZone02, '@cpa_PutawayZone02', @c_SQL_PutawayZone)    
   SET @c_SQL_PutawayZone  = [dbo].[fnc_BuildVariableString](@cpa_PutawayZone03, '@cpa_PutawayZone03', @c_SQL_PutawayZone)    
   SET @c_SQL_PutawayZone  = [dbo].[fnc_BuildVariableString](@cpa_PutawayZone04, '@cpa_PutawayZone04', @c_SQL_PutawayZone)    
   SET @c_SQL_PutawayZone  = [dbo].[fnc_BuildVariableString](@cpa_PutawayZone05, '@cpa_PutawayZone05', @c_SQL_PutawayZone)    

   IF @c_SQL_PutawayZone > ''    
   BEGIN    
      IF CHARINDEX(',', @c_SQL_PutawayZone) > 0     
      BEGIN    
         SET @c_SQL_PutawayZone = ' AND LOC.LocationCategory NOT IN ('+ @c_SQL_PutawayZone + ') '    
      END    
      ELSE     
      BEGIN    
         SET @c_SQL_PutawayZone = ' AND LOC.LocationCategory <> ' + @c_SQL_PutawayZone     
      END                   
   END   
      
   IF '1'  IN (@cpa_DimensionRestriction01,@cpa_DimensionRestriction02,@cpa_DimensionRestriction03
              ,@cpa_DimensionRestriction04,@cpa_DimensionRestriction05,@cpa_DimensionRestriction06
               ) OR
      '11' IN (@cpa_DimensionRestriction01,@cpa_DimensionRestriction02,@cpa_DimensionRestriction03
              ,@cpa_DimensionRestriction04,@cpa_DimensionRestriction05,@cpa_DimensionRestriction06
               ) 
   BEGIN
      SET @c_SQL_MaxPallet = ' AND LOC.CubicCapacity > 0.00'
   END

   IF '2'  IN (@cpa_DimensionRestriction01,@cpa_DimensionRestriction02,@cpa_DimensionRestriction03
              ,@cpa_DimensionRestriction04,@cpa_DimensionRestriction05,@cpa_DimensionRestriction06
               )
   BEGIN
      SET @c_SQL_MaxPallet = ' AND LOC.Length > 0.00 AND LOC.Width > 0.00 AND AND LOC.Height > 0.00'
   END

   IF '3'  IN (@cpa_DimensionRestriction01,@cpa_DimensionRestriction02,@cpa_DimensionRestriction03
              ,@cpa_DimensionRestriction04,@cpa_DimensionRestriction05,@cpa_DimensionRestriction06
               ) OR
      '12' IN (@cpa_DimensionRestriction01,@cpa_DimensionRestriction02,@cpa_DimensionRestriction03
              ,@cpa_DimensionRestriction04,@cpa_DimensionRestriction05,@cpa_DimensionRestriction06
               ) 
   BEGIN
      SET @c_SQL_MaxPallet = ' AND LOC.WeightCapacity > 0.00'
   END


   IF '4' IN (@cpa_LocationStateRestriction01,@cpa_LocationStateRestriction02,@cpa_LocationStateRestriction03) OR
      '5' IN (@cpa_LocationStateRestriction01,@cpa_LocationStateRestriction02,@cpa_LocationStateRestriction03) OR
      '6' IN (@cpa_LocationStateRestriction01,@cpa_LocationStateRestriction02,@cpa_LocationStateRestriction03) OR
      '7' IN (@cpa_LocationStateRestriction01,@cpa_LocationStateRestriction02,@cpa_LocationStateRestriction03)  
   BEGIN
      SET @c_SQL_MaxPallet = ' AND LOC.MaxPallet > 0'
   END

   IF '13' IN (@cpa_LocationStateRestriction01,@cpa_LocationStateRestriction02,@cpa_LocationStateRestriction03)  
   BEGIN
      SET @c_SQL_ABC = ' AND LOC.ABC > '''''
   END

   IF '17' IN (@cpa_LocationStateRestriction01,@cpa_LocationStateRestriction02,@cpa_LocationStateRestriction03)  
   BEGIN
      SET @c_SQL_HostWHCode = ' AND LOC.HostWHCode > '''''
   END

   SET @c_SQL = @c_SQL
              + @c_SQL_LocationTypeExclude        
              + @c_SQL_LocationCategoryInclude    
              + @c_SQL_LocationCategoryExclude    
              + @c_SQL_LocationHandlingInclude    
              + @c_SQL_LocationHandlingExclude    
              + @c_SQL_LocationFlagInclude        
              + @c_SQL_LocationFlagExclude        
              + @c_SQL_LocLevelInclude            
              + @c_SQL_LocLevelExclude            
              + @c_SQL_LocAisleInclude            
              + @c_SQL_LocAisleExclude             
              + @c_SQL_LocTypeRestriction 
              + @c_SQL_AreaKey
              + @c_SQL_AreaTypeExclude        
              + @c_SQL_Putawayzone  
              + @c_SQL_MaxPallet
              + @c_SQL_ABC
              + @c_SQL_HostWHCode
   QUIT_FUNC:
   RETURN @c_SQL
END
GO
GRANT SELECT  ON [dbo].[fnc_GetBookingDescByGrpFloor] TO nSQL 
GO