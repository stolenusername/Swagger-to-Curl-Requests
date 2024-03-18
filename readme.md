This script is to process Swagger 2.0 JSON files and convert them to curl requests proxied through BurpSuite for API Security Assessments.

`Usage: ./curl.sh <swagger_file> [<base_url>] [<x_api_key>] [<proxy>] [<output_file>]`

As an example:

` ./curl.sh some-swagger.json https://api.domain.com/endpoint APIKEYAPIKEY 127.0.0.1:8080 myendpoint.txt`

The end result is an output file called 'myendpoint.txt' containing curl requests for each of the API calls. From this point you can set the permissions of the output file to execute and run it from the CLI like this: `sh myendpoint.txt`.

The curl requests will then be processed through BurpSuite if you have it configured to listen on the port you passed off when you ran the script.
