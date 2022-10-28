
#!/bin/bash
echo 'Start script'

HEADER="Content-Type: application/json"
URL="https://iam.api.cloud.yandex.net/iam/v1/tokens"

RESULT=$(curl -d "{'yandexPassportOauthToken': '$YA_TOKEN' }" -H $HEADER -X POST $URL)
echo "Rezult = $RESULT"

IAMTOKEN=$(echo $RESULT | grep -oP '(?<=: )(.+)(?=,)' | tr -d '"')

echo "IAMTOKEN $IAMTOKEN"

AUTHHEADER="Authorization: Bearer $IAMTOKEN"
IDHEADER="X-Org-ID: $COMPANY_ID"
TICKET="HOMEWORKSHRI-140"

#TICKET_TEXT="Заголовок Заголовок Заголовок 12344"

TEXT=$(curl --write-out %{http_code} -H "$AUTHHEADER" -H "$IDHEADER" -d "{\"description\": \"$TICKET_TEXT\"}" -X PATCH "https://api.tracker.yandex.net/v2/issues/$TICKET" )

HTTPCODE=$(echo $TEXT | grep -Po '...$')

if [ "$HTTPCODE" = "200" ]
then
	exit 0
else
	exit 1
fi

