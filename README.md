# AWS Practice Tech Skills  

Welcome to the **AWS Practice Tech Skills** repository! This repository is designed to help you become a top performer on platforms like HackerRank by mastering the basics of problem-solving using **Ruby**, **Python**, and **Bash**. The focus is on solving technical challenges without relying on external libraries, Wi-Fi, or AI assistance—just pure coding skills and standard libraries.  

## Goals  
- Develop strong problem-solving skills using **Ruby**, **Python**, and **Bash**.  
- Master AWS-related technical challenges.  
- Focus on input/output tasks and deployment scenarios.  
- Build confidence in solving tricky problems with minimal resources.  

---

## Ruby Practice  
### Key Topics:  
- Arrays: Manipulation, iteration, and transformations.  
- Strings: Parsing, formatting, and encoding.  
- Hashes: Key-value operations, merging, and filtering.  
- Methods: Writing reusable and efficient code.  
- Logic: Conditional statements and loops.  
- Expressions: Filtering and advanced logic.  

### Example Task:  
Write a Ruby script that reads a list of numbers from input, filters out even numbers, and prints the sum of the remaining odd numbers.  

---

## Python Practice  
### Key Topics:  
- Lists: Comprehensions, slicing, and transformations.  
- Strings: Manipulation, pattern matching, and formatting.  
- Dictionaries: Key-value operations and filtering.  
- Functions: Writing reusable and modular code.  
- Control Flow: Loops, conditionals, and exception handling.  

### Example Task:  
Write a Python script that reads a string, counts the frequency of each character, and prints the result in descending order of frequency.  

---

## Bash Practice  
### Key Topics:  
- File manipulation: Reading, writing, and processing files.  
- Text processing: Using `awk`, `sed`, and `grep`.  
- Scripting: Automating tasks with loops and conditionals.  
- System commands: Interacting with the shell and system utilities.  

### Example Task:  
Write a Bash script that takes a directory path as input, counts the number of files in the directory, and prints the result.  

---

## Deployment Practice  
- Learn how to deploy simple scripts to AWS Lambda.  
- Practice setting up AWS CLI for automation.  
- Explore basic IAM roles and permissions for secure deployments.  

---

### Next Steps  
1. Start with the `ruby/` and `python/` directories for beginner-friendly tasks.  
2. Gradually move to more advanced challenges.  
3. Test your solutions locally and deploy them to AWS for real-world practice.  

Happy coding! 🚀  


Важно! Ты должен очень чётко сформулировать речь и понимать, что именно проверяют на **техническом интервью в Amazon для SysDE** (или DevOps/SRE-инженеров): это **не просто кодинг**, а **коммуникация, мышление и продакшн-инженерия** в реальном времени. Перед вами представлена моя памятка о том, **как готовиться по каждому блоку**, чтобы соответствовать *"Amazon bar"*.

---

## **Полная стратегия подготовки:**

---

### **1. Coding — “Logical & Maintainable”**

#### Что важно:

* Читаемый, модульный код.
* Использование структур данных по назначению.
* Чёткое именование переменных.
* Умение объяснять, *почему ты так пишешь*.

#### Что тренировать:

* **Leetcode Medium+**: arrays, strings, trees, graphs, hashmaps, sliding window, dynamic programming.
* Писать код **в формате интервью**:

  * Комментарии голосом.
  * Решение сначала простое → потом оптимизация.

#### Пример:

> “Я бы хотел начать с наивного решения, чтобы убедиться, что мы на одной волне, а затем оптимизирую до O(n log n).”

---

### **2. Problem Solving — “Can deal with ambiguity”**

#### Amazon **любит неочевидные вопросы**:

* “Design a URL shortening system”
* “How would you scale log processing at 10M events/sec?”
* “How would you test and debug a flaky CI pipeline?”

#### Что делать:

* **Задавай уточняющие вопросы**:

  * Какой масштаб системы?
  * Какие допущения можно сделать?
  * Какие SLA у нас?

#### Amazon любит, если ты:

* **Не боишься сказать “я не знаю, но я выясню вот так”**
* Чётко структурируешь: сначала high-level, потом углубляешься.

---

### **3. Linux Troubleshooting**

#### Что могут спросить:

* Что ты сделаешь, если 100% CPU?
* Как ты отследишь утечку памяти?
* Как находишь runaway-процесс?

#### Что готовить:

* Работа с `top`, `htop`, `strace`, `lsof`, `journalctl`, `systemctl`, `du -sh`, `vmstat`, `iotop`
* Диагностика:

  * `kill -9 $(ps aux | grep badapp)`
  * `df -h`, `free -m`, `dmesg | tail`
* Логи: `grep`, `awk`, `tail -f`, лог-роутинг.

#### Практика:

* Логинись в EC2 instance, запускай "симулированные проблемы"
* Устрой себе mini-fire drill: “почему тормозит база?”, “куда ушло место?”

---

### **4. Incident Response, RCA, Monitoring**

#### Что рассказывать:

* Реальные инциденты: что произошло, как ты отреагировал.
* Что ты автоматизировал: алерты, self-healing, графаны.
* Как писал RCA: факты, причина, действия, follow-ups.

#### Готовь 2–3 примера:

* *"У нас легло хранилище, я отреагировал через alertmanager + понял, что была переполнена очередь Kafka. Я увеличил партиции, и потом добавил метрику lag через Prometheus."*

---

## **5. Поведенческий формат: STAR + Leadership Principles**

**Каждая история =**

* **S**ituation — где ты был, контекст.
* **T**ask — твоя задача/проблема.
* **A**ction — что ты делал конкретно.
* **R**esult — каков был результат, чему научился.

#### Какие принципы важны:

* **Dive Deep**
* **Ownership**
* **Bias for Action**
* **Are Right, A Lot**
* **Insist on the Highest Standards**

---

## **Шаблон подготовки к интервью**

| День | Что делать                                       |
| ---- | ------------------------------------------------ |
| 1    | 2 задачи с Leetcode + 1 STAR история             |
| 2    | Troubleshooting EC2 / Linux drills               |
| 3    | System design: “rate limiter”, “log pipeline”    |
| 4    | Написать RCA по фиктивному инциденту             |
| 5    | Повторить AWS basics (EC2, S3, CloudWatch, etc.) |

---

Если хочешь — можем:

* Разобрать системный дизайн прямо сейчас (например, "алертинг система Amazon-style"),
* Или подготовить твои поведенческие истории под каждый principle.
  Готов двигаться дальше?
