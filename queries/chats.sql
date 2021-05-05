WITH chats as (
  SELECT
  chat.chat_identifier as account,
  message.ROWID as message_id
  FROM
    [chat].[chat]
  JOIN [chat].[chat_message_join] ON chat.ROWID = chat_message_join.chat_id
  JOIN [chat].[message] ON chat_message_join.message_id = message.ROWID
)
SELECT
  json_object(
    'href', '/_memory/display?phone=' || replace(account, '+', ''),
    'label', account
  ) as Link,
  account,
  COUNT(*) as messages
FROM chats
WHERE
  account LIKE '+1%'
GROUP BY account
ORDER BY messages desc