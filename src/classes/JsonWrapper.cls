/**
 * Created by Sergey on 06.02.2021.
 */

public  class JsonWrapper {
        @AuraEnabled public String projectAndTaskName { get; set; }
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public Boolean nonBillable { get; set; }
        @AuraEnabled public Integer Mon { get; set; }
        @AuraEnabled public Integer Tue { get; set; }
        @AuraEnabled public Integer Wed { get; set; }
        @AuraEnabled public Integer Thu { get; set; }
        @AuraEnabled public Integer Fri { get; set; }
        @AuraEnabled public Integer Sat { get; set; }
        @AuraEnabled public Integer Sun { get; set; }

    public static JsonWrapper timeSpendToWeekDay(JsonWrapper json, List<Time__c> timeList) {
        for (Time__c timeObject : timeList) {
            Datetime d = (Datetime) timeObject.Date__c;
            Integer timeSpend = Integer.valueOf(timeObject.Time_spend__c);
            String weekDayDate = d.format('E');

            switch on weekDayDate {
                when 'Mon' {
                    json.Mon = timeSpend;
                }
                when 'Tue' {
                    json.Tue = timeSpend;
                }
                when 'Wed' {
                    json.Wed = timeSpend;
                }
                when 'Thu' {
                    json.Thu = timeSpend;
                }
                when 'Fri' {
                    json.Fri = timeSpend;
                }
                when 'Sat' {
                    json.Sat = timeSpend;
                }

                when 'Sun' {
                    json.Sun = timeSpend;
                }
            }
        }

        return json;
    }
    public static List<JsonWrapper> mapToJson(List<Task__c> taskList) {

        List<JsonWrapper> jsonWrappers = new List<JsonWrapper>();
        for (Task__c task : taskList) {
            JsonWrapper json = new JsonWrapper();
            json.nonBillable = task.Billing_Rule__r.Non_billable__c;
            json.Id = task.Id;
            json.projectAndTaskName = task.Project__r.Name + ' - ' + task.Name;
            timeSpendToWeekDay(json, task.Task_Time__r);
            jsonWrappers.add(json);
        }
        return jsonWrappers;
    }

}
