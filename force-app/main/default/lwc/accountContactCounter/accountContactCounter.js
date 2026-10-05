import { LightningElement, api, wire } from "lwc";
import getContactCount from "@salesforce/apex/AccountContactCounterController.getContactCount";

export default class AccountContactCounter extends LightningElement {
  @api recordId;

  count;
  error;

  @wire(getContactCount, { accountId: "$recordId" })
  wiredCount({ data, error }) {
    if (data !== undefined) {
      this.count = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.count = undefined;
    }
  }

  get isLoading() {
    return this.count === undefined && !this.error;
  }

  get hasError() {
    return !!this.error;
  }

  get hasCount() {
    return this.count !== undefined;
  }

  get errorMessage() {
    return this.error?.body?.message || "Unable to load contact count.";
  }
}
