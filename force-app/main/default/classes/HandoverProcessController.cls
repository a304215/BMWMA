public with sharing class HandoverProcessController {
    public Account acct { set;get; }

    @AuraEnabled
    public static list < Opportunity > doInit() {
        try {
            list < Opportunity > rets = new list < Opportunity > ();

            rets = [select id, name from Opportunity where stagename = '領牌'];
            //TestCarReservationId account = [SELECT BillingPostalCode FROM Account WHERE Id=:accountId];
            return rets;
        } catch (Exception ex) {
            return null;
            //return '{"error": "' + ex.getMessage() + '"}';
        }
    }

    @AuraEnabled
    public static list < Opportunity > getIds() {
        try {
            list < Opportunity > rets = new list < Opportunity > ();

            WorkLog__c ret;
            rets = [select id, name from Opportunity where stagename = '領牌'];
            rets.add(rets[0].clone(false));
            rets.add(rets[0].clone(false));
            rets.add(rets[0].clone(false));
            rets.add(rets[0].clone(false));
            rets.add(rets[0].clone(false));
            rets.add(rets[0].clone(false));
            rets.add(rets[0].clone(false));
            return rets;
        } catch (Exception ex) {
            return null;
            //return '{"error": "' + ex.getMessage() + '"}';
        }
    }

    @AuraEnabled
    public static map < string, string > getFieldLabel(string objectAPI) {
        map < string, string > returnMap = new map < string, string > ();
        Map < String, Schema.SObjectField > fieldNameMap = Schema.getGlobalDescribe().get(objectAPI).getDescribe().fields.getMap();
        for (string fieldName: fieldNameMap.keyset()) {
            system.debug(fieldName);
            returnMap.put(fieldName, fieldNameMap.get(fieldName).getDescribe().getLabel());
        }
        return returnMap;
    }

    @AuraEnabled
    public static Opportunity getChooseOppt(string OpptId) {
        Opportunity o = [select id, accountId from Opportunity where id =: OpptId];

        return o;
    }
}