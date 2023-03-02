public class emailToOwnersAndTherMangers {
    
    public static void sendingMail(List<Id> caseId,String whomeToSendEmail)
    {
        try{
           
            String mangerEmail;
            string managersMangerEmail;
            string managersMangerMangerEmail;
            String ownerTemplate;
            String ownerMTemplate;
            String ownerMMTemplate;
            String ownerMMMTemplate;
            String emailTemplate;
            String mangerId;
            string managersMangerId;
            String managersMangerMangerId;
            String whoIdTo;
            System.debug('caseid' + caseId);
            List<Case> caseList = new List<Case>([Select Id,caseNumber,Owner.Id,Owner.email,status from case where id in: caseId]);
            List<User> myUser = new List<User>([select id,manager.Id,manager.manager.Id,manager.manager.manager.Id,manager.email,manager.manager.email,manager.manager.manager.email From User Where Id=:caseList[0].Owner.Id]);
            
            if(!String.isBlank(myUser[0].manager.email) && !String.isBlank(myUser[0].manager.Id) ){
                mangerEmail = myUser[0].manager.email;
                mangerId   =  myUser[0].manager.Id;          
            } 
            if(!String.isBlank(myUser[0].manager.manager.email) && !String.isBlank(myUser[0].manager.manager.Id)){
                managersMangerEmail = myUser[0].manager.manager.email;
                managersMangerId = myUser[0].manager.manager.Id;
            }  
            if(!String.isBlank(myUser[0].manager.manager.manager.email) && !String.isBlank(myUser[0].manager.manager.manager.Id)){
                managersMangerMangerEmail = myUser[0].manager.manager.manager.email; 
                managersMangerMangerId =  myUser[0].manager.manager.manager.Id;
            }
            System.debug('caseList '+caseList);
           
            List<SLA_Configurations__c> sla = new List<SLA_Configurations__c>([SELECT Case_Status__c,Email_Templates__c, Id, Name FROM SLA_Configurations__c Limit 1]);
            List<String> templateList =  sla[0].Email_Templates__c.split(',');
            Integer i = 0;
            for(String str : templateList){
                if(i==4)
                    break;
                switch on i {
                    when 0 {ownerTemplate = str;}	
                    when 1 {ownerMTemplate = str;}
                    when 2 {ownerMMTemplate = str;}
                    when 3 {ownerMMMTemplate = str;}
                }                
                i++;
            }
            
            if(whomeToSendEmail == 'O'){
                emailTemplate = ownerTemplate;
            }else if(whomeToSendEmail == 'OM'){
                emailTemplate = !String.isBlank(ownerMTemplate) ? ownerMTemplate : ownerTemplate ;
            }else if(whomeToSendEmail == 'OMM'){
                emailTemplate = !String.isBlank(ownerMMTemplate) ? ownerMMTemplate : ownerTemplate ;
            }else if(whomeToSendEmail == 'OMMM'){
                emailTemplate = !String.isBlank(ownerMMMTemplate) ? ownerMMMTemplate : ownerTemplate ;
            }
            
            List<EmailTemplate> et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name=: emailTemplate limit 1];
            for(Case c:caseList){
               List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Map<Integer,String> sendTo = new Map<Integer,String>();
                List<String> sendToEmails = New List<String>();
                if(c.Status==sla[0].Case_Status__c){
                    
                    if(whomeToSendEmail == 'O' && !String.isBlank(c.Owner.email)){
                        sendTo.put(0,c.OwnerId);
                        //sendToEmails.add(c.Owner.email);
                        whoIdTo = c.OwnerId;
                    }
                    
                    else if(whomeToSendEmail == 'OM' && !String.isBlank(c.Owner.email) && !String.isBlank(mangerEmail) ){
                        sendTo.put(0,c.OwnerId);
                        sendTo.put(1,mangerId);
                        sendToEmails.add(c.Owner.email);
                        //sendToEmails.add(mangerEmail);
                        whoIdTo = mangerId;
                    }else if(whomeToSendEmail == 'OMM' && !String.isBlank(c.Owner.email) && !String.isBlank(mangerEmail) && !String.isBlank(managersMangerEmail)){
                        sendTo.put(0,c.OwnerId);
                        sendTo.put(1,mangerId);
                        sendTo.put(2,managersMangerId);
                        sendToEmails.add(c.Owner.email);
                        sendToEmails.add(mangerEmail);
                        // sendToEmails.add(managersMangerEmail);
                        whoIdTo = managersMangerId;
                    }else if(whomeToSendEmail == 'OMMM' && !String.isBlank(c.Owner.email) && !String.isBlank(mangerEmail) && !String.isBlank(managersMangerEmail) && !String.isBlank(managersMangerMangerEmail)){
                        sendTo.put(0,c.OwnerId);
                        sendTo.put(1,mangerId);
                        sendTo.put(2,managersMangerId);
                        sendTo.put(3,managersMangerMangerId);
                        sendToEmails.add(c.Owner.email);
                        sendToEmails.add(mangerEmail);
                        sendToEmails.add(managersMangerEmail);
                        //sendToEmails.add(managersMangerMangerEmail);
                        whoIdTo = managersMangerMangerId;
                    }
                    
                    if(sendTo.size()>0){
                        
                        /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setToAddresses(sendTo);
mail.setTemplateId(et[0].id);
mail.setSubject(et[0].Subject);
mail.setHtmlBody(et[0].Body);
mail.setSaveAsActivity(false);
mails.add(mail); */
                          
                        System.debug('whomeToSendEmail '+whomeToSendEmail);
                        System.debug('sendTo.size() '+sendTo.size());
                       /* for(Integer j=0;j<sendTo.size();j++){
                            System.debug('sendTo.get(j) '+sendTo.get(j));
                            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et[0].id,sendTo.get(j), c.Id);
                            mail.setTargetObjectId(sendTo.get(j));
                            mail.setSubject(mail.getSubject());
                            mail.sethtmlBody(mail.gethtmlBody());
                            
                            // mail.setCcAddresses(sendToEmails);
                            mail.saveAsActivity = false;
                            mails.add(mail);
                            System.debug('mail =>>>>>>>>'+mail);
                            
                        }*/
                           
                            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et[0].id,whoIdTo, c.Id);
                            mail.setTargetObjectId(whoIdTo);
                            mail.setSubject(mail.getSubject());
                            mail.sethtmlBody(mail.gethtmlBody());
                            mail.setCcAddresses(sendToEmails);
                            mail.saveAsActivity = false;
                            mails.add(mail);
                            System.debug('mail =>>>>>>>>'+mail);
                        
                    }
                    
                }
                
                // System.debug('sendTo ====> '+sendTo);
                System.debug('System.Now ===>'+System.now());
                if(mails.size()>0){
                    System.debug('mail ===> '+mails);
                     Messaging.sendEmail(mails);
                }
                  
            }
            //if(mails.size()>0)
              //  Messaging.sendEmail(mails);
            //else
              //  return ;
        }
        catch(Exception e){
            System.debug('error '+ e.getMessage() + 'on line '+ e.getLineNumber());
        }
        
    }
    
}