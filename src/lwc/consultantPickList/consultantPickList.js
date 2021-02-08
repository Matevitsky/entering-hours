/**
 * Created by Sergey on 30.01.2021.
 */

import { LightningElement, track, wire } from "lwc";
import getAllConsultants from "@salesforce/apex/ConsultantController.getAllConsultants";

export default class ConsultantPickList extends LightningElement {
    @track items = [];
    @track value = "";

    @wire(getAllConsultants)
    wiredContacts({ error, data }) {
        if (data) {
            let i = 0;
            for (i = 0; i < data.length; i++) {
                this.items = [
                    ...this.items,
                    { value: data[i].Id, label: data[i].Name },
                ];
            }

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }
    handleConsultantChange(event) {
        const selectedOption = event.detail.value;
        console.log("handle consultant change1" + selectedOption);
        const dateChangeEvent = new CustomEvent("consultantchange", {
            detail: selectedOption,
        });
        this.dispatchEvent(dateChangeEvent);
    }
}
