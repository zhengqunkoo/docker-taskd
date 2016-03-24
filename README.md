# Docker-Taskd
Docker-Taskd is a containerized [Taskwarrior](https://taskwarrior.org/) server.

## Certificates
If there are no keys provided in `/taskd/pki`,
the server will generate self-signed certificates
based on the details specified in the `docker-compose.yml`.

## Requirements
- Docker
- docker-compose

## Usage
### Starting server
`docker-compose start`

### Stopping server
`docker-compose stop`

### Creating a user on server
- Open a shell: `docker exec -it $container sh`
- Create a group (if not done): `taskd add org '$group'`
- Add user to group: `taskd add user '$group' '$username'`
- Copy user key (refered to as `$cred`)
- Create cert/key `cd pki` `gosu taskd ./generate.client $user`
- Copy cert/key from the mounted volume or over `docker cp`

### Configure on client
- Copy `ca.cert.pem`, `$user.cert.pem` and `$user.key.pem` to client
- Add them to `.taskrc`
    - `task config taskd.certificate $pathTo/$user.cert.pem`
    - `task config taskd.key $pathTo/$user.key.pem`
    - `task config taskd.ca $pathTo/ca.cert.pem`
- Add server to `.taskrc` `task config taskd.server $host:53589`
- Add credentials to `.taskrc` `task config taskd.credentials $group/$username/$cred`
- Start sync with `task sync init`

## Documentation
[Taskwarrior docs](https://taskwarrior.org/docs/)
