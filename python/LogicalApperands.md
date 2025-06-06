# Пособие по программированию для новичков

## Введение
Это пособие предназначено для начинающих программистов, которые хотят изучить основы языка Python. Здесь вы найдете примеры работы со списками, строками, словарями, функциями, регулярными выражениями, а также основы логики, итераций и классов. Эти знания помогут вам решать задачи на платформах вроде HackerRank.

---

## Как использовать это пособие
1. **Изучите примеры кода**: Каждый раздел содержит примеры с комментариями, которые объясняют, как работают различные конструкции Python.
2. **Практикуйтесь**: Используйте предоставленные примеры как основу для написания собственного кода.
3. **Решайте задачи**: Применяйте изученные концепции для решения задач на HackerRank или других платформах.
4. **Экспериментируйте**: Меняйте код, добавляйте свои идеи и проверяйте, как это влияет на результат.

---

## Основные разделы

### 1. Списки (List)
- Используются для хранения упорядоченных данных.
- Методы позволяют добавлять, удалять, фильтровать и преобразовывать элементы.

#### Примеры:
```python
lst = [1, 2, 3]
empty = []
range_lst = list(range(1, 6))

# Доступ
lst[0]       # 1
lst[-1]      # 3
lst[1:3]     # [2, 3]

# Методы
lst.append(4)       # [1, 2, 3, 4]
lst.pop()           # 4, lst = [1, 2, 3]
lst.insert(0, 0)    # [0, 1, 2, 3]
lst.remove(2)       # [0, 1, 3]

3 in lst            # True
lst.reverse()       # [3, 1, 0]
sorted(lst)         # [0, 1, 3]
list(set(lst))      # Убирает дубликаты

[x * 2 for x in lst]       # [6, 2, 0]
[x for x in lst if x > 1]  # [3]
sum(lst)                   # Сумма элементов
```

### 2. Словари (Dictionary)
- Хранят данные в формате "ключ-значение".
- Полезны для создания маппинга или хранения состояния.

#### Примеры:
```python
d = {'a': 1, 'b': 2}
d['a']          # 1
d['c'] = 3
for k, v in d.items():
    print(f"{k}: {v}")
'b' in d        # True
```

### 3. Строки (String)
- Работа с текстом: преобразования, поиск, замена.

#### Примеры:
```python
s = "hello world"

len(s)               # 11
s.upper()            # "HELLO WORLD"
s.lower()            # "hello world"
s.split(" ")         # ["hello", "world"]
list(s)              # ['h', 'e', 'l', 'l', ...]
"wor" in s           # True
s.replace("world", "Python")  # "hello Python"
import re
bool(re.search(r"wo.ld", s))  # True
```

### 4. Условия и логика
- Используйте `if`, `elif`, `else` для ветвления логики.

#### Примеры:
```python
if x > 10:
    result = "big"
elif x > 5:
    result = "medium"
else:
    result = "small"

# Тернарный оператор
result = "yes" if x > 5 else "no"

def max_value(a, b):
    return a if a > b else b
```

### 5. Функции
- Создавайте функции для повторного использования кода.

#### Примеры:
```python
def max_value(a, b):
    return a if a > b else b

def greet(name="world"):
    print(f"Hello {name}!")
```

### 6. Регулярные выражения (Regex)
- Используются для поиска и проверки текста.

#### Примеры:
```python
import re
str = "OOM killer at 12:03"
bool(re.search(r"OOM|panic|timeout", str, re.IGNORECASE))  # True
re.search(r"\d+:\d+", str).group()                        # "12:03"
```

### 7. Итерации
- Перебирайте элементы списков с помощью `for`, `map`, `filter`.

#### Примеры:
```python
for i, val in enumerate(lst):
    print(f"{i}: {val}")

from itertools import pairwise
for a, b in pairwise(lst):
    if a < b:
        print(f"{a} < {b}")
```

### 8. Лямбды
- Анонимные функции для краткого описания логики.

#### Примеры:
```python
doubler = lambda x: x * 2
doubler(5)   # 10
```

### 9. Классы
- Используйте классы для создания структур данных.

#### Примеры:
```python
class TreeNode:
    def __init__(self, val):
        self.val = val
        self.left = None
        self.right = None
```

### 10. Полезные методы
- Методы для работы с комбинациями и перестановками.

#### Примеры:
```python
from itertools import permutations, combinations

list(permutations([1, 2, 3], 2))  # Все перестановки по 2
list(combinations([1, 2, 3], 2))  # Все комбинации по 2

["".join(p) for p in permutations("abc", 2)]
# ["ab", "ac", "ba", "bc", "ca", "cb"]
```

---

## Сравнительные операнды
| Оператор | Значение               | Пример    | Результат |
| -------- | ---------------------- | --------- | --------- |
| `==`     | Равно                  | `5 == 5`  | `True`    |
| `!=`     | Не равно               | `5 != 3`  | `True`    |
| `>`      | Больше                 | `5 > 3`   | `True`    |
| `<`      | Меньше                 | `3 < 5`   | `True`    |
| `>=`     | Больше или равно       | `5 >= 5`  | `True`    |
| `<=`     | Меньше или равно       | `3 <= 5`  | `True`    |
| `<=>`    | Spaceship (сортировка) | `3 <=> 5` | `-1`      |

---

## Логические операнды
| Оператор | Значение | Пример            | Результат    |
| -------- | -------- | ----------------- | ------------ |
| `and`    | И (AND)  | `x > 5 and x < 10` | `True/False` |
| `or`     | ИЛИ (OR) | `x < 3 or x > 7`  | `True/False` |
| `not`    | НЕ (NOT) | `not True`        | `False`      |

---

## Применение на HackerRank
1. **Чтение задачи**: Внимательно прочитайте условие задачи и определите, какие структуры данных и методы вам понадобятся.
2. **Разработка решения**:
        - Используйте списки для хранения данных.
        - Применяйте словари для подсчета или маппинга.
        - Используйте строки и регулярные выражения для обработки текстовых данных.
3. **Тестирование**: Проверьте решение на нескольких тестовых примерах.
4. **Оптимизация**: Если решение работает медленно, попробуйте использовать более эффективные методы, такие как `sum` или `itertools`.

---

## Советы для новичков
- Начинайте с простых задач, чтобы освоить базовые конструкции.
- Используйте встроенные методы Python, чтобы писать лаконичный и читаемый код.
- Не бойтесь ошибаться — каждая ошибка помогает вам учиться.
- Читайте документацию и экспериментируйте с кодом.

---

## Заключение
Это пособие — ваш первый шаг в изучении Python. Используйте его как справочник и инструмент для практики. Решайте задачи, экспериментируйте и совершенствуйте свои навыки программирования!
