import { LightningElement, api, track, wire } from "lwc";
import getTasksByDate from "@salesforce/apex/TaskController.getTasksByDate";
import getTasksByConsultant from "@salesforce/apex/TaskController.getTasksByConsultant";
import updateTasks from "@salesforce/apex/TaskController.updateTasks";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { deleteRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import { getRecordNotifyChange } from "lightning/uiRecordApi";

export default class Task extends LightningElement {
    @api taskDate;
    @api consultant;
    @track keyIndex = 0;
    @track error;
    @api recordId;
    @track tasks = [];
    draftValues = [];
    @api wiredTask = [];

    @track columns = [
        { label: "Project - Task", fieldName: "projectAndTaskName" ,  initialWidth: 300},
        { label: "Non-Billable", fieldName: "nonBillable", type: "boolean" },
        { label: "Mon", fieldName: "Mon", editable: true ,type: "number"},
        { label: "Tue", fieldName: "Tue", editable: true ,type: "number"},
        { label: "Wed", fieldName: "Wed", editable: true ,type: "number"},
        { label: "Thu", fieldName: "Thu", editable: true , type: "number"},
        { label: "Fri", fieldName: "Fri", editable: true , type: "number"},
        { label: "Sat", fieldName: "Sat", editable: true , type: "number"},
        { label: "Sun", fieldName: "Sun", editable: true , type: "number"},
        {
            type: "button-icon",
            typeAttributes: {
                iconName: "action:delete",
                label: "",
                name: "delete task",
                title: "Delete Task",
                value: "",
            },
        },
    ];

    @wire(getTasksByDate, { taskDate: "$taskDate" })
    tasksByDate(result) {
        this.wiredTask = result;
        if (result.data) {
            this.tasks = result.data;
        }
    }

    @wire(getTasksByConsultant, { consultantId: "$consultant" })
    tasksByConsultantId(result) {
        this.wiredTask = result;
        if (result.data) {
            this.tasks = result.data;
        }
    }

    handleDelete(event) {
        console.log(
            "THIS IS Access Key " + JSON.stringify(event.detail.row.Id)
        );
        let taskId = event.detail.row.Id;
        deleteRecord(taskId)
            .then(() => {
                refreshApex(this.wiredTask);
                const evt = new ShowToastEvent({
                    title: "Success",
                    message: "Task deleted",
                    variant: "success",
                    mode: "dismissable",
                });

                this.dispatchEvent(evt);
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: "Task not deleted",
                    variant: "error",
                    mode: "dismissable",
                });
                this.dispatchEvent(evt);
            });
    }

    async handleSave(event) {
        const updatedFields = event.detail.draftValues;

        const notifyChangeIds = updatedFields.map((task) => {
            return { recordId: task.Id };
        });


         await updateTasks({ data: updatedFields })
            .then((result) => {
                  this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Contact updated",
                        variant: "success",
                    })
                );

                // Refresh LDS cache and wires
                getRecordNotifyChange(notifyChangeIds);

                // Display fresh data in the datatable
                refreshApex(this.wiredTask).then(() => {
                    // Clear all draft values in the datatable
                    this.draftValues = [];
                });
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error updating or refreshing records",
                        message: error.body.message,
                        variant: "error",
                    })
                );
            });
    }
}
