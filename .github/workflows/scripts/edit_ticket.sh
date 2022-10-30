
#!/bin/bash
LATEST_TAG=$(git describe --match "rc-*" --abbrev=0 --tags $(git rev-list --tags --max-count=1))
PREVIOUS_TAG=$(git describe --match "rc-*" --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))
RELEASE_DATE=$(git log --max-count=1 --pretty=format:"%cs" $LATEST_TAG)

if [ -z "$PREVIOUS_TAG" ]
then 
	COMMITS_BETWEN=$(git log --pretty=format:"%h  %cn  %s %d \n" $LATEST_TAG | grep -v tag)
else 
	COMMITS_BETWEN=$(git log --pretty=format:"%h  %cn  %s %d \n" $PREVIOUS_TAG..$LATEST_TAG | grep -v tag)
fi

TICKET_TEXT="Responsible for release $GITHUB_ACTOR \n commits included in the release: \n$(echo $COMMITS_BETWEN)"
TITLE_TEXT="RELEASE $LATEST_TAG - $RELEASE_DATE"

echo 'Get token to patch ticket'

HEADER="Content-Type:application/json"
URL="https://iam.api.cloud.yandex.net/iam/v1/tokens"

RESULT=$(curl -d "{\"yandexPassportOauthToken\": \"$YA_TOKEN\" }" -H $HEADER -X POST $URL)
IAMTOKEN=$(echo $RESULT | grep -oP '(?<=: )(.+)(?=,)' | tr -d '"')

echo "Patch ticket description $IAMTOKEN"

AUTHHEADER="Authorization: Bearer $IAMTOKEN"
IDHEADER="X-Org-ID: $COMPANY_ID"
JSONHEADER="Content-Type: application/json"
TICKET="HOMEWORKSHRI-140"

TEXT=$(curl --write-out %{http_code} -H "$AUTHHEADER" -H "$IDHEADER" -d "{\"description\": \"$TICKET_TEXT\",\"summary\": \"$TITLE_TEXT\"}" -X PATCH "https://api.tracker.yandex.net/v2/issues/$TICKET" )

HTTPCODE=$(echo $TEXT | grep -Po '...$')

if [ "$HTTPCODE" = "200" ]
then
	exit 0
else
	exit 1
fi
