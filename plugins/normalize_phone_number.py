import re
from datasette import hookimpl

def normalize_phone_number(phone):
    """
    Phone numbers in address books can take many forms
    e.g.
    ```
    (123) 456-7890    # +11234567890
    +1 (123) 456-7890 # +11234567890
    123-456-7890      # +11234567890
    ```
    Being lazy, we assume all phone numbers of interest are 10 digits and have a US country code of (+1)
    This assumption neglects sms short codes and foreign numbers which we leave alone (mostly)
    Here we avoid some ugly / tedious sql, especially given we lack regexp out of the box
    For illustration purposes, the sql expression would look something like
    ```
    CASE
        WHEN length(replace(replace(replace(replace(replace(phone,' ',''),'-',''),'(',''),')',''), '+', '')) = 10
            THEN "+1" || replace(replace(replace(replace(replace(phone,' ',''),'-',''),'(',''),')',''), '+', '')
        WHEN length(replace(replace(replace(replace(replace(phone,' ',''),'-',''),'(',''),')',''), '+', '')) = 11
            THEN "+" || replace(replace(replace(replace(replace(phone,' ',''),'-',''),'(',''),')',''), '+', '')
        ELSE replace(replace(replace(replace(replace(phone,' ',''),'-',''),'(',''),')',''), '+', '')
    END
    ```
    Plugins (see https://docs.datasette.io/en/stable/plugins.html) to the rescue!
    """
    digits = re.sub('\D+', '', phone)
    if len(digits) == 10:
        return "+1{}".format(digits)
    elif len(digits) == 11:
        return "+{}".format(digits)
    return digits

@hookimpl
def prepare_connection(conn):
    conn.create_function("normalize_phone_number", 1, normalize_phone_number)
