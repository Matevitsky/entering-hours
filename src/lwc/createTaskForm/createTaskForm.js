/**
 * Created by Sergey on 06.02.2021.
 */

import { LightningElement } from "lwc";
import NAME_FIELD from "@salesforce/schema/Task__c.Name";
import BILLING_RULE from "@salesforce/schema/Task__c.Billing_Rule__c";
import CONSULTANT from "@salesforce/schema/Task__c.Consultant__c";
import PROJECT from "@salesforce/schema/Task__c.Project__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CreateTaskForm extends LightningElement {
    fields = [NAME_FIELD, BILLING_RULE, CONSULTANT, PROJECT];

    closeModal() {
        this.dispatchEvent(new CustomEvent("closeform"));
        this.dispatchEvent(new CustomEvent("refreshtable"));
    }
    handleSuccess() {
        const evt = new ShowToastEvent({
            title: "Account created",
            message: "Record ID: " + event.detail.id,
            variant: "success",
        });
        this.dispatchEvent(evt);
    }
}
