if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_BT_Bartender_CN_RETAILLBL]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_BT_Bartender_CN_RETAILLBL]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/******************************************************************************/                 
/* Copyright: IDS                                                             */                 
/* Purpose: isp_BT_Bartender_CN_RETAILLBL                                     */                 
/*                                                                            */                 
/* Modifications log:                                                         */                 
/*                                                                            */                 
/* Date       Rev  Author     Purposes                                        */                 
/* 2016-11-18 1.0  CSCHONG    Created (WMS-2129)                              */ 
/* 2021-03-22 1.1  CSCHONG    Remove hardcode DB name (CS01)                  */
/******************************************************************************/                
                  
CREATE PROC [dbo].[isp_BT_Bartender_CN_RETAILLBL]                      
(  @c_Sparm01            NVARCHAR(250),              
   @c_Sparm02            NVARCHAR(250),              
   @c_Sparm03            NVARCHAR(250),              
   @c_Sparm04            NVARCHAR(250),              
   @c_Sparm05            NVARCHAR(250),              
   @c_Sparm06            NVARCHAR(250),              
   @c_Sparm07            NVARCHAR(250),              
   @c_Sparm08            NVARCHAR(250),              
   @c_Sparm09            NVARCHAR(250),              
   @c_Sparm10            NVARCHAR(250),        
   @b_debug              INT = 0                         
)                      
AS                      
BEGIN                      
   SET NOCOUNT ON                 
   SET ANSI_NULLS OFF                
   SET QUOTED_IDENTIFIER OFF                 
   SET CONCAT_NULL_YIELDS_NULL OFF                
 --  SET ANSI_WARNINGS OFF                    --CS01           
                              
   DECLARE                  
      @c_labelno         NVARCHAR(20),                    
      @c_pickslipno      NVARCHAR(20),                         
      @n_intFlag         INT,     
      @n_CntRec          INT,    
      @c_SQL             NVARCHAR(4000),        
      @c_SQLSORT         NVARCHAR(4000),        
      @c_SQLJOIN         NVARCHAR(4000),
      @n_CntExtOrd       INT,
      @c_col02           NVARCHAR(20),
      @c_col50           NVARCHAR(30),
      @c_Col52           NVARCHAR(60),
      @c_Col53           NVARCHAR(60),
      @c_Col56           NVARCHAR(60),
      @c_col57			 NVARCHAR(60),
      @n_TTLQty          INT  ,
      @c_col55           NVARCHAR(60) ,
      @c_OHNOtes2        NVARCHAR(80)  ,
      @n_Notes2			 NVARCHAR(400) 
    
  DECLARE @d_Trace_StartTime   DATETIME,   
           @d_Trace_EndTime    DATETIME,  
           @c_Trace_ModuleName NVARCHAR(20),   
           @d_Trace_Step1      DATETIME,   
           @c_Trace_Step1      NVARCHAR(20),  
           @c_UserName         NVARCHAR(20),
           @c_brnd             NVARCHAR(60),
           @c_brnd01           NVARCHAR(60),         
			  @c_brnd02           NVARCHAR(60),         
			  @c_brnd03           NVARCHAR(60),        
		     @c_brnd04           NVARCHAR(60),       
			  @c_brnd05           NVARCHAR(60), 
			  @c_brnd06           NVARCHAR(60),         
			  @c_brnd07           NVARCHAR(60),         
			  @c_brnd08           NVARCHAR(60),        
		     @c_brnd09           NVARCHAR(60),       
			  @c_brnd10           NVARCHAR(60), 
			  @c_Gndr             NVARCHAR(60),     
			  @c_Gndr01           NVARCHAR(60),        
			  @c_Gndr02           NVARCHAR(60),         
			  @c_Gndr03           NVARCHAR(60),        
			  @c_Gndr04           NVARCHAR(60),         
			  @c_Gndr05           NVARCHAR(60),
			  @c_Gndr06           NVARCHAR(60),        
			  @c_Gndr07           NVARCHAR(60),         
			  @c_Gndr08           NVARCHAR(60),        
			  @c_Gndr09           NVARCHAR(60),         
			  @c_Gndr10           NVARCHAR(60),
			  @c_SBU              NVARCHAR(60),
			  @c_SBU01            NVARCHAR(60),
			  @c_SBU02            NVARCHAR(60),
			  @c_SBU03            NVARCHAR(60),
			  @c_SBU04            NVARCHAR(60),
			  @c_SBU05            NVARCHAR(60),
			  @c_SBU06            NVARCHAR(60),
			  @c_SBU07            NVARCHAR(60),
			  @c_SBU08            NVARCHAR(60),
			  @c_SBU09            NVARCHAR(60),
			  @c_SBU10            NVARCHAR(60),
			  @c_Dept             NVARCHAR(60),
			  @c_Dept01           NVARCHAR(60),
			  @c_Dept02           NVARCHAR(60),
			  @c_Dept03           NVARCHAR(60),
			  @c_Dept04           NVARCHAR(60),
			  @c_Dept05           NVARCHAR(60),
			  @c_Dept06           NVARCHAR(60),
			  @c_Dept07           NVARCHAR(60),
			  @c_Dept08           NVARCHAR(60),
			  @c_Dept09           NVARCHAR(60),
			  @c_Dept10           NVARCHAR(60),
			  @c_SY               NVARCHAR(60),
			  @c_SY01             NVARCHAR(60),
			  @c_SY02             NVARCHAR(60),
			  @c_SY03             NVARCHAR(60),
			  @c_SY04             NVARCHAR(60),
			  @c_SY05             NVARCHAR(60),
			  @c_SY06             NVARCHAR(60),
			  @c_SY07             NVARCHAR(60),
			  @c_SY08             NVARCHAR(60),
			  @c_SY09             NVARCHAR(60),
			  @c_SY10             NVARCHAR(60),
			  @c_Class            NVARCHAR(60),
			  @c_Class01          NVARCHAR(60),
			  @c_Class02          NVARCHAR(60),
			  @c_Class03          NVARCHAR(60),
			  @c_Class04          NVARCHAR(60),
			  @c_Class05          NVARCHAR(60),
			  @c_Class06          NVARCHAR(60),
			  @c_Class07          NVARCHAR(60),
			  @c_Class08          NVARCHAR(60),
			  @c_Class09          NVARCHAR(60),
			  @c_Class10          NVARCHAR(60),
			  @c_Item             NVARCHAR(60),
			  @c_Item01           NVARCHAR(60),
			  @c_Item02          NVARCHAR(60),
			  @c_Item03           NVARCHAR(60),
			  @c_Item04           NVARCHAR(60),
			  @c_Item05           NVARCHAR(60),
			  @c_Item06           NVARCHAR(60),
			  @c_Item07          NVARCHAR(60),
			  @c_Item08           NVARCHAR(60),
			  @c_Item09           NVARCHAR(60),
			  @c_Item10           NVARCHAR(60),
			  @c_LOC              NVARCHAR(60),
			  @c_LOC01            NVARCHAR(60),
			  @c_LOC02            NVARCHAR(60),
			  @c_LOC03            NVARCHAR(60),
			  @c_LOC04            NVARCHAR(60),
			  @c_LOC05            NVARCHAR(60),
			  @c_LOC06            NVARCHAR(60),
			  @c_LOC07            NVARCHAR(60),
			  @c_LOC08            NVARCHAR(60),
			  @c_LOC09            NVARCHAR(60),
			  @c_LOC10            NVARCHAR(60),
			  @c_Qty              NVARCHAR(60),
			  @c_Qty01            NVARCHAR(60),
			  @c_Qty02            NVARCHAR(60),
			  @c_Qty03            NVARCHAR(60),
			  @c_Qty04            NVARCHAR(60),
			  @c_Qty05            NVARCHAR(60),
			  @c_Qty06            NVARCHAR(60),
			  @c_Qty07            NVARCHAR(60),
			  @c_Qty08            NVARCHAR(60),
			  @c_Qty09            NVARCHAR(60),
			  @c_Qty10            NVARCHAR(60),
			  @c_PKQty              NVARCHAR(60),
			  @c_PKQty01            NVARCHAR(60),
			  @c_PKQty02            NVARCHAR(60),
			  @c_PKQty03            NVARCHAR(60),
			  @c_PKQty04            NVARCHAR(60),
			  @c_PKQty05            NVARCHAR(60),
			  @c_PKQty06            NVARCHAR(60),
			  @c_PKQty07            NVARCHAR(60),
			  @c_PKQty08            NVARCHAR(60),
			  @c_PKQty09            NVARCHAR(60),
			  @c_PKQty10            NVARCHAR(60),
			  @n_TTLpage          INT,        
           @n_CurrentPage      INT,
           @n_MaxLine          INT  ,
           @c_LLIId            NVARCHAR(80) ,
           @c_storerkey        NVARCHAR(20) ,
           @n_skuqty           INT ,
           @n_RecCnt           INT,
           @c_ExecStatements    NVARCHAR(4000),   
           @c_ExecArguments     NVARCHAR(4000)   
  
   SET @d_Trace_StartTime = GETDATE()  
   SET @c_Trace_ModuleName = ''  
        
    -- SET RowNo = 0             
    SET @c_SQL = ''     
    SET @n_CurrentPage = 1
    SET @n_TTLpage =1     
    SET @n_MaxLine = 10   
    SET @n_CntRec = 1  
    SET @n_intFlag = 1   
    SET @n_RecCnt = 1    
              
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
     
     
      CREATE TABLE [#TEMPBTSKU] (                   
      [ID]          [INT] IDENTITY(1,1) NOT NULL,  
      [labelno]     [NVARCHAR] (20) NULL,                                    
      [Brnd]        [NVARCHAR] (60) NULL,  
      [Gndr]        [NVARCHAR] (60) NULL,                  
      [SBU]         [NVARCHAR] (60) NULL, 
      [Dept]        [NVARCHAR] (60) NULL,
      [SY]          [NVARCHAR] (60) NULL,
      [Class]       [NVARCHAR] (60) NULL,
      [Item]        [NVARCHAR] (60) NULL,
  [Loc]         [NVARCHAR] (60) NULL,
      [Qty]         INT NULL,
      [PKQty]		INT NULL,
      [Retrieve]    [NVARCHAR] (1) default 'N')         
  	        
  SET @c_SQLJOIN = +' SELECT DISTINCT substring(orders.BilltoKey,3,len(orders.BilltoKey)-2) +''-'' + orders.c_contact2,'''', '  --2
             + ' ORDERS.BuyerPO,ISNULL(RTRIM(PADET.Labelno),''''),'''','+ CHAR(13)      --5      
             + ' '''','''','''','''','''','     --10  
             + ' '''','''','''','''','''','     --15  
             + ' '''','''','''','''','''','     --20       
  + CHAR(13) +      
             + ' '''','''','''','''','''','''','''','''','''','''','  --30  
             + ' '''','''','''','''','''','''','''','''','''','''','   --40       
             + ' '''','''','''','''','''','''','''','''','''',PIDET.caseid, '  --50       
             + ' PIDET.caseid,'''',WD.Wavekey,ORDERS.Sectionkey,CL.code,'''','''',CONVERT(varchar(100), GETDATE(), 20),PAH.Pickslipno,''O'' '   --60          
             + CHAR(13) +            
          -- + ' FROM RECEIPT REC WITH (NOLOCK)'       
             + ' FROM PACKHEADER PAH WITH (NOLOCK)'   
             + ' JOIN PACKDETAIL PADET WITH (NOLOCK) ON PAH.Pickslipno = PADET.Pickslipno'
             + ' JOIN PICKDETAIL PIDET WITH (NOLOCK) ON PIDET.CaseId = PADET.Labelno AND PIDET.SKU = PADET.SKU'   +CHAR(13)
             + ' JOIN ORDERDETAIL ORDDET WITH (NOLOCK) ON ORDDET.Orderkey = PIDET.Orderkey '
             + '  AND ORDDET.Orderlinenumber=PIDET.Orderlinenumber'   +CHAR(13)
             + '  JOIN ORDERS     WITH (NOLOCK) ON (ORDDET.Orderkey = ORDERS.Orderkey)' +CHAR(13)
             + '  JOIN SKU S WITH (NOLOCK) ON S.Storerkey = PADET.Storerkey and S.SKU = PADET.SKU	' +CHAR(13)
             + '  LEFT JOIN PACKINFO   PAIF WITH (NOLOCK) ON PAIF.Pickslipno =PADET.Pickslipno AND PAIF.CartonNo = PADET.CartonNo' +CHAR(13)
             + '  LEFT JOIN codelkup CL ON CL.description=ORDERS.facility AND CL.listname =''carterfac'' AND CL.storerkey=''cartersz'' ' +CHAR(13)
             + '  LEFT JOIN WAVEDETAIL WD WITH (NOLOCK) ON WD.Orderkey = ORDERS.OrderKey'+CHAR(13)
             + '  WHERE PAH.Pickslipno=@c_Sparm02	' +CHAR(13)
             + '  AND   PAH.Storerkey = @c_Sparm01'  +CHAR(13)
             + '  AND PADET.CartonNo between CONVERT(INT,@c_Sparm03) AND CONVERT(INT,@c_Sparm04)'+CHAR(13)
             + ' ORDER BY ISNULL(RTRIM(PADET.Labelno),'''')'         

          
		IF @b_debug=1        
		BEGIN        
			PRINT @c_SQLJOIN          
		END                
              
  SET @c_SQL='INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09'  + CHAR(13) +           
             +',Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22'  + CHAR(13) +           
             +',Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34' + CHAR(13) +           
             +',Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44'  + CHAR(13) +           
             +',Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54'+ CHAR(13) +           
             + ',Col55,Col56,Col57,Col58,Col59,Col60) '          
    
   SET @c_SQL = @c_SQL + @c_SQLJOIN     
   
    SET @c_ExecArguments = N'  @c_Sparm01           NVARCHAR(80)'    
                          + ', @c_Sparm02           NVARCHAR(80) '    
                          + ', @c_Sparm03           NVARCHAR(80)'   
                          + ', @c_Sparm04           NVARCHAR(80)' 
                         
                         
   EXEC sp_ExecuteSql     @c_SQL     
                        , @c_ExecArguments    
                        , @c_Sparm01    
                        , @c_Sparm02    
                        , @c_Sparm03 
                        , @c_Sparm04        
        
   -- EXEC sp_executesql @c_SQL          
        
   IF @b_debug=1        
   BEGIN          
      PRINT @c_SQL          
   END  
   
         
   IF @b_debug=1        
   BEGIN        
      SELECT * FROM #Result (nolock) 
      --GOTO EXIT_SP      
   END        
  
    SET @c_col57 = ''
  
  
  --CS01
  SELECT TOP 1 @n_Notes2 = ISNULL(o.Notes2,'')  FROM ORDERS o WITH (NOLOCK) JOIN PICKDETAIL pid WITH (NOLOCK) ON pid.OrderKey = o.OrderKey
				JOIN PackDetail  pad WITH (NOLOCK) ON pad.LabelNo = pid.CaseID
				WHERE pad.Pickslipno=@c_Sparm02 AND   pad.Storerkey = @c_Sparm01
				AND pad.CartonNo between CONVERT(INT,@c_Sparm03) AND CONVERT(INT,@c_Sparm04)
  
  IF @n_Notes2 LIKE '%-PH-%'
		BEGIN
			DECLARE @n_CharCount INT
			
			SET  @n_CharCount = LEN(@n_Notes2) - LEN(REPLACE(@n_Notes2,'|',''))
			
			IF @n_CharCount = 0
				BEGIN
					SET @c_col57 = SUBSTRING(@n_Notes2,1,CHARINDEX('-PH-',@n_Notes2)-1)
				END
			ELSE 
				BEGIN
					CREATE TABLE #CharCount (CharCount INT)
					
					DECLARE @i INT 
					SET @i = 1
					
					WHILE @i <= @n_CharCount
						BEGIN
							
							INSERT INTO #CharCount
							(
								CharCount
							)
							SELECT dbo.IndexOf(@n_Notes2,'|',@i)     --CS01
							
							SET @i = @i + 1
							
						END
					
					DECLARE @n_Pos INT , @n_StartPos INT,  @n_EndPos INT
					
					SET @n_Pos = CHARINDEX('-PH-',@n_Notes2)
					
					SELECT @n_StartPos = Max( CharCount)
					FROM #CharCount WHERE CharCount < @n_Pos
					
					SELECT @n_EndPos = MIN(CharCount)
					FROM #CharCount WHERE CharCount > @n_Pos
					
					SELECT @c_col57 = SUBSTRING(@n_Notes2,@n_StartPos+1,CHARINDEX('-PH-',@n_Notes2)-@n_StartPos-1)
					
				END
			
			 
		END

  
  DECLARE CUR_RowNoLoop CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
  SELECT DISTINCT col04 ,col59 
   FROM #Result               
   WHERE Col60 = 'O'         
          
   OPEN CUR_RowNoLoop                  
             
   FETCH NEXT FROM CUR_RowNoLoop INTO @c_labelno,@c_pickslipno 
               
   WHILE @@FETCH_STATUS <> -1             
   BEGIN                 
      IF @b_debug='1'              
      BEGIN              
    PRINT @c_LLIId                 
      END 
      

      INSERT INTO [#TEMPBTSKU] (labelno,Brnd, Gndr, SBU, Dept, SY, Class, Item,
                                 Loc, Qty, PKQty , Retrieve)
     SELECT PADET.LabelNo,      
       --S.Tariffkey as Brnd,
       CASE WHEN s.BUSR9 LIKE '%|%' THEN  SUBSTRING(S.BUSR9,1,CHARINDEX('|',S.BUSR9)-1) ELSE '' END  as Brnd,
       --S.ReceiptHoldCode as Gndr,
       CASE WHEN s.BUSR9 LIKE '%|%' THEN  SUBSTRING(S.BUSR9,CHARINDEX('|',S.BUSR9)+1,len(S.BUSR9)-CHARINDEX('|',S.BUSR9)) ELSE '' END as Gndr,
       S.SKUGroup as SBU,
       S.HazardousFlag as 'Dept',
       substring(S.Notes1 + S.Notes2,1,80) as 'SY',
       substring(S.TemperatureFlag + S.ProductModel,1,80) as 'Class',
       substring(S.Style + ' ' + S.Color + ' ' + S.Measurement + ' ' + S.Size,1,80) as Item,
       td.FinalLOC as  Location,
       SUM(PIDET.Qty * s.BUSR1)   as QTY,
       SUM(PIDET.Qty) AS PKQty,
       'N' 
		FROM PACKHEADER PAH WITH (NOLOCK)
			JOIN PACKDETAIL PADET WITH (NOLOCK) ON PAH.Pickslipno = PADET.Pickslipno
			JOIN PICKDETAIL PIDET WITH (NOLOCK) ON PIDET.CaseId = PADET.Labelno
																AND PIDET.SKU = PADET.SKU
			JOIN dbo.TaskDetail td WITH (NOLOCK) ON  td.TaskDetailKey = PIDET.TaskDetailKey AND td.TaskType='RPF'
			JOIN dbo.LOC WITH (NOLOCK) ON loc.Loc = Pidet.Loc
			 JOIN ORDERDETAIL ORDDET WITH (NOLOCK) ON ORDDET.Orderkey = PIDET.Orderkey
																AND ORDDET.Orderlinenumber=PIDET.Orderlinenumber
			JOIN ORDERS     WITH (NOLOCK) ON (ORDDET.Orderkey = ORDERS.Orderkey)
			JOIN SKU S WITH (NOLOCK) ON S.Storerkey = PADET.Storerkey and S.SKU = PADET.SKU
		WHERE PADET.LabelNo=@c_labelno
		AND PAH.PickSlipNo=@c_pickslipno 
		Group by
       PADET.LabelNo ,
    --   S.Tariffkey ,
      -- S.ReceiptHoldCode ,
       S.SKUGroup ,
       S.HazardousFlag ,
       S.Notes1 + S.Notes2 ,
       S.TemperatureFlag + S.ProductModel ,
       S.Style + ' ' + S.Color + ' ' + S.Measurement + ' ' + S.Size ,
       td.FinalLOC ,S.BUSR9,S.BUSR1
        
        
       SET @c_brnd     = ''
       SET @c_brnd01   = ''                    
		 SET @c_brnd02   = ''                    
		 SET @c_brnd03   = ''                   
		 SET @c_brnd04   = ''                  
		 SET @c_brnd05   = ''  
		 SET @c_brnd06   = ''                    
		 SET @c_brnd07   = ''                    
		 SET @c_brnd08   = ''                   
		 SET @c_brnd09 = ''                  
		 SET @c_brnd10   = ''                      
		 SET @c_Gndr     = ''                  
		 SET @c_Gndr01   = ''                  
		 SET @c_Gndr02   = ''                        
		 SET @c_Gndr03   = ''                  
		 SET @c_Gndr04   = ''                    
		 SET @c_Gndr05   = ''      
		 SET @c_Gndr06   = ''                  
		 SET @c_Gndr07   = ''                        
		 SET @c_Gndr08   = ''                  
		 SET @c_Gndr09   = ''                    
		 SET @c_Gndr10   = ''            
		 SET @c_SBU      = ''              
		 SET @c_SBU01    = ''           
		 SET @c_SBU02    = ''      
		 SET @c_SBU03    = ''      
		 SET @c_SBU04    = ''        
		 SET @c_SBU05    = '' 
		 SET @c_SBU06    = ''           
		 SET @c_SBU07    = ''      
		 SET @c_SBU08    = ''      
		 SET @c_SBU09    = ''        
		 SET @c_SBU10    = ''    
		 SET @c_Dept     = ''           
		 SET @c_Dept01   = ''          
		 SET @c_Dept02   = ''     
		 SET @c_Dept03   = ''     
		 SET @c_Dept04   = ''     
		 SET @c_Dept05   = '' 
		 SET @c_Dept06   = ''          
		 SET @c_Dept07   = ''     
		 SET @c_Dept08   = ''     
		 SET @c_Dept09   = ''     
		 SET @c_Dept10   = ''       
		 SET @c_SY       = ''                
		 SET @c_SY01     = ''          
		 SET @c_SY02     = ''             
		 SET @c_SY03     = ''           
		 SET @c_SY04     = ''             
		 SET @c_SY05     = '' 
		 SET @c_SY06     = ''          
		 SET @c_SY07     = ''             
		 SET @c_SY08     = ''           
		 SET @c_SY09     = ''             
		 SET @c_SY10     = ''                 
		 SET @c_Class    = ''             
		 SET @c_Class01  = ''         
		 SET @c_Class02  = ''          
		 SET @c_Class03  = ''          
		 SET @c_Class04  = ''         
		 SET @c_Class05  = ''  
		 SET @c_Class06  = ''         
		 SET @c_Class07  = ''     
		 SET @c_Class08  = ''          
		 SET @c_Class09  = ''         
		 SET @c_Class10  = ''              
		 SET @c_Item     = ''             
		 SET @c_Item01   = ''            
		 SET @c_Item02   = ''    
		 SET @c_Item03   = ''         
		 SET @c_Item04   = ''          
		 SET @c_Item05   = ''   
		 SET @c_Item06   = ''            
		 SET @c_Item07   = ''    
		 SET @c_Item08   = ''         
		 SET @c_Item09   = ''          
		 SET @c_Item10   = ''    
		 SET @c_LOC      = ''         
		 SET @c_LOC01    = ''            
		 SET @c_LOC02    = ''             
		 SET @c_LOC03    = ''          
		 SET @c_LOC04    = ''            
		 SET @c_LOC05    = ''   
		 SET @c_LOC06    = ''            
		 SET @c_LOC07    = ''             
		 SET @c_LOC08    = ''          
		 SET @c_LOC09    = ''            
		 SET @c_LOC10    = ''             
		 SET @c_Qty      = ''          
		 SET @c_Qty01    = ''             
		 SET @c_Qty02    = ''             
		 SET @c_Qty03    = ''            
		 SET @c_Qty04    = ''             
		 SET @c_Qty05    = ''  
		 SET @c_Qty06    = ''             
		 SET @c_Qty07    = ''             
		 SET @c_Qty08    = ''            
		 SET @c_Qty09    = ''             
		 SET @c_Qty10    = ''  
		 SET @c_PKQty      = ''          
		 SET @c_PKQty01    = ''             
		 SET @c_PKQty02    = ''             
		 SET @c_PKQty03    = ''            
		 SET @c_PKQty04    = ''             
		 SET @c_PKQty05    = ''  
		 SET @c_PKQty06    = ''             
		 SET @c_PKQty07   = ''   
		 SET @c_PKQty08    = ''            
		 SET @c_PKQty09    = ''             
		 SET @c_PKQty10    = ''            
         
      SELECT @n_CntRec = COUNT (1)
      FROM [#TEMPBTSKU]
      WHERE labelno = @c_labelno
      AND Retrieve = 'N' 
     
     -- SELECT * FROM #TEMPBTSKU
      IF @n_CntRec > @n_MaxLine
      BEGIN
        SET @n_TTLpage =  FLOOR(@n_CntRec / @n_MaxLine ) 
      END
      ELSE
      BEGIN
      	SET @n_TTLpage = 1
      END	
     
     
     SELECT @n_CntExtOrd = COUNT(DISTINCT Orders.Externorderkey)
            ,@c_col02    = ORDERS.ExternOrderKey
            ,@c_OHNOtes2 = SUBSTRING(ORDERS.notes2,1,80)
     FROM PACKHEADER PAH WITH (NOLOCK)
			JOIN PACKDETAIL PADET WITH (NOLOCK) ON PAH.Pickslipno = PADET.Pickslipno
			JOIN PICKDETAIL PIDET WITH (NOLOCK) ON PIDET.CaseId = PADET.Labelno
																AND PIDET.SKU = PADET.SKU
			 JOIN ORDERDETAIL ORDDET WITH (NOLOCK) ON ORDDET.Orderkey = PIDET.Orderkey
																AND ORDDET.Orderlinenumber=PIDET.Orderlinenumber
			JOIN ORDERS     WITH (NOLOCK) ON (ORDDET.Orderkey = ORDERS.Orderkey)
			JOIN SKU S WITH (NOLOCK) ON S.Storerkey = PADET.Storerkey and S.SKU = PADET.SKU
		WHERE PADET.LabelNo=@c_labelno
		AND PAH.PickSlipNo=@c_pickslipno 
     GROUP BY ORDERS.ExternOrderKey,SUBSTRING(ORDERS.notes2,1,80)
		
		IF @n_CntExtOrd > 1
		BEGIN
			SET @c_col02='MULTIPLE'
		END
		ELSE 
		BEGIN
			IF LEN(@c_col02) > 10
			BEGIN
				SET @c_col02 = @c_col02--RIGHT(@c_col02,10)
			END
	  END		
			
		
		SET @c_col52=''
		
		SELECT TOP 1 @c_Col52 = c.CartonType
		FROM PackDetail pd WITH (NOLOCK)
		JOIN PackInfo PI WITH (NOLOCK) ON PI.PickSlipNo = pd.PickSlipNo AND PI.CartonNo = pd.CartonNo
		JOIN CARTONIZATION c WITH (NOLOCK) ON c.CartonType=PI.CartonType 
		JOIN STORER s WITH (NOLOCK) ON s.CartonGroup=c.CartonizationGroup AND s.StorerKey=pd.StorerKey
		WHERE pd.LabelNo=@c_labelno
		
		SET @n_TTLQty = 1
		
		IF @n_CurrentPage <> @n_TTLpage
		BEGIN
			SET @c_col56 = 'CONTINUE...'
		END
		ELSE
		BEGIN
			
			SELECT @n_TTLQty = SUM(Qty)
			FROM #TEMPBTSKU AS t WITH (NOLOCK)
			WHERE labelno = @c_labelno
			
			SET @c_col56 = 'Total: ' + CONVERT(NVARCHAR(10),@n_TTLQty)
			
		END
	
		/*
		SET @c_col55 = ''
		IF @c_OHNOtes2 LIKE '%PH%'
		BEGIN
			SET @c_col55 = SUBSTRING(@c_OHNOtes2,1,CHARINDEX('-',@c_OHNOtes2)-1)
		END
		ELSE
		BEGIN
			SET @c_col55 = @c_OHNOtes2
		END	
      */
      
     WHILE @n_intFlag <= @n_CntRec           
     BEGIN   
     	
      SELECT @c_brnd = brnd,
             @c_Gndr = Gndr,
             @c_sbu  = SBU,
             @c_Dept = Dept,
             @c_SY   = SY,
             @c_Class = Class,
             @c_Item = Item,
             @c_loc   = loc,
             @c_qty = CAST (qty AS NVARCHAR(10))  ,
             @c_PKQty = CAST (PKqty AS NVARCHAR(10))  
      FROM [#TEMPBTSKU] 
      WHERE ID = @n_intFlag
      --GROUP BY SKU

     	
     	IF (@n_intFlag%@n_MaxLine) = 1 
       BEGIN        
        SET @c_brnd01      = @c_brnd
        SET @c_Gndr01      = @c_Gndr
        SET @c_sbu01       = @c_sbu  
        SET @c_Dept01      = @c_Dept
        SET @c_SY01        = @c_SY
        SET @c_Class01     = @c_Class
        SET @c_Item01      = @c_Item
        SET @c_loc01       = @c_loc
        SET @c_qty01       = @c_qty   
        SET @c_PKQty01	   = @c_PKQty
       END        
       
       ELSE IF (@n_intFlag%@n_MaxLine) = 2
       BEGIN        
         SET @c_brnd02      = @c_brnd
         SET @c_Gndr02      = @c_Gndr
         SET @c_sbu02       = @c_sbu 
         SET @c_Dept02      = @c_Dept
         SET @c_SY02        = @c_SY
         SET @c_Class02     = @c_Class
         SET @c_Item02      = @c_Item
         SET @c_loc02       = @c_loc
         SET @c_qty02       = @c_qty     
         SET @c_PKQty02	   = @c_PKQty
       END        
        
       ELSE IF (@n_intFlag%@n_MaxLine) = 3
       BEGIN  
     SET @c_brnd03      = @c_brnd
        SET @c_Gndr03      = @c_Gndr
        SET @c_sbu03       = @c_sbu 
        SET @c_Dept03      = @c_Dept
        SET @c_SY03        = @c_SY
        SET @c_Class03     = @c_Class
        SET @c_Item03      = @c_Item
        SET @c_loc03       = @c_loc
        SET @c_qty03       = @c_qty     
        SET @c_PKQty03	   = @c_PKQty
       END        
          
       ELSE IF (@n_intFlag%@n_MaxLine) = 4
       BEGIN        
        SET @c_brnd04      = @c_brnd
        SET @c_Gndr04      = @c_Gndr
        SET @c_sbu04       = @c_sbu
        SET @c_Dept04      = @c_Dept
        SET @c_SY04        = @c_SY
        SET @c_Class04     = @c_Class
        SET @c_Item04      = @c_Item
        SET @c_loc04       = @c_loc
        SET @c_qty04       = @c_qty   
        SET @c_PKQty04	   = @c_PKQty 
       END        
       
       ELSE IF (@n_intFlag%@n_MaxLine) = 5
       BEGIN        
        SET @c_brnd05      = @c_brnd
        SET @c_Gndr05      = @c_Gndr
        SET @c_sbu05       = @c_sbu 
        SET @c_Dept05      = @c_Dept
        SET @c_SY05        = @c_SY
        SET @c_Class05     = @c_Class
        SET @c_Item05      = @c_Item
        SET @c_loc05       = @c_loc
        SET @c_qty05       = @c_qty
        SET @c_PKQty05	   = @c_PKQty
       END
       
       ELSE IF (@n_intFlag%@n_MaxLine) = 6
       BEGIN        
        SET @c_brnd06      = @c_brnd
        SET @c_Gndr06      = @c_Gndr
        SET @c_sbu06       = @c_sbu 
        SET @c_Dept06      = @c_Dept
        SET @c_SY06        = @c_SY
        SET @c_Class06     = @c_Class
        SET @c_Item06      = @c_Item
        SET @c_loc06       = @c_loc
        SET @c_qty06       = @c_qty
        SET @c_PKQty06	   = @c_PKQty
       END
       
       ELSE IF (@n_intFlag%@n_MaxLine) = 7
       BEGIN        
        SET @c_brnd07      = @c_brnd
        SET @c_Gndr07      = @c_Gndr
        SET @c_sbu07       = @c_sbu 
        SET @c_Dept07      = @c_Dept
        SET @c_SY07        = @c_SY
        SET @c_Class07     = @c_Class
        SET @c_Item07      = @c_Item
        SET @c_loc07       = @c_loc
        SET @c_qty07       = @c_qty
        SET @c_PKQty07	   = @c_PKQty
       END
       
       ELSE IF (@n_intFlag%@n_MaxLine) = 8
       BEGIN        
        SET @c_brnd08      = @c_brnd
        SET @c_Gndr08      = @c_Gndr
        SET @c_sbu08       = @c_sbu 
        SET @c_Dept08      = @c_Dept
        SET @c_SY08        = @c_SY
        SET @c_Class08     = @c_Class
        SET @c_Item08      = @c_Item
        SET @c_loc08       = @c_loc
        SET @c_qty08       = @c_qty
        SET @c_PKQty08	   = @c_PKQty
       END
       
       ELSE IF (@n_intFlag%@n_MaxLine) = 9
       BEGIN        
        SET @c_brnd09      = @c_brnd
        SET @c_Gndr09      = @c_Gndr
        SET @c_sbu09       = @c_sbu 
        SET @c_Dept09      = @c_Dept
        SET @c_SY09        = @c_SY
        SET @c_Class09     = @c_Class
        SET @c_Item09      = @c_Item
        SET @c_loc09       = @c_loc
        SET @c_qty09       = @c_qty
        SET @c_PKQty09	   = @c_PKQty
       END
      
       ELSE IF (@n_intFlag%@n_MaxLine) = 0
       BEGIN   
        SET @c_brnd10      = @c_brnd
        SET @c_Gndr10      = @c_Gndr
        SET @c_sbu10       = @c_sbu 
        SET @c_Dept10      = @c_Dept
        SET @c_SY10        = @c_SY
        SET @c_Class10     = @c_Class
        SET @c_Item10      = @c_Item
        SET @c_loc10       = @c_loc
        SET @c_qty10       = @c_qty
        SET @c_PKQty10	   = @c_PKQty
       END 
         
     IF (@n_RecCnt=@n_MaxLine) OR (@n_intFlag = @n_CntRec)
     BEGIN  
       UPDATE #Result                  
       SET col02 = @c_col02,
           Col05 = LEFT(@c_brnd01 + SPACE(5),5) + LEFT(@c_Gndr01 + SPACE(6),6) + LEFT(@c_sbu01 + SPACE(5),5) + 
                   LEFT(@c_Dept01 + SPACE(4),4) + LEFT(@c_SY01 + SPACE(6),6) + LEFT(@c_Class01 + SPACE(20),20),         
           Col06 = @c_Item01,        
           Col07 = @c_loc01, 
           Col08 =  LEFT(@c_qty01 + SPACE(4),4) + LEFT(@c_PKqty01 + SPACE(4),4),--@c_qty01,
           Col09 = LEFT(@c_brnd02 + SPACE(5),5) + LEFT(@c_Gndr02 + SPACE(6),6) + LEFT(@c_sbu02 + SPACE(5),5) + 
                   LEFT(@c_Dept02 + SPACE(4),4) + LEFT(@c_SY02 + SPACE(6),6) + LEFT(@c_Class02 + SPACE(20),20), 
           Col10 = @c_Item02,
           Col11 = @c_loc02,
           Col12 = LEFT(@c_qty02 + SPACE(4),4) + LEFT(@c_PKqty02 + SPACE(4),4),--@c_qty02,
           Col13 = LEFT(@c_brnd03 + SPACE(5),5) + LEFT(@c_Gndr03 + SPACE(6),6) + LEFT(@c_sbu03 + SPACE(5),5) + 
                   LEFT(@c_Dept03 + SPACE(4),4) + LEFT(@c_SY03 + SPACE(6),6) + LEFT(@c_Class03 + SPACE(20),20),               
           Col14 = @c_Item03,         
           Col15 = @c_loc03,         
           Col16 = LEFT(@c_qty03 + SPACE(4),4) + LEFT(@c_PKqty03 + SPACE(4),4),--@c_qty03,
           Col17 = LEFT(@c_brnd04 + SPACE(5),5) + LEFT(@c_Gndr04 + SPACE(6),6) + LEFT(@c_sbu04 + SPACE(5),5) + 
                   LEFT(@c_Dept04 + SPACE(4),4) + LEFT(@c_SY04 + SPACE(6),6) + LEFT(@c_Class04 + SPACE(20),20),   
           Col18 = @c_Item04,
           Col19 = @c_loc04,
           Col20 = LEFT(@c_qty04 + SPACE(4),4) + LEFT(@c_PKqty04 + SPACE(4),4),--@c_qty04,
           Col21 = LEFT(@c_brnd05 + SPACE(5),5) + LEFT(@c_Gndr05 + SPACE(6),6) + LEFT(@c_sbu05 + SPACE(5),5) + 
                   LEFT(@c_Dept05 + SPACE(4),4) + LEFT(@c_SY05 + SPACE(6),6) + LEFT(@c_Class05 + SPACE(20),20),   
  Col22 = @c_Item05,
           Col23 = @c_loc05,        
           Col24 = LEFT(@c_qty05 + SPACE(4),4) + LEFT(@c_PKqty05 + SPACE(4),4),--@c_qty05,        
           Col25 = LEFT(@c_brnd06 + SPACE(5),5) + LEFT(@c_Gndr06 + SPACE(6),6) + LEFT(@c_sbu06 + SPACE(5),5) + 
                   LEFT(@c_Dept06 + SPACE(4),4) + LEFT(@c_SY06 + SPACE(6),6) + LEFT(@c_Class06 + SPACE(20),20),   
           Col26 = @c_Item06,
           Col27 = @c_loc06,
           Col28 = LEFT(@c_qty06 + SPACE(4),4) + LEFT(@c_PKqty06 + SPACE(4),4),--@c_qty06,
           Col29 = LEFT(@c_brnd07 + SPACE(5),5) + LEFT(@c_Gndr07 + SPACE(6),6) + LEFT(@c_sbu07 + SPACE(5),5) + 
                   LEFT(@c_Dept07 + SPACE(4),4) + LEFT(@c_SY07 + SPACE(6),6) + LEFT(@c_Class07 + SPACE(20),20),   
           Col30 = @c_Item07, 
           Col31 = @c_loc07,    
           Col32 = LEFT(@c_qty07 + SPACE(4),4) + LEFT(@c_PKqty07 + SPACE(4),4),--@c_qty07,
           Col33 = LEFT(@c_brnd08 + SPACE(5),5) + LEFT(@c_Gndr08 + SPACE(6),6) + LEFT(@c_sbu08 + SPACE(5),5) + 
                   LEFT(@c_Dept08 + SPACE(4),4) + LEFT(@c_SY08 + SPACE(6),6) + LEFT(@c_Class08 + SPACE(20),20),        
           Col34 = @c_Item08,   
           Col35 = @c_loc08,
           Col36 = LEFT(@c_qty08 + SPACE(4),4) + LEFT(@c_PKqty08 + SPACE(4),4),--@c_qty08,
           Col37 = LEFT(@c_brnd09 + SPACE(5),5) + LEFT(@c_Gndr09 + SPACE(6),6) + LEFT(@c_sbu09+ SPACE(5),5) + 
                   LEFT(@c_Dept09 + SPACE(4),4) + LEFT(@c_SY09 + SPACE(6),6) + LEFT(@c_Class09 + SPACE(20),20),
           Col38 = @c_Item09,
           Col39 = @c_loc09,
           Col40 = LEFT(@c_qty09 + SPACE(4),4) + LEFT(@c_PKqty09 + SPACE(4),4),--@c_qty09,    
           Col41 = LEFT(@c_brnd10 + SPACE(5),5) + LEFT(@c_Gndr10 + SPACE(6),6) + LEFT(@c_sbu10 + SPACE(5),5) + 
                   LEFT(@c_Dept10 + SPACE(4),4) + LEFT(@c_SY10 + SPACE(6),6) + LEFT(@c_Class10 + SPACE(20),20),        
           Col42 = @c_Item10,        
           Col43 = @c_loc10,   
           Col44 = LEFT(@c_qty10 + SPACE(4),4) + LEFT(@c_PKqty10 + SPACE(4),4),--@c_qty10,
           --Col45 = @c_SY05,
           --Col46 = @c_Class05,
           --Col47 = @c_Item05,
           --Col48 = @c_loc05,
           --Col49 = @c_qty05,
           Col52 = @c_Col52,
   --col55 = @c_col55,
           col56 = @c_Col56    ,
           col57 = @c_Col57 
 WHERE ID = @n_CurrentPage  
       

       SET @n_RecCnt = 0
     END 
     	

       
   IF @n_RecCnt = 0 AND @n_intFlag<@n_CntRec --(@n_intFlag%@n_MaxLine) = 0 AND (@n_intFlag>@n_MaxLine)
    BEGIN
    	SET @n_CurrentPage = @n_CurrentPage + 1
    	
    	INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09                 
                            ,Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22               
                            ,Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34                
                            ,Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44                 
                            ,Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54               
                            ,Col55,Col56,Col57,Col58,Col59,Col60) 
      SELECT TOP 1 Col01,col02,Col03,col04,'', '','','','','',                 
                   '','','','','', '','','','','',              
                   '','','','','', '','','','','',              
                   '','','','','', '','','','','',                 
                   '','','','','', '','','','',col50,               
                   col51,col52,col53,col54,col55, '',col57,'',col59,''
      FROM  #Result 
      WHERE Col60='O'   
      
       SET @c_brnd     = ''
       SET @c_brnd01   = ''                    
		 SET @c_brnd02   = ''                    
		 SET @c_brnd03   = ''                   
		 SET @c_brnd04   = ''                  
		 SET @c_brnd05   = ''            
		 SET @c_Gndr     = ''                  
		 SET @c_Gndr01   = ''                  
		 SET @c_Gndr02   = ''                        
		 SET @c_Gndr03   = ''                  
		 SET @c_Gndr04   = ''                    
		 SET @c_Gndr05   = ''           
		 SET @c_SBU      = ''              
		 SET @c_SBU01    = ''           
		 SET @c_SBU02    = ''      
		 SET @c_SBU03    = ''      
		 SET @c_SBU04    = ''        
		 SET @c_SBU05    = ''    
		 SET @c_Dept     = ''           
		 SET @c_Dept01   = ''          
		 SET @c_Dept02   = ''     
		 SET @c_Dept03   = ''     
		 SET @c_Dept04   = ''     
		 SET @c_Dept05   = ''      
		 SET @c_SY       = ''                
		 SET @c_SY01     = ''          
		 SET @c_SY02     = ''             
		 SET @c_SY03     = ''           
		 SET @c_SY04     = ''             
		 SET @c_SY05     = ''             
		 SET @c_Class    = ''             
		 SET @c_Class01  = ''         
		 SET @c_Class02  = ''          
		 SET @c_Class03  = ''          
		 SET @c_Class04  = ''         
		 SET @c_Class05  = ''          
		 SET @c_Item     = ''             
		 SET @c_Item01   = ''            
		 SET @c_Item02   = ''    
		 SET @c_Item03   = ''         
		 SET @c_Item04   = ''          
		 SET @c_Item05   = ''    
		 SET @c_LOC      = ''         
		 SET @c_LOC01    = ''            
		 SET @c_LOC02    = ''             
		 SET @c_LOC03    = ''          
		 SET @c_LOC04    = ''            
		 SET @c_LOC05    = ''           
		 SET @c_Qty      = ''          
		 SET @c_Qty01    = ''             
		 SET @c_Qty02    = ''             
		 SET @c_Qty03    = ''            
		 SET @c_Qty04    = ''             
		 SET @c_Qty05    = ''  
      
     -- SELECT @n_intFlag '@n_intFlag',* FROM #Result               
    	
    END  
       
    SET @n_intFlag = @n_intFlag + 1   
    SET @n_RecCnt = @n_RecCnt + 1
    --SET @n_CntRec = @n_CntRec - 1 

           
  END    
  
   FETCH NEXT FROM CUR_RowNoLoop INTO  @c_labelno,@c_pickslipno   
        
      END -- While                   
      CLOSE CUR_RowNoLoop                  
      DEALLOCATE CUR_RowNoLoop   
      	 
SELECT * FROM #Result (nolock)        
            
EXIT_SP:    
  
   SET @d_Trace_EndTime = GETDATE()  
   SET @c_UserName = SUSER_SNAME()  
 
   EXEC isp_InsertTraceInfo   
      @c_TraceCode = 'BARTENDER',  
      @c_TraceName = 'isp_BT_Bartender_CN_RETAILLBL',  
      @c_starttime = @d_Trace_StartTime,  
      @c_endtime = @d_Trace_EndTime,  
      @c_step1 = @c_UserName,  
      @c_step2 = '',  
      @c_step3 = '',  
      @c_step4 = '',  
      @c_step5 = '',  
      @c_col1 = @c_Sparm01,   
      @c_col2 = @c_Sparm02,  
      @c_col3 = @c_Sparm03,  
      @c_col4 = @c_Sparm04,  
      @c_col5 = @c_Sparm05,  
      @b_Success = 1,  
      @n_Err = 0,  
      @c_ErrMsg = ''              
   
  
                                  
END -- procedure   

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
GRANT EXECUTE ON isp_BT_Bartender_CN_RETAILLBL TO NSQL
GO



