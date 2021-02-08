import { LightningElement, api, track } from "lwc";
import { refreshApex } from "@salesforce/apex";

export default class MainComponent extends LightningElement {
    @track taskDate = new Date();
    @track consultantId;
    showNewRecordFrom = false;
    @track wiredTask = [];

    handleDateChange(event) {
        console.log("main Event handler");

        this.taskDate = event.detail;
        console.log("handle date change Main " + this.taskDate);
    }

    handleConsultantChange(event) {
        console.log("main consultant handler" + event.detail);
        this.consultantId = event.detail;
    }
    handleTableRefresh(event) {
        console.log("refresh table run" + event.detail);
        refreshApex(wiredTask);
    }
    addRow() {
        this.showNewRecordFrom = true;
    }

    handleFormClose() {
        this.showNewRecordFrom = false;
    }
}
