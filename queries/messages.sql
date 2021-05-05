WITH raw_records as (
  select
    normalize_phone_number(phone.ZFULLNUMBER) as phone,
    record.ZFIRSTNAME as first_name,
    record.ZLASTNAME as last_name
  from
    [AddressBook-v22].[ZABCDRECORD] as record
    JOIN [AddressBook-v22].[ZABCDPHONENUMBER] as phone on record.Z_PK = phone.ZOWNER
  WHERE
    phone IS NOT NULL
),
records as (
SELECT
  phone,
  min(first_name) as first_name,
  min(last_name) as last_name
FROM
  raw_records
GROUP BY
  phone
),
attachments AS (
select
    ROWID,
    filename as img_src,
    '/-/media/photo/' || ROWID as media_src,
    json_object(
        'img_src', '/-/media/photo/' || ROWID,
        'width', '200'
    ) as photo
from
    [chat].[attachment]
WHERE
    mime_type LIKE 'image/%' 
),
chat_records AS (
SELECT
  chat.chat_identifier as account,
  message.text as message,
  message.date as raw_date,
  datetime(
    message.date / 1000000000 + 978307200,
    'unixepoch',
    'localtime'
  ) as message_date,
  attachments.photo,
  attachments.img_src,
  attachments.media_src,
  message.is_from_me AS is_from_me
FROM
  [chat].[chat]
  JOIN [chat].[chat_message_join] ON chat.ROWID = chat_message_join.chat_id
  JOIN [chat].[message] ON chat_message_join.message_id = message.ROWID
  LEFT JOIN [chat].[message_attachment_join] ON chat_message_join.message_id = message_attachment_join.message_id
  LEFT JOIN attachments ON  message_attachment_join.attachment_id = attachments.ROWID
)
SELECT
CASE
  WHEN chat_records.is_from_me THEN 'To'
  ELSE 'From'
END AS direction,
records.first_name,
records.last_name,
chat_records.*
FROM
chat_records
LEFT JOIN records ON chat_records.account = records.phone
WHERE
account like '%' || :phone || '%'
AND message like '%' || :message || '%'
AND message_date like '%' || :date || '%'
ORDER BY
raw_date asc
