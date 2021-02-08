/**
 * Created by Sergey on 30.01.2021.
 */

public class ConsultantController {

    @AuraEnabled(Cacheable=true)
    public static List<Contact> getAllConsultants(){
        List<Account> accounts =
        [SELECT Account.Name,
        (SELECT Contact.Name FROM Contacts)
        FROM Account WHERE Account.Id IN
        (SELECT Contact.AccountId FROM Contact)];

        List<Contact> contactList= new List<Contact>();
        for (Account a:accounts){
            contactList.addAll(a.Contacts);
        }
        System.debug(contactList);
        return contactList;
    }

}
