# my-sysadmin-scripts

script.sh раз в 10 секунд дописывает в monitor.log вывод free -h, df -h и uptime с временной меткой. Вариант Б, мониторинг ресурсов.

## Запуск

```bash
./script.sh                          # работает, пока не остановить Ctrl+C
ITERATIONS=3 ./script.sh             # 3 снимка и выход
LOG_FILE=/tmp/mon.log ./script.sh    # лог в другом месте
```

Каждый снимок в логе начинается со строки с датой, например `--- 2026-10-18 21:12:10 ---`. Пример лежит в sample_output.txt.

Если нет нужных утилит, ITERATIONS не число или нет прав на запись лога, скрипт пишет ошибку и выходит с кодом 1, 2 или 3. По Ctrl+C или SIGTERM записывает в лог строку об остановке и выходит с кодом 0.

## Docker

```bash
docker build -t my-script .
docker run -d -p 127.0.0.1:8080:8080 --name my-app my-script
curl http://127.0.0.1:8080/monitor.log
docker compose up        # 3 снимка, лог сохраняется в ./logs
```

В контейнере вместе со скриптом работает python http.server на порту 8080, он отдаёт monitor.log.

## nginx, TLS и systemd

Конфиг nginx лежит в deploy/nginx-my-app.conf, его нужно скопировать в /etc/nginx/sites-available/my-app. Unit-файл deploy/my-app.service копируется в /etc/systemd/system/.

С порта 80 идёт редирект на HTTPS. HTTPS работает на 8443, потому что 443 на сервере уже занят. Сертификат самоподписанный.

```bash
curl -kI https://<host>:8443/
sudo journalctl -u my-app -f
sudo tail -f /var/log/nginx/access.log
```
