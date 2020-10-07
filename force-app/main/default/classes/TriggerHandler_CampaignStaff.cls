/*==============================================================
 * 產生驗證碼
 *
 *
 *==============================================================*/

public without sharing class TriggerHandler_CampaignStaff
{
    //預設為八碼。去除l1O0及小寫。
    public static string allString = 'ABCDEFGHIJKLMNPQRSTUVWXYZ23456789';
    public static integer CouponLength = 8;
    
    public static string generateOneVerifyCode()
    {
        string returnSTR = '';
        integer randomLength = allString.length();
        for(integer i=0; i <CouponLength; i++)
        {
          returnSTR += allString.mid(Math.round(Math.random()*randomLength), 1);    
        }
        return returnSTR;
    }

    //只在Insert 的時候產生。
    public static void generateVerifyCode(list<CampaignStaff__c> newList)
    {
        set<string> allStringSet = new set<string>();

        list<CampaignStaff__c> needVerifyCode = new list<CampaignStaff__c>();

        for(CampaignStaff__c loopCampaignStaff: newList)
        {
            if(string.isBlank(loopCampaignStaff.VerifyCode__c) )
            {
                needVerifyCode.add(loopCampaignStaff);
            }
        }

        if(needVerifyCode.size() >0 )
        {
            while(allStringSet.size() < needVerifyCode.size() )
            {
                string tempVerifyCode = generateOneVerifyCode();
                //contains 區分大小寫。
                if(! allStringSet.contains(tempVerifyCode))
                {
                    allStringSet.add(tempVerifyCode);
                }
            }

            //要找出重覆的。
            list<CampaignStaff__c> duplicateVerifyCode = [select VerifyCode__c from CampaignStaff__c where VerifyCode__c in: allStringSet];

            //只要>0 就要一直抓。
            while(duplicateVerifyCode.size() >0 )
            {
                for(CampaignStaff__c loopStaff: duplicateVerifyCode)
                {
                    allStringSet.remove(loopStaff.VerifyCode__c);
                }
                while(allStringSet.size() < needVerifyCode.size() )
                {
                    string tempVerifyCode = generateOneVerifyCode();
                    //contains 區分大小寫。
                    if(! allStringSet.contains(tempVerifyCode))
                    {
                        allStringSet.add(tempVerifyCode);
                    }
                }
                duplicateVerifyCode = [select VerifyCode__c from CampaignStaff__c where VerifyCode__c in: allStringSet];
            }

            integer i=0;
            for(string loopSTR: allStringSet)
            {
                needVerifyCode[i].VerifyCode__c = loopSTR;
                i++;
            }
        }
    }    
}