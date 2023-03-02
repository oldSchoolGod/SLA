public class scheduledEmails implements Schedulable {
    public static Boolean managerCheckBox{get;set;}
    public  static Boolean hiearychyCheckBox{get;set;}
    public  static Boolean Business_Hr{get;set;}
    public static Decimal mangerTime{get;set;}
    public Static String Sla_Time_Interval{get;set;}
    public static Decimal ownerTime{get;set;}
    public static Decimal ownerMangerTime{get;set;}
    public static Decimal ownerMangerMangersTime{get;set;}
    public static Decimal ownerMangerMangersMangersTime{get;set;}
    public List<Id> caseIdsSch;
    public  scheduledEmails(List<Id> caseIds){
        caseIdsSch = caseIds;
    }
    public void execute(SchedulableContext Sc){
        // List<SLA_Configuration__c> mcsList = SLA_Configuration__c.getAll().values();
        
        
        System.debug('caseIds in  Schedulable' +caseIdsSch);
        emailToOwnersAndTherMangers.sendingMail(caseIdsSch,'O');
        List<Case> caseListToUpdate = new List<Case>();
        List<Case> caseList =[Select Id,caseNumber,Owner.Id,Owner.email,status from case where id in: caseIdsSch ];
        System.debug('caseList IN Schedulable '+caseList);
        id ownerId=caseList[0].Owner.Id;
        System.debug('owner Email'+caseList[0].Owner.email);
         List<User> myUser1=new List<User>([select id,manager.email,manager.manager.email From User Where Id=:ownerId ]);
        System.debug('myUser1 '+myUser1);
        List<User> myUser=new List<User>([select id,manager.email,manager.manager.email From User Where Id=:ownerId And manager.email != NUll]);
        System.debug('myUser '+myUser);
        //User myUser=[select id,manager.email From User Where Id=:ownerId];
        if(myUser.size()>0){
            String mangerEmail=myUser[0].manager.email;
            System.debug('ownerId myUser '+mangerEmail);
            
            
            List<SLA_Configurations__c> mcsList = new List<SLA_Configurations__c>([SELECT Id, Name, Case_Status__c, Email_Templates__c, Sla_Time_Interval__c, Managers__c, Hierarchy__c, Business_Hr__c FROM SLA_Configurations__c LIMIT 1]);
            for(SLA_Configurations__c slac:mcsList){
                managerCheckBox= slac.Managers__c;
                hiearychyCheckBox = slac.Hierarchy__c;
                Sla_Time_Interval = slac.Sla_Time_Interval__c;
                //caseTriggerHandler.mangerTime = slac.Sla_Timer__c;
                Business_Hr = slac.Business_Hr__c;
            }
            
            List<String> managerDiffTimes = Sla_Time_Interval.split(',');
            if(managerDiffTimes.size() == 1){
                mangerTime = Integer.valueOf(managerDiffTimes[0]);
            }
            else{
                Integer i=0;
                for(String str : managerDiffTimes){
                    if(i==4)
                        break;
                    switch on i {
                        when 0 {		
                            ownerTime = Integer.valueOf(str);
                        }	
                        when 1 {		
                            ownerMangerTime = Integer.valueOf(str);
                        }
                        when 2 {		
                            ownerMangerMangersTime = Integer.valueOf(str);
                        }
                        when 3 {		 
                            ownerMangerMangersMangersTime = Integer.valueOf(str);
                        }
                    }                
                    i++;
                }
            }
            
            if(Business_Hr){
                for(Case c : caseList ){
                Id businessHourId = BusinessHoursService.defaultBH.id;
                Datetime currentTime =System.now();
                System.debug('mangerTime '+mangerTime);
                System.debug('ownerMangerTime '+ownerMangerTime);
                Datetime targetDT = (mangerTime!=null ? BusinessHoursService.getReminderTimeByBusinessHour(currentTime,(Integer)mangerTime) : BusinessHoursService.getReminderTimeByBusinessHour(currentTime,(Integer)ownerMangerTime));
                System.debug('target date on local time =' + targetDT.format('MM-dd-yyyy') + ' ' + targetDT.format('h:mm a'));
                Case caseObj = new Case();
                caseObj.Id = c.Id;
                caseObj.Email_Trigger_DateTime__c=targetDT;
                caseListToUpdate.add(caseObj);
                
               }
         
            update caseListToUpdate;
            }
            
            
            List<Case> newcaseList =[Select Id,caseNumber,Owner.Id,Owner.email,status,Email_Trigger_DateTime__c from case where id in: caseIdsSch ];
            
            if(!String.isBlank(mangerEmail)){
               // String cronExp;
                for(Case caseObj : newcaseList){
                    DateTime currentTime = System.now();
                    Integer totalmill = currentTime.hour()*60*60*1000  + currentTime.minute()*60*1000 + currentTime.second()*1000;
                    // first email to case Owner (shedule an apex to send email to after sla timer)
                    Integer totalMillisecond = totalmill + (mangerTime != null ? ((Integer)mangerTime * 60 * 1000) : ((Integer)ownerMangerTime * 60 * 1000));
                        
                        Integer currentMin = Business_Hr ? caseObj.Email_Trigger_DateTime__c.minute() : Integer.valueOf(Math.mod(((totalMillisecond)/(1000*60)),60)) ;
                    Integer currentHr = Business_Hr ? caseObj.Email_Trigger_DateTime__c.hour() : Integer.valueOf(Math.mod(((totalMillisecond)/(1000*60*60)), 24)); 
                    Integer mounth = Business_Hr ? caseObj.Email_Trigger_DateTime__c.month() : currentTime.month() ;
                    Integer year = Business_Hr ? caseObj.Email_Trigger_DateTime__c.year() :  currentTime.year() ;
                    Integer day =  Business_Hr ? caseObj.Email_Trigger_DateTime__c.day()  : currentTime.day();
                   
                    String cronExp = '0'+' '+ string.valueOf(currentMin) +' '+String.valueOf(currentHr)+' '+String.valueOf(day)+' ' + String.valueOf(mounth)+' '+'? ' + String.valueOf(year);
                   
                    system.debug(' line no 111 cronExp  :: '+cronExp);
                    if(caseObj.Status == mcsList[0].Case_Status__c){
                        scheduledEmailsManger scheduleForManger = new scheduledEmailsManger(caseIdsSch);
                    System.schedule('EmailToCaseManger'+String.valueOf(System.now()), cronExp, scheduleForManger);
                    }else{
                        return;
                    }
                }
                
            }else{
                return;
            }            
        }else{
            return;
        }
        
        
    }
}