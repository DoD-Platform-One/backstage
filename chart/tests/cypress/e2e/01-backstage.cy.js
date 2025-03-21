const customTimeout = Cypress.env("timeout") ?? 120_000;

const testConfig = {
  // every cy.visit assumes this base URL
  baseUrl: Cypress.env("url"),

  // some argo UI actions can be flaky so let's give ourselves a second chance
  retries: { runMode: 3, openMode: 0 },

  // wait a good long while before giving up on an Argo UI element reaching expected state
  defaultCommandTimeout: customTimeout,
};

const loadLoginSession = () => {
  cy.session("login", () => {
    cy.visit("/", { timeout: customTimeout });
    cy.get(':nth-child(1) > .MuiPaper-root-170 > .MuiCardActions-root-212 > .MuiButtonBase-root-241 > .MuiButton-label-215').click();
  });
};

beforeEach(() => {
  loadLoginSession();
});

after(() => {
  Cypress.session.clearCurrentSessionData;
});

describe(`Backstage smoke tests [baseUrl: ${testConfig.baseUrl}]`, testConfig, () => {

  it('Should be able to log into the system and view the example website', function() {

    cy.visit('/catalog/default/component/base-deployment');
    cy.get('span[title="component:default/base-deployment | website"]').should('have.text', 'base-deployment');


  });
})