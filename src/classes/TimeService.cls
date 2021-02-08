/**
 * Created by Sergey on 06.02.2021.
 */

public class TimeService {
    public static List<Time__c> updateTime(List<Time__c> times, JsonWrapper wrapper) {

        Map<String, Time__c> weekDayMap = getMapByWeekDay(times);

        if (wrapper.Mon != null) {
            Time__c timeForUpdate = weekDayMap.get('Mon');
            timeForUpdate.Time_spend__c = wrapper.Mon;
        }
        if (wrapper.Tue != null) {
            Time__c timeForUpdate = weekDayMap.get('Tue');
            timeForUpdate.Time_spend__c = wrapper.Tue;
        }
        if (wrapper.Wed != null) {
            Time__c timeForUpdate = weekDayMap.get('Wed');
            timeForUpdate.Time_spend__c = wrapper.Wed;
        }
        if (wrapper.Thu != null) {
            Time__c timeForUpdate = weekDayMap.get('Thu');
            timeForUpdate.Time_spend__c = wrapper.Thu;
        }
        if (wrapper.Fri != null) {
            Time__c timeForUpdate = weekDayMap.get('Fri');
            timeForUpdate.Time_spend__c = wrapper.Fri;
        }
        if (wrapper.Sat != null) {
            Time__c timeForUpdate = weekDayMap.get('Sat');
            timeForUpdate.Time_spend__c = wrapper.Sat;
        }
        if (wrapper.Sun != null) {
            Time__c timeForUpdate = weekDayMap.get('Sun');
            timeForUpdate.Time_spend__c = wrapper.Sun;
        }

        System.debug('Map For Update ' + weekDayMap.size());
        return weekDayMap.values();
    }

    public static List<Time__c> createWeekTimes(Task__c task) {
        List<Time__c> times = new List<Time__c>();
        Date currentDate = System.today();
        Date startOfWeek = currentDate.toStartOfWeek();
        Date endOfWeek = startOfWeek.addDays(6);
        while (startOfWeek <= endOfWeek) {
            Time__c t = new Time__c(Date__c = startOfWeek,Task__c = task.Id);
            startOfWeek = startOfWeek.addDays(1);
            times.add(t);
        }
        return times;
    }
    public static Map<String, Time__c> getMapByWeekDay(List<Time__c> times) {

        Map<String, Time__c> weekDayMap = new Map<String, Time__c>();

        for (Time__c t : times) {
            Datetime d = (Datetime) t.Date__c;
            String weekDayDay = d.format('E');
            weekDayMap.put(weekDayDay, t);
        }
        System.debug('Week Day map' + weekDayMap.size());
        return weekDayMap;
    }
}
