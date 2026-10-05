import { createElement } from "lwc";
import AccountContactCounter from "c/accountContactCounter";
import getContactCount from "@salesforce/apex/AccountContactCounterController.getContactCount";

jest.mock(
  "@salesforce/apex/AccountContactCounterController.getContactCount",
  () => {
    const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return { default: createApexTestWireAdapter(jest.fn()) };
  },
  { virtual: true }
);

const createComponent = () => {
  const element = createElement("c-account-contact-counter", {
    is: AccountContactCounter
  });
  element.recordId = "001000000000001AAA";
  document.body.appendChild(element);
  return element;
};

describe("c-account-contact-counter", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders the contact count", async () => {
    const element = createComponent();
    getContactCount.emit(5);
    await Promise.resolve();
    expect(
      element.shadowRoot.querySelector(".slds-text-heading_large").textContent
    ).toBe("5");
  });

  it("renders zero", async () => {
    const element = createComponent();
    getContactCount.emit(0);
    await Promise.resolve();
    expect(
      element.shadowRoot.querySelector(".slds-text-heading_large").textContent
    ).toBe("0");
  });

  it("renders an error message", async () => {
    const element = createComponent();
    getContactCount.error({ message: "Boom" }, 500);
    await Promise.resolve();
    expect(
      element.shadowRoot.querySelector(".slds-text-color_error").textContent
    ).toBe("Boom");
  });
});
