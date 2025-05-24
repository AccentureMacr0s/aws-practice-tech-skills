# Ниже приведены примеры для каждой из задач, описанных выше.

# 1. Массивы (Array)
# Задача 1: Найти сумму всех элементов массива.
array = [1, 2, 3, 4, 5]
puts array.sum

# Задача 2: Удалить все четные числа из массива.
array = [1, 2, 3, 4, 5]
puts array.reject(&:even?)

# Задача 3: Найти максимальное значение в массиве.
array = [1, 2, 3, 4, 5]
puts array.max

# Задача 4: Перевернуть массив.
array = [1, 2, 3, 4, 5]
puts array.reverse

# Задача 5: Удалить дубликаты из массива.
array = [1, 2, 2, 3, 4, 4, 5]
puts array.uniq

# 2. Хэши (Hash)
# Задача 6: Добавить новый ключ-значение в хэш.
hash = { a: 1, b: 2 }
hash[:c] = 3
puts hash

# Задача 7: Найти значение по ключу.
hash = { a: 1, b: 2 }
puts hash[:a]

# Задача 8: Удалить ключ из хэша.
hash = { a: 1, b: 2 }
hash.delete(:a)
puts hash

# Задача 9: Перебрать все ключи и значения.
hash = { a: 1, b: 2 }
hash.each { |key, value| puts "#{key}: #{value}" }

# Задача 10: Проверить наличие ключа.
hash = { a: 1, b: 2 }
puts hash.key?(:a)

# 3. Строки (String)
# Задача 11: Преобразовать строку в верхний регистр.
string = "hello"
puts string.upcase

# Задача 12: Найти подстроку.
string = "hello world"
puts string.include?("world")

# Задача 13: Разделить строку на массив слов.
string = "hello world"
puts string.split

# Задача 14: Заменить слово в строке.
string = "hello world"
puts string.gsub("world", "Ruby")

# Задача 15: Проверить соответствие регулярному выражению.
string = "hello123"
puts string.match?(/\d+/)

# 4. Условия и логика
# Задача 16: Определить, является ли число положительным.
number = 5
puts number.positive?

# Задача 17: Использовать тернарный оператор.
number = 5
puts number.even? ? "Even" : "Odd"

# Задача 18: Найти большее из двух чисел.
a, b = 5, 10
puts [a, b].max

# Задача 19: Проверить диапазон числа.
number = 5
puts (1..10).include?(number)

# Задача 20: Использовать логическое "ИЛИ".
a, b = nil, 10
puts a || b

# 5. Методы
# Задача 21: Написать метод для вычисления факториала.
def factorial(n)
    (1..n).reduce(1, :*)
end
puts factorial(5)

# Задача 22: Написать метод с параметром по умолчанию.
def greet(name = "Guest")
    "Hello, #{name}!"
end
puts greet
puts greet("Alice")

# Задача 23: Написать метод для проверки четности числа.
def even?(number)
    number.even?
end
puts even?(4)

# Задача 24: Написать метод для подсчета гласных в строке.
def count_vowels(string)
    string.count("aeiouAEIOU")
end
puts count_vowels("hello")

# Задача 25: Написать метод для проверки палиндрома.
def palindrome?(string)
    string == string.reverse
end
puts palindrome?("racecar")

# 6. Регулярные выражения (Regex)
# Задача 26: Найти все числа в строке.
string = "There are 3 apples and 5 oranges."
puts string.scan(/\d+/)

# Задача 27: Проверить, начинается ли строка с определенного слова.
string = "Hello world"
puts string.start_with?("Hello")

# Задача 28: Заменить все цифры на звездочки.
string = "My number is 12345"
puts string.gsub(/\d/, "*")

# Задача 29: Найти время в формате HH:MM.
string = "The time is 14:30 now."
puts string.scan(/\b\d{2}:\d{2}\b/)

# Задача 30: Проверить, содержит ли строка слово из списка.
string = "I love programming in Ruby."
words = ["Ruby", "Python", "Java"]
puts words.any? { |word| string.include?(word) }
