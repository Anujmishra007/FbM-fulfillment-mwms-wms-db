SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO  
/******************************************************************************/                     
/* Copyright: IDS                                                             */                     
/* Purpose: isp_BT_Bartender_SHIPUCCLBL_06                                    */                     
/*                                                                            */                     
/* Modifications log:                                                         */                     
/*                                                                            */                     
/* Date       Rev  Author     Purposes                                        */                     
/* 2022-03-01 1.0  CSCHONG    Devops Scripts Combine & Created (WMS-19013)    */     
/* 2022-06-22 1.1  MINGLE     Add new logic (WMS-20005)(ML01)                 */   
/* 2022-07-10 1.1  MINGLE     Add new labelno (WMS-20151)(ML02)               */   
/* 2022-08-23 1.2  CHONGCS    WMS-20570 revised field logic (CS01)            */
/* 2022-10-03 1.3  CHONGCS    WMS-20570 revised field logic (CS02)            */
/******************************************************************************/                    
                      
CREATE  OR ALTER PROC [dbo].[isp_BT_Bartender_SHIPUCCLBL_06]                          
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
      @c_ReceiptKey      NVARCHAR(10),                        
      @c_sku             NVARCHAR(80),    
      @c_sdescr          NVARCHAR(80),   
      @c_odnotes         NVARCHAR(80), --ML01  
      @n_intFlag         INT,         
      @n_CntRec          INT,        
      @c_SQL             NVARCHAR(4000),            
      @c_SQLSORT         NVARCHAR(4000),            
      @c_SQLJOIN         NVARCHAR(4000),    
      @c_col58           NVARCHAR(10)          
        
  DECLARE @d_Trace_StartTime   DATETIME,       
          @d_Trace_EndTime    DATETIME,      
          @c_Trace_ModuleName NVARCHAR(20),       
          @d_Trace_Step1      DATETIME,       
          @c_Trace_Step1      NVARCHAR(20),      
          @c_UserName         NVARCHAR(20),     
          @c_SKU01            NVARCHAR(80),             
          @c_SKU02            NVARCHAR(80),      
          @c_SKU03            NVARCHAR(80),             
          @c_SKU04            NVARCHAR(80),    
          @c_SKU05            NVARCHAR(80),    
          @c_SDESCR01         NVARCHAR(80),             
          @c_SDESCR02         NVARCHAR(80),      
          @c_SDESCR03         NVARCHAR(80),             
          @c_SDESCR04         NVARCHAR(80),    
          @c_SDESCR05         NVARCHAR(80),   
    --START ML01  
          @c_ODNotes01        NVARCHAR(80),             
          @c_ODNotes02        NVARCHAR(80),      
          @c_ODNotes03        NVARCHAR(80),             
          @c_ODNotes04        NVARCHAR(80),    
          @c_ODNotes05        NVARCHAR(80),  
    --END ML01  
          @c_SKUQty01         NVARCHAR(10),         
          @c_SKUQty02         NVARCHAR(10),      
          @c_SKUQty03         NVARCHAR(10),            
          @c_SKUQty04         NVARCHAR(10),         
          @c_SKUQty05         NVARCHAR(10),     
          @c_QtyUOM01         NVARCHAR(30),     --CS01 S       
          @c_QtyUOM02         NVARCHAR(30),      
          @c_QtyUOM03         NVARCHAR(30),            
          @c_QtyUOM04         NVARCHAR(30),         
          @c_QtyUOM05         NVARCHAR(30),     --CS01 E                
          @n_TTLpage          INT,            
          @n_CurrentPage      INT,    
          @n_MaxLine          INT  ,    
          @n_MaxCtnNo         INT  ,    
          @c_labelno          NVARCHAR(20) ,    
          @c_pickslipno       NVARCHAR(20) ,    
          @c_orderkey         NVARCHAR(20) ,    
          @n_skuqty           INT ,    
          @n_skurqty          INT ,    
          @n_pskuqty          INT ,  
          @n_ttlnetwgt        FLOAT,  
          @c_PLOC             NVARCHAR(20),     
          @c_cartonno         NVARCHAR(5),    
          @n_loopno           INT,    
          @c_LastRec          NVARCHAR(1),    
          @c_LastCtn          NVARCHAR(1),    
          @c_ExecStatements   NVARCHAR(4000),        
          @c_ExecArguments    NVARCHAR(4000) ,    
          @n_ConsigneeKey     NVARCHAR(10),    
          @n_Col03            NVARCHAR(80),    
          @n_Col04            NVARCHAR(80),    
          @n_Col05            NVARCHAR(80),    
          @n_Col06            NVARCHAR(80),    
          @n_Col07            NVARCHAR(80),  
          @dt_DeliveryDate    DATETIME,  
          @c_lastpage         NVARCHAR(1),  
          @n_qtybyctn         INT,  
          @c_packstatus       NVARCHAR(5),  
          @c_getOrderkey      NVARCHAR(20),  
          @n_packqty          INT = 0,  
          @n_pickqty          INT = 0,
          @c_uom              NVARCHAR(20)    --CS01         
      
   SET @d_Trace_StartTime = GETDATE()      
   SET @c_Trace_ModuleName = ''      
            
    -- SET RowNo = 0      
    SET @c_SQL = ''         
    SET @n_CurrentPage = 1    
    SET @n_TTLpage =1         
    SET @n_MaxLine = 5        
    SET @n_CntRec = 1      
    SET @n_intFlag = 1     
    SET @n_loopno = 1          
    SET @c_LastRec = 'Y'    
    SET @n_ConsigneeKey = ''    
    SET @n_Col03 = ''    
    SET @n_Col04 = ''    
    SET @n_Col05 = ''    
    SET @n_Col06 = ''    
    SET @n_Col07 = ''    
    SET @c_packstatus = '0'  
                  
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
         
         
      CREATE TABLE [#TEMPPDSKULOC] (                       
      [ID]           [INT] IDENTITY(1,1) NOT NULL,                                          
      [Pickslipno]   [NVARCHAR] (20) NULL,      
      [cartonno]     INT NULL,           
      [SKU]          [NVARCHAR] (20) NULL,               
      [PQty]         INT,    
      [SDescr]       [NVARCHAR](80) NULL,    
      [NetWgt]       FLOAT,   
      [Retrieve]     [NVARCHAR](1) DEFAULT 'N',  
      [ODNotes]      [NVARCHAR](80) NULL, --ML01  
      [UOM]          [NVARCHAR](20) NULL,  --CS01
      [PDIUDF03]     [NVARCHAR](30) NULL   --CS02
   )        
    
          
             
         SET @c_SQLJOIN = +' SELECT TOP 1 O.c_company,CONVERT(NVARCHAR(5), pad.cartonno),'   
             + ' OD.userdefine09,o.externorderkey,PIF.Weight,'+ CHAR(13)      --5          
             + ' (PIF.Weight-CT.cartonweight),ISNULL(CT.CartonDescription,''''),SUBSTRING(ISNULL(O.notes,''''),1,80),'''','''','          
             + ' '''','''','''','''','''','     --15      
             + ' '''','''','''','''','''','     --20           
             + CHAR(13) +          
             + ' ISNULL(o.deliveryplace,''''),ISNULL(o.buyerpo,''''),ISNULL(o.b_contact1,''''),ISNULL(o.IntermodalVehicle,''''),'  
             +' ISNULL(pad.refno,''''),SUBSTRING(ISNULL(O.notes,''''),81,80),SUBSTRING(ISNULL(O.notes,''''),161,80),pad.labelno,'''','''','  --30 --ML01 --ML02       
             + ' '''','''','''','''','''','''','''','''','''','''','   --40           
             + ' '''','''','''','''','''','''','''','''','''','''', '  --50           
             + ' '''','''','''','''','''','''', '''' ,'''',pad.pickslipno,''O'' '   --60              
             + CHAR(13) +                           
             + ' FROM PackHeader pah WITH (NOLOCK)  '    
             + ' JOIN PackDetail pad WITH (NOLOCK) ON pah.PickSlipNo = pad.PickSlipNo '       
           --  + ' JOIN LoadPlanDetail lpd WITH (NOLOCK) ON lpd.Loadkey = lp.Loadkey '  
             + ' JOIN Orders o WITH (NOLOCK) ON o.Orderkey = pah.Orderkey '      
             + ' JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.Orderkey = O.Orderkey'     
             + ' JOIN STORER ST WITH (NOLOCK) ON ST.storerkey = O.storerkey '   
             + ' JOIN PACKINFO PIF WITH (NOLOCK) ON PIF.Pickslipno = pad.pickslipno AND PIF.cartonno = pad.cartonno '   
             + ' JOIN CARTONIZATION CT WITH (NOLOCK) ON CT.cartontype=PIF.cartontype and CT.cartonizationGroup=ST.cartongroup '  
             + ' WHERE pad.pickslipno = @c_Sparm01 '       
             + ' AND pad.Cartonno >= CONVERT(INT,@c_Sparm02) '                        
             + ' AND pad.Cartonno <= CONVERT(INT,@c_Sparm03) '        
             
         
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
    
    
 SET @c_ExecArguments = N'  @c_Sparm01          NVARCHAR(80)'        
                       + ', @c_Sparm02          NVARCHAR(80) '     
                       + ', @c_Sparm03          NVARCHAR(80) '         
                             
                             
   EXEC sp_ExecuteSql     @c_SQL         
                        , @c_ExecArguments        
                        , @c_Sparm01       
                        , @c_Sparm02     
                        , @c_Sparm03          
            
    --EXEC sp_executesql @c_SQL              
            
   IF @b_debug=1            
   BEGIN              
      PRINT @c_SQL              
   END      
       
          
   IF @b_debug=1            
   BEGIN            
      SELECT * FROM #Result (NOLOCK)            
   END            
  
      
   DECLARE CUR_RowNoLoop CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
   SELECT DISTINCT col59,col02         
   FROM #Result                   
   WHERE Col60 = 'O'             
              
   OPEN CUR_RowNoLoop                      
                 
   FETCH NEXT FROM CUR_RowNoLoop INTO @c_pickslipno,@c_cartonno        
                   
   WHILE @@FETCH_STATUS <> -1                 
   BEGIN                     
      IF @b_debug='1'                  
      BEGIN                  
         SELECT @c_pickslipno '@c_pickslipno' ,   @c_cartonno '@c_cartonno'                  
      END     
          
      INSERT INTO #TEMPPDSKULOC (pickslipno,Cartonno,SKU,PQty,SDescr,NetWgt,Retrieve,ODNotes,UOM,PDIUDF03) --ML01  --CS01  --CS02          
      SELECT DISTINCT @c_pickslipno,CAST(@c_cartonno AS INT),PD.sku, SUM(PDI.qty),SUBSTRING(ISNULL(s.descr,''),1,80),      --CS02
                      SUM(s.NetWgt*pd.qty),'N',SUBSTRING(ISNULL(OD.Notes,''),1,80),OD.UOM,PDI.UserDefine03 --ML01   --CS01 --CS02
      FROM  PackDetail AS pd WITH (NOLOCK)     
      JOIN SKU S WITH (NOLOCK) ON S.StorerKey = pd.StorerKey AND S.sku = pd.sku    
      JOIN PACKHEADER PH WITH (NOLOCK) ON pd.pickslipno=ph.pickslipno          
      JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.StorerKey = pd.StorerKey AND OD.sku = pd.sku AND od.orderkey=ph.orderkey  
      JOIN PackDetailInfo PDI WITH (NOLOCK) ON PDI.PickSlipNo=PD.PickSlipNo AND PDI.UserDefine03=OD.ExternLineNo AND PDI.SKU=OD.Sku AND PDI.StorerKey=OD.StorerKey  --CS02
      WHERE  pd.Pickslipno = @c_pickslipno    
      AND pd.cartonno = CONVERT(INT,@c_cartonno)    
      GROUP BY PD.sku  ,SUBSTRING(ISNULL(s.descr,''),1,80),SUBSTRING(ISNULL(OD.Notes,''),1,80) ,OD.UOM,PDI.UserDefine03   --CS01  --CS02
  
          
      SET @c_SKU01 = ''    
      SET @c_SKU02 = ''    
      SET @c_SKU03 = ''    
      SET @c_SKU04 = ''    
      SET @c_SKU05 = ''   
      SET @c_SDESCR01 = ''  
      SET @c_SDESCR02 = ''  
      SET @c_SDESCR03 = ''  
      SET @c_SDESCR04 = ''  
      SET @c_SDESCR05 = ''  
   --START ML01  
      SET @c_ODNotes01 = ''  
      SET @c_ODNotes02 = ''  
      SET @c_ODNotes03 = ''  
      SET @c_ODNotes04 = ''  
      SET @c_ODNotes05 = ''  
   --END ML01  
      SET @c_SKUQty01 = ''    
      SET @c_SKUQty02 = ''    
      SET @c_SKUQty03 = ''    
      SET @c_SKUQty04 = ''    
      SET @c_SKUQty05 = ''   
      SET @n_pskuqty = 0  
      SET @n_ttlnetwgt = 0   
      SET @n_qtybyctn = 0  

      --CS01 S
      SET @c_QtyUOM01 = ''
      SET @c_QtyUOM02 = ''
      SET @c_QtyUOM03 = ''
      SET @c_QtyUOM04 = ''
      SET @c_QtyUOM05 = ''

      --CS01 E
    
      SET @n_MaxCtnNo =1    
      SET @c_LastCtn = 'N'    
      SET @c_lastpage = 'N'  
      SET @n_packqty = 0  
      SET @n_pickqty = 0  
      SET @c_packstatus ='0'  
      SET @c_getOrderkey = ''  
      --SELECT * FROM #TEMPLLISKUPHL03    
    
      SELECT @n_CntRec = COUNT (1)    
      FROM #TEMPPDSKULOC     
      WHERE pickslipno = @c_pickslipno     
      AND cartonno = CONVERT(INT,@c_cartonno)    
      AND Retrieve = 'N'   
  
      SELECT @n_ttlnetwgt = SUM(NetWgt)  
            ,@n_qtybyctn = SUM(pqty)    
      FROM #TEMPPDSKULOC     
      WHERE pickslipno = @c_pickslipno     
      AND cartonno = CONVERT(INT,@c_cartonno)    
  
     --IF @c_packstatus = '9'  
     --BEGIN  
      SELECT @n_MaxCtnNo = MAX(Cartonno)    
      FROM PackDetail WITH (NOLOCK)    
      WHERE PickSlipNo = @c_pickslipno    
  
  
         SELECT @c_packstatus = PH.status  
               ,@c_getOrderkey = PH.OrderKey  
         FROM dbo.PackHeader PH WITH (NOLOCK)  
          WHERE PH.PickSlipNo = @c_Sparm01  
      
            IF CAST(@c_cartonno as int) = @n_MaxCtnNo    
            BEGIN  
               SELECT @n_packqty = SUM(PD.Qty)  
               FROM dbo.PackDetail PD WITH (NOLOCK)  
               WHERE PD.PickSlipNo = @c_Sparm01  
               --AND PD.CartonNo >=CONVERT(INT,@c_Sparm02)   
           END   
           ELSE  
           BEGIN  
              SELECT @n_packqty = SUM(PD.Qty)  
               FROM dbo.PackDetail PD WITH (NOLOCK)  
               WHERE PD.PickSlipNo = @c_Sparm01  
               AND PD.CartonNo BETWEEN 1 AND CONVERT(INT,@c_Sparm02)   
           END     
  
            SELECT @n_pickqty = SUM(PD.Qty)  
            FROM dbo.PickDetail PD WITH (NOLOCK)  
            WHERE PD.OrderKey = @c_getOrderkey  
    
      IF @c_packstatus = '9'   
      BEGIN    
        IF CAST(@c_cartonno as int) = @n_MaxCtnNo    
        BEGIN  
            SET @c_LastCtn = 'Y'   
        END   
     END  
     ELSE  
     BEGIN  
         IF @n_pickqty = @n_packqty    
        BEGIN  
            SET @c_LastCtn = 'Y'   
        END   
     END   
         
    
      --IF @c_LastCtn = 'Y'    
      --BEGIN    
  
      IF  (@n_CurrentPage=@n_TTLpage)      
      BEGIN    
        SET @c_lastpage = 'Y'    
      END    
   -- END  
  
      IF @c_LastCtn = 'Y'    
      BEGIN    
        
         UPDATE #Result                      
         SET Col02 =  CONVERT(NVARCHAR(5),@n_MaxCtnNo) + '/' + @c_cartonno    
         WHERE ID = @n_CurrentPage     
      END    
          
      SET @n_TTLpage =  FLOOR(@n_CntRec / @n_MaxLine ) + CASE WHEN @n_CntRec % @n_MaxLine > 0 THEN 1 ELSE 0 END     
          
      --SELECT * FROM #TEMPEATSKU01    
          
     WHILE @n_intFlag <= @n_CntRec               
     BEGIN      
           
       IF @n_intFlag > @n_MaxLine AND (@n_intFlag%@n_MaxLine) = 1 --AND @c_LastRec = 'N'    
       BEGIN    
             
         SET @n_CurrentPage = @n_CurrentPage + 1    
             
       IF (@n_CurrentPage>@n_TTLpage)     
       BEGIN    
         BREAK;    
       END      
        
         INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09                     
                               ,Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22                   
                               ,Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34                    
                               ,Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44                     
                               ,Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54                   
                               ,Col55,Col56,Col57,Col58,Col59,Col60)     
         SELECT TOP 1 Col01,Col02,Col03,Col04,col05,col06,col07,col08,'','',                     
                      '','','','','', '','','','','',                  
                      col21,col22,col23,col24,col25, col26,col27,'','','',                  
                      '','','','','', '','','','','',                     
                      '','','','','', '','','','','',                   
                      '','','','','', '','','',col59,col60    
          FROM  #Result     
          WHERE Col60='O'     
              
         
           
               SET @c_SKU01 = ''    
               SET @c_SKU02 = ''    
               SET @c_SKU03 = ''    
               SET @c_SKU04 = ''    
               SET @c_SKU05 = ''   
               SET @c_SDESCR01 = ''  
               SET @c_SDESCR02 = ''  
               SET @c_SDESCR03 = ''  
               SET @c_SDESCR04 = ''  
               SET @c_SDESCR05 = ''  
               --START ML01  
               SET @c_ODNotes01 = ''  
               SET @c_ODNotes02 = ''  
               SET @c_ODNotes03 = ''  
               SET @c_ODNotes04 = ''  
               SET @c_ODNotes05 = ''  
               --END ML01  
               SET @c_SKUQty01 = ''    
               SET @c_SKUQty02 = ''    
               SET @c_SKUQty03 = ''    
               SET @c_SKUQty04 = ''    
               SET @c_SKUQty05 = ''     
               SET @n_pskuqty  = 0     

               --CS01 S
               SET @c_QtyUOM01 = ''
               SET @c_QtyUOM02 = ''
               SET @c_QtyUOM03 = ''
               SET @c_QtyUOM04 = ''
               SET @c_QtyUOM05 = ''

               --CS01 E        
          
       END        
                
          
      SELECT @c_sku = SKU,     
             @n_skuqty = SUM(PQty),    
             @c_sdescr = SDescr,  
             @c_odnotes = ODNotes, --ML01  
             @c_uom = UOM          --CS01
      FROM #TEMPPDSKULOC     
      WHERE ID = @n_intFlag    
      GROUP BY SKU,SDescr,ODNotes,UOM --ML01    --CS01
  
      
      IF (@n_intFlag%@n_MaxLine) = 1   
       BEGIN     
         --SELECT '1'           
        SET @c_sku01    = @c_sku     
        SET @c_SDESCR01 = @c_sdescr  
        SET @c_ODNotes01 = @c_odnotes --ML01  
        SET @c_SKUQty01 = CONVERT(NVARCHAR(10),@n_skuqty)   
        SET @c_QtyUOM01 =  @c_SKUQty01 + SPACE(1) + @c_uom   --CS01      
       END            
           
       ELSE IF (@n_intFlag%@n_MaxLine) = 2    
       BEGIN        
         --SELECT '2'         
        SET @c_sku02 = @c_sku    
        SET @c_SDESCR02 = @c_sdescr  
        SET @c_ODNotes02 = @c_odnotes --ML01  
        SET @c_SKUQty02 = CONVERT(NVARCHAR(10),@n_skuqty)     
        SET @c_QtyUOM02 =  @c_SKUQty02 + SPACE(1) + @c_uom   --CS01          
       END      
       ELSE IF (@n_intFlag%@n_MaxLine) = 3    
       BEGIN        
         --SELECT '3'         
        SET @c_sku03 = @c_sku  
        SET @c_SDESCR03 = @c_sdescr   
        SET @c_ODNotes03 = @c_odnotes --ML01  
        SET @c_SKUQty03 = CONVERT(NVARCHAR(10),@n_skuqty)   
        SET @c_QtyUOM03 =  @c_SKUQty03 + SPACE(1) + @c_uom   --CS01            
       END      
      ELSE IF (@n_intFlag%@n_MaxLine) = 4    
       BEGIN        
         --SELECT '4'         
        SET @c_sku04 = @c_sku    
        SET @c_SDESCR04 = @c_sdescr   
        SET @c_ODNotes04 = @c_odnotes --ML01  
        SET @c_SKUQty04 = CONVERT(NVARCHAR(10),@n_skuqty)     
        SET @c_QtyUOM04 =  @c_SKUQty04 + SPACE(1) + @c_uom   --CS01          
       END      
       ELSE IF (@n_intFlag%@n_MaxLine) = 0   
       BEGIN        
         --SELECT '5'         
        SET @c_sku05 = @c_sku    
        SET @c_SDESCR05 = @c_sdescr  
        SET @c_ODNotes05 = @c_odnotes --ML01  
        SET @c_SKUQty05 = CONVERT(NVARCHAR(10),@n_skuqty)     
        SET @c_QtyUOM05 =  @c_SKUQty05 + SPACE(1) + @c_uom   --CS01          
       END              
  
  
       SET @n_pskuqty = (CAST(@c_SKUQty01 AS INT ) + CAST(@c_SKUQty02 AS INT ) + CAST(@c_SKUQty03 AS INT )  
                         + CAST(@c_SKUQty04 AS INT ) + CAST(@c_SKUQty05 AS INT ) )        
              
        UPDATE #Result                      
       -- SET Col06 = @n_ttlnetwgt,       
        --SET Col09 = CASE WHEN @c_ODNotes01 <> '' THEN @c_ODNotes01 ELSE @c_SDESCR01 END, --ML01  --CS01 S
        --    Col10 = CASE WHEN @c_ODNotes02 <> '' THEN @c_ODNotes02 ELSE @c_SDESCR02 END, --ML01                    
        --    Col11 = CASE WHEN @c_ODNotes03 <> '' THEN @c_ODNotes03 ELSE @c_SDESCR03 END, --ML01  
        --    Col12 = CASE WHEN @c_ODNotes04 <> '' THEN @c_ODNotes04 ELSE @c_SDESCR04 END, --ML01               
        --    Col13 = CASE WHEN @c_ODNotes05 <> '' THEN @c_ODNotes05 ELSE @c_SDESCR05 END, --ML01  
        SET Col09 = @c_ODNotes01 , 
            Col10 = @c_ODNotes02 ,                    
            Col11 = @c_ODNotes03 ,  
            Col12 = @c_ODNotes04 ,                
            Col13 = @c_ODNotes05 ,    
            --Col14 = @c_SKUQty01,    
            --Col15 = @c_SKUQty02,   
            --Col16 = @c_SKUQty03,  
            --Col17 = @c_SKUQty04,             
            --Col18 = @c_SKUQty05,           
            Col14 = @c_QtyUOM01,    
            Col15 = @c_QtyUOM02,   
            Col16 = @c_QtyUOM03,  
            Col17 = @c_QtyUOM04,             
            Col18 = @c_QtyUOM05,           --CS01 E 
            Col19 = CASE WHEN @c_lastpage = 'Y' THEN @n_qtybyctn ELSE '' END,   
            Col20 = @n_CurrentPage    
        WHERE ID = @n_CurrentPage     
              
         -- SELECT * FROM #Result      
             
         UPDATE  #TEMPPDSKULOC    
         SET Retrieve ='Y'    
         WHERE ID= @n_intFlag     
                        
            
     SET @n_intFlag = @n_intFlag + 1      
    
     IF @n_intFlag > @n_CntRec    
     BEGIN    
       BREAK;    
     END          
   END    
   FETCH NEXT FROM CUR_RowNoLoop INTO @c_pickslipno,@c_cartonno            
            
      END -- While                       
      CLOSE CUR_RowNoLoop                      
      DEALLOCATE CUR_RowNoLoop       
       
           
   SELECT * FROM #Result (nolock)              
   ORDER BY col02   
                
EXIT_SP:        
      
   SET @d_Trace_EndTime = GETDATE()      
   SET @c_UserName = SUSER_SNAME()      
         
   --EXEC isp_InsertTraceInfo       
   --   @c_TraceCode = 'BARTENDER',      
   --   @c_TraceName = 'isp_BT_Bartender_SHIPUCCLBL_06',      
   --   @c_starttime = @d_Trace_StartTime,      
   --   @c_endtime = @d_Trace_EndTime,      
   --   @c_step1 = @c_UserName,      
   --   @c_step2 = '',      
   --   @c_step3 = '',      
   --   @c_step4 = '',      
   --   @c_step5 = '',      
   --   @c_col1 = @c_Sparm01,       
   --   @c_col2 = @c_Sparm02,      
   --   @c_col3 = @c_Sparm03,      
   --   @c_col4 = @c_Sparm04,      
   --   @c_col5 = @c_Sparm05,      
   --   @b_Success = 1,      
   --   @n_Err = 0,      
   --   @c_ErrMsg = ''                  
       
      
                                      
END -- procedure       
GO
GRANT EXECUTE ON isp_BT_Bartender_SHIPUCCLBL_06 TO NSQL
GO    
    
  