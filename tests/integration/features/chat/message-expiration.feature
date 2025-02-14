Feature: chat/message-expiration
  Background:
    Given user "participant1" exists
    Given user "participant2" exists
    Given user "participant3" exists

  Scenario: Enable message expiration and check after expire
    Given user "participant1" creates room "room" (v4)
      | roomType | 3 |
      | roomName | room |
    And user "participant1" adds user "participant2" to room "room" with 200 (v4)
    And user "participant1" sends message "Message 1" to room "room" with 201
    And user "participant1" set the message expiration to -1 of room "room" with 400 (v4)
    And user "participant2" set the message expiration to 3 of room "room" with 403 (v4)
    And user "participant3" set the message expiration to 3 of room "room" with 404 (v4)
    And user "participant1" set the message expiration to 3 of room "room" with 200 (v4)
    And user "participant1" sends message "Message 2" to room "room" with 201
    Then user "participant1" is participant of the following rooms (v4)
      | id   | type | messageExpiration |
      | room | 3    | 3                 |
    And wait for 3 seconds
    And apply message expiration job manually
    Then user "participant1" sees the following messages in room "room" with 200
      | room | actorType | actorId      | actorDisplayName         | message     | messageParameters | parentMessage |
      | room | users     | participant1 | participant1-displayname | Message 1   | []                |               |

  Scenario: Expire shared file
    Given user "participant1" creates room "room2" (v4)
      | roomType | 3     |
      | roomName | room2 |
    And user "participant1" set the message expiration to 3 of room "room2" with 200 (v4)
    When user "participant1" shares "welcome.txt" with room "room2" with OCS 100
    And user "participant1" sees the following messages in room "room2" with 200
      | room  | actorType | actorId      | actorDisplayName         | message  | messageParameters |
      | room2 | users     | participant1 | participant1-displayname | {file}   | "IGNORE"          |
    And wait for 3 seconds
    And apply message expiration job manually
    Then user "participant1" sees the following messages in room "room2" with 200
      | room | actorType | actorId      | actorDisplayName         | message     | messageParameters | parentMessage |
    And user "participant1" gets last share
    And the OCS status code should be 404
