/**
 * Created by Sergey on 30.01.2021.
 */

import { LightningElement, track, api } from "lwc";

export default class WeekStartDateInput extends LightningElement {
    @track date;
    startWeekDate = JSON.stringify(new Date());

    handleDateChange(event) {
        this.date = event.detail.value;
        console.log("handle date change WEEK" + this.date);
        const dateChangeEvent = new CustomEvent("date", {
            detail: this.date,
        });
        this.dispatchEvent(dateChangeEvent);
    }
}
