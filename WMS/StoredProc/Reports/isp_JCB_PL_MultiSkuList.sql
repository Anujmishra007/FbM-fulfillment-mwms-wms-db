SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/               
/* Copyright:                                                                 */               
/* Purpose:                                                                   */               
/* JCB Picking of Pallets Multi SKU - Get SKU LIST                            */               
/* Modifications log:                                                         */               
/*                                                                            */               
/* Date           Rev  Author     Purposes                                    */               
/* 27-11-2025     1.0  AGM046                                                 */               
/*                                                                            */               
/******************************************************************************/               
                
CREATE OR ALTER PROCEDURE [dbo].[isp_JCB_PL_MultiSkuList]                     
(  
   @c_Sparm1            NVARCHAR(250) = NULL,   -- Storerkey          
   @c_Sparm2            NVARCHAR(250) = NULL,   -- FACILITY         
   @c_Sparm3            NVARCHAR(250) = NULL,   -- ID / DropId       
   @c_Sparm4            NVARCHAR(250) = NULL,   -- Taskdetailkey        
   @c_Sparm5            NVARCHAR(250) = NULL,            
   @c_Sparm6            NVARCHAR(250) = NULL,            
   @c_Sparm7            NVARCHAR(250) = NULL,            
   @c_Sparm8            NVARCHAR(250) = NULL,            
   @c_Sparm9            NVARCHAR(250) = NULL,            
   @c_Sparm10           NVARCHAR(250) = NULL,      
   @b_debug             INT = 0                       
)                    

AS
                    
BEGIN                    
   SET NOCOUNT ON               
   SET ANSI_NULLS OFF              
   SET QUOTED_IDENTIFIER OFF               
   SET CONCAT_NULL_YIELDS_NULL OFF              

   DECLARE	@c_StorerKey         NVARCHAR(15),
            @c_Facility          NVARCHAR(5),			
			@c_TaskDetailKey     NVARCHAR(10),
			@c_DropID            NVARCHAR(20),			          	     	          
			@n_copy				 INT,
			@c_sql			     NVARCHAR(MAX), 
            --
			@n_TotalRecord      INT,             
            @n_TotalPage        INT,             
            @n_CurrentPage      INT,             
            @n_PageSize         INT,             
            @n_loopno           INT,             
            @c_ExecStatements   NVARCHAR(4000),  
            @c_ExecArguments    NVARCHAR(4000) 
			--						
   DECLARE  @d_Trace_StartTime  DATETIME, 
		    @d_Trace_EndTime    DATETIME,
		    @c_Trace_ModuleName NVARCHAR(20), 
		    @d_Trace_Step1      DATETIME, 
		    @c_Trace_Step1      NVARCHAR(20),
		    @c_UserName         NVARCHAR(20),
		    @c_billtokey        NVARCHAR(20),
		    @c_notes            NVARCHAR(250)   
            --			
   DECLARE  @c_SKU01            NVARCHAR(80),
			@c_SKU02            NVARCHAR(80),
			@c_SKU03            NVARCHAR(80),
			@c_SKU04            NVARCHAR(80),
			@c_SKU05            NVARCHAR(80),
			@c_SKU06            NVARCHAR(80),
			@c_SKU07            NVARCHAR(80),
			@c_SKU08            NVARCHAR(80),
			@c_SKU09            NVARCHAR(80),
			@c_SKU10            NVARCHAR(80),
			@c_SKU11            NVARCHAR(80),
			@c_SKU12            NVARCHAR(80),
		    --			
			@c_SKUQTY01         INT,
			@c_SKUQTY02         INT,
			@c_SKUQTY03         INT,
			@c_SKUQTY04         INT,
			@c_SKUQTY05         INT,
			@c_SKUQTY06         INT,
			@c_SKUQTY07         INT,
			@c_SKUQTY08         INT,
			@c_SKUQTY09         INT,
			@c_SKUQTY10         INT,
			@c_SKUQTY11         INT,
			@c_SKUQTY12         INT
		
   -- Set label properties     
   SET @c_SQL = ''         
   SET @n_CurrentPage = 1  
   SET @n_TotalPage = 1    
   SET @n_PageSize = 12        
   SET @n_loopno = 1       	
   
   -- Set Trace properties		
   SET @d_Trace_StartTime = GETDATE()
   SET @c_Trace_ModuleName = ''
   SET @n_copy = 1       
     	 
   CREATE TABLE [#Result] (           
      [ID]    [INT] IDENTITY(1,1) NOT NULL,                          
      [Col01] [NVARCHAR] (80) NULL,            
      [Col02] [NVARCHAR] (80) NULL,            
      [Col03] [NVARCHAR] (80) NULL,            
      [Col04] [NVARCHAR] (80) NULL,            
      [Col05] [NVARCHAR] (80) NULL,            
      [Col06] [NVARCHAR] (80) NULL,            
      [Col07] [NVARCHAR] (80) NULL,            
      [Col08] [NVARCHAR] (80) NULL,            
      [Col09] [NVARCHAR] (80) NULL,            
      [Col10] [NVARCHAR] (80) NULL,            
      [Col11] [NVARCHAR] (80) NULL,            
      [Col12] [NVARCHAR] (80) NULL,            
      [Col13] [NVARCHAR] (80) NULL,            
      [Col14] [NVARCHAR] (80) NULL,            
      [Col15] [NVARCHAR] (80) NULL,            
      [Col16] [NVARCHAR] (80) NULL,            
      [Col17] [NVARCHAR] (80) NULL,            
      [Col18] [NVARCHAR] (80) NULL,            
      [Col19] [NVARCHAR] (80) NULL,            
      [Col20] [NVARCHAR] (80) NULL,            
      [Col21] [NVARCHAR] (80) NULL,            
      [Col22] [NVARCHAR] (80) NULL,            
      [Col23] [NVARCHAR] (80) NULL,            
      [Col24] [NVARCHAR] (80) NULL,            
      [Col25] [NVARCHAR] (80) NULL,            
      [Col26] [NVARCHAR] (80) NULL,            
      [Col27] [NVARCHAR] (80) NULL,            
      [Col28] [NVARCHAR] (80) NULL,            
      [Col29] [NVARCHAR] (80) NULL,            
      [Col30] [NVARCHAR] (80) NULL,            
      [Col31] [NVARCHAR] (80) NULL,            
      [Col32] [NVARCHAR] (80) NULL,            
      [Col33] [NVARCHAR] (80) NULL,            
      [Col34] [NVARCHAR] (80) NULL,            
      [Col35] [NVARCHAR] (80) NULL,            
      [Col36] [NVARCHAR] (80) NULL,            
      [Col37] [NVARCHAR] (80) NULL,            
      [Col38] [NVARCHAR] (80) NULL,            
      [Col39] [NVARCHAR] (80) NULL,            
      [Col40] [NVARCHAR] (80) NULL,            
      [Col41] [NVARCHAR] (80) NULL,            
      [Col42] [NVARCHAR] (80) NULL,            
      [Col43] [NVARCHAR] (80) NULL,            
      [Col44] [NVARCHAR] (80) NULL,            
      [Col45] [NVARCHAR] (80) NULL,            
      [Col46] [NVARCHAR] (80) NULL,            
      [Col47] [NVARCHAR] (80) NULL,            
      [Col48] [NVARCHAR] (80) NULL,            
      [Col49] [NVARCHAR] (80) NULL,            
      [Col50] [NVARCHAR] (80) NULL,            
      [Col51] [NVARCHAR] (80) NULL,            
      [Col52] [NVARCHAR] (80) NULL,            
      [Col53] [NVARCHAR] (80) NULL,            
      [Col54] [NVARCHAR] (80) NULL,            
      [Col55] [NVARCHAR] (80) NULL,            
      [Col56] [NVARCHAR] (80) NULL,            
      [Col57] [NVARCHAR] (80) NULL,            
      [Col58] [NVARCHAR] (80) NULL,            
      [Col59] [NVARCHAR] (80) NULL,            
      [Col60] [NVARCHAR] (80) NULL             
   )          
     
   -- Temporal Table for list
   DECLARE @TEMPDATA TABLE 
   (                       
      [ID]		[INT] IDENTITY(1,1) NOT NULL, 		           
      DropID          NVARCHAR(20),               
      SKU			  NVARCHAR(20) NULL,            
      Qty			  INT NULL                     	           
   ) 
				
   -- Get data from parameters
   SET @c_StorerKey    = @c_Sparm1
   SET @c_Facility     = @c_Sparm2
   SET @c_DropID        = @c_Sparm3
   SET @c_TaskDetailKey = @c_Sparm4

   -- 
   INSERT INTO @TEMPDATA	       		
   SELECT 
      DropID, 
	  SKU, 
	  Qty 
   FROM (		
      SELECT 
	     lli.Id AS DropID,
		 lli.Sku, 
		 SUM(lli.Qty) AS Qty
      FROM dbo.LOTxLOCxID lli WITH (NOLOCK)
      WHERE lli.storerkey = @c_StorerKey
         AND lli.qty > 0
		 --AND lli.loc LIKE 'ESM%'
		 AND lli.Id IS NOT NULL
		 AND lli.Id <> ''
		 AND LLI.ID = @c_DropID
	  GROUP BY 
	     lli.Id,
		 lli.Sku
   ) T1 
   ORDER BY Qty DESC
						  
   --Get @n_TotalRecord
   SELECT @n_TotalRecord = COUNT(0) FROM @TEMPDATA

   --Get @n_TotalPage
   SELECT @n_TotalPage = Ceiling(1.0*@n_TotalRecord/@n_PageSize)

   -- Start build te label 
   WHILE @n_loopno <= @n_TotalRecord
   BEGIN 
      --Get generic fields
	  IF NOT EXISTS(SELECT 1 FROM #Result WHERE Col02 = @n_CurrentPage)
	  BEGIN
         INSERT INTO #Result 
		 (
			Col01,
		    Col02,
			Col03
	     )
		 SELECT 
		    DropID,					       							
            @n_CurrentPage,
            @n_TotalPage		
         FROM @TEMPDATA
		 WHERE ID = @n_loopno
      END
			
      -- Prepare SKU data, 12 SKUs per label
      --
      -- SKU 1
      IF @n_loopno % @n_PageSize = 1
      BEGIN
         SELECT
            @c_SKU01    = SKU,
            @c_SKUQTY01 = Qty
         FROM @TEMPDATA
         WHERE ID = @n_loopno
      END

      -- SKU 2
      IF @n_loopno % @n_PageSize = 2
      BEGIN
         SELECT
            @c_SKU02    = SKU,
            @c_SKUQTY02 = Qty
         FROM @TEMPDATA
         WHERE ID = @n_loopno
      END

      -- SKU 3
      IF @n_loopno % @n_PageSize = 3
      BEGIN
         SELECT
            @c_SKU03    = SKU,
            @c_SKUQTY03 = Qty
         FROM @TEMPDATA
         WHERE ID = @n_loopno
      END

      -- SKU 4
      IF @n_loopno % @n_PageSize = 4
      BEGIN
         SELECT
            @c_SKU04    = SKU,
            @c_SKUQTY04 = Qty
         FROM @TEMPDATA
         WHERE ID = @n_loopno
      END

      -- SKU 5
      IF @n_loopno % @n_PageSize = 5
      BEGIN
         SELECT
            @c_SKU05    = SKU,
            @c_SKUQTY05 = Qty
         FROM @TEMPDATA
         WHERE ID = @n_loopno
      END

      -- SKU 6
      IF @n_loopno % @n_PageSize = 6
      BEGIN
         SELECT
            @c_SKU06    = SKU,
            @c_SKUQTY06 = Qty
         FROM @TEMPDATA
         WHERE ID = @n_loopno
      END

      -- SKU 7
      IF @n_loopno % @n_PageSize = 7
      BEGIN
         SELECT
            @c_SKU07    = SKU,
            @c_SKUQTY07 = Qty
         FROM @TEMPDATA
         WHERE ID = @n_loopno
      END

      -- SKU 8
      IF @n_loopno % @n_PageSize = 8
      BEGIN
         SELECT
            @c_SKU08    = SKU,
            @c_SKUQTY08 = Qty
         FROM @TEMPDATA
         WHERE ID = @n_loopno
      END

      -- SKU 9
      IF @n_loopno % @n_PageSize = 9
      BEGIN
         SELECT
            @c_SKU09    = SKU,
            @c_SKUQTY09 = Qty
         FROM @TEMPDATA
         WHERE ID = @n_loopno
      END

      -- SKU 10
      IF @n_loopno % @n_PageSize = 10
      BEGIN
         SELECT
            @c_SKU10    = SKU,
            @c_SKUQTY10 = Qty
         FROM @TEMPDATA
         WHERE ID = @n_loopno
      END

      -- SKU 11
      IF @n_loopno % @n_PageSize = 11
      BEGIN
         SELECT
            @c_SKU11    = SKU,
            @c_SKUQTY11 = Qty
         FROM @TEMPDATA
         WHERE ID = @n_loopno
      END

      -- SKU 12
      IF @n_loopno % @n_PageSize = 0
      BEGIN
         SELECT
            @c_SKU12    = SKU,
            @c_SKUQTY12 = Qty
         FROM @TEMPDATA
         WHERE ID = @n_loopno
      END

      -- Update SKU data to current row
      IF @n_loopno % @n_PageSize = 0
         OR @n_loopno >= @n_TotalRecord
      BEGIN
         UPDATE #Result
         SET
            Col05 = @c_SKU01, Col06 = @c_SKUQTY01,
            Col07 = @c_SKU02, Col08 = @c_SKUQTY02,
            Col09 = @c_SKU03, Col10 = @c_SKUQTY03,
            Col11 = @c_SKU04, Col12 = @c_SKUQTY04,
            Col13 = @c_SKU05, Col14 = @c_SKUQTY05,
            Col15 = @c_SKU06, Col16 = @c_SKUQTY06,
            Col17 = @c_SKU07, Col18 = @c_SKUQTY07,
            Col19 = @c_SKU08, Col20 = @c_SKUQTY08,
            Col21 = @c_SKU09, Col22 = @c_SKUQTY09,
            Col23 = @c_SKU10, Col24 = @c_SKUQTY10,
            Col25 = @c_SKU11, Col26 = @c_SKUQTY11,
            Col27 = @c_SKU12, Col28 = @c_SKUQTY12
         WHERE Col02 = @n_CurrentPage

         SELECT
            @c_SKU01 = NULL, @c_SKUQTY01 = NULL,
            @c_SKU02 = NULL, @c_SKUQTY02 = NULL,
            @c_SKU03 = NULL, @c_SKUQTY03 = NULL,
            @c_SKU04 = NULL, @c_SKUQTY04 = NULL,
            @c_SKU05 = NULL, @c_SKUQTY05 = NULL,
            @c_SKU06 = NULL, @c_SKUQTY06 = NULL,
            @c_SKU07 = NULL, @c_SKUQTY07 = NULL,
            @c_SKU08 = NULL, @c_SKUQTY08 = NULL,
            @c_SKU09 = NULL, @c_SKUQTY09 = NULL,
            @c_SKU10 = NULL, @c_SKUQTY10 = NULL,
            @c_SKU11 = NULL, @c_SKUQTY11 = NULL,
            @c_SKU12 = NULL, @c_SKUQTY12 = NULL

         SET @n_CurrentPage = @n_CurrentPage + 1
      END

      SET @n_loopno = @n_loopno + 1
      END

      --
      WHILE @n_copy > 1
      BEGIN
         INSERT INTO #Result (
            Col01, Col02, Col03, Col04, Col05, Col06, Col07, Col08, Col09,
            Col10, Col11, Col12, Col13, Col14, Col15, Col16, Col17, Col18,
            Col19, Col20, Col21, Col22, Col23, Col24, Col25, Col26, Col27,
            Col28, Col29, Col30, Col31, Col32, Col33, Col34, Col35, Col36,
            Col37, Col38, Col39, Col40, Col41, Col42, Col43, Col44, Col45,
            Col46, Col47, Col48, Col49, Col50, Col51, Col52, Col53, Col54,
            Col55, Col56, Col57, Col58, Col59, Col60
         )
         SELECT
            Col01, Col02, Col03, Col04, Col05, Col06, Col07, Col08, Col09,
            Col10, Col11, Col12, Col13, Col14, Col15, Col16, Col17, Col18,
            Col19, Col20, Col21, Col22, Col23, Col24, Col25, Col26, Col27,
            Col28, Col29, Col30, Col31, Col32, Col33, Col34, Col35, Col36,
            Col37, Col38, Col39, Col40, Col41, Col42, Col43, Col44, Col45,
            Col46, Col47, Col48, Col49, Col50, Col51, Col52, Col53, Col54,
            Col55, Col56, Col57, Col58, Col59, Col60
         FROM #RESULT
         WHERE ID = 1

         SET @n_copy = @n_copy - 1
      END 

   IF @b_debug=1      
   BEGIN        
      PRINT @c_SQL        
   END      
   IF @b_debug=1      
   BEGIN      
      SELECT * FROM #Result (nolock)      
   END      

EXIT_SP:  

   SET @d_Trace_EndTime = GETDATE()
   SET @c_UserName = SUSER_SNAME()

   EXEC isp_InsertTraceInfo 
      @c_TraceCode = 'BARTENDER',
      @c_TraceName = 'isp_JCB_PL_MultiSkuList',
      @c_starttime = @d_Trace_StartTime,
      @c_endtime = @d_Trace_EndTime,
      @c_step1 = @c_UserName,
      @c_step2 = '',
      @c_step3 = '',
      @c_step4 = '',
      @c_step5 = '',
      @c_col1 = @c_Sparm1, 
      @c_col2 = @c_Sparm2,
      @c_col3 = @c_Sparm3,
      @c_col4 = @c_Sparm4,
      @c_col5 = @c_Sparm5,
      @b_Success = 1,
      @n_Err = 0,
      @c_ErrMsg = ''            
 
SELECT * FROM #result WITH (NOLOCK)
                                
END -- procedure
