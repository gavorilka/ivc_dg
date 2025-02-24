
## API cервис для выгрузки данных о работниках из IVC DataGate

Сервис позволяет на сайт отдавать информацию из IVC DataGate Параграф. 

##  Как добавить 
- папку site_data со всем содержим, положить в IVC DataGate по адресу: `\\0.0.0.0\c$\Program Files (x86)\IVC\DataGate\htdocs\webservice`, где 0.0.0.0 ваш удалённый сервис IVC DataGate

- добавить в бд хранимые функции из файлов *.sql

- перезапустить сервис IVC DataGate

#### Команды в Windows
```bash
    sc stop DatagateAppServer
    sc start DatagateAppServer
    sc query DatagateAppServer
```



## API Запросы

#### Получить всех учителей

```http
  GET /webservice/site_data/execute?action=teachers
```

| Get Parameter | Type     | Value    |Description   |
| :------------ | :------- | :--------|:-------------|
| `action`      | `string` | teachers |***Requerid** |

#### Получить все группы сотрудников

```http
  GET  /webservice/site_data/execute?action=group_employees
```

| Get Parameter | Type     | Value           |Description   |
| :------------ | :------- | :---------------|:-------------|
| `action`      | `string` | group_employees |***Requerid** |

#### Получить все должности сотрудников

```http
  GET  /webservice/site_data/execute?action=positions
```

| Get Parameter | Type     | Value     |Description   |
| :------------ | :------- | :---------|:-------------|
| `action`      | `string` | positions |***Requerid** |

#### Получить изображение сотрудника

```http
  GET  /webservice/site_data/execute?action=files_stream&id=${id}&name=${name}
```

| Get Parameter | Type     | Value        |Description                             |
| :------------ | :------- | :------------|:---------------------------------------|
| `action`      | `string` | files_stream |***Requerid**                           |
| `id`          | `number` |              |***Requerid** идентификитор изображения |
| `fileName`    | `string` |              |***Requerid** имя изображения           |


