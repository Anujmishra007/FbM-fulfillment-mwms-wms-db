IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_BT_Bartender_TH_EXPTCTNLBL_ADIDAS]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_BT_Bartender_TH_EXPTCTNLBL_ADIDAS]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   

/********************************************************************************/                   
/* Copyright: LFL                                                               */                   
/* Purpose: isp_BT_Bartender_TH_EXPTCTNLBL_ADIDAS                               */                   
/*                                                                              */                   
/* Modifications log:                                                           */                   
/*                                                                              */                   
/* Date       Rev  Author     Purposes                                          */                   
/* 2022-01-19 1.0  WLChooi    Created (WMS-18768)                               */  
/* 2022-01-19 1.0  WLChooi    DevOps Combine Script                             */  
/********************************************************************************/                  
                    
CREATE PROC [dbo].[isp_BT_Bartender_TH_EXPTCTNLBL_ADIDAS]                        
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
      @n_intFlag         INT,       
      @n_CntRec          INT,      
      @c_SQL             NVARCHAR(4000),          
      @c_SQLSORT         NVARCHAR(4000),          
      @c_SQLJOIN         NVARCHAR(4000),  
      @c_ExecStatements  NVARCHAR(4000),         
      @c_ExecArguments   NVARCHAR(4000),  
      
      @n_TTLpage         INT,            
      @n_CurrentPage     INT,    
      @n_MaxLine         INT
      
  DECLARE  @d_Trace_StartTime   DATETIME,     
           @d_Trace_EndTime     DATETIME,    
           @c_Trace_ModuleName  NVARCHAR(20),     
           @d_Trace_Step1       DATETIME,     
           @c_Trace_Step1       NVARCHAR(20),    
           @c_UserName          NVARCHAR(20)          
    
   SET @d_Trace_StartTime = GETDATE()    
   SET @c_Trace_ModuleName = ''   
     
   SET @n_CurrentPage = 1    
   SET @n_TTLpage =1         
   SET @n_MaxLine = 8       
   SET @n_CntRec = 1      
   SET @n_intFlag = 1     
                   
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

   SET @c_SQLJOIN = + ' SELECT DISTINCT ISNULL(TRIM(OH.C_Company),''''), ' + CHAR(13) --1
                    + ' ISNULL(TRIM(OH.C_Address1),'''') + ISNULL(TRIM(OH.C_Address2),''''), ' + CHAR(13)   --2
                    + ' ISNULL(TRIM(OH.C_Address3),'''') + ISNULL(TRIM(OH.C_Address4),''''), ' + CHAR(13)   --3
                    + ' ISNULL(TRIM(OH.C_City),'''') + '' '' + ISNULL(TRIM(OH.C_State),'''') + '' '' + ISNULL(TRIM(OH.C_Zip),''''), ' + CHAR(13)   --4
                    + ' ISNULL(TRIM(ST.B_Company),''''), ' + CHAR(13) --5
                    + ' ISNULL(TRIM(ST.B_Address1),'''') + '','' + ISNULL(TRIM(ST.B_Address2),''''), ' + CHAR(13)   --6
                    + ' ISNULL(TRIM(ST.B_Address3),'''') + '','' + ISNULL(TRIM(ST.B_Address4),''''), ' + CHAR(13)   --7
                    + ' ISNULL(TRIM(ST.B_Zip),'''') + '' '' + ISNULL(TRIM(ST.B_Country),''''), ' + CHAR(13)   --8
                    + ' PD.CartonNo, PH.TTLCNTS, '  + CHAR(13) --10      
                    + ' ROUND(ISNULL(PIF.[Weight],0), 1, 1), '  + CHAR(13) --11
                    + ' ROUND(ISNULL(PIF.[Weight],0) + ISNULL(CZ.[CartonWeight],0), 1, 1), '  + CHAR(13) --12   
                    + ' ISNULL(CZ.CartonDescription,''''), OH.TrackingNo, '   + CHAR(13)   --14
                    + ' '''', '''', '''', '''', '''', '''', '  + CHAR(13) --20         
                    + ' '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', '  + CHAR(13) --30     
                    + ' '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', '  + CHAR(13) --40  
                    + ' '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', '  + CHAR(13) --50        
                    + ' '''', '''', '''', '''', '''', '''', '''', '''', PD.LabelNo, ''TH'' '   --60            
                    + CHAR(13) +              
                    + ' FROM PACKDETAIL PD WITH (NOLOCK)'   + CHAR(13)  
                    + ' JOIN PACKHEADER PH WITH (NOLOCK) ON PH.Pickslipno = PD.Pickslipno '   + CHAR(13)  
                    + ' JOIN ORDERS OH WITH (NOLOCK) ON OH.Orderkey = PH.Orderkey '   + CHAR(13)  
                    + ' JOIN PACKINFO PIF WITH (NOLOCK) ON PIF.Pickslipno = PD.Pickslipno '   + CHAR(13)
                    + '                                AND PIF.CartonNo = PD.CartonNo '   + CHAR(13)
                    + ' JOIN STORER ST WITH (NOLOCK) ON ST.Storerkey = OH.Storerkey '   + CHAR(13)
                    + ' JOIN CARTONIZATION CZ WITH (NOLOCK) ON CZ.CartonizationGroup = ''ADIDASB2B'' '   + CHAR(13) 
                    + '                                    AND CZ.CartonType = PIF.CartonType '   + CHAR(13) 
                    + ' WHERE PD.Pickslipno =  @c_Sparm01 '   + CHAR(13)
                    + ' AND PD.LabelNo =  @c_Sparm02 '   + CHAR(13)
                    + ' AND OH.DocType =  ''N'' '   + CHAR(13)
                    + ' AND OH.C_Country <> ''TH'' '

   IF @b_debug=1          
   BEGIN          
      PRINT @c_SQLJOIN            
   END                  
                
   SET @c_SQL='INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09'  + CHAR(13) +             
             +',Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22'  + CHAR(13) +             
             +',Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34' + CHAR(13) +             
             +',Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44'  + CHAR(13) +             
             +',Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54'+ CHAR(13) +             
             +',Col55,Col56,Col57,Col58,Col59,Col60) '    
                  
   SET @c_SQL = @c_SQL + @c_SQLJOIN                
                                  
  
   SET @c_ExecArguments = N'  @c_Sparm01         NVARCHAR(80) '      
                        +  ', @c_Sparm02         NVARCHAR(80) '       
                        +  ', @c_Sparm03         NVARCHAR(80) '  
          
   EXEC sp_ExecuteSql     @c_SQL       
                        , @c_ExecArguments      
                        , @c_Sparm01      
                        , @c_Sparm02    
                        , @c_Sparm03  
          
   IF @b_debug=1          
   BEGIN            
      PRINT @c_SQL            
   END         
  
QUIT_SP:  
   SELECT * FROM #Result (nolock)       
   ORDER BY ID     
          
END -- procedure     
GO
GRANT EXECUTE ON [dbo].[isp_BT_Bartender_TH_EXPTCTNLBL_ADIDAS] TO nsql 
GO