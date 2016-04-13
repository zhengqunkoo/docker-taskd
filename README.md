# Docker-Taskd
[Docker-Taskd](https://hub.docker.com/r/x4121/taskd) is a containerized [Taskwarrior](https://taskwarrior.org/) server.

## Certificates
If there are no keys provided in `./taskd/pki`,
the server will generate self-signed certificates
based on the details specified in the `docker-compose.yml`.

## Requirements
- [Docker](https://www.docker.com/)
- [docker-compose](https://www.docker.com/products/docker-compose)

## Usage
### Starting server
For the initial start, make sure to provide certificates or check the
certificate values in `docker-compose.yml`.

`docker-compose up -d`

Remember the container id (refered to as `$container`),
it's printed as `Creating $container`.

### Starting without docker-compose
If you can't or don't want to use docker-compose, run

```
docker run -d --name taskd \
  -p 53589:53589 \
  -v $PWD/taskd:/var/taskd \
  -e CERT_CN="taskd" \
  -e CERT_ORGANIZATION="some org" \
  -e CERT_COUNTRY="DE" \
  -e CERT_STATE="Bavaria" \
  -e CERT_LOCALITY="Munich" \
  x4121/taskd:latest
```

### Stopping server
`docker-compose stop`

### Creating a user on server
To create a new user named `$username` (whitespaces allowed)
as member of the group `$group` (no whitespaces allowed) and
create a set of keys with file prefix `$user` (no whitespaces allowed):

#### Open a shell on the server
`docker exec -it $container sh`

The container name `$container` is printed on startup.

#### Create a new group (if not done)
If you want to use an existing group, skip this step. Don't use
whitespaces in the group name `$group`.

`taskd add org '$group'`

#### Add user to group
`taskd add user '$group' '$username'`

This will print `New user key: $cred`.
Copy this value, it's used on the client.

#### Create keys for the new user
```
cd pki
gosu taskd ./generate.client $user`
```
The generated files can be found in `./taskd/pki`

### Configuration on client
Copy the files `ca.cert.pem`, `$user.cert.pem` and
`$user.key.pem` to the client.

#### Editing .taskrc
Add the following configs to your `.taskrc`:
```
task config taskd.certificate $pathTo/$user.cert.pem
task config taskd.key $pathTo/$user.key.pem
task config taskd.ca $pathTo/ca.cert.pem
task config taskd.server $host:53589
task config taskd.credentials $group/$username/$cred
```

#### Initialize synchronization
`task sync init`

This is only necessary once.
Following synchronizations will be done with `task sync`.

## Documentation
[Taskwarrior docs](https://taskwarrior.org/docs/)
