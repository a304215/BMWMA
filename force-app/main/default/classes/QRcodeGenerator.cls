Global without sharing virtual class QRcodeGenerator {
    
    private CampaignMember mCampaignMember;
    public CampaignMember getCampaignMember()
    {   
        if (mCampaignMember == null)
        {            
            mCampaignMember = new CampaignMember();
            mCampaignMember = [
                select id, camp_member_name__c, LastName, FirstName, RegistrationURL__c
                from CampaignMember
                where id =: ApexPages.currentPage().getParameters().get('id')
                //and CampaignId__r.CampaignNo__c =: CampaignID
            ];
        }
        return mCampaignMember;
    }
}