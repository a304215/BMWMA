@isTest
private class TrnggerHandler_CaseTest
{
    @isTest
    private static void test1()
    {
        DealerMapping__c dm = new DealerMapping__c();
        dm.Name='19476';
        dm.DealerName__c = '桃園大桐';
        insert dm;

        NewCarPool__c nc = new NewCarPool__c();
        nc.Name = 'AAAAAAA';
        nc.Dealer__c = '桃園大桐';
        nc.VenderCode__c = '19476';
        insert nc;

        Account acct = new Account();
        acct.FirstName = 'AAAAAAA';
        acct.LastName = 'CCCCC';
        acct.RecordTypeId = '0127F000000IAMXQA4';
        acct.Gender__pc = '男性';
        acct.MainContactNumber__c ='行動電話';
        acct.PersonMobilePhone = '0000000000';
        insert acct;

        Asset ast = new Asset();
        ast.Name =  ' BBBBB';
        ast.AccountId = acct.Id;
        ast.VIN__c = nc.Id;
        insert ast;

        Case c = new Case();
        c.Invoiceidx__c = '111111111';
        c.VIN__c = nc.Id;
        c.Origin = 'email';
        insert c;
    }
    
    @isTest
    static void setup() {

        DealerMapping__c dm = new DealerMapping__c();
        dm.Name='19476';
        dm.DealerName__c = '桃園大桐';
        insert dm;

        NewCarPool__c nc = new NewCarPool__c();
        nc.Name = 'AAAAAAA';
        nc.vin_short__c = 'AAAAAAA';
        nc.Dealer__c = '桃園大桐';
        nc.VenderCode__c = '19476';
        insert nc;

        Account acct = new Account();
        acct.FirstName = 'AAAAAAA';
        acct.LastName = 'CCCCC';
        acct.RecordTypeId = '0127F000000IAMXQA4';
        acct.Gender__pc = '男性';
        acct.MainContactNumber__c ='行動電話';
        acct.PersonMobilePhone = '0000000000';
        insert acct;

        Asset ast = new Asset();
        ast.Name =  ' BBBBB';
        ast.AccountId = acct.Id;
        ast.VIN__c = nc.Id;
        ast.InstallDate = date.Today();
        insert ast;

        Case c = new Case();
        c.chassisno__c = 'AAAAAAA';
        c.Invoiceidx__c = '111111111';
        //c.VIN__c = nc.Id;
        c.Origin = 'email';
        insert c;
    }
}