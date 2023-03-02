public class caseTriggerHandler {
    public static Boolean managerCheckBox{get;set;}
    public  static Boolean hiearychyCheckBox{get;set;}
    public  static Boolean Business_Hr{get;set;}
    public static Decimal mangerTime{get;set;}
    public Static String Sla_Time_Interval{get;set;}
    public static Decimal ownerTime{get;set;}
    public static Decimal ownerMangerTime{get;set;}
    public static Decimal ownerMangerMangersTime{get;set;}
    public static Decimal ownerMangerMangersMangersTime{get;set;}
    
    public static List<String> caseIdList;
    public static void slaTimer(List<Case> CaseList){
        //get the SLA Configures (Custom Object)
        List<SLA_Configurations__c> mcsList = new List<SLA_Configurations__c>([SELECT Case_Status__c,Managers__c, Id,Hierarchy__c,Sla_Time_Interval__c,Business_Hr__c ,Name FROM SLA_Configurations__c Limit 1]);
        //List<SLA_Configuration__c> mcsList = SLA_Configuration__c.getAll().values();
        List<Case> caseListToUpdate = new List<Case>();
        for(SLA_Configurations__c slac:mcsList){
            managerCheckBox= slac.Managers__c;
            hiearychyCheckBox = slac.Hierarchy__c;
            Sla_Time_Interval = slac.Sla_Time_Interval__c;
            //caseTriggerHandler.mangerTime = slac.Sla_Timer__c;
            Business_Hr = slac.Business_Hr__c;
        }
        //Seperating Time of Different Mangers
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
        
        
        
        //get all Case Ids 
        System.debug('CaseList ' +CaseList);
        caseIdList = new List<String>();
        
        for(Case c : CaseList ){
            System.debug('cIDS=====>' +c.Id);
            caseIdList.add(c.Id);
            Id businessHourId = BusinessHoursService.defaultBH.id;
            Datetime currentTime = System.now();
            Datetime targetDT = mangerTime != null ? BusinessHoursService.getReminderTimeByBusinessHour(currentTime,(Integer)mangerTime) : BusinessHoursService.getReminderTimeByBusinessHour(currentTime,(Integer)ownerTime);
            System.debug('target date on local time =' + targetDT.format('MM-dd-yyyy') + ' ' + targetDT.format('h:mm a'));
            Case caseObj = new Case();
            caseObj.Id = c.Id;
            caseObj.Email_Trigger_DateTime__c = targetDT;
            caseListToUpdate.add(caseObj);
        }
        
        if(Business_Hr)
          update caseListToUpdate;
        
       
             List<Case> newcaseList =[Select Id,caseNumber,Owner.Id,Owner.email,status,Email_Trigger_DateTime__c from case where id in: caseIdList ];
        for(Case caseObj : newCaseList){
           //  String cronExp;
            if( managerCheckBox ){
               
                DateTime currentTime = System.now();
                Integer totalmill = currentTime.hour()*60*60*1000  + currentTime.minute()*60*1000 + currentTime.second()*1000;
                // first email to case Owner (shedule an apex to send email to after sla timer)
                System.debug('mangerTime '+mangerTime);
                System.debug('caseTriggerHandler.ownerTime  '+ caseTriggerHandler.ownerTime);
                Integer totalMillisecond = totalmill + (mangerTime != NULL ? ((Integer)caseTriggerHandler.mangerTime * 60 * 1000) : ((Integer)caseTriggerHandler.ownerTime * 60 * 1000));
                Integer currentMin = Business_Hr ? caseObj.Email_Trigger_DateTime__c.minute() : Integer.valueOf(Math.mod((totalMillisecond)/(1000*60),60)) ;
                Integer currentHr = Business_Hr ? caseObj.Email_Trigger_DateTime__c.hour() : Integer.valueOf(Math.mod((totalMillisecond)/(1000*60*60), 24)); 
                 Integer mounth = Business_Hr ? caseObj.Email_Trigger_DateTime__c.month() : currentTime.month() ;
                Integer year = Business_Hr ? caseObj.Email_Trigger_DateTime__c.year() :  currentTime.year() ;
                Integer day =  Business_Hr ? caseObj.Email_Trigger_DateTime__c.day()  : currentTime.day();
               
                String cronExp = '0'+' '+ string.valueOf(currentMin) +' '+String.valueOf(currentHr)+' '+String.valueOf(day)+' ' + String.valueOf(mounth)+' '+'? ' + String.valueOf(year);
                 //String cronExp = Business_Hr ? '0'+' '+ string.valueOf(currentMin) +' '+String.valueOf(currentHr)+' '+String.valueOf(day)+' ' + String.valueOf(mounth)+' '+'? ' +year  :  '0'+' '+ string.valueOf(currentMin) +' '+String.valueOf(currentHr)+' '+String.valueOf(day)+' ' + String.valueOf(mounth)+' '+'? ' +year;
                  System.debug('currentMin' + currentMin);
                     System.debug('currentHr' + currentHr);
                     System.debug('cronExp' + cronExp);
                System.debug('caseIdList==> '+ caseIdList);
                    if(caseObj.Status == mcsList[0].Case_Status__c){
                         scheduledEmails scheduleForOwner = new scheduledEmails(caseIdList);
                      System.schedule('EmailToCaseOwner'+String.valueOf(currentTime), cronExp, scheduleForOwner);
                    
                    }else{
                        return;
                    }
                
            
            
        }
        
            
        }
        
       
        
    }
}