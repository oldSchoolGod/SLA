@isTest
public class emailToOwnersAndTherMangers_test {
    @TestSetup
    public static void setup(){
        List<Case> caseList= new List<Case>();
        
        //Creating Users
        Profile pro = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User testUserA = new User(
            Alias = 'standard', Email='testUsera@testorganise.com',  
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pro.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testUsera@testorganise.com'); 
        insert testUserA;
        User testUserB = new User(
            Alias = 'standard', Email='testUserb@testorganise.com',  
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pro.Id,  
            TimeZoneSidKey='America/Los_Angeles', UserName='testUserb@testorganise.com');
        testUserB.ManagerID = testUserA.id;
        insert testUserB;
        User testUserC = new User(
            Alias = 'standard', Email='testUserc@testorganise.com',  
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pro.Id,  
            TimeZoneSidKey='America/Los_Angeles', UserName='testUserc@testorganise.com');
        testUserC.ManagerID = testUserB.id;
        insert testUserC;
        User testUserD = new User(
            Alias = 'standard', Email='testUserd@testorganise.com',  
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pro.Id,  
            TimeZoneSidKey='America/Los_Angeles', UserName='testUserd@testorganise.com');
        testUserD.ManagerID = testUserC.id;
        insert testUserD;
        
        //insert SLA_Configurations__c
        
        SLA_Configurations__c slaconfig = new SLA_Configurations__c();
        slaconfig.Name = 'TestForManger';
        slaconfig.Business_Hr__c =true;
        slaconfig.Case_Status__c='New';
        slaconfig.Email_Templates__c='Email To Owner,Email To Manager,Email To Managers Manager,EmailTomanagersManagerM';
        slaconfig.Managers__c=true;
        slaconfig.Sla_Time_Interval__c='0,0,0,0';
        insert slaconfig;
        
    }
    
    @isTest
    static void slaTimer_Test(){
        
        User u = [Select Id,UserName,Email From User Where UserName ='testUserd@testorganise.com'];
        System.runAs(u){
            Test.startTest();
            Case c = new Case();
            c.Status = 'New';
            c.Description = 'Test Case';
            datetime targetDT=datetime.now(); 
           // c.Email_Trigger_DateTime__c	=datetime.valueOf(datetime.now().format('MM/dd/yyyy') + ' ' + targetDT.format('h:mm a'));
            insert c;
            Test.stopTest();
            
        }
        
        
    } 
    @isTest 
    public static void testMethodSchedule(){ 
        Profile pro = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User testUserA = new User(
            Alias = 'standard', Email='testUseraa@testorganise.com',  
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pro.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testUseraa@testorganise.com'); 
        insert testUserA;
        User testUserB = new User(
            Alias = 'standard', Email='testUserbb@testorganise.com',  
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pro.Id,  
            TimeZoneSidKey='America/Los_Angeles', UserName='testUserbb@testorganise.com');
        testUserB.ManagerID = testUserA.id;
        insert testUserB;
        User testUserC = new User(
            Alias = 'standard', Email='testUsercc@testorganise.com',  
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pro.Id,  
            TimeZoneSidKey='America/Los_Angeles', UserName='testUsercc@testorganise.com');
        testUserC.ManagerID = testUserB.id;
        insert testUserC;
        User testUserD = new User(
            Alias = 'standard', Email='testUserdd@testorganise.com',  
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pro.Id,  
            TimeZoneSidKey='America/Los_Angeles', UserName='testUserdd@testorganise.com');
        testUserD.ManagerID = testUserC.id;
        insert testUserD;
        SLA_Configurations__c slaconfig = new SLA_Configurations__c();
        slaconfig.Name = 'TestForManger';
        slaconfig.Business_Hr__c =true;
        slaconfig.Case_Status__c='New';
        slaconfig.Email_Templates__c='Email To Owner,Email To Manager,Email To Managers Manager,EmailTomanagersManagerM';
        slaconfig.Managers__c=true;
        slaconfig.Sla_Time_Interval__c='0,0,0,0';
        insert slaconfig;
       // User u = [Select Id,UserName,Email From User Where UserName ='testUserdd@testorganise.com'];
       // System.runAs(u){
        Case c = new Case();
        c.Status = 'New';
        c.Description = 'Test Case';
       // c.OwnerId = userinfo.getuserid();
        datetime targetDT=datetime.now(); 
        // c.Email_Trigger_DateTime__c	=datetime.valueOf(datetime.now().format('MM/dd/yyyy') + ' ' + targetDT.format('h:mm a'));
        insert c;
        list<Id> caseIdList = new list<Id>();
        caseIdList.add(c.Id);
        Test.startTest(); 
        String cronExp ='0 0 * * * ?'; 
        System.schedule('JobName', cronExp, new scheduledEmailsManger(caseIdList)); 
        Test.stopTest(); 
      //  }
    }
}