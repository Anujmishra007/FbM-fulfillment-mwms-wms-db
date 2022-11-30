SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO  
/******************************************************************************/                         
/* Copyright: IDS                                                             */                         
/* Purpose: isp_BT_Bartender_CTNLBLUA                                         */                         
/*                                                                            */                         
/* Modifications log:                                                         */                         
/*                                                                            */                         
/* Date       Rev  Author     Purposes                                        */        
/*08-AUG-2022 1.0  MINGLE     Created (WMS-20321)                             */        
/******************************************************************************/                        
                          
CREATE OR ALTER PROC [dbo].[isp_BT_Bartender_CTNLBLUA]                              
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
                                      
   DECLARE                          
      @c_Pickslipno      NVARCHAR(20),                            
      @c_sku             NVARCHAR(80),                                 
      @n_intFlag         INT,             
      @n_CntRec          INT,            
      @c_SQL             NVARCHAR(4000),                
      @c_SQLSORT         NVARCHAR(4000),                
      @c_SQLJOIN         NVARCHAR(MAX),        
      @c_col58           NVARCHAR(10),      
      @c_labelline       NVARCHAR(10),      
      @n_CartonNo        INT              
            
   DECLARE @d_Trace_StartTime  DATETIME,           
           @d_Trace_EndTime    DATETIME,          
           @c_Trace_ModuleName NVARCHAR(20),           
           @d_Trace_Step1      DATETIME,           
           @c_Trace_Step1      NVARCHAR(20),      
			  @c_ExecStatements   NVARCHAR(4000),              
           @c_ExecArguments    NVARCHAR(4000),        
			  @c_UserName         NVARCHAR(20)                    
                
          
    SET @d_Trace_StartTime = GETDATE()          
    SET @c_Trace_ModuleName = ''          
                
    -- SET RowNo = 0                     
    SET @c_SQL = ''             
      
                      
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
      
                                   
          
       SET @c_SQLJOIN = +' SELECT DISTINCT OH.STORERKEY, OH.FACILITY, OH.LOADKEY,OH.ORDERKEY,OH.EXTERNORDERKEY,'+ CHAR(13) --5                        
                        + 'OH.EXTERNPOKEY,ISNULL(OH.BUYERPO,''''),OH.ECOM_PLATFORM,ISNULL(OH.M_COMPANY,''''),ISNULL(OH.TRACKINGNO,''''),'+ CHAR(13) --10      
                        +' OH.CONSIGNEEKEY,ISNULL(OH.C_COMPANY,''''),ISNULL(OH.C_ADDRESS1,''''),ISNULL(OH.C_ADDRESS2,''''),ISNULL(OH.C_ADDRESS3,''''), '+ CHAR(13) --15           
                        +' ISNULL(OH.C_ADDRESS4,''''),ISNULL(OH.C_STATE,''''),ISNULL(OH.C_CITY,''''),ISNULL(OH.C_ZIP,''''),ISNULL(OH.C_CONTACT1,''''),'+ CHAR(13)  --20      
                        +' ISNULL(OH.C_PHONE1,''''),ISNULL(OH.C_PHONE2,''''),OH.DELIVERYDATE,ISNULL(CL1.LONG,''''),ISNULL(OH.NOTES,''''),' + CHAR(13) --25      
                        +' OH.SHIPPERKEY,OH.ORDERDATE,ISNULL(OH.USERDEFINE01,''''),ISNULL(OH.USERDEFINE02,''''),ISNULL(OH.USERDEFINE03,''''), ' + CHAR(13) --30      
                        + 'ISNULL(OH.USERDEFINE04,''''),ISNULL(OH.USERDEFINE05,''''),ISNULL(OH.USERDEFINE06,''''),ISNULL(OH.USERDEFINE07,''''),ISNULL(OH.USERDEFINE08,''''),' + CHAR(13) --35           
                        +' ISNULL(OH.USERDEFINE09,''''),ISNULL(OH.USERDEFINE10,''''),'''','''',CL.LONG, '+ CHAR(13) --40       
                        +' '''','''',PD.DROPID,PAD.LABELNO,ST.SECONDARY, ' + CHAR(13) --45       
                        +' ST.COMPANY,ST.SUSR1,ST.SUSR2,FC.STATE,FC.CITY,' + CHAR(13) --50      
								+' FC.ZIP,FC.CONTACT1,FC.PHONE1,FC.PHONE2,'''',' + CHAR(13) --55      
                        +' '''', '''','''','''','''' ' + CHAR(13) --60                     
							   +' FROM ORDERS OH WITH (NOLOCK)      '  + CHAR(13)                                
                        +' JOIN PICKDETAIL PD WITH (NOLOCK)  ON PD.ORDERKEY = OH.ORDERKEY AND PD.STORERKEY = OH.STORERKEY '+ CHAR(13)                                     
                        +' JOIN PACKDETAIL PAD WITH (NOLOCK)  ON PAD.LABELNO = PD.DROPID    '+ CHAR(13)                  
                        +' JOIN STORER ST WITH (NOLOCK) ON ST.Storerkey = OH.STORERKEY ' + CHAR(13)           
                        +' JOIN FACILITY FC WITH (NOLOCK) ON FC.FACILITY = OH.FACILITY ' + CHAR(13)       
								+' LEFT JOIN CODELKUP CL WITH (NOLOCK) ON CL.LISTNAME = ''CREPOPARM'' AND CL.CODE2 = OH.FACILITY AND CL.STORERKEY = OH.STORERKEY AND CL.CODE = ''carrier_code'' ' + CHAR(13)        
								+' LEFT JOIN CODELKUP CL1 WITH (NOLOCK) ON CL1.LISTNAME = ''VIPWH'' AND CL1.CODE2 = OH.FACILITY AND CL1.STORERKEY = OH.STORERKEY ' + CHAR(13)   
								+'              AND CL1.CODE = OH.M_ADDRESS3 AND CL1.SHORT = ''1'' ' + CHAR(13)   
                        +' WHERE PD.DROPID = @c_Sparm01 '+ CHAR(13)  
							 --+' AND OH.ECOM_PLATFORM = ''JIT'' OR OH.ORDERGROUP = ''JIT'' '      
							 --+' AND OH.DOCTYPE = ''E'' AND OH.TYPE = ''VIP'' '     
								+' AND OH.ORDERGROUP = ''JIT'' '    
      
      
      
             
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
        
        
 SET @c_ExecArguments = N'     @c_Sparm01          NVARCHAR(80)'      
              
                                 
                                 
   EXEC sp_ExecuteSql     @c_SQL             
                        , @c_ExecArguments            
                        , @c_Sparm01           
                              
           
                
    --EXEC sp_executesql @c_SQL                  
                
   IF @b_debug=1                
   BEGIN                  
      PRINT @c_SQL                  
   END          
           
                 
   IF @b_debug=1                
   BEGIN                
      SELECT * FROM #Result (nolock)                
   END               
         
   SELECT * FROM #Result          
      
                    
EXIT_SP:            
          
   SET @d_Trace_EndTime = GETDATE()          
   SET @c_UserName = SUSER_SNAME()          
             
   EXEC isp_InsertTraceInfo           
      @c_TraceCode = 'BARTENDER',          
      @c_TraceName = 'isp_BT_Bartender_CTNLBLUA',          
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
GO
GRANT EXECUTE ON [dbo].[isp_BT_Bartender_CTNLBLUA] TO nSQL 
GO