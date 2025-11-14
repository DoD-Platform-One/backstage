
# Configure dev instance of keycloak

This guide assumes that Keycloak is deployed with a realm other than "master" (e.g., "backstage") and that a client named "backstage" is created within this realm. The steps below detail how to configure the development version of Keycloak for use with Backstage.

1. Log in to dev instance keycloak
    - Access your deployed Keycloak instance  ([link](https://keycloak.dev.bigbang.mil/auth/admin/)) with default admin credentials.
2. Create a new realm named "backstage" (don't use the baby-yoda realm for development until the outstanding issue with baby-yoda realm is resolved)
3. Create a Backstage Client
    - In the "backstage" realm, create a new client named backstage with the Client ID set to backstage.
4. Create a Backstage client
    - Change the following configuration items
      - access type: enable clientAuthentication this will enable "Credentials"_
      - For authenticationflow select the following
           - standardFlow
           - serviceAccount  //this is only required if catalog is to be enabled.
      - Base URL: Set to <https://backstage.${DOMAIN}/*>
      - Valid Redirect URIs: Add the following URLs:
          - <https://backstage.${DOMAIN}/api/auth/keycloak/handler/frame/*>
      - Web Origins: Add the following URLs:
          - <https://backstage.${DOMAIN}/*>
      - ServiceAccount tab: Add the following roles. //this is only required if catalog is enabled.
            -  query-groups
            -  query-users
            -  view-users
      - Take note of Key Credentials
            -  In the Settings tab, make a note of the Client ID.
            -  In the Credentials tab, make a note of the Client Secret. These values will be used in the Backstage Keycloak configuration.
5. Create a Backstage user
    - on the users tab, create a new user named backstage with the following settings:
            - Username: backstage
            - Email: <backstage@example.com>
            - First Name: backstage
            - Last Name: backstage
            - Email Verified: false
            - On the Credentials tab set password to "backstage"
