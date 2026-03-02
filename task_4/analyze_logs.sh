#!/bin/bash

# Создаем файл с логами (для тестирования)
cat <<EOL > access.log
192.168.1.1 - - [28/Jul/2024:12:34:56 +0000] "GET /index.html HTTP/1.1" 200 1234
192.168.1.2 - - [28/Jul/2024:12:35:56 +0000] "POST /login HTTP/1.1" 200 567
192.168.1.3 - - [28/Jul/2024:12:36:56 +0000] "GET /home HTTP/1.1" 404 890
192.168.1.1 - - [28/Jul/2024:12:37:56 +0000] "GET /index.html HTTP/1.1" 200 1234
192.168.1.4 - - [28/Jul/2024:12:38:56 +0000] "GET /about HTTP/1.1" 200 432
192.168.1.2 - - [28/Jul/2024:12:39:56 +0000] "GET /index.html HTTP/1.1" 200 1234
EOL

# Создаем отчет с использованием awk (совместимый синтаксис)
awk '
BEGIN {
    print "Отчет о логе веб-сервера"
    print "=============="
}

{
    # Общее количество запросов
    total++
    
    # Уникальные IP-адреса
    ips[$1]++
    
    # Методы запросов - извлекаем метод из кавычек
    match($0, /"([A-Z]+) /)
    if (RLENGTH > 0) {
        method = substr($0, RSTART+1, RLENGTH-2)
        methods[method]++
    }
    
    # URL-адреса для GET запросов
    if (index($0, "GET") > 0) {
        match($0, /GET ([^ ]+)/)
        if (RLENGTH > 0) {
            url = substr($0, RSTART+4, RLENGTH-4)
            urls[url]++
        }
    }
}

END {
    # Общее количество запросов
    print "Общее количество запросов:    " total
    
    # Количество уникальных IP-адресов
    print "Количество уникальных IP-адресов:    " length(ips)
    
    # Количество запросов по методам
    print "\nКоличество запросов по методам:"
    for (m in methods) {
        print methods[m], m
    }
    
    # Самый популярный URL
    print ""
    max_count = 0
    max_url = ""
    for (u in urls) {
        if (urls[u] > max_count) {
            max_count = urls[u]
            max_url = u
        }
    }
    print "Самый популярный URL:    " max_count, max_url
}' access.log > report.txt

# Создаем файл скрипта, если его нет
if [ ! -f "analyze_logs.sh" ]; then
    # Копируем текущий скрипт в analyze_logs.sh
    cp "$0" "analyze_logs.sh" 2>/dev/null || {
        echo "#!/bin/bash" > analyze_logs.sh
        cat "$0" >> analyze_logs.sh
    }
fi

# Делаем скрипт исполняемым
chmod +x analyze_logs.sh 2>/dev/null || echo "Предупреждение: не удалось сделать analyze_logs.sh исполняемым"

echo "Отчет сохранен в файл report.txt"
cat report.txt
