Feature: User registration and login

  Scenario: Successful registration
    Given a fresh game installation
    When the user registers with valid credentials
    Then the account is created and persisted

  Scenario: Login updates last_login
    Given an existing user
    When the user logs in with correct credentials
    Then the user's `last_login` timestamp is updated
