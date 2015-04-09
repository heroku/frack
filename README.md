Create row
```
~ ➤ curl -s localhost:5000/tables/ok -X POST -d '{"a": 1 }' | jq .
"c2e5fa07-abc6-45e0-9bef-5c7521ab3982"
```

Get row
```
~ ➤ curl -s localhost:5000/tables/ok/c2e5fa07-abc6-45e0-9bef-5c7521ab3982 -X GET | jq .
{
  "id": "c2e5fa07-abc6-45e0-9bef-5c7521ab3982",
  "data": {
    "a": 1
  },
  "seq": 0,
  "created_at": "2015-04-09 15:49:11 -0700",
  "updated_at": "2015-04-09 15:49:11 -0700"
}
```

Update row
```
~ ➤ curl -s localhost:5000/tables/ok/0bbb1fee-898f-4c5e-85c8-403e55d9a6e1 -X PUT -d '{"a":1, "b":2}' | jq .
{
  "id": "0bbb1fee-898f-4c5e-85c8-403e55d9a6e1",
  "data": {
    "a": 1,
    "b": 2
  },
  "seq": 21,
  "created_at": "2015-04-08 15:11:20 -0700",
  "updated_at": "2015-04-09 22:47:38 UTC"
}

~ ➤ curl -s localhost:5000/tables/ok/0bbb1fee-898f-4c5e-85c8-403e55d9a6e1 -X PATCH -d '{"d": [3,4]}' | jq .
{
  "id": "0bbb1fee-898f-4c5e-85c8-403e55d9a6e1",
  "data": {
    "a": 1,
    "b": 2,
    "d": [
      3,
      4
    ]
  },
  "seq": 22,
  "created_at": "2015-04-08 15:11:20 -0700",
  "updated_at": "2015-04-09 22:48:47 UTC"
}
```

Search rows
```
~ ➤ curl -s localhost:5000/tables/ok -X GET --data-urlencode 'q={"a":1}' | jq .
[
  {
    "id": "0bbb1fee-898f-4c5e-85c8-403e55d9a6e1",
    "data": {
      "a": 1,
      "b": 2,
      "d": [
        3,
        4
      ]
    },
    "seq": 22,
    "created_at": "2015-04-08 15:11:20 -0700",
    "updated_at": "2015-04-09 15:48:47 -0700"
  },
  {
    "id": "c2e5fa07-abc6-45e0-9bef-5c7521ab3982",
    "data": {
      "a": 1
    },
    "seq": 0,
    "created_at": "2015-04-09 15:49:11 -0700",
    "updated_at": "2015-04-09 15:49:11 -0700"
  }
]

~ ➤ curl -s localhost:5000/tables/ok -X GET --data-urlencode 'q={"b":2}' | jq .
[
  {
    "id": "0bbb1fee-898f-4c5e-85c8-403e55d9a6e1",
    "data": {
      "a": 1,
      "b": 2,
      "d": [
        3,
        4
      ]
    },
    "seq": 22,
    "created_at": "2015-04-08 15:11:20 -0700",
    "updated_at": "2015-04-09 15:48:47 -0700"
  }
]
```
