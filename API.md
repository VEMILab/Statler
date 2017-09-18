# API

## Terminology
`{baseURL}` will refer to the URL for the server (including the port). So if the server is hosted at `www.example.com`, then `{baseURL}` will be `www.example.com:3000`.

**(protected)** means that the method requires authentication to perform the operation. You must supply either an API key or user token with each request. You may request a user token from the server using `login`.

For requests where you intend to use a user token, you must supply the following in the header:
```
Authorization: Token tok
```
Where `tok` is the token string retrieved from the server by using `login`.

For requests where you intend to use an API key, you must supply the following in the header: 
```
Authorization: ApiKey key
```
Where `key` is the API key.


## Annotation JSON structure
All annotations send to the server and retrieved from the server will be [W3C Web Annotation](https://www.w3.org/TR/annotation-model/) objects in JSON form. 

A sample annotation is below. Note that we support *only* these fields as of now. All information will be discarded when ingested by the server except for where noted. When annotations are retrieved from the server, the discarded information is inferred to be there and re-added (and therefore will be uniform across all annotations).

```json
{
    "@context": "http://www.w3.org/ns/anno.jsonld",
    "id": 1, // Kept by server
    "type": "Annotation",
    "motivation": "highlighting",
    "creator": {
        "type": "Person",
        "nickname": "test",
        "email": "a6ad00ac113a19d953efb91820d8788e2263b28a" // Kept by server. SHA1 email address
    },
    "body": [
        // Only one of these is permitted
        {
            "type": "TextualBody",
            "value": "Round meerkat", // Kept by server
            "format": "text/plain",
            "language": "en",
            "purpose": "describing"
        },
        // An arbitrary number of tags may be used by making more than one of this object
        {
            "type": "TextualBody",
            "purpose": "tagging",
            "value": "Actor" // Kept by server
        }
    ],
    "target": {
        "id": "http://sachinchoolur.github.io/lightGallery/static/videos/video2.mp4", // Kept by server
        "type": "Video",
        "selector": [
            // Only one SvgSelector is allowed
            {
                "type": "SvgSelector",
                "value": "<svg:svg viewBox='0 0 100 100' preserveAspectRatio='none'><polygon points='35,17.22222222222222 38.90625,12.222222222222221 42.34375,12.222222222222221 49.6875,33.61111111111111 50.625,48.61111111111111 46.40625,62.222222222222214 45.3125,70.55121527777779 34.375,69.16666666666667 32.65625,55.83333333333333 28.906249999999996,44.72222222222222 29.84375,32.77777777777778 33.90625,22.22222222222222' /></svg:svg>" // Kept by server
            },
            // Only one FragmentSelector is allowed
            {
                "type": "FragmentSelector",
                "conformsTo": "http://www.w3.org/TR/media-frags/",
                "value": "t=1.0,11.0" // Kept by server
            }
        ]
    }
}
```

## Methods

### `getAnnotationsByLocation`
`{baseURL}/api/getAnnotationsByLocation`

Request type: `GET`

Gets a JSON array of annotation objects for the video at the given URL.

Input JSON:
```json
{
    "location": url
}
```
Where `url` is the video's source URL as a string.

Output JSON:
- A JSON array of annotation objects


### `addAnnotation` (protected)
`{baseURL}/api/addAnnotation`

Request type: `POST`

Input JSON:
- A JSON object representing a W3C Web Annotation object.

Output JSON:
- `id`: The ID generated for the new annotation by the server

Do not supply an ID with the input JSON, or it will be treated as an edit and the server will give you an error.


### `editAnnotation` (protected)
`{baseURL}/api/editAnnotation`

What actually happens here is when an annotation is edited, it is canonically replaced with a clone that has the changes applied. For this reason, when editing an annotation, you must supply all the information needed to generate an entirely new annotation.

Input JSON is the same as for `addAnnotation`, with the following added:
- `id`: The ID of the annotation to be edited

Output JSON:
- `id`: The ID of the new annotation


### `Delete annotation` (protected)
`{baseURL}/api/deleteAnnotation`

Request type: `DELETE`

Input JSON:
- `id`: The ID of the annotation you want to delete

Output JSON:
- None


### `login`
`{baseURL}/api/login`

Request type: `POST`

Logs the user with the given `username` and `password` in. Returns a token generated for the user that should be supplied with all protected requests. Note that you don't need to use this if you're using an API key.

Request Header:
```
Authorization: Basic tk
```
Where `tk` is the Base64 conversion of the string `username + ":" + password`.

Example (username is `test`, password is `pass`): `Authorization: Basic dGVzdDpwYXNz`

Input JSON:
- None

Output JSON:
- `auth_token`: The token generated by the server. Use for all protected requests.


### `logout` (protected)
`{baseURL}/api/logout`

Request type: `DELETE`

Logs the user with the supplied token out.

Input JSON:
- None

Output JSON:
- None

