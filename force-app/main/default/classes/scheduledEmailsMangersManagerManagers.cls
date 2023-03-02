public class scheduledEmailsMangersManagerManagers implements Schedulable {
    public List<Id> caseIdsSch;
    public scheduledEmailsMangersManagerManagers(List<Id> caseIds){
        caseIdsSch = caseIds;
    }
    
    public void execute(SchedulableContext Sc){
        System.debug('caseIds in  Schedulable' +caseIdsSch);
        emailToOwnersAndTherMangers.sendingMail(caseIdsSch,'OMMM');
    }

}