public class mail_test {
    public mail_test(){
        
    }
    public void send_mail_test(){
        SMSFunction a = new SMSFunction();
        a.myPhone = '0902292820';
        a.myName = 'Andy';
        a.smbody = 'test_mail';
        a.mitakeSingleCallout();
        
    }
}