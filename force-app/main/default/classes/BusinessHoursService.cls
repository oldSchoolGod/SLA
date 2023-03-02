public class BusinessHoursService {
  public static BusinessHours defaultBH{
        get
        {
            if(defaultBH == null)
                defaultBH = [select Id from BusinessHours Where IsDefault = true];
            	return defaultBH;
        }
      
      public set;
    
    } 
    public static Datetime getReminderTimeByBusinessHour(DateTime input, Integer Reminderhours){
        //BusinessHours defaultBH = [select Id from BusinessHours Where IsDefault = true];
        return BusinessHours.add(defaultBH.Id,input, Reminderhours* 60* 1000L);
    }
}