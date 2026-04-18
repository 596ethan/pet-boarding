# Pet Boarding Server

Spring Boot backend for the Pet Boarding Management System MVP.

## Stack

- Java 17 target, tested on local JDK 23
- Spring Boot 4.0.5
- Spring WebMVC
- Spring Data JPA
- Validation
- Flyway
- MySQL 8 for local runtime
- H2 for tests

## Local Database

Start Docker Desktop first, then run:

```powershell
docker compose up -d mysql
```

The default database config is:

- database: `pet_boarding`
- username: `petboarding`
- password: `petboarding`
- JDBC URL: `jdbc:mysql://localhost:13306/pet_boarding`

These defaults can be overridden before starting Docker or Spring Boot:

```powershell
$env:PET_BOARDING_MYSQL_PORT='13307'
$env:PET_BOARDING_MYSQL_DATABASE='pet_boarding'
$env:PET_BOARDING_DATASOURCE_USERNAME='petboarding'
$env:PET_BOARDING_DATASOURCE_PASSWORD='petboarding'
```

Spring Boot builds the JDBC URL from `PET_BOARDING_MYSQL_HOST`,
`PET_BOARDING_MYSQL_PORT`, and `PET_BOARDING_MYSQL_DATABASE`. To override the
whole URL directly, set:

```powershell
$env:PET_BOARDING_DATASOURCE_URL='jdbc:mysql://localhost:13307/pet_boarding?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai'
```

Flyway creates these MVP tables:

- `app_user`
- `owner`
- `pet`
- `room`
- `boarding_order`
- `care_record`

## Run

```powershell
mvn spring-boot:run
```

The server listens on `http://localhost:8080`.

## Demo Account

```text
username: admin
password: 123456
token: demo-token-admin
```

All `/api/**` endpoints except `/api/auth/login` and `/api/health` require:

```text
Authorization: Bearer demo-token-admin
```

## Verification

```powershell
mvn test
```

The tests use H2 and cover login, CRUD, delete blocking, check-in, care record restrictions, checkout, dashboard metrics, and the HTTP API demo flow.
