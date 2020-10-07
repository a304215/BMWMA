/*===========================================================
 * 行銷活動Trigger
 * 建立工作人員名單 & 驗證碼

 *===========================================================*/ 

Trigger Trigger_CreateCampaignStaff on Campaign (After Insert, After Update) {
    
    List <CampaignStaff__c> createCampaignStaff = new List <CampaignStaff__c>();
    
    if(Trigger.IsInsert || Trigger.IsUpdate){
        
        For(Campaign Campaign: Trigger.new){
            
            //檢查工作人員人數不為空且有填活動代碼
            If(Campaign.NumberOfStaff__c != null && Campaign.CampaignNo__c != null){
                
                List<CampaignStaff__c> ExixtsedRecords = [
                    Select Id,CampaignNo__c FROM CampaignStaff__c WHERE Campaign__c =:Campaign.Id
                ];
                
                // Only creating a records when there is no records exixts.
                // 不能改數量 只可以從0(空)改成別的數量QAQ
                If(ExixtsedRecords.IsEmpty()){
                    
                    For(Integer I = 0; I < Campaign.NumberOfStaff__c; I++){
                        
                        CampaignStaff__c Staff = new CampaignStaff__c();
                        Staff.Campaign__c = Campaign.id;
                        staff.CampaignNo__c = Campaign.CampaignNo__c;
                        Staff.RecordCnt__c = I+1;
                        createCampaignStaff.add(Staff);
                    }         
                }
            }
             
            try{ 
                If(!createCampaignStaff.IsEmpty()){
                    insert createCampaignStaff; 
                }
            }
            
            catch (Exception e){
                System.debug('exception=================' + e.getMessage());
            }    
        }
    }
}