
#!/bin/bash

LATEST_TAG=$(git describe --abbrev=0 --tags $(git rev-list --tags --max-count=1`))
PREVIOUS_TAG=$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1`))

COMMITS_BETWEN=$(git log --pretty=format:"%h  %cn  %s %D" $PREVIOUS_TAG..$LATEST_TAG | grep -v tag)

TICKET_TEXT=$"Ответственный за релиз $GITHUB_ACTOR \n коммиты, попавшие в релиз: \n $COMMITS_BETWEN"

echo "LATEST_TAG $LATEST_TAG"
echo "PREVIOUS_TAG $PREVIOUS_TAG"
echo "COMMITS_BETWEN $COMMITS_BETWEN"
echo "TICKET_TEXT $TICKET_TEXT"

echo 'Get token to patch ticket'

HEADER="Content-Type:application/json"
URL="https://iam.api.cloud.yandex.net/iam/v1/tokens"

RESULT=$(curl -d "{'yandexPassportOauthToken': '$YA_TOKEN' }" -H $HEADER -X POST $URL)
IAMTOKEN=$(echo $RESULT | grep -oP '(?<=: )(.+)(?=,)' | tr -d '"')

echo "Patch ticket description"

AUTHHEADER="Authorization: Bearer $IAMTOKEN"
IDHEADER="X-Org-ID: $COMPANY_ID"
TICKET="HOMEWORKSHRI-140"

TEXT=$(curl --write-out %{http_code} -H "$AUTHHEADER" -H "$IDHEADER" -d "{\"description\": \"$TICKET_TEXT\"}" -X PATCH "https://api.tracker.yandex.net/v2/issues/$TICKET" )

HTTPCODE=$(echo $TEXT | grep -Po '...$')

if [ "$HTTPCODE" = "200" ]
then
	exit 0
else
	exit 1
fi

