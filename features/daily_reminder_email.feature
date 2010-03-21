Feature: Daily reminder for tasks email
  In order to have a summary of what I should do that day
  As a user
  I want to receive a list of my tasks for that day

  Background:
    Given a confirmed user exists with login: "mislav", time_zone: "Amsterdam"
    And a project exists with name: "Aquaculture"
    And the task list called "ASAP" belongs to the project called "Aquaculture"
    And the following task with associations exist:
      | name                                   | task_list | project        |
      | Give water to the flowers              | ASAP      | Aquaculture    |
    And I am currently "mislav"
    And I have the daily task reminders turned on
    And we are in the "UTC" time zone
    And the daily task reminder emails are set to be sent at "06:00"

  Scenario: User with a late task assigned to him
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" was due 3 days ago
    When the daily task reminders go out at "05:00"
    Then I should receive an email
    When I open the email with subject "Daily task reminder"
    Then I should see "Late tasks" in the email body
    And I should see "Give water to the flowers" in the email body

  Scenario: User with a task due today assigned to him
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due today
    When the daily task reminders go out at "05:00"
    Then I should receive an email
    When I open the email with subject "Daily task reminder"
    Then I should see "Tasks for today" in the email body
    And I should see "Give water to the flowers" in the email body
    When I follow "Give water to the flowers" in the email
    And I fill in "Email or Username" with "mislav"
    And I fill in "Password" with "dragons"
    And I press "Login"
    Then I should see "Aquaculture"
    Then I should see "Give water to the flowers"

  Scenario: User with a task due today assigned to him at a diff. hour
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due today
    When the daily task reminders go out at "09:00"
    Then I should receive no emails

  Scenario Outline: User with a task due some time in the next two weeks - today is a weekend day
    Given today is "<date>"
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due in 3 days
    When the daily task reminders go out at "05:00"
    Then I should receive no emails

    Examples:
      | date        |
      | 2010/02/13  |
      | 2010/02/14  |

  Scenario: User with the task reminders turned off
    Given I have the daily task reminders turned off
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due today
    When the daily task reminders go out at "05:00"
    Then I should receive no emails

  Scenario: User with a task due tomorrow assigned to him
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due tomorrow
    When the daily task reminders go out at "05:00"
    When I open the email with subject "Daily task reminder"
    Then I should see "Tasks for tomorrow" in the email body
    And I should see "Give water to the flowers" in the email body

  Scenario: User with a task due some time in the next two weeks
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" is due in 4 days
    When the daily task reminders go out at "05:00"
    When I open the email with subject "Daily task reminder"
    Then I should see "Tasks for next two weeks" in the email body
    And I should see "Give water to the flowers" in the email body
    But I should not see "Tasks for tomorrow" in the email body

  Scenario Outline: User assigned a task without a due date - today is Monday or Thursday
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" does not have a due date
    And today is "<date>"
    When the daily task reminders go out at "05:00"
    When I open the email with subject "Daily task reminder"
    Then I should see "Tasks without a due date" in the email body
    And I should see "Give water to the flowers" in the email body

    Examples:
      | date        |
      | 2010/02/15  |
      | 2010/02/18  |

  Scenario Outline: User assigned a task without a due date - today is NOT Monday or Thursday
    Given the task called "Give water to the flowers" is assigned to me
    And the task called "Give water to the flowers" does not have a due date
    And today is "<date>"
    When the daily task reminders go out at "05:00"
    Then I should receive no emails

    Examples:
      | date        |
      | 2010/02/16  |
      | 2010/02/17  |
      | 2010/02/20  |

  Scenario: User assigned a story due today and another one without a due date - today is NOT Monday or Thursday
    Given the following task with associations exist:
      | name                                   | task_list | project        |
      | Flood the trees                        | ASAP      | Aquaculture    |
    And today is "2010/02/16"
    And the task called "Give water to the flowers" is assigned to me
    And the task called "Flood the trees" is assigned to me
    And the task called "Give water to the flowers" is due today
    And the task called "Flood the trees" does not have a due date
    When the daily task reminders go out at "05:00"
    Then I should receive an email
    When I open the email with subject "Daily task reminder"
    Then I should see "Tasks for today" in the email body
    And I should see "Give water to the flowers" in the email body
    Then I should see "Tasks without a due date" in the email body
    And I should see "Flood the trees" in the email body

  Scenario: User in a project that has a task due today but not assigned that task
    Given a user exists with login: "balint"
    And the task called "Give water to the flowers" is assigned to "balint"
    And the task called "Give water to the flowers" is due today
    When the daily task reminders go out at "05:00"
    Then I should receive no emails

  Scenario: User with no tasks
    Given I have no tasks assigned to me
    When the daily task reminders go out at "05:00"
    Then I should receive no emails
