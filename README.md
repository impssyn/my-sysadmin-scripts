# my-sysadmin-scripts

`script.sh` раз в 10 секунд дописывает в `monitor.log` снимок `free -h`, `df -h` и `uptime` с временной меткой (вариант Б — мониторинг ресурсов).

## Запуск

```bash
./script.sh                          # бесконечно, Ctrl+C — остановка
ITERATIONS=3 ./script.sh             # сделать 3 снимка и выйти
LOG_FILE=/tmp/mon.log ./script.sh    # писать лог в другое место
```

## Формат лога

```
--- 2026-10-18 21:12:10 ---
<вывод free -h>
<вывод df -h>
<вывод uptime>
```

Пример — в [`sample_output.txt`](sample_output.txt).

## Обработка ошибок

| Ситуация | Поведение | Код выхода |
|---|---|---|
| нет утилиты `free`/`df`/`uptime` | сообщение в stderr | 1 |
| `ITERATIONS` не число | сообщение в stderr | 2 |
| нет прав на запись лога | сообщение в stderr | 3 |
| SIGINT / SIGTERM (`Ctrl+C`, `docker stop`, `systemctl stop`) | строка «остановлен» в логе, чистый выход | 0 |

## Docker

```bash
docker build -t my-script .
docker run -d -p 127.0.0.1:8080:8080 --name my-app my-script
curl http://127.0.0.1:8080/monitor.log
docker compose up        # 3 снимка, лог в ./logs
```

## Деплой (nginx + TLS + systemd)

| Файл | Куда |
|---|---|
| `deploy/nginx-my-app.conf` | `/etc/nginx/sites-available/my-app` |
| `deploy/my-app.service` | `/etc/systemd/system/my-app.service` |

- 80 → 301 на `https://<host>:8443`
- 8443 (TLS, self-signed) → `proxy_pass http://127.0.0.1:8080`
- 443 на хосте занят другим сервисом, поэтому HTTPS на 8443

```bash
curl -kI https://<host>:8443/
sudo journalctl -u my-app -f
sudo tail -f /var/log/nginx/access.log
```
