SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/                     
/* Copyright: IDS                                                             */                     
/* Purpose: isp_Bartender_CN_Sortlbl01_001                                    */                     
/*                                                                            */                     
/* Modifications log:                                                         */                     
/*                                                                            */                     
/* Date       Rev  Author     Purposes                                        */     
/* 2023-08-15 1.0  CSCHONG    Devops Scripts Combine & WMS-23256-Create       */
/* 2023-11-16 1.1  ALiang     Performance Tuning (AL01)                       */
/******************************************************************************/   
CREATE OR ALTER PROC [dbo].[isp_Bartender_CN_Sortlbl01_001]                 
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
      @c_PalletKey         NVARCHAR(50),              
      @c_SKU               NVARCHAR(20),             
      @c_serialno          NVARCHAR(4000),        
      @c_SQL               NVARCHAR(4000),  
      @c_SQLSORT           NVARCHAR(4000),  
      @c_SQLJOIN           NVARCHAR(4000),  
      @n_TTLCopy           INT,  
      @c_ChkStatus         NVARCHAR(2),  
      @c_Uccno             NVARCHAR(80),  
      @c_storerkey         NVARCHAR(80),  
      @n_continue          INT,  
      @c_ExecStatements    NVARCHAR(4000),     
      @c_ExecArguments     NVARCHAR(4000),  
      @n_MaxLine           INT,     
      @n_pageno            INT,     
      @n_totalpg           INT        
   
  
  
    -- SET RowNo = 0       
    SET @c_SQL = ''    
    SET @n_TTLCopy = 1  
    SET @n_MaxLine = 100  
        
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
  
  
         
         
     INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09    
             ,Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22    
             ,Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34    
             ,Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44   
             ,Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54  
             ,Col55,Col56,Col57,Col58,Col59,Col60)  

    SELECT CASE WHEN o.ecom_single_flag='S' then N'单' ELSE N'多' END,
           CASE o.userdefine03 WHEN '1' then 'W'
                WHEN '2' then 'TM'
                WHEN '4' then 'JD'
                WHEN '5' then 'DY'  ELSE '' END,
          ISNULL(r.position,rrr.Position),o.userdefine09,o.orderkey,pp.qty,ISNULL(o.deliverynote,''),'','','',
           '','','','','','','','','','', 
           '','','','','','','','','','', 
           '','','','','','','','','','', 
           '','','','','','','','','','', 
           '','','','','','','','','',''
    FROM wave w (nolock)
    JOIN orders o (nolock) on o.userdefine09=w.wavekey
    Left join rdt.rdtPTLPieceLog r (nolock) on r.orderkey=o.orderkey
    Left join ( select rr.*
                FROM ( select rl.*,row_number() over (partition by rl.orderkey order by rl.adddate desc) num
                             from rdt.rdtPTLPieceLog_log rl (nolock)
                             join codelkup c(nolocK) on c.code=rl.station
                             where c.LISTNAME='TCPClient' --AL01 Performance Tuning
                             AND c.storerkey='18505'      --AL01 Performance Tuning
                             AND rl.wavekey=@c_Sparm01    --AL01 Performance Tuning
                             AND rl.orderkey=@c_Sparm02   --AL01 Performance Tuning
                    ) rr
               where rr.num=1
             ) rrr on rrr.orderkey=o.orderkey
      join ( select p.orderkey,sum(p.qty) qty
               from pickdetail p (nolock) where  storerkey='18505' AND orderkey=@c_Sparm02 --AL01 Performance Tuning
           group by p.orderkey
         ) pp on pp.orderkey=o.orderkey
where w.WaveKey=@c_Sparm01
AND o.orderkey=@c_Sparm02
AND o.storerkey='18505'

   SELECT * FROM #Result WITH (NOLOCK)  

  
   EXIT_SP:         
                                 
   END -- procedure       
GO
GRANT EXECUTE ON [dbo].[isp_Bartender_CN_Sortlbl01_001] TO [NSQL]
GO

