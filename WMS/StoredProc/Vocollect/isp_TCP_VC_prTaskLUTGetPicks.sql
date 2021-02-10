IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_TCP_VC_prTaskLUTGetPicks]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_TCP_VC_prTaskLUTGetPicks]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/                
 /* Store Procedure:  isp_TCP_VC_prTaskLUTGetPicks                       */                
 /* Creation Date: 26-Feb-2013                                           */                
 /* Copyright: IDS                                                       */                
 /* Written by: Shong                                                    */                
 /*                                                                      */                
 /* Purposes: The message retrieves individual pick item records for a   */                
 /*           picking assignment from the host system.                   */                
 /*                                                                      */                
 /* Updates:                                                             */                
 /* Date         Author    Purposes                                      */           
 /* 27-03-2013   ChewKP    Revise (ChewKP01)                             */          
 /* 27-10-2014   ChewKP    Sending whole pickslip task to Voice          */    
 /*                        (ChewKP02)                                    */     
 /* 14-01-2015   ChewKP    Convert Qty to Pick by PickDetail.UOM         */  
 /* 15-01-2015   ChewKP    Set @c_RtnMessage to MAX                      */
/*************************************************************************/            
CREATE PROC [dbo].[isp_TCP_VC_prTaskLUTGetPicks] (                
    @c_TranDate      NVARCHAR(20)                
   ,@c_DevSerialNo   NVARCHAR(20)                
   ,@c_OperatorID    NVARCHAR(20)                
   ,@c_GroupID       NVARCHAR(20)  -- SourceKey -- (ChewKP01)        
   ,@c_ShortSkipFlag NVARCHAR(10)  -- Set to 1 only when the VoiceApplication is requesting to go back for shorts before passing the assignment                
   ,@c_GoBackShort   NVARCHAR(10)                
   ,@c_OrderType     NVARCHAR(10)  -- 0 = normal order, 1 = reverse order                
   ,@n_SerialNo      INT                
   ,@c_RtnMessage    NVARCHAR(MAX) OUTPUT                    
   ,@b_Success       INT = 1 OUTPUT                
   ,@n_Error         INT = 0 OUTPUT                
   ,@c_ErrMsg        NVARCHAR(255) = '' OUTPUT                 
                
)                
AS                
BEGIN                
   DECLARE @c_ErrorCode         NVARCHAR(20) --  0: No error. The VoiceApplication proceeds.                
                                            -- 98: Critical error. If this error is received,                 
                                            --     the VoiceApplication speaks the error message, and forces the operator to sign off.                 
                                            -- 99: Informational error. The VoiceApplication speaks the informational error message,                 
                                            --     but does not force the operator to sign off.                
         , @c_Message            NVARCHAR(400)                
         , @c_PickStatus         NVARCHAR(1)     -- N = not picked, N = not picked, S = skipped, G = go back for short                     
         , @c_BaseItem           NVARCHAR(1)     -- 0 = item is not spoken in base item, 1 = item is spoken in base item summary                
         , @c_Sequence           NVARCHAR(10) -- TaskDetailKey                 
         , @c_LOC                NVARCHAR(10)                
         , @c_Region             NVARCHAR(10) -- Numeric position where items for the work ID should be placed.                
         , @c_PreAisleDirec      NVARCHAR(10) -- Pre-Aisle Direction                
         , @c_Aisle              NVARCHAR(10) -- Aisle                
         , @c_PostAisleDirec     NVARCHAR(50) -- Post-Aisle Direction                
         , @c_Bay                NVARCHAR(10) -- Location Bay                
         , @n_QtyToPick          INT                          
         , @c_UOMDesc            NVARCHAR(50)  -- UOM description                   
         , @c_SKU                NVARCHAR(20)                 
         , @c_VariableWeight     NVARCHAR(1)      -- 0 = device does not prompt the operator to speak weight(s) for the pick                
                                              -- 1 = device prompts the operator to speak weight(s) for the pick                
         , @c_WeightMin          NVARCHAR(10)  -- Only required when the variable weight field = 1.                
         , @c_WeightMax          NVARCHAR(10)  -- Only required when the variable weight field = 1.                         
         , @n_QtyPicked          INT                
         , @c_CheckDigit         NVARCHAR(10)  -- Check digits of the pickGÇÿs location.                
         , @c_ScanSKU            NVARCHAR(20)                
         , @c_SpokenSKU          NVARCHAR(5)                
         , @c_SKUDesc            NVARCHAR(60)                
         , @c_Size               NVARCHAR(10)                
         , @c_UPC                NVARCHAR(20)                
         , @c_AssignID           NVARCHAR(10)  -- TaskDetailKey                
         , @c_AssignIDDesc       NVARCHAR(100)                
         , @c_DeliveryLoc        NVARCHAR(10)                
         , @c_CombineFlag        NVARCHAR(1)                
         , @c_Store              NVARCHAR(100)                
         , @c_CaseLblChkDigit    NVARCHAR(10)                
         , @c_TargetContainer    NVARCHAR(20)      -- Alter Column Length (ChewKP01)         
         , @c_CaptureLottable    NVARCHAR(1)       -- 0 = No, 1=Yes                       
         , @c_PickMessage        NVARCHAR(250)                
         , @c_VerifyLoc          NVARCHAR(1)                
         , @c_CycleCount         NVARCHAR(1)                
         , @c_CaptureSerialNo    NVARCHAR(1)                
         , @c_SpeakSKUDesc       NVARCHAR(1)                
         , @c_PackKey            NVARCHAR(10)                
         , @c_UOM                NVARCHAR(5)                
         , @c_OrderKey           NVARCHAR(10)                
         , @c_FromID             NVARCHAR(18)                
         , @c_StorerKey          NVARCHAR(15)            
         , @c_Status             NVARCHAR(10)            
         , @c_AreaKey            NVARCHAR(10)            
         , @c_NextTaskdetailkey  NVARCHAR(10)               
         , @c_TTMTasktype        NVARCHAR(20)            
         , @c_RefKey01           NVARCHAR(20)            
         , @c_RefKey02           NVARCHAR(20)            
         , @c_RefKey03           NVARCHAR(20)            
         , @c_RefKey04           NVARCHAR(20)            
         , @c_RefKey05           NVARCHAR(20)            
         , @c_SuggToLoc          NVARCHAR(10)            
         , @c_outstring          NVARCHAR(255)              
         , @c_TaskDetailKey      NVARCHAR(10)          
         , @n_Counter            INT        
         , @n_GetNextTask        INT        
         , @c_PickZone           NVARCHAR(10)        
         , @c_Aisle_Desc         NVARCHAR(10)    
         , @c_PrevSKU            NVARCHAR(20)  
         , @c_PrevUOM            NVARCHAR(10)  
         , @c_PrevBatch          NVARCHAR(18)   
         , @c_PrevLOC            NVARCHAR(10)        
         , @n_UOMQTY             INT  
                         
   DECLARE @c_LottableDesc    NVARCHAR(60)                
         , @c_Lottable01Label NVARCHAR(20)                
         , @c_Lottable02Label NVARCHAR(20)                
         , @c_Lottable03Label NVARCHAR(20)                
         , @c_Lottable04Label NVARCHAR(20)              
         , @c_LangCode        NVARCHAR(10)        
         , @c_LottableValue   NVARCHAR(18)      
         , @c_Message02       NVARCHAR(20)  
               
           
   SET @c_LangCode = 'ENG'                         
   SET @c_PickStatus = N'N'                
   SET @c_BaseItem   = N'0'                
   SET @c_Sequence = N'1'                
   SET @c_VariableWeight = N'0'                
   SET @c_WeightMin=N'0'                
   SET @c_WeightMax=N'0'               
   SET @n_QtyPicked=0                
   SET @c_ScanSKU=N''                
   SET @c_SpokenSKU=N''                
   SET @c_CombineFlag=N'0'                
   SET @c_CaseLblChkDigit=N''                
   SET @c_TargetContainer=N''                
   SET @c_CaptureLottable=N'0'                
   SET @c_PickMessage = N''                
   SET @c_VerifyLoc = N'1'                
   SET @c_CycleCount = N'0'                
   SET @c_CaptureSerialNo=N'0'                
   SET @c_SpeakSKUDesc = N'1'                
   SET @c_FromID = N''                          
   SET @c_Bay = N''                
   SET @c_Lottable01Label = N''                
   SET @c_Lottable02Label = N''                
   SET @c_Lottable03Label = N''                
   SET @c_Lottable04Label = N''                
   SET @c_LottableDesc = N''                
   SET @c_TaskDetailKey = ''         
   SET @n_Counter = 1        
   SET @c_RtnMessage = ''                
   SET @c_ErrorCode = 0                 
   SET @c_Message = ''            
   SET @n_GetNextTask = 0          
   SET @c_Aisle_Desc = N''          
   SET @c_CheckDigit = ''      
   SET @c_Message02 = ''  
   SET @c_PrevSKU =''  
   SET @c_PrevUOM=''  
   SET @c_PrevBatch=''   
   SET @c_PrevLOC=''       
   SET @n_UOMQTY = 0 
               
   SELECT @c_TaskDetailKey = V_TaskDetailKey           
   FROM rdt.rdtMobRec WITH (NOLOCK)           
   WHERE DeviceID = @c_DevSerialNo           
        
   SELECT @c_LangCode = r.DefaultLangCode              
   FROM rdt.RDTUser r (NOLOCK)              
   WHERE r.UserName = @c_OperatorID                          
                       
   GenGetPicks:          
    
   SELECT TOP 1      
        @c_StorerKey = va.Storerkey           
   FROM VoiceAssignment AS va WITH (NOLOCK)               
   WHERE va.GroupID  = @c_GroupID              
   AND   va.UserName = @c_OperatorID                
   AND   va.[Status] = '0'                  
                  
   IF ISNULL(RTRIM(@c_StorerKey), '') <> ''    
   BEGIN                         
      -- Flag to indicate whether the VoiceApplication should capture the serial                 
      -- number of each individual item picked                
      SET @c_CaptureSerialNo = '0'    
      SELECT @c_CaptureSerialNo = ISNULL(sc.SValue,'0')                 
      FROM StorerConfig sc WITH (NOLOCK)                  
      WHERE sc.StorerKey = @c_StorerKey                 
      AND   sc.ConfigKey = 'VoicePK_CaptureSerialNo'                 
                   
      -- Flag to indicate whether the VoiceApplication should speak the item description                 
      -- of the item being picked in the pick prompt.                
      SET @c_SpeakSKUDesc = '0'    
      SELECT @c_SpeakSKUDesc = ISNULL(sc.SValue,'0')                 
      FROM StorerConfig sc WITH (NOLOCK)                  
      WHERE sc.StorerKey = @c_StorerKey                 
      AND   sc.ConfigKey = 'VoicePK_SpeakSKUDesc'                 
    
      SET @c_CaptureLottable = '0'                
      SELECT @c_CaptureLottable = ISNULL(sc.SValue,'0'),               
               @c_LottableDesc = CASE WHEN sc.SValue IN ('1','2','3','4') THEN sc.ConfigDesc ELSE '' END                 
      FROM StorerConfig sc WITH (NOLOCK)                 
      WHERE sc.StorerKey = @c_StorerKey                
      AND   sc.ConfigKey = 'VoicePK_CaptureLottable'                
          
      DECLARE CursorGetPicks CURSOR LOCAL FAST_FORWARD READ_ONLY FOR            
      SELECT td.FromLoc, -- @c_LOC                 
             td.AreaKey, -- @c_Region                
             '', -- ISNULL(L.PickZone, ''),  -- @c_PickZone      
             L.LocAisle,                 
             '', -- @c_PostAisleDirec               
             ISNULL(L.LocBay,''),  -- @c_Bay              
             L.LocAisle,                 
             TD.Qty,                 
             SKU.PackKey,           
             td.UOM,                 
             TD.Sku,                
             L.LocCheckDigit,                 
             SKU.DESCR,                
             SKU.[Size],                 
             '', --SKU.ALTSKU,  -- @c_UPC               
             vad.AssignmentID,     
             va.GroupID,  -- @c_AssignIDDesc               
             ISNULL(TD.ToLoc,''), -- @c_DeliveryLoc                
             TD.OrderKey, -- @c_OrderKey                
             ISNULL(TD.FromID, ''),                
             TD.Storerkey,                
             ISNULL(SKU.LOTTABLE01LABEL, ''),                
             ISNULL(SKU.LOTTABLE02LABEL, ''),                
             ISNULL(SKU.LOTTABLE03LABEL, ''),                
             ISNULL(SKU.LOTTABLE04LABEL, ''),           
             TD.DropID,  -- @c_TargetContainer      
             CAST(vad.SeqNo AS VARCHAR(10)),  
             TD.Message02   
               
      FROM VoiceAssignment AS va WITH (NOLOCK)        
      JOIN VoiceAssignmentDetail AS vad WITH (NOLOCK) ON vad.AssignmentID = va.AssignmentID    
      JOIN TaskDetail td WITH (NOLOCK)ON vad.TaskDetailKey = td.TaskDetailKey                      
      JOIN SKU WITH (NOLOCK) ON SKU.Storerkey = td.Storerkey AND SKU.Sku = td.Sku                 
      JOIN LOC l WITH (NOLOCK) ON td.FromLoc = l.Loc                
      JOIN FACILITY f WITH (NOLOCK) ON f.Facility = l.Facility      
      WHERE va.GroupID  = @c_GroupID              
      AND   va.UserName = @c_OperatorID     
      AND   vad.[Status] = '0'                
      AND   td.[Status] = '3'     
      Order by vad.SeqNo       
              
              
      OPEN CursorGetPicks                    
           
      FETCH NEXT FROM CursorGetPicks INTO         
               @c_LOC             , @c_Region            , @c_PickZone            , @c_Aisle             , @c_PostAisleDirec        
             , @c_Bay             , @c_Aisle             , @n_QtyToPick           , @c_PackKey           , @c_UOM        
             , @c_SKU             , @c_CheckDigit        , @c_SKUDesc             , @c_Size              , @c_UPC        
             , @c_AssignID        , @c_AssignIDDesc      , @c_DeliveryLoc         , @c_OrderKey          , @c_FromID        
             , @c_StorerKey       , @c_Lottable01Label   , @c_Lottable02Label     , @c_Lottable03Label   , @c_Lottable04Label        
             , @c_TargetContainer , @c_Sequence          , @c_Message02  
              
              
      WHILE @@FETCH_STATUS <> -1             
      BEGIN  
         IF ISNULL(RTRIM(@c_PrevSKU),'') = ''   
         BEGIN  
            SET @c_PrevSKU = @c_SKU  
            SET @c_PrevUOM = @c_UOM  
            SET @c_PrevLOC = @c_LOC  
            SET @c_PrevBatch = @c_Message02  
         END    
         ELSE  
         BEGIN  
            IF @c_PrevSKU <> @c_SKU OR   
               @c_PrevUOM <> @c_UOM OR   
               @c_PrevLOC <> @c_LOC   
            BEGIN  
               SET @c_CombineFlag = '0'  
            END  
            ELSE  
            BEGIN  
               IF @c_PrevBatch <> @c_Message02  
                  SET @c_CombineFlag = CONVERT(VARCHAR(2), CAST(@c_CombineFlag AS INT) + 1)  
            END  
            SET @c_PrevSKU = @c_SKU  
            SET @c_PrevUOM = @c_UOM  
            SET @c_PrevLOC = @c_LOC  
            SET @c_PrevBatch = @c_Message02  
              
         END  
                         
         SET @c_Store = ''                    
         SELECT TOP 1     
               @c_Store = ISNULL(o.ConsigneeKey,'')                
         FROM ORDERS o WITH (NOLOCK)                
         JOIN STORER s WITH (NOLOCK) ON s.StorerKey = o.ConsigneeKey    
         WHERE o.OrderKey = @c_OrderKey                 
                         
         IF @c_CaptureLottable IN ('1','2','3','4')                 
         BEGIN                
            IF @c_CaptureLottable = '1'      
            BEGIN      
               SELECT @c_LottableDesc = UDF01      
               FROM dbo.Codelkup WITH (NOLOCK)      
               WHERE ListName = 'LOTTABLE01'       
               AND Code = @c_Lottable01Label      
                     
               SELECT @c_LottableValue = ISNULL(LA.Lottable01,'')      
               FROM dbo.LotAttribute LA WITH (NOLOCK)      
               INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON PD.Lot = LA.Lot      
               WHERE PD.TaskDetailKey = @c_TaskDetailKey      
               AND PD.StorerKey = @c_StorerKey      
               AND PD.SKU = @c_SKU      
            END      
            ELSE IF @c_CaptureLottable = '2'      
            BEGIN      
               SELECT @c_LottableDesc = UDF01      
               FROM dbo.Codelkup WITH (NOLOCK)      
               WHERE ListName = 'LOTTABLE02'       
               AND Code = @c_Lottable02Label      
                     
               SELECT @c_LottableValue = ISNULL(LA.Lottable02,'')      
               FROM dbo.LotAttribute LA WITH (NOLOCK)      
               INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON PD.Lot = LA.Lot      
               WHERE PD.TaskDetailKey = @c_TaskDetailKey      
               AND PD.StorerKey = @c_StorerKey      
               AND PD.SKU = @c_SKU      
                     
               IF @c_LottableValue = ''      
               BEGIN      
                  SELECT @c_LottableDesc = UDF01      
                  FROM dbo.Codelkup WITH (NOLOCK)      
                  WHERE ListName = 'LOTTABLE04'       
                  AND Code = @c_Lottable02Label      
                        
                  SELECT @c_LottableValue = ISNULL(LA.Lottable04,'')      
                  FROM dbo.LotAttribute LA WITH (NOLOCK)      
                  INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON PD.Lot = LA.Lot      
                  WHERE PD.TaskDetailKey = @c_TaskDetailKey      
                  AND PD.StorerKey = @c_StorerKey      
                  AND PD.SKU = @c_SKU                          
               END             
            END      
            ELSE IF @c_CaptureLottable = '3'      
            BEGIN      
                     
               SELECT @c_LottableDesc = UDF01      
               FROM dbo.Codelkup WITH (NOLOCK)      
               WHERE ListName = 'LOTTABLE03'       
               AND Code = @c_Lottable03Label      
                     
               SELECT @c_LottableValue = ISNULL(LA.Lottable03,'')      
               FROM dbo.LotAttribute LA WITH (NOLOCK)      
               INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON PD.Lot = LA.Lot      
               WHERE PD.TaskDetailKey = @c_TaskDetailKey      
               AND PD.StorerKey = @c_StorerKey      
               AND PD.SKU = @c_SKU      
                     
            END      
            ELSE IF @c_CaptureLottable = '4'      
            BEGIN      
                     
               SELECT @c_LottableDesc = UDF01      
               FROM dbo.Codelkup WITH (NOLOCK)      
               WHERE ListName = 'LOTTABLE04'       
               AND Code = @c_Lottable04Label      
                     
               SELECT @c_LottableValue = ISNULL(CAST (LA.Lottable04 AS NVARCHAR(18)),'')      
               FROM dbo.LotAttribute LA WITH (NOLOCK)      
               INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON PD.Lot = LA.Lot      
               WHERE PD.TaskDetailKey = @c_TaskDetailKey      
               AND PD.StorerKey = @c_StorerKey      
               AND PD.SKU = @c_SKU      
                     
            END      
            ELSE      
            BEGIN      
               SET @c_LottableDesc = 'None'           
            END      
                  
            IF @c_LottableDesc = 'None'                
            BEGIN                
               SET @c_CaptureLottable = '0'                
               SET @c_LottableDesc = ''                
            END                 
            ELSE      
            BEGIN      
               -- Do not Prompt Capture Lot, replace by Picking Message      
               -- SET @c_CaptureLottable = '1'       
               SET @c_LottableDesc = [dbo].[fnc_GetVC_Message](@c_LangCode, 'vc_prTaskLUTGetPicks_05', N'First 4 Digit of',@c_LottableDesc,'','','','')      
               --SET @c_UPC = @c_LottableDesc + ' ' + @c_LottableValue      
      
               --SET @c_PickMessage = @c_LottableDesc + ' ' + LEFT(LTRIM(@c_LottableValue),4)      
                                    
               --SET @c_CaptureLottable = '0'                
               --SET @c_LottableDesc = ''                
            END      
                                                
         END                         
         ELSE                
         BEGIN                
            SET @c_CaptureLottable = '0'                
            SET @c_LottableDesc = ''                 
         END                
                            
         IF ISNULL(RTRIM(@c_UOM), '') = ''              
            SET @c_UOM = '6'              
                          
         SET @c_UOMDesc = 'Units'                
         SELECT @c_UOMDesc = CASE WHEN @c_LangCode = 'ENG' THEN C.Description ELSE ISNULL(C.[Long], 'Units') END                 
         FROM CODELKUP c WITH (NOLOCK)                 
         WHERE Code = @c_UOM                 
         AND   c.LISTNAME = 'TMUOM'  
         
         -- Convert Qty by UOM 
         IF @c_UOM <> '6'
         BEGIN
            SET @n_UOMQTY = ISNULL(rdt.rdtConvUOMQTY( @c_StorerKey, @c_SKU, @n_QtyToPick, '6', @c_UOM), 0) -- Convert to QTY in master UOM
         END
                      
--         IF LEN(ISNULL(RTRIM(@c_FromID),'')) > 0                 
--         BEGIN                
--            SET @c_PickMessage = [dbo].[fnc_GetVC_Message](@c_LangCode, 'vc_prTaskLUTGetPicks_01', N'Pallet ID %s',RIGHT(RTRIM(@c_FromID), 3),'','','','')                
--         END                
                               
         IF ISNULL(RTRIM(@c_Bay),'') = ''                 
         BEGIN              
            SET @c_PostAisleDirec   = [dbo].[fnc_GetVC_Message](@c_LangCode, 'vc_prTaskLUTGetPicks_02', N'Go to Location %s',@c_LOC,'','','','')                
         END                                    
                      
         IF ISNULL(RTRIM(@c_PickZone),'') <> ''        
         BEGIN        
            SET @c_PreAisleDirec = [dbo].[fnc_GetVC_Message](@c_LangCode, 'vc_prTaskLUTGetPicks_04', N'Zone %s',@c_PickZone,'','','','')               
         END        
         ELSE        
            SET @c_PreAisleDirec = ''                
                 
         SET @c_Aisle_Desc = ''       
         SET @c_Aisle_Desc = LEFT(RTRIM(@c_Aisle),1) + ' ' +  SUBSTRING(RTRIM(@c_Aisle),2,1 )
         
         PRINT @c_Aisle
         PRINT @c_Aisle_Desc
--         SET @n_Counter = 1         
--         WHILE @n_Counter <= LEN(@c_Aisle)        
--         BEGIN        
--            SET @c_Aisle_Desc = ISNULL(RTRIM(@c_Aisle_Desc),'') +         
--                                CASE WHEN ISNULL(RTRIM(@c_Aisle_Desc),'') = '' THEN '' ELSE ' ' END +         
--                                SUBSTRING(@c_Aisle, @n_Counter, 1)        
--                                        
--           SET @n_Counter = @n_Counter + 1                             
--         END        
  
  
         SET @c_PickMessage = @c_SKU  
                     
         SET @c_RtnMessage = RTRIM(@c_RtnMessage) +         
              CASE WHEN LEN(ISNULL(RTRIM(@c_RtnMessage),'')) = 0 THEN '' ELSE '<CR><LF>' END +         
              ISNULL(RTRIM(@c_PickStatus),'') + ',' +                 
              ISNULL(RTRIM(@c_BaseItem),'')   + ',' +                
              ISNULL(RTRIM(@c_Sequence),'')   + ',' +                 
              ISNULL(RTRIM(@c_LOC),'')        + ',' +                
              ISNULL(RTRIM(@c_Region),'')     + ',' +                
              ISNULL(RTRIM(@c_PreAisleDirec),'')  + ',' + -- 6                 
              ISNULL(RTRIM(@c_Aisle_Desc),'')          + ',' + -- 7                
              ISNULL(RTRIM(@c_PostAisleDirec),'') + ',' + -- 8                
              ISNULL(RTRIM(@c_Bay),'') + N',' + -- 9 Slot                
              CAST(@n_UOMQTY AS NVARCHAR(10)) + ',' + -- 10                
              ISNULL(RTRIM(@c_UOMDesc),'') + ',' + -- 11                
              ISNULL(RTRIM(@c_SKU),'') +  ',' + -- 12                
              ISNULL(RTRIM(@c_VariableWeight),'') + ',' + -- 13                
              ISNULL(RTRIM(@c_WeightMin),'') + ',' + -- 14                
              ISNULL(RTRIM(@c_WeightMax),'') + ',' + -- 15                
              CAST(@n_QtyPicked AS NVARCHAR(10)) + ',' + -- 16                
              ISNULL(RTRIM(@c_CheckDigit),'')  + ',' + -- 17                 
              ISNULL(RTRIM(@c_ScanSKU),'')  + ',' + -- 18                
              ISNULL(RTRIM(@c_SpokenSKU),'')  + ',' + -- 19                 
              ISNULL(RTRIM(@c_PickMessage),'')  + ',' + -- 20  
              ISNULL(RTRIM(@c_Size),'')  + ',' + -- 21                
              ISNULL(RTRIM(@c_UPC),'')  + ',' + -- 22                
              ISNULL(RTRIM(@c_AssignID),'')  + ',' + -- 23                
              ISNULL(RTRIM(@c_AssignIDDesc),'')  + ',' + -- 24                
              ISNULL(RTRIM(@c_DeliveryLoc),'')  + ',' + -- 25                
              ISNULL(RTRIM(@c_CombineFlag),'')  + ',' + -- 26                
              ISNULL(RTRIM(@c_Store),'')  + ',' + -- 27                
              ISNULL(RTRIM(@c_CaseLblChkDigit),'')  + ',' + -- 28                
              ISNULL(RTRIM(@c_TargetContainer),'')  + ',' + -- 29                
              ISNULL(RTRIM(@c_CaptureLottable),'')  + ',' + -- 30                
              ISNULL(RTRIM(@c_LottableDesc),'')  + ',' + -- 31                
              ISNULL(RTRIM(@c_Message02),'')  + ',' + -- 32                
              ISNULL(RTRIM(@c_VerifyLoc),'')  + ',' + -- 33                
              ISNULL(RTRIM(@c_CycleCount),'')  + ',' + -- 34                 
              ISNULL(RTRIM(@c_CaptureSerialNo),'')  + ',' + -- 35                
              ISNULL(RTRIM(@c_SpeakSKUDesc),'')  + ',' + -- 36                
              ISNULL(RTRIM(@c_ErrorCode),'')  + ',' +                 
              ISNULL(RTRIM(@c_Message),'')           
                                  
                  
         SET @n_Counter = @n_Counter + 1              
                                                    
         FETCH NEXT FROM CursorGetPicks INTO         
               @c_LOC             , @c_Region            , @c_PickZone            , @c_Aisle             , @c_PostAisleDirec        
             , @c_Bay             , @c_Aisle             , @n_QtyToPick           , @c_PackKey           , @c_UOM        
             , @c_SKU             , @c_CheckDigit        , @c_SKUDesc             , @c_Size              , @c_UPC        
             , @c_AssignID        , @c_AssignIDDesc      , @c_DeliveryLoc         , @c_OrderKey          , @c_FromID        
             , @c_StorerKey       , @c_Lottable01Label   , @c_Lottable02Label     , @c_Lottable03Label   , @c_Lottable04Label        
             , @c_TargetContainer , @c_Sequence          , @c_Message02  
                                       
      END        
      CLOSE CursorGetPicks                    
      DEALLOCATE CursorGetPicks                                   
   END            
   --ELSE IF @c_Status = '9' -- Task Completed            
           
--   IF LEN(ISNULL(@c_RtnMessage,'')) = 0 AND @n_GetNextTask = 0         
--   BEGIN            
--      SET @n_GetNextTask = 1        
--              
--      -- Get Next Task          
--      SELECT @c_AreaKey   = r.V_String1,             
--             @c_SuggToLoc = r.V_Loc            
--      FROM RDT.RDTMOBREC r WITH (NOLOCK)            
--      WHERE r.UserName = @c_OperatorID             
--      AND   r.DeviceID = @c_DevSerialNo            
--                 
--      SELECT @c_ErrMsg = '', @c_NextTaskdetailkey = '', @c_TTMTasktype = ''            
--          
--      EXEC dbo.nspTMTM01            
--       @c_sendDelimiter = null            
--      ,  @c_ptcid         = 'VOICE'            
--      ,  @c_userid        = @c_OperatorID            
--      ,  @c_taskId        = 'VOICE'            
--      ,  @c_databasename  = NULL            
--      ,  @c_appflag       = NULL            
--      ,  @c_recordType    = NULL            
--      ,  @c_server        = NULL            
--      , @c_ttm           = NULL            
--      ,  @c_areakey01     = @c_AreaKey            
--      ,  @c_areakey02     = ''            
--      ,  @c_areakey03     = ''            
--      ,  @c_areakey04     = ''            
--      ,  @c_areakey05     = ''            
--      ,  @c_lastloc       = @c_SuggToLoc            
--      ,  @c_lasttasktype  = 'VNPK'            
--      ,  @c_outstring     = @c_outstring     OUTPUT            
--      ,  @b_Success       = @b_Success       OUTPUT            
--      ,  @n_err           = @n_Error         OUTPUT            
--      ,  @c_errmsg        = @c_ErrMsg        OUTPUT            
--      ,  @c_taskdetailkey = @c_NextTaskdetailkey OUTPUT            
--      ,  @c_ttmtasktype   = @c_TTMTasktype   OUTPUT            
--      ,  @c_RefKey01      = @c_RefKey01      OUTPUT              
--      ,  @c_RefKey02      = @c_RefKey02      OUTPUT              
--      ,  @c_RefKey03      = @c_RefKey03      OUTPUT              
--      ,  @c_RefKey04      = @c_RefKey04      OUTPUT              
--      ,  @c_RefKey05      = @c_RefKey05      OUTPUT              
--                
--      IF ISNULL(RTRIM(@c_NextTaskdetailkey),'') <> ''            
--      BEGIN            
--         SET @c_GroupID = ''        
--                 
--         --SET @c_GroupID       = @c_NextTaskdetailkey  -- (ChewKP01)          
--         SELECT @c_GroupID = SourceKey        
--         FROM dbo.TaskDetail WITH (NOLOCK)           
--         WHERE TaskDetailKey = @c_NextTaskdetailkey          
--                      
--         SET @c_TaskDetailKey = @c_NextTaskdetailkey          
--                      
--         UPDATE rdt.RDTMOBREC            
--            SET V_TaskDetailKey =  @c_NextTaskdetailkey            
--         FROM RDT.RDTMOBREC WITH (NOLOCK)            
--         WHERE UserName = @c_OperatorID             
--         AND   DeviceID = @c_DevSerialNo              
--                   
--         GOTO GenGetPicks                                           
--      END            
--      ELSE            
--      BEGIN            
--         SET SET @c_PickMessage = [dbo].[fnc_GetVC_Message](@c_LangCode, 'vc_prTaskLUTGetPicks_03', N'No More Assignment. Please SignOff',RIGHT(RTRIM(@c_FromID), 3),'','','','')              
--         SET @c_RtnMessage = 'N,0,,,,,,,,,,,,,,,,,,,,,,,0,0,0,,,0,,,0,0,0,0,89,' + @c_PickMessage             
--      END                      
--   END            
                                                
   IF LEN(ISNULL(@c_RtnMessage,'')) = 0                 
   BEGIN         
      --          
      SET @c_RtnMessage = 'N,0,,,,,,,,,,,,,,,,,,,,,,,0,0,0,,,0,,,0,0,0,0,89,No Pick Task'    
   END          
END
GO
GRANT EXECUTE ON [dbo].[isp_TCP_VC_prTaskLUTGetPicks] TO nSQL 
GO
