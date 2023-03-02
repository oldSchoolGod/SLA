@isTest
public class caseTriggerHandler_Test {
    
    @TestSetup
    public static void setup() {
        
        //insert SLA_Configurations__c
        SLA_Configurations__c slaconfig = new SLA_Configurations__c();
        slaconfig.Name = 'TestForManger';
       // slaconfig.Business_Hr__c =true;
        slaconfig.Case_Status__c='New';
        slaconfig.Email_Templates__c='Email To Owner,Email To Manager,Email To Managers Manager,EmailTomanagersManagerM';
        slaconfig.Managers__c=true;
        slaconfig.Sla_Time_Interval__c='1,1,1,1';
        insert slaconfig;
        
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
        
        User testUserE = new User(
            Alias = 'standard', Email='testUsere@testorganise.com',  
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pro.Id,  
            TimeZoneSidKey='America/Los_Angeles', UserName='testUsere@testorganise.com');
        testUserE.ManagerID = testUserD.id;
        insert testUserE;
        
        User testUserF = new User(
            Alias = 'standard', Email='testUserf@testorganise.com',  
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pro.Id,  
            TimeZoneSidKey='America/Los_Angeles', UserName='testUserf@testorganise.com');
        testUserF.ManagerID = testUserE.id;
        insert testUserF;
        
        User testUserG = new User(
            Alias = 'standard', Email='testUserf@testorganise.com',  
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pro.Id,  
            TimeZoneSidKey='America/Los_Angeles', UserName='testUserg@testorganise.com');
        testUserG.ManagerID = testUserF.id;
        insert testUserG;
        
    }
    
    @isTest
    static void slaTimer_Test(){
        
        User u = [Select Id,UserName,Email From User Where UserName ='testUserb@testorganise.com'];
        
        Test.startTest();
        Case c = new Case();
        c.Status = 'New';
        c.OwnerId = u.Id;
        c.Description = 'Test_Case';
        insert c; 
        Test.stopTest();
        
        
        
    }
    @isTest
    static void scheduledEmailsMangerTest(){
        User u = [Select Id,UserName,Email From User Where UserName ='testUsere@testorganise.com'];
        list<Id> caseIdList = new list<Id>();
        Case c = new Case();
        c.Status = 'New';
        c.Description = 'Test_Case';
        c.OwnerId = u.Id;
        insert c;
        caseIdList.add(c.Id);
        
        
        
        Test.startTest(); 
        String cronExp ='0 0 * * * ?'; 
        System.schedule('JobName', cronExp, new scheduledEmailsManger(caseIdList)); 
        Test.stopTest(); 
        
    }
    @isTest
    static void scheduledEmailsMangersManagerTest(){
        User u = [Select Id,UserName,Email From User Where UserName ='testUserf@testorganise.com'];
        list<Id> caseIdList = new list<Id>();
        Case c = new Case();
        c.Status = 'New';
        c.Description = 'Test_Case';
        c.OwnerId = u.Id;
        insert c;
        caseIdList.add(c.Id);
        
        
        
        Test.startTest(); 
        String cronExp ='0 0 * * * ?'; 
        System.schedule('JobName', cronExp, new scheduledEmailsMangersManager(caseIdList)); 
        Test.stopTest(); 
        
    }
    @isTest
    static void scheduledEmailsMangersManagerManagersTest(){
        User u = [Select Id,UserName,Email From User Where UserName ='testUserg@testorganise.com'];
        list<Id> caseIdList = new list<Id>();
        Case c = new Case();
        c.Status = 'New';
        c.Description = 'Test_Case';
        c.OwnerId = u.Id;
        insert c;
        caseIdList.add(c.Id);
        
        
        
        Test.startTest(); 
        String cronExp ='0 0 * * * ?'; 
        System.schedule('JobName', cronExp, new scheduledEmailsMangersManagerManagers(caseIdList)); 
        Test.stopTest(); 
        
    }
    
    
}